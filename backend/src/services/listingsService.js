import { HttpError } from '../utils/httpError.js';

/**
 * Listing rules: ownership, photo limits, and keeping photo storage in step with the database.
 * Listings come back with `photos: [{ id, url }]`.
 */
export function createListingsService({ listings, photoStorage, maxPhotos }) {
  const tooManyPhotos = () => new HttpError(400, `You can add up to ${maxPhotos} photos.`);

  function withPhotoUrls(listing) {
    return {
      ...listing,
      photos: listing.photos.map((photo) => ({ id: photo.id, url: photoStorage.urlFor(photo.file_name) })),
    };
  }

  /** Storage cleanup never fails the request: the database is already consistent. */
  async function discardPhotos(refs) {
    try {
      await photoStorage.delete(refs);
    } catch (error) {
      console.error('Could not delete photos', refs, error);
    }
  }

  async function requireListing(id) {
    const listing = await listings.findById(id);
    if (!listing) throw new HttpError(404, 'This listing is no longer available.');
    return listing;
  }

  async function requireOwnedListing(id, sellerId) {
    const listing = await requireListing(id);
    if (listing.seller_id !== sellerId) throw new HttpError(403, 'You can only change your own listings.');
    return listing;
  }

  return {
    /** Active listings for the buyer feed, never including the viewer's own. */
    async search(query, viewerId) {
      return (await listings.search({ ...query, excludeSellerId: viewerId })).map(withPhotoUrls);
    },

    async get(id) {
      return withPhotoUrls(await requireListing(id));
    },

    async listForSeller(sellerId) {
      return (await listings.findBySeller(sellerId)).map(withPhotoUrls);
    },

    /** `files` are multer memory files: `{ buffer, mimetype }`. */
    async create(sellerId, fields, files) {
      if (files.length > maxPhotos) throw tooManyPhotos();
      const refs = await photoStorage.save(files);
      let id;
      try {
        id = await listings.create(sellerId, fields, refs);
      } catch (error) {
        await discardPhotos(refs);
        throw error;
      }
      return withPhotoUrls(await listings.findById(id));
    },

    async update(id, sellerId, { remove_photo_ids: removePhotoIds = [], ...fields }, files) {
      const listing = await requireOwnedListing(id, sellerId);
      const keptCount = listing.photos.filter((photo) => !removePhotoIds.includes(photo.id)).length;
      if (keptCount + files.length > maxPhotos) throw tooManyPhotos();

      const refs = await photoStorage.save(files);
      let removedRefs;
      try {
        removedRefs = await listings.update(id, fields, { removePhotoIds, addPhotoRefs: refs });
      } catch (error) {
        await discardPhotos(refs);
        throw error;
      }
      await discardPhotos(removedRefs);
      return withPhotoUrls(await listings.findById(id));
    },

    async remove(id, sellerId) {
      await requireOwnedListing(id, sellerId);
      await discardPhotos(await listings.delete(id));
    },
  };
}
