import 'angles.dart';
import 'julian.dart';

/// सूर्य की स्थिति। Meeus अध्याय 25 (कम-सटीकता वाला तरीक़ा,
/// ~0.01° यानी 36 विकला तक सही)।
///
/// तिथि 12° चौड़ी होती है, इसलिए 0.01° की ग़लती का मतलब है
/// समय में लगभग 20 सेकंड — पंचांग के लिए ज़रूरत से कहीं ज़्यादा सटीक।

/// सूर्य का सायन (tropical) आभासी देशांतर, डिग्री में। JDE (TT) चाहिए।
double sunApparentLongitude(double jde) {
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

/// सूर्य का आभासी दाहिना आरोहण (RA) और क्रांति (declination), डिग्री।
/// सूर्योदय-सूर्यास्त निकालने के लिए चाहिए।
({double rightAscension, double declination}) sunEquatorial(double jde) {
  final lambda = sunApparentLongitude(jde);
  final epsilon = trueObliquity(jde);

  final ra = norm360(atan2D(cosD(epsilon) * sinD(lambda), cosD(lambda)));
  final dec = asinD(sinD(epsilon) * sinD(lambda));

  return (rightAscension: ra, declination: dec);
}
