import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// लग्न — **NASA JPL Horizons से**, हमारे सूत्र के बिना निकला जवाब
/// (→ D-105, docs/08 §18)।
///
/// जिस क्षण सूर्य का केंद्र ज्यामितीय क्षितिज पर हो (बिना वायुमंडल के ऊँचाई
/// ठीक 0°), उस क्षण उगता हुआ क्रांतिवृत्त का बिंदु सूर्य ही है — क्योंकि
/// सूर्य हमेशा क्रांतिवृत्त पर रहता है। तो:
///
///     उगते समय   लग्न = सूर्य का सायन देशांतर
///     डूबते समय  लग्न = सूर्य का सायन देशांतर + 180°
///
/// दोनों संख्याएँ — क्षितिज पार करने का क्षण और सूर्य का देशांतर — Horizons
/// से आती हैं (`tools/horizons_lagna.py`)। यह वही कसौटी है जो `docs/29` §9 में
/// K2 के लिए रखी गई थी (लग्न 2 कला के भीतर), बस संदर्भ-पंचांग की जगह NASA।
void main() {
  final file = File('test/data/horizons_lagna.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final entries = (data['entries'] as List).cast<Map<String, dynamic>>();

  test('चार शहर, बारह तारीख़ें, उगना और डूबना — 96 क्षण', () {
    expect(entries.length, greaterThanOrEqualTo(90));
    expect(entries.map((e) => e['sthan']).toSet().length, 4);
  });

  test('लग्न पूरे चक्र में फैला है — बारहों राशियाँ आईं', () {
    final rashiyan =
        entries.map((e) => ((e['lagnaSayan'] as num) ~/ 30) % 12).toSet();
    expect(rashiyan.length, 12);
  });

  test('हर क्षण पर लग्न NASA से 2 कला के भीतर', () {
    var sabseBada = 0.0;
    for (final e in entries) {
      final place = Place(
          name: e['sthan'] as String,
          latitude: (e['latitude'] as num).toDouble(),
          longitude: (e['longitude'] as num).toDouble());
      final jd = julianDayFromUtc(DateTime.parse('${e['ut']}Z'));
      final farq =
          norm180(lagnaSayan(jd, place) - (e['lagnaSayan'] as num)).abs();
      if (farq > sabseBada) sabseBada = farq;
      expect(farq, lessThan(2 / 60),
          reason: '${e['sthan']} ${e['ut']} ${e['kism']}: ${farq * 60} कला');
    }
    print('  लग्न — NASA से सबसे बड़ा फ़र्क़: '
        '${(sabseBada * 3600).toStringAsFixed(1)} विकला (${entries.length} क्षण)');
  });
}
