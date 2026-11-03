import Foundation

/// Composition root: the only place that creates concrete services, and the factory for view models.
final class AppContainer {
    let session: SessionStore
    let settings: ServerSettings

    private let listings: any ListingBrowsing & ListingManaging

    init(session: SessionStore, settings: ServerSettings, listings: any ListingBrowsing & ListingManaging) {
        self.session = session
        self.settings = settings
        self.listings = listings
    }

    // MARK: - Factories

    static func make(settings: ServerSettings) -> AppContainer {
        settings.usesMockBackend ? .mock(settings: settings, latency: .milliseconds(350)) : .live(settings: settings)
    }

    static func live(settings: ServerSettings) -> AppContainer {
        let tokenStore = KeychainTokenStore()
        let client = HTTPAPIClient(baseURL: settings.baseURL, tokenStore: tokenStore)
        let session = SessionStore(auth: RemoteAuthService(client: client, tokenStore: tokenStore))
        client.onUnauthorized = { [weak session] in session?.handleUnauthorized() }
        return AppContainer(session: session, settings: settings, listings: RemoteListingRepository(client: client))
    }

    /// The offline demo backend; also used for previews.
    static func mock(settings: ServerSettings, signedInAs user: User? = nil, latency: Duration = .zero) -> AppContainer {
        let marketplace = MockMarketplace(signedInUser: user)
        let auth = MockAuthService(marketplace: marketplace, latency: latency)
        let session = SessionStore(auth: auth, state: user.map(SessionStore.State.signedIn) ?? .restoring)
        return AppContainer(
            session: session,
            settings: settings,
            listings: MockListingRepository(marketplace: marketplace, latency: latency),
        )
    }

    static func preview(signedInAs user: User? = SampleData.omar) -> AppContainer {
        let defaults = UserDefaults(suiteName: "preview") ?? .standard
        return .mock(settings: ServerSettings(defaults: defaults), signedInAs: user)
    }

    // MARK: - View models

    func makeAuthViewModel(mode: AuthMode) -> AuthViewModel {
        AuthViewModel(mode: mode, authenticator: session)
    }

    func makeServerSettingsViewModel() -> ServerSettingsViewModel {
        ServerSettingsViewModel(settings: settings)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: listings)
    }

    func makeListingDetailViewModel(listingID: Listing.ID) -> ListingDetailViewModel {
        ListingDetailViewModel(listingID: listingID, repository: listings)
    }

    func makeMyListingsViewModel() -> MyListingsViewModel {
        MyListingsViewModel(repository: listings)
    }

    func makeListingEditorViewModel(mode: ListingEditorMode) -> ListingEditorViewModel {
        ListingEditorViewModel(mode: mode, repository: listings, imageCompressor: ImageCompressor())
    }
}
