// 🧭 पहली बार वाला रास्ता हर भाषा में ठीक दिखता है या नहीं
//
// ऐप खुलते ही नए किसान को नीचे के पाँच tab समझाए जाते हैं। यही उसका पहला
// अनुभव है — अगर यहीं अंग्रेज़ी दिख गई या टूटा-फूटा पाठ आया, तो वह ऐप
// वहीं छोड़ देगा।
//
// इसलिए ये जाँचें असली lookup से पूछती हैं (वही रास्ता जो ऐप चलते समय
// इस्तेमाल करता है), न कि फ़ाइल में शब्द ढूँढ़कर।

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/l10n/app_localizations.dart';

/// पहली बार वाले रास्ते की सारी चाबियाँ
const _tourKeys = [
  'tour_nav_home_title', 'tour_nav_home_desc',
  'tour_nav_milk_title', 'tour_nav_milk_desc',
  'tour_nav_pashu_title', 'tour_nav_pashu_desc',
  'tour_nav_kheti_title', 'tour_nav_kheti_desc',
  'tour_nav_more_title', 'tour_nav_more_desc',
];

/// किस भाषा को कौन सी लिपि चाहिए
const _lipi = {
  'ta': [0x0B80, 0x0BFF], // तमिल
  'te': [0x0C00, 0x0C7F], // तेलुगु
  'kn': [0x0C80, 0x0CFF], // कन्नड़
  'bn': [0x0980, 0x09FF], // बांग्ला
  'gu': [0x0A80, 0x0AFF], // गुजराती
  'pa': [0x0A00, 0x0A7F], // गुरमुखी
  'mr': [0x0900, 0x097F], // देवनागरी
  'bho': [0x0900, 0x097F], // देवनागरी
};

/// चलते समय ऐप जो लौटाता है, वही
String _tr(String lang, String key) =>
    AppLocalizations(Locale(lang)).translate(key);

void main() {
  group('🧭 पहली बार वाला रास्ता — हर भाषा में', () {
    test('हिंदी और अंग्रेज़ी दोनों में हर चाबी है', () {
      for (final k in _tourKeys) {
        for (final l in ['hi', 'en']) {
          final v = _tr(l, k);
          expect(v, isNot(k), reason: '$l · $k — कुछ है ही नहीं');
          expect(v.trim(), isNotEmpty);
        }
      }
    });

    test('आठों भाषाओं में अपना अनुवाद है (अंग्रेज़ी नहीं लौट रही)', () {
      final chhoote = <String>[];
      for (final l in _lipi.keys) {
        for (final k in _tourKeys) {
          final v = _tr(l, k);
          if (v == k || v == _tr('en', k) || v.trim().isEmpty) {
            chhoote.add('$l · $k');
          }
        }
      }
      expect(chhoote, isEmpty,
          reason: 'इनका अनुवाद नहीं हुआ — किसान को अंग्रेज़ी दिखेगी:\n'
              '${chhoote.take(10).join('\n')}');
    });

    test('⚠️ हर भाषा अपनी ही लिपि में है', () {
      // मशीन के अनुवाद में सबसे आम ग़लती — तेलुगु के बीच तमिल का अक्षर
      // रह जाना। आँख से पकड़ में नहीं आती, पर किसान पढ़ ही नहीं पाता।
      const saajha = {0x0964, 0x0965, 0x0970, 0x00B7}; // । ॥ ॰ ·

      final ghusi = <String>[];
      _lipi.forEach((l, range) {
        for (final k in _tourKeys) {
          final v = _tr(l, k);
          for (final r in v.runes) {
            if (saajha.contains(r)) continue;
            // सिर्फ़ भारतीय लिपियों के इलाक़े देखो
            if (r < 0x0900 || r > 0x0CFF) continue;
            if (r < range[0] || r > range[1]) {
              ghusi.add('$l · $k → "${String.fromCharCode(r)}" ($v)');
              break;
            }
          }
        }
      });
      expect(ghusi, isEmpty,
          reason: 'इनमें दूसरी लिपि घुस गई:\n${ghusi.take(10).join('\n')}');
    });

    test('शीर्षक छोटे हैं — कार्ड में कटेंगे नहीं', () {
      // शीर्षक एक पंक्ति में दिखता है। बहुत लंबा हुआ तो "…" में कट जाएगा।
      final lambe = <String>[];
      for (final l in [..._lipi.keys, 'hi', 'en']) {
        for (final k in _tourKeys.where((k) => k.endsWith('_title'))) {
          final v = _tr(l, k);
          if (v.length > 34) lambe.add('$l · $k (${v.length}) — $v');
        }
      }
      expect(lambe, isEmpty,
          reason: 'ये शीर्षक बहुत लंबे हैं:\n${lambe.join('\n')}');
    });

    test('ब्योरा भी हद में है', () {
      final lambe = <String>[];
      for (final l in [..._lipi.keys, 'hi', 'en']) {
        for (final k in _tourKeys.where((k) => k.endsWith('_desc'))) {
          final v = _tr(l, k);
          if (v.length > 130) lambe.add('$l · $k (${v.length})');
        }
      }
      expect(lambe, isEmpty,
          reason: 'ये ब्योरे बहुत लंबे हैं, कार्ड बहुत बड़ा हो जाएगा:\n'
              '${lambe.join('\n')}');
    });
  });
}
