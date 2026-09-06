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
///
/// सूर्यग्रहण में भी यही दहलीज़ लगती है — ग्रहण तब तक दिखता है जब तक
/// सूरज की कोर क्षितिज पर है (→ `surya_grahan.dart`, D-055)।
const double suryodayKiDehleez = -0.8333;

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
  var previousDiff = sunAltitude(previousJd, place) - suryodayKiDehleez;

  for (var jd = localMidnightJd + step; jd <= localMidnightJd + 1.0; jd += step) {
    final diff = sunAltitude(jd, place) - suryodayKiDehleez;

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

  final loSign = (sunAltitude(lo, place) - suryodayKiDehleez).sign;

  while (hi - lo > oneSecond) {
    final mid = (lo + hi) / 2;
    final midDiff = sunAltitude(mid, place) - suryodayKiDehleez;
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

/// ब्रह्म मुहूर्त सूर्योदय से कितना पहले शुरू होता है।
///
/// रात के तीस मुहूर्तों में यह चौदहवाँ है — यानी सूर्योदय से **दो मुहूर्त
/// (96 मिनट) पहले**, और अड़तालीस मिनट तक चलता है।
const Duration brahmaMuhurtaSePehle = Duration(minutes: 96);

/// एक पूरा दिन — **ब्रह्म मुहूर्त से अगले ब्रह्म मुहूर्त तक।**
///
/// ## यह क्यों बना, और सीमा सूर्योदय पर क्यों नहीं
///
/// ऐप को कई जगह यह तय करना पड़ता है कि *"क्या यह अब भी उसी दिन की बात
/// है?"* — जैसे अधूरी छूटी पूजा कब तक याद रखनी है (→ D-044)।
///
/// **आधी रात का 12 बजे वाला हिसाब साफ़ ग़लत है।** इस ऐप की तीन सबसे बड़ी
/// पूजाएँ रात में ही होती हैं — जन्माष्टमी की **आधी रात को** (निशीथ),
/// महाशिवरात्रि की भी निशीथ काल में, दीपावली की प्रदोष काल में। बारह बजे
/// दिन बदलना इन तीनों को **बीच पूजा में** काट देता।
///
/// **पर सीमा सूर्योदय भी नहीं हो सकती।** बहुत लोग सूर्योदय से पहले उठकर,
/// ब्रह्म मुहूर्त में पूजा करते हैं — और वो *अगले* दिन की पूजा है, पिछले
/// दिन की नहीं। सूर्योदय वाली सीमा उन्हें सुबह चार बजे कल की अधूरी पूजा
/// थमा देती।
///
/// **ब्रह्म मुहूर्त दोनों बातें एक साथ सँभाल लेता है:**
///
/// ```
/// …दिन N…  प्रदोष  निशीथ ┊ ब्रह्म मुहूर्त  सूर्योदय  …दिन N+1…
///          (दीपावली) (जन्माष्टमी)  ┊  (सुबह की पूजा)
///                          ┊
///                     यहाँ दिन बदलता है
/// ```
///
/// रात की पूजाएँ पूरी बचती हैं, और सुबह उठने वाले को नया दिन मिलता है।
///
/// ⚠️ यह **पंचांग वाला दिन नहीं** है। तिथि, नक्षत्र और त्योहार अब भी
/// सूर्योदय से ही तय होते हैं ([sunriseSunset] देखो) — वो गणित मत छूना।
/// यह सिर्फ़ *"वही बैठक है या नई"* वाला सवाल हल करता है।
class HinduDin {
  /// `20260904` जैसी गिनती — दो दिनों को सीधे भिड़ाने के लिए।
  ///
  /// यह उस **स्थानीय तारीख़** की है जिसके सूर्योदय की तरफ़ यह दिन जा रहा
  /// है। यानी 4 सितम्बर की आधी रात (जो 5 सितम्बर की तारीख़ में पड़ती है)
  /// भी `20260904` ही है।
  final int ginti;

  /// यह दिन जहाँ शुरू हुआ — उस सुबह का ब्रह्म मुहूर्त, **असली पल** (UTC)।
  final DateTime aarambh;

  /// यह दिन जहाँ ख़त्म होगा — अगली सुबह का ब्रह्म मुहूर्त, **असली पल**।
  final DateTime ant;

  /// इस दिन का सूर्योदय — पंचांग इसी से चलता है।
  final DateTime suryoday;

  const HinduDin({
    required this.ginti,
    required this.aarambh,
    required this.ant,
    required this.suryoday,
  });

  /// यह पल इसी हिंदू दिन के भीतर है या नहीं।
  ///
  /// ⚠️ [moment] **असली पल** होना चाहिए — `DateTime.now()` या
  /// `DateTime.fromMillisecondsSinceEpoch(...)`. घड़ी वाला नक़ली UTC
  /// (जैसा `muhurta.dart` के टुकड़ों में है) यहाँ मत भेजना।
  bool samaayeHai(DateTime moment) =>
      !moment.isBefore(aarambh) && moment.isBefore(ant);

  @override
  String toString() => 'हिंदू दिन $ginti';
}

/// इस पल पर कौन सा दिन चल रहा है — **ब्रह्म मुहूर्त की सीमा से।**
///
/// रात का समय **पिछले दिन** में गिना जाता है, पर सुबह ब्रह्म मुहूर्त लगते
/// ही नया दिन शुरू हो जाता है। यानी रात 11 बजे और रात 1 बजे एक ही दिन
/// हैं, पर सुबह 4:30 बजे (ब्रह्म मुहूर्त में) अगला दिन है।
///
/// ⚠️ [moment] असली पल होना चाहिए ([HinduDin.samaayeHai] देखो)।
/// ध्रुवीय इलाक़ों में सूरज न उगे तो `null` — बुलाने वाला अपना रास्ता तय करे।
HinduDin? hinduDin(DateTime moment, Place place) {
  /// किसी स्थानीय तारीख़ की सुबह, दिन कहाँ बदलता है।
  DateTime? seema(DateTime din) {
    final suryoday =
        sunriseSunset(din.year, din.month, din.day, place).sunrise;
    return suryoday?.subtract(brahmaMuhurtaSePehle);
  }

  // असली पल से स्थानीय तारीख़ निकालो — भारत में +5:30 जोड़कर।
  final sthaniya = moment.toUtc().add(place.timeZoneOffset);
  var din = DateTime.utc(sthaniya.year, sthaniya.month, sthaniya.day);

  var aarambh = seema(din);
  if (aarambh == null) return null;

  // आज की सीमा से पहले हैं — यानी अभी पिछला दिन ही चल रहा है।
  if (moment.isBefore(aarambh)) {
    din = din.subtract(const Duration(days: 1));
    aarambh = seema(din);
    if (aarambh == null) return null;
  }

  final ant = seema(din.add(const Duration(days: 1)));
  final suryoday = sunriseSunset(din.year, din.month, din.day, place).sunrise;
  if (ant == null || suryoday == null) return null;

  return HinduDin(
    ginti: din.year * 10000 + din.month * 100 + din.day,
    aarambh: aarambh,
    ant: ant,
    suryoday: suryoday,
  );
}
