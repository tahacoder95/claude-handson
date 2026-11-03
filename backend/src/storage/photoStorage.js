import fs from 'node:fs';
import path from 'node:path';

/** Photo files on local disk, served by Express at /uploads. */
export function createPhotoStorage(uploadsDir) {
  fs.mkdirSync(uploadsDir, { recursive: true });

  return {
    directory: uploadsDir,

    deleteFiles(fileNames = []) {
      for (const fileName of fileNames) {
        // basename() guards against a stored name ever escaping the uploads folder.
        fs.rm(path.join(uploadsDir, path.basename(fileName)), { force: true }, () => {});
      }
    },
  };
}
