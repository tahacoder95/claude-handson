import Foundation

/// Raw values match the API's `condition` field.
enum ItemCondition: String, CaseIterable, Identifiable {
    case new
    case likeNew = "like_new"
    case good
    case fair

    var id: Self { self }

    var title: String {
        switch self {
        case .new: String(localized: "New")
        case .likeNew: String(localized: "Like New")
        case .good: String(localized: "Good")
        case .fair: String(localized: "Fair")
        }
    }
}
