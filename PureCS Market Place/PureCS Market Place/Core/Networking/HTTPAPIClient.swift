import Foundation

final class HTTPAPIClient: APIClient {
    let baseURL: URL
    /// Called when an authenticated request gets a 401, so the app can return to sign-in.
    var onUnauthorized: (() -> Void)?

    private let tokenStore: any TokenStore
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL, tokenStore: any TokenStore, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    // MARK: - APIClient

    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        let data = try await perform(endpoint)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    // MARK: - Private

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        let request = try makeRequest(for: endpoint)
        let (data, response) = try await load(request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        switch http.statusCode {
        case 200..<300:
            return data
        case 401:
            if endpoint.requiresAuth { onUnauthorized?() }
            throw APIError.unauthorized(message: serverMessage(in: data))
        default:
            throw APIError.server(status: http.statusCode, message: serverMessage(in: data))
        }
    }

    private func load(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw APIError.network(error)
        }
    }

    private func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false,
        ) else { throw APIError.invalidURL }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let contentType = endpoint.contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        if endpoint.requiresAuth, let token = tokenStore.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    private func serverMessage(in data: Data) -> String? {
        try? JSONDecoder().decode(ErrorResponseDTO.self, from: data).error
    }
}
