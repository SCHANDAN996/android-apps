import 'package:flutter/material.dart';

import '../vidhi/granth.dart';
import 'granth_screen.dart';

/// दुर्गा सप्तशती — कवच, अर्गला, कीलक और तीन चरित्रों में तेरह अध्याय
/// (→ D-084)।
///
/// ## पहले यहाँ क्या था
/// नवरात्रि के पर्व-पन्ने पर लिखा था *"पूरी सप्तशती ऐप में नहीं है — अपनी
/// पुस्तिका से पढ़िए"*। डेवलपर ने साफ़ कहा कि पूरा पाठ ऐप में चाहिए।
///
/// ## अब
/// पूरा पन्ना [GranthScreen] है — वही क्रम, वही "जहाँ छोड़ा था वहीं से",
/// वही पिछला/अगला। गीता आने पर वह पन्ना हर ग्रंथ के लिए एक हो गया
/// (→ D-098); यह नाम इसलिए बचा है कि पर्व-पन्ना और "चालीसा और आरती" की
/// सूची इसे इसी नाम से खोलते हैं।
class SaptashatiScreen extends StatelessWidget {
  const SaptashatiScreen({super.key});

  /// आख़िरी खोला पाठ — `SharedPreferences` में। वही कुंजी जो
  /// `GranthScreen.pichhlaKeyFor('saptashati')` देता है; पुराने फ़ोन पर बची
  /// हुई जगह इसी नाम से पढ़ी जाती है, इसलिए यह नहीं बदलेगी।
  static const pichhlaKey = 'saptashati_pichhla';

  @override
  Widget build(BuildContext context) =>
      const GranthScreen(granth: GranthSuchiEntry.saptashati);
}
