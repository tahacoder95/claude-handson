import SwiftUI
import UIKit

/// Shows the seller's phone number with Call and Copy.
struct ContactSellerSheet: View {
    let listing: Listing

    @Environment(\.openURL) private var openURL
    @State private var didCopy = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(spacing: Spacing.s) {
                AvatarView(name: listing.sellerName, size: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Contact \(listing.sellerName)")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Text("About “\(listing.title)”")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
            }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Phone number")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(listing.sellerPhone ?? String(localized: "Not available"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.m)
            .background(Theme.background, in: RoundedRectangle(cornerRadius: Theme.fieldRadius))

            HStack(spacing: Spacing.s) {
                Button(action: call) {
                    Label("Call", systemImage: "phone.fill")
                }
                .buttonStyle(.primary)
                Button(action: copy) {
                    Label(didCopy ? "Copied" : "Copy", systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.secondary)
            }
            .disabled(listing.sellerPhone == nil)

            Text("Meet in a public place and check the item before you pay.")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(Spacing.xl)
        .presentationDragIndicator(.visible)
        .sensoryFeedback(.success, trigger: didCopy)
    }

    private func call() {
        guard let url = listing.phoneURL else { return }
        openURL(url)
    }

    private func copy() {
        UIPasteboard.general.string = listing.sellerPhone
        withAnimation { didCopy = true }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ContactSellerSheet(listing: SampleData.listings()[0])
                .presentationDetents([.height(380)])
        }
}
