import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// त्योहार की तारीख़ों की जाँच।
///
/// **बीसों नियमों की सात-सात साल (2024–2030) की तारीख़ें drikpanchang.com से
/// पक्की की हुई हैं** (→ D-087, D-117) — हर एक के लिए
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

  group(
      'व्रत और पितृ पक्ष — सात साल, हर तारीख़ संदर्भ-पंचांग से (→ D-087, D-117)',
      () {
    // 2024–2030, दिल्ली। (2029 और 2030 आठ अक्टूबर 2026 को जुड़े → D-117;
    // उसी जाँच में छठ 2030 ग़लत निकला और नियम अपराह्न से सूर्योदय हुआ।)
    // हर तारीख़ के लिए संदर्भ-पंचांग का उस दिन वाला
    // पन्ना खोलकर देखा कि वो ख़ुद उस दिन यह नाम लिखता है। व्यापिनी वही
    // रखी जिस पर सब साल मेल खाए (बाक़ी क्यों नहीं — नियम के ऊपर लिखा)।
    const verified = {
      'vat_savitri': [
        (2024, 6, 6),
        (2025, 5, 26),
        (2026, 5, 16),
        (2027, 6, 4),
        (2028, 5, 24),
        (2029, 6, 11),
        (2030, 5, 31)
      ],
      'varalakshmi_vrat': [
        (2024, 8, 16),
        (2025, 8, 8),
        (2026, 8, 28),
        (2027, 8, 13),
        (2028, 8, 4),
        (2029, 8, 24),
        (2030, 8, 9)
      ],
      'hartalika_teej': [
        (2024, 9, 6),
        (2025, 8, 26),
        (2026, 9, 14),
        (2027, 9, 3),
        (2028, 8, 22),
        (2029, 9, 11), // किनारे का मामला: तृतीया सूर्योदय के 5 मिनट बाद तक
        (2030, 8, 31)
      ],
      'pitru_paksha_arambh': [
        (2024, 9, 18),
        (2025, 9, 8),
        (2026, 9, 27),
        (2027, 9, 16),
        (2028, 9, 4),
        (2029, 9, 23),
        (2030, 9, 12)
      ],
      'sarvapitri_amavasya': [
        (2024, 10, 2),
        (2025, 9, 21),
        (2026, 10, 10),
        (2027, 9, 29),
        (2028, 9, 18),
        (2029, 10, 7),
        (2030, 9, 27)
      ],
      'dussehra': [
        (2024, 10, 12),
        (2025, 10, 2),
        (2026, 10, 20),
        (2027, 10, 9),
        (2028, 9, 27),
        (2029, 10, 16),
        (2030, 10, 6)
      ],
      // → D-130: संदर्भ-पंचांग के दिन-पन्ने, सातों साल «Kojagara Puja» और
      // «Sharad Purnima» उसी दिन। 2027 और 2028 में दूसरे दिन शाम को भी
      // पूर्णिमा है («केचित्» वाला मत) — पन्ना पहला दिन लिखता है, ग्रंथ भी।
      'sharad_purnima': [
        (2024, 10, 16),
        (2025, 10, 6),
        (2026, 10, 25),
        (2027, 10, 14),
        (2028, 10, 2),
        (2029, 10, 21),
        (2030, 10, 10)
      ],
      'karwa_chauth': [
        (2024, 10, 20),
        (2025, 10, 10),
        (2026, 10, 29),
        (2027, 10, 18),
        (2028, 10, 7),
        (2029, 10, 26),
        (2030, 10, 15)
      ],
      'chhath': [
        (2024, 11, 7),
        (2025, 10, 27),
        (2026, 11, 15),
        (2027, 11, 4),
        (2028, 10, 23),
        (2029, 11, 11),
        (2030, 11, 1) // अपराह्न वाला नियम 31 अक्टू देता था — संदर्भ में 1 नव
      ],
      // → D-140: धर्मसिंधु पृ. 98 — प्रबोधिनी के पारण वाले दिन। 2024–2026 कई
      // पंचांग-पन्नों से, 2027–2030 DekhoPanchang से। 2025 में द्वादशी किसी
      // सूर्योदय को नहीं छूती — पहला ढाँचा (एकादशी-सूर्योदय + 1) 3 नव देता था।
      'tulsi_vivah': [
        (2024, 11, 13),
        (2025, 11, 2),
        (2026, 11, 21),
        (2027, 11, 11),
        (2028, 10, 29),
        (2029, 11, 17),
        (2030, 11, 6)
      ],
      // → D-140: प्रदोष वाली पूर्णिमा। 2027 और 2028 Drik के देव दीपावली पन्ने
      // से (13 नव, 1 नव) — दोनों साल कार्तिक पूर्णिमा से एक दिन पहले।
      'dev_deepawali': [
        (2024, 11, 15),
        (2025, 11, 5),
        (2026, 11, 24),
        (2027, 11, 13),
        (2028, 11, 1),
        (2029, 11, 20),
        (2030, 11, 9)
      ],
      'kartik_purnima': [
        (2024, 11, 15),
        (2025, 11, 5),
        (2026, 11, 24),
        (2027, 11, 14),
        (2028, 11, 2),
        (2029, 11, 21),
        (2030, 11, 10)
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

  group('बारह पुराने त्योहार — सात साल, हर तारीख़ संदर्भ-पंचांग से (→ D-117)',
      () {
    // 2024–2030, दिल्ली। 8 अक्टूबर 2026 तक ये बारह सिर्फ़ 2026 पर जँचे थे।
    // सात साल पर जाँचा तो पाँच नियमों की दस तारीख़ें एक दिन इधर-उधर निकलीं
    // (नीचे ✎) — उन पाँचों का नियम अब धर्मसिंधु के छपे पन्ने से है।
    const verified = {
      'maha_shivaratri': [
        (2024, 3, 8),
        (2025, 2, 26),
        (2026, 2, 15),
        (2027, 3, 6),
        (2028, 2, 23),
        (2029, 2, 11),
        (2030, 3, 2)
      ],
      'holika_dahan': [
        (2024, 3, 24), // ✎ पहले 25
        (2025, 3, 13), // ✎ पहले 14
        (2026, 3, 3),
        (2027, 3, 21), // ✎ पहले 22
        (2028, 3, 10),
        (2029, 2, 28),
        (2030, 3, 19)
      ],
      'rama_navami': [
        (2024, 4, 17),
        (2025, 4, 6),
        (2026, 3, 26),
        (2027, 4, 15),
        (2028, 4, 3),
        (2029, 4, 23), // ✎ पहले 22
        (2030, 4, 12)
      ],
      'raksha_bandhan': [
        (2024, 8, 19),
        (2025, 8, 9), // ✎ पहले 8
        (2026, 8, 28),
        (2027, 8, 17),
        (2028, 8, 5),
        (2029, 8, 23), // ✎ पहले 24
        (2030, 8, 13)
      ],
      'janmashtami': [
        (2024, 8, 26),
        (2025, 8, 15), // संदर्भ में 15 «स्मार्त», 16 «इस्कॉन»
        (2026, 9, 4),
        (2027, 8, 25), // ✎ पहले 24
        (2028, 8, 13),
        (2029, 9, 1), // ✎ पहले 31 अगस्त
        (2030, 8, 21) // ✎ पहले 20
      ],
      'ganesh_chaturthi': [
        (2024, 9, 7),
        (2025, 8, 27),
        (2026, 9, 14),
        (2027, 9, 4),
        (2028, 8, 23),
        (2029, 9, 11),
        (2030, 9, 1)
      ],
      'navratri_ghatasthapana': [
        (2024, 10, 3),
        (2025, 9, 22),
        (2026, 10, 11),
        (2027, 9, 30),
        (2028, 9, 19),
        (2029, 10, 8),
        (2030, 9, 28)
      ],
      'diwali': [
        (2024, 11, 1), // ✎ पहले 31 अक्टूबर
        (2025, 10, 20),
        (2026, 11, 8),
        (2027, 10, 29),
        (2028, 10, 17),
        (2029, 11, 5),
        (2030, 10, 26)
      ],
      'dhanteras': [
        (2024, 10, 29),
        (2025, 10, 18),
        (2026, 11, 6),
        (2027, 10, 27),
        (2028, 10, 15),
        (2029, 11, 4),
        (2030, 10, 24)
      ],
      'govardhan_puja': [
        (2024, 11, 2),
        (2025, 10, 22),
        (2026, 11, 10),
        (2027, 10, 30),
        (2028, 10, 18),
        (2029, 11, 6),
        (2030, 10, 27)
      ],
      'bhai_dooj': [
        (2024, 11, 3),
        (2025, 10, 23),
        (2026, 11, 11),
        (2027, 10, 31),
        (2028, 10, 19),
        (2029, 11, 7),
        (2030, 10, 28)
      ],
      'vasant_panchami': [
        (2024, 2, 14),
        (2025, 2, 2),
        (2026, 1, 23),
        (2027, 2, 11),
        (2028, 1, 31),
        (2029, 1, 19),
        (2030, 2, 7)
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
  });

  group('पाँच निर्णय — धर्मसिंधु के छपे नियम (→ D-117)', () {
    FestivalDate nikalo(String id, int year) => findFestival(
        festivalRules.firstWhere((r) => r.id == id), year, Place.delhi)!;

    test(
        'सातों पर निर्णय लगा है (पाँच D-117, शरद पूर्णिमा D-130, तुलसी विवाह D-140), बाक़ी सत्रह पर नहीं',
        () {
      final nirnayWale = {
        for (final r in festivalRules)
          if (r.nirnaya != Nirnaya.vyapini) r.id: r.nirnaya
      };
      expect(nirnayWale, {
        'holika_dahan': Nirnaya.holika,
        'rama_navami': Nirnaya.ramNavami,
        'raksha_bandhan': Nirnaya.raksha,
        'janmashtami': Nirnaya.janmashtami,
        'diwali': Nirnaya.lakshmiPujan,
        'sharad_purnima': Nirnaya.kojagara,
        'tulsi_vivah': Nirnaya.paranDin,
      });
      for (final r in festivalRules) {
        final f = findFestival(r, 2027, Place.delhi)!;
        expect(
            f.explanation.contains('धर्मसिंधु'), r.nirnaya != Nirnaya.vyapini,
            reason: r.name);
      }
    });

    // → D-138 (स्वतंत्र जाँच J-001): दोनों दिन प्रदोष में अमावस्या एक घड़ी से कम —
    // पहले «काल छुआ नहीं» कहकर पहली रात देता था। ग्रंथकार का मत: दूसरे दिन
    // साढ़े तीन प्रहर से ज़्यादा हो तो दूसरा दिन। उस साल मुंबई में लक्ष्मी पूजा
    // रविवार 3 नवंबर को हुई (उस दिन की छपी ख़बर — JAANCH_SAMASYA_PANJI)।
    test(
        'दीपावली 2013 मुंबई: दोनों दिन प्रदोष थोड़ा-सा — दूसरा दिन, पहला भी दिखे',
        () {
      final f = findFestival(festivalRules.firstWhere((r) => r.id == 'diwali'),
          2013, Place.mumbai)!;
      expect(f.date, DateTime.utc(2013, 11, 3));
      expect(f.otherCandidate, DateTime.utc(2013, 11, 2));
      expect(f.missedKaal, isFalse, reason: 'दोनों दिन प्रदोष को छूती है');
      expect(f.explanation, contains('साढ़े तीन प्रहर'));
    });

    test('होलिका: भद्रा आधी रात से पहले छूटे तो उसी रात', () {
      // 2024: भद्रा 23:13 तक; 2025: 23:27 तक — दोनों बार पुराना नियम अगले दिन देता था
      for (final y in [2024, 2025]) {
        final f = nikalo('holika_dahan', y);
        expect(f.shiftedForBhadra, isFalse, reason: '$y');
        expect(f.explanation, contains('भद्रा आधी रात से पहले छूट जाती है'));
      }
    });

    test('होलिका: भद्रा आधी रात के बाद तक — साढ़े तीन प्रहर फ़ैसला करते हैं',
        () {
      // 2026: अगले दिन पूर्णिमा 17:07 तक (साढ़े तीन प्रहर ≈ 16:55) → अगले दिन
      final a = nikalo('holika_dahan', 2026);
      expect(a.date, DateTime.utc(2026, 3, 3));
      expect(a.shiftedForBhadra, isTrue);
      expect(a.explanation, contains('साढ़े तीन प्रहर से ज़्यादा'));

      // 2027: अगले दिन पूर्णिमा 16:13 तक (साढ़े तीन प्रहर ≈ 17:01) → उसी रात
      final b = nikalo('holika_dahan', 2027);
      expect(b.date, DateTime.utc(2027, 3, 21));
      expect(b.shiftedForBhadra, isFalse);
      expect(b.explanation, contains('साढ़े तीन प्रहर नहीं रहती'));
    });

    test(
        'रक्षाबंधन: सूर्योदय के बाद तीन मुहूर्त से कम पूर्णिमा हो तो पिछला दिन',
        () {
      // 2029: 24 अगस्त को सूर्योदय 05:55, पूर्णिमा 07:21 तक — डेढ़ घंटे से कम
      final f = nikalo('raksha_bandhan', 2029);
      expect(f.date, DateTime.utc(2029, 8, 23));
      expect(f.shiftedForBhadra, isFalse);
      expect(f.explanation, contains('तीन मुहूर्त से कम'));

      // 2025: अपराह्न में पूर्णिमा लगते ही भद्रा — अगला दिन
      final g = nikalo('raksha_bandhan', 2025);
      expect(g.date, DateTime.utc(2025, 8, 9));
      expect(g.shiftedForBhadra, isTrue);
      expect(g.explanation, contains('तीन मुहूर्त से ज़्यादा'));
    });

    test('रक्षाबंधन के दिन सूर्योदय से प्रदोष तक कहीं पूर्णिमा ज़रूर है', () {
      final rule = festivalRules.firstWhere((r) => r.id == 'raksha_bandhan');
      for (var y = 2024; y <= 2040; y++) {
        final f = findFestival(rule, y, Place.delhi)!;
        // चुने हुए दिन के सूर्योदय से प्रदोष के अंत तक कहीं न कहीं पूर्णिमा हो
        final rs =
            sunriseSunset(f.date.year, f.date.month, f.date.day, Place.delhi);
        final uday = rs.sunrise!.add(Place.delhi.timeZoneOffset);
        final pradoshAnt = rs.sunset!
            .add(Place.delhi.timeZoneOffset)
            .add(const Duration(hours: 2, minutes: 24));
        expect(f.tithiStart.isBefore(pradoshAnt) && f.tithiEnd.isAfter(uday),
            isTrue,
            reason: '$y — ${f.date}');
      }
    });

    test(
        'राम नवमी: दोनों दिन मध्याह्न हो तो दूसरा दिन, चाहे पहले में ज़्यादा देर',
        () {
      // 2029: 22 अप्रैल को 43 मिनट, 23 को 29 मिनट — फिर भी 23
      final f = nikalo('rama_navami', 2029);
      expect(f.date, DateTime.utc(2029, 4, 23));
      expect(f.ambiguous, isFalse);
      expect(f.explanation, contains('दोनों दिन मध्याह्न'));

      // 2026 और 2028: मध्याह्न सिर्फ़ पहले दिन — पहला दिन
      expect(nikalo('rama_navami', 2026).date, DateTime.utc(2026, 3, 26));
      expect(nikalo('rama_navami', 2028).date, DateTime.utc(2028, 4, 3));
    });

    test('दीपावली: दूसरे दिन प्रदोष में एक घड़ी से ज़्यादा हो तभी दूसरा दिन',
        () {
      // 2024: दूसरे दिन सूर्यास्त के बाद 41 मिनट → 1 नवम्बर; दूसरा दावेदार 31 अक्टूबर
      final a = nikalo('diwali', 2024);
      expect(a.date, DateTime.utc(2024, 11, 1));
      expect(a.ambiguous, isTrue);
      expect(a.otherCandidate, DateTime.utc(2024, 10, 31));
      expect(a.explanation, contains('एक घड़ी से ज़्यादा'));

      // 2025: दूसरे दिन सिर्फ़ 9 मिनट → 20 अक्टूबर; दूसरा दावेदार 21
      final b = nikalo('diwali', 2025);
      expect(b.date, DateTime.utc(2025, 10, 20));
      expect(b.ambiguous, isTrue);
      expect(b.otherCandidate, DateTime.utc(2025, 10, 21));
      expect(b.explanation, contains('एक घड़ी से कम'));

      // 2026: एक ही दावेदार
      expect(nikalo('diwali', 2026).ambiguous, isFalse);
    });

    test('जन्माष्टमी: रोहिणी दूसरे दिन जुड़े तो दूसरा दिन, पहला भी दिखता है',
        () {
      for (final (y, m, d, dm, dd) in [
        (2027, 8, 25, 8, 24),
        (2029, 9, 1, 8, 31),
        (2030, 8, 21, 8, 20),
      ]) {
        final f = nikalo('janmashtami', y);
        expect(f.date, DateTime.utc(y, m, d), reason: '$y');
        expect(f.ambiguous, isTrue, reason: '$y');
        expect(f.otherCandidate, DateTime.utc(y, dm, dd), reason: '$y');
        expect(f.explanation, contains('रोहिणी —'), reason: '$y');
        expect(f.explanation, contains('दूसरा दिन ($d/$m)'), reason: '$y');
      }
    });

    test('जन्माष्टमी: रोहिणी न हो तो आधी रात की अष्टमी से', () {
      // 2025: अष्टमी 15 की रात 23:50 पर लगी, 16 को 21:34 तक — रोहिणी नहीं
      final f = nikalo('janmashtami', 2025);
      expect(f.date, DateTime.utc(2025, 8, 15));
      expect(f.otherCandidate, DateTime.utc(2025, 8, 16));
      expect(f.explanation, contains('रोहिणी नक्षत्र नहीं पड़ता'));
      expect(f.explanation, contains('आधी रात को अष्टमी सिर्फ़ पहले दिन'));

      // 2024, 2026, 2028: दूसरा कोई दावेदार नहीं
      for (final y in [2024, 2026, 2028]) {
        expect(nikalo('janmashtami', y).ambiguous, isFalse, reason: '$y');
      }
    });

    test('जन्माष्टमी — आठ और साल, संदर्भ-पंचांग के «स्मार्त» वाले दिन से', () {
      // आधी रात के योग वाली शाखाएँ 2024–2030 में कम आती हैं, इसलिए पीछे-आगे के
      // वे साल भी जाँचे जिनमें आती हैं। पन्ने 8 अक्टूबर 2026 को देखे।
      for (final (y, m, d) in [
        (2002, 8, 31),
        (2005, 8, 26),
        (2007, 9, 3),
        (2010, 9, 1),
        (2018, 9, 2),
        (2021, 8, 30),
        (2023, 9, 6),
        (2037, 9, 2),
      ]) {
        expect(nikalo('janmashtami', y).date, DateTime.utc(y, m, d),
            reason: '$y');
      }
    });

    test('जन्माष्टमी: जहाँ ग्रंथ और संदर्भ-पंचांग अलग हैं, दोनों दिन दिखते हैं',
        () {
      // पहली रात आधी रात को अष्टमी-रोहिणी साथ, और रोहिणी अगली आधी रात तक —
      // धर्मसिंधु पहला दिन कहता है, संदर्भ-पंचांग दूसरा (28 अगस्त 2032;
      // मुंबई में 1 सितम्बर 2029)। ऐप पहला दिन देता है और दूसरा साथ दिखाता है।
      // ⚠️ यह जाँच फ़ैसला याद रखने के लिए है, यह साबित करने के लिए नहीं कि
      // पहला दिन ही सही है — छपे पंचांग से मिलाना बाक़ी है।
      final a = nikalo('janmashtami', 2032);
      expect(a.date, DateTime.utc(2032, 8, 27));
      expect(a.otherCandidate, DateTime.utc(2032, 8, 28));

      final rule = festivalRules.firstWhere((r) => r.id == 'janmashtami');
      final b = findFestival(rule, 2029, Place.mumbai)!;
      expect(b.date, DateTime.utc(2029, 8, 31));
      expect(b.otherCandidate, DateTime.utc(2029, 9, 1));
      // दिल्ली में उसी साल रोहिणी आधी रात के 12 मिनट बाद लगती है — दूसरा दिन
      expect(nikalo('janmashtami', 2029).date, DateTime.utc(2029, 9, 1));
    });

    test('शहर बदलने से दिन बदलता है — मुंबई के दो पन्ने संदर्भ-पंचांग से मिले',
        () {
      FestivalDate mumbai(String id, int year) => findFestival(
          festivalRules.firstWhere((r) => r.id == id), year, Place.mumbai)!;

      // दीपावली 2024: मुंबई में सूर्यास्त देर से — दूसरे दिन अमावस्या एक घड़ी
      // नहीं रहती → 31 अक्टूबर (दिल्ली 1 नवम्बर)
      final d = mumbai('diwali', 2024);
      expect(d.date, DateTime.utc(2024, 10, 31));
      expect(d.otherCandidate, DateTime.utc(2024, 11, 1));
      expect(d.explanation, contains('एक घड़ी से कम'));

      // होलिका 2026: मुंबई में दिन लंबा — साढ़े तीन प्रहर पूरे नहीं होते
      // → 2 मार्च (दिल्ली 3 मार्च)
      final h = mumbai('holika_dahan', 2026);
      expect(h.date, DateTime.utc(2026, 3, 2));
      expect(h.shiftedForBhadra, isFalse);
      expect(h.explanation, contains('साढ़े तीन प्रहर नहीं रहती'));
    });

    test('दूसरा दावेदार हमेशा ठीक एक दिन आगे या पीछे', () {
      for (final rule in festivalRules) {
        for (var y = 2024; y <= 2040; y++) {
          final f = findFestival(rule, y, Place.delhi)!;
          expect(f.ambiguous, f.otherCandidate != null,
              reason: '${rule.id} $y');
          if (f.otherCandidate != null) {
            expect(f.otherCandidate!.difference(f.date).inDays.abs(), 1,
                reason: '${rule.id} $y');
          }
        }
      }
    });

    test('हिसाब में किसी वेबसाइट का नाम या रोमन अक्षर नहीं', () {
      final roman = RegExp('[A-Za-z]');
      for (final rule in festivalRules) {
        for (var y = 2024; y <= 2032; y++) {
          final f = findFestival(rule, y, Place.delhi)!;
          expect(roman.hasMatch(f.explanation), isFalse,
              reason: '${rule.id} $y: ${f.explanation}');
        }
      }
    });

    test('दूसरे शहरों में भी हर साल एक तारीख़ निकलती है', () {
      // नए नियम सूर्योदय, सूर्यास्त और आधी रात पर टिके हैं — जो शहर से बदलते हैं
      for (final place in [Place.chennai, Place.delhi]) {
        for (final rule
            in festivalRules.where((r) => r.nirnaya != Nirnaya.vyapini)) {
          for (var y = 2024; y <= 2045; y++) {
            final f = findFestival(rule, y, place);
            expect(f, isNotNull, reason: '${rule.id} $y');
            expect(f!.date.year, y, reason: '${rule.id} $y');
            // चुना हुआ दिन तिथि से एक दिन से ज़्यादा दूर नहीं
            final shuru = DateTime.utc(
                f.tithiStart.year, f.tithiStart.month, f.tithiStart.day);
            expect(f.date.difference(shuru).inDays, inInclusiveRange(-1, 2),
                reason: '${rule.id} $y');
          }
        }
      }
    });
  });

  group('भद्रा वाला नियम', () {
    test('होलिका दहन और रक्षाबंधन दोनों भद्रा की वजह से खिसकते हैं', () {
      // 2026 में दोनों की पूर्णिमा का पहला आधा हिस्सा भद्रा में है, और
      // भद्रा उस दिन के ज़रूरी काल को पूरा ढक लेती है। इसलिए त्योहार
      // अगले दिन चला जाता है — और Drik भी यही कहता है।
      // (हर साल नहीं: होलिका 2024, 2025 और 2027 में उसी रात रहती है —
      // ऊपर «पाँच निर्णय» में।)
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

  group('तुलसी विवाह — पारण वाला दिन (→ D-140)', () {
    final rule = festivalRules.firstWhere((r) => r.id == 'tulsi_vivah');

    test('2025: द्वादशी क्षय — वह दिन जिसमें द्वादशी है, «काल नहीं छुआ» नहीं',
        () {
      final f = findFestival(rule, 2025, Place.delhi)!;
      expect(f.date, DateTime.utc(2025, 11, 2));
      expect(f.missedKaal, isFalse);
      expect(f.ambiguous, isFalse);
      expect(f.explanation, contains('द्वादशी किसी सूर्योदय को नहीं छूती'));
    });

    test('2028: द्वादशी दो सूर्योदय तक — पहला दिन, एक ही तारीख़', () {
      final f = findFestival(rule, 2028, Place.delhi)!;
      expect(f.date, DateTime.utc(2028, 10, 29));
      expect(f.otherCandidate, isNull);
      expect(f.explanation, contains('पारण पहले दिन'));
    });

    test('हिसाब में «प्रदोष व्यापिनी» नहीं — पारण का दिन, और एकादशी का समय',
        () {
      final f = findFestival(rule, 2026, Place.delhi)!;
      expect(f.explanation, isNot(contains('प्रदोष व्यापिनी')));
      expect(f.explanation, contains('पारण वाले दिन, रात के पहले भाग में'));
      expect(f.explanation, contains('एकादशी (व्रत) — 20/11'));
      // काल = उसी दिन का प्रदोष (धर्मसिंधु का «पूर्वरात्रौ»)
      expect(f.kaalStart.day, 21);
      expect(f.kaalStart.hour, 17);
    });

    test(
        '2015–2040: हमेशा प्रबोधिनी के अगले एक-दो दिन में, कार्तिक पूर्णिमा से पहले',
        () {
      final purnima = festivalRules.firstWhere((r) => r.id == 'kartik_purnima');
      for (var y = 2015; y <= 2040; y++) {
        final f = findFestival(rule, y, Place.delhi)!;
        final p = findFestival(purnima, y, Place.delhi)!;
        final kitne = p.date.difference(f.date).inDays;
        expect(kitne, inInclusiveRange(2, 4), reason: '$y');
      }
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
      'sharad_purnima': [9, 10, 11],
      'tulsi_vivah': [10, 11],
      'dev_deepawali': [10, 11],
      'kartik_purnima': [10, 11, 12],
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
        // पारण वाले दिन तिथि बदल चुकी होती है — वहाँ व्यापिनी नहीं, शर्त (→ D-140)
        expect(
            found.explanation,
            contains(rule.nirnaya == Nirnaya.paranDin
                ? rule.nirnaya.visheshan!
                : rule.vyapini.hindi));
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
