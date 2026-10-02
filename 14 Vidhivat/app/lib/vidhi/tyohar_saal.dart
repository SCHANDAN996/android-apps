import 'package:panchang_engine/panchang_engine.dart';

import 'aane_wale_din.dart' show sankrantiKiPuja, sankrantiPujaDin;

/// साल भर के त्योहार — इंजन के **तिथि वाले**, और **संक्रांति वाले** भी।
///
/// ## यह क्यों बना
///
/// 17 सितम्बर 2026, विश्वकर्मा पूजा के दिन — होम की "आने वाली पूजा" में
/// वह थी, पर **"आज" पन्ने और कैलेंडर में नहीं।** दोनों सीधे इंजन का
/// `festivalsInYear` पढ़ते थे, जो सिर्फ़ तिथि वाले त्योहार जानता है।
/// संक्रांति वाली पूजा सिर्फ़ `aaneWaliPujaayein` में जोड़ी गई थी।
///
/// अब "आज" और कैलेंडर यही पढ़ते हैं। नई संक्रांति-पूजा [sankrantiKiPuja]
/// में जुड़ी तो तीनों जगह अपने आप आएगी।
final Map<String, List<FestivalDate>> _tyoharSaalBharCache = {};

/// ज़रूरत पड़ने पर (जैसे शहर बदलने पर) कैश साफ़ करने के लिए।
void saafTyoharSaalBharCache() => _tyoharSaalBharCache.clear();

List<FestivalDate> tyoharSaalBhar(int year, Place place) {
  final key =
      '$year|${place.name}|${place.latitude}|${place.longitude}|${place.timeZoneOffset.inMinutes}';
  final cached = _tyoharSaalBharCache[key];
  if (cached != null) return cached;

  final sab = [
    ...festivalsInYear(year, place),
    ...sankrantiTyohar(year, place),
  ]..sort((a, b) => a.date.compareTo(b.date));

  if (_tyoharSaalBharCache.length >= 10) {
    _tyoharSaalBharCache.remove(_tyoharSaalBharCache.keys.first);
  }
  return _tyoharSaalBharCache[key] = List.unmodifiable(sab);
}

/// [year] की संक्रांति वाली पूजाएँ, कैलेंडर के त्योहार वाले रूप में।
///
/// ## [FestivalDate] में क्यों, जबकि वह तिथि के लिए बना है
///
/// "आज" और कैलेंडर उसमें से सिर्फ़ नाम, तारीख़, "दो तारीख़ें" और हिसाब
/// दिखाते हैं — अलग ढाँचा बनाते तो दोनों पन्नों में हर जगह दो सूचियाँ
/// सँभालनी पड़तीं। इसलिए:
///
/// - `tithiStart` / `tithiEnd` / `kaalStart` / `kaalEnd` — चारों
///   **संक्रांति का पल**। यहाँ कोई तिथि-खिड़की नहीं होती।
/// - `rule` का मास, पक्ष और तिथि — उस दिन सूर्योदय के पंचांग के। ये
///   नियम नहीं, सिर्फ़ उस दिन के तथ्य हैं; तारीख़ इनसे नहीं निकली।
/// - हिसाब (`explanation`) साफ़ कहता है कि दिन सूर्य की राशि से तय है।
///
/// ## "दो तारीख़ें"
///
/// इंजन का पल स्वतंत्र संदर्भ-गणना से ±5 मिनट तक हिलता है। पल स्थानीय आधी रात के छह
/// मिनट के भीतर पड़े तो दिन पक्का नहीं — तब `ambiguous` और दूसरा दिन
/// भी, ताकि ऐप चुपचाप एक न चुने। (2023–2028 में ऐसा कोई साल नहीं।)
List<FestivalDate> sankrantiTyohar(int year, Place place) {
  final mile = <FestivalDate>[];
  for (final entry in sankrantiKiPuja.entries) {
    final puja = entry.value;
    final s = sankrantiInYear(year, entry.key, place);
    final din = sankrantiPujaDin(s, place, puja.dinNiyam);
    if (din.year != year) continue;
    mile.add(_sankrantiSe(s, din, puja.naam, puja.kyon, place));
  }
  return mile;
}

/// पल आधी रात के इतने पास हो तो दिन पक्का नहीं (इंजन की छूट ±5 मिनट)।
const Duration sankrantiDinKiChhoot = Duration(minutes: 6);

/// पल आधी रात के पास हो तो **दूसरा दावेदार दिन**, वरना `null`।
DateTime? sankrantiDoosraDin(DateTime pal) {
  final din = DateTime(pal.year, pal.month, pal.day);
  final bitaa = pal.difference(din);
  if (bitaa < sankrantiDinKiChhoot) {
    return din.subtract(const Duration(days: 1));
  }
  if (const Duration(days: 1) - bitaa <= sankrantiDinKiChhoot) {
    return din.add(const Duration(days: 1));
  }
  return null;
}

FestivalDate _sankrantiSe(
  Sankranti s,
  DateTime din,
  String naam,
  String kyon,
  Place place,
) {
  final p = computePanchang(din.year, din.month, din.day, place);
  final tithi = p.tithi.index;
  final doosra = sankrantiDoosraDin(s.pal);

  String samay(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  return FestivalDate(
    rule: FestivalRule(
      id: 'sankranti_${s.rashi}',
      name: naam,
      masa: p.masa,
      paksha: tithi < 15 ? 0 : 1,
      tithi: tithi < 15 ? tithi + 1 : tithi - 14,
    ),
    date: din,
    tithiStart: s.pal,
    tithiEnd: s.pal,
    kaalStart: s.pal,
    kaalEnd: s.pal,
    shiftedForBhadra: false,
    missedKaal: false,
    ambiguous: doosra != null,
    otherCandidate: doosra,
    explanation: [
      '$kyon — सूर्य ${din.day}/${din.month} को ${samay(s.pal)} पर '
          '${s.rashiNaam} राशि में',
      'यह तिथि से नहीं, सूर्य की राशि से तय होती है',
      if (din == s.din)
        'दिन वही, जिस तारीख़ को संक्रांति का पल पड़े'
      else
        'प्रवेश सूर्यास्त के बाद — पुण्यकाल अगले दिन सूर्योदय से',
      if (doosra != null)
        'पल आधी रात के बहुत पास है — छपे पंचांग से दिन मिला लें',
      'दृक् गणित · लाहिड़ी अयनांश · सूर्य की निरयण राशि',
    ].join('\n'),
  );
}
