import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:vidhivat/vidhi/parv_aaj.dart';

void main() {
  group('नवरात्रि का पंचांग', () {
    test('पाँच साल की घटस्थापना Drik की दिल्ली तारीख़ों से मिलती है', () {
      const drik = {
        2024: (10, 3),
        2025: (9, 22),
        2026: (10, 11),
        2027: (9, 30),
        2028: (9, 19),
      };

      for (final entry in drik.entries) {
        final halat = navratriAaj(
          aaj: DateTime(entry.key, 1, 1),
          place: Place.delhi,
        );
        expect(
          (halat.shuruTarikh!.month, halat.shuruTarikh!.day),
          entry.value,
          reason: '${entry.key} की घटस्थापना',
        );
      }
    });

    test('आरम्भ से पहले सही गिनती और तारीख़ देता है', () {
      final pehle = navratriAaj(
        aaj: DateTime(2026, 9, 1),
        place: Place.delhi,
      );

      expect(pehle.shuruTarikh, isNotNull);
      expect(pehle.kitneDinBaad, greaterThan(0));
      expect(pehle.aajKaDin, isNull);
      expect(pehle.kulDin, inInclusiveRange(8, 10));
    });

    test('घटस्थापना की तारीख़ पर दिन १ आता है', () {
      final shuru = findFestival(
        const FestivalRule(
          id: 'janch',
          name: 'जाँच',
          masa: 6,
          paksha: 0,
          tithi: 1,
          vyapini: Vyapini.sunrise,
        ),
        2026,
        Place.delhi,
      )!;

      final halat = navratriAaj(aaj: shuru.date, place: Place.delhi);
      expect(halat.aajKaDin, 1);
      expect(halat.kitneDinBaad, isNull);
      expect(halat.ghatasthapanaShuru, isNotNull);
      expect(halat.ghatasthapanaAnt, isNotNull);
      expect(
        halat.ghatasthapanaAnt!.isAfter(halat.ghatasthapanaShuru!),
        isTrue,
      );
    });

    test('संधि पूजा अष्टमी-नवमी संधि के पूरे 48 मिनट देती है', () {
      final halat = navratriAaj(
        aaj: DateTime(2026, 1, 1),
        place: Place.delhi,
      );
      expect(halat.sandhiShuru, isNotNull);
      expect(halat.sandhiAnt, isNotNull);
      expect(
        halat.sandhiAnt!.difference(halat.sandhiShuru!),
        const Duration(minutes: 48),
      );
    });

    test('दशमी पर दिन १० और उसके बाद पर्व बीता हुआ मिलता है', () {
      final dashami = findFestival(
        const FestivalRule(
          id: 'janch',
          name: 'जाँच',
          masa: 6,
          paksha: 0,
          tithi: 10,
          vyapini: Vyapini.sunrise,
        ),
        2026,
        Place.delhi,
      )!;

      expect(
        navratriAaj(aaj: dashami.date, place: Place.delhi).aajKaDin,
        10,
      );
      final baad = navratriAaj(
        aaj: dashami.date.add(const Duration(days: 2)),
        place: Place.delhi,
      );
      expect(baad.aajKaDin, isNull);
      expect(baad.kitneDinBaad, isNull);
    });

    test('कई सालों और शहरों में अवधि ८ से १० दिन रहती है', () {
      for (final place in [Place.delhi, Place.chennai, Place.mumbai]) {
        for (var year = 2024; year <= 2032; year++) {
          final halat = navratriAaj(
            aaj: DateTime(year, 1, 1),
            place: place,
          );
          expect(
            halat.kulDin,
            inInclusiveRange(8, 10),
            reason: '$year, ${place.name}',
          );
          expect(halat.shuruTarikh, isNotNull);
          expect(halat.antTarikh, isNotNull);
          expect(halat.antTarikh!.isAfter(halat.shuruTarikh!), isTrue);
        }
      }
    });
  });
}
