import { Router } from 'express';
import { serializeListing, serializeUser } from '../utils/serializers.js';

/** Routes about the signed-in user. Mounted behind requireAuth. */
export function createMeRouter({ listingsService }) {
  const router = Router();

  router.get('/', (req, res) => {
    res.json(serializeUser(req.user));
  });

  router.get('/listings', async (req, res) => {
    const listings = await listingsService.listForSeller(req.user.id);
    res.json(listings.map((listing) => serializeListing(listing)));
  });

  return router;
}
