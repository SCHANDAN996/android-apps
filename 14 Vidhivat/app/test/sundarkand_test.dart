import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/granth_screen.dart';
import 'package:vidhivat/screens/granthalaya_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// सुंदरकांड — श्रीरामचरितमानस का पाँचवाँ सोपान, बारह प्रसंगों में (→ D-106)।
///
/// पाठ एक खुले डिजिटल पाठ से लिया गया और पाँच छपी पुस्तकों से पंक्ति-दर-पंक्ति
/// मिलाया गया (ब्यौरा `docs/18_SROT_PANJI.md` अध्याय २२)। ये जाँचें उसी की
/// पहरेदारी करती हैं — कोई दोहा न छूटे, गिनती न बिगड़े, कोई अर्थ ख़ाली न रहे।
void main() {
  const dir = 'assets/granth/sundarkand';
  const ank = '०१२३४५६७८९';
  String dev(int n) =>
      n.toString().split('').map((d) => ank[int.parse(d)]).join();

  late GranthKram kram;
  late Map<String, Paath> paath;
  late List<PaathKhand> saare;

  setUpAll(() {
    kram = GranthKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse(
            '$dir/${p.id}.json', File('$dir/${p.id}.json').readAsStringSync()),
    };
    saare = [for (final p in kram.kram) ...paath[p.id]!.khand];
  });

  group('ढाँचा', () {
    test('ग्रंथालय की सूची में है — प्रसंग और पद के नाम से', () {
      final suchi = GranthSuchiEntry.parseAll(
          GranthBhandar.suchiPath,
          File(GranthBhandar.suchiPath).readAsStringSync());
      final g = suchi.singleWhere((g) => g.id == 'sundarkand');
      expect(g.naam, 'सुंदरकांड');
      expect(g.ikai, 'प्रसंग');
      expect(g.khandIkai, 'पद');
      expect(g.gintiNaam, 'पद');
      // गीता में यह खाना नहीं लिखा — वहाँ पुराना "श्लोक" ही रहे
      expect(suchi.singleWhere((g) => g.id == 'gita').gintiNaam, 'श्लोक');
      expect(GranthSuchiEntry.saptashati.gintiNaam, 'श्लोक');
    });

    test('बारह प्रसंग, क्रम से, चार हिस्सों में', () {
      expect(kram.id, 'sundarkand');
      expect(kram.kram.map((p) => p.id).toList(), [
        for (var n = 1; n <= 12; n++)
          'sundarkand_${n.toString().padLeft(2, '0')}',
      ]);
      expect(kram.hisse.map((h) => h.paath.length), [4, 3, 2, 3]);
      expect(PaathBhandar.pathFor('sundarkand_05'),
          '$dir/sundarkand_05.json');
    });

    test('फ़ोल्डर की हर फ़ाइल क्रम में है, और क्रम का हर पाठ फ़ोल्डर में', () {
      final files = Directory(dir)
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json') && n != '_kram.json')
          .map((n) => n.substring(0, n.length - 5))
          .toSet();
      expect(files, kram.kram.map((p) => p.id).toSet());
    });

    test('क्रम में लिखा नाम और गिनती फ़ाइल से मिलते हैं', () {
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(p.naam, k.naam, reason: k.id);
        expect(p.khandKul, k.shlok, reason: k.id);
        expect(p.prakar, PaathPrakar.granth, reason: k.id);
        expect(p.bhasha, 'अवधी', reason: k.id);
        expect(p.jaanch.paas, isFalse, reason: k.id);
      }
    });
  });

  group('गिनती', () {
    int kitne(String shuru) =>
        saare.where((k) => k.shirshak.startsWith(shuru)).length;

    test('तीन श्लोक, बासठ दोहे, एक सोरठा, छह छंद — कुल 344 पद', () {
      expect(saare, hasLength(344));
      expect(kitne('श्लोक'), 3);
      expect(kitne('दोहा'), 62);
      expect(kitne('सोरठा'), 1);
      expect(kitne('छंद'), 6);
      expect(kitne('चौपाई'), 271);
      expect(kitne('समापन'), 1);
    });

    /// साठ इकाइयाँ: हर एक चौपाइयों से शुरू होकर अपने दोहे पर पूरी होती है।
    /// बारहवीं का दोहा नहीं, सोरठा है; ३९, ४९ और ५६ में दो-दो दोहे (क, ख)।
    test('दोहा १ से ६० — क्रम से, कोई छूटा नहीं', () {
      final dohe = saare
          .where((k) =>
              k.shirshak.startsWith('दोहा') || k.shirshak.startsWith('सोरठा'))
          .map((k) => k.shirshak)
          .toList();
      expect(dohe, [
        for (var n = 1; n <= 60; n++)
          if (n == 12)
            'सोरठा ${dev(n)}'
          else if (n == 39 || n == 49 || n == 56) ...[
            'दोहा ${dev(n)} (क)',
            'दोहा ${dev(n)} (ख)',
          ] else
            'दोहा ${dev(n)}',
      ]);
    });

    test('हर दोहे से पहले उसकी चौपाइयाँ — १, २, ३ … बिना छूटे', () {
      var doha = 1;
      var agli = 1;
      for (final k in saare) {
        final s = k.shirshak;
        if (s.startsWith('चौपाई')) {
          expect(s, 'चौपाई ${dev(doha)}.${dev(agli)}');
          agli++;
        } else if (s.startsWith('दोहा') || s.startsWith('सोरठा')) {
          expect(agli, greaterThan(1), reason: '$s से पहले चौपाई नहीं');
          if (!s.endsWith('(क)')) {
            doha++;
            agli = 1;
          }
        }
      }
      expect(doha, 61);
    });

    /// पुस्तक में चौपाई की एक पंक्ति «अ। ब॥» होती है; ऐप में वह यति पर दो
    /// पंक्तियों में है। गिनती «॥» पर ख़त्म होने वाली पंक्तियों की।
    test('छपी पुस्तकों वाली गिनती: चौपाइयों की 526 पंक्तियाँ', () {
      final panktiyan = saare
          .where((k) => k.shirshak.startsWith('चौपाई'))
          .expand((k) => k.dev.split('\n'))
          .where((x) => x.endsWith('॥'))
          .toList();
      expect(panktiyan, hasLength(526));
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
          expect(k.shirshak, isNot(matches(RegExp('[A-Za-z0-9]'))),
              reason: kahan);
          expect(k.roman.runes.any((r) => r >= 0x0900 && r <= 0x097F), isFalse,
              reason: kahan);
          expect(k.dev.split('\n').length, k.roman.split('\n').length,
              reason: kahan);
        }
      }
    });

    test('विराम नियम से: चौपाई «अ। / ब॥», दोहे की पहली पंक्ति «।», दूसरी «॥»', () {
      for (final k in saare) {
        final l = k.dev.split('\n');
        if (k.shirshak.startsWith('चौपाई')) {
          // हर पंक्ति यति पर टूटी हुई: आधा «।» पर, आधा «॥» पर — और बीच में कोई
          // विराम नहीं
          expect(l.length.isEven, isTrue, reason: k.shirshak);
          for (final (i, x) in l.indexed) {
            expect(x.endsWith(i.isEven ? '।' : '॥'), isTrue,
                reason: '${k.shirshak}: $x');
            expect(RegExp('[।॥]').allMatches(x).length, 1,
                reason: '${k.shirshak}: $x');
          }
        } else if (k.shirshak.startsWith('दोहा') ||
            k.shirshak.startsWith('सोरठा')) {
          expect(l, hasLength(2), reason: k.shirshak);
          expect(l[0].endsWith('।'), isTrue, reason: k.shirshak);
          expect(l[1].endsWith('॥'), isTrue, reason: k.shirshak);
        } else if (k.shirshak.startsWith('छंद')) {
          expect(l, hasLength(4), reason: k.shirshak);
        }
      }
    });

    test('जानी-पहचानी पंक्तियाँ अपनी जगह पर हैं', () {
      String s(String id, String shirshak) =>
          paath[id]!.khand.firstWhere((k) => k.shirshak == shirshak).dev;
      expect(s('sundarkand_01', 'श्लोक ३'), contains('अतुलितबलधामं'));
      expect(s('sundarkand_01', 'चौपाई १.१'), startsWith('जामवंत के बचन सुहाए'));
      expect(s('sundarkand_01', 'दोहा १'),
          contains('राम काजु कीन्हें बिनु मोहि कहाँ बिश्राम'));
      expect(s('sundarkand_02', 'चौपाई ५.१'),
          startsWith('प्रबिसि नगर कीजे सब काजा'));
      expect(s('sundarkand_03', 'सोरठा १२'), startsWith('कपि करि हृदयँ बिचार'));
      expect(s('sundarkand_04', 'चौपाई १३.५'),
          startsWith('राम दूत मैं मातु जानकी'));
      expect(s('sundarkand_11', 'दोहा ५७'), contains('भय बिनु होइ न प्रीति'));
      expect(s('sundarkand_12', 'दोहा ६०'), startsWith('सकल सुमंगल दायक'));
      expect(paath['sundarkand_12']!.khand.last.dev, contains('पञ्चमः सोपानः'));
    });

    /// आधार के डिजिटल पाठ में छपाई की 108 भूलें पाँच छपी पुस्तकों से मिलाकर
    /// सुधारी गईं। ये कुछ ऐसी हैं जो लौट आएँ तो तुरंत दिखें।
    test('आधार की छपाई की भूलें लौटी नहीं', () {
      final sab = saare.map((k) => k.dev).join('\n');
      expect(sab, contains('सीता देहु राम कहुँ')); // "सीत देहु" नहीं
      expect(sab, contains('संधानेउ प्रभु')); // "संघानेउ" नहीं
      expect(sab, contains('निकट मृत्यु अब')); // "मुत्यु" नहीं
      expect(sab, contains('बिमल मयंका')); // "मंयका" नहीं
      expect(sab, contains('सुनु सुत तोहि उरिन मैं नाहीं'));
      expect(sab, contains('उर धरि प्रभु प्रभुताई'));
      expect(sab, isNot(contains('स्त्रव'))); // स्रवना = बहना
      expect(sab, isNot(contains('(क)')));
      expect(sab, isNot(contains('-')));
    });

    test('श्लोक और समापन का रोमन संस्कृत चाल में, बाक़ी अवधी चाल में', () {
      final p = paath['sundarkand_01']!;
      expect(p.khand[2].roman, contains('vaatajaatam namaami'));
      expect(
          p.khand.firstWhere((k) => k.shirshak == 'चौपाई १.१').roman,
          startsWith('jaamavant ke bachan suhaae |'));
      // शब्द के अंत का "अ" नहीं बोला जाता; अनुनासिक छूटता है
      expect(p.khand.firstWhere((k) => k.shirshak == 'दोहा १').roman,
          contains('raam kaaju keenhe binu mohi kahaan bishraam ||'));
    });

    test('अर्थ और परिचय में नुक़्ता खुले रूप में है', () {
      final juda = RegExp('[${String.fromCharCodes([
            for (var c = 0x0958; c <= 0x095F; c++) c,
            0x0929,
            0x0931,
            0x0934,
          ])}]');
      for (final p in paath.values) {
        expect(p.parichay, isNot(matches(juda)), reason: p.id);
        expect(p.kaisePadhein, isNot(matches(juda)), reason: p.id);
        for (final k in p.khand) {
          expect(k.arth, isNot(matches(juda)), reason: '${p.id} ${k.shirshak}');
        }
      }
    });
  });

  group('ⓘ', () {
    test('नोट पढ़ने लायक़ लंबाई में है, और अर्थ का दावा सच्चा है', () {
      final web = RegExp(r'https?://|www\.|\.com\b|\.org\b|\.in\b');
      for (final p in paath.values) {
        expect(p.strot.note.length, lessThanOrEqualTo(600), reason: p.id);
        expect(p.strot.note, contains('शब्दशः अनुवाद नहीं'), reason: p.id);
        expect(p.strot.note, contains('पाँच छपी पुस्तकों'), reason: p.id);
        expect(p.strot.note, isNot(matches(web)), reason: p.id);
      }
    });

    /// "ढोल गवाँर…" — ऐप पाठ नहीं बदलता, पर यह साफ़ कहता है कि यह कथा में
    /// समुद्र का कथन है और ऐप किसी के अपमान की सीख नहीं दे रहा।
    test('चौपाई ५९.३ का अर्थ और नोट बताते हैं कि यह समुद्र का कथन है', () {
      final p = paath['sundarkand_12']!;
      final k = p.khand.firstWhere((k) => k.shirshak == 'चौपाई ५९.३');
      expect(k.dev, contains('सकल ताड़ना के अधिकारी'));
      expect(k.arth, contains('समुद्र का अपना कथन'));
      expect(k.arth, contains('टीकाकार अलग-अलग'));
      expect(p.strot.note, contains('समुद्र का कथन'));
      expect(p.strot.note, contains('सीख नहीं दे रहा'));
    });
  });

  group('पूजा से सुंदरकांड का रास्ता', () {
    Charan kadam(String id) {
      final path = 'assets/vidhi/$id.json';
      final v = Vidhi.parse(path, File(path).readAsStringSync());
      return v.charan.singleWhere((c) => c.granth == 'sundarkand');
    }

    test('हनुमान पूजा का "पाठ" वाला कदम चालीसा और सुंदरकांड, दोनों खोलता है',
        () {
      final c = kadam('hanuman_pooja');
      expect(c.shirshak, 'पाठ');
      expect(c.paath, ['hanuman_chalisa']);
      // अब यह कहना झूठ होता कि सुंदरकांड ऐप में नहीं है
      expect(c.vivaran, isNot(contains('सुंदरकांड अभी ऐप में नहीं')));
      expect(c.vivaran, contains('बजरंग बाण अभी ऐप में नहीं है'));
    });

    test('राम पूजा का "पाठ" वाला कदम सुंदरकांड खोलता है', () {
      final c = kadam('ram_pooja');
      expect(c.shirshak, 'पाठ');
      expect(c.vivaran, isNot(contains('इनमें से कोई पाठ अभी ऐप में नहीं')));
      expect(c.vivaran, contains('सुंदरकांड ऐप में है'));
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
      tester.view.physicalSize = const Size(360 * 3, 6000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    Future<GranthSuchiEntry> entry() async =>
        (await granthBhandar.suchi()).singleWhere((g) => g.id == 'sundarkand');

    testWidgets('ग्रंथालय में दिखता है और दबाने पर बारह प्रसंग खुलते हैं',
        (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const GranthalayaScreen()));
      await tester.pumpAndSettle();

      expect(find.text('सुंदरकांड'), findsOneWidget);
      await tester.tap(find.text('सुंदरकांड'));
      await tester.pumpAndSettle();

      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('सीता जी की खोज'), findsOneWidget);
      expect(find.text('विभीषण और समुद्र'), findsOneWidget);
      expect(find.text('प्रसंग १ — समुद्र लाँघना'), findsOneWidget);
      expect(find.text('प्रसंग १२ — समुद्र की विनती और समापन'), findsOneWidget);
      // गिनती "पद" में — "श्लोक" यहाँ ग़लत होता
      expect(find.text('26 पद'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^[0-9]+ श्लोक')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('प्रसंग खुलता है, पट्टी "सुंदरकांड · प्रसंग" कहती है, अगला चलता है',
        (tester) async {
      lambaPhone(tester);
      final g = await tester.runAsync(entry);
      await tester.pumpWidget(app(GranthScreen(granth: g!)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('प्रसंग २ — लंका में प्रवेश, विभीषण से भेंट'));
      await tester.pumpAndSettle();

      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('सुंदरकांड · प्रसंग 2/12'), findsOneWidget);
      expect(find.textContaining('पद 1/25'), findsOneWidget);
      expect(find.text('25 पद'), findsOneWidget);
      expect(find.text('चौपाई ४.१'), findsOneWidget);
      expect(find.textContaining('मसक समान रूप कपि धरी'), findsOneWidget);

      await tester.tap(find.text('अगला'));
      await tester.pumpAndSettle();
      expect(find.text('सुंदरकांड · प्रसंग 3/12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('"अर्थ दिखाएँ" दबाने पर चौपाई का अर्थ और रोमन दिखते हैं',
        (tester) async {
      lambaPhone(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'sundarkand_02')));
      await tester.pumpAndSettle();

      const arth = 'मच्छर जितना छोटा रूप धरा';
      expect(find.textContaining(arth), findsNothing);
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();
      expect(find.textContaining(arth), findsOneWidget);
      expect(find.textContaining('masak samaan roop kapi dharee'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 चौड़ाई और 1.5 गुना अक्षर पर कुछ बाहर नहीं निकलता',
        (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final g = await tester.runAsync(entry);
      await tester.pumpWidget(app(GranthScreen(granth: g!)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // छोटी स्क्रीन पर सूची का पहला नाम भी नीचे है — सूची lazy है
      final naam = find.text('प्रसंग १ — समुद्र लाँघना');
      await tester.scrollUntilVisible(naam, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(naam);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('हनुमान पूजा के "पाठ" वाले कदम पर सुंदरकांड और चालीसा के बटन',
        (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 2600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final v = await vidhiBhandar.vidhi('hanuman_pooja');
      final index = v.charan.indexWhere((c) => c.granth == 'sundarkand');
      await tester.pumpWidget(
        app(VidhiPlayerScreen(vidhi: v, initialStepIndex: index)),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(VidhivatButton, 'सुंदरकांड'), findsOneWidget);
      expect(find.widgetWithText(VidhivatButton, 'श्री हनुमान चालीसा'),
          findsOneWidget);

      await tester.tap(find.widgetWithText(VidhivatButton, 'सुंदरकांड'));
      await tester.pumpAndSettle();
      expect(find.byType(GranthScreen), findsOneWidget);
      expect(find.text('प्रसंग १ — समुद्र लाँघना'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
