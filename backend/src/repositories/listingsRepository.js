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

const INSERT_PHOTO = 'INSERT INTO listing_photos (listing_id, file_name, position) VALUES (?, ?, ?)';

function escapeLike(text) {
  return text.replace(/[\\%_]/g, (char) => `\\${char}`);
}

/**
 * Data access for `listings` and `listing_photos`. Rows come back with a `photos` array of
 * `{ id, file_name, position }`. Multi-statement writes use one atomic batch.
 */
export function createListingsRepository(db) {
  function photosFor(listingId) {
    return db.all(
      'SELECT id, listing_id, file_name, position FROM listing_photos WHERE listing_id = ? ORDER BY position, id',
      [listingId],
    );
  }

  async function attachPhotos(rows) {
    if (rows.length === 0) return rows;
    const ids = rows.map((row) => row.id);
    const photos = await db.all(
      `SELECT id, listing_id, file_name, position FROM listing_photos
       WHERE listing_id IN (${ids.map(() => '?').join(', ')}) ORDER BY position, id`,
      ids,
    );
    const byListing = Map.groupBy(photos, (photo) => photo.listing_id);
    return rows.map((row) => ({ ...row, photos: byListing.get(row.id) ?? [] }));
  }

  return {
    async search({ q, category, sort = 'newest', excludeSellerId, limit = 100 }) {
      const conditions = ["l.status = 'active'"];
      const args = [];
      if (excludeSellerId) {
        conditions.push('l.seller_id != ?');
        args.push(excludeSellerId);
      }
      if (category) {
        conditions.push('l.category = ?');
        args.push(category);
      }
      if (q) {
        const pattern = `%${escapeLike(q)}%`;
        conditions.push(
          "(l.title LIKE ? ESCAPE '\\' OR l.description LIKE ? ESCAPE '\\' OR l.location LIKE ? ESCAPE '\\')",
        );
        args.push(pattern, pattern, pattern);
      }
      const rows = await db.all(
        `SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS}
         WHERE ${conditions.join(' AND ')}
         ORDER BY ${ORDER_BY[sort] ?? ORDER_BY.newest}
         LIMIT ?`,
        [...args, limit],
      );
      return attachPhotos(rows);
    },

    async findById(id) {
      const row = await db.get(`SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS} WHERE l.id = ?`, [id]);
      return row ? (await attachPhotos([row]))[0] : undefined;
    },

    async findBySeller(sellerId) {
      const rows = await db.all(
        `SELECT ${LISTING_COLUMNS} ${FROM_LISTINGS} WHERE l.seller_id = ? ORDER BY l.updated_at DESC, l.id DESC`,
        [sellerId],
      );
      return attachPhotos(rows);
    },

    /** Returns the new listing's id. */
    async create(sellerId, fields, photoRefs) {
      const { lastInsertRowid: id } = await db.run(
        `INSERT INTO listings (seller_id, title, description, price_aed, category, condition, location)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [sellerId, fields.title, fields.description, fields.price_aed, fields.category, fields.condition, fields.location],
      );
      try {
        await db.batch(photoRefs.map((ref, index) => [INSERT_PHOTO, [id, ref, index]]));
      } catch (error) {
        await db.run('DELETE FROM listings WHERE id = ?', [id]);
        throw error;
      }
      return id;
    },

    /** Returns the references of removed photos so the caller can delete the files. */
    async update(id, fields, { removePhotoIds = [], addPhotoRefs = [] } = {}) {
      const current = await photosFor(id);
      const removed = current.filter((photo) => removePhotoIds.includes(photo.id));
      const kept = current.filter((photo) => !removePhotoIds.includes(photo.id));

      const columns = UPDATABLE_COLUMNS.filter((column) => fields[column] !== undefined);
      const assignments = [...columns.map((column) => `${column} = ?`), `updated_at = ${SQL_NOW}`].join(', ');

      await db.batch([
        [`UPDATE listings SET ${assignments} WHERE id = ?`, [...columns.map((column) => fields[column]), id]],
        ...removed.map((photo) => ['DELETE FROM listing_photos WHERE id = ?', [photo.id]]),
        ...kept.map((photo, index) => ['UPDATE listing_photos SET position = ? WHERE id = ?', [index, photo.id]]),
        ...addPhotoRefs.map((ref, index) => [INSERT_PHOTO, [id, ref, kept.length + index]]),
      ]);
      return removed.map((photo) => photo.file_name);
    },

    /** Returns the references of the listing's photos so the caller can delete the files. */
    async delete(id) {
      const photos = await photosFor(id);
      await db.batch([
        ['DELETE FROM listing_photos WHERE listing_id = ?', [id]],
        ['DELETE FROM listings WHERE id = ?', [id]],
      ]);
      return photos.map((photo) => photo.file_name);
    },
  };
}
