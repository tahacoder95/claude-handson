import path from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const isVercel = Boolean(process.env.VERCEL);

export const config = {
  isVercel,
  port: Number(process.env.PORT ?? 3000),
  host: process.env.HOST ?? '0.0.0.0',

  // Turso (hosted SQLite) in production; a local SQLite file for development.
  databaseUrl: process.env.TURSO_DATABASE_URL ?? `file:${path.join(rootDir, 'data', 'market.db')}`,
  databaseAuthToken: process.env.TURSO_AUTH_TOKEN,

  // Vercel Blob when a token is present (or on Vercel); local disk for development.
  blobToken: process.env.BLOB_READ_WRITE_TOKEN,
  uploadsDir: process.env.UPLOADS_DIR ?? path.join(rootDir, 'uploads'),

  // Fill an empty database with the demo accounts and listings. Set SEED_DEMO_DATA=false to disable.
  seedDemoData: process.env.SEED_DEMO_DATA !== 'false',

  maxPhotos: 3,
  // Vercel caps request bodies at 4.5 MB, so keep each photo (and the 3 together) under that.
  // The iOS app compresses photos to well under 1 MB.
  maxPhotoBytes: 4 * 1024 * 1024,
};

/** Fails fast with a readable message when production settings are missing. */
export function assertProductionConfig() {
  if (isVercel && !process.env.TURSO_DATABASE_URL) {
    throw new Error('TURSO_DATABASE_URL is not set. Connect a Turso database to this Vercel project.');
  }
}
