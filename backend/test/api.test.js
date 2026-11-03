import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { after, before, describe, test } from 'node:test';
import { createApp } from '../src/app.js';
import { openDatabase } from '../src/db/database.js';
import { seedIfEmpty } from '../src/db/seed.js';
import { createLocalPhotoStorage } from '../src/storage/localPhotoStorage.js';

// A 1×1 transparent PNG.
const PNG_BYTES = Buffer.from(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  'base64',
);

let server;
let baseURL;
let db;
let tempDir;
let uploadsDir;

async function api(method, route, { token, json, form } = {}) {
  const headers = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  let body;
  if (json) {
    headers['Content-Type'] = 'application/json';
    body = JSON.stringify(json);
  } else if (form) {
    body = form;
  }
  const response = await fetch(`${baseURL}${route}`, { method, headers, body });
  const text = await response.text();
  return { status: response.status, body: text ? JSON.parse(text) : null };
}

function listingForm(fields, photoCount = 0) {
  const form = new FormData();
  for (const [key, value] of Object.entries(fields)) form.append(key, String(value));
  for (let index = 0; index < photoCount; index += 1) {
    form.append('photos', new Blob([PNG_BYTES], { type: 'image/png' }), `photo-${index}.png`);
  }
  return form;
}

const SOFA = {
  title: 'Grey sofa',
  description: 'Three seats, washable covers.',
  price_aed: 900,
  category: 'home',
  condition: 'good',
  location: 'Al Majaz, Sharjah',
};

before(async () => {
  tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'purecs-test-'));
  uploadsDir = path.join(tempDir, 'uploads');
  db = await openDatabase({ url: `file:${path.join(tempDir, 'test.db')}` });
  const photoStorage = createLocalPhotoStorage(uploadsDir);
  const app = createApp({ db, photoStorage, maxPhotos: 3, maxPhotoBytes: 1024 * 1024 });
  await new Promise((resolve) => {
    server = app.listen(0, '127.0.0.1', resolve);
  });
  baseURL = `http://127.0.0.1:${server.address().port}`;
});

after(() => {
  server.close();
  db.close();
  fs.rmSync(tempDir, { recursive: true, force: true });
});

describe('PureCS Market API', () => {
  let sellerToken;
  let buyerToken;
  let listing;

  test('register creates an account and returns a token', async () => {
    const response = await api('POST', '/auth/register', {
      json: { username: 'Sara', password: 'demo123', display_name: 'Sara Ali', phone: '+971 55 234 5678' },
    });
    assert.equal(response.status, 201);
    assert.ok(response.body.token);
    assert.equal(response.body.user.username, 'sara');
    assert.equal(response.body.user.password_hash, undefined);
    sellerToken = response.body.token;
  });

  test('register rejects a taken username and invalid input', async () => {
    const taken = await api('POST', '/auth/register', {
      json: { username: 'sara', password: 'demo123', display_name: 'Other', phone: '+971 50 000 0000' },
    });
    assert.equal(taken.status, 409);

    const invalid = await api('POST', '/auth/register', {
      json: { username: 'x', password: '1', display_name: '', phone: 'abc' },
    });
    assert.equal(invalid.status, 400);
    assert.match(invalid.body.error, /Username/);
  });

  test('login checks the password', async () => {
    await api('POST', '/auth/register', {
      json: { username: 'omar', password: 'demo123', display_name: 'Omar Haddad', phone: '+971 50 987 6543' },
    });
    const wrong = await api('POST', '/auth/login', { json: { username: 'omar', password: 'nope' } });
    assert.equal(wrong.status, 401);

    const right = await api('POST', '/auth/login', { json: { username: 'OMAR', password: 'demo123' } });
    assert.equal(right.status, 200);
    buyerToken = right.body.token;
  });

  test('browsers get CORS headers and preflights are answered', async () => {
    const preflight = await fetch(`${baseURL}/listings`, {
      method: 'OPTIONS',
      headers: { Origin: 'http://localhost:5173', 'Access-Control-Request-Method': 'POST' },
    });
    assert.equal(preflight.status, 204);
    assert.equal(preflight.headers.get('access-control-allow-origin'), '*');
    assert.match(preflight.headers.get('access-control-allow-headers'), /Authorization/);

    const health = await fetch(`${baseURL}/health`, { headers: { Origin: 'http://localhost:5173' } });
    assert.equal(health.headers.get('access-control-allow-origin'), '*');
  });

  test('listing routes require a token', async () => {
    const response = await api('GET', '/listings');
    assert.equal(response.status, 401);
    assert.equal(response.body.error, 'Please sign in again.');
  });

  test('a seller creates a listing with a photo', async () => {
    const response = await api('POST', '/listings', { token: sellerToken, form: listingForm(SOFA, 1) });
    assert.equal(response.status, 201);
    assert.equal(response.body.title, SOFA.title);
    assert.equal(response.body.price_aed, 900);
    assert.equal(response.body.status, 'active');
    assert.equal(response.body.photos.length, 1);
    listing = response.body;

    const photo = await fetch(`${baseURL}${listing.photos[0].url}`);
    assert.equal(photo.status, 200);
  });

  test('creating a listing validates fields and photo count', async () => {
    const badPrice = await api('POST', '/listings', { token: sellerToken, form: listingForm({ ...SOFA, price_aed: 0 }) });
    assert.equal(badPrice.status, 400);
    assert.equal(badPrice.body.error, 'Enter a price above 0.');

    const tooMany = await api('POST', '/listings', { token: sellerToken, form: listingForm(SOFA, 4) });
    assert.equal(tooMany.status, 400);
    assert.equal(tooMany.body.error, 'You can add up to 3 photos.');
  });

  test('the buyer feed shows other sellers, filters and sorts', async () => {
    await api('POST', '/listings', {
      token: sellerToken,
      form: listingForm({ ...SOFA, title: 'iPhone 14', price_aed: 1950, category: 'electronics' }),
    });

    const ownFeed = await api('GET', '/listings', { token: sellerToken });
    assert.equal(ownFeed.body.length, 0, 'sellers never see their own listings in the feed');

    const feed = await api('GET', '/listings?sort=price_asc', { token: buyerToken });
    assert.deepEqual(feed.body.map((item) => item.price_aed), [900, 1950]);
    assert.equal(feed.body[0].seller_phone, undefined, 'phone numbers only appear on the detail endpoint');

    const electronics = await api('GET', '/listings?category=electronics', { token: buyerToken });
    assert.deepEqual(electronics.body.map((item) => item.title), ['iPhone 14']);

    const search = await api('GET', '/listings?q=sofa', { token: buyerToken });
    assert.deepEqual(search.body.map((item) => item.title), ['Grey sofa']);
  });

  test('listing detail includes the seller phone', async () => {
    const response = await api('GET', `/listings/${listing.id}`, { token: buyerToken });
    assert.equal(response.status, 200);
    assert.equal(response.body.seller_name, 'Sara Ali');
    assert.equal(response.body.seller_phone, '+971 55 234 5678');

    const missing = await api('GET', '/listings/99999', { token: buyerToken });
    assert.equal(missing.status, 404);
  });

  test('only the owner can update, and sold listings leave the feed', async () => {
    const notOwner = await api('PATCH', `/listings/${listing.id}`, { token: buyerToken, json: { status: 'sold' } });
    assert.equal(notOwner.status, 403);

    const sold = await api('PATCH', `/listings/${listing.id}`, {
      token: sellerToken,
      json: { status: 'sold', price_aed: 850 },
    });
    assert.equal(sold.status, 200);
    assert.equal(sold.body.status, 'sold');
    assert.equal(sold.body.price_aed, 850);
    assert.equal(sold.body.title, SOFA.title, 'fields not sent stay unchanged');

    const feed = await api('GET', '/listings', { token: buyerToken });
    assert.ok(!feed.body.some((item) => item.id === listing.id));

    const mine = await api('GET', '/me/listings', { token: sellerToken });
    assert.ok(mine.body.some((item) => item.id === listing.id && item.status === 'sold'));
  });

  test('updating can swap photos', async () => {
    const response = await api('PATCH', `/listings/${listing.id}`, {
      token: sellerToken,
      form: listingForm({ remove_photo_ids: String(listing.photos[0].id) }, 2),
    });
    assert.equal(response.status, 200);
    assert.equal(response.body.photos.length, 2);
    assert.ok(!response.body.photos.some((photo) => photo.id === listing.photos[0].id));
    listing = response.body;
  });

  test('deleting removes the listing and its photo files', async () => {
    const fileName = path.basename(listing.photos[0].url);
    assert.ok(fs.existsSync(path.join(uploadsDir, fileName)));

    const response = await api('DELETE', `/listings/${listing.id}`, { token: sellerToken });
    assert.equal(response.status, 204);

    const detail = await api('GET', `/listings/${listing.id}`, { token: buyerToken });
    assert.equal(detail.status, 404);

    assert.ok(!fs.existsSync(path.join(uploadsDir, fileName)));
  });

  test('seeding only happens on an empty database', async () => {
    assert.equal(await seedIfEmpty(db), false, 'accounts already exist');

    const emptyDir = fs.mkdtempSync(path.join(os.tmpdir(), 'purecs-seed-'));
    const emptyDb = await openDatabase({ url: `file:${path.join(emptyDir, 'seed.db')}` });
    assert.equal(await seedIfEmpty(emptyDb), true);
    assert.equal(await seedIfEmpty(emptyDb), false, 'second call is a no-op');
    const { count } = await emptyDb.get('SELECT COUNT(*) AS count FROM listings');
    assert.equal(count, 16);
    emptyDb.close();
    fs.rmSync(emptyDir, { recursive: true, force: true });
  });

  test('logout invalidates the token', async () => {
    const logout = await api('POST', '/auth/logout', { token: buyerToken });
    assert.equal(logout.status, 204);

    const me = await api('GET', '/me', { token: buyerToken });
    assert.equal(me.status, 401);
  });
});
