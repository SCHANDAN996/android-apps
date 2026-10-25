// शुभ मुहूर्त — दोनों ग्रंथों वाले नियमों से 2026 की सूचियाँ, और website वाली
// गृह प्रवेश सूची से फ़र्क़ (→ D-148)। `dart run tool/muhurat_naap.dart`
import 'package:panchang_engine/panchang_engine.dart';

import '../test/shubh_muhurat_test.dart' show drikGrihaPravesh2026;

void main() {
  for (final a in Activity.values) {
    final list = shubhDinList(a, 2026, Place.delhi);
    print('## ${ruleFor(a).name} — ${list.length} दिन');
    print('   ${list.map((d) => '${d.date.month}-${d.date.day}').join(' ')}');
  }

  final hamara = shubhDinList(Activity.grihaPravesh, 2026, Place.delhi);
  final h = {for (final d in hamara) '${d.date.month}-${d.date.day}'};
  final w = drikGrihaPravesh2026.toSet();
  print('');
  print('गृह प्रवेश 2026 — website सूची से: मिले ${w.intersection(h).length}/${w.length}'
      ' · छूटे ${w.difference(h).length} · फ़ालतू ${h.difference(w).length}');
  print('छूटे:');
  for (final s in w.difference(h)) {
    final parts = s.split('-').map(int.parse).toList();
    final p = computePanchang(2026, parts[0], parts[1], Place.delhi,
        masaSystem: MasaSystem.amanta);
    print('   $s  ${p.masaFullName} ${p.pakshaName} ${p.tithi.name} '
        '${p.varaName} ${p.nakshatra.name} अयन=${p.ayanaName}');
  }
  print('फ़ालतू: ${h.difference(w).join(' ')}');
}
