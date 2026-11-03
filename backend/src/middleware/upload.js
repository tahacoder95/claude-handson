import crypto from 'node:crypto';
import multer from 'multer';
import { HttpError } from '../utils/httpError.js';

const EXTENSIONS = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/heic': '.heic',
  'image/webp': '.webp',
};

/** Multipart parser for listing photos (field name `photos`). */
export function createPhotoUpload({ uploadsDir, maxPhotos, maxPhotoBytes }) {
  const storage = multer.diskStorage({
    destination: uploadsDir,
    filename: (_req, file, callback) => callback(null, `${crypto.randomUUID()}${EXTENSIONS[file.mimetype]}`),
  });

  return multer({
    storage,
    limits: { files: maxPhotos, fileSize: maxPhotoBytes },
    fileFilter: (_req, file, callback) => {
      if (EXTENSIONS[file.mimetype]) {
        callback(null, true);
      } else {
        callback(new HttpError(400, 'Photos must be JPEG, PNG, HEIC or WebP images.'));
      }
    },
  }).array('photos', maxPhotos);
}
