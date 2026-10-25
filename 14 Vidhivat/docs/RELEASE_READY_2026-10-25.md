# विधिवत v1.2.0 — प्रकाशन की वर्तमान स्थिति

26 अक्टूबर 2026 · उपयोगकर्ता की नवीनतम अनुमति: **समीक्षा और प्रकाशन तक पूरा काम करना है।** पुराना “publish से पहले रुकना” निर्देश इस अनुमति से बदल गया है।

**वर्तमान स्थिति: सफलतापूर्वक Google समीक्षा में भेज दिया।** Console में **Changes in review**,
Production **1.2.0 (8) — Start full rollout**, तीन हिंदी listing बदलाव और Data Safety दिखे।
पुराना क्रमांक7 समीक्षा में नहीं गया। **Managed publishing off** है: Google की स्वीकृति के बाद स्वतः प्रकाशन।
अभी नया संस्करण live/approved होने का दावा नहीं; Google review बाहरी प्रक्रिया है।

## जो अपडेट हो गया

- सार्वजनिक गोपनीयता नीति **उसी URL** पर 25 अक्टूबर की सही bilingual प्रति से Update हुई। सार्वजनिक पन्ना खोलकर तारीख, Photon/PayU, जन्म-विवरण, backup/sharing और संपर्क पढ़े। शीर्षक अब “विधिवत — गोपनीयता नीति / Vidhivat Privacy Policy” है।
- सार्वजनिक लिंक: https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html । कोई नई post या नया permalink नहीं।
- Store settings में ईमेल `all.chandansingh@gmail.com`, वेबसाइट `https://vidhivatpuja.blogspot.com`, Lifestyle श्रेणी और Books & reference/Calendar/Lifestyle/Religious text tags सही मिले; सही मौजूदा विवरण नहीं बदले। किसी दूसरे ऐप या global Blogger profile में बदलाव नहीं।
- मुख्य हिंदी विवरण (79/80 और 3713/4000), आठ नए RGB screenshots सही क्रम में, हिंदी release notes 446/500 अक्षर सहेजे। आठ नए AI-सहायता से तैयार visual assets का AI-label चयन भी किया।
- Data Safety फॉर्म बदला और Save हुआ: search history तथा IP/network identifier के लिए Device or other IDs; Collected+Shared, optional, not ephemeral। Search के लिए app functionality; IP logs के लिए functionality/security। HTTPS Yes, account/external-login No, server deletion mechanism No। आधार `app/play_store_assets/release_2026-10-25/data-safety-basis.md`। बिना प्रमाण sharing exemption या 90-day deletion badge नहीं चुना।

## अंतिम बिल्ड का निश्चित स्रोत और फाइलें

Commit **71302b671a5f9c10044688ae97d5cafb0fad6b39**। D-146/D-147 पाठ और D-148 मुहूर्त गणित शामिल;
बंद मुहूर्त feature flags नहीं खोले। आधी रात/अगले दिन resume पर होम की cached तारीख़ बदलने का सुधार
जोड़ा। पूजा की गिनती और पंचांग अब एक ही loaded day लेते हैं। आगे की mobile retest उपयोगकर्ता ने
स्पष्ट रूप से मना की: “अब चेक करने की जरूरत नहीं…fix…publish”। इसलिए final code8 की नई manual phone
जाँच नहीं की; local regression और release validations किए।

Downloads: `C:/Users/Admin/Downloads/Vidhivat_v1.2.0_8_2026-10-26/`। **71302b6 नाम वाली code8 फाइलें ही अंतिम हैं; ac61/code7 और 9d2 पुराने candidates हैं।**

| फ़ाइल | bytes | SHA-256 |
|---|---:|---|
| Vidhivat_v1.2.0_8_71302b6.aab | 86914609 | a329e775a1ce2bb260fd18ee47bd5d571ea935958bd6cfe29a87a2529d517fc9 |
| Vidhivat_v1.2.0_8_71302b6.apk | 89394010 | e51093543577705a253e0a014fb4c75341cd57cf3a28dc09780149591bdd94c3 |

Latest artifact manifest `LATEST_ARTIFACTS.json` है। इसी फ़ोल्डर में screenshots ZIP, नीति और listing की प्रतियाँ हैं। कोई signing key/password या निजी phone screenshot शामिल नहीं।

## वास्तव में की गई वर्तमान जाँच

- आधी रात के सुधार से पहले सही ac61 snapshot पर app **1456/1456**, engine **629/629** — **2085 pass**। अंतिम code8 सुधार के बाद **14 home tests** (दो नए clock/resume regression समेत), **124 संबंधित shell/navigation/version tests**, analyzer clean। नया पूरा app suite दोबारा नहीं चलाया; unchanged engine629 checkpoint वही है। Snapshot granth/vrat validators पास। यह खुले धार्मिक J-/U-findings का स्वतः समाधान नहीं है।
- **सभी 543 input files** स्वतंत्र रूप से Git commit blobs से मिलाईं (सिर्फ़ CRLF तुलना सामान्य की); 18 runtime input बदलाव, 525 पुरानी input files अपरिवर्तित। AAB के **434 packaged assets** actual source-byte hashes से मिले।
- bundletool validate पास। com.vidhivat, 1.2.0+8, min24/target36, PAGE_ALIGNMENT_16K। 12 native ELF files की static alignment जाँच; आवश्यक 64-bit LOAD alignment पास।
- सभी **840 payload entries** JarFile से पढ़कर cryptographic signature सत्यापित; वही एक non-debug upload certificate। APK signature और `zipalign -P16` पास।
- ac61/code7 APK install-r सफल; unlock के बाद updated Hanuman Chalisa/अर्थ और home/reading grid खोले। इसी native run में midnight stale-home दोष मिला। उसके बाद user ने आगे mobile check रोककर fix/publish कहा; code8 मोबाइल retest नहीं की। सुरक्षित फोन lock कभी bypass नहीं किया।
- पहले archive गलती से cached root के एक स्तर ऊपर निकला था। पुराने checks/build को वर्तमान-source प्रमाण नहीं माना। सही root में निकालकर सभी inputs Git से मिलाए, पूरा app/engine test और build दोबारा चलाया। पुरानी गलत-folder build upload नहीं की; पहले सही ac61/code7, फिर midnight सुधार वाली अंतिम71302b6/code8 AAB upload की।

## Console में सत्यापित

Final Production release internal ID7, versionCode8/name1.2.0। पुराना internalID6/code7 नया final release बनने पर supersede हुआ और अंतिम publishing table में नहीं था। अंतिम AAB स्वीकार हुई। समर्थित फोन 12,441 और tablets 6,814; कोई पूर्व समर्थित device नहीं घटा।

अंतिम code8 review में blocking error नहीं। पहले code7 को code5 से तुलना में size warning मिली थी (लगभग36.4MB download,11.7MB अधिक/update14.4MB); code8 में कोई नया आकार उछाल नहीं। Rollout100%, मौजूदा target countries वही। “Submit5changes” और फिर “Send changes for review” किया; बाद में Changes in review में code8 और बाकी चार बदलाव सत्यापित किए।

## फोन और screenshot का पहले पूरा हुआ आधार

Vivo V2553 (720×1600) पर पिछले candidate9d2 की पूरी मुख्य UI जाँच हुई: आगामी popular grid, नित्य पूजा के सभी10चरण व दक्षिणा भाग (कोई payment नहीं), संकल्प, गीता/रोमन/अर्थ, पंचांग, Delhi/Varanasi खोज, कुंडली ग्रह/दशा/पंचांग tabs, नए Tulsi/Kartik चित्र। स्वीकृत fake रवि और Demo QA हटे, मूल तीन कुंडलियाँ बचीं।

आठ Store screenshots उसी असली UI से हैं; उनके दिखाए screens/assets ac61 में नहीं बदले। ये generated/fake app UI नहीं हैं: केवल Android status/navigation पट्टी हटाकर समान अनुपात, ब्रांड और captions जोड़े। कुछ natural scroll positions हैं। निजी सूची/कॉल/notifications को public package में नहीं रखा। ac61/code7 पर updated Hanuman Chalisa और अर्थ का native smoke test बाद में पूरा हुआ। code8 का अतिरिक्त mobile test उपयोगकर्ता ने waive किया।

## अब बाहरी शेष प्रक्रिया

Google की review/approval बाकी है। Console ने “Your changes are now in review” दिखाया और कोई असहेजा/अप्रेषित final change नहीं छोड़ा। Managed publishing off होने से approval पर स्वतः प्रकाशित हो सकता है; उपयोगकर्ता को फिर Submit/Publish दबाने की आवश्यकता नहीं बताई गई। Google की मंजूरी या review के दिनों का वादा नहीं किया।

26 अक्टूबर के अंतिम proofs: `publishing-in-review-code8.png`, `final8-inputs.json`, `final8-bundle-verification.json`, `final8-manifest.xml`, `final8-signature.json`, `midnight-regression-tests.log`, `midnight-shell-tests.log`। सार्वजनिक policy proof `policy-published.png`। सभी `design_sources/release_2026-10-25/` में हैं; folder date आरम्भिक evidence session की है।

नीति स्रोत: [Google Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN), [Photon endpoint के log पर आधिकारिक उत्तर](https://github.com/komoot/photon/discussions/539) (lonvia,16Feb2021; exact वर्तमान retention days नहीं), [Android backup](https://developer.android.com/identity/data/autobackup), [AI labels](https://support.google.com/googleplay/android-developer/answer/17262077?hl=en)।

स्थानीय प्रमाण `design_sources/release_2026-10-25/current-*`, policy-published.png और Console captures में हैं। Source-audit shared docs पर केवल append; किसी अन्य session की content files/staged work नहीं छुआ।
