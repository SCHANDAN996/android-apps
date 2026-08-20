import 'angles.dart';
import 'ayanamsa.dart';
import 'julian.dart';
import 'moon.dart';
import 'moonrise.dart';
import 'names.dart';
import 'place.dart';
import 'sun.dart';
import 'sunrise.dart';

/// पंचांग का एक अंग — तिथि, नक्षत्र, योग या करण।
class Anga {
  /// 0 से गिनती (कोड के लिए)। करण में यह नाम की सूची का क्रमांक है।
  final int index;

  /// 1 से गिनती (लोगों के लिए)।
  int get number => index + 1;

  final String name;

  /// कब शुरू हुआ। पिछले दिन का भी हो सकता है।
  final DateTime? startsAt;

  /// कब ख़त्म होगा।
  final DateTime? endsAt;

  /// सूर्योदय के वक़्त कितना बीत चुका था, 0 से 1 के बीच।
  final double fractionElapsed;

  const Anga({
    required this.index,
    required this.name,
    required this.startsAt,
    required this.endsAt,
    required this.fractionElapsed,
  });

  @override
  String toString() => name;
}

/// दिन का एक कालखंड — राहुकाल, यमगंड, गुलिक, अभिजित, भद्रा।
class Kaal {
  final String name;
  final DateTime start;
  final DateTime end;

  const Kaal(this.name, this.start, this.end);

  Duration get duration => end.difference(start);

  @override
  String toString() => name;
}

/// किसी एक दिन का पूरा पंचांग।
///
/// अंगों के **मान सूर्योदय के क्षण** के हैं। साथ में हर अंग की पूरी
/// सूची भी है — सूर्योदय से अगले सूर्योदय तक जितने अंग बदले।
class Panchang {
  final DateTime date;
  final Place place;

  final DateTime? sunrise;
  final DateTime? sunset;

  /// अगले दिन का सूर्योदय — हिंदू दिन यहीं ख़त्म होता है।
  final DateTime? nextSunrise;

  /// चंद्रोदय और चंद्रास्त।
  ///
  /// ⚠️ **`null` होना ग़लती नहीं है।** चंद्रमा रोज़ ~50 मिनट देर से उगता
  /// है, इसलिए महीने में एक बार ऐसा दिन आता है जब उदय (या अस्त) उस
  /// तारीख़ में पड़ता ही नहीं। छपे पंचांग में भी वहाँ जगह ख़ाली रहती है।
  final DateTime? moonrise;
  final DateTime? moonset;

  // ── सूर्योदय के वक़्त के अंग ──
  final Anga tithi;
  final Anga nakshatra;
  final Anga yoga;
  final Anga karana;

  // ── पूरे हिंदू दिन में जितने अंग बदले ──
  //
  // छपे पंचांग में यही दिखता है। जैसे 365 में से 349 दिन ऐसे होते हैं
  // जिनमें दो करण चलते हैं — सिर्फ़ सूर्योदय वाला दिखाना अधूरा है।
  final List<Anga> tithis;
  final List<Anga> nakshatras;
  final List<Anga> yogas;
  final List<Anga> karanas;

  /// क्षय तिथि — जो तिथि किसी सूर्योदय को छू ही नहीं पाई, इसलिए
  /// कैलेंडर से ग़ायब हो गई। null का मतलब आज कोई क्षय नहीं।
  final int? kshayaTithiIndex;
  String? get kshayaTithiName =>
      kshayaTithiIndex == null ? null : tithiNames[kshayaTithiIndex!];

  /// वृद्धि तिथि — जो तिथि दो सूर्योदय तक खिंच गई, यानी दो दिन वही तिथि।
  final bool isVriddhiTithi;

  /// 0 = रविवार
  final int vara;
  String get varaName => varaNames[vara];

  /// 0 = शुक्ल, 1 = कृष्ण
  final int paksha;
  String get pakshaName => pakshaNames[paksha];

  /// चुनी हुई पद्धति (अमांत/पूर्णिमांत) के हिसाब से मास।
  final int masa;
  String get masaName => masaNames[masa];
  final MasaSystem masaSystem;

  /// अधिक मास है या नहीं।
  ///
  /// अधिक (पुरुषोत्तम) मास हर ढाई-तीन साल में एक बार आता है — जब किसी
  /// चांद्र मास में सूर्य राशि नहीं बदलता। जैसे 2026 में **अधिक ज्येष्ठ**,
  /// 17 मई से 15 जून तक।
  final bool isAdhikaMasa;

  /// दिखाने वाला पूरा नाम — अधिक मास हो तो आगे "अधिक" लगाकर।
  /// ऐप में हमेशा यही दिखाना, सादा [masaName] नहीं।
  String get masaFullName => isAdhikaMasa ? 'अधिक $masaName' : masaName;

  final int vikramSamvat;
  final int shakaSamvat;

  /// संवत्सर का नाम — साठ साल का बृहस्पति चक्र।
  /// उत्तर और दक्षिण के चक्र अलग चलते हैं, इसलिए दोनों अलग।
  String get vikramSamvatsara => vikramSamvatsaraOf(vikramSamvat);
  String get shakaSamvatsara => shakaSamvatsaraOf(shakaSamvat);

  /// 0 = उत्तरायण, 1 = दक्षिणायन
  final int ayana;
  String get ayanaName => ayanaNames[ayana];

  final int ritu;
  String get rituName => rituNames[ritu];

  final int sunRashi;
  String get sunRashiName => rashiNames[sunRashi];

  final int moonRashi;
  String get moonRashiName => rashiNames[moonRashi];

  /// सूर्योदय के क्षण का अयनांश, डिग्री। जाँच के लिए।
  final double ayanamsa;

  // ── दिन के कालखंड ──
  final Kaal? rahuKaal;
  final Kaal? yamaganda;
  final Kaal? gulika;
  final Kaal? abhijit;

  /// भद्रा — विष्टि करण का समय। इसमें शुभ काम नहीं होते।
  final Kaal? bhadra;

  /// दिनमान — सूर्योदय से सूर्यास्त तक।
  final Duration? dinamana;

  /// रात्रिमान — सूर्यास्त से अगले सूर्योदय तक।
  final Duration? ratrimana;

  /// पंचक — चंद्रमा कुम्भ-मीन में (धनिष्ठा के तीसरे चरण से रेवती तक)।
  final bool isPanchak;

  /// गंडमूल नक्षत्र — अश्विनी, आश्लेषा, मघा, ज्येष्ठा, मूल, रेवती।
  bool get isGandmool => gandmoolNakshatras.contains(nakshatra.index);

  const Panchang({
    required this.date,
    required this.place,
    required this.sunrise,
    required this.sunset,
    required this.nextSunrise,
    required this.moonrise,
    required this.moonset,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.tithis,
    required this.nakshatras,
    required this.yogas,
    required this.karanas,
    required this.kshayaTithiIndex,
    required this.isVriddhiTithi,
    required this.vara,
    required this.paksha,
    required this.masa,
    required this.masaSystem,
    required this.isAdhikaMasa,
    required this.vikramSamvat,
    required this.shakaSamvat,
    required this.ayana,
    required this.ritu,
    required this.sunRashi,
    required this.moonRashi,
    required this.ayanamsa,
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.abhijit,
    required this.bhadra,
    required this.dinamana,
    required this.ratrimana,
    required this.isPanchak,
  });

  /// पुराने कोड के लिए — राहुकाल की शुरुआत और अंत सीधे।
  DateTime? get rahuKaalStart => rahuKaal?.start;
  DateTime? get rahuKaalEnd => rahuKaal?.end;
}

// ─────────────────────────────────────────────────────────────
// कोण निकालने वाले छोटे फलन। सब JD (UT) लेते हैं।
// ─────────────────────────────────────────────────────────────

/// चंद्र और सूर्य के बीच का कोण। तिथि और करण इसी से बनते हैं।
double elongationAt(double jdUt) {
  final jde = toEphemerisTime(jdUt);
  return norm360(moonLongitude(jde) - sunApparentLongitude(jde));
}

/// चंद्र का निरयन देशांतर। नक्षत्र इसी से।
double moonSiderealAt(double jdUt) {
  final jde = toEphemerisTime(jdUt);
  return toSidereal(moonLongitude(jde), jde);
}

/// सूर्य का निरयन देशांतर। मास, अयन और राशि इसी से।
double sunSiderealAt(double jdUt) {
  final jde = toEphemerisTime(jdUt);
  return toSidereal(sunApparentLongitude(jde), jde);
}

/// सूर्य और चंद्र के निरयन देशांतरों का जोड़। योग इसी से।
double yogaAngleAt(double jdUt) {
  final jde = toEphemerisTime(jdUt);
  return norm360(
      toSidereal(moonLongitude(jde), jde) + toSidereal(sunApparentLongitude(jde), jde));
}

// ─────────────────────────────────────────────────────────────
// जड़-खोज — "ये कोण कब पार होगा"
// ─────────────────────────────────────────────────────────────

const double _oneSecond = 1.0 / 86400.0;
const double _searchStep = 0.02; // लगभग 29 मिनट

/// [angleAt] नाम का कोण [targetDeg] को कब पार करेगा, [startJd] के बाद।
///
/// चारों अंगों के कोण हमेशा आगे ही बढ़ते हैं (कभी पीछे नहीं जाते),
/// इसलिए सीधा-सादा द्विभाजन काफ़ी है। एक सेकंड तक सटीक।
double? findCrossing(
  double Function(double) angleAt,
  double targetDeg,
  double startJd,
  double maxDays,
) {
  double gap(double jd) => norm180(angleAt(jd) - targetDeg);

  var previousJd = startJd;
  var previousGap = gap(previousJd);

  for (var jd = startJd + _searchStep; jd <= startJd + maxDays; jd += _searchStep) {
    final currentGap = gap(jd);

    if (previousGap < 0 && currentGap >= 0) {
      return _bisect(gap, previousJd, jd);
    }

    previousJd = jd;
    previousGap = currentGap;
  }
  return null;
}

/// वही खोज, पर पीछे की तरफ़ — "ये कोण पार कब हुआ था"।
/// किसी अंग की शुरुआत का समय निकालने के लिए।
double? findPreviousCrossing(
  double Function(double) angleAt,
  double targetDeg,
  double beforeJd,
  double maxDays,
) {
  double gap(double jd) => norm180(angleAt(jd) - targetDeg);

  var laterJd = beforeJd;
  var laterGap = gap(laterJd);

  for (var jd = beforeJd - _searchStep; jd >= beforeJd - maxDays; jd -= _searchStep) {
    final currentGap = gap(jd);

    if (currentGap < 0 && laterGap >= 0) {
      return _bisect(gap, jd, laterJd);
    }

    laterJd = jd;
    laterGap = currentGap;
  }
  return null;
}

double _bisect(double Function(double) gap, double lowJd, double highJd) {
  var lo = lowJd;
  var hi = highJd;
  while (hi - lo > _oneSecond) {
    final mid = (lo + hi) / 2;
    if (gap(mid) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// इस क्षण से पहले की आख़िरी अमावस्या (जब चंद्र-सूर्य का कोण 0 था)।
/// चांद्र मास यहीं से शुरू होता है।
double previousNewMoon(double jdUt) {
  final elongation = elongationAt(jdUt);

  // कोण औसतन 12.19° प्रतिदिन बढ़ता है — पहला अंदाज़ा वहीं से
  final guess = jdUt - elongation / 12.19;

  double gap(double jd) => norm180(elongationAt(jd));

  return _bisect(gap, guess - 1.5, guess + 1.5);
}

// ─────────────────────────────────────────────────────────────
// मुख्य गणना
// ─────────────────────────────────────────────────────────────

/// किसी स्थानीय तारीख़ और जगह का पूरा पंचांग।
///
/// **अंगों के मान सूर्योदय के क्षण के हैं** — यही हिंदू दिन की शुरुआत है।
/// [masaSystem] डिफ़ॉल्ट में पूर्णिमांत, क्योंकि उत्तर भारत वही मानता है।
Panchang computePanchang(
  int year,
  int month,
  int day,
  Place place, {
  MasaSystem masaSystem = MasaSystem.purnimanta,
}) {
  final riseSet = sunriseSunset(year, month, day, place);
  final riseJd = sunriseJd(year, month, day, place);

  final moonTimes = moonriseMoonset(year, month, day, place);

  final nextDay = DateTime.utc(year, month, day).add(const Duration(days: 1));
  final nextRiseJd = sunriseJd(nextDay.year, nextDay.month, nextDay.day, place);

  DateTime toLocal(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);
  DateTime? toLocalOrNull(double? jd) => jd == null ? null : toLocal(jd);

  // ── चारों अंग, सूर्योदय के वक़्त और पूरे दिन की सूची ──
  const nakshatraSpan = 360.0 / 27.0; // 13°20'

  final tithis = _angaSeries(
    angleAt: elongationAt,
    span: 12.0,
    cycle: 30,
    nameOf: (count) => tithiNames[count],
    indexOf: (count) => count,
    fromJd: riseJd,
    toJd: nextRiseJd,
    maxDays: 2.5,
    toLocal: toLocal,
  );

  final nakshatras = _angaSeries(
    angleAt: moonSiderealAt,
    span: nakshatraSpan,
    cycle: 27,
    nameOf: (count) => nakshatraNames[count],
    indexOf: (count) => count,
    fromJd: riseJd,
    toJd: nextRiseJd,
    maxDays: 2.5,
    toLocal: toLocal,
  );

  final yogas = _angaSeries(
    angleAt: yogaAngleAt,
    span: nakshatraSpan,
    cycle: 27,
    nameOf: (count) => yogaNames[count],
    indexOf: (count) => count,
    fromJd: riseJd,
    toJd: nextRiseJd,
    maxDays: 2.5,
    toLocal: toLocal,
  );

  final karanas = _angaSeries(
    angleAt: elongationAt,
    span: 6.0,
    cycle: 60,
    nameOf: (count) => karanaNames[karanaNameIndex(count)],
    indexOf: (count) => karanaNameIndex(count),
    fromJd: riseJd,
    toJd: nextRiseJd,
    maxDays: 1.5,
    toLocal: toLocal,
  );

  final tithi = tithis.first;
  final nakshatra = nakshatras.first;
  final yoga = yogas.first;
  final karana = karanas.first;

  // ── क्षय और वृद्धि तिथि ──
  //
  // तिथि 19 से 26 घंटे चलती है, और दिन 24 घंटे का। इसलिए कभी कोई तिथि
  // दो सूर्योदय छू लेती है (वृद्धि), तो कभी कोई सूर्योदय छू ही नहीं
  // पाती और कैलेंडर से ग़ायब हो जाती है (क्षय)।
  final tithiAtNextSunrise = (elongationAt(nextRiseJd) / 12.0).floor() % 30;
  final tithiJump = (tithiAtNextSunrise - tithi.index + 30) % 30;
  final isVriddhi = tithiJump == 0;
  final kshayaTithiIndex = tithiJump == 2 ? (tithi.index + 1) % 30 : null;

  // ── पक्ष ──
  final paksha = tithi.index < 15 ? 0 : 1;

  // ── मास ──
  final newMoonJd = previousNewMoon(riseJd);
  final sunRashiAtNewMoon = (sunSiderealAt(newMoonJd) / 30.0).floor() % 12;
  final amantaMasa = (sunRashiAtNewMoon + 1) % 12;

  // अधिक मास: अगर इस अमावस्या और अगली के बीच सूर्य ने राशि नहीं बदली
  final nextNewMoonJd = previousNewMoon(newMoonJd + 32.0);
  final sunRashiAtNextNewMoon = (sunSiderealAt(nextNewMoonJd) / 30.0).floor() % 12;
  final isAdhika = sunRashiAtNewMoon == sunRashiAtNextNewMoon;

  // पूर्णिमांत में कृष्ण पक्ष का मास एक आगे का होता है —
  // **पर अधिक मास में नहीं।**
  //
  // अधिक मास पूरा का पूरा एक अतिरिक्त महीना होता है, इसलिए उसमें दोनों
  // पद्धतियाँ एक ही नाम लेती हैं। 1 जून 2026 (कृष्ण प्रतिपदा) पर Drik
  // दोनों जगह "ज्येष्ठ (अधिक)" लिखता है।
  final masa = masaSystem == MasaSystem.purnimanta && paksha == 1 && !isAdhika
      ? (amantaMasa + 1) % 12
      : amantaMasa;

  // ── संवत् ──
  // नया साल चैत्र शुक्ल प्रतिपदा से, जो मार्च–अप्रैल में पड़ता है
  int shaka;
  if (month >= 5) {
    shaka = year - 78;
  } else if (month <= 2) {
    shaka = year - 79;
  } else {
    shaka = amantaMasa == 11 ? year - 79 : year - 78;
  }
  final vikram = shaka + 135;

  // ── अयन, ऋतु, राशि ──
  final sunSidereal = sunSiderealAt(riseJd);
  final moonSidereal = moonSiderealAt(riseJd);
  final ayana = (sunSidereal >= 270.0 || sunSidereal < 90.0) ? 0 : 1;
  final ritu = amantaMasa ~/ 2;
  final sunRashi = (sunSidereal / 30.0).floor() % 12;
  final moonRashi = (moonSidereal / 30.0).floor() % 12;

  // पंचक — धनिष्ठा के तीसरे चरण (300°) से रेवती के अंत तक
  final isPanchak = moonSidereal >= 300.0;

  // ── वार ── (0 = रविवार)
  final vara = DateTime.utc(year, month, day).weekday % 7;

  // ── दिन के कालखंड ──
  Kaal? rahu, yama, gulik, abhijitKaal;
  Duration? dinamana, ratrimana;

  final sunriseLocal = toLocalOrNull(riseJd);
  final sunsetLocal =
      riseSet.sunset == null ? null : riseSet.sunset!.add(place.timeZoneOffset);
  final nextSunriseLocal = toLocalOrNull(nextRiseJd);

  if (sunriseLocal != null && sunsetLocal != null) {
    dinamana = sunsetLocal.difference(sunriseLocal);
    if (nextSunriseLocal != null) {
      ratrimana = nextSunriseLocal.difference(sunsetLocal);
    }

    // दिन के आठ भाग — राहुकाल, यमगंड और गुलिक इन्हीं में से एक-एक
    final eighth = dinamana.inMilliseconds ~/ 8;
    Kaal eighthPart(String name, int partIndex) {
      final start =
          sunriseLocal.add(Duration(milliseconds: eighth * partIndex));
      return Kaal(name, start, start.add(Duration(milliseconds: eighth)));
    }

    rahu = eighthPart('राहुकाल', rahuKaalPart[vara]);
    yama = eighthPart('यमगंड', yamagandaPart[vara]);
    gulik = eighthPart('गुलिक', gulikaPart[vara]);

    // अभिजित — दिन के पंद्रह मुहूर्तों में से आठवाँ
    final muhurta = dinamana.inMilliseconds ~/ 15;
    final abhijitStart = sunriseLocal.add(Duration(milliseconds: muhurta * 7));
    abhijitKaal = Kaal(
        'अभिजित', abhijitStart, abhijitStart.add(Duration(milliseconds: muhurta)));
  }

  // ── भद्रा — विष्टि करण का समय ──
  Kaal? bhadra;
  for (final k in karanas) {
    if (k.index == 6 && k.startsAt != null && k.endsAt != null) {
      bhadra = Kaal('भद्रा', k.startsAt!, k.endsAt!);
      break;
    }
  }

  return Panchang(
    date: DateTime.utc(year, month, day),
    place: place,
    sunrise: sunriseLocal,
    sunset: sunsetLocal,
    nextSunrise: nextSunriseLocal,
    moonrise: moonTimes.moonrise,
    moonset: moonTimes.moonset,
    tithi: tithi,
    nakshatra: nakshatra,
    yoga: yoga,
    karana: karana,
    tithis: tithis,
    nakshatras: nakshatras,
    yogas: yogas,
    karanas: karanas,
    kshayaTithiIndex: kshayaTithiIndex,
    isVriddhiTithi: isVriddhi,
    vara: vara,
    paksha: paksha,
    masa: masa,
    masaSystem: masaSystem,
    isAdhikaMasa: isAdhika,
    vikramSamvat: vikram,
    shakaSamvat: shaka,
    ayana: ayana,
    ritu: ritu,
    sunRashi: sunRashi,
    moonRashi: moonRashi,
    ayanamsa: lahiriAyanamsa(toEphemerisTime(riseJd)),
    rahuKaal: rahu,
    yamaganda: yama,
    gulika: gulik,
    abhijit: abhijitKaal,
    bhadra: bhadra,
    dinamana: dinamana,
    ratrimana: ratrimana,
    isPanchak: isPanchak,
  );
}

/// सूर्योदय से अगले सूर्योदय तक जितने अंग बदले, सबकी सूची।
List<Anga> _angaSeries({
  required double Function(double) angleAt,
  required double span,
  required int cycle,
  required String Function(int count) nameOf,
  required int Function(int count) indexOf,
  required double fromJd,
  required double toJd,
  required double maxDays,
  required DateTime Function(double) toLocal,
}) {
  final result = <Anga>[];
  var cursor = fromJd;

  // एक दिन में चार से ज़्यादा करण कभी नहीं बदलते — यह सिर्फ़ सुरक्षा के लिए
  for (var guard = 0; guard < 8; guard++) {
    final angle = angleAt(cursor);
    final count = (angle / span).floor() % cycle;

    final endJd = findCrossing(angleAt, ((count + 1) * span) % 360.0, cursor, maxDays);
    if (endJd == null) break;

    final startJd =
        findPreviousCrossing(angleAt, (count * span) % 360.0, cursor, maxDays);

    result.add(Anga(
      index: indexOf(count),
      name: nameOf(count),
      startsAt: startJd == null ? null : toLocal(startJd),
      endsAt: toLocal(endJd),
      fractionElapsed: (angle - count * span) / span,
    ));

    if (endJd >= toJd) break;
    cursor = endJd + _oneSecond;
  }

  return result;
}
