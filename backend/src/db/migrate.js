// Timestamps are stored as ISO-8601 without fractional seconds so iOS's
// JSONDecoder `.iso8601` strategy can decode them directly.
const NOW = "(strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))";

const SCHEMA = `
CREATE TABLE IF NOT EXISTS users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  username      TEXT NOT NULL UNIQUE COLLATE NOCASE,
  password_hash TEXT NOT NULL,
  display_name  TEXT NOT NULL,
  phone         TEXT NOT NULL,
  created_at    TEXT NOT NULL DEFAULT ${NOW}
);

CREATE TABLE IF NOT EXISTS sessions (
  token      TEXT PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TEXT NOT NULL DEFAULT ${NOW}
);

CREATE TABLE IF NOT EXISTS listings (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  seller_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price_aed   INTEGER NOT NULL CHECK (price_aed > 0),
  category    TEXT NOT NULL,
  condition   TEXT NOT NULL,
  location    TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'sold')),
  created_at  TEXT NOT NULL DEFAULT ${NOW},
  updated_at  TEXT NOT NULL DEFAULT ${NOW}
);

CREATE INDEX IF NOT EXISTS idx_listings_status_created ON listings (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_listings_seller ON listings (seller_id);

CREATE TABLE IF NOT EXISTS listing_photos (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  listing_id INTEGER NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
  file_name  TEXT NOT NULL,
  position   INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_photos_listing ON listing_photos (listing_id, position);
`;

export function migrate(db) {
  db.exec(SCHEMA);
}

export const SQL_NOW = NOW;
