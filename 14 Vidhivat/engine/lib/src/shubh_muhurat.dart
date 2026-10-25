import 'graha.dart';
import 'graha_ast.dart';
import 'muhurta.dart';
import 'names.dart';
import 'panchang.dart';
import 'place.dart';
import 'sunrise.dart';

/// किसी काम के लिए शुभ दिन — गृह प्रवेश, मुंडन, नामकरण, भूमि पूजन, विद्यारंभ।
///
/// # नियम अब दो छपे ग्रंथों से हैं (25 अक्टूबर 2026, → D-148)
///
/// पहले की तालिकाएँ एक website की सूची से उलटकर निकाली गई थीं (→ D-019) —
/// वे हटीं। अब हर खाना दो अलग ग्रंथों के पन्नों से है, आँख से पढ़कर:
///
/// - **मुहूर्त चिंतामणि** (रामदैवज्ञ) — योगेश्वर पाठक की भाषाटीका, ठाकुर प्रसाद,
///   वाराणसी 2012 (archive: `muhurt-chintamani-of-divagya-anant-sutaram-…`)
/// - **मुहूर्त मार्तण्ड** (नारायण दैवज्ञ) — कपिलेश्वर शास्त्री, चौखम्भा, वाराणसी 1978
///   (archive: `muhurt-martand-of-narayan-daivagya-by-kapileshvar-shastri-…`)
///
/// नियम: **वही दिन, जो दोनों ग्रंथों में मान्य हो** (`docs/30` §५.२ म३)। जहाँ एक
/// ग्रंथ कड़ा है, वही लगता है। पूरा लट्ठा — कौन-सा नियम किस श्लोक से —
/// `docs/18` §४४।
///
/// # फिर भी अभी ऐप में नहीं ([shubhMuhuratIsReady] = false)
///
/// खोलने की कसौटी (`docs/30` §५.३) में दूसरी शर्त है: छपी/प्रकाशित सूचियों से
/// नाप में दस में नौ तारीख़ें मिलें। वह नाप अभी नहीं हुई — website वाली सूची
/// (`test/shubh_muhurat_test.dart`) ख़ुद अलग नियम से बनी है (आषाढ़ में भी गृह प्रवेश
/// देती है, जो दोनों ग्रंथ मना करते हैं), इसलिए उससे मिलान कसौटी नहीं बन सकता।
/// घर के छपे पंचांग की मुहूर्त-सूची से नाप होगी, तब खुलेगा।
///
/// # जो ग्रंथ देखते हैं पर ऐप नहीं देख सकता
/// - **लग्न** (स्थिर/चर लग्न, केन्द्र-त्रिकोण में ग्रह) — ऐप लग्न-शुद्धि नहीं देखता।
/// - **जन्म-राशि से चंद्र/तारा बल** — यूज़र की कुंडली चाहिए।
/// - **द्वार की दिशा** (गृह प्रवेश में तिथि और वाम रवि) — घर का मुख चाहिए।
/// - बच्चे की उम्र (मुंडन तीसरे वर्ष से विषम वर्ष, अक्षरारम्भ पाँचवें वर्ष)।
/// इन्हें हर दिन की व्याख्या में "अपने पुरोहित से देखें" के रूप में लिखा है।
///
/// ⚠️ **विवाह का मुहूर्त जान-बूझकर नहीं डाला गया** — उसके नियम कई गुना हैं।
/// ⚠️ **वाहन** — दोनों ग्रंथों में वाहन ख़रीदने का अलग मुहूर्त नहीं मिला; सिर्फ़
/// इतना कि चर नक्षत्र वाहन-यान के काम के हैं। इसलिए उसकी सूची नहीं बनती।

/// इस हिस्से की हालत — ऐप को यह देखकर ही तय करना चाहिए कि दिखाना है या नहीं।
const bool shubhMuhuratIsReady = false;

/// कौन सा काम।
enum Activity { grihaPravesh, mundan, namkaran, vahan, bhumiPujan, vidyarambh }

/// एक काम के लिए शास्त्रीय नियम — दोनों ग्रंथों का मेल।
class ActivityRule {
  final Activity activity;
  final String name;

  /// मान्य नक्षत्र, 0 से गिनती (अश्विनी = 0)।
  final List<int> nakshatras;

  /// मान्य तिथि, पक्ष के भीतर 1 से 15 (15 = पूर्णिमा/अमावस्या)।
  final List<int> tithis;

  /// मान्य वार, 0 = रविवार।
  final List<int> varas;

  /// मान्य अमांत मास (0 = चैत्र); null = कोई भी।
  final List<int>? masas;

  /// सिर्फ़ उत्तरायण में (निरयन मकर से मिथुन तक सूर्य)।
  final bool uttarayanOnly;

  /// सिर्फ़ शुक्ल पक्ष में।
  final bool shuklaOnly;

  /// कृष्ण पक्ष में सिर्फ़ पंचमी तक (उपनयन वाला नियम)।
  final bool krishnaUptoPanchami;

  /// सोमवार सिर्फ़ शुक्ल पक्ष में (मुहूर्त मार्तण्ड, चूडाकरण)।
  final bool somOnlyShukla;

  /// सूर्य कुम्भ राशि में न हो।
  final bool sunNotKumbha;

  /// पंचक में नहीं।
  final bool excludePanchak;

  /// संक्रांति के दिन नहीं (पर्व)।
  final bool excludeSankranti;

  /// गृह प्रवेश का कुम्भ-चक्र — सूर्य के नक्षत्र से 1–5 और 14–21 वर्जित।
  final bool kumbhChakra;

  /// गृहारम्भ का वृषभ-चक्र — दोनों ग्रंथों की गिनती, दोनों में शुभ हो तभी।
  final bool vrishabhChakra;

  /// गुरु/शुक्र अस्त और उसके आगे-पीछे के बाल्य-वार्धक दिन वर्जित।
  final bool guruShukraAst;

  /// नियम दो ग्रंथों से पक्का हुआ? नहीं तो सूची नहीं बनती।
  final bool pakka;

  /// नियम कहाँ से — व्याख्या और ⓘ के लिए।
  final String strot;

  /// जो ग्रंथ देखते हैं पर ऐप नहीं देखता — व्याख्या में।
  final List<String> appNahiDekhta;

  const ActivityRule({
    required this.activity,
    required this.name,
    required this.nakshatras,
    required this.tithis,
    required this.varas,
    required this.strot,
    this.masas,
    this.uttarayanOnly = false,
    this.shuklaOnly = false,
    this.krishnaUptoPanchami = false,
    this.somOnlyShukla = false,
    this.sunNotKumbha = false,
    this.excludePanchak = false,
    this.excludeSankranti = false,
    this.kumbhChakra = false,
    this.vrishabhChakra = false,
    this.guruShukraAst = false,
    this.pakka = true,
    this.appNahiDekhta = const [],
  });

  /// पुराना नाम — गुरु/शुक्र देखना ज़रूरी है?
  bool get needsGuruShukra => guruShukraAst;
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

  /// गुरु/शुक्र अस्त अब गणना से देखा जाता है — पर छपी सूचियाँ अस्त की तारीख़ों में
  /// कुछ दिन अलग चलती हैं (→ D-119), इसलिए व्याख्या में यह याद दिलाया जाता है।
  bool get guruShukraNotChecked => false;

  /// यह नतीजा अभी ऐप में दिखाने लायक नहीं। देखो फ़ाइल का ऊपरी नोट।
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
// नियम — दोनों ग्रंथों का मेल (पन्ने `docs/18` §४४ में)
// ─────────────────────────────────────────────────────────────

/// नक्षत्रों के नाम से क्रमांक — नियम पढ़ने में आसानी के लिए।
int _nak(String name) {
  final i = nakshatraNames.indexOf(name);
  assert(i >= 0, name);
  return i;
}

List<int> _naks(List<String> names) => [for (final n in names) _nak(n)];

const _lagnaNahi = 'लग्न-शुद्धि (स्थिर/चर लग्न, ग्रहों के भाव)';
const _chandraNahi = 'जन्म-राशि से चंद्र और तारा बल';

final List<ActivityRule> activityRules = [
  // मुहूर्त चिंतामणि, गृहप्रवेश-प्रकरण श्लो.1–6 (पृ. 183–185);
  // मुहूर्त मार्तण्ड, गृह-प्रकरण श्लो.19–21 (पृ. 119–121) और श्लो.6 (पृ. 104–105)
  ActivityRule(
    activity: Activity.grihaPravesh,
    name: 'गृह प्रवेश',
    // चिंतामणि: मृदु + ध्रुव; मार्तण्ड (नया घर): गृहारम्भ के नक्षत्र — दोनों में ये आठ
    nakshatras: _naks([
      'रोहिणी', 'मृगशिरा', 'उत्तरा फाल्गुनी', 'चित्रा', 'अनुराधा',
      'उत्तराषाढ़ा', 'उत्तरा भाद्रपदा', 'रेवती',
    ]),
    // दोनों रिक्ता (4, 9, 14) छोड़ते हैं; चिंतामणि अमावस्या भी
    tithis: [1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15],
    // दोनों रवि और मंगल छोड़ते हैं
    varas: [1, 3, 4, 5, 6],
    // चिंतामणि: ज्येष्ठ, माघ, फाल्गुन, वैशाख; मार्तण्ड में वैशाख-फाल्गुन सीधे,
    // माघ-ज्येष्ठ नारद-मत से
    masas: [1, 2, 10, 11],
    uttarayanOnly: true,
    kumbhChakra: true,
    guruShukraAst: true,
    strot: 'मुहूर्त चिंतामणि (गृहप्रवेश-प्रकरण, श्लोक 1–6) और मुहूर्त मार्तण्ड '
        '(गृह-प्रकरण, श्लोक 19–21) — नया घर (अपूर्व प्रवेश)',
    appNahiDekhta: [
      _lagnaNahi,
      'घर के द्वार की दिशा — उसी से तिथि (पूर्वमुख में पूर्णा, दक्षिण में नन्दा, '
          'पश्चिम में भद्रा, उत्तर में जया) और वाम रवि',
      _chandraNahi,
    ],
  ),

  // चिंतामणि, संस्कार-प्रकरण श्लो.26, 29–30 (पृ. 76–77);
  // मार्तण्ड, संस्कार-प्रकरण श्लो.10–11 (पृ. 19–20)
  ActivityRule(
    activity: Activity.mundan,
    name: 'मुंडन',
    // दोनों में अक्षरशः यही बारह
    nakshatras: _naks([
      'अश्विनी', 'मृगशिरा', 'पुनर्वसु', 'पुष्य', 'हस्त', 'चित्रा',
      'स्वाति', 'ज्येष्ठा', 'श्रवण', 'धनिष्ठा', 'शतभिषा', 'रेवती',
    ]),
    // चिंतामणि: 8, 12, रिक्ता, 1, 6, पर्व छोड़कर; मार्तण्ड रिक्ता छोड़ता है
    tithis: [2, 3, 5, 7, 10, 11, 13],
    varas: [1, 3, 4, 5],
    somOnlyShukla: true,
    // मार्तण्ड: माघ, फाल्गुन, वैशाख, ज्येष्ठ, आषाढ़; चिंतामणि: उत्तरायण, चैत्र नहीं
    masas: [1, 2, 3, 10, 11],
    uttarayanOnly: true,
    guruShukraAst: true,
    strot: 'मुहूर्त चिंतामणि (संस्कार-प्रकरण, श्लोक 26, 29–30) और मुहूर्त मार्तण्ड '
        '(संस्कार-प्रकरण, श्लोक 10–11)',
    appNahiDekhta: [
      'बच्चे की उम्र — तीसरे वर्ष से विषम वर्ष (मार्तण्ड: दूसरा, तीसरा या पाँचवाँ), '
          'या कुल का आचार',
      'माता गर्भवती हो तो (पाँच वर्ष से छोटे बच्चे का मुंडन नहीं)',
      _lagnaNahi,
      _chandraNahi,
    ],
  ),

  // चिंतामणि, संस्कार-प्रकरण श्लो.11 (पृ. 70); मार्तण्ड, संस्कार-प्रकरण श्लो.5 (पृ. 14–15)
  ActivityRule(
    activity: Activity.namkaran,
    name: 'नामकरण',
    // मृदु, ध्रुव, क्षिप्र, चर — दोनों में
    nakshatras: _naks([
      'अश्विनी', 'रोहिणी', 'मृगशिरा', 'पुनर्वसु', 'पुष्य', 'उत्तरा फाल्गुनी',
      'हस्त', 'चित्रा', 'स्वाति', 'अनुराधा', 'उत्तराषाढ़ा', 'श्रवण',
      'धनिष्ठा', 'शतभिषा', 'उत्तरा भाद्रपदा', 'रेवती',
    ]),
    // दोनों: रिक्ता, अष्टमी, पूर्णिमा, अमावस्या नहीं
    tithis: [1, 2, 3, 5, 6, 7, 10, 11, 12, 13],
    // मार्तण्ड: मंगल, शनि नहीं; चिंतामणि: शुभ वार
    varas: [1, 3, 4, 5],
    excludeSankranti: true,
    strot: 'मुहूर्त चिंतामणि (संस्कार-प्रकरण, श्लोक 11) और मुहूर्त मार्तण्ड '
        '(संस्कार-प्रकरण, श्लोक 5)',
    appNahiDekhta: [
      'जन्म से ग्यारहवाँ या बारहवाँ दिन (चिंतामणि); मार्तण्ड में बारहवाँ, सोलहवाँ, '
          'बीसवाँ या बाईसवाँ — या जातकर्म के नक्षत्रों में',
      _lagnaNahi,
    ],
  ),

  // दोनों में वाहन ख़रीदने का अलग मुहूर्त नहीं — चिंतामणि नक्षत्र-प्रकरण श्लो.3
  // (पृ. 32), मार्तण्ड नक्षत्र-प्रकरण श्लो.2–3 (पृ. 7): चर नक्षत्र वाहन-यान के काम के
  ActivityRule(
    activity: Activity.vahan,
    name: 'वाहन ख़रीद',
    nakshatras: _naks(['पुनर्वसु', 'स्वाति', 'श्रवण', 'धनिष्ठा', 'शतभिषा']),
    tithis: [],
    varas: [],
    pakka: false,
    strot: 'दोनों ग्रंथ सिर्फ़ इतना कहते हैं कि चर नक्षत्र (स्वाति, पुनर्वसु, श्रवण, '
        'धनिष्ठा, शतभिषा) वाहन-यान के काम के हैं — वाहन ख़रीदने की तिथि, वार और मास '
        'का अलग नियम दोनों में नहीं मिला',
  ),

  // गृहारम्भ — चिंतामणि, वास्तु-प्रकरण श्लो.13–18 (पृ. 176–178);
  // मार्तण्ड, गृह-प्रकरण श्लो.5–6 (पृ. 104–105)
  ActivityRule(
    activity: Activity.bhumiPujan,
    name: 'भूमि पूजन',
    // दोनों में अक्षरशः यही तेरह
    nakshatras: _naks([
      'रोहिणी', 'मृगशिरा', 'पुष्य', 'उत्तरा फाल्गुनी', 'हस्त', 'चित्रा',
      'स्वाति', 'अनुराधा', 'उत्तराषाढ़ा', 'धनिष्ठा', 'शतभिषा',
      'उत्तरा भाद्रपदा', 'रेवती',
    ]),
    // चिंतामणि: शुक्ल पक्ष; रिक्ता, अमावस्या, प्रतिपदा नहीं; मार्तण्ड: रिक्ता नहीं
    tithis: [2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15],
    shuklaOnly: true,
    // दोनों रवि और मंगल छोड़ते हैं
    varas: [1, 3, 4, 5, 6],
    // दोनों: वैशाख, श्रावण, मार्गशीर्ष, पौष, फाल्गुन
    masas: [1, 4, 8, 9, 11],
    excludePanchak: true,
    vrishabhChakra: true,
    guruShukraAst: true,
    strot: 'मुहूर्त चिंतामणि (वास्तु-प्रकरण, श्लोक 13–18) और मुहूर्त मार्तण्ड '
        '(गृह-प्रकरण, श्लोक 5–6) — गृहारम्भ',
    appNahiDekhta: [
      _lagnaNahi,
      'घर के मुख की दिशा और चंद्र की दिशा',
      _chandraNahi,
    ],
  ),

  // अक्षरारम्भ — चिंतामणि, संस्कार-प्रकरण श्लो.37 (पृ. 79–80);
  // मार्तण्ड, संस्कार-प्रकरण श्लो.13 (पृ. 22–23), समय श्लो.18 → उपनयन श्लो.16 (पृ. 26)
  ActivityRule(
    activity: Activity.vidyarambh,
    name: 'विद्यारंभ',
    // दोनों में ये आठ
    nakshatras: _naks([
      'अश्विनी', 'पुनर्वसु', 'हस्त', 'चित्रा', 'स्वाति', 'अनुराधा',
      'श्रवण', 'रेवती',
    ]),
    // चिंतामणि: 2, 3, 5, 6, 10, 11, 12; मार्तण्ड (उपनयन से): रिक्ता, 7, 13 नहीं
    tithis: [2, 3, 5, 6, 10, 11, 12],
    varas: [1, 3, 4, 5],
    krishnaUptoPanchami: true,
    // मार्तण्ड (उपनयन से): माघ, फाल्गुन, चैत्र, वैशाख, ज्येष्ठ; दोनों: उत्तरायण
    masas: [0, 1, 2, 10, 11],
    uttarayanOnly: true,
    sunNotKumbha: true,
    guruShukraAst: true,
    strot: 'मुहूर्त चिंतामणि (संस्कार-प्रकरण, श्लोक 37 — अक्षरारम्भ) और मुहूर्त '
        'मार्तण्ड (संस्कार-प्रकरण, श्लोक 13, 18, 16)',
    appNahiDekhta: [
      'बच्चे की उम्र — पाँचवाँ वर्ष, उपनयन से पहले',
      _lagnaNahi,
    ],
  ),
];

ActivityRule ruleFor(Activity activity) =>
    activityRules.firstWhere((r) => r.activity == activity);

// ─────────────────────────────────────────────────────────────
// मुख्य काम
// ─────────────────────────────────────────────────────────────

/// किसी काम के लिए उस साल के शुभ दिन। वाहन जैसे कामों में — जिनका नियम दो
/// ग्रंथों से पक्का नहीं — सूची ख़ाली।
List<ShubhDin> shubhDinList(Activity activity, int year, Place place) {
  final rule = ruleFor(activity);
  if (!rule.pakka) return const [];

  final ast = rule.guruShukraAst ? _astKeDin(year, place) : const <_Daur>[];
  final found = <ShubhDin>[];

  var day = DateTime.utc(year, 1, 1);
  Panchang? agla;
  while (day.year == year) {
    final p = agla ??
        computePanchang(day.year, day.month, day.day, place,
            masaSystem: MasaSystem.amanta);
    final next = day.add(const Duration(days: 1));
    agla = computePanchang(next.year, next.month, next.day, place,
        masaSystem: MasaSystem.amanta);
    final din = _check(rule, p, agla, ast, place);
    if (din != null) found.add(din);
    day = next;
  }

  return found;
}

/// गुरु/शुक्र का एक वर्जित दौर — वार्धक के पहले दिन से बाल्य के आख़िरी दिन तक।
class _Daur {
  final Graha graha;
  final DateTime se;
  final DateTime tak;
  const _Daur(this.graha, this.se, this.tak);

  bool chhoota(DateTime din) => !din.isBefore(se) && !din.isAfter(tak);
}

/// दोनों ग्रंथों का बाल्य-वार्धक: चिंतामणि (श्लो.27) गुरु 15-15, शुक्र 3/10 और
/// 15/5; मार्तण्ड (श्लो.6) सात-सात। जो लंबा, वही — तभी दिन दोनों में मान्य।
List<_Daur> _astKeDin(int year, Place place) {
  final se = DateTime.utc(year, 1, 1);
  final tak = DateTime.utc(year, 12, 31);
  return [
    for (final g in [Graha.guru, Graha.shukra])
      for (final a in grahaAstKaal(g, se, tak, place))
        _Daur(
          g,
          a.astDin.subtract(Duration(days: a.vardhakDin < 7 ? 7 : a.vardhakDin)),
          a.udayDin.add(Duration(days: a.balyaDin < 7 ? 7 : a.balyaDin)),
        ),
  ];
}

/// 27 नक्षत्रों में, सूर्य के नक्षत्र को 1 गिनकर [nak] कौन-सा।
int _suryaSe(int suryaNak, int nak) => (nak - suryaNak + 27) % 27 + 1;

/// 28 नक्षत्रों (अभिजित् सहित) वाली गिनती — चिंतामणि का वृषभ-चक्र इसी में है।
/// अभिजित्: उत्तराषाढ़ा के अंतिम चरण से श्रवण के पंद्रहवें भाग तक।
int _nak28(double longitude) {
  const abhijitShuru = 276.0 + 40.0 / 60.0;
  const abhijitAnt = 280.0 + 53.0 / 60.0 + 20.0 / 3600.0;
  if (longitude >= abhijitShuru && longitude < abhijitAnt) return 21;
  final n27 = (longitude / (360.0 / 27.0)).floor() % 27;
  return n27 <= 20 ? n27 : n27 + 1;
}

/// क्या यह दिन इस काम के लिए शुभ है? न हो तो null।
///
/// ⚠️ **सूर्योदय की तिथि/नक्षत्र देखना काफ़ी नहीं।** मुहूर्त एक *खिड़की* है —
/// जहाँ मान्य तिथि और मान्य नक्षत्र एक साथ चल रहे हों।
ShubhDin? _check(
    ActivityRule rule, Panchang p, Panchang agla, List<_Daur> ast, Place place) {
  final date = DateTime.utc(p.date.year, p.date.month, p.date.day);

  // ── अधिक मास में कोई मांगलिक काम नहीं ──
  if (p.isAdhikaMasa) return null;

  // ── मास, अयन, सूर्य की राशि ──
  if (rule.masas != null && !rule.masas!.contains(p.masa)) return null;
  if (rule.uttarayanOnly && p.ayana != 0) return null;
  if (rule.sunNotKumbha && p.sunRashi == 10) return null;

  // ── पक्ष ──
  if (rule.shuklaOnly && p.paksha != 0) return null;

  // ── वार पूरे दिन का होता है ──
  if (!rule.varas.contains(p.vara)) return null;
  if (rule.somOnlyShukla && p.vara == 1 && p.paksha != 0) return null;

  // ── संक्रांति, पंचक ──
  if (rule.excludeSankranti && p.sunRashi != agla.sunRashi) return null;
  if (rule.excludePanchak && p.isPanchak) return null;

  // ── गुरु/शुक्र अस्त, बाल्य, वार्धक ──
  for (final d in ast) {
    if (d.chhoota(date)) return null;
  }

  if (p.sunrise == null || p.sunset == null) return null;

  // ── मान्य तिथि और मान्य नक्षत्र की खिड़कियाँ ──
  final tithiWindows = <({DateTime start, DateTime end, String name})>[];
  for (final anga in p.tithis) {
    final inPaksha = anga.index < 15 ? anga.index + 1 : anga.index - 14;
    if (!rule.tithis.contains(inPaksha)) continue;
    if (rule.shuklaOnly && anga.index >= 15) continue;
    if (rule.krishnaUptoPanchami && anga.index >= 15 && inPaksha > 5) continue;
    if (anga.endsAt == null) continue;
    tithiWindows.add((
      start: anga.startsAt ?? p.sunrise!,
      end: anga.endsAt!,
      name: anga.name
    ));
  }
  if (tithiWindows.isEmpty) return null;

  // सूर्य का नक्षत्र (चक्रों के लिए) — सूर्योदय पर
  final riseJd = sunriseJd(p.date.year, p.date.month, p.date.day, place);
  final suryaLon = sunSiderealAt(riseJd);
  final suryaNak = (suryaLon / (360.0 / 27.0)).floor() % 27;
  final suryaNak28 = _nak28(suryaLon);

  final nakshatraWindows = <({DateTime start, DateTime end, String name})>[];
  for (final anga in p.nakshatras) {
    if (!rule.nakshatras.contains(anga.index)) continue;
    if (anga.endsAt == null) continue;

    // गृह प्रवेश — कुम्भ-चक्र (दोनों ग्रंथ): सूर्य-नक्षत्र से 1–5, 14–21 वर्जित
    if (rule.kumbhChakra) {
      final k = _suryaSe(suryaNak, anga.index);
      if (k <= 5 || (k >= 14 && k <= 21)) continue;
    }

    // भूमि पूजन — वृषभ-चक्र, दोनों गिनतियों में शुभ हो तभी
    if (rule.vrishabhChakra) {
      // मार्तण्ड: 4–7, 15–18, 23–27 वर्जित
      final m = _suryaSe(suryaNak, anga.index);
      if ((m >= 4 && m <= 7) || (m >= 15 && m <= 18) || m >= 23) continue;
      // चिंतामणि (28 में): पहले 7 और अंतिम 10 वर्जित
      final c = (_nak28Index(anga.index) - suryaNak28 + 28) % 28 + 1;
      if (c <= 7 || c >= 19) continue;
    }

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

      // दिन के उजाले तक सीमित — दोनों ग्रंथ रात में मना करते हैं
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
  final windows = choghadiya(p.date.year, p.date.month, p.date.day, place)
      .where((s) =>
          s.isDay &&
          s.auspicious == true &&
          s.start.isBefore(muhurtaEnd) &&
          muhurtaStart.isBefore(s.end))
      .toList();

  return ShubhDin(
    rule: rule,
    date: date,
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
    explanation:
        _explain(rule, p, bestNakshatra, bestTithi, muhurtaStart, muhurtaEnd),
  );
}

/// 27 वाले क्रमांक को 28 वाले में — अभिजित् (21) के बाद वाले एक आगे।
int _nak28Index(int n27) => n27 <= 20 ? n27 : n27 + 1;

String _hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _explain(ActivityRule rule, Panchang p, String nakshatra, String tithi,
    DateTime start, DateTime end) {
  final lines = <String>[
    '${p.masaFullName} (अमांत) ${p.pakshaName} $tithi · ${p.varaName}',
    'नक्षत्र $nakshatra',
    'मुहूर्त ${_hm(start)} से ${_hm(end)} तक — इसी टुकड़े में तिथि, '
        'नक्षत्र और वार तीनों ${rule.name} के लिए मान्य हैं',
    'नियम: ${rule.strot} — जो दिन दोनों में मान्य हो',
  ];
  if (rule.guruShukraAst) {
    lines.add('गुरु-शुक्र के अस्त और उसके आगे-पीछे के दिन छोड़े गए हैं — अस्त की '
        'तारीख़ें छपे पंचांगों में कुछ दिन आगे-पीछे मिलती हैं, अपने पंचांग से मिला लें');
  }
  if (rule.appNahiDekhta.isNotEmpty) {
    lines.add('ऐप यह नहीं देखता — ${rule.appNahiDekhta.join('; ')}; '
        'ये अपने पुरोहित से देखें');
  }

  lines.add('दृक् गणित · लाहिड़ी अयनांश');
  return lines.join('\n');
}
