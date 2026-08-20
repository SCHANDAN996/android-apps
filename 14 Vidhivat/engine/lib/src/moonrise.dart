import 'angles.dart';
import 'julian.dart';
import 'moon.dart';
import 'place.dart';
import 'sun.dart';
import 'sunrise.dart';

/// चंद्रोदय और चंद्रास्त।
///
/// तरीक़ा सूर्योदय जैसा ही है — ऊँचाई का फलन बनाओ और जड़-खोज करो।
/// पर **दो बड़े फ़र्क़** हैं, और दोनों भूलना आसान है:
///
/// **1. लंबन (parallax)।** सूरज इतनी दूर है कि उसका लंबन नगण्य है।
/// चंद्रमा पास है — लगभग 0.95° का लंबन। इसीलिए क्षितिज की ऊँचाई
/// `−0.8333°` नहीं, बल्कि `0.7275·π − 34ʹ` होती है, जो लगभग `+0.125°`
/// बनती है। यानी चंद्रमा का उदय क्षितिज से **ऊपर** होता है, नीचे नहीं।
///
/// **2. हर दिन चंद्रोदय नहीं होता।** चंद्रमा रोज़ लगभग 50 मिनट देर से
/// उगता है, इसलिए महीने में एक बार ऐसा दिन आता है जब चंद्रोदय हुआ ही
/// नहीं (या चंद्रास्त हुआ ही नहीं)। **यह ग़लती नहीं है** — छपे पंचांग
/// में भी उस दिन जगह ख़ाली रहती है। इसलिए `null` लौटता है।

/// चंद्रमा का दाहिना आरोहण (RA) और क्रांति (declination), डिग्री।
///
/// सूर्य से एक फ़र्क़: चंद्रमा का अक्षांश (β) शून्य नहीं होता, ±5.2° तक
/// जाता है — इसलिए बदलने का सूत्र भी पूरा वाला लगता है।
({double rightAscension, double declination}) moonEquatorial(double jde) {
  final lambda = moonLongitude(jde);
  final beta = moonLatitude(jde);
  final epsilon = trueObliquity(jde);

  final ra = norm360(atan2D(
    sinD(lambda) * cosD(epsilon) - tanD(beta) * sinD(epsilon),
    cosD(lambda),
  ));

  final dec = asinD(
    sinD(beta) * cosD(epsilon) + cosD(beta) * sinD(epsilon) * sinD(lambda),
  );

  return (rightAscension: ra, declination: dec);
}

/// दिए गए क्षण पर चंद्रमा की ऊँचाई (altitude), डिग्री। JD (UT) चाहिए।
double moonAltitude(double jdUt, Place place) {
  final jde = toEphemerisTime(jdUt);
  final eq = moonEquatorial(jde);

  final lst = greenwichMeanSiderealTime(jdUt) + place.longitude;
  final hourAngle = norm180(lst - eq.rightAscension);

  return asinD(sinD(place.latitude) * sinD(eq.declination) +
      cosD(place.latitude) * cosD(eq.declination) * cosD(hourAngle));
}

/// चंद्रोदय की दहलीज़ में सुधार, डिग्री। छपे पंचांग से मिलाकर ही बदलना।
///
/// ⚠️ **यहाँ एक अनसुलझा फ़र्क़ है — 21 अगस्त 2026 को नापा गया।**
///
/// Drik Panchang के बताए चंद्रोदय/चंद्रास्त के क्षण पर हमारी गणना में
/// चंद्रमा की भूकेंद्रीय ऊँचाई लगभग **+0.97°** निकलती है, जबकि Meeus का
/// मानक `0.7275·π − 34ʹ` लगभग **+0.09°** कहता है। छह नमूनों में (दिल्ली
/// और चेन्नई, अलग-अलग लंबन) यह 0.963° से 0.988° के बीच रहा — यानी
/// Drik की दहलीज़ लगभग स्थिर है, लंबन के साथ बदलती नहीं।
///
/// इसका मतलब **हमारी स्थिति ग़लत नहीं है** (चंद्र का अक्षांश Meeus की
/// अपनी मिसाल से शून्य फ़र्क़ पर मिलता है) — **परिभाषा अलग है।**
/// नतीजा: चंद्रोदय ~5 मिनट पहले, चंद्रास्त ~5 मिनट बाद।
///
/// **फ़ैसला (D-014 के मुताबिक़):** मानक वाला सूत्र ही रखा गया है, मिलाने
/// के लिए गणित नहीं बिगाड़ा। छपे ठाकुर प्रसाद पंचांग से जाँचने के बाद
/// अगर ज़रूरत पड़े तो नीचे वाली घुंडी घुमाना — बाक़ी कोड को हाथ मत लगाना।
///
/// (Drik से मिलाना हो तो यहाँ लगभग `0.88` डालना पड़ेगा।)
double moonHorizonAdjustment = 0.0;

/// उस क्षण चंद्रोदय/चंद्रास्त की क्षितिज-ऊँचाई, डिग्री।
///
///     h₀ = 0.7275·π − 34ʹ
///
/// जहाँ π क्षैतिज लंबन है (~0.95°) और 34ʹ वायुमंडलीय अपवर्तन।
/// नतीजा लगभग +0.1° आता है। यह Meeus अध्याय 15 का मानक है।
double _moonHorizon(double jdUt) =>
    0.7275 * moonParallax(toEphemerisTime(jdUt)) -
    0.5667 +
    moonHorizonAdjustment;

/// एक स्थानीय दिन का चंद्रोदय और चंद्रास्त।
///
/// [year], [month], [day] स्थानीय तारीख़ है। लौटाता है **स्थानीय समय** में।
/// किसी दिन उदय या अस्त न हो तो वहाँ `null` — यह सामान्य है, महीने में
/// एक बार होता ही है।
({DateTime? moonrise, DateTime? moonset}) moonriseMoonset(
  int year,
  int month,
  int day,
  Place place,
) {
  final localMidnightJd = julianDay(year, month, day.toDouble()) -
      place.timeZoneOffset.inSeconds / 86400.0;

  double gap(double jd) => moonAltitude(jd, place) - _moonHorizon(jd);

  DateTime? rise;
  DateTime? set;

  // चंद्रमा सूरज से तेज़ चलता है, इसलिए क़दम छोटे — 5 मिनट
  const step = 5.0 / (24.0 * 60.0);
  const oneSecond = 1.0 / 86400.0;

  var previousJd = localMidnightJd;
  var previousGap = gap(previousJd);

  for (var jd = localMidnightJd + step; jd <= localMidnightJd + 1.0; jd += step) {
    final currentGap = gap(jd);

    if (previousGap < 0 && currentGap >= 0 && rise == null) {
      rise = _refine(gap, previousJd, jd, oneSecond, place);
    } else if (previousGap > 0 && currentGap <= 0 && set == null) {
      set = _refine(gap, previousJd, jd, oneSecond, place);
    }

    previousJd = jd;
    previousGap = currentGap;
  }

  return (moonrise: rise, moonset: set);
}

DateTime _refine(double Function(double) gap, double lowJd, double highJd,
    double tolerance, Place place) {
  var lo = lowJd;
  var hi = highJd;
  final loSign = gap(lo).sign;

  while (hi - lo > tolerance) {
    final mid = (lo + hi) / 2;
    if (gap(mid).sign == loSign) {
      lo = mid;
    } else {
      hi = mid;
    }
  }

  return utcFromJulianDay((lo + hi) / 2).add(place.timeZoneOffset);
}
