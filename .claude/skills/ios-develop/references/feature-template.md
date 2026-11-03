# Feature template — every layer, one file each

A worked example: the buyer **Browse** screen, from domain model to test. Copy the shape, not the names. Each code block is **its own file**; the heading is the path under `PureCS Market Place/PureCS Market Place/`.

## Contents
1. Model, query and mapping
2. DTO
3. Endpoint
4. APIClient and errors
5. Repository protocol, remote and mock
6. View model
7. View, component and previews
8. Composition root
9. Tests

---

## 1. Model, query and mapping

### `Core/Models/Listing.swift`
```swift
import Foundation

struct Listing: Identifiable, Hashable {
    let id: Int
    let sellerID: Int
    var sellerName: String
    var sellerPhone: String?
    var title: String
    var details: String
    var price: Decimal
    var category: ListingCategory
    var condition: ItemCondition
    var location: String
    var photoURLs: [URL]
    var status: ListingStatus
    let createdAt: Date
}
```

### `Core/Models/ListingQuery.swift`
```swift
import Foundation

struct ListingQuery: Equatable {
    var text = ""
    var category: ListingCategory?
    var sort: ListingSort = .newest
}
```

### `Core/Models/ListingSort.swift`
```swift
import Foundation

enum ListingSort: String, CaseIterable, Identifiable {
    case newest
    case priceLowToHigh = "price_asc"
    case priceHighToLow = "price_desc"

    var id: Self { self }
}
```

### `Core/Models/Listing+Formatting.swift`
Display formatting lives in a focused extension, not in the view or the repository (single responsibility).
```swift
import Foundation

extension Listing {
    var formattedPrice: String {
        price.formatted(.currency(code: "AED").precision(.fractionLength(0)))
    }

    var postedAgo: String {
        createdAt.formatted(.relative(presentation: .named))
    }
}
```

### `Core/Models/Listing+DTO.swift`
Mapping is the only place that knows both shapes.
```swift
import Foundation

extension Listing {
    init(dto: ListingDTO, baseURL: URL) {
        self.init(
            id: dto.id,
            sellerID: dto.sellerId,
            sellerName: dto.sellerName,
            sellerPhone: dto.sellerPhone,
            title: dto.title,
            details: dto.description,
            price: Decimal(dto.priceAed),
            category: ListingCategory(rawValue: dto.category) ?? .other,
            condition: ItemCondition(rawValue: dto.condition) ?? .good,
            location: dto.location,
            photoURLs: dto.photos.compactMap { URL(string: $0, relativeTo: baseURL)?.absoluteURL },
            status: ListingStatus(rawValue: dto.status) ?? .active,
            createdAt: dto.createdAt
        )
    }
}
```

## 2. DTO

### `Core/Networking/DTOs/ListingDTO.swift`
Matches the JSON exactly (snake_case is converted by the decoder). `nonisolated` so decoding isn't tied to the main actor under the project's default MainActor isolation.
```swift
import Foundation

nonisolated struct ListingDTO: Decodable {
    let id: Int
    let sellerId: Int
    let sellerName: String
    let sellerPhone: String?
    let title: String
    let description: String
    let priceAed: Int
    let category: String
    let condition: String
    let location: String
    let photos: [String]
    let status: String
    let createdAt: Date
}
```

## 3. Endpoint

### `Core/Networking/Endpoint.swift`
```swift
import Foundation

struct Endpoint {
    var method: HTTPMethod = .get
    var path: String
    var queryItems: [URLQueryItem] = []
    var body: Data?
    var contentType: String?
    var requiresAuth = true
}
```

### `Core/Networking/HTTPMethod.swift`
```swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
```

### `Core/Networking/Endpoint+Listings.swift`
New endpoints are added as extensions (open/closed): the client never changes.
```swift
import Foundation

extension Endpoint {
    static func listings(_ query: ListingQuery) -> Endpoint {
        var items = [URLQueryItem(name: "sort", value: query.sort.rawValue)]
        if !query.text.isEmpty {
            items.append(URLQueryItem(name: "q", value: query.text))
        }
        if let category = query.category {
            items.append(URLQueryItem(name: "category", value: category.rawValue))
        }
        return Endpoint(path: "/listings", queryItems: items)
    }

    static func listing(id: Listing.ID) -> Endpoint {
        Endpoint(path: "/listings/\(id)")
    }
}
```

## 4. APIClient and errors

### `Core/Networking/APIClient.swift`
```swift
import Foundation

protocol APIClient {
    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response
    func send(_ endpoint: Endpoint) async throws
}
```

### `Core/Networking/HTTPAPIClient.swift`
```swift
import Foundation

final class HTTPAPIClient: APIClient {
    private let baseURL: URL
    private let tokenStore: any TokenStore
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL, tokenStore: any TokenStore, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    // MARK: - APIClient

    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        let data = try await perform(endpoint)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        _ = try await perform(endpoint)
    }

    // MARK: - Private

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        let request = try makeRequest(for: endpoint)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        switch http.statusCode {
        case 200..<300: return data
        case 401: throw APIError.unauthorized
        default: throw APIError.server(status: http.statusCode, message: Self.serverMessage(in: data))
        }
    }

    private func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        ) else { throw APIError.invalidURL }
        if !endpoint.queryItems.isEmpty { components.queryItems = endpoint.queryItems }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        if let contentType = endpoint.contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        if endpoint.requiresAuth, let token = tokenStore.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    /// The backend sends `{ "error": "message" }` on failure.
    private static func serverMessage(in data: Data) -> String? {
        struct ErrorBody: Decodable { let error: String }
        return try? JSONDecoder().decode(ErrorBody.self, from: data).error
    }
}
```

### `Core/Networking/APIError.swift`
```swift
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case network(Error)
    case server(status: Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized: String(localized: "Your session has expired. Please sign in again.")
        case .network: String(localized: "Can't reach the server. Check your connection.")
        case .server(_, let message?): message
        default: String(localized: "Something went wrong. Please try again.")
        }
    }
}
```

### `Core/Utilities/Error+UserMessage.swift`
```swift
import Foundation

extension Error {
    var userMessage: String {
        (self as? LocalizedError)?.errorDescription
            ?? String(localized: "Something went wrong. Please try again.")
    }
}
```

## 5. Repository protocol, remote and mock

### `Core/Repositories/ListingBrowsing.swift`
Role-based and small (interface segregation). The doc comment is the contract every conformer honours (Liskov).
```swift
import Foundation

protocol ListingBrowsing {
    /// Active listings from other sellers, filtered by `query.text` (title or location,
    /// case-insensitive) and `query.category`, ordered by `query.sort`.
    func fetchListings(matching query: ListingQuery) async throws -> [Listing]

    /// Throws `APIError.server(status: 404, …)` when the listing doesn't exist.
    func fetchListing(id: Listing.ID) async throws -> Listing
}
```

### `Core/Repositories/Remote/RemoteListingRepository.swift`
```swift
import Foundation

final class RemoteListingRepository: ListingBrowsing {
    private let client: any APIClient
    private let baseURL: URL

    init(client: any APIClient, baseURL: URL) {
        self.client = client
        self.baseURL = baseURL
    }

    func fetchListings(matching query: ListingQuery) async throws -> [Listing] {
        let dtos: [ListingDTO] = try await client.send(.listings(query))
        return dtos.map { Listing(dto: $0, baseURL: baseURL) }
    }

    func fetchListing(id: Listing.ID) async throws -> Listing {
        let dto: ListingDTO = try await client.send(.listing(id: id))
        return Listing(dto: dto, baseURL: baseURL)
    }
}
```

### `Core/Repositories/Mock/MockListingRepository.swift`
Same contract as the server: same filtering, sorting and errors. Not `#if DEBUG` (it also powers the offline demo mode).
```swift
import Foundation

final class MockListingRepository: ListingBrowsing {
    private let listings: [Listing]
    private let error: Error?
    private let latency: Duration

    init(listings: [Listing] = SampleData.listings, error: Error? = nil, latency: Duration = .zero) {
        self.listings = listings
        self.error = error
        self.latency = latency
    }

    func fetchListings(matching query: ListingQuery) async throws -> [Listing] {
        try await simulateNetwork()
        return query.apply(to: listings.filter { $0.status == .active })
    }

    func fetchListing(id: Listing.ID) async throws -> Listing {
        try await simulateNetwork()
        guard let listing = listings.first(where: { $0.id == id }) else {
            throw APIError.server(status: 404, message: String(localized: "This listing is no longer available."))
        }
        return listing
    }

    private func simulateNetwork() async throws {
        try await Task.sleep(for: latency)
        if let error { throw error }
    }
}
```

### `Core/Repositories/Mock/ListingQuery+Filtering.swift`
```swift
import Foundation

extension ListingQuery {
    func apply(to listings: [Listing]) -> [Listing] {
        let term = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = listings.filter { listing in
            let matchesCategory = category.map { listing.category == $0 } ?? true
            let matchesText = term.isEmpty
                || listing.title.localizedStandardContains(term)
                || listing.location.localizedStandardContains(term)
            return matchesCategory && matchesText
        }
        switch sort {
        case .newest: return filtered.sorted { $0.createdAt > $1.createdAt }
        case .priceLowToHigh: return filtered.sorted { $0.price < $1.price }
        case .priceHighToLow: return filtered.sorted { $0.price > $1.price }
        }
    }
}
```

## 6. View model

### `Features/Buyer/Browse/BrowseViewModel.swift`
No `import SwiftUI`. State is read-only from outside; intents are methods; the dependency is a protocol passed in.
```swift
import Foundation
import Observation

@Observable
final class BrowseViewModel {
    private(set) var state: Loadable<[Listing]> = .idle
    var searchText = ""
    private(set) var selectedCategory: ListingCategory?
    private(set) var sort: ListingSort = .newest

    private let repository: any ListingBrowsing

    init(repository: any ListingBrowsing) {
        self.repository = repository
    }

    // MARK: - Intents

    func load() async {
        if case .loaded = state {} else { state = .loading }   // keep content visible while refreshing
        do {
            let listings = try await repository.fetchListings(matching: query)
            state = .loaded(listings)
        } catch {
            state = .failed(message: error.userMessage)
        }
    }

    func selectCategory(_ category: ListingCategory?) async {
        guard category != selectedCategory else { return }
        selectedCategory = category
        await load()
    }

    func selectSort(_ newSort: ListingSort) async {
        sort = newSort
        await load()
    }

    // MARK: - Private

    private var query: ListingQuery {
        ListingQuery(text: searchText, category: selectedCategory, sort: sort)
    }
}
```

## 7. View, component and previews

### `Features/Buyer/Browse/BrowseView.swift`
```swift
import SwiftUI

struct BrowseView: View {
    @State private var viewModel: BrowseViewModel

    init(viewModel: BrowseViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Browse")
                .searchable(text: $viewModel.searchText, prompt: "Search items")
                .onSubmit(of: .search) { Task { await viewModel.load() } }
                .toolbar { sortMenu }
                .safeAreaInset(edge: .top) {
                    CategoryChips(selection: viewModel.selectedCategory) { category in
                        Task { await viewModel.selectCategory(category) }
                    }
                }
                .navigationDestination(for: Listing.ID.self) { id in
                    Text("Listing \(id)") // ListingDetailView(viewModel: container.makeListingDetailViewModel(id: id))
                }
        }
        .task { await viewModel.load() }
    }

    // MARK: - Sections

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let listings) where listings.isEmpty:
            ContentUnavailableView.search(text: viewModel.searchText)
        case .loaded(let listings):
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: Spacing.m)], spacing: Spacing.l) {
                    ForEach(listings) { listing in
                        NavigationLink(value: listing.id) { ListingCard(listing: listing) }
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.m)
            }
            .refreshable { await viewModel.load() }
        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't load listings", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.load() } }
            }
        }
    }

    private var sortMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Sort", selection: Binding(
                    get: { viewModel.sort },
                    set: { newSort in Task { await viewModel.selectSort(newSort) } }
                )) {
                    Text("Newest").tag(ListingSort.newest)
                    Text("Price: Low to High").tag(ListingSort.priceLowToHigh)
                    Text("Price: High to Low").tag(ListingSort.priceHighToLow)
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
}

// MARK: - Previews

#Preview("Loaded") {
    BrowseView(viewModel: BrowseViewModel(repository: MockListingRepository()))
}

#Preview("Empty") {
    BrowseView(viewModel: BrowseViewModel(repository: MockListingRepository(listings: [])))
}

#Preview("Error") {
    BrowseView(viewModel: BrowseViewModel(repository: MockListingRepository(error: APIError.network(URLError(.notConnectedToInternet)))))
}
```

### `Features/Buyer/Browse/Components/ListingCard.swift`
Takes plain values, not the view model, so it's reusable and trivially previewable.
```swift
import SwiftUI

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    AsyncImage(url: listing.photoURLs.first) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Theme.placeholderFill
                    }
                }
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            Text(listing.formattedPrice)
                .font(.headline)
            Text(listing.title)
                .font(.subheadline)
                .lineLimit(1)
            Text(listing.location)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ListingCard(listing: SampleData.listings[0])
        .frame(width: 180)
        .padding()
}
```

## 8. Composition root

### `App/AppContainer.swift`
The only file that knows concrete types.
```swift
import Foundation

final class AppContainer {
    let session: SessionStore
    private let listings: any ListingBrowsing & ListingManaging
    private let auth: any AuthServicing

    init(session: SessionStore, listings: any ListingBrowsing & ListingManaging, auth: any AuthServicing) {
        self.session = session
        self.listings = listings
        self.auth = auth
    }

    static func live() -> AppContainer {
        let tokenStore = KeychainTokenStore()
        let client = HTTPAPIClient(baseURL: AppConfig.apiBaseURL, tokenStore: tokenStore)
        return AppContainer(
            session: SessionStore(tokenStore: tokenStore),
            listings: RemoteListingRepository(client: client, baseURL: AppConfig.apiBaseURL),
            auth: RemoteAuthService(client: client, tokenStore: tokenStore)
        )
    }

    static func mock() -> AppContainer {
        let tokenStore = InMemoryTokenStore()
        return AppContainer(
            session: SessionStore(tokenStore: tokenStore),
            listings: MockListingRepository(),
            auth: MockAuthService(tokenStore: tokenStore)
        )
    }

    // MARK: - View model factories

    func makeBrowseViewModel() -> BrowseViewModel {
        BrowseViewModel(repository: listings)
    }
}
```

### `App/PureCS_Market_PlaceApp.swift`
```swift
import SwiftUI

@main
struct PureCS_Market_PlaceApp: App {
    @State private var settings: ServerSettings
    @State private var container: AppContainer

    init() {
        let settings = ServerSettings()
        _settings = State(initialValue: settings)
        _container = State(initialValue: AppContainer.make(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .id(ObjectIdentifier(container))
                .appEnvironment(container)
                .onChange(of: settings.revision) { container = AppContainer.make(settings: settings) }
        }
    }
}
```

## 9. Tests

### `PureCS Market PlaceTests/Features/Buyer/BrowseViewModelTests.swift`
```swift
import Foundation
import Testing
@testable import PureCS_Market_Place

@MainActor
struct BrowseViewModelTests {
    @Test func loadPublishesListings() async throws {
        let viewModel = BrowseViewModel(repository: MockListingRepository(listings: SampleData.listings))

        await viewModel.load()

        guard case .loaded(let listings) = viewModel.state else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(!listings.isEmpty)
    }

    @Test func selectingCategoryFiltersResults() async {
        let viewModel = BrowseViewModel(repository: MockListingRepository())

        await viewModel.selectCategory(.home)

        guard case .loaded(let listings) = viewModel.state else {
            Issue.record("Expected .loaded")
            return
        }
        #expect(listings.allSatisfy { $0.category == .home })
    }

    @Test func failureShowsUserMessage() async {
        let viewModel = BrowseViewModel(repository: MockListingRepository(error: APIError.unauthorized))

        await viewModel.load()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected .failed")
            return
        }
        #expect(message == APIError.unauthorized.errorDescription)
    }
}
```
