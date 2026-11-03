import SwiftUI

/// The app's logo tile.
struct BrandMark: View {
    var size: CGFloat = 64

    var body: some View {
        Image(systemName: "storefront.fill")
            .font(.system(size: size * 0.46, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Theme.accent.gradient, in: RoundedRectangle(cornerRadius: size * 0.3))
            .shadow(color: Theme.accent.opacity(0.35), radius: 12, y: 6)
            .accessibilityHidden(true)
    }
}

#Preview {
    BrandMark()
}
