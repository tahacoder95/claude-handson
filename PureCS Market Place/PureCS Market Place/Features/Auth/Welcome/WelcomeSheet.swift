import Foundation

/// The sheets the welcome screen can present.
enum WelcomeSheet: Identifiable {
    case auth(AuthMode)
    case serverSettings

    var id: String {
        switch self {
        case .auth(let mode): "auth-\(mode)"
        case .serverSettings: "server-settings"
        }
    }
}
