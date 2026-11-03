// Shapes database rows into the public JSON contract (snake_case keys).
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

export function serializeListing(row, { includeSellerPhone = false } = {}) {
  return {
    id: row.id,
    seller_id: row.seller_id,
    seller_name: row.seller_name,
    ...(includeSellerPhone ? { seller_phone: row.seller_phone } : {}),
    title: row.title,
    description: row.description,
    price_aed: row.price_aed,
    category: row.category,
    condition: row.condition,
    location: row.location,
    status: row.status,
    photos: (row.photos ?? []).map((photo) => ({
      id: photo.id,
      url: `/uploads/${photo.file_name}`,
    })),
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}
