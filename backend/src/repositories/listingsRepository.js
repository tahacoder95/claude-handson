import { SQL_NOW } from '../db/migrate.js';

const LISTING_COLUMNS = `
  l.id, l.seller_id, u.display_name AS seller_name, u.phone AS seller_phone,
  l.title, l.description, l.price_aed, l.category, l.condition, l.location, l.status,
  l.created_at, l.updated_at`;

const FROM_LISTINGS = 'FROM listings l JOIN users u ON u.id = l.seller_id';

const ORDER_BY = {
  newest: 'l.created_at DESC, l.id DESC',
  price_asc: 'l.price_aed ASC, l.id DESC',
  price_desc: 'l.price_aed DESC, l.id DESC',
};

const UPDATABLE_COLUMNS = ['title', 'description', 'price_aed', 'category', 'condition', 'location', 'status'];

function escapeLike(text) {
  return text.replace(/[\\%_]/g, (char) => `\\${char}`);
}

/** Data access for `listings` and `listing_photos`. Rows come back with a `photos` array. */
export function createListingsRepository(db) {
  const selectById = db.prepare(`SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS} WHERE l.id = ?`);
  const selectBySeller = db.prepare(
    `SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS} WHERE l.seller_id = ? ORDER BY l.updated_at DESC, l.id DESC`,
  );
  const insertListing = db.prepare(`
    INSERT INTO listings (seller_id, title, description, price_aed, category, condition, location)
    VALUES (@seller_id, @title, @description, @price_aed, @category, @condition, @location)`);
  const insertPhoto = db.prepare('INSERT INTO listing_photos (listing_id, file_name, position) VALUES (?, ?, ?)');
  const selectPhotos = db.prepare(
    'SELECT id, listing_id, file_name, position FROM listing_photos WHERE listing_id = ? ORDER BY position, id',
  );
  const selectPhoto = db.prepare('SELECT id, file_name FROM listing_photos WHERE id = ? AND listing_id = ?');
  const deletePhoto = db.prepare('DELETE FROM listing_photos WHERE id = ?');
  const touch = db.prepare(`UPDATE listings SET updated_at = ${SQL_NOW} WHERE id = ?`);
  const deleteListing = db.prepare('DELETE FROM listings WHERE id = ?');

  function attachPhotos(rows) {
    if (rows.length === 0) return rows;
    const ids = rows.map((row) => row.id);
    const photos = db
      .prepare(
        `SELECT id, listing_id, file_name, position FROM listing_photos
         WHERE listing_id IN (${ids.map(() => '?').join(', ')}) ORDER BY position, id`,
      )
      .all(...ids);
    const byListing = Map.groupBy(photos, (photo) => photo.listing_id);
    return rows.map((row) => ({ ...row, photos: byListing.get(row.id) ?? [] }));
  }

  const createTransaction = db.transaction((sellerId, fields, fileNames) => {
    const { lastInsertRowid } = insertListing.run({
      seller_id: sellerId,
      title: fields.title,
      description: fields.description,
      price_aed: fields.price_aed,
      category: fields.category,
      condition: fields.condition,
      location: fields.location,
    });
    fileNames.forEach((fileName, index) => insertPhoto.run(lastInsertRowid, fileName, index));
    return Number(lastInsertRowid);
  });

  const updateTransaction = db.transaction((id, fields, removePhotoIds, addFileNames) => {
    const columns = UPDATABLE_COLUMNS.filter((column) => fields[column] !== undefined);
    if (columns.length > 0) {
      const assignments = columns.map((column) => `${column} = @${column}`).join(', ');
      const values = Object.fromEntries(columns.map((column) => [column, fields[column]]));
      db.prepare(`UPDATE listings SET ${assignments}, updated_at = ${SQL_NOW} WHERE id = @id`).run({ ...values, id });
    } else {
      touch.run(id);
    }

    const removedFileNames = [];
    for (const photoId of removePhotoIds) {
      const photo = selectPhoto.get(photoId, id);
      if (photo) {
        deletePhoto.run(photo.id);
        removedFileNames.push(photo.file_name);
      }
    }

    const remaining = selectPhotos.all(id);
    remaining.forEach((photo, index) => {
      db.prepare('UPDATE listing_photos SET position = ? WHERE id = ?').run(index, photo.id);
    });
    addFileNames.forEach((fileName, index) => insertPhoto.run(id, fileName, remaining.length + index));
    return removedFileNames;
  });

  const deleteTransaction = db.transaction((id) => {
    const fileNames = selectPhotos.all(id).map((photo) => photo.file_name);
    deleteListing.run(id);
    return fileNames;
  });

  return {
    search({ q, category, sort = 'newest', excludeSellerId, limit = 100 }) {
      const conditions = ["l.status = 'active'"];
      const params = [];
      if (excludeSellerId) {
        conditions.push('l.seller_id != ?');
        params.push(excludeSellerId);
      }
      if (category) {
        conditions.push('l.category = ?');
        params.push(category);
      }
      if (q) {
        const pattern = `%${escapeLike(q)}%`;
        conditions.push(
          "(l.title LIKE ? ESCAPE '\\' OR l.description LIKE ? ESCAPE '\\' OR l.location LIKE ? ESCAPE '\\')",
        );
        params.push(pattern, pattern, pattern);
      }
      const rows = db
        .prepare(
          `SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS}
           WHERE ${conditions.join(' AND ')}
           ORDER BY ${ORDER_BY[sort] ?? ORDER_BY.newest}
           LIMIT ?`,
        )
        .all(...params, limit);
      return attachPhotos(rows);
    },

    findById(id) {
      const row = selectById.get(id);
      return row ? attachPhotos([row])[0] : undefined;
    },

    findBySeller(sellerId) {
      return attachPhotos(selectBySeller.all(sellerId));
    },

    countPhotos(id) {
      return selectPhotos.all(id).length;
    },

    /** Returns the new listing's id. */
    create(sellerId, fields, fileNames) {
      return createTransaction(sellerId, fields, fileNames);
    },

    /** Returns the file names of removed photos so the caller can delete them from disk. */
    update(id, fields, { removePhotoIds = [], addFileNames = [] } = {}) {
      return updateTransaction(id, fields, removePhotoIds, addFileNames);
    },

    /** Returns the file names of the listing's photos so the caller can delete them from disk. */
    delete(id) {
      return deleteTransaction(id);
    },
  };
}
