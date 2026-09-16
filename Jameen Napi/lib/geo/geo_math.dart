import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// 📐 नक्शे के बिंदुओं से दूरी और रकबा — बिना किसी UI के, ताकि test हो सके।
///
/// Pro Kisan (`land_measurement_service.dart`) से यही तरीक़ा लिया है, एक सुधार
/// के साथ: वहाँ पृथ्वी को गोला मानकर एक ही त्रिज्या ली गई थी। यहाँ WGS-84
/// ellipsoid की **उस जगह की** दोनों त्रिज्याएँ लेते हैं (उत्तर-दक्षिण वाली M और
/// पूरब-पश्चिम वाली N)। भारत के अक्षांशों पर गोले वाला हिसाब रकबे में ~0.5%
/// तक का फ़र्क़ डालता था; अब यह 0.01% से नीचे है।
///
/// ⚠️ इकाइयाँ यहाँ से सिर्फ़ **वर्ग फीट** में निकलती हैं। बीघा/कट्ठा वग़ैरह
/// हमेशा `land_units.dart` से बनें — Pro Kisan के बीघा/लट्ठा के मान इस ऐप से
/// मेल नहीं खाते, इसलिए वो नहीं लिए।

/// WGS-84: भूमध्य रेखा पर त्रिज्या (मीटर)
const double _a = 6378137.0;

/// WGS-84: eccentricity²
const double _e2 = 0.00669437999014;

/// पृथ्वी की औसत त्रिज्या — सिर्फ़ लंबी दूरी (haversine) के लिए
const double _meanRadius = 6371008.8;

/// 1 वर्ग मीटर = 10.7639… वर्ग फीट (`land_units.dart` में भी यही मान है)
const double sqFtPerSqMeter = 10.7639104;

/// 1 मीटर = 3.28084 फीट
const double feetPerMeter = 1 / 0.3048;

double _rad(double deg) => deg * math.pi / 180.0;

/// किसी अक्षांश पर 1 रेडियन अक्षांश और देशांतर कितने मीटर का होता है।
({double m, double n}) _radiiAt(double latDeg) {
  final s = math.sin(_rad(latDeg));
  final w = 1 - _e2 * s * s;
  return (m: _a * (1 - _e2) / math.pow(w, 1.5), n: _a / math.sqrt(w));
}

/// बिंदुओं को उनके केंद्र के आसपास समतल (मीटर) में बदलता है।
///
/// खेत या गाँव जितने क्षेत्र के लिए यह बहुत सटीक है। केंद्र को आधार इसलिए
/// लेते हैं कि विकृति सबसे कम रहे।
class LocalProjection {
  LocalProjection._(this.lat0, this.lon0, this._mPerRadLat, this._mPerRadLon);

  factory LocalProjection.around(List<LatLng> points) {
    assert(points.isNotEmpty);
    var lat = 0.0, lon = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    lat /= points.length;
    lon /= points.length;
    final r = _radiiAt(lat);
    return LocalProjection._(lat, lon, r.m, r.n * math.cos(_rad(lat)));
  }

  final double lat0;
  final double lon0;
  final double _mPerRadLat;
  final double _mPerRadLon;

  /// (पूरब की ओर मीटर, उत्तर की ओर मीटर)
  math.Point<double> toMeters(LatLng p) => math.Point(
        _rad(p.longitude - lon0) * _mPerRadLon,
        _rad(p.latitude - lat0) * _mPerRadLat,
      );
}

/// दो बिंदुओं की दूरी (मीटर)।
///
/// 20 किमी तक (खेत, सड़क का टुकड़ा, GPS के दो पड़ोसी बिंदु) ellipsoid वाला
/// स्थानीय हिसाब — सबसे सटीक। उससे लंबी सीधी दूरी पर haversine।
double distanceMeters(LatLng a, LatLng b) {
  final midLat = (a.latitude + b.latitude) / 2;
  final r = _radiiAt(midLat);
  final dy = _rad(b.latitude - a.latitude) * r.m;
  final dx = _rad(b.longitude - a.longitude) * r.n * math.cos(_rad(midLat));
  final local = math.sqrt(dx * dx + dy * dy);
  if (local <= 20000) return local;

  final dLat = _rad(b.latitude - a.latitude);
  final dLon = _rad(b.longitude - a.longitude);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.latitude)) *
          math.cos(_rad(b.latitude)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * _meanRadius * math.asin(math.min(1.0, math.sqrt(h)));
}

/// रेखा की कुल लंबाई (मीटर)। [closed] = true हो तो आख़िरी से पहले बिंदु तक
/// की भुजा भी जुड़ती है (खेत की परिधि)।
double pathLengthMeters(List<LatLng> points, {bool closed = false}) {
  if (points.length < 2) return 0;
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += distanceMeters(points[i - 1], points[i]);
  }
  if (closed && points.length > 2) {
    total += distanceMeters(points.last, points.first);
  }
  return total;
}

/// बंद आकृति का क्षेत्रफल (वर्ग मीटर) — shoelace सूत्र, स्थानीय मीटरों में।
double polygonAreaSqMeters(List<LatLng> points) {
  if (points.length < 3) return 0;
  final proj = LocalProjection.around(points);
  final xy = points.map(proj.toMeters).toList();
  var sum = 0.0;
  for (var i = 0; i < xy.length; i++) {
    final p = xy[i];
    final q = xy[(i + 1) % xy.length];
    sum += p.x * q.y - q.x * p.y;
  }
  return sum.abs() / 2;
}

/// बंद आकृति का क्षेत्रफल (वर्ग फीट) — `land_units.dart` की इकाइयों के लिए।
double polygonAreaSqFt(List<LatLng> points) =>
    polygonAreaSqMeters(points) * sqFtPerSqMeter;

/// क्या खेत की सीमा ख़ुद को कहीं काट रही है?
///
/// बिंदु गलत क्रम में लगें (जैसे 1-2-4-3) तो आकृति "8" जैसी बनती है और
/// shoelace दोनों हिस्सों को घटा देता है — रकबा बहुत कम दिखता है। ऐसे में
/// user को चेतावनी दिखनी चाहिए।
bool isSelfIntersecting(List<LatLng> points) {
  final n = points.length;
  if (n < 4) return false;
  final proj = LocalProjection.around(points);
  final xy = points.map(proj.toMeters).toList();

  for (var i = 0; i < n; i++) {
    final a1 = xy[i], a2 = xy[(i + 1) % n];
    for (var j = i + 1; j < n; j++) {
      // पड़ोसी भुजाएँ एक कोना साझा करती हैं — वो "कटना" नहीं है
      if (j == i || (j + 1) % n == i || (i + 1) % n == j) continue;
      final b1 = xy[j], b2 = xy[(j + 1) % n];
      if (_segmentsCross(a1, a2, b1, b2)) return true;
    }
  }
  return false;
}

bool _segmentsCross(math.Point<double> p1, math.Point<double> p2,
    math.Point<double> q1, math.Point<double> q2) {
  double orient(math.Point<double> a, math.Point<double> b,
          math.Point<double> c) =>
      (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
  final d1 = orient(q1, q2, p1);
  final d2 = orient(q1, q2, p2);
  final d3 = orient(p1, p2, q1);
  final d4 = orient(p1, p2, q2);
  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

/// एक GPS reading — जगह, कितनी सटीक (मीटर), और कब।
class GpsFix {
  const GpsFix(this.position, this.accuracyMeters, this.time);

  final LatLng position;
  final double accuracyMeters;
  final DateTime time;
}

/// कोने पर खड़े होकर ली गई कई readings का औसत।
///
/// हर reading को 1/accuracy² का वज़न मिलता है — जो reading ज़्यादा सटीक है
/// उसकी बात ज़्यादा मानी जाती है। [maxAccuracy] से ख़राब readings छोड़ दी
/// जाती हैं; सब ख़राब हों तो सबसे अच्छी वाली ही लौटती है (ताकि किसान अटके
/// नहीं), और [CornerEstimate.isWeak] true रहता है।
CornerEstimate averageFixes(List<GpsFix> fixes, {double maxAccuracy = 15}) {
  if (fixes.isEmpty) {
    throw ArgumentError('कम से कम एक GPS reading चाहिए');
  }
  final good = fixes.where((f) => f.accuracyMeters <= maxAccuracy).toList();
  if (good.isEmpty) {
    final best =
        fixes.reduce((a, b) => a.accuracyMeters <= b.accuracyMeters ? a : b);
    return CornerEstimate(best.position, best.accuracyMeters, 1, isWeak: true);
  }

  var wSum = 0.0, lat = 0.0, lon = 0.0;
  for (final f in good) {
    final acc = math.max(f.accuracyMeters, 1.0);
    final w = 1 / (acc * acc);
    wSum += w;
    lat += f.position.latitude * w;
    lon += f.position.longitude * w;
  }
  // कई स्वतंत्र readings मिलाने पर अनुमानित सटीकता √(1/Σw)
  return CornerEstimate(
    LatLng(lat / wSum, lon / wSum),
    math.sqrt(1 / wSum),
    good.length,
    isWeak: false,
  );
}

class CornerEstimate {
  const CornerEstimate(this.position, this.accuracyMeters, this.samplesUsed,
      {required this.isWeak});

  final LatLng position;
  final double accuracyMeters;
  final int samplesUsed;

  /// कोई भी reading [averageFixes] की सटीकता-शर्त पर खरी नहीं उतरी
  final bool isWeak;
}

/// चलते हुए (या गाड़ी से) GPS track बनाते समय कौन-सा बिंदु रखें, कौन छोड़ें।
///
/// तीन शर्तें:
/// 1. reading बहुत ख़राब न हो ([maxAccuracy])
/// 2. पिछले बिंदु से कम से कम [minGapMeters] दूर हो — वरना खड़े-खड़े GPS के
///    हिलने से ही दूरी बढ़ती जाती है
/// 3. पिछले बिंदु से छलांग असंभव न हो ([maxSpeedMps]) — GPS कभी-कभी 50-100 मी
///    कूद जाता है, वो बिंदु जुड़ जाए तो सड़क की दूरी ग़लत बढ़ती है
class TrackFilter {
  TrackFilter({
    this.maxAccuracy = 20,
    this.minGapMeters = 3,
    this.maxSpeedMps = 45,
  });

  /// पैदल: 3 मी का फ़ासला, 7 मी/से (दौड़ने से भी तेज़) की सीमा
  factory TrackFilter.walking() =>
      TrackFilter(maxAccuracy: 20, minGapMeters: 3, maxSpeedMps: 7);

  /// बाइक/गाड़ी: 10 मी का फ़ासला, 45 मी/से (162 किमी/घंटा) की सीमा
  factory TrackFilter.vehicle() =>
      TrackFilter(maxAccuracy: 25, minGapMeters: 10, maxSpeedMps: 45);

  final double maxAccuracy;
  final double minGapMeters;
  final double maxSpeedMps;

  GpsFix? _last;

  /// आख़िरी रखा गया बिंदु
  GpsFix? get last => _last;

  /// true = यह बिंदु track में जोड़ो।
  bool accept(GpsFix fix) {
    if (fix.accuracyMeters > maxAccuracy) return false;
    final prev = _last;
    if (prev == null) {
      _last = fix;
      return true;
    }
    final d = distanceMeters(prev.position, fix.position);
    if (d < minGapMeters) return false;

    final seconds = fix.time.difference(prev.time).inMilliseconds / 1000;
    // समय पीछे चला जाए या शून्य हो तो रफ़्तार नहीं जाँच सकते — दूरी से ही तय करें
    if (seconds > 0 && d / seconds > maxSpeedMps) return false;

    _last = fix;
    return true;
  }

  /// Pause के बाद दोबारा शुरू करते समय — वरना रुकने के दौरान user जितना
  /// आगे गया, वो पहला बिंदु "असंभव छलांग" मानकर छूटता रहेगा। (रुकने से पहले
  /// और बाद के बिंदुओं को सीधी रेखा से न जोड़ना screen का काम है — वो नया
  /// टुकड़ा शुरू करती है।)
  void reset() => _last = null;
}
