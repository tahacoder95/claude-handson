import Foundation

extension ListingQuery {
    /// The same filtering and ordering the API applies, for the mock repository.
    func apply(to listings: [Listing]) -> [Listing] {
        let term = text.trimmed
        let filtered = listings.filter { listing in
            let matchesCategory = category.map { listing.category == $0 } ?? true
            let matchesText = term.isEmpty
                || listing.title.localizedStandardContains(term)
                || listing.details.localizedStandardContains(term)
                || listing.location.localizedStandardContains(term)
            return matchesCategory && matchesText
        }
        switch sort {
        case .newest: return filtered.sorted { $0.createdAt > $1.createdAt }
        case .priceLowToHigh: return filtered.sorted { $0.price < $1.price }
        case .priceHighToLow: return filtered.sorted { $0.price > $1.price }
        }
    }
}
