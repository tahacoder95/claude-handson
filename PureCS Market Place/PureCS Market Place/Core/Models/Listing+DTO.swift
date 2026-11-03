import Foundation

extension Listing {
    /// `baseURL` turns the API's relative photo paths into absolute URLs.
    init(dto: ListingDTO, baseURL: URL) {
        self.init(
            id: dto.id,
            sellerID: dto.sellerId,
            sellerName: dto.sellerName,
            sellerPhone: dto.sellerPhone,
            title: dto.title,
            details: dto.description,
            price: Decimal(dto.priceAed),
            category: ListingCategory(rawValue: dto.category) ?? .other,
            condition: ItemCondition(rawValue: dto.condition) ?? .good,
            location: dto.location,
            photos: dto.photos.compactMap { photo in
                URL(string: photo.url, relativeTo: baseURL).map { ListingPhoto(id: photo.id, url: $0.absoluteURL) }
            },
            status: ListingStatus(rawValue: dto.status) ?? .active,
            createdAt: dto.createdAt,
        )
    }
}
