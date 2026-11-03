import SwiftUI

/// Buying mode: Home and Profile, with the centre button switching to selling.
struct BuyerTabView: View {
    let container: AppContainer
    let user: User

    @Environment(SessionStore.self) private var session
    @State private var selection: BuyerTab = .home
    @State private var homePath: [BuyerRoute] = []

    var body: some View {
        ZStack {
            NavigationStack(path: $homePath) {
                HomeView(viewModel: container.makeHomeViewModel(), user: user, onStartSelling: session.switchMode)
                    .navigationDestination(for: BuyerRoute.self, destination: destination)
            }
            .tabContent(isActive: selection == .home)

            NavigationStack {
                ProfileView(user: user)
            }
            .tabContent(isActive: selection == .profile)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            // The listing detail has its own bottom bar, so the tab bar steps aside.
            if homePath.isEmpty || selection != .home {
                FloatingTabBar(
                    items: [
                        TabBarItem(tab: .home, title: "Home", systemImage: "house"),
                        TabBarItem(tab: .profile, title: "Profile", systemImage: "person"),
                    ],
                    selection: $selection,
                    centerSystemImage: "tag",
                    centerAccessibilityLabel: "Switch to selling",
                    centerAction: session.switchMode,
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth, value: homePath.isEmpty)
    }

    @ViewBuilder
    private func destination(for route: BuyerRoute) -> some View {
        switch route {
        case .listing(let id):
            ListingDetailView(viewModel: container.makeListingDetailViewModel(listingID: id))
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    BuyerTabView(container: container, user: SampleData.omar)
        .appEnvironment(container)
}
