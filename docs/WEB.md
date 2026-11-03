# Building the web app

A guide to building a responsive web client with the same features, architecture and look as the iOS app. Read [API.md](API.md) (the contract) and [DESIGN.md](DESIGN.md) (the look) first.

## Recommended stack

| Concern | Choice | Why |
|---|---|---|
| Framework | **React + TypeScript**, built with **Vite** | A fast dev server, and a plain static site to deploy |
| Server state | **TanStack Query** | Caching, refetching, and loading/error states for free. Plays the "view model" role for data |
| Routing | React Router | `/`, `/listings/:id`, `/sell`, `/sell/new`, `/sell/:id/edit`, `/profile`, `/signin` |
| Styling | CSS variables for the DESIGN.md tokens + CSS Modules (or Tailwind configured with the same tokens) | One place for colours, radii and spacing |
| Forms | Controlled components + a small validator mirroring API.md's rules | Same messages as the server |
| Tests | Vitest + Testing Library; MSW to fake the API | Test hooks and screens without a server |

Put the project in `web/` at the repo root (`npm create vite@latest web -- --template react-ts`).

## Project structure

The same layering as the mobile apps: components never call `fetch` directly.

```
web/src/
├── main.tsx, App.tsx              router, QueryClientProvider, session provider
├── app/container.ts               composition root: picks the remote or mock repositories
├── core/
│   ├── models.ts                  Listing, User, enums, ListingQuery, ListingInput
│   ├── api/
│   │   ├── apiClient.ts           fetch wrapper: base URL, Bearer token, JSON, { error } → ApiError, 401 handling
│   │   ├── dto.ts + mappers.ts    wire types (snake_case) → models (camelCase), photo URL resolution
│   ├── repositories/
│   │   ├── types.ts               ListingBrowsing, ListingManaging, AuthService interfaces
│   │   ├── remote*.ts             real implementations
│   │   └── mock/                  mockMarketplace.ts, sampleData.ts (copy from iOS SampleData.swift)
│   ├── session/                   SessionContext: user, mode (buying/selling), token in localStorage
│   └── images/compress.ts         canvas resize + JPEG before upload
├── design-system/                 tokens.css, Button, SearchField, Chip, ListingCard, CategoryPlaceholder,
│                                  PillSegmentedControl, TabBar, FormField, ErrorBanner, …
└── features/
    ├── auth/        WelcomePage, AuthForm
    ├── buyer/       HomePage (+ useListingsFeed hook), ListingDetailPage, ContactSellerDialog
    ├── seller/      MyListingsPage (+ useMyListings), ListingEditorPage (+ useListingDraft)
    └── profile/     ProfilePage
```

**Custom hooks are the view models.** For example, `useListingsFeed()` owns the search text, category and sort, debounces the search, and returns `{ state, setQuery, selectCategory, … }`. Pages render that state and call its functions.

## Key building blocks

```ts
// core/api/apiClient.ts
export class ApiError extends Error {
  constructor(public status: number, message: string) { super(message); }
}

export function createApiClient(baseUrl: string, getToken: () => string | null, onUnauthorized: () => void) {
  async function request<T>(path: string, init: RequestInit & { auth?: boolean } = {}): Promise<T> {
    const headers = new Headers(init.headers);
    const token = getToken();
    if (init.auth !== false && token) headers.set('Authorization', `Bearer ${token}`);
    const response = await fetch(new URL(path, baseUrl), { ...init, headers });
    if (response.status === 204) return undefined as T;
    const body = await response.json().catch(() => ({}));
    if (!response.ok) {
      // 401 from /auth/login means "wrong password", not "session expired".
      if (response.status === 401 && init.auth !== false) onUnauthorized();
      throw new ApiError(response.status, body.error ?? 'Something went wrong. Please try again.');
    }
    return body as T;
  }
  return { request, baseUrl };
}
```

```ts
// Creating a listing: FormData, with each photo appended under the same name
const form = new FormData();
form.append('title', input.title);
form.append('price_aed', String(input.price));
// …description, category, condition, location
for (const photo of compressedPhotos) form.append('photos', photo, 'photo.jpg');
await client.request<ListingDto>('/listings', { method: 'POST', body: form }); // don't set Content-Type yourself
```

**Details that matter:**
- **Photo URLs:** `new URL(photo.url, baseUrl).href`. They're relative locally and absolute in production.
- **Compress before upload:** `createImageBitmap(file)`, draw it onto a canvas with the longest side ≤ 1600 px, then `canvas.toBlob(cb, 'image/jpeg', 0.75)`. Production rejects bodies over 4.5 MB. Use `<input type="file" accept="image/*" multiple>` and enforce "3 minus the current count" in code.
- **Token storage:** `localStorage` is fine for the MVP, because the API uses Bearer tokens, not cookies. Keep everything rendered through React (no `dangerouslySetInnerHTML`) so listing text can't inject scripts.
- **Money and dates:** `new Intl.NumberFormat('en-AE', { style: 'currency', currency: 'AED', maximumFractionDigits: 0 })` and `Intl.RelativeTimeFormat`.
- **Contact Seller:** use a `tel:` link for Call (it opens the dialer on phones) and `navigator.clipboard.writeText` for Copy. On desktop, show the number prominently.
- **Accessibility:** use real `<button>`/`<a>` elements, labels on inputs, `aria-label` on icon-only buttons, visible focus rings, and the colour pairs from DESIGN.md (use `accentText`, not `accent`, for small text).

## Layout: mobile first, then wider

- **Phones (< 640 px):** match the iOS screens exactly, including the floating bottom tab bar with the diamond centre button.
- **Tablet and desktop:**
  - The listing grid goes to 3 or 4 columns (`grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))`) inside a container up to about 1200 px wide.
  - The tab bar becomes a top navigation bar: logo, Home / My Listings, a mode switch pill, Profile.
  - Listing detail becomes two columns, photos on the left and details plus Contact Seller on the right.
  - Sheets become centred dialogs.

## Local development

```bash
cd web
npm install
npm run dev        # http://localhost:5173
```

Point the app at the API with an env var:

```bash
# web/.env.local
VITE_API_BASE_URL=http://localhost:3000
```

The API already sends CORS headers (`CORS_ORIGINS`, default `*`), so the browser can call it directly. In production, set `CORS_ORIGINS` on the API to your web app's exact origin, e.g. `https://purecs-market-web.vercel.app`.

Add an **offline demo mode** that switches `container.ts` to the mock repositories, e.g. with `?demo=1` or a toggle on the sign-in page. It lets you develop UI and run demos without a server.

## Deploying

The web app is a static build (`npm run build` → `dist/`). Deploy it as a **separate Vercel project** with Root Directory `web`, framework preset Vite, and environment variable `VITE_API_BASE_URL=https://<your API URL>`. Then add that site's origin to the API's `CORS_ORIGINS`.

## Build order

1. `tokens.css` and design-system components, each on a simple demo page.
2. Models, DTOs, mappers, mock repositories, sample data, then every screen working on mocks.
3. API client, remote repositories, session handling (including 401 → sign-in).
4. Photo picking, compression, upload.
5. Responsive desktop layout.
6. Tests for hooks (with mock repositories) and key flows (with MSW).
7. Run the parity checklist in [ANDROID.md](ANDROID.md#parity-checklist). It applies to the web app too.
