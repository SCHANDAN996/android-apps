// गुरु या शुक्र सूर्य के पास कब हैं — रोज़ का ब्योरा: देशांतर का अंतर, सूर्यास्त के
// कितनी देर बाद ग्रह डूबता है, सूर्योदय से कितनी देर पहले उगता है, और उस पल
// सूर्य क्षितिज से कितना नीचे है। अस्त का नियम समझने और जाँचने के लिए
// (→ D-119, docs/08 §21)।
//
//     dart run tool/ast_byora.dart guru 2026-07-08 2026-08-18
//     dart run tool/ast_byora.dart shukra 2026-10-05 2026-11-03
//
// यह जाँच का औज़ार है, ऐप इसे नहीं बुलाता। समय भारतीय (IST), जगह दिल्ली।
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

const place = Place.delhi;

String ghadi(DateTime? d) => d == null
    ? '  —  '
    : '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String minute(Duration? d) =>
    d == null ? '     —' : (d.inSeconds / 60.0).toStringAsFixed(1).padLeft(6);

/// उस स्थानीय पल पर सूर्य क्षितिज से कितना नीचे है, अंश में।
String suryaNeeche(DateTime? sthaniya) {
  if (sthaniya == null) return '    —';
  final jd = julianDayFromUtc(sthaniya.subtract(place.timeZoneOffset));
  return '${(-sunAltitude(jd, place)).toStringAsFixed(1).padLeft(5)}°';
}

void main(List<String> argv) {
  if (argv.length < 3) {
    stderr.writeln(
        'dart run tool/ast_byora.dart <guru|shukra> <YYYY-MM-DD> <YYYY-MM-DD>');
    exit(64);
  }
  final g = argv[0] == 'guru' ? Graha.guru : Graha.shukra;
  var d = DateTime.parse('${argv[1]}T00:00:00Z');
  final ant = DateTime.parse('${argv[2]}T00:00:00Z');

  stdout.writeln(
      'तारीख़      देशांतर-अंतर  वक्री | सूर्यास्त ग्रह-अस्त  बाद(मि) सूर्य-नीचे | '
      'ग्रह-उदय सूर्योदय पहले(मि) सूर्य-नीचे');
  while (!d.isAfter(ant)) {
    final rs = sunriseSunset(d.year, d.month, d.day, place);
    final uday = rs.sunrise!.add(place.timeZoneOffset);
    final ast = rs.sunset!.add(place.timeZoneOffset);
    final jde = toEphemerisTime(julianDayFromUtc(rs.sunset!));
    final r = grahaUdayAst(g, d.year, d.month, d.day, place)!;

    stdout.writeln('${d.toIso8601String().substring(0, 10)}  '
        '${grahaSuryaAntar(g, jde).toStringAsFixed(2).padLeft(7)}°  '
        '${grahaVakri(g, jde) ? "वक्री" : "  —  "} | '
        '${ghadi(ast)}     ${ghadi(r.ast)}   ${minute(r.suryastKeBaad)} '
        '${suryaNeeche(r.ast)} | '
        '${ghadi(r.uday)}    ${ghadi(uday)}   ${minute(r.suryodaySePehle)} '
        '${suryaNeeche(r.uday)}');
    d = d.add(const Duration(days: 1));
  }
}
