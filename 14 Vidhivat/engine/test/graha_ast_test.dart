import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// गुरु और शुक्र के अस्त की जाँच (→ D-119, `docs/08_VERIFICATION.md` §21)।
///
/// यहाँ तीन अलग चीज़ें जाँची जाती हैं — और तीनों का दर्जा अलग है:
///
/// 1. **गणित** (ग्रह कब उगता-डूबता है) — संदर्भ-पंचांग के छपे पलों से
///    एक-दो मिनट के भीतर। यह पक्का है।
/// 2. **"अंश" वाला तरीक़ा** — एक प्रकाशित सूची के पलों से आधे घंटे के भीतर,
///    तारीख़ें हूबहू। यह भी पक्का है: उस सूची का नियम यही है।
/// 3. **संदर्भ-पंचांग की अस्त-तारीख़ें** — वे आधुनिक "आँख से दिखने" वाले
///    हिसाब से हैं, जो छपे नियम से नहीं निकलता। हमारे दोनों तरीक़े उनसे कुछ
///    दिन हटते हैं। यहाँ वह **फ़र्क़ दर्ज है, मिटाया नहीं गया।**
void main() {
  const dilli = Place.delhi;
  final se = DateTime.utc(2024, 1, 1);
  final tak = DateTime.utc(2027, 12, 31);

  DateTime din(int y, int m, int d) => DateTime.utc(y, m, d);

  group('कालांश — छपी संख्याएँ', () {
    test('गुरु 11, शुक्र 10, वक्री शुक्र 8 (सूर्यसिद्धांत ९.६–७)', () {
      expect(astKalansh(Graha.guru, vakri: false), 11);
      expect(astKalansh(Graha.guru, vakri: true), 11);
      expect(astKalansh(Graha.shukra, vakri: false), 10);
      expect(astKalansh(Graha.shukra, vakri: true), 8);
    });

    test('बाक़ी ग्रहों का अस्त यहाँ नहीं निकलता', () {
      for (final g in [Graha.mangal, Graha.budh, Graha.shani]) {
        expect(() => astKalansh(g, vakri: false), throwsArgumentError);
      }
    });
  });

  group('गणित — ग्रह का उदय-अस्त, संदर्भ-पंचांग के छपे पल से', () {
    // संदर्भ-पंचांग अस्त का पल उस शाम ग्रह के डूबने का, और उदय का पल उस भोर
    // ग्रह के उगने का लिखता है (दिल्ली; पन्ने 8 अक्टूबर 2026 को देखे)। अस्त
    // की *तारीख़* चुनने का उसका नियम हमारा नहीं है — पर उस तारीख़ पर ग्रह
    // कब डूबा/उगा, यह शुद्ध गणित है और मिलना चाहिए।
    const pal = [
      (Graha.guru, 2024, 5, 7, false, 19, 36),
      (Graha.guru, 2024, 6, 6, true, 4, 36),
      (Graha.guru, 2025, 6, 12, false, 19, 56),
      (Graha.guru, 2025, 7, 9, true, 4, 44),
      (Graha.guru, 2026, 7, 15, false, 19, 59),
      (Graha.guru, 2026, 8, 12, true, 5, 3),
      (Graha.guru, 2027, 8, 17, false, 19, 32),
      (Graha.guru, 2027, 9, 13, true, 5, 22),
      (Graha.shukra, 2024, 4, 25, true, 5, 19),
      (Graha.shukra, 2024, 6, 29, false, 19, 52),
      (Graha.shukra, 2025, 3, 19, false, 19, 0),
      (Graha.shukra, 2025, 3, 23, true, 5, 52),
      (Graha.shukra, 2025, 12, 11, true, 6, 35),
      (Graha.shukra, 2026, 2, 1, false, 18, 27),
      (Graha.shukra, 2026, 10, 12, false, 18, 19),
      (Graha.shukra, 2026, 10, 29, true, 6, 0),
      (Graha.shukra, 2027, 7, 21, true, 5, 8),
      (Graha.shukra, 2027, 9, 9, false, 19, 0),
    ];

    for (final (g, y, m, d, uday, ghanta, minute) in pal) {
      test(
          '${g.naam} $d/$m/$y — ${uday ? "उगा" : "डूबा"} '
          '$ghanta:${minute.toString().padLeft(2, '0')}', () {
        final r = grahaUdayAst(g, y, m, d, dilli)!;
        final hamara = uday ? r.uday! : r.ast!;
        final chhapa = DateTime.utc(y, m, d, ghanta, minute);
        expect(
            hamara.difference(chhapa).inSeconds.abs(), lessThanOrEqualTo(120),
            reason: 'हमारा $hamara');
      });
    }
  });

  group('अंश से — देशांतर का अंतर कालांश से कम', () {
    final guru = grahaAstKaal(Graha.guru, se, tak, dilli);
    final shukra = grahaAstKaal(Graha.shukra, se, tak, dilli);

    test('गुरु 2024–2027: चार अस्त, हर साल एक', () {
      expect([
        for (final a in guru) (a.astDin, a.udayDin)
      ], [
        (din(2024, 5, 3), din(2024, 6, 3)),
        (din(2025, 6, 9), din(2025, 7, 10)),
        (din(2026, 7, 14), din(2026, 8, 13)),
        (din(2027, 8, 16), din(2027, 9, 15)),
      ]);
      for (final a in guru) {
        expect(a.kalansh, 11);
        expect(a.ganana, AstGanana.ansh);
      }
    });

    test('शुक्र 2024–2027: तीन लंबी (ऊपरी युति) और दो छोटी (वक्री) अस्त', () {
      expect([
        for (final a in shukra) (a.astDin, a.udayDin, a.kalansh)
      ], [
        (din(2024, 4, 28), din(2024, 7, 11), 10),
        (din(2025, 3, 18), din(2025, 3, 28), 8),
        (din(2025, 11, 26), din(2026, 2, 17), 10),
        (din(2026, 10, 19), din(2026, 10, 29), 8),
        (din(2027, 7, 6), din(2027, 9, 17), 10),
      ]);
    });

    test('एक प्रकाशित सूची के छह पल — तारीख़ वही, पल आधे घंटे के भीतर', () {
      // एक ज्योतिष-साइट, जो ठीक यही नियम लिखती है ("सूर्य से 11 / 10 / वक्री 8
      // अंश के भीतर") — कड़ी `docs/18` §३२ में। सबसे बड़ा फ़र्क़ 34 मिनट, यानी
      // कोण में 0.006° — दो गणनाओं के बीच इतना रहता ही है।
      final chhape = [
        (guru[0].ast, DateTime.utc(2024, 5, 3, 23, 5)),
        (guru[0].uday, DateTime.utc(2024, 6, 3, 4, 23)),
        (shukra[0].ast, DateTime.utc(2024, 4, 28, 7, 2)),
        (shukra[0].uday, DateTime.utc(2024, 7, 11, 7, 57)),
        (shukra[3].ast, DateTime.utc(2026, 10, 19, 8, 10)),
        (shukra[3].uday, DateTime.utc(2026, 10, 29, 9, 33)),
      ];
      for (final (hamara, chhapa) in chhape) {
        expect(hamara.difference(chhapa).inMinutes.abs(), lessThanOrEqualTo(40),
            reason: 'हमारा $hamara · छपा $chhapa');
      }
    });

    test('दिशा: गुरु पश्चिम में डूबता, पूर्व में उगता है — हमेशा', () {
      final lambe = grahaAstKaal(Graha.guru, DateTime.utc(2020, 1, 1),
          DateTime.utc(2035, 12, 31), dilli);
      expect(lambe.length, inInclusiveRange(14, 16));
      for (final a in lambe) {
        expect(a.astPurvMein, isFalse, reason: '${a.astDin}');
        expect(a.udayPurvMein, isTrue, reason: '${a.astDin}');
        expect(a.udayDin.difference(a.astDin).inDays, inInclusiveRange(27, 33));
      }
    });

    test(
        'दिशा: शुक्र की लंबी अस्त पूर्व में डूबकर पश्चिम में उगती है; वक्री उलटी',
        () {
      for (final a in shukra) {
        if (a.kalansh == 10) {
          expect(a.astPurvMein, isTrue, reason: '${a.astDin}');
          expect(a.udayPurvMein, isFalse, reason: '${a.astDin}');
        } else {
          expect(a.astPurvMein, isFalse, reason: '${a.astDin}');
          expect(a.udayPurvMein, isTrue, reason: '${a.astDin}');
        }
      }
    });

    test('छोटी खिड़की भी चलते हुए अस्त को पकड़ती है', () {
      final beech = grahaAstKaal(Graha.guru, DateTime.utc(2026, 7, 20),
          DateTime.utc(2026, 7, 25), dilli);
      expect(beech, hasLength(1));
      expect(beech.single.astDin, din(2026, 7, 14));

      final baahar = grahaAstKaal(Graha.guru, DateTime.utc(2026, 9, 1),
          DateTime.utc(2026, 10, 30), dilli);
      expect(baahar, isEmpty);
    });
  });

  group('कालांश से — उदय/अस्त के समय का अंतर (सूर्यसिद्धांत ९.५)', () {
    final guru =
        grahaAstKaal(Graha.guru, se, tak, dilli, ganana: AstGanana.kalansh);
    final shukra =
        grahaAstKaal(Graha.shukra, se, tak, dilli, ganana: AstGanana.kalansh);

    test('गुरु 2024–2027 (दिल्ली)', () {
      expect([
        for (final a in guru) (a.astDin, a.udayDin)
      ], [
        (din(2024, 5, 5), din(2024, 6, 5)),
        (din(2025, 6, 10), din(2025, 7, 9)),
        (din(2026, 7, 13), din(2026, 8, 12)),
        (din(2027, 8, 13), din(2027, 9, 14)),
      ]);
    });

    test('शुक्र 2024–2027 (दिल्ली)', () {
      expect([
        for (final a in shukra) (a.astDin, a.udayDin, a.kalansh)
      ], [
        (din(2024, 4, 3), din(2024, 7, 10), 10),
        (din(2025, 3, 19), din(2025, 3, 24), 8),
        (din(2025, 12, 2), din(2026, 2, 14), 10),
        (din(2026, 10, 10), din(2026, 10, 30), 8),
        (din(2027, 7, 11), din(2027, 9, 30), 10),
      ]);
    });

    test('अस्त का पल सूर्यास्त के बाद, उदय का पल सूर्योदय से पहले (गुरु)', () {
      for (final a in guru) {
        expect(a.ast.hour, inInclusiveRange(18, 21), reason: '${a.ast}');
        expect(a.uday.hour, inInclusiveRange(4, 6), reason: '${a.uday}');
      }
    });
  });

  group('⚠ संदर्भ-पंचांग से फ़र्क़ — दर्ज है, मिटाया नहीं गया', () {
    // संदर्भ-पंचांग (दिल्ली) की अस्त → उदय तारीख़ें। उसका अपना पन्ना कहता है
    // कि वह सूर्यसिद्धांत के अंशों से नहीं, "आधुनिक" हिसाब से गिनता है।
    final sandarbhGuru = [
      (din(2024, 5, 7), din(2024, 6, 6)),
      (din(2025, 6, 12), din(2025, 7, 9)),
      (din(2026, 7, 15), din(2026, 8, 12)),
      (din(2027, 8, 17), din(2027, 9, 13)),
    ];
    final sandarbhShukra = [
      (din(2024, 4, 25), din(2024, 6, 29)),
      (din(2025, 3, 19), din(2025, 3, 23)),
      (din(2025, 12, 11), din(2026, 2, 1)),
      (din(2026, 10, 12), din(2026, 10, 29)),
      (din(2027, 7, 21), din(2027, 9, 9)),
    ];

    int sabseBada(List<GrahaAst> hamare, List<(DateTime, DateTime)> unke) {
      expect(hamare, hasLength(unke.length));
      var bada = 0;
      for (var i = 0; i < unke.length; i++) {
        final a = hamare[i].astDin.difference(unke[i].$1).inDays.abs();
        final u = hamare[i].udayDin.difference(unke[i].$2).inDays.abs();
        if (a > bada) bada = a;
        if (u > bada) bada = u;
      }
      return bada;
    }

    test('गुरु: दोनों तरीक़े संदर्भ से चार दिन के भीतर', () {
      for (final ganana in AstGanana.values) {
        final h = grahaAstKaal(Graha.guru, se, tak, dilli, ganana: ganana);
        expect(sabseBada(h, sandarbhGuru), 4, reason: ganana.name);
      }
    });

    test('शुक्र: अंश से 16 दिन तक, कालांश से 22 दिन तक — लंबी अस्त में', () {
      final ansh = grahaAstKaal(Graha.shukra, se, tak, dilli);
      final kal =
          grahaAstKaal(Graha.shukra, se, tak, dilli, ganana: AstGanana.kalansh);
      expect(sabseBada(ansh, sandarbhShukra), 16);
      expect(sabseBada(kal, sandarbhShukra), 22);
    });

    test('शुक्र की वक्री (छोटी) अस्त में कालांश संदर्भ से दो दिन के भीतर', () {
      final kal =
          grahaAstKaal(Graha.shukra, se, tak, dilli, ganana: AstGanana.kalansh);
      for (final i in [1, 3]) {
        expect(kal[i].kalansh, 8);
        expect(kal[i].astDin.difference(sandarbhShukra[i].$1).inDays.abs(),
            lessThanOrEqualTo(2));
        expect(kal[i].udayDin.difference(sandarbhShukra[i].$2).inDays.abs(),
            lessThanOrEqualTo(2));
      }
    });
  });

  group('बाल्य और वार्धक के दिन — मुहूर्त चिंतामणि, संस्कार प्रकरण २७–२८', () {
    GrahaAst banao(Graha g, {required bool astPurv, required bool udayPurv}) =>
        GrahaAst(
          graha: g,
          ast: DateTime.utc(2026, 7, 14, 18),
          uday: DateTime.utc(2026, 8, 13, 5),
          astPurvMein: astPurv,
          udayPurvMein: udayPurv,
          kalansh: 11,
          ganana: AstGanana.ansh,
        );

    test('गुरु: अस्त से पहले 15 दिन वृद्ध, उदय के बाद 15 दिन बाल', () {
      final a = banao(Graha.guru, astPurv: false, udayPurv: true);
      expect(a.vardhakDin, 15);
      expect(a.balyaDin, 15);
      expect(a.vardhakShuru, din(2026, 6, 29));
      expect(a.balyaAnt, din(2026, 8, 28));
    });

    test('शुक्र: पूर्व में उगे तो 3 दिन बाल, पश्चिम में 10', () {
      expect(banao(Graha.shukra, astPurv: false, udayPurv: true).balyaDin, 3);
      expect(banao(Graha.shukra, astPurv: true, udayPurv: false).balyaDin, 10);
    });

    test('शुक्र: पूर्व में डूबने से पहले 15 दिन वृद्ध, पश्चिम में 5', () {
      expect(
          banao(Graha.shukra, astPurv: true, udayPurv: false).vardhakDin, 15);
      expect(banao(Graha.shukra, astPurv: false, udayPurv: true).vardhakDin, 5);
    });

    test('दूसरे मत: दस, सात, और बहुत ज़रूरी काम में तीन दिन', () {
      expect(astKeMatantarDin, [10, 7, 3]);
    });
  });
}
