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
      expect(pehle.dinTarikhein.keys,
          containsAll(List.generate(10, (i) => i + 1)));
      expect(pehle.dinTarikhein[1], contains(pehle.shuruTarikh));
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

    // ── Drik Panchang का नवरात्रि कैलेंडर, नई दिल्ली (→ D-073) ─────────
    //
    // 13 सित 2026 तक यहाँ सिर्फ़ घटस्थापना मिलाई गई थी। अंत के दिन कभी
    // नहीं मिलाए गए — और 2026 में ऐप दशहरा 21 अक्टूबर बता रहा था, जबकि
    // Drik 20 कहता है। तिथियों के समय दोनों में मिनट तक एक थे; ग़लती
    // दिन चुनने के नियम में थी। ये पाँच साल drikpanchang.com के
    // ashwin-shardiya-navratri-dates पन्ने से लिए गए।
    //
    // (कालरात्रि, दुर्गा अष्टमी, महानवमी, विजयादशमी, संधि-प्रारम्भ)
    const drikKaCalendar = {
      2024: ((10, 10), (10, 11), (10, 11), (10, 12), (11, 42)),
      2025: ((9, 29), (9, 30), (10, 1), (10, 2), (17, 42)),
      2026: ((10, 17), (10, 19), (10, 19), (10, 20), (10, 27)),
      2027: ((10, 6), (10, 7), (10, 8), (10, 9), (6, 3)),
      2028: ((9, 25), (9, 26), (9, 26), (9, 27), (6, 34)),
    };

    DateTime tarikh(int saal, (int, int) md) => DateTime(saal, md.$1, md.$2);

    test('पाँच साल की विजयादशमी Drik से मिलती है', () {
      for (final e in drikKaCalendar.entries) {
        final halat =
            navratriAaj(aaj: DateTime(e.key, 1, 1), place: Place.delhi);
        expect(
          (halat.antTarikh!.month, halat.antTarikh!.day),
          e.value.$4,
          reason: '${e.key} की विजयादशमी',
        );
      }
    });

    test('पाँच साल में कालरात्रि, दुर्गा अष्टमी, महानवमी सही दिन पर "आज" हैं',
        () {
      for (final e in drikKaCalendar.entries) {
        final saal = e.key;
        final (kalaratri, ashtami, navami, dashami, _) = e.value;

        expect(
          navratriAaj(aaj: tarikh(saal, kalaratri), place: Place.delhi)
              .aajKaDin,
          7,
          reason: '$saal की कालरात्रि',
        );
        expect(
          navratriAaj(aaj: tarikh(saal, dashami), place: Place.delhi).aajKaDin,
          10,
          reason: '$saal की विजयादशमी',
        );

        final navamiKaDin =
            navratriAaj(aaj: tarikh(saal, navami), place: Place.delhi);
        expect(navamiKaDin.aajKaDin, 9, reason: '$saal की महानवमी');

        if (ashtami == navami) {
          // अष्टमी और नवमी एक ही तारीख़ — दिन ९ पर "इस साल एक साथ"
          expect(navamiKaDin.mileHueDin, contains(9),
              reason: '$saal — अष्टमी-नवमी साथ');
        } else {
          expect(
            navratriAaj(aaj: tarikh(saal, ashtami), place: Place.delhi)
                .aajKaDin,
            8,
            reason: '$saal की दुर्गा अष्टमी',
          );
        }
      }
    });

    test('पाँच साल की संधि पूजा Drik के समय से दो मिनट के भीतर है', () {
      for (final e in drikKaCalendar.entries) {
        final saal = e.key;
        final (_, _, _, _, (ghanta, minute)) = e.value;
        final halat =
            navratriAaj(aaj: DateTime(saal, 1, 1), place: Place.delhi);
        final shuru = halat.sandhiShuru!;
        final antar = (shuru.hour * 60 + shuru.minute) - (ghanta * 60 + minute);
        expect(antar.abs(), lessThanOrEqualTo(2),
            reason: '$saal संधि — ऐप ${shuru.hour}:${shuru.minute}');
      }
    });

    test('2026 की टिप्पणी सप्तमी की वृद्धि और अष्टमी-नवमी दोनों बताती है', () {
      final halat = navratriAaj(aaj: DateTime(2026, 9, 13), place: Place.delhi);
      expect(halat.kulDin, 9);
      expect(halat.tippani, contains('सप्तमी दो सूर्योदय'));
      expect(halat.tippani, contains('महानवमी एक ही दिन'));
    });

    test('दशमी पर दिन १० और उसके बाद पर्व बीता हुआ मिलता है', () {
      // Drik: विजयादशमी 2026 — 20 अक्टूबर (सूर्योदय वाली दशमी 21 को है,
      // पर दशहरा अपराह्न-व्यापिनी दशमी से मनता है)।
      final dashami = DateTime(2026, 10, 20);

      expect(
        navratriAaj(aaj: dashami, place: Place.delhi).aajKaDin,
        10,
      );
      final baad = navratriAaj(
        aaj: dashami.add(const Duration(days: 2)),
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
