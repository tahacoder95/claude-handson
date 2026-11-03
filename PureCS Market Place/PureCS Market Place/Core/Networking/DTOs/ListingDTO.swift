import Foundation

/// Mirrors the API's listing JSON (snake_case is converted by the decoder).
nonisolated struct ListingDTO: Decodable {
    let id: Int
    let sellerId: Int
    let sellerName: String
    let sellerPhone: String?
    let title: String
    let description: String
    let priceAed: Int
    let category: String
    let condition: String
    let location: String
    let status: String
    let photos: [ListingPhotoDTO]
    let createdAt: Date
}
