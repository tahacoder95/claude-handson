import SwiftUI

@main
struct PureCS_Market_PlaceApp: App {
    @State private var settings: ServerSettings
    @State private var container: AppContainer

    init() {
        let settings = ServerSettings()
        _settings = State(initialValue: settings)
        _container = State(initialValue: AppContainer.make(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                // A new container (server changed) starts the UI fresh.
                .id(ObjectIdentifier(container))
                .appEnvironment(container)
                .onChange(of: settings.revision) {
                    container = AppContainer.make(settings: settings)
                }
        }
    }
}
