import SwiftUI

/// Title, price, condition/category chips, area and age.
struct ListingSummary: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(listing.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.ink)
            Text(listing.formattedPrice)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.accentText)
            HStack(spacing: Spacing.xs) {
                Chip(text: listing.condition.title, style: .accent)
                Chip(text: listing.category.title)
                if listing.status == .sold {
                    Chip(text: ListingStatus.sold.title, style: .success)
                }
            }
            HStack(spacing: Spacing.m) {
                Label(listing.location, systemImage: "mappin.and.ellipse")
                Label(listing.postedAgo, systemImage: "clock")
            }
            .font(.footnote)
            .foregroundStyle(Theme.textSecondary)
        }
    }
}

#Preview {
    ListingSummary(listing: SampleData.listings()[0])
        .padding()
}
