import SwiftUI

/// Hero photos, item details, the seller, and a Contact Seller bar.
struct ListingDetailView: View {
    @State private var viewModel: ListingDetailViewModel
    @State private var contactListing: Listing?

    init(viewModel: ListingDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .background(Theme.background)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task { await viewModel.load() }
            .sheet(item: $contactListing) { listing in
                ContactSellerSheet(listing: listing)
                    .presentationDetents([.height(380)])
                    .presentationCornerRadius(Theme.heroRadius)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let listing):
            loaded(listing)
        }
    }

    private func loaded(_ listing: Listing) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PhotoGallery(photos: listing.photos, category: listing.category)
                    .frame(height: 400)
                VStack(alignment: .leading, spacing: Spacing.l) {
                    ListingSummary(listing: listing)
                    Divider()
                    ExpandableDescription(text: listing.details)
                    Divider()
                    SellerRow(name: listing.sellerName)
                }
                .padding(Spacing.l)
            }
        }
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ContactBar(listing: listing) { contactListing = listing }
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        ListingDetailView(viewModel: container.makeListingDetailViewModel(listingID: 1))
    }
    .appEnvironment(container)
}
