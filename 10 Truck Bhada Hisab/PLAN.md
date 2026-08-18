# 10 — Truck/Tempo Bhada Hisab (Priority: LOW-MEDIUM)

## Ek line mein
Truck/tempo/pickup driver-malik ka trip hisab — bhada, diesel, kharcha, kitna bacha — offline.

## Target User
- Chhote truck/tempo/pickup malik (1-3 gadi wale)
- Driver jo malik ko hisab dete hain
- Tractor-trolley bhada wale (gaon mein)

## Problem
Trip ka hisab diary mein likha jata hai — bhada kitna mila, diesel kitne ka bhara, toll/khana/repair kharcha, driver ki tankhwa. Mahine ke end par pata nahi asli bachat kitni hui. Fleet apps bade transporters ke liye hain (online, English, mehngi) — 1-2 gadi wale ke liye kuch nahi.

## MVP Features (v1)
1. **Gadi list** — apni gadiyan (number, type)
2. **Trip entry** — kahan se kahan, bhada, advance mila, baki kitna
3. **Kharcha entry** — diesel (litre + rate), toll, khana, repair, police — categories ke saath
4. **Trip ka result** — bhada − kharcha = bachat, turant dikhao
5. **Mahine ka hisab** — gadi-wise: total bhada, total kharcha, total bachat, diesel average
6. **Party khata** — kis party se kitna bhada baki hai (udhar tracking)
7. **WhatsApp share** — trip bill party ko bhejo

## Baad ke Features (v2+)
- Driver hisab (tankhwa + trip bhatta)
- Kist/EMI reminder (gadi ki kist — Kisan Calculator ka EMI engine reuse)
- Mileage tracking

## Screens
1. Home — is mahine ka summary + naya trip button
2. Trip entry screen
3. Kharcha entry (trip ke andar)
4. Reports (gadi-wise, mahina-wise)
5. Party khata screen

## Engine Reuse
- 03/04 wala database layer + Kisan Calculator ka EMI logic
- Ye app 04 (Hajiri) ke structure se milta-julta hai — uske baad banana easy

## Monetization
- Interstitial report par (transport/finance context = theek eCPM)
- ₹199 lifetime (2nd gadi add karne par) — malik log paying audience hai

## ASO / Keywords
- truck hisab, bhada hisab, transport hisab app, gadi ka hisab, trip book hindi, tempo bhada
- Naam suggestion: "Bhada Hisab - Truck Tempo Trip Book"

## Competition
- Fleet management apps hain lekin sab enterprise/online. 1-gadi wale malik ke liye simple offline Hindi app = gap. Niche chhota hai isliye priority low, lekin loyal audience

## Kitna Time Lagega
2-3 hafte

## Success Metric (3 mahine)
- 4,000+ installs
- Paid conversion 1.5%+ (malik audience)
