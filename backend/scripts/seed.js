// Resets the database to demo data: 4 accounts (password "demo123") and 16 listings.
// Uses TURSO_DATABASE_URL / TURSO_AUTH_TOKEN when set, otherwise the local data/market.db.
// Usage: npm run seed
import { config } from '../src/config.js';
import { openDatabase } from '../src/db/database.js';
import { DEMO_COUNTS, DEMO_PASSWORD, resetToDemoData } from '../src/db/seed.js';
import { createPhotoStorage } from '../src/storage/createPhotoStorage.js';

const db = await openDatabase({ url: config.databaseUrl, authToken: config.databaseAuthToken });
const removedPhotos = await resetToDemoData(db);
await createPhotoStorage(config).delete(removedPhotos);
db.close();

console.log(`Seeded ${DEMO_COUNTS.users} users and ${DEMO_COUNTS.listings} listings in ${config.databaseUrl.split('?')[0]}.`);
console.log(`Sign in with any of: omar, aisha, sara, ravi — password "${DEMO_PASSWORD}".`);
