@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/vidhi.dart' show Bharosa, VidhiFormatException;

/// चालीसा और आरती के कंटेंट की जाँच (→ D-039)।
///
/// पूजाओं वाली `vidhi_test.dart` जैसा ही अनुशासन — सूची और फ़ाइलें
/// आपस में मिलनी चाहिए, और ढाँचा अधूरे पाठ को "तैयार" नहीं दिखने देता।
void main() {
  const dir = 'assets/paath';
  const suchiPath = '$dir/_suchi.json';

  late List<PaathSuchiEntry> suchi;

  setUpAll(() {
    suchi = PaathSuchiEntry.parseAll(
      suchiPath,
      File(suchiPath).readAsStringSync(),
    );
  });

  group('सूची और फ़ाइलें आपस में मेल खाती हैं', () {
    test('सूची पढ़ी जा सकती है और ख़ाली नहीं है', () {
      expect(suchi, isNotEmpty);
    });

    test('हर तैयार पाठ की फ़ाइल मौजूद है और पढ़ी जा सकती है', () {
      for (final e in suchi.where((e) => e.taiyar)) {
        final path = '$dir/${e.id}.json';
        expect(File(path).existsSync(), isTrue,
            reason: 'सूची में "${e.naam}" तैयार लिखा है पर $path है ही नहीं');
        expect(() => Paath.parse(path, File(path).readAsStringSync()),
            returnsNormally,
            reason: '$path पढ़ी नहीं जा सकी');
      }
    });

    test('फ़ोल्डर की हर फ़ाइल सूची में दर्ज है', () {
      final files = Directory(dir)
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.endsWith('.json') && n != '_suchi.json')
          .map((n) => n.substring(0, n.length - 5))
          .toSet();
      expect(files.difference(suchi.map((e) => e.id).toSet()), isEmpty,
          reason: 'ये फ़ाइलें फ़ोल्डर में हैं पर सूची में नहीं');
    });

    test('सूची का नाम, प्रकार, देवता और पास-हालत फ़ाइल से मिलती है', () {
      for (final e in suchi.where((e) => e.taiyar)) {
        final path = '$dir/${e.id}.json';
        final p = Paath.parse(path, File(path).readAsStringSync());
        expect(p.id, e.id, reason: '$path — id नहीं मिली');
        expect(p.naam, e.naam, reason: '$path — नाम नहीं मिला');
        expect(p.prakar, e.prakar, reason: '$path — प्रकार नहीं मिला');
        expect(p.devta, e.devta, reason: '$path — देवता नहीं मिला');
        expect(p.jaanch.paas, e.paas, reason: '$path — पास-हालत नहीं मिली');
      }
    });
  });

  group('हर तैयार पाठ में वो सब है जो चाहिए', () {
    for (final id in _taiyarIds(suchiPath, dir)) {
      final path = '$dir/$id.json';
      late Paath p;

      setUpAll(() => p = Paath.parse(path, File(path).readAsStringSync()));

      group(id, () {
        test('परिचय, कब और कैसे पढ़ें — तीनों भरे हैं', () {
          expect(p.parichay.trim(), isNotEmpty);
          expect(p.kabPadhein.trim(), isNotEmpty);
          expect(p.kaisePadhein.trim(), isNotEmpty);
        });

        test('रचयिता और भाषा लिखी है — कॉपीराइट के लिए ज़रूरी', () {
          // तुलसीदास जैसी पुरानी रचना सार्वजनिक है; किसी आधुनिक रचयिता
          // का पाठ बिना अनुमति नहीं जा सकता। इसलिए नाम हमेशा दर्ज हो।
          expect(p.rachnakar.trim(), isNotEmpty);
          expect(p.bhasha.trim(), isNotEmpty);
        });

        test('पद हैं, और हर पद का शीर्षक है', () {
          expect(p.khand, isNotEmpty);
          for (final k in p.khand) {
            expect(k.shirshak.trim(), isNotEmpty);
          }
        });

        test('स्रोत लिखा है', () {
          expect(p.strot.paddhati.trim(), isNotEmpty);
          expect(p.strot.kshetra.trim(), isNotEmpty);
        });

        test('जिस पद की रिकॉर्डिंग लिखी है वो फ़ाइल मौजूद है', () {
          for (final k in p.khand) {
            if (k.audio.trim().isEmpty) continue;
            expect(File('$dir/audio/${k.audio}').existsSync(), isTrue,
                reason: '"${k.shirshak}" की रिकॉर्डिंग ${k.audio} नहीं मिली');
          }
        });
      });
    }
  });

  group('ढाँचा ग़लत पाठ को अंदर नहीं आने देता', () {
    test('"चालीसा" में चालीस चौपाइयाँ न हों तो नहीं चलेगा', () {
      // नाम ही गिनती का वादा करता है। एक चौपाई छूट जाए तो चुपचाप
      // छूटनी नहीं चाहिए।
      expect(
        () => Paath.parse('जाँच', _chalisaWith(chaupai: 39)),
        throwsA(isA<VidhiFormatException>()),
      );
      expect(
        () => Paath.parse('जाँच', _chalisaWith(chaupai: 40)),
        returnsNormally,
      );
    });

    test('पाठ लिखा हो तो sthiti "khaali" नहीं रह सकती', () {
      expect(
        () => Paath.parse('जाँच', _chalisaWith(chaupai: 40, pehlaDev: 'कुछ पाठ')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('बिना पाठ के पद "पास" नहीं हो सकता', () {
      expect(
        () => Paath.parse(
            'जाँच', _chalisaWith(chaupai: 40, pehlaSthiti: 'paas')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('कच्चे पद वाला पाठ "पास" नहीं हो सकता', () {
      expect(
        () => Paath.parse('जाँच', _chalisaWith(chaupai: 40, paasHai: true)),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('ग़लत prakar वाली फ़ाइल नहीं चलेगी', () {
      expect(
        () => Paath.parse(
            'जाँच', _chalisaWith(chaupai: 40).replaceFirst('"chalisa"', '"bhajan"')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    // ── दोहराव (→ D-083) ──
    String aarti(String khandJson) => '''
{"schemaVersion": 1, "id": "x", "naam": "क", "upnaam": [], "prakar": "aarti",
 "devta": "क", "rachnakar": "क", "bhasha": "क", "parichay": "क",
 "kabPadhein": "क", "kaisePadhein": "क", "khand": [$khandJson],
 "strot": {"paddhati": "क", "kshetra": "क", "note": ""},
 "jaanch": {"panditNaam": "", "tarikh": "", "paas": false}}''';
    String khand(String sh, {bool? dohraav}) =>
        '{"shirshak": "$sh", "dev": "पाठ", "roman": "", "arth": "", '
        '"audio": "", "sthiti": "draft"'
        '${dohraav == null ? '' : ', "dohraav": $dohraav'}}';

    test('दोहराव वाला खंड सबसे पहले हो तो चलेगा', () {
      final p = Paath.parse('जाँच',
          aarti('${khand('क', dohraav: true)}, ${khand('ख')}, ${khand('ग')}'));
      expect(p.dohraavKhand?.shirshak, 'क');
      expect(p.padGinti, 2);
    });

    test('दोहराव बीच में हो तो नहीं चलेगा', () {
      expect(
        () => Paath.parse('जाँच',
            aarti('${khand('क')}, ${khand('ख', dohraav: true)}')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('दो खंडों पर दोहराव नहीं चलेगा', () {
      expect(
        () => Paath.parse('जाँच', aarti(
            '${khand('क', dohraav: true)}, ${khand('ख', dohraav: true)}')),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('ग़ैर-bool दोहराव नहीं चलेगा', () {
      expect(
        () => Paath.parse('जाँच', aarti(
            khand('क').replaceFirst('}', ', "dohraav": "हाँ"}'))),
        throwsA(isA<VidhiFormatException>()),
      );
    });

    test('ग़लती के संदेश में फ़ाइल का नाम आता है', () {
      try {
        Paath.parse('hanuman_chalisa.json', '{"schemaVersion": 99}');
        fail('फेंकना चाहिए था');
      } on VidhiFormatException catch (e) {
        expect(e.toString(), contains('hanuman_chalisa.json'));
      }
    });
  });

  /// **हर आरती में शुरुआती पंक्तियाँ ही दोहराव हैं** (→ D-083)।
  ///
  /// पहले यह सिर्फ़ शीर्षक के शब्द "टेक" से पहचानी जाती थी, और पन्ना उसे
  /// सबसे ऊपर एक बार दिखाकर छोड़ देता था। अब निशान से — और स्क्रीन पर
  /// "टेक" शब्द कहीं नहीं आता।
  test('हर आरती: ठीक एक दोहराव, सबसे पहले, शीर्षक में "टेक" नहीं', () {
    final aartiyan = suchi.where((e) => e.taiyar && e.prakar == PaathPrakar.aarti);
    expect(aartiyan.length, 11);
    for (final e in aartiyan) {
      final path = '$dir/${e.id}.json';
      final p = Paath.parse(path, File(path).readAsStringSync());
      expect(p.khand.first.dohraav, isTrue, reason: e.id);
      expect(p.khand.where((k) => k.dohraav).length, 1, reason: e.id);
      expect(p.khand.any((k) => k.shirshak.contains('टेक')), isFalse,
          reason: e.id);
      expect(p.kaisePadhein, contains('हर पद के बाद'), reason: e.id);
    }
  });

  test('चालीसा और स्तोत्र में दोहराव नहीं, और शीर्षक देवनागरी अंकों में', () {
    for (final e in suchi.where((e) => e.taiyar && e.prakar != PaathPrakar.aarti)) {
      final path = '$dir/${e.id}.json';
      final p = Paath.parse(path, File(path).readAsStringSync());
      expect(p.dohraavKhand, isNull, reason: e.id);
      for (final k in p.khand) {
        expect(k.shirshak, isNot(matches(RegExp(r'[0-9]'))),
            reason: '${e.id} — "${k.shirshak}"');
      }
    }
  });

  /// **सप्तश्लोकी दुर्गा कोई अलग रचना नहीं है** — वह दुर्गा सप्तशती से
  /// चुने हुए सात श्लोक हैं। 21 सित 2026 को उसे जोड़ते समय सातों श्लोक
  /// मूल सप्तशती के पूरे पाठ से मशीन द्वारा शब्द-दर-शब्द मिलाए गए थे।
  ///
  /// यह जाँच उसी का निशान है: तीसरा श्लोक वही होना चाहिए जो ऐप की
  /// **दुर्गा अष्टमी** और **कलश स्थापना** के देवी-पूजन में पहले से है।
  /// अगर कभी कोई एक जगह बदले और दूसरी न बदले, यह टूट जाएगी।
  group('सप्तश्लोकी दुर्गा', () {
    test('सातों श्लोक मौजूद हैं और भरे हुए हैं', () {
      const path = '$dir/saptashloki_durga.json';
      final p = Paath.parse(path, File(path).readAsStringSync());
      expect(p.khand.length, 7);
      expect(p.khand.every((k) => k.hasPath), isTrue);
      expect(p.khand.every((k) => k.roman.trim().isNotEmpty), isTrue);
      expect(p.khand.every((k) => k.arth.trim().isNotEmpty), isTrue);
    });

    test('तीसरा श्लोक वही है जो दुर्गा अष्टमी के देवी-पूजन में है', () {
      const path = '$dir/saptashloki_durga.json';
      final p = Paath.parse(path, File(path).readAsStringSync());
      final teesra = p.khand[2].dev.replaceAll(RegExp(r'\s+'), ' ');

      final vidhi = jsonDecode(
        File('assets/vidhi/durga_ashtami_kanya_poojan.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final poojan = (vidhi['charan'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((c) => c['shirshak'] == 'देवी पूजन');
      final mantra = (poojan['mantra'] as Map<String, dynamic>)['devanagari']
          as String;

      // दोनों जगह "सर्वमङ्गलमाङ्गल्ये … नारायणि नमोऽस्तु ते" है।
      expect(teesra, contains('सर्वमङ्गलमाङ्गल्ये'));
      expect(mantra.replaceAll(RegExp(r'\s+'), ' '),
          contains('सर्वमङ्गलमाङ्गल्ये'));
      for (final tuk in ['शिवे सर्वार्थसाधिके', 'शरण्ये त्र्यम्बके गौरि']) {
        expect(teesra, contains(tuk), reason: tuk);
        expect(mantra, contains(tuk), reason: tuk);
      }
    });
  });

  /// **"जगजननी जय जय" — चार छपे रूपों से मिलाया हुआ पाठ।**
  ///
  /// 21 सित 2026 को चार स्वतंत्र स्रोतों से पद-दर-पद बहुमत लेकर भरी गई।
  /// हर स्रोत में कोई न कोई छपाई-ग़लती थी — एक में Kruti Dev वाली
  /// ("विघा", "कत्र्ता"), एक में "हारिणि सब **बाघा**" (बाघ = शेर!) —
  /// और बहुमत ने चारों काट दीं। ये जाँचें उसी सफ़ाई को पकड़े रखती हैं।
  group('जगजननी जय जय', () {
    late Paath p;
    setUpAll(() {
      const path = '$dir/jagjanani_aarti.json';
      p = Paath.parse(path, File(path).readAsStringSync());
    });

    test('शुरुआती पंक्तियाँ और तेरह पद, सब भरे', () {
      expect(p.khand.length, 14);
      expect(p.khand.first.dohraav, isTrue);
      expect(p.khand.every((k) => k.hasPath), isTrue);
      expect(p.khand.every((k) => k.roman.trim().isNotEmpty), isTrue);
      expect(p.khand.every((k) => k.arth.trim().isNotEmpty), isTrue);
    });

    test('छपाई की वे ग़लतियाँ नहीं लौटीं जो बहुमत ने काटी थीं', () {
      final sab = p.khand.map((k) => k.dev).join('\n');
      for (final (galat, sahi) in [
        ('बाघा', 'बाधा'), // एक स्रोत में "बाधा" की जगह "बाघ"
        ('विघा', 'विद्या'), // Kruti Dev
        ('कत्र्ता', 'कर्ता'), // Kruti Dev
        ('जनजननी', 'जगजननी'),
        ('ब्रह्मरुपा', 'ब्रह्मरूपा'),
      ]) {
        expect(sab, isNot(contains(galat)), reason: '"$galat" लौट आया');
        expect(sab, contains(sahi), reason: '"$sahi" ग़ायब');
      }
      // छिपे हुए अक्षर (ZWJ/ZWNJ) — एक स्रोत के "रत्न" में थे
      expect(sab, isNot(matches(RegExp('[​-‏]'))));
    });

    test('नवरात्रि के हर आरती-कदम पर दोनों आरतियाँ हैं', () {
      final files = [
        ...Directory('assets/vidhi/navratri')
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json')),
        File('assets/vidhi/kalash_sthapana.json'),
        File('assets/vidhi/durga_ashtami_kanya_poojan.json'),
      ];
      expect(files.length, 11);
      for (final f in files) {
        final d = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        final paath = [
          for (final c in (d['charan'] as List).cast<Map<String, dynamic>>())
            ...((c['paath'] as List?) ?? const []).cast<String>(),
        ];
        expect(paath, containsAll(['durga_aarti', 'jagjanani_aarti']),
            reason: f.uri.pathSegments.last);
      }
    });
  });

  /// **राम जी की आरती — खेमराज की छपी आरती-पुस्तक से (→ D-146)।**
  ///
  /// सितम्बर (D-082) में जिन "छह छपे रूपों" से मिलाई थी, वे websites
  /// निकलीं — D-139 के बाद गवाह नहीं। छपी पुस्तकों में यह आरती अभी एक ही
  /// में मिली (खेमराज, पृ. 23–24): टेक में "राजा रामचंद्र", ठीक पाँच पद,
  /// "सीताराम को सोहे", "रामजी को भावे", "नामदेव जी गावे"। एक गवाह —
  /// इसलिए भरोसा मध्यम।
  group('राम जी की आरती', () {
    late Paath p;
    setUpAll(() {
      const path = '$dir/ram_aarti.json';
      p = Paath.parse(path, File(path).readAsStringSync());
    });

    test('शुरुआती पंक्तियाँ और पाँच पद, सब भरे, एक गवाह — भरोसा मध्यम', () {
      expect(p.khand.length, 6);
      expect(p.khand.first.dohraav, isTrue);
      expect(p.khand.every((k) => k.hasPath), isTrue);
      expect(p.khand.every((k) => k.roman.trim().isNotEmpty), isTrue);
      expect(p.khand.every((k) => k.arth.trim().isNotEmpty), isTrue);
      expect(p.bharosa, Bharosa.madhyam);
    });

    test('पाठ छपी पुस्तक वाला है', () {
      expect(p.khand[0].dev, contains('राजा रामचन्द्र'));
      expect(p.khand[3].dev, contains('सीताराम को सोहे'));
      expect(p.khand[5].dev, contains('रामजी को भावे'));
      expect(p.khand[5].dev, contains('नामदेव जी गावे'));
    });
  });

  group('🚧 पाठ की नापी हुई हालत', () {
    test('कितने पाठ, कितने पद, कितनी रिकॉर्डिंग', () {
      var kul = 0, bhare = 0, audio = 0;
      for (final e in suchi.where((e) => e.taiyar)) {
        final path = '$dir/${e.id}.json';
        final p = Paath.parse(path, File(path).readAsStringSync());
        kul += p.khandKul;
        bhare += p.khandBhareHue;
        audio += p.khandAudioWale;
      }
      final paas = suchi.where((e) => e.paas).length;

      // ignore: avoid_print
      print('''

  🚧 पाठ की हालत
     पाठ         ${suchi.where((e) => e.taiyar).length} / ${suchi.length} जुड़े
     जाँचे हुए   $paas / ${suchi.length}
     पद          $bhare / $kul का पाठ भरा
     रिकॉर्डिंग   $audio / $kul
     ➜ पाठ अपनी पुस्तिका से आएगा, रिकॉर्डिंग अपनी आवाज़ में
''');

      expect(bhare, lessThanOrEqualTo(kul));
    });
  });

  test('विश्वकर्मा सूक्त का सातवाँ मंत्र और पूजा का आवाहन मंत्र एक ही हैं', () {
    // एक ही ऋचा (ऋग्वेद १०.८१.७) दो जगह है — सूक्त में, और विश्वकर्मा
    // पूजा के आवाहन वाले कदम पर। एक जगह सुधरे तो दूसरी पीछे न छूटे।
    const path = 'assets/paath/vishwakarma_sukta.json';
    final sukta = Paath.parse(path, File(path).readAsStringSync());
    final vidhi = jsonDecode(
        File('assets/vidhi/vishwakarma_pooja.json').readAsStringSync());
    final aavahan = (vidhi['charan'] as List).firstWhere(
        (c) => ((c['paath'] as List?) ?? const []).contains(sukta.id));
    String saaf(String s) => s.replaceAll(RegExp(r'[\s।॥]'), '');

    expect(sukta.khand, hasLength(7));
    expect(saaf(sukta.khand[6].dev),
        saaf(aavahan['mantra']['devanagari'] as String));
  });
}

List<String> _taiyarIds(String suchiPath, String dir) =>
    PaathSuchiEntry.parseAll(suchiPath, File(suchiPath).readAsStringSync())
        .where((e) => e.taiyar)
        .map((e) => e.id)
        .toList(growable: false);

/// जाँच के लिए एक चालीसा — चौपाइयों की गिनती बदली जा सकती है।
String _chalisaWith({
  required int chaupai,
  String pehlaDev = '',
  String pehlaSthiti = 'khaali',
  bool paasHai = false,
}) {
  final khand = <String>[
    '{"shirshak": "दोहा १", "dev": "$pehlaDev", "roman": "", "arth": "", '
        '"audio": "", "sthiti": "$pehlaSthiti"}',
    for (var i = 1; i <= chaupai; i++)
      '{"shirshak": "चौपाई $i", "dev": "", "roman": "", "arth": "", '
          '"audio": "", "sthiti": "khaali"}',
  ];
  final jaanch = paasHai
      ? '{"panditNaam": "कोई पंडित जी", "tarikh": "2026-09-15", "paas": true}'
      : '{"panditNaam": "", "tarikh": "", "paas": false}';
  return '''
{
  "schemaVersion": 1,
  "id": "jaanch",
  "naam": "जाँच वाला पाठ",
  "upnaam": [],
  "prakar": "chalisa",
  "devta": "कोई देवता",
  "rachnakar": "कोई रचयिता",
  "bhasha": "अवधी",
  "parichay": "सिर्फ़ जाँच के लिए",
  "kabPadhein": "कभी भी",
  "kaisePadhein": "बैठकर",
  "khand": [${khand.join(",")}],
  "bharosa": "kam",
  "strot": {"paddhati": "जाँच", "kshetra": "जाँच", "note": ""},
  "jaanch": $jaanch
}
''';
}
