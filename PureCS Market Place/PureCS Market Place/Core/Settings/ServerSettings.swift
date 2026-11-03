import Foundation
import Observation

/// Persists the server address and the offline-demo switch. Changing either bumps `revision`,
/// which tells the app to rebuild its dependencies.
///
/// Can also be set at launch, e.g. `-server.usesMockBackend YES` in the scheme's arguments.
@Observable
final class ServerSettings: ServerSettingsStoring {
    /// The simulator reaches the Mac's localhost directly. Phones need the Mac's LAN address
    /// (printed by `npm start`) or a hosted URL, entered on the welcome screen.
    static let defaultBaseURLString = "http://127.0.0.1:3000"

    private(set) var baseURLString: String
    private(set) var usesMockBackend: Bool
    private(set) var revision = 0

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        baseURLString = defaults.string(forKey: Keys.baseURL) ?? Self.defaultBaseURLString
        usesMockBackend = defaults.bool(forKey: Keys.usesMockBackend)
    }

    var baseURL: URL {
        // The fallback is a hard-coded valid URL, so the force unwrap can't fail.
        URL(string: baseURLString) ?? URL(string: Self.defaultBaseURLString)!
    }

    func apply(baseURLString: String, usesMockBackend: Bool) {
        self.baseURLString = baseURLString
        self.usesMockBackend = usesMockBackend
        defaults.set(baseURLString, forKey: Keys.baseURL)
        defaults.set(usesMockBackend, forKey: Keys.usesMockBackend)
        revision += 1
    }

    private enum Keys {
        static let baseURL = "server.baseURL"
        static let usesMockBackend = "server.usesMockBackend"
    }
}
