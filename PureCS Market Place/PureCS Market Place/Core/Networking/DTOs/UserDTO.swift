import Foundation

/// `nonisolated` so decoding isn't tied to the main actor (the project's default isolation).
nonisolated struct UserDTO: Decodable {
    let id: Int
    let username: String
    let displayName: String
    let phone: String
}
