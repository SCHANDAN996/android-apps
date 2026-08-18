# PRO KISAN (प्रो किसान) — Master Product Plan v2.0

> **एक line में:** पूरे भारत के किसान का एक ही app — हिसाब (दूध/पशु/खाद) + जानकारी (योजना/मंडी भाव/मौसम/समाचार) + AI सलाहकार। Offline-first core, online content layer।
> **Package:** `com.chandansingh.pro_kisan` · **Play title:** Pro Kisan - दूध पशु खाद हिसाब
> **Tagline:** "हर किसान, प्रो किसान"

---

## 1. VISION और POSITIONING

**समस्या:** भारत के किसान के फ़ोन में या तो 10 अलग-अलग आधे-अधूरे apps हैं (दूध का अलग, मंडी का अलग, योजना का अलग), या कुछ भी नहीं। सरकारी apps भारी और उलझे हैं; private apps login माँगते हैं और data बेचते हैं।

**हमारा जवाब:** एक app जो —
1. **रोज़ काम आए** (दूध का हिसाब = रोज़ खुलेगा) — यही retention engine है
2. **पैसा बचाए/कमाए** (खाद dose, मंडी भाव, योजना का पैसा)
3. **याद रखे** (पशु की तारीख़ें, टीके)
4. **बिना login, बिना data बेचे** — भरोसा ही brand है

**Positioning statement:** "जो काम गाँव में मुनीम, पशु-मित्र, कृषि-सलाहकार और अख़बार मिलकर करते हैं — वो अकेला Pro Kisan करता है।"

---

## 2. TARGET USERS (पूरा भारत, परत-दर-परत)

| परत | कौन | कौन-सा module खींचेगा |
|---|---|---|
| Core | डेयरी किसान (दूध बेचने वाले, 2-10 पशु) — UP, बिहार, राजस्थान, MP, पंजाब, हरियाणा, गुजरात, महाराष्ट्र | दूध + पशु |
| दूसरी | आम खेती करने वाले (1-10 एकड़़) — हर राज्य | खाद-बीज + मंडी भाव + मौसम |
| तीसरी | योजना खोजने वाले (सबसे बड़ी संख्या) | योजना + समाचार |
| चौथी | युवा/पढ़े-लिखे किसान परिवार के सदस्य | AI सलाहकार |

**भाषा रणनीति (pan-India का असली रास्ता):**
- **Phase 1:** हिंदी (default) + English — 60% भारत cover
- **Phase 2:** मराठी, गुजराती, पंजाबी (कृषि-प्रधान राज्य)
- **Phase 3:** बंगाली, तेलुगु, तमिल, कन्नड़
- Jameen Napi वाला `app_language.dart` pattern reuse होगा — strings पहले दिन से file में, hardcode कभी नहीं

---

## 3. MODULE MAP (पूरा app एक नज़र में)

```
┌──────────────────── PRO KISAN ────────────────────┐
│                                                    │
│  OFFLINE CORE (हमेशा चलेगा, बिना internet)          │
│  🥛 दूध का हिसाब   🐄 पशु reminder   🌾 खाद-बीज     │
│                                                    │
│  ONLINE LAYER (internet पर ताज़ा, cache में बासी)   │
│  🌦️ मौसम   📊 मंडी भाव   🏛️ सरकारी योजना   📰 समाचार │
│                                                    │
│  AI LAYER (Phase 3)                                │
│  🤖 किसान AI सलाहकार (Gemini)                       │
└────────────────────────────────────────────────────┘
```

**First-run Onboarding (app खुलते ही, 3 छोटे steps):**
1. **भाषा चुनें** — बड़े बटन: हिंदी / English (Phase 2 में बाक़ी भाषाएँ इसी screen पर जुड़ेंगी) — बिना चुने आगे नहीं
2. **राज्य चुनें** — 28 राज्य + UT की सूची (खोज के साथ) — यही राज्य तय करेगा: बीघा/कट्ठा का माप, आपके राज्य की योजनाएँ, आपकी मंडियाँ। "बाद में बदल सकते हैं" नोट के साथ
3. **आप क्या करते हैं?** (optional, skip हो सकता है) — ☑️ दूध बेचता हूँ ☑️ पशु पालता हूँ ☑️ खेती करता हूँ → इसी से dashboard के cards का order तय होगा (personalization पहले दिन से)
- तीनों जवाब shared_preferences में; Settings से कभी भी बदले जा सकें

**Navigation:** Bottom nav 5 tabs — घर (dashboard) | दूध | पशु | खेती (खाद+मंडी+मौसम) | और (योजना, समाचार, AI, settings)
**घर (Dashboard):** आज का सारांश एक screen पर — आज का दूध, आज के pashu reminders, आज का मौसम, आज का मंडी भाव (चुनी फ़सल), 1 योजना highlight। यही screen app की जान है — किसान को रोज़ सुबह एक नज़र में सब मिले।

---

## 4. OFFLINE CORE — तीनों modules (पूरा technical spec `AI_BUILD_PROMPT.md` में है)

### 🥛 दूध का हिसाब
रोज़ की entry (10 सेकंड), किसान/दूधवाला mode, flat/fat rate, महीने का हिसाब, ग्राहक उधार, WhatsApp bill, JSON backup। **Base code तैयार है** (`dudh_ka_hisab` — ~5,000 lines)।

### 🐄 पशु
AI/गर्भाधान date → अपने-आप पूरी timeline (heat +21d, जाँच +75d, दूध सुखाना −60d, ब्याना 283/310d) + टीका schedule (FMD/HS/BQ/डीवर्मिंग) + आहार कैलकुलेटर। Local notifications।

### 🌾 खाद-बीज
15 फ़सलों का NPK dose (यूरिया/DAP/MOP + बोरी + ख़र्च), राज्य-wise बीघा, बीज दर, छिड़काव कैलकुलेटर। हर जगह "मिट्टी जाँच कराएँ" disclaimer।

---

## 5. ONLINE LAYER — नए modules (यहीं app "Pro" बनता है)

### 🌦️ मौसम (Phase 1 में ही — किसान की #1 रोज़ की ज़रूरत)
- **Data source:** Open-Meteo API — **बिल्कुल free, कोई API key नहीं, commercial use allowed** — यह solo dev के लिए वरदान है
- Features: आज + 7 दिन का forecast (बारिश %, तापमान, हवा), **"छिड़काव के लिए ठीक?" indicator** (तेज़ हवा/बारिश में spray बर्बाद — यह छोटा feature किसान का दिल जीत लेगा), बुवाई/कटाई सलाह वाले basic alerts
- Location: user से GPS permission या manual ज़िला चुनना (privacy-friendly default: manual)
- Offline behavior: आख़िरी fetch cache में, "X घंटे पुराना" label के साथ

### 📊 मंडी भाव (Phase 2 — सबसे ज़्यादा माँगा जाने वाला feature)
- **Data source:** data.gov.in का AGMARKNET daily mandi price API — **सरकारी, free (free API key registration)**
- Features: अपना राज्य + ज़िला + 3-5 पसंदीदा फ़सलें चुनो → उनका आज का भाव dashboard पर; आस-पास की मंडियों की तुलना ("यहाँ ₹2,100, 40km दूर ₹2,350")
- Offline: आख़िरी भाव cache, date-stamp के साथ
- ⚠️ Disclaimer: "भाव सरकारी AGMARKNET data से हैं, बेचने से पहले मंडी में पुष्टि करें"

### 🏛️ सरकारी योजना (Phase 2 — installs का सबसे बड़ा magnet)
**Data architecture (यह सबसे सोच-समझकर बनाना है):**
- योजनाओं का data एक **remote JSON** में (GitHub Pages/Firebase Hosting पर free host) — app खोलने पर fetch, local cache। **App update के बिना योजनाएँ update होती रहेंगी** — यही पूरी तरकीब है
- हर योजना का schema: नाम, केंद्र/राज्य, किसे मिलेगा (पात्रता), क्या मिलेगा (लाभ), कैसे मिलेगा (steps), ज़रूरी documents, **आधिकारिक link/portal**, helpline, आख़िरी-update date
- **Launch content:** 12-15 केंद्रीय योजनाएँ (PM-Kisan सम्मान निधि, PM फ़सल बीमा, KCC, Soil Health Card, PM-Kusum, e-NAM, PKVY जैविक, पशुधन बीमा...) + **Top 10 कृषि राज्यों** की 3-5 बड़ी योजनाएँ प्रत्येक (UP, बिहार, MP, महाराष्ट्र, राजस्थान, पंजाब, हरियाणा, गुजरात, कर्नाटक, आंध्र/तेलंगाना)
- User अपना राज्य चुनता है → केंद्रीय + उसके राज्य की योजनाएँ दिखती हैं
- **⚠️ POLICY SAFETY (जान से ज़रूरी — account इसी पर टिका है):**
  - App में साफ़ लिखा हो: "यह एक निजी जानकारी app है, सरकारी app नहीं" (Play का impersonation rule)
  - Play Console में **Government apps declaration** में सही जवाब: सरकारी app नहीं, सरकारी जानकारी देता है
  - कभी "यहाँ apply करें" का form मत बनाओ — हमेशा **आधिकारिक portal का link** खोलो
  - हर योजना पर "जानकारी बदल सकती है — आधिकारिक source देखें" + source link
  - कोई पैसा/subsidy दिलाने का वादा नहीं, कोई "guaranteed" शब्द नहीं
- **Maintenance वादा (खुद से):** महीने में 1 बार JSON review — बासी योजना जानकारी = 1-star reviews + policy risk

### 📰 खेती समाचार (Phase 2)
- **Legal-safe तरीक़ा (यह ज़रूरी है):** किसी अख़बार का content **copy नहीं** करना — सिर्फ़:
  1. **सरकारी/public feeds:** PIB (कृषि मंत्रालय releases), ICAR, DD Kisan — headline + summary + link
  2. **अपना curated content:** हफ़्ते में 5-7 छोटी news items ख़ुद likhna/likhwana (AI से draft बनवाकर verify) — यही remote JSON में
- Format: छोटे cards — headline, 2-line सार, date, "पूरा पढ़ें" (browser में खुले)
- मौसमी alerts भी यहीं: "गेहूं बुवाई का समय शुरू", "आम में दवा छिड़काव का हफ़्ता"

### 🤖 किसान AI सलाहकार (Phase 3 — सोच-समझकर)
- **Engine:** Gemini API (free tier) — हिंदी में सवाल-जवाब: "गेहूं में पीलापन क्यों?", "भैंस दूध कम दे रही है"
- System prompt में सीमाएँ: सिर्फ़ खेती/पशु विषय, हर जवाब के अंत में "गंभीर समस्या में कृषि विशेषज्ञ/पशु चिकित्सक से मिलें"
- **Rate limit अपनी तरफ़ से:** 10 सवाल/दिन per user (free tier quota बचाने के लिए) — बाद में rewarded ad से 5 और
- ⚠️ **Data Safety असर:** AI questions server पर जाते हैं → Play के Data Safety form में यह declare करना होगा। Privacy policy में भी। (Offline-only claim तब सिर्फ़ core modules के लिए करना।)
- Photo-based रोग पहचान: Phase 4 का सपना — पहले text से शुरू

---

## 6. TECH ARCHITECTURE (एक paragraph में साफ़)

**Offline-first core + cached online layer.** तीनों हिसाब modules sqflite में, internet के बिना 100% काम। Online modules एक common `ContentRepository` से चलेंगे: fetch → local cache (sqflite/file) → UI हमेशा cache से पढ़े (ताज़ा हो तो ताज़ा, वरना बासी + timestamp label)। Remote config = एक hosted JSON (योजना/समाचार/app-config) — app release के बिना content बदलता रहे। Firebase सिर्फ़ Analytics के लिए (कौन-सा module चलता है यह जानना ज़रूरी है)। कोई user account नहीं, कोई personal data server पर नहीं (सिवाय AI सवालों के — Phase 3 में declared)।

---

## 7. MONETIZATION (परत-दर-परत)

| Source | कहाँ | कब |
|---|---|---|
| Banner | दूध home + मंडी भाव screen | v1.0 |
| Interstitial | महीने की report खोलने पर (1/session) + खाद result (हर 3rd) | v1.0 |
| Native ads | समाचार feed के बीच (हर 5th card) — news feed ads के लिए सबसे natural जगह | v1.1 |
| Rewarded | AI के extra सवाल unlock | v2.0 |
| **Pro subscription ₹99/साल** | ad-free + unlimited AI + premium reports (PDF) | v2.0 |
| B2B सपना | dairy collection centers को white-label दूध module | जब 50k+ users |

नियम वही: reminder/SOS जैसी जगहों पर कभी ad नहीं, app-open पर कभी नहीं।

---

## 8. PHASED ROADMAP (सबसे ज़रूरी section — इसी अनुशासन से app बनेगा)

### 🚀 v1.0 — "हिसाब + मौसम" (6-7 हफ़्ते) — LAUNCH
- तीनों offline modules (दूध base code से शुरू — आधा तैयार)
- मौसम (Open-Meteo — free, आसान, बड़ा value)
- घर dashboard, हिंदी+English, backup, ads, analytics
- **यहीं launch करो। बाक़ी सब बाद में।** (जो app v1 में सब कुछ करना चाहता है वह v0 पर मर जाता है)

### 📈 v1.1 — "जानकारी" (launch के 4-6 हफ़्ते बाद)
- सरकारी योजना module (केंद्र + top 10 राज्य, remote JSON)
- मंडी भाव (data.gov.in API)
- समाचार (PIB/curated)
- ASO refresh: "yojana", "mandi bhav" keywords जुड़ेंगे → installs की दूसरी लहर

### 🤖 v2.0 — "AI + भाषाएँ" (data देखकर)
- किसान AI सलाहकार (Gemini, limits के साथ)
- मराठी/गुजराती/पंजाबी
- Pro subscription
- जो module analytics में सबसे ज़्यादा चले, उसे गहरा करो

### 🌟 v3.0+ — सपने (सिर्फ़ तब जब 1 लाख+ users)
- Photo से रोग पहचान, पशु बीमा/loan जानकारी, किसान community, mandi rate alerts (notifications)

---

## 9. PLAY POLICY और RISK REGISTER (हर risk का इलाज साथ में)

| Risk | इलाज |
|---|---|
| सरकारी app समझा जाना (impersonation) | "निजी app है" साफ़ लिखा + सरकारी logo/नाम कभी icon/title में नहीं + Government apps declaration सही भरना |
| योजना की बासी/गलत जानकारी | Remote JSON + महीने की review + हर item पर source link + date + disclaimer |
| समाचार copyright | सिर्फ़ सरकारी feeds/अपना content; बाहरी ख़बर = headline+link only |
| पशु/खेती सलाह से नुकसान का आरोप | हर सलाह पर "विशेषज्ञ से पुष्टि करें" — app "जानकारी" देता है, "प्रिस्क्रिप्शन" नहीं |
| AI गलत जवाब | Phase 3 में limits + disclaimers + खेती-only scope; बिना तैयारी AI मत जोड़ना |
| Data Safety गलत भरना | v1.0 = offline+ads (ad ID declare); Phase 3 में AI जुड़ने पर form दोबारा update |
| API मर गया (mandi/weather) | Cache + graceful "data उपलब्ध नहीं" — app कभी crash न हो; core modules तो चलते ही रहेंगे |
| Scope-death (सब एक साथ बनाने में app कभी न बने) | ऊपर का phased roadmap — v1.0 की सीमा पत्थर की लकीर |

---

## 10. ASO — PAN-INDIA रणनीति

- **Title:** Pro Kisan - दूध पशु खाद हिसाब (v1.1 के बाद: "Pro Kisan: हिसाब, योजना, मंडी भाव" test करो)
- **Keywords (हिंदी):** dudh ka hisab, pashu calculator, गाभिन कैलकुलेटर, खाद कैलकुलेटर, kisan app hindi, मंडी भाव, सरकारी योजना किसान, मौसम खेती
- **Keywords (English):** dairy record app, cattle reminder, fertilizer calculator, mandi rates, kisan yojana
- हर भाषा में listing localize (Phase 2 भाषाओं के साथ) — Play में हर locale अलग index होती है
- Cross-promotion: Jameen Napi ↔ Pro Kisan दोनों में एक-दूसरे का link
- Reels रणनीति: हर module के 5 shorts ("भैंस कब ब्याएगी — 5 सेकंड में जानो", "यूरिया कितना डालें — गिनकर")

## 11. SUCCESS METRICS

| Metric | v1.0 (3 महीने) | v1.1 (6 महीने) |
|---|---|---|
| Installs | 15,000 | 50,000 |
| DAU/MAU | 25%+ (दूध module की ताक़त) | 30%+ |
| D-30 retention | 20%+ | 25%+ |
| Module usage | दूध #1 expected | योजना/मंडी से नई install-लहर |
| Rating | 4.3+ | 4.4+ |

## 12. खुद से वादे (maintenance discipline)

1. योजना JSON — महीने में 1 review (calendar reminder)
2. फ़सल/खाद data — साल में 2 बार (रबी/खरीफ से पहले)
3. हर release के बाद 1 हफ़्ता crash/review watch
4. जो module 3 महीने में 5% से कम use हो — उसे गहरा करने में समय मत डालो
5. v1.0 ship किए बिना v1.1 का code नहीं

---

*Plan v2.0 — 18-07-2026। Technical build spec (offline core) `AI_BUILD_PROMPT.md` में; online layer के specs v1.1 शुरू करते समय उसी में जोड़े जाएँगे।*
