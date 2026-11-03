import Foundation

/// Raw values match the API's `category` field.
enum ListingCategory: String, CaseIterable, Identifiable {
    case electronics
    case home
    case fashion
    case vehicles
    case books
    case sports
    case other

    var id: Self { self }

    var title: String {
        switch self {
        case .electronics: String(localized: "Electronics")
        case .home: String(localized: "Home")
        case .fashion: String(localized: "Fashion")
        case .vehicles: String(localized: "Vehicles")
        case .books: String(localized: "Books")
        case .sports: String(localized: "Sports")
        case .other: String(localized: "Other")
        }
    }
}
