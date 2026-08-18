// पालन/फ़सल के गहरे अनुवाद की जाँच
//
// ⚠️ ये अनुवाद **मशीन के किए हुए** हैं। किसी पशु-चिकित्सक ने नहीं जाँचे।
// इसलिए जो बातें मशीन से बिगड़ सकती हैं और किसान को सीधा नुक़सान पहुँचा
// सकती हैं, उन्हें जाँच से बाँध दिया गया है:
//
//   1. **संख्या** — "500 ग्राम" का अनुवाद "50 ग्राम" हो जाए तो जानवर की
//      खुराक आधी हो जाएगी। हर अनुवाद में वही अंक होने चाहिए जो हिंदी में हैं।
//   2. **अधूरी पंक्ति** — किसी वाक्य का 5 भाषाओं में अनुवाद हो और 3 में न हो,
//      तो वही पन्ना आधा-अधूरा दिखेगा। हर entry में आठों भाषाएँ हों।
//   3. **देवनागरी का रिसाव** — तमिल चुनने वाले को देवनागरी दिखे तो वह पढ़ ही
//      नहीं पाएगा। ग़ैर-देवनागरी भाषाओं में देवनागरी नहीं रिसनी चाहिए।

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/palan/palan_i18n.dart';

const langs = ['ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho'];

/// देवनागरी लिपि वाली भाषाएँ — इनमें देवनागरी दिखना सही है
const devanagari = {'mr', 'bho'};

/// हर लिपि के अंक ASCII में बदलो।
///
/// अनुवाद में बांग्ला के '৫০০' और अंग्रेज़ी के '500' दोनों सही हैं — किसान
/// दोनों पढ़ लेता है। पर **मान** वही रहना चाहिए, इसलिए तुलना से पहले सबको
/// एक ही रूप में लाते हैं।
String asciiDigits(String s) {
  const bases = {
    0x0966: 'deva', // देवनागरी ०-९
    0x09E6: 'beng', // बांग्ला ০-৯
    0x0AE6: 'guj',  // गुजराती ૦-૯
    0x0A66: 'guru', // गुरमुखी ੦-੯
    0x0BE6: 'taml', // तमिल ௦-௯
    0x0C66: 'telu', // तेलुगु ౦-౯
    0x0CE6: 'knda', // कन्नड़ ೦-೯
  };
  final out = StringBuffer();
  for (final r in s.runes) {
    var done = false;
    for (final b in bases.keys) {
      if (r >= b && r <= b + 9) {
        out.write(r - b);
        done = true;
        break;
      }
    }
    if (!done) out.writeCharCode(r);
  }
  return out.toString();
}

/// पाठ में से सारे अंक-समूह निकालो — "2-3 किग्रा" → ['2', '3']
List<String> numbersIn(String s) =>
    RegExp(r'\d+').allMatches(asciiDigits(s)).map((m) => m.group(0)!).toList();

/// देवनागरी अक्षर (अंक और दंड छोड़कर) है या नहीं
bool hasDevanagariLetters(String s) {
  for (final r in s.runes) {
    // 0x0900-0x097F देवनागरी। अंक (0966-096F) और ॥/। (0964-0965) छोड़ दो
    if (r >= 0x0904 && r <= 0x0963) return true;
    if (r >= 0x0970 && r <= 0x097F) return true;
  }
  return false;
}

void main() {
  group('गहरा अनुवाद — भरोसे की जाँच', () {
    test('हर पंक्ति में आठों भाषाएँ हैं — कोई अधूरी नहीं', () {
      final adhoore = <String>[];
      kPalanI18n.forEach((hi, m) {
        final missing = langs.where((l) => !m.containsKey(l)).toList();
        if (missing.isNotEmpty) adhoore.add('$hi → $missing');
      });
      expect(adhoore, isEmpty,
          reason: 'इन वाक्यों का अनुवाद अधूरा है:\n${adhoore.take(10).join('\n')}');
    });

    test('कोई अनुवाद ख़ाली नहीं है', () {
      final khaali = <String>[];
      kPalanI18n.forEach((hi, m) {
        m.forEach((l, v) {
          if (v.trim().isEmpty) khaali.add('$hi [$l]');
        });
      });
      expect(khaali, isEmpty, reason: 'ख़ाली अनुवाद: $khaali');
    });

    test('⚠️ संख्याएँ नहीं बदलीं — खुराक/दाम वही हैं', () {
      // यही सबसे ज़रूरी जाँच है। "दाना 500 ग्राम" का अनुवाद "दाना 50 ग्राम"
      // हो जाए तो किसान जानवर को आधी खुराक देगा।
      final bigde = <String>[];
      kPalanI18n.forEach((hi, m) {
        final chahiye = numbersIn(hi)..sort();
        if (chahiye.isEmpty) return;
        m.forEach((l, v) {
          final mila = numbersIn(v)..sort();
          if (chahiye.join(',') != mila.join(',')) {
            bigde.add('[$l] "$hi"\n      चाहिए $chahiye, मिला $mila');
          }
        });
      });
      expect(bigde, isEmpty,
          reason: 'इन अनुवादों में संख्या बदल गई:\n${bigde.take(12).join('\n')}');
    });

    test('₹ का चिह्न जहाँ हिंदी में है, अनुवाद में भी है', () {
      final bigde = <String>[];
      kPalanI18n.forEach((hi, m) {
        if (!hi.contains('₹')) return;
        m.forEach((l, v) {
          if (!v.contains('₹')) bigde.add('[$l] $hi');
        });
      });
      expect(bigde, isEmpty, reason: '₹ ग़ायब: ${bigde.take(8)}');
    });

    test('⚠️ हर भाषा अपनी ही लिपि में है — दूसरी लिपि नहीं घुसी', () {
      // 6 अगस्त 2026 को यह जाँच इसलिए जोड़ी कि मशीन के अनुवाद में **30 जगह**
      // दूसरी लिपि के अक्षर रह गए थे — मराठी के बीच गुजराती (`હેક્ટર`),
      // तेलुगु में तमिल का `மீ`, कन्नड़ में तमिल का `இடது` (यानी वह शब्द
      // अनुवाद ही नहीं हुआ था, तमिल का तमिल ही चिपका रह गया)।
      //
      // नीचे वाली "देवनागरी नहीं रिसती" जाँच इन्हें नहीं पकड़ती थी, क्योंकि
      // वह सिर्फ़ देवनागरी देखती है। किसान को ऐसे अक्षर पढ़ने ही नहीं आते,
      // और देखने में तुरंत पता भी नहीं चलता।
      const blocks = {
        'deva': [0x0900, 0x097F], 'beng': [0x0980, 0x09FF],
        'guru': [0x0A00, 0x0A7F], 'gujr': [0x0A80, 0x0AFF],
        'taml': [0x0B80, 0x0BFF], 'telu': [0x0C00, 0x0C7F],
        'knda': [0x0C80, 0x0CFF],
      };
      const want = {
        'ta': 'taml', 'te': 'telu', 'kn': 'knda', 'bn': 'beng',
        'gu': 'gujr', 'pa': 'guru', 'mr': 'deva', 'bho': 'deva',
      };
      // ये चिह्न देवनागरी के खाने में हैं पर सारी भारतीय लिपियों में चलते
      // हैं — बांग्ला और पंजाबी भी दंड (।) लगाते हैं। इन्हें ग़लती मत मानो।
      const shared = {0x0964, 0x0965, 0x0970, 0x00B7};

      String? scriptOf(int cp) {
        if (shared.contains(cp)) return null;
        for (final e in blocks.entries) {
          if (cp >= e.value[0] && cp <= e.value[1]) return e.key;
        }
        return null;
      }

      final ghusi = <String>[];
      kPalanI18n.forEach((hi, m) {
        m.forEach((l, v) {
          final chahiye = want[l];
          if (chahiye == null) return;
          final wrong = <String>{};
          for (final r in v.runes) {
            final s = scriptOf(r);
            if (s != null && s != chahiye) wrong.add(s);
          }
          if (wrong.isNotEmpty) {
            ghusi.add('[$l] चाहिए $chahiye, मिला $wrong → $v');
          }
        });
      });
      expect(ghusi, isEmpty,
          reason: 'इनमें दूसरी लिपि घुस गई:\n${ghusi.take(10).join('\n')}');
    });

    test('ग़ैर-देवनागरी भाषाओं में देवनागरी नहीं रिसती', () {
      final risav = <String>[];
      kPalanI18n.forEach((hi, m) {
        m.forEach((l, v) {
          if (devanagari.contains(l)) return;
          if (hasDevanagariLetters(v)) risav.add('[$l] $v');
        });
      });
      expect(risav, isEmpty,
          reason: 'इनमें देवनागरी रह गई:\n${risav.take(10).join('\n')}');
    });

    test('मशीन-अनुवाद की चेतावनी आठों भाषाओं में मौजूद है', () {
      // गहरा पाठ मशीन ने अनुवाद किया है, इसलिए हर उस भाषा में चेतावनी
      // ज़रूरी है — वरना किसान उसे जाँचा हुआ मान लेगा।
      for (final l in langs) {
        expect(kMachineTxWarning[l], isNotNull, reason: '$l की चेतावनी नहीं है');
        expect(kMachineTxWarning[l]!.length, greaterThan(40),
            reason: '$l की चेतावनी बहुत छोटी है');
        expect(kMachineTxWarning[l], contains('KVK'),
            reason: '$l में किससे पूछें, यह नहीं लिखा');
      }
      // हिंदी/अंग्रेज़ी मूल हैं — उनमें चेतावनी नहीं होनी चाहिए
      expect(kMachineTxWarning['hi'], isNull);
      expect(kMachineTxWarning['en'], isNull);
    });

    test('जाँची हुई पुरानी परत मशीन वाली पर भारी पड़ती है', () {
      // kPalanI18nCore हाथ से बनाई गई थी। अगर वही वाक्य मशीन वाली परत में
      // भी हो, तो दिखना जाँचा हुआ ही चाहिए।
      for (final hi in kPalanI18nCore.keys) {
        expect(kPalanI18n[hi]!['ta'], kPalanI18nCore[hi]!['ta'],
            reason: '"$hi" पर मशीन वाला अनुवाद हावी हो गया');
      }
    });
  });
}
