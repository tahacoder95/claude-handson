import SwiftUI

extension View {
    /// App-wide state and styling. Used by the app and by every preview.
    func appEnvironment(_ container: AppContainer) -> some View {
        environment(container.session)
            .environment(container.settings)
            .tint(Theme.accent)
            .fontDesign(.rounded)
            // The palette is designed for light mode only in this MVP.
            .preferredColorScheme(.light)
    }
}
