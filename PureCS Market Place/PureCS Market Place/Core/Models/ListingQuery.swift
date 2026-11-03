import Foundation

/// What the buyer feed should show.
struct ListingQuery: Equatable {
    var text = ""
    var category: ListingCategory?
    var sort: ListingSort = .newest
}
