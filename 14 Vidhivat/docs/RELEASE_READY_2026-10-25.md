# विधिवत v1.2.0 — प्रकाशन की वर्तमान स्थिति

25 अक्टूबर 2026 · उपयोगकर्ता की नवीनतम अनुमति: **समीक्षा और प्रकाशन तक पूरा काम करना है।** पुराना “publish से पहले रुकना” निर्देश इस अनुमति से बदल गया है।

**वर्तमान स्थिति:** नया बिल्ड Play Console में स्वीकार, Production release 1.2.0 (7) सहेजी। विवरण, आठ phone screenshots और Data Safety समेत **5 changes** Publishing overview में हैं। अंतिम नए APK का phone smoke test फोन अनलॉक होने की प्रतीक्षा में है। अभी Send for review नहीं दबाया; पुराने संस्करण को नया प्रकाशित नहीं कहा जा सकता।

## जो अपडेट हो गया

- सार्वजनिक गोपनीयता नीति **उसी URL** पर 25 अक्टूबर की सही bilingual प्रति से Update हुई। सार्वजनिक पन्ना खोलकर तारीख, Photon/PayU, जन्म-विवरण, backup/sharing और संपर्क पढ़े। शीर्षक अब “विधिवत — गोपनीयता नीति / Vidhivat Privacy Policy” है।
- सार्वजनिक लिंक: https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html । कोई नई post या नया permalink नहीं।
- Store settings में ईमेल `all.chandansingh@gmail.com`, वेबसाइट `https://vidhivatpuja.blogspot.com`, Lifestyle श्रेणी और Books & reference/Calendar/Lifestyle/Religious text tags सही मिले; सही मौजूदा विवरण नहीं बदले। किसी दूसरे ऐप या global Blogger profile में बदलाव नहीं।
- मुख्य हिंदी विवरण (79/80 और 3713/4000), आठ नए RGB screenshots सही क्रम में, हिंदी release notes 373/500 अक्षर सहेजे। आठ नए AI-सहायता से तैयार visual assets का AI-label चयन भी किया।
- Data Safety फॉर्म बदला और Save हुआ: search history तथा IP/network identifier के लिए Device or other IDs; Collected+Shared, optional, not ephemeral। Search के लिए app functionality; IP logs के लिए functionality/security। HTTPS Yes, account/external-login No, server deletion mechanism No। आधार `app/play_store_assets/release_2026-10-25/data-safety-basis.md`। बिना प्रमाण sharing exemption या 90-day deletion badge नहीं चुना।

## अंतिम बिल्ड का निश्चित स्रोत और फाइलें

Commit **ac61db7bc42a3fc5d70fa152619c8534325493ef**। D-146/D-147 पाठ और D-148 मुहूर्त गणित शामिल; बंद मुहूर्त feature के flags नहीं खोले। यह इस release का निश्चित cutoff है; बाद का समानांतर कार्य अपने आप इस AAB में नहीं आएगा।

Downloads: `C:/Users/Admin/Downloads/Vidhivat_v1.2.0_7_2026-10-25/`। **ac61db7 नाम वाली नई फाइलें इस्तेमाल करें; 9d2c1f1 पुराना candidate है।**

| फ़ाइल | bytes | SHA-256 |
|---|---:|---|
| Vidhivat_v1.2.0_7_ac61db7.aab | 86915082 | 60704b36912f7b924f2dc333f21524aacbf08053bda5890b89a92e378ac59bbf |
| Vidhivat_v1.2.0_7_ac61db7.apk | 89394010 | 070d0d59120b8280042a7060c661ed7ff88c18da5f60bb16f431ed8e205ed1fa |

Latest artifact manifest `LATEST_ARTIFACTS.json` है। इसी फ़ोल्डर में screenshots ZIP, नीति और listing की प्रतियाँ हैं। कोई signing key/password या निजी phone screenshot शामिल नहीं।

## वास्तव में की गई वर्तमान जाँच

- सही snapshot पर app **1456/1456**, engine **629/629** — कुल **2085 pass**, analyzer clean। Snapshot granth/vrat validators पास। यह खुले धार्मिक J-/U-findings का स्वतः समाधान नहीं है।
- **सभी 543 input files** स्वतंत्र रूप से Git commit blobs से मिलाईं (सिर्फ़ CRLF तुलना सामान्य की); 16 runtime input बदलाव, 527 पुरानी input files अपरिवर्तित। AAB के **434 packaged assets** actual source-byte hashes से मिले।
- bundletool validate पास। com.vidhivat, 1.2.0+7, min24/target36, PAGE_ALIGNMENT_16K। 12 native ELF files की static alignment जाँच; आवश्यक 64-bit LOAD alignment पास।
- सभी **840 payload entries** JarFile से पढ़कर cryptographic signature सत्यापित; वही एक non-debug upload certificate। APK signature और `zipalign -P16` पास।
- APK `install -r` फोन पर सफल। फोन sleep/secure lock पर है; उसे bypass नहीं किया। अनलॉक के लिए उपयोगकर्ता से async सूचना माँगी है।
- पहले archive गलती से cached root के एक स्तर ऊपर निकला था। पुराने checks/build को वर्तमान-source प्रमाण नहीं माना। सही root में निकालकर सभी inputs Git से मिलाए, पूरा app/engine test और build दोबारा चलाया। Console पर **केवल सही ac61 AAB** upload की।

## Console में सत्यापित

Production release internal ID6, versionCode7/name1.2.0। पुराने code5/1.1.0 को नया release नहीं कहा। नया AAB upload स्वीकार हुआ। समर्थित फोन 12,441 और tablets 6,814; कोई पूर्व समर्थित device नहीं घटा।

**कोई blocking error नहीं; एक size warning:** नया per-device download लगभग36.4MB, पहले से11.7MB अधिक; update14.4MB। UI/ग्रंथ चित्रों से आकार बढ़ा है। Rollout100%, मौजूदा target countries वही। Final Save से change Publishing overview में आया।

## फोन और screenshot का पहले पूरा हुआ आधार

Vivo V2553 (720×1600) पर पिछले candidate9d2 की पूरी मुख्य UI जाँच हुई: आगामी popular grid, नित्य पूजा के सभी10चरण व दक्षिणा भाग (कोई payment नहीं), संकल्प, गीता/रोमन/अर्थ, पंचांग, Delhi/Varanasi खोज, कुंडली ग्रह/दशा/पंचांग tabs, नए Tulsi/Kartik चित्र। स्वीकृत fake रवि और Demo QA हटे, मूल तीन कुंडलियाँ बचीं।

आठ Store screenshots उसी असली UI से हैं; उनके दिखाए screens/assets ac61 में नहीं बदले। ये generated/fake app UI नहीं हैं: केवल Android status/navigation पट्टी हटाकर समान अनुपात, ब्रांड और captions जोड़े। कुछ natural scroll positions हैं। निजी सूची/कॉल/notifications को public package में नहीं रखा। वर्तमान APK पर updated paath का अंतिम native smoke test अलग से बाकी है।

## शेष अंतिम चरण

1. फोन अनलॉक होने पर नई APK पर home तथा बदले paath खोलें; फिर अंतिम native checkpoint लिखें।
2. Publishing overview में automated checks/सभी5changes मिलाकर Submit for review करें। Managed publishing अभी off है, इसलिए Google की स्वीकृति के बाद release स्वतः प्रकाशित हो सकती है।
3. Submit और Google approval/live को अलग दर्ज करें। Google review की अवधि और स्वीकृति agent के नियंत्रण में नहीं। कोई “live” दावा तभी जब Console/public Store में पुष्टि मिले।

नीति स्रोत: [Google Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN), [Photon endpoint के log पर आधिकारिक उत्तर](https://github.com/komoot/photon/discussions/539) (lonvia,16Feb2021; exact वर्तमान retention days नहीं), [Android backup](https://developer.android.com/identity/data/autobackup), [AI labels](https://support.google.com/googleplay/android-developer/answer/17262077?hl=en)।

स्थानीय प्रमाण `design_sources/release_2026-10-25/current-*`, policy-published.png और Console captures में हैं। Source-audit shared docs पर केवल append; किसी अन्य session की content files/staged work नहीं छुआ।
