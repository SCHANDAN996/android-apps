import 'package:panchang_engine/panchang_engine.dart';

/// इंजन की गति — किसी सूत्र को बदलने से पहले और बाद में (→ D-097, D-104)।
///
///   dart run tool/gati_naap.dart
void main() {
  final sw = Stopwatch();
  double naap(void Function() f) {
    f(); // गरम करना
    sw
      ..reset()
      ..start();
    f();
    sw.stop();
    return sw.elapsedMicroseconds / 1000.0;
  }

  final a = naap(() {
    var x = 0.0;
    for (var i = 0; i < 20000; i++) {
      x += sunApparentLongitude(2461000.5 + i * 0.37);
    }
    if (x.isNaN) throw StateError('nan');
  });
  final b = naap(() {
    for (var d = 1; d <= 28; d++) {
      computePanchang(2026, 10, d, Place.patna);
    }
  });
  final c = naap(() {
    for (var i = 0; i < 365; i++) {
      final t = DateTime.utc(2027, 1, 1).add(Duration(days: i));
      suryodayaTithi(t.year, t.month, t.day, Place.patna);
    }
  });
  final d = naap(() => festivalsInYear(2029, Place.jaipur));
  print('सूर्य का देशांतर, 20,000 बार : ${a.toStringAsFixed(1)} ms '
      '(${(a * 1000 / 20000).toStringAsFixed(2)} µs हर बार)');
  print('computePanchang, 28 दिन      : ${b.toStringAsFixed(1)} ms');
  print('suryodayaTithi, 365 दिन      : ${c.toStringAsFixed(1)} ms');
  print('festivalsInYear, एक साल     : ${d.toStringAsFixed(1)} ms');
}
