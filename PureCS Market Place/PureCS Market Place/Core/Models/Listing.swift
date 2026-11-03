import Foundation

struct Listing: Identifiable, Hashable {
    let id: Int
    let sellerID: Int
    var sellerName: String
    /// Only present when the listing was fetched individually (the detail endpoint).
    var sellerPhone: String?
    var title: String
    var details: String
    var price: Decimal
    var category: ListingCategory
    var condition: ItemCondition
    var location: String
    var photos: [ListingPhoto]
    var status: ListingStatus
    let createdAt: Date

    var coverPhotoURL: URL? { photos.first?.url }
}
