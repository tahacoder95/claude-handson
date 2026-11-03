import { createBlobPhotoStorage } from './blobPhotoStorage.js';
import { createLocalPhotoStorage } from './localPhotoStorage.js';

/**
 * Vercel Blob when a token is configured or when running on Vercel (whose disk is read-only);
 * otherwise local disk. Both expose `save(files)`, `urlFor(ref)`, `delete(refs)`.
 */
export function createPhotoStorage({ blobToken, isVercel, uploadsDir }) {
  if (blobToken || isVercel) {
    return createBlobPhotoStorage({ token: blobToken });
  }
  return createLocalPhotoStorage(uploadsDir);
}
