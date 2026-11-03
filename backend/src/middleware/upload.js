import multer from 'multer';
import { PHOTO_EXTENSIONS } from '../storage/photoTypes.js';
import { HttpError } from '../utils/httpError.js';

/**
 * Multipart parser for listing photos (field name `photos`). Files are kept in memory and handed
 * to photo storage by the service, so nothing is written to the (read-only) serverless disk.
 */
export function createPhotoUpload({ maxPhotos, maxPhotoBytes }) {
  return multer({
    storage: multer.memoryStorage(),
    limits: { files: maxPhotos, fileSize: maxPhotoBytes },
    fileFilter: (_req, file, callback) => {
      if (PHOTO_EXTENSIONS[file.mimetype]) {
        callback(null, true);
      } else {
        callback(new HttpError(400, 'Photos must be JPEG, PNG, HEIC or WebP images.'));
      }
    },
  }).array('photos', maxPhotos);
}
