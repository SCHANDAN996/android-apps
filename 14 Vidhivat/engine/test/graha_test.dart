import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// पाँच तारा-ग्रह और राहु — `graha.dart` (→ D-098, docs/29 चरण K1)।
///
/// तीन तरह की जाँच, तीन अलग स्रोतों से:
///
/// 1. **VSOP87 के अपने जाँच-मान** (`vsop87.chk`) — तालिका सही उतरी या नहीं।
/// 2. **NASA JPL Horizons** — 5 ग्रह × 20 तारीख़ें, 1930 से 2040। यह पूरी
///    कड़ी की जाँच है: तालिका, प्रकाश का समय, aberration, नतांश।
/// 3. **प्रकृति के नियम** — विपरीत (opposition) पर बाहरी ग्रह वक्री होता है,
///    राहु 18.6 साल में लौटता है। इनके लिए कोई बाहरी डेटा नहीं चाहिए।
///
/// ⚠️ D-014: मिलाने के लिए गणित नहीं बिगाड़ा जाता। नीचे की हदें **नापकर**
/// रखी गई हैं — जो फ़र्क़ आज है उससे थोड़ी ढीली — ताकि आगे कोई बदलाव
/// चुपचाप सटीकता न घटा दे।
void main() {
  const vikala = 1 / 3600.0; // एक विकला, डिग्री में

  final horizons =
      jsonDecode(File('test/data/horizons_graha.json').readAsStringSync())
          as Map<String, dynamic>;
  final jd = (horizons['jdTt'] as List).map((x) => (x as num).toDouble()).toList();
  final pind = horizons['pind'] as Map<String, dynamic>;

  group('VSOP87 की तालिका', () {
    final chk = jsonDecode(File('test/data/vsop_chk.json').readAsStringSync())
        as Map<String, dynamic>;

    test('छँटी हुई शृंखला पूरी शृंखला के जाँच-मानों से मिलती है', () {
      final maan = chk['maan'] as List;
      expect(maan, hasLength(12)); // छह पिंड × दो तारीख़ें
      for (final m in maan.cast<Map<String, dynamic>>()) {
        final naam = m['pind'] as String;
        final jde = (m['jde'] as num).toDouble();
        final h = naam == 'prithvi'
            ? earthHeliocentric(jde)
            : grahaHeliocentric(Graha.values.byName(naam), jde);
        final l = norm360((m['l'] as num) * 180 / math.pi);
        final b = (m['b'] as num) * 180 / math.pi;
        final kahan = '$naam @ $jde';
        // छँटाई से नापी हुई ग़लती 0.42" तक है (`vsop_data.dart` का सिर)
        expect(norm180(h.longitude - l).abs(), lessThan(0.6 * vikala),
            reason: '$kahan L');
        expect((h.latitude - b).abs(), lessThan(0.6 * vikala),
            reason: '$kahan B');
        expect((h.distance - (m['r'] as num)).abs(), lessThan(4e-6),
            reason: '$kahan R');
      }
    });
  });

  group('Meeus की मिसाल — शुक्र, 20 दिसम्बर 1992', () {
    // अध्याय 32–33 की हल की हुई मिसाल: JDE 2448976.5 (0h TD)।
    const jde = 2448976.5;

    test('सूर्य-केंद्रित स्थिति (मिसाल 32.a)', () {
      final h = grahaHeliocentric(Graha.shukra, jde);
      expect(h.longitude, closeTo(26.11428, 0.0005));
      expect(h.latitude, closeTo(-2.62070, 0.0005));
      expect(h.distance, closeTo(0.724603, 0.000005));
    });

    test('पृथ्वी से आभासी स्थिति (मिसाल 33.a) — RA 21h04m41.50s, δ −18°53′16.9″',
        () {
      final a = grahaApparent(Graha.shukra, jde);
      final eps = trueObliquity(jde);
      double r(double d) => d * math.pi / 180;
      final ra = norm360(math.atan2(
              math.sin(r(a.longitude)) * math.cos(r(eps)) -
                  math.tan(r(a.latitude)) * math.sin(r(eps)),
              math.cos(r(a.longitude))) *
          180 /
          math.pi);
      final dec = math.asin(math.sin(r(a.latitude)) * math.cos(r(eps)) +
              math.cos(r(a.latitude)) *
                  math.sin(r(eps)) *
                  math.sin(r(a.longitude))) *
          180 /
          math.pi;
      // 21h04m41.50s = 316.17292°; −18°53′16.9″ = −18.88803°
      expect(ra, closeTo(316.17292, 1.5 * vikala));
      expect(dec, closeTo(-18.88803, 1.5 * vikala));
      expect(a.distance, closeTo(0.910947, 0.00001));
    });
  });

  group('JPL Horizons से मिलान — 1930 से 2040', () {
    test('डेटा पूरा है: 20 तारीख़ें, पाँचों ग्रह', () {
      expect(jd, hasLength(20));
      for (final g in Graha.values) {
        expect(pind[g.name], hasLength(20), reason: g.name);
      }
      // 1930 से 2040 तक फैला हुआ
      expect(utcFromJulianDay(jd.first).year, 1930);
      expect(utcFromJulianDay(jd.last).year, inInclusiveRange(2039, 2040));
    });

    for (final g in Graha.values) {
      test('${g.naam}: देशांतर और अक्षांश 2 विकला के भीतर', () {
        // नापा हुआ (2 अक्तूबर 2026): सबसे बड़ा फ़र्क़ देशांतर में 0.63",
        // अक्षांश में 0.32"। हद 2" — कुंडली को 60" (एक कला) चाहिए।
        final rows = pind[g.name] as List;
        for (var i = 0; i < jd.length; i++) {
          final a = grahaApparent(g, jd[i]);
          final hl = (rows[i][0] as num).toDouble();
          final hb = (rows[i][1] as num).toDouble();
          final kahan = '${g.name} @ ${jd[i]}';
          expect(norm180(a.longitude - hl).abs(), lessThan(2 * vikala),
              reason: '$kahan देशांतर: ${a.longitude} बनाम $hl');
          expect((a.latitude - hb).abs(), lessThan(2 * vikala),
              reason: '$kahan अक्षांश: ${a.latitude} बनाम $hb');
        }
      });
    }

    /// ये दो जाँचें ग्रहों की नहीं, **पंचांग की रीढ़** की हैं — पर डेटा उसी
    /// खेप का है। सूर्य और चंद्र के सूत्र नहीं बदले गए; यह सिर्फ़ दर्ज
    /// करता है कि वे आज कितने सही हैं, ताकि आगे कोई उन्हें अनजाने में
    /// न बिगाड़े।
    test('पंचांग का सूर्य Horizons से 0.01° के भीतर है (उसका अपना वादा)', () {
      // नापा हुआ: सबसे बड़ा फ़र्क़ 21.5"। `sun.dart` का वादा 36" (0.01°)।
      final rows = pind['surya'] as List;
      for (var i = 0; i < jd.length; i++) {
        final d = norm180(sunApparentLongitude(jd[i]) - (rows[i][0] as num));
        expect(d.abs(), lessThan(0.01), reason: 'सूर्य @ ${jd[i]}: $d°');
      }
    });

    test('पंचांग का चंद्र Horizons से 15 विकला के भीतर है', () {
      // नापा हुआ: देशांतर में 9.9", अक्षांश में 1.6"।
      final rows = pind['chandra'] as List;
      for (var i = 0; i < jd.length; i++) {
        final d = norm180(moonLongitude(jd[i]) - (rows[i][0] as num));
        expect(d.abs(), lessThan(15 * vikala), reason: 'चंद्र @ ${jd[i]}');
        expect((moonLatitude(jd[i]) - (rows[i][1] as num)).abs(),
            lessThan(4 * vikala),
            reason: 'चंद्र का अक्षांश @ ${jd[i]}');
      }
    });

    test('VSOP से निकला सूर्य Horizons से 1 विकला के भीतर — तालिका की स्वतंत्र जाँच',
        () {
      final rows = pind['surya'] as List;
      for (var i = 0; i < jd.length; i++) {
        final d = norm180(sunLongitudeVsop(jd[i]) - (rows[i][0] as num));
        expect(d.abs(), lessThan(1 * vikala), reason: 'सूर्य (VSOP) @ ${jd[i]}');
      }
    });
  });

  group('वक्री और मार्गी — प्रकृति का नियम', () {
    final shuru = julianDay(2026, 1, 1);

    /// [g] की सूर्य से दूरी; `jde` पर।
    double doori(Graha g, double jde) =>
        grahaSuryaSeDoori(g, jde, sunApparentLongitude(jde));

    for (final g in [Graha.mangal, Graha.guru, Graha.shani]) {
      test('${g.naam}: सूर्य के ठीक सामने (विपरीत) हो तो वक्री', () {
        // अगले ~800 दिनों में वह दिन जब ग्रह सूर्य से सबसे दूर (≈180°) है।
        var best = shuru, bestD = 0.0;
        for (var t = shuru; t < shuru + 800; t += 1) {
          final d = doori(g, t);
          if (d > bestD) {
            bestD = d;
            best = t;
          }
        }
        expect(bestD, greaterThan(170), reason: 'विपरीत मिला ही नहीं');
        expect(grahaVakri(g, best), isTrue);
        expect(grahaGati(g, best), lessThan(0));
      });

      test('${g.naam}: सूर्य के पास (युति) हो तो मार्गी', () {
        var best = shuru, bestD = 999.0;
        for (var t = shuru; t < shuru + 800; t += 1) {
          final d = doori(g, t);
          if (d < bestD) {
            bestD = d;
            best = t;
          }
        }
        expect(bestD, lessThan(5), reason: 'युति मिली ही नहीं');
        expect(grahaVakri(g, best), isFalse);
      });
    }

    for (final g in [Graha.budh, Graha.shukra]) {
      test('${g.naam}: सूर्य से कभी बहुत दूर नहीं जाता', () {
        // भीतरी ग्रह — बुध ~28° और शुक्र ~47° से आगे नहीं निकल सकता।
        final hadd = g == Graha.budh ? 29.0 : 48.5;
        for (var t = shuru; t < shuru + 800; t += 3) {
          expect(doori(g, t), lessThan(hadd), reason: '${g.name} @ $t');
        }
      });

      test('${g.naam}: पृथ्वी के सबसे पास हो (निचली युति) तो वक्री', () {
        var best = shuru, bestR = 99.0;
        for (var t = shuru; t < shuru + 800; t += 1) {
          final r = grahaApparent(g, t).distance;
          if (r < bestR) {
            bestR = r;
            best = t;
          }
        }
        expect(grahaVakri(g, best), isTrue);
        expect(doori(g, best), lessThan(12));
      });
    }

    test('हर ग्रह ज़्यादातर समय मार्गी रहता है', () {
      for (final g in Graha.values) {
        var vakri = 0, kul = 0;
        for (var t = shuru; t < shuru + 3650; t += 5) {
          kul++;
          if (grahaVakri(g, t)) vakri++;
        }
        // मंगल ~9%, बुध ~19%, गुरु ~30%, शुक्र ~7%, शनि ~36%
        expect(vakri / kul, inInclusiveRange(0.04, 0.42), reason: g.name);
      }
    });
  });

  group('निरयन', () {
    test('निरयन = सायन − लाहिड़ी अयनांश', () {
      final t = julianDay(2026, 10, 2);
      for (final g in Graha.values) {
        final farq =
            norm180(grahaLongitude(g, t) - grahaNirayan(g, t) - lahiriAyanamsa(t));
        expect(farq.abs(), lessThan(1e-9), reason: g.name);
      }
    });
  });

  group('राहु और केतु', () {
    test('J2000 पर औसत राहु — सूत्र का अचर पद', () {
      expect(rahuMadhya(j2000), closeTo(125.0445479, 1e-9));
    });

    test('राहु उलटा चलता है — रोज़ लगभग 3 कला', () {
      final t = julianDay(2026, 10, 2);
      final chaal = norm180(rahuMadhya(t + 1) - rahuMadhya(t));
      expect(chaal, closeTo(-0.05295, 0.0001));
    });

    test('18.6 साल में एक चक्कर', () {
      final t = julianDay(2026, 10, 2);
      // पात का नाक्षत्र आवर्त ~6798 दिन
      expect(norm180(rahuMadhya(t + 6798.4) - rahuMadhya(t)).abs(),
          lessThan(0.05));
    });

    /// स्पष्ट पात का सूत्र पाँच पदों का सन्निकट रूप है। Horizons चंद्र-कक्षा
    /// का क्षण-विशेष का पात देता है (J2000 के क्रांतिवृत्त में); उसे उस दिन
    /// के विषुव में लाने के लिए अयन-चलन जोड़ा जाता है।
    test('स्पष्ट राहु JPL Horizons के पात से 0.25° के भीतर — औसत 1.7° तक हटता है',
        () {
      final p = horizons['chandraPaat'] as Map<String, dynamic>;
      final jds = (p['jdTdb'] as List).cast<num>();
      final om = (p['omJ2000'] as List).cast<num>();
      expect(jds, hasLength(30));
      var badaSpasht = 0.0, badaMadhya = 0.0;
      for (var i = 0; i < jds.length; i++) {
        final t = jds[i].toDouble();
        final sadi = (t - j2000) / 36525.0;
        // सामान्य अयन-चलन (देशांतर में), डिग्री
        final ayan = (5028.796195 * sadi + 1.1054348 * sadi * sadi) / 3600.0;
        final asli = om[i] + ayan;
        final s = norm180(rahuSpasht(t) - asli).abs();
        final m = norm180(rahuMadhya(t) - asli).abs();
        if (s > badaSpasht) badaSpasht = s;
        if (m > badaMadhya) badaMadhya = m;
      }
      // नापा हुआ: स्पष्ट 0.175°, औसत 1.717°
      expect(badaSpasht, lessThan(0.25));
      expect(badaMadhya, inInclusiveRange(1.5, 1.8));
    });

    test('स्पष्ट राहु औसत के इर्द-गिर्द ही झूलता है — कभी 2° से दूर नहीं', () {
      final shuru = julianDay(2020, 1, 1);
      var bada = 0.0;
      for (var t = shuru; t < shuru + 3650; t += 1.3) {
        final d = norm180(rahuSpasht(t) - rahuMadhya(t)).abs();
        if (d > bada) bada = d;
      }
      // पाँचों पदों का जोड़ 1.97° है — उससे आगे जा ही नहीं सकता
      expect(bada, inInclusiveRange(1.5, 1.97));
    });

    test('केतु ठीक सामने', () {
      expect(ketuSe(10), 190);
      expect(ketuSe(200), 20);
    });

    /// राहु वह बिंदु है जहाँ चंद्रमा क्रांतिवृत्त को दक्षिण से उत्तर की ओर
    /// पार करता है। तो जिस क्षण चंद्र का अक्षांश शून्य होकर बढ़ रहा हो,
    /// चंद्रमा राहु पर होना चाहिए — औसत राहु से ~1.7° के भीतर (औसत और
    /// स्पष्ट पात का इतना ही फ़र्क़ रहता है)।
    test('चंद्रमा जहाँ क्रांतिवृत्त को ऊपर की ओर काटता है, वहीं राहु है', () {
      var mile = 0;
      final shuru = julianDay(2020, 1, 1);
      for (var t = shuru; t < shuru + 3650; t += 0.25) {
        final a = moonLatitude(t), b = moonLatitude(t + 0.25);
        if (a < 0 && b >= 0) {
          // ठीक क्षण — रेखा खींचकर
          final x = t + 0.25 * (-a) / (b - a);
          final farq = norm180(moonLongitude(x) - rahuMadhya(x));
          expect(farq.abs(), lessThan(2.0),
              reason: 'JD $x पर चंद्र राहु से $farq° दूर');
          mile++;
        }
      }
      // दस साल में ~134 बार (पात-मास 27.21 दिन)
      expect(mile, inInclusiveRange(130, 138));
    });
  });
}
