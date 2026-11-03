#if DEBUG
import Foundation

/// Rehearsal and screenshot shortcuts read from launch arguments (Debug builds only), e.g.
/// `-debug.signInAs omar -debug.mode selling`. Uses the demo password from the seed data.
enum DebugLaunchOptions {
    static func apply(to session: SessionStore, defaults: UserDefaults = .standard) async {
        if session.currentUser == nil, let username = defaults.string(forKey: "debug.signInAs") {
            do {
                try await session.signIn(username: username, password: SampleData.password)
            } catch {
                print("Debug sign-in as \(username) failed: \(error.userMessage)")
                return
            }
        }
        // Also applies when the session was restored from the Keychain.
        if defaults.string(forKey: "debug.mode") == "selling", session.currentUser != nil, session.mode == .buying {
            session.switchMode()
        }
    }
}
#endif
