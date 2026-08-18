/// Pro Kisan का backend (Hostinger VPS)।
///
/// ⚠️ HTTPS ही रखना — HTTP पर किसान का नाम और फ़ोन नंबर बिना ताले के जाएगा,
/// और Android 9+ वैसे भी cleartext अपने आप रोक देता है।
///
/// यह सर्वर IP पर सीधे 10 साल का self-signed सर्टिफ़िकेट इस्तेमाल करता है,
/// इसलिए ऐप में उसका pinning किया गया है — देखें `services/ssl_pinning.dart`।
/// सर्टिफ़िकेट बदले तो वहाँ का fingerprint भी बदलना ज़रूरी है।
class ServerConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://72.61.235.129/prokisan_api',
  );

  /// सुझाव/शिकायत भेजना (POST)
  static String get sujhavUrl => '$baseUrl/api/sujhav.php';

  /// ऐप की सूचनाएँ (GET)
  static String get noticesUrl => '$baseUrl/api/notices.php';

  /// मंडी भाव (GET)
  ///
  /// 3 अगस्त 2026 को सर्वर पर लग गया — अब HTTP 200 और असली भाव आते हैं
  /// (देखें `SERVER_UPDATE/README.md`)। इससे पहले 404 था।
  ///
  /// सर्वर पर सारे **28 राज्यों** का भाव है (5 अगस्त 2026 को 1,04,128
  /// पंक्तियाँ)। ⚠️ पर एक माँग में सब नहीं आता — सर्वर `LIMIT` पर काटता है
  /// और क्रम राज्य के अकारादि में है, इसलिए बिना छाँटे माँगने पर सिर्फ़ शुरू
  /// के 7-8 राज्य आते हैं। इसीलिए मंडी screen राज्य चुनते ही `?state=` लगाकर
  /// दोबारा माँगती है।
  ///
  /// नमूना भाव फिर भी रखे हैं (हर ज़िले का भाव सर्वर पर नहीं होता), पर हर
  /// पंक्ति पर 🟢 असली / 🟠 अनुमान का निशान लगता है — देखें
  /// `ui/mandi_screen.dart` का `_MandiRate.isReal`।
  static String get mandiUrl => '$baseUrl/api/mandi.php';
}
