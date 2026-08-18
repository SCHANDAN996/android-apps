# 09 — Bachat Gat / SHG Hisab (Priority: MEDIUM-LOW)

## Ek line mein
Mahila bachat gat (Self Help Group) ka poora hisab — kaun kitna jama kiya, kisne loan liya, byaj kitna bana — offline register.

## Target User
- SHG group leader/secretary (mahila, 25-50 saal, gaon/kasba)
- Anganwadi/NRLM didi jo groups chalati hain
- India mein 80 lakh+ SHG groups hain (bahut bada niche)

## Problem
Bachat gat ka hisab register copy mein hota hai — monthly meeting mein jama, loan, byaj ka jod-ghata haath se. Galti hui to group mein anban. NRLM ke sarkari apps complex hain aur login/network mangte hain. Simple offline Hindi app nahi hai.

## MVP Features (v1)
1. **Group setup** — members ki list (10-20 naam), monthly bachat amount
2. **Meeting entry** — is mahine kisne kitna jama kiya (ek screen par sab naam, tick karte jao)
3. **Loan register** — kisko kitna loan diya, byaj rate (mahina %), kitni kist wapas aayi
4. **Byaj auto-calculate** — Kisan Calculator ka sood engine yahan direct kaam aayega
5. **Member passbook** — har member ka total jama + loan baki ek screen par
6. **Group summary** — group ke paas total fund kitna, kitna loan par gaya
7. **WhatsApp share** — meeting ka summary group mein bhejo

## Baad ke Features (v2+)
- PDF register print (bank linkage ke liye documents)
- Multiple groups (ek didi kai group chalati hai)
- Marathi/Bengali/Telugu (SHG movement south/east mein bahut strong hai)

## Screens
1. Home — group summary card + is mahine ki meeting ka button
2. Meeting entry screen (member list, amount entry)
3. Loan screens (naya loan, kist entry)
4. Member passbook screen
5. Reports

## Engine Reuse
- Kisan Calculator ka sood/byaj logic — direct reuse
- 03/04 wala database layer — reuse
- Lekin ye list ka sabse complex data model hai (members × months × loans) — isliye priority thodi niche

## Monetization
- Ads kam rakho (mahila users, trust important) — banner only
- ₹199/saal per group unlock (2 groups ke baad) — NGO/NRLM bulk interest bhi aa sakta hai

## ASO / Keywords
- bachat gat hisab, SHG app hindi, self help group register, samuh hisab, mahila bachat gat
- Naam suggestion: "Bachat Gat Hisab - SHG Register"

## Competition
- Sarkari (NRLM/Lokos) apps hain lekin unki reviews kharab hain (complex, server issues). Private simple offline app almost zero

## Kitna Time Lagega
3-4 hafte (data model bada hai)

## Success Metric (3 mahine)
- 5,000+ installs
- Ek bhi NGO/block-level adoption mila to jackpot — unse baat karne ka rasta dhundo
