import SwiftUI

/// The buyer feed: greeting, search, promo, categories and listings.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    let user: User
    let onStartSelling: () -> Void

    init(viewModel: HomeViewModel, user: User, onStartSelling: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.user = user
        self.onStartSelling = onStartSelling
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                GreetingHeader(greeting: "Hello,", name: user.displayName) {
                    ModeSwitchButton(currentMode: .buying, action: onStartSelling)
                }
                searchRow
                if viewModel.showsPromo {
                    PromoBanner(onStartSelling: onStartSelling)
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
                CategoryRail(selection: viewModel.selectedCategory) { category in
                    Task { await viewModel.selectCategory(category) }
                }
                listingsSection
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xl)
            .animation(.smooth, value: viewModel.showsPromo)
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Theme.background)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await viewModel.load() }
        .task(id: viewModel.searchText) { await viewModel.searchTextChanged() }
    }

    // MARK: - Sections

    private var searchRow: some View {
        HStack(spacing: Spacing.s) {
            SearchField(text: $viewModel.searchText, prompt: "Search items")
            SortMenu(selection: viewModel.sort) { sort in
                Task { await viewModel.selectSort(sort) }
            }
        }
    }

    @ViewBuilder
    private var listingsSection: some View {
        SectionHeader(title: viewModel.sectionTitle)
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 240)
        case .loaded(let listings) where listings.isEmpty:
            emptyState
        case .loaded(let listings):
            ListingGrid(listings: listings)
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No items found", systemImage: "magnifyingglass")
        } description: {
            Text(viewModel.hasActiveFilters ? "Try another search or category." : "Nothing is for sale yet. Check back soon!")
        } actions: {
            if viewModel.hasActiveFilters {
                Button("Clear filters") {
                    Task { await viewModel.clearFilters() }
                }
                .buttonStyle(.compactPill)
            }
        }
    }
}

#Preview("Feed") {
    let container = AppContainer.preview()
    NavigationStack {
        HomeView(viewModel: container.makeHomeViewModel(), user: SampleData.omar, onStartSelling: {})
    }
    .appEnvironment(container)
}

#Preview("Error") {
    let container = AppContainer.preview()
    let repository = MockListingRepository(
        marketplace: MockMarketplace(signedInUser: SampleData.omar),
        error: APIError.network(URLError(.notConnectedToInternet)),
    )
    NavigationStack {
        HomeView(viewModel: HomeViewModel(repository: repository), user: SampleData.omar, onStartSelling: {})
    }
    .appEnvironment(container)
}
