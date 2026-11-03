import Foundation

/// Raw values match the API's `sort` query parameter.
enum ListingSort: String, CaseIterable, Identifiable {
    case newest
    case priceLowToHigh = "price_asc"
    case priceHighToLow = "price_desc"

    var id: Self { self }

    var title: String {
        switch self {
        case .newest: String(localized: "Newest first")
        case .priceLowToHigh: String(localized: "Price: low to high")
        case .priceHighToLow: String(localized: "Price: high to low")
        }
    }
}
