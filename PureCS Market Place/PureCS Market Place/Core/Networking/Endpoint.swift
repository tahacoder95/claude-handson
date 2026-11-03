import Foundation

/// A description of one API request. Feature endpoints live in `Endpoint+Feature.swift` extensions.
struct Endpoint {
    var method: HTTPMethod = .get
    var path: String
    var queryItems: [URLQueryItem] = []
    var body: Data?
    var contentType: String?
    var requiresAuth = true
}

extension Endpoint {
    /// An endpoint with a JSON body, keys converted to snake_case.
    static func json(
        _ method: HTTPMethod,
        _ path: String,
        body value: some Encodable,
        requiresAuth: Bool = true,
    ) throws -> Endpoint {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return Endpoint(
            method: method,
            path: path,
            body: try encoder.encode(value),
            contentType: "application/json",
            requiresAuth: requiresAuth,
        )
    }
}
