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

/// नौ उपनिषद और शांति मंत्र (→ D-109)। गवाह और मिलान `docs/18_SROT_PANJI.md`
/// अध्याय २५ में।
void main() {
  const dir = 'assets/granth/upanishad';
  const ank = '०१२३४५६७८९';
  String dev(int n) =>
      n.toString().split('').map((d) => ank[int.parse(d)]).join();

  // पाठ → मंत्रों (तैत्तिरीय में अनुवाकों) की गिनती, क्रम में।
  const ginti = <String, int>{
    'upanishad_isha': 18,
    'upanishad_kena': 34,
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
    'upanishad_tait_1': 12,
    'upanishad_tait_2': 9,
    'upanishad_tait_3': 10,
    'upanishad_aitareya_1': 23,
    'upanishad_aitareya_2': 6,
    'upanishad_aitareya_3': 4,
    'upanishad_shveta_1': 16,
    'upanishad_shveta_2': 17,
    'upanishad_shveta_3': 21,
    'upanishad_shveta_4': 22,
    'upanishad_shveta_5': 14,
    'upanishad_shveta_6': 23,
    'upanishad_shanti': 8,
  };

  // जिन पाठों का पहला खंड "शांति पाठ" है → शांति मंत्रों के पन्ने का वही मंत्र।
  // तैत्तिरीय की पहली वल्ली यहाँ नहीं — उसका पहला अनुवाक ही "शं नो मित्रः" है।
  const shantiSe = <String, String>{
    'upanishad_isha': 'ॐ पूर्णमदः',
    'upanishad_kena': 'ॐ आप्यायन्तु',
    'upanishad_katha_11': 'ॐ सह नाववतु',
    'upanishad_prashna_1': 'ॐ भद्रं कर्णेभिः',
    'upanishad_mundaka_11': 'ॐ भद्रं कर्णेभिः',
    'upanishad_mandukya': 'ॐ भद्रं कर्णेभिः',
    'upanishad_tait_2': 'ॐ सह नाववतु',
    'upanishad_tait_3': 'ॐ सह नाववतु',
    'upanishad_aitareya_1': 'ॐ वाङ् मे मनसि',
    'upanishad_shveta_1': 'ॐ सह नाववतु',
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

  bool anuvakWala(String id) => id.startsWith('upanishad_tait_');

  /// गिने जाने वाले खंड — मंत्र; तैत्तिरीय में अनुवाक।
  Iterable<PaathKhand> gine(Paath p) => p.khand.where((k) =>
      k.shirshak.startsWith(anuvakWala(p.id) ? 'अनुवाक' : 'मंत्र'));

  String s(String id, String shirshak) =>
      paath[id]!.khand.firstWhere((k) => k.shirshak == shirshak).dev;

  /// पंक्तियों का टूटना और विराम छोड़कर सिर्फ़ शब्द।
  String shabd(String t) => t
      .replaceAll(RegExp('[।॥ \n]'), ' ')
      .replaceAll(RegExp(' +'), ' ')
      .trim();

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

    test('पाठों का क्रम और हर एक की गिनती; नौ उपनिषदों का जोड़', () {
      expect(kram.kram.map((p) => p.id), ginti.keys);
      for (final k in kram.kram) {
        final p = paath[k.id]!;
        expect(gine(p).length, ginti[k.id], reason: k.id);
        expect(k.shlok, ginti[k.id], reason: k.id);
        expect(p.naam, k.naam, reason: k.id);
        expect(p.bhasha, 'संस्कृत', reason: k.id);
        // तैत्तिरीय अनुवाकों में गिना जाता है, बाक़ी मंत्रों में
        expect(k.gintiNaam, anuvakWala(k.id) ? 'अनुवाक' : isNull, reason: k.id);
      }
      int kul(String shuru) => ginti.entries
          .where((e) => e.key.startsWith(shuru))
          .fold(0, (a, e) => a + e.value);
      expect(kul('upanishad_katha_'), 119);
      expect(kul('upanishad_prashna_'), 67);
      expect(kul('upanishad_mundaka_'), 64);
      expect(kul('upanishad_tait_'), 31);
      expect(kul('upanishad_aitareya_'), 33);
      expect(kul('upanishad_shveta_'), 113);
      // दस हिस्से: नौ उपनिषद + शांति मंत्र
      expect(kram.hisse.length, 10);
      expect(kram.hisse.last.shirshak, 'शांति मंत्र');
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

    test('खंड क्रम से गिने हैं', () {
      const khandWale = {
        // «मंत्र खंड.मंत्र» — केन के चार खंड; ऐतरेय के पहले अध्याय के तीन
        'upanishad_kena': [(1, 8), (2, 5), (3, 12), (4, 9)],
        'upanishad_aitareya_1': [(1, 4), (2, 5), (3, 14)],
      };
      for (final id in ginti.keys) {
        if (id == 'upanishad_shanti') continue;
        final naam = gine(paath[id]!).map((k) => k.shirshak).toList();
        if (khandWale.containsKey(id)) {
          expect(naam, [
            for (final (kh, n) in khandWale[id]!)
              for (var i = 1; i <= n; i++) 'मंत्र ${dev(kh)}.${dev(i)}',
          ]);
        } else {
          final ikai = anuvakWala(id) ? 'अनुवाक' : 'मंत्र';
          expect(naam, [for (var i = 1; i <= naam.length; i++) '$ikai ${dev(i)}'],
              reason: id);
        }
      }
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
      PaathKhand wahi(String naam) =>
          shanti.khand.singleWhere((k) => k.shirshak.endsWith('— $naam'));
      for (final e in shantiSe.entries) {
        final pehla = paath[e.key]!.khand.first;
        expect(pehla.shirshak, 'शांति पाठ', reason: e.key);
        expect(pehla.dev, wahi(e.value).dev, reason: e.key);
        expect(pehla.arth, wahi(e.value).arth, reason: e.key);
      }
      // बाक़ी पाठों में (उसी उपनिषद की अगली वल्ली/प्रश्न/खंड) शांति पाठ दोबारा नहीं
      for (final id in ginti.keys) {
        if (shantiSe.containsKey(id)) continue;
        expect(paath[id]!.khand.any((k) => k.shirshak == 'शांति पाठ'), isFalse,
            reason: id);
      }
      // तैत्तिरीय की शीक्षा वल्ली का पहला अनुवाक ही "शं नो मित्रः" है — शब्द वही
      final tait = paath['upanishad_tait_1']!.khand.first;
      expect(tait.shirshak, 'अनुवाक १');
      expect(shabd(tait.dev), shabd(wahi('ॐ शं नो मित्रः').dev));
      // …और बारहवाँ उसी का भूतकाल वाला रूप
      expect(s('upanishad_tait_1', 'अनुवाक १२'),
          contains('त्वामेव प्रत्यक्षं ब्रह्मावादिषम्'));

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
      expect(s('upanishad_tait_1', 'अनुवाक ११'), contains('सत्यं वद'));
      expect(s('upanishad_tait_1', 'अनुवाक ११'), contains('मातृदेवो भव'));
      expect(s('upanishad_tait_2', 'अनुवाक १'), contains('सत्यं ज्ञानमनन्तं ब्रह्म'));
      expect(s('upanishad_tait_2', 'अनुवाक ९'), contains('यतो वाचो निवर्तन्ते'));
      expect(s('upanishad_tait_3', 'अनुवाक ६'),
          startsWith('आनन्दो ब्रह्मेति व्यजानात्'));
      expect(s('upanishad_aitareya_1', 'मंत्र १.१'), startsWith('ॐ आत्मा वा इदमेक'));
      expect(s('upanishad_aitareya_3', 'मंत्र ३'), endsWith('प्रज्ञानं ब्रह्म ॥'));
      expect(s('upanishad_shveta_1', 'मंत्र १'), startsWith('ॐ ब्रह्मवादिनो वदन्ति'));
      expect(s('upanishad_shveta_3', 'मंत्र ८'),
          startsWith('वेदाहमेतं पुरुषं महान्तम'));
      expect(s('upanishad_shveta_4', 'मंत्र ३'), startsWith('त्वं स्त्री त्वं पुमानसि'));
      expect(s('upanishad_shveta_6', 'मंत्र ११'),
          startsWith('एको देवः सर्वभूतेषु गूढः'));
      expect(s('upanishad_shanti', 'मंत्र ८ — ॐ असतो मा सद्गमय'),
          contains('मृत्योर्माऽमृतं गमय'));
      expect(s('upanishad_shanti', 'मंत्र ५ — ॐ शं नो मित्रः'),
          contains('त्वामेव प्रत्यक्षं ब्रह्म वदिष्यामि'));
      // एक ही मंत्र तीन उपनिषदों में — तीनों जगह एक पाठ
      final naTatra = s('upanishad_katha_22', 'मंत्र १५');
      expect(naTatra, startsWith('न तत्र सूर्यो भाति'));
      expect(s('upanishad_mundaka_22', 'मंत्र १०'), naTatra);
      expect(s('upanishad_shveta_6', 'मंत्र १४'), naTatra);
      // दो पक्षियों वाला मंत्र — मुण्डक और श्वेताश्वतर में
      expect(s('upanishad_shveta_4', 'मंत्र ६'),
          s('upanishad_mundaka_31', 'मंत्र १'));
    });

    test('जहाँ गवाह बँटे थे, वहाँ बहुमत वाला पाठ है — और ⓘ कहता है', () {
      // केन — docs/18 §२५
      expect(s('upanishad_kena', 'मंत्र १.३'),
          contains('यथैतदनुशिष्यादन्यदेव तद्विदितादथो'));
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
      // तैत्तिरीय
      expect(s('upanishad_tait_1', 'अनुवाक ५'), contains('सर्वे लोका महीयन्ते'));
      expect(s('upanishad_tait_1', 'अनुवाक १०'), contains('सुमेधा अमृतोक्षितः'));
      expect(s('upanishad_tait_2', 'अनुवाक ९'), contains('आत्मानं स्पृणुते'));
      // ऐतरेय
      expect(s('upanishad_aitareya_1', 'मंत्र ३.१०'), contains('यद्वायुरन्नायुर्वा एष'));
      expect(s('upanishad_aitareya_2', 'मंत्र २'), contains('आत्मभूयं'));
      // श्वेताश्वतर — दोनों छपे संस्करण जहाँ एक थे
      expect(s('upanishad_shveta_2', 'मंत्र ८'), endsWith('भयावहानि ॥'));
      expect(s('upanishad_shveta_3', 'मंत्र १३'), contains('हृदा मन्वीशो'));
      expect(s('upanishad_shveta_4', 'मंत्र १७'), contains('हृदा मनीषा'));
      expect(s('upanishad_shveta_3', 'मंत्र १७'), endsWith('शरणं बृहत् ॥'));
      expect(s('upanishad_shveta_4', 'मंत्र १०'), contains('मायिनं तु महेश्वरम्'));
      // …और जहाँ वे बँटे थे, वहाँ ⓘ दोनों रूप बताता है
      final shvetaNote = paath['upanishad_shveta_1']!.strot.note;
      expect(s('upanishad_shveta_6', 'मंत्र २'), contains('कालकारो'));
      expect(shvetaNote, contains('कालकालो'));
      expect(s('upanishad_shveta_1', 'मंत्र १५'), contains('दधिनीव'));
      expect(shvetaNote, contains('दधनीव'));
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
        'upanishad_tait_2',
        'upanishad_aitareya_3',
        'upanishad_shveta_4',
      ]) {
        expect(paath[id]!.strot.note, contains('किसी एक मत का भाष्य नहीं'),
            reason: id);
      }
      // योग के फल वाला अध्याय — ऐप फल का वादा नहीं करता
      expect(paath['upanishad_shveta_2']!.strot.note,
          contains('ऐप किसी फल का वादा नहीं करता'));
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

    Future<void> granthKholo(WidgetTester tester) async {
      lambaPhone(tester);
      final g =
          (await granthBhandar.suchi()).singleWhere((g) => g.id == 'upanishad');
      await tester.pumpWidget(app(GranthScreen(granth: g)));
      await tester.pumpAndSettle();
    }

    testWidgets('ग्रंथ का पन्ना → केन उपनिषद; गिनती मंत्र में', (tester) async {
      await granthKholo(tester);

      expect(find.text('ईशावास्य उपनिषद'), findsOneWidget);
      expect(find.text('34 मंत्र'), findsOneWidget);
      expect(find.text('कठ — कृष्ण यजुर्वेद'), findsOneWidget);
      expect(find.text('कठ — अध्याय १, वल्ली १'), findsOneWidget);

      await tester.tap(find.text('केन उपनिषद'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('उपनिषद · भाग 2/${ginti.length}'), findsOneWidget);
      expect(find.text('34 मंत्र'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('कठ की पहली वल्ली खुलती है — शांति पाठ सबसे ऊपर', (tester) async {
      await granthKholo(tester);
      await tester.tap(find.text('कठ — अध्याय १, वल्ली १'));
      await tester.pumpAndSettle();
      expect(find.text('उपनिषद · भाग 3/${ginti.length}'), findsOneWidget);
      expect(find.text('29 मंत्र'), findsOneWidget);
      expect(find.text('शांति पाठ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('तैत्तिरीय की गिनती "अनुवाक" में — सूची में भी, पन्ने पर भी',
        (tester) async {
      await granthKholo(tester);
      final shiksha = find.text('तैत्तिरीय — शीक्षा वल्ली');
      await tester.scrollUntilVisible(shiksha, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text('12 अनुवाक'), findsOneWidget);
      expect(find.text('12 मंत्र'), findsOneWidget); // माण्डूक्य

      await tester.tap(shiksha);
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
      expect(find.text('उपनिषद · भाग 22/${ginti.length}'), findsOneWidget);
      expect(find.text('12 अनुवाक'), findsOneWidget);
      expect(find.textContaining('अनुवाक 1/'), findsOneWidget);
      expect(find.text('शांति पाठ'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
