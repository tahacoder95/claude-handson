import Foundation

/// What a seller can do with their own listings.
protocol ListingManaging {
    /// All of the signed-in user's listings, active and sold, most recently changed first.
    func fetchMyListings() async throws -> [Listing]

    func createListing(_ input: ListingInput) async throws -> Listing

    /// Replaces the listing's fields, removes `input.removedPhotoIDs` and appends `input.newPhotos`.
    /// Throws `APIError.server(status: 403, …)` for someone else's listing.
    func updateListing(id: Listing.ID, with input: ListingInput) async throws -> Listing

    func setStatus(_ status: ListingStatus, forListing id: Listing.ID) async throws -> Listing

    func deleteListing(id: Listing.ID) async throws
}
