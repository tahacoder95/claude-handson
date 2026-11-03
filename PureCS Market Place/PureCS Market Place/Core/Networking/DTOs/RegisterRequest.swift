import Foundation

/// Encoded with `.convertToSnakeCase`, so `displayName` is sent as `display_name`.
nonisolated struct RegisterRequest: Encodable {
    let username: String
    let password: String
    let displayName: String
    let phone: String
}
