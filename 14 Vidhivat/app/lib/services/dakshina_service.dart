/// **स्वैच्छिक दक्षिणा — ऐप की इकलौती कमाई।** (→ D-053)
///
/// ## सबसे ज़रूरी नियम, जो कभी नहीं टूटना चाहिए
///
/// **देने वाले को कुछ अतिरिक्त नहीं मिलता।** न कोई पूजा, न बैज, न theme,
/// न ज़्यादा रिमाइंडर, न कुछ और। सिर्फ़ "धन्यवाद", और छह महीने की चुप्पी।
///
/// यह विनम्रता नहीं, **Google Play की शर्त** है: भुगतान से किसी digital
/// चीज़ का रास्ता खुलते ही वह "दक्षिणा" नहीं रहती, एक साधारण in-app
/// purchase बन जाती है — और तब Play Billing अनिवार्य हो जाती।
///
/// ## भुगतान अब PayU से (→ D-090)
///
/// Play की नीति कहती है: tip का 100% पाने वाले को जाए और बदले में कुछ न
/// मिले, तो वह peer-to-peer भुगतान है और Play Billing ज़रूरी नहीं। इसी
/// छूट पर यह चलता है — इसलिए ऊपर वाला नियम अब **दोगुना** ज़रूरी है। इसीलिए इस फ़ाइल में कहीं भी कोई `unlock`, `isPro`
/// या `premium` जैसा झंडा नहीं है — और न कभी जोड़ना।
///
/// पूरी योजना और हर शब्द → `docs/20_KAMAI_YOJANA.md`
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// एक सुझाई हुई राशि। PayU के पन्ने पर आदमी राशि ख़ुद भरता है; यहाँ
/// चुनी राशि वहाँ भरने का सुझाव है।
///
/// [id] अब सिर्फ़ पहचान है (पहले Play Console के product की id थी)।
class DakshinaRaashi {
  final String id;
  final int rupaye;

  const DakshinaRaashi(this.id, this.rupaye);

  /// स्क्रीन पर दिखने वाला रूप। ₹21 · ₹51 · ₹101 …
  String get label => '₹$rupaye';
}

/// सात तय राशियाँ, छोटी से बड़ी।
///
/// ➕ **₹11 बाद में जोड़ा गया** (6 सितम्बर 2026)। पहले छह थीं और
/// सबसे छोटी ₹21। वजह वही है जो ₹21 को पहले रखने की थी — **मना
/// करने लायक़ छोटा पहला क़दम सबसे ज़्यादा लोगों से मिलता है।** ₹11
/// भी शगुन का अंक है, और Play की भारत वाली सबसे कम क़ीमत (₹10) से
/// ऊपर भी है।
///
/// ₹1100 "अपनी राशि" की जगह है, ऊपर वाला सिरा।
///
/// ⛔ इनमें से किसी पर भी कोई ठप्पा मत लगाना, और कोई भी राशि
/// **पहले से चुनी हुई मत रखना** — यूज़र ने चुना ही नहीं होता।
///
const dakshinaRaashiyan = <DakshinaRaashi>[
  DakshinaRaashi('dakshina_11', 11),
  DakshinaRaashi('dakshina_21', 21),
  DakshinaRaashi('dakshina_51', 51),
  DakshinaRaashi('dakshina_101', 101),
  DakshinaRaashi('dakshina_251', 251),
  DakshinaRaashi('dakshina_501', 501),
  DakshinaRaashi('dakshina_1100', 1100),
];

/// पहले से चुनी हुई राशि (→ D-063)।
///
/// ⚠ **यह D-053 का पलटा हुआ फ़ैसला है।** पहले लिखा था "कोई भी
/// राशि पहले से चुनी हुई मत रखना" — डेवलपर ने 9 सितम्बर 2026
/// को जोख़िम जानते हुए यह बदलवाया।
///
/// जो रक्षा बची हुई है: **बटन एक बार दबाना फिर भी पड़ता है**,
/// और उसके बाद PayU का पन्ना खुलता है, जहाँ आदमी ख़ुद भरता और चुकाता
/// है। पैसा अपने आप कभी नहीं कटता — और यह बात कभी नहीं बदलनी चाहिए।
DakshinaRaashi get pehleSeChuniRaashi =>
    dakshinaRaashiyan.firstWhere((r) => r.rupaye == 51);

/// दक्षिणा देने की कोशिश का नतीजा।
enum DakshinaNatija {
  /// मिल गई — धन्यवाद दिखाओ, और छह महीने चुप रहो।
  mili,

  /// यूज़र ने बीच में छोड़ दिया। **कुछ मत कहो** — यह पूरी तरह उसका हक़ है।
  radd,

  /// भुगतान का पन्ना खुला ही नहीं (कोई browser/UPI app नहीं मिला)।
  upalabdhNahi,

  /// PayU का पन्ना बाहर खुल गया। **ऐप को पता नहीं चलता कि पैसा गया या
  /// नहीं** — इसलिए लौटने पर आदमी से ही पूछा जाता है, अपने आप कुछ दर्ज
  /// नहीं होता (→ D-090)।
  baharKhula,

  /// कुछ टूटा। शांत भाषा में बताओ, और दोबारा कोशिश करने दो।
  truti,
}

/// जहाँ से पैसा आता है। PayU का पन्ना इसका एक रूप है ([PayuDwar])।
///
/// यह परत सिर्फ़ इसलिए है कि **जाँचें असली पन्ना खोले बिना चल सकें**।
abstract class DakshinaDwar {
  const DakshinaDwar();

  /// दुकान खुली है या नहीं।
  Future<bool> khulaHai();

  /// एक राशि की दक्षिणा।
  Future<DakshinaNatija> dena(DakshinaRaashi raashi);
}

/// दक्षिणा की बही — किसने कब दी, और डिब्बा कब दिखे।
///
/// ## घड़ी का नियम (→ `docs/20_KAMAI_YOJANA.md` §5)
/// ```
/// दिखेगा      → हर मार्गदर्शिका पूरी होने पर
/// नहीं दिखेगा → दे चुके हैं          → छह महीने तक बिलकुल नहीं
///             → तीन बार दिख चुका है  → तीस दिन तक नहीं
/// ```
/// तीस दिन बीतते ही गिनती फिर शून्य से शुरू होती है।
class DakshinaBahi extends ChangeNotifier {
  static const _kDiyaKab = 'dakshinaDiyaKab.v1';
  static const _kDikhiGinti = 'dakshinaDikhiGinti.v1';
  static const _kDikhiKab = 'dakshinaDikhiKab.v1';

  /// दे चुके यूज़र से दोबारा कब पूछें। छह महीने — यानी साल में दो बार से
  /// ज़्यादा कभी नहीं।
  static const diyeKaAaram = Duration(days: 182);

  /// बिना दिए इतनी बार दिख चुका, तो कुछ दिन चुप।
  static const kitniBaarDikhe = 3;
  static const chhodneKaAaram = Duration(days: 30);

  SharedPreferences? _prefs;
  DateTime? _diyaKab;
  int _dikhiGinti = 0;
  DateTime? _dikhiKab;

  /// पैसा किस रास्ते आए। `main.dart` में [PayuDwar] लगता है;
  /// जाँचों में नक़ली द्वार, ताकि असली पन्ना कभी न खुले।
  DakshinaDwar? dwar;

  /// यूज़र कभी दक्षिणा दे चुका है?
  ///
  /// ⚠️ यह **सिर्फ़ "फिर मत पूछो"** के लिए है। इससे ऐप में कुछ खुलता
  /// नहीं, और कभी नहीं खुलेगा (→ D-053)।
  bool get kabhiDiThi => _diyaKab != null;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _diyaKab = _samay(_prefs!.getInt(_kDiyaKab));
    _dikhiGinti = _prefs!.getInt(_kDikhiGinti) ?? 0;
    _dikhiKab = _samay(_prefs!.getInt(_kDikhiKab));
  }

  /// पूजा पूरी होने वाले पन्ने पर **पूरी माँग** वाला डिब्बा दिखे या नहीं।
  /// `false` पर भी पन्ने पर दक्षिणा का हिस्सा रहता है — छोटा धन्यवाद-डिब्बा,
  /// फिर देने के रास्ते के साथ (→ D-131)।
  ///
  /// ── यह नियम 9 सितम्बर 2026 को नरम हुआ (→ D-063) ──────
  ///
  /// पहले दो आराम थे — दे चुके हैं तो छह महीने, और **बिना दिए
  /// तीन बार दिख जाए तो तीस दिन**। फ़ोन पर दिखा कि बहुत पूजाओं
  /// के बाद डिब्बा गायब हो जाता है, और डेवलपर ने दूसरा आराम
  /// हटाने को कहा।
  ///
  /// ⚠ **पहला आराम जान-बूझकर बचा हुआ है।** जो दे चुका है, उससे
  /// अगले दिन दोबारा माँगना पीछा करना हो जाता है — वो कभी नहीं।
  bool dikhega(DateTime ab) {
    if (_diyaKab != null && ab.difference(_diyaKab!) < diyeKaAaram) {
      return false;
    }
    return true;
  }

  /// डिब्बा दिखा दिया गया — गिनती बढ़ाओ।
  ///
  /// ⚠️ "छोड़ना" अलग से नहीं गिना जाता। इसकी दो वजहें हैं: ऐप को यह
  /// पता ही नहीं चलता कि यूज़र ने *मना* किया या बस आगे बढ़ गया, और
  /// पूछना ही वो चीज़ है जिसकी हद बाँधनी है — मना करना नहीं।
  Future<void> dikhaayiGayi(DateTime ab) async {
    final aaramPuraHua = _dikhiGinti >= kitniBaarDikhe &&
        (_dikhiKab == null || ab.difference(_dikhiKab!) >= chhodneKaAaram);
    _dikhiGinti = (aaramPuraHua ? 0 : _dikhiGinti) + 1;
    _dikhiKab = ab;
    await _prefs?.setInt(_kDikhiGinti, _dikhiGinti);
    await _prefs?.setInt(_kDikhiKab, ab.millisecondsSinceEpoch);
  }

  /// दक्षिणा मिल गई। अब छह महीने चुप।
  Future<void> mili(DateTime ab) async {
    _diyaKab = ab;
    _dikhiGinti = 0;
    _dikhiKab = null;
    await _prefs?.setInt(_kDiyaKab, ab.millisecondsSinceEpoch);
    await _prefs?.setInt(_kDikhiGinti, 0);
    await _prefs?.remove(_kDikhiKab);
    notifyListeners();
  }

  /// ऐप खुलते ही एक बार — द्वार लगाओ।
  void shuru(DakshinaDwar naya) {
    dwar = naya;
  }

  /// एक राशि की दक्षिणा दो।
  Future<DakshinaNatija> dena(DakshinaRaashi raashi) async {
    final khula = dwar;
    if (khula == null) return DakshinaNatija.upalabdhNahi;
    final natija = await khula.dena(raashi);
    if (natija == DakshinaNatija.mili) await mili(DateTime.now());
    return natija;
  }

  static DateTime? _samay(int? millis) =>
      millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
}

/// पूरे ऐप की एक ही बही — वैसे ही जैसे `settings`।
final dakshina = DakshinaBahi();

/// PayU का "payment handle" — दक्षिणा का पन्ना। **डेवलपर का अपना link।**
///
/// PayU Dashboard → Business summary → Payment Handle → copy link।
/// यह पन्ना PayU का है: राशि, UPI/कार्ड, सब वहीं भरा जाता है।
const String payuDakshinaLink = 'https://u.payu.in/GIebkTbsw8X7';

/// PayU वाला द्वार — link बाहर (browser या UPI app में) खोलता है।
///
/// ## ऐप को नतीजा क्यों पता नहीं चलता
/// बिना सर्वर के PayU से "पैसा आया" की पुष्टि का कोई रास्ता नहीं, और
/// सर्वर हम बनाते नहीं (`CLAUDE.md`)। इसलिए यह सिर्फ़
/// [DakshinaNatija.baharKhula] लौटाता है — आगे आदमी ख़ुद बताता है।
class PayuDwar extends DakshinaDwar {
  final String link;
  final Future<bool> Function(Uri uri) _kholo;

  PayuDwar({
    this.link = payuDakshinaLink,
    Future<bool> Function(Uri uri)? kholo,
  }) : _kholo = kholo ??
            ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication));

  @override
  Future<bool> khulaHai() async => link.startsWith('https://');

  @override
  Future<DakshinaNatija> dena(DakshinaRaashi raashi) async {
    if (!await khulaHai()) return DakshinaNatija.upalabdhNahi;
    try {
      final khula = await _kholo(Uri.parse(link));
      return khula ? DakshinaNatija.baharKhula : DakshinaNatija.upalabdhNahi;
    } catch (_) {
      return DakshinaNatija.upalabdhNahi;
    }
  }
}
