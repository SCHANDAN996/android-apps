// इंजन के आठ व्रत-नियम किसी साल में क्या देते हैं — तारीख़, तिथि का आरंभ-अंत,
// व्यापिनी की खिड़की और झंडे — JSON में (→ D-116, docs/30 §४)।
//
//     dart run tool/vrat_saal.dart 2029 2030 > ../tools/out.json
//     dart run tool/vrat_saal.dart --sab 2027 2028      (आठ नहीं, बीसों नियम)
//
// यह जाँच का औज़ार है: इसका नतीजा `tools/horizons_vrat.py` NASA के ephemeris से
// मिलाता है। समय भारतीय (IST) हैं, जैसे इंजन देता है।
import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

/// D-087 वाले आठ नियम — पाँच साल (2024–2028) पर संदर्भ-पंचांग से मिले हुए।
const aath = [
  'vat_savitri',
  'varalakshmi_vrat',
  'hartalika_teej',
  'pitru_paksha_arambh',
  'sarvapitri_amavasya',
  'dussehra',
  'karwa_chauth',
  'chhath',
];

String iso(DateTime t) => t.toIso8601String().substring(0, 19);

void main(List<String> argv) {
  final sab = argv.contains('--sab');
  final args = argv.where((a) => a != '--sab').toList();
  final saal = args.isEmpty ? [2029, 2030] : args.map(int.parse).toList();
  final ids = sab ? [for (final r in festivalRules) r.id] : aath;
  final out = <Map<String, Object?>>[];
  for (final y in saal) {
    for (final id in ids) {
      final rule = festivalRules.firstWhere((r) => r.id == id);
      final f = findFestival(rule, y, Place.delhi);
      if (f == null) {
        out.add({'id': id, 'saal': y, 'mila': false});
        continue;
      }
      out.add({
        'id': id,
        'naam': rule.name,
        'saal': y,
        'mila': true,
        'date': iso(f.date).substring(0, 10),
        'tithi': rule.tithi,
        'paksha': rule.paksha,
        'vyapini': rule.vyapini.name,
        'vaarPehle': rule.vaarPehle,
        'tithiStart': iso(f.tithiStart),
        'tithiEnd': iso(f.tithiEnd),
        'kaalStart': iso(f.kaalStart),
        'kaalEnd': iso(f.kaalEnd),
        'shiftedForBhadra': f.shiftedForBhadra,
        'missedKaal': f.missedKaal,
        'ambiguous': f.ambiguous,
        'otherCandidate': f.otherCandidate == null
            ? null
            : iso(f.otherCandidate!).substring(0, 10),
        'explanation': f.explanation,
      });
    }
  }
  stdout.writeln(const JsonEncoder.withIndent(' ').convert(out));
}
