import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// व्रत की तारीख़ें — वही व्यापिनी नियम जो त्योहारों में लगता है।
///
/// ⚠️ यहाँ **फल का कोई दावा नहीं** जाँचा जाता, सिर्फ़ तारीख़। "यह व्रत
/// करने से क्या मिलेगा" — वो ऐप कहता ही नहीं।
void main() {
  const dilli = Place.delhi;

  List<VratDin> nikalo({
    required DateTime se,
    int dinAage = 45,
    int kitne = 40,
    MasaSystem masa = MasaSystem.purnimanta,
  }) =>
      aaneWaleVrat(
        place: dilli,
        masaSystem: masa,
        aaj: se,
        dinAage: dinAage,
        kitne: kitne,
      );

  group('तिथि से बनी तारीख़ें', () {
    test('हर व्रत उसी तिथि पर पड़ता है जो उसका नियम कहता है', () {
      // यही पूरी जाँच की जड़ है — अगर कोई व्रत ग़लत तिथि पर आ गया, तो
      // यूज़र ग़लत दिन उपवास रखेगा।
      for (final v in nikalo(se: DateTime(2026, 1, 1), dinAage: 120)) {
        final p = computePanchang(
          v.tarikh.year,
          v.tarikh.month,
          v.tarikh.day,
          dilli,
        );
        final pakshaKaTithi = (p.tithi.index % 15) + 1;

        expect(pakshaKaTithi, v.niyam.tithi,
            reason: '${v.niyam.naam} ${v.tarikh} पर ग़लत तिथि');
        if (v.niyam.paksha != null) {
          expect(p.paksha, v.niyam.paksha,
              reason: '${v.niyam.naam} ${v.tarikh} पर ग़लत पक्ष');
        }
      }
    });

    test('एकादशी दोनों पक्षों में आती है', () {
      final ekadashi = nikalo(se: DateTime(2026, 1, 1), dinAage: 90)
          .where((v) => v.niyam.id == 'ekadashi')
          .toList();

      // तीन महीने में छह एकादशी होनी चाहिए (कभी-कभी पाँच या सात, अगर
      // तिथि क्षय/वृद्धि हो) — पर दोनों पक्ष ज़रूर मिलें।
      expect(ekadashi.length, greaterThanOrEqualTo(5));
      final paksh = {
        for (final v in ekadashi)
          computePanchang(v.tarikh.year, v.tarikh.month, v.tarikh.day, dilli)
              .paksha
      };
      expect(paksh, {0, 1}, reason: 'शुक्ल और कृष्ण, दोनों की एकादशी');
    });

    test('अमावस्या कृष्ण में, पूर्णिमा शुक्ल में — कभी उल्टा नहीं', () {
      for (final v in nikalo(se: DateTime(2026, 1, 1), dinAage: 120)) {
        if (v.niyam.id != 'purnima' && v.niyam.id != 'amavasya') continue;
        final p = computePanchang(
            v.tarikh.year, v.tarikh.month, v.tarikh.day, dilli);
        expect(p.paksha, v.niyam.id == 'purnima' ? 0 : 1,
            reason: '${v.niyam.naam} ${v.tarikh}');
      }
    });

    test('संकष्टी और मासिक शिवरात्रि सिर्फ़ कृष्ण पक्ष में', () {
      for (final v in nikalo(se: DateTime(2026, 1, 1), dinAage: 120)) {
        if (v.niyam.id != 'sankashti' && v.niyam.id != 'masik_shivratri') {
          continue;
        }
        final p = computePanchang(
            v.tarikh.year, v.tarikh.month, v.tarikh.day, dilli);
        expect(p.paksha, 1, reason: '${v.niyam.naam} ${v.tarikh}');
      }
    });
  });

  group('सूची का ढंग', () {
    test('तारीख़ों के क्रम में आती है', () {
      final sab = nikalo(se: DateTime(2026, 3, 1), dinAage: 60);
      for (var i = 1; i < sab.length; i++) {
        expect(
          sab[i].tarikh.isBefore(sab[i - 1].tarikh),
          isFalse,
          reason: 'क्रम टूटा: ${sab[i - 1].tarikh} के बाद ${sab[i].tarikh}',
        );
      }
    });

    test('"कितने" से ज़्यादा कभी नहीं लौटाता', () {
      expect(nikalo(se: DateTime(2026, 3, 1), kitne: 4).length, 4);
    });

    test('kitneDinBaad सचमुच उतने ही दिन है', () {
      final se = DateTime(2026, 3, 1);
      for (final v in nikalo(se: se, dinAage: 40)) {
        expect(v.tarikh.difference(DateTime(2026, 3, 1)).inDays,
            v.kitneDinBaad);
      }
    });

    test('आज पड़ने वाला व्रत "आज" कहलाता है', () {
      // 1 जनवरी 2026 से आगे का पहला व्रत ढूँढ़ो, फिर उसी दिन से पूछो।
      final pehla = nikalo(se: DateTime(2026, 1, 1), kitne: 1).single;
      final usiDin = nikalo(se: pehla.tarikh, kitne: 1).single;

      expect(usiDin.kitneDinBaad, 0);
      expect(usiDin.kabLikha, 'आज');
    });

    test('कल, परसों — फिर गिनती', () {
      final se = DateTime(2026, 3, 1);
      for (final v in nikalo(se: se, dinAage: 40)) {
        final likha = switch (v.kitneDinBaad) {
          0 => 'आज',
          1 => 'कल',
          2 => 'परसों',
          _ => '${v.kitneDinBaad} दिन बाद',
        };
        expect(v.kabLikha, likha);
      }
    });
  });

  group('जगह और पद्धति', () {
    test('चेन्नई में भी तिथि का नियम वही रहता है', () {
      final sab = aaneWaleVrat(
        place: Place.chennai,
        masaSystem: MasaSystem.amanta,
        aaj: DateTime(2026, 3, 1),
        dinAage: 60,
      );
      expect(sab, isNotEmpty);
      for (final v in sab) {
        final p = computePanchang(
          v.tarikh.year,
          v.tarikh.month,
          v.tarikh.day,
          Place.chennai,
          masaSystem: MasaSystem.amanta,
        );
        expect((p.tithi.index % 15) + 1, v.niyam.tithi);
      }
    });

    test('मास-पद्धति से तिथि नहीं बदलती — सिर्फ़ मास का नाम बदलता है', () {
      // पूर्णिमांत और अमांत में **तिथि वही** होती है; फ़र्क़ सिर्फ़ यह है
      // कि महीना कब बदलता है। इसलिए व्रत की तारीख़ें एक जैसी आनी चाहिए।
      final se = DateTime(2026, 4, 1);
      final purnimanta = nikalo(se: se, masa: MasaSystem.purnimanta);
      final amanta = nikalo(se: se, masa: MasaSystem.amanta);

      expect(
        purnimanta.map((v) => '${v.niyam.id}|${v.tarikh}').toList(),
        amanta.map((v) => '${v.niyam.id}|${v.tarikh}').toList(),
      );
    });
  });
}
