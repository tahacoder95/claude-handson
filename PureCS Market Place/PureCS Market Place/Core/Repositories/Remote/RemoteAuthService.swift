import Foundation

final class RemoteAuthService: AuthServicing {
    private let client: any APIClient
    private let tokenStore: any TokenStore

    init(client: any APIClient, tokenStore: any TokenStore) {
        self.client = client
        self.tokenStore = tokenStore
    }

    func signIn(username: String, password: String) async throws -> User {
        let endpoint = try Endpoint.login(LoginRequest(username: username, password: password))
        let response: AuthResponseDTO = try await client.send(endpoint)
        tokenStore.save(response.token)
        return User(dto: response.user)
    }

    func register(_ input: RegistrationInput) async throws -> User {
        let request = RegisterRequest(
            username: input.username,
            password: input.password,
            displayName: input.displayName,
            phone: input.phone,
        )
        let response: AuthResponseDTO = try await client.send(try Endpoint.register(request))
        tokenStore.save(response.token)
        return User(dto: response.user)
    }

    func restoreSession() async throws -> User? {
        guard tokenStore.token != nil else { return nil }
        do {
            let dto: UserDTO = try await client.send(.currentUser)
            return User(dto: dto)
        } catch APIError.unauthorized {
            tokenStore.clear()
            return nil
        }
    }

    func signOut() async {
        // Best effort: the token is discarded locally whether or not the server hears about it.
        try? await client.send(.logout)
        tokenStore.clear()
    }
}
