import 'package:panchang_engine/panchang_engine.dart';

final Map<String, List<FestivalDate>> _pitruScheduleCache = {};

void saafPitruScheduleCache() => _pitruScheduleCache.clear();

/// पूर्णिमा श्राद्ध अलग है; उसके बाद कृष्ण पक्ष की 15 तिथियाँ हैं।
/// सभी दिन अपराह्न-व्यापिनी नियम से, चुनी हुई जगह के लिए निकाले जाते हैं।
List<FestivalDate> pitruSchedule(int year, Place place) {
  final key =
      '$year|${place.name}|${place.latitude}|${place.longitude}|${place.timeZoneOffset.inMinutes}';
  final cached = _pitruScheduleCache[key];
  if (cached != null) return cached;

  final months = lunarMonthsAround(year, place);
  final entries = <FestivalDate>[];
  for (var i = 0; i <= 15; i++) {
    final rule = FestivalRule(
      id: i == 0 ? 'purnima_shraadh' : 'pitru_tithi_$i',
      name: i == 0
          ? 'पूर्णिमा श्राद्ध'
          : i == 15
              ? 'सर्वपितृ अमावस्या'
              : 'कृष्ण ${tithiNames[14 + i]} श्राद्ध',
      masa: i == 0 ? 5 : 6,
      paksha: i == 0 ? 0 : 1,
      tithi: i == 0 ? 15 : i,
      vyapini: Vyapini.aparahna,
    );
    final date = findFestival(rule, year, place, months);
    if (date != null) entries.add(date);
  }

  if (_pitruScheduleCache.length >= 10) {
    _pitruScheduleCache.remove(_pitruScheduleCache.keys.first);
  }
  return _pitruScheduleCache[key] = List.unmodifiable(entries);
}
