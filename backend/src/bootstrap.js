import { createApp } from './app.js';
import { assertProductionConfig, config } from './config.js';
import { openDatabase } from './db/database.js';
import { DEMO_COUNTS, DEMO_PASSWORD, seedIfEmpty } from './db/seed.js';
import { createPhotoStorage } from './storage/createPhotoStorage.js';

/** Builds the app from environment config. Shared by the local server and the Vercel function. */
export async function createConfiguredApp() {
  assertProductionConfig();
  const db = await openDatabase({ url: config.databaseUrl, authToken: config.databaseAuthToken });
  if (config.seedDemoData && (await seedIfEmpty(db))) {
    console.log(`Seeded ${DEMO_COUNTS.users} demo users and ${DEMO_COUNTS.listings} listings (password "${DEMO_PASSWORD}").`);
  }
  const app = createApp({
    db,
    photoStorage: createPhotoStorage(config),
    maxPhotos: config.maxPhotos,
    maxPhotoBytes: config.maxPhotoBytes,
    logRequests: true,
  });
  return { app, db };
}
