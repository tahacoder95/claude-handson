# PureCS Market Place

A thin MVP marketplace for a **live demo with ~20 users**: people post items for sale, others browse them and contact the seller by phone. One iOS app with two modes (Buying / Selling) on a single account, backed by a small Node.js + SQLite API.

Keep the scope thin. If a request adds something from "Out of scope" below, say so and confirm before building it.

## Repo layout

```
.
├── CLAUDE.md
├── .claude/skills/ios-develop/     iOS coding rules (MVVM, SOLID, conventions) — load before touching Swift
├── PureCS Market Place/            iOS app (Xcode project)
│   ├── PureCS Market Place.xcodeproj
│   ├── Config/Info.plist           merged into the generated plist (ATS exception for the HTTP demo server)
│   └── PureCS Market Place/        Swift sources: App/ Core/ DesignSystem/ Features/
└── backend/                        Node.js API: src/{routes,services,repositories,middleware,validation,db} · scripts/seed.js · test/
```

## Scope

**In (MVP)**
- Username + password sign-up/sign-in (display name and phone collected at sign-up), sign-out
- One account, Buying/Selling mode switch in Profile
- Buyer: browse grid, text search, category filter, sort (newest / price), listing detail with photo carousel, **Contact Seller** sheet (phone number with Call / Copy)
- Seller: My Listings (Active/Sold tabs, small stats line), create and edit a listing (up to 3 photos, title, description, price in AED, category, condition, location), mark sold / relist, delete with confirmation

**Out:** chat, push notifications, favourites, payments, ratings/reviews, maps, admin panel, social login.

UX reference (clickable prototype of every screen): https://claude.ai/artifact/KyGoGJ8nnh4YNjQVh994s6

## iOS app

- SwiftUI, iOS 26.5 deployment target, Xcode 26. No third-party packages.
- Architecture: **MVVM** — View → `@Observable` ViewModel → role-based repository protocols (`ListingBrowsing`, `ListingManaging`, `AuthServicing`) → `Remote…` (APIClient/URLSession) or `Mock…` implementations. Concrete types are created only in `App/AppContainer.swift`.
- **Before writing or changing any Swift code, use the `ios-develop` skill.** It holds the folder structure, one-type-per-file rule, SOLID mapping, naming conventions, templates for every layer and a review checklist.
- Build settings that matter: Swift 5 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (everything is main-actor by default), approachable concurrency on.
- The project uses **folder-synchronized groups**: new files under `PureCS Market Place/PureCS Market Place/` are added to the target automatically. Don't edit `project.pbxproj` by hand.
- `ServerSettings` (server address + **Offline demo mode**) is edited from the server button on the welcome screen; changing it rebuilds `AppContainer`. Offline mode uses `MockMarketplace`, so mocks ship in release builds.
- Design language (from the user's reference): periwinkle accent `#6B73E8`, lavender-grey background, white rounded cards, pill buttons, circular icon buttons, floating tab bar with a diamond centre button, rounded font. All tokens live in `DesignSystem/Theme.swift` and `Spacing.swift`; light mode only.
- `Config/Info.plist` sets `NSAllowsArbitraryLoads` because the demo server is plain HTTP. Remove it once the API is behind HTTPS.

### Commands

```bash
# Build
xcodebuild -project "PureCS Market Place/PureCS Market Place.xcodeproj" \
  -scheme "PureCS Market Place" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet build

# Test (once the test target exists)
xcodebuild -project "PureCS Market Place/PureCS Market Place.xcodeproj" \
  -scheme "PureCS Market Place" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet test

# Debug-only launch shortcuts (scheme arguments, or `xcrun simctl launch … -debug.signInAs omar -debug.mode selling`)
-debug.signInAs <username>     # signs in with the demo password
-debug.mode selling            # starts in selling mode
```

There is no iOS test target yet. When the first view model lands, ask the user to add one in Xcode (File → New → Target → Unit Testing Bundle, Swift Testing) named `PureCS Market PlaceTests`.

## Backend

- Node.js 24, Express 5, `@libsql/client` (SQLite locally, **Turso** in production), `@vercel/blob` (photos in production), `bcryptjs`, `multer` (memory storage), `zod`. Nothing else without asking.
- Deployed on **Vercel** as one serverless function: `backend/api/index.js` + `backend/vercel.json` route every path to the Express app (Vercel project Root Directory = `backend`). `src/server.js` is the local dev server. Both build the app through `src/bootstrap.js`.
- Storage is picked from env: `TURSO_DATABASE_URL`/`TURSO_AUTH_TOKEN` → Turso, else `file:data/market.db`; `BLOB_READ_WRITE_TOKEN` (or running on Vercel) → Vercel Blob, else `uploads/` served at `/uploads`. Photo rows store a reference (file name or blob URL); the service turns it into `photos: [{ id, url }]`.
- Serverless rules: no local disk writes, multi-statement writes are one `db.batch(...)` (atomic, one round trip), no reliance on `ON DELETE CASCADE` (delete children explicitly), request bodies ≤ 4.5 MB (photos capped at 4 MB each).
- Auth: passwords hashed with bcrypt; sign-in returns a random token stored in a `sessions` table; clients send `Authorization: Bearer <token>`. No JWT.
- Errors are JSON: `{ "error": "message" }` with a proper status code. JSON keys are `snake_case`; the iOS decoder converts them.
- Layers: routes (HTTP + validation) → services (rules: ownership, photo limits, storage cleanup) → repositories (SQL only).
- Demo data: an empty database is seeded automatically on first start (`SEED_DEMO_DATA=false` disables it): 4 accounts (`omar`, `aisha`, `sara`, `ravi`, password `demo123`) and 16 listings without photos. `npm run seed` wipes and re-seeds whichever database the env points at. `SampleData.swift` mirrors it for the app's offline mode.
- Node comes from nvm (`~/.nvm/versions/node/v24.18.0`); it isn't on the default PATH, so run `nvm use` or export that bin dir first.

```bash
cd backend
npm install
npm start         # http://localhost:3000 (seeds an empty local DB), also prints the LAN address for phones
npm run seed      # reset demo data
npm test          # node:test: API suite + the Vercel handler, against temp SQLite files
```

| Method | Path | Notes |
|---|---|---|
| POST | `/auth/register`, `/auth/login`, `/auth/logout` | register/login return `{ token, user }` |
| GET | `/me` | current user |
| GET | `/listings?q=&category=&sort=` | active listings; `sort` = `newest` \| `price_asc` \| `price_desc` |
| GET | `/listings/:id` | includes seller name and phone |
| GET | `/me/listings` | the seller's own listings, all statuses |
| POST | `/listings` | multipart, up to 3 `photos` |
| PATCH | `/listings/:id` | owner only: fields and/or `status` |
| DELETE | `/listings/:id` | owner only |

## Working rules

- Build after every Swift change and report the real result; don't claim success without it.
- Keep every screen previewable with mock data — if it can't be previewed, the dependencies are wrong.
- Use sample data that reads like real UAE listings (AED prices, Dubai / Abu Dhabi / Sharjah areas); no lorem ipsum.
- Don't commit, push or create branches unless asked.

## Open decisions (ask before assuming)

1. Will the 20 demo users install the app on their own phones (TestFlight + hosted backend) or watch one device?
2. Where the Node server is hosted (Render / Railway / Fly.io / VM vs a laptop on venue Wi-Fi).
