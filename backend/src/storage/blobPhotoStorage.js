import crypto from 'node:crypto';
import { del, put } from '@vercel/blob';
import { HttpError } from '../utils/httpError.js';
import { PHOTO_EXTENSIONS } from './photoTypes.js';
import { saveAll } from './saveAll.js';

/** Photos in Vercel Blob. The stored reference is the blob's public URL. */
export function createBlobPhotoStorage({ token }) {
  async function deleteRefs(refs = []) {
    if (refs.length === 0 || !token) return;
    await del(refs, { token });
  }

  return {
    localDirectory: undefined,

    /** Returns one reference (a public https URL) per file. */
    save(files) {
      if (files.length === 0) return Promise.resolve([]);
      if (!token) {
        throw new HttpError(503, 'Photo uploads are not set up on the server yet (BLOB_READ_WRITE_TOKEN is missing).');
      }
      return saveAll(
        files,
        async (file) => {
          const pathname = `listings/${crypto.randomUUID()}${PHOTO_EXTENSIONS[file.mimetype]}`;
          const blob = await put(pathname, file.buffer, { access: 'public', contentType: file.mimetype, token });
          return blob.url;
        },
        deleteRefs,
      );
    },

    urlFor(ref) {
      return ref;
    },

    delete: deleteRefs,
  };
}
