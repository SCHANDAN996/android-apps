# Launch Checklist — मिस्त्री कैलकुलेटर (v1.0)

Ordered from a signed build to full rollout. Tick top-to-bottom.

---

## PHASE 0 — Before you touch Play Console (in the app)
- [ ] Replace **AdMob TEST IDs with real IDs**: App ID in `AndroidManifest.xml` + banner/interstitial units in `lib/core/services/ad_service.dart`.
- [ ] Add your real **Privacy Policy URL** in Settings and wire the button (needs `url_launcher`).
- [ ] Set a **branded app icon** (512×512 per graphics_specs.md) via `flutter_launcher_icons`.
- [ ] Create a proper **release keystore** (do NOT ship on the debug key — current `build.gradle.kts` uses `signingConfigs.debug`). Store keystore + passwords safely.
- [ ] Bump `version: 1.0.0+1` if needed; confirm `applicationId = com.mistricalculator.mistri_calculator`.
- [ ] `flutter analyze` clean ✅ (already passing) and `flutter test` runs.
- [ ] Build signed release: `flutter build appbundle --release` → get `app-release.aab`.
- [ ] Install the AAB (via bundletool or internal testing) on a **real low-end Android phone** and sanity-check all 6 calculators + share + language toggle + ads load.

## PHASE 1 — Create the app in Play Console
- [ ] Create app → Default language **Hindi (हिन्दी)** → App name `Mistri Calculator: Ghar Hisab` → App (not game) → Free.
- [ ] Accept Developer Program Policies & US export laws declaration.
- [ ] **Register the package name for Android Developer Verification** (2026 requirement): Play Console → Home → Android developer verification → Register `com.mistricalculator.mistri_calculator`. Distribution outside Play = No. **Apps not registered by Sept 2026 will stop installing on certified Android devices — do NOT skip this.**

## PHASE 2 — Store listing (use store_listing.md)
- [ ] Main store listing (Hindi): title, short desc, full desc.
- [ ] Add **English (India)** listing locale with the English versions.
- [ ] Upload **App icon (512×512)** + **Feature graphic (1024×500)** (graphics_specs.md).
- [ ] Upload **8 phone screenshots** with captions (screenshots_plan.md).
- [ ] Category = **Tools**; add tags; contact email = `[MY_EMAIL - all.chandansingh@gmail.com]`.

## PHASE 3 — Policy & compliance declarations
- [ ] **Privacy Policy** URL added (hosted privacy_policy.html).
- [ ] **Data safety** form completed (data_safety_answers.md) — declare Advertising ID; do NOT mark "no data collected".
- [ ] **Content rating** questionnaire submitted (content_rating_answers.md) → expect Everyone.
- [ ] **Ads** declaration = "Yes, contains ads".
- [ ] **Target audience & content** = adults (13+); NOT designed for families.
- [ ] **Government apps / COVID / news / financial features** = No.
- [ ] **Data deletion** note filled (no personal data; ad ID resettable on device).

## PHASE 4 — Release setup
- [ ] Pricing = **Free** (no IAP in v1.0).
- [ ] **Countries/regions:** launch in **India only** first (Hindi audience, best AdMob eCPM, easy support). Add **Nepal** in a later update if reviews are healthy. (Don't go global at launch — support + relevance would suffer.)
- [ ] App signing by Google Play = **enabled** (recommended).

## PHASE 5 — Internal testing pass (do NOT skip)
- [ ] Upload AAB to **Internal testing** track; add 2–5 testers (your own accounts/friends).
- [ ] Verify on 2+ real devices: no crash on empty/zero input, ads show, results correct, Hindi↔English persists, share works.
- [ ] Fix any blocker → re-upload. Only proceed when a full run is clean.

## PHASE 6 — Production submission
- [ ] Promote the tested build to **Production**.
- [ ] Add **release notes** (release_notes.txt) for both locales.
- [ ] **Staged rollout: start at 20%** (not 100%) so you can halt if crashes spike.
- [ ] Submit for review. (First review can take a few days — be patient, don't resubmit repeatedly.)

## PHASE 7 — First-week monitoring plan
- [ ] **Day 1–2:** Play Console → Quality → **Android vitals**; keep **crash-free rate > 99%**. If crash rate climbs, **halt rollout** and patch.
- [ ] **Daily:** read every review; reply politely in Hindi; note repeated complaints (missing feature, wrong number) for v1.1.
- [ ] **ANR rate** < 0.47% and crash rate < 1.09% (Play "bad behaviour" thresholds) — stay well under.
- [ ] Watch **AdMob** dashboard: ads actually filling & earning (confirms real IDs work).
- [ ] If Day 2–3 vitals are healthy → **increase rollout 20% → 50% → 100%**.
- [ ] Track **installs, uninstalls, Day-1 retention**; target 4.3★+ and fix the top complaint fast in v1.1.

## PHASE 8 — Post-launch (week 2+)
- [ ] Fold real Play "search terms" back into the description (ASO).
- [ ] Plan v1.1 from review feedback; consider the ₹99 ad-free IAP (re-do content rating Q10).
- [ ] Backup keystore + Play credentials in a safe place.
