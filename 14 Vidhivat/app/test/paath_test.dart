@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/vidhi.dart' show VidhiFormatException;

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

    test('ग़लती के संदेश में फ़ाइल का नाम आता है', () {
      try {
        Paath.parse('hanuman_chalisa.json', '{"schemaVersion": 99}');
        fail('फेंकना चाहिए था');
      } on VidhiFormatException catch (e) {
        expect(e.toString(), contains('hanuman_chalisa.json'));
      }
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
