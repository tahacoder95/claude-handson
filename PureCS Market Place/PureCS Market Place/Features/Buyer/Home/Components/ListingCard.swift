import SwiftUI

/// A photo card with a frosted label strip: title, area, price and condition.
struct ListingCard: View {
    let listing: Listing

    var body: some View {
        ListingImageView(url: listing.coverPhotoURL, category: listing.category, symbolSize: 40)
            .aspectRatio(0.74, contentMode: .fit)
            .overlay(alignment: .bottom) { label }
            .clipShape(.rect(cornerRadius: Theme.cardRadius))
            .contentShape(.rect(cornerRadius: Theme.cardRadius))
            .shadow(color: Theme.shadowColor, radius: 10, y: 4)
            .accessibilityElement(children: .combine)
    }

    private var label: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(listing.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
            Text("\(listing.shortLocation) · \(listing.postedAgo)")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
            HStack(spacing: Spacing.xxs) {
                Text(listing.formattedPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.accentText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
                Chip(text: listing.condition.title, style: .frosted)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(Spacing.xs)
    }
}

#Preview {
    ListingCard(listing: SampleData.listings()[0])
        .frame(width: 180)
        .padding()
        .background(Theme.background)
}
