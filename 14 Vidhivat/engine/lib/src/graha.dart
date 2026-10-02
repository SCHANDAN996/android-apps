import 'dart:math' as math;

import 'angles.dart';
import 'ayanamsa.dart';
import 'julian.dart';
import 'nutation.dart';
import 'vsop_data.dart';

/// पाँच तारा-ग्रह और राहु-केतु की स्थिति (→ D-098, docs/29 चरण K1)।
///
/// सूर्य और चंद्र इस फ़ाइल में **नहीं** हैं — वे `sun.dart` और `moon.dart`
/// में हैं और पूरा पंचांग उन्हीं पर टिका है। कुंडली में भी सूर्य-चंद्र वहीं
/// से आएँगे, ताकि जन्म-पंचांग और "आज" वाला पन्ना आपस में कभी न लड़ें।
///
/// ## तरीक़ा
/// Meeus अध्याय 32–33 — वही किताब जो सूर्य, चंद्र और दोनों ग्रहण में चली:
///
/// 1. **VSOP87D** से ग्रह और पृथ्वी की सूर्य-केंद्रित स्थिति (L, B, R)।
///    तालिका `vsop_data.dart` में है और औज़ार से बनती है
///    (`tools/banao_vsop.py`) — हाथ से एक संख्या नहीं।
/// 2. पृथ्वी से देखने का रूपांतरण, **प्रकाश के समय** के साथ: ग्रह वहाँ
///    दिखता है जहाँ वह कुछ मिनट पहले था।
/// 3. **aberration**, FK5 का छोटा सुधार, और **नतांश** — वही नतांश जो
///    सूर्य-चंद्र पर लगता है (`nutation.dart`)।
///
/// नतीजा **आभासी सायन देशांतर** है, उस दिन के विषुव में — ठीक वैसा ही जैसा
/// [sunApparentLongitude] और [moonLongitude] देते हैं। निरयन के लिए
/// [grahaNirayan]।
///
/// ## कितना सही
/// JPL Horizons से 5 ग्रह × 20 तारीख़ें (1930–2040) मिलाई गईं; ब्यौरा
/// `docs/08_VERIFICATION.md` में और जाँच `test/graha_test.dart` में।

/// पाँच तारा-ग्रह। क्रम वही जो वार के स्वामियों का है।
enum Graha {
  mangal('मंगल'),
  budh('बुध'),
  guru('गुरु'),
  shukra('शुक्र'),
  shani('शनि');

  final String naam;
  const Graha(this.naam);
}

/// किसी पिंड की VSOP शृंखलाएँ — L, B, R।
typedef _Vsop = ({
  List<List<double>> l,
  List<List<double>> b,
  List<List<double>> r,
});

const _Vsop _prithvi = (l: prithviL, b: prithviB, r: prithviR);

_Vsop _vsopOf(Graha g) => switch (g) {
      Graha.mangal => (l: mangalL, b: mangalB, r: mangalR),
      Graha.budh => (l: budhL, b: budhB, r: budhR),
      Graha.guru => (l: guruL, b: guruB, r: guruR),
      Graha.shukra => (l: shukraL, b: shukraB, r: shukraR),
      Graha.shani => (l: shaniL, b: shaniB, r: shaniR),
    };

/// Σ_α τ^α · Σ A·cos(B + C·τ) — एक चर की पूरी शृंखला।
double _shrinkhala(List<List<double>> series, double tau) {
  var kul = 0.0;
  var ghaat = 1.0; // τ^α
  for (final pad in series) {
    var s = 0.0;
    for (var i = 0; i < pad.length; i += 3) {
      s += pad[i] * math.cos(pad[i + 1] + pad[i + 2] * tau);
    }
    kul += s * ghaat;
    ghaat *= tau;
  }
  return kul;
}

/// सूर्य-केंद्रित स्थिति: L और B **डिग्री** में, R खगोलीय इकाई में।
({double l, double b, double r}) _suryaKendrit(_Vsop v, double jde) {
  // VSOP का समय सहस्राब्दी में चलता है, शताब्दी में नहीं।
  final tau = (jde - j2000) / 365250.0;
  return (
    l: norm360(_shrinkhala(v.l, tau) * radToDeg),
    b: _shrinkhala(v.b, tau) * radToDeg,
    r: _shrinkhala(v.r, tau),
  );
}

/// ग्रह की सूर्य-केंद्रित स्थिति — L, B डिग्री में (उस दिन के विषुव में),
/// R खगोलीय इकाई में। Meeus अध्याय 32।
({double longitude, double latitude, double distance}) grahaHeliocentric(
    Graha g, double jde) {
  final p = _suryaKendrit(_vsopOf(g), jde);
  return (longitude: p.l, latitude: p.b, distance: p.r);
}

/// पृथ्वी की सूर्य-केंद्रित स्थिति — जाँच के लिए, और सूर्य से तुलना के लिए।
({double longitude, double latitude, double distance}) earthHeliocentric(
    double jde) {
  final p = _suryaKendrit(_prithvi, jde);
  return (longitude: p.l, latitude: p.b, distance: p.r);
}

/// प्रकाश को एक खगोलीय इकाई पार करने में लगने वाला समय, दिनों में।
const double _prakashDinPratiAu = 0.0057755183;

/// aberration का स्थिरांक, विकला में।
const double _kappa = 20.49552;

/// पृथ्वी से दिखने वाली ग्रह की **आभासी** स्थिति।
///
/// `longitude` — सायन देशांतर, डिग्री; नतांश और aberration शामिल।
/// `latitude`  — क्रांतिवृत्त से ऊपर-नीचे, डिग्री।
/// `distance`  — पृथ्वी से दूरी, खगोलीय इकाई में।
///
/// Meeus अध्याय 33। JDE (TT) चाहिए।
({double longitude, double latitude, double distance}) grahaApparent(
    Graha g, double jde) {
  final v = _vsopOf(g);
  final e = _suryaKendrit(_prithvi, jde);

  // पृथ्वी के समकोण निर्देशांक (सूर्य-केंद्रित)
  final ex = e.r * cosD(e.b) * cosD(e.l);
  final ey = e.r * cosD(e.b) * sinD(e.l);
  final ez = e.r * sinD(e.b);

  // ── प्रकाश का समय ──────────────────────────────────────────────
  // ग्रह वहाँ दिखता है जहाँ वह τ दिन पहले था, और τ ख़ुद दूरी पर टिका है —
  // इसलिए दोहराकर निकालते हैं। तीन बार काफ़ी है (शनि पर भी τ ≈ 0.06 दिन)।
  var der = 0.0;
  var x = 0.0, y = 0.0, z = 0.0, doori = 0.0;
  for (var i = 0; i < 3; i++) {
    final p = _suryaKendrit(v, jde - der);
    x = p.r * cosD(p.b) * cosD(p.l) - ex;
    y = p.r * cosD(p.b) * sinD(p.l) - ey;
    z = p.r * sinD(p.b) - ez;
    doori = math.sqrt(x * x + y * y + z * z);
    der = _prakashDinPratiAu * doori;
  }

  var lambda = norm360(atan2D(y, x));
  var beta = atan2D(z, math.sqrt(x * x + y * y));

  // ── aberration (Meeus 33, सूर्य की स्थिति से) ──────────────────
  final t = julianCenturies(jde);
  final ecc = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;
  final pi = 102.93735 + 1.71946 * t + 0.00046 * t * t; // पृथ्वी का उपसौर
  final surya = e.l + 180.0; // सूर्य का सच्चा देशांतर
  final dLambda = (-_kappa * cosD(surya - lambda) +
          ecc * _kappa * cosD(pi - lambda)) /
      cosD(beta);
  final dBeta =
      -_kappa * sinD(beta) * (sinD(surya - lambda) - ecc * sinD(pi - lambda));
  lambda += dLambda / 3600.0;
  beta += dBeta / 3600.0;

  // ── VSOP का विषुव → FK5 (Meeus 32.3) — एक विकला का दसवाँ हिस्सा ──
  final lPrime = lambda - 1.397 * t - 0.00031 * t * t;
  lambda += (-0.09033 + 0.03916 * (cosD(lPrime) + sinD(lPrime)) * tanD(beta)) /
      3600.0;
  beta += 0.03916 * (cosD(lPrime) - sinD(lPrime)) / 3600.0;

  // ── नतांश — वही जो सूर्य और चंद्र पर लगता है ───────────────────
  lambda += nutationInLongitude(jde);

  return (longitude: norm360(lambda), latitude: beta, distance: doori);
}

/// ग्रह का आभासी **सायन** देशांतर, डिग्री। JDE (TT) चाहिए।
double grahaLongitude(Graha g, double jde) => grahaApparent(g, jde).longitude;

/// ग्रह का **निरयन** (लाहिड़ी) देशांतर, डिग्री — राशि और नक्षत्र इसी से।
double grahaNirayan(Graha g, double jde) =>
    toSidereal(grahaLongitude(g, jde), jde);

/// ग्रह की रोज़ की चाल, डिग्री प्रति दिन। ऋणात्मक = वक्री।
///
/// आधा दिन पहले और आधा दिन बाद की स्थिति का फ़र्क़ — उस एक दिन की औसत चाल।
double grahaGati(Graha g, double jde) =>
    norm180(grahaLongitude(g, jde + 0.5) - grahaLongitude(g, jde - 0.5));

/// ग्रह वक्री है — यानी राशि-चक्र में पीछे की ओर चल रहा है।
bool grahaVakri(Graha g, double jde) => grahaGati(g, jde) < 0;

/// सूर्य से ग्रह की कोणीय दूरी, डिग्री (0–180)। [suryaLongitude] सूर्य का
/// आभासी सायन देशांतर है — `sunApparentLongitude(jde)`।
///
/// अस्त (सूर्य के पास होने से न दिखना) इसी से तय होता है। कितने अंश पर
/// ग्रह अस्त माना जाए, यह **नियम** है, गणित नहीं — वह यहाँ नहीं है।
double grahaSuryaSeDoori(Graha g, double jde, double suryaLongitude) {
  final p = grahaApparent(g, jde);
  // गोले पर दो बिंदुओं के बीच का कोण; सूर्य का अक्षांश शून्य।
  return acosD(cosD(p.latitude) * cosD(p.longitude - suryaLongitude));
}

/// VSOP की पृथ्वी से निकला सूर्य का आभासी सायन देशांतर, डिग्री।
///
/// ⚠️ **पंचांग इसे इस्तेमाल नहीं करता** — वहाँ [sunApparentLongitude] है
/// (Meeus 25 का छोटा सूत्र), और वह नहीं बदलेगा। यह सिर्फ़ जाँच के लिए है:
/// दो बिल्कुल अलग रास्तों से निकला सूर्य आपस में मिलना चाहिए।
double sunLongitudeVsop(double jde) {
  final e = _suryaKendrit(_prithvi, jde);
  final t = julianCenturies(jde);
  var lambda = e.l + 180.0;
  final beta = -e.b;
  final lPrime = lambda - 1.397 * t - 0.00031 * t * t;
  lambda += (-0.09033 + 0.03916 * (cosD(lPrime) + sinD(lPrime)) * tanD(beta)) /
      3600.0;
  lambda += -20.4898 / e.r / 3600.0; // aberration
  lambda += nutationInLongitude(jde);
  return norm360(lambda);
}

// ─────────────────────────────────────────────────────────────
// राहु और केतु — चंद्र-कक्षा के पात
// ─────────────────────────────────────────────────────────────

/// चंद्र-कक्षा के आरोही पात का **माध्य** देशांतर, सायन, डिग्री — औसत राहु।
///
/// Meeus अध्याय 47। यह बिंदु राशि-चक्र में उलटा चलता है और लगभग 18.6
/// साल में एक चक्कर पूरा करता है।
double rahuMadhya(double jde) {
  final t = julianCenturies(jde);
  return norm360(125.0445479 -
      1934.1362891 * t +
      0.0020754 * t * t +
      t * t * t / 467441.0 -
      t * t * t * t / 60616000.0);
}

/// औसत राहु का **निरयन** देशांतर, डिग्री।
double rahuMadhyaNirayan(double jde) => toSidereal(rahuMadhya(jde), jde);

/// चंद्र-कक्षा के आरोही पात का **स्पष्ट** देशांतर, सायन, डिग्री — स्पष्ट राहु।
///
/// औसत पात एक-सी चाल से उलटा चलता है; असली पात उसके इर्द-गिर्द 1.7° तक
/// झूलता है (सूर्य के खिंचाव से) और कभी-कभी कुछ दिन सीधा भी चल लेता है।
/// Meeus अध्याय 47 के पाँच सबसे बड़े पद:
///
/// ```
/// Ω' = Ω − 1.4979° sin 2(D−F) − 0.1500° sin M − 0.1226° sin 2D
///        + 0.1176° sin 2F − 0.0801° sin 2(M′−F)
/// ```
///
/// ⚠️ **यह सन्निकट है — JPL Horizons के क्षण-विशेष के पात से 0.18° तक
/// हटता है** (30 तारीख़ें, 1972–2030; `graha_test.dart`)। औसत राहु अपने
/// सूत्र में सटीक है; यह नहीं। कुंडली में स्पष्ट राहु लेना तय हुआ तो और पद
/// जोड़ने होंगे — 0.18° यानी 11 कला, जो नवमांश के खाने (3°20′) से छोटा है
/// पर "एक कला" वाले लक्ष्य से बड़ा।
double rahuSpasht(double jde) {
  final t = julianCenturies(jde);
  final t2 = t * t, t3 = t2 * t, t4 = t3 * t;
  // चंद्र के चार मूल कोण — वही मान जो `moon.dart` में हैं (Meeus 47)।
  final d = 297.8501921 +
      445267.1114034 * t -
      0.0018819 * t2 +
      t3 / 545868.0 -
      t4 / 113065000.0;
  final m = 357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0;
  final mPrime = 134.9633964 +
      477198.8675055 * t +
      0.0087414 * t2 +
      t3 / 69699.0 -
      t4 / 14712000.0;
  final f = 93.2720950 +
      483202.0175233 * t -
      0.0036539 * t2 -
      t3 / 3526000.0 +
      t4 / 863310000.0;
  return norm360(rahuMadhya(jde) -
      1.4979 * sinD(2 * (d - f)) -
      0.1500 * sinD(m) -
      0.1226 * sinD(2 * d) +
      0.1176 * sinD(2 * f) -
      0.0801 * sinD(2 * (mPrime - f)));
}

/// स्पष्ट राहु का **निरयन** देशांतर, डिग्री।
double rahuSpashtNirayan(double jde) => toSidereal(rahuSpasht(jde), jde);

/// केतु राहु के ठीक सामने होता है — 180° पर।
double ketuSe(double rahu) => norm360(rahu + 180.0);
