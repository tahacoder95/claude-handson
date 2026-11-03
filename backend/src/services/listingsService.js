import { HttpError } from '../utils/httpError.js';

/** Listing rules: ownership, photo limits and cleaning up photo files. */
export function createListingsService({ listings, photoStorage, maxPhotos }) {
  function requireListing(id) {
    const listing = listings.findById(id);
    if (!listing) throw new HttpError(404, 'This listing is no longer available.');
    return listing;
  }

  function requireOwnedListing(id, sellerId) {
    const listing = requireListing(id);
    if (listing.seller_id !== sellerId) throw new HttpError(403, 'You can only change your own listings.');
    return listing;
  }

  return {
    /** Active listings for the buyer feed, never including the viewer's own. */
    search(query, viewerId) {
      return listings.search({ ...query, excludeSellerId: viewerId });
    },

    get(id) {
      return requireListing(id);
    },

    listForSeller(sellerId) {
      return listings.findBySeller(sellerId);
    },

    create(sellerId, fields, fileNames) {
      if (fileNames.length > maxPhotos) {
        throw new HttpError(400, `You can add up to ${maxPhotos} photos.`);
      }
      const id = listings.create(sellerId, fields, fileNames);
      return listings.findById(id);
    },

    update(id, sellerId, { remove_photo_ids: removePhotoIds = [], ...fields }, fileNames) {
      const listing = requireOwnedListing(id, sellerId);
      const keptPhotos = listing.photos.filter((photo) => !removePhotoIds.includes(photo.id)).length;
      if (keptPhotos + fileNames.length > maxPhotos) {
        throw new HttpError(400, `You can add up to ${maxPhotos} photos.`);
      }
      const removedFileNames = listings.update(id, fields, { removePhotoIds, addFileNames: fileNames });
      photoStorage.deleteFiles(removedFileNames);
      return listings.findById(id);
    },

    remove(id, sellerId) {
      requireOwnedListing(id, sellerId);
      photoStorage.deleteFiles(listings.delete(id));
    },
  };
}
