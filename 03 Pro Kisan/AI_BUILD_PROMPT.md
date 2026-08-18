# AI BUILD PROMPT — Pro Kisan (प्रो किसान) 3-in-1

> **उपयोग (मेरे लिए):** पूरा English हिस्सा किसी भी AI को दो + PLAN.md। साथ में Jameen Napi project का `lib/data/land_units.dart` (राज्य-wise बीघा table) दो — reuse होगा। App बनने के बाद root की `0.1 PLAY STORE ASSETS PROMPT` file use करो। यह spec पुराने 3 apps (Dudh, Pashu, Khaad) का merge है — कहीं और देखने की ज़रूरत नहीं, सब यहीं है।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec. Hindi-first UI (Devanagari), simple large-button design for rural Indian users aged 30-55. Do not skip sections; ask at most 3 questions, otherwise proceed with stated defaults.

## PRODUCT
**Pro Kisan (प्रो किसान)** — a 3-in-1 offline companion that makes an Indian dairy farmer a "pro":
1. **दूध (Milk)** — daily milk record book (the daily-use core)
2. **पशु (Cattle)** — pregnancy & vaccination reminders
3. **खाद-बीज (Fertilizer & Seed)** — dose calculators

## STANDARD PROJECT RULES
- Flutter stable, Android-only, minSdk 23, Material 3, < 25 MB.
- Package `com.chandansingh.pro_kisan`. App display name: "Pro Kisan" (in-app branding: "प्रो किसान"). 100% offline, no login/server; INTERNET permission only for ads. (Base code `dudh_ka_hisab` must be renamed to this package.)
- DB: **sqflite** — ALL db code in a clean `lib/db/` module (models, DAOs, versioned migrations). I will reuse this module in future apps; document it.
- State: Provider/Riverpod. All UI strings in one strings file: Hindi (default) + English structure.
- Local notifications: `flutter_local_notifications` (default 7:00 AM; reschedule on boot). POST_NOTIFICATIONS runtime permission with Hindi explanation; app fully usable if denied.
- Local backup/restore: full DB export/import as versioned JSON via share/file-picker. Monthly backup reminder notification.
- AdMob (`google_mobile_ads`): **TEST ad unit IDs** in code; real IDs via one config file. Placements ONLY: banner on Milk home bottom; interstitial when opening monthly milk report (max 1/session) and after every 3rd fertilizer calculation. Never on app open/exit, never on reminder screens.
- in_app_review after 15th milk entry. Settings: language, mode, rates, notification time, backup, privacy-policy + more-apps placeholders.
- Indian number format (1,00,000), dates DD-MM-YYYY, Hindi month names on reports.
- Never crash on empty/zero input — friendly Hindi validation everywhere.
- Deliverables: full runnable project + README (build steps, real-AdMob-ID steps, keystore steps) + unit tests for all money/date math.

## FIRST-RUN ONBOARDING (mandatory, build this first)
Three quick full-screen steps shown ONCE on first launch (all editable later in Settings; stored in shared_preferences):
1. **Language** — big buttons: हिंदी / English (design the screen so more languages can be added later). Cannot skip.
2. **State** — searchable list of all 28 states + UTs with a "बाद में बदल सकते हैं" note. State drives: bigha/katha size (khaad module), and later yojana/mandi filtering. Cannot skip (default fallback: उत्तर प्रदेश).
3. **"आप क्या करते हैं?"** — optional multi-select chips: दूध बेचता हूँ / पशु पालता हूँ / खेती करता हूँ → orders the dashboard cards (personalization). Skippable.
Also ask milk-module mode (किसान/दूधवाला) the first time the Milk tab opens, not in onboarding.

## NAVIGATION
Bottom navigation, 4 tabs: 🥛 दूध | 🐄 पशु | 🌾 खाद-बीज | ⚙️ और (settings/backup/language/state/reports shortcuts).

---

## MODULE 1 — दूध (Milk record; build this first, it is the core)

### Modes
- **किसान mode** — user sells milk to ONE dairy: single ledger.
- **दूधवाला mode** — user delivers to MANY customers: customer list + per-customer ledger. Mode switchable in settings (with warning).

### Data models (sqflite)
```
customers(id, name, phone?, defaultQtyL REAL, rateType TEXT('flat'|'fat'), flatRate REAL, active INT)
milk_entries(id, customerId?/null=kisan-mode, date TEXT, shift TEXT('M'|'E'), qtyL REAL, fatPct REAL?, amount REAL)
payments(id, customerId?, date, amount REAL, note TEXT)
settings(key, value)  -- kisan-mode rate config here
```
`amount` computed at entry time and stored (rate changes must not rewrite history).

### Rate logic (unit-test)
- Flat: amount = qtyL × flatRate.
- Fat-based: amount = qtyL × fatPct × ratePerFatPoint (e.g. 6.5 fat × ₹6.8 = ₹44.20/L). Formula shown on rate-settings screen so the user can match their dairy.
- Due (doodhwala): customerDue = Σamount − Σpayments; red = due, green = advance.

### Screens
1. **Milk home** — big "आज की entry" button; running month total card (लीटर + ₹); recent entries; doodhwala mode: customer strip with due badges.
2. **Entry** — date (default today), M/E toggle, customer picker (doodhwala), big numeric litre pad (0.5 steps), optional fat, live amount preview, save in ≤10 seconds. Long-press entry to edit/delete; same-day same-shift duplicate → ask "बदलें या जोड़ें?".
3. **Customer detail** — month entries calendar-style, payments, "पैसा मिला" button, monthly bill share.
4. **Monthly report** — month picker; kisan: total L/avg fat/total ₹; doodhwala: per-customer table. WhatsApp share as Hindi text bill:
```
🥛 दूध का हिसाब — [माह 2026]
ग्राहक: [नाम]
कुल दूध: 45.5 ली | रेट: ₹60/ली
कुल: ₹2,730 | मिला: ₹2,000 | बाकी: ₹730
— किसान साथी app
```

---

## MODULE 2 — पशु (Cattle reminders)

### Domain constants (implement exactly)
- Gestation: cow = **283 days**, buffalo = **310 days** from AI/service date.
- Heat cycle = 21 days; pregnancy-check reminder = +75 days (editable 60-90).
- Dry-off = expected delivery − 60 days. Post-calving heat watch = +45 days.
- Vaccination defaults (editable): FMD every 6 months; HS yearly (May); BQ yearly (May); deworming every 3 months (calf) / 6 months (adult).
- Feed rule (आहार): concentrate kg/day = milkL/2.5 + 1.5; +1 kg in last 2 months of pregnancy. Green fodder 15-25 kg, dry 4-6 kg as guidance text. Disclaimer everywhere: "सलाह के लिए पशु चिकित्सक से मिलें।"

### Data models
```
animals(id, tagOrName, type TEXT('cow'|'buffalo'), status TEXT('milking'|'dry'|'pregnant'|'heifer'), aiDate?, calvingDate?, milkLpd REAL?, photoPath?, active INT)
animal_events(id, animalId, type TEXT('ai','heat','preg_check','dry_off','delivery','vaccine_fmd','vaccine_hs','vaccine_bq','deworm','custom'), dueDate, doneDate?, note)
```
Setting AI date auto-creates the event chain (heat +21d, preg check +75d, dry-off, delivery) each with a notification 1 day before. Recording delivery closes the old chain and resets the cycle. Past AI date → only future events. Unit-test all date math incl. month boundaries.

### Screens
1. **Pashu home** — animal cards (photo, status badge, "ब्याने में 45 दिन" chip); summary strip (कुल/गाभिन/दूध में); FAB add.
2. **Animal detail** — event timeline (done/upcoming); buttons: "AI कराया" (date → regenerate chain), "ब्याई" (record delivery), "हीट में आई"; edit.
3. **Quick calculators** (no animal needed): गाभिन calculator (date → full milestone table, shareable) + आहार calculator.
4. **Reminders list** — all upcoming events across animals, mark-done.

---

## MODULE 3 — खाद-बीज (Fertilizer & seed)

### Land units
Reuse my provided `land_units.dart` (state-wise bigha in sq ft) if given; else JSON asset: UP 27000, Bihar 27220, Rajasthan 27225, MP 12000, WB 14400, HP 8712; katha = bigha/20 (state divisor). All doses internal per hectare, converted to user's unit. State picked in onboarding/settings.

### Crop data (assets/crops.json — generate fully; header: "general ICAR-style recommendations — verify locally")
Schema: `{"id":"wheat","name_hi":"गेहूं","npk_kg_ha":[120,60,40],"seed_kg_ha":100,"splits_hi":"N: आधा बुवाई पर, चौथाई पहली सिंचाई, चौथाई दूसरी। P+K: पूरा बुवाई पर।","season":"रबी"}`
15 crops: गेहूं 120:60:40/100; धान 120:60:60/20(रोपाई); मक्का 120:60:40/20; सरसों 80:40:40/5; आलू 180:80:100/2500(कंद); चना 20:60:20/80; मसूर 20:40:20/45; अरहर 25:50:25/15; गन्ना 150:60:60; बाजरा 80:40:40/4; ज्वार 80:40:40/8; मूंगफली 20:60:40/100; सोयाबीन 30:60:40/75; प्याज 100:50:50/8; टमाटर 120:60:60/0.4.

### Fertilizer math (exact; unit-test: wheat 1 ha → DAP 130.4 kg, urea ≈ 209.7 kg, MOP 66.7 kg)
1. DAP kg = P₂O₅_req / 0.46
2. N_from_DAP = DAP × 0.18
3. Urea kg = (N_req − N_from_DAP) / 0.46 (floor 0 — never negative)
4. MOP kg = K₂O_req / 0.60
5. Scale by area_ha; round 0.5 kg; also show बोरी (urea 45 kg, DAP 50, MOP 50) + cost from editable rates (defaults: urea ₹266/बोरी, DAP ₹1350, MOP ₹1700).
Alt mode "सीधे NPK से": user enters soil-test targets.

### Seed & spray
- Seed kg = seed_kg_ha × area_ha.
- Spray: dose (ml/g per litre OR per-15L tank) + area; spray volume default 500 L/ha (editable) → total water, total chemical, tank count (15L default).

### Screens
Khaad home (4 cards: खाद / बीज / छिड़काव / NPK से) → crop grid → area input (value + unit dropdown) → result card (table + splits + share). Disclaimer footer on every result.

---

## THEME (unique)
Seed fresh green (#2E7D32) with warm cream surfaces; each module gets an accent (milk = teal, pashu = brown, khaad = amber) used in its tab/screens. Icon: farmer silhouette + milk can + wheat spike in a green rounded square. Large fonts (min 16sp body).

## BUILD ORDER
1. DB module + migrations (documented, reusable) + app shell (bottom nav, strings, theme, onboarding)
2. Milk module end-to-end (entry → report → share) + rate unit tests
3. Pashu module (event engine + notifications) + date unit tests
4. Khaad module (land units + crops.json + math tests) + seed/spray
5. Backup/restore + monthly reminder
6. Ads (test IDs) + review prompt + polish + README

## ACCEPTANCE CHECKLIST
- [ ] Milk: 10-second entry; fat & flat rates correct (tests); backup→wipe→restore identical
- [ ] Pashu: cow AI 01-01 → delivery 10-10 (283d) and buffalo +310d (tests); notifications fire; delivery resets cycle
- [ ] Khaad: wheat/1 bigha (UP) matches hand calculation (test); urea never negative; disclaimer visible
- [ ] All 3 modules fully offline in airplane mode; no ad on open/exit; flutter analyze clean; release AAB builds
