import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/kundali_profiles_screen.dart';
import 'package:vidhivat/screens/kundali_screen.dart';
import 'package:vidhivat/screens/more_screen.dart';
import 'package:vidhivat/state/kundali_profiles.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/kundali_chitra.dart';

/// कुंडली की स्क्रीनें (→ D-105, docs/29 चरण K3)।
///
/// गणित की जाँच इंजन में है (`kundali_test`, `lagna_nasa_test`, `janm_test`)।
/// यहाँ यह देखा जाता है कि वह स्क्रीन तक पहुँचता है, छोटे फ़ोन और बड़े अक्षर
/// पर कुछ बाहर नहीं निकलता, और **जो नहीं होना चाहिए वह नहीं है** — फल,
/// राशिफल, दोष, उपाय।
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

  void phone(WidgetTester tester, {double width = 360, double scale = 1}) {
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  final patna1990 = KundaliProfile(
    id: 'a',
    naam: 'रमेश',
    janm: DateTime(1990, 5, 15, 14, 30),
    sthanNaam: 'पटना',
    latitude: 25.5941,
    longitude: 85.1376,
  );

  group('जन्म का ब्यौरा', () {
    test('JSON में जाकर वैसा ही लौटता है', () {
      final lauta = KundaliProfile.fromJson(
          Map<String, dynamic>.from(patna1990.toJson()));
      expect(lauta.naam, 'रमेश');
      expect(lauta.janm, DateTime(1990, 5, 15, 14, 30));
      expect(lauta.janmUtc, DateTime.utc(1990, 5, 15, 9, 0));
      expect(lauta.latitude, 25.5941);
      expect(lauta.yuddhKal, isFalse);
    });

    test('युद्ध-काल के जन्म में घड़ी +6:30 मानी जाती है', () {
      final p = KundaliProfile(
        id: 'b',
        naam: 'दादी',
        janm: DateTime(1943, 6, 1, 8, 0),
        sthanNaam: 'पटना',
        latitude: 25.5941,
        longitude: 85.1376,
      );
      expect(p.yuddhKal, isTrue);
      expect(p.place.timeZoneOffset, const Duration(hours: 6, minutes: 30));
      expect(p.janmUtc, DateTime.utc(1943, 6, 1, 1, 30));
    });

    test('सहेजना, बदलना, हटाना — सिर्फ़ फ़ोन में', () async {
      await kundaliProfiles.save(patna1990);
      await kundaliProfiles.load();
      expect(kundaliProfiles.items.single.naam, 'रमेश');
      await kundaliProfiles.save(KundaliProfile(
        id: 'a',
        naam: 'रमेश कुमार',
        janm: patna1990.janm,
        sthanNaam: 'पटना',
        latitude: 25.5941,
        longitude: 85.1376,
      ));
      expect(kundaliProfiles.items.single.naam, 'रमेश कुमार');
      await kundaliProfiles.delete('a');
      await kundaliProfiles.load();
      expect(kundaliProfiles.items, isEmpty);
    });
  });

  group('भावों का बँटवारा', () {
    final k = computeKundali(patna1990.janmUtc, patna1990.place);

    test('लग्न कुंडली: पहला भाव लग्न की राशि, नौ ग्रह कुल', () {
      final b = bhavVibhag(k, KundaliAadhar.lagna);
      expect(b.length, 12);
      expect(b.first.rashi, k.lagna.rashi);
      expect(b.first.lagnaYahan, isTrue);
      expect(b.where((x) => x.lagnaYahan).length, 1);
      expect(b.fold<int>(0, (n, x) => n + x.grahas.length), 9);
      for (final x in b) {
        for (final g in x.grahas) {
          expect(k.bhav(g.graha), x.bhav);
        }
      }
    });

    test('चंद्र कुंडली: पहला भाव चंद्र की राशि; लग्न अपनी राशि वाले भाव में', () {
      final b = bhavVibhag(k, KundaliAadhar.chandra);
      expect(b.first.rashi, k[KundaliGraha.chandra].rashi);
      expect(b.first.grahas.map((g) => g.graha), contains(KundaliGraha.chandra));
      expect(b.singleWhere((x) => x.lagnaYahan).rashi, k.lagna.rashi);
      for (final x in b) {
        for (final g in x.grahas) {
          expect(k.chandraSeBhav(g.graha), x.bhav);
        }
      }
    });

    test('नवमांश: ग्रह अपने नवमांश की राशि में', () {
      final b = bhavVibhag(k, KundaliAadhar.navamsha);
      expect(b.first.rashi, k.lagna.navamsha);
      for (final x in b) {
        for (final g in x.grahas) {
          expect(g.navamsha, x.rashi);
          expect(k.navamshaBhav(g.graha), x.bhav);
        }
      }
    });

    test('राहु और केतु हमेशा आमने-सामने — सातवें भाव पर', () {
      final b = bhavVibhag(k, KundaliAadhar.lagna);
      int bhavOf(KundaliGraha g) =>
          b.firstWhere((x) => x.grahas.any((s) => s.graha == g)).bhav;
      expect((bhavOf(KundaliGraha.ketu) - bhavOf(KundaliGraha.rahu) + 12) % 12, 6);
    });
  });

  group('स्क्रीन', () {
    testWidgets('"अधिक" में कुंडली का अपना हिस्सा है, और वहाँ लिखा है कि फल नहीं',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('जन्म कुंडली'), 300);
      expect(find.text('जन्म के समय का आकाश — गणित, फल नहीं'), findsOneWidget);
      await tester.tap(find.text('जन्म कुंडली'));
      await tester.pumpAndSettle();
      expect(find.byType(KundaliProfilesScreen), findsOneWidget);
      expect(find.textContaining('फल, राशिफल या उपाय ऐप नहीं बताता'),
          findsOneWidget);
      expect(find.text('नई कुंडली बनाएँ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('अधूरा ब्यौरा नहीं सहेजा जाता — हर कमी साफ़ बताई जाती है',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const KundaliForm()));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('कुंडली बनाएँ'), 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('कुंडली बनाएँ'));
      await tester.pump();
      expect(find.text('नाम लिखिए।'), findsOneWidget);
      expect(find.byType(KundaliForm), findsOneWidget);
    });

    testWidgets('पुराना ब्यौरा बदलने पर वही शहर, तारीख़ और समय भरे मिलते हैं',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(KundaliForm(existing: patna1990)));
      await tester.pumpAndSettle();
      expect(find.text('रमेश'), findsOneWidget);
      expect(find.text('तारीख़: 15 मई 1990'), findsOneWidget);
      expect(find.text('समय: 14:30'), findsOneWidget);
      expect(find.textContaining('पटना'), findsWidgets);
    });

    testWidgets('1943 की तारीख़ पर घड़ी वाली चेतावनी खुली दिखती है',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(KundaliForm(
        existing: KundaliProfile(
          id: 'b',
          naam: 'दादी',
          janm: DateTime(1943, 6, 1, 8, 0),
          sthanNaam: 'पटना',
          latitude: 25.5941,
          longitude: 85.1376,
        ),
      )));
      await tester.pumpAndSettle();
      expect(find.textContaining('घड़ी एक घंटा आगे रखी गई'), findsOneWidget);
    });

    testWidgets('कुंडली: चारों पट्टियाँ खुलती हैं, और चित्र में नौ ग्रह हैं',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(KundaliScreen(
        profile: patna1990,
        abhi: DateTime.utc(2026, 10, 2),
      )));
      await tester.pumpAndSettle();

      expect(find.byType(KundaliChitra), findsOneWidget);
      expect(find.textContaining('रमेश · लग्न कुंडली'), findsOneWidget);
      // चित्र में हर ग्रह का छोटा नाम एक-एक बार
      for (final naam in grahaChhotaNaam.values) {
        expect(
            find.descendant(
                of: find.byType(KundaliChitra),
                matching: find.textContaining(naam, findRichText: true)),
            findsWidgets,
            reason: naam);
      }

      await tester.tap(find.text('नवमांश'));
      await tester.pumpAndSettle();
      expect(find.textContaining('रमेश · नवमांश कुंडली'), findsOneWidget);

      await tester.tap(find.text('ग्रह'));
      await tester.pumpAndSettle();
      expect(find.text('लग्न'), findsWidgets);
      expect(find.text('सूर्य'), findsOneWidget);

      await tester.tap(find.text('दशा'));
      await tester.pumpAndSettle();
      expect(find.textContaining('किस दशा में क्या होगा, यह ऐप नहीं बताता'),
          findsOneWidget);
      // 1990 का जन्म, 2026 में चौथी महादशा चल रही है — सूची में नीचे
      await tester.scrollUntilVisible(find.text('अभी की अंतर्दशा'), 300,
          scrollable: find.byType(Scrollable).last);
      expect(find.text('अभी'), findsOneWidget);
      expect(find.text('अभी की अंतर्दशा'), findsOneWidget);

      await tester.tap(find.text('पंचांग'));
      await tester.pumpAndSettle();
      expect(find.text('मंगलवार'), findsOneWidget); // 15 मई 1990
      expect(find.text('जन्म राशि'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('लग्न राशि की सीमा के पास हो तो चेतावनी खुली दिखती है',
        (tester) async {
      // ऐसा मिनट ढूँढो जब लग्न सीमा से एक अंश के भीतर हो
      KundaliProfile? sandhi;
      for (var m = 0; m < 24 * 60 && sandhi == null; m++) {
        final p = KundaliProfile(
          id: 's',
          naam: 'सीमा',
          janm: DateTime(1990, 5, 15).add(Duration(minutes: m)),
          sthanNaam: 'पटना',
          latitude: 25.5941,
          longitude: 85.1376,
        );
        if (computeKundali(p.janmUtc, p.place).lagnaSandhiMein()) sandhi = p;
      }
      expect(sandhi, isNotNull);
      phone(tester);
      await tester.pumpWidget(app(KundaliScreen(profile: sandhi!)));
      await tester.pumpAndSettle();
      expect(find.textContaining('राशि की सीमा के बिल्कुल पास'), findsOneWidget);

      // और आम जन्म पर वह नहीं दिखती
      await tester.pumpWidget(app(KundaliScreen(
          key: const ValueKey('aam'), profile: patna1990)));
      await tester.pumpAndSettle();
      expect(find.textContaining('राशि की सीमा के बिल्कुल पास'), findsNothing);
    });

    testWidgets('"यह गणना कैसे हुई" में तीनों चलन लिखे हैं',
        (tester) async {
      phone(tester);
      await tester.pumpWidget(app(KundaliScreen(profile: patna1990)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('यह गणना कैसे हुई'), 300,
          scrollable: find.byType(Scrollable).last);
      await tester.tap(find.text('यह गणना कैसे हुई'));
      await tester.pumpAndSettle();
      // शीट की सूची भी उतनी ही बनती है जितनी दिखती है — हर पंक्ति तक खिसकाओ
      for (final baat in [
        'लाहिड़ी (चित्रपक्ष)',
        'एक राशि, एक भाव',
        'औसत पात',
        'साल 365.25 दिन का',
        'फल बताना इस ऐप का काम नहीं',
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
        await tester.pumpWidget(app(KundaliScreen(
          profile: patna1990,
          abhi: DateTime.utc(2026, 10, 2),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'कुंडली');
        for (final patti in ['ग्रह', 'दशा', 'पंचांग']) {
          await tester.tap(find.text(patti));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: patti);
        }

        await tester.pumpWidget(app(const KundaliForm()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'ब्यौरा भरना');
        await tester.pumpWidget(app(const KundaliProfilesScreen()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'सूची');
      });
    }

    testWidgets('कहीं फल, राशिफल, दोष या उपाय का कोई शब्द वादे की तरह नहीं',
        (tester) async {
      phone(tester);
      tester.view.physicalSize = const Size(360 * 3, 9000 * 3);
      await tester.pumpWidget(app(KundaliScreen(
        profile: patna1990,
        abhi: DateTime.utc(2026, 10, 2),
      )));
      await tester.pumpAndSettle();
      const varjit = ['मांगलिक', 'दोष', 'साढ़ेसाती', 'कालसर्प', 'रत्न', 'शुभ फल',
        'अशुभ', 'भविष्य', 'उपाय कीजिए'];
      for (final patti in ['कुंडली', 'ग्रह', 'दशा', 'पंचांग']) {
        await tester.tap(find.text(patti).first);
        await tester.pumpAndSettle();
        final sab = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
            .join('\n');
        for (final shabd in varjit) {
          expect(sab, isNot(contains(shabd)), reason: '$patti में "$shabd"');
        }
      }
    });
  });
}
