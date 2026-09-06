import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// सूर्यग्रहण — स्थानकेंद्रीय सदिशों वाला सीधा तरीक़ा (→ D-055)।
///
/// ## यहाँ मिलान दो जगह से है, और दोनों ज़रूरी हैं
///
/// - **NASA/GSFC** (Espenak) — *पूरी पृथ्वी* की बात: ग्रहण का विश्व-मध्य,
///   केंद्रीय है या नहीं, और केंद्रीय रेखा पर खग्रास कितनी देर।
/// - **Drik Panchang** — *एक शहर* की बात: स्पर्श, मध्य, मोक्ष, मान, और
///   सूतक। यही वो हिस्सा है जो यूज़र को दिखेगा।
///
/// ⚠️ भारत के शहर यहाँ कम हैं, और यह मजबूरी है: Drik के पन्ने पर
/// सूर्यग्रहण का डेटा **6 फ़रवरी 2027 तक** ही है, और उस तारीख़ तक भारत से
/// कोई सूर्यग्रहण दिखता ही नहीं। इसलिए मिलान मैड्रिड, रेक्याविक, ब्यूनस
/// आयर्स और केप टाउन से करना पड़ा। **गणित शहर नहीं देखता** — जो चारों
/// जगह सही है वो दिल्ली में भी सही होगा।
void main() {
  const madrid = Place(
      name: 'Madrid',
      latitude: 40.4168,
      longitude: -3.7038,
      timeZoneOffset: Duration(hours: 2));
  const reykjavik = Place(
      name: 'Reykjavik',
      latitude: 64.1466,
      longitude: -21.9426,
      timeZoneOffset: Duration.zero);
  const buenosAires = Place(
      name: 'Buenos Aires',
      latitude: -34.6118,
      longitude: -58.4173,
      timeZoneOffset: Duration(hours: -3));
  const capeTown = Place(
      name: 'Cape Town',
      latitude: -33.9249,
      longitude: 18.4241,
      timeZoneOffset: Duration(hours: 2));
  const luxor = Place(
      name: 'Luxor',
      latitude: 25.6872,
      longitude: 32.6396,
      timeZoneOffset: Duration(hours: 2));

  final chheSaal = suryaGrahan(
    se: DateTime.utc(2025, 1, 1),
    tak: DateTime.utc(2031, 1, 1),
  );

  SuryaGrahan ek(int y, int m, int d) => suryaGrahan(
        se: DateTime.utc(y, m, d).subtract(const Duration(days: 1)),
        tak: DateTime.utc(y, m, d).add(const Duration(days: 1)),
      ).single;

  group('गणित की अपनी सच्चाई', () {
    test('हर ग्रहण अमावस्या पर ही पड़ता है', () {
      for (final g in chheSaal) {
        final p = computePanchang(
            g.madhya.year, g.madhya.month, g.madhya.day, Place.delhi);
        // तिथि 0..29; अमावस्या = 29 (तीसवीं), किनारे पर 0 भी चल जाए
        final door = p.tithi.index;
        expect(door >= 28 || door <= 1, isTrue,
            reason: '${g.madhya} पर तिथि ${p.tithi.name} — अमावस्या नहीं');
      }
    });

    test('स्पर्श, मध्य और मोक्ष क्रम में हैं', () {
      for (final g in chheSaal) {
        for (final p in [madrid, reykjavik, buenosAires, capeTown, luxor]) {
          final d = suryaGrahanYahanSe(g, p);
          if (!d.dikhega) continue;
          expect(d.shuru!.isBefore(d.madhya!), isTrue,
              reason: '${p.name} ${g.madhya}: स्पर्श मध्य के बाद');
          expect(d.madhya!.isBefore(d.khatm!), isTrue);
          if (d.kendriyaShuru != null) {
            expect(d.shuru!.isBefore(d.kendriyaShuru!), isTrue);
            expect(d.kendriyaShuru!.isBefore(d.kendriyaKhatm!), isTrue);
            expect(d.kendriyaKhatm!.isBefore(d.khatm!), isTrue);
          }
        }
      }
    });

    test('जहाँ ग्रहण नहीं, वहाँ न समय है न सूतक', () {
      for (final g in chheSaal) {
        final d = suryaGrahanYahanSe(g, Place.delhi);
        if (d.dikhega) continue;
        expect(d.shuru, isNull);
        expect(d.khatm, isNull);
        expect(d.maan, 0);
        expect(d.sutakShuru, isNull);
        expect(d.komalSutakShuru, isNull);
      }
    });

    test('केंद्रीय दशा सिर्फ़ वहीं जहाँ मान एक से ऊपर पहुँचे', () {
      for (final g in chheSaal) {
        for (final p in [madrid, reykjavik, buenosAires, capeTown, luxor]) {
          final d = suryaGrahanYahanSe(g, p);
          if (d.prakar == SuryaGrahanPrakar.khandgras) {
            expect(d.maan < 1, isTrue,
                reason: '${p.name}: खंडग्रास में मान ${d.maan}');
          } else if (d.prakar == SuryaGrahanPrakar.khagras) {
            expect(d.maan >= 1, isTrue,
                reason: '${p.name}: खग्रास में मान ${d.maan}');
          }
        }
      }
    });

    test('जगह बदलने से जवाब बदलता है — यही पूरी बात है', () {
      // सूर्यग्रहण की सारी नाज़ुकी यही है। अगर हर शहर का जवाब एक जैसा आ
      // रहा है तो लंबन देखा ही नहीं जा रहा।
      final g = ek(2027, 8, 2);
      final maan = [madrid, reykjavik, buenosAires, capeTown, luxor]
          .map((p) => suryaGrahanYahanSe(g, p).maan)
          .toSet();
      expect(maan.length > 1, isTrue);
    });
  });

  // ── NASA/GSFC — Solar Eclipses: 2021–2030 (Fred Espenak) ─────────
  //
  // तारीख़ · TD (विश्व-मध्य) · केंद्रीय है या नहीं
  group('NASA के कैटलॉग से मिलान — पूरी पृथ्वी', () {
    const nasa = [
      ('2025-03-29', '10:48:36', false),
      ('2025-09-21', '19:43:04', false),
      ('2026-02-17', '12:13:05', true),
      ('2026-08-12', '17:47:05', true),
      ('2027-02-06', '16:00:47', true),
      ('2027-08-02', '10:07:49', true),
      ('2028-01-26', '15:08:58', true),
      ('2028-07-22', '02:56:39', true),
      ('2029-01-14', '17:13:47', false),
      ('2029-06-12', '04:06:13', false),
      ('2029-07-11', '15:37:18', false),
      ('2029-12-05', '15:03:57', false),
      ('2030-06-01', '06:29:13', true),
      ('2030-11-25', '06:51:37', true),
    ];

    test('एक भी ग्रहण न छूटा, न कोई फ़ालतू निकला', () {
      expect(chheSaal, hasLength(nasa.length));
    });

    test('विश्व-मध्य का समय डेढ़ मिनट के भीतर है', () {
      // ⚠️ NASA का समय **TD** में है, हमारा **UT** में। तुलना से पहले ΔT
      // जोड़ना पड़ता है — 2027 में लगभग सत्तर सेकंड। यह भूलने पर हर जवाब
      // एक जैसा खिसका दिखेगा, और वो असली ग़लती नहीं होगी।
      for (final (tarikh, samay, _) in nasa) {
        final td = DateTime.parse('${tarikh}T${samay}Z');
        final apna = chheSaal.firstWhere(
            (g) => g.madhya.difference(td).abs() < const Duration(hours: 6));
        final deltaT =
            Duration(seconds: deltaTSeconds(apna.madhya.year, 1).round());
        final fark = apna.madhya.add(deltaT).difference(td).abs();
        expect(fark < const Duration(seconds: 90), isTrue,
            reason: '$tarikh — NASA $samay TD, हमारा '
                '${apna.madhya.add(deltaT)} — फ़र्क़ $fark');
      }
    });

    test('कौन सा ग्रहण केंद्रीय है, यह चौदहों पर सही निकलता है', () {
      for (final (tarikh, samay, kendriya) in nasa) {
        final td = DateTime.parse('${tarikh}T${samay}Z');
        final apna = chheSaal.firstWhere(
            (g) => g.madhya.difference(td).abs() < const Duration(hours: 6));
        expect(apna.kendriya, kendriya,
            reason: '$tarikh — gamma ${apna.gamma}');
      }
    });

    test('लक्सर में खग्रास 6मि 23से का है — NASA की केंद्रीय अवधि वही है',
        () {
      // 2 अगस्त 2027 का विश्व-मध्य लक्सर के लगभग ऊपर ही पड़ता है, इसलिए
      // वहाँ की अवधि सीधे NASA की छपी अवधि से मिलनी चाहिए।
      final d = suryaGrahanYahanSe(ek(2027, 8, 2), luxor);
      expect(d.prakar, SuryaGrahanPrakar.khagras);
      final fark = (d.kendriyaAvadhi! - const Duration(seconds: 383)).abs();
      expect(fark < const Duration(seconds: 15), isTrue,
          reason: 'NASA 06म23से, हमारा ${d.kendriyaAvadhi}');
    });
  });

  // ── Drik Panchang — 5 सितम्बर 2026 को नापा गया ───────────────────
  group('Drik Panchang से मिलान — चार शहर, दो ग्रहण', () {
    DateTime sthaniya(Place p, int y, int m, int d, int hh, int mm) =>
        DateTime.utc(y, m, d, hh, mm).subtract(p.timeZoneOffset);

    void kareeb(DateTime? mila, DateTime chahiye, Duration chhoot, String kya) {
      expect(mila, isNotNull, reason: '$kya मिला ही नहीं');
      final fark = mila!.difference(chahiye).abs();
      expect(fark <= chhoot, isTrue,
          reason: '$kya — Drik $chahiye, हमारा $mila, फ़र्क़ $fark');
    }

    // Drik मिनट तक ही छापता है; ऊपर से बहुत छिछले ग्रहण में स्पर्श का
    // क्षण अपने आप नाज़ुक होता है (बिंब बस छूकर निकल जाते हैं)।
    const sparshChhoot = Duration(minutes: 2);
    // सूतक प्रहर की सीमा पर बैठता है, वहाँ छूट कम रखी जा सकती है।
    const sutakChhoot = Duration(seconds: 90);

    test('मैड्रिड, 12 अगस्त 2026 — ग्रहण सूर्यास्त पर कटता है', () {
      final d = suryaGrahanYahanSe(ek(2026, 8, 12), madrid);
      expect(d.prakar, SuryaGrahanPrakar.khandgras);

      // Drik: Start 19:36 · Max 20:32 · "would end with Sunset" 21:16
      kareeb(d.shuru, sthaniya(madrid, 2026, 8, 12, 19, 36), sparshChhoot,
          'स्पर्श');
      kareeb(d.madhya, sthaniya(madrid, 2026, 8, 12, 20, 32), sparshChhoot,
          'मध्य');
      kareeb(d.khatm, sthaniya(madrid, 2026, 8, 12, 21, 16), sparshChhoot,
          'मोक्ष (सूर्यास्त पर)');
      // ⚠️ यही वो जगह है जहाँ एक असली बग निकला था: सूरज "ऊपर" की दहलीज़
      // शून्य रखने पर मोक्ष 21:11 आता था, यानी साढ़े चार मिनट जल्दी।
      final ast = sunriseSunset(2026, 8, 12, madrid).sunset!;
      expect((d.khatm!.difference(ast)).abs() < const Duration(minutes: 1),
          isTrue,
          reason: 'ग्रहण ठीक सूर्यास्त पर कटना चाहिए');

      // Drik: Maximum Magnitude 0.99
      expect((d.maan - 0.99).abs() < 0.02, isTrue, reason: 'मान ${d.maan}');
      // Drik: Sutak 04:51 · Kids 14:20
      kareeb(d.sutakShuru, sthaniya(madrid, 2026, 8, 12, 4, 51), sutakChhoot,
          'सूतक');
      kareeb(d.komalSutakShuru, sthaniya(madrid, 2026, 8, 12, 14, 20),
          sutakChhoot, 'कोमल सूतक');
    });

    test('रेक्याविक, 12 अगस्त 2026 — खग्रास, सिर्फ़ एक मिनट का', () {
      final d = suryaGrahanYahanSe(ek(2026, 8, 12), reykjavik);
      expect(d.prakar, SuryaGrahanPrakar.khagras);

      // Drik: Start 16:47 · Total 17:48–17:49 · Max 17:48 · End 18:47
      kareeb(d.shuru, sthaniya(reykjavik, 2026, 8, 12, 16, 47), sparshChhoot,
          'स्पर्श');
      kareeb(d.kendriyaShuru, sthaniya(reykjavik, 2026, 8, 12, 17, 48),
          sparshChhoot, 'खग्रास की शुरुआत');
      kareeb(d.kendriyaKhatm, sthaniya(reykjavik, 2026, 8, 12, 17, 49),
          sparshChhoot, 'खग्रास का अंत');
      kareeb(d.khatm, sthaniya(reykjavik, 2026, 8, 12, 18, 47), sparshChhoot,
          'मोक्ष');

      // Drik: Total Eclipse Duration 01 Min 05 Secs
      final fark = (d.kendriyaAvadhi! - const Duration(seconds: 65)).abs();
      expect(fark < const Duration(seconds: 15), isTrue,
          reason: 'खग्रास की अवधि ${d.kendriyaAvadhi}');

      // ⚠️ Drik यहाँ मान **1.00** छापता है, 1.039 नहीं — जबकि पूरे ग्रहण
      // का मान 1.039 है। रेक्याविक छाया के ठीक किनारे पर है। यही जाँच उस
      // ग़लती को पकड़ती है जिसमें केंद्रीय दशा के लिए अलग सूत्र लगा दिया
      // गया था (→ D-055)।
      expect((d.maan - 1.00).abs() < 0.02, isTrue,
          reason: 'मान ${d.maan} — 1.039 आ रहा हो तो विश्व वाला सूत्र लगा है');

      // Drik: Sutak 01:33 · Kids 09:20
      kareeb(d.sutakShuru, sthaniya(reykjavik, 2026, 8, 12, 1, 33),
          sutakChhoot, 'सूतक');
      kareeb(d.komalSutakShuru, sthaniya(reykjavik, 2026, 8, 12, 9, 20),
          sutakChhoot, 'कोमल सूतक');
    });

    test('ब्यूनस आयर्स, 6 फ़रवरी 2027 — साढ़े तीन घंटे का खंडग्रास', () {
      final d = suryaGrahanYahanSe(ek(2027, 2, 6), buenosAires);
      expect(d.prakar, SuryaGrahanPrakar.khandgras);

      // Drik: Max 12:31 · End 14:15 · Duration 03h 29m 17s · Mag 0.87
      kareeb(d.madhya, sthaniya(buenosAires, 2027, 2, 6, 12, 31), sparshChhoot,
          'मध्य');
      kareeb(d.khatm, sthaniya(buenosAires, 2027, 2, 6, 14, 15), sparshChhoot,
          'मोक्ष');
      final avadhi = d.khatm!.difference(d.shuru!);
      final fark =
          (avadhi - const Duration(hours: 3, minutes: 29, seconds: 17)).abs();
      expect(fark < const Duration(seconds: 30), isTrue,
          reason: 'Drik 3घं 29मि 17से, हमारा $avadhi');
      expect((d.maan - 0.87).abs() < 0.02, isTrue, reason: 'मान ${d.maan}');

      // Drik: Sutak 22:32 (5 Feb) · Kids 06:19 — और वो ठीक सूर्योदय है
      kareeb(d.sutakShuru, sthaniya(buenosAires, 2027, 2, 5, 22, 32),
          sutakChhoot, 'सूतक');
      kareeb(d.komalSutakShuru, sthaniya(buenosAires, 2027, 2, 6, 6, 19),
          sutakChhoot, 'कोमल सूतक');
    });

    test('केप टाउन, 6 फ़रवरी 2027 — बस छूकर निकलता ग्रहण', () {
      // मान सिर्फ़ 0.07 — बिंब मुश्किल से छूते हैं। ऐसे ग्रहण में स्पर्श
      // का क्षण अपने आप नाज़ुक होता है, इसलिए छूट थोड़ी ज़्यादा है।
      final d = suryaGrahanYahanSe(ek(2027, 2, 6), capeTown);
      expect(d.prakar, SuryaGrahanPrakar.khandgras);
      expect((d.maan - 0.07).abs() < 0.02, isTrue, reason: 'मान ${d.maan}');

      kareeb(d.khatm, sthaniya(capeTown, 2027, 2, 6, 19, 22), sparshChhoot,
          'मोक्ष');
      // Drik: Sutak 03:37 · Kids 13:00
      kareeb(d.sutakShuru, sthaniya(capeTown, 2027, 2, 6, 3, 37), sutakChhoot,
          'सूतक');
      kareeb(d.komalSutakShuru, sthaniya(capeTown, 2027, 2, 6, 13, 0),
          sutakChhoot, 'कोमल सूतक');
    });
  });

  group('सूतक — चार प्रहर, तीन नहीं', () {
    test('सूर्यग्रहण का सूतक चंद्रग्रहण से एक प्रहर लंबा होता है', () {
      expect(suryaGrahanKeSutakKePrahar, 4);
      expect(chandraGrahanKeSutakKePrahar, 3);
    });

    test('सूतक ठीक चार प्रहर पीछे वाली सीमा पर बैठता है', () {
      for (final g in chheSaal) {
        for (final p in [madrid, reykjavik, buenosAires, capeTown, luxor]) {
          final d = suryaGrahanYahanSe(g, p);
          if (!d.dikhega) continue;
          expect(d.sutakShuru, praharPeeche(d.shuru!, p, 4));
          expect(d.komalSutakShuru, praharPeeche(d.shuru!, p, 1));
          expect(d.sutakKhatm, d.khatm);
        }
      }
    });

    test('सूतक बारह घंटे का "लगभग" होता है, ठीक बारह का कभी नहीं', () {
      final avadhiyan = <Duration>{};
      for (final g in chheSaal) {
        for (final p in [madrid, buenosAires, capeTown]) {
          final d = suryaGrahanYahanSe(g, p);
          if (!d.dikhega) continue;
          avadhiyan.add(d.shuru!.difference(d.sutakShuru!));
        }
      }
      expect(avadhiyan, isNotEmpty);
      expect(avadhiyan.contains(const Duration(hours: 12)), isFalse,
          reason: 'ठीक बारह घंटे आ रहे हैं — प्रहर देखे ही नहीं जा रहे');
    });
  });
}
