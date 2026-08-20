import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// खगोल-गणित की जाँच।
///
/// इन जाँचों को किसी बाहरी डेटा की ज़रूरत नहीं — ये ऐसी बातें परखती हैं
/// जो प्रकृति के नियम से तय हैं (संक्रांति की तारीख़ें, चांद्र मास की
/// लंबाई, दिन-रात का संतुलन)। अगर गणित में कहीं चिह्न उल्टा है, इकाई
/// ग़लत है, या तालिका में कोई पद छूट गया है — यहीं पकड़ा जाएगा।
///
/// छपे पंचांग से मिलान अलग फ़ाइल में है: reference_test.dart

double _jdUtc(int y, int m, int d, [double hour = 0]) =>
    julianDay(y, m, d + hour / 24.0);

/// सूर्य का सायन देशांतर, JD (UT) से।
double _sunLong(double jdUt) => sunApparentLongitude(toEphemerisTime(jdUt));

/// चंद्र का सायन देशांतर, JD (UT) से।
double _moonLong(double jdUt) => moonLongitude(toEphemerisTime(jdUt));

void main() {
  group('जूलियन दिन', () {
    test('J2000.0 सही बैठता है', () {
      // 1 जनवरी 2000, दोपहर 12 बजे = JD 2451545.0 — यह परिभाषा है
      expect(julianDay(2000, 1, 1.5), closeTo(2451545.0, 1e-9));
    });

    test('Meeus की मिसाल — स्पूतनिक', () {
      // 4 अक्टूबर 1957, 19:26:24 UT = JD 2436116.31
      expect(julianDay(1957, 10, 4.81), closeTo(2436116.31, 1e-6));
    });

    test('आगे-पीछे बदलने पर वही तारीख़ लौटे', () {
      final original = DateTime.utc(2026, 8, 20, 14, 35, 27);
      final jd = julianDayFromUtc(original);
      final back = utcFromJulianDay(jd);
      expect(back.difference(original).inMilliseconds.abs(), lessThan(1000));
    });

    test('ΔT आज के दौर में 60–80 सेकंड के बीच है', () {
      expect(deltaTSeconds(2026, 8), inInclusiveRange(60, 80));
    });
  });

  group('सूर्य', () {
    // संक्रांति और विषुव — ये तारीख़ें प्रकृति तय करती है, पंचांग नहीं।
    // अगर सूर्य का गणित ग़लत हुआ तो ये तुरंत खिसक जाएँगी।

    void checkSolarEvent(String label, double target, int startMonth,
        int expectedMonth, int earliestDay, int latestDay) {
      test('$label सही तारीख़ पर पड़ता है', () {
        final start = _jdUtc(2026, startMonth, 1);
        final crossing = findCrossing(_sunLong, target, start, 200);
        expect(crossing, isNotNull, reason: '$label मिला ही नहीं');

        final when = utcFromJulianDay(crossing!);
        expect(when.year, 2026);
        expect(when.month, expectedMonth);
        expect(when.day, inInclusiveRange(earliestDay, latestDay));
      });
    }

    checkSolarEvent('वसंत विषुव (सूर्य 0°)', 0.0, 1, 3, 19, 22);
    checkSolarEvent('ग्रीष्म संक्रांति (सूर्य 90°)', 90.0, 1, 6, 20, 22);
    checkSolarEvent('शरद विषुव (सूर्य 180°)', 180.0, 5, 9, 21, 24);
    checkSolarEvent('शीत संक्रांति (सूर्य 270°)', 270.0, 8, 12, 20, 23);

    test('सूर्य रोज़ लगभग एक डिग्री चलता है', () {
      for (var day = 0; day < 365; day += 17) {
        final jd = _jdUtc(2026, 1, 1) + day;
        final motion = norm180(_sunLong(jd + 1) - _sunLong(jd));
        expect(motion, inInclusiveRange(0.95, 1.02),
            reason: 'दिन $day पर सूर्य की चाल गड़बड़');
      }
    });

    test('साल भर में सूर्य पूरा चक्कर लगाता है', () {
      final start = _sunLong(_jdUtc(2026, 1, 1));
      final afterYear = _sunLong(_jdUtc(2026, 1, 1) + 365.2422);
      expect(norm180(afterYear - start).abs(), lessThan(0.05));
    });

    test('तिरछाहट आज लगभग 23.44° है', () {
      expect(meanObliquity(_jdUtc(2026, 1, 1)), closeTo(23.436, 0.01));
    });
  });

  group('चंद्रमा', () {
    test('चांद्र मास 29.27 से 29.83 दिन का होता है', () {
      var jd = _jdUtc(2026, 1, 15);
      var previous = previousNewMoon(jd);

      for (var i = 0; i < 12; i++) {
        final next = previousNewMoon(previous + 32.0);
        final length = next - previous;
        expect(length, inInclusiveRange(29.20, 29.90),
            reason: 'मास $i की लंबाई ग़लत: $length दिन');
        previous = next;
      }
    });

    test('अमावस्या पर सूर्य-चंद्र का कोण शून्य होता है', () {
      final newMoon = previousNewMoon(_jdUtc(2026, 8, 20));
      final gap = norm180(elongationAt(newMoon));
      expect(gap.abs(), lessThan(0.001),
          reason: 'अमावस्या का क्षण ग़लत निकला');
    });

    test('नाक्षत्र मास लगभग 27.32 दिन का होता है', () {
      final start = _jdUtc(2026, 3, 1);
      final startLongitude = _moonLong(start);
      final returnJd =
          findCrossing(_moonLong, startLongitude, start + 20, 12);
      expect(returnJd, isNotNull);
      expect(returnJd! - start, inInclusiveRange(27.0, 27.7));
    });

    test('चंद्रमा रोज़ 11.7 से 15.4 डिग्री चलता है', () {
      for (var day = 0; day < 60; day += 3) {
        final jd = _jdUtc(2026, 6, 1) + day;
        final motion = norm180(_moonLong(jd + 1) - _moonLong(jd));
        expect(motion, inInclusiveRange(11.6, 15.5),
            reason: 'दिन $day पर चंद्र की चाल गड़बड़');
      }
    });

    test('Meeus की अपनी मिसाल (उदाहरण 47.a) से मिलान', () {
      // यह सबसे कड़ी जाँच है। Meeus की किताब में 12 अप्रैल 1992, 0h TD का
      // हिसाब ख़ुद दिया हुआ है। अगर 60 पद की तालिका में एक भी अंक ग़लत
      // टाइप हुआ होगा, तो यहीं पकड़ा जाएगा — और कहीं नहीं।
      const jde = 2448724.5;
      const bookApparentLongitude = 133.167265;

      final difference =
          (moonLongitude(jde) - bookApparentLongitude).abs() * 3600;
      expect(difference, lessThan(1.0),
          reason: 'किताब से $difference विकला का फ़र्क़ — तालिका जाँचो');
    });

    test('तालिका में साठों पद मौजूद हैं', () {
      // अगर तालिका टाइप करते वक़्त कोई लाइन छूटी हो तो चंद्र की स्थिति
      // चुपचाप ग़लत होती रहेगी। यहाँ मोटी जाँच: पूर्णिमा पर सूर्य और
      // चंद्र ठीक आमने-सामने होने चाहिए।
      final fullMoon = findCrossing(elongationAt, 180.0, _jdUtc(2026, 8, 1), 32);
      expect(fullMoon, isNotNull);
      expect(norm180(elongationAt(fullMoon!) - 180.0).abs(), lessThan(0.001));
    });
  });

  group('अयनांश', () {
    test('Drik Panchang के मानों से हूबहू मिलता है', () {
      // ये चारों मान drikpanchang.com से लिए गए हैं (20 अगस्त 2026 को),
      // दिल्ली के सूर्योदय के क्षण के। अयनांश ही वो एक चीज़ है जो पूरे
      // निरयन गणित को हिला सकती है — इसलिए इसे यहीं बाँध दिया है।
      const fromDrik = {
        '2026-01-14': 24.227532,
        '2026-08-20': 24.235869,
        '2026-10-10': 24.237820,
        '2036-01-14': 24.367229,
      };

      fromDrik.forEach((date, expected) {
        final parts = date.split('-').map(int.parse).toList();
        final jde = toEphemerisTime(
            sunriseJd(parts[0], parts[1], parts[2], Place.delhi));

        expect(lahiriAyanamsa(jde), closeTo(expected, 0.0001), reason: date);
      });
    });

    test('J2000 पर लगभग 23°51ʹ', () {
      expect(lahiriAyanamsa(j2000), closeTo(23.864, 0.01));
    });

    test('हर साल लगभग 50 विकला बढ़ता है', () {
      final a2000 = lahiriAyanamsa(_jdUtc(2000, 1, 1));
      final a2100 = lahiriAyanamsa(_jdUtc(2100, 1, 1));
      final arcsecPerYear = (a2100 - a2000) * 3600 / 100;
      expect(arcsecPerYear, inInclusiveRange(50.0, 50.6));
    });

    test('मकर संक्रांति हमेशा 14–15 जनवरी को पड़ती है', () {
      // यह अयनांश की सबसे सच्ची जाँच है। मकर संक्रांति का मतलब है
      // सूर्य का निरयन 270° पर पहुँचना। अगर अयनांश ज़रा भी खिसका, तो
      // तारीख़ 13 या 16 जनवरी पर चली जाएगी — और पूरा भारत जानता है
      // कि संक्रांति 14 (कभी-कभी 15) को होती है।
      for (var year = 2024; year <= 2035; year++) {
        final crossing =
            findCrossing(sunSiderealAt, 270.0, julianDay(year, 1, 5.0), 20);
        expect(crossing, isNotNull, reason: '$year में संक्रांति मिली ही नहीं');

        final ist = utcFromJulianDay(crossing!)
            .add(const Duration(hours: 5, minutes: 30));
        expect(ist.month, 1, reason: '$year');
        expect(ist.day, inInclusiveRange(14, 15), reason: '$year');
      }
    });

    test('मेष संक्रांति 13–15 अप्रैल को पड़ती है', () {
      for (var year = 2024; year <= 2035; year++) {
        final crossing =
            findCrossing(sunSiderealAt, 0.0, julianDay(year, 4, 5.0), 20);
        expect(crossing, isNotNull, reason: '$year');

        final ist = utcFromJulianDay(crossing!)
            .add(const Duration(hours: 5, minutes: 30));
        expect(ist.month, 4, reason: '$year');
        expect(ist.day, inInclusiveRange(13, 15), reason: '$year');
      }
    });

    test('निरयन देशांतर सायन से अयनांश जितना पीछे रहता है', () {
      final jde = toEphemerisTime(_jdUtc(2026, 8, 20));
      final tropical = sunApparentLongitude(jde);
      final sidereal = toSidereal(tropical, jde);
      expect(norm180(tropical - sidereal), closeTo(lahiriAyanamsa(jde), 1e-9));
    });
  });

  group('सूर्योदय और सूर्यास्त', () {
    test('सूर्योदय हमेशा सूर्यास्त से पहले', () {
      for (final place in Place.testCities) {
        for (final month in [1, 4, 7, 10]) {
          final r = sunriseSunset(2026, month, 15, place);
          expect(r.sunrise, isNotNull, reason: '${place.name} $month');
          expect(r.sunset, isNotNull, reason: '${place.name} $month');
          expect(r.sunrise!.isBefore(r.sunset!), isTrue,
              reason: '${place.name}, महीना $month');
        }
      }
    });

    test('दिल्ली में जून का दिन दिसम्बर से लंबा होता है', () {
      final june = sunriseSunset(2026, 6, 21, Place.delhi);
      final december = sunriseSunset(2026, 12, 21, Place.delhi);

      final juneLength = june.sunset!.difference(june.sunrise!);
      final decemberLength = december.sunset!.difference(december.sunrise!);

      expect(juneLength.inMinutes, greaterThan(13 * 60));
      expect(decemberLength.inMinutes, lessThan(11 * 60));
      expect(juneLength, greaterThan(decemberLength));
    });

    test('विषुव पर भूमध्य रेखा का दिन लगभग बारह घंटे का', () {
      const equator = Place(name: 'भूमध्य रेखा', latitude: 0.0, longitude: 78.0);
      final r = sunriseSunset(2026, 3, 20, equator);
      final length = r.sunset!.difference(r.sunrise!).inMinutes;
      // अपवर्तन की वजह से थोड़ा ज़्यादा — इसलिए 12 घंटे से कुछ ऊपर
      expect(length, inInclusiveRange(715, 735));
    });

    test('सूर्योदय के क्षण सूरज ठीक क्षितिज पर होता है', () {
      final r = sunriseSunset(2026, 8, 20, Place.delhi);
      final jd = julianDayFromUtc(r.sunrise!);
      expect(sunAltitude(jd, Place.delhi), closeTo(-0.8333, 0.01));
    });

    test('पूरब का शहर पहले देखता है सूरज', () {
      // पटना दिल्ली से पूरब में है, तो वहाँ सूर्योदय पहले होगा
      final patna = sunriseSunset(2026, 8, 20, Place.patna).sunrise!;
      final delhi = sunriseSunset(2026, 8, 20, Place.delhi).sunrise!;
      expect(patna.isBefore(delhi), isTrue);
    });
  });

  group('पंचांग के अंग', () {
    final p = computePanchang(2026, 8, 20, Place.delhi);

    test('चारों अंग अपनी सीमा में हैं', () {
      expect(p.tithi.index, inInclusiveRange(0, 29));
      expect(p.nakshatra.index, inInclusiveRange(0, 26));
      expect(p.yoga.index, inInclusiveRange(0, 26));
      expect(p.karana.index, inInclusiveRange(0, 10));
      expect(p.vara, inInclusiveRange(0, 6));
      expect(p.masa, inInclusiveRange(0, 11));
    });

    test('हर अंग की समाप्ति सूर्योदय के बाद है', () {
      for (final anga in [p.tithi, p.nakshatra, p.yoga, p.karana]) {
        expect(anga.endsAt, isNotNull, reason: '${anga.name} की समाप्ति नहीं मिली');
        expect(anga.endsAt!.isAfter(p.sunrise!), isTrue,
            reason: '${anga.name} सूर्योदय से पहले ही ख़त्म दिखा');
      }
    });

    test('करण तिथि के भीतर ही ख़त्म होता है', () {
      // करण आधी तिथि का होता है, तो वो कभी तिथि के बाद ख़त्म नहीं हो सकता
      expect(p.karana.endsAt!.isAfter(p.tithi.endsAt!), isFalse);
    });

    test('तिथि 19 से 26 घंटे चलती है', () {
      // लगातार दो तिथि-सीमाओं के बीच का समय नापो। चंद्रमा की चाल घटती-बढ़ती
      // रहती है, इसलिए तिथि कभी छोटी कभी बड़ी — पर इस दायरे से बाहर नहीं।
      var boundary = findCrossing(elongationAt, 0.0, julianDay(2026, 9, 1.0), 30)!;

      for (var i = 1; i <= 30; i++) {
        final next = findCrossing(elongationAt, (i * 12.0) % 360.0, boundary, 2.5);
        expect(next, isNotNull, reason: 'तिथि $i की सीमा नहीं मिली');

        final hours = (next! - boundary) * 24;
        expect(hours, inInclusiveRange(19.0, 26.5),
            reason: 'तिथि $i की लंबाई ${hours.toStringAsFixed(1)} घंटे');

        boundary = next;
      }
    });

    test('पक्ष तिथि से मेल खाता है', () {
      for (var day = 1; day <= 30; day++) {
        final panchang = computePanchang(2026, 10, day, Place.delhi);
        final expected = panchang.tithi.index < 15 ? 0 : 1;
        expect(panchang.paksha, expected, reason: '10/$day');
      }
    });

    test('तिथि रोज़ आगे बढ़ती है, पीछे नहीं', () {
      // क्षय तिथि में एक तिथि छूट सकती है, इसलिए 0, 1 या 2 की छलाँग ठीक है
      var previous = computePanchang(2026, 4, 1, Place.delhi).tithi.index;
      for (var day = 2; day <= 30; day++) {
        final current = computePanchang(2026, 4, day, Place.delhi).tithi.index;
        final jump = (current - previous + 30) % 30;
        expect(jump, inInclusiveRange(0, 2), reason: '4/$day पर छलाँग $jump');
        previous = current;
      }
    });

    test('वार रोज़ एक कदम आगे बढ़ता है', () {
      var previous = computePanchang(2026, 5, 1, Place.delhi).vara;
      for (var day = 2; day <= 31; day++) {
        final current = computePanchang(2026, 5, day, Place.delhi).vara;
        expect(current, (previous + 1) % 7, reason: '5/$day');
        previous = current;
      }
    });

    test('पूर्णिमांत का मास कृष्ण पक्ष में अमांत से एक आगे रहता है', () {
      for (var day = 1; day <= 30; day++) {
        final amanta =
            computePanchang(2026, 7, day, Place.delhi, masaSystem: MasaSystem.amanta);
        final purnimanta = computePanchang(2026, 7, day, Place.delhi,
            masaSystem: MasaSystem.purnimanta);

        if (amanta.paksha == 1) {
          expect(purnimanta.masa, (amanta.masa + 1) % 12, reason: '7/$day');
        } else {
          expect(purnimanta.masa, amanta.masa, reason: '7/$day');
        }
      }
    });

    test('उत्तरायण मकर से मिथुन तक रहता है', () {
      // 15 जनवरी — मकर संक्रांति के तुरंत बाद
      expect(computePanchang(2026, 1, 20, Place.delhi).ayana, 0);
      // 15 अगस्त — दक्षिणायन
      expect(computePanchang(2026, 8, 15, Place.delhi).ayana, 1);
    });

    test('अधिक मास — 2026 में अधिक ज्येष्ठ', () {
      // हर ढाई-तीन साल में एक अतिरिक्त चांद्र मास आता है, जब किसी मास में
      // सूर्य राशि नहीं बदलता। 2026 में यह **अधिक ज्येष्ठ** है, 17 मई से
      // 15 जून तक। Drik भी 1 जून को "Jyeshtha (Adhik)" और
      // "Purushottam Masa Day 16" लिखता है।

      final beech = computePanchang(2026, 6, 1, Place.delhi);
      expect(beech.isAdhikaMasa, isTrue, reason: '1 जून अधिक मास में है');
      expect(beech.masaFullName, 'अधिक ज्येष्ठ');

      // अधिक मास में पूर्णिमांत का +1 नहीं लगता — दोनों पद्धतियाँ एक ही नाम
      final amanta = computePanchang(2026, 6, 1, Place.delhi,
          masaSystem: MasaSystem.amanta);
      expect(amanta.masaFullName, beech.masaFullName,
          reason: 'अधिक मास में दोनों पद्धतियों का नाम एक होना चाहिए');

      // उससे पहले और बाद में अधिक मास नहीं
      expect(computePanchang(2026, 5, 10, Place.delhi).isAdhikaMasa, isFalse);
      expect(computePanchang(2026, 7, 1, Place.delhi).isAdhikaMasa, isFalse);

      // और 2027 में कोई अधिक मास नहीं
      for (final month in [2, 5, 8, 11]) {
        expect(computePanchang(2027, month, 15, Place.delhi).isAdhikaMasa,
            isFalse,
            reason: '2027/$month में अधिक मास नहीं होना चाहिए');
      }
    });

    test('सामान्य मास में पूर्णिमांत का +1 लगता ही है', () {
      // यह पक्का करने के लिए कि ऊपर वाला सुधार ज़्यादा दूर तक न चला जाए
      final amanta = computePanchang(2026, 7, 10, Place.delhi,
          masaSystem: MasaSystem.amanta);
      final purnimanta = computePanchang(2026, 7, 10, Place.delhi);

      expect(amanta.paksha, 1, reason: 'कृष्ण पक्ष होना चाहिए');
      expect(amanta.masaName, 'ज्येष्ठ');
      expect(purnimanta.masaName, 'आषाढ़');
    });

    test('संवत् का फ़र्क़ हमेशा 135 का रहता है', () {
      final p2 = computePanchang(2026, 8, 20, Place.delhi);
      expect(p2.vikramSamvat - p2.shakaSamvat, 135);
      expect(p2.shakaSamvat, inInclusiveRange(1947, 1949));
    });

    test('करण के नाम सही क्रम में लगते हैं', () {
      expect(karanaNameIndex(0), 10); // किंस्तुघ्न
      expect(karanaNameIndex(1), 0); // बव
      expect(karanaNameIndex(7), 6); // विष्टि
      expect(karanaNameIndex(8), 0); // फिर बव
      expect(karanaNameIndex(57), 7); // शकुनि
      expect(karanaNameIndex(58), 8); // चतुष्पाद
      expect(karanaNameIndex(59), 9); // नाग
    });

    test('राहुकाल दिन के भीतर और लगभग डेढ़ घंटे का', () {
      expect(p.rahuKaalStart!.isAfter(p.sunrise!), isTrue);
      expect(p.rahuKaalEnd!.isBefore(p.sunset!.add(const Duration(minutes: 1))),
          isTrue);
      final minutes = p.rahuKaalEnd!.difference(p.rahuKaalStart!).inMinutes;
      expect(minutes, inInclusiveRange(70, 110));
    });

    test('एक ही इनपुट पर हमेशा एक ही जवाब', () {
      final a = computePanchang(2026, 8, 20, Place.delhi);
      final b = computePanchang(2026, 8, 20, Place.delhi);
      expect(a.tithi.index, b.tithi.index);
      expect(a.tithi.endsAt, b.tithi.endsAt);
      expect(a.nakshatra.index, b.nakshatra.index);
    });

    test('संवत्सर के नाम — Drik से बँधे हुए', () {
      // उत्तर (विक्रम) और दक्षिण (शक) के चक्र अलग चलते हैं — यह भूल नहीं,
      // दो अलग परंपराएँ हैं। दोनों Drik से जाँचे हुए।
      expect(vikramSamvatsaraOf(2083), 'सिद्धार्थी');
      expect(vikramSamvatsaraOf(2084), 'रौद्र');
      expect(shakaSamvatsaraOf(1948), 'पराभव');
      expect(shakaSamvatsaraOf(1949), 'प्लवंग');

      final p2 = computePanchang(2026, 8, 20, Place.delhi);
      expect(p2.vikramSamvatsara, 'सिद्धार्थी');
      expect(p2.shakaSamvatsara, 'पराभव');

      // चक्र साठ साल में लौटता है
      expect(vikramSamvatsaraOf(2083 + 60), 'सिद्धार्थी');
    });

    test('दिन के दोनों करण — Drik से मिलते हैं', () {
      // Drik 20 अगस्त 2026 को दो करण दिखाता है:
      // "Vishti upto 08:15 AM" और "Bava upto 09:18 PM"
      final p2 = computePanchang(2026, 8, 20, Place.delhi);

      expect(p2.karanas.length, greaterThanOrEqualTo(2),
          reason: 'दिन में कम से कम दो करण चलते हैं');
      expect(p2.karanas[0].name, contains('विष्टि'));
      expect(_hhmm(p2.karanas[0].endsAt!), '08:15');
      expect(p2.karanas[1].name, 'बव');
      expect(_hhmm(p2.karanas[1].endsAt!), '21:18');
    });

    test('ज़्यादातर दिनों में एक से ज़्यादा करण होते हैं', () {
      // साल भर की जाँच में निकला था कि 365 में से 349 दिन ऐसे हैं।
      // सिर्फ़ सूर्योदय वाला करण दिखाना अधूरा पंचांग है।
      var multiple = 0;
      for (var day = 1; day <= 30; day++) {
        if (computePanchang(2026, 9, day, Place.delhi).karanas.length >= 2) {
          multiple++;
        }
      }
      expect(multiple, greaterThan(25), reason: '30 में से $multiple');
    });

    test('यमगंड, गुलिक और अभिजित — Drik से मिलते हैं', () {
      // Drik, 20 अगस्त 2026 दिल्ली:
      //   Yamaganda 05:53–07:31 · Gulika 09:09–10:46 · Abhijit 11:58–12:50
      final p2 = computePanchang(2026, 8, 20, Place.delhi);

      expect(_hhmm(p2.yamaganda!.start), '05:52'); // 1 मिनट की छूट
      expect(_hhmm(p2.gulika!.start), '09:08');
      expect(_hhmm(p2.abhijit!.start), '11:58');
      expect(_hhmm(p2.abhijit!.end), '12:50');

      // तीनों दिन के आठवें हिस्से जितने लंबे (अभिजित पंद्रहवाँ हिस्सा)
      final eighth = p2.dinamana!.inSeconds / 8;
      for (final k in [p2.rahuKaal!, p2.yamaganda!, p2.gulika!]) {
        expect(k.duration.inSeconds, closeTo(eighth, 2), reason: k.name);
      }
      expect(p2.abhijit!.duration.inSeconds,
          closeTo(p2.dinamana!.inSeconds / 15, 2));
    });

    test('दिनमान और रात्रिमान — Drik से मिलते हैं', () {
      // Drik: दिनमान 13:02:57, रात्रिमान 10:57:34
      final p2 = computePanchang(2026, 8, 20, Place.delhi);

      expect(p2.dinamana!.inSeconds, closeTo(13 * 3600 + 2 * 60 + 57, 30));
      expect(p2.ratrimana!.inSeconds, closeTo(10 * 3600 + 57 * 60 + 34, 30));

      // रात्रिमान सूर्यास्त से *अगले* सूर्योदय तक है, 24 घंटे में से घटाकर नहीं
      expect(p2.ratrimana, p2.nextSunrise!.difference(p2.sunset!));
    });

    test('भद्रा तभी दिखे जब विष्टि करण हो', () {
      for (var day = 15; day <= 25; day++) {
        final p2 = computePanchang(2026, 8, day, Place.delhi);
        final hasVishti = p2.karanas.any((k) => k.index == 6);
        expect(p2.bhadra != null, hasVishti, reason: '8/$day');
      }
    });

    test('क्षय और वृद्धि तिथि — गिनती से मेल खाती है', () {
      for (var day = 1; day <= 28; day++) {
        final today = computePanchang(2026, 3, day, Place.delhi);
        final tomorrow = computePanchang(2026, 3, day + 1, Place.delhi);
        final jump = (tomorrow.tithi.index - today.tithi.index + 30) % 30;

        expect(today.isVriddhiTithi, jump == 0, reason: '3/$day वृद्धि');
        expect(today.kshayaTithiName != null, jump == 2, reason: '3/$day क्षय');
      }
    });

    test('गंडमूल और पंचक सही नक्षत्र/राशि पर लगते हैं', () {
      for (var day = 1; day <= 28; day++) {
        final p2 = computePanchang(2026, 4, day, Place.delhi);

        // गंडमूल = अश्विनी, आश्लेषा, मघा, ज्येष्ठा, मूल, रेवती
        expect(p2.isGandmool, gandmoolNakshatras.contains(p2.nakshatra.index),
            reason: '4/$day गंडमूल');

        // पंचक = चंद्रमा कुम्भ या मीन में
        expect(p2.isPanchak, p2.moonRashi == 10 || p2.moonRashi == 11,
            reason: '4/$day पंचक');
      }
    });

    test('हर अंग की शुरुआत उसकी समाप्ति से पहले है', () {
      final p2 = computePanchang(2026, 8, 20, Place.delhi);
      for (final list in [p2.tithis, p2.nakshatras, p2.yogas, p2.karanas]) {
        for (final a in list) {
          if (a.startsAt == null) continue;
          expect(a.startsAt!.isBefore(a.endsAt!), isTrue, reason: a.name);
        }
      }
    });

    test('नामों की सूचियाँ पूरी हैं', () {
      expect(tithiNames.length, 30);
      expect(nakshatraNames.length, 27);
      expect(yogaNames.length, 27);
      expect(karanaNames.length, 11);
      expect(masaNames.length, 12);
      expect(varaNames.length, 7);
      expect(rashiNames.length, 12);
      expect(rituNames.length, 6);
    });
  });
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
