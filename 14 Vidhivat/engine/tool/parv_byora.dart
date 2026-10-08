// एक त्योहार का पूरा ब्योरा, साल-दर-साल — तिथि कब से कब, अगली तिथि कब तक,
// भद्रा, और आस-पास के हर दिन का सूर्योदय, सूर्यास्त और पाँचों काल में तिथि
// कितनी देर रही। नियम बदलने से पहले यही देखो (→ D-117)।
//
//     dart run tool/parv_byora.dart holika_dahan 2024 2030
//     dart run tool/parv_byora.dart janmashtami 2024 2030     (रोहिणी भी)
//
// यह जाँच का औज़ार है, ऐप इसे नहीं बुलाता। समय भारतीय (IST)।
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

String ghadi(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String t(DateTime d) => '${d.day.toString().padLeft(2)}/${d.month} ${ghadi(d)}';

String avadhi(Duration d) => d.isNegative || d == Duration.zero
    ? '—'
    : '${d.inHours}घं${(d.inMinutes % 60).toString().padLeft(2, '0')}मि';

Duration chhua(DateTime a0, DateTime a1, DateTime b0, DateTime b1) {
  final s = a0.isAfter(b0) ? a0 : b0;
  final e = a1.isBefore(b1) ? a1 : b1;
  return e.isAfter(s) ? e.difference(s) : Duration.zero;
}

void main(List<String> argv) {
  if (argv.isEmpty) {
    stderr
        .writeln('dart run tool/parv_byora.dart <id> [पहला साल] [आख़िरी साल]');
    exit(64);
  }
  final rule = festivalRules.firstWhere((r) => r.id == argv[0]);
  final y0 = argv.length > 1 ? int.parse(argv[1]) : 2024;
  final y1 = argv.length > 2 ? int.parse(argv[2]) : y0;
  const place = Place.delhi;
  DateTime local(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  for (var y = y0; y <= y1; y++) {
    final f = findFestival(rule, y, place);
    if (f == null) {
      stdout.writeln('══ $y — नहीं मिला');
      continue;
    }
    // अगली तिथि का अंत (वृद्धि/ह्रास देखने के लिए)
    final startJd = julianDayFromUtc(f.tithiEnd.subtract(place.timeZoneOffset));
    final agliAnsh = ((rule.tithiIndex + 2) * 12.0) % 360.0;
    final agliEnd =
        local(findCrossing(elongationAt, agliAnsh, startJd + 0.01, 3)!);

    stdout.writeln('══ $y ${rule.name} — इंजन: ${f.date.day}/${f.date.month}'
        '${f.shiftedForBhadra ? " · भद्रा से खिसका" : ""}'
        '${f.missedKaal ? " · काल छूटा" : ""}${f.ambiguous ? " · दो दावेदार" : ""}');
    stdout.writeln('   ${rule.tithiName}: ${t(f.tithiStart)} → ${t(f.tithiEnd)}'
        ' (${avadhi(f.tithiEnd.difference(f.tithiStart))})'
        ' · अगली तिथि ${t(agliEnd)} तक (${avadhi(agliEnd.difference(f.tithiEnd))})');
    for (final line in f.explanation.split('\n')) {
      if (line.startsWith('भद्रा —')) stdout.writeln('   $line');
    }

    if (rule.id == 'janmashtami') {
      // रोहिणी = चौथा नक्षत्र, 40° से 53°20′
      final r0 = findCrossing(moonSiderealAt, 40.0, startJd - 3.0, 6);
      if (r0 != null) {
        final r1 =
            findCrossing(moonSiderealAt, 40.0 + 360.0 / 27.0, r0 + 0.01, 3)!;
        final a = local(r0), b = local(r1);
        stdout.writeln('   रोहिणी: ${t(a)} → ${t(b)} · अष्टमी के साथ '
            '${avadhi(chhua(a, b, f.tithiStart, f.tithiEnd))}');
      }
    }

    final pehla =
        DateTime.utc(f.tithiStart.year, f.tithiStart.month, f.tithiStart.day);
    for (var k = 0; k <= 2; k++) {
      final d = pehla.add(Duration(days: k));
      final rs = sunriseSunset(d.year, d.month, d.day, place);
      final n = d.add(const Duration(days: 1));
      final rs2 = sunriseSunset(n.year, n.month, n.day, place);
      if (rs.sunrise == null || rs.sunset == null || rs2.sunrise == null)
        continue;
      final uday = rs.sunrise!.add(place.timeZoneOffset);
      final ast = rs.sunset!.add(place.timeZoneOffset);
      final agla = rs2.sunrise!.add(place.timeZoneOffset);
      final din = chhua(f.tithiStart, f.tithiEnd, uday, agla);
      if (din == Duration.zero) continue;
      final udayKeBaad = f.tithiStart.isAfter(uday)
          ? Duration.zero
          : chhua(f.tithiStart, f.tithiEnd, uday, agla);
      final yaam = ast.difference(uday) * (1 / 4);
      final buf = StringBuffer('   ${d.day.toString().padLeft(2)}/${d.month} '
          'उदय ${ghadi(uday)} अस्त ${ghadi(ast)} · '
          'उदय के बाद तिथि ${avadhi(udayKeBaad)} '
          '(3 मुहूर्त ${avadhi(ast.difference(uday) * (3 / 15))}, '
          'साढ़े तीन याम ${avadhi(yaam * 3.5)}) ·');
      for (final v in Vyapini.values) {
        final w = kaalWindow(v, d.year, d.month, d.day, place);
        if (w == null) continue;
        final c = chhua(f.tithiStart, f.tithiEnd, w.start, w.end);
        if (v == Vyapini.sunrise || v == Vyapini.chandrodaya) {
          buf.write(' ${v.kaalName}${c > Duration.zero ? "✓" : "✗"}');
        } else {
          buf.write(' ${v.kaalName} ${ghadi(w.start)}–${ghadi(w.end)}'
              '[${avadhi(c)}]');
        }
      }
      stdout.writeln(buf);
    }
  }
}
