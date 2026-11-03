# API reference

The contract every client (iOS, Android, web) follows. The source of truth is `backend/src/validation/schemas.js` and `backend/src/utils/serializers.js`. Update this file whenever either changes.

- **Base URL:** `http://localhost:3000` locally; your deployed URL in production.
- **Format:** JSON request and response bodies, except listing create/update, which are `multipart/form-data` because of photos.
- **Keys** are `snake_case` both ways.
- **Dates** are ISO-8601 UTC without fractional seconds: `"2026-11-03T09:51:02Z"`.
- **Money** is whole UAE dirhams as an integer: `price_aed: 1950`.

## Authentication

Sign in or register to get a `token`, then send it on every other request:

```
Authorization: Bearer 3f9c…e1a2
```

Tokens don't expire on their own. They stop working after sign-out or when the database is reset. **Any `401` means the session is over:** clear the stored token and show the sign-in screen.

## Errors

Every error has a status code and a body with a message you can show the user as-is:

```json
{ "error": "Title needs at least 3 characters." }
```

| Status | Meaning |
|---|---|
| `400` | Validation failed. The message names the problem |
| `401` | Missing or invalid token, or wrong username/password on `/auth/login` |
| `403` | You're changing someone else's listing |
| `404` | Listing or route doesn't exist |
| `409` | Username already taken |
| `500` | Server bug or misconfiguration |

Validation stops at the first problem, so `400` carries one message.

## Objects

### User

```json
{
  "id": 1,
  "username": "omar",
  "display_name": "Omar Haddad",
  "phone": "+971 50 987 6543",
  "created_at": "2026-07-06T09:51:02Z"
}
```

### Listing

```json
{
  "id": 12,
  "seller_id": 1,
  "seller_name": "Omar Haddad",
  "seller_phone": "+971 50 987 6543",
  "title": "Trek Marlin 7 mountain bike",
  "description": "Size M, hydraulic disc brakes.",
  "price_aed": 1850,
  "category": "sports",
  "condition": "good",
  "location": "Al Reem Island, Abu Dhabi",
  "status": "active",
  "photos": [
    { "id": 31, "url": "/uploads/1d0c….jpg" }
  ],
  "created_at": "2026-10-31T09:51:02Z",
  "updated_at": "2026-10-31T09:51:02Z"
}
```

- `seller_phone` is **only** included by `GET /listings/:id`. Show it on the detail screen.
- `photos` are ordered; the **first is the cover**. A listing can have 0–3 photos. Show a category placeholder when there are none (the demo data has none).
- `photos[].url` is **relative** (`/uploads/…`) on a local server and an **absolute** `https://` URL in production. Always resolve it against the base URL, which leaves absolute URLs unchanged: `new URL(url, baseUrl)`, `HttpUrl.resolve()`, or `URL(string:relativeTo:)`.

### Enums

| Field | Values |
|---|---|
| `category` | `electronics`, `home`, `fashion`, `vehicles`, `books`, `sports`, `other` |
| `condition` | `new`, `like_new`, `good`, `fair` |
| `status` | `active`, `sold` |
| `sort` (query) | `newest` (default), `price_asc`, `price_desc` |

Treat unknown values gracefully (e.g. fall back to `other`), so a new category doesn't crash old app versions.

## Endpoints

| Method | Path | Auth | Body | Returns |
|---|---|---|---|---|
| GET | `/health` | — | — | `{ "status": "ok" }` |
| POST | `/auth/register` | — | JSON | `201 { token, user }` |
| POST | `/auth/login` | — | JSON | `200 { token, user }` |
| POST | `/auth/logout` | ✓ | — | `204` |
| GET | `/me` | ✓ | — | `User` |
| GET | `/me/listings` | ✓ | — | `Listing[]` |
| GET | `/listings` | ✓ | query | `Listing[]` |
| GET | `/listings/:id` | ✓ | — | `Listing` (with `seller_phone`) |
| POST | `/listings` | ✓ | multipart | `201 Listing` |
| PATCH | `/listings/:id` | ✓ owner | multipart or JSON | `Listing` |
| DELETE | `/listings/:id` | ✓ owner | — | `204` |

### `POST /auth/register`

```json
{ "username": "taha", "password": "secret1", "display_name": "Taha", "phone": "+971 50 000 0000" }
```

| Field | Rule |
|---|---|
| `username` | 3–30 of `a–z 0–9 _ .`. Stored lowercase, unique, case-insensitive |
| `password` | 6–100 characters |
| `display_name` | 1–50 characters. Shown to buyers |
| `phone` | 7–20 digits and spaces, optional leading `+`. Shown to buyers on listing detail |

### `POST /auth/login`

```json
{ "username": "omar", "password": "demo123" }
```

Username is case-insensitive. Wrong credentials give `401 { "error": "Wrong username or password." }`. Show that message; don't treat it as "session expired".

### `GET /listings` (the buyer feed)

Query parameters, all optional: `q` (search text), `category`, `sort`.

```
GET /listings?q=bike&category=sports&sort=price_asc
```

- Only **active** listings.
- **Never the signed-in user's own listings.** Sellers see those in `/me/listings`.
- `q` matches title, description or location, case-insensitive.
- Returns up to 100 listings, with no pagination.

### `GET /me/listings`

All of the signed-in user's listings, **active and sold**, most recently changed first. Use it for the Selling screen and its stats (counts, and earnings = sum of `price_aed` where `status` is `sold`).

### `POST /listings` (create)

`multipart/form-data` fields:

| Field | Rule |
|---|---|
| `title` | 3–80 characters, required |
| `description` | Up to 1000 characters, optional |
| `price_aed` | Whole number, 1–10,000,000, required |
| `category` | Enum, required |
| `condition` | Enum, required |
| `location` | 2–80 characters, required. Area and city, not a street address |
| `photos` | 0–3 files, repeated field name `photos`. JPEG, PNG, HEIC or WebP, **≤ 4 MB each** |

**Compress photos on the device before uploading:** longest side about 1600 px, JPEG quality about 0.75. Production hosting rejects request bodies over 4.5 MB in total.

```bash
curl -X POST http://localhost:3000/listings \
  -H "Authorization: Bearer $TOKEN" \
  -F title="Grey sofa" -F price_aed=900 -F category=home -F condition=good \
  -F location="Al Majaz, Sharjah" -F description="Three seats." \
  -F photos=@sofa.jpg
```

### `PATCH /listings/:id` (edit, mark sold, relist)

Owner only (`403` otherwise). Send only what changes. Fields you leave out keep their values.

- **Text fields and status**, as JSON or multipart: any of `title`, `description`, `price_aed`, `category`, `condition`, `location`, `status`.
- **Photos:** new files need multipart; removals work either way.
  - `remove_photo_ids`: a comma-separated list such as `"31,32"` (or a JSON array) of photo ids to delete.
  - `photos`: new files, **appended** after the remaining ones.
  - The total after removals and additions must be ≤ 3.

```bash
# Mark as sold
curl -X PATCH http://localhost:3000/listings/12 -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"status":"sold"}'
```

### `DELETE /listings/:id`

Owner only. Deletes the listing and its photos permanently. Ask the user to confirm first.

## Product rules every client should mirror

- Your own listings never appear in your buyer feed; sold listings never appear in anyone's feed.
- Buyers contact sellers by phone only (there's no chat). Show the number with **Call** and **Copy**.
- Validate forms with the rules above before sending, but always show the server's message if it rejects anyway.
- Show validation errors after the first submit attempt, not while the form is still empty.
