/// ऐप की वो बातें जो लॉन्च से पहले बदलनी हैं।
class AppConfig {
  AppConfig._();

  static const String brandName = 'Kaajo';
  static const String appName = 'काजो';
  static const String partnerAppName = 'काजो पार्टनर';
  static const String tagline = 'काम हो कोई, काजो पे बुलाओ';
  static const String vendorLine = 'आप पैनल लगाइए, मेंटेनेंस हम संभाल लेंगे।';
  static const String version = '0.1.0';

  /// TODO(लॉन्च से पहले): असली WhatsApp नंबर, देश कोड के साथ, बिना + के।
  static const String businessWhatsApp = '919999999999';

  /// TODO(लॉन्च से पहले): असली कॉल नंबर।
  static const String businessPhone = '+919999999999';

  static const String serviceArea = 'वाराणसी शहर';

  /// TODO(लॉन्च से पहले): फ़ील्ड ट्रायल पास करने का सुपरवाइज़र कोड (सिर्फ़ मालिक/सीनियर को पता हो)।
  /// v0.2 में यह सर्वर से एडमिन की मंज़ूरी बन जाएगा।
  static const String supervisorPin = '2580';

  /// क्विज़ पास होने के लिए कम से कम प्रतिशत।
  static const int quizPassPercent = 80;
  static const String workingHours = 'सुबह 8 से शाम 7 बजे, सातों दिन';

  /// बुकिंग के बाद कितनी देर में कॉल करेंगे (ग्राहक को दिखता है)।
  static const String callbackPromise = 'हम 2 घंटे के अंदर कॉल करके समय पक्का करेंगे।';
}
