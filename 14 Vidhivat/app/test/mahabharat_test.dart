import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';

/// महाभारत — अठारह पर्वों का **सार** (→ D-111)। यह पाठ नहीं, गद्य है; आधार
/// महाभारत का अपना पर्वसंग्रह (`docs/18_SROT_PANJI.md` अध्याय २७)।
void main() {
  const dir = 'assets/granth/mahabharat';
  const ank = '०१२३४५६७८९';

  /// "७,९८४" → 7984
  int ginti(String s) => int.parse(s
      .replaceAll(',', '')
      .split('')
      .map((c) => ank.indexOf(c).toString())
      .join());

  late GranthKram kram;
  late Map<String, Paath> paath;
  late List<Paath> parv; // p01 … p18, क्रम में

  setUpAll(() {
    kram = GranthKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse(
            '$dir/${p.id}.json', File('$dir/${p.id}.json').readAsStringSync()),
    };
    parv = [
      for (var i = 1; i <= 18; i++)
        paath['mahabharat_p${i.toString().padLeft(2, '0')}']!,
    ];
  });

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है; परिचय और अठारह पर्व, क्रम में', () {
      final suchi = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'mahabharat');
      expect(g.naam, 'महाभारत');
      expect(g.gintiNaam, 'खंड');
      expect(GranthBhandar.granthIds, contains('mahabharat'));

      expect(kram.kram.map((p) => p.id), [
        'mahabharat_parichay',
        for (var i = 1; i <= 18; i++)
          'mahabharat_p${i.toString().padLeft(2, '0')}',
      ]);
      expect(kram.kram.map((p) => p.naam).skip(1), [
        'आदि पर्व', 'सभा पर्व', 'वन पर्व', 'विराट पर्व', 'उद्योग पर्व',
        'भीष्म पर्व', 'द्रोण पर्व', 'कर्ण पर्व', 'शल्य पर्व', 'सौप्तिक पर्व',
        'स्त्री पर्व', 'शांति पर्व', 'अनुशासन पर्व', 'आश्वमेधिक पर्व',
        'आश्रमवासिक पर्व', 'मौसल पर्व', 'महाप्रस्थानिक पर्व',
        'स्वर्गारोहण पर्व',
      ]);
    });

    test('हर पाठ "सार" है — गद्य भरा, रोमन और अर्थ ख़ाली, अंग्रेज़ी अक्षर नहीं', () {
      final latin = RegExp(r'[A-Za-z0-9]');
      for (final p in paath.values) {
        expect(p.prakar, PaathPrakar.saar, reason: p.id);
        expect(p.bhasha, 'हिंदी', reason: p.id);
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.dev.trim().split(RegExp(r'\s+')).length, greaterThan(7),
              reason: kahan);
          expect(k.roman, isEmpty, reason: kahan);
          expect(k.arth, isEmpty, reason: kahan);
          expect(latin.hasMatch(k.dev), isFalse, reason: kahan);
        }
      }
      // सूची की गिनती = खंडों की गिनती
      for (final s in kram.kram) {
        expect(s.shlok, paath[s.id]!.khandKul, reason: s.id);
      }
    });

    test('🔑 "यह सार है, शब्दशः पाठ नहीं" हर पन्ने पर खुला रहेगा', () {
      for (final p in paath.values) {
        expect(p.saavdhani, contains('यह सार है'), reason: p.id);
        expect(p.saavdhani, contains('शब्दशः पाठ नहीं'), reason: p.id);
      }
    });
  });

  group('गिनती — पर्वसंग्रह और समीक्षित संस्करण', () {
    final nazar = RegExp(r'पर्वसंग्रह की गिनती: ([०-९,]+) अध्याय, ([०-९,]+) श्लोक। '
        r'समीक्षित संस्करण में (?:भी )?([०-९,]+) अध्याय।');

    test('हर पर्व का पहला खंड "एक नज़र में", और उसमें दोनों गिनतियाँ', () {
      // पर्वसंग्रह (१.२.९५–२३२) के शब्दों से पढ़ी हुई गिनती
      const parvasangraha = [
        (218, 7984), (72, 2511), (269, 11664), (67, 2050), (186, 6698),
        (117, 5884), (170, 8909), (69, 4900), (59, 3220), (18, 870),
        (27, 775), (339, 14525), (146, 6700), (133, 3320), (42, 1506),
        (8, 300), (3, 120), (5, 200),
      ];
      // समीक्षित संस्करण की फ़ाइलों से मशीन की गिनती
      const samikshit = [
        225, 72, 299, 67, 197, 117, 173, 69, 64, 18, 27, 353, 154, 96, 47, 9,
        3, 5,
      ];
      for (var i = 0; i < 18; i++) {
        final pehla = parv[i].khand.first;
        expect(pehla.shirshak, 'एक नज़र में', reason: parv[i].id);
        final m = nazar.firstMatch(pehla.dev);
        expect(m, isNotNull, reason: parv[i].id);
        expect(ginti(m!.group(1)!), parvasangraha[i].$1, reason: parv[i].id);
        expect(ginti(m.group(2)!), parvasangraha[i].$2, reason: parv[i].id);
        expect(ginti(m.group(3)!), samikshit[i], reason: parv[i].id);
        // "भी" तभी, जब दोनों गिनतियाँ एक हों
        expect(pehla.dev.contains('संस्करण में भी'),
            parvasangraha[i].$1 == samikshit[i],
            reason: parv[i].id);
      }
    });

    test('परिचय का जोड़ पर्वों की गिनती से मिलता है', () {
      var adhyay = 0, shlok = 0, samikshit = 0;
      for (final p in parv) {
        final m = nazar.firstMatch(p.khand.first.dev)!;
        adhyay += ginti(m.group(1)!);
        shlok += ginti(m.group(2)!);
        samikshit += ginti(m.group(3)!);
      }
      expect(adhyay, 1948);
      expect(shlok, 82136);
      expect(samikshit, 1995);
      final kitna = paath['mahabharat_parichay']!
          .khand
          .singleWhere((k) => k.shirshak == 'कितना बड़ा')
          .dev;
      expect(kitna, contains('१,९४८ अध्याय और ८२,१३६ श्लोक'));
      expect(kitna, contains('१,९९५ अध्याय'));
      expect(kitna, contains('एक लाख श्लोकों'));
    });
  });

  group('कथा', () {
    String sab(Paath p) => p.khand.map((k) => k.dev).join('\n');

    test('जो हिस्से ग्रंथालय में पूरे पाठ के साथ हैं, उनका पता सही पर्व में', () {
      expect(sab(parv[5]), contains('गीता')); // भीष्म
      expect(sab(parv[5]), contains('अध्याय २३ से ४० तक'));
      expect(sab(parv[12]), contains('विष्णु सहस्रनाम')); // अनुशासन
      expect(sab(parv[12]), contains('अध्याय १३५'));
      expect(sab(parv[4]), contains('विदुर नीति')); // उद्योग
      expect(sab(parv[4]), contains('सनत्सुजात'));
      expect(sab(parv[2]), contains('यक्ष के प्रश्नों')); // वन
    });

    test('हर पर्व की पहचान वाली घटना अपने पर्व में है', () {
      const pehchan = [
        ['जनमेजय', 'भीष्म', 'द्रौपदी का विवाह', 'खांडव वन'],
        ['राजसूय', 'जरासंध', 'शिशुपाल', 'शकुनि'],
        ['नल और दमयंती', 'किरात', 'जयद्रथ', 'सावित्री', 'कुंडल'],
        ['शमी', 'कीचक', 'उत्तरा'],
        ['उपप्लव्य', 'अक्षौहिणी', 'संजय', 'योगेश्वर', 'अंबा'],
        ['जंबूखंड', 'शिखंडी', 'दस दिन'],
        ['संशप्तक', 'अभिमन्यु', 'जयद्रथ', 'नारायणास्त्र'],
        ['शल्य', 'त्रिपुर', 'कर्ण को मार देते हैं'],
        ['शल्य', 'गदायुद्ध', 'सरस्वती'],
        ['कृतवर्मा', 'अश्वत्थामा', 'सात्यकि', 'तर्पण'],
        ['विलाप', 'गांधारी', 'दाह'],
        ['राजधर्म', 'आपद्धर्म', 'मोक्षधर्म'],
        ['दानों का फल', 'भीष्म स्वर्ग को जाते हैं'],
        ['संवर्त', 'परीक्षित', 'बभ्रुवाहन', 'नेवले'],
        ['गांधारी', 'कुंती', 'विदुर', 'नारद'],
        ['एरका', 'बलराम', 'द्वारका', 'गांडीव'],
        ['उत्तर दिशा', 'कुत्ता', 'इंद्र', 'द्वैतवन'],
        ['दुर्योधन', 'देवदूत', 'तीसरी परीक्षा', 'आकाशगंगा', '«जय»'],
      ];
      for (var i = 0; i < 18; i++) {
        for (final shabd in pehchan[i]) {
          expect(sab(parv[i]), contains(shabd),
              reason: '${parv[i].naam}: "$shabd"');
        }
      }
    });

    test('ⓘ बताता है कि सार किस पर टिका है — और क्या नहीं जोड़ा गया', () {
      final note = parv[0].strot.note;
      expect(note, contains('पर्वसंग्रह'));
      expect(note, contains('जो बात वहाँ नहीं है, वह यहाँ भी नहीं जोड़ी गई'));
      expect(note, contains('शब्द ऐप के अपने हैं'));
      // आख़िरी दो पर्व सीधे अपने पाठ से
      for (final p in [parv[16], parv[17]]) {
        expect(p.strot.note, contains('सीधे इन पर्वों के पाठ को पढ़कर'),
            reason: p.id);
      }
    });
  });

  group('स्क्रीन पर', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
    });

    Widget app(Widget home) => ListenableBuilder(
          listenable: settings,
          builder: (context, _) =>
              MaterialApp(theme: VidhivatTheme.dark(), home: home),
        );

    void lambaPhone(WidgetTester tester, {double width = 400}) {
      tester.view.physicalSize = Size(width * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<void> granthKholo(WidgetTester tester) async {
      lambaPhone(tester);
      final g = (await granthBhandar.suchi())
          .singleWhere((g) => g.id == 'mahabharat');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();
    }

    testWidgets('ग्रंथ का पन्ना — तीन हिस्से, गिनती "खंड" में', (tester) async {
      await granthKholo(tester);
      for (final hissa in [
        'युद्ध से पहले',
        'अठारह दिन का युद्ध',
        'युद्ध के बाद',
      ]) {
        expect(find.text(hissa), findsOneWidget, reason: hissa);
      }
      expect(find.text('आदि पर्व'), findsOneWidget);
      expect(find.text('6 खंड'), findsOneWidget); // आदि पर्व
      expect(find.textContaining('श्लोक'), findsNothing);
      // सूची उतनी ही बनती है जितनी दिखती है — आख़िरी पर्व तक खिसकाओ
      await tester.scrollUntilVisible(find.text('स्वर्गारोहण पर्व'), 300,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('स्वर्गारोहण पर्व'), findsOneWidget);
      expect(find.textContaining('श्लोक'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पर्व खुलता है: "यह सार है" खुला, "अर्थ दिखाएँ" नहीं, अक्षर पढ़ने वाले',
        (tester) async {
      await granthKholo(tester);
      await tester.tap(find.text('भीष्म पर्व'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('महाभारत · भाग 7/19'), findsOneWidget);

      // खुला सच — ⓘ के पीछे नहीं (→ D-060)
      expect(find.textContaining('यह सार है'), findsOneWidget);
      expect(find.textContaining('शब्दशः पाठ नहीं'), findsOneWidget);

      // "पाठ" नहीं, "सार"; और अर्थ/रोमन का बटन नहीं
      expect(find.text('सार'), findsOneWidget);
      expect(find.text('पाठ'), findsNothing);
      expect(find.text('4 खंड'), findsOneWidget);
      expect(find.text('अर्थ दिखाएँ'), findsNothing);
      expect(find.text('रोमन दिखाएँ'), findsNothing);

      // गद्य मंत्र वाले बड़े अक्षरों में नहीं
      final type = VidhivatTheme.typographyOf(
          tester.element(find.byType(PaathScreen)));
      final gadya = tester.widget<Text>(
          find.textContaining('अर्जुन पर मोह छा जाता है'));
      expect(gadya.style!.fontSize, type.bodyLarge.fontSize);
      expect(gadya.style!.fontSize, isNot(type.mantra.fontSize));
      expect(tester.takeException(), isNull);
    });

    for (final (chaudai, akshar) in [(320.0, 1.5), (360.0, 2.0)]) {
      testWidgets(
          'छोटे फ़ोन पर भी कुछ बाहर नहीं निकलता — $chaudai चौड़ाई, $akshar गुना अक्षर',
          (tester) async {
        tester.view.physicalSize = Size(chaudai * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        tester.platformDispatcher.textScaleFactorTestValue = akshar;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final g = (await granthBhandar.suchi())
            .singleWhere((g) => g.id == 'mahabharat');
        await tester.pumpWidget(app(GranthScreen(granth: g)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'सूची');
        await tester.scrollUntilVisible(find.text('आदि पर्व'), 200,
            scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('आदि पर्व'));
        await tester.pumpAndSettle();
        expect(find.byType(PaathScreen), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'पर्व');
      });
    }
  });
}
