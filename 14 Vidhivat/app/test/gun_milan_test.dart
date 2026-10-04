import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/gun_milan_screen.dart';
import 'package:vidhivat/screens/kundali_profiles_screen.dart';
import 'package:vidhivat/screens/kundali_screen.dart';
import 'package:vidhivat/state/kundali_profiles.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

/// अवकहड़ा और गुण मिलान की स्क्रीनें (→ D-110, docs/29 चरण K4)।
///
/// तालिकाओं की जाँच इंजन में है (`avakahada_test`)। यहाँ यह देखा जाता है कि
/// वे स्क्रीन तक ठीक पहुँचती हैं, खुले सच खुले हैं, छोटे फ़ोन पर कुछ बाहर
/// नहीं निकलता — और **जो नहीं होना चाहिए वह नहीं है**: फ़ैसला, दोष, फल।
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    await kundaliProfiles.load();
  });

  Widget app(Widget home) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) =>
            MaterialApp(theme: VidhivatTheme.dark(), home: home),
      );

  void phone(WidgetTester tester,
      {double width = 360, double height = 800, double scale = 1}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  KundaliProfile janm(String id, String naam, DateTime kab) => KundaliProfile(
        id: id,
        naam: naam,
        janm: kab,
        sthanNaam: 'पटना',
        latitude: 25.5941,
        longitude: 85.1376,
      );

  final ramesh = janm('a', 'रमेश', DateTime(1990, 5, 15, 14, 30));
  final sunita = janm('b', 'सुनीता', DateTime(1993, 11, 2, 6, 10));

  RashiSthiti chandra(KundaliProfile p) =>
      computeKundali(p.janmUtc, p.place)[KundaliGraha.chandra];

  String sabText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .join('\n');

  /// जो शब्द इन पन्नों पर कहीं नहीं आने चाहिए।
  const varjit = [
    'दोष', 'मांगलिक', 'अशुभ', 'शुभ फल', 'भविष्य', 'उपाय', 'मृत्यु', 'परिहार',
    'कलह', 'उत्तम मिलान', 'विवाह न करें', 'शादी न करें', 'साढ़ेसाती',
  ];

  test('गुण का अंक — आधे के साथ', () {
    expect(gunAnk(0), '0');
    expect(gunAnk(0.5), '½');
    expect(gunAnk(1.5), '1½');
    expect(gunAnk(8), '8');
    expect(gunAnk(26.5), '26½');
    expect(gunAnk(36), '36');
  });

  group('अवकहड़ा — कुंडली के "पंचांग" वाले पन्ने पर', () {
    testWidgets('नाम का अक्षर और पाँचों चीज़ें दिखती हैं, इंजन वाली ही',
        (tester) async {
      phone(tester, height: 3000);
      final av = avakahada(chandra(ramesh).nirayan);
      await tester.pumpWidget(app(KundaliScreen(profile: ramesh)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();

      expect(find.text('अवकहड़ा'), findsOneWidget);
      for (final label in [
        'नाम का अक्षर', 'राशि स्वामी', 'वर्ण', 'वश्य', 'योनि', 'गण', 'नाड़ी',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text(av.naamAkshar), findsOneWidget);
      expect(find.text(av.yoni.naam), findsWidgets);
      expect(find.text(av.gana.naam), findsWidgets);
      expect(find.text(av.nadi.naam), findsWidgets);
      expect(
          find.textContaining(
              '${av.chandra.nakshatraNaam}, चरण ${av.charan}'),
          findsWidgets);
      // दो खुली बातें — ⓘ के पीछे नहीं
      expect(find.textContaining('जाति से इसका कोई संबंध नहीं'), findsOneWidget);
      expect(find.textContaining('ऐप इनका कोई फल नहीं बताता'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"ये तालिकाएँ कहाँ से" — तीनों बातें, और वश्य पर पुस्तकों का मतभेद',
        (tester) async {
      phone(tester, height: 3000);
      await tester.pumpWidget(app(KundaliScreen(profile: ramesh)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ये तालिकाएँ कहाँ से'));
      await tester.pumpAndSettle();
      for (final baat in [
        'शतपद चक्र',
        'छोटी-बड़ी मात्रा एक ही गिनी जाती है',
        'मुहूर्तचिंतामणि',
        'यहाँ पुस्तकें बँटी हैं',
        'घर के पंचांग में कुछ अलग छपा हो तो वही मानिए',
      ]) {
        await tester.scrollUntilVisible(find.textContaining(baat), 150,
            scrollable: find.byType(Scrollable).last);
        expect(find.textContaining(baat), findsWidgets, reason: baat);
      }
    });

    testWidgets('चंद्रमा चरण की सीमा पर हो तो चेतावनी खुली दिखती है',
        (tester) async {
      KundaliProfile? seema;
      KundaliProfile? door;
      for (var m = 0; m < 3 * 24 * 60 && (seema == null || door == null); m += 5) {
        final p = janm('s', 'सीमा',
            DateTime(1990, 5, 15).add(Duration(minutes: m)));
        final d = chandra(p).charanSeemaSeDoori;
        if (d < 0.3) seema ??= p;
        if (d > 1.0) door ??= p;
      }
      expect(seema, isNotNull);
      expect(door, isNotNull);
      phone(tester, height: 3000);
      await tester.pumpWidget(app(KundaliScreen(profile: seema!)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();
      expect(find.textContaining('चरण की सीमा के बिल्कुल पास'), findsOneWidget);

      await tester.pumpWidget(
          app(KundaliScreen(key: const ValueKey('door'), profile: door!)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();
      expect(find.textContaining('चरण की सीमा के बिल्कुल पास'), findsNothing);
    });
  });

  group('गुण मिलान', () {
    testWidgets('दो कुंडलियाँ हों तभी दरवाज़ा दिखता है, और वहाँ से पन्ना खुलता है',
        (tester) async {
      phone(tester, height: 1600);
      await kundaliProfiles.save(ramesh);
      await tester.pumpWidget(app(const KundaliProfilesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('गुण मिलान'), findsNothing);

      await kundaliProfiles.save(sunita);
      await tester.pumpWidget(
          app(const KundaliProfilesScreen(key: ValueKey('do'))));
      await tester.pumpAndSettle();
      expect(find.text('गुण मिलान'), findsOneWidget);
      expect(find.textContaining('सिर्फ़ जोड़, फ़ैसला नहीं'), findsOneWidget);

      await tester.tap(find.text('गुण मिलान'));
      await tester.pumpAndSettle();
      expect(find.byType(GunMilanScreen), findsOneWidget);
      expect(find.textContaining('दोनों की कुंडली चुनिए'), findsOneWidget);
    });

    testWidgets('कुल और आठों कूट — इंजन वाले ही अंक; खुले सच खुले',
        (tester) async {
      phone(tester, height: 3000);
      final m = gunMilan(
        varChandra: chandra(ramesh).nirayan,
        kanyaChandra: chandra(sunita).nirayan,
      );
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, sunita],
        vara: ramesh,
        kanya: sunita,
      )));
      await tester.pumpAndSettle();

      final kul = tester.widget<Text>(find.byKey(const ValueKey('kul-gun')));
      expect(kul.textSpan!.toPlainText(), '${gunAnk(m.kul)}  36 में से');
      for (final a in m.koot) {
        expect(find.text(a.koot.naam), findsOneWidget, reason: a.koot.naam);
        expect(find.text('${gunAnk(a.ank)} / ${a.koot.adhiktam}'), findsWidgets,
            reason: a.koot.naam);
        expect(find.textContaining('वर ${a.varKa} · कन्या ${a.kanyaKa}'),
            findsWidgets,
            reason: a.koot.naam);
      }
      final purani = m.puraniTalikaSeKul;
      expect(find.textContaining('पुरानी छपी तालिका से जोड़ें तो'),
          purani == null ? findsNothing : findsOneWidget);

      // तीन खुली बातें
      expect(find.textContaining('यह ऐप नहीं बताता'), findsOneWidget);
      expect(find.textContaining('यह तालिका हर पुस्तक में अलग छपी है'),
          findsOneWidget);
      expect(find.textContaining('वह ग़लती नहीं, दूसरी तालिका है'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('जहाँ पुरानी तालिका का अंक अलग है, वहाँ वह साथ में दिखता है',
        (tester) async {
      // ऐसा जोड़ा ढूँढो जिसमें योनि या गण का अंक दोनों तालिकाओं में अलग हो
      KundaliProfile? kanya;
      GunMilan? mila;
      for (var d = 0; d < 60 && kanya == null; d++) {
        final p = janm('k', 'गीता',
            DateTime(1992, 1, 1, 9, 0).add(Duration(days: d)));
        final m = gunMilan(
          varChandra: chandra(ramesh).nirayan,
          kanyaChandra: chandra(p).nirayan,
        );
        if (m.puraniTalikaSeKul != null) {
          kanya = p;
          mila = m;
        }
      }
      expect(kanya, isNotNull);
      phone(tester, height: 3000);
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, kanya!],
        vara: ramesh,
        kanya: kanya,
      )));
      await tester.pumpAndSettle();
      expect(
          find.text(
              'पुरानी छपी तालिका से जोड़ें तो ${gunAnk(mila!.puraniTalikaSeKul!)}'),
          findsOneWidget);
      expect(find.textContaining('पुरानी छपी तालिका में '), findsWidgets);
    });

    testWidgets('वर और कन्या बदलने पर जोड़ दोबारा बनता है', (tester) async {
      phone(tester, height: 3000);
      final ulta = gunMilan(
        varChandra: chandra(sunita).nirayan,
        kanyaChandra: chandra(ramesh).nirayan,
      );
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, sunita],
        vara: ramesh,
        kanya: sunita,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('वर और कन्या आपस में बदलें'));
      await tester.pumpAndSettle();
      final kul = tester.widget<Text>(find.byKey(const ValueKey('kul-gun')));
      expect(kul.textSpan!.toPlainText(), '${gunAnk(ulta.kul)}  36 में से');
      expect(
          find.textContaining(
              'वर ${ulta[Koot.varna].varKa} · कन्या ${ulta[Koot.varna].kanyaKa}'),
          findsWidgets);
    });

    testWidgets('दोनों जगह एक ही कुंडली — अंक नहीं, बात', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, sunita],
        vara: ramesh,
        kanya: ramesh,
      )));
      await tester.pumpAndSettle();
      expect(find.text('दोनों जगह एक ही कुंडली चुनी है।'), findsOneWidget);
      expect(find.byKey(const ValueKey('kul-gun')), findsNothing);
    });

    testWidgets('चंद्रमा नक्षत्र की सीमा पर हो तो चेतावनी खुली दिखती है',
        (tester) async {
      KundaliProfile? seema;
      for (var m = 0; m < 3 * 24 * 60 && seema == null; m += 5) {
        final p = janm('s', 'सीमा',
            DateTime(1990, 5, 15).add(Duration(minutes: m)));
        if (chandra(p).nakshatraSeemaSeDoori < chandraSeemaKiHad) seema = p;
      }
      expect(seema, isNotNull);
      phone(tester, height: 3000);
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [seema!, sunita],
        vara: seema,
        kanya: sunita,
      )));
      await tester.pumpAndSettle();
      expect(find.textContaining('नक्षत्र की सीमा के बिल्कुल पास'),
          findsOneWidget);
      expect(find.textContaining('सीमा का चंद्रमा'), findsOneWidget);
    });

    testWidgets('"ये अंक कैसे निकले" — आठों कूट का नियम, और जो नहीं जोड़ा गया',
        (tester) async {
      phone(tester, height: 3000);
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, sunita],
        vara: ramesh,
        kanya: sunita,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ये अंक कैसे निकले'));
      await tester.pumpAndSettle();
      for (final baat in [
        'कुल 36',
        'राशि का पुराना वर्ग (जाति नहीं)',
        'नौ से भाग',
        'तालिका दो तरह की छपी मिलती है',
        'दोनों सम 3',
        'छठी-आठवीं',
        'एक हो तो 0',
        'ऐप सिर्फ़ मूल तालिका का अंक दिखाता है',
        'अंकों का मतलब निकालना इस ऐप का काम नहीं',
      ]) {
        await tester.scrollUntilVisible(find.textContaining(baat), 150,
            scrollable: find.byType(Scrollable).last);
        expect(find.textContaining(baat), findsWidgets, reason: baat);
      }
    });

    for (final (chaudai, akshar) in [(320.0, 1.5), (360.0, 2.0)]) {
      testWidgets(
          'छोटे फ़ोन पर भी कुछ बाहर नहीं निकलता — $chaudai चौड़ाई, $akshar गुना अक्षर',
          (tester) async {
        phone(tester, width: chaudai, scale: akshar);
        await tester.pumpWidget(app(GunMilanScreen(
          profiles: [ramesh, sunita],
          vara: ramesh,
          kanya: sunita,
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'नतीजा');
        await tester.pumpWidget(app(GunMilanScreen(
          key: const ValueKey('khali'),
          profiles: [ramesh, sunita],
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'ख़ाली');

        await kundaliProfiles.save(ramesh);
        await kundaliProfiles.save(sunita);
        await tester.pumpWidget(app(const KundaliProfilesScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'सूची');
      });
    }

    testWidgets('कहीं फ़ैसला, दोष या फल का कोई शब्द नहीं — पन्ने पर भी, शीट में भी',
        (tester) async {
      phone(tester, height: 9000);
      await tester.pumpWidget(app(GunMilanScreen(
        profiles: [ramesh, sunita],
        vara: ramesh,
        kanya: sunita,
      )));
      await tester.pumpAndSettle();
      var sab = sabText(tester);
      for (final shabd in varjit) {
        expect(sab, isNot(contains(shabd)), reason: 'पन्ने पर "$shabd"');
      }
      await tester.tap(find.text('ये अंक कैसे निकले'));
      await tester.pumpAndSettle();
      sab = sabText(tester);
      for (final shabd in varjit) {
        expect(sab, isNot(contains(shabd)), reason: 'शीट में "$shabd"');
      }
    });

    testWidgets('अवकहड़ा वाले हिस्से में भी वही शब्द नहीं — पन्ने पर भी, शीट में भी',
        (tester) async {
      phone(tester, height: 9000);
      await tester.pumpWidget(app(KundaliScreen(profile: ramesh)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();
      var sab = sabText(tester);
      for (final shabd in varjit) {
        expect(sab, isNot(contains(shabd)), reason: 'पंचांग वाले पन्ने पर "$shabd"');
      }
      await tester.tap(find.text('ये तालिकाएँ कहाँ से'));
      await tester.pumpAndSettle();
      sab = sabText(tester);
      for (final shabd in varjit) {
        expect(sab, isNot(contains(shabd)), reason: 'अवकहड़ा में "$shabd"');
      }
    });
  });
}
