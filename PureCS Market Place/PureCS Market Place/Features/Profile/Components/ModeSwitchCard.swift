import SwiftUI

/// "You're in Buying mode" with a button to switch.
struct ModeSwitchCard: View {
    let mode: AppMode
    let onSwitch: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.s) {
                Image(systemName: mode == .buying ? "bag.fill" : "tag.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentText)
                    .frame(width: 44, height: 44)
                    .background(Theme.accentSoft, in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode == .buying ? "You're in Buying mode" : "You're in Selling mode")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(mode == .buying ? "Browse listings and contact sellers." : "Post items and manage your listings.")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Button(action: onSwitch) {
                Label(mode == .buying ? "Switch to Selling" : "Switch to Buying", systemImage: "arrow.left.arrow.right")
            }
            .buttonStyle(.primary)
        }
        .padding(Spacing.l)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

#Preview {
    ModeSwitchCard(mode: .buying) {}
        .padding()
        .background(Theme.background)
}
