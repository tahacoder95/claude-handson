import Foundation

extension Endpoint {
    static func login(_ request: LoginRequest) throws -> Endpoint {
        try .json(.post, "/auth/login", body: request, requiresAuth: false)
    }

    static func register(_ request: RegisterRequest) throws -> Endpoint {
        try .json(.post, "/auth/register", body: request, requiresAuth: false)
    }

    static let logout = Endpoint(method: .post, path: "/auth/logout")

    static let currentUser = Endpoint(path: "/me")
}
