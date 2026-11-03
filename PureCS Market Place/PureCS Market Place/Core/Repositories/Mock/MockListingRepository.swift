import Foundation

/// Previews, tests and the offline demo mode. Pass `error` to simulate a failing server.
final class MockListingRepository: ListingBrowsing, ListingManaging {
    private let marketplace: MockMarketplace
    private let latency: Duration
    private let error: Error?

    init(marketplace: MockMarketplace, latency: Duration = .zero, error: Error? = nil) {
        self.marketplace = marketplace
        self.latency = latency
        self.error = error
    }

    // MARK: - ListingBrowsing

    func fetchListings(matching query: ListingQuery) async throws -> [Listing] {
        try await simulateNetwork()
        return try marketplace.feed(matching: query)
    }

    func fetchListing(id: Listing.ID) async throws -> Listing {
        try await simulateNetwork()
        return try marketplace.listing(id: id)
    }

    // MARK: - ListingManaging

    func fetchMyListings() async throws -> [Listing] {
        try await simulateNetwork()
        return try marketplace.myListings()
    }

    func createListing(_ input: ListingInput) async throws -> Listing {
        try await simulateNetwork()
        return try marketplace.create(input)
    }

    func updateListing(id: Listing.ID, with input: ListingInput) async throws -> Listing {
        try await simulateNetwork()
        return try marketplace.update(id: id, with: input)
    }

    func setStatus(_ status: ListingStatus, forListing id: Listing.ID) async throws -> Listing {
        try await simulateNetwork()
        return try marketplace.setStatus(status, forListing: id)
    }

    func deleteListing(id: Listing.ID) async throws {
        try await simulateNetwork()
        try marketplace.delete(id: id)
    }

    // MARK: - Private

    private func simulateNetwork() async throws {
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
