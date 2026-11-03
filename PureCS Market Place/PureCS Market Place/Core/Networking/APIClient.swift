import Foundation

protocol APIClient: AnyObject {
    /// Used to resolve server-relative paths such as photo URLs.
    var baseURL: URL { get }

    /// Sends the request and decodes the JSON response.
    /// Throws `APIError`, or `CancellationError` when the calling task was cancelled.
    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response

    /// Sends the request and ignores the response body.
    func send(_ endpoint: Endpoint) async throws
}
