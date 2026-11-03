import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { PHOTO_EXTENSIONS } from './photoTypes.js';
import { saveAll } from './saveAll.js';

/** Photos on local disk, served by Express at /uploads. For development. */
export function createLocalPhotoStorage(uploadsDir) {
  fs.mkdirSync(uploadsDir, { recursive: true });

  // basename() guards against a stored reference ever escaping the uploads folder.
  const pathFor = (ref) => path.join(uploadsDir, path.basename(ref));

  async function deleteRefs(refs = []) {
    await Promise.all(refs.map((ref) => fs.promises.rm(pathFor(ref), { force: true })));
  }

  return {
    /** Express serves this folder at /uploads. */
    localDirectory: uploadsDir,

    /** Returns one reference (a file name) per file. */
    save(files) {
      return saveAll(
        files,
        async (file) => {
          const fileName = `${crypto.randomUUID()}${PHOTO_EXTENSIONS[file.mimetype]}`;
          await fs.promises.writeFile(pathFor(fileName), file.buffer);
          return fileName;
        },
        deleteRefs,
      );
    },

    urlFor(ref) {
      return `/uploads/${ref}`;
    },

    delete: deleteRefs,
  };
}
