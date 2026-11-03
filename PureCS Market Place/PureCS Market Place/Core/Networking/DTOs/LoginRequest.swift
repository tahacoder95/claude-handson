import Foundation

nonisolated struct LoginRequest: Encodable {
    let username: String
    let password: String
}
