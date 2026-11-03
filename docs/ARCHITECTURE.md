# Architecture

## The big picture

```
┌────────────── Clients ──────────────┐            ┌──────────────── backend/ ────────────────┐
│ iOS (SwiftUI)   ← done              │            │ Express app (src/app.js)                 │
│ Android (Compose) ← docs/ANDROID.md │ ── JSON ──►│  routes → services → repositories → SQL  │
│ Web (React)      ← docs/WEB.md      │  Bearer    │  photo storage (disk or Vercel Blob)     │
└─────────────────────────────────────┘  token     └──────────────────────────────────────────┘
```

All clients use the same layering, so a feature looks alike on every platform:

```
Screen / View  →  ViewModel (screen state + user intents)  →  Repository interface  →  API client
                                                            ↘  Mock repository (previews, tests, offline demo)
```

**The rules behind it:**
- **Screens never call the network.** They render view-model state and call view-model methods.
- **View models depend on interfaces**, passed in through their constructor. Only the *composition root* (`AppContainer` on iOS) creates concrete classes.
- **Interfaces are small and role-based** (SOLID's interface segregation): `ListingBrowsing` for buyers, `ListingManaging` for sellers, `AuthServicing` for accounts.
- **Mocks follow the same rules as the server** (own listings hidden, sold hidden, owner-only edits), so previews and tests tell the truth.
- **One loading state per screen:** `idle | loading | loaded(value) | failed(message)`, never separate flags that can disagree.

## Backend (`backend/`)

Node.js 24, Express 5, SQLite via `@libsql/client`, `zod` for validation, `bcryptjs` for passwords, `multer` for uploads.

```
backend/
├── api/index.js           Vercel serverless entry (wraps the app)
├── vercel.json            routes every path to api/index.js
├── scripts/seed.js        npm run seed: wipe and restore demo data
├── src/
│   ├── server.js          local dev server (npm start)
│   ├── bootstrap.js       builds the app from env config; shared by server.js and api/index.js
│   ├── config.js          every setting, read from environment variables
│   ├── app.js             wiring: repositories → services → routes
│   ├── routes/            HTTP only: parse/validate input, call a service, serialize output
│   ├── services/          rules: ownership, photo limits, keeping photo storage in sync
│   ├── repositories/      SQL only, no rules
│   ├── storage/           photo storage: local disk or Vercel Blob, same interface
│   ├── middleware/        auth, CORS, uploads, errors, logging
│   ├── validation/        zod schemas (the API contract) + parse helpers
│   ├── db/                connection, schema migration, demo seed data
│   └── utils/             HttpError, JSON serializers, SQLite error helpers
└── test/                  node:test suites (run against temp SQLite files)
```

**Request flow:** route → `parse(schema, input)` (400 on failure) → service (throws `HttpError` for 403/404/409) → repository (SQL) → `serializeX()` → JSON. The error handler turns anything thrown into `{ "error": "…" }`.

**Data model:**

```
users(id, username UNIQUE, password_hash, display_name, phone, created_at)
sessions(token PK, user_id → users, created_at)
listings(id, seller_id → users, title, description, price_aed INT, category, condition,
         location, status active|sold, created_at, updated_at)
listing_photos(id, listing_id → listings, file_name, position)   -- file_name = disk name or blob URL
```

The schema is created automatically on start (`src/db/migrate.js`, `CREATE TABLE IF NOT EXISTS`). There's no migration tool yet: for a breaking change, add a numbered migration step rather than editing the existing statements.

**Environment switches** (see `backend/.env.example`):

| Setting | Local default | Production |
|---|---|---|
| Database | `file:data/market.db` | `TURSO_DATABASE_URL` + `TURSO_AUTH_TOKEN` |
| Photos | `uploads/` folder, served at `/uploads` | Vercel Blob (`BLOB_READ_WRITE_TOKEN`) |
| Demo data | Seeded when empty | Same (`SEED_DEMO_DATA=false` turns it off) |
| CORS | `*` | `CORS_ORIGINS` = the web app's origin |

**Serverless rules** (the API also runs on Vercel):
- Never write to local disk in production.
- Make multi-statement writes one atomic `db.batch([...])`.
- Delete child rows explicitly instead of relying on `ON DELETE CASCADE`.
- Keep request bodies under 4.5 MB.

**Adding an endpoint:**
1. Zod schema in `validation/schemas.js`.
2. Repository method (SQL).
3. Service method (rules).
4. Route.
5. Serializer, if the endpoint returns a new shape.
6. A test in `test/api.test.js`.
7. Document it in [API.md](API.md).

## iOS app (`PureCS Market Place/`)

SwiftUI, iOS 26.5, Swift 5 mode with **main-actor isolation by default**, and no third-party packages. The full rules are in [`.claude/skills/ios-develop/SKILL.md`](../.claude/skills/ios-develop/SKILL.md). It's written for Claude Code but is the team's iOS style guide too.

```
PureCS Market Place/PureCS Market Place/
├── App/            entry point, AppContainer (composition root), debug launch options
├── Core/
│   ├── Models/        domain structs (Listing, User, enums) + DTO mapping + formatting
│   ├── Networking/    APIClient, HTTPAPIClient, Endpoint (+ per-feature extensions), DTOs, multipart
│   ├── Repositories/  ListingBrowsing, ListingManaging, AuthServicing
│   │   ├── Remote/    real implementations over APIClient
│   │   └── Mock/      MockMarketplace (in-memory server), SampleData (mirrors the seed)
│   ├── Session/       SessionStore: who is signed in, Buying/Selling mode
│   ├── Settings/      ServerSettings: server address, offline demo mode
│   ├── Storage/       TokenStore (Keychain)
│   └── Utilities/     Loadable, image compression, helpers
├── DesignSystem/   Theme, Spacing, button styles, cards, chips, tab bar… (see DESIGN.md)
└── Features/
    ├── Root/          RootView: launch / signed out / buying / selling
    ├── Auth/          Welcome, sign in / register
    ├── Settings/      server address screen
    ├── Buyer/         BuyerTabView, Home (feed), ListingDetail
    ├── Seller/        SellerTabView, MyListings, ListingEditor
    └── Profile/       shared by both modes
```

**Conventions:**
- One type per file, named after the type.
- View models are `@Observable final class`, don't import SwiftUI, expose `private(set)` state and intent methods, and receive protocols through `init`.
- Views own their view model with `@State` and start loading in `.task {}`.
- Every view file ends with `#Preview`s built on mocks.

**App-wide state:**
- `SessionStore` holds who is signed in and the current mode, and is shared through the environment.
- `ServerSettings` holds the server address and the offline switch. Changing it rebuilds `AppContainer`.
- A `401` from any request signs the user out (`HTTPAPIClient.onUnauthorized`).

**iOS tests:** there's no test target yet. Add one in Xcode (File → New → Target → Unit Testing Bundle, Swift Testing, named `PureCS Market PlaceTests`), then test view models against `MockListingRepository`.

## Where Android and web plug in

They're new folders, `android/` and `web/`, that talk to the same API. Use the same screen → view model → repository layering and the same mock-first approach. Platform guides: [ANDROID.md](ANDROID.md), [WEB.md](WEB.md). Visual spec: [DESIGN.md](DESIGN.md).
