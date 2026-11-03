# PureCS Market Place

A thin marketplace MVP: people post items for sale, others browse them and contact the seller by phone. One account has two modes, **Buying** and **Selling**, and switches between them at any time.

This repo holds a working **iOS app** (SwiftUI) and **API** (Node.js + SQLite), built for a live demo. Android and web clients are next. Everything they need is in [`docs/`](docs/).

| | Status | Where |
|---|---|---|
| API | Done, 15 tests | [`backend/`](backend/) |
| iOS app | Done | [`PureCS Market Place/`](PureCS%20Market%20Place/) |
| Android app | To build | [`docs/ANDROID.md`](docs/ANDROID.md) |
| Web app | To build | [`docs/WEB.md`](docs/WEB.md) |
| Hosting | Vercel project created; database and photo storage still to connect | [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) |

## Quick start (about 5 minutes)

You need macOS with **Xcode 26+** for iOS, and **Node.js 24** for the API ([nvm](https://github.com/nvm-sh/nvm) recommended).

```bash
git clone https://github.com/tahacoder95/claude-handson.git
cd claude-handson/backend
nvm install        # reads .nvmrc → Node 24
npm install
npm start          # API on http://localhost:3000, seeds demo data on first run
```

Then open `PureCS Market Place/PureCS Market Place.xcodeproj` in Xcode, pick an iPhone simulator and press **Run**. Sign in with any demo account:

| Username | Password | Notes |
|---|---|---|
| `omar` | `demo123` | Has 3 active and 2 sold listings, good for Selling mode |
| `aisha`, `sara`, `ravi` | `demo123` | Other sellers, so everyone's feed has content |

No server handy? On the welcome screen tap the server button and turn on **Offline demo mode** to use built-in sample data.

Full setup, running on a real iPhone, and troubleshooting: **[docs/LOCAL_SETUP.md](docs/LOCAL_SETUP.md)**.

## What the MVP does

- **Accounts:** sign up with username, password, display name and phone; sign in; sign out.
- **Buying:** feed of other people's active listings, text search, category filter, sort by newest or price, listing detail with photos, and **Contact Seller** (the seller's phone number with Call / Copy).
- **Selling:** My Listings with Active/Sold tabs and earnings, post or edit a listing (up to 3 photos, title, description, price in AED, category, condition, pickup location), mark as sold or relist, delete.

Deliberately **out of scope**: chat, push notifications, favourites, payments, reviews, maps, admin tools.

## How it fits together

```
 iOS app (SwiftUI)  ─┐
 Android app (todo) ─┼──  HTTPS + JSON, Bearer token  ──►  Node.js API (Express)
 Web app (todo)     ─┘                                      ├─ SQLite: local file, or Turso in production
                                                            └─ Photos: local folder, or Vercel Blob in production
```

Every client talks to the same small REST API, documented in **[docs/API.md](docs/API.md)**. Clients follow the same layering (screen → view model → repository interface → API client) and share one design language.

## Documentation

| Doc | Read it when |
|---|---|
| [LOCAL_SETUP.md](docs/LOCAL_SETUP.md) | You're setting up a machine, running on a phone, or something won't start |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | You want to understand the code, or add a feature |
| [API.md](docs/API.md) | You're building or changing a client: every endpoint, field and rule |
| [DESIGN.md](docs/DESIGN.md) | You're building UI: colours, type, components, screens and flows |
| [ANDROID.md](docs/ANDROID.md) | You're building the Android app |
| [WEB.md](docs/WEB.md) | You're building the web app |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | You're putting the API online |
| [CLAUDE.md](CLAUDE.md) | You're using Claude Code in this repo (the iOS rules live in `.claude/skills/ios-develop`) |

## Repo layout

```
.
├── README.md                 you are here
├── CLAUDE.md                 instructions for Claude Code
├── docs/                     setup, architecture, API, design, Android, web, deployment
├── .claude/skills/ios-develop/  iOS coding rules: MVVM, SOLID, one type per file
├── backend/                  Node.js API
└── PureCS Market Place/      iOS app (Xcode project)
```

Android and web code should go in new top-level `android/` and `web/` folders.
