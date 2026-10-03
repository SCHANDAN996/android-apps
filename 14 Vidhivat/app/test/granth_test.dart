@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/granth.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

/// ग्रंथालय — श्रीमद्भगवद्गीता का पूरा पाठ ऐप में (→ D-098)।
///
/// पाठ चार अलग संस्करणों से मशीन द्वारा, श्लोक-दर-श्लोक मिलाया गया था
/// (ब्यौरा `docs/18_SROT_PANJI.md` में)। ये जाँचें उसी की पहरेदारी करती हैं
/// — कोई अध्याय छोटा न हो जाए, क्रम न बिगड़े, कोई अर्थ ख़ाली न रहे।
void main() {
  const dir = 'assets/granth';
  late List<GranthSuchiEntry> suchi;
  late GranthKram kram;
  late Map<String, Paath> paath;

  setUpAll(() {
    suchi = GranthSuchiEntry.parseAll(
        '$dir/_suchi.json', File('$dir/_suchi.json').readAsStringSync());
    kram = GranthKram.parse('$dir/gita/_kram.json',
        File('$dir/gita/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse('$dir/gita/${p.id}.json',
            File('$dir/gita/${p.id}.json').readAsStringSync()),
    };
  });

  Iterable<PaathKhand> shlok(Paath p) =>
      p.khand.where((k) => k.shirshak.startsWith('श्लोक'));

  group('ग्रंथालय की सूची', () {
    test('सूची और भंडार की ग्रंथ-सूची एक हैं', () {
      // सप्तशती `_suchi.json` में नहीं — उसका पाठ अपने पुराने फ़ोल्डर में
      // रहा और वह कोड में लिखी है।
      expect(
        {...suchi.map((g) => g.id), GranthSuchiEntry.saptashati.id},
        GranthBhandar.granthIds,
      );
    });

    test('हर ग्रंथ का फ़ोल्डर और क्रम मौजूद है', () {
      for (final id in GranthBhandar.granthIds) {
        final path = '${GranthBhandar.dirFor(id)}/_kram.json';
        final k = GranthKram.parse(path, File(path).readAsStringSync());
        expect(k.id, id, reason: path);
      }
    });

    test('पाठ की id से फ़ोल्डर तय होता है', () {
      expect(PaathBhandar.pathFor('gita_07'), '$dir/gita/gita_07.json');
      expect(PaathBhandar.pathFor('saptashati_05'),
          'assets/paath/saptashati/saptashati_05.json');
      expect(
          PaathBhandar.pathFor('hanuman_chalisa'),
          'assets/paath/hanuman_chalisa.json');
      expect(GranthBhandar.granthOf('gita_01'), 'gita');
      expect(GranthBhandar.granthOf('ganesh_aarti'), isNull);
    });

    test('ग़लत ग्रंथ की id वाला पाठ क्रम में नहीं चलेगा', () {
      const galat = '''
{"schemaVersion": 1, "id": "gita", "naam": "क", "parichay": "ख",
 "khand": [{"shirshak": "ग", "paath": [
   {"id": "saptashati_01", "naam": "घ", "ekLine": "च", "shlok": 3}]}]}''';
      expect(() => GranthKram.parse('x', galat),
          throwsA(isA<VidhiFormatException>()));
    });
  });

  group('श्रीमद्भगवद्गीता', () {
    test('अठारह अध्याय, क्रम से, तीन हिस्सों में', () {
      expect(kram.id, 'gita');
      expect(kram.kram.map((p) => p.id).toList(), [
        for (var n = 1; n <= 18; n++) 'gita_${n.toString().padLeft(2, '0')}',
      ]);
      expect(kram.hisse.map((h) => h.paath.length), [6, 6, 6]);
    });

    test('फ़ोल्डर की हर फ़ाइल क्रम में है, और क्रम का हर पाठ फ़ोल्डर में', () {
      final files = Directory('$dir/gita')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json') && n != '_kram.json')
          .map((n) => n.substring(0, n.length - 5))
          .toSet();
      expect(files, kram.kram.map((p) => p.id).toSet());
    });

    /// गीता की गिनती तय है — हर अध्याय की, और कुल सात सौ। यही गिनती
    /// `docs/29` में लिखी है और औज़ार (`banao_granth.py`) भी इसी पर रुकता है।
    test('हर अध्याय की श्लोक-गिनती, और कुल सात सौ', () {
      const ginti = [
        47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 34, 27, 20, 24, 28, 78,
      ];
      expect(ginti.fold<int>(0, (a, b) => a + b), 700);
      for (final (i, k) in kram.kram.indexed) {
        expect(k.shlok, ginti[i], reason: k.id);
        expect(shlok(paath[k.id]!).length, ginti[i], reason: k.id);
      }
    });

    test('क्रम में लिखा नाम फ़ाइल से मिलता है; हर अध्याय ग्रंथ वाला पाठ है', () {
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(p.id, k.id);
        expect(p.naam, k.naam, reason: k.id);
        expect(p.prakar, PaathPrakar.granth, reason: k.id);
        expect(p.parichay.trim(), isNotEmpty, reason: k.id);
      }
    });

    test('श्लोक क्रम से गिने हैं — देवनागरी अंकों में, बिना छूटे', () {
      const ank = '०१२३४५६७८९';
      String dev(int n) => n.toString().split('').map((d) => ank[int.parse(d)]).join();
      for (final p in paath.values) {
        final s = shlok(p).toList();
        for (final (i, k) in s.indexed) {
          expect(k.shirshak, 'श्लोक ${dev(i + 1)}', reason: p.id);
        }
      }
    });

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
          // रोमन में देवनागरी न बचे — कोई अक्षर औज़ार से छूट गया तो यहीं दिखे
          expect(k.roman.runes.any((r) => r >= 0x0900 && r <= 0x097F), isFalse,
              reason: kahan);
        }
      }
    });

    /// repo का चलन: नुक़्ता खुला हुआ (ज + ़)। जुड़ा हुआ रूप (U+095B…) आँख
    /// से वैसा ही दिखता है पर बराबर नहीं होता — `find.text` चुपचाप चूकता है।
    test('अर्थ और सार में नुक़्ता खुले रूप में है', () {
      // अक्षर यहाँ सीधे नहीं लिखे — अंकों से बनाए हैं, ताकि इस फ़ाइल का
      // नुक़्ता खोलने वाला औज़ार इसी नियम को न बिगाड़ दे।
      final juda = RegExp('[${String.fromCharCodes([
            for (var c = 0x0958; c <= 0x095F; c++) c,
            0x0929,
            0x0931,
            0x0934,
          ])}]');
      for (final p in paath.values) {
        expect(p.parichay, isNot(matches(juda)), reason: p.id);
        for (final k in p.khand) {
          expect(k.arth, isNot(matches(juda)), reason: '${p.id} ${k.shirshak}');
        }
      }
    });

    test('उनसठ जगह "उवाच" — श्रीभगवान २८, अर्जुन २१, संजय ९, धृतराष्ट्र १', () {
      final saare = paath.values.expand(shlok).map((k) => k.dev).toList();
      int kitne(String vakta) => saare
          .where((d) => d.split('\n').any((l) => l.trim() == vakta))
          .length;
      expect(kitne('श्रीभगवानुवाच'), 28);
      expect(kitne('अर्जुन उवाच'), 21);
      expect(kitne('सञ्जय उवाच'), 9);
      expect(kitne('धृतराष्ट्र उवाच'), 1);
    });

    test('पहला श्लोक धृतराष्ट्र का, आख़िरी संजय का', () {
      expect(shlok(paath['gita_01']!).first.dev,
          contains('धर्मक्षेत्रे कुरुक्षेत्रे'));
      expect(shlok(paath['gita_18']!).last.dev,
          contains('यत्र योगेश्वरः कृष्णो'));
    });

    test('जाने-पहचाने श्लोक अपनी जगह पर हैं', () {
      String s(String id, String shirshak) =>
          paath[id]!.khand.firstWhere((k) => k.shirshak == shirshak).dev;
      expect(s('gita_02', 'श्लोक ४७'), contains('कर्मण्येवाधिकारस्ते'));
      expect(s('gita_04', 'श्लोक ७'), contains('यदा यदा हि धर्मस्य'));
      expect(s('gita_09', 'श्लोक २६'), contains('पत्रं पुष्पं फलं तोयं'));
      expect(s('gita_18', 'श्लोक ६६'), contains('सर्वधर्मान्परित्यज्य'));
    });

    /// तेरहवाँ अध्याय "इदं शरीरं" से शुरू होता है — सात सौ वाला रूप। कुछ
    /// पुस्तकों में उससे पहले अर्जुन का एक श्लोक और है; ⓘ में यही लिखा है।
    test('तेरहवाँ अध्याय सात सौ वाली गिनती में है, और ⓘ यह बताता है', () {
      final p = paath['gita_13']!;
      expect(shlok(p).first.dev, contains('इदं शरीरं कौन्तेय'));
      expect(p.strot.note, contains('सात सौ एक'));
      // १३.१२ — जगह डालने से अर्थ एक ही मत का हो जाता है; पाठ बिना जगह के
      expect(
          p.khand.firstWhere((k) => k.shirshak == 'श्लोक १२').dev,
          contains('अनादिमत्परं'));
    });

    test('हर अध्याय अपने समापन-वाक्य पर ख़त्म होता है', () {
      for (final p in paath.values) {
        final ant = p.khand.last;
        expect(ant.shirshak, 'समापन', reason: p.id);
        expect(ant.dev, startsWith('ॐ तत्सदिति'), reason: p.id);
        expect(ant.dev, contains('ऽध्यायः'), reason: p.id);
        // नाम वही जो ऊपर अध्याय के नाम में है
        final naam = p.naam.split(' — ').last;
        expect(ant.dev, contains(naam), reason: p.id);
      }
    });

    test('ⓘ का नोट पढ़ने लायक़ लंबाई में है, और अर्थ का दावा सच्चा है', () {
      for (final p in paath.values) {
        expect(p.strot.note.length, lessThanOrEqualTo(600), reason: p.id);
        expect(p.strot.note, contains('शब्दशः अनुवाद नहीं'), reason: p.id);
        expect(p.jaanch.paas, isFalse, reason: p.id);
      }
    });
  });

  group('पूजा से ग्रंथ का रास्ता', () {
    test('कृष्ण पूजा का "पाठ" वाला कदम गीता खोलता है', () {
      const path = 'assets/vidhi/krishna_pooja.json';
      final v = Vidhi.parse(path, File(path).readAsStringSync());
      final kadam = v.charan.where((c) => c.granth.isNotEmpty).toList();
      expect(kadam, hasLength(1));
      expect(kadam.single.shirshak, 'पाठ');
      expect(kadam.single.granth, 'gita');
      // उसी कदम पर विष्णु सहस्रनाम भी (→ D-107)
      expect(kadam.single.granthSuchi, ['gita', 'vishnusahasranama']);
      // अब यह कहना झूठ होता कि गीता या सहस्रनाम ऐप में नहीं है
      expect(kadam.single.vivaran, contains('दोनों ऐप में हैं'));
      expect(kadam.single.vivaran, isNot(contains('इनका पूरा पाठ अभी ऐप में नहीं')));
      expect(kadam.single.vivaran, isNot(contains('सहस्रनाम अभी ऐप में नहीं')));
    });

    test('किसी भी पूजा में लिखा ग्रंथ ग्रंथालय में है', () {
      for (final f in Directory('assets/vidhi')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') && !f.path.endsWith('_suchi.json'))) {
        final v = Vidhi.parse(f.path, f.readAsStringSync());
        for (final c in v.charan) {
          for (final g in c.granthSuchi) {
            expect(GranthBhandar.granthIds, contains(g),
                reason: '${f.path} — ${c.shirshak}');
          }
        }
      }
    });
  });
}
