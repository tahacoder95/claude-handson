import Foundation
import Observation

@Observable
final class ServerSettingsViewModel {
    var baseURLText: String
    var usesMockBackend: Bool

    private let settings: any ServerSettingsStoring

    init(settings: any ServerSettingsStoring) {
        self.settings = settings
        baseURLText = settings.baseURLString
        usesMockBackend = settings.usesMockBackend
    }

    var validationMessage: String? {
        guard !usesMockBackend else { return nil }
        guard let url = URL(string: baseURLText.trimmed),
              let scheme = url.scheme, ["http", "https"].contains(scheme),
              url.host() != nil
        else { return String(localized: "Enter a full address, like http://192.168.1.20:3000") }
        return nil
    }

    var canSave: Bool { validationMessage == nil }

    func save() {
        guard canSave else { return }
        settings.apply(baseURLString: baseURLText.trimmed, usesMockBackend: usesMockBackend)
    }
}
