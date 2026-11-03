// Shapes service results into the public JSON contract (snake_case keys).
// Never return password hashes or raw rows from a route.

export function serializeUser(row) {
  return {
    id: row.id,
    username: row.username,
    display_name: row.display_name,
    phone: row.phone,
    created_at: row.created_at,
  };
}

/** Expects `listing.photos` as `[{ id, url }]` (see listingsService). */
export function serializeListing(listing, { includeSellerPhone = false } = {}) {
  return {
    id: listing.id,
    seller_id: listing.seller_id,
    seller_name: listing.seller_name,
    ...(includeSellerPhone ? { seller_phone: listing.seller_phone } : {}),
    title: listing.title,
    description: listing.description,
    price_aed: listing.price_aed,
    category: listing.category,
    condition: listing.condition,
    location: listing.location,
    status: listing.status,
    photos: listing.photos.map((photo) => ({ id: photo.id, url: photo.url })),
    created_at: listing.created_at,
    updated_at: listing.updated_at,
  };
}
