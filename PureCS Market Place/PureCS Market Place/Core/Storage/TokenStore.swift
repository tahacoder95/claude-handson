import Foundation

/// Where the session token lives between launches.
protocol TokenStore: AnyObject {
    var token: String? { get }
    func save(_ token: String)
    func clear()
}
