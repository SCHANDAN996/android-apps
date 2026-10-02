import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// जन्म का क्षण: भारत की घड़ी का इतिहास, और जन्म-पंचांग (→ D-105)।
void main() {
  group('भारत की घड़ी — tz database, Asia/Kolkata', () {
    Duration antar(int y, int m, int d, [int h = 12]) =>
        bharatSamayAntar(DateTime(y, m, d, h));
    const manak = Duration(hours: 5, minutes: 30);
    const yuddh = Duration(hours: 6, minutes: 30);

    test('आम सालों में +5:30', () {
      expect(antar(1990, 5, 15), manak);
      expect(antar(1930, 1, 1), manak);
      expect(antar(1947, 8, 15), manak);
      expect(antar(2026, 10, 2), manak);
    });

    test('युद्ध-काल के दो दौर में घड़ी एक घंटा आगे', () {
      expect(antar(1941, 12, 1), yuddh);
      expect(antar(1943, 6, 1), yuddh);
      expect(antar(1945, 8, 15), yuddh);
    });

    test('दोनों दौरों के बीच के साढ़े तीन महीने और किनारे', () {
      expect(antar(1941, 9, 30), manak);
      expect(antar(1941, 10, 1, 0), yuddh);
      expect(antar(1942, 5, 14, 23), yuddh);
      expect(antar(1942, 5, 15, 0), manak);
      expect(antar(1942, 7, 1), manak);
      expect(antar(1942, 8, 31, 23), manak);
      expect(antar(1942, 9, 1, 0), yuddh);
      expect(antar(1945, 10, 14, 23), yuddh);
      expect(antar(1945, 10, 15, 0), manak);
    });

    test('समय-क्षेत्र का निशान नहीं देखा जाता — घड़ी के अंक ही', () {
      expect(bharatSamayAntar(DateTime.utc(1943, 6, 1, 12)), yuddh);
      expect(yuddhKalKiGhadi(DateTime.utc(1943, 6, 1, 12)), isTrue);
      expect(yuddhKalKiGhadi(DateTime(2000, 1, 1)), isFalse);
    });
  });

  group('जन्म-पंचांग', () {
    DateTime utc(int y, int m, int d, int h, int min, Place p) =>
        DateTime.utc(y, m, d, h, min).subtract(p.timeZoneOffset);

    test('सूर्योदय के ठीक बाद का जन्म — उस दिन के पंचांग से हूबहू', () {
      for (final place in Place.testCities) {
        for (var i = 0; i < 40; i++) {
          final d = DateTime.utc(2026, 1, 1).add(Duration(days: i * 9));
          final p = computePanchang(d.year, d.month, d.day, place);
          // जिस दिन कोई अंग सूर्योदय के दो मिनट के भीतर बदल रहा हो, वह दिन
          // इस जाँच का नहीं — वहाँ आधा मिनट बाद का जन्म सचमुच अगले अंग में है।
          bool turant(Anga a) =>
              a.endsAt != null &&
              a.endsAt!.difference(p.sunrise!).inSeconds.abs() < 120;
          if ([p.tithi, p.nakshatra, p.yoga, p.karana].any(turant)) continue;
          final janm = p.sunrise!
              .add(const Duration(seconds: 30))
              .subtract(place.timeZoneOffset);
          final j = janmPanchang(janm, place);
          final kahan = '${place.name} $d';
          expect(j.suryodaySePehle, isFalse, reason: kahan);
          expect(j.hinduDin, DateTime.utc(d.year, d.month, d.day), reason: kahan);
          expect(j.vara, p.vara, reason: kahan);
          expect(j.tithi, p.tithi.index, reason: kahan);
          expect(j.nakshatra, p.nakshatra.index, reason: kahan);
          expect(j.yoga, p.yoga.index, reason: kahan);
          expect(j.karana, p.karana.index, reason: kahan);
          expect(j.masa, p.masa, reason: kahan);
          expect(j.vikramSamvat, p.vikramSamvat, reason: kahan);
        }
      }
    });

    test('रात 2 बजे का जन्म पिछले दिन के वार में गिना जाता है', () {
      // 15 मई 1990 मंगलवार था; रात 2 बजे सूर्योदय नहीं हुआ था → सोमवार।
      final j = janmPanchang(utc(1990, 5, 15, 2, 0, Place.patna), Place.patna);
      expect(j.suryodaySePehle, isTrue);
      expect(j.hinduDin, DateTime.utc(1990, 5, 14));
      expect(j.varaName, 'सोमवार');

      final dopahar =
          janmPanchang(utc(1990, 5, 15, 14, 30, Place.patna), Place.patna);
      expect(dopahar.suryodaySePehle, isFalse);
      expect(dopahar.varaName, 'मंगलवार');
    });

    test('जन्म के क्षण की तिथि, नक्षत्र और चरण कुंडली के चंद्र से मिलते हैं', () {
      for (var i = 0; i < 60; i++) {
        final janm = DateTime.utc(1975, 3, 1, 7, 13).add(Duration(hours: i * 613));
        final j = janmPanchang(janm, Place.delhi);
        final k = computeKundali(janm, Place.delhi);
        final chandra = k[KundaliGraha.chandra];
        expect(j.nakshatra, chandra.nakshatra, reason: '$janm');
        expect(j.charan, chandra.charan, reason: '$janm');
        final surya = k[KundaliGraha.surya];
        final elong = norm360(chandra.nirayan - surya.nirayan);
        expect(j.tithi, (elong / 12).floor() % 30, reason: '$janm');
      }
    });

    test('अमावस्या पार होने के बाद का जन्म अगले मास में गिना जाता है', () {
      // ऐसा दिन ढूँढो जिसके सूर्योदय पर अमावस्या हो और रात 11 बजे तक
      // शुक्ल प्रतिपदा लग चुकी हो।
      var mile = 0;
      for (var i = 0; i < 400 && mile < 3; i++) {
        final d = DateTime.utc(2026, 1, 1).add(Duration(days: i));
        final p = computePanchang(d.year, d.month, d.day, Place.patna,
            masaSystem: MasaSystem.amanta);
        if (p.tithi.index != 29) continue;
        final janm = utc(d.year, d.month, d.day, 23, 0, Place.patna);
        final j = janmPanchang(janm, Place.patna, masaSystem: MasaSystem.amanta);
        if (j.tithi != 0) continue;
        mile++;
        final agla = d.add(const Duration(days: 1));
        final pAgla = computePanchang(agla.year, agla.month, agla.day,
            Place.patna,
            masaSystem: MasaSystem.amanta);
        expect(j.masa, pAgla.masa, reason: '$d');
        expect(j.isAdhikaMasa, pAgla.isAdhikaMasa, reason: '$d');
        // अधिक मास न हो तो अमांत मास सचमुच बदलता है
        if (!p.isAdhikaMasa && !pAgla.isAdhikaMasa) {
          expect(j.masa, isNot(p.masa), reason: '$d');
        }
        expect(j.paksha, 0);
        expect(j.vara, p.vara, reason: 'वार सूर्योदय वाला ही');
      }
      expect(mile, greaterThan(0), reason: 'साल भर में ऐसा कोई दिन नहीं मिला');
    });

    test('युद्ध-काल के जन्म में घड़ी का एक घंटा लग्न की पूरी राशि बदल देता है', () {
      // 1 जून 1943, घड़ी में सुबह 8:00 — घड़ी तब +6:30 पर थी।
      const sahi = Place(
          name: 'पटना',
          latitude: 25.5941,
          longitude: 85.1376,
          timeZoneOffset: Duration(hours: 6, minutes: 30));
      final ghadi = DateTime(1943, 6, 1, 8, 0);
      expect(bharatSamayAntar(ghadi), sahi.timeZoneOffset);
      final a = computeKundali(utc(1943, 6, 1, 8, 0, sahi), sahi);
      final b = computeKundali(utc(1943, 6, 1, 8, 0, Place.patna), Place.patna);
      // एक घंटे में लग्न लगभग 15° चलता है
      final farq = norm180(a.lagna.nirayan - b.lagna.nirayan).abs();
      expect(farq, inInclusiveRange(10.0, 20.0));
    });
  });
}
