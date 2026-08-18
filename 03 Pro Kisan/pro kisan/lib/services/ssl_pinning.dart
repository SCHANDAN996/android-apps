import 'dart:io';

import 'package:crypto/crypto.dart';

/// अपने VPS के self-signed सर्टिफ़िकेट को भरोसेमंद बनाना — **सिर्फ़ उसी को**।
///
/// ⚠️ यह क्यों ऐसे लिखा है, यह समझना ज़रूरी है।
///
/// आम सुझाव यह मिलता है:
/// ```dart
/// badCertificateCallback = (cert, host, port) => true;   // ❌ मत करना
/// ```
/// इसका मतलब है **पूरे ऐप की सर्टिफ़िकेट जाँच बंद कर देना** — सिर्फ़ अपने
/// सर्वर की नहीं, बल्कि मौसम API, समाचार feed, नक्शे की टाइल्स, सबकी।
/// तब कोई भी बीच में बैठकर (public Wi-Fi, दूषित राउटर) किसान का नाम, फ़ोन
/// नंबर और सारा traffic पढ़ या बदल सकता है।
///
/// इसके अलावा Google Play इसे पकड़ता है — "unsafe implementation of
/// TrustManager/HostnameVerifier" वाली चेतावनी आती है और ऐप हट सकता है।
///
/// इसलिए यहाँ **certificate pinning** किया गया है:
///  • सिर्फ़ अपने सर्वर के host के लिए
///  • सिर्फ़ उसी एक सर्टिफ़िकेट के लिए (SHA-256 fingerprint से मिलान)
///  • बाक़ी हर host की जाँच पहले जैसी सख़्त रहती है
///
/// यानी अपना सर्वर चलेगा, और सुरक्षा भी नहीं टूटेगी।
class ProKisanHttpOverrides extends HttpOverrides {
  /// हमारे VPS का host (server_config के baseUrl से मेल खाना चाहिए)
  static const String pinnedHost = '72.61.235.129';

  /// उस सर्वर के सर्टिफ़िकेट का SHA-256 fingerprint (लोअरकेस, बिना कोलन)।
  ///
  /// निकालने का तरीक़ा:
  /// ```
  /// echo | openssl s_client -connect 72.61.235.129:443 2>/dev/null \
  ///   | openssl x509 -noout -fingerprint -sha256
  /// ```
  /// ⚠️ सर्टिफ़िकेट बदलें (नवीनीकरण/नया बनाएँ) तो यह भी बदलना होगा,
  /// वरना ऐप सर्वर से जुड़ना बंद कर देगा। मौजूदा सर्टिफ़िकेट 20 जुलाई 2036
  /// तक चलेगा।
  static const String pinnedSha256 =
      '6af9722ccf2d9e84e61ba35e11ac9c894f007d64cffbe62df2b483dae461763e';

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = _verify
      // धीमे गाँव के नेटवर्क पर 15 सेकंड ठीक है
      ..connectionTimeout = const Duration(seconds: 15);
  }

  /// यह तभी बुलाया जाता है जब सामान्य जाँच नाकाम हो।
  /// हम सिर्फ़ अपने host + अपने सर्टिफ़िकेट को ही "हाँ" कहते हैं।
  static bool _verify(X509Certificate cert, String host, int port) {
    if (host != pinnedHost) return false; // दूसरा कोई host? सख़्ती से मना
    final fp = sha256.convert(cert.der).toString().toLowerCase();
    return fp == pinnedSha256.toLowerCase();
  }
}
