import Foundation

nonisolated struct ListingPhotoDTO: Decodable {
    let id: Int
    /// A server-relative path such as `/uploads/abc.jpg`.
    let url: String
}
