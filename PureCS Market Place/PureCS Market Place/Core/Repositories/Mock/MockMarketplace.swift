import Foundation

/// An in-memory stand-in for the server: same rules (ownership, own listings hidden from the feed,
/// sold listings hidden) so mocks behave like the real API. Shared by the mock auth and listing services.
final class MockMarketplace {
    private struct Account {
        var user: User
        var password: String
    }

    private(set) var signedInUser: User?
    private var accounts: [Account]
    private var listings: [Listing]
    private var nextUserID: Int
    private var nextListingID: Int
    private var nextPhotoID = 10_000

    init(listings: [Listing] = SampleData.listings(), signedInUser: User? = nil) {
        self.accounts = SampleData.users.map { Account(user: $0, password: SampleData.password) }
        self.listings = listings
        self.signedInUser = signedInUser
        self.nextUserID = (SampleData.users.map(\.id).max() ?? 0) + 1
        self.nextListingID = (listings.map(\.id).max() ?? 0) + 1
    }

    // MARK: - Auth

    func signIn(username: String, password: String) throws -> User {
        let username = username.trimmed.lowercased()
        guard let account = accounts.first(where: { $0.user.username == username && $0.password == password }) else {
            throw APIError.unauthorized(message: String(localized: "Wrong username or password."))
        }
        signedInUser = account.user
        return account.user
    }

    func register(_ input: RegistrationInput) throws -> User {
        let username = input.username.trimmed.lowercased()
        guard !accounts.contains(where: { $0.user.username == username }) else {
            throw APIError.server(status: 409, message: String(localized: "That username is already taken."))
        }
        let user = User(id: nextUserID, username: username, displayName: input.displayName.trimmed, phone: input.phone.trimmed)
        nextUserID += 1
        accounts.append(Account(user: user, password: input.password))
        signedInUser = user
        return user
    }

    func signOut() {
        signedInUser = nil
    }

    // MARK: - Listings

    func feed(matching query: ListingQuery) throws -> [Listing] {
        let viewer = try requireUser()
        let visible = listings.filter { $0.status == .active && $0.sellerID != viewer.id }
        return query.apply(to: visible).map { $0.withoutPhone() }
    }

    func listing(id: Listing.ID) throws -> Listing {
        _ = try requireUser()
        guard let listing = listings.first(where: { $0.id == id }) else { throw Self.notFound }
        return listing
    }

    func myListings() throws -> [Listing] {
        let seller = try requireUser()
        return listings.filter { $0.sellerID == seller.id }.sorted { $0.createdAt > $1.createdAt }
    }

    func create(_ input: ListingInput) throws -> Listing {
        let seller = try requireUser()
        let listing = Listing(
            id: nextListingID,
            sellerID: seller.id,
            sellerName: seller.displayName,
            sellerPhone: seller.phone,
            title: input.title,
            details: input.details,
            price: input.price,
            category: input.category,
            condition: input.condition,
            location: input.location,
            photos: try storePhotos(input.newPhotos),
            status: .active,
            createdAt: .now,
        )
        nextListingID += 1
        listings.insert(listing, at: 0)
        return listing
    }

    func update(id: Listing.ID, with input: ListingInput) throws -> Listing {
        let index = try ownedListingIndex(id)
        var listing = listings[index]
        listing.title = input.title
        listing.details = input.details
        listing.price = input.price
        listing.category = input.category
        listing.condition = input.condition
        listing.location = input.location
        listing.photos.removeAll { input.removedPhotoIDs.contains($0.id) }
        listing.photos += try storePhotos(input.newPhotos)
        listings[index] = listing
        return listing
    }

    func setStatus(_ status: ListingStatus, forListing id: Listing.ID) throws -> Listing {
        let index = try ownedListingIndex(id)
        listings[index].status = status
        return listings[index]
    }

    func delete(id: Listing.ID) throws {
        let index = try ownedListingIndex(id)
        listings.remove(at: index)
    }

    // MARK: - Private

    private static let notFound = APIError.server(
        status: 404,
        message: String(localized: "This listing is no longer available."),
    )

    private func requireUser() throws -> User {
        guard let signedInUser else { throw APIError.unauthorized(message: nil) }
        return signedInUser
    }

    private func ownedListingIndex(_ id: Listing.ID) throws -> Int {
        let user = try requireUser()
        guard let index = listings.firstIndex(where: { $0.id == id }) else { throw Self.notFound }
        guard listings[index].sellerID == user.id else {
            throw APIError.server(status: 403, message: String(localized: "You can only change your own listings."))
        }
        return index
    }

    /// Writes photos to the temporary directory so `AsyncImage` can load them from file URLs.
    private func storePhotos(_ photos: [Data]) throws -> [ListingPhoto] {
        try photos.map { data in
            let url = URL.temporaryDirectory.appending(path: "mock-photo-\(UUID().uuidString).jpg")
            try data.write(to: url)
            defer { nextPhotoID += 1 }
            return ListingPhoto(id: nextPhotoID, url: url)
        }
    }
}

private extension Listing {
    /// The feed endpoint doesn't include phone numbers; keep the mock honest.
    func withoutPhone() -> Listing {
        var copy = self
        copy.sellerPhone = nil
        return copy
    }
}
