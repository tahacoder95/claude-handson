import Foundation
import Security

/// Keeps the session token in the Keychain so it survives app restarts.
final class KeychainTokenStore: TokenStore {
    private let service: String
    private let account = "session-token"
    private var cachedToken: String?
    private var hasLoaded = false

    init(service: String = Bundle.main.bundleIdentifier ?? "PureCSMarketPlace") {
        self.service = service
    }

    var token: String? {
        if !hasLoaded {
            cachedToken = readToken()
            hasLoaded = true
        }
        return cachedToken
    }

    func save(_ token: String) {
        deleteToken()
        var query = baseQuery
        query[kSecValueData as String] = Data(token.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        // If the write fails the user simply signs in again next launch; the in-memory copy still works now.
        _ = SecItemAdd(query as CFDictionary, nil)
        cachedToken = token
        hasLoaded = true
    }

    func clear() {
        deleteToken()
        cachedToken = nil
        hasLoaded = true
    }

    // MARK: - Private

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    private func readToken() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteToken() {
        SecItemDelete(baseQuery as CFDictionary)
    }
}
