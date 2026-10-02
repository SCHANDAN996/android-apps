import 'julian.dart';
import 'names.dart';
import 'panchang.dart';
import 'place.dart';

/// जन्म के **क्षण** का पंचांग (→ D-105, docs/29 चरण K3)।
///
/// `computePanchang` दिन का पंचांग देता है — अंग सूर्योदय के क्षण के। जन्म-पत्री
/// में जन्म के क्षण की तिथि, नक्षत्र, योग और करण लिखे जाते हैं, जो दिन के
/// पंचांग से अलग हो सकते हैं (दोपहर तक तिथि बदल चुकी हो सकती है)।
///
/// दो बातें जो आसानी से ग़लत होती हैं:
///
/// 1. **वार सूर्योदय से बदलता है, आधी रात से नहीं।** रात 2 बजे का जन्म पिछले
///    दिन के वार में गिना जाता है। [suryodaySePehle] यही बताता है।
/// 2. **मास और संवत् जन्म की तिथि के हैं, सूर्योदय की तिथि के नहीं।** अमावस्या
///    के सूर्योदय के बाद प्रतिपदा में जन्म हो, तो मास अगला है।
class JanmPanchang {
  /// जन्म — घड़ी का समय (UTC के खाने में, जैसे पूरे इंजन में)।
  final DateTime janmSthaniya;

  /// जिस हिंदू दिन में जन्म हुआ, उसकी तारीख़ (सूर्योदय वाली)।
  final DateTime hinduDin;

  /// जन्म आधी रात के बाद पर सूर्योदय से पहले हुआ — वार और हिंदू दिन पिछली
  /// तारीख़ के हैं।
  final bool suryodaySePehle;

  /// वार — 0 = रविवार।
  final int vara;

  /// जन्म के क्षण की तिथि — 0 = शुक्ल प्रतिपदा … 29 = अमावस्या।
  final int tithi;

  /// नक्षत्र (0 = अश्विनी) और उसका चरण (1–4)।
  final int nakshatra;
  final int charan;

  /// योग — 0 = विष्कुम्भ … 26 = वैधृति।
  final int yoga;

  /// करण — [karanaNames] में जगह।
  final int karana;

  /// मास, पक्ष, संवत् — जन्म की तिथि वाले।
  final int masa;
  final bool isAdhikaMasa;
  final int vikramSamvat;
  final int shakaSamvat;

  /// उस हिंदू दिन का सूर्योदय और सूर्यास्त (घड़ी का समय)।
  final DateTime? sunrise;
  final DateTime? sunset;

  const JanmPanchang({
    required this.janmSthaniya,
    required this.hinduDin,
    required this.suryodaySePehle,
    required this.vara,
    required this.tithi,
    required this.nakshatra,
    required this.charan,
    required this.yoga,
    required this.karana,
    required this.masa,
    required this.isAdhikaMasa,
    required this.vikramSamvat,
    required this.shakaSamvat,
    required this.sunrise,
    required this.sunset,
  });

  int get paksha => tithi < 15 ? 0 : 1;
  String get pakshaName => pakshaNames[paksha];
  String get tithiName => tithiNames[tithi];
  String get varaName => varaNames[vara];
  String get nakshatraName => nakshatraNames[nakshatra];
  String get yogaName => yogaNames[yoga];
  String get karanaName => karanaNames[karana];
  String get masaName => masaNames[masa];
  String get masaFullName => isAdhikaMasa ? 'अधिक $masaName' : masaName;
  String get vikramSamvatsara => vikramSamvatsaraOf(vikramSamvat);
}

/// किसी क्षण और जगह का जन्म-पंचांग। [janmUtc] UTC में होना चाहिए।
JanmPanchang janmPanchang(
  DateTime janmUtc,
  Place place, {
  MasaSystem masaSystem = MasaSystem.purnimanta,
}) {
  assert(janmUtc.isUtc, 'जन्म का समय UTC में चाहिए');
  final sthaniya = janmUtc.add(place.timeZoneOffset);
  final jd = julianDayFromUtc(janmUtc);

  // ── हिंदू दिन: सूर्योदय से पहले का जन्म पिछले दिन में गिना जाता है ──
  var din = DateTime.utc(sthaniya.year, sthaniya.month, sthaniya.day);
  var p = computePanchang(din.year, din.month, din.day, place,
      masaSystem: masaSystem);
  final pehle = p.sunrise != null && sthaniya.isBefore(p.sunrise!);
  if (pehle) {
    din = din.subtract(const Duration(days: 1));
    p = computePanchang(din.year, din.month, din.day, place,
        masaSystem: masaSystem);
  }

  // ── जन्म के क्षण के अंग ──────────────────────────────────────────
  final elong = elongationAt(jd);
  final tithi = (elong / 12.0).floor() % 30;
  final chandra = moonSiderealAt(jd);
  const nakAnsh = 360.0 / 27.0;
  final nakshatra = (chandra / nakAnsh).floor() % 27;
  final charan = ((chandra % nakAnsh) / (nakAnsh / 4)).floor() + 1;
  final yoga = (yogaAngleAt(jd) / nakAnsh).floor() % 27;
  final karana = karanaNameIndex((elong / 6.0).floor() % 60);

  // ── मास और संवत्: जन्म की तिथि का पक्ष सूर्योदय वाले से अलग हो, तो बीच में
  // अमावस्या (या पूर्णिमांत में पूर्णिमा) पार हुई है — अगली सुबह का पंचांग
  // उसी मास का है जिसमें जन्म हुआ।
  var masaWala = p;
  if ((tithi < 15 ? 0 : 1) != p.paksha) {
    final agla = din.add(const Duration(days: 1));
    masaWala = computePanchang(agla.year, agla.month, agla.day, place,
        masaSystem: masaSystem);
  }

  return JanmPanchang(
    janmSthaniya: sthaniya,
    hinduDin: din,
    suryodaySePehle: pehle,
    vara: p.vara,
    tithi: tithi,
    nakshatra: nakshatra,
    charan: charan,
    yoga: yoga,
    karana: karana,
    masa: masaWala.masa,
    isAdhikaMasa: masaWala.isAdhikaMasa,
    vikramSamvat: masaWala.vikramSamvat,
    shakaSamvat: masaWala.shakaSamvat,
    sunrise: p.sunrise,
    sunset: p.sunset,
  );
}
