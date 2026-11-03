import Foundation

/// Raw values match the API's `status` field.
enum ListingStatus: String, CaseIterable, Identifiable {
    case active
    case sold

    var id: Self { self }

    var title: String {
        switch self {
        case .active: String(localized: "Active")
        case .sold: String(localized: "Sold")
        }
    }
}
