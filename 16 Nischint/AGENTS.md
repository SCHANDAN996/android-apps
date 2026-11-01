# AI agents के लिए निर्देश — निश्चिंत (Nischint)

(यह फ़ाइल CLAUDE.md जैसी ही है, ताकि Codex, Gemini, Cursor जैसे टूल भी इसे पढ़ें।)

**सबसे पहले [`START_HERE.md`](START_HERE.md) पढ़ें।** उसमें बिज़नेस, फ़ैसले, स्थिति और आगे का क्रम है। UI/UX और कंटेंट: [`PLAN.md`](PLAN.md)। अगला बड़ा काम (सर्वर, टेक्नीशियन, फ़ोटो): [`docs/TECHNICIAN_AND_SERVER_PLAN.md`](docs/TECHNICIAN_AND_SERVER_PLAN.md)।

## मालिक के साथ काम
- चंदन से हिंदी/हिंग्लिश में, सीधी और आसान भाषा में बात करें।
- उन्हें "ख़ुद खोज लीजिए" न कहें — रिसर्च करके अंतिम जवाब/सलाह दें।
- बड़े फ़ैसले (सर्वर, रेट, नाम) उनसे पूछकर; बाक़ी समझदारी से तय करके बता दें।
- हर बड़े फ़ैसले के बाद `START_HERE.md` का "फ़ैसलों का रिकॉर्ड" और "अभी की स्थिति" अपडेट करें, ताकि अगली चैट में कुछ छूटे नहीं।

## कोड के नियम
- Flutter, Material 3, Dart 3 null-safe। ऐप का सारा टेक्स्ट सरल हिंदी (देवनागरी) में।
- ढाँचा: `packages/nischint_core` (साझा), `apps/customer` (निश्चिंत), `apps/partner` (निश्चिंत पार्टनर)। ऐप `nischint_core` को `package:nischint_core/...` से लेते हैं; साझा चीज़ें core में ही बदलें।
- रंग/दूरी/टेक्स्ट सिर्फ़ `nischint_core/app/theme.dart` (AppColors, AppSpace, AppText) से। साझा विजेट `widgets/common.dart`, `widgets/pickers.dart`।
- रेट और सेवाएँ सिर्फ़ `content/catalog.dart`; नंबर और नाम `content/config.dart`।
- ऐसे API से बचें जो Flutter वर्ज़न के साथ बदलते/deprecated हैं: `withOpacity`, `WillPopScope`, `RadioListTile` groupValue, `DropdownButtonFormField`, ThemeData के component themes, `MaterialStateProperty`। `await` के बाद `mounted` जाँचें।
- `android/` फ़ोल्डर कमिट नहीं होता; CI और लोकल में `flutter create --platforms=android --org com.schandan996 --project-name <nischint|nischint_partner> .` से बनता है, फिर `git checkout -- lib test pubspec.yaml analysis_options.yaml`।
- इस माहौल में अक्सर Flutter SDK नहीं होता — तब कोड ध्यान से लिखें और GitHub Actions (`Nischint Android APKs`) के नतीजे से जाँचें।

## डेटा और गोपनीयता
- रिपॉज़िटरी **public** है। PAN, बैंक, पासवर्ड, API secret key कभी कमिट न करें। Supabase की सिर्फ़ anon key ऐप में; service key कभी नहीं।
- वेंडर पोर्टल की मूल फ़ाइल (जिसमें PAN है) कमिट न करें; `business/Varanasi_vendor_call_tracker.xlsx` में PAN/GST हटाए हुए हैं।
