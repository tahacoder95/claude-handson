import Foundation

/// What the sign-in screen needs from the session, so its view model doesn't depend on `SessionStore`.
protocol Authenticating: AnyObject {
    func signIn(username: String, password: String) async throws
    func register(_ input: RegistrationInput) async throws
}
