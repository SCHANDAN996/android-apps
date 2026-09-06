/// **स्वैच्छिक दक्षिणा — ऐप की इकलौती कमाई।** (→ D-053)
///
/// ## सबसे ज़रूरी नियम, जो कभी नहीं टूटना चाहिए
///
/// **देने वाले को कुछ अतिरिक्त नहीं मिलता।** न कोई पूजा, न बैज, न theme,
/// न ज़्यादा रिमाइंडर, न कुछ और। सिर्फ़ "धन्यवाद", और छह महीने की चुप्पी।
///
/// यह विनम्रता नहीं, **Google Play की शर्त** है: भुगतान से किसी digital
/// चीज़ का रास्ता खुलते ही वह "दक्षिणा" नहीं रहती, एक साधारण in-app
/// purchase बन जाती है। इसीलिए इस फ़ाइल में कहीं भी कोई `unlock`, `isPro`
/// या `premium` जैसा झंडा नहीं है — और न कभी जोड़ना।
///
/// पूरी योजना और हर शब्द → `docs/20_KAMAI_YOJANA.md`
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// एक राशि। दाम Play Console में तय होते हैं, इसलिए "अपनी राशि" वाला
/// खाना बन ही नहीं सकता — छह ही रहेंगी।
///
/// ⚠️ [id] ठीक वही रहे जो Play Console में बना है। बदलने पर पुरानी
/// ख़रीदें अनाथ हो जाएँगी।
class DakshinaRaashi {
  final String id;
  final int rupaye;

  const DakshinaRaashi(this.id, this.rupaye);

  /// स्क्रीन पर दिखने वाला रूप। ₹21 · ₹51 · ₹101 …
  String get label => '₹$rupaye';
}

/// छह तय राशियाँ, छोटी से बड़ी।
///
/// ₹21 शगुन का अंक है और जान-बूझकर सबसे पहले है — **मना करने लायक
/// छोटा** पहला क़दम सबसे ज़्यादा लोगों से मिलता है। ₹1100 "अपनी राशि"
/// की जगह है, ऊपर वाला सिरा।
///
/// ⛔ इनमें से किसी पर **"सबसे लोकप्रिय"** मत लिखना, और कोई भी राशि
/// **पहले से चुनी हुई मत रखना** — यूज़र ने चुना ही नहीं होता।
const dakshinaRaashiyan = <DakshinaRaashi>[
  DakshinaRaashi('dakshina_21', 21),
  DakshinaRaashi('dakshina_51', 51),
  DakshinaRaashi('dakshina_101', 101),
  DakshinaRaashi('dakshina_251', 251),
  DakshinaRaashi('dakshina_501', 501),
  DakshinaRaashi('dakshina_1100', 1100),
];

/// दक्षिणा देने की कोशिश का नतीजा।
enum DakshinaNatija {
  /// मिल गई — धन्यवाद दिखाओ, और छह महीने चुप रहो।
  mili,

  /// यूज़र ने बीच में छोड़ दिया। **कुछ मत कहो** — यह पूरी तरह उसका हक़ है।
  radd,

  /// Play का दरवाज़ा खुला ही नहीं (नेटवर्क नहीं, या दुकान उपलब्ध नहीं)।
  upalabdhNahi,

  /// कुछ टूटा। शांत भाषा में बताओ, और दोबारा कोशिश करने दो।
  truti,
}

/// जहाँ से पैसा आता है। Play Billing इसका एक रूप है।
///
/// यह परत सिर्फ़ इसलिए है कि **जाँचें असली Play को छुए बिना चल सकें**।
abstract class DakshinaDwar {
  const DakshinaDwar();

  /// दुकान खुली है या नहीं।
  Future<bool> khulaHai();

  /// एक राशि की दक्षिणा। लौटने तक यूज़र Play की अपनी शीट में रहता है।
  Future<DakshinaNatija> dena(DakshinaRaashi raashi);

  /// ऐप खुलते ही पहरा — बीच में अटकी ख़रीद बाद में पूरी हो तो वह भी
  /// दर्ज हो जाए (UPI में यह आम है: पैसा कुछ मिनट बाद कटता है)।
  void pehraShuru({required void Function() jabMile}) {}

  /// पहरा बंद।
  Future<void> pehraBand() async {}
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

  /// पैसा किस रास्ते आए। `main.dart` में [PlayBillingDwar] लगता है;
  /// जाँचों में नक़ली द्वार, ताकि असली Play कभी न छुए।
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

  /// पूजा पूरी होने वाले पन्ने पर डिब्बा दिखे या नहीं।
  bool dikhega(DateTime ab) {
    if (_diyaKab != null && ab.difference(_diyaKab!) < diyeKaAaram) {
      return false;
    }
    if (_dikhiGinti >= kitniBaarDikhe &&
        _dikhiKab != null &&
        ab.difference(_dikhiKab!) < chhodneKaAaram) {
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

  /// ऐप खुलते ही एक बार — द्वार लगाओ और पहरा बिठाओ।
  void shuru(DakshinaDwar naya) {
    dwar = naya;
    naya.pehraShuru(jabMile: () => mili(DateTime.now()));
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

/// Play Billing वाला द्वार। **असली Play को यही छूता है।**
///
/// ⚠️ इसे सिर्फ़ `main.dart` में बनाना। इसका बनना ही
/// `InAppPurchase.instance` को छू लेता है, जो जाँचों में नहीं चलता।
///
/// ## तीन बातें जो यहाँ सँभालनी पड़ीं
/// 1. **हर ख़रीद `completePurchase` माँगती है** — तीन दिन में न करो तो
///    Google पैसा अपने आप वापस कर देता है।
/// 2. **UPI की ख़रीद बाद में पूरी होती है** — इसीलिए ऐप खुलते ही पहरा
///    ([pehraShuru]) बैठता है, सिर्फ़ बटन दबने पर नहीं।
/// 3. **कोई timeout नहीं** — यूज़र Play की शीट में जितना चाहे लगाए।
class PlayBillingDwar extends DakshinaDwar {
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _pehra;
  final Map<String, Completer<DakshinaNatija>> _intezaar = {};
  void Function()? _jabMile;

  PlayBillingDwar({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  @override
  void pehraShuru({required void Function() jabMile}) {
    _jabMile = jabMile;
    _pehra ??= _iap.purchaseStream.listen(
      _aayi,
      // दुकान का टूटना यूज़र की पूजा नहीं रोकेगा। ऐप बाक़ी सब वैसे ही
      // चलता रहेगा — दक्षिणा के सिवा कुछ इस पर टिका ही नहीं है।
      onError: (Object _) {},
    );
  }

  @override
  Future<void> pehraBand() async {
    await _pehra?.cancel();
    _pehra = null;
  }

  Future<void> _aayi(List<PurchaseDetails> kharidein) async {
    for (final kharid in kharidein) {
      // अभी चल रही है (UPI में यह मिनटों तक रह सकती है) — इंतज़ार।
      if (kharid.status == PurchaseStatus.pending) continue;

      if (kharid.pendingCompletePurchase) {
        await _iap.completePurchase(kharid);
      }

      final DakshinaNatija natija;
      if (kharid.status == PurchaseStatus.purchased ||
          kharid.status == PurchaseStatus.restored) {
        natija = DakshinaNatija.mili;
        _jabMile?.call();
      } else if (kharid.status == PurchaseStatus.canceled) {
        natija = DakshinaNatija.radd;
      } else {
        natija = DakshinaNatija.truti;
      }

      final koiIntezaarMein = _intezaar.remove(kharid.productID);
      if (koiIntezaarMein != null && !koiIntezaarMein.isCompleted) {
        koiIntezaarMein.complete(natija);
      }
    }
  }

  @override
  Future<bool> khulaHai() => _iap.isAvailable();

  @override
  Future<DakshinaNatija> dena(DakshinaRaashi raashi) async {
    if (!await _iap.isAvailable()) return DakshinaNatija.upalabdhNahi;

    final jawab = await _iap.queryProductDetails({raashi.id});
    final mile =
        jawab.productDetails.where((product) => product.id == raashi.id);
    if (mile.isEmpty) return DakshinaNatija.upalabdhNahi;
    final saamaan = mile.first;

    final intezaar = Completer<DakshinaNatija>();
    _intezaar[raashi.id] = intezaar;
    try {
      final chala = await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: saamaan),
      );
      if (!chala) {
        _intezaar.remove(raashi.id);
        return DakshinaNatija.truti;
      }
      return await intezaar.future;
    } catch (_) {
      _intezaar.remove(raashi.id);
      return DakshinaNatija.truti;
    }
  }
}
