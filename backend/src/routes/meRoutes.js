import { Router } from 'express';
import { serializeListing, serializeUser } from '../utils/serializers.js';

/** Routes about the signed-in user. Mounted behind requireAuth. */
export function createMeRouter({ listingsService }) {
  const router = Router();

  router.get('/', (req, res) => {
    res.json(serializeUser(req.user));
  });

  router.get('/listings', (req, res) => {
    const listings = listingsService.listForSeller(req.user.id);
    res.json(listings.map((listing) => serializeListing(listing)));
  });

  return router;
}
