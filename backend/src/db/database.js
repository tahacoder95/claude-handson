import fs from 'node:fs';
import path from 'node:path';
import Database from 'better-sqlite3';
import { migrate } from './migrate.js';

/**
 * Opens (and migrates) the SQLite database. Pass ':memory:' for tests.
 */
export function openDatabase(filePath) {
  if (filePath !== ':memory:') {
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
  }
  const db = new Database(filePath);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');
  migrate(db);
  return db;
}
