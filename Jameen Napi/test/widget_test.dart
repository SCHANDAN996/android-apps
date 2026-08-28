import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:jameen_napi/data/app_language.dart';
import 'package:jameen_napi/data/land_units.dart';
import 'package:jameen_napi/data/length_units.dart';
import 'package:jameen_napi/data/pro_kisan_strings.dart';
import 'package:jameen_napi/data/tool_strings.dart';
import 'package:jameen_napi/main.dart';
import 'package:jameen_napi/screens/batwara_screen.dart';
import 'package:jameen_napi/screens/irregular_plot_screen.dart';

void main() {
  testWidgets('home screen shows all 6 dedicated land measurement tools', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KisanCalculatorApp(isOnboardingCompleted: true));
    await tester.pumpAndSettle();

    expect(find.text('जमीन नापी'), findsOneWidget);
    expect(find.text('भूमि क्षेत्रफल कन्वर्टर'), findsOneWidget);
    expect(find.text('4-भुजा खेत नापी (विषमबाहु)'), findsOneWidget);
    expect(find.text('प्लाट / लंबाई नाप कन्वर्टर'), findsOneWidget);
    expect(find.text('लग्गी पैमाना (धुर / कट्ठा)'), findsOneWidget);
    expect(find.text('जमीन बंटवारा (हिस्सा कैलकुलेटर)'), findsOneWidget);
    expect(find.text('त्रिकोणीय खेत नापी (3 भुजाएं)'), findsOneWidget);
  });

  testWidgets('batwara: removing a partner does not leave stale rows', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const MaterialApp(home: BatwaraScreen()));
    await tester.pumpAndSettle();

    // "अलग-अलग हिस्सा" मोड खोलें
    await tester.tap(find.text('अलग-अलग हिस्सा'));
    await tester.pumpAndSettle();

    // हर हिस्सेदार की एक row = [नाम, अनुपात], तो अनुपात वाले खाने विषम index पर हैं
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(6));
    await tester.enterText(fields.at(3), '2'); // हिस्सेदार 2 का अनुपात
    await tester.enterText(fields.at(5), '3'); // हिस्सेदार 3 का अनुपात
    await tester.pumpAndSettle();

    // बीच वाले (हिस्सेदार 2, अनुपात 2) को हटाएँ
    await tester.tap(find.byIcon(Icons.remove_circle_outline).at(1));
    await tester.pumpAndSettle();

    // बचे हुए खाने 1 और 3 दिखाने चाहिए — 1 और 2 नहीं (यही पुराना bug था)
    expect(find.widgetWithText(TextFormField, '3'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '2'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'हिस्सेदार 3'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'हिस्सेदार 2'), findsNothing);
  });

  testWidgets('irregular plot screen renders in the chosen language, not Hindi',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final previous = LanguageNotifier.instance.value;
    addTearDown(() => LanguageNotifier.instance.value = previous);
    LanguageNotifier.instance.value = AppLang.tamil;

    await tester.pumpWidget(const MaterialApp(home: IrregularPlotScreen()));
    await tester.pumpAndSettle();

    final tamil = AppStrings(AppLang.tamil);
    final hindi = AppStrings(AppLang.hindi);

    expect(find.text(tamil.irrEnterFourSides), findsOneWidget);
    expect(find.text(tamil.irrSideNorth), findsOneWidget);
    expect(find.text(tamil.unitLabel), findsOneWidget);

    // वही label हिंदी में कहीं नहीं दिखना चाहिए
    expect(find.text(hindi.irrEnterFourSides), findsNothing);
    expect(find.text(hindi.irrSideNorth), findsNothing);
  });

  group('land unit conversions', () {
    double convert(double value, LandUnit from, LandUnit to) =>
        value * from.sqft / to.sqft;

    LandUnit unit(String state, String en) =>
        unitsForState(state).firstWhere((u) => u.en == en);

    test('Bihar: 1 bigha = 20 katha = 400 dhur', () {
      const state = 'बिहार / झारखंड';
      final bigha = unit(state, 'Bigha');
      final katha = unit(state, 'Katha');
      final dhur = unit(state, 'Dhur');

      expect(convert(1, bigha, katha), closeTo(20, 1e-9));
      expect(convert(1, bigha, dhur), closeTo(400, 1e-9));
    });

    test('Punjab/Haryana: 1 killa = 1 acre = 8 kanal, 1 kanal = 20 marla', () {
      const state = 'पंजाब / हरियाणा';
      final killa = unit(state, 'Killa');
      final kanal = unit(state, 'Kanal');
      final marla = unit(state, 'Marla');
      final acre = unit(state, 'Acre');

      expect(convert(1, killa, acre), closeTo(1, 1e-9));
      expect(convert(1, killa, kanal), closeTo(8, 1e-9));
      expect(convert(1, kanal, marla), closeTo(20, 1e-9));

      final ghumao = unit(state, 'Ghumao');
      expect(convert(1, ghumao, acre), closeTo(1, 1e-9));
    });

    test('Bengal: 1 bigha = 20 katha, 1 katha = 16 chatak', () {
      const state = 'पश्चिम बंगाल';
      final bigha = unit(state, 'Bigha');
      final katha = unit(state, 'Katha');
      final chatak = unit(state, 'Chatak');

      expect(convert(1, bigha, katha), closeTo(20, 1e-9));
      expect(convert(1, katha, chatak), closeTo(16, 1e-9));
    });

    test('1 acre = 100 dismil = 40 guntha', () {
      final acre = standardUnits.firstWhere((u) => u.en == 'Acre');
      final dismil =
          standardUnits.firstWhere((u) => u.en == 'Dismil / Decimal');
      final guntha = unitsForState('महाराष्ट्र')
          .firstWhere((u) => u.en == 'Guntha');

      expect(convert(1, acre, dismil), closeTo(100, 1e-9));
      expect(convert(1, acre, guntha), closeTo(40, 1e-9));
    });

    test('1 hectare ≈ 2.4711 acre', () {
      final acre = standardUnits.firstWhere((u) => u.en == 'Acre');
      final hectare = standardUnits.firstWhere((u) => u.en == 'Hectare');

      expect(convert(1, hectare, acre), closeTo(2.4711, 0.0001));
    });
  });

  group('irregular plot calculation', () {
    test('Heron rectangle with diagonal: 120 x 90, diagonal 150 = 10800 sq ft', () {
      final res = calculateIrregularPlot(
        a: 120,
        b: 90,
        c: 120,
        d: 90,
        diagonal: 150,
      );

      expect(res.isValidDiagonal, isTrue);
      expect(res.exactAreaSqFt, closeTo(10800, 1e-5));
      expect(res.averageAreaSqFt, closeTo(10800, 1e-5));
    });

    // यह test तय करता है कि कौन-सा विकर्ण माँगा जा रहा है — ऐप की helper text
    // इसी से मेल खानी चाहिए, वरना किसान गलत तिरछी नाप डालेगा।
    //
    // खेत के कोने: NW(0,40) — NE(20,90) — SE(130,0) — SW(0,0)
    //   A (उत्तर, NW→NE) = √2900,  B (पूर्व, NE→SE) = √20200
    //   C (दक्षिण, SE→SW) = 130,   D (पश्चिम, SW→NW) = 40
    // सही क्षेत्रफल (shoelace) = 6250 वर्ग फीट
    test('diagonal must run NW(A-D corner) to SE(B-C corner)', () {
      final a = math.sqrt(2900); // ≈ 53.85
      final b = math.sqrt(20200); // ≈ 142.13
      const c = 130.0;
      const d = 40.0;

      final correctDiagonal = math.sqrt(18500); // NW → SE, ≈ 136.01
      final wrongDiagonal = math.sqrt(8500); // NE → SW, ≈ 92.20

      final correct = calculateIrregularPlot(
          a: a, b: b, c: c, d: d, diagonal: correctDiagonal);
      expect(correct.isValidDiagonal, isTrue);
      expect(correct.exactAreaSqFt, closeTo(6250.0, 1e-6));

      // उल्टा विकर्ण डालने पर इसी खेत का जवाब 70% तक गलत आता है —
      // इसीलिए helper text में सही कोना बताना ज़रूरी है।
      final wrong = calculateIrregularPlot(
          a: a, b: b, c: c, d: d, diagonal: wrongDiagonal);
      expect(wrong.exactAreaSqFt, isNotNull);
      expect(wrong.exactAreaSqFt, closeTo(1864.14, 0.01));
    });

    test('Average method when diagonal is omitted', () {
      final res = calculateIrregularPlot(
        a: 100,
        b: 50,
        c: 120,
        d: 70,
        diagonal: null,
      );

      expect(res.isValidDiagonal, isFalse);
      expect(res.exactAreaSqFt, isNull);
      expect(res.averageAreaSqFt, closeTo(110 * 60, 1e-5)); // 6600
    });
  });

  group('laggi scale calculations', () {
    test('5.5 haath laggi: 1 dhur = 68.0625 sq ft, 1 katha = 1361.25, 1 bigha = 27225', () {
      final info = LaggiInfo.fromHaath(5.5);
      expect(info.feet, closeTo(8.25, 1e-9));
      expect(info.inches, closeTo(99.0, 1e-9));
      expect(info.dhurSqFt, closeTo(68.0625, 1e-9));
      expect(info.kathaSqFt, closeTo(1361.25, 1e-9));
      expect(info.bighaSqFt, closeTo(27225.0, 1e-9));
      expect(info.dismilPerKatha, closeTo(3.125, 1e-9));
      expect(info.dismilPerBigha, closeTo(62.5, 1e-9));
    });

    test('6.0 haath laggi: 1 dhur = 81 sq ft, 1 katha = 1620, 1 bigha = 32400', () {
      final info = LaggiInfo.fromHaath(6.0);
      expect(info.feet, closeTo(9.0, 1e-9));
      expect(info.dhurSqFt, closeTo(81.0, 1e-9));
      expect(info.kathaSqFt, closeTo(1620.0, 1e-9));
      expect(info.bighaSqFt, closeTo(32400.0, 1e-9));
    });
  });

  group('triangle Heron calculation', () {
    test('3-4-5 right triangle = 6 sq units', () {
      final area = calculateTriangleHeron(3, 4, 5);
      expect(area, isNotNull);
      expect(area!, closeTo(6.0, 1e-9));
    });
  });

  group('length unit conversions', () {
    double convert(double value, LengthUnit from, LengthUnit to) =>
        value * from.feet / to.feet;

    LengthUnit unit(String en) =>
        lengthUnits.firstWhere((u) => u.en == en);

    test('1 Gaj = 3 Feet = 36 Inches', () {
      final gaj = unit('Gaj / Yard');
      final feet = unit('Feet');
      final inch = unit('Inch');

      expect(convert(1, gaj, feet), closeTo(3, 1e-9));
      expect(convert(1, gaj, inch), closeTo(36, 1e-9));
    });

    test('1 Haath = 1.5 Feet = 18 Inches', () {
      final haath = unit('Haath / Cubit');
      final feet = unit('Feet');
      final inch = unit('Inch');

      expect(convert(1, haath, feet), closeTo(1.5, 1e-9));
      expect(convert(1, haath, inch), closeTo(18, 1e-9));
    });

    test('1 Jarib = 100 Kadi = 66 Feet', () {
      final jarib = unit('Jarib / Chain');
      final kadi = unit('Kadi / Link');
      final feet = unit('Feet');

      expect(convert(1, jarib, kadi), closeTo(100, 1e-9));
      expect(convert(1, jarib, feet), closeTo(66, 1e-9));
    });
  });

  group('tool string coverage', () {
    // चारों नापी स्क्रीनों की strings `tool_strings.dart` में हैं। हर string नौ
    // की नौ भाषाओं में होनी चाहिए — एक भी छूटी तो वो भाषा चुपचाप हिंदी पर गिर
    // जाती है और user को अपनी भाषा के बीच हिंदी दिखती है। यह test source पढ़कर
    // हर `pick({...})` map की चाबियाँ गिनता है।
    test('every pick() map covers all nine languages', () {
      // दोनों फाइलें: स्क्रीनों की strings और AppStrings के अपने getters.
      final toolSource = File('lib/data/tool_strings.dart').readAsStringSync();
      final langSource = File('lib/data/app_language.dart').readAsStringSync() +
          File('lib/data/pro_kisan_strings.dart').readAsStringSync();
      expect(toolSource, contains('extension ToolStrings'),
          reason: 'tool_strings.dart नहीं मिली या बदल गई है');
      final source = toolSource + String.fromCharCode(10) + langSource;

      final maps = RegExp(r'pick\((?:const\s+)?\{(.*?)\}\)', dotAll: true)
          .allMatches(source);
      expect(maps.length, greaterThan(70),
          reason: 'pick() maps मिले ही नहीं — regex टूट गया?');

      final missing = <String>[];
      for (final match in maps) {
        final body = match.group(1)!;
        final present = AppLang.values
            .where((lang) => body.contains('AppLang.${lang.name}:'))
            .toSet();
        final absent =
            AppLang.values.where((l) => !present.contains(l)).toList();
        if (absent.isNotEmpty) {
          // गड़बड़ कहाँ है, यह बताने के लिए पहली line दिखाएँ
          final head = body.trim().split('\n').first.trim();
          missing.add('${absent.map((l) => l.name).join(', ')}  ←  $head');
        }
      }

      expect(missing, isEmpty,
          reason: 'इन strings में भाषाएँ छूटी हैं:\n${missing.join('\n')}');
    });

    test('no string mixes two Indic scripts', () {
      // पहले onboarding की पंजाबी string में कन्नड़ के अक्षर घुस गए थे और
      // गुजराती में बंगाली — फोन पर टूटा text दिखता है। यह test उसे पकड़ता है।
      const blocks = <String, List<int>>{
        'Devanagari': [0x0900, 0x097F],
        'Bengali': [0x0980, 0x09FF],
        'Gurmukhi': [0x0A00, 0x0A7F],
        'Gujarati': [0x0A80, 0x0AFF],
        'Tamil': [0x0B80, 0x0BFF],
        'Telugu': [0x0C00, 0x0C7F],
        'Kannada': [0x0C80, 0x0CFF],
      };

      String? scriptOf(int code) {
        for (final entry in blocks.entries) {
          if (code >= entry.value[0] && code <= entry.value[1]) {
            return entry.key;
          }
        }
        return null;
      }

      // देवनागरी दंड '।' पंजाबी/बंगाली में भी चलता है, इसे छोड़ दें
      const shared = {0x0964, 0x0965};

      final offenders = <String>[];
      for (final lang in AppLang.values) {
        final strings = AppStrings(lang);
        final samples = <String>[
          strings.appTitle,
          strings.appSubtitle,
          strings.settingsTitle,
          strings.selectLanguage,
          strings.irrEnterFourSides,
          strings.irrDiagonalHelper,
          strings.irrPatwariNote,
          strings.batEqualMode,
          strings.batCustomMode,
          strings.batFinalShares,
          strings.lagChooseLaggi,
          strings.lagHaathNote,
          strings.lagAminFormula,
          strings.triEnterThreeSides,
          strings.triInvalidHint,
          strings.triTotalArea,
          strings.unitLabel,
          strings.stateLabel,
          strings.sharedFromApp,
          // Converter / Length screen aur baaki nayi strings
          strings.directAreaMode,
          strings.lengthWidthMode,
          strings.totalCalculatedArea,
          strings.selectState,
          strings.enterArea,
          strings.selectUnit,
          strings.lengthEnterHeading,
          strings.lengthOtherUnits,
          strings.lengthInfoTitle,
          strings.copied,
          strings.calculate,
          strings.shareResultTitle,
          // Home ke badge
          strings.badgeStates,
          strings.badgeExact,
          strings.badgeChain,
          strings.badgeDesiScale,
          strings.badgePartition,
          strings.badgeThreeSides,
          // Nakshe ke label
          strings.dirNorth,
          strings.dirEast,
          strings.dirSouth,
          strings.dirWest,
          strings.diagonalShort,
          strings.baseShort,
          // Privacy dialog
          strings.privacyIntro,
          strings.privacyOffline,
          strings.privacyNoPersonalData,
          strings.privacyAds,
          strings.privacyNoOtherPermission,
          strings.shareAppTitle,
          strings.shareAppSubtitle,
          // Rajya ke naam
          ...stateUnits.keys.map(strings.stateDisplayName),
          strings.stateDisplayName(standardStateKey),
          ...strings.lengthInfoLines,
          ...lengthUnits.map((u) => strings.lengthUnitName(u.en)),
          // Pro Kisan promo
          strings.pkOurOtherApp,
          strings.pkName,
          strings.pkTagline,
          strings.pkWhatItDoes,
          strings.pkMilkTitle,
          strings.pkMilkBody,
          strings.pkFertTitle,
          strings.pkFertBody,
          strings.pkCattleTitle,
          strings.pkCattleBody,
          strings.pkWeatherBody,
          strings.pkMandiBody,
          strings.pkSchemeBody,
          strings.pkGpsBody,
          strings.pkDataNote,
          strings.pkInternetNote,
          strings.pkInstallNow,
          strings.pkOpenApp,
        ];

        for (final text in samples) {
          final found = <String>{};
          for (final code in text.runes) {
            if (shared.contains(code)) continue;
            final script = scriptOf(code);
            if (script != null) found.add(script);
          }
          if (found.length > 1) {
            offenders.add('${lang.name}: "$text" → ${found.join(' + ')}');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'इन strings में दो लिपियाँ मिली हुई हैं:\n${offenders.join('\n')}');
    });
  });

  group('startup language', () {
    test('saved choice always wins over the phone language', () {
      expect(
        resolveStartupLanguage(
          savedCode: 'tamil',
          deviceLocales: const [Locale('mr')],
        ),
        AppLang.tamil,
      );
    });

    test('with no saved choice, follows the phone language', () {
      expect(
        resolveStartupLanguage(
          savedCode: null,
          deviceLocales: const [Locale('bn', 'IN')],
        ),
        AppLang.bengali,
      );
      expect(
        resolveStartupLanguage(
          savedCode: null,
          deviceLocales: const [Locale('en', 'US')],
        ),
        AppLang.english,
      );
    });

    test('skips unsupported phone languages and uses the next one', () {
      expect(
        resolveStartupLanguage(
          savedCode: null,
          deviceLocales: const [Locale('ml'), Locale('kn')],
        ),
        AppLang.kannada,
      );
    });

    test('falls back to Hindi only when nothing matches', () {
      expect(
        resolveStartupLanguage(savedCode: null, deviceLocales: const []),
        AppLang.hindi,
      );
      expect(
        resolveStartupLanguage(
          savedCode: null,
          deviceLocales: const [Locale('ja')],
        ),
        AppLang.hindi,
      );
    });

    test('a corrupt saved code does not crash, falls through to phone language', () {
      expect(
        resolveStartupLanguage(
          savedCode: 'klingon',
          deviceLocales: const [Locale('gu')],
        ),
        AppLang.gujarati,
      );
    });

    test('every offered language is reachable from a phone locale', () {
      for (final lang in AppLang.values) {
        expect(
          AppStrings.languageNames.containsKey(lang),
          isTrue,
          reason: '${lang.name} has no display name in the settings list',
        );
      }
      // हर भाषा किसी न किसी ISO code से मिलनी चाहिए
      const codes = ['hi', 'en', 'mr', 'gu', 'pa', 'bn', 'te', 'ta', 'kn'];
      final reachable = codes.map(appLangFromLanguageCode).toSet();
      expect(reachable, containsAll(AppLang.values));
    });
  });

  group('length screen defaults', () {
    test('default length unit is Feet, not whatever sits at index 2', () {
      final feet =
          lengthUnits.firstWhere((u) => u.en == 'Feet', orElse: () => lengthUnits.first);
      expect(feet.feet, 1.0);
      expect(feet.hi, 'फीट');
    });
  });

  group('formatIndian', () {
    test('groups digits in Indian style', () {
      expect(formatIndian(1234567), '12,34,567');
      expect(formatIndian(100000), '1,00,000');
      expect(formatIndian(1000), '1,000');
      expect(formatIndian(999), '999');
    });

    test('trims trailing zeros', () {
      expect(formatIndian(20), '20');
      expect(formatIndian(2.5), '2.5');
    });
  });
}
