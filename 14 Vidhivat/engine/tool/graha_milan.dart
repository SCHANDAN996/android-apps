// JPL Horizons से ग्रहों का मिलान — हर पिंड का सबसे बड़ा फ़र्क़, विकला में।
//
//     dart run tool/graha_milan.dart
//
// जाँच `test/graha_test.dart` में है; यह औज़ार नाप देखने के लिए है।
import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

void main() {
  final j = jsonDecode(File('test/data/horizons_graha.json').readAsStringSync())
      as Map<String, dynamic>;
  final jd = (j['jdTt'] as List).cast<num>();
  final pind = j['pind'] as Map<String, dynamic>;

  double lon(String naam, double jde) => switch (naam) {
        'surya' => sunApparentLongitude(jde),
        'chandra' => moonLongitude(jde),
        _ => grahaLongitude(Graha.values.byName(naam), jde),
      };
  double? lat(String naam, double jde) => switch (naam) {
        'surya' => null,
        'chandra' => moonLatitude(jde),
        _ => grahaApparent(Graha.values.byName(naam), jde).latitude,
      };

  for (final naam in pind.keys) {
    final rows = pind[naam] as List;
    var badaL = 0.0, badaB = 0.0, jodL = 0.0;
    for (var i = 0; i < jd.length; i++) {
      final t = jd[i].toDouble();
      final dl = norm180(lon(naam, t) - (rows[i][0] as num)) * 3600;
      jodL += dl;
      if (dl.abs() > badaL.abs()) badaL = dl;
      final b = lat(naam, t);
      if (b != null) {
        final db = (b - (rows[i][1] as num)) * 3600;
        if (db.abs() > badaB.abs()) badaB = db;
      }
    }
    stdout.writeln('${naam.padRight(8)} देशांतर: सबसे बड़ा फ़र्क़ '
        '${badaL.toStringAsFixed(2).padLeft(7)}" · औसत '
        '${(jodL / jd.length).toStringAsFixed(2).padLeft(6)}" · '
        'अक्षांश: ${badaB.toStringAsFixed(2).padLeft(6)}"');
  }
  var bada = 0.0;
  for (final t in jd) {
    final d = norm180(sunLongitudeVsop(t.toDouble()) -
            sunApparentLongitude(t.toDouble())) *
        3600;
    if (d.abs() > bada.abs()) bada = d;
  }
  stdout.writeln('सूर्य: VSOP वाला − पंचांग वाला, सबसे बड़ा फ़र्क़ '
      '${bada.toStringAsFixed(2)}"');
}
