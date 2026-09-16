import 'package:latlong2/latlong.dart';

import 'geo_math.dart';

/// क्या नाप रहे हैं — खेत का रकबा या रास्ते की लंबाई।
enum MeasureKind { area, distance }

/// कैसे नाप रहे हैं।
enum MeasureMethod {
  /// नक्शे पर उंगली से बिंदु लगाकर
  tap,

  /// खेत के हर कोने पर रुककर, कुछ सेकंड की GPS readings के औसत से
  walkCorners,

  /// चलते/गाड़ी से जाते हुए GPS अपने आप रेखा बनाता है
  track,
}

/// एक नाप — बिंदुओं की सूची, जो pause होने पर टुकड़ों में बँटती है।
///
/// **टुकड़े क्यों?** सड़क नापते हुए user रुककर चाय पीने गया और 200 मी दूर
/// से दोबारा शुरू किया — तो रुकने से पहले और बाद के बिंदु सीधी रेखा से नहीं
/// जुड़ने चाहिए। दूरी हर टुकड़े की अलग-अलग जोड़ी जाती है।
///
/// रकबे में टुकड़ों का कोई मतलब नहीं — खेत की सीमा एक ही बंद आकृति है, इसलिए
/// वहाँ सारे बिंदु क्रम से जोड़ दिए जाते हैं।
class MeasureSession {
  MeasureSession(this.kind) : _segments = [<LatLng>[]];

  MeasureSession._(this.kind, this._segments);

  final MeasureKind kind;
  final List<List<LatLng>> _segments;

  /// सारे बिंदु क्रम से (रकबे के लिए, और नक्शे पर नंबर दिखाने के लिए)
  List<LatLng> get points =>
      List.unmodifiable(_segments.expand((s) => s));

  /// टुकड़े — दूरी वाली रेखा बनाने के लिए
  List<List<LatLng>> get segments =>
      List.unmodifiable(_segments.where((s) => s.isNotEmpty).map(List.of));

  int get pointCount => _segments.fold(0, (n, s) => n + s.length);
  bool get isEmpty => pointCount == 0;

  void add(LatLng p) => _segments.last.add(p);

  /// [index] = [points] वाला क्रमांक
  void move(int index, LatLng p) {
    var i = index;
    for (final s in _segments) {
      if (i < s.length) {
        s[i] = p;
        return;
      }
      i -= s.length;
    }
  }

  /// आख़िरी बिंदु हटाओ। आख़िरी टुकड़ा ख़ाली हो जाए तो वो भी हटे, ताकि अगला
  /// undo पिछले टुकड़े का बिंदु हटाए।
  void undo() {
    while (_segments.length > 1 && _segments.last.isEmpty) {
      _segments.removeLast();
    }
    if (_segments.last.isNotEmpty) _segments.last.removeLast();
  }

  void clear() {
    _segments
      ..clear()
      ..add(<LatLng>[]);
  }

  /// Pause के बाद दोबारा चलने पर नया टुकड़ा। पिछला ख़ाली हो तो नया नहीं बनता।
  void startNewSegment() {
    if (_segments.last.isNotEmpty) _segments.add(<LatLng>[]);
  }

  bool get hasArea => kind == MeasureKind.area && pointCount >= 3;

  /// रकबा (वर्ग फीट)। दूरी वाले नाप में शून्य।
  double get areaSqFt => hasArea ? polygonAreaSqFt(points) : 0;

  /// रकबे में: खेत की परिधि। दूरी में: सारे टुकड़ों की कुल लंबाई।
  double get lengthMeters {
    if (kind == MeasureKind.area) {
      return pathLengthMeters(points, closed: pointCount >= 3);
    }
    return _segments.fold(0.0, (sum, s) => sum + pathLengthMeters(s));
  }

  /// सीमा ख़ुद को काट रही है — रकबा ग़लत (कम) आएगा
  bool get crossesItself =>
      kind == MeasureKind.area && isSelfIntersecting(points);

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'segments': [
          for (final s in _segments)
            if (s.isNotEmpty)
              [
                for (final p in s)
                  [_round(p.latitude), _round(p.longitude)]
              ]
        ],
      };

  /// ख़राब/पुराना JSON मिले तो null — एक टूटी entry पूरी सूची न बिगाड़े।
  static MeasureSession? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = MeasureKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    final raw = json['segments'];
    if (kind == null || raw is! List) return null;

    final segments = <List<LatLng>>[];
    for (final s in raw) {
      if (s is! List) return null;
      final pts = <LatLng>[];
      for (final p in s) {
        if (p is! List || p.length != 2) return null;
        final lat = p[0], lon = p[1];
        if (lat is! num || lon is! num) return null;
        if (lat.abs() > 90 || lon.abs() > 180) return null;
        pts.add(LatLng(lat.toDouble(), lon.toDouble()));
      }
      if (pts.isNotEmpty) segments.add(pts);
    }
    if (segments.isEmpty) segments.add(<LatLng>[]);
    return MeasureSession._(kind, segments);
  }

  /// 7 दशमलव ≈ 1 सेंटीमीटर — इससे ज़्यादा अंक सिर्फ़ जगह घेरते हैं
  static double _round(double v) => (v * 1e7).roundToDouble() / 1e7;
}

/// GPS से नापे खेत में रकबा लगभग कितना ग़लत हो सकता है (अनुपात: 0.2 = 20%)।
///
/// यह **मोटा अनुमान** है, पक्का हिसाब नहीं। सीमा अगर हर जगह औसतन `d` मीटर
/// अंदर-बाहर खिसके तो रकबा लगभग `परिधि × d` बदलता है। फ़ोन जो accuracy
/// बताता है वो "68% बार इतने के अंदर" वाला घेरा है — सीमा के लंबवत औसत खिसकाव
/// उसका लगभग आधा मानते हैं।
///
/// छोटे खेत पर यह अनुपात तेज़ी से बढ़ता है (4 मी accuracy पर):
/// 1 एकड़ ≈ 13%, 40×40 मी ≈ 20%, 20×20 मी ≈ 40%।
/// इसी से तय होता है कि "फीते से नापें" वाली चेतावनी दिखे या नहीं — कोई
/// मनमाना "इतने धुर से छोटा" नियम नहीं।
double gpsAreaUncertainty({
  required double perimeterMeters,
  required double areaSqMeters,
  required double accuracyMeters,
}) {
  if (areaSqMeters <= 0) return double.infinity;
  return perimeterMeters * (accuracyMeters / 2) / areaSqMeters;
}

/// इससे ज़्यादा अनिश्चितता हो तो user को फीते से नापने की सलाह दें
const double gpsAreaWarnThreshold = 0.2;
