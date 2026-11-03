import SwiftUI

/// One of the seller's listings. Tap to edit; the menu marks it sold or deletes it.
struct MyListingRow: View {
    let listing: Listing
    let onEdit: () -> Void
    let onToggleStatus: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s) {
            Button(action: onEdit) {
                HStack(spacing: Spacing.s) {
                    ListingImageView(url: listing.coverPhotoURL, category: listing.category, symbolSize: 24)
                        .frame(width: 72, height: 72)
                        .clipShape(.rect(cornerRadius: 16))
                    info
                    Spacer(minLength: 0)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Edit listing")

            actionsMenu
        }
        .padding(Spacing.s)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(listing.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .lineLimit(2)
            Text(listing.formattedPrice)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.accentText)
            Text(listing.status == .sold ? "Sold" : "Posted \(listing.postedAgo)")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var actionsMenu: some View {
        Menu {
            Button("Edit", systemImage: "pencil", action: onEdit)
            if listing.status == .active {
                Button("Mark as Sold", systemImage: "checkmark.seal", action: onToggleStatus)
            } else {
                Button("Relist", systemImage: "arrow.uturn.backward", action: onToggleStatus)
            }
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Theme.ink)
                .frame(width: 44, height: 44)
                .background(Theme.background, in: Circle())
        }
        .accessibilityLabel("Actions for \(listing.title)")
    }
}

#Preview {
    VStack {
        MyListingRow(listing: SampleData.listings()[11], onEdit: {}, onToggleStatus: {}, onDelete: {})
        MyListingRow(listing: SampleData.listings()[14], onEdit: {}, onToggleStatus: {}, onDelete: {})
    }
    .padding()
    .background(Theme.background)
}
