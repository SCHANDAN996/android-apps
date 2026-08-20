import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// चंद्रमा की जाँच — अक्षांश, दूरी, लंबन, और चंद्रोदय/चंद्रास्त।
///
/// सबसे ज़रूरी जाँच पहली वाली है: Meeus उदाहरण 47.a। किताब में अक्षांश,
/// दूरी और लंबन तीनों के जवाब दिए हैं, इसलिए तालिका 47.B या Σr में कोई
/// अंक ग़लत टाइप हुआ हो तो वहीं पकड़ा जाएगा — और कहीं नहीं।

void main() {
  group('चंद्रमा की स्थिति', () {
    test('Meeus उदाहरण 47.a — अक्षांश, दूरी और लंबन तीनों', () {
      const jde = 2448724.5; // 12 अप्रैल 1992, 0h TD

      expect(moonLatitude(jde), closeTo(-3.229126, 0.0005),
          reason: 'अक्षांश — तालिका 47.B जाँचो');
      expect(moonDistance(jde), closeTo(368409.7, 1.0),
          reason: 'दूरी — Σr के गुणांक जाँचो');
      expect(moonParallax(jde), closeTo(0.991990, 0.0005),
          reason: 'लंबन');
    });

    test('अक्षांश हमेशा ±5.3° के भीतर रहता है', () {
      for (var day = 0; day < 60; day++) {
        final jde = toEphemerisTime(julianDay(2026, 6, 1.0 + day));
        expect(moonLatitude(jde).abs(), lessThan(5.3), reason: 'दिन $day');
      }
    });

    test('दूरी 356000 से 407000 किमी के बीच रहती है', () {
      for (var day = 0; day < 60; day++) {
        final jde = toEphemerisTime(julianDay(2026, 6, 1.0 + day));
        expect(moonDistance(jde), inInclusiveRange(356000, 407000),
            reason: 'दिन $day');
      }
    });

    test('लंबन दूरी के उल्टा चलता है', () {
      // चंद्रमा पास आए तो लंबन बढ़े — यह ज्यामिति है, कोई तालिका नहीं
      final jde1 = toEphemerisTime(julianDay(2026, 6, 1.0));
      final jde2 = toEphemerisTime(julianDay(2026, 6, 15.0));

      final paasWala = moonDistance(jde1) < moonDistance(jde2) ? jde1 : jde2;
      final doorWala = paasWala == jde1 ? jde2 : jde1;

      expect(moonParallax(paasWala), greaterThan(moonParallax(doorWala)));
    });
  });

  group('चंद्रोदय और चंद्रास्त', () {
    test('चंद्रोदय रोज़ लगभग 50 मिनट पीछे खिसकता है', () {
      DateTime? previous;
      var checked = 0;

      for (var day = 22; day <= 29; day++) {
        final r = moonriseMoonset(2026, 8, day, Place.delhi);
        if (r.moonrise == null) continue;

        if (previous != null) {
          final shift = r.moonrise!.difference(previous).inMinutes - 24 * 60;
          expect(shift, inInclusiveRange(20, 80),
              reason: '8/$day पर खिसकाव $shift मिनट');
          checked++;
        }
        previous = r.moonrise;
      }
      expect(checked, greaterThan(4));
    });

    test('महीने में कोई एक-दो दिन चंद्रोदय या चंद्रास्त छूटता है', () {
      // यह ग़लती नहीं है — चंद्रमा रोज़ ~50 मिनट देर से उगता है, इसलिए
      // महीने में एक बार उदय (या अस्त) उस तारीख़ में पड़ता ही नहीं।
      // छपे पंचांग में भी उस दिन जगह ख़ाली रहती है।
      var missing = 0;
      for (var day = 1; day <= 31; day++) {
        final r = moonriseMoonset(2026, 8, day, Place.delhi);
        if (r.moonrise == null || r.moonset == null) missing++;
      }
      expect(missing, inInclusiveRange(1, 4),
          reason: 'अगस्त 2026 में $missing दिन छूटे');
    });

    test('पूर्णिमा के आसपास चंद्रमा सूर्यास्त के वक़्त उगता है', () {
      // पूर्णिमा को चंद्रमा सूरज के ठीक सामने होता है, इसलिए सूर्यास्त
      // के आसपास उगता है। यह भौतिकी है, परंपरा नहीं — इसलिए यह जाँच
      // स्थिति और समय दोनों को एक साथ परखती है।
      final purnima =
          findCrossing(elongationAt, 180.0, julianDay(2026, 8, 20.0), 32);
      expect(purnima, isNotNull);

      final ist = utcFromJulianDay(purnima!)
          .add(const Duration(hours: 5, minutes: 30));
      final p = computePanchang(ist.year, ist.month, ist.day, Place.delhi);

      expect(p.moonrise, isNotNull);
      final gap = p.moonrise!.difference(p.sunset!).inMinutes.abs();
      expect(gap, lessThan(90), reason: 'पूर्णिमा पर $gap मिनट का फ़र्क़');
    });

    test('अमावस्या के आसपास चंद्रमा सूर्योदय के वक़्त उगता है', () {
      final amavasya = previousNewMoon(julianDay(2026, 10, 20.0));
      final ist = utcFromJulianDay(amavasya)
          .add(const Duration(hours: 5, minutes: 30));
      final p = computePanchang(ist.year, ist.month, ist.day, Place.delhi);

      if (p.moonrise == null) return; // उस दिन उदय न पड़ा हो तो छोड़ दो
      final gap = p.moonrise!.difference(p.sunrise!).inMinutes.abs();
      expect(gap, lessThan(90), reason: 'अमावस्या पर $gap मिनट का फ़र्क़');
    });

    test('चंद्रोदय के क्षण चंद्रमा ठीक दहलीज़ पर होता है', () {
      final r = moonriseMoonset(2026, 8, 20, Place.delhi);
      final jd = julianDayFromUtc(
          r.moonrise!.subtract(const Duration(hours: 5, minutes: 30)));

      final expectedHorizon =
          0.7275 * moonParallax(toEphemerisTime(jd)) - 0.5667;
      expect(moonAltitude(jd, Place.delhi), closeTo(expectedHorizon, 0.01));
    });

    test('दक्षिण के शहर में भी चलता है', () {
      final r = moonriseMoonset(2026, 8, 20, Place.chennai);
      expect(r.moonrise, isNotNull);
      expect(r.moonset, isNotNull);
      expect(r.moonrise!.isBefore(r.moonset!), isTrue);
    });

    test('Drik से फ़र्क़ 6 मिनट के भीतर है — परिभाषा अलग होने की वजह से', () {
      // ⚠️ यह जाँच "सही" की नहीं, **जानी-पहचानी दूरी** की है।
      //
      // Drik की दहलीज़ हमसे अलग है — उसके बताए क्षण पर हमारी गणना में
      // चंद्रमा +0.97° पर होता है, जबकि Meeus का मानक +0.09° कहता है।
      // हमने मानक रखा और मिलाने के लिए गणित नहीं बिगाड़ा (D-014)।
      // पूरा ब्यौरा moonrise.dart की टिप्पणी में।
      //
      // अगर यह जाँच कभी टूटे तो या तो सूत्र बदला गया है, या स्थिति में
      // कोई असली ग़लती आ गई है — दोनों जाँचने लायक हैं।
      final r = moonriseMoonset(2026, 8, 20, Place.delhi);

      final drikRise = DateTime.utc(2026, 8, 20, 13, 16);
      final drikSet = DateTime.utc(2026, 8, 20, 23, 24);

      expect(r.moonrise!.difference(drikRise).inMinutes.abs(), lessThan(6),
          reason: 'चंद्रोदय');
      expect(r.moonset!.difference(drikSet).inMinutes.abs(), lessThan(6),
          reason: 'चंद्रास्त');
    });

    test('घुंडी घुमाने से Drik से मिलान हो जाता है', () {
      // यह साबित करता है कि फ़र्क़ सिर्फ़ दहलीज़ का है, स्थिति का नहीं।
      // घुंडी 0.88° पर रखो तो Drik से एक मिनट के भीतर मिल जाता है।
      moonHorizonAdjustment = 0.88;
      try {
        final r = moonriseMoonset(2026, 8, 20, Place.delhi);
        expect(r.moonrise!.difference(DateTime.utc(2026, 8, 20, 13, 16))
            .inMinutes.abs(), lessThanOrEqualTo(1));
        expect(r.moonset!.difference(DateTime.utc(2026, 8, 20, 23, 24))
            .inMinutes.abs(), lessThanOrEqualTo(1));
      } finally {
        moonHorizonAdjustment = 0.0; // वापस मानक पर
      }
    });
  });

  group('पंचांग में चंद्रोदय', () {
    test('Panchang में जुड़ा हुआ है', () {
      final p = computePanchang(2026, 8, 20, Place.delhi);
      expect(p.moonrise, isNotNull);
      expect(p.moonset, isNotNull);
    });

    test('null होना ग़लती नहीं मानी जाती', () {
      // पूरे महीने में कहीं न कहीं null आएगा ही, और वो सामान्य है
      var nullMile = false;
      for (var day = 1; day <= 31; day++) {
        final p = computePanchang(2026, 8, day, Place.delhi);
        if (p.moonrise == null || p.moonset == null) nullMile = true;
      }
      expect(nullMile, isTrue, reason: 'महीने में एक बार तो छूटना ही चाहिए');
    });
  });
}
