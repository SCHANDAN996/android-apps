// एक नियम को हर व्यापिनी से चलाकर देखना कि कौन सी किन सालों में कौन सी तारीख़ देती है
// (→ D-117)। नियम बदलने से पहले यही नापा जाता है — अंदाज़े से व्यापिनी नहीं बदली जाती।
//
//     dart run tool/vyapini_aazmao.dart chhath 2024 2030
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

void main(List<String> args) {
  final id = args[0];
  final a = int.parse(args[1]), b = int.parse(args[2]);
  final asli = festivalRules.firstWhere((r) => r.id == id);
  stdout.writeln('${asli.name} — अभी: ${asli.vyapini.name}');
  for (final v in Vyapini.values) {
    final rule = FestivalRule(
      id: asli.id,
      name: asli.name,
      masa: asli.masa,
      paksha: asli.paksha,
      tithi: asli.tithi,
      vyapini: v,
      avoidBhadra: asli.avoidBhadra,
      masaSystem: asli.masaSystem,
      vaarPehle: asli.vaarPehle,
    );
    final buf = StringBuffer('${v.name.padRight(12)}');
    for (var y = a; y <= b; y++) {
      final f = findFestival(rule, y, Place.delhi);
      final d = f?.date;
      buf.write(d == null
          ? '  $y: —    '
          : '  $y: ${d.day.toString().padLeft(2)}/${d.month.toString().padLeft(2)}'
              '${f!.missedKaal ? '*' : f.ambiguous ? '?' : ' '}');
    }
    stdout.writeln(buf);
  }
  stdout.writeln(
      '* = काल छूटा (तिथि उस खिड़की को किसी दिन नहीं छूती) · ? = दो दावेदार');
}
