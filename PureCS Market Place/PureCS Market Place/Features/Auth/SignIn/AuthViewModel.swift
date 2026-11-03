import Foundation
import Observation

@Observable
final class AuthViewModel {
    private(set) var mode: AuthMode
    var username = ""
    var password = ""
    var displayName = ""
    var phone = ""
    private(set) var isSubmitting = false
    private(set) var errorMessage: String?

    private let authenticator: any Authenticating

    init(mode: AuthMode, authenticator: any Authenticating) {
        self.mode = mode
        self.authenticator = authenticator
    }

    // MARK: - State

    var title: String {
        mode == .signIn ? String(localized: "Welcome back") : String(localized: "Create your account")
    }

    var subtitle: String {
        mode == .signIn
            ? String(localized: "Sign in to buy and sell near you.")
            : String(localized: "It takes less than a minute.")
    }

    var submitTitle: String {
        mode == .signIn ? String(localized: "Sign In") : String(localized: "Create Account")
    }

    /// The button stays disabled until the form could plausibly succeed; the server has the final say.
    var canSubmit: Bool {
        guard !isSubmitting, !username.trimmed.isEmpty, !password.isEmpty else { return false }
        switch mode {
        case .signIn:
            return true
        case .register:
            return username.trimmed.count >= 3
                && password.count >= 6
                && !displayName.trimmed.isEmpty
                && phone.filter(\.isNumber).count >= 7
        }
    }

    // MARK: - Intents

    func toggleMode() {
        mode = mode.toggled
        errorMessage = nil
    }

    func submit() async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            switch mode {
            case .signIn:
                try await authenticator.signIn(username: username.trimmed, password: password)
            case .register:
                try await authenticator.register(
                    RegistrationInput(
                        username: username.trimmed,
                        password: password,
                        displayName: displayName.trimmed,
                        phone: phone.trimmed,
                    ),
                )
            }
        } catch {
            errorMessage = error.userMessage
        }
    }
}
