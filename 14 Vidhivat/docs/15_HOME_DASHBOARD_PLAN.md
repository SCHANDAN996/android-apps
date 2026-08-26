# 15 — Home / Dashboard Plan

**Status:** Implemented and verified on the connected Vivo V2553.

Implementation uses four destinations (`होम`, `पूजा`, `कैलेंडर`, `अधिक`),
real local Panchang data, technical Puja resume position, 2×2 quick actions
and centered 2×2 Puja artwork cards. No religious content or verification
flag was changed as part of this dashboard work.

## Goal

Home should answer four questions without making the user search:

1. आज का महत्वपूर्ण पंचांग क्या है?
2. अभी कौन-सी पूजा शुरू या जारी कर सकता हूँ?
3. संकल्प या चौघड़िया जल्दी कैसे खोलूँ?
4. बाकी पूजा-विधियाँ कहाँ मिलेंगी?

Home is a daily dashboard. The separate Puja tab remains the complete library.

## Recommended bottom navigation — four destinations

| Tab | Contains |
|---|---|
| `होम` | Daily Panchang summary, featured/resume Puja, quick actions, popular Pujas |
| `पूजा` | Complete Puja Library, categories, search and availability status |
| `कैलेंडर` | Calendar, festivals and selected-day Panchang |
| `अधिक` | Sankalp, full Choghadiya/Hora, Settings, sources and app information |

Current `आज` becomes part of Home. Current `संकल्प`, `चौघड़िया` and `सेटिंग` remain directly reachable through Home quick actions and the More screen. No feature is removed.

## Home hierarchy

### 1. Compact header

- Greeting: `जय श्री गणेश 🙏`
- Current auto/manual location label
- Location label is tappable and opens the shared location selector
- Do not add notification/profile icons until they have real functionality

### 2. Primary hero — one action only

Priority order:

1. If a Puja has resumable progress: `पूजा जारी रखें`
2. Otherwise: show the existing `नित्य पूजा` as the calm default
3. A festival-specific recommendation may appear only when the existing festival engine and an available Puja entry both support it

Hero contains artwork, title, short supporting line, duration, step count and one primary CTA. Artwork must blend into the surface with transparent edges and preserve its aspect ratio.

### 3. Today’s Panchang strip

Four compact values:

- तिथि
- सूर्योदय
- राहुकाल
- शुभ समय / अभिजित when available

The whole strip opens the detailed Today/Panchang view. Values must come from the existing Panchang engine and the shared exact location coordinates.

### 4. Quick actions — 2 × 2

- `पूजा विधि`
- `आज का पंचांग`
- `संकल्प`
- `चौघड़िया`

These are navigation shortcuts, not duplicate business logic. A generic `सामग्री` action should be shown only when there is an active/resumable Puja whose checklist can be opened.

### 5. Popular / useful Puja grid — 2 × 2

- Show at most four image-led cards on Home
- Card contains a centred Puja-specific image and Puja name only
- No repeated diya placeholder when a specific approved asset exists
- `सभी देखें` opens the full Puja tab
- Do not put procedure text, verification copy or buttons over the image

### 6. Trust line

Show a small non-intrusive content-status line or source link. Never imply that an unreviewed Puja is authoritative.

## Visual direction

- Deep charcoal plus smoky aubergine background
- Warm ivory text
- Antique gold limited to emphasis, active navigation and primary CTA
- Copper/brown separators instead of bright yellow outlines everywhere
- Soft local artwork glow; no rectangular black image backgrounds
- Rounded surfaces with restrained elevation
- Minimum 48 dp touch targets and Hindi text scaling support

## Data and state

Create one Home view model assembled only from existing sources:

- `settings.city/place` for location-sensitive calculations
- Panchang engine for today’s values
- festival engine for real date relevance
- `vidhiBhandar` for Puja availability and content status
- saved player progress for resume state
- `DevotionalAssets` for stable Puja-specific artwork mapping

Home must not invent a recommendation, duration, verification status, mantra or festival association.

## Implementation phases

1. **Navigation:** introduce Home and More; remap the current six destinations into four without deleting screens.
2. **Dashboard data:** add a small Home data/view-model layer that reads existing engines and repositories.
3. **Dashboard UI:** header, hero, Panchang strip, quick actions and four-card Puja grid.
4. **Interactions:** resume/open Puja, location selector, Today detail, Sankalp and Choghadiya routes.
5. **More screen:** Sankalp, Choghadiya, Settings, sources and about links.
6. **Verification:** 320/360/393 dp, large text, long Hindi labels, offline mode, location denied/manual mode, empty progress and resumable-progress states.

## Files expected in implementation

- `app/lib/main.dart` — four-destination shell
- `app/lib/screens/home_screen.dart` — new dashboard
- `app/lib/screens/more_screen.dart` — grouped secondary destinations
- `app/lib/screens/vidhi_list_screen.dart` — remains the full Puja library
- `app/lib/widgets/design_system.dart` — only if a genuinely reusable dashboard primitive is missing
- targeted widget tests plus navigation/state tests

## Explicit non-goals for the first dashboard pass

- No new Puja ritual content
- No fake notifications or account/profile system
- No advertisements
- No AI-generated daily religious claim
- No duplicated Panchang calculations
- No package addition unless implementation proves it necessary
