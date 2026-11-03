import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    /// 401. The message is the server's (e.g. "Wrong username or password.") when it sent one.
    case unauthorized(message: String?)
    case network(URLError)
    case server(status: Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized(let message):
            message ?? String(localized: "Your session has expired. Please sign in again.")
        case .network:
            String(localized: "Can't reach the server. Check your connection and the server address.")
        case .server(_, let message?):
            message
        case .server(let status, nil):
            String(localized: "The server returned an error (\(status)). Please try again.")
        case .decoding:
            String(localized: "The server sent an unexpected response.")
        case .invalidURL, .invalidResponse:
            String(localized: "Something went wrong. Please try again.")
        }
    }
}
