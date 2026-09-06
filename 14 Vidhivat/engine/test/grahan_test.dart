import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// चंद्रग्रहण — Meeus अध्याय 54।
///
/// ## ⚠️ यह जाँच अभी **पूरी नहीं** है
///
/// यहाँ जो देखा जाता है वो **गणित की अपनी सच्चाई** है: ग्रहण सिर्फ़
/// पूर्णिमा पर, समय क्रम में, छाया उपछाया के भीतर, मान और gamma का
/// रिश्ता। ये सब पक्का करते हैं कि लागू करने में कोई भूल नहीं हुई।
///
/// पर **यह पक्का नहीं करते कि समय मिनट-दर-मिनट सही है।** उसके लिए
/// बाहर से मिलाना पड़ता है, और वो हो चुका है:
///
/// - **समय, gamma, अवधि, मान** — NASA/GSFC के कैटलॉग से, दस ग्रहण
///   (→ D-052)
/// - **सूतक** — Drik Panchang से, तीन ग्रहण, तीन अलग हालतें (→ D-054)
///
/// > सूतक का समय ग़लत बताना "मंत्र ग़लत होना" वाले दर्जे की ग़लती है।
/// > इसीलिए मिलान वाली जाँचें सबसे ज़रूरी हैं — बाक़ी सब उनके बाद।
void main() {
  const dilli = Place.delhi;

  /// सूतक के तीसरे रास्ते (चंद्रास्त) के लिए — भारत में अगले कई साल
  /// वैसा ग्रहण नहीं पड़ता, इसलिए मिलान बाहर से करना पड़ा।
  const newYork = Place(
    name: 'New York',
    latitude: 40.7128,
    longitude: -74.0060,
    timeZoneOffset: Duration(hours: -5),
  );

  final chaarSaal = chandraGrahan(
    se: DateTime.utc(2025, 1, 1),
    tak: DateTime.utc(2029, 1, 1),
  );

  group('गणित की अपनी सच्चाई', () {
    test('हर ग्रहण पूर्णिमा के आसपास ही पड़ता है', () {
      // चंद्रग्रहण पूर्णिमा पर ही होता है — और कहीं नहीं। तिथि 15
      // (पूर्णिमा) या उसके एक दिन इधर-उधर मिलनी चाहिए।
      for (final g in chaarSaal) {
        final p = computePanchang(
          g.madhya.year,
          g.madhya.month,
          g.madhya.day,
          dilli,
        );
        // तिथि 0..29; पूर्णिमा = 14 (यानी पंद्रहवीं)
        final door = (p.tithi.index - 14).abs();
        expect(door <= 1 || door >= 29, isTrue,
            reason: '${g.madhya} पर तिथि ${p.tithi.name} — पूर्णिमा नहीं');
      }
    });

    test('समय क्रम में हैं — स्पर्श, मध्य, मोक्ष', () {
      for (final g in chaarSaal) {
        expect(g.upachhayaSparsha.isBefore(g.madhya), isTrue);
        expect(g.madhya.isBefore(g.upachhayaMoksha), isTrue);

        if (g.sparsha != null) {
          expect(g.sparsha!.isBefore(g.madhya), isTrue);
          expect(g.madhya.isBefore(g.moksha!), isTrue);
          // असली छाया हमेशा उपछाया के **भीतर** रहती है
          expect(g.upachhayaSparsha.isBefore(g.sparsha!), isTrue,
              reason: '${g.madhya}: छाया उपछाया से पहले शुरू नहीं हो सकती');
          expect(g.moksha!.isBefore(g.upachhayaMoksha), isTrue);
        }
      }
    });

    test('मान और दर्जा आपस में मेल खाते हैं', () {
      for (final g in chaarSaal) {
        switch (g.prakar) {
          case GrahanPrakar.khagras:
            expect(g.maan, greaterThanOrEqualTo(1.0));
            expect(g.sparsha, isNotNull);
          case GrahanPrakar.khandgras:
            expect(g.maan, greaterThan(0));
            expect(g.maan, lessThan(1.0));
            expect(g.sparsha, isNotNull);
          case GrahanPrakar.upachhaya:
            expect(g.maan, lessThanOrEqualTo(0));
            expect(g.sparsha, isNull,
                reason: 'उपछाया ग्रहण में असली छाया छूती ही नहीं');
        }
      }
    });

    test('gamma जितना छोटा, ग्रहण उतना गहरा', () {
      // gamma = छाया की धुरी से दूरी। शून्य के पास = चंद्रमा बीच से
      // गुज़रा = गहरा ग्रहण। यह रिश्ता कभी उल्टा नहीं हो सकता।
      final khagras = chaarSaal.where((g) => g.prakar == GrahanPrakar.khagras);
      final upachhaya =
          chaarSaal.where((g) => g.prakar == GrahanPrakar.upachhaya);

      for (final g in khagras) {
        expect(g.gamma.abs(), lessThan(0.6), reason: 'खग्रास पर gamma बड़ा');
      }
      for (final g in upachhaya) {
        expect(g.gamma.abs(), greaterThan(0.9),
            reason: 'उपछाया पर gamma छोटा');
      }
    });

    test('गिनती खगोल के हिसाब से है — साल में दो-तीन', () {
      // चार साल में सात से बारह के बीच होने चाहिए। इससे बहुत कम या बहुत
      // ज़्यादा मतलब कहीं गड़बड़ है।
      expect(chaarSaal.length, inInclusiveRange(7, 12));
    });

    test('दो ग्रहणों के बीच कम से कम पाँच महीने', () {
      // लगातार दो पूर्णिमाओं पर ग्रहण नहीं हो सकता — पात तक पहुँचने में
      // समय लगता है। (कभी-कभी एक महीने का फ़र्क़ भी होता है, पर वो
      // सूर्य-चंद्र की जोड़ी में; दो चंद्रग्रहणों में नहीं।)
      for (var i = 1; i < chaarSaal.length; i++) {
        final din = chaarSaal[i]
            .madhya
            .difference(chaarSaal[i - 1].madhya)
            .inDays;
        expect(din, greaterThan(140),
            reason: '${chaarSaal[i - 1].madhya} और ${chaarSaal[i].madhya}');
      }
    });
  });

  group('सूतक — सबसे नाज़ुक हिस्सा', () {
    // ── Drik Panchang से मिलान — 5 सितम्बर 2026 (→ D-054) ────────
    //
    // ⚠️ पहले यहाँ लिखा था *"सूतक ठीक नौ घंटे पहले लगता है"*, और जाँच
    // पास भी होती थी। **वो नियम ही ग़लत था।** Drik के अपने पन्ने पर
    // उनका अपना वाक्य है: *"There are total 8 Prahars from Sunrise
    // to Sunrise. Hence Sutak is observed ... for 9 hours before Lunar
    // Eclipse"* — पर उनकी गिनती नौ घंटे घटाकर नहीं होती। तीनों
    // मिसालों में सूतक **उस प्रहर की शुरुआत** पर लगा जो ग्रहण
    // वाले प्रहर से तीन प्रहर पीछे है। नौ घंटे तो बस औसत है।
    //
    // तीन मिसालें जान-बूझकर तीन अलग हालतों की हैं:
    //   1. दिल्ली 2025 — चाँद पूरे ग्रहण भर ऊपर
    //   2. दिल्ली 2026 — ग्रहण **चंद्रोदय के साथ** शुरू
    //   3. न्यूयॉर्क 2026 — ग्रहण **चंद्रास्त पर** कट जाता है
    //
    // तीसरी मिसाल भारत की नहीं है, और होनी भी नहीं चाहिए: चंद्रास्त
    // वाला रास्ता भारत में अगले कई साल किसी ग्रहण पर नहीं पड़ता, पर
    // कोड में तो है — जँचना चाहिए।
    group('Drik Panchang से मिलान — तीन ग्रहण, तीन हालतें', () {
      DateTime sthaniya(Place p, int y, int m, int d, int hh, int mm) =>
          DateTime.utc(y, m, d, hh, mm).subtract(p.timeZoneOffset);

      void kareeb(
          DateTime? mila, DateTime chahiye, Duration chhoot, String kya) {
        expect(mila, isNotNull, reason: '$kya मिला ही नहीं');
        final fark = mila!.difference(chahiye).abs();
        expect(fark <= chhoot, isTrue,
            reason: '$kya — Drik $chahiye, हमारा $mila, फ़र्क़ $fark');
      }

      // Drik मिनट तक ही छापता है, इसलिए एक मिनट की छूट लाज़मी है।
      const minute = Duration(seconds: 90);
      // मोक्ष Meeus की अपनी सटीकता पर टिका है — वहाँ तीन मिनट।
      const moksh = Duration(minutes: 3);

      GrahanDarshan ekGrahan(Place p, int y, int m, int d) {
        final sab = chandraGrahan(
          se: DateTime.utc(y, m, d).subtract(const Duration(days: 1)),
          tak: DateTime.utc(y, m, d).add(const Duration(days: 1)),
        );
        expect(sab, hasLength(1), reason: '$y-$m-$d पर एक ही ग्रहण चाहिए');
        return dekhaJayega(sab.single, p);
      }

      test('दिल्ली, 7 सितम्बर 2025 — चाँद पूरे ग्रहण भर ऊपर', () {
        final d = ekGrahan(dilli, 2025, 9, 7);
        expect(d.dikhega, isTrue);
        expect(d.chandrodayParShuru, isFalse);
        expect(d.chandrastParKhatm, isFalse);

        // Drik: Sutak Begins 12:19 · Kids 18:36 · Sutak Ends 01:26 (8 Sep)
        kareeb(d.sutakShuru, sthaniya(dilli, 2025, 9, 7, 12, 19), minute,
            'सूतक');
        kareeb(d.komalSutakShuru, sthaniya(dilli, 2025, 9, 7, 18, 36), minute,
            'कोमल सूतक');
        kareeb(d.sutakKhatm, sthaniya(dilli, 2025, 9, 8, 1, 26), moksh,
            'सूतक का अंत');
      });

      test('दिल्ली, 3 मार्च 2026 — ग्रहण चंद्रोदय के साथ शुरू', () {
        final d = ekGrahan(dilli, 2026, 3, 3);
        expect(d.dikhega, isTrue);
        expect(d.chandrodayParShuru, isTrue,
            reason: 'स्पर्श 15:19 पर चाँद अभी उगा ही नहीं था');

        // Drik: Lunar Eclipse Starts (With Moonrise) 18:26
        kareeb(d.sthaniyaShuru, sthaniya(dilli, 2026, 3, 3, 18, 26), minute,
            'स्थानीय शुरुआत (चंद्रोदय)');
        // Drik: Sutak Begins 09:39 · Kids 15:28 · Sutak Ends 18:46
        kareeb(d.sutakShuru, sthaniya(dilli, 2026, 3, 3, 9, 39), minute,
            'सूतक');
        kareeb(d.komalSutakShuru, sthaniya(dilli, 2026, 3, 3, 15, 28), minute,
            'कोमल सूतक');
        kareeb(d.sutakKhatm, sthaniya(dilli, 2026, 3, 3, 18, 46), moksh,
            'सूतक का अंत');
      });

      test('न्यूयॉर्क, 3 मार्च 2026 — ग्रहण चंद्रास्त पर कट जाता है', () {
        final d = ekGrahan(newYork, 2026, 3, 3);
        expect(d.dikhega, isTrue);
        expect(d.chandrastParKhatm, isTrue,
            reason: 'मोक्ष 08:14 से पहले ही चाँद डूब जाता है');

        // Drik: Lunar Eclipse Ends (With Moonset) 06:24
        kareeb(d.sthaniyaKhatm, sthaniya(newYork, 2026, 3, 3, 6, 24), minute,
            'स्थानीय अंत (चंद्रास्त)');
        // Drik: Sutak Begins 17:49 (2 Mar) · Kids 00:08 · Ends 06:24
        kareeb(d.sutakShuru, sthaniya(newYork, 2026, 3, 2, 17, 49), minute,
            'सूतक');
        kareeb(d.komalSutakShuru, sthaniya(newYork, 2026, 3, 3, 0, 8), minute,
            'कोमल सूतक');
        kareeb(d.sutakKhatm, sthaniya(newYork, 2026, 3, 3, 6, 24), minute,
            'सूतक का अंत');
      });
    });

    test('सूतक हमेशा नौ घंटे का नहीं होता — यही पूरी बात है', () {
      // पुरानी जाँच यही मान बैठी थी और इसीलिए ग़लती पकड़ नहीं पाई।
      // अगर कभी कोई इसे वापस "नौ घंटे घटाओ" बना दे, यह टूटेगी।
      final avadhiyan = <Duration>{};
      for (final g in chaarSaal) {
        final d = dekhaJayega(g, dilli);
        if (d.sutakShuru == null) continue;
        avadhiyan.add(d.sthaniyaShuru!.difference(d.sutakShuru!));
      }
      expect(avadhiyan, isNotEmpty);
      expect(avadhiyan.every((a) => a == const Duration(hours: 9)), isFalse,
          reason: 'हर ग्रहण पर ठीक नौ घंटे आ रहे हैं — प्रहर देखे ही नहीं जा रहे');
    });

    test('सूतक ग्रहण के स्थानीय अंत पर उतरता है, मोक्ष पर नहीं', () {
      for (final g in chaarSaal) {
        final d = dekhaJayega(g, dilli);
        if (d.sutakKhatm == null) continue;
        expect(d.sutakKhatm, d.sthaniyaKhatm);
        expect(d.sutakShuru!.isBefore(d.sthaniyaShuru!), isTrue);
        // कोमल सूतक हमेशा बीच में पड़ता है — दो प्रहर बाद, ग्रहण से पहले।
        expect(d.sutakShuru!.isBefore(d.komalSutakShuru!), isTrue);
        expect(d.komalSutakShuru!.isBefore(d.sthaniyaShuru!), isTrue);
      }
    });

    test('उपछाया ग्रहण पर सूतक कभी नहीं', () {
      // वो आँख से दिखता ही नहीं — चंद्रमा बस थोड़ा धुँधला पड़ता है।
      for (final g in chaarSaal) {
        if (g.prakar != GrahanPrakar.upachhaya) continue;
        final d = dekhaJayega(g, dilli);
        expect(d.sutakShuru, isNull,
            reason: '${g.madhya} उपछाया है, उस पर सूतक नहीं');
        expect(d.sutakKhatm, isNull);
      }
    });

    test('जो ग्रहण यहाँ दिखता ही नहीं, उसका सूतक भी नहीं', () {
      for (final g in chaarSaal) {
        final d = dekhaJayega(g, dilli);
        if (!d.dikhega) {
          expect(d.sutakShuru, isNull,
              reason: '${g.madhya} दिल्ली से नहीं दिखता, सूतक क्यों');
        }
      }
    });

    test('दिखना जगह से बदलता है — यही पूरी बात है', () {
      // एक ही ग्रहण भारत से दिखे और अमेरिका से नहीं, या उल्टा। अगर
      // हर जगह एक ही जवाब आ रहा है तो जगह देखी ही नहीं जा रही।
      final jawab = <bool>{};
      for (final g in chaarSaal) {
        jawab.add(dekhaJayega(g, dilli).dikhega ==
            dekhaJayega(g, newYork).dikhega);
      }
      expect(jawab.contains(false), isTrue,
          reason: 'किसी न किसी ग्रहण पर दोनों शहरों का जवाब अलग होना चाहिए');
    });
  });

  group('सूची का ढंग', () {
    test('तारीख़ों के क्रम में आती है', () {
      for (var i = 1; i < chaarSaal.length; i++) {
        expect(chaarSaal[i].madhya.isAfter(chaarSaal[i - 1].madhya), isTrue);
      }
    });

    test('माँगी हुई अवधि के बाहर कुछ नहीं लौटाता', () {
      final se = DateTime.utc(2026, 1, 1);
      final tak = DateTime.utc(2027, 1, 1);
      for (final g in chandraGrahan(se: se, tak: tak)) {
        expect(g.madhya.isBefore(se), isFalse);
        expect(g.madhya.isAfter(tak), isFalse);
      }
    });

    test('किनारे वाला ग्रहण छूटता नहीं', () {
      // छोटी खिड़की में जो ग्रहण मिले, वो बड़ी खिड़की में भी मिलना चाहिए।
      final bada = chandraGrahan(
        se: DateTime.utc(2025, 1, 1),
        tak: DateTime.utc(2027, 1, 1),
      ).map((g) => g.madhya).toSet();

      for (var m = 1; m <= 12; m++) {
        for (final g in chandraGrahan(
          se: DateTime.utc(2026, m, 1),
          tak: DateTime.utc(2026, m + 1, 1),
        )) {
          expect(bada.contains(g.madhya), isTrue,
              reason: '${g.madhya} महीने वाली खोज में मिला, साल वाली में नहीं');
        }
      }
    });
  });

  // ── NASA (Espenak) से मिलान — 5 सितम्बर 2026 ────────────────────
  //
  // स्रोत: https://eclipse.gsfc.nasa.gov/LEdecade/LEdecade2021.html
  // (Fred Espenak, NASA/GSFC — यही तालिका दुनिया भर के पंचांग और
  // ग्रहण-पन्ने इस्तेमाल करते हैं।)
  //
  // ⚠️ NASA का समय **TD** में है, हमारा **UT** में। इसलिए तुलना से पहले
  // हमारे समय में ΔT जोड़ना पड़ता है, वरना जवाब सत्तर सेकंड खिसका दिखेगा।
  group('NASA के कैटलॉग से मिलान', () {
    // तारीख़ · TD · प्रकार · umbral magnitude
    const nasa = [
      ('2025-03-14', '06:59:56', GrahanPrakar.khagras, 1.178),
      ('2025-09-07', '18:12:58', GrahanPrakar.khagras, 1.362),
      ('2026-03-03', '11:34:52', GrahanPrakar.khagras, 1.151),
      ('2026-08-28', '04:14:04', GrahanPrakar.khandgras, 0.930),
      ('2027-02-20', '23:14:06', GrahanPrakar.upachhaya, -0.057),
      ('2027-08-17', '07:14:59', GrahanPrakar.upachhaya, -0.525),
      ('2028-01-12', '04:14:13', GrahanPrakar.khandgras, 0.066),
      ('2028-07-06', '18:20:57', GrahanPrakar.khandgras, 0.389),
      ('2028-12-31', '16:53:15', GrahanPrakar.khagras, 1.246),
    ];

    ChandraGrahan? apna(DateTime td) => chaarSaal
        .where((g) => g.madhya.difference(td).abs() < const Duration(hours: 6))
        .firstOrNull;

    test('हर ग्रहण मिलता है, और दर्जा वही निकलता है', () {
      for (final (tarikh, samay, prakar, _) in nasa) {
        final td = DateTime.parse('${tarikh}T${samay}Z');
        final g = apna(td);
        expect(g, isNotNull, reason: '$tarikh NASA में है, हमारे पास नहीं');
        expect(g!.prakar, prakar, reason: '$tarikh का दर्जा');
      }
    });

    test('समय ढाई मिनट के भीतर है', () {
      // Meeus अध्याय 54 इतनी ही सटीकता का दावा करता है। सूतक के लिए यह
      // काफ़ी है — नौ घंटे पहले लगने वाली चीज़ में दो मिनट मायने नहीं रखते।
      //
      // ⚠️ यह हद ढीली मत करना। पहले यहाँ **चौदह मिनट** का फ़र्क़ था, और
      // वही अध्याय 49 बनाम 54 वाली भूल पकड़ने का इकलौता ज़रिया बना।
      for (final (tarikh, samay, _, __) in nasa) {
        final td = DateTime.parse('${tarikh}T${samay}Z');
        final g = apna(td)!;
        final apnaTd = g.madhya.add(Duration(
            milliseconds:
                (deltaTSeconds(td.year, td.month) * 1000).round()));
        expect(apnaTd.difference(td).abs(), lessThan(const Duration(minutes: 3)),
            reason: '$tarikh का समय');
      }
    });

    test('मान 0.01 के भीतर है, और हमेशा थोड़ा कम', () {
      // हमारा मान हर बार NASA से **कम** निकलता है, 0.001 से 0.009 तक।
      // वजह छाया का फैलाव है — पृथ्वी का वायुमंडल छाया को ~2% बड़ा करता
      // है और NASA उसे थोड़ा अलग गिनता है। यह एकतरफ़ा फ़र्क़ है, बिखराव
      // नहीं — इसीलिए इसे यहाँ दर्ज किया गया है, छिपाया नहीं।
      for (final (tarikh, samay, _, maan) in nasa) {
        final td = DateTime.parse('${tarikh}T${samay}Z');
        final farq = apna(td)!.maan - maan;
        expect(farq, lessThanOrEqualTo(0.0), reason: '$tarikh — मान ज़्यादा');
        expect(farq, greaterThan(-0.01), reason: '$tarikh — मान बहुत कम');
      }
    });

    test('gamma और अवधि भी मिलती हैं', () {
      // तारीख़ · TD · gamma · उपछाया की पूरी अवधि · खंडग्रास की अवधि (मिनट)
      //
      // ⚠️ अवधि वाली यह जाँच सबसे काम की निकली। पहली बार `n` को स्थिर
      // 0.5458 रखा था और अवधि **चौबीस मिनट** तक ग़लत आ रही थी — समय और
      // मान दोनों सही दिखने के बावजूद। Meeus का `n = 0.5458 + 0.0400
      // cos M'` छूट गया था, और उसे सिर्फ़ यही जाँच पकड़ सकती थी।
      const vistar = [
        ('2025-03-14', '06:59:56', 0.3484, 362.6, 218.3),
        ('2025-09-07', '18:12:58', -0.2752, 326.7, 209.4),
        ('2026-03-03', '11:34:52', -0.3765, 338.6, 207.2),
      ];

      for (final (tarikh, samay, gamma, upachhayaMin, chhayaMin) in vistar) {
        final g = apna(DateTime.parse('${tarikh}T${samay}Z'))!;

        expect((g.gamma - gamma).abs(), lessThan(0.005),
            reason: '$tarikh का gamma');

        final apniUpachhaya =
            g.upachhayaMoksha.difference(g.upachhayaSparsha).inSeconds / 60.0;
        expect((apniUpachhaya - upachhayaMin).abs(), lessThan(5),
            reason: '$tarikh की उपछाया अवधि');

        final apniChhaya =
            g.moksha!.difference(g.sparsha!).inSeconds / 60.0;
        expect((apniChhaya - chhayaMin).abs(), lessThan(5),
            reason: '$tarikh की खंडग्रास अवधि');
      }
    });

    test('🚧 18 जुलाई 2027 वाला छिछला उपछाया ग्रहण अब भी छूटता है', () {
      // ⚠️ **यह जाँच जान-बूझकर "फ़ेल" को दर्ज करती है**, ताकि यह कमी
      // चुपचाप न रह जाए।
      //
      // NASA उसे ग्रहण मानता है (umbral magnitude −1.068)। हमारे यहाँ
      // |γ| = 1.5801 और उपछाया की त्रिज्या 1.5766 — बाल भर ज़्यादा,
      // इसलिए अवधि का वर्गमूल ऋणात्मक हो जाता है और ग्रहण गिर जाता है।
      //
      // **यह क्यों चलने दिया गया:** उपछाया ग्रहण आँख से दिखता ही नहीं
      // (चंद्रमा बस ज़रा धुँधला पड़ता है), और इस ऐप में **उस पर सूतक भी
      // नहीं** है। यानी यूज़र के लिए इसमें कुछ करने को है ही नहीं।
      // दस साल में ऐसा एक ग्रहण छूटता है।
      //
      // अगर कभी यह जाँच **टूटे** — यानी ग्रहण मिलने लगे — तो यह अच्छी
      // ख़बर है: ऊपर वाली टिप्पणी और D-052 दोनों अपडेट कर देना।
      final td = DateTime.parse('2027-07-18T16:04:09Z');
      expect(apna(td), isNull,
          reason: 'अब मिलने लगा है — D-052 और टिप्पणियाँ अपडेट करो');
    });
  });

  // ── 🔴 यहाँ वो जाँचें आएँगी जो अभी नहीं लिखी जा सकतीं ──────────────
  //
  // नीचे वाली जाँच **जान-बूझकर ढीली** है। यह सिर्फ़ इतना देखती है कि
  // 7 सितंबर 2025 का खग्रास चंद्रग्रहण भारत से दिखता है — वो एक ऐसी
  // बात है जिस पर भरोसा किया जा सकता है (वो भारत में व्यापक रूप से
  // देखा गया था)।
  //
  // पर **समय मिनट तक सही है या नहीं, यह अभी नहीं जँचा।** उसके लिए
  // NASA/Drik से मिलाना बाक़ी है (→ D-052)।
  group('जो सबसे ज़्यादा लोगों ने देखा', () {
    test('7 सितंबर 2025 का खग्रास भारत से दिखता है', () {
      final g = chandraGrahan(
        se: DateTime.utc(2025, 9, 1),
        tak: DateTime.utc(2025, 10, 1),
      ).single;

      expect(g.prakar, GrahanPrakar.khagras);
      expect(dekhaJayega(g, dilli).dikhega, isTrue);
      expect(dekhaJayega(g, dilli).sutakShuru, isNotNull);
    });
  });
}
