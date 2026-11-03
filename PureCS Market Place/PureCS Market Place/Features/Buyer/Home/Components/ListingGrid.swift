import SwiftUI

/// Two-column grid of listing cards that push the detail screen.
struct ListingGrid: View {
    let listings: [Listing]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.m) {
            ForEach(listings) { listing in
                NavigationLink(value: BuyerRoute.listing(listing.id)) {
                    ListingCard(listing: listing)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            ListingGrid(listings: SampleData.listings())
                .padding()
        }
        .background(Theme.background)
    }
}
