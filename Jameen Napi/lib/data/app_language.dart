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

  // Converter Screen Mode
  String get directAreaMode => isEn ? 'Direct Area' : 'डायरेक्ट क्षेत्रफल';
  String get lengthWidthMode => isEn ? 'Length × Width (L × W)' : 'लंबाई × चौड़ाई (नापाई)';

  String get lengthLabel => isEn ? 'Length' : 'लंबाई';
  String get widthLabel => isEn ? 'Width' : 'चौड़ाई';
  String get totalCalculatedArea => isEn ? 'Calculated Total Area' : 'कुल नापा गया क्षेत्रफल';
  String get selectState => isEn ? 'Select State / Region' : 'राज्य / क्षेत्र चुनें';
  String get enterArea => isEn ? 'Enter Area Value' : 'क्षेत्रफल मान दर्ज करें';
  String get selectUnit => isEn ? 'Select Unit' : 'इकाई चुनें';
  String get privacyPolicy => isEn ? 'Privacy Policy' : 'प्राइवेसी पॉलिसी';
  String get aboutApp => isEn ? 'About App' : 'ऐप के बारे में';
  String get ok => isEn ? 'OK' : 'ठीक है';

  // Common
  String get copy => isEn ? 'Copy' : 'कॉपी करें';
  String get share => isEn ? 'Share' : 'शेयर करें';
  String get copied => isEn ? 'Copied to clipboard!' : 'क्लिपबोर्ड में कॉपी हो गया!';
  String get clear => isEn ? 'Clear' : 'साफ करें';
  String get calculate => isEn ? 'Calculate' : 'हिसाब निकालें';

  // Converter share/results
  String get shareResultTitle =>
      isEn ? 'Land Area Conversion' : 'भूमि क्षेत्रफल की माप';
  String get sqFtLabel => isEn ? 'Sq Ft' : 'वर्ग फीट';

  // Length screen
  String get lengthEnterHeading =>
      isEn ? 'Enter the length to measure' : 'नाप की लंबाई दर्ज करें';
  String get lengthInputLabel => isEn ? 'Enter length' : 'लंबाई दर्ज करें';
  String get lengthOtherUnits =>
      isEn ? 'Value in all other units:' : 'अन्य सभी इकाइयों में मान:';
  String get lengthInfoTitle =>
      isEn ? 'Key measurement facts:' : 'नापाई की मुख्य जानकारी:';
  List<String> get lengthInfoLines => isEn
      ? const [
          '• 1 Haath (Cubit) = 1.5 Feet = 18 Inches',
          '• 1 Gaj (Yard) = 3 Feet = 36 Inches',
          '• 1 Meter = 3.28084 Feet (about 39.37 inches)',
          '• 1 Latha (Laggi) = 8.25 Feet (5.5 Haath)',
          '• 1 Jarib (Chain) = 100 Kadi = 66 Feet (22 Gaj)',
        ]
      : const [
          '• 1 हाथ (Haath) = 1.5 फीट = 18 इंच',
          '• 1 गज (Yard) = 3 फीट = 36 इंच',
          '• 1 मीटर = 3.28 फीट (लगभग 39.37 इंच)',
          '• 1 लाठी (लट्ठा) = 8.25 फीट (5.5 हाथ)',
          '• 1 जरीब (Chain) = 100 कड़ी = 66 फीट (22 गज)',
        ];
}
