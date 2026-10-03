import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// श्री विष्णु सहस्रनाम — महाभारत, अनुशासन पर्व (→ D-107)।
///
/// पाठ महाभारत के शोध-संस्करण, दो संग्रहों और छपी पुस्तकों से मिलाया गया
/// (ब्यौरा `docs/18_SROT_PANJI.md` अध्याय २३)। हज़ार नाम शंकर-भाष्य वाली
/// गिनती पर हैं — यह जाँच देखती है कि गिनती कहीं टूटी नहीं।
void main() {
  const dir = 'assets/granth/vishnusahasranama';
  const ank = '०१२३४५६७८९';
  int sankhya(String dev) =>
      int.parse(dev.split('').map((c) => ank.indexOf(c).toString()).join());

  late GranthKram kram;
  late Map<String, Paath> paath;

  setUpAll(() {
    kram = GranthKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse(
            '$dir/${p.id}.json', File('$dir/${p.id}.json').readAsStringSync()),
    };
  });

  Iterable<PaathKhand> shlok(Paath p) =>
      p.khand.where((k) => k.shirshak.startsWith('श्लोक'));

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है', () {
      final suchi = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'vishnusahasranama');
      expect(g.naam, 'श्री विष्णु सहस्रनाम');
      expect(g.ikai, 'भाग');
      expect(g.khandIkai, 'श्लोक');
      expect(GranthBhandar.granthIds, contains('vishnusahasranama'));
    });

    test('तीन भाग: तेरह श्लोक, एक सौ सात, बाईस — कुल 142, महाभारत वाली गिनती',
        () {
      expect(kram.kram.map((p) => p.id), [
        'vishnusahasranama_01',
        'vishnusahasranama_02',
        'vishnusahasranama_03',
      ]);
      final ginti = [for (final p in kram.kram) shlok(paath[p.id]!).length];
      expect(ginti, [13, 107, 22]);
      expect(ginti.fold<int>(0, (a, b) => a + b), 142);
      for (final k in kram.kram) {
        expect(k.shlok, shlok(paath[k.id]!).length, reason: k.id);
        expect(paath[k.id]!.naam, k.naam, reason: k.id);
      }
    });

    test('फ़ोल्डर की हर फ़ाइल क्रम में है', () {
      final files = Directory(dir)
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json') && n != '_kram.json')
          .map((n) => n.substring(0, n.length - 5))
          .toSet();
      expect(files, kram.kram.map((p) => p.id).toSet());
    });
  });

  group('हज़ार नाम', () {
    /// हर श्लोक का अर्थ "(नाम ९९३–१०००) शङ्खभृत् — …; नन्दकी — …" से शुरू
    /// होता है। अंक एक से हज़ार तक बिना टूटे चलें, और हर श्लोक में उतने ही
    /// नाम हों जितने अंक कहते हैं।
    test('नाम एक से हज़ार तक, बिना छूटे, बिना दोहराए', () {
      final p = paath['vishnusahasranama_02']!;
      var agla = 1;
      for (final k in shlok(p)) {
        final m = RegExp(r'^\(नाम ([०-९]+)–([०-९]+)\) (.+)।$').firstMatch(k.arth);
        expect(m, isNotNull, reason: k.shirshak);
        final a = sankhya(m!.group(1)!), b = sankhya(m.group(2)!);
        expect(a, agla, reason: k.shirshak);
        expect(m.group(3)!.split('; ').length, b - a + 1, reason: k.shirshak);
        agla = b + 1;
      }
      expect(agla, 1001);
    });

    test('पहला, आख़िरी और कुछ जाने-पहचाने श्लोक', () {
      String s(String id, String shirshak) =>
          paath[id]!.khand.firstWhere((k) => k.shirshak == shirshak).dev;
      expect(s('vishnusahasranama_02', 'श्लोक १'),
          startsWith('विश्वं विष्णुर्वषट्कारो'));
      expect(s('vishnusahasranama_02', 'श्लोक १०७'),
          contains('सर्वप्रहरणायुधः'));
      expect(s('vishnusahasranama_02', 'श्लोक ८८'), contains('न्यग्रोधोदुम्बरो'));
      expect(s('vishnusahasranama_01', 'ध्यान'),
          startsWith('शान्ताकारं भुजगशयनं'));
      expect(s('vishnusahasranama_01', 'श्लोक १'), startsWith('वैशम्पायन उवाच'));
      expect(s('vishnusahasranama_03', 'श्लोक २२'), contains('प्रभवाप्ययम्'));
      expect(paath['vishnusahasranama_03']!.khand.last.shirshak, 'समापन');
      expect(paath['vishnusahasranama_03']!.khand.last.dev,
          contains('दिव्यसहस्रनामस्तोत्रम्'));
    });
  });

  group('पाठ', () {
    test('हर खंड भरा है — देवनागरी, रोमन और अर्थ; अंग्रेज़ी अक्षर नहीं', () {
      for (final p in paath.values) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.hasPath, isTrue, reason: kahan);
          expect(k.roman.trim(), isNotEmpty, reason: kahan);
          expect(k.arth.trim(), isNotEmpty, reason: kahan);
          expect(k.dev, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.arth, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.roman.runes.any((r) => r >= 0x0900 && r <= 0x097F), isFalse,
              reason: kahan);
        }
      }
    });

    test('ⓘ: लंबाई, अर्थ का दावा, और फलश्रुति पर चिकित्सा वाली बात', () {
      final web = RegExp(r'https?://|www\.|\.com\b|\.org\b|\.in\b');
      for (final p in paath.values) {
        expect(p.strot.note.length, lessThanOrEqualTo(600), reason: p.id);
        expect(p.strot.note, contains('शब्दशः अनुवाद नहीं'), reason: p.id);
        expect(p.strot.note, isNot(matches(web)), reason: p.id);
        expect(p.jaanch.paas, isFalse, reason: p.id);
      }
      expect(paath['vishnusahasranama_03']!.strot.note,
          contains('कोई चिकित्सकीय वादा नहीं'));
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

    void lambaPhone(WidgetTester tester) {
      tester.view.physicalSize = const Size(400 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('कृष्ण पूजा के "पाठ" कदम पर गीता और सहस्रनाम, दोनों बटन',
        (tester) async {
      lambaPhone(tester);
      final v = await vidhiBhandar.vidhi('krishna_pooja');
      final index = v.charan.indexWhere((c) => c.granthSuchi.length == 2);
      expect(index, isNonNegative);
      await tester.pumpWidget(
        app(VidhiPlayerScreen(vidhi: v, initialStepIndex: index)),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(VidhivatButton, 'श्रीमद्भगवद्गीता'),
          findsOneWidget);
      expect(find.widgetWithText(VidhivatButton, 'श्री विष्णु सहस्रनाम'),
          findsOneWidget);

      await tester
          .tap(find.widgetWithText(VidhivatButton, 'श्री विष्णु सहस्रनाम'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('सहस्रनाम — एक हज़ार नाम'), findsOneWidget);
      expect(find.text('107 श्लोक'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('आरंभ वाले भाग में "13 श्लोक" — मंगलाचरण और ध्यान गिनती में नहीं',
        (tester) async {
      lambaPhone(tester);
      await tester
          .pumpWidget(app(const PaathScreen(id: 'vishnusahasranama_01')));
      await tester.pumpAndSettle();
      expect(find.text('13 श्लोक'), findsOneWidget);
      expect(find.text('मंगलाचरण १'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
