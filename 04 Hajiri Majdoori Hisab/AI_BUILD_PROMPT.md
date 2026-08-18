# AI BUILD PROMPT — Hajiri Majdoori Hisab (हाजिरी + मजदूरी)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md। अगर "Dudh ka Hisab" app बन चुका है तो उसका `lib/db/` module भी दो — same DB pattern reuse होगा। बाद में root की `0.1 PLAY STORE ASSETS PROMPT` file।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec.

## PRODUCT
**Hajiri** — Hindi-first, 100% offline labour attendance + wage book for small Indian contractors (thekedar) and masons who manage 2-30 workers. One-tap daily attendance, advance (पेशगी) tracking, weekly/monthly auto-calculated settlement, WhatsApp share.

## STANDARD PROJECT RULES
- Flutter stable, Android-only, minSdk 23, Material 3, < 20 MB, 100% offline, no login.
- DB: sqflite in clean `lib/db/` module (reuse pattern from my Dudh ka Hisab app if provided).
- Hindi default + English strings file. Indian number format, DD-MM-YYYY.
- Local JSON backup/restore via share/file-picker.
- AdMob TEST IDs (real via config): banner on report screen; interstitial ONLY on opening weekly/monthly settlement, max 1/session.
- Freemium: FREE = up to 5 workers; unlimited via one-time IAP ₹199 (`in_app_purchase` package, product id `unlimited_workers`). Show gentle paywall when adding 6th worker.
- in_app_review after 10th attendance day saved.

## DATA MODELS
```
workers(id, name, phone?, photoPath?, wageType TEXT('daily'|'monthly'), dailyRate REAL, monthlyRate REAL, otHourRate REAL, active INT, siteId?)
attendance(id, workerId, date TEXT, status TEXT('P'|'A'|'H'|'PO'), otHours REAL DEFAULT 0)  -- P=हाजिर, A=गैरहाजिर, H=आधा दिन, PO=हाजिर+OT
advances(id, workerId, date, amount REAL, note)
settlements(id, workerId, fromDate, toDate, totalDays REAL, otAmount REAL, gross REAL, advanceDeducted REAL, paid REAL, date)
sites(id, name) -- v1: single default site; schema ready for multi-site v2
```

## WAGE MATH
- days = P(1.0) + H(0.5) per period; gross = days × dailyRate + Σ(otHours × otHourRate)
- Monthly-type worker: gross = monthlyRate × (days present / working days in period) — show formula on screen.
- payable = gross − Σ(unadjusted advances in period). Settlement records what was actually paid; remainder carries forward (show as "पिछला बाकी").

## SCREENS
1. **Aaj ki Hajiri (home)** — today's date header with day-strip navigation; worker list where each row has 4 toggle chips: हाजिर / गैर / आधा / OT (OT opens hours input). Bulk button "सबको हाजिर". Bottom summary: आज हाजिर X/Y.
2. **Worker detail** — rate info, this-period days counter, advances list + "पेशगी दो" button, attendance calendar (month grid, colored dots), running hisab card.
3. **Hisab (settlement)** — pick worker + period (इस हफ़्ते / इस महीने / custom); shows days, OT, gross, advances, बाकी; "हिसाब चुकता करो" records settlement; "WhatsApp भेजो" shares formatted Hindi summary (worker name, days, rate, advance, net).
4. **Workers list** — add/edit/deactivate (never hard-delete history), photo optional (image_picker, store path).
5. **Settings** — backup, language, IAP restore, privacy/more-apps placeholders.

## THEME (unique)
Seed brown (#5D4037) with amber accents; icon: register/notebook with a tick mark. Chunky touch targets (outdoor use, dusty hands).

## EDGE CASES
- Changing a past attendance recalculates any UNSETTLED period only; settled periods locked (show lock icon, long-press to unlock with warning).
- Rate change applies from a chosen date, not retroactively (store rate on each settlement).
- 6th worker with no IAP → paywall sheet, never data loss.

## BUILD ORDER
1. DB module + workers CRUD
2. Attendance screen (the core UX — make it 1-tap fast)
3. Advances + hisab math + settlement flow (unit-test the math)
4. WhatsApp share + calendar view
5. IAP + ads + backup + polish + README

## ACCEPTANCE CHECKLIST
- [ ] Marking 10 workers' attendance takes < 15 seconds
- [ ] Settlement math correct across P/A/H/OT + advances (unit tests)
- [ ] Settled periods immutable by default; IAP unlock persists after reinstall (restore purchases)
- [ ] Backup→restore identical; airplane-mode OK; analyze clean; AAB builds
