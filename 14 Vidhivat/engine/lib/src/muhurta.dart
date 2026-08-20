import 'names.dart';
import 'place.dart';
import 'sunrise.dart';

/// चौघड़िया और होरा।
///
/// दोनों एक ही जड़ से निकलते हैं — **वार के स्वामी ग्रह से।** इसीलिए
/// दोनों की शुरुआती तालिका एक ही है।
///
/// ```
/// रवि → सूर्य    सोम → चंद्र    मंगल → मंगल    बुध → बुध
/// गुरु → गुरु    शुक्र → शुक्र   शनि → शनि
/// ```
///
/// और आगे का क्रम **होरा-क्रम** से चलता है (कल्दियन क्रम का उल्टा):
/// ```
/// सूर्य → शुक्र → बुध → चंद्र → शनि → गुरु → मंगल → सूर्य …
/// ```
///
/// इसी क्रम की सबसे सुंदर बात: सूर्योदय से 24 होरा गिनो तो अगले सूर्योदय
/// पर अगले वार का स्वामी आ जाता है — **वारों का क्रम इसी से बना है।**
///
/// ## तालिकाएँ कहाँ से आईं
/// अंदाज़े से नहीं। Drik से **दो वार** मिलाकर — 20 अगस्त 2026 (गुरुवार)
/// और 23 अगस्त 2026 (रविवार)। दोनों में दिन और रात दोनों की पूरी सूची
/// हूबहू मिली। ब्यौरा `docs/08_VERIFICATION.md` में।

/// होरा का क्रम — यही चौघड़िया का भी क्रम है।
const List<String> horaLords = [
  'सूर्य', 'शुक्र', 'बुध', 'चंद्र', 'शनि', 'गुरु', 'मंगल',
];

/// चौघड़िया के नाम, होरा-क्रम के हिसाब से।
/// (उद्वेग = सूर्य की, चर = शुक्र की, और आगे इसी तरह)
const List<String> choghadiyaNames = [
  'उद्वेग', 'चर', 'लाभ', 'अमृत', 'काल', 'शुभ', 'रोग',
];

/// कौन सी चौघड़िया शुभ है। चर, लाभ, अमृत और शुभ — बाक़ी तीन अशुभ।
const List<bool> choghadiyaAuspicious = [
  false, // उद्वेग
  true, // चर
  true, // लाभ
  true, // अमृत
  false, // काल
  true, // शुभ
  false, // रोग
];

/// वार का स्वामी — होरा-क्रम की सूची में उसकी जगह। 0 = रविवार।
///
/// यही तालिका चौघड़िया और होरा दोनों की शुरुआत तय करती है।
const List<int> weekdayLord = [0, 3, 6, 2, 5, 1, 4];

/// दिन या रात का एक टुकड़ा।
class MuhurtaSlot {
  final String name;
  final DateTime start;
  final DateTime end;

  /// दिन का टुकड़ा है या रात का।
  final bool isDay;

  /// चौघड़िया में — शुभ है या अशुभ। होरा में हमेशा null।
  final bool? auspicious;

  const MuhurtaSlot({
    required this.name,
    required this.start,
    required this.end,
    required this.isDay,
    this.auspicious,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  @override
  String toString() => name;
}

/// दिन और रात की सीमाएँ — तीनों गणनाओं को यही चाहिए।
({DateTime sunrise, DateTime sunset, DateTime nextSunrise})? _dayBounds(
    int year, int month, int day, Place place) {
  final riseSet = sunriseSunset(year, month, day, place);
  if (riseSet.sunrise == null || riseSet.sunset == null) return null;

  final next = DateTime.utc(year, month, day).add(const Duration(days: 1));
  final nextRise = sunriseSunset(next.year, next.month, next.day, place).sunrise;
  if (nextRise == null) return null;

  return (
    sunrise: riseSet.sunrise!.add(place.timeZoneOffset),
    sunset: riseSet.sunset!.add(place.timeZoneOffset),
    nextSunrise: nextRise.add(place.timeZoneOffset),
  );
}

/// पूरे हिंदू दिन की चौघड़िया — **आठ दिन की, आठ रात की।**
///
/// दिन (सूर्योदय→सूर्यास्त) के आठ बराबर भाग, फिर रात (सूर्यास्त→अगला
/// सूर्योदय) के आठ भाग।
///
/// ⚠️ **दिन और रात का क्रम अलग चलता है।** दिन में हर अगली चौघड़िया
/// होरा-क्रम में एक क़दम आगे बढ़ती है, पर **रात में दो क़दम पीछे**।
/// यह भूलना आसान है — Drik से मिलाने पर ही पकड़ में आया।
List<MuhurtaSlot> choghadiya(int year, int month, int day, Place place) {
  final bounds = _dayBounds(year, month, day, place);
  if (bounds == null) return const [];

  final vara = DateTime.utc(year, month, day).weekday % 7;
  final dayStart = weekdayLord[vara];

  final slots = <MuhurtaSlot>[];

  MuhurtaSlot make(int index, DateTime start, DateTime end, bool isDay) {
    final i = ((index % 7) + 7) % 7;
    return MuhurtaSlot(
      name: choghadiyaNames[i],
      start: start,
      end: end,
      isDay: isDay,
      auspicious: choghadiyaAuspicious[i],
    );
  }

  // ── दिन के आठ भाग — क्रम आगे बढ़ता है ──
  final dayPart = bounds.sunset.difference(bounds.sunrise) ~/ 8;
  for (var n = 0; n < 8; n++) {
    final start = bounds.sunrise.add(dayPart * n);
    final end = n == 7 ? bounds.sunset : bounds.sunrise.add(dayPart * (n + 1));
    slots.add(make(dayStart + n, start, end, true));
  }

  // ── रात के आठ भाग — शुरुआत पाँच क़दम आगे, फिर हर बार दो क़दम पीछे ──
  final nightStart = dayStart + 5;
  final nightPart = bounds.nextSunrise.difference(bounds.sunset) ~/ 8;
  for (var n = 0; n < 8; n++) {
    final start = bounds.sunset.add(nightPart * n);
    final end =
        n == 7 ? bounds.nextSunrise : bounds.sunset.add(nightPart * (n + 1));
    slots.add(make(nightStart - 2 * n, start, end, false));
  }

  return slots;
}

/// पूरे हिंदू दिन के चौबीस होरा — **बारह दिन के, बारह रात के।**
///
/// होरा एक घंटे का नहीं होता। दिन के बारह बराबर भाग, रात के बारह —
/// इसलिए गर्मियों में दिन का होरा लंबा और रात का छोटा होता है।
///
/// क्रम दिन-रात में एक ही रहता है, बीच में टूटता नहीं।
List<MuhurtaSlot> hora(int year, int month, int day, Place place) {
  final bounds = _dayBounds(year, month, day, place);
  if (bounds == null) return const [];

  final vara = DateTime.utc(year, month, day).weekday % 7;
  final start = weekdayLord[vara];

  final slots = <MuhurtaSlot>[];

  void add(int index, DateTime from, DateTime to, bool isDay) {
    slots.add(MuhurtaSlot(
      name: horaLords[((index % 7) + 7) % 7],
      start: from,
      end: to,
      isDay: isDay,
    ));
  }

  final dayHora = bounds.sunset.difference(bounds.sunrise) ~/ 12;
  for (var n = 0; n < 12; n++) {
    add(
      start + n,
      bounds.sunrise.add(dayHora * n),
      n == 11 ? bounds.sunset : bounds.sunrise.add(dayHora * (n + 1)),
      true,
    );
  }

  final nightHora = bounds.nextSunrise.difference(bounds.sunset) ~/ 12;
  for (var n = 0; n < 12; n++) {
    add(
      start + 12 + n,
      bounds.sunset.add(nightHora * n),
      n == 11 ? bounds.nextSunrise : bounds.sunset.add(nightHora * (n + 1)),
      false,
    );
  }

  return slots;
}

/// अभी कौन सी चौघड़िया चल रही है।
///
/// ⚠️ हिंदू दिन सूर्योदय से शुरू होता है — इसलिए आधी रात से सूर्योदय तक
/// का समय **पिछले दिन** की सूची में पड़ता है। यही देखा जाता है।
MuhurtaSlot? currentChoghadiya(DateTime localMoment, Place place) =>
    _findCurrent(localMoment, place, choghadiya);

/// अभी कौन सा होरा चल रहा है।
MuhurtaSlot? currentHora(DateTime localMoment, Place place) =>
    _findCurrent(localMoment, place, hora);

MuhurtaSlot? _findCurrent(
  DateTime moment,
  Place place,
  List<MuhurtaSlot> Function(int, int, int, Place) build,
) {
  // आज और कल दोनों देखो — सूर्योदय से पहले का समय पिछले दिन में पड़ता है
  for (final offset in [0, -1]) {
    final day = DateTime.utc(moment.year, moment.month, moment.day)
        .add(Duration(days: offset));

    for (final slot in build(day.year, day.month, day.day, place)) {
      if (slot.contains(moment)) return slot;
    }
  }
  return null;
}

/// आगे आने वाली शुभ चौघड़िया — "अभी कोई काम शुरू करना हो तो कब"।
List<MuhurtaSlot> upcomingAuspicious(DateTime localMoment, Place place,
    {int howMany = 3}) {
  final found = <MuhurtaSlot>[];

  for (var offset = 0; offset <= 1 && found.length < howMany; offset++) {
    final day = DateTime.utc(localMoment.year, localMoment.month, localMoment.day)
        .add(Duration(days: offset));

    for (final slot in choghadiya(day.year, day.month, day.day, place)) {
      if (slot.auspicious != true) continue;
      if (!slot.end.isAfter(localMoment)) continue;

      found.add(slot);
      if (found.length == howMany) break;
    }
  }

  return found;
}

/// जाँच के लिए — वार का नाम, वही जो `names.dart` में है।
String varaNameFor(int year, int month, int day) =>
    varaNames[DateTime.utc(year, month, day).weekday % 7];
