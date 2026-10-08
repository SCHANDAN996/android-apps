import 'julian.dart';
import 'moonrise.dart';
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
///
/// पाँच त्योहारों (होलिका दहन, रक्षाबंधन, राम नवमी, जन्माष्टमी, दीपावली) के
/// लिए सीधी व्यापिनी काफ़ी नहीं निकली — 2024–2030 की जाँच में उनकी 35 में से
/// 10 तारीख़ें एक दिन इधर-उधर थीं। उनका नियम अब **धर्मसिंधु** के छपे पन्ने से
/// है ([Nirnaya], → D-117), और सातों साल संदर्भ-पंचांग से मिलता है।

/// तिथि किस काल में चालू होनी चाहिए।
enum Vyapini {
  /// सूर्योदय पर — ज़्यादातर व्रत, एकादशी, नवरात्रि; रक्षाबंधन भी
  /// (तीन मुहूर्त की शर्त के साथ, [Nirnaya.raksha])
  sunrise,

  /// मध्याह्न (दिन का तीसरा पंचमांश) — राम नवमी, गणेश चतुर्थी
  madhyahna,

  /// अपराह्न (दिन का चौथा पंचमांश) — श्राद्ध, दशहरा, भाई दूज
  aparahna,

  /// प्रदोष (सूर्यास्त से 2 घंटे 24 मिनट) — दीपावली, होलिका दहन
  pradosha,

  /// निशीथ (रात का आठवाँ मुहूर्त) — महाशिवरात्रि, जन्माष्टमी
  nishitha,

  /// चंद्रोदय पर — करवा चौथ (व्रत चाँद देखकर खुलता है)
  chandrodaya,
}

extension VyapiniName on Vyapini {
  String get hindi => switch (this) {
        Vyapini.sunrise => 'सूर्योदय व्यापिनी',
        Vyapini.madhyahna => 'मध्याह्न व्यापिनी',
        Vyapini.aparahna => 'अपराह्न व्यापिनी',
        Vyapini.pradosha => 'प्रदोष व्यापिनी',
        Vyapini.nishitha => 'निशीथ व्यापिनी',
        Vyapini.chandrodaya => 'चंद्रोदय व्यापिनी',
      };

  String get kaalName => switch (this) {
        Vyapini.sunrise => 'सूर्योदय',
        Vyapini.madhyahna => 'मध्याह्न',
        Vyapini.aparahna => 'अपराह्न',
        Vyapini.pradosha => 'प्रदोष',
        Vyapini.nishitha => 'निशीथ',
        Vyapini.chandrodaya => 'चंद्रोदय',
      };
}

/// दिन किस तरह चुना जाए। ज़्यादातर त्योहारों के लिए सीधी व्यापिनी काफ़ी है;
/// पाँच के लिए छपे निर्णय-ग्रंथ का अपना, लंबा नियम है (→ D-117)।
enum Nirnaya {
  /// जिस दिन के काल में तिथि हो — सीधे [Vyapini] से
  vyapini,

  /// होलिका दहन — प्रदोष, भद्रा कब छूटती है, और साढ़े तीन प्रहर
  holika,

  /// रक्षाबंधन — सूर्योदय के बाद तीन मुहूर्त से ज़्यादा पूर्णिमा
  raksha,

  /// राम नवमी — दोनों दिन मध्याह्न हो तो दूसरा दिन
  ramNavami,

  /// जन्माष्टमी — आधी रात की अष्टमी, और रोहिणी का योग
  janmashtami,

  /// दीपावली का लक्ष्मी पूजन — दोनों दिन प्रदोष हो तो दूसरा दिन
  lakshmiPujan,
}

extension NirnayaName on Nirnaya {
  /// व्यापिनी के साथ जुड़ने वाली शर्त — हिसाब में दिखाने के लिए।
  String? get visheshan => switch (this) {
        Nirnaya.holika => 'भद्रा रहित',
        Nirnaya.raksha => 'उदय के बाद तीन मुहूर्त से अधिक, भद्रा रहित',
        Nirnaya.janmashtami => 'रोहिणी का योग देखकर',
        Nirnaya.vyapini || Nirnaya.ramNavami || Nirnaya.lakshmiPujan => null,
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

  /// तिथि से नहीं, **उस तिथि से पहले पड़ने वाले इस वार** से तय होने वाला
  /// त्योहार (`DateTime.friday` जैसा)। तिथि वाला दिन ख़ुद उसी वार का हो
  /// तो वही दिन। वरलक्ष्मी व्रत = श्रावण पूर्णिमा से पहले का शुक्रवार।
  final int? vaarPehle;

  /// दिन चुनने का तरीक़ा — पाँच त्योहारों का अपना, बाक़ी सबका [Nirnaya.vyapini]।
  final Nirnaya nirnaya;

  const FestivalRule({
    required this.id,
    required this.name,
    required this.masa,
    required this.paksha,
    required this.tithi,
    this.vyapini = Vyapini.sunrise,
    this.avoidBhadra = false,
    this.masaSystem = MasaSystem.purnimanta,
    this.vaarPehle,
    this.nirnaya = Nirnaya.vyapini,
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

  /// दो दिन दावेदार थे। [date] वह है जो नियम चुनता है; [otherCandidate]
  /// वह दूसरा दिन, जिसे दूसरी परंपरा या दूसरा पंचांग मानता है (जैसे
  /// जन्माष्टमी में स्मार्त-वैष्णव, दीपावली 2024)।
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

    case Vyapini.chandrodaya:
      // चंद्रोदय भी एक क्षण है — सूर्योदय की तरह एक मिनट की खिड़की।
      // किसी दिन चाँद उगे ही नहीं (महीने में एक बार) तो वह दिन दावेदार नहीं।
      final rise = moonriseMoonset(year, month, day, place).moonrise;
      if (rise == null) return null;
      return (start: rise, end: rise.add(const Duration(minutes: 1)));

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

bool _overlaps(
        DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) =>
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

final Map<int, List<LunarMonth>> _lunarMonthsCache = {};

/// किसी ग्रेगोरियन साल के आसपास के सारे चांद्र मास।
/// (पिछले साल के दिसम्बर से अगले साल के फ़रवरी तक, ताकि किनारे न छूटें)
List<LunarMonth> lunarMonthsAround(int year, Place place) {
  final cached = _lunarMonthsCache[year];
  if (cached != null) return cached;

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

  if (_lunarMonthsCache.length >= 10) {
    _lunarMonthsCache.remove(_lunarMonthsCache.keys.first);
  }
  return _lunarMonthsCache[year] = List.unmodifiable(months);
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
FestivalDate? findFestival(
  FestivalRule rule,
  int year,
  Place place, [
  List<LunarMonth>? precomputedMonths,
]) {
  // पूर्णिमांत में कृष्ण पक्ष का त्योहार पिछले अमांत मास में पड़ता है
  final targetAmanta =
      rule.masaSystem == MasaSystem.purnimanta && rule.paksha == 1
          ? (rule.masa - 1 + 12) % 12
          : rule.masa;

  final months = precomputedMonths ?? lunarMonthsAround(year, place);
  for (final month in months) {
    if (month.isAdhika) continue; // त्योहार अधिक मास में नहीं
    if (month.amantaMasa != targetAmanta) continue;

    final tithi = _tithiInterval(rule.tithiIndex, month.newMoonJd, place);
    if (tithi.start.year != year && tithi.end.year != year) continue;

    final bhadra = rule.avoidBhadra
        ? _bhadraInterval(rule.tithiIndex, month.newMoonJd, place)
        : null;

    final result = switch (rule.nirnaya) {
      Nirnaya.vyapini => _pickDay(rule, tithi, bhadra, place),
      Nirnaya.holika => _holika(rule, tithi, bhadra, place),
      Nirnaya.raksha => _raksha(rule, tithi, bhadra, place),
      Nirnaya.ramNavami => _ramNavami(rule, tithi, place),
      Nirnaya.janmashtami => _janmashtami(rule, tithi, place),
      Nirnaya.lakshmiPujan => _lakshmiPujan(rule, tithi, place),
    };
    if (result != null) return _vaarPehle(rule, result);
  }

  return null;
}

/// [FestivalRule.vaarPehle] वाले त्योहार — तिथि वाले दिन से पीछे जाकर
/// पहला वही वार। बाक़ी सब नियम ज्यों के त्यों।
FestivalDate _vaarPehle(FestivalRule rule, FestivalDate tithiKaDin) {
  final vaar = rule.vaarPehle;
  if (vaar == null) return tithiKaDin;

  final peeche = (tithiKaDin.date.weekday - vaar + 7) % 7;
  final din = tithiKaDin.date.subtract(Duration(days: peeche));
  return FestivalDate(
    rule: rule,
    date: din,
    tithiStart: tithiKaDin.tithiStart,
    tithiEnd: tithiKaDin.tithiEnd,
    kaalStart: tithiKaDin.kaalStart,
    kaalEnd: tithiKaDin.kaalEnd,
    shiftedForBhadra: false,
    missedKaal: false,
    ambiguous: false,
    otherCandidate: null,
    explanation: '${tithiKaDin.explanation}\n'
        '${rule.masaName} ${rule.tithiName} से पहले का '
        '${varaNames[vaar % 7]} (उसी दिन हो तो वही)',
  );
}

FestivalDate? _pickDay(
  FestivalRule rule,
  ({DateTime start, DateTime end}) tithi,
  ({DateTime start, DateTime end})? bhadra,
  Place place,
) {
  final firstDay =
      DateTime.utc(tithi.start.year, tithi.start.month, tithi.start.day);

  final candidates =
      <({DateTime day, DateTime kaalStart, DateTime kaalEnd, bool blocked})>[];

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
        ({
          DateTime day,
          DateTime kaalStart,
          DateTime kaalEnd,
          bool blocked
        }) c) {
      final start =
          c.kaalStart.isAfter(tithi.start) ? c.kaalStart : tithi.start;
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

// ─────────────────────────────────────────────────────────────
// पाँच त्योहार, जिनका दिन सीधी व्यापिनी से तय नहीं होता (→ D-117)
// ─────────────────────────────────────────────────────────────
//
// नीचे के पाँचों नियम **धर्मसिंधु** (काशीनाथ उपाध्याय) की छपी प्रति के पन्ने
// आँख से पढ़कर लिखे गए हैं — हर फलन के ऊपर उसका मूल वाक्य और पृष्ठ है — और
// हर एक 2024–2030 के सातों साल (दिल्ली) संदर्भ-पंचांग से मिलाया गया है।
// इनसे पहले ये पाँचों `_pickDay` से चलते थे और उन 35 तारीख़ों में से 10
// ग़लत थीं; लट्ठा `docs/08_VERIFICATION.md` §14 में।
//
// ⚠️ यहाँ कोई संख्या अंदाज़े से मत बदलना। "तीन मुहूर्त", "साढ़े तीन प्रहर",
// "एक घड़ी", "आधी रात" — चारों छपे वाक्य के शब्द हैं।

typedef _Antaral = ({DateTime start, DateTime end});

/// एक हिंदू दिन — सूर्योदय से अगले सूर्योदय तक (सब स्थानीय समय)।
typedef _Din = ({DateTime din, DateTime uday, DateTime ast, DateTime aglaUday});

/// एक दावेदार दिन, और उसके काल में तिथि कितनी देर रही।
typedef _Dawedar = ({
  _Din din,
  DateTime kaalStart,
  DateTime kaalEnd,
  Duration chhua
});

/// एक घड़ी (घटिका) = 24 मिनट; एक मुहूर्त = दो घड़ी।
const _ekGhati = Duration(minutes: 24);
const _ekMuhurt = Duration(minutes: 48);

_Din? _dinKaByora(DateTime tarikh, Place place) {
  final agla = tarikh.add(const Duration(days: 1));
  final aaj = sunriseSunset(tarikh.year, tarikh.month, tarikh.day, place);
  final kal = sunriseSunset(agla.year, agla.month, agla.day, place).sunrise;
  if (aaj.sunrise == null || aaj.sunset == null || kal == null) return null;
  return (
    din: tarikh,
    uday: aaj.sunrise!.add(place.timeZoneOffset),
    ast: aaj.sunset!.add(place.timeZoneOffset),
    aglaUday: kal.add(place.timeZoneOffset),
  );
}

/// वह हिंदू दिन जिसमें [pal] पड़ता है — सूर्योदय से पहले का पल पिछले दिन का।
_Din? _hinduDin(DateTime pal, Place place) {
  final tarikh = DateTime.utc(pal.year, pal.month, pal.day);
  final d = _dinKaByora(tarikh, place);
  if (d == null) return null;
  if (!pal.isBefore(d.uday)) return d;
  return _dinKaByora(tarikh.subtract(const Duration(days: 1)), place);
}

_Din? _aglaDin(_Din d, Place place) =>
    _dinKaByora(d.din.add(const Duration(days: 1)), place);

/// रात का ठीक बीच। धर्मसिंधु (पृ. 57): «रात्र्यर्धं निशीथपदार्थः»।
DateTime _aadhiRaat(_Din d) => d.ast.add(d.aglaUday.difference(d.ast) * 0.5);

Duration _chhua(
    DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
  final s = aStart.isAfter(bStart) ? aStart : bStart;
  final e = aEnd.isBefore(bEnd) ? aEnd : bEnd;
  return e.isAfter(s) ? e.difference(s) : Duration.zero;
}

/// जिन दिनों की [vyapini] वाली खिड़की को तिथि छूती है — थोड़ा-सा भी।
List<_Dawedar> _dawedar(Vyapini vyapini, _Antaral tithi, Place place) {
  final pehla =
      DateTime.utc(tithi.start.year, tithi.start.month, tithi.start.day);
  final mile = <_Dawedar>[];
  for (var k = -1; k <= 2; k++) {
    final tarikh = pehla.add(Duration(days: k));
    final d = _dinKaByora(tarikh, place);
    final kaal =
        kaalWindow(vyapini, tarikh.year, tarikh.month, tarikh.day, place);
    if (d == null || kaal == null) continue;
    final c = _chhua(tithi.start, tithi.end, kaal.start, kaal.end);
    if (c == Duration.zero) continue;
    mile.add((din: d, kaalStart: kaal.start, kaalEnd: kaal.end, chhua: c));
  }
  return mile;
}

/// इस तिथि के बाद वाली तिथि कब ख़त्म होती है — "प्रतिपदा बढ़ती हुई है या
/// घटती हुई" देखने के लिए।
DateTime _agliTithiKaAnt(FestivalRule rule, _Antaral tithi, Place place) {
  final endJd = julianDayFromUtc(tithi.end.subtract(place.timeZoneOffset));
  final jd = findCrossing(
      elongationAt, ((rule.tithiIndex + 2) * 12.0) % 360.0, endJd + 0.01, 3)!;
  return utcFromJulianDay(jd).add(place.timeZoneOffset);
}

/// इस तिथि के साथ पड़ने वाला रोहिणी नक्षत्र (40° से 53°20′) — न पड़े तो null।
///
/// खोज तिथि लगने से डेढ़ दिन पहले से: रोहिणी सवा दिन से लंबी नहीं होती,
/// इसलिए जो उससे पहले लगी वह तिथि तक पहुँच ही नहीं सकती।
_Antaral? _rohini(_Antaral tithi, Place place) {
  DateTime local(double jd) => utcFromJulianDay(jd).add(place.timeZoneOffset);

  final startJd = julianDayFromUtc(tithi.start.subtract(place.timeZoneOffset));
  final r0 = findCrossing(moonSiderealAt, 40.0, startJd - 1.5, 4);
  if (r0 == null) return null;
  final r1 = findCrossing(moonSiderealAt, 40.0 + 360.0 / 27.0, r0 + 0.01, 3);
  if (r1 == null) return null;

  final rohini = (start: local(r0), end: local(r1));
  if (_chhua(rohini.start, rohini.end, tithi.start, tithi.end) ==
      Duration.zero) {
    return null;
  }
  return rohini;
}

String _stamp(DateTime d) =>
    '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

String _avadhi(Duration d) {
  final ghante = d.inHours;
  final minute = d.inMinutes % 60;
  if (ghante == 0) return '$minute मिनट';
  return '$ghante ${ghante == 1 ? 'घंटा' : 'घंटे'} $minute मिनट';
}

FestivalDate _nirnit(
  FestivalRule rule,
  _Antaral tithi,
  _Antaral? bhadra,
  Place place, {
  required DateTime din,
  required List<String> kyon,
  bool khiska = false,
  bool kaalChhuta = false,
  DateTime? doosra,
}) {
  final kaal = kaalWindow(rule.vyapini, din.year, din.month, din.day, place);
  return FestivalDate(
    rule: rule,
    date: din,
    tithiStart: tithi.start,
    tithiEnd: tithi.end,
    kaalStart: kaal?.start ?? tithi.start,
    kaalEnd: kaal?.end ?? tithi.end,
    shiftedForBhadra: khiska,
    missedKaal: kaalChhuta,
    ambiguous: doosra != null,
    otherCandidate: doosra,
    explanation: _explain(rule, tithi, bhadra,
        shifted: false, missed: false, vishesh: kyon),
  );
}

/// **होलिका दहन** — धर्मसिंधु, फाल्गुन मास, होलिकानिर्णय (पृ. 113–114):
///
/// «सा प्रदोषव्यापिनी भद्रारहिता ग्राह्या। दिनद्वये प्रदोषव्याप्तौ परदिने
/// प्रदोषैकदेशव्याप्तौ वा परैव। पूर्वदिने भद्रादोषात्। परदिने प्रदोषस्पर्शाभावे
/// पूर्वदिने प्रदोषे भद्रासत्त्वे यदि पूर्णिमा परदिने सार्धत्रियामा ततोऽधिका वा,
/// तत्परदिने च प्रतिपद् वृद्धिगामिनी, तदा परदिने प्रतिपदि प्रदोषव्यापिन्यां
/// होलिका। उक्तविषये यदि प्रतिपदो ह्रासस्तदा पूर्वदिने … भद्रामुखमात्रं त्यक्त्वा
/// भद्रायामेव वा। परदिने प्रदोषस्पर्शाभावे पूर्वदिने यदि निशीथात्प्राक्
/// भद्रासमाप्तिस्तदा भद्रावसानोत्तरमेव होलिकादीपनम्। निशीथोत्तरं भद्रासमाप्तौ
/// भद्रामुखं त्यक्त्वा भद्रायामेव। … दिनद्वयेऽपि पूर्णिमायाः प्रदोषस्पर्शाभावे
/// पूर्वदिन एव»
///
/// "प्रतिपदा बढ़ती हुई" = प्रतिपदा पूर्णिमा से लंबी (वही ग्रंथ, पृ. 93:
/// «दर्शापेक्षया प्रतिपद्वृद्धिसत्त्वे»)।
///
/// सात साल: 2024 और 2025 में भद्रा आधी रात से पहले छूटी → उसी रात; 2026 में
/// आधी रात के बाद तक, और अगले दिन साढ़े तीन प्रहर से लगभग 13 मिनट ज़्यादा →
/// अगले दिन; 2027 में लगभग 48 मिनट कम → उसी रात। पुराना नियम ("भद्रा हो तो अगले दिन")
/// 2024, 2025 और 2027 तीनों में एक दिन आगे था।
///
/// ⚠️ उसी पन्ने का ग्रहण वाला वाक्य («ग्रस्तोदये परदिने प्रदोषे पूर्णिमासत्त्वे
/// ग्रहणमध्य एव कार्यम्। अन्यथा पूर्वदिने») यहाँ **नहीं** लगाया गया: 2026 में
/// वह 2 मार्च कहता, संदर्भ-पंचांग 3 मार्च लिखता है। 2027–2030 में फाल्गुन
/// पूर्णिमा पर भारत में दिखने वाला कोई ग्रहण नहीं है।
FestivalDate? _holika(
  FestivalRule rule,
  _Antaral tithi,
  _Antaral? bhadra,
  Place place,
) {
  final d = _dawedar(Vyapini.pradosha, tithi, place);

  if (d.length >= 2) {
    return _nirnit(rule, tithi, bhadra, place, din: d.last.din.din, kyon: [
      'पूर्णिमा दोनों दिन प्रदोष को छूती है — दूसरा दिन, क्योंकि पहले दिन भद्रा है',
    ]);
  }

  if (d.isEmpty) {
    final pehla = _hinduDin(tithi.start, place);
    if (pehla == null) return _pickDay(rule, tithi, bhadra, place);
    return _nirnit(rule, tithi, bhadra, place,
        din: pehla.din,
        kaalChhuta: true,
        kyon: [
          'पूर्णिमा किसी दिन प्रदोष को नहीं छूती — दहन उसी रात, जिस रात पूर्णिमा लगी',
        ]);
  }

  final c = d.single;
  if (bhadra == null ||
      _chhua(bhadra.start, bhadra.end, c.kaalStart, c.kaalEnd) ==
          Duration.zero) {
    return _nirnit(rule, tithi, bhadra, place, din: c.din.din, kyon: const []);
  }

  if (bhadra.end.isBefore(_aadhiRaat(c.din))) {
    return _nirnit(rule, tithi, bhadra, place, din: c.din.din, kyon: [
      'भद्रा आधी रात से पहले छूट जाती है — दहन उसी रात, भद्रा के बाद',
    ]);
  }

  var kami = 'अगले दिन पूर्णिमा साढ़े तीन प्रहर नहीं रहती';
  final agla = _aglaDin(c.din, place);
  if (agla != null) {
    final udayKeBaad = tithi.end.difference(agla.uday);
    final saadheTeenPrahar = agla.ast.difference(agla.uday) * (3.5 / 4);
    final purnima = tithi.end.difference(tithi.start);
    final pratipada = _agliTithiKaAnt(rule, tithi, place).difference(tithi.end);

    if (udayKeBaad >= saadheTeenPrahar && pratipada > purnima) {
      return _nirnit(rule, tithi, bhadra, place,
          din: agla.din,
          khiska: true,
          kyon: [
            'भद्रा आधी रात के बाद तक है, और अगले दिन पूर्णिमा साढ़े तीन प्रहर '
                'से ज़्यादा रहती है — इसलिए दहन अगले दिन प्रदोष में',
          ]);
    }
    if (udayKeBaad >= saadheTeenPrahar) {
      kami = 'उसके बाद की प्रतिपदा घटती हुई है';
    }
  }

  return _nirnit(rule, tithi, bhadra, place, din: c.din.din, kyon: [
    'भद्रा आधी रात के बाद तक है, पर $kami — दहन उसी रात, भद्रा का मुख छोड़कर',
  ]);
}

/// **रक्षाबंधन** — धर्मसिंधु, श्रावण पूर्णिमा (पृ. 56):
///
/// «रक्षाबन्धनमस्यामेव पूर्णिमायां भद्रारहितायां त्रिमुहूर्ताधिकोदयव्यापिन्यामपराह्णे
/// प्रदोषे वा कार्यम्। उदये त्रिमुहूर्तन्यूनत्वे पूर्वेद्युर्भद्रारहिते प्रदोषादिकाले
/// कार्यम्»
///
/// यानी दिन **सूर्योदय** से तय होता है, अपराह्न से नहीं: जिस सूर्योदय के बाद
/// पूर्णिमा तीन मुहूर्त (दिनमान का पंचमांश) से ज़्यादा बचे, वही दिन। कम बचे
/// तो पिछला दिन, भद्रा के बाद।
///
/// पुराना नियम (अपराह्न + भद्रा) सात में से दो साल ग़लत था: 2025 में 8 अगस्त
/// देता था (अपराह्न में पूर्णिमा लगते ही भद्रा, फिर भी "रोका नहीं" माना) —
/// असल 9; 2029 में 24 अगस्त (सूर्योदय के बाद सिर्फ़ 1 घंटा 25 मिनट) — असल 23।
FestivalDate? _raksha(
  FestivalRule rule,
  _Antaral tithi,
  _Antaral? bhadra,
  Place place,
) {
  final pehla = _hinduDin(tithi.start, place);
  final agla = pehla == null ? null : _aglaDin(pehla, place);
  if (pehla == null || agla == null) {
    return _pickDay(rule, tithi, bhadra, place);
  }

  // पूर्णिमा अगले सूर्योदय तक पहुँची ही नहीं — एक ही दिन है
  if (!agla.uday.isBefore(tithi.end)) {
    return _nirnit(rule, tithi, bhadra, place,
        din: pehla.din,
        kaalChhuta: true,
        kyon: [
          'पूर्णिमा किसी सूर्योदय पर नहीं है — जिस दिन लगी उसी दिन, भद्रा के बाद',
        ]);
  }

  final udayKeBaad = tithi.end.difference(agla.uday);
  final teenMuhurt = agla.ast.difference(agla.uday) * (3 / 15);

  if (udayKeBaad > teenMuhurt) {
    // पहले दिन के अपराह्न या प्रदोष में भी पूर्णिमा थी — पर भद्रा के साथ
    final pehleDinBhi = tithi.start
        .isBefore(pehla.ast.add(const Duration(hours: 2, minutes: 24)));
    return _nirnit(rule, tithi, bhadra, place,
        din: agla.din,
        khiska: pehleDinBhi,
        kyon: [
          if (pehleDinBhi)
            'पहले दिन पूर्णिमा के साथ भद्रा है — रक्षाबंधन अगले दिन, जब '
                'सूर्योदय के बाद पूर्णिमा तीन मुहूर्त से ज़्यादा है '
                '(${_avadhi(udayKeBaad)})'
          else
            'सूर्योदय के बाद पूर्णिमा तीन मुहूर्त से ज़्यादा है '
                '(${_avadhi(udayKeBaad)})',
        ]);
  }

  return _nirnit(rule, tithi, bhadra, place, din: pehla.din, kyon: [
    'अगले दिन सूर्योदय के बाद पूर्णिमा तीन मुहूर्त से कम रहती है '
        '(${_avadhi(udayKeBaad)}) — इसलिए पहले दिन, भद्रा के बाद',
  ]);
}

/// **राम नवमी** — धर्मसिंधु, चैत्र मास, रामनवमीनिर्णय (पृ. 34):
///
/// «अस्यां मध्याह्नव्यापिन्यामुपोषणं कार्यम्। पूर्वेद्युरेव मध्याह्ने सत्त्वे सैव
/// ग्राह्या। दिनद्वये मध्याह्नव्याप्तावव्याप्तौ वा परा। अष्टमीविद्धाया निषेधात्।
/// अतः पूर्वेद्युः सकलमध्याह्नव्यापिनीमपि त्यक्त्वा मध्याह्नैकदेशव्यापिन्यपि परैव
/// ग्राह्या»
///
/// पुराना नियम दो दावेदारों में "जिस दिन मध्याह्न में ज़्यादा देर" चुनता था —
/// 2029 में 22 अप्रैल (43 मिनट बनाम 29 मिनट); असल 23।
FestivalDate? _ramNavami(FestivalRule rule, _Antaral tithi, Place place) {
  final d = _dawedar(Vyapini.madhyahna, tithi, place);

  if (d.length == 1) {
    return _nirnit(rule, tithi, null, place,
        din: d.single.din.din, kyon: const []);
  }

  if (d.length >= 2) {
    return _nirnit(rule, tithi, null, place, din: d.last.din.din, kyon: [
      'नवमी दोनों दिन मध्याह्न को छूती है — दूसरा दिन (अष्टमी से जुड़ी नवमी नहीं ली जाती)',
    ]);
  }

  // किसी दिन मध्याह्न नहीं — तब भी दूसरा दिन, यानी जिसके सूर्योदय पर नवमी है
  final para = _hinduDin(tithi.end.subtract(const Duration(seconds: 1)), place);
  if (para == null) return _pickDay(rule, tithi, null, place);
  return _nirnit(rule, tithi, null, place,
      din: para.din,
      kaalChhuta: true,
      kyon: [
        'नवमी किसी दिन मध्याह्न को नहीं छूती — दूसरा दिन, जिसके सूर्योदय पर नवमी है',
      ]);
}

/// **दीपावली (लक्ष्मी पूजन)** — धर्मसिंधु, आश्विन अमावास्या (पृ. 93):
///
/// «अथाश्विनामावास्यायां प्रातरभ्यंगः प्रदोषे दीपदानलक्ष्मीपूजनादि विहितम्। तत्र
/// सूर्योदयं व्याप्यास्तोत्तरं घटिकाधिकरात्रिव्यापिनि दर्शे सति न संदेहः। …
/// परदिने एव दिनद्वयेऽपि वा प्रदोषव्याप्तौ परा। पूर्वत्रैव प्रदोषव्याप्तौ
/// लक्ष्मीपूजनादौ पूर्वा। … एवमुभयत्र प्रदोषव्याप्त्यभावेऽपि»
///
/// "प्रदोष में है" तभी गिना, जब अमावस्या सूर्यास्त के बाद **एक घड़ी से
/// ज़्यादा** रहे («घटिकाधिक»)। यही दोनों बँटे हुए साल अलग करता है: 2024 में
/// दूसरे दिन 41 मिनट → 1 नवम्बर; 2025 में दूसरे दिन 9 मिनट → 20 अक्टूबर।
/// पुराना नियम ("जिस दिन ज़्यादा देर") 2024 में 31 अक्टूबर देता था।
///
/// ⚠️ उसी पन्ने पर पुरुषार्थचिंतामणि का दूसरा मत भी लिखा है (दूसरे दिन
/// अमावस्या तीन प्रहर से ज़्यादा और प्रतिपदा बढ़ती हुई हो तो दूसरा ही दिन) —
/// वह 2025 में 21 अक्टूबर कहता; संदर्भ-पंचांग 20 लिखता है। इसलिए दोनों दिन
/// दावेदार हों तो दूसरा दिन भी `otherCandidate` में जाता है।
FestivalDate? _lakshmiPujan(FestivalRule rule, _Antaral tithi, Place place) {
  final d = _dawedar(Vyapini.pradosha, tithi, place);
  final pakke = d.where((c) => c.chhua > _ekGhati).toList();

  if (pakke.isEmpty) {
    final pehla = _hinduDin(tithi.start, place);
    if (pehla == null) return _pickDay(rule, tithi, null, place);
    return _nirnit(rule, tithi, null, place,
        din: pehla.din,
        kaalChhuta: true,
        kyon: [
          'अमावस्या किसी दिन प्रदोष में एक घड़ी से ज़्यादा नहीं रहती — '
              'लक्ष्मी पूजन पहली रात',
        ]);
  }

  final chuna = pakke.last;
  if (d.length < 2) {
    return _nirnit(rule, tithi, null, place,
        din: chuna.din.din, kyon: const []);
  }

  final doosra = d.firstWhere((c) => c.din.din != chuna.din.din);
  final baadWala = chuna.din.din.isAfter(doosra.din.din);
  // दूसरा चुना हो और पहले दिन अमावस्या प्रदोष के आख़िरी मिनटों में ही लगी हो,
  // तो पहला दिन दावेदार नहीं
  if (baadWala && doosra.chhua <= _ekGhati) {
    return _nirnit(rule, tithi, null, place,
        din: chuna.din.din, kyon: const []);
  }
  return _nirnit(rule, tithi, null, place,
      din: chuna.din.din,
      doosra: doosra.din.din,
      kyon: [
        if (baadWala) ...[
          'अमावस्या दोनों दिन प्रदोष में है (दूसरे दिन सूर्यास्त के बाद '
              '${_avadhi(chuna.chhua)} — एक घड़ी से ज़्यादा) — इसलिए दूसरा दिन',
          'पहला दिन भी दिखाया है — उस दिन भी प्रदोष में अमावस्या है',
        ] else ...[
          'दूसरे दिन अमावस्या सूर्यास्त के बाद सिर्फ़ ${_avadhi(doosra.chhua)} '
              'रहती है — एक घड़ी से कम, इसलिए पहला दिन',
          'दूसरा दिन भी दिखाया है — उस दिन सूर्योदय पर अमावस्या है',
        ],
      ]);
}

/// **जन्माष्टमी** — धर्मसिंधु, जन्माष्टमीव्रत (पृ. 56–59)। आठ-दस पक्षों के बाद
/// ग्रंथ का अपना निचोड़ (पृ. 58, «संक्षेपेण निर्णयसंग्रहः»):
///
/// «शुद्धसमायां शुद्धन्यूनायां वा विद्धसमायां विद्धन्यूनायां वा केवलाष्टम्यां
/// संदेह एव नास्ति। शुद्धाधिकापि केवलाष्टमी पूर्वैव। विद्धाधिका तु पूर्वदिन एव
/// निशीथव्याप्तौ पूर्वा। दिनद्वये निशीथव्याप्तावव्याप्तौ वा परैव। अथ रोहिणीयोगे
/// … शुद्धाधिकायां पूर्वदिने दिनद्वयेऽपि वा रोहिणीयोगे पूर्वैव। शुद्धाधिकायामुत्तरदिन
/// एव रोहिणीयोगे मुहूर्तमात्रा परैव। विद्धाधिकायां पूर्वदिन एव निशीथात्पूर्वं
/// निशीथे वा रोहिणीयोगे पूर्वा। दिनद्वयेऽपि परत्रैव वा, निशीथे वा निशीथं विहाय,
/// रोहिणीयोगे परैव»
///
/// और उसी जगह तीन बातें, जिनके बिना ऊपर का वाक्य ग़लत पढ़ा जाएगा:
/// - निशीथ = रात का ठीक बीच: «रात्र्यर्धं निशीथपदार्थः»। पहले (सप्तमी वाले)
///   दिन अष्टमी आधी रात तक लग चुकी हो, दूसरे दिन आधी रात के बाद तक चले —
///   तभी "निशीथव्यापिनी" («सप्तमीयुक्तायां रात्रिपूर्वार्धावसाने कलयाप्यष्टम्याः
///   सत्त्वे एव निशीथव्यापित्वम्»)। रोहिणी के योग पर भी यही («एवं
///   वक्ष्यमाणरोहिणीयुक्तभेदेष्वपि ज्ञेयम्»)।
/// - आधी रात पर अष्टमी-रोहिणी का योग सबसे भारी: सिर्फ़ पहले दिन हो तो पहला
///   दिन, चाहे दूसरे दिन दिन में रोहिणी बची हो (पृ. 57, पहला पक्ष)।
/// - पहले दिन आधी रात के **बाद** लगी रोहिणी नहीं गिनी जाती («विद्धायां
///   निशीथोत्तरं रोहिणीयोगस्याप्रयोजकत्वात्»), और दूसरे दिन अष्टमी एक मुहूर्त से
///   कम बचे तो वह दिन नहीं («सर्वपक्षेषु यदि परदिने मुहूर्तन्यूना वर्तते तदा सा
///   न ग्राह्या किंतु पूर्वैव»)।
///
/// पुराना नियम सिर्फ़ "निशीथ में अष्टमी" देखता था — 2027, 2029 और 2030 में
/// एक दिन पहले पड़ा, क्योंकि तीनों साल रोहिणी दूसरे दिन जुड़ती है।
///
/// संदर्भ-पंचांग से मिलान (दिल्ली): 2024–2030 के सातों साल, और 2002, 2005,
/// 2007, 2010, 2018, 2021, 2023, 2037 — पंद्रह में पंद्रह।
///
/// ⚠️ **एक जगह ग्रंथ और संदर्भ-पंचांग अलग पड़ते हैं** — जब पहली रात आधी रात
/// को अष्टमी-रोहिणी साथ हों *और* रोहिणी अगली आधी रात तक चले (तब दूसरे दिन
/// बची हुई पूरी अष्टमी रोहिणी में है)। ग्रंथ का पहला पक्ष (पृ. 57) पहला दिन
/// कहता है; संदर्भ-पंचांग दूसरा लिखता है। दिल्ली में यह 2032 और 2056 में
/// होता है, मुंबई-गुजरात में 2029 में भी (रोहिणी वहाँ की आधी रात से कुछ ही
/// मिनट पहले लगती है)। यहाँ ग्रंथ रखा है और दूसरा दिन `otherCandidate` में जाता
/// है — यानी ऐप दोनों दिखाता है। संदर्भ के पीछे जाकर यह शाखा मत बदलना:
/// छपे पंचांग या पंडित जी से पूछकर ही (→ `docs/08` §20.6)।
FestivalDate? _janmashtami(FestivalRule rule, _Antaral tithi, Place place) {
  final v = _hinduDin(tithi.start, place);
  final e = _hinduDin(tithi.end.subtract(const Duration(seconds: 1)), place);
  if (v == null || e == null) return _pickDay(rule, tithi, null, place);

  // पूरी अष्टमी एक ही हिंदू दिन में — «संदेह एव नास्ति»
  if (e.din == v.din) {
    return _nirnit(rule, tithi, null, place, din: v.din, kyon: const []);
  }

  final rohini = _rohini(tithi, place);
  // अष्टमी और रोहिणी साथ-साथ कब से कब
  final yog = rohini == null
      ? null
      : (
          start: rohini.start.isAfter(tithi.start) ? rohini.start : tithi.start,
          end: rohini.end.isBefore(tithi.end) ? rohini.end : tithi.end,
        );
  final rohiniPankti = rohini == null
      ? 'अष्टमी के साथ रोहिणी नक्षत्र नहीं पड़ता'
      : 'रोहिणी — ${_stamp(rohini.start)} से ${_stamp(rohini.end)} तक';

  // शुद्धाधिका: बीच का पूरा दिन अष्टमी, और अगले सूर्योदय के बाद भी बची
  final shuddha = e.din.difference(v.din).inDays >= 2;
  final purva = shuddha ? _aglaDin(v, place) : v;
  final para = e;
  if (purva == null) return _pickDay(rule, tithi, null, place);

  final paraMein = tithi.end.difference(para.uday);
  final bool paraChuna;
  String karan;

  if (shuddha) {
    // रोहिणी का योग सिर्फ़ दूसरे दिन हो, तभी दूसरा दिन
    paraChuna = yog != null && !yog.start.isBefore(para.uday);
    karan = paraChuna
        ? 'अष्टमी के साथ रोहिणी सिर्फ़ दूसरे दिन है — दूसरा दिन'
        : 'पहले दिन सूर्योदय से पूरे दिन-रात अष्टमी है — पहला दिन';
  } else {
    final ratP = _aadhiRaat(purva);
    final ratQ = _aadhiRaat(para);
    final nP = !tithi.start.isAfter(ratP);
    final nQ = tithi.end.isAfter(ratQ);
    final nyP =
        yog != null && !yog.start.isAfter(ratP) && yog.end.isAfter(ratP);
    final nyQ =
        yog != null && !yog.start.isAfter(ratQ) && yog.end.isAfter(ratQ);

    if (nyP && !nyQ) {
      paraChuna = false;
      karan = 'आधी रात को अष्टमी और रोहिणी साथ सिर्फ़ पहले दिन हैं — पहला दिन';
    } else if (nyQ) {
      paraChuna = true;
      karan = 'आधी रात को अष्टमी और रोहिणी साथ दूसरे दिन हैं — दूसरा दिन';
    } else if (yog != null && yog.end.isAfter(para.uday)) {
      paraChuna = true;
      final kitna =
          _avadhi(_chhua(yog.start, yog.end, para.uday, para.aglaUday));
      karan = nP
          ? 'पहले दिन आधी रात को अष्टमी है, पर रोहिणी का योग दूसरे दिन है '
              '($kitna) — दूसरा दिन'
          : 'अष्टमी के साथ रोहिणी दूसरे दिन है ($kitna) — दूसरा दिन';
    } else if (yog != null && !yog.end.isAfter(ratP)) {
      paraChuna = false;
      karan =
          'अष्टमी के साथ रोहिणी सिर्फ़ पहले दिन है, आधी रात से पहले — पहला दिन';
    } else if (nP && !nQ) {
      paraChuna = false;
      karan = 'आधी रात को अष्टमी सिर्फ़ पहले दिन है — पहला दिन';
    } else {
      paraChuna = true;
      karan = nQ && nP
          ? 'आधी रात को अष्टमी दोनों दिन है — दूसरा दिन'
          : nQ
              ? 'आधी रात को अष्टमी सिर्फ़ दूसरे दिन है — दूसरा दिन'
              : 'आधी रात को अष्टमी किसी दिन नहीं — दूसरा दिन';
    }
  }

  final chunaDin = paraChuna ? para.din : purva.din;
  karan = '$karan (${chunaDin.day}/${chunaDin.month})';

  // दूसरे दिन अष्टमी एक मुहूर्त भी न बचे तो वह दिन नहीं
  if (paraChuna && paraMein < _ekMuhurt) {
    return _nirnit(rule, tithi, null, place, din: purva.din, kyon: [
      rohiniPankti,
      'दूसरे दिन सूर्योदय के बाद अष्टमी एक मुहूर्त भी नहीं बचती — पहला दिन '
          '(${purva.din.day}/${purva.din.month})',
    ]);
  }

  if (paraChuna) {
    // पहले दिन आधी रात को अष्टमी थी — कई पंचांग उसे भी लिखते हैं
    final pehlaBhi = !tithi.start.isAfter(_aadhiRaat(purva));
    return _nirnit(rule, tithi, null, place,
        din: para.din,
        doosra: pehlaBhi ? purva.din : null,
        kyon: [
          rohiniPankti,
          karan,
          if (pehlaBhi) 'पहला दिन भी दिखाया है — उस रात आधी रात को अष्टमी है',
        ]);
  }

  // शुद्धाधिका में पहला दिन सूर्योदय से ही अष्टमी है — दूसरा कोई दावेदार नहीं
  final doosraBhi = !shuddha && paraMein >= _ekMuhurt;
  return _nirnit(rule, tithi, null, place,
      din: purva.din,
      doosra: doosraBhi ? para.din : null,
      kyon: [
        rohiniPankti,
        karan,
        if (doosraBhi) 'दूसरा दिन भी दिखाया है — उस दिन सूर्योदय पर अष्टमी है',
      ]);
}

String _explain(
  FestivalRule rule,
  ({DateTime start, DateTime end}) tithi,
  ({DateTime start, DateTime end})? bhadra, {
  required bool shifted,
  required bool missed,
  List<String> vishesh = const [],
}) {
  final visheshan = rule.nirnaya.visheshan;
  final lines = <String>[
    '${rule.masaName} ${rule.pakshaName} ${rule.tithiName}',
    visheshan == null
        ? rule.vyapini.hindi
        : '${rule.vyapini.hindi} — $visheshan',
    '${rule.tithiName} — ${_stamp(tithi.start)} से ${_stamp(tithi.end)} तक',
  ];

  if (bhadra != null) {
    lines.add('भद्रा — ${_stamp(bhadra.start)} से ${_stamp(bhadra.end)} तक');
  }
  if (shifted) {
    lines.add('भद्रा में यह काम नहीं होता, इसलिए अगले दिन');
  }
  if (missed) {
    lines.add('तिथि ${rule.vyapini.kaalName} काल को छू नहीं पाई — '
        'इसलिए जिस दिन तिथि सबसे ज़्यादा देर रही, वही दिन');
  }
  lines.addAll(vishesh);
  if (rule.nirnaya != Nirnaya.vyapini) {
    lines.add('निर्णय धर्मसिंधु के अनुसार');
  }

  lines.add('दृक् गणित · लाहिड़ी अयनांश · '
      '${rule.masaSystem == MasaSystem.purnimanta ? "पूर्णिमांत" : "अमांत"} पद्धति');

  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────
// त्योहारों की सूची
// ─────────────────────────────────────────────────────────────

/// **पहली बारह तारीख़ें drikpanchang.com से पक्की की हुई हैं** (2026, दिल्ली) —
/// हर एक के लिए उस दिन का पन्ना खोलकर देखा गया कि Drik ख़ुद वहाँ उस
/// त्योहार का नाम लिखता है या नहीं। लट्ठा `docs/08_VERIFICATION.md` में।
///
/// 8 अक्टूबर 2026 को वही जाँच **2024–2030 के सातों साल** पर हुई (→ D-117)।
/// सात नियम सातों साल मिले; पाँच नहीं — उन पर अब [Nirnaya] लगा है।
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
    nirnaya: Nirnaya.holika,
  ),
  FestivalRule(
    id: 'rama_navami',
    name: 'राम नवमी',
    masa: 0, // चैत्र
    paksha: 0,
    tithi: 9,
    vyapini: Vyapini.madhyahna,
    nirnaya: Nirnaya.ramNavami,
  ),
  FestivalRule(
    id: 'raksha_bandhan',
    name: 'रक्षाबंधन',
    masa: 4, // श्रावण
    paksha: 0,
    tithi: 15, // पूर्णिमा
    // अपराह्न नहीं — धर्मसिंधु का शब्द «त्रिमुहूर्ताधिकोदयव्यापिनी» है
    vyapini: Vyapini.sunrise,
    avoidBhadra: true,
    nirnaya: Nirnaya.raksha,
  ),
  FestivalRule(
    id: 'janmashtami',
    name: 'जन्माष्टमी',
    masa: 5, // भाद्रपद (पूर्णिमांत)
    paksha: 1,
    tithi: 8,
    vyapini: Vyapini.nishitha,
    nirnaya: Nirnaya.janmashtami,
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
    nirnaya: Nirnaya.lakshmiPujan,
  ),
  FestivalRule(
    id: 'dhanteras',
    name: 'धनतेरस',
    masa: 7, // कार्तिक
    paksha: 1,
    tithi: 13,
    vyapini: Vyapini.pradosha,
  ),
  FestivalRule(
    id: 'govardhan_puja',
    name: 'गोवर्धन पूजा',
    masa: 7, // कार्तिक
    paksha: 0,
    tithi: 1,
    vyapini: Vyapini.sunrise,
  ),
  FestivalRule(
    id: 'bhai_dooj',
    name: 'भाई दूज',
    masa: 7, // कार्तिक
    paksha: 0,
    tithi: 2,
    vyapini: Vyapini.aparahna,
  ),
  FestivalRule(
    id: 'vasant_panchami',
    name: 'वसंत पंचमी',
    masa: 10, // माघ
    paksha: 0,
    tithi: 5,
    vyapini: Vyapini.madhyahna,
  ),

  // ── 22 सित 2026 — व्रत और पितृ पक्ष (→ D-087) ────────────────────────
  //
  // हर नियम की व्यापिनी अंदाज़े से नहीं चुनी: 2024–2028 के पाँचों साल
  // (दिल्ली) संदर्भ-पंचांग के उस दिन वाले पन्ने से मिलाकर। जिस व्यापिनी पर
  // पाँचों मेल खाए वही रखी — बाक़ी क्यों नहीं, `docs/08_VERIFICATION.md` में।
  FestivalRule(
    id: 'vat_savitri',
    name: 'वट सावित्री व्रत',
    masa: 2, // ज्येष्ठ (पूर्णिमांत) — अमांत में यह वैशाख की अमावस्या है
    paksha: 1,
    tithi: 15, // अमावस्या
    // सूर्योदय वाला नियम 2025 में 27 मई देता — असल 26 मई
    vyapini: Vyapini.madhyahna,
  ),
  FestivalRule(
    id: 'varalakshmi_vrat',
    name: 'वरलक्ष्मी व्रत',
    masa: 4, // श्रावण
    paksha: 0,
    tithi: 15, // पूर्णिमा — व्रत उससे पहले वाले शुक्रवार को
    vaarPehle: DateTime.friday,
  ),
  FestivalRule(
    id: 'hartalika_teej',
    name: 'हरितालिका तीज',
    masa: 5, // भाद्रपद
    paksha: 0,
    tithi: 3,
    // मध्याह्न वाला नियम 2026 में 13 सित देता — असल 14 सित
    vyapini: Vyapini.sunrise,
  ),
  FestivalRule(
    id: 'pitru_paksha_arambh',
    name: 'पितृ पक्ष आरम्भ',
    masa: 6, // आश्विन (पूर्णिमांत) — कृष्ण प्रतिपदा
    paksha: 1,
    tithi: 1,
    vyapini: Vyapini.aparahna, // श्राद्ध अपराह्न में
  ),
  FestivalRule(
    id: 'sarvapitri_amavasya',
    name: 'सर्वपितृ अमावस्या',
    masa: 6, // आश्विन (पूर्णिमांत)
    paksha: 1,
    tithi: 15,
    // सूर्योदय वाला नियम 2027 में 30 सित देता — असल 29 सित
    vyapini: Vyapini.aparahna,
  ),
  FestivalRule(
    id: 'dussehra',
    name: 'दशहरा',
    masa: 6, // आश्विन
    paksha: 0,
    tithi: 10,
    // सूर्योदय वाला नियम 2024 में 13 अक्टू देता — असल 12 अक्टू
    vyapini: Vyapini.aparahna,
  ),
  FestivalRule(
    id: 'karwa_chauth',
    name: 'करवा चौथ',
    masa: 7, // कार्तिक (पूर्णिमांत)
    paksha: 1,
    tithi: 4,
    // व्रत चाँद देखकर खुलता है — चतुर्थी चंद्रोदय पर चाहिए
    vyapini: Vyapini.chandrodaya,
  ),
  FestivalRule(
    id: 'chhath',
    name: 'छठ पूजा',
    masa: 7, // कार्तिक
    paksha: 0,
    tithi: 6, // षष्ठी — संध्या अर्घ्य का दिन
    // सूर्योदय वाली षष्ठी। 2024–2028 में अपराह्न, मध्याह्न और सूर्योदय तीनों
    // एक ही दिन देते थे, इसलिए पाँच साल की जाँच इन्हें अलग नहीं कर पाई।
    // 2030 ने किया: षष्ठी 31 अक्टू 10:25 से 1 नव 08:04 तक — अपराह्न 31 देता
    // है, संदर्भ-पंचांग 1 नवम्बर लिखता है। सात साल (2024–2030) पर सिर्फ़
    // सूर्योदय ही सातों बार मिला (→ D-117, `tool/vyapini_aazmao.dart`)।
    vyapini: Vyapini.sunrise,
  ),
];

/// पूरे साल के त्योहार, तारीख़ के हिसाब से।
///
/// ⚡ एक बार का हिसाब याद रहता है (साल + शहर)। होम, कैलेंडर, "आज" और
/// आने वाली पूजाएँ — चारों यही माँगते हैं, और हर बार का हिसाब फ़ोन पर
/// कुछ सौ मिलीसेकंड था। सूची बदली नहीं जा सकती, ताकि कोई एक पन्ना
/// दूसरे का कैश न बिगाड़े।
List<FestivalDate> festivalsInYear(int year, Place place) {
  final key = '$year|${place.latitude}|${place.longitude}|'
      '${place.timeZoneOffset.inMinutes}';
  final yaad = _festivalsCache[key];
  if (yaad != null) return yaad;

  final months = lunarMonthsAround(year, place);
  final found = <FestivalDate>[];
  for (final rule in festivalRules) {
    final date = findFestival(rule, year, place, months);
    if (date != null) found.add(date);
  }
  found.sort((a, b) => a.date.compareTo(b.date));

  if (_festivalsCache.length >= _festivalsCacheSize) {
    _festivalsCache.remove(_festivalsCache.keys.first);
  }
  return _festivalsCache[key] = List.unmodifiable(found);
}

const _festivalsCacheSize = 8;
final Map<String, List<FestivalDate>> _festivalsCache = {};
