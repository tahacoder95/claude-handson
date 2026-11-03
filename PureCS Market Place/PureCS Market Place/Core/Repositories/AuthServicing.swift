import Foundation

/// Account and session operations. Implementations store the session token themselves.
protocol AuthServicing {
    /// Throws `APIError.unauthorized(message:)` for a wrong username or password.
    func signIn(username: String, password: String) async throws -> User

    /// Throws `APIError.server(status: 409, …)` when the username is taken.
    func register(_ input: RegistrationInput) async throws -> User

    /// The user for the stored token, or nil when there is no valid stored session.
    func restoreSession() async throws -> User?

    /// Always ends the local session, even if the server can't be reached.
    func signOut() async
}
