import assert from 'node:assert/strict';
import fs from 'node:fs';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import { after, before, test } from 'node:test';

// Exercises api/index.js the way Vercel calls it: a plain (req, res) handler, configured only by
// environment variables, seeding an empty database on first use.
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'purecs-vercel-'));
process.env.TURSO_DATABASE_URL = `file:${path.join(tempDir, 'vercel.db')}`;
process.env.UPLOADS_DIR = path.join(tempDir, 'uploads');

let server;
let baseURL;

before(async () => {
  const { default: handler } = await import('../api/index.js');
  await new Promise((resolve) => {
    server = http.createServer(handler).listen(0, '127.0.0.1', resolve);
  });
  baseURL = `http://127.0.0.1:${server.address().port}`;
});

after(() => {
  server.close();
  fs.rmSync(tempDir, { recursive: true, force: true });
});

test('the Vercel handler serves the API and seeds demo data', async () => {
  const health = await fetch(`${baseURL}/health`);
  assert.equal(health.status, 200);
  assert.deepEqual(await health.json(), { status: 'ok' });

  const login = await fetch(`${baseURL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'omar', password: 'demo123' }),
  });
  assert.equal(login.status, 200);
  const { token } = await login.json();

  const feed = await fetch(`${baseURL}/listings`, { headers: { Authorization: `Bearer ${token}` } });
  assert.equal(feed.status, 200);
  assert.equal((await feed.json()).length, 11, "omar sees everyone else's active listings");

  const missing = await fetch(`${baseURL}/nope`);
  assert.equal(missing.status, 404);
  assert.deepEqual(await missing.json(), { error: 'Not found.' });
});
