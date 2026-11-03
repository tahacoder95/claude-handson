import Foundation
import Observation

/// App-wide session state: who is signed in and which mode (buying or selling) they're in.
@Observable
final class SessionStore {
    enum State: Equatable {
        case restoring
        case signedOut
        case signedIn(User)
    }

    private(set) var state: State
    private(set) var mode: AppMode = .buying

    private let auth: any AuthServicing

    init(auth: any AuthServicing, state: State = .restoring) {
        self.auth = auth
        self.state = state
    }

    var currentUser: User? {
        if case .signedIn(let user) = state { user } else { nil }
    }

    // MARK: - Intents

    func restore() async {
        guard state == .restoring else { return }
        do {
            state = try await auth.restoreSession().map(State.signedIn) ?? .signedOut
        } catch {
            // Usually the server is unreachable at launch. Show sign-in; the stored token is kept.
            state = .signedOut
        }
    }

    func switchMode() {
        mode = mode.toggled
    }

    func signOut() async {
        await auth.signOut()
        mode = .buying
        state = .signedOut
    }

    /// The server rejected our token (expired, or the database was re-seeded).
    func handleUnauthorized() {
        guard currentUser != nil else { return }
        mode = .buying
        state = .signedOut
    }
}

// MARK: - Authenticating

extension SessionStore: Authenticating {
    func signIn(username: String, password: String) async throws {
        let user = try await auth.signIn(username: username, password: password)
        mode = .buying
        state = .signedIn(user)
    }

    func register(_ input: RegistrationInput) async throws {
        let user = try await auth.register(input)
        mode = .buying
        state = .signedIn(user)
    }
}
