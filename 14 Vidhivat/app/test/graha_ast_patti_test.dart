// गुरु/शुक्र अस्त की पट्टी (→ D-119)।
//
// ⚠️ यह पट्टी अभी **बंद** है। यहाँ की पहली जाँच उसी ताले की है: उसे खोलने
// वाला पहले `docs/08_VERIFICATION.md` §21 की शर्त पूरी करे, फिर यह जाँच बदले।
// बाक़ी जाँचें widget को सीधे चलाती हैं, ताकि बंद रहते हुए भी वह टूटे नहीं।
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/graha_ast_patti.dart';
import 'package:vidhivat/widgets/taalne_wale_din_card.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget child) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  void phone(WidgetTester tester, {double width = 400, double height = 2400}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('🔒 ताला', () {
    test('पट्टी अभी बंद है', () {
      expect(grahaAstPattiKhuli, isFalse,
          reason: 'खोलने से पहले: डेवलपर के पंचांग की अस्त-सूची से मिलान, '
              'और फ़ोन पर देखना (docs/08 §21)। फिर यह जाँच बदलो।');
    });

    testWidgets('बंद रहते "कौन से दिन टालने हैं" में पट्टी नहीं आती',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const TaalneWaleDinCard()));
      await tester.pumpAndSettle();
      expect(find.byType(TaalneWaleDinCard), findsOneWidget);
      expect(find.byType(GrahaAstPatti), findsNothing);
    });
  });

  group('कौन से अस्त-काल दिखेंगे', () {
    test('आगे के साठ दिन में पड़ने वाला गुरु अस्त', () {
      final mile = aaneWaleGrahaAst(DateTime(2026, 6, 20), 60, Place.delhi);
      expect(mile, hasLength(1));
      expect(mile.single.graha, Graha.guru);
      expect(mile.single.astDin, DateTime.utc(2026, 7, 14));
      expect(mile.single.udayDin, DateTime.utc(2026, 8, 13));
    });

    test('अस्त बीत गया हो पर "बाल" दिन चल रहे हों — तब भी दिखता है', () {
      // गुरु 13 अगस्त को उदित; 15 बाल दिन → 28 अगस्त तक
      final beech = aaneWaleGrahaAst(DateTime(2026, 8, 20), 10, Place.delhi);
      expect([for (final a in beech) a.graha], [Graha.guru]);

      final baad = aaneWaleGrahaAst(DateTime(2026, 8, 29), 10, Place.delhi);
      expect(baad, isEmpty);
    });

    test('अस्त अभी दूर हो पर "वृद्ध" दिन खिड़की में आ जाएँ — तब भी', () {
      // शुक्र (वक्री) 19 अक्टूबर को अस्त; 5 वृद्ध दिन → 14 अक्टूबर से
      final mile = aaneWaleGrahaAst(DateTime(2026, 10, 1), 14, Place.delhi);
      expect([for (final a in mile) a.graha], [Graha.shukra]);
      expect(mile.single.vardhakShuru, DateTime.utc(2026, 10, 14));
    });

    test('गुरु और शुक्र दोनों हों तो तारीख़ के क्रम में', () {
      final mile = aaneWaleGrahaAst(DateTime(2027, 6, 15), 90, Place.delhi);
      expect([for (final a in mile) a.graha], [Graha.shukra, Graha.guru]);
    });
  });

  group('पट्टी क्या लिखती है', () {
    final guru2026 = aaneWaleGrahaAst(DateTime(2026, 6, 20), 60, Place.delhi);

    testWidgets('तारीख़ें "लगभग" के साथ, और आगे-पीछे के दिन', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(GrahaAstPatti(kaal: guru2026)));
      await tester.pumpAndSettle();

      expect(find.text('गुरु अस्त — लगभग 14 जुल से 13 अग तक'), findsOneWidget);
      // 15 दिन पहले से (29 जून) 15 दिन बाद तक (28 अगस्त)
      expect(find.textContaining('29 जून से 28 अग तक'), findsOneWidget);
      expect(find.textContaining('अपने पंचांग से मिला लें'), findsOneWidget);
    });

    testWidgets('"यह कैसे निकला" में नियम, दोनों ग्रंथ और दूसरे मत',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(GrahaAstPatti(kaal: guru2026)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('यह कैसे निकला'));
      await tester.pumpAndSettle();

      expect(find.textContaining('बीच 11 अंश से कम अंतर'), findsOneWidget);
      expect(find.textContaining('सूर्यसिद्धांत'), findsOneWidget);
      expect(find.textContaining('मुहूर्त चिंतामणि'), findsOneWidget);
      expect(find.textContaining('10 दिन कहते हैं'), findsOneWidget);
      expect(find.textContaining('पश्चिम में डूबकर पूर्व में फिर दिखेंगे'),
          findsOneWidget);
      expect(
          find.textContaining('अंतिम निर्णय अपने पंडित जी से'), findsOneWidget);
    });

    testWidgets('कोई अस्त न हो तो कुछ नहीं दिखता', (tester) async {
      await tester.pumpWidget(app(const GrahaAstPatti(kaal: [])));
      await tester.pumpAndSettle();
      expect(find.textContaining('अस्त'), findsNothing);
    });

    testWidgets('शुक्र की वक्री अस्त: 8 अंश, 5 दिन पहले और 3 दिन बाद',
        (tester) async {
      phone(tester);
      final shukra = aaneWaleGrahaAst(DateTime(2026, 10, 1), 30, Place.delhi);
      await tester.pumpWidget(app(GrahaAstPatti(kaal: shukra)));
      await tester.pumpAndSettle();
      expect(find.text('शुक्र अस्त — लगभग 19 अक्तू से 29 अक्तू तक'),
          findsOneWidget);
      expect(find.textContaining('पहले के 5 और उदय के बाद के 3 दिन'),
          findsOneWidget);
      await tester.tap(find.text('यह कैसे निकला'));
      await tester.pumpAndSettle();
      expect(find.textContaining('बीच 8 अंश से कम अंतर'), findsOneWidget);
    });
  });

  group('⛔ यह मुहूर्त होने का दावा नहीं करती', () {
    // स्रोत पढ़कर — वही तरीक़ा जो "कौन से दिन टालने हैं" पर है। सिर्फ़ string
    // देखी जाती हैं, टिप्पणियाँ नहीं।
    final src = File('lib/widgets/graha_ast_patti.dart').readAsStringSync();
    final shabd =
        RegExp("'([^']*)'").allMatches(src).map((m) => m[1]!).join(' ');

    test('स्क्रीन पर कोई शुभ-दिन वाला वाक्य नहीं', () {
      for (final manahi in [
        'शुभ',
        'इस दिन करें',
        'सबसे अच्छा दिन',
        'मुहूर्त निकाला',
        'फल मिल',
      ]) {
        expect(shabd.contains(manahi), isFalse, reason: '"$manahi" मिला');
      }
    });

    test('"लगभग" और "अपने पंचांग से मिला लें" दोनों मौजूद हैं', () {
      expect(shabd, contains('लगभग'));
      expect(shabd, contains('अपने पंचांग से मिला लें'));
    });

    test('किसी वेबसाइट का नाम या रोमन शब्द स्क्रीन पर नहीं', () {
      final roman = RegExp(r'[A-Za-z]{3,}');
      final devanagari = RegExp(r'[ऀ-ॿ]');
      // सिर्फ़ वे string जिनमें हिंदी है (import के रास्ते नहीं), और उनमें से
      // `$naam`, `${a.kalansh}` जैसे टुकड़े हटाकर
      final dikhneWale = RegExp("'([^']*)'")
          .allMatches(src)
          .map((m) => m[1]!)
          .where(devanagari.hasMatch)
          .map((t) => t
              .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
              .replaceAll(RegExp(r'\$[A-Za-z_]+'), ''))
          .join(' ');
      expect(dikhneWale, isNotEmpty);
      expect(roman.allMatches(dikhneWale).map((m) => m[0]).toList(), isEmpty);
    });
  });
}
