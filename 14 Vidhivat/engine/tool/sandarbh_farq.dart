import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

/// `test/data/reference_dates.json` के हर छपे समय से हमारा फ़र्क़, **सेकंड में**।
///
///   dart run tool/sandarbh_farq.dart
///
/// `reference_test` सिर्फ़ यह देखता है कि फ़र्क़ 2 मिनट के भीतर है; यह औज़ार
/// बताता है कि कितना है — किसी सूत्र को बदलने से पहले और बाद में नापने के लिए
/// (→ D-104)। संदर्भ मिनट तक ही छपा है, इसलिए ±30 सेकंड उसकी अपनी गोलाई है।
void main() {
  final data = jsonDecode(File('test/data/reference_dates.json').readAsStringSync())
      as Map<String, dynamic>;
  final cities = data['cities'] as Map<String, dynamic>;
  final entries = (data['entries'] as List)
      .cast<Map<String, dynamic>>()
      .where((e) => e['expected'] != null);

  final sab = <String, List<int>>{};
  for (final e in entries) {
    final c = cities[e['city']] as Map<String, dynamic>;
    final place = Place(
        name: c['name'] as String,
        latitude: (c['lat'] as num).toDouble(),
        longitude: (c['lon'] as num).toDouble());
    final d = (e['date'] as String).split('-').map(int.parse).toList();
    final p = computePanchang(d[0], d[1], d[2], place);
    final x = e['expected'] as Map<String, dynamic>;

    int? farq(String key, DateTime? mila) {
      final want = x[key] as String?;
      if (want == null || mila == null) return null;
      final hm = want.split(':').map(int.parse).toList();
      final chahiye = DateTime.utc(mila.year, mila.month, mila.day, hm[0], hm[1]);
      return mila.difference(chahiye).inSeconds;
    }

    final row = <String, int?>{
      'सूर्योदय': farq('sunrise', p.sunrise),
      'सूर्यास्त': farq('sunset', p.sunset),
      'तिथि': farq('tithiEndsAt', p.tithi.endsAt),
      'नक्षत्र': farq('nakshatraEndsAt', p.nakshatra.endsAt),
    };
    stdout.writeln('${e['date']} ${(e['city'] as String).padRight(9)} '
        '${row.entries.map((r) => '${r.key} ${(r.value ?? '—').toString().padLeft(4)}').join('  ')}');
    for (final r in row.entries) {
      if (r.value != null) (sab[r.key] ??= []).add(r.value!);
    }
  }
  stdout.writeln('');
  for (final r in sab.entries) {
    final v = r.value;
    final ausat = v.reduce((a, b) => a + b) / v.length;
    final bada = v.map((a) => a.abs()).reduce((a, b) => a > b ? a : b);
    stdout.writeln('${r.key.padRight(9)} n=${v.length}  औसत ${ausat.toStringAsFixed(0).padLeft(4)} से  '
        'सबसे बड़ा ${bada.toString().padLeft(3)} से');
  }
}
