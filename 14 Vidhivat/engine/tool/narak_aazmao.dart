// नरक चतुर्दशी — हर साल चतुर्दशी, भोर का चंद्रोदय, सूर्योदय और चुना दिन (→ D-150)।
// `dart run tool/narak_aazmao.dart`
import 'package:panchang_engine/panchang_engine.dart';

void main() {
  final rule = festivalRules.firstWhere((r) => r.id == 'narak_chaturdashi');
  for (var y = 2020; y <= 2030; y++) {
    final f = findFestival(rule, y, Place.delhi)!;
    String hm(DateTime d) =>
        '${d.month}-${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final d = f.date;
    final kal = d.subtract(const Duration(days: 1));
    final chandKal = moonriseMoonset(kal.year, kal.month, kal.day, Place.delhi).moonrise;
    final chand = moonriseMoonset(d.year, d.month, d.day, Place.delhi).moonrise;
    print('$y → ${d.month}-${d.day} | चतुर्दशी ${hm(f.tithiStart)} – ${hm(f.tithiEnd)} | '
        'चंद्रोदय ${chandKal == null ? '-' : hm(chandKal)}, ${chand == null ? '-' : hm(chand)} | '
        '${f.explanation.split('\n').last}');
  }
}
