import fs from 'node:fs';
import path from 'node:path';
import { createClient } from '@libsql/client';
import { migrate } from './migrate.js';

function ensureLocalDirectory(url) {
  if (!url.startsWith('file:')) return;
  const filePath = url.slice('file:'.length);
  fs.mkdirSync(path.dirname(path.resolve(filePath)), { recursive: true });
}

function toPlainRows(result) {
  return result.rows.map((row) => Object.fromEntries(result.columns.map((column) => [column, row[column]])));
}

/**
 * Opens (and migrates) the database: a `file:` URL locally, a `libsql://` URL for Turso.
 * Returns a small async wrapper so repositories don't depend on the driver's API.
 */
export async function openDatabase({ url, authToken }) {
  ensureLocalDirectory(url);
  const client = createClient({ url, authToken });
  await migrate(client);

  const all = async (sql, args = []) => toPlainRows(await client.execute({ sql, args }));

  return {
    all,

    async get(sql, args = []) {
      return (await all(sql, args))[0];
    },

    async run(sql, args = []) {
      const result = await client.execute({ sql, args });
      return {
        lastInsertRowid: result.lastInsertRowid === undefined ? undefined : Number(result.lastInsertRowid),
        changes: result.rowsAffected,
      };
    },

    /** Runs `[sql, args]` statements atomically in one round trip. */
    async batch(statements) {
      if (statements.length === 0) return;
      await client.batch(statements.map(([sql, args = []]) => ({ sql, args })), 'write');
    },

    close() {
      client.close();
    },
  };
}
