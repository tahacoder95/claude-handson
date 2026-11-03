import Foundation

final class MockAuthService: AuthServicing {
    private let marketplace: MockMarketplace
    private let latency: Duration

    init(marketplace: MockMarketplace, latency: Duration = .zero) {
        self.marketplace = marketplace
        self.latency = latency
    }

    func signIn(username: String, password: String) async throws -> User {
        try await Task.sleep(for: latency)
        return try marketplace.signIn(username: username, password: password)
    }

    func register(_ input: RegistrationInput) async throws -> User {
        try await Task.sleep(for: latency)
        return try marketplace.register(input)
    }

    func restoreSession() async throws -> User? {
        marketplace.signedInUser
    }

    func signOut() async {
        marketplace.signOut()
    }
}
