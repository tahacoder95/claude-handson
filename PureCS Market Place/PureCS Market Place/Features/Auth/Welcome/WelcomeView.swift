import SwiftUI

/// First screen for signed-out users.
struct WelcomeView: View {
    let container: AppContainer

    @State private var sheet: WelcomeSheet?

    var body: some View {
        VStack(spacing: 0) {
            WelcomeHero()
                .frame(maxHeight: .infinity)
            content
        }
        .background(Theme.background)
        .overlay(alignment: .topTrailing) { serverButton }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .auth(let mode):
                AuthView(viewModel: container.makeAuthViewModel(mode: mode))
            case .serverSettings:
                ServerSettingsView(viewModel: container.makeServerSettingsViewModel())
            }
        }
    }

    // MARK: - Sections

    private var content: some View {
        VStack(spacing: Spacing.m) {
            Text("Find great deals right next door")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
            Text("Buy and sell pre-loved items with people near you. Posting takes less than a minute.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button("Create Account") { sheet = .auth(.register) }
                .buttonStyle(.primary)
                .padding(.top, Spacing.s)
            HStack(spacing: Spacing.xxs) {
                Text("I already have an account?")
                    .foregroundStyle(Theme.ink)
                Button("Sign In") { sheet = .auth(.signIn) }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accentText)
            }
            .font(.subheadline)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.l)
    }

    private var serverButton: some View {
        Button {
            sheet = .serverSettings
        } label: {
            Image(systemName: "server.rack")
        }
        .buttonStyle(.circleIcon(size: 44))
        .padding(.trailing, Spacing.l)
        .accessibilityLabel("Server settings")
    }
}

#Preview {
    let container = AppContainer.preview(signedInAs: nil)
    WelcomeView(container: container)
        .appEnvironment(container)
}
