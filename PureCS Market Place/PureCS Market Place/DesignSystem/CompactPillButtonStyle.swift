import SwiftUI

/// A small accent pill, like a banner's call to action.
struct CompactPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.m)
            .frame(minHeight: 36)
            .background(configuration.isPressed ? Theme.accentPressed : Theme.accent, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }
}

extension ButtonStyle where Self == CompactPillButtonStyle {
    static var compactPill: CompactPillButtonStyle { CompactPillButtonStyle() }
}
