import SwiftUI

/// Chooses between launch, sign-in, and the buying or selling experience.
struct RootView: View {
    let container: AppContainer

    @Environment(SessionStore.self) private var session

    var body: some View {
        ZStack {
            switch session.state {
            case .restoring:
                LaunchView()
                    .transition(.opacity)
            case .signedOut:
                WelcomeView(container: container)
                    .transition(.opacity)
            case .signedIn(let user):
                signedIn(as: user)
            }
        }
        .animation(.smooth, value: session.state)
        .animation(.smooth, value: session.mode)
        .task {
            await session.restore()
            #if DEBUG
            await DebugLaunchOptions.apply(to: session)
            #endif
        }
    }

    @ViewBuilder
    private func signedIn(as user: User) -> some View {
        switch session.mode {
        case .buying:
            BuyerTabView(container: container, user: user)
                .transition(.move(edge: .leading).combined(with: .opacity))
        case .selling:
            SellerTabView(container: container, user: user)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

#Preview("Signed out") {
    let container = AppContainer.preview(signedInAs: nil)
    RootView(container: container)
        .appEnvironment(container)
}

#Preview("Signed in") {
    let container = AppContainer.preview()
    RootView(container: container)
        .appEnvironment(container)
}
