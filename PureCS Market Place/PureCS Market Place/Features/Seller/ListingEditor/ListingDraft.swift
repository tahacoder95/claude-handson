import Foundation

/// The editor's form state, with the same validation rules as the API.
struct ListingDraft: Equatable {
    enum Field: Hashable {
        case title
        case price
        case location
    }

    static let maxPhotos = 3

    var title = ""
    var details = ""
    /// Whole dirhams, typed on a number pad.
    var priceText = ""
    var category: ListingCategory = .electronics
    var condition: ItemCondition = .good
    var location = ""
    var existingPhotos: [ListingPhoto] = []
    var newPhotos: [PhotoAttachment] = []

    init() {}

    init(listing: Listing) {
        title = listing.title
        details = listing.details
        priceText = NSDecimalNumber(decimal: listing.price).stringValue
        category = listing.category
        condition = listing.condition
        location = listing.location
        existingPhotos = listing.photos
    }

    // MARK: - Derived

    var photoCount: Int { existingPhotos.count + newPhotos.count }

    var remainingPhotoSlots: Int { max(0, Self.maxPhotos - photoCount) }

    var price: Decimal? {
        let digits = priceText.filter(\.isNumber)
        guard let value = Decimal(string: digits), value > 0 else { return nil }
        return value
    }

    var issues: [Field: String] {
        var issues: [Field: String] = [:]
        if title.trimmed.count < 3 {
            issues[.title] = String(localized: "Title needs at least 3 characters.")
        }
        if price == nil {
            issues[.price] = String(localized: "Enter a price above 0.")
        }
        if location.trimmed.count < 2 {
            issues[.location] = String(localized: "Add a pickup location.")
        }
        return issues
    }

    /// Nil while the draft has validation issues.
    func makeInput(removedPhotoIDs: [ListingPhoto.ID]) -> ListingInput? {
        guard issues.isEmpty, let price else { return nil }
        return ListingInput(
            title: title.trimmed,
            details: details.trimmed,
            price: price,
            category: category,
            condition: condition,
            location: location.trimmed,
            newPhotos: newPhotos.map(\.data),
            removedPhotoIDs: removedPhotoIDs,
        )
    }
}
