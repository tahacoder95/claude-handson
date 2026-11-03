import SwiftUI

/// The seller's shop: stats, Active/Sold filter and their listings.
struct MyListingsView: View {
    @Bindable var viewModel: MyListingsViewModel
    let user: User
    let onCreate: () -> Void
    let onEdit: (Listing) -> Void
    let onBrowse: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                GreetingHeader(greeting: "Your shop,", name: user.displayName) {
                    ModeSwitchButton(currentMode: .selling, action: onBrowse)
                }
                StatsStrip(stats: viewModel.stats)
                PillSegmentedControl(options: ListingStatus.allCases, selection: $viewModel.filter) { status in
                    "\(status.title) (\(viewModel.count(for: status)))"
                }
                content
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xl)
        }
        .background(Theme.background)
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await viewModel.load() }
        .task { await viewModel.load() }
        .confirmationDialog(
            "Delete this listing?",
            isPresented: isConfirmingDeletion,
            titleVisibility: .visible,
            presenting: viewModel.pendingDeletion,
        ) { listing in
            Button("Delete “\(listing.title)”", role: .destructive) {
                Task { await viewModel.delete(listing) }
            }
        } message: { _ in
            Text("Buyers will no longer see it. This can't be undone.")
        }
        .alert("Something went wrong", isPresented: isShowingActionError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.actionError ?? "")
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 240)
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded:
            if viewModel.visibleListings.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: Spacing.s) {
                    ForEach(viewModel.visibleListings) { listing in
                        MyListingRow(
                            listing: listing,
                            onEdit: { onEdit(listing) },
                            onToggleStatus: { Task { await viewModel.toggleStatus(of: listing) } },
                            onDelete: { viewModel.requestDeletion(of: listing) },
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                viewModel.filter == .active ? "No active listings" : "Nothing sold yet",
                systemImage: viewModel.filter == .active ? "shippingbox" : "checkmark.seal",
            )
        } description: {
            Text(viewModel.filter == .active
                ? "Post an item and buyers will see it straight away."
                : "Items you mark as sold show up here.")
        } actions: {
            if viewModel.filter == .active {
                Button("Post an Item", action: onCreate)
                    .buttonStyle(.compactPill)
            }
        }
    }

    // MARK: - Bindings

    private var isConfirmingDeletion: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDeletion != nil },
            set: { if !$0 { viewModel.pendingDeletion = nil } },
        )
    }

    private var isShowingActionError: Binding<Bool> {
        Binding(
            get: { viewModel.actionError != nil },
            set: { if !$0 { viewModel.actionError = nil } },
        )
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        MyListingsView(
            viewModel: container.makeMyListingsViewModel(),
            user: SampleData.omar,
            onCreate: {},
            onEdit: { _ in },
            onBrowse: {},
        )
    }
    .appEnvironment(container)
}
