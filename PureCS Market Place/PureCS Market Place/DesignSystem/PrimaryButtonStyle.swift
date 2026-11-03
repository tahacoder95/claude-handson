import SwiftUI

/// Full-width periwinkle pill, used for the main action on a screen.
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, Spacing.l)
            .background(configuration.isPressed ? Theme.accentPressed : Theme.accent, in: Capsule())
            .shadow(color: Theme.accent.opacity(isEnabled ? 0.3 : 0), radius: 12, y: 6)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
