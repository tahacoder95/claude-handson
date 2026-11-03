# Design guide

The look every client shares: soft and friendly, a periwinkle accent on a pale lavender-grey background, white rounded cards, pill buttons and circular controls. The iOS implementation is the reference. Its tokens live in `PureCS Market Place/PureCS Market Place/DesignSystem/Theme.swift` and `Spacing.swift`; copy the values below rather than eyeballing screenshots.

The MVP is **light mode only**.

## Colour tokens

| Token | Hex | Use |
|---|---|---|
| `accent` | `#6B73E8` | Primary buttons, selected states, tab bar centre button |
| `accentPressed` | `#5961D9` | Pressed primary button |
| `accentText` | `#4A52C9` | Accent-coloured **text** on light backgrounds (passes 4.5:1 contrast; `accent` doesn't for small text) |
| `accentSoft` | `#E8EAFD` | Secondary buttons, icon circles, soft chips |
| `background` | `#F4F5FB` | Screen background |
| `surface` | `#FFFFFF` | Cards, fields, tab bar |
| `surfaceMuted` | `#ECEDF6` | Search field, neutral chips |
| `ink` | `#1C1D2B` | Primary text, dark icon buttons |
| `textSecondary` | `#666879` | Secondary text, inactive tab items |
| `danger` / `dangerSoft` | `#C62F25` / `#FCE9E7` | Errors, destructive actions / error banner background |
| `success` | `#1F8A55` | "Sold" chip text (on 12% tint) |
| Promo gradient | `#E4E7FD → #D4EEF4` | Home promo banner, top-left to bottom-right |
| Shadow | black at 7% | Soft card/button shadow: blur about 10, y-offset about 4 |

### Category placeholders

Listings without photos (all the demo data) show a pastel gradient with a category icon. Use the same colours everywhere so a category is recognisable at a glance.

| Category | Gradient (top-left → bottom-right) | Icon colour | iOS SF Symbol | Material Symbol (Android/web) |
|---|---|---|---|---|
| electronics | `#DCE9FA → #BDD6F4` | `#2F5BB7` | `iphone.gen3` | `smartphone` |
| home | `#FCE8D9 → #F5D0B2` | `#A4561B` | `sofa` | `chair` |
| fashion | `#FADFE9 → #F1C3D6` | `#A1365F` | `tshirt` | `apparel` |
| vehicles | `#E5E3FB → #CDC8F3` | `#4B43A8` | `car` | `directions_car` |
| books | `#F1E8DA → #E2D2BA` | `#6F4D2C` | `book` | `menu_book` |
| sports | `#DBF2E5 → #B9E3CB` | `#2B7341` | `figure.run` | `directions_run` |
| other | `#E8EAF0 → #D3D7E1` | `#4A5060` | `shippingbox` | `inventory_2` |

## Typography

A rounded sans-serif throughout.

| Platform | Font |
|---|---|
| iOS | System font with `.fontDesign(.rounded)` (SF Pro Rounded) |
| Android | [Nunito](https://fonts.google.com/specimen/Nunito) (closest rounded match), or system default if you must |
| Web | `font-family: ui-rounded, "SF Pro Rounded", "Nunito", system-ui, sans-serif` (load Nunito from Google Fonts) |

| Role | Size / weight |
|---|---|
| Screen headline (welcome, auth) | 34 / bold |
| Listing title on detail | 22 / bold |
| Section header ("Categories") | 20 / semibold |
| Name in greeting | 20 / bold |
| Body / button | 17 / semibold for buttons |
| Card title, secondary text | 15 / semibold or regular |
| Captions, chips, tab labels | 11–13 / semibold |

Prices are bold in `accentText`, formatted as `AED 1,950` with no decimals.

## Spacing and shape

- **Spacing scale (pt / dp / px):** 4 · 8 · 12 · 16 · 20 · 24 · 32. Screen side padding is **20**.
- **Radii:** cards 22, form fields 18, the detail hero image's bottom corners and bottom bar's top corners 36. Buttons, chips, search field and tab bar are **fully rounded** (pill/capsule).
- **Touch targets:** at least 44 × 44.

## Components

| Component | Spec |
|---|---|
| **Primary button** | Full width, 56 high, pill, `accent` fill, white semibold text, soft accent-tinted shadow; 50% opacity when disabled |
| **Secondary button** | Same shape, `accentSoft` fill, `accentText` label |
| **Compact pill** | 36 high, horizontal padding 16, `accent` fill, small semibold white text, e.g. "Start Selling" |
| **Circle icon button** | 44–52 round, white with soft shadow (or `ink` fill for emphasis), icon in `ink` |
| **Search field** | 52 high pill, `surfaceMuted`, magnifier icon, clear button when filled; a circle "filter" button beside it opens the sort menu |
| **Greeting header** | 52 avatar (initials on accent gradient, white ring), "Hello," (secondary) over the name (bold), and a **mode switch pill** on the right: "Sell" (tag icon) in Buying, "Browse" (bag icon) in Selling |
| **Promo banner** | Promo gradient card, radius 22: "Turn your clutter into **cash**" (accent word), subtitle, compact pill "Start Selling", round white artwork with a tag icon. Only shown when no search or filter is active |
| **Category bubble** | 64 rounded square (radius 20) category placeholder with white 2 px border, label below; selected gets a 3 px `accent` border and `accentText` label. Horizontal scrolling row |
| **Listing card** | Photo (or placeholder) filling a card about 0.74 wide:tall, radius 22, soft shadow; a frosted strip inset 8 at the bottom: title (1 line), "Area · 2 days ago", then price and a condition chip. 2-column grid, 16 gaps |
| **Chip** | Small capsule, 12 semibold: neutral (`surfaceMuted`), accent (`accentSoft` + `accentText`), frosted (blur), success |
| **Form field** | Label above (15 semibold); white field, radius 18, min height 54; on error a 1.5 `danger` border and a red message with an icon below |
| **Pill segmented control** | White capsule track; the selected segment is an `accent` capsule with white text that slides between options. Used for Active/Sold and Condition |
| **Floating tab bar** | White capsule, 72 high, inset 20 from the sides, big soft shadow; one item on each side plus a raised **diamond** button in the middle (a 46 rounded square rotated 45°, `accent`, white icon). Hidden on the listing detail screen |
| **Error banner** | `dangerSoft` rounded box with a warning icon and `danger` text |

## Screens and flows

```
Welcome ──► Create account / Sign in (sheet) ──► Buying mode
   └─ server button ► Server settings (address, Offline demo mode)

Buying mode   tab bar: [Home]  ◆ Sell  [Profile]          ◄──── mode switch ────►   Selling mode
  Home: greeting + Sell pill, search + sort, promo, categories, "Latest listings" grid      tab bar: [My Listings]  ◆ +  [Profile]
   └─► Listing detail: hero photos (swipe; thumbnail rail if >1), title, price,             My Listings: greeting + Browse pill, stats (Active, Sold, Earned),
       condition/category chips, area · age, description (Read more), seller,                Active/Sold control, rows (tap = edit; ⋯ = Edit / Mark as Sold or Relist / Delete)
       bottom bar: price + Contact Seller ─► sheet: phone, Call, Copy, safety tip          ◆ + ─► New listing: photos (up to 3, first is cover), title, description,
                                                                                               price (AED), category, condition, pickup location, Post Listing
Profile (both modes): avatar, name, @username, mode switch card, phone, server, Sign Out
```

**UX details to keep:**
- **Mode switch is never more than one tap away:** the header pill, the tab bar's centre button in Buying mode, and the Profile card.
- **Empty states explain and offer an action:** "No items found" with **Clear filters**; "No active listings" with **Post an Item**.
- **Load errors** show a message and **Try Again**; refreshing keeps the old content visible instead of flashing a spinner.
- **Search** runs as you type (about 300 ms debounce).
- **Deleting needs a confirmation.** Contact Seller ends with a safety tip.
- Form validation messages appear **after the first Post attempt**.

**References:**
- **Interactive prototype of every screen:** https://claude.ai/artifact/KyGoGJ8nnh4YNjQVh994s6. It's private; ask the project owner to share it.
- **Pixel reference:** run the iOS app (offline demo mode needs no server), or open any view's `#Preview` in Xcode.
