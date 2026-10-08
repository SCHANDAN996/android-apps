import 'angles.dart';
import 'graha.dart';
import 'julian.dart';
import 'place.dart';
import 'sun.dart';
import 'sunrise.dart';

/// **गुरु और शुक्र का अस्त** — सूर्य के पास आ जाने से न दिखना (→ D-119)।
///
/// मांगलिक कामों में यह दौर टाला जाता है (मुहूर्त चिंतामणि, संस्कार प्रकरण
/// २६: «नो वा बाल्यास्तवार्ध्ये सुरगुरुसितयोः»)। यह फ़ाइल सिर्फ़ यह बताती है
/// कि वह दौर **कब** है — कोई दिन "शुभ" नहीं कहती।
///
/// ## कितने अंश पर अस्त — छपा नियम
///
/// सूर्यसिद्धांत, उदयास्ताधिकार ९.६–७ (छपी प्रति पृ. 246):
///
/// «एकादशामरेज्यस्य … अस्तांशाः» — गुरु के **11** कालांश।
/// «पश्चादस्तमयोऽष्टाभिरुदयः प्राङ्महत्तया। प्रागस्त उदयः पश्चादल्पत्वाद्दशभिर्भृगोः»
/// — शुक्र पश्चिम में डूबे और पूर्व में उगे (वक्री, बड़ा बिंब) तो **8**; पूर्व
/// में डूबे और पश्चिम में उगे तो **10**।
///
/// वही संख्याएँ भास्कराचार्य के नाम से मुहूर्त चिंतामणि की पीयूषधारा टीका में
/// हैं («रुद्राः खचन्द्राः … ज्ञशुक्रयोर्वक्रगयोर्द्विहीनाः»)।
///
/// ## पर "कालांश" के दो पढ़ने के तरीक़े हैं — और तीसरा, जो छपे नियम से नहीं है
///
/// | | क्या नापा जाता है | किसमें मिलता है |
/// |---|---|---|
/// | [AstGanana.ansh] | सूर्य और ग्रह के **देशांतर का अंतर**, अंश में | ज़्यादातर छपी-प्रकाशित सूचियाँ; मुहूर्त की टीकाएँ भी इसी तरह गिनती हैं |
/// | [AstGanana.kalansh] | सूर्य और ग्रह के **उदय (या अस्त) के बीच का समय**; 1 कालांश = 60 असु ≈ 4 मिनट | सूर्यसिद्धांत ९.५ की अपनी परिभाषा; जगह से बदलता है |
/// | (इंजन में नहीं) | आँख से दिखने का आधुनिक हिसाब | दृक्-पंचांग; छपे नियम से नहीं निकलता |
///
/// तीनों की तारीख़ें आपस में **कुछ दिन** हटती हैं — गुरु में चार दिन तक, शुक्र
/// की लंबी (ऊपरी युति वाली) अस्त में दो-तीन हफ़्ते तक। 2024–2027 की नाप
/// `docs/08_VERIFICATION.md` §21 में। इसलिए ऐप में ये तारीख़ें हमेशा
/// **"लगभग"** कहकर ही दिखें, और साथ में यह कि अपने पंचांग से मिला लें।
///
/// ⚠️ यहाँ की संख्याएँ (11, 10, 8) किसी सूची से मिलाने के लिए मत बदलना।
/// तीसरे तरीक़े को "बैठाने" के लिए कोई नई दहलीज़ भी मत जोड़ना (→ D-014, D-019)।

/// अस्त गिनने का तरीक़ा — ऊपर की तालिका देखो।
enum AstGanana {
  /// देशांतर का अंतर कालांश जितने अंश से कम।
  ansh,

  /// उदय/अस्त के समय का अंतर कालांश (× 60 असु) से कम। जगह से बदलता है।
  kalansh,
}

/// गुरु या शुक्र का एक अस्त-काल।
class GrahaAst {
  final Graha graha;

  /// अस्त का पल, स्थानीय समय में।
  ///
  /// [AstGanana.ansh] में — जब देशांतर का अंतर कालांश से कम हुआ।
  /// [AstGanana.kalansh] में — पहली शाम (या भोर) जब ग्रह नहीं दिखा; उस दिन
  /// ग्रह के डूबने (या उगने) का पल।
  final DateTime ast;

  /// उदय का पल, स्थानीय समय में — ऊपर जैसा ही, उलटकर।
  final DateTime uday;

  /// अस्त पूर्व में हुआ (भोर का तारा डूबा)? नहीं तो पश्चिम में।
  final bool astPurvMein;

  /// उदय पूर्व में हुआ (भोर में दिखा)? नहीं तो पश्चिम में।
  final bool udayPurvMein;

  /// जिस कालांश से यह अस्त गिना गया — 11, 10 या 8।
  final int kalansh;

  final AstGanana ganana;

  const GrahaAst({
    required this.graha,
    required this.ast,
    required this.uday,
    required this.astPurvMein,
    required this.udayPurvMein,
    required this.kalansh,
    required this.ganana,
  });

  /// अस्त से पहले के "वृद्ध" दिन — मुहूर्त चिंतामणि, संस्कार प्रकरण २७:
  /// «पुरः पश्चाद्भृगोर्बाल्यं त्रिदशाहं च वार्धकम्। पक्षं पञ्चदिनं ते द्वे गुरोः
  /// पक्षमुदाहृते» — शुक्र: पूर्व में अस्त से पहले 15, पश्चिम में 5; गुरु: 15।
  int get vardhakDin => graha == Graha.guru ? 15 : (astPurvMein ? 15 : 5);

  /// उदय के बाद के "बाल" दिन — वही श्लोक: शुक्र पूर्व में उगे तो 3, पश्चिम
  /// में 10; गुरु: 15।
  int get balyaDin => graha == Graha.guru ? 15 : (udayPurvMein ? 3 : 10);

  DateTime get astDin => DateTime.utc(ast.year, ast.month, ast.day);
  DateTime get udayDin => DateTime.utc(uday.year, uday.month, uday.day);

  /// वृद्ध दिनों का पहला दिन (मुख्य मत से)।
  DateTime get vardhakShuru => astDin.subtract(Duration(days: vardhakDin));

  /// बाल दिनों का आख़िरी दिन (मुख्य मत से)।
  DateTime get balyaAnt => udayDin.add(Duration(days: balyaDin));
}

/// बाल्य और वार्धक के दिनों पर दूसरे मत — मुहूर्त चिंतामणि, संस्कार प्रकरण २८:
/// «ते दशाहं द्वयोः प्रोक्ते कैश्चित्सप्तदिनं परैः। त्र्यहं त्वात्ययिकेऽप्यन्यैः» —
/// कोई दस दिन कहते हैं, कोई सात, और बहुत ज़रूरी काम में तीन।
const List<int> astKeMatantarDin = [10, 7, 3];

/// इस ग्रह का कालांश। सिर्फ़ गुरु और शुक्र के लिए — मांगलिक कामों में इन्हीं
/// दो का अस्त देखा जाता है।
int astKalansh(Graha g, {required bool vakri}) => switch (g) {
      Graha.guru => 11,
      Graha.shukra => vakri ? 8 : 10,
      _ => throw ArgumentError(
          'अस्त सिर्फ़ गुरु और शुक्र का निकलता है: ${g.naam}'),
    };

/// एक कालांश, दिन में: 60 असु = नाक्षत्र दिन का 360वाँ हिस्सा (≈ 3 मिनट 59 सेकंड)।
const double _ekKalanshDin = 0.99726957 / 360.0;

/// बिंदु जैसे पिंड के उदय-अस्त की दहलीज़: सिर्फ़ अपवर्तन (34′)।
const double _grahaDehleez = -0.5667;

/// ग्रह और सूर्य के देशांतर का अंतर, अंश (−180…180)। धन = ग्रह सूर्य से आगे,
/// यानी शाम को पश्चिम में दिखता है; ऋण = भोर में पूर्व में। JDE (TT) चाहिए।
double grahaSuryaAntar(Graha g, double jde) =>
    norm180(grahaLongitude(g, jde) - sunLongitudeVsop(jde));

/// दिए गए क्षण पर ग्रह की ऊँचाई (altitude), डिग्री। JD (UT) चाहिए।
double grahaUnchai(Graha g, double jdUt, Place place) {
  final jde = toEphemerisTime(jdUt);
  final p = grahaApparent(g, jde);
  final eps = trueObliquity(jde);

  final ra = norm360(atan2D(
    sinD(p.longitude) * cosD(eps) - tanD(p.latitude) * sinD(eps),
    cosD(p.longitude),
  ));
  final dec = asinD(
    sinD(p.latitude) * cosD(eps) +
        cosD(p.latitude) * sinD(eps) * sinD(p.longitude),
  );

  final lst = greenwichMeanSiderealTime(jdUt) + place.longitude;
  final hourAngle = norm180(lst - ra);

  return asinD(sinD(place.latitude) * sinD(dec) +
      cosD(place.latitude) * cosD(dec) * cosD(hourAngle));
}

/// [kendraJd] के ±5 घंटे में ग्रह क्षितिज कब पार करता है ([uday] = ऊपर की ओर)।
/// न करे तो null — तब ग्रह सूर्य से दूर है।
double? _kshitijPaar(Graha g, double kendraJd, Place place,
    {required bool uday}) {
  double gap(double jd) => grahaUnchai(g, jd, place) - _grahaDehleez;

  const kadam = 10.0 / 1440.0;
  const ekSecond = 1.0 / 86400.0;
  var pichlaJd = kendraJd - 5.0 / 24.0;
  var pichlaGap = gap(pichlaJd);

  for (var jd = pichlaJd + kadam; jd <= kendraJd + 5.0 / 24.0; jd += kadam) {
    final abGap = gap(jd);
    final paar =
        uday ? (pichlaGap < 0 && abGap >= 0) : (pichlaGap >= 0 && abGap < 0);
    if (paar) {
      var lo = pichlaJd, hi = jd;
      while (hi - lo > ekSecond) {
        final mid = (lo + hi) / 2;
        if ((gap(mid) < 0) == (pichlaGap < 0)) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return (lo + hi) / 2;
    }
    pichlaJd = jd;
    pichlaGap = abGap;
  }
  return null;
}

/// किसी स्थानीय दिन सूर्य के आस-पास ग्रह का उदय और अस्त (स्थानीय समय)।
///
/// `uday` — सूर्योदय के पाँच घंटे इधर-उधर ग्रह का उगना; `ast` — सूर्यास्त के
/// पाँच घंटे इधर-उधर ग्रह का डूबना। ग्रह सूर्य से दूर हो तो दोनों null हो
/// सकते हैं — यह फलन अस्त के आस-पास के दिनों के लिए है।
///
/// `suryodaySePehle` — ग्रह सूर्य से कितना पहले उगा (ऋण = बाद में);
/// `suryastKeBaad` — सूर्य के कितनी देर बाद डूबा (ऋण = पहले)।
({
  DateTime? uday,
  DateTime? ast,
  Duration? suryodaySePehle,
  Duration? suryastKeBaad,
})? grahaUdayAst(Graha g, int year, int month, int day, Place place) {
  final rs = sunriseSunset(year, month, day, place);
  if (rs.sunrise == null || rs.sunset == null) return null;
  final uJd = julianDayFromUtc(rs.sunrise!);
  final aJd = julianDayFromUtc(rs.sunset!);

  final gUday = _kshitijPaar(g, uJd, place, uday: true);
  final gAst = _kshitijPaar(g, aJd, place, uday: false);

  DateTime local(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);
  Duration avadhi(double din) => Duration(seconds: (din * 86400.0).round());

  return (
    uday: gUday == null ? null : local(gUday),
    ast: gAst == null ? null : local(gAst),
    suryodaySePehle: gUday == null ? null : avadhi(uJd - gUday),
    suryastKeBaad: gAst == null ? null : avadhi(gAst - aJd),
  );
}

/// [se] से [tak] तक (स्थानीय तारीख़ें, दोनों सहित) जो अस्त-काल पड़ते हैं —
/// वे भी जो [se] से पहले शुरू हुए या [tak] के बाद ख़त्म होंगे।
///
/// [AstGanana.kalansh] जगह से बदलता है और धीमा है (हर दिन ग्रह का उदय-अस्त
/// निकलता है) — उसे `build` के भीतर मत बुलाना।
List<GrahaAst> grahaAstKaal(
  Graha g,
  DateTime se,
  DateTime tak,
  Place place, {
  AstGanana ganana = AstGanana.ansh,
}) {
  // शुक्र की लंबी अस्त तीन महीने से ऊपर जा सकती है — इतना आगे-पीछे देखो
  const haashiya = Duration(days: 130);
  final shuru = DateTime.utc(se.year, se.month, se.day).subtract(haashiya);
  final ant = DateTime.utc(tak.year, tak.month, tak.day).add(haashiya);

  final sab = ganana == AstGanana.ansh
      ? _anshSe(g, shuru, ant, place)
      : _kalanshSe(g, shuru, ant, place);

  final seDin = DateTime.utc(se.year, se.month, se.day);
  final takDin = DateTime.utc(tak.year, tak.month, tak.day);
  return [
    for (final a in sab)
      if (!a.udayDin.isBefore(seDin) && !a.astDin.isAfter(takDin)) a,
  ];
}

// ─────────────────────────────────────────────────────────────
// अंश से — देशांतर का अंतर
// ─────────────────────────────────────────────────────────────

List<GrahaAst> _anshSe(Graha g, DateTime shuru, DateTime ant, Place place) {
  DateTime local(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  // धन = अस्त नहीं (कालांश से बाहर)
  double gap(double jdUt) {
    final jde = toEphemerisTime(jdUt);
    return grahaSuryaAntar(g, jde).abs() -
        astKalansh(g, vakri: grahaVakri(g, jde));
  }

  double paar(double lo, double hi) {
    final loAst = gap(lo) < 0;
    var a = lo, b = hi;
    while (b - a > 1.0 / 86400.0) {
      final mid = (a + b) / 2;
      if ((gap(mid) < 0) == loAst) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return (a + b) / 2;
  }

  final mile = <GrahaAst>[];
  final tzDin = place.timeZoneOffset.inSeconds / 86400.0;
  var jd = julianDay(shuru.year, shuru.month, shuru.day.toDouble()) - tzDin;
  final antJd = julianDay(ant.year, ant.month, ant.day.toDouble()) - tzDin;

  var pichlaAst = gap(jd) < 0;
  double? astJd;
  for (jd += 1.0; jd <= antJd; jd += 1.0) {
    final abAst = gap(jd) < 0;
    if (abAst && !pichlaAst) {
      astJd = paar(jd - 1.0, jd);
    } else if (!abAst && pichlaAst && astJd != null) {
      final udayJd = paar(jd - 1.0, jd);
      final astJde = toEphemerisTime(astJd);
      mile.add(GrahaAst(
        graha: g,
        ast: local(astJd),
        uday: local(udayJd),
        // अस्त के पल ग्रह सूर्य से पीछे (ऋण) हो तो वह भोर का तारा था — पूर्व में डूबा
        astPurvMein: grahaSuryaAntar(g, astJde) < 0,
        udayPurvMein: grahaSuryaAntar(g, toEphemerisTime(udayJd)) < 0,
        kalansh: astKalansh(g, vakri: grahaVakri(g, astJde)),
        ganana: AstGanana.ansh,
      ));
      astJd = null;
    }
    pichlaAst = abAst;
  }
  return mile;
}

// ─────────────────────────────────────────────────────────────
// कालांश से — उदय/अस्त के समय का अंतर (सूर्यसिद्धांत ९.५)
// ─────────────────────────────────────────────────────────────

List<GrahaAst> _kalanshSe(Graha g, DateTime shuru, DateTime ant, Place place) {
  DateTime local(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  final mile = <GrahaAst>[];
  var pichlaAst = false;
  var pehlaDin = true;
  DateTime? astPal;
  var astPurv = false;
  var astKalanshMaan = 0;

  for (var d = shuru; !d.isAfter(ant); d = d.add(const Duration(days: 1))) {
    final rs = sunriseSunset(d.year, d.month, d.day, place);
    if (rs.sunrise == null || rs.sunset == null) continue;
    final uJd = julianDayFromUtc(rs.sunrise!);
    final aJd = julianDayFromUtc(rs.sunset!);
    final jde = toEphemerisTime(aJd);
    final antar = grahaSuryaAntar(g, jde);

    var abAst = false;
    double? gUday, gAst;
    var kalansh = 0;
    // सूर्य से 30° से दूर ग्रह अस्त नहीं हो सकता — वहाँ उदय-अस्त मत निकालो
    if (antar.abs() < 30.0) {
      kalansh = astKalansh(g, vakri: grahaVakri(g, jde));
      final had = kalansh * _ekKalanshDin;
      gUday = _kshitijPaar(g, uJd, place, uday: true);
      gAst = _kshitijPaar(g, aJd, place, uday: false);
      final shaamDikha = gAst != null && gAst - aJd >= had;
      final subahDikha = gUday != null && uJd - gUday >= had;
      abAst = !(shaamDikha || subahDikha);
    }

    if (!pehlaDin) {
      if (abAst && !pichlaAst) {
        // ग्रह सूर्य से आगे था तो शाम का तारा था — पश्चिम में डूबा
        astPurv = antar < 0;
        final pal = astPurv ? gUday : gAst;
        astPal = local(pal ?? (astPurv ? uJd : aJd));
        astKalanshMaan = kalansh;
      } else if (!abAst && pichlaAst && astPal != null) {
        final udayPurv = antar < 0;
        final pal = udayPurv ? gUday : gAst;
        mile.add(GrahaAst(
          graha: g,
          ast: astPal,
          uday: local(pal ?? (udayPurv ? uJd : aJd)),
          astPurvMein: astPurv,
          udayPurvMein: udayPurv,
          kalansh: astKalanshMaan,
          ganana: AstGanana.kalansh,
        ));
        astPal = null;
      }
    }
    pichlaAst = abAst;
    pehlaDin = false;
  }
  return mile;
}
