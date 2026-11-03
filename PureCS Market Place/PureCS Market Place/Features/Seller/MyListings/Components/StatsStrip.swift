import SwiftUI

/// Active, sold and earned, side by side.
struct StatsStrip: View {
    let stats: SellerStats

    var body: some View {
        HStack(spacing: Spacing.s) {
            StatCard(value: "\(stats.activeCount)", label: "Active", systemImage: "tag", isHighlighted: false)
            StatCard(value: "\(stats.soldCount)", label: "Sold", systemImage: "checkmark.seal", isHighlighted: false)
            StatCard(value: stats.earned.aedFormatted, label: "Earned", systemImage: "banknote", isHighlighted: true)
        }
    }
}

#Preview {
    StatsStrip(stats: SellerStats(listings: SampleData.listings().filter { $0.sellerID == SampleData.omar.id }))
        .padding()
        .background(Theme.background)
}
