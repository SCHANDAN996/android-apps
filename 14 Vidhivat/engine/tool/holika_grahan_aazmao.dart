// होलिका दहन — फाल्गुन पूर्णिमा पर चंद्रग्रहण किन सालों में, और भारत में दिखता है या नहीं (J-002)।
// `dart run tool/holika_grahan_aazmao.dart`
import 'package:panchang_engine/panchang_engine.dart';

void main() {
  final rule = festivalRules.firstWhere((r) => r.id == 'holika_dahan');
  String hm(DateTime d) {
    final l = d.add(Place.delhi.timeZoneOffset);
    return '${l.month}-${l.day} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  for (var y = 2024; y <= 2060; y++) {
    final f = findFestival(rule, y, Place.delhi);
    if (f == null) continue;
    final g = chandraGrahan(
            se: f.tithiStart.subtract(const Duration(days: 1)),
            tak: f.tithiEnd.add(const Duration(days: 1)))
        .where((g) => !g.madhya.isBefore(f.tithiStart.subtract(const Duration(hours: 12))) &&
            !g.madhya.isAfter(f.tithiEnd.add(const Duration(hours: 12))));
    for (final x in g) {
      final dd = dekhaJayega(x, Place.delhi);
      print('$y होलिका ${f.date.month}-${f.date.day} | पूर्णिमा ${hm(f.tithiStart)}–${hm(f.tithiEnd)} | '
          '${x.prakar.naam} ${hm(x.shuru)}–${hm(x.khatm)} | दिल्ली में ${dd.dikhega ? 'दिखेगा' : 'नहीं'}'
          '${dd.sthaniyaShuru == null ? '' : ' ${hm(dd.sthaniyaShuru!)}–${hm(dd.sthaniyaKhatm!)}'}');
    }
  }
}
