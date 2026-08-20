import 'dart:math' as math;

/// कोण से जुड़े छोटे-छोटे औज़ार। पूरे इंजन में डिग्री ही चलती है,
/// रेडियन सिर्फ़ sin/cos के अंदर जाते वक़्त।

const double degToRad = math.pi / 180.0;
const double radToDeg = 180.0 / math.pi;

double sinD(double deg) => math.sin(deg * degToRad);
double cosD(double deg) => math.cos(deg * degToRad);
double tanD(double deg) => math.tan(deg * degToRad);

double asinD(double x) => math.asin(x.clamp(-1.0, 1.0)) * radToDeg;
double acosD(double x) => math.acos(x.clamp(-1.0, 1.0)) * radToDeg;
double atan2D(double y, double x) => math.atan2(y, x) * radToDeg;

/// 0 से 360 के बीच लाओ।
double norm360(double deg) {
  final d = deg % 360.0;
  return d < 0 ? d + 360.0 : d;
}

/// −180 से +180 के बीच लाओ। दो कोणों का अंतर निकालते वक़्त काम आता है।
double norm180(double deg) => norm360(deg + 180.0) - 180.0;

/// डिग्री को "23° 51' 23.4"" जैसे रूप में।
String toDms(double deg) {
  final sign = deg < 0 ? '-' : '';
  var d = deg.abs();
  final degrees = d.floor();
  d = (d - degrees) * 60;
  final minutes = d.floor();
  final seconds = (d - minutes) * 60;
  return "$sign$degrees° $minutes' ${seconds.toStringAsFixed(1)}\"";
}
