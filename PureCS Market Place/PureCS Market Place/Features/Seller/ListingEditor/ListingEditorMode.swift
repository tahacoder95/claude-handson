import Foundation

enum ListingEditorMode: Identifiable {
    case create
    case edit(Listing)

    var id: String {
        switch self {
        case .create: "create"
        case .edit(let listing): "edit-\(listing.id)"
        }
    }
}
