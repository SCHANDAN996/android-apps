# 01 — Mistri Calculator (Priority: SABSE HIGH)

## Ek line mein
Ghar banane ka poora material hisab — eent, cement, saria, balu, gitti, plaster — Hindi mein, bilkul offline.

## Target User
- Mistri (raj mistri), thekedar, chhote contractor
- Ghar banwane wale aam log jo material ka estimate chahte hain
- Tier 2/3 sheher + gaon, Hindi-speaking

## Problem
Mistri aaj bhi kagaz par ya andaze se material ka hisab lagata hai. English apps (construction calculator) complex hain, online-first hain, aur Hindi mein achha simple offline app nahi hai. Galat estimate = paisa barbad.

## MVP Features (v1)
1. **Eent Calculator** — deewar ki lambai × unchai × motai (4"/9") → kitni eent lagegi + cement/balu masala
2. **Cement-Balu-Gitti (Concrete) Calculator** — slab/column/beam ka volume → cement bags, balu, gitti (M15/M20/M25 ratio select)
3. **Saria (TMT) Calculator** — diameter + length → weight (kg) aur andazan cost
4. **Plaster Calculator** — area + motai → cement, balu
5. **Tiles/Flooring Calculator** — room size → kitne tiles/marble box
6. **Paint Calculator** — deewar area → kitna litre paint
7. Har result ka **screenshot/share button** (WhatsApp par bhejne ke liye)
8. **Rate save** — user apne local rate dale (eent ₹/1000, cement ₹/bag) to total cost bhi dikhe

## Baad ke Features (v2+)
- Chhat (roof slab) ka poora package estimate
- Boundary wall estimate
- PDF estimate banake dena (thekedar client ko de sake)
- Bhojpuri/Marathi/Bengali language add

## Screens
1. Home — 6-8 bade icon-cards (Eent, Cement, Saria, Plaster, Tiles, Paint)
2. Har calculator ka input screen (bade input box, Hindi labels, unit dropdown: feet/meter)
3. Result screen — bada clear number + cost + share button
4. Settings — apne rates, language

## Engine Reuse
Kisan Calculator ka base project copy karo:
- Calculator input/result UI framework — 70% reuse
- Unit conversion logic pattern — reuse
- Sirf formulas aur labels naye hain

## Monetization
- Interstitial ad har 3rd calculation ke baad (finance/construction eCPM achha)
- Banner result screen par
- Baad mein: ₹99 lifetime ad-free IAP

## ASO / Keywords
- Hindi: mistri calculator, eent ka hisab, cement calculator hindi, ghar banane ka kharcha, saria weight calculator, building material calculator
- App ka naam suggestion: "Mistri Calculator - Ghar ka Hisab"
- Size 15MB se kam rakho, "100% Offline" description mein bold

## Competition
- English construction calculators bahut hain lekin Hindi + offline + simple combo weak hai
- "Construction Calculator" type apps ke reviews padho — users Hindi aur simplicity mangte hain

## Kitna Time Lagega
2-3 hafte (Kisan Calculator base ke saath)

## Success Metric (3 mahine)
- 10,000+ installs organic
- Day-30 retention 15%+
- Ratings 4.3+
