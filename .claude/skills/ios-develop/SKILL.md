---
name: ios-develop
description: How to write Swift and SwiftUI code for the PureCS Market Place iOS app — MVVM with @Observable view models, SOLID, protocol-based repositories, one type per file, Swift API Design Guidelines, Swift Testing. Use this skill whenever you create, change, refactor or review anything in the iOS project — a new screen, a view model, a model or DTO, a repository, networking, previews, tests, or a bug fix in a .swift file — even if the user doesn't mention MVVM or architecture, and even for "small" changes, because small changes are where architecture drifts.
---

# iOS development — PureCS Market Place

This skill keeps the codebase consistent while several people (and Claude) add features quickly for a demo MVP. The rules exist so that any screen can be understood, previewed and tested on its own, and so that swapping the mock backend for the real Node.js API never touches a view.

Read this whole file before writing code. For copy-paste starting points of every layer (model → DTO → endpoint → repository → mock → view model → view → preview → test), read `references/feature-template.md`. Before you finish, run through `references/review-checklist.md`.

## Project facts you need

- Xcode 26, iOS 26.5 deployment target, SwiftUI only (no UIKit screens, no storyboards).
- Swift 5 language mode with **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** and approachable concurrency. Every type is `@MainActor` unless you say otherwise. Don't sprinkle `@MainActor` on everything; do mark pure value types or helpers `nonisolated` when they must be used off the main actor.
- The Xcode project uses **folder-synchronized groups**: any `.swift` file you create under `PureCS Market Place/PureCS Market Place/` is compiled automatically. Never edit `project.pbxproj` to add files.
- Module name for `@testable import`: `PureCS_Market_Place`.
- No third-party Swift packages. Use Foundation, SwiftUI, Observation, PhotosUI, Security (Keychain). Ask before adding a dependency.
- Backend: Node.js + Express + SQLite, JSON over HTTPS, `Authorization: Bearer <token>`. See the API table in the root `CLAUDE.md`.

## Architecture: MVVM with a repository layer

```
View (SwiftUI)  ──owns──►  ViewModel (@Observable)  ──depends on──►  Repository protocol
                                                                       ├─ Remote…Repository → APIClient → URLSession
                                                                       └─ Mock…Repository   (previews, tests, offline demo)
```

Dependencies point one way: View → ViewModel → protocol. Nothing points back up.

| Layer | Owns | Must not |
|---|---|---|
| **View** | Layout, styling, navigation, animations, reading `viewModel` state, calling `viewModel` intents | Call repositories or `URLSession`, contain business rules, format data with logic beyond trivial display, hold domain state in `@State` |
| **ViewModel** | Screen state (`private(set)`), user intents as methods, validation, mapping errors to messages, calling repositories | `import SwiftUI`, know about `Color`/`Font`/`View`, create its own dependencies, talk to `URLSession` |
| **Repository** | Fetching/saving domain models, mapping DTO ↔ model | Hold UI state, format strings for display |
| **APIClient** | HTTP, auth header, JSON coding, status-code → `APIError` | Know about specific features |
| **Model** | Plain `struct` domain data (`Identifiable`, `Equatable`, `Hashable`) | Be `Codable` against the wire format — that's the DTO's job |

Why the ViewModel doesn't import SwiftUI: it keeps view models unit-testable without a UI host, and it forces presentation concerns (colors, fonts) to stay in views. Observation (`import Observation`) gives you `@Observable` without SwiftUI.

### App-wide state vs screen state

- **Screen state** (search text, loading state, form fields) lives in that screen's view model.
- **App-wide state** (signed-in user, Buying/Selling mode) lives in `SessionStore`, an `@Observable` injected once with `.environment(session)` and read with `@Environment(SessionStore.self)`. Don't duplicate it into view models; pass the values a view model needs (e.g. `currentUser.id`) into its init or intent.

### Dependency injection (the D in SOLID)

- `App/AppContainer.swift` is the **composition root**: the only place that creates concrete types (`HTTPAPIClient`, `KeychainTokenStore`, `Remote…Repository`). It has `static func live()` and `static func preview()`/`mock()` factories, plus `make…ViewModel()` factory methods.
- View models receive protocols through `init`. No singletons (`static let shared`), no `ServiceLocator.resolve()` inside view models.
- Views receive their view model (or the container, at feature roots) through `init`.

### Owning a view model in a view

```swift
struct BrowseView: View {
    @State private var viewModel: BrowseViewModel

    init(viewModel: BrowseViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    // body uses viewModel.state, $viewModel.searchText, viewModel.intent()
}
```

- `@State` keeps the view model alive across re-renders. SwiftUI may call `init` again and throw the new instance away, so **keep view-model `init` cheap** — store dependencies only, do no work. Start loading from `.task { await viewModel.load() }`, which also cancels automatically when the view disappears.
- Child views that only display data take plain values (`let listing: Listing`), not the whole view model. Child views that need to mutate get a `Binding` or a closure (`onDelete: () -> Void`).

### Loading state

Use the shared `Loadable<Value>` enum (`Core/Utilities/Loadable.swift`) instead of separate `isLoading` / `error` / `items` properties that can disagree:

```swift
enum Loadable<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(message: String)
}
```

Views `switch` over it and must handle every case, including empty `loaded` results (`ContentUnavailableView`).

## SOLID, applied to this codebase

- **S — Single responsibility.** One view model per screen. A view model that serves two screens, or a view over ~150 lines, is a signal to split. Formatting lives in focused helpers (`Listing+Formatting.swift`, `PriceFormatter`), not in repositories or views.
- **O — Open/closed.** Extend by adding, not editing: a new data source is a new type conforming to the repository protocol; a new endpoint is a new `static func` in an `Endpoint+Feature.swift` extension; a new reusable style is a new `ButtonStyle`. Existing view models shouldn't change when you swap mock for remote.
- **L — Liskov substitution.** Every conformer honours the protocol's contract. `MockListingRepository` must throw the same kinds of errors, respect the same filters and sorting, and return the same shapes as the remote one — otherwise previews and tests lie. Document non-obvious contract rules on the protocol.
- **I — Interface segregation.** Small, role-based protocols: `ListingBrowsing` (buyer reads) and `ListingManaging` (seller create/update/delete/mine) instead of one fat `ListingService`. `AuthServicing` is separate from both. One concrete class may conform to several; each view model depends only on what it uses.
- **D — Dependency inversion.** View models depend on protocols, never on `Remote…` or `HTTPAPIClient`. Concrete types are created only in `AppContainer`.

## Files and folders

**One top-level type per file, file named after the type.** `BrowseViewModel` lives in `BrowseViewModel.swift`. Small private helper types used only by that file (a `private struct Row: View`) may stay in it. Extensions go in `Type+Purpose.swift` (`Listing+Formatting.swift`, `Endpoint+Listings.swift`). Why: you find code by type name, diffs stay small, and merge conflicts drop. Aim for files under ~200 lines; if one grows past that, it usually holds two responsibilities.

```
PureCS Market Place/PureCS Market Place/
├── App/                     PureCS_Market_PlaceApp.swift · AppContainer.swift · View+AppEnvironment.swift · DebugLaunchOptions.swift
├── Core/
│   ├── Models/              Listing.swift · ListingCategory.swift · ItemCondition.swift · ListingStatus.swift · User.swift · AppMode.swift
│   ├── Networking/          APIClient.swift · HTTPAPIClient.swift · Endpoint.swift · Endpoint+Auth.swift · Endpoint+Listings.swift
│   │                        HTTPMethod.swift · APIError.swift · MultipartFormData.swift
│   │   └── DTOs/            ListingDTO.swift · UserDTO.swift · AuthResponseDTO.swift · CreateListingRequest.swift
│   ├── Repositories/        ListingBrowsing.swift · ListingManaging.swift · AuthServicing.swift
│   │   ├── Remote/          RemoteListingRepository.swift · RemoteAuthService.swift
│   │   └── Mock/            MockMarketplace.swift · MockListingRepository.swift · MockAuthService.swift · SampleData.swift
│   ├── Session/             SessionStore.swift · Authenticating.swift
│   ├── Settings/            ServerSettings.swift · ServerSettingsStoring.swift
│   ├── Storage/             TokenStore.swift · KeychainTokenStore.swift
│   └── Utilities/           Loadable.swift · Error+UserMessage.swift · ImageCompressor.swift
├── DesignSystem/            Theme.swift · Spacing.swift · PrimaryButtonStyle.swift · FloatingTabBar.swift · ListingImageView.swift · …
└── Features/
    ├── Root/                RootView.swift · LaunchView.swift
    ├── Auth/                Welcome/WelcomeView.swift · SignIn/AuthView.swift · SignIn/AuthViewModel.swift
    ├── Settings/            ServerSettingsView.swift · ServerSettingsViewModel.swift
    ├── Buyer/               BuyerTabView.swift · BuyerRoute.swift
    ├── Buyer/Home/          HomeView.swift · HomeViewModel.swift · Components/ListingCard.swift · Components/CategoryRail.swift
    ├── Buyer/ListingDetail/ ListingDetailView.swift · ListingDetailViewModel.swift · Components/ContactSellerSheet.swift
    ├── Seller/MyListings/   MyListingsView.swift · MyListingsViewModel.swift · Components/MyListingRow.swift
    ├── Seller/ListingEditor/ListingEditorView.swift · ListingEditorViewModel.swift · ListingDraft.swift
    ├── Seller/              SellerTabView.swift (owns MyListingsViewModel so the editor sheet can refresh it)
    └── Profile/             ProfileView.swift (reads SessionStore directly; no view model needed)
```

Feature folders are by screen, each with its own `Components/` for subviews only that screen uses. A component used by two features moves to `DesignSystem/`. Mock repositories and sample data are compiled in release builds too, because the demo has an offline fallback mode — don't wrap them in `#if DEBUG`.

## Swift conventions

Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). In practice:

- **Naming:** `UpperCamelCase` types and protocols, `lowerCamelCase` everything else. Protocols describing a role end in `-ing`/`-able` or a noun (`ListingBrowsing`, `TokenStore`). Booleans read as assertions (`isLoading`, `hasMorePages`, `canPost`). Methods with side effects are verbs (`load()`, `markAsSold(_:)`); non-mutating ones read as nouns (`formattedPrice`). No abbreviations except well-known ones (`id`, `url`, `dto`) — and acronyms are uniformly cased (`apiClient`, `APIClient`, `listingID`).
- **Access control:** start `private`, widen only when needed. View model state is `private(set) var`; dependencies are `private let`. Mark classes `final` unless designed for subclassing.
- **Value types first:** models, DTOs, drafts and query objects are `struct`s; view models, stores and repositories are `final class`.
- **Safety:** no force unwraps (`!`) or `try!` in app code — `guard let … else` with an early return, or throw. The only exception is compile-time constants such as a hard-coded `URL(string:)` in `AppConfig`, which should carry a comment.
- **Errors:** throw typed errors (`APIError`, `ValidationError`) conforming to `LocalizedError`; view models convert to text with `error.userMessage`. Never swallow errors with empty `catch {}`.
- **Concurrency:** `async/await` only — no completion handlers, no Combine in new code, no `DispatchQueue.main.async` (everything is main-actor already). Prefer `.task {}` over `onAppear { Task {} }`, since it cancels for you.
- **Money:** prices are `Decimal` in models (never `Double`); the API sends integer AED.
- **Organisation inside a file:** properties → `init` → `body` (views) or public intents (view models) → private helpers, separated with `// MARK: - Section` comments.
- **Formatting:** 4-space indent, about 120-character lines, trailing commas in multi-line collections, one blank line between members. Comments explain *why*, not what.
- **Strings:** user-facing text goes in `Text("…")` / `String(localized:)` literals so it's ready for a String Catalog. No string-typed identifiers — use enums.

## SwiftUI conventions

- Keep `body` short: extract sections into `private var header: some View` or, when a section has its own inputs or is reused, into a separate `struct` in `Components/`.
- Styling comes from `DesignSystem` (`Theme.accent`, `Spacing.m`, `PrimaryButtonStyle`). No hex colours or magic numbers scattered through views.
- Navigation: one `NavigationStack` per tab with a typed `Route` enum and `.navigationDestination(for:)`. Sheets are driven by optional state (`sheet(item:)`), not multiple booleans.
- Every interactive element gets a meaningful accessibility label when its visible text isn't enough (icon-only buttons). Support Dynamic Type — don't fix text heights.
- Every view file ends with at least one `#Preview` that builds its view model with a mock repository. If a view is hard to preview, its dependencies are wrong.
- Images from the API use `AsyncImage` with a placeholder; photos picked with `PhotosPicker` are compressed by `ImageCompressor` before upload.

## Testing

- Use **Swift Testing** (`import Testing`, `@Test`, `#expect`, `#require`), not XCTest, for new tests.
- Test view models and repositories, not views: construct the view model with a mock, call an intent, `#expect` the resulting state. Cover the happy path, the empty result, and a failure.
- Test files mirror source: `BrowseViewModel.swift` → `PureCS Market PlaceTests/Features/Buyer/BrowseViewModelTests.swift`. Mark test suites `@MainActor`.
- If the test target doesn't exist yet, say so and ask the user to add it in Xcode (File → New → Target → Unit Testing Bundle, testing system: Swift Testing) rather than hand-editing the project file.

## Workflow for a new feature or screen

1. Model the data: domain `struct` in `Core/Models`, wire DTO in `Core/Networking/DTOs`, mapping `init(dto:)` on the model.
2. Add the endpoint as an `Endpoint` extension.
3. Extend or add a role-based repository protocol; implement it in both `Remote…` and `Mock…`.
4. Write the view model: state as `Loadable`/`private(set)`, intents as methods, dependencies via `init`.
5. Write the view, extracting components as they appear; add `#Preview`s for loaded, empty and error states.
6. Wire it in `AppContainer` (`make…ViewModel()`) and the parent view or tab.
7. Write view-model tests.
8. Build (and test, once the target exists):
   ```bash
   xcodebuild -project "PureCS Market Place/PureCS Market Place.xcodeproj" \
     -scheme "PureCS Market Place" \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet build
   ```
   Fix every error and new warning before saying you're done; report the build result honestly.

## Things to push back on

If a request would break these rules — "just put it all in ContentView", "call the API from the button" — do it the right way and briefly explain why, unless the user explicitly insists on the shortcut (e.g. a throwaway spike). Then mark the shortcut with a `// TODO:` so it's easy to find later.
