import 'angles.dart';
import 'julian.dart';
import 'place.dart';
import 'sun.dart';

/// सूर्योदय और सूर्यास्त।
///
/// **यही पूरे पंचांग की धुरी है।** हिंदू दिन आधी रात से नहीं, सूर्योदय से
/// शुरू होता है। "आज की तिथि" का मतलब है — आज सूर्योदय के समय जो तिथि
/// चल रही थी। ये एक बात ग़लत हुई तो पूरा पंचांग एक दिन खिसक जाएगा।
///
/// तरीक़ा: Meeus की interpolation वाली विधि की जगह सीधा जड़-खोज
/// (root finding) — सूर्य की ऊँचाई का फलन बनाओ, और जहाँ वो −0.8333°
/// को पार करे वहाँ द्विभाजन (bisection) से समय निकालो। ये लिखने में
/// आसान है और ग़लती की गुंजाइश कम।

/// क्षितिज की मानक ऊँचाई: −50 कलामात्र।
/// इसमें वायुमंडलीय अपवर्तन (34') और सूर्य का अर्धव्यास (16') दोनों हैं।
const double _horizonAltitude = -0.8333;

/// ग्रीनविच का माध्य नाक्षत्र काल, डिग्री। Meeus 12.4। JD (UT) चाहिए।
double greenwichMeanSiderealTime(double jdUt) {
  final t = julianCenturies(jdUt);
  final theta = 280.46061837 +
      360.98564736629 * (jdUt - j2000) +
      0.000387933 * t * t -
      t * t * t / 38710000.0;
  return norm360(theta);
}

/// दिए गए क्षण पर सूर्य की ऊँचाई (altitude), डिग्री। JD (UT) चाहिए।
double sunAltitude(double jdUt, Place place) {
  final jde = toEphemerisTime(jdUt);
  final eq = sunEquatorial(jde);

  final lst = greenwichMeanSiderealTime(jdUt) + place.longitude;
  final hourAngle = norm180(lst - eq.rightAscension);

  return asinD(sinD(place.latitude) * sinD(eq.declination) +
      cosD(place.latitude) * cosD(eq.declination) * cosD(hourAngle));
}

/// एक स्थानीय दिन के सूर्योदय और सूर्यास्त।
///
/// [year], [month], [day] स्थानीय तारीख़ है (भारत में IST)।
/// लौटाता है UTC में — दिखाते वक़्त [Place.timeZoneOffset] जोड़ना।
/// ध्रुवीय इलाक़ों में सूरज न उगे तो null।
({DateTime? sunrise, DateTime? sunset}) sunriseSunset(
  int year,
  int month,
  int day,
  Place place,
) {
  // स्थानीय आधी रात का JD (UT में)
  final localMidnightJd =
      julianDay(year, month, day.toDouble()) - place.timeZoneOffset.inSeconds / 86400.0;

  DateTime? rise;
  DateTime? set;

  // 10 मिनट के क़दमों से पूरा दिन छानो, और जहाँ चिह्न बदले वहाँ बारीक़ी से खोजो
  const step = 10.0 / (24.0 * 60.0);
  var previousJd = localMidnightJd;
  var previousDiff = sunAltitude(previousJd, place) - _horizonAltitude;

  for (var jd = localMidnightJd + step; jd <= localMidnightJd + 1.0; jd += step) {
    final diff = sunAltitude(jd, place) - _horizonAltitude;

    if (previousDiff < 0 && diff >= 0 && rise == null) {
      rise = utcFromJulianDay(_bisect(previousJd, jd, place));
    } else if (previousDiff > 0 && diff <= 0 && set == null) {
      set = utcFromJulianDay(_bisect(previousJd, jd, place));
    }

    previousJd = jd;
    previousDiff = diff;
  }

  return (sunrise: rise, sunset: set);
}

/// दो क्षणों के बीच वो पल खोजो जहाँ सूरज क्षितिज पर था। एक सेकंड तक सटीक।
double _bisect(double lowJd, double highJd, Place place) {
  var lo = lowJd;
  var hi = highJd;
  const oneSecond = 1.0 / 86400.0;

  final loSign = (sunAltitude(lo, place) - _horizonAltitude).sign;

  while (hi - lo > oneSecond) {
    final mid = (lo + hi) / 2;
    final midDiff = sunAltitude(mid, place) - _horizonAltitude;
    if (midDiff.sign == loSign) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// सूर्योदय का JD (UT)। अगर सूरज न उगे तो स्थानीय 6 बजे मान लो —
/// भारत में ऐसा कभी नहीं होगा, पर गणित टूटना नहीं चाहिए।
double sunriseJd(int year, int month, int day, Place place) {
  final result = sunriseSunset(year, month, day, place);
  if (result.sunrise != null) {
    return julianDayFromUtc(result.sunrise!);
  }
  return julianDay(year, month, day + 0.25) - place.timeZoneOffset.inSeconds / 86400.0;
}
