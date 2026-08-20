import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// छपे हुए पंचांग से मिलान।
///
/// यह इंजन की **आख़िरी अदालत** है। astronomy_test.dart यह जाँचता है कि
/// गणित अपने आप में ठीक है; यह फ़ाइल जाँचती है कि हमारा जवाब वही है जो
/// ठाकुर प्रसाद के कैलेंडर में छपा है — क्योंकि यूज़र उसी से मिलाएगा।
///
/// भरने का तरीक़ा `test/data/reference_dates.json` में लिखा है।

/// समय की छूट। Drik अपने समय मिनट तक ही दिखाता है, और हमारे-उसके बीच
/// लगभग 30–60 सेकंड का पक्का फ़र्क़ रह जाता है (कारण JSON में लिखा है)।
/// असली गड़बड़ी मिनटों में नहीं, घंटों में दिखेगी — यह छूट उसे नहीं छिपाएगी।
const _timeTolerance = Duration(minutes: 2);

void main() {
  final file = File('test/data/reference_dates.json');

  if (!file.existsSync()) {
    test('reference_dates.json मौजूद नहीं', () {
      fail('test/data/reference_dates.json नहीं मिली');
    });
    return;
  }

  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final cities = data['cities'] as Map<String, dynamic>;
  final entries = (data['entries'] as List).cast<Map<String, dynamic>>();

  final filled = entries.where((e) => e['expected'] != null).toList();

  group('छपे पंचांग से मिलान', () {
    test('कितनी तारीख़ें भरी जा चुकी हैं', () {
      final total = entries.where((e) => e.containsKey('date')).length;
      final cityCount =
          filled.map((e) => e['city'] as String).toSet().length;

      print('');
      print('  भरी हुई तारीख़ें: ${filled.length} / $total  ·  शहर: $cityCount / 5');
      print('  ➜  और जोड़ने के लिए: dart run tool/panchang_cli.dart --fill');
      print('');
      print('  ⚠️  याद रहे — यह सिर्फ़ *गणित* की जाँच है।');
      print('     त्योहार की तारीख़ें व्यापिनी नियम से तय होती हैं,');
      print('     सिर्फ़ सूर्योदय की तिथि से नहीं। देखो test/festival_notes.md');
      print('');
    });

    if (filled.isEmpty) {
      test('अभी कोई तारीख़ भरी नहीं गई', () {
        markTestSkipped('reference_dates.json में expected भरना बाक़ी है');
      }, skip: 'छपे पंचांग से भरना बाक़ी है');
      return;
    }

    for (final entry in filled) {
      final dateText = entry['date'] as String;
      final cityKey = entry['city'] as String;
      final expected = entry['expected'] as Map<String, dynamic>;
      final city = cities[cityKey] as Map<String, dynamic>;

      final place = Place(
        name: city['name'] as String,
        latitude: (city['lat'] as num).toDouble(),
        longitude: (city['lon'] as num).toDouble(),
      );

      final parts = dateText.split('-').map(int.parse).toList();

      test('$dateText — ${place.name}', () {
        final p = computePanchang(parts[0], parts[1], parts[2], place);

        if (expected['tithi'] != null) {
          expect(p.tithi.number, expected['tithi'], reason: 'तिथि');
        }
        if (expected['nakshatra'] != null) {
          expect(p.nakshatra.number, expected['nakshatra'], reason: 'नक्षत्र');
        }
        if (expected['yoga'] != null) {
          expect(p.yoga.number, expected['yoga'], reason: 'योग');
        }
        if (expected['masa'] != null) {
          expect(p.masaFullName, expected['masa'], reason: 'मास');
        }
        if (expected['paksha'] != null) {
          expect(p.pakshaName, expected['paksha'], reason: 'पक्ष');
        }

        void checkTime(String key, DateTime? actual, String label) {
          final want = expected[key] as String?;
          if (want == null || actual == null) return;
          final hm = want.split(':').map(int.parse).toList();
          final wanted = DateTime.utc(
              actual.year, actual.month, actual.day, hm[0], hm[1]);
          final off = actual.difference(wanted).abs();
          expect(off, lessThanOrEqualTo(_timeTolerance),
              reason: '$label — मिला ${_hhmm(actual)}, चाहिए $want');
        }

        checkTime('sunrise', p.sunrise, 'सूर्योदय');
        checkTime('sunset', p.sunset, 'सूर्यास्त');
        checkTime('tithiEndsAt', p.tithi.endsAt, 'तिथि समाप्ति');
        checkTime('nakshatraEndsAt', p.nakshatra.endsAt, 'नक्षत्र समाप्ति');
      });
    }
  });
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
