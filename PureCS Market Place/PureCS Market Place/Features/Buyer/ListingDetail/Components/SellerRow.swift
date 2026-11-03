import SwiftUI

struct SellerRow: View {
    let name: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            AvatarView(name: name, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text("Seller")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(Spacing.m)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SellerRow(name: "Aisha Khan")
        .padding()
        .background(Theme.background)
}
