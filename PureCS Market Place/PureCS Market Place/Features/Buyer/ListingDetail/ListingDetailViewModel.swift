import Foundation
import Observation

@Observable
final class ListingDetailViewModel {
    let listingID: Listing.ID
    private(set) var state: Loadable<Listing> = .idle

    private let repository: any ListingBrowsing

    init(listingID: Listing.ID, repository: any ListingBrowsing) {
        self.listingID = listingID
        self.repository = repository
    }

    func load() async {
        if state.value == nil { state = .loading }
        do {
            state = .loaded(try await repository.fetchListing(id: listingID))
        } catch is CancellationError {
            return
        } catch {
            state = .failed(message: error.userMessage)
        }
    }
}
