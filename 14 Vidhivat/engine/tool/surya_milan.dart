import 'package:panchang_engine/panchang_engine.dart';

/// पंचांग का सूर्य (Meeus 25, छोटा सूत्र) बनाम VSOP87 वाला सूर्य — **नापकर**
/// (→ D-102 का दूसरा फ़ैसला, D-104)।
///
///   dart run tool/surya_milan.dart
///
/// संदर्भ: Drik के छपे हुए कन्या-संक्रांति के क्षण (2023–2028, IST, मिनट तक)।
/// संक्रांति वही जगह है जहाँ सूर्य की ग़लती सबसे बड़ी बनकर दिखती है: सूर्य 59′
/// रोज़ चलता है, तो 1 विकला = 24 सेकंड।

const _drik = {
  2023: (9, 17, 13, 43),
  2024: (9, 16, 19, 53),
  2025: (9, 17, 1, 55),
  2026: (9, 17, 7, 58),
  2027: (9, 17, 14, 14),
  2028: (9, 16, 20, 23),
};

/// वह क्षण (JD, UT) जब [surya] का निरयन देशांतर [ansh] को पार करता है।
double _pal(double Function(double jde) surya, double jdShuru, double ansh) {
  double f(double jd) {
    final jde = toEphemerisTime(jd);
    return norm180(toSidereal(surya(jde), jde) - ansh);
  }

  var a = jdShuru, b = jdShuru + 4;
  assert(f(a) < 0 && f(b) > 0);
  for (var i = 0; i < 60; i++) {
    final m = (a + b) / 2;
    if (f(m) < 0) {
      a = m;
    } else {
      b = m;
    }
  }
  return (a + b) / 2;
}

void main() {
  print('कन्या संक्रांति — Drik से फ़र्क़ (सेकंड; + = हमारा बाद में)');
  print('साल    छोटा सूत्र   VSOP');
  var sabseBadaChhota = 0.0, sabseBadaVsop = 0.0;
  for (final MapEntry(key: saal, value: (m, d, h, min)) in _drik.entries) {
    final drikUtc = DateTime.utc(saal, m, d, h, min)
        .subtract(const Duration(hours: 5, minutes: 30));
    final jdDrik = julianDayFromUtc(drikUtc);
    final chhota =
        (_pal(sunApparentLongitudeLaghu, jdDrik - 2, 150) - jdDrik) * 86400;
    final vsop = (_pal(sunApparentLongitude, jdDrik - 2, 150) - jdDrik) * 86400;
    if (chhota.abs() > sabseBadaChhota) sabseBadaChhota = chhota.abs();
    if (vsop.abs() > sabseBadaVsop) sabseBadaVsop = vsop.abs();
    print('$saal   ${chhota.toStringAsFixed(0).padLeft(8)}   '
        '${vsop.toStringAsFixed(0).padLeft(6)}');
  }
  print('सबसे बड़ा: छोटा सूत्र ${sabseBadaChhota.toStringAsFixed(0)} से, '
      'VSOP ${sabseBadaVsop.toStringAsFixed(0)} से');
  print('(Drik मिनट तक ही छापता है — ±30 सेकंड उसकी अपनी गोलाई है।)');
}
