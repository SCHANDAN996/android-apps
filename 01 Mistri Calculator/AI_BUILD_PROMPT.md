# AI BUILD PROMPT — Mistri Calculator (मिस्त्री कैलकुलेटर)

> **उपयोग (मेरे लिए):** इस फ़ाइल का पूरा English हिस्सा किसी भी AI को दो और कहो: "Build this complete Flutter app exactly per this spec." साथ में PLAN.md भी दो। App बनने के बाद root folder की `0.1 PLAY STORE ASSETS PROMPT` फ़ाइल use करो।

---

## ROLE
You are a senior Flutter developer. Build a complete, production-ready Android app from this spec. Do not skip sections. Ask at most 3 questions; otherwise proceed with stated defaults.

## PRODUCT
**Mistri Calculator** — a Hindi-first, 100% offline construction material calculator for Indian masons (mistri), small contractors, and home builders. It calculates bricks, cement, sand, aggregate, steel (saria), plaster, tiles, and paint quantities with local cost estimates. Reference existing sibling app style: simple large-button Hindi UI like a village-friendly tool.

## STANDARD PROJECT RULES
- Flutter latest stable, Android-only. minSdk 23. Material 3. App size < 20 MB.
- 100% offline. No login, no server, no internet permission needed except for ads.
- State: Provider or Riverpod (simple). Persistence: shared_preferences (rates, language); no DB needed.
- All UI strings in one strings file with Hindi (default) + English; structure ready for more languages.
- Numbers displayed in Indian format (1,00,000). Units: feet default, meter toggle.
- AdMob via google_mobile_ads. TEST ad unit IDs in code; real IDs via a single config file. Banner on result screens; interstitial ONLY after every 3rd completed calculation (counter in prefs), never on app open/exit.
- in_app_review prompt after 3rd successful calculation (once).
- Settings screen: language, units, my rates, share app, privacy policy link placeholder, "more apps" link placeholder.
- Never crash on empty/zero input — show friendly Hindi validation.
- Deliverables: full runnable project + README (build steps, where to put real AdMob IDs, keystore steps).

## SCREENS
1. **Home** — grid of 7 large cards with icons (Hindi labels): ईंट (Bricks), कंक्रीट/ढलाई (Concrete), सरिया (Steel), प्लास्टर (Plaster), टाइल्स (Tiles), पेंट (Paint), मेरा रेट (My Rates). AppBar: app name + settings icon.
2. **Each calculator screen** — inputs at top (large fields, unit dropdown ft/m), बड़ा "हिसाब करें" button, result card below (quantities + cost if rates set), Share and Copy buttons (share_plus). Result text is a formatted Hindi summary suitable for WhatsApp.
3. **My Rates screen** — editable local prices: ईंट ₹/1000, cement ₹/bag, sand ₹/CFT, aggregate ₹/CFT, saria ₹/kg, tile ₹/box, paint ₹/L. Saved in prefs. Used to show total cost on every result.
4. **Settings** — as in standard rules.

## CORE FORMULAS (implement exactly; all volumes internal in m³, display both units)
Constants: 1 cement bag = 50 kg = 0.0347 m³. Dry-volume factor concrete 1.54, mortar 1.33. Wastage: bricks 5%, tiles 10%, steel 3%.

**1. Brick wall (ईंट):** Inputs: length, height (ft or m), thickness choice 4.5"/9" (0.115/0.23 m), mortar ratio 1:4/1:6.
- volume = L×H×t (m³); bricks = volume × 500 × 1.05 (round up)
- mortar wet = volume × 0.25; dry = wet × 1.33
- 1:6 → cement m³ = dry/7 → bags = /0.0347; sand m³ = dry×6/7 (also show CFT: ×35.31)
- (1:4 → divide by 5, sand ×4/5)

**2. Concrete (ढलाई):** Inputs: L×W×thickness (slab) OR count×L×W×D (column/beam), grade M15 (1:2:4), M20 (1:1.5:3), M25 (1:1:2).
- dry = volume × 1.54; sum = ratio parts total
- cement bags/m³: M15 = 6.3, M20 = 8.1, M25 = 11.1 (compute from formula, don't hardcode: dry×(c/sum)/0.0347)
- sand m³ = dry×(s/sum); aggregate m³ = dry×(a/sum); show CFT too

**3. Steel/Saria (सरिया):** Inputs: diameter (8/10/12/16/20 mm), total length (m or count of 12m rods) OR slab quick-mode (slab volume × 80 kg/m³ residential thumb).
- weight kg/m = d²/162; total = length × kg/m × 1.03

**4. Plaster (प्लास्टर):** Inputs: area, thickness 12mm (inner)/15mm (outer), ratio 1:4/1:6.
- wet = area×t; dry = ×1.33; cement/sand split by ratio as in bricks

**5. Tiles (टाइल्स):** Inputs: floor L×W, tile size dropdown (1×1 ft, 2×2 ft, 600×600mm, 300×600mm, custom), tiles per box (editable, default 4 for 2×2).
- tiles = ceil(area/tileArea × 1.10); boxes = ceil(tiles/perBox)

**6. Paint (पेंट):** Inputs: wall area (or room L×W×H auto: 2(L+W)×H minus 10% openings), coats (default 2).
- litres = area_m² × coats / 10; show 1L/4L/10L/20L bucket combination suggestion

Every result shows: quantities + "अनुमानित ख़र्च" (from My Rates; hide cost line if rate not set) + disclaimer line "यह अनुमान है, ख़रीद से पहले मिस्त्री/इंजीनियर से सलाह लें।"

## THEME (must be unique vs my other apps)
Seed color deep orange (#E65100) with warm grey surfaces; icon concept: brick trowel + calculator inside orange rounded square. Font: default Material with large sizes (min 16sp body — users are 35-55 age).

## BUILD ORDER
1. Project skeleton + theme + strings file + home grid
2. Brick calculator end-to-end (input→result→share) — establish the reusable CalculatorScaffold widget
3. Remaining 5 calculators using the same scaffold
4. My Rates + cost lines
5. Settings + language toggle
6. Ads (test IDs) + review prompt
7. Polish: validation, Indian number format, empty states
8. README + release checklist

## ACCEPTANCE CHECKLIST
- [ ] All 6 calculators produce correct sample outputs: e.g., 10ft×10ft 9" wall 1:6 → ~2.13 m³? NO — verify: 10×10 ft = 9.29 m² × 0.23 = 2.14 m³ → ~1123 bricks, ~2 bags cement (mortar dry 0.71 m³ → 0.101 m³ cement ≈ 2.9 bags — AI must verify math against formulas above)
- [ ] Zero/empty input never crashes
- [ ] Hindi + English complete, language persists
- [ ] Interstitial only after 3rd calculation; test IDs in debug
- [ ] flutter analyze clean; release AAB builds
