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

/// उपनिषद और शांति मंत्र (→ D-109)। गवाह और मिलान `docs/18_SROT_PANJI.md`
/// अध्याय २५ में।
void main() {
  const dir = 'assets/granth/upanishad';
  const ank = '०१२३४५६७८९';
  String dev(int n) =>
      n.toString().split('').map((d) => ank[int.parse(d)]).join();

  // पाठ → मंत्रों की गिनती, क्रम में। नया उपनिषद जुड़े तो यहीं जोड़ो।
  const ginti = <String, int>{
    'upanishad_isha': 18,
    'upanishad_kena': 35,
    'upanishad_katha_11': 29,
    'upanishad_katha_12': 25,
    'upanishad_katha_13': 17,
    'upanishad_katha_21': 15,
    'upanishad_katha_22': 15,
    'upanishad_katha_23': 18,
    'upanishad_prashna_1': 16,
    'upanishad_prashna_2': 13,
    'upanishad_prashna_3': 12,
    'upanishad_prashna_4': 11,
    'upanishad_prashna_5': 7,
    'upanishad_prashna_6': 8,
    'upanishad_mundaka_11': 9,
    'upanishad_mundaka_12': 13,
    'upanishad_mundaka_21': 10,
    'upanishad_mundaka_22': 11,
    'upanishad_mundaka_31': 10,
    'upanishad_mundaka_32': 11,
    'upanishad_mandukya': 12,
    'upanishad_shanti': 8,
  };

  // हर उपनिषद का पहला पाठ → उसका शांति पाठ, शांति मंत्रों के पन्ने वाला ही
  const shantiSe = <String, String>{
    'upanishad_isha': 'ॐ पूर्णमदः',
    'upanishad_kena': 'ॐ आप्यायन्तु',
    'upanishad_katha_11': 'ॐ सह नाववतु',
    'upanishad_prashna_1': 'ॐ भद्रं कर्णेभिः',
    'upanishad_mundaka_11': 'ॐ भद्रं कर्णेभिः',
    'upanishad_mandukya': 'ॐ भद्रं कर्णेभिः',
  };

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
      final g = suchi.singleWhere((g) => g.id == 'upanishad');
      expect(g.naam, 'उपनिषद');
      expect(g.ikai, 'भाग');
      expect(g.gintiNaam, 'मंत्र');
      expect(GranthBhandar.granthIds, contains('upanishad'));
    });

    test('पाठों का क्रम और हर एक में मंत्रों की गिनती', () {
      expect(kram.kram.map((p) => p.id), ginti.keys);
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(mantra(p).length, ginti[k.id], reason: k.id);
        expect(k.shlok, ginti[k.id], reason: k.id);
        expect(p.naam, k.naam, reason: k.id);
        expect(p.bhasha, 'संस्कृत', reason: k.id);
      }
      // कठ ११९, प्रश्न ६७, मुण्डक ६४
      int kul(String shuru) => ginti.entries
          .where((e) => e.key.startsWith(shuru))
          .fold(0, (a, e) => a + e.value);
      expect(kul('upanishad_katha_'), 119);
      expect(kul('upanishad_prashna_'), 67);
      expect(kul('upanishad_mundaka_'), 64);
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

    test('मंत्र क्रम से गिने हैं', () {
      for (final id in ginti.keys) {
        if (id == 'upanishad_kena' || id == 'upanishad_shanti') continue;
        for (final (i, m) in mantra(paath[id]!).indexed) {
          expect(m.shirshak, 'मंत्र ${dev(i + 1)}', reason: id);
        }
      }
      // केन: खंड.मंत्र — ९ + ५ + १२ + ९
      final kena = mantra(paath['upanishad_kena']!).map((k) => k.shirshak);
      expect(kena, [
        for (final (kh, n) in [(1, 9), (2, 5), (3, 12), (4, 9)])
          for (var i = 1; i <= n; i++) 'मंत्र ${dev(kh)}.${dev(i)}',
      ]);
    });
  });

  group('पाठ', () {
    test('हर खंड भरा है; स्वर-चिह्न और अंग्रेज़ी अक्षर नहीं', () {
      final swar = RegExp('[॒॑᳐-᳿꣠-ꣿ]');
      for (final p in paath.values) {
        for (final k in p.khand) {
          final kahan = '${p.id} ${k.shirshak}';
          expect(k.hasPath, isTrue, reason: kahan);
          expect(k.roman.trim(), isNotEmpty, reason: kahan);
          expect(k.arth.trim(), isNotEmpty, reason: kahan);
          expect(k.dev, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.dev, isNot(matches(swar)), reason: kahan);
          expect(k.dev, isNot(contains('  ')), reason: kahan);
          expect(k.dev.trimRight(), endsWith('॥'), reason: kahan);
          expect(k.arth, isNot(matches(RegExp('[A-Za-z0-9]'))), reason: kahan);
          expect(k.roman.runes.any((r) => r >= 0x0900 && r <= 0x097F), isFalse,
              reason: kahan);
        }
      }
    });

    test('अर्थ में बोलने वाले के उद्धरण-चिह्न जोड़े में हैं', () {
      for (final p in paath.values) {
        for (final k in p.khand) {
          expect('"'.allMatches(k.arth).length.isEven, isTrue,
              reason: '${p.id} ${k.shirshak}');
        }
      }
    });

    test('हर उपनिषद अपने शांति पाठ से खुलता है — वही जो शांति मंत्रों में है', () {
      final shanti = paath['upanishad_shanti']!;
      for (final e in shantiSe.entries) {
        final pehla = paath[e.key]!.khand.first;
        expect(pehla.shirshak, 'शांति पाठ', reason: e.key);
        final wahi =
            shanti.khand.singleWhere((k) => k.shirshak.endsWith('— ${e.value}'));
        expect(pehla.dev, wahi.dev, reason: e.key);
        expect(pehla.arth, wahi.arth, reason: e.key);
      }
      // बाक़ी पाठों में (उसी उपनिषद की अगली वल्ली/प्रश्न/खंड) शांति पाठ दोबारा नहीं
      for (final id in ginti.keys) {
        if (shantiSe.containsKey(id)) continue;
        expect(paath[id]!.khand.any((k) => k.shirshak == 'शांति पाठ'), isFalse,
            reason: id);
      }
      for (final k in shanti.khand) {
        expect(k.dev, endsWith('ॐ शान्तिः शान्तिः शान्तिः ॥'),
            reason: k.shirshak);
        expect(k.dev, startsWith('ॐ '), reason: k.shirshak);
      }
    });

    test('पहचानी हुई पंक्तियाँ', () {
      expect(s('upanishad_isha', 'मंत्र १'), startsWith('ॐ ईशा वास्यमिदं सर्वं'));
      expect(s('upanishad_isha', 'मंत्र १५'), startsWith('हिरण्मयेन पात्रेण'));
      expect(s('upanishad_isha', 'मंत्र १८'), startsWith('अग्ने नय सुपथा'));
      expect(s('upanishad_kena', 'मंत्र १.१'), startsWith('ॐ केनेषितं पतति'));
      expect(s('upanishad_kena', 'मंत्र ३.१२'), contains('हैमवतीं तां होवाच'));
      expect(s('upanishad_katha_11', 'मंत्र १'), startsWith('ॐ उशन् ह वै'));
      expect(s('upanishad_katha_12', 'मंत्र १८'), startsWith('न जायते म्रियते वा'));
      expect(s('upanishad_katha_13', 'मंत्र ३'),
          startsWith('आत्मानं रथिनं विद्धि'));
      expect(s('upanishad_katha_13', 'मंत्र १४'), startsWith('उत्तिष्ठत जाग्रत'));
      expect(s('upanishad_katha_23', 'मंत्र १'), startsWith('ऊर्ध्वमूलोऽवाक्शाख'));
      expect(s('upanishad_prashna_1', 'मंत्र १'), startsWith('ॐ सुकेशा च'));
      expect(s('upanishad_prashna_6', 'मंत्र ८'), endsWith('नमः परमऋषिभ्यः ॥'));
      expect(s('upanishad_mundaka_11', 'मंत्र ७'), startsWith('यथोर्णनाभिः'));
      expect(s('upanishad_mundaka_22', 'मंत्र ४'), startsWith('प्रणवो धनुः'));
      expect(s('upanishad_mundaka_31', 'मंत्र १'), startsWith('द्वा सुपर्णा'));
      expect(s('upanishad_mandukya', 'मंत्र १'),
          startsWith('ओमित्येतदक्षरमिदं सर्वं'));
      expect(s('upanishad_mandukya', 'मंत्र ७'),
          contains('शान्तं शिवमद्वैतं चतुर्थं मन्यन्ते'));
      expect(s('upanishad_shanti', 'मंत्र ८ — ॐ असतो मा सद्गमय'),
          contains('मृत्योर्माऽमृतं गमय'));
      expect(s('upanishad_shanti', 'मंत्र ५ — ॐ शं नो मित्रः'),
          contains('त्वामेव प्रत्यक्षं ब्रह्म वदिष्यामि'));
      // एक ही मंत्र दो उपनिषदों में — दोनों जगह एक पाठ
      expect(s('upanishad_katha_22', 'मंत्र १५'),
          s('upanishad_mundaka_22', 'मंत्र १०'));
      expect(s('upanishad_katha_22', 'मंत्र १५'), startsWith('न तत्र सूर्यो भाति'));
    });

    test('जहाँ गवाह बँटे थे, वहाँ बहुमत वाला पाठ है — और ⓘ कहता है', () {
      // केन २.१ और ४.२ — docs/18 §२५
      expect(s('upanishad_kena', 'मंत्र २.१'), contains('दभ्रमेवापि'));
      expect(s('upanishad_kena', 'मंत्र २.१'), isNot(contains('दहर')));
      expect(s('upanishad_kena', 'मंत्र ४.२'), contains('पस्पृशुस्ते'));
      expect(s('upanishad_kena', 'मंत्र ४.५'), contains('यदेतद्गच्छतीव'));
      expect(paath['upanishad_kena']!.strot.note, contains('दभ्रमेवापि'));
      expect(paath['upanishad_kena']!.strot.note, contains('पस्पृशुः'));
      // माण्डूक्य — संधि वाला रूप
      expect(s('upanishad_mandukya', 'मंत्र ६'), startsWith('एष सर्वेश्वर एष'));
      // कठ
      expect(s('upanishad_katha_21', 'मंत्र १२'),
          contains('ईशानो भूतभव्यस्य न ततो'));
      expect(s('upanishad_katha_21', 'मंत्र ५'),
          contains('ईशानं भूतभव्यस्य न ततो'));
      expect(s('upanishad_katha_23', 'मंत्र १०'), contains('न विचेष्टति'));
      expect(s('upanishad_katha_12', 'मंत्र २३'), contains('तनूं स्वाम्'));
      // प्रश्न — आधार की वर्तनी की भूलें नहीं बचीं
      expect(s('upanishad_prashna_1', 'मंत्र ३'), contains('कुतो ह वा'));
      expect(s('upanishad_prashna_4', 'मंत्र ७'),
          startsWith('स यथा सोम्य वयांसि वासोवृक्षं'));
      expect(s('upanishad_prashna_4', 'मंत्र ८'), contains('पादौ च गन्तव्यं'));
      expect(s('upanishad_prashna_2', 'मंत्र ११'), contains('प्राणैकर्षिरत्ता'));
      // मुण्डक — "सत्यमेव जयति", और ⓘ में "जयते" वाला पाठ भी बताया है
      expect(s('upanishad_mundaka_31', 'मंत्र ६'),
          startsWith('सत्यमेव जयति नानृतं'));
      expect(paath['upanishad_mundaka_31']!.strot.note,
          contains('सत्यमेव जयते'));
      expect(s('upanishad_mundaka_32', 'मंत्र ३'), contains('तनुं स्वाम्'));
      expect(s('upanishad_mundaka_11', 'मंत्र २'), contains('सत्यवहाय'));
    });

    test('ⓘ: लंबाई; कोई वेबसाइट नहीं; "किसी एक मत का भाष्य नहीं"', () {
      final web = RegExp(r'https?://|www\.|\.com\b|\.org\b|\.in\b');
      for (final p in paath.values) {
        expect(p.strot.note.length, lessThanOrEqualTo(600), reason: p.id);
        expect(p.strot.note, isNot(matches(web)), reason: p.id);
        expect(p.parichay, isNot(matches(web)), reason: p.id);
        expect(p.jaanch.paas, isFalse, reason: p.id);
        expect(p.kaisePadhein, contains('आचार्यों ने'), reason: p.id);
        if (p.id != 'upanishad_shanti') {
          expect(p.strot.note, contains('अपने शब्दों में'), reason: p.id);
        }
      }
      for (final id in [
        'upanishad_isha',
        'upanishad_katha_12',
        'upanishad_prashna_1',
        'upanishad_mundaka_11',
      ]) {
        expect(paath[id]!.strot.note, contains('किसी एक मत का भाष्य नहीं'),
            reason: id);
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

    testWidgets('ग्रंथ का पन्ना → केन उपनिषद; गिनती मंत्र में', (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final g =
          (await granthBhandar.suchi()).singleWhere((g) => g.id == 'upanishad');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();

      expect(find.text('ईशावास्य उपनिषद'), findsOneWidget);
      expect(find.text('35 मंत्र'), findsOneWidget);
      expect(find.text('कठ — कृष्ण यजुर्वेद'), findsOneWidget);
      expect(find.text('कठ — अध्याय १, वल्ली १'), findsOneWidget);

      await tester.tap(find.text('केन उपनिषद'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('उपनिषद · भाग 2/${ginti.length}'), findsOneWidget);
      expect(find.text('35 मंत्र'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('कठ की पहली वल्ली खुलती है — शांति पाठ सबसे ऊपर',
        (tester) async {
      tester.view.physicalSize = const Size(400 * 3, 3000 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final g =
          (await granthBhandar.suchi()).singleWhere((g) => g.id == 'upanishad');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('कठ — अध्याय १, वल्ली १'));
      await tester.pumpAndSettle();
      expect(find.text('उपनिषद · भाग 3/${ginti.length}'), findsOneWidget);
      expect(find.text('29 मंत्र'), findsOneWidget);
      expect(find.text('शांति पाठ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
