import Foundation
import Observation

@Observable
final class MyListingsViewModel {
    private(set) var state: Loadable<[Listing]> = .idle
    var filter: ListingStatus = .active
    /// Set to ask the view to confirm a delete; cleared when the dialog closes.
    var pendingDeletion: Listing?
    /// A failed mark-as-sold or delete; cleared when the alert closes.
    var actionError: String?

    private let repository: any ListingManaging

    init(repository: any ListingManaging) {
        self.repository = repository
    }

    // MARK: - State

    var stats: SellerStats { SellerStats(listings: state.value ?? []) }

    var visibleListings: [Listing] {
        (state.value ?? []).filter { $0.status == filter }
    }

    func count(for status: ListingStatus) -> Int {
        (state.value ?? []).filter { $0.status == status }.count
    }

    // MARK: - Intents

    func load() async {
        if state.value == nil { state = .loading }
        do {
            state = .loaded(try await repository.fetchMyListings())
        } catch is CancellationError {
            return
        } catch {
            state = .failed(message: error.userMessage)
        }
    }

    func toggleStatus(of listing: Listing) async {
        let newStatus: ListingStatus = listing.status == .active ? .sold : .active
        do {
            let updated = try await repository.setStatus(newStatus, forListing: listing.id)
            replace(updated)
        } catch {
            actionError = error.userMessage
        }
    }

    func requestDeletion(of listing: Listing) {
        pendingDeletion = listing
    }

    func delete(_ listing: Listing) async {
        do {
            try await repository.deleteListing(id: listing.id)
            if case .loaded(let listings) = state {
                state = .loaded(listings.filter { $0.id != listing.id })
            }
        } catch {
            actionError = error.userMessage
        }
    }

    // MARK: - Private

    private func replace(_ listing: Listing) {
        guard case .loaded(var listings) = state,
              let index = listings.firstIndex(where: { $0.id == listing.id })
        else { return }
        listings[index] = listing
        state = .loaded(listings)
    }
}
