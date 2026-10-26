import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/paath_assets.dart';
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// रुद्राष्टाध्यायी — शुक्ल यजुर्वेद के आठ अध्याय (→ D-156)। हर मंत्र दो छपी
/// पुस्तकों (गीताप्रेस, «शिवपूजा विधि — रुद्री सहित») के पन्नों से; लट्ठा
/// `tools/granth_paath/rudri/00_PADHIYE.md`।
void main() {
  const dir = 'assets/granth/rudri';
  const ank = '०१२३४५६७८९';
  String dev(int n) =>
      n.toString().split('').map((d) => ank[int.parse(d)]).join();

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

  Iterable<PaathKhand> mantra(Paath p) =>
      p.khand.where((k) => k.shirshak.startsWith('मंत्र'));

  String s(int adhyay, int n) => paath['rudri_adhyay$adhyay']!
      .khand
      .firstWhere((k) => k.shirshak == 'मंत्र ${dev(n)}')
      .dev;

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है — गिनती "मंत्र" में', () {
      final suchi = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'rudri');
      expect(g.naam, 'रुद्राष्टाध्यायी');
      expect(g.ikai, 'अध्याय');
      expect(g.gintiNaam, 'मंत्र');
      expect(GranthBhandar.granthIds, contains('rudri'));
      expect(GranthBhandar.granthOf('rudri_adhyay5'), 'rudri');
    });

    test('आठ अध्याय, 176 मंत्र — हर अध्याय की गिनती संहिता वाली', () {
      expect(kram.kram.map((p) => p.id),
          [for (var i = 1; i <= 8; i++) 'rudri_adhyay$i']);
      expect([for (final p in kram.kram) mantra(paath[p.id]!).length],
          [10, 22, 17, 17, 66, 8, 7, 29]);
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(k.shlok, mantra(p).length, reason: k.id);
        expect(p.bhasha, 'वैदिक संस्कृत', reason: k.id);
        for (final (i, m) in mantra(p).indexed) {
          expect(m.shirshak, 'मंत्र ${dev(i + 1)}', reason: k.id);
        }
      }
    });

    test('ग्रंथालय में चित्र — रुद्राभिषेक वाला, दीया नहीं', () {
      final a = PaathAssets.forGranthId('rudri').assetPath;
      expect(a, isNot(contains('diya')));
      expect(File(a).existsSync(), isTrue);
    });
  });

  group('पाठ', () {
    test('हर खंड भरा है; स्वर-चिह्न, निजी glyph और अंग्रेज़ी अक्षर नहीं', () {
      final swar = RegExp('[॒॑᳐-᳿꣠-ꣿ-]');
      for (final p in paath.values) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.roman.trim(), isNotEmpty, reason: kahan);
          expect(k.arth.trim(), isNotEmpty, reason: kahan);
          expect(k.dev, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.dev, isNot(matches(swar)), reason: kahan);
          // प्लुत/अनुनासिक का अंक (लोकाँ२) ऐप में नहीं
          expect(k.dev, isNot(contains('२')), reason: kahan);
          expect(k.arth, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
        }
      }
    });

    test('पहचानी हुई पंक्तियाँ — छपी पुस्तकों वाले रूप', () {
      expect(s(1, 1), startsWith('गणानां त्वा गणपतिं हवामहे'));
      expect(s(1, 5), contains('तन्मे मनः शिवसङ्कल्पमस्तु'));
      expect(s(1, 9), contains('यजूंषि')); // डिजिटल में निजी glyph था
      expect(s(2, 18), startsWith('वेदाहमेतं पुरुषं महान्तमादित्यवर्णं'));
      expect(s(3, 5),
          startsWith('बलविज्ञाय स्थविरः')); // दोनों छपी में विसर्ग नहीं
      expect(s(5, 1), startsWith('नमस्ते रुद्र मन्यव'));
      expect(s(5, 41), contains('नमः शिवाय च शिवतराय च'));
      expect(s(6, 5), startsWith('त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्'));
      expect(s(8, 1), startsWith('वाजश्च मे'));
      expect(s(8, 15), startsWith('वसु च मे')); // डिजिटल की टंकण-भूल «चे»
      expect(s(8, 19), endsWith('यज्ञेन कल्पन्ताम्॥'));
    });

    test('ⓘ में वे बातें जो पाठ के साथ कहनी हैं', () {
      expect(paath['rudri_adhyay2']!.strot.note, contains('यह रूपक है'));
      expect(paath['rudri_adhyay5']!.strot.note,
          contains('किसी व्यक्ति के विरुद्ध नहीं'));
      expect(paath['rudri_adhyay8']!.strot.note, contains('(न॰)'));
      for (final p in paath.values) {
        expect(p.strot.note, contains('छपी'), reason: p.id);
      }
    });
  });

  group('पूजा से रास्ता', () {
    test('रुद्राभिषेक का «जल से अभिषेक» कदम रुद्राष्टाध्यायी खोलता है', () {
      const path = 'assets/vidhi/rudrabhishek.json';
      final v = Vidhi.parse(path, File(path).readAsStringSync());
      final c = v.charan.singleWhere((c) => c.granth == 'rudri');
      expect(c.shirshak, 'जल से अभिषेक');
      // अब यह कहना झूठ होता कि पाठ ऐप में नहीं है
      expect(v.parichay, contains('अब ऐप के ग्रंथालय में है'));
      expect(v.parichay, isNot(contains('वो पाठ इस ऐप में नहीं है')));
    });

    testWidgets('कदम से ग्रंथ खुलता है — आठ अध्याय दिखते हैं', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
      tester.view.physicalSize = const Size(400 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final v = await vidhiBhandar.vidhi('rudrabhishek');
      final index = v.charan.indexWhere((c) => c.granth == 'rudri');
      await tester.pumpWidget(ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          theme: VidhivatTheme.dark(),
          home: VidhiPlayerScreen(vidhi: v, initialStepIndex: index),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(VidhivatButton, 'रुद्राष्टाध्यायी'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('66 मंत्र'), findsOneWidget);
      expect(find.text('29 मंत्र'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
