import Foundation

/// What a buyer can read.
protocol ListingBrowsing {
    /// Active listings from other sellers (never the signed-in user's own), filtered by `query.text`
    /// (title, description or location, case-insensitive) and `query.category`, ordered by `query.sort`.
    func fetchListings(matching query: ListingQuery) async throws -> [Listing]

    /// One listing including the seller's phone number.
    /// Throws `APIError.server(status: 404, …)` when it no longer exists.
    func fetchListing(id: Listing.ID) async throws -> Listing
}
