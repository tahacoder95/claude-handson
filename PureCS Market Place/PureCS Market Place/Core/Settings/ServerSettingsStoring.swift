import Foundation

/// Which backend the app talks to.
protocol ServerSettingsStoring: AnyObject {
    var baseURLString: String { get }
    var usesMockBackend: Bool { get }
    func apply(baseURLString: String, usesMockBackend: Bool)
}
