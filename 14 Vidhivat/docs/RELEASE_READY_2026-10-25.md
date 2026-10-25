# विधिवत v1.2.0 — प्रकाशन से पहले का हैंडओवर

25 अक्टूबर 2026 · स्थिति: **Console listing draft सहेजा; review/publish रोका हुआ है।**

## तैयार सामग्री

- मुख्य हिंदी लिस्टिंग: नाम वही (29 अक्षर), छोटा विवरण 79, पूरा विवरण 3713, रिलीज़ नोट 373 अक्षर। सादे पाठ `app/play_store_assets/release_2026-10-25/` में हैं। छोटा और पूरा विवरण Console में **Save as draft** किया और नया पाठ दोबारा पढ़कर मिलाया।
- आठ नए 1080×1920 RGB PNG: `app/play_store_assets/screenshots/release_2026-10-25/`। क्रम संकल्प, होम, ग्रंथालय, पाठ, पूजा, पंचांग, कुंडली, जगह खोज। सभी अंतिम APK से वास्तविक फोन पर। आठों तस्वीरें Console draft में इसी क्रम में सहेजी गईं। आइकन/feature graphic नहीं बदले।
- `privacy_policy.html` सुधारी; उससे `privacy_policy_blogger.html` दोबारा बनाई। हिंदी/अंग्रेज़ी तारीख 25 अक्टूबर। Photon और PayU दोनों, request metadata, जन्म-विवरण, स्वैच्छिक दक्षिणा, सिस्टम बैकअप और आपके चुने sharing विकल्प स्पष्ट किए। पुराने विरोधाभासी वाक्य हटाए।
- Blogger की **मौजूदा पोस्ट** के HTML editor में पूरा नया पाठ तैयार है। **Changes not saved / Update** की स्थिति है: सार्वजनिक Update नहीं दबाया। नई पोस्ट नहीं बनाई, मौजूदा URL नहीं बदला। सुरक्षित मूल फ़ाइल स्थानीय है; editor बंद होने पर उसी से फिर भर सकते हैं।

## बनी फाइलें

Downloads फ़ोल्डर: `C:/Users/Admin/Downloads/Vidhivat_v1.2.0_7_2026-10-25/`

| फ़ाइल | bytes | SHA-256 |
|---|---:|---|
| `Vidhivat_v1.2.0_7_9d2c1f1.aab` | 86912807 | `5b765ea8c57fbc069fceb981df9eab45528b2502c46863d1ea8038a5287b7c06` |
| `Vidhivat_v1.2.0_7_9d2c1f1.apk` | 89391734 | `ed652237d99ec24ab3babe3d40216368a1543044a02ab1581027d1a201515444` |

इसी फ़ोल्डर में screenshots ZIP, नीति की दोनों प्रतियाँ, चार listing पाठ और ARTIFACTS.json हैं। कोई signing key/password या निजी फोन screenshot शामिल नहीं। **AAB Console पर upload नहीं हुई।**

## बिल्ड का निश्चित स्रोत

Snapshot commit `9d2c1f1360cd9b4ff4e5a31c21b779ee31ad94e3`। अलग, ignored archive से build की ताकि साथ चल रहे content edits बीच में न मिलें। ऐप v1.2.0+7, package com.vidhivat, minSdk24, targetSdk36।

**इसके बाद के D-146 (`9b6c5e8`) और D-147 (`3bd9340`) धार्मिक-पाठ सुधार इस candidate में नहीं हैं।** उन्हें release में लेने पर नए स्थिर snapshot से build और संबंधित tests/phone smoke test करना होगा। केवल working tree के नए होने से पुरानी बनी AAB नई नहीं हो जाती। Root app/build में दूसरे artifacts हो सकते हैं; ऊपर की स्पष्ट नाम वाली फाइलों को ही इस रिपोर्ट का candidate मानें।

## वास्तव में की गई जाँच

- Snapshot Flutter app **1456/1456 pass**, analyzer clean। Engine के पूर्व **623/623 pass** का checkpoint; engine source अपरिवर्तित, परीक्षण अनावश्यक रूप से नहीं दोहराया।
- Snapshot `jaancho_vrat.py` और `jaancho_granth.py` पास: 33 व्रत; generated granth assets generator परिणाम से मिले। यह धार्मिक स्रोत-जाँच के खुले J-/U-निष्कर्ष बंद नहीं करता।
- bundletool 1.18.3 validate पास; manifest/name/code/SDK पढ़े; config **PAGE_ALIGNMENT_16K**। 543 snapshot inputs और 434 packaged assets के hashes मिले। 12 native ELF files जाँचीं; आवश्यक 64-bit LOAD segments 16KB aligned।
- सभी **840 AAB payload entries** JarFile से पढ़कर cryptographic digest/signature सत्यापित; एक non-debug signer। APK apksigner v2 और `zipalign -c -P16` पास।
- jarsigner ने `jar verified` कहा, साथ में self-signed/no-timestamp और JarInputStream ZIP-order चेतावनी दी। उसे छिपाया नहीं; अलग Java verifier ने हर payload JarFile से पढ़कर signature जाँचा। Store acceptance का प्रमाण अभी नहीं।
- पहले Console bundle explorer में 5 entries देखीं; अधिकतम code **5 / 1.1.0**। code7 अभी खाली था; upload से ठीक पहले फिर मिलाएँ।

## फोन पर हुई जाँच

Vivo V2553, 720×1600। अंतिम snapshot APK `install -r` सफल; पुराना app data रखा।

- होम में करवा चौथ, धनतेरस, दीपावली लक्ष्मी-गणेश और गोवर्धन की 2×2 लोकप्रिय पूजा दिखी।
- नित्य पूजा की तैयारी → सभी **10 चरण** → मार्गदर्शिका पूरी → दक्षिणा का वैकल्पिक हिस्सा देखा। **भुगतान नहीं किया।**
- पूरा संकल्प बना; ग्रंथालय और गीता अध्याय 1, अर्थ/रोमन toggle, पढ़ने का स्थान खुला।
- पूरा पंचांग, Delhi जगह चुनना और Varanasi नाम की खोज जाँची। अलग राज्यों के नतीजे अलग विवरण के साथ दिखे। GPS/system permission नहीं दबाई, global शहर नहीं बदला।
- बनावटी Demo QA (1 जनवरी 1990, 06:00, Delhi) से कुंडली बनी; ग्रह/दशा/पंचांग tabs खुले। यह navigation/render smoke test है, स्वतंत्र खगोलीय पुनर्गणना नहीं।
- तुलसी विवाह और कार्तिक पूर्णिमा के **दोनों नए चित्र वास्तविक फोन पर सही खुले** और आँख से देखे।
- स्वीकृत अस्थायी संकल्प व्यक्ति रवि और Demo QA कुंडली हटा दीं। पहले से मौजूद **तीन कुंडलियाँ** बचीं; उनके विवरण/फाइलें सार्वजनिक package में नहीं।
- बाद में USB फोन अलग हुआ। अतिरिक्त वैकल्पिक screenshot retake नहीं हुआ; ऊपर का smoke test और आठ exports पहले पूरे थे। स्क्रीनशॉट कुछ स्वाभाविक scroll positions दिखाते हैं।

## अभी शेष / प्रकाशन पर रोक

1. मालिक से अंतिम content cutoff: वर्तमान जाँचा 9d2 candidate या D-146/D-147 समेत नया candidate।
2. Blogger का **public Update** और फिर वही URL खोलकर पुष्टि।
3. Data safety: Photon की retention, IP-derived location और collected/shared exception की लागू स्थिति की पुष्टि। केवल ऐप search history न रखे, इससे server processing ephemeral सिद्ध नहीं होता। Console declaration इस पास में नहीं बदली; अनुमान से “Yes/No” नहीं भरे।
4. चुनी अंतिम AAB upload, release notes, Console validation, review और rollout। मालिक के निर्देश पर **Send for review / Publish नहीं दबाए**। कोई push भी नहीं किया।
5. मामूली खुला UX-017: पूजा पूरी होने पर “होम पर लौटें” पिछले पूजा tab पर लौट सकता है। यह बंद/भुगतान/डेटा-हानि नहीं करता; अलग छोटा UI सुधार।

नीति के आधार: [ऐप की Data safety घोषणा](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [Android Auto Backup](https://developer.android.com/identity/data/autobackup), [Google screenshot विनिर्देश](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en-en)। Source behavior: `app/lib/services/osm_khoj.dart:105,282`, Android merged manifest और share actions। असल cloud backup चलाकर निजी डेटा भेजने का परीक्षण नहीं किया।

स्थानीय प्रमाण: `design_sources/release_2026-10-25/` में snapshot logs, manifest/config, artifact hashes, Console draft screenshot और चुने phone captures। `.private/` का raw evidence Git/upload से बाहर है।
