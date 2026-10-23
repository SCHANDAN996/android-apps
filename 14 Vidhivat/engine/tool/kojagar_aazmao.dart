// शरद पूर्णिमा (कोजागर) — इंजन किस साल कौन-सा दिन देता है, और क्यों (→ D-130)।
//
//     dart run tool/kojagar_aazmao.dart 2024 2030 [delhi|mumbai]
//
// हर साल: पूर्णिमा कब से कब, दोनों दिनों की आधी रात, प्रदोष, और चुना दिन — ताकि
// संदर्भ-पंचांग के पन्नों से मिलाया जा सके।
import 'package:panchang_engine/panchang_engine.dart';

String t(DateTime d) =>
    '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

void main(List<String> args) {
  final se = args.isNotEmpty ? int.parse(args[0]) : 2024;
  final tak = args.length > 1 ? int.parse(args[1]) : 2030;
  final place = (args.length > 2 && args[2] == 'mumbai') ? Place.mumbai : Place.delhi;
  final rule = festivalRules.firstWhere((r) => r.id == 'sharad_purnima');

  for (var y = se; y <= tak; y++) {
    final f = findFestival(rule, y, place)!;
    print('$y  →  ${f.date.day}/${f.date.month}'
        '${f.otherCandidate == null ? '' : '   (दूसरा दावेदार ${f.otherCandidate!.day}/${f.otherCandidate!.month})'}');
    print('      पूर्णिमा ${t(f.tithiStart)} → ${t(f.tithiEnd)}');
    for (var k = -1; k <= 1; k++) {
      final d = f.date.add(Duration(days: k));
      final n = kaalWindow(Vyapini.nishitha, d.year, d.month, d.day, place);
      final p = kaalWindow(Vyapini.pradosha, d.year, d.month, d.day, place);
      if (n == null || p == null) continue;
      final aadhi = n.start.add(n.end.difference(n.start) * 0.5);
      print('      ${d.day}/${d.month}: प्रदोष ${t(p.start)}–${t(p.end)}, '
          'निशीथ ${t(n.start)}–${t(n.end)} (बीच ≈ ${t(aadhi)})');
    }
    for (final l in f.explanation.split('\n').skip(3)) {
      print('      · $l');
    }
  }
}
