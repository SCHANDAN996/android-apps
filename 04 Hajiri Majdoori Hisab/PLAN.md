# 04 — Hajiri + Majdoori Hisab (Priority: MEDIUM-HIGH)

## Ek line mein
Thekedar ka labour attendance (hajiri) aur majdoori ka hisab — kaun kitne din aaya, kitna paisa banta hai, kitna advance diya — offline.

## Target User
- Chhote thekedar (construction, khet, factory, loading)
- Mistri jo 2-5 labour rakhta hai
- Chhote dukandaar/karkhana malik

## Problem
Thekedar copy mein hajiri lagata hai. Hafte ke end mein hisab jodna, advance (peshgi) minus karna — galti aur jhagda common hai. Khatabook jaise apps udhar ke liye hain, hajiri ke liye nahi. Jo hajiri apps hain wo online + English + login mangte hain.

## MVP Features (v1)
1. **Labour list** — naam, photo (optional), roz ka rate ya monthly
2. **Ek tap hajiri** — Present / Absent / Half day / Overtime
3. **Advance entry** — kisi ko 500 advance diya, minus hota rahe
4. **Hafta/Mahina hisab** — auto calculation: din × rate − advance = dena hai
5. **WhatsApp par hisab bhejo** — labour ko uska hisab text mein
6. **Purana record** — pichhle mahine ka bhi dekh sako
7. Koi login nahi, poora offline, local backup file

## Baad ke Features (v2+)
- Multiple sites/projects (site-wise labour group)
- Overtime rate alag
- PDF salary sheet

## Screens
1. Home — aaj ki hajiri screen (labour list, har naam ke aage P/A/H bade buttons)
2. Labour detail — uska rate, advance history, is mahine ka hisab
3. Hisab/report screen — hafta ya mahina select karo
4. Settings — backup, rate defaults

## Engine Reuse
- Dudh ka Hisab (03) wala database layer — 80% reuse (isliye ye 03 ke BAAD banao)
- Kisan Calculator ka UI framework

## Monetization
- Interstitial hisab report par (finance context = achha eCPM)
- ₹199 lifetime unlock (unlimited labour; free mein 5 labour tak)
- Freemium yahan kaam karega kyunki thekedar ka roz ka business tool hai

## ASO / Keywords
- hajiri app, labour hajiri, majdoori hisab, attendance register hindi, thekedar app, labour khata
- Naam suggestion: "Hajiri - Labour Majdoori Hisab"

## Competition
- Kuch hajiri apps hain (attendance register) lekin zyada-tar online/ads se bhare/English. Offline + Hindi + advance-tracking combo weak hai

## Kitna Time Lagega
2 hafte (03 ka database layer milne ke baad)

## Success Metric (3 mahine)
- 10,000+ installs
- Paid conversion 1%+ (ye app paid unlock ke liye best candidate hai)
