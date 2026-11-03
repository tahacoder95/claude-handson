import Foundation

/// Everything needed to create or update a listing. Photos are already-compressed JPEG data.
struct ListingInput: Equatable {
    var title: String
    var details: String
    var price: Decimal
    var category: ListingCategory
    var condition: ItemCondition
    var location: String
    var newPhotos: [Data] = []
    var removedPhotoIDs: [ListingPhoto.ID] = []
}
