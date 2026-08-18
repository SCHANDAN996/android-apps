import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../data/india_states.dart';

/// 📐 खेत का रकबा — GPS बिंदुओं से।
///
/// ⚠️ यहाँ का गणित पहले दो जगह गलत था, दोनों ठीक किए गए हैं:
///
/// **1. देशांतर (longitude) की चौड़ाई अक्षांश पर निर्भर करती है।**
///    पहले दोनों दिशाओं में 1° = 111,320 मी मान लिया गया था। यह अक्षांश के लिए
///    तो ठीक है, पर देशांतर के लिए नहीं — वहाँ 1° = 111,320 × cos(अक्षांश)।
///    वाराणसी (25.3°N) पर इससे रकबा **+10.6%**, लुधियाना (30.9°N) पर **+16.5%**
///    ज़्यादा दिखता था। अब हर बिंदु को खेत के केंद्र के आसपास मीटर में बदलकर
///    (equirectangular projection) नापते हैं — खेत जितने छोटे क्षेत्र के लिए
///    यह तरीक़ा बहुत सटीक है।
///
/// **2. बीघा को एकड़ के बराबर मान लिया गया था** (`bigha = acres / 1.0`)।
///    बीघा हर राज्य में अलग होता है और ऐप के पास `india_states.dart` में सही
///    आँकड़े पहले से हैं (UP 27,000 वर्ग फुट, पंजाब 9,070, MP 12,000...)।
///    अब वही इस्तेमाल होते हैं — पहले UP में 1.61 बीघा को 1.0 दिखाया जाता था।
class LandMeasurementService {
  static final LandMeasurementService instance = LandMeasurementService._();
  LandMeasurementService._();

  /// पृथ्वी की त्रिज्या (मीटर) — WGS-84 का औसत
  static const double _earthRadius = 6378137.0;

  /// 1 एकड़ = 43,560 वर्ग फुट
  static const double _sqFtPerAcre = 43560.0;

  /// 1 वर्ग मीटर = 10.7639 वर्ग फुट
  static const double _sqFtPerSqM = 10.763910417;

  // ── लट्ठा / फ़ीट / गज → मीटर conversion ──
  /// 1 लट्ठा = 99 इंच = 8.25 फ़ीट = 2.5146 मीटर
  static const double lathaToMeters = 2.5146;
  static const double feetToMeters = 0.3048;
  static const double yardToMeters = 0.9144;

  final List<LatLng> _points = [];
  bool _isMeasuring = false;

  void startMeasurement() {
    _points.clear();
    _isMeasuring = true;
  }

  void stopMeasurement() => _isMeasuring = false;

  /// नया GPS बिंदु जोड़ो। बहुत पास वाले बिंदु छोड़ देते हैं ताकि खड़े-खड़े
  /// GPS के हिलने से आकृति बिगड़े नहीं।
  void addPoint(LatLng point, {double minGapMeters = 2.0}) {
    if (!_isMeasuring) return;
    if (_points.isNotEmpty) {
      final d = distanceBetween(_points.last, point);
      if (d < minGapMeters) return;
    }
    _points.add(point);
  }

  /// किसी पॉइंट की जगह बदलो (drag करने पर) — Tap Mode के लिए
  void updatePoint(int index, LatLng newPosition) {
    if (index >= 0 && index < _points.length) {
      _points[index] = newPosition;
    }
  }

  /// आख़िरी बिंदु हटाओ (गलती सुधारने के लिए)
  void removeLastPoint() {
    if (_points.isNotEmpty) _points.removeLast();
  }

  int get pointCount => _points.length;
  bool get isMeasuring => _isMeasuring;
  List<LatLng> get points => List.unmodifiable(_points);

  void reset() {
    _points.clear();
    _isMeasuring = false;
  }

  /// पॉइंट्स को बाहर से सेट करो (saved fields लोड करने के लिए)
  void loadPoints(List<LatLng> pts) {
    _points
      ..clear()
      ..addAll(pts);
    _isMeasuring = false;
  }

  /// दो बिंदुओं के बीच की दूरी (मीटर) — haversine
  static double distanceBetween(LatLng a, LatLng b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * _earthRadius * math.asin(math.min(1.0, math.sqrt(h)));
  }

  /// खेत की परिधि (मीटर) — बंद आकृति मानकर
  double perimeterMeters() {
    if (_points.length < 2) return 0;
    double p = 0;
    for (int i = 0; i < _points.length; i++) {
      p += distanceBetween(_points[i], _points[(i + 1) % _points.length]);
    }
    return p;
  }

  /// 📐 क्षेत्रफल — सीधे **वर्ग मीटर** में।
  ///
  /// तरीक़ा: खेत के केंद्र को शून्य मानकर हर बिंदु को मीटर में बदलो
  /// (x = R·Δlon·cos(lat₀), y = R·Δlat), फिर shoelace लगाओ।
  double areaSquareMeters() {
    if (_points.length < 3) return 0.0;

    // केंद्र (सिर्फ़ projection का आधार — इससे विकृति सबसे कम रहती है)
    final lat0 = _points.map((p) => p.latitude).reduce((a, b) => a + b) /
        _points.length;
    final lon0 = _points.map((p) => p.longitude).reduce((a, b) => a + b) /
        _points.length;
    final cosLat0 = math.cos(_rad(lat0));

    // मीटर में बदलो
    final xs = <double>[];
    final ys = <double>[];
    for (final p in _points) {
      xs.add(_rad(p.longitude - lon0) * _earthRadius * cosLat0);
      ys.add(_rad(p.latitude - lat0) * _earthRadius);
    }

    // shoelace
    double sum = 0;
    for (int i = 0; i < xs.length; i++) {
      final j = (i + 1) % xs.length;
      sum += xs[i] * ys[j] - xs[j] * ys[i];
    }
    return sum.abs() / 2.0;
  }

  /// सभी इकाइयों में नतीजा। बीघा उपयोगकर्ता के राज्य के हिसाब से।
  AreaResult getAreaInAllUnits({String? stateCode}) {
    final sqM = areaSquareMeters();
    final bighaSqFt =
        stateCode == null ? null : stateByCode(stateCode).bighaSqFt;

    return AreaResult(
      squareMeters: sqM,
      hectares: sqM / 10000.0,
      acres: sqM * _sqFtPerSqM / _sqFtPerAcre,
      // राज्य में बीघा चलता ही न हो तो null — UI तब बीघा दिखाएगा ही नहीं
      bigha: bighaSqFt == null ? null : (sqM * _sqFtPerSqM) / bighaSqFt,
      bighaSqFt: bighaSqFt,
      perimeterMeters: perimeterMeters(),
      points: List.of(_points),
    );
  }

  // ── लंबाई × चौड़ाई कैलकुलेटर (GPS बिना) ──

  /// यूनिट कोड → मीटर में बदलने का गुणक
  static double unitToMeters(String unit) {
    switch (unit) {
      case 'latha':
        return lathaToMeters; // 99 इंच = 2.5146 मीटर
      case 'feet':
        return feetToMeters;
      case 'yard':
        return yardToMeters;
      case 'meter':
      default:
        return 1.0;
    }
  }

  /// लंबाई × चौड़ाई से क्षेत्रफल (GPS ज़रूरत नहीं)
  static AreaResult calculateFromLW({
    required double length,
    required double width,
    required String unit,
    required String shape,
    String? stateCode,
  }) {
    final m = unitToMeters(unit);
    final lM = length * m; // लंबाई मीटर में
    final wM = width * m; // चौड़ाई मीटर में

    double sqM;
    double perimeter;
    if (shape == 'triangle') {
      sqM = 0.5 * lM * wM;
      // त्रिभुज की तीसरी भुजा (कर्ण) — अनुमान
      final hyp = math.sqrt(lM * lM + wM * wM);
      perimeter = lM + wM + hyp;
    } else {
      // rectangle (default)
      sqM = lM * wM;
      perimeter = 2 * (lM + wM);
    }

    final bighaSqFt =
        stateCode == null ? null : stateByCode(stateCode).bighaSqFt;

    return AreaResult(
      squareMeters: sqM,
      hectares: sqM / 10000.0,
      acres: sqM * _sqFtPerSqM / _sqFtPerAcre,
      bigha: bighaSqFt == null ? null : (sqM * _sqFtPerSqM) / bighaSqFt,
      bighaSqFt: bighaSqFt,
      perimeterMeters: perimeter,
      points: const [], // GPS पॉइंट्स नहीं हैं
    );
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}

/// नापने का नतीजा
class AreaResult {
  final double squareMeters;
  final double hectares;
  final double acres;

  /// उपयोगकर्ता के राज्य के हिसाब से बीघा। राज्य में बीघा न चलता हो तो null।
  final double? bigha;

  /// उस राज्य में 1 बीघा कितने वर्ग फुट का है (दिखाने के लिए)
  final double? bighaSqFt;

  final double perimeterMeters;
  final List<LatLng> points;

  const AreaResult({
    required this.squareMeters,
    required this.hectares,
    required this.acres,
    required this.bigha,
    required this.bighaSqFt,
    required this.perimeterMeters,
    required this.points,
  });

  bool get isEmpty => points.length < 3 && squareMeters <= 0;
}

