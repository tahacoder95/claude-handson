// Resets the database to demo data: 4 accounts (password "demo123") and 16 listings.
// Usage: npm run seed
import fs from 'node:fs';
import path from 'node:path';
import bcrypt from 'bcryptjs';
import { config } from '../src/config.js';
import { openDatabase } from '../src/db/database.js';

const PASSWORD = 'demo123';

const USERS = [
  { username: 'omar', displayName: 'Omar Haddad', phone: '+971 50 987 6543', location: 'Al Reem Island, Abu Dhabi' },
  { username: 'aisha', displayName: 'Aisha Khan', phone: '+971 50 123 4567', location: 'Dubai Marina, Dubai' },
  { username: 'sara', displayName: 'Sara Ali', phone: '+971 55 234 5678', location: 'Al Majaz, Sharjah' },
  { username: 'ravi', displayName: 'Ravi Menon', phone: '+971 52 345 6789', location: 'Al Barsha, Dubai' },
];

// [seller, title, description, price, category, condition, daysAgo, status]
const LISTINGS = [
  ['aisha', 'iPhone 14 · 128GB, Midnight', 'Used for eight months, always in a case with a screen protector. Battery health 91%. Comes with the original box and cable. No scratches or dents.', 1950, 'electronics', 'like_new', 2, 'active'],
  ['aisha', 'Nespresso Vertuo coffee machine', 'Works perfectly, descaled last month. Includes the milk frother and a sleeve of pods.', 380, 'home', 'like_new', 6, 'active'],
  ['aisha', 'Yoga mat and resistance bands', 'Brand new 6 mm mat plus a set of five resistance bands. Never used, still in the bag.', 95, 'sports', 'new', 8, 'active'],
  ['sara', 'IKEA 3-seat sofa, grey', 'Comfortable KIVIK sofa with washable covers. Pet-free and smoke-free home. You collect.', 900, 'home', 'good', 3, 'active'],
  ['sara', 'Wool coat, size M', 'Camel wool-blend coat, worn twice. Perfect for travel to colder places.', 220, 'fashion', 'like_new', 4, 'active'],
  ['sara', 'Bundle of 6 paperbacks', 'Mix of fiction and self-help, all in good condition. Happy to list the titles on request.', 120, 'books', 'good', 6, 'active'],
  ['sara', 'Nike Air Jordan 1, size 42', 'Unworn, original box and receipt. Bought the wrong size.', 650, 'fashion', 'new', 1, 'active'],
  ['ravi', 'Toyota Corolla 2019, 62,000 km', 'Single owner, full service history at the agency. GCC specs, no accidents.', 48500, 'vehicles', 'good', 5, 'active'],
  ['ravi', 'Road bike, 54 cm frame', 'Aluminium frame, Shimano 105 groupset. New tyres fitted in September.', 1400, 'sports', 'good', 7, 'active'],
  ['ravi', 'Samsung 55" 4K smart TV', 'Crisp picture, comes with the remote and wall bracket. Moving out sale.', 1100, 'electronics', 'good', 3, 'active'],
  ['ravi', 'Dining table with 4 chairs', 'Solid wood, a few marks on the tabletop. Seats four comfortably.', 750, 'home', 'fair', 10, 'active'],
  ['omar', 'Trek Marlin 7 mountain bike', 'Size M, hydraulic disc brakes. Serviced last month, ready to ride.', 1850, 'sports', 'good', 3, 'active'],
  ['omar', 'PlayStation 5 Slim + 2 controllers', 'Disc edition with two DualSense controllers. Selling because I barely play.', 1700, 'electronics', 'like_new', 5, 'active'],
  ['omar', 'Leather office chair', 'Ergonomic chair with lumbar support. Adjustable height and arms.', 450, 'home', 'good', 9, 'active'],
  ['omar', 'Standing desk, oak top', 'Electric sit-stand desk, 140 × 70 cm.', 650, 'home', 'good', 21, 'sold'],
  ['omar', 'AirPods Pro (2nd gen)', 'With charging case and spare tips.', 500, 'electronics', 'like_new', 30, 'sold'],
];

function isoDaysAgo(days) {
  return new Date(Date.now() - days * 86_400_000).toISOString().replace(/\.\d{3}Z$/, 'Z');
}

function clearUploads() {
  fs.mkdirSync(config.uploadsDir, { recursive: true });
  for (const name of fs.readdirSync(config.uploadsDir)) {
    if (name !== '.gitkeep') fs.rmSync(path.join(config.uploadsDir, name), { force: true });
  }
}

const db = openDatabase(config.databasePath);
const passwordHash = bcrypt.hashSync(PASSWORD, 10);

db.transaction(() => {
  db.exec(`
    DELETE FROM listing_photos;
    DELETE FROM listings;
    DELETE FROM sessions;
    DELETE FROM users;
    DELETE FROM sqlite_sequence;
  `);

  const insertUser = db.prepare(
    'INSERT INTO users (username, password_hash, display_name, phone, created_at) VALUES (?, ?, ?, ?, ?)',
  );
  const insertListing = db.prepare(`
    INSERT INTO listings (seller_id, title, description, price_aed, category, condition, location, status, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`);

  const users = new Map();
  for (const user of USERS) {
    const { lastInsertRowid } = insertUser.run(user.username, passwordHash, user.displayName, user.phone, isoDaysAgo(120));
    users.set(user.username, { id: lastInsertRowid, location: user.location });
  }

  for (const [seller, title, description, price, category, condition, daysAgo, status] of LISTINGS) {
    const { id, location } = users.get(seller);
    const createdAt = isoDaysAgo(daysAgo);
    insertListing.run(id, title, description, price, category, condition, location, status, createdAt, createdAt);
  }
})();

clearUploads();
db.close();

console.log(`Seeded ${USERS.length} users and ${LISTINGS.length} listings.`);
console.log(`Sign in with any of: ${USERS.map((user) => user.username).join(', ')} — password "${PASSWORD}".`);
