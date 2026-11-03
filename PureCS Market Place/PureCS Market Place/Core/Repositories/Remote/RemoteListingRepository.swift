import Foundation

final class RemoteListingRepository: ListingBrowsing, ListingManaging {
    private let client: any APIClient

    init(client: any APIClient) {
        self.client = client
    }

    // MARK: - ListingBrowsing

    func fetchListings(matching query: ListingQuery) async throws -> [Listing] {
        let dtos: [ListingDTO] = try await client.send(.listings(query))
        return dtos.map(makeListing)
    }

    func fetchListing(id: Listing.ID) async throws -> Listing {
        let dto: ListingDTO = try await client.send(.listing(id: id))
        return makeListing(from: dto)
    }

    // MARK: - ListingManaging

    func fetchMyListings() async throws -> [Listing] {
        let dtos: [ListingDTO] = try await client.send(.myListings)
        return dtos.map(makeListing)
    }

    func createListing(_ input: ListingInput) async throws -> Listing {
        let dto: ListingDTO = try await client.send(.createListing(input))
        return makeListing(from: dto)
    }

    func updateListing(id: Listing.ID, with input: ListingInput) async throws -> Listing {
        let dto: ListingDTO = try await client.send(.updateListing(id: id, with: input))
        return makeListing(from: dto)
    }

    func setStatus(_ status: ListingStatus, forListing id: Listing.ID) async throws -> Listing {
        let dto: ListingDTO = try await client.send(try .updateStatus(status, forListing: id))
        return makeListing(from: dto)
    }

    func deleteListing(id: Listing.ID) async throws {
        try await client.send(.deleteListing(id: id))
    }

    // MARK: - Private

    private func makeListing(from dto: ListingDTO) -> Listing {
        Listing(dto: dto, baseURL: client.baseURL)
    }
}
