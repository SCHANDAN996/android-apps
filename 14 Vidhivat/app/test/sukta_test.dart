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
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// वेद के सूक्त — पुरुष सूक्त (ऋग्वेद और शुक्ल यजुर्वेद), नासदीय, श्री सूक्त
/// (→ D-108)। गवाह और मिलान `docs/18_SROT_PANJI.md` अध्याय २४ में।
void main() {
  const dir = 'assets/granth/sukta';
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

  String s(String id, String shirshak) =>
      paath[id]!.khand.firstWhere((k) => k.shirshak == shirshak).dev;

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है — गिनती "मंत्र" में', () {
      final suchi = GranthSuchiEntry.parseAll(GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'sukta');
      expect(g.naam, 'वेद के सूक्त');
      expect(g.ikai, 'सूक्त');
      expect(g.gintiNaam, 'मंत्र');
      expect(GranthBhandar.granthIds, contains('sukta'));
    });

    test('पाँच पाठ: सोलह, सोलह, बारह, सात और पंद्रह मंत्र', () {
      expect(kram.kram.map((p) => p.id), [
        'sukta_purusha',
        'sukta_purusha_yv',
        'sukta_narayana',
        'sukta_nasadiya',
        'sukta_shri',
      ]);
      expect([for (final p in kram.kram) mantra(paath[p.id]!).length],
          [16, 16, 12, 7, 15]);
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(k.shlok, mantra(p).length, reason: k.id);
        expect(p.naam, k.naam, reason: k.id);
        expect(p.bhasha, 'वैदिक संस्कृत', reason: k.id);
        // मंत्र क्रम से गिने हैं
        for (final (i, m) in mantra(p).indexed) {
          expect(m.shirshak, 'मंत्र ${dev(i + 1)}', reason: k.id);
        }
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

  group('पाठ', () {
    test('हर खंड भरा है; स्वर-चिह्न और अंग्रेज़ी अक्षर नहीं', () {
      // उदात्त-अनुदात्त की रेखाएँ और वैदिक चिह्न — ऐप बिना स्वर का पाठ देता है
      final swar = RegExp('[॒॑᳐-᳿꣠-ꣿ]');
      for (final p in paath.values) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.hasPath, isTrue, reason: kahan);
          expect(k.roman.trim(), isNotEmpty, reason: kahan);
          expect(k.arth.trim(), isNotEmpty, reason: kahan);
          expect(k.dev, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.dev, isNot(matches(swar)), reason: kahan);
          expect(k.arth, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.roman.runes.any((r) => r >= 0x0900 && r <= 0x097F), isFalse,
              reason: kahan);
        }
      }
    });

    test('पुरुष सूक्त: ऋग्वेद और यजुर्वेद के पाठ सचमुच अलग हैं', () {
      expect(s('sukta_purusha', 'मंत्र १'), contains('विश्वतो वृत्वा'));
      expect(s('sukta_purusha_yv', 'मंत्र १'), contains('सर्वत स्पृत्वा'));
      expect(s('sukta_purusha', 'मंत्र २'), contains('यच्च भव्यम्'));
      expect(s('sukta_purusha_yv', 'मंत्र २'), contains('यच्च भाव्यम्'));
      expect(s('sukta_purusha', 'मंत्र ५'), startsWith('तस्माद्विराळजायत'));
      expect(s('sukta_purusha_yv', 'मंत्र ५'), startsWith('ततो विराडजायत'));
      // क्रम: ऋग्वेद का छठा मंत्र यजुर्वेद में चौदहवाँ है
      expect(s('sukta_purusha', 'मंत्र ६'), startsWith('यत्पुरुषेण हविषा'));
      expect(s('sukta_purusha_yv', 'मंत्र १४'), startsWith('यत्पुरुषेण हविषा'));
      expect(s('sukta_purusha_yv', 'मंत्र १२'),
          contains('श्रोत्राद्वायुश्च प्राणश्च मुखादग्निरजायत'));
      // दोनों का आख़िरी मंत्र एक
      expect(s('sukta_purusha', 'मंत्र १६'), s('sukta_purusha_yv', 'मंत्र १६'));
    });

    test('यजुर्वेद वाले पाठ का अर्थ उसके अपने क्रम में है', () {
      String arth(String id, String sh) =>
          paath[id]!.khand.firstWhere((k) => k.shirshak == sh).arth;
      expect(arth('sukta_purusha_yv', 'मंत्र १४'),
          arth('sukta_purusha', 'मंत्र ६'));
      expect(arth('sukta_purusha_yv', 'मंत्र ६'),
          arth('sukta_purusha', 'मंत्र ८'));
      expect(arth('sukta_purusha_yv', 'मंत्र १२'), contains('कान से वायु'));
    });

    test('नासदीय और श्री सूक्त की पहचानी हुई पंक्तियाँ', () {
      expect(s('sukta_nasadiya', 'मंत्र १'),
          startsWith('नासदासीन्नो सदासीत्तदानीं'));
      expect(s('sukta_nasadiya', 'मंत्र ७'), contains('यदि वा न वेद'));
      expect(s('sukta_shri', 'मंत्र १'), startsWith('हिरण्यवर्णां हरिणीं'));
      expect(s('sukta_shri', 'मंत्र ३'), contains('श्रीर्मा देवीर्जुषताम्'));
      expect(s('sukta_shri', 'मंत्र ९'), startsWith('गन्धद्वारां दुराधर्षां'));
      expect(
          s('sukta_shri', 'मंत्र १५'), contains('प्रभूतं गावो दास्योऽश्वान्'));
      expect(paath['sukta_shri']!.khand.last.shirshak, 'फलश्रुति');
    });

    // → D-127: तैत्तिरीय आरण्यक का द्रविड़ पाठ, आनन्दाश्रम के छपे पन्नों से आँख से
    test('नारायण सूक्त: बारह मंत्र, और साथ बोले जाने वाले दो', () {
      final p = paath['sukta_narayana']!;
      expect(s('sukta_narayana', 'मंत्र १'), startsWith('सहस्रशीर्षं देवं विश्वाक्षं'));
      expect(s('sukta_narayana', 'मंत्र १२'), contains('स ब्रह्म स शिवः स हरिः सेन्द्रः'));
      expect(p.khand.map((k) => k.shirshak).skip(12),
          ['ऋतं सत्यम् — नमस्कार', 'नारायण गायत्री']);
      expect(p.khand.last.dev, contains('नारायणाय विद्महे वासुदेवाय धीमहि'));
      // जहाँ एक टंकित संग्रह अलग था — छपी पुस्तक और दूसरे संग्रह वाला रूप
      expect(s('sukta_narayana', 'मंत्र ७'), contains('वितस्त्यान्ते'));
      expect(s('sukta_narayana', 'मंत्र ७'), contains('भाती विश्वस्यायतनं'));
      expect(s('sukta_narayana', 'मंत्र ९'), contains('महानग्निर्विश्वार्चि'));
      expect(s('sukta_narayana', 'मंत्र ४'), contains('नारायण परं ब्रह्मतत्त्वं'));
      // आंध्र पाठ के शब्द नहीं घुसे
      for (final w in ['परमं प्रभुम्', 'वितस्त्यां तु', 'स ब्रह्मा स']) {
        expect(p.khand.map((k) => k.dev).join(' '), isNot(contains(w)), reason: w);
      }
      expect(p.strot.note, contains('दूसरी परंपरा है'));
      expect(p.strot.note, contains('आंध्र पाठ'));
    });

    test('ⓘ: लंबाई; वर्ण वाले मंत्र और समृद्धि वाले सूक्त पर खुली बात', () {
      final web = RegExp(r'https?://|www\.|\.com\b|\.org\b|\.in\b');
      for (final p in paath.values) {
        expect(p.strot.note.length, lessThanOrEqualTo(600), reason: p.id);
        expect(p.strot.note, isNot(matches(web)), reason: p.id);
        expect(p.jaanch.paas, isFalse, reason: p.id);
      }
      expect(paath['sukta_purusha']!.strot.note, contains('यह रूपक है'));
      expect(paath['sukta_purusha_yv']!.strot.note, contains('यह रूपक है'));
      expect(paath['sukta_shri']!.strot.note,
          contains('ऐप किसी फल का वादा नहीं करता'));
    });
  });

  group('पूजा से रास्ता', () {
    test('लक्ष्मी पूजन का "महालक्ष्मी पूजन" कदम सूक्त खोलता है', () {
      const path = 'assets/vidhi/lakshmi_poojan.json';
      final v = Vidhi.parse(path, File(path).readAsStringSync());
      final c = v.charan.singleWhere((c) => c.granth == 'sukta');
      expect(c.shirshak, 'महालक्ष्मी पूजन');
      expect(c.mantra!.vikalp, contains('वह ऐप में है'));
    });

    test('किसी पूजा में अब यह नहीं लिखा कि श्रीसूक्त ऐप में नहीं आया', () {
      for (final f in Directory('assets/vidhi')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))) {
        expect(f.readAsStringSync(),
            isNot(contains('श्रीसूक्त इस पूजा का बड़ा पाठ है, वह अभी')),
            reason: f.path);
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

    void lambaPhone(WidgetTester tester) {
      tester.view.physicalSize = const Size(400 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('लक्ष्मी पूजन से "वेद के सूक्त" → श्री सूक्त; गिनती मंत्र में',
        (tester) async {
      lambaPhone(tester);
      final v = await vidhiBhandar.vidhi('lakshmi_poojan');
      final index = v.charan.indexWhere((c) => c.granth == 'sukta');
      await tester.pumpWidget(
        app(VidhiPlayerScreen(vidhi: v, initialStepIndex: index)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(VidhivatButton, 'वेद के सूक्त'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('श्री सूक्त'), findsOneWidget);
      expect(find.text('15 मंत्र'), findsOneWidget);
      expect(find.text('16 मंत्र'), findsNWidgets(2));

      await tester.tap(find.text('श्री सूक्त'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      // पुरुष (दो पाठ), नारायण, नासदीय, श्री — श्री पाँचवाँ
      expect(find.text('सूक्त · सूक्त 5/5'), findsOneWidget);
      expect(find.text('15 मंत्र'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
