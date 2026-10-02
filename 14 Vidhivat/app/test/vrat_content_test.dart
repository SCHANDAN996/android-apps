// व्रत के पन्नों का कंटेंट — एकादशी, सोमवार, मंगलवार, बृहस्पतिवार… (→ D-075)
//
// ⚠️ UI अभी बना नहीं है, पर कंटेंट पहले से ऐप में है। ये जाँचें उसी
// ईमानदारी को पकड़े रखती हैं जिस पर व्रत का पूरा ढाँचा खड़ा है:
// ऐप अपनी तरफ़ से फल नहीं बताएगा (→ D-051), निर्जल का सुझाव नहीं देगा,
// और लोक-कथा को पुराण नहीं कहेगा। यही जाँचें `tools/jaancho_vrat.py` में
// भी हैं — वो बिना Flutter के जल्दी चलती है।
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/katha.dart';

Future<Map<String, dynamic>> _json(String path) async {
  final data = await rootBundle.load(path);
  return jsonDecode(utf8.decode(data.buffer.asUint8List()))
      as Map<String, dynamic>;
}

Iterable<String> _sabPaath(Object? x) sync* {
  if (x is String) {
    yield x;
  } else if (x is Map) {
    for (final v in x.values) {
      yield* _sabPaath(v);
    }
  } else if (x is List) {
    for (final v in x) {
      yield* _sabPaath(v);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Map<String, dynamic>> suchi;
  late Map<String, Map<String, dynamic>> vrat;

  setUpAll(() async {
    final s = await _json('assets/vrat/_suchi.json');
    suchi = [for (final e in s['vrat'] as List) e as Map<String, dynamic>];
    vrat = {
      // `faail` वाली entry व्रत-पन्ना नहीं, अलग ढाँचा है (साल की एकादशियाँ)
      for (final e in suchi
          .where((e) => e['taiyar'] == true && e['faail'] == null))
        e['id'] as String: await _json('assets/vrat/${e['id']}.json'),
    };
  });

  test('पहले चरण के चारों व्रत लिखे जा चुके हैं', () {
    expect(vrat.keys.toSet(),
        containsAll({'ekadashi', 'somvar', 'mangalvar', 'brihaspativar'}));
    final ids = suchi.map((e) => e['id']).toList();
    expect(ids.toSet().length, ids.length, reason: 'सूची में कोई id दो बार');
  });

  test('हर व्रत की फ़ाइल सूची से मिलती है, और कुछ भी "पास" नहीं', () {
    for (final e in suchi) {
      expect(e['paas'], isFalse, reason: '${e['id']} — D-072');
    }
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      final e = suchi.firstWhere((e) => e['id'] == id);
      expect(v['schemaVersion'], 1, reason: id);
      expect(v['id'], id);
      expect(v['naam'], e['naam'], reason: id);
      expect(v['samuh'], e['samuh'], reason: id);
      final mantra = v['mantra'] as Map;
      expect(mantra['sthiti'], isNot('paas'), reason: id);
      // मंत्र न मिला हो तो गढ़ा नहीं जाता — ख़ाली रहता है, कारण के साथ (→ D-041)
      if ((mantra['devanagari'] as String).trim().isEmpty) {
        expect(mantra['sthiti'], 'khaali', reason: id);
        expect((mantra['strot'] as String).trim().length, greaterThan(40),
            reason: '$id — मंत्र ख़ाली क्यों है, यह लिखा हो');
      } else {
        expect((mantra['roman'] as String).trim(), isNotEmpty, reason: id);
        expect((mantra['strot'] as String).trim(), isNotEmpty, reason: id);
      }
    }
  });

  test('बारहों खाने भरे हैं', () {
    const khaane = [
      'ekLine', 'kab', 'bhav', 'mahatmya', 'niyam', 'bhojan', 'paran', //
      'puja', 'mantra', 'kathaIds', 'udyapan', 'savdhani', 'sawaal', 'strot',
    ];
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      for (final k in khaane) {
        final x = v[k];
        expect(x, isNotNull, reason: '$id — $k');
        if (x is String) expect(x.trim(), isNotEmpty, reason: '$id — $k');
        // कथा जान-बूझकर न ली हो तो कारण लिखा हो (→ D-076)
        if (k == 'kathaIds' && x is List && x.isEmpty) {
          expect((v['kathaKyonNahi'] as String?)?.trim().length ?? 0,
              greaterThan(60),
              reason: '$id — कथा नहीं है तो कारण लिखा हो');
          continue;
        }
        if (x is List) expect(x, isNotEmpty, reason: '$id — $k');
      }
    }
  });

  // ⚠️ यही वो जाँच है जो "फ़ायदे" को ऐप का वादा बनने से रोकती है।
  test('फल या लाभ का कोई दावा नहीं — न व्रत में, न उसकी कथा में', () async {
    const daawe = [
      'मनोकामना',
      'पूरी होती',
      'लाभ होता',
      'लाभ होगा',
      'फल मिलता',
      'पुण्य मिलता',
      'कष्ट दूर',
    ];
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      final kathaPaath = [
        for (final k in v['kathaIds'] as List)
          ...(await _json('assets/katha/$k.json')).values,
      ];
      for (final s in _sabPaath([v, kathaPaath])) {
        for (final d in daawe) {
          expect(s.contains(d), isFalse, reason: '$id — "$d": $s');
        }
      }
    }
  });

  test('माहात्म्य हमेशा स्रोत के साथ, और ऐप का वादा नहीं', () {
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      final m = v['mahatmya'] as Map;
      expect(['uncha', 'madhyam', 'kam'], contains(m['bharosa']), reason: id);
      expect(m['strot'] as String, contains('ऐप'), reason: id);
      expect((m['strot'] as String).length, lessThanOrEqualTo(600),
          reason: '$id — D-050');
    }
  });

  test('निर्जल का सुझाव नहीं — हमेशा हल्का रूप पहले, और सावधानी साथ', () {
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      final bhojan = [for (final b in v['bhojan'] as List) b as Map];
      expect(bhojan.first['roop'], isNot('निर्जल'), reason: id);
      expect(bhojan.any((b) => b['roop'] == 'फलाहार'), isTrue, reason: id);
      for (final b in bhojan.where((b) => b['roop'] == 'निर्जल')) {
        expect(b['vivaran'] as String, contains('सुझाव नहीं'), reason: id);
      }
      expect((v['savdhani'] as List).any((s) => (s as String).contains('डॉक्टर')),
          isTrue,
          reason: id);
    }
  });

  test('हर व्रत की कथा खुलती है, और उसी पैमाने पर खरी है', () async {
    for (final v in vrat.values) {
      for (final kid in v['kathaIds'] as List) {
        final Katha k = await kathaBhandar.katha(kid as String);
        expect(k.roop, KathaRoop.bhavarth, reason: kid);
        expect(k.strot.trim().length, greaterThan(60), reason: kid);
        expect(k.kabSunayen.trim().length, greaterThan(30), reason: kid);
        for (final a in k.adhyay) {
          expect(a.gadya.trim().split(RegExp(r'\s+')).length, greaterThan(200),
              reason: '$kid — ${a.shirshak}');
        }
        // वार के व्रतों की कथाएँ किसी पुराण में नहीं — यह छिपना नहीं चाहिए।
        if (v['samuh'] == 'vaar') {
          expect(k.strot, contains('लोक-कथा'), reason: kid);
        }
      }
    }
  });

  // ── साल की एकादशियाँ ───────────────────────────────
  test('साल की छब्बीस एकादशियाँ — हर महीने के दोनों पक्ष, और अधिक मास की दो',
      () async {
    final d = await _json('assets/vrat/_ekadashi_varsh.json');
    final sab = [for (final e in d['ekadashi'] as List) e as Map];
    expect(sab, hasLength(26));
    expect(sab.map((e) => e['id']).toSet(), hasLength(26));
    final jode = {
      for (final e in sab) '${e['adhik'] == true ? 'अधिक' : e['maas']}-${e['paksha']}',
    };
    expect(jode, hasLength(26), reason: 'कोई महीना-पक्ष दो बार या छूटा');
    expect(sab.where((e) => e['adhik'] == true), hasLength(2));
  });

  test('हर एकादशी की कथा खुलती है, पैमाने पर खरी है, और कोई दावा नहीं',
      () async {
    const daawe = [
      'मनोकामना', 'पूरी होती', 'लाभ होता', 'लाभ होगा', //
      'फल मिलता', 'पुण्य मिलता', 'कष्ट दूर',
    ];
    final d = await _json('assets/vrat/_ekadashi_varsh.json');
    for (final e in d['ekadashi'] as List) {
      final kid = (e as Map)['kathaId'] as String;
      final Katha k = await kathaBhandar.katha(kid);
      expect(k.roop, KathaRoop.bhavarth, reason: kid);
      expect(k.strot.trim().length, greaterThan(60), reason: kid);
      expect(k.kabSunayen.trim().length, greaterThan(30), reason: kid);
      for (final a in k.adhyay) {
        expect(a.gadya.trim().split(RegExp(r'\s+')).length, greaterThan(200),
            reason: '$kid — ${a.shirshak}');
      }
      final kathaJson = await _json('assets/katha/$kid.json');
      for (final s in _sabPaath([e, kathaJson])) {
        for (final daawa in daawe) {
          expect(s.contains(daawa), isFalse, reason: '$kid — "$daawa"');
        }
      }
      // निर्जला पर भी ऐप निर्जल का सुझाव नहीं देता
      if ((e['naam'] as String).contains('निर्जल')) {
        expect(e['vishesh'] as String, contains('सुझाव नहीं'));
      }
    }
  });

  test('जिस पाठ और विधि का नाम लिखा, वो ऐप में है', () async {
    final paath = await _json('assets/paath/_suchi.json');
    final taiyar = {
      for (final p in paath['paath'] as List)
        if ((p as Map)['taiyar'] == true) p['id'],
    };
    for (final MapEntry(key: id, value: v) in vrat.entries) {
      for (final p in v['paath'] as List) {
        expect(taiyar, contains(p), reason: '$id — $p');
      }
      final vidhi = v['vidhiId'];
      if (vidhi != null) {
        await expectLater(
            vidhiBhandar.vidhi(vidhi as String), completes, reason: id);
      }
    }
  });
}
