# Building the Android app

A guide to building the Android client with the same features, architecture and look as the iOS app. Read [API.md](API.md) (the contract) and [DESIGN.md](DESIGN.md) (the look) first.

## Recommended stack

| Concern | Choice | Why |
|---|---|---|
| Language / UI | Kotlin, **Jetpack Compose**, Material 3 | Declarative like SwiftUI, so screens port almost one to one |
| Architecture | **MVVM**: `ViewModel` + `StateFlow<UiState>` | Mirrors the iOS `@Observable` view models |
| Networking | **Retrofit + OkHttp + kotlinx.serialization** | Multipart support and an interceptor for the auth header |
| Images | **Coil** (`AsyncImage`) | Equivalent of SwiftUI `AsyncImage` |
| Navigation | Navigation Compose with typed routes | Same shape as the iOS `BuyerRoute` |
| Token storage | DataStore (Preferences) | Survives restarts. Encrypt with Android Keystore if this goes beyond a demo |
| Dependency injection | A hand-written `AppContainer` (same as iOS); move to Hilt later if it grows | Keeps the MVP simple, and the patterns match across platforms |
| Tests | JUnit 5 + kotlinx-coroutines-test (+ Turbine for flows) | Test view models against fake repositories |

Minimum SDK 26 is a sensible floor. Package name suggestion: `ae.purehealth.purecsmarket`. Put the project in `android/` at the repo root.

## Project structure

Mirror the iOS folders so people can find the same thing on both platforms:

```
android/app/src/main/java/ae/purehealth/purecsmarket/
├── App.kt, AppContainer.kt            composition root: creates API client, repositories, view-model factories
├── core/
│   ├── model/        Listing, User, ListingCategory, ItemCondition, ListingStatus, ListingQuery, ListingInput
│   ├── network/      ApiService (Retrofit), AuthInterceptor, dto/ (…Dto + toDomain()), ApiError
│   ├── repository/   ListingBrowsing, ListingManaging, AuthService   ← interfaces
│   │   ├── remote/   RemoteListingRepository, RemoteAuthService
│   │   └── mock/     MockMarketplace, SampleData (copy from iOS SampleData.swift)
│   ├── session/      SessionStore (StateFlow<SessionState>, mode)
│   ├── settings/     ServerSettings (base URL, offline mode, in DataStore)
│   └── util/         Loadable, ImageCompressor
├── designsystem/     Theme.kt (colours, type, shapes), PrimaryButton, SearchField, Chip, ListingCard,
│                     CategoryPlaceholder, FloatingTabBar, PillSegmentedControl, …
└── feature/
    ├── auth/         WelcomeScreen, AuthScreen + AuthViewModel
    ├── buyer/        BuyerTabs, home/ (HomeScreen + HomeViewModel), detail/ (ListingDetail…, ContactSellerSheet)
    ├── seller/       SellerTabs, mylistings/ (…Screen + ViewModel), editor/ (ListingEditor… + ListingDraft)
    ├── profile/      ProfileScreen
    └── settings/     ServerSettingsScreen + ViewModel
```

**Rules (the same as iOS):**
- Screens never call Retrofit.
- View models take repository **interfaces** in their constructor.
- Only `AppContainer` creates concrete classes.
- Every screen has a `@Preview` backed by the mock repository.
- One class per file.

## Key building blocks

```kotlin
// core/util/Loadable.kt: one loading state per screen
sealed interface Loadable<out T> {
    data object Idle : Loadable<Nothing>
    data object Loading : Loadable<Nothing>
    data class Loaded<T>(val value: T) : Loadable<T>
    data class Failed(val message: String) : Loadable<Nothing>
}
```

```kotlin
// core/repository/ListingBrowsing.kt: role-based, same contract as iOS
interface ListingBrowsing {
    /** Active listings from other sellers, filtered and sorted as [query] says. */
    suspend fun fetchListings(query: ListingQuery): List<Listing>
    /** Includes the seller's phone. Throws ApiError.Server(404) if it's gone. */
    suspend fun fetchListing(id: Int): Listing
}
```

```kotlin
// core/network/ApiService.kt
interface ApiService {
    @POST("auth/login") suspend fun login(@Body body: LoginRequest): AuthResponseDto
    @POST("auth/register") suspend fun register(@Body body: RegisterRequest): AuthResponseDto
    @POST("auth/logout") suspend fun logout()
    @GET("me") suspend fun me(): UserDto
    @GET("me/listings") suspend fun myListings(): List<ListingDto>
    @GET("listings") suspend fun listings(
        @Query("q") q: String?, @Query("category") category: String?, @Query("sort") sort: String,
    ): List<ListingDto>
    @GET("listings/{id}") suspend fun listing(@Path("id") id: Int): ListingDto
    @Multipart @POST("listings")
    suspend fun createListing(@PartMap fields: Map<String, @JvmSuppressWildcards RequestBody>,
                              @Part photos: List<MultipartBody.Part>): ListingDto
    @Multipart @PATCH("listings/{id}")
    suspend fun updateListing(@Path("id") id: Int,
                              @PartMap fields: Map<String, @JvmSuppressWildcards RequestBody>,
                              @Part photos: List<MultipartBody.Part>): ListingDto
    @PATCH("listings/{id}") suspend fun updateStatus(@Path("id") id: Int, @Body body: StatusRequest): ListingDto
    @DELETE("listings/{id}") suspend fun deleteListing(@Path("id") id: Int)
}
```

**Details that matter:**
- **snake_case:** annotate DTO fields with `@SerialName("price_aed")` (or use a snake-case naming strategy), and decode with `Json { ignoreUnknownKeys = true }` so new server fields don't break the app.
- **Auth header:** an OkHttp interceptor adds `Authorization: Bearer <token>`. On any `401` from an authenticated call, clear the token and set the session to signed-out. **But** `401` from `/auth/login` means "wrong password": show the server's message instead.
- **Errors:** parse `{ "error": "…" }` from error bodies into `ApiError.Server(status, message)` and show the message as-is. Map `IOException` to "Can't reach the server…".
- **Photo URLs:** resolve with `baseUrl.toHttpUrl().resolve(photo.url)`. They're relative locally and absolute in production.
- **Uploads:** each photo is a part named `photos`. **Compress first:** decode, scale so the longest side is ≤ 1600 px, `Bitmap.compress(JPEG, 75)`. Use the Photo Picker, which needs no storage permission: `PickMultipleVisualMedia(maxItems = 3 - current)` when 2 or more slots are free, `PickVisualMedia` when exactly 1 is (the multiple picker needs `maxItems` ≥ 2).
- **Prices:** `Int` dirhams on the wire. Format with `NumberFormat` as `AED 1,950`.
- **Dates:** parse with `Instant.parse(...)`, then show relative time with `DateUtils.getRelativeTimeSpanString`.
- **Calling the seller:** `Intent(Intent.ACTION_DIAL, Uri.parse("tel:$digits"))` opens the dialer without the CALL_PHONE permission. Copy with `ClipboardManager`.
- **Search:** debounce about 300 ms in the view model, e.g. `snapshotFlow`/`debounce` or a `Job` you cancel.

## Local development

| Running on | API base URL |
|---|---|
| Android **emulator** | `http://10.0.2.2:3000`, the emulator's alias for your computer's localhost |
| Real phone on the same Wi-Fi | `http://<LAN address printed by npm start>:3000` |
| Production | The deployed `https://` URL |

Copy the iOS **server settings screen**: let the user edit the base URL and turn on an **offline demo mode** that swaps in `MockMarketplace`. It's what makes live demos safe.

**Cleartext HTTP:** Android blocks plain `http://` by default. Allow it for development only, with `res/xml/network_security_config.xml` in a **debug** source set:

```xml
<network-security-config>
    <base-config cleartextTrafficPermitted="true" />  <!-- debug builds only -->
</network-security-config>
```

and `android:networkSecurityConfig="@xml/network_security_config"` in the debug manifest. Release builds should use `https://` only.

## Build order

1. **Design system:** `Theme.kt` with the tokens from DESIGN.md, plus the components, each previewed on its own.
2. **Models, DTOs, mock repositories, SampleData:** the whole app can now run offline.
3. **Screens on mocks:** Welcome → Auth → Home → Detail → My Listings → Editor → Profile, with tab bars and the mode switch.
4. **Real networking:** `ApiService`, interceptor, remote repositories, and the server settings screen.
5. **Photos:** picker, compression, multipart upload.
6. **View-model tests:** happy path, empty, failure, using the fakes.
7. **Run through the checklist below** against the iOS app.

## Parity checklist

- [ ] Sign up / sign in / sign out; a `401` anywhere returns to sign-in
- [ ] One account, Buying ↔ Selling switch in the header pill, tab centre button and Profile
- [ ] Feed: search (debounced), category bubbles (tap the selected one to clear), sort menu, promo banner only when unfiltered
- [ ] Own and sold listings never in the feed
- [ ] Detail: photo pager with thumbnails, chips, Read more, seller, Contact Seller sheet (Call / Copy)
- [ ] My Listings: stats, Active/Sold control, edit, mark sold / relist, delete with confirmation
- [ ] Editor: up to 3 photos (first is the cover, removable), validation shown after the first attempt, server errors shown
- [ ] Empty, loading and error states everywhere; pull to refresh
- [ ] Server settings + offline demo mode
