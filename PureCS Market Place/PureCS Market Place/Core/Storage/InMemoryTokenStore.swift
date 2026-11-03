import Foundation

/// For previews, tests and the offline demo mode.
final class InMemoryTokenStore: TokenStore {
    private(set) var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func save(_ token: String) {
        self.token = token
    }

    func clear() {
        token = nil
    }
}
