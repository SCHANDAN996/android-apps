import 'julian.dart';
import 'names.dart';
import 'panchang.dart';
import 'place.dart';
import 'sunrise.dart';

/// त्योहार की तारीख़ें — **व्यापिनी नियम** से।
///
/// यह फ़ाइल `panchang.dart` को छूती नहीं, उसके ऊपर बैठती है।
///
/// ## सबसे ज़रूरी बात
///
/// **"सूर्योदय के वक़्त कौन सी तिथि" — यह हर त्योहार का नियम नहीं है।**
/// शास्त्र में हर त्योहार के लिए अलग नियम है कि तिथि *किस काल में* चालू
/// होनी चाहिए। महाशिवरात्रि की पूजा आधी रात को होती है, तो तिथि आधी रात
/// को चाहिए। दीपावली का लक्ष्मी पूजन सूर्यास्त के बाद, तो तिथि प्रदोष में।
///
/// यही वजह है कि पुराना "सूर्योदय वाला" तरीक़ा महाशिवरात्रि और दीपावली
/// दोनों पर एक दिन ग़लत निकल रहा था।
///
/// ## नियम कहाँ से आए
///
/// अंदाज़े से नहीं — Drik से पक्की की हुई तारीख़ों का असली डेटा निकालकर।
/// पूरा ब्यौरा `test/festival_notes.md` और `docs/08_VERIFICATION.md` में।

/// तिथि किस काल में चालू होनी चाहिए।
enum Vyapini {
  /// सूर्योदय पर — ज़्यादातर व्रत, एकादशी, नवरात्रि
  sunrise,

  /// मध्याह्न (दिन का तीसरा पंचमांश) — राम नवमी, गणेश चतुर्थी
  madhyahna,

  /// अपराह्न (दिन का चौथा पंचमांश) — श्राद्ध, रक्षाबंधन
  aparahna,

  /// प्रदोष (सूर्यास्त से 2 घंटे 24 मिनट) — दीपावली, होलिका दहन
  pradosha,

  /// निशीथ (रात का आठवाँ मुहूर्त) — महाशिवरात्रि, जन्माष्टमी
  nishitha,
}

extension VyapiniName on Vyapini {
  String get hindi => switch (this) {
        Vyapini.sunrise => 'सूर्योदय व्यापिनी',
        Vyapini.madhyahna => 'मध्याह्न व्यापिनी',
        Vyapini.aparahna => 'अपराह्न व्यापिनी',
        Vyapini.pradosha => 'प्रदोष व्यापिनी',
        Vyapini.nishitha => 'निशीथ व्यापिनी',
      };

  String get kaalName => switch (this) {
        Vyapini.sunrise => 'सूर्योदय',
        Vyapini.madhyahna => 'मध्याह्न',
        Vyapini.aparahna => 'अपराह्न',
        Vyapini.pradosha => 'प्रदोष',
        Vyapini.nishitha => 'निशीथ',
      };
}

/// एक त्योहार का नियम। **तारीख़ कभी हाथ से मत भरना** — नियम लिखो, तारीख़
/// किसी भी साल के लिए अपने आप निकलेगी, 2050 की भी।
class FestivalRule {
  final String id;
  final String name;

  /// 0 = चैत्र … 11 = फाल्गुन
  final int masa;

  /// 0 = शुक्ल, 1 = कृष्ण
  final int paksha;

  /// पक्ष के भीतर तिथि, 1 से 15 (पूर्णिमा/अमावस्या = 15)
  final int tithi;

  final Vyapini vyapini;

  /// भद्रा (विष्टि करण) में यह काम नहीं होता — होलिका दहन, रक्षाबंधन।
  final bool avoidBhadra;

  /// मास किस पद्धति से गिनना है। उत्तर भारत के त्योहार पूर्णिमांत से।
  final MasaSystem masaSystem;

  const FestivalRule({
    required this.id,
    required this.name,
    required this.masa,
    required this.paksha,
    required this.tithi,
    this.vyapini = Vyapini.sunrise,
    this.avoidBhadra = false,
    this.masaSystem = MasaSystem.purnimanta,
  });

  /// तीस तिथियों वाली गिनती में यह तिथि कहाँ पड़ती है (0 से)।
  int get tithiIndex => paksha == 0 ? tithi - 1 : 14 + tithi;

  String get tithiName => tithiNames[tithiIndex];
  String get masaName => masaNames[masa];
  String get pakshaName => pakshaNames[paksha];
}

/// निकाली हुई तारीख़ — **और वो कैसे निकली।**
///
/// `explanation` इसलिए है कि यूज़र को हिसाब खोलकर दिखाया जा सके। अगर
/// हमारी तारीख़ किसी और कैलेंडर से अलग पड़े, तो वो सोचे "ये क्यों अलग है"
/// — न कि "ऐप ग़लत है"।
class FestivalDate {
  final FestivalRule rule;

  /// स्थानीय तारीख़ (समय बेमानी है, सिर्फ़ दिन देखो)।
  final DateTime date;

  final DateTime tithiStart;
  final DateTime tithiEnd;

  /// जिस खिड़की के आधार पर यह दिन चुना गया।
  final DateTime kaalStart;
  final DateTime kaalEnd;

  /// भद्रा की वजह से अगले दिन खिसकाना पड़ा।
  final bool shiftedForBhadra;

  /// तिथि उस काल को छू ही नहीं पाई (क्षय तिथि जैसी हालत) — तब
  /// "जिस दिन तिथि सबसे ज़्यादा देर रही" वाला नियम लगा।
  final bool missedKaal;

  /// दो दिन दावेदार थे और नियम साफ़ फ़ैसला नहीं कर सका।
  /// ऐसे में ऐप को **दोनों दिन दिखाने चाहिए**, चुपचाप एक मत चुनना।
  final bool ambiguous;
  final DateTime? otherCandidate;

  final String explanation;

  const FestivalDate({
    required this.rule,
    required this.date,
    required this.tithiStart,
    required this.tithiEnd,
    required this.kaalStart,
    required this.kaalEnd,
    required this.shiftedForBhadra,
    required this.missedKaal,
    required this.ambiguous,
    required this.otherCandidate,
    required this.explanation,
  });
}

// ─────────────────────────────────────────────────────────────
// काल की खिड़कियाँ
// ─────────────────────────────────────────────────────────────

/// किसी स्थानीय दिन के पाँचों काल, स्थानीय समय में।
///
/// परिभाषाएँ:
/// - **मध्याह्न** — दिन (सूर्योदय→सूर्यास्त) के पाँच भाग, तीसरा
/// - **अपराह्न** — वही पाँच भाग, चौथा
/// - **प्रदोष** — सूर्यास्त से 2 घंटे 24 मिनट (तीन मुहूर्त)
/// - **निशीथ** — रात (सूर्यास्त→अगला सूर्योदय) के पंद्रह मुहूर्त, आठवाँ
///
/// ⚠️ निशीथ की खिड़की **अगले दिन की सुबह** में पड़ती है — 20 तारीख़ का
/// निशीथ असल में 21 तारीख़ के 00:30 के आसपास होता है।
({DateTime start, DateTime end})? kaalWindow(
  Vyapini vyapini,
  int year,
  int month,
  int day,
  Place place,
) {
  final riseSet = sunriseSunset(year, month, day, place);
  if (riseSet.sunrise == null || riseSet.sunset == null) return null;

  final sunriseLocal = riseSet.sunrise!.add(place.timeZoneOffset);
  final sunsetLocal = riseSet.sunset!.add(place.timeZoneOffset);
  final dayLength = sunsetLocal.difference(sunriseLocal);

  switch (vyapini) {
    case Vyapini.sunrise:
      // सूर्योदय एक क्षण है, खिड़की नहीं — एक मिनट की पतली खिड़की बना दो
      return (
        start: sunriseLocal,
        end: sunriseLocal.add(const Duration(minutes: 1))
      );

    case Vyapini.madhyahna:
      return (
        start: sunriseLocal.add(dayLength * (2 / 5)),
        end: sunriseLocal.add(dayLength * (3 / 5)),
      );

    case Vyapini.aparahna:
      return (
        start: sunriseLocal.add(dayLength * (3 / 5)),
        end: sunriseLocal.add(dayLength * (4 / 5)),
      );

    case Vyapini.pradosha:
      return (
        start: sunsetLocal,
        end: sunsetLocal.add(const Duration(hours: 2, minutes: 24)),
      );

    case Vyapini.nishitha:
      final next = DateTime.utc(year, month, day).add(const Duration(days: 1));
      final nextRise =
          sunriseSunset(next.year, next.month, next.day, place).sunrise;
      if (nextRise == null) return null;

      final night = nextRise.add(place.timeZoneOffset).difference(sunsetLocal);
      return (
        start: sunsetLocal.add(night * (7 / 15)),
        end: sunsetLocal.add(night * (8 / 15)),
      );
  }
}

// ─────────────────────────────────────────────────────────────
// तिथि और भद्रा के अंतराल
// ─────────────────────────────────────────────────────────────

({DateTime start, DateTime end}) _tithiInterval(
    int tithiIndex, double newMoonJd, Place place) {
  DateTime toLocal(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  final startJd =
      findCrossing(elongationAt, tithiIndex * 12.0, newMoonJd - 0.05, 32)!;
  final endJd = findCrossing(
      elongationAt, ((tithiIndex + 1) * 12.0) % 360.0, startJd + 0.01, 3)!;

  return (start: toLocal(startJd), end: toLocal(endJd));
}

/// इस तिथि में भद्रा (विष्टि करण) कब है — हर तिथि दो करण की होती है,
/// जिस आधे में विष्टि पड़े वही भद्रा। न हो तो null।
({DateTime start, DateTime end})? _bhadraInterval(
    int tithiIndex, double newMoonJd, Place place) {
  DateTime toLocal(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  for (final half in [0, 1]) {
    final karanaCount = (tithiIndex * 2 + half) % 60;
    if (karanaNameIndex(karanaCount) != 6) continue; // 6 = विष्टि

    final startJd =
        findCrossing(elongationAt, karanaCount * 6.0, newMoonJd - 0.05, 32)!;
    final endJd = findCrossing(
        elongationAt, ((karanaCount + 1) * 6.0) % 360.0, startJd + 0.01, 2)!;

    return (start: toLocal(startJd), end: toLocal(endJd));
  }
  return null;
}

bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
    aStart.isBefore(bEnd) && bStart.isBefore(aEnd);

/// भद्रा उस काल को **पूरी तरह** ढक रही है?
bool _bhadraBlocks(({DateTime start, DateTime end})? bhadra, DateTime kaalStart,
    DateTime kaalEnd) {
  if (bhadra == null) return false;
  return !bhadra.start.isAfter(kaalStart) && !bhadra.end.isBefore(kaalEnd);
}

// ─────────────────────────────────────────────────────────────
// चांद्र मास ढूँढना
// ─────────────────────────────────────────────────────────────

/// एक चांद्र मास — कब शुरू हुआ, कौन सा है, अधिक तो नहीं।
typedef LunarMonth = ({double newMoonJd, int amantaMasa, bool isAdhika});

/// किसी ग्रेगोरियन साल के आसपास के सारे चांद्र मास।
/// (पिछले साल के दिसम्बर से अगले साल के फ़रवरी तक, ताकि किनारे न छूटें)
List<LunarMonth> lunarMonthsAround(int year, Place place) {
  final months = <LunarMonth>[];
  var jd = previousNewMoon(julianDay(year - 1, 12, 1.0));

  while (jd < julianDay(year + 1, 2, 1.0)) {
    final rashi = (sunSiderealAt(jd) / 30.0).floor() % 12;
    final nextJd = previousNewMoon(jd + 32.0);
    final nextRashi = (sunSiderealAt(nextJd) / 30.0).floor() % 12;

    months.add((
      newMoonJd: jd,
      amantaMasa: (rashi + 1) % 12,
      isAdhika: rashi == nextRashi,
    ));

    jd = nextJd;
  }

  return months;
}

// ─────────────────────────────────────────────────────────────
// मुख्य काम
// ─────────────────────────────────────────────────────────────

/// किसी नियम की उस साल की तारीख़।
///
/// **तरीक़ा:**
/// 1. वो चांद्र मास ढूँढो जिसमें यह त्योहार पड़ता है (अधिक मास छोड़कर —
///    त्योहार अधिक मास में नहीं मनाए जाते)
/// 2. उस मास में तिथि का पूरा अंतराल निकालो
/// 3. जिन दिनों के ज़रूरी काल में वो तिथि चालू हो, वे दावेदार
/// 4. भद्रा और क्षय-तिथि वाले नियम लगाओ
FestivalDate? findFestival(FestivalRule rule, int year, Place place) {
  // पूर्णिमांत में कृष्ण पक्ष का त्योहार पिछले अमांत मास में पड़ता है
  final targetAmanta =
      rule.masaSystem == MasaSystem.purnimanta && rule.paksha == 1
          ? (rule.masa - 1 + 12) % 12
          : rule.masa;

  for (final month in lunarMonthsAround(year, place)) {
    if (month.isAdhika) continue; // त्योहार अधिक मास में नहीं
    if (month.amantaMasa != targetAmanta) continue;

    final tithi = _tithiInterval(rule.tithiIndex, month.newMoonJd, place);
    if (tithi.start.year != year && tithi.end.year != year) continue;

    final bhadra = rule.avoidBhadra
        ? _bhadraInterval(rule.tithiIndex, month.newMoonJd, place)
        : null;

    final result = _pickDay(rule, tithi, bhadra, place);
    if (result != null) return result;
  }

  return null;
}

FestivalDate? _pickDay(
  FestivalRule rule,
  ({DateTime start, DateTime end}) tithi,
  ({DateTime start, DateTime end})? bhadra,
  Place place,
) {
  final firstDay =
      DateTime.utc(tithi.start.year, tithi.start.month, tithi.start.day);

  final candidates = <({
    DateTime day,
    DateTime kaalStart,
    DateTime kaalEnd,
    bool blocked
  })>[];

  // −1 से इसलिए कि निशीथ की खिड़की आधी रात के *बाद* पड़ती है — यानी
  // 20 तारीख़ का निशीथ असल में 21 की सुबह है। सिर्फ़ आगे देखने पर वो छूट
  // जाता, और महाशिवरात्रि जैसे त्योहार कुछ सालों में ग़ायब हो जाते।
  for (var offset = -1; offset <= 2; offset++) {
    final day = firstDay.add(Duration(days: offset));
    final kaal = kaalWindow(rule.vyapini, day.year, day.month, day.day, place);
    if (kaal == null) continue;
    if (!_overlaps(tithi.start, tithi.end, kaal.start, kaal.end)) continue;

    candidates.add((
      day: day,
      kaalStart: kaal.start,
      kaalEnd: kaal.end,
      blocked: _bhadraBlocks(bhadra, kaal.start, kaal.end),
    ));
  }

  // ── तिथि उस काल को छू ही नहीं पाई ──
  //
  // क्षय तिथि में ऐसा होता है। जैसे 2027 की घटस्थापना: प्रतिपदा
  // 30/9 08:06 से 1/10 05:35 तक चली, और दोनों दिन सूर्योदय 06:13 पर था —
  // यानी किसी सूर्योदय को छुआ ही नहीं।
  //
  // ऐसे में **जिस दिन तिथि सबसे ज़्यादा देर रहे**, वही दिन।
  if (candidates.isEmpty) {
    return _prevailingDay(rule, tithi, bhadra, place, firstDay);
  }

  final usable = candidates.where((c) => !c.blocked).toList();

  // ── सब दावेदार भद्रा में डूबे हों ──
  //
  // शास्त्र कहता है भद्रा में यह काम नहीं होता। तो अगले दिन देखो — अगर
  // उस दिन के सूर्योदय पर तिथि अब भी चल रही है और भद्रा बीत चुकी है, तो
  // त्योहार वहाँ खिसक जाता है।
  //
  // यही नियम होलिका दहन 2026 (2 मार्च → 3 मार्च) और रक्षाबंधन 2026
  // (27 अगस्त → 28 अगस्त) दोनों को सही जवाब देता है।
  if (usable.isEmpty) {
    final blocked = candidates.first;
    final nextDay = blocked.day.add(const Duration(days: 1));

    final rise =
        sunriseSunset(nextDay.year, nextDay.month, nextDay.day, place).sunrise;
    if (rise == null) return null;
    final nextSunrise = rise.add(place.timeZoneOffset);

    final tithiStillOn =
        nextSunrise.isAfter(tithi.start) && nextSunrise.isBefore(tithi.end);
    final bhadraOver = bhadra == null || !nextSunrise.isBefore(bhadra.end);

    if (!tithiStillOn || !bhadraOver) {
      return _prevailingDay(rule, tithi, bhadra, place, firstDay);
    }

    return FestivalDate(
      rule: rule,
      date: nextDay,
      tithiStart: tithi.start,
      tithiEnd: tithi.end,
      kaalStart: blocked.kaalStart,
      kaalEnd: blocked.kaalEnd,
      shiftedForBhadra: true,
      missedKaal: false,
      ambiguous: false,
      otherCandidate: null,
      explanation: _explain(rule, tithi, bhadra, shifted: true, missed: false),
    );
  }

  // ── एक ही दावेदार — सीधा फ़ैसला ──
  if (usable.length == 1) {
    final c = usable.first;
    return FestivalDate(
      rule: rule,
      date: c.day,
      tithiStart: tithi.start,
      tithiEnd: tithi.end,
      kaalStart: c.kaalStart,
      kaalEnd: c.kaalEnd,
      shiftedForBhadra: candidates.length > usable.length,
      missedKaal: false,
      ambiguous: false,
      otherCandidate: null,
      explanation: _explain(rule, tithi, bhadra, shifted: false, missed: false),
    );
  }

  // ── दो दावेदार ──
  //
  // ⚠️ यहाँ पूरा शास्त्रीय नियम नहीं लगाया गया। जिस दिन काल में तिथि
  // ज़्यादा देर रही उसे चुनते हैं, और `ambiguous` की झंडी लगा देते हैं।
  // **ऐप को दोनों दिन दिखाने चाहिए** — चुपचाप एक चुनकर यूज़र को धोखे में
  // मत रखना। असली नियम छपे पंचांग से मिलाकर ही डालना।
  usable.sort((a, b) {
    Duration overlapOf(
        ({DateTime day, DateTime kaalStart, DateTime kaalEnd, bool blocked}) c) {
      final start = c.kaalStart.isAfter(tithi.start) ? c.kaalStart : tithi.start;
      final end = c.kaalEnd.isBefore(tithi.end) ? c.kaalEnd : tithi.end;
      return end.difference(start);
    }

    return overlapOf(b).compareTo(overlapOf(a));
  });

  final best = usable.first;
  return FestivalDate(
    rule: rule,
    date: best.day,
    tithiStart: tithi.start,
    tithiEnd: tithi.end,
    kaalStart: best.kaalStart,
    kaalEnd: best.kaalEnd,
    shiftedForBhadra: false,
    missedKaal: false,
    ambiguous: true,
    otherCandidate: usable[1].day,
    explanation: _explain(rule, tithi, bhadra, shifted: false, missed: false),
  );
}

/// जिस हिंदू दिन (सूर्योदय से अगले सूर्योदय तक) में तिथि सबसे ज़्यादा
/// देर रही, वही दिन।
FestivalDate? _prevailingDay(
  FestivalRule rule,
  ({DateTime start, DateTime end}) tithi,
  ({DateTime start, DateTime end})? bhadra,
  Place place,
  DateTime firstDay,
) {
  DateTime? bestDay;
  DateTime? bestStart;
  DateTime? bestEnd;
  var bestOverlap = Duration.zero;

  for (var offset = -1; offset <= 1; offset++) {
    final day = firstDay.add(Duration(days: offset));
    final next = day.add(const Duration(days: 1));

    final rise = sunriseSunset(day.year, day.month, day.day, place).sunrise;
    final nextRise =
        sunriseSunset(next.year, next.month, next.day, place).sunrise;
    if (rise == null || nextRise == null) continue;

    final dayStart = rise.add(place.timeZoneOffset);
    final dayEnd = nextRise.add(place.timeZoneOffset);

    final start = dayStart.isAfter(tithi.start) ? dayStart : tithi.start;
    final end = dayEnd.isBefore(tithi.end) ? dayEnd : tithi.end;
    if (!start.isBefore(end)) continue;

    final overlap = end.difference(start);
    if (overlap > bestOverlap) {
      bestOverlap = overlap;
      bestDay = day;
      bestStart = dayStart;
      bestEnd = dayEnd;
    }
  }

  if (bestDay == null) return null;

  return FestivalDate(
    rule: rule,
    date: bestDay,
    tithiStart: tithi.start,
    tithiEnd: tithi.end,
    kaalStart: bestStart!,
    kaalEnd: bestEnd!,
    shiftedForBhadra: false,
    missedKaal: true,
    ambiguous: false,
    otherCandidate: null,
    explanation: _explain(rule, tithi, bhadra, shifted: false, missed: true),
  );
}

String _explain(
  FestivalRule rule,
  ({DateTime start, DateTime end}) tithi,
  ({DateTime start, DateTime end})? bhadra, {
  required bool shifted,
  required bool missed,
}) {
  String stamp(DateTime d) =>
      '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  final lines = <String>[
    '${rule.masaName} ${rule.pakshaName} ${rule.tithiName}',
    rule.vyapini.hindi,
    '${rule.tithiName} — ${stamp(tithi.start)} से ${stamp(tithi.end)} तक',
  ];

  if (bhadra != null) {
    lines.add('भद्रा — ${stamp(bhadra.start)} से ${stamp(bhadra.end)} तक');
  }
  if (shifted) {
    lines.add('भद्रा में यह काम नहीं होता, इसलिए अगले दिन');
  }
  if (missed) {
    lines.add('तिथि ${rule.vyapini.kaalName} काल को छू नहीं पाई — '
        'इसलिए जिस दिन तिथि सबसे ज़्यादा देर रही, वही दिन');
  }

  lines.add('दृक् गणित · लाहिड़ी अयनांश · '
      '${rule.masaSystem == MasaSystem.purnimanta ? "पूर्णिमांत" : "अमांत"} पद्धति');

  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────
// त्योहारों की सूची
// ─────────────────────────────────────────────────────────────

/// **आठों तारीख़ें drikpanchang.com से पक्की की हुई हैं** (2026, दिल्ली) —
/// हर एक के लिए उस दिन का पन्ना खोलकर देखा गया कि Drik ख़ुद वहाँ उस
/// त्योहार का नाम लिखता है या नहीं। लट्ठा `docs/08_VERIFICATION.md` में।
///
/// नया त्योहार जोड़ो तो **नियम अंदाज़े से मत लिखना** — Drik या छपे पंचांग
/// से मिलाकर, और जाँच `test/festival_test.dart` में डालकर।
const List<FestivalRule> festivalRules = [
  FestivalRule(
    id: 'maha_shivaratri',
    name: 'महाशिवरात्रि',
    masa: 11, // फाल्गुन
    paksha: 1,
    tithi: 14,
    vyapini: Vyapini.nishitha,
  ),
  FestivalRule(
    id: 'holika_dahan',
    name: 'होलिका दहन',
    masa: 11, // फाल्गुन
    paksha: 0,
    tithi: 15, // पूर्णिमा
    vyapini: Vyapini.pradosha,
    avoidBhadra: true,
  ),
  FestivalRule(
    id: 'rama_navami',
    name: 'राम नवमी',
    masa: 0, // चैत्र
    paksha: 0,
    tithi: 9,
    vyapini: Vyapini.madhyahna,
  ),
  FestivalRule(
    id: 'raksha_bandhan',
    name: 'रक्षाबंधन',
    masa: 4, // श्रावण
    paksha: 0,
    tithi: 15, // पूर्णिमा
    vyapini: Vyapini.aparahna,
    avoidBhadra: true,
  ),
  FestivalRule(
    id: 'janmashtami',
    name: 'जन्माष्टमी',
    masa: 5, // भाद्रपद (पूर्णिमांत)
    paksha: 1,
    tithi: 8,
    vyapini: Vyapini.nishitha,
  ),
  FestivalRule(
    id: 'ganesh_chaturthi',
    name: 'गणेश चतुर्थी',
    masa: 5, // भाद्रपद
    paksha: 0,
    tithi: 4,
    vyapini: Vyapini.madhyahna,
  ),
  FestivalRule(
    id: 'navratri_ghatasthapana',
    name: 'शारदीय नवरात्रि — घटस्थापना',
    masa: 6, // आश्विन
    paksha: 0,
    tithi: 1,
    vyapini: Vyapini.sunrise,
  ),
  FestivalRule(
    id: 'diwali',
    name: 'दीपावली',
    masa: 7, // कार्तिक
    paksha: 1,
    tithi: 15, // अमावस्या
    vyapini: Vyapini.pradosha,
  ),
];

/// पूरे साल के त्योहार, तारीख़ के हिसाब से।
List<FestivalDate> festivalsInYear(int year, Place place) {
  final found = <FestivalDate>[];
  for (final rule in festivalRules) {
    final date = findFestival(rule, year, place);
    if (date != null) found.add(date);
  }
  found.sort((a, b) => a.date.compareTo(b.date));
  return found;
}
