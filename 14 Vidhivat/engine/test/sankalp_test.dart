import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// संकल्प जनरेटर की जाँच।
///
/// ⚠️ यहाँ **संस्कृत की शुद्धता नहीं जाँची जा सकती** — वो पंडित जी का
/// काम है। यहाँ सिर्फ़ यह जाँचा जाता है कि पंचांग के सारे मान सही जगह
/// भर रहे हैं और कोई हिस्सा छूट नहीं रहा।

const details = SankalpDetails(
  name: 'चन्दन सिंह',
  gotra: 'कश्यप',
  place: 'दिल्ली',
  purpose: 'श्री सत्यनारायण पूजनं',
);

void main() {
  group('संकल्प — पंचांग के सारे मान भरते हैं', () {
    final p = computePanchang(2026, 8, 20, Place.delhi);
    final s = buildSankalp(p, details);

    test('संवत् और संवत्सर आते हैं', () {
      expect(s.full, contains('सिद्धार्थी'));
      expect(s.simple, contains('2083'));
    });

    test('अयन, ऋतु, मास, पक्ष सब आते हैं', () {
      expect(s.full, contains('दक्षिणायने'));
      expect(s.full, contains('वर्षा ऋतौ'));
      expect(s.full, contains('श्रावण मासे'));
      expect(s.full, contains('शुक्ल पक्षे'));
    });

    test('तिथि, वार, नक्षत्र सब आते हैं', () {
      expect(s.full, contains('अष्टमी तिथौ'));
      expect(s.full, contains('गुरुवासरे'));
      expect(s.full, contains('विशाखा नक्षत्रे'));
    });

    test('यजमान की जानकारी आती है', () {
      expect(s.full, contains('कश्यप गोत्रोत्पन्नः'));
      expect(s.full, contains('चन्दन सिंह'));
      expect(s.full, contains('श्री सत्यनारायण पूजनं करिष्ये'));
      expect(s.full, contains('दिल्ली क्षेत्रे'));
    });

    test('सरल रूप में भी सब कुछ है, पर हिंदी में', () {
      expect(s.simple, contains('दक्षिणायन'));
      expect(s.simple, contains('श्रावण'));
      expect(s.simple, contains('गुरुवार'));
      expect(s.simple, contains('विशाखा'));
      expect(s.simple, contains('चन्दन सिंह'));
    });

    test('चौदह हिस्से अलग-अलग मिलते हैं', () {
      expect(s.parts.length, 14);
      for (final part in s.parts) {
        expect(part.label, isNotEmpty);
        expect(part.value, isNotEmpty);
      }
    });

    test('पंडित जी की जाँच बाक़ी है — यह झंडी हमेशा लगी रहे', () {
      // जब तक कोई पंडित जी संस्कृत पास न कर दें, ऐप को चेतावनी दिखानी है
      expect(s.needsPanditReview, isTrue);
    });
  });

  group('हर दिन और हर जगह चलता है', () {
    test('अधिक मास में "अधिक" लिखा आता है', () {
      // 2026 में अधिक ज्येष्ठ — 17 मई से 15 जून
      final p = computePanchang(2026, 6, 1, Place.delhi);
      final s = buildSankalp(p, details);
      expect(s.full, contains('अधिक ज्येष्ठ मासे'));
    });

    test('उत्तरायण में सही रूप आता है', () {
      final p = computePanchang(2026, 1, 20, Place.delhi);
      expect(buildSankalp(p, details).full, contains('उत्तरायणे'));
    });

    test('कृष्ण पक्ष में सही रूप आता है', () {
      final p = computePanchang(2026, 10, 10, Place.delhi);
      expect(buildSankalp(p, details).full, contains('कृष्ण पक्षे'));
    });

    test('जगह बदलने पर क्षेत्र बदलता है', () {
      final p = computePanchang(2026, 8, 20, Place.chennai);
      const chennaiDetails = SankalpDetails(
        name: 'राम', gotra: 'भारद्वाज', place: 'चेन्नई',
        purpose: 'देवपूजनं',
      );
      expect(buildSankalp(p, chennaiDetails).full, contains('चेन्नई क्षेत्रे'));
    });

    test('साल भर कभी ख़ाली नहीं आता', () {
      var day = DateTime.utc(2026, 1, 1);
      while (day.year == 2026) {
        final p = computePanchang(day.year, day.month, day.day, Place.delhi);
        final s = buildSankalp(p, details);

        expect(s.full.length, greaterThan(200), reason: '$day');
        expect(s.full, isNot(contains('null')), reason: '$day');
        expect(s.parts.length, 14, reason: '$day');

        day = day.add(const Duration(days: 7));
      }
    });
  });

  group('नामों की सूचियाँ पंचांग से मेल खाती हैं', () {
    test('वार, अयन, पक्ष — तीनों की गिनती वही है', () {
      expect(sankalpNamesAreConsistent(), isTrue);
      expect(sankalpVaraCount, 7);
    });

    test('हर वार का संकल्प-रूप "वासरे" पर ख़त्म होता है', () {
      for (var v = 0; v < 7; v++) {
        expect(sankalpVaraName(v), endsWith('वासरे'));
      }
    });

    test('आम पूजाओं और गोत्रों की सूचियाँ भरी हुई हैं', () {
      expect(commonPurposes.length, greaterThanOrEqualTo(10));
      expect(commonGotras.length, greaterThanOrEqualTo(10));
      expect(commonGotras, contains('कश्यप'));
    });
  });
}
