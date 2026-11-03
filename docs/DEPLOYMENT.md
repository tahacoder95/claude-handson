# Deploying the API

The API runs on **Vercel** as a single serverless function. Vercel's disk is temporary and every instance gets its own, so production data lives in hosted services:

| What | Local | Production |
|---|---|---|
| Database | `backend/data/market.db` | **Turso** (hosted SQLite) |
| Photos | `backend/uploads/` | **Vercel Blob** |

The code picks the right one from environment variables (see `backend/src/config.js` and `backend/.env.example`).

## Current status

- **Done:**
  - The Vercel project `claude-handson-purecs` deploys from `main` with Root Directory `backend`.
  - The function runs: https://claude-handson-purecs.vercel.app/health answers with JSON.
- **To do:**
  - Connect a Turso database and Vercel Blob (steps 2–3 below).
  - Until then, every request returns `500 {"error":"The server is not configured: TURSO_DATABASE_URL is not set…"}`.

## Setting up from scratch (Vercel)

1. **Create the project.** On Vercel, go to **Add New → Project**, import this GitHub repo, and set:
   - **Root Directory:** `backend` (the repo also contains the iOS app).
   - **Framework Preset:** Other. `backend/vercel.json` already routes every path to `api/index.js`.
2. **Database.** Go to **Storage → Create Database → Turso** (Marketplace) and connect it to the project. Then make sure these exist under **Settings → Environment Variables** (Production):
   - `TURSO_DATABASE_URL`, like `libsql://<db>-<org>.turso.io`
   - `TURSO_AUTH_TOKEN`

   If the integration named them differently, add these two names yourself with the same values. Alternatively, create the database on turso.tech and paste the URL and a token.
3. **Photos.** Go to **Storage → Create → Blob** and connect it. This adds `BLOB_READ_WRITE_TOKEN`.
4. **Optional variables:**
   - `CORS_ORIGINS`: set it to the web app's origin once there is one (the default `*` allows any).
   - `SEED_DEMO_DATA=false`: set it once you no longer want demo data in a new, empty database.
5. **Redeploy.** Environment variables only apply to new deployments: **Deployments → ⋯ → Redeploy**.
6. **Verify:**
   ```bash
   curl https://<your-app>.vercel.app/health           # {"status":"ok"}
   curl -X POST https://<your-app>.vercel.app/auth/login \
     -H 'Content-Type: application/json' -d '{"username":"omar","password":"demo123"}'
   ```
   The first request into an empty database seeds the demo accounts and listings.
7. **Point the apps at it.** In the iOS app, tap the server button on the welcome screen and enter `https://<your-app>.vercel.app`.

**Re-seeding production:** run `npm run seed` locally with the production `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN` in `backend/.env`. **This wipes all production data.**

## Limits to know

| Limit | Value | Effect |
|---|---|---|
| Request body | 4.5 MB | Clients must compress photos (the iOS app does: about 1600 px, JPEG 0.75). Each photo is capped at 4 MB |
| Cold starts | About a second on the first request after idling | The first request after a quiet period is slower |
| Listings per feed request | 100 | Add pagination before real usage |

## Before real users (beyond the demo)

- **Plain-HTTP exception:** remove it from the iOS app (`PureCS Market Place/Config/Info.plist`, `NSAllowsArbitraryLoads`) once everything uses `https://`.
- **Default server address:** change the iOS default (`ServerSettings.defaultBaseURLString`) to the production URL, so testers don't have to type it.
- **CORS:** set `CORS_ORIGINS` to exact origins instead of `*`.
- **Product features:**
  - Rate limiting on `/auth/*`.
  - Token expiry.
  - Pagination.
  - Account deletion: Apple requires it for apps with sign-up.
  - Reporting listings and blocking users: also required by the App Store for user-generated content.

## Alternative: a regular server (Railway, Render, a VM)

If you'd rather run one long-lived server instead of serverless:
- Run `npm start` with a persistent volume.
- Set `UPLOADS_DIR=/data/uploads` and `TURSO_DATABASE_URL=file:/data/market.db`. A `file:` URL works with the same driver.
- No Turso or Blob account is needed.
- Keep it to **one instance**: the SQLite file lives on that machine's volume.
