# MASS APP — Master Plan

11 app ideas, priority order mein. Har folder mein detailed PLAN.md hai.

## Priority List

| # | App | Engine | Time | Kyun is number par |
|---|-----|--------|------|---------------------|
| 01 | Mistri Calculator | Kisan Calc | 2-3 hafte | Best combo: demand high + finance eCPM + 70% code ready |
| 02 | Interview English | SpeakEasy | 2 hafte | Keyword volume sabse high, engine 90% ready |
| 03 | Dudh ka Hisab | Naya DB layer | 3 hafte | Daily-use = roz ads; DB layer aage ke apps mein lagega |
| 04 | Hajiri Majdoori Hisab | 03 ka DB | 2 hafte | Paid unlock ka best candidate, 03 ke baad easy |
| 05 | Pashu Calculator | Kisan Calc + DB | 2 hafte | Sabse khali niche (zero competition) |
| 06 | Khaad-Beej Calculator | Kisan Calc | 2 hafte | Land-unit converter ki superpower, seasonal demand |
| 07 | English for Drivers Delivery | SpeakEasy | 1.5 hafte | Zero competition, 02 ke baad template ready |
| 08 | English for Shopkeepers | SpeakEasy | 1 hafta | 07 ke turant baad, same pattern |
| 09 | Bachat Gat SHG Hisab | Sood + DB | 3-4 hafte | Bada gap lekin sabse complex data model |
| 10 | Truck Bhada Hisab | EMI + DB | 2-3 hafte | Loyal paying audience, lekin niche chhota |
| 11 | Silai Master | DB | 2-3 hafte | Sabse zyada existing competition, isliye last |

## Banane ka Sahi Order (dependencies ke hisab se)

```
Track 1 (Calculator): 01 → 06 → 05
Track 2 (Voice):      02 → 07 → 08
Track 3 (Hisab/DB):   03 → 04 → 10 → 09 → 11
```

- 03 pehle banao Track 3 mein — uska database layer 04, 09, 10, 11 sab mein reuse hoga
- 02 pehle banao Track 2 mein — uska content-pack template 07, 08 ko 1-hafte ka kaam bana dega

## Golden Rules (research se)

1. **Har app par 2-4 hafte se zyada mat lagao** — portfolio mein 1 hi app winner banta hai, jaldi ship karo, jo uthe usi par dam lagao
2. **India banner eCPM kam hai ($0.30-0.80)** — interstitial + rewarded use karo, finance-context apps (01, 04, 09, 10) ka eCPM 3-5x hota hai
3. **Har app: Hindi-first, 100% offline, size <20MB, koi login nahi** — yahi Bharat market ka winning formula hai
4. **Cross-promotion** — har app mein apne dusre apps ka "Hamare aur apps" section rakho
5. **ASO** — general keywords ("calculator", "english") par mat lado; specific Hindi keywords ("mistri calculator", "dudh ka hisab") par rank karo
6. **Ek hi developer account** par sab apps — Play Store ka trust build hota hai
