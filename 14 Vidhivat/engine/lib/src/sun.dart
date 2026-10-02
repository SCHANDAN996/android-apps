import 'dart:math' as math;

import 'angles.dart';
import 'julian.dart';
import 'nutation.dart';
import 'vsop_data.dart';

/// सूर्य की स्थिति।
///
/// ## दो सूत्र, दो काम (→ D-104, 2 अक्टूबर 2026)
///
/// | | किससे | कितना सही | कहाँ लगता है |
/// |---|---|---|---|
/// | [sunApparentLongitude] | VSOP87 — पृथ्वी की L शृंखला (Meeus 25, ऊँची सटीकता वाला तरीक़ा) | NASA JPL Horizons से **0.3 विकला** | तिथि, योग, करण, संक्रांति, राशि, कुंडली, ग्रहण |
/// | [sunApparentLongitudeLaghu] | Meeus 25 का छोटा सूत्र | 21.5 विकला तक (वादा 36) | सिर्फ़ सूर्योदय-सूर्यास्त — वहाँ 21 विकला का मतलब डेढ़ सेकंड है, और यह दस गुना तेज़ है |
///
/// 2 अक्टूबर 2026 तक पूरा पंचांग छोटे सूत्र पर था। नाप (`tool/surya_milan.dart`,
/// `tool/sandarbh_farq.dart`, `docs/08` §17): संक्रांति का क्षण संदर्भ-पंचांग से
/// ±5 मिनट इधर-उधर था, अब एक ही तरफ़ 30–90 सेकंड (जो संदर्भ की अपनी गोलाई
/// है); और तिथि का अंत NASA से ±34 सेकंड था, अब ±10।
///
/// ⚠️ इस फ़ाइल को **नापे बिना** कोई न बदले — पूरा पंचांग इसी पर टिका है
/// (→ D-014: मिलाने के लिए गणित नहीं बिगाड़ना; सुधारना हो तो पहले नापना)।

/// सूर्य का सायन (tropical) आभासी देशांतर, डिग्री में। JDE (TT) चाहिए।
///
/// पृथ्वी का सूर्य-केंद्रित देशांतर (VSOP87D) + 180° = सूर्य का भू-केंद्रित
/// देशांतर; फिर FK5 का सुधार, aberration और नतांश। पृथ्वी का अक्षांश (B) यहाँ
/// नहीं चाहिए — सूर्य क्रांतिवृत्त से 1.2 विकला से ज़्यादा कभी नहीं हटता, और
/// देशांतर पर उसका असर 10⁻⁶ विकला है। पूरा रास्ता (B और R सहित) `graha.dart`
/// के `sunLongitudeVsop` में है; दोनों का आपस में मिलना `graha_test` देखता है।
double sunApparentLongitude(double jde) {
  // VSOP का समय सहस्राब्दी में चलता है, शताब्दी में नहीं।
  final tau = (jde - j2000) / 365250.0;
  var kul = 0.0;
  var ghaat = 1.0; // τ^α
  for (final pad in prithviL) {
    var s = 0.0;
    for (var i = 0; i < pad.length; i += 3) {
      s += pad[i] * math.cos(pad[i + 1] + pad[i + 2] * tau);
    }
    kul += s * ghaat;
    ghaat *= tau;
  }
  final lambda = kul * radToDeg +
      180.0 -
      0.09033 / 3600.0 - // FK5
      20.4898 / (sunDistance(jde) / _khagoliyaIkai) / 3600.0 + // aberration
      nutationInLongitude(jde);
  return norm360(lambda);
}

/// सूर्य का आभासी देशांतर — **छोटा सूत्र** (Meeus अध्याय 25, कम-सटीकता वाला
/// तरीक़ा, ~0.01° यानी 36 विकला तक सही)। सिर्फ़ सूर्योदय-सूर्यास्त के लिए।
double sunApparentLongitudeLaghu(double jde) {
  final t = julianCenturies(jde);

  // ज्यामितीय माध्य देशांतर
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;

  // माध्य विसंगति (mean anomaly)
  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;

  // केंद्र समीकरण (equation of centre)
  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sinD(m) +
      (0.019993 - 0.000101 * t) * sinD(2 * m) +
      0.000289 * sinD(3 * m);

  final trueLongitude = l0 + c;

  // चंद्र-कक्षा का आरोही पात — आभासी स्थिति के लिए
  final omega = 125.04 - 1934.136 * t;

  // −0.00569 प्रकाश की गति का सुधार (aberration)
  return norm360(trueLongitude - 0.00569 - 0.00478 * sinD(omega));
}

/// सूर्य का माध्य देशांतर — नक्षत्र-गणना वग़ैरह में काम नहीं आता,
/// पर जाँच के लिए रखा है।
double sunMeanLongitude(double jde) {
  final t = julianCenturies(jde);
  return norm360(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
}

/// क्रांतिवृत्त की तिरछाहट (obliquity of the ecliptic), डिग्री।
/// Meeus 22.2 — माध्य मान, नतांश (nutation) के बिना।
double meanObliquity(double jde) {
  final t = julianCenturies(jde);
  return 23.439291111 -
      0.0130041667 * t -
      1.6666667e-7 * t * t +
      5.027778e-7 * t * t * t;
}

/// आभासी (सच्ची) तिरछाहट = माध्य + नतांश का असर।
/// सूर्य और चंद्र दोनों को RA/क्रांति निकालते वक़्त यही चाहिए।
double trueObliquity(double jde) =>
    meanObliquity(jde) +
    0.00256 * cosD(125.04 - 1934.136 * julianCenturies(jde));

/// सूर्य का आभासी दाहिना आरोहण (RA) और क्रांति (declination), डिग्री —
/// पूरी सटीकता से ([sunApparentLongitude])। सूर्यग्रहण में यही लगता है।
({double rightAscension, double declination}) sunEquatorial(double jde) =>
    _vishuvatiya(sunApparentLongitude(jde), jde);

/// वही, छोटे सूत्र से ([sunApparentLongitudeLaghu]) — **सूर्योदय-सूर्यास्त
/// के लिए**। वहाँ सूर्य हर दिन दर्जनों बार निकाला जाता है (कैलेंडर के 42
/// खाने, साल भर के त्योहार → D-097), और 21 विकला की ग़लती उगने के समय में
/// डेढ़ सेकंड से कम है।
({double rightAscension, double declination}) sunEquatorialLaghu(double jde) =>
    _vishuvatiya(sunApparentLongitudeLaghu(jde), jde);

({double rightAscension, double declination}) _vishuvatiya(
    double lambda, double jde) {
  final epsilon = trueObliquity(jde);

  final ra = norm360(atan2D(cosD(epsilon) * sinD(lambda), cosD(lambda)));
  final dec = asinD(sinD(epsilon) * sinD(lambda));

  return (rightAscension: ra, declination: dec);
}

/// पृथ्वी से सूर्य की दूरी, **किलोमीटर** में। Meeus 25.5।
///
/// सूर्यग्रहण के लिए ज़रूरी है: सूर्य का कोणीय अर्धव्यास इसी से निकलता है,
/// और वही तय करता है कि ग्रहण खग्रास होगा या कंकणाकृति (→ D-055)।
///
/// साल भर में यह दूरी लगभग 3.4% घटती-बढ़ती है — जनवरी में पृथ्वी सूरज के
/// सबसे पास होती है, जुलाई में सबसे दूर।
double sunDistance(double jde) {
  final t = julianCenturies(jde);

  final m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final e = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;
  final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sinD(m) +
      (0.019993 - 0.000101 * t) * sinD(2 * m) +
      0.000289 * sinD(3 * m);

  // सच्ची विसंगति (true anomaly) से त्रिज्या-सदिश, खगोलीय इकाई में
  final nu = m + c;
  final rAu = 1.000001018 * (1 - e * e) / (1 + e * cosD(nu));

  return rAu * _khagoliyaIkai;
}

/// एक खगोलीय इकाई (astronomical unit), किलोमीटर।
const double _khagoliyaIkai = 149597870.7;
