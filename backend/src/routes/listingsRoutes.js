import { Router } from 'express';
import { serializeListing } from '../utils/serializers.js';
import { createListingSchema, idParamSchema, searchSchema, updateListingSchema } from '../validation/schemas.js';
import { parse, parseId } from '../validation/parse.js';

/** Listing routes. Mounted behind requireAuth, so `req.user` is always set. */
export function createListingsRouter({ listingsService, photoUpload }) {
  const router = Router();

  router.get('/', async (req, res) => {
    const query = parse(searchSchema, req.query);
    const listings = await listingsService.search(query, req.user.id);
    res.json(listings.map((listing) => serializeListing(listing)));
  });

  router.get('/:id', async (req, res) => {
    const listing = await listingsService.get(parseId(idParamSchema, req.params.id));
    res.json(serializeListing(listing, { includeSellerPhone: true }));
  });

  router.post('/', photoUpload, async (req, res) => {
    const fields = parse(createListingSchema, req.body ?? {});
    const listing = await listingsService.create(req.user.id, fields, req.files ?? []);
    res.status(201).json(serializeListing(listing));
  });

  router.patch('/:id', photoUpload, async (req, res) => {
    const id = parseId(idParamSchema, req.params.id);
    const changes = parse(updateListingSchema, req.body ?? {});
    const listing = await listingsService.update(id, req.user.id, changes, req.files ?? []);
    res.json(serializeListing(listing));
  });

  router.delete('/:id', async (req, res) => {
    await listingsService.remove(parseId(idParamSchema, req.params.id), req.user.id);
    res.status(204).end();
  });

  return router;
}
