import SwiftUI

/// Shared by both modes: account details, the mode switch, server info and sign-out.
struct ProfileView: View {
    let user: User

    @Environment(SessionStore.self) private var session
    @Environment(ServerSettings.self) private var settings
    @State private var isSigningOut = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                accountCard
                ModeSwitchCard(mode: session.mode, onSwitch: session.switchMode)
                detailsCard
                signOutButton
                Text("PureCS Market · v0.1 demo")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
        .background(Theme.background)
        .navigationTitle("Profile")
    }

    // MARK: - Sections

    private var accountCard: some View {
        VStack(spacing: Spacing.s) {
            AvatarView(name: user.displayName, size: 84)
            VStack(spacing: Spacing.xxs) {
                Text(user.displayName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.l)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            ProfileInfoRow(systemImage: "phone", title: "Phone", value: user.phone)
            Divider().padding(.leading, 56)
            ProfileInfoRow(
                systemImage: "server.rack",
                title: "Server",
                value: settings.usesMockBackend ? String(localized: "Offline demo") : settings.baseURLString,
            )
        }
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            isSigningOut = true
            Task { await session.signOut() }
        } label: {
            if isSigningOut {
                ProgressView()
            } else {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .font(.headline)
        .foregroundStyle(Theme.danger)
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(Theme.surface, in: Capsule())
        .disabled(isSigningOut)
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        ProfileView(user: SampleData.omar)
    }
    .appEnvironment(container)
}
