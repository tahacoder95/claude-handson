import SwiftUI

/// A round icon button: white with a soft shadow, or solid ink for emphasis.
struct CircleIconButtonStyle: ButtonStyle {
    enum Variant {
        case light
        case dark
    }

    var variant: Variant = .light
    var size: CGFloat = 48

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(variant == .dark ? Color.white : Theme.ink)
            .frame(width: size, height: size)
            .background(variant == .dark ? Theme.ink : Theme.surface, in: Circle())
            .shadow(color: Theme.shadowColor, radius: 10, y: 4)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CircleIconButtonStyle {
    static func circleIcon(_ variant: CircleIconButtonStyle.Variant = .light, size: CGFloat = 48) -> CircleIconButtonStyle {
        CircleIconButtonStyle(variant: variant, size: size)
    }
}
