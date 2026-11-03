import SwiftUI

/// Nudges buyers to try selling.
struct PromoBanner: View {
    let onStartSelling: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Turn your clutter into \(Text("cash").foregroundStyle(Theme.accentText))")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text("Post an item in under a minute.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                Button("Start Selling", action: onStartSelling)
                    .buttonStyle(.compactPill)
                    .padding(.top, Spacing.xxs)
            }
            Spacer(minLength: 0)
            artwork
        }
        .padding(Spacing.l)
        .background(Theme.promoGradient, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var artwork: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 104, height: 104)
            Image(systemName: "tag.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .rotationEffect(.degrees(-12))
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    PromoBanner {}
        .padding()
        .background(Theme.background)
}
