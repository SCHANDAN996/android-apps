import 'muhurta.dart';
import 'names.dart';
import 'panchang.dart';
import 'place.dart';

/// किसी काम के लिए शुभ दिन — गृह प्रवेश, मुंडन, नामकरण, वाहन, भूमि पूजन।
///
/// # 🚧 यह हिस्सा अभी अधूरा है — ऐप में मत दिखाना
///
/// मशीनरी बन चुकी है और सही है, पर **नियमों की तालिकाएँ भरोसे लायक नहीं
/// हैं।** नीचे नाप कर लिखा है कि कहाँ खड़े हैं।
///
/// ## नापी हुई हालत (21 अगस्त 2026)
///
/// Drik की 2026 गृह प्रवेश सूची (दिल्ली, 37 तारीख़ें) से मिलान:
///
/// ```
/// मिले           26 / 37
/// छूट गए         11
/// फ़ालतू निकले    33   (जिनमें 22 गुरु/शुक्र अस्त वाले महीनों के)
///
/// अस्त वाले महीने (जन, अग, सित, अक्तू) हटाकर भी:
/// मिले 26 / 37 · छूटे 11 · फ़ालतू 11
/// ```
///
/// यानी **तिथि/नक्षत्र/वार की तालिका ही लगभग 70% सही है**, और उसके ऊपर
/// अस्त वाली पूरी कमी अलग से है।
///
/// ## दो चीज़ें चाहिए, तभी यह ऐप में जा सकता है
///
/// **1. गुरु तारा / शुक्र तारा अस्त**
/// जब बृहस्पति या शुक्र सूर्य के पास आ जाते हैं तो वे "अस्त" कहलाते हैं,
/// और उस पूरे दौर में मांगलिक काम नहीं होते। 2026 में अगस्त से अक्टूबर
/// तक Drik में एक भी गृह प्रवेश मुहूर्त नहीं है — पूरी वजह यही है।
///
/// इसके लिए **बृहस्पति और शुक्र का देशांतर** चाहिए। हमारे इंजन में सिर्फ़
/// सूर्य और चंद्र हैं (देखो `07_GANIT.md`)। यह जोड़े बिना यह फ़ीचर ग़लत
/// सलाह देगा — और अगस्त की तारीख़ें कोई भी पंडित तुरंत पकड़ लेगा।
///
/// **2. असली मुहूर्त नियम — किसी प्रामाणिक स्रोत से**
/// अभी की तालिकाएँ Drik की सूची से **उलटकर निकाली गई हैं**, शास्त्र से
/// नहीं ली गईं। 37 तारीख़ों पर fitting करके 100% मिलान बनाया जा सकता है,
/// पर वो नियम नहीं होगा — इत्तेफ़ाक़ होगा। छपे मुहूर्त-ग्रंथ या पंडित जी
/// से असली नियम लेने पड़ेंगे। (→ D-014, D-019)
///
/// ## जो सही है और रखने लायक है
/// - मुहूर्त **खिड़की** निकालना (मान्य तिथि ∩ मान्य नक्षत्र ∩ दिन)
/// - अधिक मास बाहर रखना
/// - भद्रा, पंचक, गंडमूल, क्षय तिथि की चेतावनियाँ
/// - शुभ चौघड़िया और अभिजित जोड़ना
///
/// ⚠️ **विवाह का मुहूर्त जान-बूझकर नहीं डाला गया** — गुरु-शुक्र देखे बिना
/// विवाह मुहूर्त बताना सीधे ग़लत सलाह देना होगा।

/// इस हिस्से की हालत — ऐप को यह देखकर ही तय करना चाहिए कि दिखाना है या नहीं।
const bool shubhMuhuratIsReady = false;

/// कौन सा काम।
enum Activity { grihaPravesh, mundan, namkaran, vahan, bhumiPujan, vidyarambh }

/// एक काम के लिए शास्त्रीय नियम।
class ActivityRule {
  final Activity activity;
  final String name;

  /// मान्य नक्षत्र, 0 से गिनती (अश्विनी = 0)।
  final List<int> nakshatras;

  /// मान्य तिथि, पक्ष के भीतर 1 से 15।
  final List<int> tithis;

  /// मान्य वार, 0 = रविवार।
  final List<int> varas;

  /// इस काम के लिए गुरु/शुक्र तारा अस्त देखना ज़रूरी है?
  /// (हम देख नहीं सकते — पर बताना ज़रूरी है कि देखना चाहिए)
  final bool needsGuruShukra;

  const ActivityRule({
    required this.activity,
    required this.name,
    required this.nakshatras,
    required this.tithis,
    required this.varas,
    this.needsGuruShukra = false,
  });
}

/// एक शुभ दिन — और वो शुभ क्यों है।
class ShubhDin {
  final ActivityRule rule;
  final DateTime date;

  final String nakshatra;
  final String tithi;
  final String vara;
  final String masa;

  /// मुहूर्त की खिड़की — जहाँ मान्य तिथि और मान्य नक्षत्र दोनों साथ चले।
  /// **यही असली मुहूर्त है, पूरा दिन नहीं।**
  final DateTime muhurtaStart;
  final DateTime muhurtaEnd;

  /// उस खिड़की के भीतर पड़ने वाली शुभ चौघड़िया।
  final List<MuhurtaSlot> windows;

  /// अभिजित मुहूर्त — दिन का सबसे शुभ समय।
  final DateTime? abhijitStart;
  final DateTime? abhijitEnd;

  /// जो बातें ध्यान देने लायक हैं — भद्रा, पंचक, गंडमूल वग़ैरह।
  final List<String> cautions;

  /// **हमेशा सच।** गुरु/शुक्र तारा अस्त की जाँच नहीं हुई।
  bool get guruShukraNotChecked => rule.needsGuruShukra;

  /// यह नतीजा अभी भरोसे लायक नहीं है। देखो फ़ाइल का ऊपरी नोट।
  bool get isReliable => shubhMuhuratIsReady;

  final String explanation;

  const ShubhDin({
    required this.rule,
    required this.date,
    required this.nakshatra,
    required this.tithi,
    required this.vara,
    required this.masa,
    required this.muhurtaStart,
    required this.muhurtaEnd,
    required this.windows,
    required this.abhijitStart,
    required this.abhijitEnd,
    required this.cautions,
    required this.explanation,
  });
}

// ─────────────────────────────────────────────────────────────
// नियम
// ─────────────────────────────────────────────────────────────

/// नक्षत्रों के नाम से क्रमांक — नियम पढ़ने में आसानी के लिए।
int _nak(String name) => nakshatraNames.indexOf(name);

/// गृह प्रवेश के नियम — **Drik की 2026 सूची से मिलाकर निकाले गए।**
final List<ActivityRule> activityRules = [
  ActivityRule(
    activity: Activity.grihaPravesh,
    name: 'गृह प्रवेश',
    nakshatras: [
      _nak('रोहिणी'),
      _nak('मृगशिरा'),
      _nak('उत्तरा फाल्गुनी'),
      _nak('चित्रा'),
      _nak('अनुराधा'),
      _nak('उत्तराषाढ़ा'),
      _nak('उत्तरा भाद्रपदा'),
      _nak('रेवती'),
    ],
    tithis: [2, 3, 5, 7, 10, 11, 13],
    varas: [1, 3, 4, 5, 6], // सोम, बुध, गुरु, शुक्र, शनि
    needsGuruShukra: true,
  ),

  // ⬜ नीचे वाले नियम शास्त्रीय सूचियों से हैं, **Drik से मिलाना बाक़ी है**
  ActivityRule(
    activity: Activity.mundan,
    name: 'मुंडन',
    nakshatras: [
      _nak('अश्विनी'),
      _nak('मृगशिरा'),
      _nak('पुष्य'),
      _nak('हस्त'),
      _nak('चित्रा'),
      _nak('स्वाति'),
      _nak('ज्येष्ठा'),
      _nak('श्रवण'),
      _nak('धनिष्ठा'),
      _nak('शतभिषा'),
      _nak('रेवती'),
    ],
    tithis: [2, 3, 5, 7, 10, 11, 13],
    varas: [1, 3, 4, 5],
    needsGuruShukra: true,
  ),
  ActivityRule(
    activity: Activity.namkaran,
    name: 'नामकरण',
    nakshatras: [
      _nak('अश्विनी'),
      _nak('रोहिणी'),
      _nak('मृगशिरा'),
      _nak('पुनर्वसु'),
      _nak('पुष्य'),
      _nak('हस्त'),
      _nak('चित्रा'),
      _nak('स्वाति'),
      _nak('अनुराधा'),
      _nak('श्रवण'),
      _nak('धनिष्ठा'),
      _nak('शतभिषा'),
      _nak('रेवती'),
    ],
    tithis: [1, 2, 3, 5, 7, 10, 11, 12, 13],
    varas: [1, 3, 4, 5],
  ),
  ActivityRule(
    activity: Activity.vahan,
    name: 'वाहन ख़रीद',
    nakshatras: [
      _nak('अश्विनी'),
      _nak('रोहिणी'),
      _nak('मृगशिरा'),
      _nak('पुनर्वसु'),
      _nak('पुष्य'),
      _nak('हस्त'),
      _nak('चित्रा'),
      _nak('स्वाति'),
      _nak('अनुराधा'),
      _nak('धनिष्ठा'),
      _nak('शतभिषा'),
      _nak('रेवती'),
    ],
    tithis: [1, 2, 3, 5, 7, 10, 11, 13],
    varas: [1, 3, 4, 5],
  ),
  ActivityRule(
    activity: Activity.bhumiPujan,
    name: 'भूमि पूजन',
    nakshatras: [
      _nak('रोहिणी'),
      _nak('मृगशिरा'),
      _nak('उत्तरा फाल्गुनी'),
      _nak('चित्रा'),
      _nak('अनुराधा'),
      _nak('उत्तराषाढ़ा'),
      _nak('उत्तरा भाद्रपदा'),
      _nak('रेवती'),
    ],
    tithis: [2, 3, 5, 7, 10, 11, 13],
    varas: [1, 3, 4, 5],
    needsGuruShukra: true,
  ),
  ActivityRule(
    activity: Activity.vidyarambh,
    name: 'विद्यारंभ',
    nakshatras: [
      _nak('अश्विनी'),
      _nak('मृगशिरा'),
      _nak('पुनर्वसु'),
      _nak('पुष्य'),
      _nak('हस्त'),
      _nak('चित्रा'),
      _nak('स्वाति'),
      _nak('अनुराधा'),
      _nak('श्रवण'),
      _nak('धनिष्ठा'),
      _nak('शतभिषा'),
      _nak('रेवती'),
    ],
    tithis: [2, 3, 5, 10, 11, 12, 13],
    varas: [1, 3, 4, 5],
  ),
];

ActivityRule ruleFor(Activity activity) =>
    activityRules.firstWhere((r) => r.activity == activity);

// ─────────────────────────────────────────────────────────────
// मुख्य काम
// ─────────────────────────────────────────────────────────────

/// किसी काम के लिए उस साल के शुभ दिन।
///
/// ⚠️ गुरु/शुक्र तारा अस्त की जाँच नहीं होती — देखो इस फ़ाइल का ऊपरी नोट।
List<ShubhDin> shubhDinList(Activity activity, int year, Place place) {
  final rule = ruleFor(activity);
  final found = <ShubhDin>[];

  var day = DateTime.utc(year, 1, 1);
  while (day.year == year) {
    final din = _check(rule, day.year, day.month, day.day, place);
    if (din != null) found.add(din);
    day = day.add(const Duration(days: 1));
  }

  return found;
}

/// क्या यह दिन इस काम के लिए शुभ है? न हो तो null।
///
/// ⚠️ **सूर्योदय की तिथि/नक्षत्र देखना काफ़ी नहीं।**
///
/// मुहूर्त एक *खिड़की* है, पूरा दिन नहीं। दिन में तिथि और नक्षत्र दोनों
/// बदल सकते हैं, और मुहूर्त वहाँ बनता है जहाँ **मान्य तिथि और मान्य
/// नक्षत्र एक साथ चल रहे हों।**
///
/// इसीलिए Drik अपनी सूची में एक ही दिन के आगे दो नक्षत्र और दो तिथि
/// लिखता है — जैसे "6 फ़रवरी — चित्रा, हस्त | षष्ठी, पंचमी"। वहाँ मुहूर्त
/// उस टुकड़े में है जहाँ चित्रा और पंचमी दोनों साथ थे।
///
/// पहले सिर्फ़ सूर्योदय देखा था और 37 में से 21 तारीख़ें छूट गई थीं।
ShubhDin? _check(
    ActivityRule rule, int year, int month, int day, Place place) {
  final p = computePanchang(year, month, day, place);

  // ── अधिक मास में कोई मांगलिक काम नहीं ──
  if (p.isAdhikaMasa) return null;

  // ── वार पूरे दिन का होता है ──
  if (!rule.varas.contains(p.vara)) return null;

  if (p.sunrise == null || p.sunset == null) return null;

  // ── मान्य तिथि और मान्य नक्षत्र की खिड़कियाँ ──
  final tithiWindows = <({DateTime start, DateTime end, String name})>[];
  for (final anga in p.tithis) {
    final inPaksha = anga.index < 15 ? anga.index + 1 : anga.index - 14;
    if (!rule.tithis.contains(inPaksha)) continue;
    if (anga.endsAt == null) continue;
    tithiWindows.add((
      start: anga.startsAt ?? p.sunrise!,
      end: anga.endsAt!,
      name: anga.name
    ));
  }
  if (tithiWindows.isEmpty) return null;

  final nakshatraWindows = <({DateTime start, DateTime end, String name})>[];
  for (final anga in p.nakshatras) {
    if (!rule.nakshatras.contains(anga.index)) continue;
    if (anga.endsAt == null) continue;
    nakshatraWindows.add((
      start: anga.startsAt ?? p.sunrise!,
      end: anga.endsAt!,
      name: anga.name
    ));
  }
  if (nakshatraWindows.isEmpty) return null;

  // ── दोनों जहाँ मिलें, वही मुहूर्त — और वो दिन के उजाले में हो ──
  DateTime? bestStart;
  DateTime? bestEnd;
  var bestTithi = '';
  var bestNakshatra = '';

  for (final t in tithiWindows) {
    for (final n in nakshatraWindows) {
      var start = t.start.isAfter(n.start) ? t.start : n.start;
      var end = t.end.isBefore(n.end) ? t.end : n.end;

      // दिन के उजाले तक सीमित
      if (start.isBefore(p.sunrise!)) start = p.sunrise!;
      if (end.isAfter(p.sunset!)) end = p.sunset!;
      if (!start.isBefore(end)) continue;

      final length = end.difference(start);
      if (bestStart == null || length > bestEnd!.difference(bestStart)) {
        bestStart = start;
        bestEnd = end;
        bestTithi = t.name;
        bestNakshatra = n.name;
      }
    }
  }

  if (bestStart == null || bestEnd == null) return null;
  final muhurtaStart = bestStart;
  final muhurtaEnd = bestEnd;

  // ── ध्यान देने लायक बातें ──
  final cautions = <String>[
    if (p.bhadra != null)
      'भद्रा — ${_hm(p.bhadra!.start)} से ${_hm(p.bhadra!.end)} तक',
    if (p.isPanchak) 'पंचक चल रहा है',
    if (p.isGandmool) 'गंडमूल नक्षत्र',
    if (p.kshayaTithiName != null) 'क्षय तिथि — ${p.kshayaTithiName}',
  ];

  // ── काम शुरू करने के शुभ समय — मुहूर्त की खिड़की के भीतर वाली चौघड़िया ──
  final windows = choghadiya(year, month, day, place)
      .where((s) =>
          s.isDay &&
          s.auspicious == true &&
          s.start.isBefore(muhurtaEnd) &&
          muhurtaStart.isBefore(s.end))
      .toList();

  return ShubhDin(
    rule: rule,
    date: DateTime.utc(year, month, day),
    nakshatra: bestNakshatra,
    tithi: bestTithi,
    vara: p.varaName,
    masa: p.masaFullName,
    muhurtaStart: muhurtaStart,
    muhurtaEnd: muhurtaEnd,
    windows: windows,
    abhijitStart: p.abhijit?.start,
    abhijitEnd: p.abhijit?.end,
    cautions: cautions,
    explanation: _explain(rule, p, bestNakshatra, bestTithi, muhurtaStart, muhurtaEnd),
  );
}

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _explain(ActivityRule rule, Panchang p, String nakshatra, String tithi,
    DateTime start, DateTime end) {
  final lines = <String>[
    '${p.masaFullName} ${p.pakshaName} $tithi · ${p.varaName}',
    'नक्षत्र $nakshatra',
    'मुहूर्त ${_hm(start)} से ${_hm(end)} तक — इसी टुकड़े में तिथि, '
        'नक्षत्र और वार तीनों ${rule.name} के लिए मान्य हैं',
  ];

  lines.add('⚠️ यह सूची अभी अधूरी है — नियमों की तालिका पक्की नहीं हुई');
  if (rule.needsGuruShukra) {
    lines.add('⚠️ गुरु/शुक्र तारा अस्त की जाँच नहीं होती — '
        'अस्त के दौर में यह काम नहीं होता, पंडित जी से पक्का करें');
  }

  lines.add('दृक् गणित · लाहिड़ी अयनांश');
  return lines.join('\n');
}
