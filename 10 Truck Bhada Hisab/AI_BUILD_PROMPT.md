# AI BUILD PROMPT — Truck Bhada Hisab (भाड़ा हिसाब)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md + Dudh/Hajiri का `lib/db/` module (मिले तो)। बाद में `0.1 PLAY STORE ASSETS PROMPT`।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec.

## PRODUCT
**Bhada Hisab** — Hindi-first, offline trip account book for small Indian truck/tempo/pickup/tractor-trolley owners (1-3 vehicles). Per-trip: fare (भाड़ा), diesel, expenses, profit; monthly per-vehicle reports; party (customer) dues tracking.

## STANDARD PROJECT RULES
- Flutter stable, Android-only, minSdk 23, Material 3, < 20 MB, offline, no login.
- DB: sqflite clean module (reuse pattern if provided). Hindi default + English strings. JSON backup/restore.
- AdMob TEST IDs: banner home; interstitial only on opening monthly report, 1/session.
- Freemium: 1 vehicle free; 2+ vehicles IAP ₹199 lifetime.
- in_app_review after 5th trip saved. Settings standard.

## DATA MODELS
```
vehicles(id, name, number TEXT, type TEXT('truck'|'tempo'|'pickup'|'tractor'|'other'), active INT)
parties(id, name, phone?)
trips(id, vehicleId, partyId?, date, fromPlace, toPlace, fare REAL, advanceReceived REAL, status TEXT('open'|'settled'))
expenses(id, tripId?/null=general, vehicleId, date, category TEXT('diesel'|'toll'|'food'|'repair'|'police'|'driver'|'other'), amount REAL, litres REAL?, note)
partyPayments(id, partyId, date, amount REAL, note)
```

## MATH
- Trip profit = fare − Σtrip expenses. Month vehicle report: total fare, expenses by category, general (non-trip) expenses, net profit, diesel litres + avg ₹/litre.
- Party due = Σ(fares of that party's trips) − Σ(advances) − Σ(partyPayments). Red/green badges.

## SCREENS
1. **Home** — month summary card (भाड़ा / ख़र्च / बचत) per selected vehicle (vehicle switcher chip), "नया ट्रिप" FAB, recent trips list (place→place, fare, profit chip).
2. **Trip entry** — vehicle, date, from/to (text, recent suggestions), party (optional, quick-add), fare, advance. Save → trip detail where expenses are added fast (category chips + amount; diesel asks litres too).
3. **Trip detail** — expense list, profit line, "बिल भेजें" WhatsApp text (party, route, date, fare, advance, बाकी), settle button.
4. **Party khata** — list with dues; detail: trips + payments + "पैसा मिला" entry; share statement text.
5. **Reports** — month picker, vehicle-wise cards, category-wise expense breakdown, share summary text.
6. **Settings** — vehicles manager, IAP, backup, language.

## THEME (unique)
Seed steel-blue (#1565C0) with road-grey; icon: truck silhouette + rupee coin. Chunky UI.

## EDGE CASES
- Trip without party (cash trip) fully supported.
- General expenses (insurance, EMI, repair not tied to trip) counted in month report.
- Deleting a trip asks about its expenses; party dues recompute.

## BUILD ORDER
1. DB + vehicles + trip entry/detail
2. Expenses + profit math (unit tests)
3. Party khata + payments + share texts
4. Reports + IAP + ads + backup + polish + README

## ACCEPTANCE CHECKLIST
- [ ] Trip: fare 12000, advance 5000, expenses 7200 → profit 4800, party due 7000 (unit test)
- [ ] Vehicle switcher isolates data correctly
- [ ] Backup→restore identical; airplane OK; analyze clean; AAB builds
