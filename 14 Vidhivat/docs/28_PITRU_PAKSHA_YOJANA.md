# 28 — पितृ पक्ष: संशोधित product plan

**स्थिति:** 23 सितम्बर 2026 को review और P0–P2 implementation किया गया।

## लागू हुआ

- Calendar (चुना दिन और साल-सूची) तथा `आज` में साझा destination resolver;
  पितृ पक्ष के दोनों engine events सीधे श्राद्ध विधि खोलते हैं।
- पिंडदान `vaikalpik` चरण है: स्पष्ट skip button और 79 मिनट सरल क्रम +
  10 मिनट वैकल्पिक समय। सिर्फ़ साफ़ जगह, जल-पात्र और काला तिल ज़रूरी;
  बाकी सामग्री परंपरा/इच्छा के अनुसार अलग समूह में है।
- स्थानीय अपराह्न नियम से पूर्णिमा + 15 कृष्ण तिथियों की सूची। 2026
  दिल्ली की सभी 16 entries प्रकाशित पंचांग से test में मिलीं, जिसमें
  चतुर्थी और पंचमी दोनों 30 सितम्बर को आती हैं।
- परिवार की अनेक device-local profiles; नाम वैकल्पिक, सम्बन्ध, मूल शहर,
  मृत्यु तारीख़+समय से चंद्र-तिथि, manual override, अज्ञात तिथि का
  सर्वपितृ अमावस्या route और हटाने का विकल्प।
- Opt-in local reminder: permission केवल switch on करने पर, inexact
  scheduling, lock-screen नाम privacy toggle, boot के बाद reschedule।

2026 के दिन [Drik Panchang की दिल्ली श्राद्ध सूची](https://www.drikpanchang.com/shraddha/pitru-paksha-shraddha-dates.html?geoname-id=1273294)
से spot-check किए गए। Reminder का platform setup
[flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
के आधिकारिक निर्देशों पर है।

**रिलीज़ से पहले शेष:** मूल शहर सूची में न होने पर तिथि हाथ से देनी होगी;
2024–2030 के automatic engine tests हैं पर प्रकाशित पंचांग से हर साल/शहर
का स्वतंत्र मिलान और आचार्य की content review अभी नहीं हुई। Android और
iOS के असली फ़ोन पर notification delivery/permission QA भी बाकी है।

## अभी क्या सच में काम करता है

- इंजन पितृ पक्ष आरम्भ और सर्वपितृ अमावस्या पहचानता है।
- `श्राद्ध और तर्पण` page पर घर का सरल पितृ-स्मरण खुलता है। तर्पण के लिए
  सामान्य पितृ-नमन और पिंड-अर्पण के लिए अलग पितृ-स्तुति, दोनों पर ⓘ सीमा,
  हैं। पिंड और दान optional हैं।
- यह **पूर्ण पार्वण/एकोद्दिष्ट/तीर्थ पिंडदान नहीं** है। नाम-गोत्र/शाखा वाला
  पूर्ण क्रम अब भी app का दावा नहीं।

## पुराने plan की समीक्षा

पुराना plan दिशा में सही था, लेकिन इन सुधारों के बिना अधूरा रहता:

1. **15 बनाम 16:** पितृ पक्ष की 15 कृष्ण तिथियाँ अलग हैं; पूर्णिमा श्राद्ध
   उससे पहले अलग entry है। UI में कुल 16 entries दिखेंगी, उन्हें एक ही
   “15-दिन की list” कहना गलत होगा।
2. **तिथि अंग्रेज़ी date नहीं:** death anniversary के लिए user की death
   date/time/location से lunar tithi निकले, और उसे manual edit किया जा सके।
   Unknown-tithi route सर्वपितृ अमावस्या होगा।
3. **आस्था + privacy:** मृत्यु का कारण, संवेदनशील notes या server account
   नहीं चाहिए। केवल local device पर नाम/सम्बन्ध/तिथि; export/delete स्पष्ट।
4. **reminder:** पहले opt-in local notification; exact alarm default नहीं।
   अगली occurrence app खुलने/boot पर regenerate हो; Android permission तभी
   माँगी जाए जब user reminder on करे।
5. **दो modes:** simple home remembrance और full family tradition अलग
   wording/CTA में रहें। पहली को किसी भी घर का निकट परिजन कर सकता है;
   दूसरी में app केवल तैयारी और questions दे।

## build order

### P0 — सही रास्ता और truthful copy

- Calendar, home और `आज` से `पितृ पक्ष आरम्भ`/`सर्वपितृ अमावस्या` दबाने पर
  `VidhiScreen(id: 'shraadh')` खुले; generic vrat page नहीं।
- Current generic Sankalp केवल यजमान का नाम/gotra जानता है। इसलिए simple
  श्राद्ध flow में वह हटाकर plain-Hindi remembrance sentence रखा गया है;
  `AncestorProfile` आने तक app किसी specific deceased-person sankalp का दावा
  न करे।
- पिंडदान के लिए explicit **“यह वैकल्पिक कदम छोड़ें”** CTA और base duration
  बनाम optional duration अलग दिखे। Minimal materials और family-tradition
  materials अलग समूह हों।
- Tests: 2026-09-27 और 2026-10-10 calendar routes, player में दोनों ⓘ sheets,
  320dp/1.5x layout और no-pending route।

### P1 — dedicated Pitru Paksha page

- 16-entry local schedule: पूर्णिमा श्राद्ध, प्रतिपदा से अमावस्या,
  सर्वपितृ अमावस्या; local place/timezone और `अपराह्न` note।
- हर entry: date, tithi, short meaning, “सरल स्मरण खोलें”; duplicate/special
  tithis को static guess से नहीं, verified local Panchang calculations से।
- No “फल मिलेगा” guarantees, no caste/gender exclusion; known family rite gets
  priority over app’s simple route.

### P2 — family tithi profile + reminders

- Local `AncestorProfile`: relation, display name optional, death tithi or
  original date/time/place, reminder choice. A family can add many profiles.
- Calculator result explain करे: year/location से tithi बदल सकती है;
  user override और result-source metadata रखा जाए।
- Notification: “आज [नाम] का स्मरण-दिन है” — lock-screen privacy toggle,
  no network and no mandatory exact alarm.

### P3 — verification/release

- 2024–2030, Delhi + two non-India timezones, Purnimanta/Amanta labels; external
  published calendars से test fixtures मिलाएँ।
- scholar/acharya review for wording, not for making a universal ritual claim.
- accessibility: large text, screen-reader labels, offline first, cancel/delete
  profile test, and failure-safe reminders.

## broader app improvements, priority order

1. Calendar destination resolver — one shared mapping for festival → correct
   puja/parv/vrat page; regression test every special event.
2. Optional-step model in `Charan` — duration, skip CTA and material groups
   must match content; useful beyond पिंडदान too.
3. Source/data quality guardrails — new user-visible schema fields require
   language/length tests; source registry stays in docs, not user UI.
4. Content accessibility — all long-source/info sheets checked at 320dp and
   1.5× text, and high-risk claims always scoped in plain Hindi.

## success criteria

A person can open the relevant day from calendar, choose **simple home
remembrance**, see only necessary material, read a sourced non-universal prayer
and its limit, skip optional pinda, and set or decline a private reminder —
without being told that a full branch-specific ritual was completed.
