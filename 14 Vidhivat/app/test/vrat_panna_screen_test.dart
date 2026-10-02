// व्रत का पन्ना, कथा का पन्ना और साल की एकादशियाँ (→ D-075, D-076)।
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vrat_panna_screen.dart';
import 'package:vidhivat/screens/vrat_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/vidhi/vrat_panna.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget child) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: child,
      );

  void phoneNaap(WidgetTester tester,
      {double width = 360, double height = 800}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> scrollTak(WidgetTester tester, Finder tak,
      {double kadam = 200}) async {
    await tester.scrollUntilVisible(tak, kadam,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  group('व्रत का मॉडल', () {
    test('सूची का हर तैयार व्रत ऐप के ढाँचे में खुलता है', () async {
      final suchi = await vratBhandar.suchi();
      final taiyar = suchi.where((e) => e.taiyar && e.faail == null).toList();
      expect(taiyar.length, greaterThanOrEqualTo(30));
      for (final e in taiyar) {
        // Mantra.fromJson के नियम भी यहीं लगते हैं — बिना स्रोत का पाठ,
        // या "paas" बिना जाँच के, पढ़ते ही टूटेगा।
        final v = await vratBhandar.panna(e.id);
        expect(v.naam, e.naam, reason: e.id);
        expect(v.bhojan.first.nirjal, isFalse, reason: e.id);
        expect(v.mantra.sthiti, isNot(MantraSthiti.paas), reason: e.id);
        expect(
          v.kathaIds.isNotEmpty || v.kathaKyonNahi.isNotEmpty,
          isTrue,
          reason: e.id,
        );
      }
    });

    test('पढ़ते ही ** के तारे हट जाते हैं — व्रत में भी, कथा में भी', () async {
      final v = await vratBhandar.panna('pradosh');
      expect(v.doDin, isNot(contains('**')));
      final k = await kathaBhandar.katha('somvar_vrat');
      for (final a in k.adhyay) {
        expect(a.gadya, isNot(contains('**')), reason: a.shirshak);
      }
    });

    test('साल की 26 एकादशियाँ क्रम से, अधिक मास की दो', () async {
      final sab = await vratBhandar.ekadashiVarsh();
      expect(sab, hasLength(26));
      expect([for (final e in sab) e.kram], List.generate(26, (i) => i + 1));
      expect(sab.where((e) => e.adhik), hasLength(2));
      final nirjala = sab.firstWhere((e) => e.id == 'nirjala');
      expect(nirjala.kabLikha, 'ज्येष्ठ शुक्ल पक्ष');
      expect(nirjala.vishesh, contains('सुझाव नहीं'));
    });
  });

  group('व्रत का पन्ना', () {
    testWidgets('एकादशी — बारहों खाने क्रम से, और कथा खुलती है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratPannaScreen(id: 'ekadashi')));
      await tester.pumpAndSettle();

      // नाम AppBar में भी है और ऊपर के चित्र वाले हिस्से में भी — AppBar वाला देखो।
      expect(
          find.descendant(
              of: find.byType(AppBar), matching: find.text('एकादशी व्रत')),
          findsOneWidget);
      for (final khana in [
        'कब करें',
        'यह व्रत क्यों रखा जाता है',
        'माहात्म्य',
        'नियम',
        'भोजन',
        'पारण — व्रत कब और कैसे खोलें',
        'पूजा',
        'मंत्र',
        'कथा',
        'उद्यापन',
        'सावधानी',
        'आम सवाल',
      ]) {
        await scrollTak(tester, find.text(khana));
        expect(find.text(khana), findsOneWidget, reason: khana);
      }
      expect(find.textContaining('**'), findsNothing);

      // कथा का बटन ऊपर छूट गया है — वापस ऊपर चलो।
      final kathaBatan =
          find.text('एकादशी की उत्पत्ति — उत्पन्ना एकादशी व्रत कथा');
      await scrollTak(tester, kathaBatan, kadam: -200);
      await tester.tap(kathaBatan);
      await tester.pumpAndSettle();
      expect(find.byType(KathaScreen), findsOneWidget);
      // भावार्थ वाली बात कथा के ऊपर खुली रहती है (→ D-060)
      expect(find.textContaining('शब्दशः संस्कृत पाठ नहीं'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('मंत्र ख़ाली हो तो बना हुआ मंत्र नहीं, कारण दिखता है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratPannaScreen(id: 'shukravar')));
      await tester.pumpAndSettle();

      await scrollTak(
          tester, find.textContaining('संतोषी माता का कोई मंत्र ऐप को'));
      expect(find.textContaining('संतोषी माता का कोई मंत्र ऐप को'),
          findsOneWidget);
    });

    testWidgets('ऋषि पंचमी — कथा न लेने का कारण खुला दिखता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratPannaScreen(id: 'rishi_panchami')));
      await tester.pumpAndSettle();

      await scrollTak(
          tester, find.textContaining('इसलिए ऐप ने इसे जान-बूझकर नहीं लिया'));
      expect(find.textContaining('इसलिए ऐप ने इसे जान-बूझकर नहीं लिया'),
          findsOneWidget);
    });

    testWidgets('माहात्म्य का स्रोत ⓘ के पीछे, "ऐप का वादा नहीं" के साथ',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratPannaScreen(id: 'somvar')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('यह बात कहाँ से है'));
      await tester.tap(find.text('यह बात कहाँ से है'));
      await tester.pumpAndSettle();
      expect(find.text('यह ग्रंथ या कथा का कथन है — ऐप का वादा नहीं।'),
          findsOneWidget);
    });

    testWidgets('320 dp और 1.5x अक्षर पर पूरा पन्ना सुरक्षित है',
        (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(MaterialApp(
        theme: VidhivatTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: VratPannaScreen(id: 'chhath'),
        ),
      ));
      await tester.pumpAndSettle();
      for (final khana in ['भोजन', 'मंत्र', 'सावधानी', 'आम सवाल']) {
        await scrollTak(tester, find.text(khana));
      }
      expect(tester.takeException(), isNull, reason: '320dp/1.5x पर overflow');
    });
  });

  group('व्रत की सूची से पन्ने तक', () {
    testWidgets('"हर व्रत का पूरा पन्ना" से सोमवार खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VratScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('सोमवार व्रत'));
      await tester.tap(find.text('सोमवार व्रत'));
      await tester.pumpAndSettle();
      expect(find.byType(VratPannaScreen), findsOneWidget);
      expect(find.text('हर सोमवार — शिव-पार्वती का व्रत'), findsOneWidget);
    });

    testWidgets('साल की एकादशियाँ — निर्जला की कथा चेतावनी के साथ खुलती है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const EkadashiVarshScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('निर्जला एकादशी'));
      await tester.tap(find.text('निर्जला एकादशी'));
      await tester.pumpAndSettle();
      expect(find.byType(KathaScreen), findsOneWidget);
      expect(
          find.textContaining('ऐप निर्जल का सुझाव नहीं देता'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  test('समूहों के नाम', () {
    expect(VratSamuh.values.map((s) => s.naam), [
      'हर हफ़्ते',
      'हर महीने',
      'साल की एकादशियाँ',
      'साल के बड़े व्रत',
    ]);
  });
}
