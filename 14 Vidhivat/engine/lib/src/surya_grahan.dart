import 'dart:math' as math;

import 'angles.dart';
import 'julian.dart';
import 'moon.dart';
import 'moonrise.dart' show moonEquatorial;
import 'place.dart';
import 'prahar.dart';
import 'sun.dart';
import 'sunrise.dart';

/// **सूर्यग्रहण।**
///
/// ## चंद्रग्रहण से यह क्यों अलग है
///
/// चंद्रग्रहण **सबको एक जैसा दिखता है** — जिसे भी उस वक़्त चाँद दिख रहा
/// हो, उसे वही ग्रहण उसी समय दिखता है। पृथ्वी की छाया चाँद पर पड़ती है,
/// और छाया एक ही है।
///
/// सूर्यग्रहण में छाया **पृथ्वी पर** पड़ती है, और वो छाया चौड़ाई में कुछ
/// सौ किलोमीटर की होती है। इसलिए एक ही ग्रहण एक शहर में खग्रास होता है,
/// तीन सौ किलोमीटर दूर सिर्फ़ खंडग्रास, और हज़ार किलोमीटर दूर दिखता ही
/// नहीं। **"कहाँ से देख रहे हो" इस बार सवाल का हिस्सा है, बाद की बात
/// नहीं।**
///
/// ## Besselian elements क्यों नहीं
///
/// किताबें यही रास्ता बताती हैं, और NASA भी वही छापता है। पर उसके लिए
/// आठ राशियों की अलग तालिका हर ग्रहण के लिए चाहिए — या तो बाहर से लाओ
/// (यानी सर्वर, जो इस ऐप में नहीं है), या ख़ुद निकालो, जो और लंबा गणित
/// है।
///
/// **यहाँ सीधा रास्ता लिया गया है:** उस शहर से, उस पल, सूर्य और चंद्रमा
/// के बिंब आसमान में कितनी दूर हैं — यही नापो। दोनों के **स्थानकेंद्रीय**
/// (topocentric) सदिश निकालो, बीच का कोण नापो, और दोनों के अर्धव्यास जोड़
/// लो। कोण उससे छोटा हुआ तो ग्रहण लगा।
///
///     अंतर < (सूर्य का अर्धव्यास + चंद्रमा का अर्धव्यास)  → ग्रहण लगा
///     अंतर < |सूर्य − चंद्रमा|                            → केंद्रीय दशा
///
/// यह वही भौतिकी है जिससे Besselian elements बनते हैं — बस बीच का
/// गणितीय ढाँचा छोड़कर सीधे जवाब पर। हर शहर के लिए अलग हिसाब लगाना पड़ता
/// है, जो एक फ़ोन के लिए कोई भारी बात नहीं।
///
/// ⚠️ **लंबन (parallax) यहाँ मुख्य पात्र है, कोई सुधार नहीं।** पृथ्वी के
/// केंद्र से और सतह से चाँद की दिशा पूरे एक डिग्री तक अलग होती है — चाँद
/// के अपने बिंब से दुगनी। इसीलिए ग्रहण हर शहर में अलग दिखता है। पूरा
/// हिसाब सदिशों में होता है ताकि यह अपने आप सधे।
///
/// ## सूतक
///
/// सूर्यग्रहण का सूतक **चार प्रहर** पहले लगता है — चंद्रग्रहण के तीन से
/// एक ज़्यादा (→ `prahar.dart`, D-054)। और वही दो शर्तें: ग्रहण उस जगह से
/// दिखना चाहिए, वरना सूतक नहीं।

/// चंद्रमा की त्रिज्या, किलोमीटर। ग्रहण की गणना में यही मानक है।
const double chandraKiTrijya = 1737.4;

/// सूर्य की त्रिज्या, किलोमीटर।
const double suryaKiTrijya = 696000.0;

/// पृथ्वी की भूमध्यरेखीय त्रिज्या, किलोमीटर।
const double prithviKiTrijya = 6378.14;

/// पृथ्वी कितनी चपटी है — ध्रुवीय/भूमध्यरेखीय त्रिज्या का अनुपात।
const double _chapatapan = 0.99664719;

/// सूर्यग्रहण का सूतक कितने प्रहर पहले लगता है।
const int suryaGrahanKeSutakKePrahar = 4;

/// उस शहर से ग्रहण किस दर्जे का दिखेगा।
enum SuryaGrahanPrakar {
  /// चंद्रमा सूरज को छूता ही नहीं — यहाँ ग्रहण है ही नहीं।
  nahi('यहाँ ग्रहण नहीं'),

  /// सूरज का कुछ हिस्सा ढका।
  khandgras('खंडग्रास सूर्यग्रहण'),

  /// चंद्रमा सूरज के बीच में है पर छोटा पड़ता है — किनारे की चमकती अँगूठी।
  kankanakriti('कंकणाकृति सूर्यग्रहण'),

  /// पूरा सूरज ढका।
  khagras('खग्रास सूर्यग्रहण');

  final String naam;
  const SuryaGrahanPrakar(this.naam);
}

/// एक सूर्यग्रहण — **पूरी पृथ्वी के लिए**, किसी एक शहर के लिए नहीं।
///
/// यहाँ सिर्फ़ इतना है कि ग्रहण है और उसका मध्य कब है। "यहाँ कैसा दिखेगा"
/// के लिए [suryaGrahanYahanSe]।
class SuryaGrahan {
  /// ग्रहण का मध्य (greatest eclipse) — **असली UTC पल**।
  final DateTime madhya;

  /// छाया की धुरी पृथ्वी के केंद्र से कितनी दूर, पृथ्वी की त्रिज्या में।
  ///
  /// `|gamma| < 0.9972` हो तो छाया की धुरी पृथ्वी पर पड़ती है — यानी
  /// कहीं न कहीं ग्रहण पूरा (खग्रास या कंकणाकृति) दिखेगा।
  final double gamma;

  /// Meeus का `u` — छाया-शंकु की त्रिज्या। ऋणात्मक यानी खग्रास।
  final double u;

  const SuryaGrahan({
    required this.madhya,
    required this.gamma,
    required this.u,
  });

  /// छाया की धुरी पृथ्वी को छूती है — यानी कहीं न कहीं पूरा ग्रहण दिखेगा।
  bool get kendriya => gamma.abs() < 0.9972;
}

/// एक सूर्यग्रहण, एक शहर से देखा हुआ।
class SuryaGrahanDarshan {
  final SuryaGrahan grahan;

  /// यहाँ से ग्रहण किस दर्जे का दिखेगा।
  final SuryaGrahanPrakar prakar;

  /// यहाँ दिखेगा या नहीं — यानी ग्रहण के दौरान सूरज क्षितिज के ऊपर है।
  bool get dikhega => prakar != SuryaGrahanPrakar.nahi;

  /// स्पर्श, मध्य और मोक्ष — **यहाँ से**, और सूर्योदय-सूर्यास्त से कटे हुए।
  ///
  /// ग्रहण सूरज उगने से पहले शुरू हो चुका हो तो [shuru] सूर्योदय है।
  final DateTime? shuru;
  final DateTime? madhya;
  final DateTime? khatm;

  /// सबसे ज़्यादा ग्रास के समय सूरज का कितना हिस्सा ढका — 0 से 1 से ऊपर।
  ///
  /// यह **व्यास** का हिस्सा है (magnitude), क्षेत्रफल का नहीं। 1 या उससे
  /// ज़्यादा यानी पूरा सूरज ढका।
  final double maan;

  /// उस पल सूरज क्षितिज से कितना ऊपर, डिग्री।
  final double madhyaParSuryaKiUnchai;

  /// खग्रास या कंकणाकृति दशा कब से कब तक — खंडग्रास में दोनों `null`।
  ///
  /// यही उस दिन का सबसे ज़रूरी आँकड़ा होता है: पूरा सूरज कितनी देर ढका
  /// रहेगा, या अँगूठी कितनी देर दिखेगी।
  final DateTime? kendriyaShuru;
  final DateTime? kendriyaKhatm;

  /// केंद्रीय दशा कितनी देर की।
  Duration? get kendriyaAvadhi =>
      kendriyaShuru == null || kendriyaKhatm == null
          ? null
          : kendriyaKhatm!.difference(kendriyaShuru!);

  /// सूतक — **चार प्रहर** पहले, और ग्रहण छूटने पर उतरता है।
  final DateTime? sutakShuru;
  final DateTime? sutakKhatm;

  /// बच्चों, बूढ़ों और बीमारों के लिए — सिर्फ़ एक प्रहर पहले।
  final DateTime? komalSutakShuru;

  const SuryaGrahanDarshan({
    required this.grahan,
    required this.prakar,
    required this.shuru,
    required this.madhya,
    required this.khatm,
    required this.maan,
    required this.madhyaParSuryaKiUnchai,
    required this.kendriyaShuru,
    required this.kendriyaKhatm,
    required this.sutakShuru,
    required this.sutakKhatm,
    required this.komalSutakShuru,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  भाग १ — ग्रहण है या नहीं (Meeus अध्याय 54)
// ═══════════════════════════════════════════════════════════════════

/// इससे बड़ा `|sin F|` हो तो उस अमावस्या पर ग्रहण है ही नहीं।
const double _grahanKiHadd = 0.36;

/// एक अमावस्या पर सूर्यग्रहण है या नहीं।
///
/// [k] Meeus का चंद्र-चक्र गिनने वाला पूर्णांक — अमावस्या के लिए इसमें
/// कुछ नहीं जुड़ता (पूर्णिमा के लिए `.5` जुड़ता है, → `grahan.dart`)।
SuryaGrahan? _grahanEkAmavasyaPar(double k) {
  final t = k / 1236.85;
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  var jde = 2451550.09766 +
      29.530588861 * k +
      0.00015437 * t2 -
      0.000000150 * t3 +
      0.00000000073 * t4;

  final m = norm360(
      2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3);
  final mPrime = norm360(201.5643 +
      385.81693528 * k +
      0.0107582 * t2 +
      0.00001238 * t3 -
      0.000000058 * t4);
  final f = norm360(160.7108 +
      390.67050284 * k -
      0.0016118 * t2 -
      0.00000227 * t3 +
      0.000000011 * t4);
  final omega = norm360(
      124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3);

  if (sinD(f).abs() > _grahanKiHadd) return null;

  final e = 1 - 0.002516 * t - 0.0000074 * t2;
  final f1 = f - 0.02665 * sinD(omega);
  final a1 = norm360(299.77 + 0.107408 * k - 0.009173 * t2);

  // ⚠️ यह अध्याय **54** की सूची है, 49 की नहीं। चंद्रग्रहण में यही
  // ग़लती चौदह मिनट खा गई थी (→ D-052)। सूची दोनों ग्रहणों के लिए एक ही है।
  jde += -0.4075 * sinD(mPrime) +
      0.1721 * e * sinD(m) +
      0.0161 * sinD(2 * mPrime) -
      0.0097 * sinD(2 * f1) +
      0.0073 * e * sinD(mPrime - m) -
      0.0050 * e * sinD(mPrime + m) -
      0.0023 * sinD(mPrime - 2 * f1) +
      0.0021 * e * sinD(2 * m) +
      0.0012 * sinD(mPrime + 2 * f1) +
      0.0006 * e * sinD(2 * mPrime + m) -
      0.0004 * sinD(3 * mPrime) -
      0.0003 * e * sinD(m + 2 * f1) +
      0.0003 * sinD(a1) -
      0.0002 * e * sinD(m - 2 * f1) -
      0.0002 * e * sinD(2 * mPrime - m) -
      0.0002 * sinD(omega);

  final p = 0.2070 * e * sinD(m) +
      0.0024 * e * sinD(2 * m) -
      0.0392 * sinD(mPrime) +
      0.0116 * sinD(2 * mPrime) -
      0.0073 * e * sinD(mPrime + m) +
      0.0067 * e * sinD(mPrime - m) +
      0.0118 * sinD(2 * f1);

  final q = 5.2207 -
      0.0048 * e * cosD(m) +
      0.0020 * e * cosD(2 * m) -
      0.3299 * cosD(mPrime) -
      0.0060 * e * cosD(mPrime + m) +
      0.0041 * e * cosD(mPrime - m);

  final w = cosD(f1).abs();
  final gamma = (p * cosD(f1) + q * sinD(f1)) * (1 - 0.0048 * w);
  final u = 0.0059 +
      0.0046 * e * cosD(m) -
      0.0182 * cosD(mPrime) +
      0.0004 * cosD(2 * mPrime) -
      0.0005 * e * cosD(m + mPrime);

  // पृथ्वी से इतनी दूर से छाया गुज़रे तो कहीं ग्रहण नहीं (Meeus 54)।
  if (gamma.abs() > 1.5433 + u) return null;

  // JDE (ephemeris time) से UT — वरना जवाब ΔT जितना खिसका रहेगा।
  final varsh = utcFromJulianDay(jde).year;
  final deltaT = deltaTSeconds(varsh, 1) / 86400.0;

  return SuryaGrahan(
    madhya: utcFromJulianDay(jde - deltaT),
    gamma: gamma,
    u: u,
  );
}

/// दो तारीख़ों के बीच पड़ने वाले सारे सूर्यग्रहण — **पूरी पृथ्वी के**।
///
/// साल में दो से पाँच तक। इनमें से ज़्यादातर किसी एक शहर से नहीं दिखते —
/// वो [suryaGrahanYahanSe] बताएगा।
List<SuryaGrahan> suryaGrahan({
  required DateTime se,
  required DateTime tak,
}) {
  double kFor(DateTime d) {
    final varsh = d.year + (d.month - 0.5) / 12.0;
    return (varsh - 2000) * 12.3685;
  }

  final mile = <SuryaGrahan>[];
  final shuruK = kFor(se).floor() - 2;
  final antK = kFor(tak).ceil() + 2;

  for (var n = shuruK; n <= antK; n++) {
    final g = _grahanEkAmavasyaPar(n.toDouble());
    if (g == null) continue;
    if (g.madhya.isBefore(se) || g.madhya.isAfter(tak)) continue;
    mile.add(g);
  }

  mile.sort((a, b) => a.madhya.compareTo(b.madhya));
  return mile;
}

// ═══════════════════════════════════════════════════════════════════
//  भाग २ — यहाँ से कैसा दिखेगा (सदिशों का सीधा हिसाब)
// ═══════════════════════════════════════════════════════════════════

/// एक पल पर, एक शहर से, सूर्य और चंद्रमा का आपसी नाप।
class _Nazara {
  /// दोनों बिंबों के केंद्रों के बीच का कोण, डिग्री।
  final double antar;

  /// सूर्य और चंद्रमा के कोणीय अर्धव्यास, डिग्री।
  final double suryaAdha;
  final double chandraAdha;

  const _Nazara(this.antar, this.suryaAdha, this.chandraAdha);

  /// बिंब छूने में कितना बाक़ी। ऋणात्मक यानी ग्रहण लगा हुआ है।
  double get sparshTak => antar - (suryaAdha + chandraAdha);

  /// केंद्रीय दशा में कितना बाक़ी। ऋणात्मक यानी खग्रास/कंकणाकृति चल रही है।
  double get kendraTak => antar - (chandraAdha - suryaAdha).abs();

  /// सूरज का कितना हिस्सा ढका — **व्यास** के हिसाब से (magnitude)।
  ///
  ///     मान = (सूर्य का अर्धव्यास + चंद्रमा का अर्धव्यास − अंतर) ÷ सूर्य का व्यास
  ///
  /// ⚠️ **यहाँ केंद्रीय दशा के लिए अलग सूत्र नहीं लगता, और यह ग़लती एक
  /// बार हो चुकी है।** पहले यहाँ लिखा था कि खग्रास में मान = दोनों बिंबों
  /// के व्यास का अनुपात — क्योंकि NASA अपने पन्ने पर 2027 वाले ग्रहण का
  /// मान 1.079 छापता है, और वो अनुपात ही है।
  ///
  /// पर वो **पूरी पृथ्वी का** मान है, ग्रहण के विश्व-मध्य वाला। किसी एक
  /// शहर का मान वो नहीं होता: 12 अगस्त 2026 को रेक्याविक में खग्रास सिर्फ़
  /// **65 सेकंड** का है — यानी वो छाया के ठीक किनारे पर है — इसलिए वहाँ
  /// मान 1.00 है, 1.039 नहीं। Drik भी वहाँ 1.00 ही छापता है।
  double get maan {
    if (sparshTak >= 0) return 0;
    return (suryaAdha + chandraAdha - antar) / (2 * suryaAdha);
  }
}

/// देखने वाले की जगह का सदिश, पृथ्वी के केंद्र से — किलोमीटर।
///
/// Meeus अध्याय 11: पृथ्वी गोल नहीं, थोड़ी चपटी है, इसलिए भौगोलिक अक्षांश
/// से भूकेंद्रीय अक्षांश निकालना पड़ता है।
({double x, double y, double z}) _dekhneWaleKaSthan(
  double jdUt,
  Place place,
) {
  final u = atan2D(_chapatapan * sinD(place.latitude), cosD(place.latitude));
  final rhoSinPhi = _chapatapan * sinD(u);
  final rhoCosPhi = cosD(u);

  // स्थानीय नाक्षत्र काल — यही बताता है कि इस वक़्त शहर किस दिशा में है।
  final theta = norm360(greenwichMeanSiderealTime(jdUt) + place.longitude);

  return (
    x: prithviKiTrijya * rhoCosPhi * cosD(theta),
    y: prithviKiTrijya * rhoCosPhi * sinD(theta),
    z: prithviKiTrijya * rhoSinPhi,
  );
}

/// भूकेंद्रीय दिशा और दूरी से सदिश।
({double x, double y, double z}) _sadish(
  double ra,
  double dec,
  double doori,
) =>
    (
      x: doori * cosD(dec) * cosD(ra),
      y: doori * cosD(dec) * sinD(ra),
      z: doori * sinD(dec),
    );

/// उस पल का पूरा नज़ारा — शहर से देखा हुआ।
_Nazara _nazara(double jdUt, Place place) {
  final jde = toEphemerisTime(jdUt);

  final suryaSe = sunEquatorial(jde);
  final surya = _sadish(
      suryaSe.rightAscension, suryaSe.declination, sunDistance(jde));

  final chandraSe = moonEquatorial(jde);
  final chandra = _sadish(
      chandraSe.rightAscension, chandraSe.declination, moonDistance(jde));

  final ghar = _dekhneWaleKaSthan(jdUt, place);

  // ── यहीं लंबन अपने आप सध जाता है ──
  //
  // पृथ्वी के केंद्र वाले सदिश में से शहर का सदिश घटाते ही जो बचता है,
  // वही वहाँ खड़े आदमी की दिशा है। चाँद के लिए यह घटाव पूरे एक डिग्री
  // तक की बात है; सूरज के लिए नौ विकला की। दोनों ज़रूरी हैं।
  ({double x, double y, double z}) ghatao(({double x, double y, double z}) v) =>
      (x: v.x - ghar.x, y: v.y - ghar.y, z: v.z - ghar.z);

  final suryaYahanSe = ghatao(surya);
  final chandraYahanSe = ghatao(chandra);

  double lambai(({double x, double y, double z}) v) =>
      math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);

  final suryaDoori = lambai(suryaYahanSe);
  final chandraDoori = lambai(chandraYahanSe);

  final dotProduct = suryaYahanSe.x * chandraYahanSe.x +
      suryaYahanSe.y * chandraYahanSe.y +
      suryaYahanSe.z * chandraYahanSe.z;

  return _Nazara(
    acosD(dotProduct / (suryaDoori * chandraDoori)),
    asinD(suryaKiTrijya / suryaDoori),
    asinD(chandraKiTrijya / chandraDoori),
  );
}

/// दो पलों के बीच वो क्षण जहाँ [naap] शून्य पार करता है (द्विभाजन)।
///
/// [rinPar] वो सिरा है जहाँ नाप ऋणात्मक है।
DateTime _shunyaKahan(
  DateTime rinPar,
  DateTime dhanPar,
  Place place,
  double Function(_Nazara) naap,
) {
  var rin = rinPar;
  var dhan = dhanPar;
  for (var i = 0; i < 30; i++) {
    final beech = rin.add(dhan.difference(rin) ~/ 2);
    if (beech == rin || beech == dhan) break;
    if (naap(_nazara(julianDayFromUtc(beech), place)) < 0) {
      rin = beech;
    } else {
      dhan = beech;
    }
  }
  return rin;
}

/// यह सूर्यग्रहण इस शहर से कैसा दिखेगा — और सूतक कब से।
SuryaGrahanDarshan suryaGrahanYahanSe(SuryaGrahan g, Place place) {
  SuryaGrahanDarshan nahiDikhega() => SuryaGrahanDarshan(
        grahan: g,
        prakar: SuryaGrahanPrakar.nahi,
        shuru: null,
        madhya: null,
        khatm: null,
        maan: 0,
        madhyaParSuryaKiUnchai: 0,
        kendriyaShuru: null,
        kendriyaKhatm: null,
        sutakShuru: null,
        sutakKhatm: null,
        komalSutakShuru: null,
      );

  // ── १. सबसे ज़्यादा ग्रास कब — मोटी छानबीन, फिर बारीक़ ──
  //
  // ग्रहण की छाया पृथ्वी पर तीन घंटे तक चलती रह सकती है, इसलिए विश्व-मध्य
  // से चार घंटे इधर-उधर देखना पड़ता है।
  const daayra = Duration(hours: 4);
  const motaKadam = Duration(minutes: 5);

  DateTime sabseKareeb = g.madhya;
  var sabseKamAntar = double.infinity;
  for (var t = g.madhya.subtract(daayra);
      t.isBefore(g.madhya.add(daayra));
      t = t.add(motaKadam)) {
    final antar = _nazara(julianDayFromUtc(t), place).antar;
    if (antar < sabseKamAntar) {
      sabseKamAntar = antar;
      sabseKareeb = t;
    }
  }

  // बारीक़ी — पाँच मिनट के भीतर तीन-भाग खोज (ternary search)।
  var baayaan = sabseKareeb.subtract(motaKadam);
  var daayaan = sabseKareeb.add(motaKadam);
  for (var i = 0; i < 40; i++) {
    final teesra = daayaan.difference(baayaan) ~/ 3;
    if (teesra.inMicroseconds < 1000) break;
    final a = baayaan.add(teesra);
    final b = daayaan.subtract(teesra);
    if (_nazara(julianDayFromUtc(a), place).antar <
        _nazara(julianDayFromUtc(b), place).antar) {
      daayaan = b;
    } else {
      baayaan = a;
    }
  }
  final grahanKaMadhya = baayaan.add(daayaan.difference(baayaan) ~/ 2);
  final madhyaKaNazara = _nazara(julianDayFromUtc(grahanKaMadhya), place);

  // बिंब छुए ही नहीं — यहाँ ग्रहण है ही नहीं।
  if (madhyaKaNazara.sparshTak >= 0) return nahiDikhega();

  // ── २. स्पर्श और मोक्ष ──
  // यहाँ मध्य पर ग्रहण लगा हुआ है और चार घंटे बाहर कहीं नहीं — इसलिए
  // सीधा द्विभाजन काफ़ी है, एक-एक मिनट चलने की ज़रूरत नहीं। (एक शहर से
  // ग्रहण साढ़े तीन घंटे से ज़्यादा नहीं चलता।)
  DateTime? kinara(DateTime bahar) {
    if (_nazara(julianDayFromUtc(bahar), place).sparshTak < 0) return null;
    return _shunyaKahan(grahanKaMadhya, bahar, place, (n) => n.sparshTak);
  }

  final sparsha = kinara(grahanKaMadhya.subtract(daayra));
  final moksha = kinara(grahanKaMadhya.add(daayra));
  if (sparsha == null || moksha == null) return nahiDikhega();

  // ⚠️ द्विभाजन हमेशा **ऋणात्मक** सिरा लौटाता है — यानी वो पल जब ग्रहण
  // अभी लगा हुआ है। स्पर्श और मोक्ष दोनों पर फ़र्क़ एक सेकंड से कम का है।

  // ── ३. सूरज ऊपर है या नहीं — बिना इसके ग्रहण दिखेगा ही नहीं ──
  //
  // ⚠️ दहलीज़ **शून्य नहीं, −0.8333°** है — वही जो सूर्योदय-सूर्यास्त की
  // है (34ʹ वायुमंडलीय अपवर्तन + 16ʹ सूर्य का अर्धव्यास)। शून्य रखने पर
  // ग्रहण सूर्यास्त से लगभग **साढ़े चार मिनट पहले** ही ख़त्म दिखने लगता
  // था — 12 अगस्त 2026 को मैड्रिड में Drik 21:16 (सूर्यास्त) कहता है और
  // हमारा 21:11 आ रहा था। ग्रहण तब तक दिखता है जब तक सूरज की **कोर**
  // क्षितिज पर है, उसका केंद्र नहीं।
  bool suryaUpar(DateTime t) =>
      sunAltitude(julianDayFromUtc(t), place) > suryodayKiDehleez;

  const kadam = Duration(minutes: 2);
  DateTime? pehlaUpar;
  DateTime? antimUpar;
  for (var t = sparsha; t.isBefore(moksha); t = t.add(kadam)) {
    if (suryaUpar(t)) {
      pehlaUpar ??= t;
      antimUpar = t;
    }
  }
  if (suryaUpar(moksha)) {
    pehlaUpar ??= moksha;
    antimUpar = moksha;
  }
  if (pehlaUpar == null || antimUpar == null) return nahiDikhega();

  /// सूरज कब क्षितिज पार करता है — [upar] पर ऊपर, [neeche] पर नीचे।
  DateTime kshitijPar(DateTime upar, DateTime neeche) {
    var u = upar;
    var n = neeche;
    for (var i = 0; i < 24; i++) {
      final beech = n.add(u.difference(n) ~/ 2);
      if (beech == u || beech == n) break;
      if (suryaUpar(beech)) {
        u = beech;
      } else {
        n = beech;
      }
    }
    return u;
  }

  final sthaniyaShuru = pehlaUpar == sparsha
      ? sparsha
      : kshitijPar(pehlaUpar, pehlaUpar.subtract(kadam));
  final aglaKadam = antimUpar.add(kadam);
  final sthaniyaKhatm = suryaUpar(moksha)
      ? moksha
      : kshitijPar(
          antimUpar, aglaKadam.isAfter(moksha) ? moksha : aglaKadam);

  // ── ४. सबसे ज़्यादा ग्रास — पर सिर्फ़ उतना जितना यहाँ दिखेगा ──
  //
  // ग्रहण का असली मध्य सूरज डूबने के बाद पड़े तो यहाँ जो दिखा उसमें सबसे
  // ज़्यादा ग्रास सूर्यास्त के वक़्त था, मध्य में नहीं।
  final dikhneWalaMadhya = grahanKaMadhya.isBefore(sthaniyaShuru)
      ? sthaniyaShuru
      : grahanKaMadhya.isAfter(sthaniyaKhatm)
          ? sthaniyaKhatm
          : grahanKaMadhya;
  final dikhneWalaNazara = _nazara(julianDayFromUtc(dikhneWalaMadhya), place);

  final prakar = dikhneWalaNazara.kendraTak < 0
      ? (dikhneWalaNazara.chandraAdha >= dikhneWalaNazara.suryaAdha
          ? SuryaGrahanPrakar.khagras
          : SuryaGrahanPrakar.kankanakriti)
      : SuryaGrahanPrakar.khandgras;

  // ── ५. केंद्रीय दशा कब से कब तक — यही सबसे बड़ी बात होती है ──
  //
  // खग्रास कितनी देर रहेगा, यह उस दिन का सबसे ज़रूरी आँकड़ा है। रेक्याविक
  // में 12 अगस्त 2026 को वो सिर्फ़ **65 सेकंड** का है।
  DateTime? kendraKinara(DateTime bahar) {
    if (_nazara(julianDayFromUtc(bahar), place).kendraTak < 0) return null;
    return _shunyaKahan(dikhneWalaMadhya, bahar, place, (n) => n.kendraTak);
  }

  final kendriyaShuru = prakar == SuryaGrahanPrakar.khandgras
      ? null
      : kendraKinara(sparsha);
  final kendriyaKhatm = prakar == SuryaGrahanPrakar.khandgras
      ? null
      : kendraKinara(moksha);

  return SuryaGrahanDarshan(
    grahan: g,
    prakar: prakar,
    shuru: sthaniyaShuru,
    madhya: dikhneWalaMadhya,
    khatm: sthaniyaKhatm,
    maan: dikhneWalaNazara.maan,
    kendriyaShuru: kendriyaShuru,
    kendriyaKhatm: kendriyaKhatm,
    madhyaParSuryaKiUnchai:
        sunAltitude(julianDayFromUtc(dikhneWalaMadhya), place),
    // सूतक चार प्रहर पहले — और गिनती वहीं से जहाँ से ग्रहण यहाँ दिखेगा।
    sutakShuru:
        praharPeeche(sthaniyaShuru, place, suryaGrahanKeSutakKePrahar),
    sutakKhatm: sthaniyaKhatm,
    komalSutakShuru:
        praharPeeche(sthaniyaShuru, place, komalJanoKeSutakKePrahar),
  );
}
