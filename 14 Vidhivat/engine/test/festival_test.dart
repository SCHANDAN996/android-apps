import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// त्योहार की तारीख़ों की जाँच।
///
/// **बारह पुरानी तारीख़ें drikpanchang.com से पक्की की हुई हैं** (और
/// व्रत-पितृ पक्ष वाले आठ नियमों की पाँच-पाँच साल की, → D-087) — हर एक के लिए
/// उस दिन का पन्ना खोलकर देखा गया कि Drik ख़ुद वहाँ उस त्योहार का नाम
/// लिखता है या नहीं। पूरा लट्ठा `docs/08_VERIFICATION.md` में।
///
/// यह फ़ाइल इंजन का सबसे नाज़ुक हिस्सा पकड़ती है — क्योंकि पंचांग सही
/// होने और त्योहार की तारीख़ सही होने में फ़र्क़ है।

void main() {
  group('2026 के त्योहार — सब Drik से पक्के', () {
    // तारीख़, और Drik के पन्ने पर उस दिन क्या लिखा मिला
    const verified = {
      'maha_shivaratri': (2, 15, 'Maha Shivaratri'),
      'holika_dahan': (3, 3, 'Chhoti Holi (Holika Dahan)'),
      'rama_navami': (3, 26, 'Rama Navami *Smarta'),
      'raksha_bandhan': (8, 28, 'Raksha Bandhan/Rakhi'),
      'janmashtami': (9, 4, 'Krishna Janmashtami'),
      'ganesh_chaturthi': (9, 14, 'Ganesh Chaturthi'),
      'navratri_ghatasthapana': (10, 11, 'Navratri Begins / Ghatasthapana'),
      'diwali': (11, 8, 'Diwali'),
      'dhanteras': (11, 6, 'Dhantrayodashi'),
      'govardhan_puja': (11, 10, 'Govardhan Puja'),
      'bhai_dooj': (11, 11, 'Bhai Dooj'),
      'vasant_panchami': (1, 23, 'Vasant Panchami'),
    };

    for (final entry in verified.entries) {
      final rule = festivalRules.firstWhere((r) => r.id == entry.key);
      final (month, day, drikName) = entry.value;

      test('${rule.name} → $day/$month  [Drik: $drikName]', () {
        final found = findFestival(rule, 2026, Place.delhi);

        expect(found, isNotNull, reason: '${rule.name} मिला ही नहीं');
        expect(found!.date.month, month, reason: 'महीना');
        expect(found.date.day, day, reason: 'दिन');
      });
    }
  });

  group('व्रत और पितृ पक्ष — पाँच साल, हर तारीख़ संदर्भ-पंचांग से (→ D-087)',
      () {
    // 2024–2028, दिल्ली। हर तारीख़ के लिए संदर्भ-पंचांग का उस दिन वाला
    // पन्ना खोलकर देखा कि वो ख़ुद उस दिन यह नाम लिखता है। व्यापिनी वही
    // रखी जिस पर पाँचों साल मेल खाए (बाक़ी क्यों नहीं — नियम के ऊपर लिखा)।
    const verified = {
      'vat_savitri': [
        (2024, 6, 6),
        (2025, 5, 26),
        (2026, 5, 16),
        (2027, 6, 4),
        (2028, 5, 24)
      ],
      'varalakshmi_vrat': [
        (2024, 8, 16),
        (2025, 8, 8),
        (2026, 8, 28),
        (2027, 8, 13),
        (2028, 8, 4)
      ],
      'hartalika_teej': [
        (2024, 9, 6),
        (2025, 8, 26),
        (2026, 9, 14),
        (2027, 9, 3),
        (2028, 8, 22)
      ],
      'pitru_paksha_arambh': [
        (2024, 9, 18),
        (2025, 9, 8),
        (2026, 9, 27),
        (2027, 9, 16),
        (2028, 9, 4)
      ],
      'sarvapitri_amavasya': [
        (2024, 10, 2),
        (2025, 9, 21),
        (2026, 10, 10),
        (2027, 9, 29),
        (2028, 9, 18)
      ],
      'dussehra': [
        (2024, 10, 12),
        (2025, 10, 2),
        (2026, 10, 20),
        (2027, 10, 9),
        (2028, 9, 27)
      ],
      'karwa_chauth': [
        (2024, 10, 20),
        (2025, 10, 10),
        (2026, 10, 29),
        (2027, 10, 18),
        (2028, 10, 7)
      ],
      'chhath': [
        (2024, 11, 7),
        (2025, 10, 27),
        (2026, 11, 15),
        (2027, 11, 4),
        (2028, 10, 23)
      ],
    };

    for (final entry in verified.entries) {
      final rule = festivalRules.firstWhere((r) => r.id == entry.key);
      for (final (year, month, day) in entry.value) {
        test('${rule.name} $year → $day/$month', () {
          final found = findFestival(rule, year, Place.delhi);
          expect(found, isNotNull, reason: '${rule.name} मिला ही नहीं');
          expect(found!.date, DateTime.utc(year, month, day));
        });
      }
    }

    test('वरलक्ष्मी व्रत हमेशा शुक्रवार, और श्रावण पूर्णिमा से पहले या उसी दिन',
        () {
      final purnima = festivalRules.firstWhere((r) => r.id == 'raksha_bandhan');
      final vara = festivalRules.firstWhere((r) => r.id == 'varalakshmi_vrat');
      for (var y = 2024; y <= 2035; y++) {
        final v = findFestival(vara, y, Place.delhi)!;
        final p = findFestival(
          FestivalRule(
            id: 'p',
            name: 'p',
            masa: purnima.masa,
            paksha: 0,
            tithi: 15,
          ),
          y,
          Place.delhi,
        )!;
        expect(v.date.weekday, DateTime.friday, reason: '$y');
        final peeche = p.date.difference(v.date).inDays;
        expect(peeche, inInclusiveRange(0, 6), reason: '$y');
        expect(v.explanation, contains('शुक्रवार'));
      }
    });

    test('करवा चौथ का हिसाब चंद्रोदय से', () {
      final rule = festivalRules.firstWhere((r) => r.id == 'karwa_chauth');
      expect(rule.vyapini, Vyapini.chandrodaya);
      final f = findFestival(rule, 2026, Place.delhi)!;
      expect(f.explanation, contains('चंद्रोदय व्यापिनी'));
      // चंद्रोदय की खिड़की शाम-रात में — कृष्ण चतुर्थी का चाँद देर से उगता है
      final w = kaalWindow(Vyapini.chandrodaya, 2026, 10, 29, Place.delhi)!;
      expect(w.start.hour, inInclusiveRange(18, 23));
    });

    test('पितृ पक्ष आरम्भ से सर्वपितृ अमावस्या तक चौदह-पंद्रह दिन', () {
      final a = festivalRules.firstWhere((r) => r.id == 'pitru_paksha_arambh');
      final z = festivalRules.firstWhere((r) => r.id == 'sarvapitri_amavasya');
      for (var y = 2024; y <= 2035; y++) {
        final din = findFestival(z, y, Place.delhi)!
            .date
            .difference(findFestival(a, y, Place.delhi)!.date)
            .inDays;
        expect(din, inInclusiveRange(12, 15), reason: '$y');
      }
    });
  });

  group('भद्रा वाला नियम', () {
    test('होलिका दहन और रक्षाबंधन दोनों भद्रा की वजह से खिसकते हैं', () {
      // 2026 में दोनों की पूर्णिमा का पहला आधा हिस्सा भद्रा में है, और
      // भद्रा उस दिन के ज़रूरी काल को पूरा ढक लेती है। इसलिए त्योहार
      // अगले दिन चला जाता है — और Drik भी यही कहता है।
      for (final id in ['holika_dahan', 'raksha_bandhan']) {
        final rule = festivalRules.firstWhere((r) => r.id == id);
        final found = findFestival(rule, 2026, Place.delhi)!;

        expect(found.shiftedForBhadra, isTrue, reason: rule.name);
      }
    });

    test('भद्रा-रहित त्योहार नहीं खिसकते', () {
      for (final id in ['maha_shivaratri', 'diwali', 'ganesh_chaturthi']) {
        final rule = festivalRules.firstWhere((r) => r.id == id);
        final found = findFestival(rule, 2026, Place.delhi)!;

        expect(found.shiftedForBhadra, isFalse, reason: rule.name);
      }
    });
  });

  group('व्यापिनी नियम सच में फ़र्क़ डालते हैं', () {
    test('सूर्योदय वाला पुराना तरीक़ा महाशिवरात्रि और दीपावली पर ग़लत था', () {
      // यह जाँच याद दिलाती है कि नियम क्यों चाहिए था।
      // महाशिवरात्रि: 15 फ़रवरी को सूर्योदय पर त्रयोदशी थी, चतुर्दशी नहीं।
      // फिर भी त्योहार 15 को है, क्योंकि आधी रात को चतुर्दशी चल रही थी।
      final shivaratri = computePanchang(2026, 2, 15, Place.delhi);
      expect(shivaratri.tithi.name, 'त्रयोदशी',
          reason: 'सूर्योदय पर चतुर्दशी नहीं थी — फिर भी महाशिवरात्रि इसी दिन');

      // दीपावली: 9 नवम्बर को सूर्योदय पर अमावस्या थी, पर वो 12:32 पर
      // ख़त्म हो गई — प्रदोष तक बची ही नहीं। इसलिए दीपावली 8 को।
      final navamber9 = computePanchang(2026, 11, 9, Place.delhi);
      expect(navamber9.tithi.name, 'अमावस्या');
      expect(navamber9.tithi.endsAt!.hour, lessThan(17),
          reason: 'अमावस्या सूर्यास्त से पहले ख़त्म हो गई');
    });

    test('निशीथ काल आधी रात के आसपास पड़ता है', () {
      final k = kaalWindow(Vyapini.nishitha, 2026, 2, 15, Place.delhi)!;
      // रात के बीचोबीच — यानी आधी रात के आसपास
      final ghanta = k.start.hour;
      expect(ghanta == 23 || ghanta <= 1, isTrue,
          reason: 'निशीथ $ghanta बजे शुरू हुआ');
      expect(k.start.day, 16,
          reason: 'निशीथ आधी रात के *बाद* पड़ता है, इसलिए अगली तारीख़ में');
    });

    test('प्रदोष सूर्यास्त से शुरू होता है', () {
      final p = computePanchang(2026, 11, 8, Place.delhi);
      final k = kaalWindow(Vyapini.pradosha, 2026, 11, 8, Place.delhi)!;

      expect(k.start, p.sunset);
      expect(k.end.difference(k.start).inMinutes, 144); // 2 घंटे 24 मिनट
    });

    test('मध्याह्न और अपराह्न दिन के तीसरे-चौथे पंचमांश हैं', () {
      final p = computePanchang(2026, 9, 14, Place.delhi);
      final madhyahna =
          kaalWindow(Vyapini.madhyahna, 2026, 9, 14, Place.delhi)!;
      final aparahna = kaalWindow(Vyapini.aparahna, 2026, 9, 14, Place.delhi)!;

      final fifth = p.dinamana!.inSeconds / 5;

      expect(madhyahna.end, aparahna.start, reason: 'दोनों लगातार हैं');
      expect(madhyahna.end.difference(madhyahna.start).inSeconds,
          closeTo(fifth, 2));
      expect(
          aparahna.end.difference(aparahna.start).inSeconds, closeTo(fifth, 2));
    });
  });

  group('किसी भी साल चलता है', () {
    // तारीख़ें हाथ से नहीं भरी गईं, नियम से निकलती हैं — तो किसी भी साल
    // सही मौसम में पड़नी चाहिए। यह जाँच मास-गणना की ग़लती पकड़ती है।
    const seasons = {
      'maha_shivaratri': [2, 3],
      'holika_dahan': [2, 3],
      'rama_navami': [3, 4],
      'raksha_bandhan': [8, 9],
      'janmashtami': [8, 9],
      'ganesh_chaturthi': [8, 9],
      'navratri_ghatasthapana': [9, 10],
      'diwali': [10, 11],
      'dhanteras': [10, 11],
      'govardhan_puja': [10, 11],
      'bhai_dooj': [10, 11],
      'vasant_panchami': [1, 2],
      'vat_savitri': [5, 6],
      'varalakshmi_vrat': [7, 8, 9],
      'hartalika_teej': [8, 9],
      'pitru_paksha_arambh': [9, 10],
      'sarvapitri_amavasya': [9, 10],
      'dussehra': [9, 10],
      'karwa_chauth': [10, 11],
      'chhath': [10, 11],
    };

    for (var year = 2024; year <= 2032; year++) {
      test('$year — सब त्योहार अपने मौसम में', () {
        for (final rule in festivalRules) {
          final found = findFestival(rule, year, Place.delhi);
          expect(found, isNotNull,
              reason: '$year में ${rule.name} मिला ही नहीं');

          final allowed = seasons[rule.id]!;
          expect(allowed, contains(found!.date.month),
              reason:
                  '$year — ${rule.name} ${found.date.day}/${found.date.month} '
                  'पर पड़ा, जो अपेक्षित महीनों $allowed में नहीं');
          expect(found.date.year, year);
        }
      });
    }

    test('अधिक मास में कोई त्योहार नहीं पड़ता', () {
      // 2026 में अधिक ज्येष्ठ था (17 मई – 15 जून)। कोई त्योहार वहाँ
      // नहीं गिरना चाहिए — शास्त्र में अधिक मास में त्योहार नहीं मनाए जाते।
      for (final rule in festivalRules) {
        final found = findFestival(rule, 2026, Place.delhi)!;
        final p = computePanchang(
            found.date.year, found.date.month, found.date.day, Place.delhi);

        expect(p.isAdhikaMasa, isFalse, reason: rule.name);
      }
    });
  });

  group('हिसाब खोलकर दिखाना', () {
    test('हर तारीख़ के साथ पूरा कारण आता है', () {
      for (final rule in festivalRules) {
        final found = findFestival(rule, 2026, Place.delhi)!;

        expect(found.explanation, contains(rule.tithiName));
        expect(found.explanation, contains(rule.vyapini.hindi));
        expect(found.explanation, contains('दृक् गणित'));
      }
    });

    test('भद्रा वाला त्योहार अपनी वजह भी बताता है', () {
      final rule = festivalRules.firstWhere((r) => r.id == 'holika_dahan');
      final found = findFestival(rule, 2026, Place.delhi)!;

      expect(found.explanation, contains('भद्रा'));
      expect(found.explanation, contains('अगले दिन'));
    });

    test('तिथि का अंतराल चुने हुए दिन के आसपास ही है', () {
      for (final rule in festivalRules) {
        final f = findFestival(rule, 2026, Place.delhi)!;

        expect(f.tithiStart.isBefore(f.tithiEnd), isTrue, reason: rule.name);
        final gap = f.date.difference(DateTime.utc(
            f.tithiStart.year, f.tithiStart.month, f.tithiStart.day));
        expect(gap.inDays.abs(), lessThanOrEqualTo(2), reason: rule.name);
      }
    });
  });

  group('साल की सूची', () {
    test('तारीख़ के हिसाब से क्रम में आती है', () {
      final list = festivalsInYear(2026, Place.delhi);

      expect(list.length, festivalRules.length);
      // एक दिन पर दो भी हो सकते हैं — 2026 में रक्षाबंधन और वरलक्ष्मी
      // व्रत दोनों 28 अगस्त (पूर्णिमा ख़ुद शुक्रवार है)।
      for (var i = 1; i < list.length; i++) {
        expect(list[i].date.isBefore(list[i - 1].date), isFalse);
      }
    });

    test('जगह बदलने से तारीख़ शायद ही कभी बदले', () {
      // सूर्योदय-सूर्यास्त शहर के हिसाब से बदलते हैं, पर तिथि नहीं।
      // इसलिए ज़्यादातर त्योहार पूरे भारत में एक ही दिन पड़ते हैं।
      final delhi = festivalsInYear(2026, Place.delhi);
      final chennai = festivalsInYear(2026, Place.chennai);

      var same = 0;
      for (var i = 0; i < delhi.length; i++) {
        if (delhi[i].date == chennai[i].date) same++;
      }
      expect(same, greaterThanOrEqualTo(delhi.length - 1),
          reason: 'दिल्ली और चेन्नई में $same/${delhi.length} एक जैसे');
    });
  });
}
