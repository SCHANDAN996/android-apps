// 🏷️ बराबर चौड़ाई वाले chip के नाम कटने नहीं चाहिए
//
// खाद कैलकुलेटर में तीन chip एक पंक्ति में हैं — "कम से कम", "सही मात्रा",
// "ज्यादा से ज्यादा"। तीनों `Expanded` हैं, यानी हर एक को screen की ठीक
// एक-तिहाई चौड़ाई मिलती है, और उन पर `overflow: ellipsis` लगा है।
//
// 8 अगस्त 2026 को असली फ़ोन पर पकड़ा गया: बीच वाला "✅ सही मात्रा (सुझाव)"
// कटकर "✅ सही मात्रा (सु…" दिख रहा था। नीचे उसका ब्योरा वैसे भी लिखा
// रहता है, इसलिए कोष्ठक वाला हिस्सा हटा दिया गया।
//
// यह जाँच उसी ग़लती को दोबारा आने से रोकती है — किसी भी भाषा में।

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/l10n/app_localizations.dart';

/// एक तिहाई चौड़ाई में 14sp पर इतने से ज़्यादा नहीं समाते
const _hadd = 18;

const _sabBhashayein = [
  'hi', 'en', 'ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho',
];

const _chipKeys = ['tierLow', 'tierRight', 'tierHigh'];

String _tr(String lang, String key) =>
    AppLocalizations(Locale(lang)).translate(key);

void main() {
  group('🏷️ खाद के तीन chip — हर भाषा में', () {
    test('हर भाषा में तीनों नाम मौजूद हैं', () {
      for (final l in _sabBhashayein) {
        for (final k in _chipKeys) {
          final v = _tr(l, k);
          expect(v, isNot(k), reason: '$l · $k — कुछ है ही नहीं');
          expect(v.trim(), isNotEmpty, reason: '$l · $k — ख़ाली है');
        }
      }
    });

    test('⚠️ कोई नाम इतना लंबा नहीं कि chip में कट जाए', () {
      final lambe = <String>[];
      for (final l in _sabBhashayein) {
        for (final k in _chipKeys) {
          final v = _tr(l, k);
          if (v.length > _hadd) lambe.add('$l · $k (${v.length}) — $v');
        }
      }
      expect(lambe, isEmpty,
          reason: 'ये chip में "…" बनकर कट जाएँगे — छोटा कीजिए, '
              'बाक़ी बात नीचे के ब्योरे में डालिए:\n${lambe.join('\n')}');
    });

    test('ब्योरा तीनों का अलग-अलग है (कॉपी-पेस्ट की ग़लती नहीं)', () {
      for (final l in _sabBhashayein) {
        final d = [
          _tr(l, 'tierLowDesc'),
          _tr(l, 'tierRightDesc'),
          _tr(l, 'tierHighDesc'),
        ];
        expect(d.toSet().length, 3,
            reason: '$l — तीनों का ब्योरा एक जैसा है: $d');
      }
    });
  });
}
