# Local setup

Get the API and the iOS app running on your machine, then on a real phone.

## 1. Prerequisites

| Tool | Version | Install |
|---|---|---|
| macOS | Recent | Only needed for iOS |
| Xcode | 26 or newer | Mac App Store. The app targets iOS 26.5 |
| Node.js | 24 | `nvm install 24` (install [nvm](https://github.com/nvm-sh/nvm) first) |
| Git | Any | `xcode-select --install` |

Android and web work need their own tools; see [ANDROID.md](ANDROID.md) and [WEB.md](WEB.md).

## 2. Run the API

```bash
cd backend
nvm use            # switches to Node 24 from .nvmrc
npm install
npm start
```

You should see:

```
Seeded 4 demo users and 16 listings (password "demo123").
PureCS Market API listening on http://localhost:3000
  on your network:  http://192.168.1.20:3000
```

Check it: `curl http://localhost:3000/health` should return `{"status":"ok"}`.

| Command | What it does |
|---|---|
| `npm start` | Runs the API. Seeds demo data if the database is empty |
| `npm run dev` | Same, restarting automatically when you change code |
| `npm run seed` | **Wipes everything** and restores the demo data |
| `npm test` | Runs the API tests against temporary databases. Your data is untouched |

Data lives in `backend/data/market.db` (SQLite) and photos in `backend/uploads/`. Both are git-ignored. To change ports or other settings, copy `backend/.env.example` to `backend/.env`; it's loaded automatically.

> Re-seeding or deleting `market.db` invalidates everyone's session. Apps will show the sign-in screen again; that's expected.

## 3. Run the iOS app in the simulator

1. Open `PureCS Market Place/PureCS Market Place.xcodeproj`.
2. Choose an iPhone simulator (e.g. iPhone 17 Pro) and press **Run** (⌘R).
3. Sign in as `omar` / `demo123`.

The app talks to `http://127.0.0.1:3000` by default, which is the Mac itself, so the simulator needs no extra setup.

From the command line:

```bash
xcodebuild -project "PureCS Market Place/PureCS Market Place.xcodeproj" \
  -scheme "PureCS Market Place" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet build
```

**Debug shortcuts:** in Xcode, open **Product → Scheme → Edit Scheme → Run → Arguments** and add:
- `-debug.signInAs omar` signs in automatically.
- `-debug.mode selling` starts in Selling mode.

These only work in Debug builds.

**Previews:** every SwiftUI view has `#Preview`s backed by mock data, so you can work on UI without the API running.

## 4. Run on a real iPhone

1. **Signing:** in Xcode, select the project → target **PureCS Market Place** → **Signing & Capabilities**. Pick *your* Team. If Xcode complains about the bundle identifier, change it to something unique, e.g. `com.yourname.purecs-market`.
2. Connect the iPhone, select it as the run destination, and press **Run**. The first time, approve the developer certificate on the phone under **Settings → General → VPN & Device Management**.
3. **Point the app at your Mac.** The phone can't reach `127.0.0.1` on your Mac. Put both on the **same Wi-Fi**, then on the app's welcome screen tap the **server button** (top right). Enter the address `npm start` printed under "on your network", e.g. `http://192.168.1.20:3000`, and save.
4. Allow **Local Network** access when iOS asks.

**Offline demo mode** (the same server screen) uses built-in sample data and needs no server at all. Sign in with `omar` / `demo123`. It's the fallback if the venue Wi-Fi fails.

## 5. Troubleshooting

| Problem | Fix |
|---|---|
| `command not found: node` / `npm` | Node comes from nvm: run `nvm use` in `backend/`, or `source ~/.nvm/nvm.sh` first |
| `EADDRINUSE: address already in use :::3000` | Something else uses port 3000. Stop it, or start with `PORT=3001 npm start` and use that port in the app |
| App shows "Can't reach the server" | API not running, wrong address in the server screen, or the phone is on a different network or guest Wi-Fi. Corporate Wi-Fi often blocks device-to-device traffic, so try a phone hotspot |
| Phone can't connect but the simulator can | macOS firewall: **System Settings → Network → Firewall**, allow incoming connections for `node` |
| Signed out unexpectedly | The database was re-seeded or reset. Sign in again |
| Xcode signing errors | Choose your own Team and a unique bundle ID (step 4.1) |
| `npm install` fails, or the API crashes on start after switching Node versions | Check `node -v` says v24, then `rm -rf node_modules && npm install` (the SQLite driver ships a per-platform binary) |
| Photos don't appear on the phone | The phone must reach the same server address that served the listing. Re-check the server screen |

Still stuck? Run `npm test` in `backend/`. If tests pass, the problem is network or app configuration rather than the API.
