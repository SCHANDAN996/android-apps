// गुरु या शुक्र के अस्त-काल, दोनों तरीक़ों से — संदर्भ-पंचांग और छपी सूचियों के
// सामने रखने के लिए (→ D-119, docs/08 §21):
//
//   अंश    — देशांतर का अंतर कालांश से कम (गुरु 11°, शुक्र 10°, वक्री 8°)
//   कालांश — ग्रह का उदय/अस्त सूर्य के उदय/अस्त से (कालांश × 60 असु) के भीतर
//
//     dart run tool/ast_aazmao.dart guru 2024 2027
//     dart run tool/ast_aazmao.dart shukra 2024 2027 mumbai
//
// यह जाँच का औज़ार है, ऐप इसे नहीं बुलाता। समय भारतीय (IST)।
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

String pal(DateTime d) =>
    '${d.day.toString().padLeft(2)}/${d.month.toString().padLeft(2)}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String din(DateTime d) => '${d.day}/${d.month}';

void main(List<String> argv) {
  if (argv.length < 3) {
    stderr.writeln(
        'dart run tool/ast_aazmao.dart <guru|shukra> <पहला साल> <आख़िरी साल> [mumbai]');
    exit(64);
  }
  final g = argv[0] == 'guru' ? Graha.guru : Graha.shukra;
  final se = DateTime.utc(int.parse(argv[1]), 1, 1);
  final tak = DateTime.utc(int.parse(argv[2]), 12, 31);
  final place =
      argv.length > 3 && argv[3] == 'mumbai' ? Place.mumbai : Place.delhi;

  for (final ganana in AstGanana.values) {
    stdout.writeln(
        '── ${g.naam} · ${ganana == AstGanana.ansh ? "अंश" : "कालांश"} · ${place.name}');
    for (final a in grahaAstKaal(g, se, tak, place, ganana: ganana)) {
      stdout.writeln(
          '  अस्त ${pal(a.ast)} (${a.astPurvMein ? "पूर्व" : "पश्चिम"}) → '
          'उदय ${pal(a.uday)} (${a.udayPurvMein ? "पूर्व" : "पश्चिम"}) · '
          '${a.udayDin.difference(a.astDin).inDays} दिन · कालांश ${a.kalansh} · '
          'वृद्ध ${din(a.vardhakShuru)} से (${a.vardhakDin}) · बाल ${din(a.balyaAnt)} तक (${a.balyaDin})');
    }
  }
}
