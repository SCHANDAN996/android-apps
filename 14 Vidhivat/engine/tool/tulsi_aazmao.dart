// तुलसी विवाह, देव दीपावली और कार्तिक पूर्णिमा — इंजन किस साल कौन-सा दिन देता है, और क्यों
// (→ D-140)।
//
//     dart run tool/tulsi_aazmao.dart 2023 2030 [delhi|mumbai]
//
// हर साल: प्रबोधिनी एकादशी कब से कब, आसपास के सूर्योदय; कार्तिक पूर्णिमा कब से
// कब, सूर्योदय और प्रदोष — ताकि संदर्भ-पंचांग के पन्नों से मिलाया जा सके।
import 'package:panchang_engine/panchang_engine.dart';

String t(DateTime d) =>
    '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

void main(List<String> args) {
  final se = args.isNotEmpty ? int.parse(args[0]) : 2024;
  final tak = args.length > 1 ? int.parse(args[1]) : 2030;
  final place =
      (args.length > 2 && args[2] == 'mumbai') ? Place.mumbai : Place.delhi;

  for (var y = se; y <= tak; y++) {
    print('── $y ──');
    for (final id in ['tulsi_vivah', 'dev_deepawali', 'kartik_purnima']) {
      final rule = festivalRules.firstWhere((r) => r.id == id);
      final f = findFestival(rule, y, place)!;
      print('  ${rule.name}  →  ${f.date.day}/${f.date.month}'
          '${f.otherCandidate == null ? '' : '   (दूसरा दावेदार ${f.otherCandidate!.day}/${f.otherCandidate!.month})'}'
          '${f.missedKaal ? '   [काल नहीं छुआ]' : ''}');
      print('      तिथि ${t(f.tithiStart)} → ${t(f.tithiEnd)}');
      for (var k = -2; k <= 1; k++) {
        final d = f.date.add(Duration(days: k));
        final s = kaalWindow(Vyapini.sunrise, d.year, d.month, d.day, place);
        final p = kaalWindow(Vyapini.pradosha, d.year, d.month, d.day, place);
        if (s == null || p == null) continue;
        print('      ${d.day}/${d.month}: सूर्योदय ${t(s.start)}, '
            'प्रदोष ${t(p.start)}–${t(p.end)}');
      }
      for (final l in f.explanation.split('\n').skip(3)) {
        print('      · $l');
      }
    }
  }
}
