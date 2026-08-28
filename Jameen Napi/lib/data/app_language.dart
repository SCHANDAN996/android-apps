import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLang {
  hindi,
  english,
  marathi,
  gujarati,
  punjabi,
  bengali,
  telugu,
  tamil,
  kannada,
}

/// फोन की भाषा (ISO code) से ऐप की भाषा — जो हम support करते हैं उसी में।
/// जो भाषा हमारे पास नहीं है, उसके लिए `null`.
AppLang? appLangFromLanguageCode(String languageCode) {
  switch (languageCode.toLowerCase()) {
    case 'hi':
      return AppLang.hindi;
    case 'en':
      return AppLang.english;
    case 'mr':
      return AppLang.marathi;
    case 'gu':
      return AppLang.gujarati;
    case 'pa':
      return AppLang.punjabi;
    case 'bn':
      return AppLang.bengali;
    case 'te':
      return AppLang.telugu;
    case 'ta':
      return AppLang.tamil;
    case 'kn':
      return AppLang.kannada;
  }
  return null;
}

/// ऐप शुरू होने पर कौन-सी भाषा दिखेगी, इसका क्रम:
/// 1. user ने Settings/Onboarding में जो चुना है (सबसे ऊपर),
/// 2. वरना फोन की भाषा (जो फोन में पहली support वाली भाषा मिले),
/// 3. वरना हिंदी।
AppLang resolveStartupLanguage({
  required String? savedCode,
  required List<Locale> deviceLocales,
}) {
  if (savedCode != null) {
    for (final lang in AppLang.values) {
      if (lang.name == savedCode) return lang;
    }
  }
  for (final locale in deviceLocales) {
    final match = appLangFromLanguageCode(locale.languageCode);
    if (match != null) return match;
  }
  return AppLang.hindi;
}

class LanguageNotifier extends ValueNotifier<AppLang> {
  static const String prefKey = 'user_selected_language_code';
  static final LanguageNotifier instance = LanguageNotifier._internal();

  /// हिंदी सिर्फ़ आख़िरी fallback है — असली भाषा `main()` में
  /// [resolveStartupLanguage] से तय होती है (prefs → फोन की भाषा → हिंदी)।
  LanguageNotifier._internal() : super(AppLang.hindi);

  Future<void> setLanguage(AppLang lang) async {
    value = lang;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKey, lang.name);
    } catch (_) {}
  }
}

class AppStrings {
  final AppLang lang;
  AppStrings(this.lang);

  bool get isEn => lang == AppLang.english;

  /// नौ भाषाओं वाली string चुनें। जिस भाषा का अनुवाद न मिले उसके लिए हिंदी।
  ///
  /// स्क्रीनों की सारी नई strings इसी से आती हैं — देखें `tool_strings.dart`.
  /// (`widget_test.dart` जाँचता है कि हर map में नौ की नौ भाषाएँ मौजूद हों,
  /// ताकि कोई भाषा चुपचाप हिंदी पर न गिर जाए।)
  String pick(Map<AppLang, String> options) =>
      options[lang] ?? options[AppLang.hindi] ?? '';

  // Display names for settings menu
  static const Map<AppLang, String> languageNames = {
    AppLang.hindi: 'हिंदी (Hindi)',
    AppLang.english: 'English',
    AppLang.marathi: 'मराठी (Marathi)',
    AppLang.gujarati: 'ગુજરાતી (Gujarati)',
    AppLang.punjabi: 'ਪੰਜਾਬੀ (Punjabi)',
    AppLang.bengali: 'বাংলা (Bengali)',
    AppLang.telugu: 'తెలుగు (Telugu)',
    AppLang.tamil: 'தமிழ் (Tamil)',
    AppLang.kannada: 'ಕನ್ನಡ (Kannada)',
  };

  // App Bar & Subtitle
  String get appTitle {
    switch (lang) {
      case AppLang.english:
        return 'Jameen Napi';
      case AppLang.marathi:
        return 'जमीन नापी (मोजणी)';
      case AppLang.gujarati:
        return 'જમીન માપણી (નાપી)';
      case AppLang.punjabi:
        return 'ਜ਼ਮੀਨ ਨਾਪੀ (ਮਿਣਤੀ)';
      case AppLang.bengali:
        return 'জমি নাপি (পরিমাপ)';
      case AppLang.telugu:
        return 'జమీన్ నాపి (భూమి కొలత)';
      case AppLang.tamil:
        return 'ஜமீன் நாபி (நில அளவீடு)';
      case AppLang.kannada:
        return 'ಜಮೀನ್ ನಾಪಿ (ಅಳತೆ)';
      default:
        return 'जमीन नापी';
    }
  }

  String get appSubtitle {
    switch (lang) {
      case AppLang.english:
        return 'Land Area, 4-Sided Plots, Laggi Scale & Length Converter — 100% Offline';
      case AppLang.marathi:
        return 'बीघा, एकर, गुंठा, ४ बाजूंचे शेत आणि प्लॉट मोजणी — १००% ऑफलाइन.';
      case AppLang.gujarati:
        return 'વીઘા, એકર, ગુણઠા, ૪ બાજુનું ખેતર અને પ્લોટ માપણી — 100% ઑફલાઇન.';
      case AppLang.punjabi:
        return 'ਬੀਘਾ, ਏਕੜ, ਕਨਾਲ, ੪-ਭੁਜਾਵੀਂ ਖੇਤ ਅਤੇ ਪਲਾਟ ਮਿਣਤੀ — 100% ਔਫਲਾਈਨ।';
      case AppLang.bengali:
        return 'বিঘা, একর, কাঠা, ৪-কোণা জমি ও প্লট পরিমাপ — ১০০% অফলাইন।';
      case AppLang.telugu:
        return 'భూమి వైశాల్య, 4 భుజాల పొలం మరియు ప్లాట్ కొలత — 100% ఆఫ్‌లైన్.';
      case AppLang.tamil:
        return 'நிலப்பரப்பு, 4 பக்க நிலம் மற்றும் பிளாட் நீள அளவீடு — 100% ஆஃப்லைன்.';
      case AppLang.kannada:
        return 'ಜಮೀನು ವಿಸ್ತೀರ್ಣ, 4 ಬದಿ ಜಮೀನು ಮತ್ತು ಪ್ಲಾಟ್ ಉದ್ದ ಅಳತೆ — 100% ಆಫ್‌ಲೈನ್.';
      default:
        return 'बीघा, एकड़, कट्ठा, 4-भुजा खेत व प्लाट नापने का कैलकुलेटर — 100% ऑफलाइन।';
    }
  }

  String get settingsTitle {
    switch (lang) {
      case AppLang.english:
        return 'Settings & Language';
      case AppLang.marathi:
        return 'सेटिंग्ज आणि भाषा';
      case AppLang.gujarati:
        return 'સેટિંગ્સ અને ભાષા';
      case AppLang.punjabi:
        return 'ਸੈਟਿੰਗਾਂ ਅਤੇ ਭਾਸ਼ਾ';
      case AppLang.bengali:
        return 'সেটিংস ও ভাষা';
      case AppLang.telugu:
        return 'సెట్టింగ్‌లు & భాష';
      case AppLang.tamil:
        return 'அமைப்புகள் & மொழி';
      case AppLang.kannada:
        return 'ಸೆಟ್ಟಿಂಗ್ಸ್ ಮತ್ತು ಭಾಷೆ';
      default:
        return 'सेटिंग्स एवं भाषा';
    }
  }

  String get selectLanguage {
    switch (lang) {
      case AppLang.english:
        return 'Select App Language';
      case AppLang.marathi:
        return 'ॲपची भाषा निवडा';
      case AppLang.gujarati:
        return 'ઍપની ભાષા પસંદ કરો';
      case AppLang.punjabi:
        return 'ਐਪ ਦੀ ਭਾਸ਼ਾ ਚੁਣੋ';
      case AppLang.bengali:
        return 'অ্যাপের ভাষা নির্বাচন করুন';
      case AppLang.telugu:
        return 'యాప్ భాషను ఎంచుకోండి';
      case AppLang.tamil:
        return 'செயலி மொழியைத் தேர்ந்தெடுக்கவும்';
      case AppLang.kannada:
        return 'ಆಪ್ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';
      default:
        return 'ऐप की भाषा चुनें';
    }
  }

  // Tool 1: Land Area Converter
  String get toolLand {
    switch (lang) {
      case AppLang.english:
        return 'Land Area Converter';
      case AppLang.marathi:
        return 'जमीन क्षेत्र कन्व्हर्टर';
      case AppLang.gujarati:
        return 'જમીન ક્ષેત્રફળ કન્વર્ટર';
      case AppLang.punjabi:
        return 'ਜ਼ਮੀਨ ਖੇਤਰਫਲ ਕਨਵਰਟਰ';
      case AppLang.bengali:
        return 'জমি ক্ষেত্রফল রূপান্তরক';
      case AppLang.telugu:
        return 'భూమి వైశాల్య కన్వర్టర్';
      case AppLang.tamil:
        return 'நிலப்பரப்பு மாற்றி';
      case AppLang.kannada:
        return 'ಜಮೀನು ವಿಸ್ತೀರ್ಣ ಪರಿವರ್ತಕ';
      default:
        return 'भूमि क्षेत्रफल कन्वर्टर';
    }
  }

  String get toolLandSub {
    switch (lang) {
      case AppLang.english:
        return 'Bigha, Katha, Dhur, Guntha, Acre, Hectare, Dismil';
      case AppLang.marathi:
        return 'बीघा, गुंठा, एकर, हेक्टर — राज्यानुसार';
      case AppLang.gujarati:
        return 'વીઘા, ગુણઠા, એકર, હેક્ટર — રાજ્ય મુજબ';
      case AppLang.punjabi:
        return 'ਬੀਘਾ, ਕਨਾਲ, ਮਰਲਾ, ਕਿੱਲਾ, ਏਕੜ — ਰਾਜ ਅਨੁਸਾਰ';
      case AppLang.bengali:
        return 'বিঘা, কাঠা, ছটাক, একর, হেক্টর — রাজ্য অনুযায়ী';
      case AppLang.telugu:
        return 'బీగా, కుంటా, సెంట్, ఎకరం, హెక్టార్';
      case AppLang.tamil:
        return 'சென்ட், கிரவுண்ட், ஏக்ரா, ஹெக்டேர்';
      case AppLang.kannada:
        return 'ಗುಂಟೆ, ಎಕರೆ, ಹೆಕ್ಟೇರ್ — ರಾಜ್ಯದ ಪ್ರಕಾರ';
      default:
        return 'बीघा, कट्ठा, धुर, गज, डिसमिल, एकड़ — 13+ राज्य';
    }
  }

  // Tool 2: 4-Sided Irregular Plot
  String get toolIrregularPlot {
    switch (lang) {
      case AppLang.english:
        return '4-Sided / Irregular Plot';
      case AppLang.marathi:
        return '४-बाजूंचे विषमबाहु शेत';
      case AppLang.gujarati:
        return '૪-બાજુનું અનિયમિત ખેતર';
      case AppLang.punjabi:
        return '੪-ਭੁਜਾਵੀਂ ਅਸਾਵਾਂ ਖੇਤ';
      case AppLang.bengali:
        return '৪-কোণা অসম জমি পরিমাপ';
      case AppLang.telugu:
        return '4 భుజాల అసమాన పొలం';
      case AppLang.tamil:
        return '4 பக்க ஒழுங்கற்ற நிலம்';
      case AppLang.kannada:
        return '೪-ಬದಿಗಳ ಅಸಮ ಜಮೀನು';
      default:
        return '4-भुजा खेत नापी (विषमबाहु)';
    }
  }

  String get toolIrregularPlotSub {
    switch (lang) {
      case AppLang.english:
        return 'Calculate 4 unequal sides with Diagonal (Heron\'s Formula)';
      case AppLang.marathi:
        return '४ असमान बाजू आणि कर्ण (Diagonal) द्वारे १००% अचूक नाप';
      case AppLang.gujarati:
        return '૪ અસમાન બાજુઓ અને વિકર્ણ (Diagonal) થી ચોક્કસ માપ';
      case AppLang.punjabi:
        return '੪ ਅਸਾਵੀਆਂ ਬਾਹੀਆਂ ਅਤੇ ਵਿਕਰਨ ਨਾਲ ਸਹੀ ਨਾਪ';
      case AppLang.bengali:
        return '৪টি অসমান বাহু ও কর্ণের সাহায্যে ১০০% সঠিক মাপ';
      case AppLang.telugu:
        return '4 అసమాన భుజాలు & కర్ణముతో ఖచ్చితమైన వైశాల్యం';
      case AppLang.tamil:
        return '4 சமமற்ற பக்கங்கள் & மூலைவிட்டத்துடன் துல்லியமான பரப்பளவு';
      case AppLang.kannada:
        return '೪ ಅಸಮ ಬದಿಗಳು & ಕರ್ಣದೊಂದಿಗೆ ನಿಖರ ವಿಸ್ತೀರ್ಣ';
      default:
        return '4 असमान भुजाएं + विकर्ण (Heron सूत्र) से 100% सटीक क्षेत्रफल';
    }
  }

  // Tool 3: Plot / Length Converter
  String get toolLength {
    switch (lang) {
      case AppLang.english:
        return 'Plot / Length Converter';
      case AppLang.marathi:
        return 'प्लॉट / लांबी मोजणी';
      case AppLang.gujarati:
        return 'પ્લોટ / લંબાઈ માપણી';
      case AppLang.punjabi:
        return 'ਪਲਾਟ / ਲੰਬਾਈ ਮਿਣਤੀ';
      case AppLang.bengali:
        return 'প্লট / দৈর্ঘ্য পরিমাপ';
      case AppLang.telugu:
        return 'ప్లాట్ / పొడవు కొలత';
      case AppLang.tamil:
        return 'பிளாட் / நீள அளவீடு';
      case AppLang.kannada:
        return 'ಪ್ಲಾಟ್ / ಉದ್ದ ಅಳತೆ';
      default:
        return 'प्लाट / लंबाई नाप कन्वर्टर';
    }
  }

  String get toolLengthSub {
    switch (lang) {
      case AppLang.english:
        return 'Feet, Gaj, Meter, Latha, Haath, Kadi, Jarib (Chain)';
      case AppLang.marathi:
        return 'फूट, वार, मीटर, साखळी, काठी, हात मोजणी';
      case AppLang.gujarati:
        return 'ફૂટ, વાર, મીટર, લાકડી, સાંકળ, હાથ';
      case AppLang.punjabi:
        return 'ਫੁੱਟ, ਗਜ਼, ਮੀਟਰ, ਕਰਮ, ਜਰੀਬ (ਚੇਨ), ਹੱਥ';
      case AppLang.bengali:
        return 'ফুট, গজ, মিটার, লাঠি, চেইন, হাত';
      case AppLang.telugu:
        return 'ఫీట్లు, గజాలు, మీటర్లు, గొలుసు, బెత్త';
      case AppLang.tamil:
        return 'அடி, கஜம், மீட்டர், சங்கிலி (Chain)';
      case AppLang.kannada:
        return 'ಅಡಿ, ಗಜ, ಮೀಟರ್, ಸರಪಳಿ (Chain)';
      default:
        return 'फीट, गज, मीटर, हाथ, लाठी, कड़ी, जरीब नापने का कैलकुलेटर';
    }
  }

  // Tool 4: Laggi Scale Customizer
  String get toolLaggi {
    switch (lang) {
      case AppLang.english:
        return 'Laggi & Scale Customizer';
      case AppLang.marathi:
        return 'काठी / लग्गी पैमाना';
      case AppLang.gujarati:
        return 'લાકડી / લગ્ગી માપ';
      case AppLang.punjabi:
        return 'ਕਰਮ / ਲੱਗੀ ਪੈਮਾਨਾ';
      case AppLang.bengali:
        return 'নল / লাঘি মাপকাঠি';
      case AppLang.telugu:
        return 'లగ్గి / కర్ర కొలత స్కేల్';
      case AppLang.tamil:
        return 'லக்கி அளவு அளவுகோல்';
      case AppLang.kannada:
        return 'ಲಗ್ಗಿ ಅಳತೆ ಪ್ರಮಾಣ';
      default:
        return 'लग्गी पैमाना (धुर / कट्ठा)';
    }
  }

  String get toolLaggiSub {
    switch (lang) {
      case AppLang.english:
        return 'Find 1 Dhur, Katha & Bigha from 4 to 9 Haath Laggi';
      case AppLang.marathi:
        return '४ ते ९ हात काठीनुसार धुर, कट्ठा आणि बीघा चे अचूक गणित';
      case AppLang.gujarati:
        return '૪ થી ૯ હાથ લગ્ગી અનુસાર ધૂર, કઠ્ઠા અને વીઘાનું ગણિત';
      case AppLang.punjabi:
        return '੪ ਤੋਂ ੯ ਹੱਥ ਲੱਗੀ ਅਨੁਸਾਰ ਧੁਰ, ਕੱਠਾ ਅਤੇ ਬੀਘਾ ਦਾ ਹਿਸਾਬ';
      case AppLang.bengali:
        return '৪ থেকে ৯ হাত লাঘি অনুসারে ধুর, কাঠা ও বিঘার হিসেব';
      case AppLang.telugu:
        return '4 నుండి 9 చేతుల లగ్గితో ధూర్, కట్టా మరియు బీగా లెక్కలు';
      case AppLang.tamil:
        return '4 முதல் 9 கை லக்கியுடன் துல்லியமான கணக்கீடு';
      case AppLang.kannada:
        return '೪ ರಿಂದ ೯ ಕೈಗಳ ಲಗ್ಗಿಯೊಂದಿಗೆ ನಿಖರ ಲೆಕ್ಕಾಚಾರ';
      default:
        return '4 से 9 हाथ की लग्गी से 1 धुर, कट्ठा व बीघा का सटीक मान';
    }
  }

  // Tool 5: Land Batwara / Share
  String get toolBatwara {
    switch (lang) {
      case AppLang.english:
        return 'Land Share & Partition (Batwara)';
      case AppLang.marathi:
        return 'जमीन वाटप / हिस्सा (बंटवारा)';
      case AppLang.gujarati:
        return 'જમીન વહેંચણી / હિસ્સો (બંટવારા)';
      case AppLang.punjabi:
        return 'ਜ਼ਮੀਨ ਵੰਡ / ਹਿੱਸਾ (ਬੰਟਵਾਰਾ)';
      case AppLang.bengali:
        return 'জমি ভাগ / অংশ বণ্টন';
      case AppLang.telugu:
        return 'భూమి పంపకం / వాటా';
      case AppLang.tamil:
        return 'நிலப் பகிர்வு / பங்கு';
      case AppLang.kannada:
        return 'ಜಮೀನು ಪಾಲು / ಹಂಚಿಕೆ';
      default:
        return 'जमीन बंटवारा (हिस्सा कैलकुलेटर)';
    }
  }

  String get toolBatwaraSub {
    switch (lang) {
      case AppLang.english:
        return 'Divide land among partners/brothers by equal or custom ratio';
      case AppLang.marathi:
        return 'भाऊ किंवा भागीदारांमध्ये जमिनीचे अचूक वाटप करा';
      case AppLang.gujarati:
        return 'ભાઈઓ અથવા ભાગીદારોમાં જમીનની સમાન કે ગુણોત્તર વહેંચણી';
      case AppLang.punjabi:
        return 'ਭਰਾਵਾਂ ਜਾਂ ਹਿੱਸੇਦਾਰਾਂ ਵਿੱਚ ਜ਼ਮੀਨ ਦੀ ਬਰਾਬਰ ਜਾਂ ਅਨੁਪਾਤਕ ਵੰਡ';
      case AppLang.bengali:
        return 'ভাই বা অংশীদারদের মধ্যে জমির সমান বা অনুপাত বণ্টন';
      case AppLang.telugu:
        return 'సోదరులు లేదా భాగస్వాములలో భూమి సమాన లేదా నిష్పత్తి పంపకం';
      case AppLang.tamil:
        return 'பங்குதாரர்கள் மத்தியில் நிலத்தை சமமாக அல்லது விகிதத்தில் பிரிக்கவும்';
      case AppLang.kannada:
        return 'ಪಾಲುದಾರರಲ್ಲಿ ಜಮೀನನ್ನು ಸಮನಾಗಿ ಅಥವಾ ಅನುಪಾತದಲ್ಲಿ ಹಂಚಿ';
      default:
        return 'भाइयों या हिस्सेदारों में बराबर या अनुपात अनुसार जमीन बांटें';
    }
  }

  // Tool 6: Triangular Plot
  String get toolTriangle {
    switch (lang) {
      case AppLang.english:
        return 'Triangular Plot Area';
      case AppLang.marathi:
        return 'त्रिकोणी शेताचे क्षेत्रफळ';
      case AppLang.gujarati:
        return 'ત્રિકોણીય ખેતરનું ક્ષેત્રફળ';
      case AppLang.punjabi:
        return 'ਤਿਕੋਣੇ ਖੇਤ ਦਾ ਖੇਤਰਫਲ';
      case AppLang.bengali:
        return 'ত্রিকোণাকার জমি পরিমাপ';
      case AppLang.telugu:
        return 'త్రికోణాకార పొలం వైశాల్యం';
      case AppLang.tamil:
        return 'முக்கோண நிலப்பரப்பு';
      case AppLang.kannada:
        return 'ತ್ರಿಕೋನ ಜಮೀನು ವಿಸ್ತೀರ್ಣ';
      default:
        return 'त्रिकोणीय खेत नापी (3 भुजाएं)';
    }
  }

  String get toolTriangleSub {
    switch (lang) {
      case AppLang.english:
        return 'Calculate 3 sides (Heron) or Base × Height';
      case AppLang.marathi:
        return '३ बाजू किंवा पाया × उंची द्वारे क्षेत्रफळ';
      case AppLang.gujarati:
        return '૩ બાજુઓ અથવા પાયો × ઊંચાઈ દ્વારા ક્ષેત્રફળ';
      case AppLang.punjabi:
        return '੩ ਬਾਹੀਆਂ ਜਾਂ ਆਧਾਰ × ਉਚਾਈ ਨਾਲ ਖੇਤਰਫਲ';
      case AppLang.bengali:
        return '৩টি বাহু অথবা ভূমি × উচ্চতা দিয়ে পরিমাপ';
      case AppLang.telugu:
        return '3 భుజాలు లేదా భూమి × ఎత్తుతో వైశాల్యం';
      case AppLang.tamil:
        return '3 பக்கங்கள் அல்லது அடிப்பகுதி × உயரம் மூலம் பரப்பளவு';
      case AppLang.kannada:
        return '೩ ಬದಿಗಳು ಅಥವಾ ಪಾದ × ಎತ್ತರದಿಂದ ವಿಸ್ತೀರ್ಣ';
      default:
        return '3 भुजाएं (हेरॉन सूत्र) या आधार × ऊंचाई से क्षेत्रफल';
    }
  }

  // ───────── Converter / Length screen — नौ भाषाएँ ─────────
  //
  // ये पहले `isEn ? English : हिंदी` थे — यानी तमिल/बांग्ला/तेलुगु चुनने पर भी
  // इन screens का अंदर पूरा हिंदी में दिखता था। अब हर string नौ भाषाओं में है;
  // `widget_test.dart` का coverage test कोई भाषा छूटने पर fail होगा।

  String get directAreaMode => pick(const {
        AppLang.hindi: 'डायरेक्ट क्षेत्रफल',
        AppLang.english: 'Direct Area',
        AppLang.marathi: 'थेट क्षेत्रफळ',
        AppLang.gujarati: 'સીધું ક્ષેત્રફળ',
        AppLang.punjabi: 'ਸਿੱਧਾ ਖੇਤਰਫਲ',
        AppLang.bengali: 'সরাসরি ক্ষেত্রফল',
        AppLang.telugu: 'నేరుగా వైశాల్యం',
        AppLang.tamil: 'நேரடி பரப்பளவு',
        AppLang.kannada: 'ನೇರ ವಿಸ್ತೀರ್ಣ',
      });

  String get lengthWidthMode => pick(const {
        AppLang.hindi: 'लंबाई × चौड़ाई',
        AppLang.english: 'Length × Width',
        AppLang.marathi: 'लांबी × रुंदी',
        AppLang.gujarati: 'લંબાઈ × પહોળાઈ',
        AppLang.punjabi: 'ਲੰਬਾਈ × ਚੌੜਾਈ',
        AppLang.bengali: 'দৈর্ঘ্য × প্রস্থ',
        AppLang.telugu: 'పొడవు × వెడల్పు',
        AppLang.tamil: 'நீளம் × அகலம்',
        AppLang.kannada: 'ಉದ್ದ × ಅಗಲ',
      });

  String get lengthLabel => pick(const {
        AppLang.hindi: 'लंबाई',
        AppLang.english: 'Length',
        AppLang.marathi: 'लांबी',
        AppLang.gujarati: 'લંબાઈ',
        AppLang.punjabi: 'ਲੰਬਾਈ',
        AppLang.bengali: 'দৈর্ঘ্য',
        AppLang.telugu: 'పొడవు',
        AppLang.tamil: 'நீளம்',
        AppLang.kannada: 'ಉದ್ದ',
      });

  String get widthLabel => pick(const {
        AppLang.hindi: 'चौड़ाई',
        AppLang.english: 'Width',
        AppLang.marathi: 'रुंदी',
        AppLang.gujarati: 'પહોળાઈ',
        AppLang.punjabi: 'ਚੌੜਾਈ',
        AppLang.bengali: 'প্রস্থ',
        AppLang.telugu: 'వెడల్పు',
        AppLang.tamil: 'அகலம்',
        AppLang.kannada: 'ಅಗಲ',
      });

  String get totalCalculatedArea => pick(const {
        AppLang.hindi: 'कुल नापा गया क्षेत्रफल',
        AppLang.english: 'Calculated Total Area',
        AppLang.marathi: 'एकूण मोजलेले क्षेत्रफळ',
        AppLang.gujarati: 'કુલ માપેલું ક્ષેત્રફળ',
        AppLang.punjabi: 'ਕੁੱਲ ਮਿਣਿਆ ਖੇਤਰਫਲ',
        AppLang.bengali: 'মোট মাপা ক্ষেত্রফল',
        AppLang.telugu: 'మొత్తం కొలిచిన వైశాల్యం',
        AppLang.tamil: 'மொத்த அளந்த பரப்பளவு',
        AppLang.kannada: 'ಒಟ್ಟು ಅಳೆದ ವಿಸ್ತೀರ್ಣ',
      });

  String get selectState => pick(const {
        AppLang.hindi: 'राज्य / क्षेत्र चुनें',
        AppLang.english: 'Select State / Region',
        AppLang.marathi: 'राज्य / प्रदेश निवडा',
        AppLang.gujarati: 'રાજ્ય / પ્રદેશ પસંદ કરો',
        AppLang.punjabi: 'ਰਾਜ / ਖੇਤਰ ਚੁਣੋ',
        AppLang.bengali: 'রাজ্য / অঞ্চল নির্বাচন করুন',
        AppLang.telugu: 'రాష్ట్రం / ప్రాంతం ఎంచుకోండి',
        AppLang.tamil: 'மாநிலம் / பகுதியைத் தேர்ந்தெடுக்கவும்',
        AppLang.kannada: 'ರಾಜ್ಯ / ಪ್ರದೇಶ ಆಯ್ಕೆಮಾಡಿ',
      });

  String get enterArea => pick(const {
        AppLang.hindi: 'क्षेत्रफल मान दर्ज करें',
        AppLang.english: 'Enter Area Value',
        AppLang.marathi: 'क्षेत्रफळ मूल्य टाका',
        AppLang.gujarati: 'ક્ષેત્રફળ મૂલ્ય દાખલ કરો',
        AppLang.punjabi: 'ਖੇਤਰਫਲ ਮੁੱਲ ਭਰੋ',
        AppLang.bengali: 'ক্ষেত্রফল মান লিখুন',
        AppLang.telugu: 'వైశాల్య విలువ నమోదు చేయండి',
        AppLang.tamil: 'பரப்பளவு மதிப்பை உள்ளிடவும்',
        AppLang.kannada: 'ವಿಸ್ತೀರ್ಣ ಮೌಲ್ಯ ನಮೂದಿಸಿ',
      });

  String get selectUnit => pick(const {
        AppLang.hindi: 'इकाई चुनें',
        AppLang.english: 'Select Unit',
        AppLang.marathi: 'एकक निवडा',
        AppLang.gujarati: 'એકમ પસંદ કરો',
        AppLang.punjabi: 'ਇਕਾਈ ਚੁਣੋ',
        AppLang.bengali: 'একক নির্বাচন করুন',
        AppLang.telugu: 'యూనిట్ ఎంచుకోండి',
        AppLang.tamil: 'அலகைத் தேர்ந்தெடுக்கவும்',
        AppLang.kannada: 'ಘಟಕ ಆಯ್ಕೆಮಾಡಿ',
      });

  String get privacyPolicy => pick(const {
        AppLang.hindi: 'प्राइवेसी पॉलिसी',
        AppLang.english: 'Privacy Policy',
        AppLang.marathi: 'गोपनीयता धोरण',
        AppLang.gujarati: 'ગોપનીયતા નીતિ',
        AppLang.punjabi: 'ਪਰਾਈਵੇਸੀ ਪਾਲਿਸੀ',
        AppLang.bengali: 'গোপনীয়তা নীতি',
        AppLang.telugu: 'గోప్యతా విధానం',
        AppLang.tamil: 'தனியுரிமைக் கொள்கை',
        AppLang.kannada: 'ಗೌಪ್ಯತಾ ನೀತಿ',
      });

  String get aboutApp => pick(const {
        AppLang.hindi: 'ऐप के बारे में',
        AppLang.english: 'About App',
        AppLang.marathi: 'ॲपविषयी',
        AppLang.gujarati: 'ઍપ વિશે',
        AppLang.punjabi: 'ਐਪ ਬਾਰੇ',
        AppLang.bengali: 'অ্যাপ সম্পর্কে',
        AppLang.telugu: 'యాప్ గురించి',
        AppLang.tamil: 'செயலி பற்றி',
        AppLang.kannada: 'ಆಪ್ ಕುರಿತು',
      });

  String get ok => pick(const {
        AppLang.hindi: 'ठीक है',
        AppLang.english: 'OK',
        AppLang.marathi: 'ठीक आहे',
        AppLang.gujarati: 'બરાબર',
        AppLang.punjabi: 'ਠੀਕ ਹੈ',
        AppLang.bengali: 'ঠিক আছে',
        AppLang.telugu: 'సరే',
        AppLang.tamil: 'சரி',
        AppLang.kannada: 'ಸರಿ',
      });

  String get copy => pick(const {
        AppLang.hindi: 'कॉपी करें',
        AppLang.english: 'Copy',
        AppLang.marathi: 'कॉपी करा',
        AppLang.gujarati: 'કૉપિ કરો',
        AppLang.punjabi: 'ਕਾਪੀ ਕਰੋ',
        AppLang.bengali: 'কপি করুন',
        AppLang.telugu: 'కాపీ చేయండి',
        AppLang.tamil: 'நகலெடு',
        AppLang.kannada: 'ನಕಲಿಸಿ',
      });

  String get share => pick(const {
        AppLang.hindi: 'शेयर करें',
        AppLang.english: 'Share',
        AppLang.marathi: 'शेअर करा',
        AppLang.gujarati: 'શેર કરો',
        AppLang.punjabi: 'ਸਾਂਝਾ ਕਰੋ',
        AppLang.bengali: 'শেয়ার করুন',
        AppLang.telugu: 'షేర్ చేయండి',
        AppLang.tamil: 'பகிர்',
        AppLang.kannada: 'ಹಂಚಿಕೊಳ್ಳಿ',
      });

  String get copied => pick(const {
        AppLang.hindi: 'क्लिपबोर्ड में कॉपी हो गया!',
        AppLang.english: 'Copied to clipboard!',
        AppLang.marathi: 'क्लिपबोर्डवर कॉपी झाले!',
        AppLang.gujarati: 'ક્લિપબોર્ડમાં કૉપિ થયું!',
        AppLang.punjabi: 'ਕਲਿੱਪਬੋਰਡ ਵਿੱਚ ਕਾਪੀ ਹੋ ਗਿਆ!',
        AppLang.bengali: 'ক্লিপবোর্ডে কপি হয়েছে!',
        AppLang.telugu: 'క్లిప్‌బోర్డ్‌కు కాపీ అయ్యింది!',
        AppLang.tamil: 'கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது!',
        AppLang.kannada: 'ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ!',
      });

  String get clear => pick(const {
        AppLang.hindi: 'साफ करें',
        AppLang.english: 'Clear',
        AppLang.marathi: 'साफ करा',
        AppLang.gujarati: 'સાફ કરો',
        AppLang.punjabi: 'ਸਾਫ਼ ਕਰੋ',
        AppLang.bengali: 'মুছুন',
        AppLang.telugu: 'తొలగించండి',
        AppLang.tamil: 'அழி',
        AppLang.kannada: 'ಅಳಿಸಿ',
      });

  String get calculate => pick(const {
        AppLang.hindi: 'हिसाब निकालें',
        AppLang.english: 'Calculate',
        AppLang.marathi: 'हिशोब काढा',
        AppLang.gujarati: 'ગણતરી કરો',
        AppLang.punjabi: 'ਹਿਸਾਬ ਕੱਢੋ',
        AppLang.bengali: 'হিসাব করুন',
        AppLang.telugu: 'లెక్కించండి',
        AppLang.tamil: 'கணக்கிடு',
        AppLang.kannada: 'ಲೆಕ್ಕ ಹಾಕಿ',
      });

  String get shareResultTitle => pick(const {
        AppLang.hindi: 'भूमि क्षेत्रफल की माप',
        AppLang.english: 'Land Area Conversion',
        AppLang.marathi: 'जमीन क्षेत्रफळाचे माप',
        AppLang.gujarati: 'જમીન ક્ષેત્રફળનું માપ',
        AppLang.punjabi: 'ਜ਼ਮੀਨ ਖੇਤਰਫਲ ਦੀ ਮਿਣਤੀ',
        AppLang.bengali: 'জমির ক্ষেত্রফলের পরিমাপ',
        AppLang.telugu: 'భూమి వైశాల్య కొలత',
        AppLang.tamil: 'நிலப்பரப்பு அளவீடு',
        AppLang.kannada: 'ಜಮೀನು ವಿಸ್ತೀರ್ಣ ಅಳತೆ',
      });

  String get sqFtLabel => pick(const {
        AppLang.hindi: 'वर्ग फीट',
        AppLang.english: 'sq ft',
        AppLang.marathi: 'चौरस फूट',
        AppLang.gujarati: 'ચોરસ ફૂટ',
        AppLang.punjabi: 'ਵਰਗ ਫੁੱਟ',
        AppLang.bengali: 'বর্গ ফুট',
        AppLang.telugu: 'చదరపు అడుగులు',
        AppLang.tamil: 'சதுர அடி',
        AppLang.kannada: 'ಚದರ ಅಡಿ',
      });

  String get lengthEnterHeading => pick(const {
        AppLang.hindi: 'नाप की लंबाई दर्ज करें',
        AppLang.english: 'Enter the length to measure',
        AppLang.marathi: 'मोजायची लांबी टाका',
        AppLang.gujarati: 'માપવાની લંબાઈ દાખલ કરો',
        AppLang.punjabi: 'ਮਿਣਨ ਵਾਲੀ ਲੰਬਾਈ ਭਰੋ',
        AppLang.bengali: 'মাপার দৈর্ঘ্য লিখুন',
        AppLang.telugu: 'కొలవాల్సిన పొడవు నమోదు చేయండి',
        AppLang.tamil: 'அளக்க வேண்டிய நீளத்தை உள்ளிடவும்',
        AppLang.kannada: 'ಅಳೆಯಬೇಕಾದ ಉದ್ದ ನಮೂದಿಸಿ',
      });

  String get lengthInputLabel => pick(const {
        AppLang.hindi: 'लंबाई दर्ज करें',
        AppLang.english: 'Enter length',
        AppLang.marathi: 'लांबी टाका',
        AppLang.gujarati: 'લંબાઈ દાખલ કરો',
        AppLang.punjabi: 'ਲੰਬਾਈ ਭਰੋ',
        AppLang.bengali: 'দৈর্ঘ্য লিখুন',
        AppLang.telugu: 'పొడవు నమోదు చేయండి',
        AppLang.tamil: 'நீளத்தை உள்ளிடவும்',
        AppLang.kannada: 'ಉದ್ದ ನಮೂದಿಸಿ',
      });

  String get lengthOtherUnits => pick(const {
        AppLang.hindi: 'अन्य सभी इकाइयों में मान:',
        AppLang.english: 'Value in all other units:',
        AppLang.marathi: 'इतर सर्व एककांमधील मूल्य:',
        AppLang.gujarati: 'અન્ય તમામ એકમોમાં મૂલ્ય:',
        AppLang.punjabi: 'ਬਾਕੀ ਸਾਰੀਆਂ ਇਕਾਈਆਂ ਵਿੱਚ ਮੁੱਲ:',
        AppLang.bengali: 'অন্য সব এককে মান:',
        AppLang.telugu: 'ఇతర అన్ని యూనిట్లలో విలువ:',
        AppLang.tamil: 'மற்ற எல்லா அலகுகளிலும் மதிப்பு:',
        AppLang.kannada: 'ಇತರ ಎಲ್ಲಾ ಘಟಕಗಳಲ್ಲಿ ಮೌಲ್ಯ:',
      });

  String get lengthInfoTitle => pick(const {
        AppLang.hindi: 'नापाई की मुख्य जानकारी:',
        AppLang.english: 'Key measurement facts:',
        AppLang.marathi: 'मोजणीची मुख्य माहिती:',
        AppLang.gujarati: 'માપણીની મુખ્ય માહિતી:',
        AppLang.punjabi: 'ਮਿਣਤੀ ਦੀ ਮੁੱਖ ਜਾਣਕਾਰੀ:',
        AppLang.bengali: 'পরিমাপের প্রধান তথ্য:',
        AppLang.telugu: 'కొలత ముఖ్య సమాచారం:',
        AppLang.tamil: 'அளவீட்டின் முக்கியத் தகவல்:',
        AppLang.kannada: 'ಅಳತೆಯ ಮುಖ್ಯ ಮಾಹಿತಿ:',
      });

  /// नापाई की बुनियादी जानकारी। इकाइयों के नाम (हाथ, गज, जरीब) राजस्व रिकॉर्ड
  /// के अपने नाम हैं, इसलिए हर भाषा में उसी भाषा की लिपि में लिखे हैं।
  List<String> get lengthInfoLines {
    final haath = pick(const {
      AppLang.hindi: 'हाथ',
      AppLang.english: 'Haath (Cubit)',
      AppLang.marathi: 'हात',
      AppLang.gujarati: 'હાથ',
      AppLang.punjabi: 'ਹੱਥ',
      AppLang.bengali: 'হাত',
      AppLang.telugu: 'హాత్',
      AppLang.tamil: 'ஹாத் (முழம்)',
      AppLang.kannada: 'ಹಾತ್',
    });
    final gaj = pick(const {
      AppLang.hindi: 'गज',
      AppLang.english: 'Gaj (Yard)',
      AppLang.marathi: 'वार',
      AppLang.gujarati: 'વાર',
      AppLang.punjabi: 'ਗਜ਼',
      AppLang.bengali: 'গজ',
      AppLang.telugu: 'గజం',
      AppLang.tamil: 'கஜம்',
      AppLang.kannada: 'ಗಜ',
    });
    final meter = pick(const {
      AppLang.hindi: 'मीटर',
      AppLang.english: 'Meter',
      AppLang.marathi: 'मीटर',
      AppLang.gujarati: 'મીટર',
      AppLang.punjabi: 'ਮੀਟਰ',
      AppLang.bengali: 'মিটার',
      AppLang.telugu: 'మీటర్',
      AppLang.tamil: 'மீட்டர்',
      AppLang.kannada: 'ಮೀಟರ್',
    });
    final latha = pick(const {
      AppLang.hindi: 'लाठी (लट्ठा)',
      AppLang.english: 'Latha (Laggi)',
      AppLang.marathi: 'काठी',
      AppLang.gujarati: 'લાકડી',
      AppLang.punjabi: 'ਕਰਮ',
      AppLang.bengali: 'লাঠি',
      AppLang.telugu: 'లగ్గి',
      AppLang.tamil: 'லக்கி',
      AppLang.kannada: 'ಲಗ್ಗಿ',
    });
    final jarib = pick(const {
      AppLang.hindi: 'जरीब',
      AppLang.english: 'Jarib (Chain)',
      AppLang.marathi: 'साखळी',
      AppLang.gujarati: 'સાંકળ',
      AppLang.punjabi: 'ਜਰੀਬ',
      AppLang.bengali: 'চেইন',
      AppLang.telugu: 'గొలుసు',
      AppLang.tamil: 'சங்கிலி',
      AppLang.kannada: 'ಸರಪಳಿ',
    });
    final kadi = pick(const {
      AppLang.hindi: 'कड़ी',
      AppLang.english: 'Kadi (Links)',
      AppLang.marathi: 'कडी',
      AppLang.gujarati: 'કડી',
      AppLang.punjabi: 'ਕੜੀ',
      AppLang.bengali: 'কড়ি',
      AppLang.telugu: 'కడీ',
      AppLang.tamil: 'கடி',
      AppLang.kannada: 'ಕಡಿ',
    });
    final feet = pick(const {
      AppLang.hindi: 'फीट',
      AppLang.english: 'feet',
      AppLang.marathi: 'फूट',
      AppLang.gujarati: 'ફૂટ',
      AppLang.punjabi: 'ਫੁੱਟ',
      AppLang.bengali: 'ফুট',
      AppLang.telugu: 'అడుగులు',
      AppLang.tamil: 'அடி',
      AppLang.kannada: 'ಅಡಿ',
    });
    final inch = pick(const {
      AppLang.hindi: 'इंच',
      AppLang.english: 'inches',
      AppLang.marathi: 'इंच',
      AppLang.gujarati: 'ઇંચ',
      AppLang.punjabi: 'ਇੰਚ',
      AppLang.bengali: 'ইঞ্চি',
      AppLang.telugu: 'అంగుళాలు',
      AppLang.tamil: 'அங்குலம்',
      AppLang.kannada: 'ಇಂಚು',
    });

    return [
      '• 1 $haath = 1.5 $feet = 18 $inch',
      '• 1 $gaj = 3 $feet = 36 $inch',
      '• 1 $meter = 3.28 $feet',
      '• 1 $latha = 8.25 $feet (5.5 $haath)',
      '• 1 $jarib = 100 $kadi = 66 $feet (22 $gaj)',
    ];
  }

  // ─────────────────── होम स्क्रीन के badge ───────────────────

  String get badgeStates => pick(const {
        AppLang.hindi: '13+ राज्य',
        AppLang.english: '13+ states',
        AppLang.marathi: '१३+ राज्ये',
        AppLang.gujarati: '૧૩+ રાજ્યો',
        AppLang.punjabi: '੧੩+ ਰਾਜ',
        AppLang.bengali: '১৩+ রাজ্য',
        AppLang.telugu: '13+ రాష్ట్రాలు',
        AppLang.tamil: '13+ மாநிலம்',
        AppLang.kannada: '13+ ರಾಜ್ಯ',
      });

  String get badgeExact => pick(const {
        AppLang.hindi: '100% सटीक',
        AppLang.english: '100% exact',
        AppLang.marathi: '१००% अचूक',
        AppLang.gujarati: '૧૦૦% ચોક્કસ',
        AppLang.punjabi: '੧੦੦% ਸਹੀ',
        AppLang.bengali: '১০০% সঠিক',
        AppLang.telugu: '100% కచ్చితం',
        AppLang.tamil: '100% துல்லியம்',
        AppLang.kannada: '100% ನಿಖರ',
      });

  String get badgeChain => pick(const {
        AppLang.hindi: 'जरीब / लाठी / कड़ी',
        AppLang.english: 'Jarib / Latha / Kadi',
        AppLang.marathi: 'साखळी / काठी',
        AppLang.gujarati: 'સાંકળ / લાકડી',
        AppLang.punjabi: 'ਜਰੀਬ / ਕਰਮ / ਕੜੀ',
        AppLang.bengali: 'চেইন / লাঠি',
        AppLang.telugu: 'గొలుసు / లగ్గి',
        AppLang.tamil: 'சங்கிலி / லக்கி',
        AppLang.kannada: 'ಸರಪಳಿ / ಲಗ್ಗಿ',
      });

  String get badgeDesiScale => pick(const {
        AppLang.hindi: 'देसी पैमाना',
        AppLang.english: 'Local scale',
        AppLang.marathi: 'देशी मापदंड',
        AppLang.gujarati: 'દેશી માપ',
        AppLang.punjabi: 'ਦੇਸੀ ਪੈਮਾਨਾ',
        AppLang.bengali: 'দেশি মাপ',
        AppLang.telugu: 'దేశీ కొలత',
        AppLang.tamil: 'நாட்டு அளவு',
        AppLang.kannada: 'ದೇಸಿ ಅಳತೆ',
      });

  String get badgePartition => pick(const {
        AppLang.hindi: 'हिस्सा बंटवारा',
        AppLang.english: 'Share split',
        AppLang.marathi: 'हिस्सा वाटप',
        AppLang.gujarati: 'હિસ્સા વહેંચણી',
        AppLang.punjabi: 'ਹਿੱਸਾ ਵੰਡ',
        AppLang.bengali: 'অংশ বণ্টন',
        AppLang.telugu: 'వాటా పంపకం',
        AppLang.tamil: 'பங்கு பிரிவு',
        AppLang.kannada: 'ಪಾಲು ಹಂಚಿಕೆ',
      });

  String get badgeThreeSides => pick(const {
        AppLang.hindi: '3 भुजाएं',
        AppLang.english: '3 sides',
        AppLang.marathi: '३ बाजू',
        AppLang.gujarati: '૩ બાજુ',
        AppLang.punjabi: '੩ ਬਾਹੀਆਂ',
        AppLang.bengali: '৩ বাহু',
        AppLang.telugu: '3 భుజాలు',
        AppLang.tamil: '3 பக்கம்',
        AppLang.kannada: '೩ ಬದಿ',
      });

  // ─────────────── खेत के नक्शे (canvas) के labels ───────────────

  String get dirNorth => pick(const {
        AppLang.hindi: 'उत्तर',
        AppLang.english: 'North',
        AppLang.marathi: 'उत्तर',
        AppLang.gujarati: 'ઉત્તર',
        AppLang.punjabi: 'ਉੱਤਰ',
        AppLang.bengali: 'উত্তর',
        AppLang.telugu: 'ఉత్తరం',
        AppLang.tamil: 'வடக்கு',
        AppLang.kannada: 'ಉತ್ತರ',
      });

  String get dirEast => pick(const {
        AppLang.hindi: 'पूर्व',
        AppLang.english: 'East',
        AppLang.marathi: 'पूर्व',
        AppLang.gujarati: 'પૂર્વ',
        AppLang.punjabi: 'ਪੂਰਬ',
        AppLang.bengali: 'পূর্ব',
        AppLang.telugu: 'తూర్పు',
        AppLang.tamil: 'கிழக்கு',
        AppLang.kannada: 'ಪೂರ್ವ',
      });

  String get dirSouth => pick(const {
        AppLang.hindi: 'दक्षिण',
        AppLang.english: 'South',
        AppLang.marathi: 'दक्षिण',
        AppLang.gujarati: 'દક્ષિણ',
        AppLang.punjabi: 'ਦੱਖਣ',
        AppLang.bengali: 'দক্ষিণ',
        AppLang.telugu: 'దక్షిణం',
        AppLang.tamil: 'தெற்கு',
        AppLang.kannada: 'ದಕ್ಷಿಣ',
      });

  String get dirWest => pick(const {
        AppLang.hindi: 'पश्चिम',
        AppLang.english: 'West',
        AppLang.marathi: 'पश्चिम',
        AppLang.gujarati: 'પશ્ચિમ',
        AppLang.punjabi: 'ਪੱਛਮ',
        AppLang.bengali: 'পশ্চিম',
        AppLang.telugu: 'పడమర',
        AppLang.tamil: 'மேற்கு',
        AppLang.kannada: 'ಪಶ್ಚಿಮ',
      });

  String get diagonalShort => pick(const {
        AppLang.hindi: 'विकर्ण',
        AppLang.english: 'Diagonal',
        AppLang.marathi: 'कर्ण',
        AppLang.gujarati: 'વિકર્ણ',
        AppLang.punjabi: 'ਵਿਕਰਨ',
        AppLang.bengali: 'কর্ণ',
        AppLang.telugu: 'కర్ణం',
        AppLang.tamil: 'மூலைவிட்டம்',
        AppLang.kannada: 'ಕರ್ಣ',
      });

  String get baseShort => pick(const {
        AppLang.hindi: 'आधार',
        AppLang.english: 'Base',
        AppLang.marathi: 'पाया',
        AppLang.gujarati: 'પાયો',
        AppLang.punjabi: 'ਆਧਾਰ',
        AppLang.bengali: 'ভূমি',
        AppLang.telugu: 'భూమి',
        AppLang.tamil: 'அடிப்பகுதி',
        AppLang.kannada: 'ಪಾದ',
      });

  // ──────────────── राज्य / क्षेत्र के नाम ────────────────
  //
  // राज्यों के अपने नाम हर भाषा की लिपि में। prefs में और `stateUnits` की key
  // के तौर पर हमेशा हिंदी वाला नाम ही रहता है — यह सिर्फ़ दिखाने के लिए है।

  String stateDisplayName(String stateKey) {
    final table = _stateNames[stateKey];
    if (table == null) return stateKey;
    return table[lang] ?? stateKey;
  }

  static const Map<String, Map<AppLang, String>> _stateNames = {
    'पूरे भारत की मानक इकाइयाँ': {
      AppLang.hindi: 'पूरे भारत की मानक इकाइयाँ',
      AppLang.english: 'Standard units (all India)',
      AppLang.marathi: 'संपूर्ण भारताची प्रमाणित एकके',
      AppLang.gujarati: 'સમગ્ર ભારતનાં પ્રમાણભૂત એકમો',
      AppLang.punjabi: 'ਪੂਰੇ ਭਾਰਤ ਦੀਆਂ ਮਿਆਰੀ ਇਕਾਈਆਂ',
      AppLang.bengali: 'সমগ্র ভারতের প্রমিত একক',
      AppLang.telugu: 'భారతదేశ ప్రామాణిక యూనిట్లు',
      AppLang.tamil: 'இந்தியா முழுவதற்கும் நிலையான அலகுகள்',
      AppLang.kannada: 'ಭಾರತದಾದ್ಯಂತ ಪ್ರಮಾಣಿತ ಘಟಕಗಳು',
    },
    'उत्तर प्रदेश': {
      AppLang.hindi: 'उत्तर प्रदेश',
      AppLang.english: 'Uttar Pradesh',
      AppLang.marathi: 'उत्तर प्रदेश',
      AppLang.gujarati: 'ઉત્તર પ્રદેશ',
      AppLang.punjabi: 'ਉੱਤਰ ਪ੍ਰਦੇਸ਼',
      AppLang.bengali: 'উত্তর প্রদেশ',
      AppLang.telugu: 'ఉత్తర ప్రదేశ్',
      AppLang.tamil: 'உத்தரப் பிரதேசம்',
      AppLang.kannada: 'ಉತ್ತರ ಪ್ರದೇಶ',
    },
    'बिहार / झारखंड': {
      AppLang.hindi: 'बिहार / झारखंड',
      AppLang.english: 'Bihar / Jharkhand',
      AppLang.marathi: 'बिहार / झारखंड',
      AppLang.gujarati: 'બિહાર / ઝારખંડ',
      AppLang.punjabi: 'ਬਿਹਾਰ / ਝਾਰਖੰਡ',
      AppLang.bengali: 'বিহার / ঝাড়খণ্ড',
      AppLang.telugu: 'బీహార్ / ఝార్ఖండ్',
      AppLang.tamil: 'பீகார் / ஜார்க்கண்ட்',
      AppLang.kannada: 'ಬಿಹಾರ / ಜಾರ್ಖಂಡ್',
    },
    'राजस्थान': {
      AppLang.hindi: 'राजस्थान',
      AppLang.english: 'Rajasthan',
      AppLang.marathi: 'राजस्थान',
      AppLang.gujarati: 'રાજસ્થાન',
      AppLang.punjabi: 'ਰਾਜਸਥਾਨ',
      AppLang.bengali: 'রাজস্থান',
      AppLang.telugu: 'రాజస్థాన్',
      AppLang.tamil: 'ராஜஸ்தான்',
      AppLang.kannada: 'ರಾಜಸ್ಥಾನ',
    },
    'पंजाब / हरियाणा': {
      AppLang.hindi: 'पंजाब / हरियाणा',
      AppLang.english: 'Punjab / Haryana',
      AppLang.marathi: 'पंजाब / हरियाणा',
      AppLang.gujarati: 'પંજાબ / હરિયાણા',
      AppLang.punjabi: 'ਪੰਜਾਬ / ਹਰਿਆਣਾ',
      AppLang.bengali: 'পাঞ্জাব / হরিয়ানা',
      AppLang.telugu: 'పంజాబ్ / హర్యానా',
      AppLang.tamil: 'பஞ்சாப் / ஹரியானா',
      AppLang.kannada: 'ಪಂಜಾಬ್ / ಹರಿಯಾಣ',
    },
    'गुजरात': {
      AppLang.hindi: 'गुजरात',
      AppLang.english: 'Gujarat',
      AppLang.marathi: 'गुजरात',
      AppLang.gujarati: 'ગુજરાત',
      AppLang.punjabi: 'ਗੁਜਰਾਤ',
      AppLang.bengali: 'গুজরাট',
      AppLang.telugu: 'గుజరాత్',
      AppLang.tamil: 'குஜராத்',
      AppLang.kannada: 'ಗುಜರಾತ್',
    },
    'महाराष्ट्र': {
      AppLang.hindi: 'महाराष्ट्र',
      AppLang.english: 'Maharashtra',
      AppLang.marathi: 'महाराष्ट्र',
      AppLang.gujarati: 'મહારાષ્ટ્ર',
      AppLang.punjabi: 'ਮਹਾਰਾਸ਼ਟਰ',
      AppLang.bengali: 'মহারাষ্ট্র',
      AppLang.telugu: 'మహారాష్ట్ర',
      AppLang.tamil: 'மகாராஷ்டிரா',
      AppLang.kannada: 'ಮಹಾರಾಷ್ಟ್ರ',
    },
    'कर्नाटक': {
      AppLang.hindi: 'कर्नाटक',
      AppLang.english: 'Karnataka',
      AppLang.marathi: 'कर्नाटक',
      AppLang.gujarati: 'કર્ણાટક',
      AppLang.punjabi: 'ਕਰਨਾਟਕ',
      AppLang.bengali: 'কর্ণাটক',
      AppLang.telugu: 'కర్ణాటక',
      AppLang.tamil: 'கர்நாடகா',
      AppLang.kannada: 'ಕರ್ನಾಟಕ',
    },
    'पश्चिम बंगाल': {
      AppLang.hindi: 'पश्चिम बंगाल',
      AppLang.english: 'West Bengal',
      AppLang.marathi: 'पश्चिम बंगाल',
      AppLang.gujarati: 'પશ્ચિમ બંગાળ',
      AppLang.punjabi: 'ਪੱਛਮੀ ਬੰਗਾਲ',
      AppLang.bengali: 'পশ্চিমবঙ্গ',
      AppLang.telugu: 'పశ్చిమ బెంగాల్',
      AppLang.tamil: 'மேற்கு வங்கம்',
      AppLang.kannada: 'ಪಶ್ಚಿಮ ಬಂಗಾಳ',
    },
    'तमिलनाडु / पुडुचेरी': {
      AppLang.hindi: 'तमिलनाडु / पुडुचेरी',
      AppLang.english: 'Tamil Nadu / Puducherry',
      AppLang.marathi: 'तमिळनाडू / पुद्दुचेरी',
      AppLang.gujarati: 'તમિલનાડુ / પુડુચેરી',
      AppLang.punjabi: 'ਤਾਮਿਲਨਾਡੂ / ਪੁਡੂਚੇਰੀ',
      AppLang.bengali: 'তামিলনাড়ু / পুদুচেরি',
      AppLang.telugu: 'తమిళనాడు / పుదుచ్చేరి',
      AppLang.tamil: 'தமிழ்நாடு / புதுச்சேரி',
      AppLang.kannada: 'ತಮಿಳುನಾಡು / ಪುದುಚೇರಿ',
    },
    'आंध्र प्रदेश / तेलंगाना': {
      AppLang.hindi: 'आंध्र प्रदेश / तेलंगाना',
      AppLang.english: 'Andhra Pradesh / Telangana',
      AppLang.marathi: 'आंध्र प्रदेश / तेलंगणा',
      AppLang.gujarati: 'આંધ્ર પ્રદેશ / તેલંગાણા',
      AppLang.punjabi: 'ਆਂਧਰਾ ਪ੍ਰਦੇਸ਼ / ਤੇਲੰਗਾਨਾ',
      AppLang.bengali: 'অন্ধ্রপ্রদেশ / তেলঙ্গানা',
      AppLang.telugu: 'ఆంధ్రప్రదేశ్ / తెలంగాణ',
      AppLang.tamil: 'ஆந்திரப் பிரதேசம் / தெலங்கானா',
      AppLang.kannada: 'ಆಂಧ್ರಪ್ರದೇಶ / ತೆಲಂಗಾಣ',
    },
    'असम': {
      AppLang.hindi: 'असम',
      AppLang.english: 'Assam',
      AppLang.marathi: 'आसाम',
      AppLang.gujarati: 'આસામ',
      AppLang.punjabi: 'ਅਸਾਮ',
      AppLang.bengali: 'আসাম',
      AppLang.telugu: 'అస్సాం',
      AppLang.tamil: 'அசாம்',
      AppLang.kannada: 'ಅಸ್ಸಾಂ',
    },
    'मध्य प्रदेश / छत्तीसगढ़': {
      AppLang.hindi: 'मध्य प्रदेश / छत्तीसगढ़',
      AppLang.english: 'Madhya Pradesh / Chhattisgarh',
      AppLang.marathi: 'मध्य प्रदेश / छत्तीसगड',
      AppLang.gujarati: 'મધ્ય પ્રદેશ / છત્તીસગઢ',
      AppLang.punjabi: 'ਮੱਧ ਪ੍ਰਦੇਸ਼ / ਛੱਤੀਸਗੜ੍ਹ',
      AppLang.bengali: 'মধ্যপ্রদেশ / ছত্তিশগড়',
      AppLang.telugu: 'మధ్యప్రదేశ్ / ఛత్తీస్‌గఢ్',
      AppLang.tamil: 'மத்தியப் பிரதேசம் / சத்தீஸ்கர்',
      AppLang.kannada: 'ಮಧ್ಯಪ್ರದೇಶ / ಛತ್ತೀಸ್‌ಗಢ',
    },
    'हिमाचल प्रदेश': {
      AppLang.hindi: 'हिमाचल प्रदेश',
      AppLang.english: 'Himachal Pradesh',
      AppLang.marathi: 'हिमाचल प्रदेश',
      AppLang.gujarati: 'હિમાચલ પ્રદેશ',
      AppLang.punjabi: 'ਹਿਮਾਚਲ ਪ੍ਰਦੇਸ਼',
      AppLang.bengali: 'হিমাচল প্রদেশ',
      AppLang.telugu: 'హిమాచల్ ప్రదేశ్',
      AppLang.tamil: 'இமாசலப் பிரதேசம்',
      AppLang.kannada: 'ಹಿಮಾಚಲ ಪ್ರದೇಶ',
    },
    'उत्तराखंड': {
      AppLang.hindi: 'उत्तराखंड',
      AppLang.english: 'Uttarakhand',
      AppLang.marathi: 'उत्तराखंड',
      AppLang.gujarati: 'ઉત્તરાખંડ',
      AppLang.punjabi: 'ਉੱਤਰਾਖੰਡ',
      AppLang.bengali: 'উত্তরাখণ্ড',
      AppLang.telugu: 'ఉత్తరాఖండ్',
      AppLang.tamil: 'உத்தராகண்ட்',
      AppLang.kannada: 'ಉತ್ತರಾಖಂಡ',
    },
  };

  // ─────────────── Privacy dialog (नौ भाषाएँ) ───────────────
  //
  // यह `privacy_policy.html` और Play के Data safety form से मेल खाना चाहिए।
  // ऐप में AdMob है — "कोई परमिशन/डेटा नहीं" जैसा दावा यहाँ कभी न लिखें।

  String get privacyIntro => pick(const {
        AppLang.hindi: 'जमीन नापी आपकी गोपनीयता का पूरा सम्मान करता है।',
        AppLang.english: 'Jameen Napi respects your privacy.',
        AppLang.marathi: 'जमीन नापी आपल्या गोपनीयतेचा पूर्ण आदर करते.',
        AppLang.gujarati: 'જમીન નાપી તમારી ગોપનીયતાનું પૂરું સન્માન કરે છે.',
        AppLang.punjabi: 'ਜ਼ਮੀਨ ਨਾਪੀ ਤੁਹਾਡੀ ਨਿੱਜਤਾ ਦਾ ਪੂਰਾ ਸਤਿਕਾਰ ਕਰਦਾ ਹੈ।',
        AppLang.bengali: 'জমি নাপি আপনার গোপনীয়তাকে সম্পূর্ণ সম্মান করে।',
        AppLang.telugu: 'జమీన్ నాపి మీ గోప్యతను పూర్తిగా గౌరవిస్తుంది.',
        AppLang.tamil: 'ஜமீன் நாபி உங்கள் தனியுரிமையை முழுமையாக மதிக்கிறது.',
        AppLang.kannada: 'ಜಮೀನ್ ನಾಪಿ ನಿಮ್ಮ ಗೌಪ್ಯತೆಯನ್ನು ಸಂಪೂರ್ಣವಾಗಿ ಗೌರವಿಸುತ್ತದೆ.',
      });

  String get privacyOffline => pick(const {
        AppLang.hindi:
            'आपकी सारी नाप-गणना आपके फोन में ही होती है। नाप का कोई डेटा कहीं नहीं भेजा जाता।',
        AppLang.english:
            'All calculations run offline on your phone. Nothing you measure is uploaded anywhere.',
        AppLang.marathi:
            'सर्व मोजणी तुमच्या फोनमध्येच होते. मोजलेला कोणताही डेटा कुठेही पाठवला जात नाही.',
        AppLang.gujarati:
            'બધી ગણતરી તમારા ફોનમાં જ થાય છે. માપેલો કોઈ ડેટા ક્યાંય મોકલાતો નથી.',
        AppLang.punjabi:
            'ਸਾਰੀ ਗਿਣਤੀ ਤੁਹਾਡੇ ਫ਼ੋਨ ਵਿੱਚ ਹੀ ਹੁੰਦੀ ਹੈ। ਮਿਣਿਆ ਕੋਈ ਡਾਟਾ ਕਿਤੇ ਨਹੀਂ ਭੇਜਿਆ ਜਾਂਦਾ।',
        AppLang.bengali:
            'সব হিসাব আপনার ফোনেই হয়। মাপা কোনো তথ্য কোথাও পাঠানো হয় না।',
        AppLang.telugu:
            'అన్ని లెక్కలు మీ ఫోన్‌లోనే జరుగుతాయి. కొలిచిన సమాచారం ఎక్కడికీ పంపబడదు.',
        AppLang.tamil:
            'எல்லா கணக்கீடுகளும் உங்கள் தொலைபேசியிலேயே நடக்கின்றன. அளந்த தகவல் எங்கும் அனுப்பப்படுவதில்லை.',
        AppLang.kannada:
            'ಎಲ್ಲಾ ಲೆಕ್ಕಾಚಾರ ನಿಮ್ಮ ಫೋನಿನಲ್ಲೇ ನಡೆಯುತ್ತದೆ. ಅಳೆದ ಯಾವುದೇ ಮಾಹಿತಿ ಎಲ್ಲಿಗೂ ಕಳುಹಿಸಲಾಗುವುದಿಲ್ಲ.',
      });

  String get privacyNoPersonalData => pick(const {
        AppLang.hindi:
            'हम आपका नाम, मोबाइल नंबर, लोकेशन या कॉन्टैक्ट कुछ भी एकत्र नहीं करते।',
        AppLang.english:
            'We collect no name, phone number, location or contacts.',
        AppLang.marathi:
            'आम्ही तुमचे नाव, मोबाइल क्रमांक, स्थान किंवा संपर्क काहीही गोळा करत नाही.',
        AppLang.gujarati:
            'અમે તમારું નામ, મોબાઇલ નંબર, સ્થાન કે સંપર્ક કશું એકત્ર કરતા નથી.',
        AppLang.punjabi:
            'ਅਸੀਂ ਤੁਹਾਡਾ ਨਾਮ, ਮੋਬਾਈਲ ਨੰਬਰ, ਟਿਕਾਣਾ ਜਾਂ ਸੰਪਰਕ ਕੁਝ ਵੀ ਇਕੱਠਾ ਨਹੀਂ ਕਰਦੇ।',
        AppLang.bengali:
            'আমরা আপনার নাম, মোবাইল নম্বর, অবস্থান বা পরিচিতি কিছুই সংগ্রহ করি না।',
        AppLang.telugu:
            'మేము మీ పేరు, మొబైల్ నంబర్, స్థానం లేదా కాంటాక్ట్‌లు ఏవీ సేకరించము.',
        AppLang.tamil:
            'உங்கள் பெயர், கைபேசி எண், இருப்பிடம் அல்லது தொடர்புகள் எதையும் நாங்கள் சேகரிப்பதில்லை.',
        AppLang.kannada:
            'ನಾವು ನಿಮ್ಮ ಹೆಸರು, ಮೊಬೈಲ್ ಸಂಖ್ಯೆ, ಸ್ಥಳ ಅಥವಾ ಸಂಪರ್ಕಗಳನ್ನು ಸಂಗ್ರಹಿಸುವುದಿಲ್ಲ.',
      });

  String get privacyAds => pick(const {
        AppLang.hindi:
            'ऐप में Google AdMob के विज्ञापन दिखते हैं। सिर्फ़ विज्ञापनों के लिए AdMob इंटरनेट और आपके फोन की Advertising ID का उपयोग करता है।',
        AppLang.english:
            'The app shows Google AdMob ads. For ads only, AdMob uses the internet and your device\'s Advertising ID.',
        AppLang.marathi:
            'ॲपमध्ये Google AdMob च्या जाहिराती दिसतात. फक्त जाहिरातींसाठी AdMob इंटरनेट आणि तुमच्या फोनची Advertising ID वापरते.',
        AppLang.gujarati:
            'ઍપમાં Google AdMob ની જાહેરાતો દેખાય છે. માત્ર જાહેરાતો માટે AdMob ઇન્ટરનેટ અને તમારા ફોનની Advertising ID વાપરે છે.',
        AppLang.punjabi:
            'ਐਪ ਵਿੱਚ Google AdMob ਦੇ ਇਸ਼ਤਿਹਾਰ ਦਿਖਦੇ ਹਨ। ਸਿਰਫ਼ ਇਸ਼ਤਿਹਾਰਾਂ ਲਈ AdMob ਇੰਟਰਨੈੱਟ ਅਤੇ ਤੁਹਾਡੇ ਫ਼ੋਨ ਦੀ Advertising ID ਵਰਤਦਾ ਹੈ।',
        AppLang.bengali:
            'অ্যাপে Google AdMob-এর বিজ্ঞাপন দেখা যায়। কেবল বিজ্ঞাপনের জন্য AdMob ইন্টারনেট ও আপনার ফোনের Advertising ID ব্যবহার করে।',
        AppLang.telugu:
            'యాప్‌లో Google AdMob ప్రకటనలు కనిపిస్తాయి. ప్రకటనల కోసం మాత్రమే AdMob ఇంటర్నెట్ మరియు మీ ఫోన్ Advertising ID ఉపయోగిస్తుంది.',
        AppLang.tamil:
            'செயலியில் Google AdMob விளம்பரங்கள் தோன்றும். விளம்பரங்களுக்கு மட்டும் AdMob இணையத்தையும் உங்கள் சாதனத்தின் Advertising ID-யையும் பயன்படுத்துகிறது.',
        AppLang.kannada:
            'ಆಪ್‌ನಲ್ಲಿ Google AdMob ಜಾಹೀರಾತುಗಳು ಕಾಣಿಸುತ್ತವೆ. ಜಾಹೀರಾತುಗಳಿಗಾಗಿ ಮಾತ್ರ AdMob ಇಂಟರ್ನೆಟ್ ಮತ್ತು ನಿಮ್ಮ ಫೋನಿನ Advertising ID ಬಳಸುತ್ತದೆ.',
      });

  String get privacyNoOtherPermission => pick(const {
        AppLang.hindi:
            'इसके अलावा कोई परमिशन (लोकेशन, कॉन्टैक्ट, स्टोरेज, कैमरा) नहीं मांगी जाती।',
        AppLang.english:
            'No other permission (location, contacts, storage, camera) is requested.',
        AppLang.marathi:
            'याशिवाय कोणतीही परवानगी (स्थान, संपर्क, स्टोरेज, कॅमेरा) मागितली जात नाही.',
        AppLang.gujarati:
            'આ સિવાય કોઈ પરવાનગી (સ્થાન, સંપર્ક, સ્ટોરેજ, કૅમેરા) માંગવામાં આવતી નથી.',
        AppLang.punjabi:
            'ਇਸ ਤੋਂ ਇਲਾਵਾ ਕੋਈ ਇਜਾਜ਼ਤ (ਟਿਕਾਣਾ, ਸੰਪਰਕ, ਸਟੋਰੇਜ, ਕੈਮਰਾ) ਨਹੀਂ ਮੰਗੀ ਜਾਂਦੀ।',
        AppLang.bengali:
            'এ ছাড়া কোনো অনুমতি (অবস্থান, পরিচিতি, স্টোরেজ, ক্যামেরা) চাওয়া হয় না।',
        AppLang.telugu:
            'ఇది తప్ప ఏ అనుమతీ (స్థానం, కాంటాక్ట్‌లు, స్టోరేజ్, కెమెరా) అడగబడదు.',
        AppLang.tamil:
            'இதைத் தவிர வேறு எந்த அனுமதியும் (இருப்பிடம், தொடர்புகள், சேமிப்பு, கேமரா) கேட்கப்படுவதில்லை.',
        AppLang.kannada:
            'ಇದನ್ನು ಬಿಟ್ಟು ಬೇರೆ ಯಾವ ಅನುಮತಿಯನ್ನೂ (ಸ್ಥಳ, ಸಂಪರ್ಕ, ಸಂಗ್ರಹ, ಕ್ಯಾಮೆರಾ) ಕೇಳಲಾಗುವುದಿಲ್ಲ.',
      });

  String get shareAppTitle => pick(const {
        AppLang.hindi: 'ऐप दोस्तों के साथ शेयर करें',
        AppLang.english: 'Share the app with friends',
        AppLang.marathi: 'ॲप मित्रांसोबत शेअर करा',
        AppLang.gujarati: 'ઍપ મિત્રો સાથે શેર કરો',
        AppLang.punjabi: 'ਐਪ ਦੋਸਤਾਂ ਨਾਲ ਸਾਂਝਾ ਕਰੋ',
        AppLang.bengali: 'অ্যাপটি বন্ধুদের সঙ্গে শেয়ার করুন',
        AppLang.telugu: 'యాప్‌ను స్నేహితులతో షేర్ చేయండి',
        AppLang.tamil: 'செயலியை நண்பர்களுடன் பகிரவும்',
        AppLang.kannada: 'ಆಪ್ ಅನ್ನು ಸ್ನೇಹಿತರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ',
      });

  String get shareAppSubtitle => pick(const {
        AppLang.hindi: 'जमीन नापी ऐप को व्हाट्सएप पर भेजें',
        AppLang.english: 'Send Jameen Napi on WhatsApp',
        AppLang.marathi: 'जमीन नापी ॲप व्हॉट्सॲपवर पाठवा',
        AppLang.gujarati: 'જમીન નાપી ઍપ વૉટ્સએપ પર મોકલો',
        AppLang.punjabi: 'ਜ਼ਮੀਨ ਨਾਪੀ ਐਪ ਵਟਸਐਪ ਉੱਤੇ ਭੇਜੋ',
        AppLang.bengali: 'জমি নাপি অ্যাপ হোয়াটসঅ্যাপে পাঠান',
        AppLang.telugu: 'జమీన్ నాపి యాప్‌ను వాట్సాప్‌లో పంపండి',
        AppLang.tamil: 'ஜமீன் நாபி செயலியை வாட்ஸ்அப்பில் அனுப்பவும்',
        AppLang.kannada: 'ಜಮೀನ್ ನಾಪಿ ಆಪ್ ಅನ್ನು ವಾಟ್ಸ್‌ಆ್ಯಪ್‌ನಲ್ಲಿ ಕಳುಹಿಸಿ',
      });

  // ─────────── लंबाई की इकाइयों के नाम (नौ भाषाएँ) ───────────
  //
  // पहले सिर्फ़ `hi`/`en` थे, इसलिए तमिल/तेलुगु में भी "सेंटीमीटर", "इंच" हिंदी
  // में दिखते थे। मीटर-इंच जैसी इकाइयाँ हर भाषा में लिखी जाती हैं; लाठी/जरीब
  // जैसे देसी नाम उसी भाषा की लिपि में लिप्यंतरित हैं।

  String lengthUnitName(String englishName) {
    final table = _lengthUnitNames[englishName];
    if (table == null) return englishName;
    return table[lang] ?? englishName;
  }

  static const Map<String, Map<AppLang, String>> _lengthUnitNames = {
    'Centimeter': {
      AppLang.hindi: 'सेंटीमीटर',
      AppLang.english: 'Centimeter',
      AppLang.marathi: 'सेंटिमीटर',
      AppLang.gujarati: 'સેન્ટિમીટર',
      AppLang.punjabi: 'ਸੈਂਟੀਮੀਟਰ',
      AppLang.bengali: 'সেন্টিমিটার',
      AppLang.telugu: 'సెంటీమీటర్',
      AppLang.tamil: 'சென்டிமீட்டர்',
      AppLang.kannada: 'ಸೆಂಟಿಮೀಟರ್',
    },
    'Inch': {
      AppLang.hindi: 'इंच',
      AppLang.english: 'Inch',
      AppLang.marathi: 'इंच',
      AppLang.gujarati: 'ઇંચ',
      AppLang.punjabi: 'ਇੰਚ',
      AppLang.bengali: 'ইঞ্চি',
      AppLang.telugu: 'అంగుళం',
      AppLang.tamil: 'அங்குலம்',
      AppLang.kannada: 'ಇಂಚು',
    },
    'Beetta / Span': {
      AppLang.hindi: 'बित्ता',
      AppLang.english: 'Beetta / Span',
      AppLang.marathi: 'वीत',
      AppLang.gujarati: 'વેંત',
      AppLang.punjabi: 'ਬਿੱਤਾ',
      AppLang.bengali: 'বিঘত',
      AppLang.telugu: 'జాన',
      AppLang.tamil: 'சாண்',
      AppLang.kannada: 'ಗೇಣು',
    },
    'Haath / Cubit': {
      AppLang.hindi: 'हाथ',
      AppLang.english: 'Haath / Cubit',
      AppLang.marathi: 'हात',
      AppLang.gujarati: 'હાથ',
      AppLang.punjabi: 'ਹੱਥ',
      AppLang.bengali: 'হাত',
      AppLang.telugu: 'మూర',
      AppLang.tamil: 'முழம்',
      AppLang.kannada: 'ಮೊಳ',
    },
    'Kadi / Link': {
      AppLang.hindi: 'कड़ी (जरीब की)',
      AppLang.english: 'Kadi / Link',
      AppLang.marathi: 'कडी (साखळीची)',
      AppLang.gujarati: 'કડી (સાંકળની)',
      AppLang.punjabi: 'ਕੜੀ (ਜਰੀਬ ਦੀ)',
      AppLang.bengali: 'কড়ি (চেইনের)',
      AppLang.telugu: 'కడీ (గొలుసు)',
      AppLang.tamil: 'கடி (சங்கிலி)',
      AppLang.kannada: 'ಕಡಿ (ಸರಪಳಿ)',
    },
    'Feet': {
      AppLang.hindi: 'फीट',
      AppLang.english: 'Feet',
      AppLang.marathi: 'फूट',
      AppLang.gujarati: 'ફૂટ',
      AppLang.punjabi: 'ਫੁੱਟ',
      AppLang.bengali: 'ফুট',
      AppLang.telugu: 'అడుగు',
      AppLang.tamil: 'அடி',
      AppLang.kannada: 'ಅಡಿ',
    },
    'Gaj / Yard': {
      AppLang.hindi: 'गज',
      AppLang.english: 'Gaj / Yard',
      AppLang.marathi: 'वार',
      AppLang.gujarati: 'વાર',
      AppLang.punjabi: 'ਗਜ਼',
      AppLang.bengali: 'গজ',
      AppLang.telugu: 'గజం',
      AppLang.tamil: 'கஜம்',
      AppLang.kannada: 'ಗಜ',
    },
    'Meter': {
      AppLang.hindi: 'मीटर',
      AppLang.english: 'Meter',
      AppLang.marathi: 'मीटर',
      AppLang.gujarati: 'મીટર',
      AppLang.punjabi: 'ਮੀਟਰ',
      AppLang.bengali: 'মিটার',
      AppLang.telugu: 'మీటర్',
      AppLang.tamil: 'மீட்டர்',
      AppLang.kannada: 'ಮೀಟರ್',
    },
    'Latha / Laggi': {
      AppLang.hindi: 'लाठी / लट्ठा (5.5 हाथ)',
      AppLang.english: 'Latha / Laggi (5.5 Haath)',
      AppLang.marathi: 'काठी / लग्गी (५.५ हात)',
      AppLang.gujarati: 'લાકડી / લગ્ગી (૫.૫ હાથ)',
      AppLang.punjabi: 'ਕਰਮ / ਲੱਗੀ (੫.੫ ਹੱਥ)',
      AppLang.bengali: 'লাঠি / লাঘি (৫.৫ হাত)',
      AppLang.telugu: 'లగ్గి (5.5 మూరలు)',
      AppLang.tamil: 'லக்கி (5.5 முழம்)',
      AppLang.kannada: 'ಲಗ್ಗಿ (5.5 ಮೊಳ)',
    },
    'Jarib / Chain': {
      AppLang.hindi: 'जरीब (चेन)',
      AppLang.english: 'Jarib / Chain',
      AppLang.marathi: 'साखळी',
      AppLang.gujarati: 'સાંકળ',
      AppLang.punjabi: 'ਜਰੀਬ (ਚੇਨ)',
      AppLang.bengali: 'চেইন',
      AppLang.telugu: 'గొలుసు',
      AppLang.tamil: 'சங்கிலி',
      AppLang.kannada: 'ಸರಪಳಿ',
    },
    'Kilometer': {
      AppLang.hindi: 'किलोमीटर',
      AppLang.english: 'Kilometer',
      AppLang.marathi: 'किलोमीटर',
      AppLang.gujarati: 'કિલોમીટર',
      AppLang.punjabi: 'ਕਿਲੋਮੀਟਰ',
      AppLang.bengali: 'কিলোমিটার',
      AppLang.telugu: 'కిలోమీటర్',
      AppLang.tamil: 'கிலோமீட்டர்',
      AppLang.kannada: 'ಕಿಲೋಮೀಟರ್',
    },
    'Mile': {
      AppLang.hindi: 'मील',
      AppLang.english: 'Mile',
      AppLang.marathi: 'मैल',
      AppLang.gujarati: 'માઇલ',
      AppLang.punjabi: 'ਮੀਲ',
      AppLang.bengali: 'মাইল',
      AppLang.telugu: 'మైలు',
      AppLang.tamil: 'மைல்',
      AppLang.kannada: 'ಮೈಲಿ',
    },
  };

  // ─────────── शेयर करने वाले संदेश (नौ भाषाएँ) ───────────

  /// Settings → "ऐप दोस्तों के साथ शेयर करें" पर जाने वाला पूरा संदेश।
  /// लिंक `app_links.dart` से आता है — screen उसे अंत में जोड़ती है।
  String get shareAppMessage => pick(const {
        AppLang.hindi:
            '🌾 जमीन नापी — बीघा, कट्ठा, धूर, एकड़ और गुंठा में खेत-जमीन नापने का कैलकुलेटर। 4-भुजा टेढ़ा खेत, लग्गी पैमाना और बंटवारा भी। मुफ़्त, और बिना इंटरनेट के भी चलता है।',
        AppLang.english:
            '🌾 Jameen Napi — measure fields and land in Bigha, Katha, Dhur, Acre and Guntha. Also 4-sided irregular plots, the laggi scale and land partition. Free, and works without internet.',
        AppLang.marathi:
            '🌾 जमीन नापी — बीघा, गुंठा, एकर मध्ये शेत व जमीन मोजण्याचे कॅल्क्युलेटर. ४ बाजूंचे वेडेवाकडे शेत, काठी मापदंड आणि वाटपही. मोफत, आणि इंटरनेटशिवायही चालते.',
        AppLang.gujarati:
            '🌾 જમીન નાપી — વીઘા, ગુણઠા, એકરમાં ખેતર અને જમીન માપવાનું કેલ્ક્યુલેટર. ૪ બાજુનું અનિયમિત ખેતર, લગ્ગી માપ અને વહેંચણી પણ. મફત, અને ઇન્ટરનેટ વગર પણ ચાલે છે.',
        AppLang.punjabi:
            '🌾 ਜ਼ਮੀਨ ਨਾਪੀ — ਬੀਘਾ, ਕਨਾਲ, ਮਰਲਾ, ਏਕੜ ਵਿੱਚ ਖੇਤ ਤੇ ਜ਼ਮੀਨ ਮਿਣਨ ਦਾ ਕੈਲਕੁਲੇਟਰ। ੪-ਭੁਜਾਵੀਂ ਅਸਾਵਾਂ ਖੇਤ, ਲੱਗੀ ਪੈਮਾਨਾ ਤੇ ਵੰਡ ਵੀ। ਮੁਫ਼ਤ, ਤੇ ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ ਵੀ ਚੱਲਦਾ ਹੈ।',
        AppLang.bengali:
            '🌾 জমি নাপি — বিঘা, কাঠা, শতক, একরে জমি ও খেত মাপার ক্যালকুলেটর। ৪-কোণা অসম জমি, লাঘি মাপকাঠি ও ভাগ-বণ্টনও। বিনামূল্যে, ইন্টারনেট ছাড়াও চলে।',
        AppLang.telugu:
            '🌾 జమీన్ నాపి — బీగా, కుంటా, సెంట్, ఎకరాలలో పొలం, భూమి కొలిచే క్యాలిక్యులేటర్. 4 భుజాల అసమాన పొలం, లగ్గి కొలత, భూమి పంపకం కూడా. ఉచితం, ఇంటర్నెట్ లేకుండా కూడా పనిచేస్తుంది.',
        AppLang.tamil:
            '🌾 ஜமீன் நாபி — சென்ட், ஏக்கர், கிரவுண்டில் நிலம் அளக்கும் கால்குலேட்டர். 4 பக்க ஒழுங்கற்ற நிலம், லக்கி அளவுகோல், நிலப் பகிர்வும் உண்டு. இலவசம், இணையம் இல்லாமலும் வேலை செய்யும்.',
        AppLang.kannada:
            '🌾 ಜಮೀನ್ ನಾಪಿ — ಗುಂಟೆ, ಎಕರೆ, ಸೆಂಟ್‌ನಲ್ಲಿ ಜಮೀನು ಅಳೆಯುವ ಕ್ಯಾಲ್ಕುಲೇಟರ್. ೪ ಬದಿಯ ಅಸಮ ಜಮೀನು, ಲಗ್ಗಿ ಅಳತೆ, ಪಾಲು ಹಂಚಿಕೆಯೂ ಇದೆ. ಉಚಿತ, ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆಯೂ ನಡೆಯುತ್ತದೆ.',
      });

  /// लिंक से ठीक पहले की पंक्ति — "अभी डाउनलोड करें:"
  String get downloadCta => pick(const {
        AppLang.hindi: 'अभी डाउनलोड करें',
        AppLang.english: 'Download now',
        AppLang.marathi: 'आताच डाउनलोड करा',
        AppLang.gujarati: 'હમણાં જ ડાઉનલોડ કરો',
        AppLang.punjabi: 'ਹੁਣੇ ਡਾਊਨਲੋਡ ਕਰੋ',
        AppLang.bengali: 'এখনই ডাউনলোড করুন',
        AppLang.telugu: 'ఇప్పుడే డౌన్‌లోడ్ చేయండి',
        AppLang.tamil: 'இப்போதே பதிவிறக்கவும்',
        AppLang.kannada: 'ಈಗಲೇ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      });
}
