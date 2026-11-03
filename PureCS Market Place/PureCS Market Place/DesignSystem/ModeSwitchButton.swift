import SwiftUI

/// Header pill that flips between buying and selling, so neither mode is a dead end.
struct ModeSwitchButton: View {
    let currentMode: AppMode
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(
                currentMode == .buying ? "Sell" : "Browse",
                systemImage: currentMode == .buying ? "tag.fill" : "bag.fill",
            )
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.accentText)
            .padding(.horizontal, Spacing.m)
            .frame(minHeight: 44)
            .background(Theme.surface, in: Capsule())
            .shadow(color: Theme.shadowColor, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(currentMode == .buying ? "Switch to selling" : "Switch to buying")
    }
}

#Preview {
    HStack {
        ModeSwitchButton(currentMode: .buying) {}
        ModeSwitchButton(currentMode: .selling) {}
    }
    .padding()
    .background(Theme.background)
}
