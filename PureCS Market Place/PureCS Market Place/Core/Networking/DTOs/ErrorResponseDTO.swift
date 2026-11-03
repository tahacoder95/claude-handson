import Foundation

/// The body the API sends with every error status: `{ "error": "message" }`.
nonisolated struct ErrorResponseDTO: Decodable {
    let error: String
}
