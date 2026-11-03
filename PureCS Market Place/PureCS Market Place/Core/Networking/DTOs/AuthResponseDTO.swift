import Foundation

nonisolated struct AuthResponseDTO: Decodable {
    let token: String
    let user: UserDTO
}
