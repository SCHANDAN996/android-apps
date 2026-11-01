/// ऐप की वो बातें जो लॉन्च से पहले बदलनी हैं।
class AppConfig {
  AppConfig._();

  static const String appName = 'निश्चिंत';
  static const String partnerAppName = 'निश्चिंत पार्टनर';
  static const String tagline = 'घर का हर काम, आप निश्चिंत।';
  static const String vendorLine = 'आप पैनल लगाइए, मेंटेनेंस हम संभाल लेंगे।';
  static const String version = '0.1.0';

  /// TODO(लॉन्च से पहले): असली WhatsApp नंबर, देश कोड के साथ, बिना + के।
  static const String businessWhatsApp = '919999999999';

  /// TODO(लॉन्च से पहले): असली कॉल नंबर।
  static const String businessPhone = '+919999999999';

  static const String serviceArea = 'वाराणसी शहर';
  static const String workingHours = 'सुबह 8 से शाम 7 बजे, सातों दिन';

  /// बुकिंग के बाद कितनी देर में कॉल करेंगे (ग्राहक को दिखता है)।
  static const String callbackPromise = 'हम 2 घंटे के अंदर कॉल करके समय पक्का करेंगे।';
}
