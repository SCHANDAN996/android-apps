// अक्षय तृतीया, आँवला नवमी, गोपाष्टमी (→ D-151), गीता और दत्तात्रेय जयंती (→ D-152) —
// हर साल तिथि, चुना दिन और वजह।
// `dart run tool/yugadi_aazmao.dart`
import 'package:panchang_engine/panchang_engine.dart';

void main() {
  String hm(DateTime d) =>
      '${d.month}-${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  for (final id in [
    'akshaya_tritiya',
    'akshaya_navami',
    'gopashtami',
    'gita_jayanti',
    'dattatreya_jayanti'
  ]) {
    final rule = festivalRules.firstWhere((r) => r.id == id);
    print('── ${rule.name}');
    for (var y = 2020; y <= 2040; y++) {
      final f = findFestival(rule, y, Place.delhi)!;
      final d = f.date;
      final lines = f.explanation.split('\n');
      print('$y → ${d.month}-${d.day} | ${hm(f.tithiStart)} – ${hm(f.tithiEnd)}'
          '${f.ambiguous ? ' | दूसरा: ${f.otherCandidate!.month}-${f.otherCandidate!.day}' : ''}'
          '${f.missedKaal ? ' | काल छूटा' : ''} | ${lines.length > 5 ? lines[lines.length - 3] : ''}');
    }
  }
}
