import multer from 'multer';
import { HttpError } from '../utils/httpError.js';

const MULTER_MESSAGES = {
  LIMIT_FILE_SIZE: 'Each photo must be 5 MB or smaller.',
  LIMIT_FILE_COUNT: 'You can add up to 3 photos.',
  LIMIT_UNEXPECTED_FILE: 'You can add up to 3 photos.',
};

/** Turns any error into `{ "error": "message" }` with the right status code. */
export function createErrorHandler({ photoStorage }) {
  // Express recognises error handlers by their four-argument signature.
  // eslint-disable-next-line no-unused-vars
  return function errorHandler(error, req, res, _next) {
    // Uploaded files belong to a request that failed: don't leave them on disk.
    if (req.files?.length) {
      photoStorage.deleteFiles(req.files.map((file) => file.filename));
    }

    if (error instanceof HttpError) {
      res.status(error.status).json({ error: error.message });
    } else if (error instanceof multer.MulterError) {
      res.status(400).json({ error: MULTER_MESSAGES[error.code] ?? 'Could not read the uploaded photos.' });
    } else if (error?.type === 'entity.parse.failed') {
      res.status(400).json({ error: 'The request body is not valid JSON.' });
    } else {
      console.error(error);
      res.status(500).json({ error: 'Something went wrong on the server.' });
    }
  };
}
