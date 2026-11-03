import path from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export const config = {
  port: Number(process.env.PORT ?? 3000),
  host: process.env.HOST ?? '0.0.0.0',
  databasePath: process.env.DATABASE_PATH ?? path.join(rootDir, 'data', 'market.db'),
  uploadsDir: process.env.UPLOADS_DIR ?? path.join(rootDir, 'uploads'),
  maxPhotos: 3,
  maxPhotoBytes: 5 * 1024 * 1024,
};
