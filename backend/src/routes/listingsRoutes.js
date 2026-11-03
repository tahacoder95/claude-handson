import { Router } from 'express';
import { serializeListing } from '../utils/serializers.js';
import { createListingSchema, idParamSchema, searchSchema, updateListingSchema } from '../validation/schemas.js';
import { parse, parseId } from '../validation/parse.js';

/** Listing routes. Mounted behind requireAuth, so `req.user` is always set. */
export function createListingsRouter({ listingsService, photoUpload }) {
  const router = Router();
  const uploadedFileNames = (req) => (req.files ?? []).map((file) => file.filename);

  router.get('/', (req, res) => {
    const query = parse(searchSchema, req.query);
    const listings = listingsService.search(query, req.user.id);
    res.json(listings.map((listing) => serializeListing(listing)));
  });

  router.get('/:id', (req, res) => {
    const listing = listingsService.get(parseId(idParamSchema, req.params.id));
    res.json(serializeListing(listing, { includeSellerPhone: true }));
  });

  router.post('/', photoUpload, (req, res) => {
    const fields = parse(createListingSchema, req.body ?? {});
    const listing = listingsService.create(req.user.id, fields, uploadedFileNames(req));
    res.status(201).json(serializeListing(listing));
  });

  router.patch('/:id', photoUpload, (req, res) => {
    const id = parseId(idParamSchema, req.params.id);
    const changes = parse(updateListingSchema, req.body ?? {});
    const listing = listingsService.update(id, req.user.id, changes, uploadedFileNames(req));
    res.json(serializeListing(listing));
  });

  router.delete('/:id', (req, res) => {
    listingsService.remove(parseId(idParamSchema, req.params.id), req.user.id);
    res.status(204).end();
  });

  return router;
}
