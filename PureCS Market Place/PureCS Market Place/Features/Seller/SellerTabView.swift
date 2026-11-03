import SwiftUI

/// Selling mode: My Listings and Profile, with the centre button posting a new item.
struct SellerTabView: View {
    let container: AppContainer
    let user: User

    @Environment(SessionStore.self) private var session
    @State private var selection: SellerTab = .listings
    @State private var editorMode: ListingEditorMode?
    /// Owned here so the editor sheet (opened from the tab bar too) can refresh the list after saving.
    @State private var myListings: MyListingsViewModel

    init(container: AppContainer, user: User) {
        self.container = container
        self.user = user
        _myListings = State(initialValue: container.makeMyListingsViewModel())
    }

    var body: some View {
        ZStack {
            NavigationStack {
                MyListingsView(
                    viewModel: myListings,
                    user: user,
                    onCreate: { editorMode = .create },
                    onEdit: { editorMode = .edit($0) },
                    onBrowse: session.switchMode,
                )
            }
            .tabContent(isActive: selection == .listings)

            NavigationStack {
                ProfileView(user: user)
            }
            .tabContent(isActive: selection == .profile)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            FloatingTabBar(
                items: [
                    TabBarItem(tab: .listings, title: "My Listings", systemImage: "square.grid.2x2"),
                    TabBarItem(tab: .profile, title: "Profile", systemImage: "person"),
                ],
                selection: $selection,
                centerSystemImage: "plus",
                centerAccessibilityLabel: "Post a new item",
                centerAction: { editorMode = .create },
            )
        }
        .sheet(item: $editorMode) { mode in
            ListingEditorView(viewModel: container.makeListingEditorViewModel(mode: mode)) { _ in
                selection = .listings
                Task { await myListings.load() }
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    SellerTabView(container: container, user: SampleData.omar)
        .appEnvironment(container)
}
