@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/saptashati.dart';

/// दुर्गा सप्तशती — पूरा पाठ ऐप में (→ D-084)।
///
/// पाठ दो स्वतंत्र संस्करणों से मशीन द्वारा मिलाया गया था (अक्षर-स्तर पर
/// लगभग ९९% मेल)। ये जाँचें उसी की पहरेदारी करती हैं — कोई अध्याय छोटा न
/// हो जाए, क्रम न बिगड़े, और यह पाठ ऐप के पुराने दावों से मेल खाता रहे।
void main() {
  const dir = 'assets/paath/saptashati';
  late SaptashatiKram kram;
  late Map<String, Paath> paath;

  setUpAll(() {
    kram = SaptashatiKram.parse(
        '$dir/_kram.json', File('$dir/_kram.json').readAsStringSync());
    paath = {
      for (final p in kram.kram)
        p.id: Paath.parse('$dir/${p.id}.json',
            File('$dir/${p.id}.json').readAsStringSync()),
    };
  });

  test('क्रम: कवच, अर्गला, कीलक, फिर तेरह अध्याय', () {
    expect(kram.kram.map((p) => p.id).toList(), [
      'saptashati_kavach',
      'saptashati_argala',
      'saptashati_keelak',
      for (var n = 1; n <= 13; n++) 'saptashati_${n.toString().padLeft(2, '0')}',
    ]);
    expect(kram.hisse.map((h) => h.shirshak), [
      'पाठ से पहले',
      'प्रथम चरित्र — महाकाली',
      'मध्यम चरित्र — महालक्ष्मी',
      'उत्तम चरित्र — महासरस्वती',
    ]);
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

  test('पाठ भंडार इन्हें सही फ़ोल्डर में ढूँढता है', () {
    expect(PaathBhandar.pathFor('saptashati_05'), '$dir/saptashati_05.json');
    expect(PaathBhandar.pathFor('durga_aarti'), 'assets/paath/durga_aarti.json');
  });

  test('क्रम में लिखा नाम और श्लोक-गिनती फ़ाइल से मिलती है', () {
    for (final k in kram.kram) {
      final p = paath[k.id]!;
      expect(p.naam, k.naam, reason: k.id);
      expect(p.khand.where((x) => x.shirshak.startsWith('श्लोक')).length,
          k.shlok,
          reason: k.id);
    }
  });

  test('हर अध्याय में उतनी ही इकाइयाँ जितनी स्रोत में — कोई छूटी नहीं', () {
    const ginti = [104, 69, 44, 42, 85, 24, 27, 63, 41, 32, 55, 41, 29];
    for (var n = 1; n <= 13; n++) {
      final id = 'saptashati_${n.toString().padLeft(2, '0')}';
      expect(kram.kram.firstWhere((p) => p.id == id).shlok, ginti[n - 1],
          reason: id);
    }
    expect(ginti.fold<int>(0, (a, b) => a + b), 656);
  });

  test('हर खंड भरा है — देवनागरी और रोमन दोनों, कोई अंग्रेज़ी अक्षर नहीं', () {
    for (final p in paath.values) {
      expect(p.parichay.trim(), isNotEmpty, reason: p.id);
      for (final k in p.khand) {
        expect(k.hasPath, isTrue, reason: '${p.id} ${k.shirshak}');
        expect(k.roman.trim(), isNotEmpty, reason: '${p.id} ${k.shirshak}');
        expect(k.dev, isNot(matches(RegExp('[A-Za-z]'))),
            reason: '${p.id} ${k.shirshak}');
        expect(k.shirshak, isNot(matches(RegExp('[0-9]'))),
            reason: '${p.id} ${k.shirshak}');
      }
    }
  });

  /// हर श्लोक का सरल हिंदी अर्थ (→ D-085)। कोई खंड बिना अर्थ के न रहे,
  /// और अर्थ में अंग्रेज़ी अक्षर या अंक न घुसें।
  test('हर खंड का हिंदी अर्थ है', () {
    for (final p in paath.values) {
      for (final k in p.khand) {
        expect(k.arth.trim(), isNotEmpty, reason: '${p.id} ${k.shirshak}');
        expect(k.arth, isNot(matches(RegExp('[A-Za-z0-9]'))),
            reason: '${p.id} ${k.shirshak}');
      }
    }
  });

  /// जो श्लोक सप्तश्लोकी में भी हैं, उनका अर्थ दोनों जगह एक रहे।
  test('सप्तश्लोकी वाले श्लोकों का अर्थ दोनों जगह एक', () {
    final sapta = Paath.parse(
        'assets/paath/saptashloki_durga.json',
        File('assets/paath/saptashloki_durga.json').readAsStringSync());
    final saare = paath.values.expand((p) => p.khand).toList();
    for (final s in sapta.khand.skip(1)) {
      // पंक्तियाँ दोनों जगह अलग ढंग से टूटी हैं — ख़ाली जगह हटाकर मिलाओ
      String saaf(String x) => x.replaceAll(RegExp(r'\s'), '');
      final pehli = saaf(s.dev).substring(0, 20);
      final mile =
          saare.where((k) => saaf(k.dev).startsWith(pehli)).toList();
      expect(mile, isNotEmpty, reason: pehli);
      expect(mile.first.arth, s.arth, reason: pehli);
    }
  });

  test('"या देवी सर्वभूतेषु" के इक्कीसों रूप अलग-अलग, पूरे', () {
    final roop = paath['saptashati_05']!
        .khand
        .where((k) => k.dev.contains('या देवी सर्वभूतेषु'))
        .toList();
    expect(roop.length, 21);
    for (final k in roop) {
      expect(k.dev, contains('नमस्तस्यै नमस्तस्यै नमस्तस्यै नमो नमः'));
    }
  });

  /// ऐप का पुराना दावा (D-071): नवदुर्गा के नौ नाम **देवी कवच के श्लोक
  /// ३–५** में हैं। कवच अब ऐप में है — दावा उसी से पक्का रहे।
  test('नवदुर्गा के नौ नाम कवच के श्लोक ३–५ में', () {
    final kavach = paath['saptashati_kavach']!.khand;
    final teen = kavach
        .where((k) => ['श्लोक ३', 'श्लोक ४', 'श्लोक ५'].contains(k.shirshak))
        .map((k) => k.dev)
        .join(' ');
    for (final naam in ['शैलपुत्री', 'ब्रह्मचारिणी', 'चन्द्रघण्ट',
        'कूष्माण्ड', 'स्कन्दमात', 'कात्यायनी', 'कालरात्रि', 'महागौरी',
        'सिद्धिदात्री']) {
      expect(teen, contains(naam), reason: naam);
    }
  });

  /// नवरात्रि की विधियों का "सर्वमङ्गलमाङ्गल्ये" (D-081 में कहा: नारायणी
  /// स्तुति वाले अध्याय का श्लोक) — ग्यारहवें अध्याय में सचमुच है।
  test('"सर्वमङ्गलमाङ्गल्ये" ग्यारहवें अध्याय में है', () {
    final g = paath['saptashati_11']!.khand.map((k) => k.dev).join(' ');
    expect(g, contains('सर्वमङ्गलमाङ्गल्ये'));
    expect(g, contains('नारायणि नमोऽस्तु ते'));
  });

  test('पहला अध्याय मार्कण्डेय ऋषि के वचन से शुरू, तेरहवाँ वरदान पर', () {
    final pehla = paath['saptashati_01']!.khand;
    expect(pehla.first.shirshak, 'ध्यान');
    expect(pehla[1].dev, contains('मार्कण्डेय उवाच'));
    expect(paath['saptashati_13']!.khand.map((k) => k.dev).join(' '),
        contains('सावर्णि'));
  });

  test('अध्याय १२ का सार ग्रंथ के फल को ऐप का वादा नहीं बनाता', () {
    expect(paath['saptashati_12']!.parichay, contains('ऐप की ओर से कोई वादा नहीं'));
  });
}
