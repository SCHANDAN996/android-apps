import 'names.dart';
import 'panchang.dart';

/// संकल्प वाक्य — **ऐप का सबसे बड़ा हथियार।**
///
/// हर पूजा संकल्प से शुरू होती है, और संकल्प में आज का संवत्, अयन, ऋतु,
/// मास, पक्ष, तिथि, वार और नक्षत्र सब बोलना पड़ता है। **यही वो जगह है
/// जहाँ हर आदमी अटकता है और पंडित जी को बुलाना पड़ता है।**
///
/// हमारे पास पंचांग इंजन है, इसलिए हम यह वाक्य **ख़ुद बना सकते हैं** —
/// यूज़र से सिर्फ़ नाम, गोत्र और जगह पूछकर। बाज़ार में किसी ऐप के पास
/// यह नहीं है।
///
/// ## ⚠️ संस्कृत पंडित जी से पास होनी बाक़ी है
///
/// नीचे के रूप (मासे, तिथौ, वासरे, नक्षत्रे) प्रचलित संकल्प-पाठ से लिए
/// गए हैं, पर **किसी पंडित जी ने अभी जाँचे नहीं हैं।**
///
/// प्रोजेक्ट का नियम साफ़ है (→ D-009): *मंत्र ग़लत होना तिथि ग़लत होने
/// से भी बुरा है।* इसलिए [Sankalp.needsPanditReview] हमेशा सच रहता है,
/// और ऐप को यह चेतावनी दिखानी है — जब तक पंडित जी पास न कर दें।
///
/// क्षेत्रीय फ़र्क़ भी रहेंगे (द्वीप, खंड, गोत्र-उच्चारण), इसलिए एक
/// **सरल रूप** भी दिया गया है जो हर जगह चल जाता है।

/// यजमान की जानकारी — एक बार पूछो, फिर हमेशा याद रखो।
class SankalpDetails {
  /// यजमान का नाम, जैसे "चन्दन सिंह"
  final String name;

  /// गोत्र, जैसे "कश्यप"। न पता हो तो "कश्यप" ही आम चलन है।
  final String gotra;

  /// जगह का नाम, जैसे "दिल्ली"
  final String place;

  /// किस काम का संकल्प, जैसे "श्री सत्यनारायण पूजनं"
  final String purpose;

  const SankalpDetails({
    required this.name,
    required this.gotra,
    required this.place,
    required this.purpose,
  });
}

/// बना हुआ संकल्प — पूरा वाक्य, और हर हिस्सा अलग से भी।
class Sankalp {
  /// पूरा पारंपरिक संकल्प।
  final String full;

  /// छोटा रूप — जिन्हें पूरा कहना मुश्किल लगे उनके लिए।
  final String simple;

  /// हर हिस्सा अलग, ताकि ऐप में एक-एक लाइन दिखाई जा सके और यूज़र
  /// साथ-साथ बोल सके।
  final List<({String label, String value})> parts;

  /// **हमेशा सच** — जब तक पंडित जी संस्कृत पास न कर दें।
  final bool needsPanditReview;

  const Sankalp({
    required this.full,
    required this.simple,
    required this.parts,
    this.needsPanditReview = true,
  });
}

// ─────────────────────────────────────────────────────────────
// संकल्प वाले रूप (locative)
// ─────────────────────────────────────────────────────────────

/// वार के संकल्प-रूप। 0 = रविवार।
const List<String> _varaInSankalp = [
  'रविवासरे',
  'सोमवासरे',
  'मंगलवासरे',
  'बुधवासरे',
  'गुरुवासरे',
  'शुक्रवासरे',
  'शनिवासरे',
];

/// अयन के रूप।
const List<String> _ayanaInSankalp = ['उत्तरायणे', 'दक्षिणायने'];

/// पक्ष के रूप।
const List<String> _pakshaInSankalp = ['शुक्ल पक्षे', 'कृष्ण पक्षे'];

// ─────────────────────────────────────────────────────────────
// मुख्य काम
// ─────────────────────────────────────────────────────────────

/// उस दिन का पूरा संकल्प वाक्य बनाओ।
///
/// पंचांग से सब कुछ अपने आप भर जाता है — यूज़र से सिर्फ़ [details] चाहिए।
Sankalp buildSankalp(Panchang p, SankalpDetails details) {
  final samvatsara = p.vikramSamvatsara;
  final ayana = _ayanaInSankalp[p.ayana];
  final ritu = '${p.rituName} ऋतौ';
  final masa = '${p.masaFullName} मासे';
  final paksha = _pakshaInSankalp[p.paksha];
  final tithi = '${p.tithi.name} तिथौ';
  final vara = _varaInSankalp[p.vara];
  final nakshatra = '${p.nakshatra.name} नक्षत्रे';

  final parts = <({String label, String value})>[
    (label: 'देश-काल', value: 'जम्बूद्वीपे भरतखण्डे भारतवर्षे'),
    (label: 'स्थान', value: '${details.place} क्षेत्रे'),
    (label: 'संवत्', value: 'विक्रम संवत् ${p.vikramSamvat}'),
    (label: 'संवत्सर', value: '$samvatsara नाम संवत्सरे'),
    (label: 'अयन', value: ayana),
    (label: 'ऋतु', value: ritu),
    (label: 'मास', value: masa),
    (label: 'पक्ष', value: paksha),
    (label: 'तिथि', value: tithi),
    (label: 'वार', value: vara),
    (label: 'नक्षत्र', value: nakshatra),
    (label: 'गोत्र', value: '${details.gotra} गोत्रोत्पन्नः'),
    (label: 'नाम', value: '${details.name} अहं'),
    (label: 'संकल्प', value: '${details.purpose} करिष्ये'),
  ];

  final full = '''
ॐ विष्णुर्विष्णुर्विष्णुः।
श्रीमद्भगवतो महापुरुषस्य विष्णोराज्ञया प्रवर्तमानस्य
अद्य ब्रह्मणो द्वितीये परार्धे श्वेतवाराहकल्पे
वैवस्वतमन्वन्तरे अष्टाविंशतितमे कलियुगे कलिप्रथमचरणे
जम्बूद्वीपे भरतखण्डे भारतवर्षे आर्यावर्तान्तर्गते
${details.place} क्षेत्रे
$samvatsara नाम संवत्सरे $ayana
$ritu $masa $paksha
$tithi $vara $nakshatra
${details.gotra} गोत्रोत्पन्नः ${details.name} अहं
मम आत्मनः श्रुतिस्मृतिपुराणोक्तफलप्राप्त्यर्थं
${details.purpose} करिष्ये।'''
      .trim();

  final simple = '''
ॐ विष्णुर्विष्णुर्विष्णुः।
आज ${details.place} में,
विक्रम संवत् ${p.vikramSamvat}, $samvatsara संवत्सर,
${p.ayanaName}, ${p.rituName} ऋतु,
${p.masaFullName} मास, ${p.pakshaName} पक्ष,
${p.tithi.name} तिथि, ${p.varaName}, ${p.nakshatra.name} नक्षत्र —
${details.gotra} गोत्र में जन्मा/जन्मी ${details.name},
${details.purpose} का संकल्प लेता/लेती हूँ।'''
      .trim();

  return Sankalp(full: full, simple: simple, parts: parts);
}

/// आम पूजाओं के संकल्प-वाक्य — यूज़र को टाइप न करना पड़े।
///
/// ⚠️ ये भी पंडित जी से पास होने बाक़ी हैं।
const Map<String, String> commonPurposes = {
  'नित्य पूजा': 'देवपूजनं',
  'सत्यनारायण': 'श्री सत्यनारायण पूजनं',
  'गणेश पूजन': 'श्री गणेश पूजनं',
  'गृह प्रवेश': 'गृहप्रवेशं',
  'लक्ष्मी पूजन': 'श्री महालक्ष्मी पूजनं',
  'कलश स्थापना': 'घटस्थापनं',
  'रुद्राभिषेक': 'श्री रुद्राभिषेकं',
  'श्राद्ध': 'पितृतर्पणं',
  'वाहन पूजा': 'वाहनपूजनं',
  'मुंडन': 'चूडाकर्म संस्कारं',
  'व्रत': 'व्रतं',
};

/// आम गोत्र — जिन्हें अपना गोत्र न पता हो वे "कश्यप" कहते हैं।
const List<String> commonGotras = [
  'कश्यप', 'भारद्वाज', 'वशिष्ठ', 'गौतम', 'शांडिल्य', 'अत्रि',
  'विश्वामित्र', 'जमदग्नि', 'पराशर', 'गर्ग', 'कौशिक', 'उपमन्यु',
];

/// जाँच के लिए — क्या यह वार का रूप सही है?
String sankalpVaraName(int vara) => _varaInSankalp[vara];

/// जाँच के लिए — नामों की सूचियाँ पूरी हैं?
int get sankalpVaraCount => _varaInSankalp.length;

/// पंचांग के नाम और संकल्प के नाम मेल खाते हैं या नहीं, यह जाँचने के लिए।
bool sankalpNamesAreConsistent() =>
    _varaInSankalp.length == varaNames.length &&
    _ayanaInSankalp.length == ayanaNames.length &&
    _pakshaInSankalp.length == pakshaNames.length;
