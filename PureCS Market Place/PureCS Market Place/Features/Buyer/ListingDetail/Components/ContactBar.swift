import SwiftUI

/// The detail screen's bottom bar: price and Contact Seller.
struct ContactBar: View {
    let listing: Listing
    let onContact: () -> Void

    var body: some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Price")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(listing.formattedPrice)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)
            }
            Spacer(minLength: Spacing.s)
            Button(action: onContact) {
                Label(isSold ? "Sold" : "Contact Seller", systemImage: isSold ? "checkmark.seal" : "phone.fill")
            }
            .buttonStyle(.primary)
            .frame(maxWidth: 210)
            .disabled(isSold)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.top, Spacing.m)
        .padding(.bottom, Spacing.xs)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: Theme.heroRadius, topTrailingRadius: Theme.heroRadius)
                .fill(Theme.surface)
                .shadow(color: Color.black.opacity(0.06), radius: 16, y: -4)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var isSold: Bool { listing.status == .sold }
}

#Preview {
    ContactBar(listing: SampleData.listings()[0]) {}
        .frame(maxHeight: .infinity, alignment: .bottom)
        .background(Theme.background)
}
