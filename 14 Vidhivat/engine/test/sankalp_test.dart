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
      // सन्धि और समास बनकर — अलग-अलग नहीं (→ A7)।
      expect(s.full, contains('वर्षर्तौ'));
      expect(s.full, contains('श्रावणमासे'));
      expect(s.full, contains('शुक्लपक्षे'));
    });

    test('तिथि, वार, नक्षत्र सब आते हैं', () {
      // सप्तमी विभक्ति में — "अष्टमी तिथौ" नहीं (→ A2, D-041)।
      expect(s.full, contains('अष्टम्यां तिथौ'));
      expect(s.full, isNot(contains('अष्टमी तिथौ')));
      expect(s.full, contains('गुरुवासरे'));
      expect(s.full, contains('विशाखानक्षत्रे'));
    });

    test('यजमान की जानकारी आती है', () {
      // समास बनकर — "कश्यप गोत्रोत्पन्नः" अलग-अलग नहीं (→ A7)।
      expect(s.full, contains('कश्यपगोत्रोत्पन्नः'));
      expect(s.full, contains('चन्दन सिंह'));
      expect(s.full, contains('श्री सत्यनारायण पूजनं करिष्ये'));
    });

    test('जगह "क्षेत्रे" नहीं, "नाम्नि नगरे" के साथ आती है (→ A5)', () {
      expect(s.full, contains('दिल्लीनाम्नि नगरे'));
      // पुराना रूप कहीं बचा तो नहीं
      expect(s.full, isNot(contains('दिल्ली क्षेत्रे')));
    });

    test('नाम "अहं" नहीं, "नामाहम्" के साथ आता है (→ A11)', () {
      // दो शब्दों का नाम जोड़ा नहीं जाता — "चन्दन सिंहनामाहम्" अटपटा है
      expect(s.full, contains('चन्दन सिंह नामाहम्'));
      expect(s.full, isNot(contains('चन्दन सिंह अहं')));
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
    test('अधिक मास में "अधिकज्येष्ठमासे" आता है', () {
      // 2026 में अधिक ज्येष्ठ — 17 मई से 15 जून
      final p = computePanchang(2026, 6, 1, Place.delhi);
      final s = buildSankalp(p, details);
      // समास बनकर (→ A7, A8)। "अधिक" रखा गया है — देखो docs/18 §1.8।
      expect(s.full, contains('अधिकज्येष्ठमासे'));
    });

    test('उत्तरायण में सही रूप आता है', () {
      final p = computePanchang(2026, 1, 20, Place.delhi);
      expect(buildSankalp(p, details).full, contains('उत्तरायणे'));
    });

    test('कृष्ण पक्ष में सही रूप आता है', () {
      final p = computePanchang(2026, 10, 10, Place.delhi);
      expect(buildSankalp(p, details).full, contains('कृष्णपक्षे'));
    });

    test('जगह बदलने पर जगह का नाम बदलता है', () {
      final p = computePanchang(2026, 8, 20, Place.chennai);
      const chennaiDetails = SankalpDetails(
        name: 'राम', gotra: 'भारद्वाज', place: 'चेन्नई',
        purpose: 'देवपूजनं',
      );
      expect(buildSankalp(p, chennaiDetails).full, contains('चेन्नईनाम्नि नगरे'));
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

  group('यजमान का लिंग — A3', () {
    final p = computePanchang(2026, 8, 20, Place.delhi);

    const purushDetails = SankalpDetails(
      name: 'चन्दन सिंह', gotra: 'कश्यप', place: 'दिल्ली',
      purpose: 'श्री सत्यनारायण पूजनं',
      yajaman: Yajaman.purush,
    );
    const striDetails = SankalpDetails(
      name: 'सीता देवी', gotra: 'भारद्वाज', place: 'दिल्ली',
      purpose: 'श्री सत्यनारायण पूजनं',
      yajaman: Yajaman.stri,
    );

    test('पुरुष — गोत्रोत्पन्नः और नामाहम्', () {
      final s = buildSankalp(p, purushDetails);
      expect(s.full, contains('कश्यपगोत्रोत्पन्नः'));
      expect(s.full, contains('चन्दन सिंह नामाहम्'));
    });

    test('स्त्री — गोत्रोत्पन्ना और नाम्नी अहम्', () {
      final s = buildSankalp(p, striDetails);
      expect(s.full, contains('भारद्वाजगोत्रोत्पन्ना'));
      expect(s.full, contains('सीता देवी नाम्नी अहम्'));
      // पुल्लिंग रूप कहीं बचा तो नहीं — यही असली बग था
      expect(s.full, isNot(contains('गोत्रोत्पन्नः')));
      expect(s.full, isNot(contains('नामाहम्')));
    });

    test('एक शब्द का नाम जुड़ता है, दो शब्दों का नहीं', () {
      const ekShabd = SankalpDetails(
        name: 'राम', gotra: 'कश्यप', place: 'दिल्ली', purpose: 'देवपूजनं',
      );
      expect(buildSankalp(p, ekShabd).full, contains('रामनामाहम्'));
      expect(buildSankalp(p, purushDetails).full,
          contains('चन्दन सिंह नामाहम्'));
    });

    test('सरल (हिंदी) रूप भी लिंग से मिलता है', () {
      expect(buildSankalp(p, purushDetails).simple, contains('जन्मा'));
      expect(buildSankalp(p, purushDetails).simple, contains('लेता हूँ'));
      expect(buildSankalp(p, striDetails).simple, contains('जन्मी'));
      expect(buildSankalp(p, striDetails).simple, contains('लेती हूँ'));
      // "जन्मा/जन्मी" वाला दोनों-एक-साथ रूप अब कहीं नहीं
      expect(buildSankalp(p, striDetails).simple, isNot(contains('जन्मा/जन्मी')));
    });

    test('कुछ न बताया जाए तो पुरुष ही मानता है (पुराना बर्ताव)', () {
      const bina = SankalpDetails(
        name: 'राम', gotra: 'कश्यप', place: 'दिल्ली', purpose: 'देवपूजनं',
      );
      expect(buildSankalp(p, bina).full, contains('गोत्रोत्पन्नः'));
    });
  });

  group('जगह किस तरह की है — A5', () {
    final p = computePanchang(2026, 8, 20, Place.delhi);

    SankalpDetails withPrakar(String place, SthanPrakar prakar) =>
        SankalpDetails(
          name: 'राम', gotra: 'कश्यप', place: place,
          purpose: 'देवपूजनं', sthanPrakar: prakar,
        );

    test('नगर — गुड़गाँवनाम्नि नगरे', () {
      expect(buildSankalp(p, withPrakar('गुड़गाँव', SthanPrakar.nagar)).full,
          contains('गुड़गाँवनाम्नि नगरे'));
    });

    test('गाँव — ग्रामे', () {
      expect(buildSankalp(p, withPrakar('रामपुर', SthanPrakar.gram)).full,
          contains('रामपुरनाम्नि ग्रामे'));
    });

    test('तीर्थ — पुण्यक्षेत्रे', () {
      expect(buildSankalp(p, withPrakar('काशी', SthanPrakar.kshetra)).full,
          contains('काशीनाम्नि पुण्यक्षेत्रे'));
    });

    test('हर शहर पर "क्षेत्रे" लगाने वाला पुराना बग वापस न आए', () {
      // यही मूल शिकायत थी — "गुड़गाँव क्षेत्रे", "नोएडा क्षेत्रे"
      for (final shahar in ['गुड़गाँव', 'नोएडा', 'इंदौर', 'पटना']) {
        final full = buildSankalp(p, withPrakar(shahar, SthanPrakar.nagar)).full;
        expect(full, isNot(contains('$shahar क्षेत्रे')), reason: shahar);
        expect(full, contains('${shahar}नाम्नि नगरे'), reason: shahar);
      }
    });

    test('कुछ न बताया जाए तो नगर ही मानता है', () {
      const bina = SankalpDetails(
        name: 'राम', gotra: 'कश्यप', place: 'दिल्ली', purpose: 'देवपूजनं',
      );
      expect(buildSankalp(p, bina).full, contains('दिल्लीनाम्नि नगरे'));
    });
  });

  group('सन्धि और समास — A7', () {
    test('छहों ऋतुएँ सन्धि किए हुए रूप में हैं', () {
      // नियम: अ/आ + ऋ → अर् (गुण)। इसलिए सब "र्तौ" पर ख़त्म होती हैं…
      for (var r = 0; r < 6; r++) {
        final rup = sankalpRituName(r);
        if (rup != 'शरदृतौ') {
          expect(rup, endsWith('र्तौ'), reason: 'ऋतु $r → $rup');
        }
        // …और कहीं भी अलग खड़ा "ऋतौ" नहीं बचा
        expect(rup, isNot(contains(' ')), reason: 'ऋतु $r में जगह बची है');
      }
    });

    test('शरद् अलग चलती है — दकारान्त है, गुण नहीं लगता', () {
      expect(sankalpRituName(3), 'शरदृतौ');
    });

    test('दो शब्दों वाले नक्षत्र भी जुड़ते हैं', () {
      // "पूर्वा फाल्गुनी" जैसे नाम — बीच की जगह हटनी चाहिए
      final p = computePanchang(2026, 3, 1, Place.delhi);
      final full = buildSankalp(p, details).full;
      final line =
          full.split('\n').firstWhere((l) => l.contains('नक्षत्रे'));
      expect(line, isNot(contains(' नक्षत्रे')),
          reason: 'नक्षत्र का नाम अलग खड़ा है: $line');
    });

    test('साल भर कहीं भी अलग खड़ा पद नहीं बचता', () {
      // यही A7 की असली जाँच है — किसी भी दिन "X मासे" जैसा टूटा जोड़ा
      // नहीं बनना चाहिए।
      var day = DateTime.utc(2026, 1, 1);
      while (day.year == 2026) {
        final p = computePanchang(day.year, day.month, day.day, Place.delhi);
        final full = buildSankalp(p, details).full;
        for (final pad in [' मासे', ' पक्षे', ' नक्षत्रे', ' ऋतौ']) {
          expect(full, isNot(contains(pad)), reason: '$day पर "$pad" अलग खड़ा है');
        }
        day = day.add(const Duration(days: 5));
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

    test('तीसों तिथियाँ सप्तमी विभक्ति में हैं — कोई प्रथमा नहीं बची', () {
      // ईकारान्त/आकारान्त स्त्रीलिंग का सप्तमी एकवचन "-ां" पर ख़त्म
      // होता है (नवम्यां, द्वितीयायां)। एक ही अपवाद प्रतिपदा है —
      // *प्रतिपद्* दकारान्त है, इसलिए "प्रतिपदि"।
      for (var t = 0; t < 30; t++) {
        final rup = sankalpTithiName(t);
        expect(rup, isNotEmpty, reason: 'तिथि $t');
        if (rup != 'प्रतिपदि') {
          expect(rup, endsWith('ां'), reason: 'तिथि $t → $rup');
        }
        // प्रथमा वाला रूप कहीं बचा तो नहीं
        expect(tithiNames[t] == rup, isFalse, reason: 'तिथि $t अब भी प्रथमा में');
      }
    });

    test('दोनों पक्षों के दोनों अपवाद सही हैं', () {
      expect(sankalpTithiName(0), 'प्रतिपदि');       // शुक्ल प्रतिपदा
      expect(sankalpTithiName(8), 'नवम्यां');        // शुक्ल नवमी
      expect(sankalpTithiName(14), 'पौर्णमास्यां');  // पूर्णिमा
      expect(sankalpTithiName(15), 'प्रतिपदि');      // कृष्ण प्रतिपदा
      expect(sankalpTithiName(29), 'अमावास्यायां');  // अमावस्या
    });

    test('आम पूजाओं और गोत्रों की सूचियाँ भरी हुई हैं', () {
      expect(commonPurposes.length, greaterThanOrEqualTo(10));
      expect(commonGotras.length, greaterThanOrEqualTo(10));
      expect(commonGotras, contains('कश्यप'));
    });
  });
}
