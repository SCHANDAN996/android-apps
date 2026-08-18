import 'package:flutter/material.dart';

import 'palan_i18n.dart';

/// दो भाषाओं वाला एक वाक्य। बाक़ी 8 भाषाएँ ऐप के नियम के अनुसार
/// हिंदी पर fallback करती हैं (AppLocalizations.isHindiLike)।
typedef L = ({String hi, String en});

/// चारे की तालिका की एक पंक्ति — "किस उम्र में, क्या, कितना"
typedef FeedRow = ({L stage, L feed, L qty});

/// टीके की एक पंक्ति — "कब, कौन सा टीका"
typedef VaccRow = ({L when, L what});

/// लागत/आमदनी की एक पंक्ति।
///
/// `oneTime: true` = शुरू में एक ही बार लगने वाला ख़र्च (शेड, पिंजरा, जानवर
/// ख़रीदना, बाड़)। `false` = हर चक्र/साल दोबारा लगने वाला (दाना, दवा, चूज़े)।
///
/// ⚠️ यह फ़र्क़ बहुत ज़रूरी है। पहले दोनों एक साथ जुड़ जाते थे और आमदनी सिर्फ़
/// एक चक्र की होती थी — इसलिए बकरी, ब्रॉयलर, भेड़, बटेर और एमू की गाइड में
/// ऐप बड़े लाल अक्षरों में **घाटा** दिखाता था, जबकि असल में मुनाफ़ा है।
typedef MoneyRow = ({L item, String value, bool oneTime});

/// आमदनी की पंक्ति (हमेशा एक चक्र/साल की)
MoneyRow money(L item, String value, {bool oneTime = false}) =>
    (item: item, value: value, oneTime: oneTime);

/// एक पालन (जानवर या पक्षी) की पूरी जानकारी।
///
/// सब कुछ ऐप के अंदर ही है — कोई इंटरनेट नहीं चाहिए।
class PalanGuide {
  final String id;
  final String emoji;
  final L name;
  final L tagline; // एक पंक्ति में — "कम जगह, जल्दी मुनाफ़ा"
  final Color color;

  /// 1. परिचय + नस्लें
  final L intro;
  final List<L> breeds;

  /// 2. आवास / शेड
  final List<L> housing;

  /// 3. चारा-दाना तालिका
  final List<FeedRow> feed;
  final List<L> feedNotes;

  /// 4. उत्पादन बढ़ाने के उपाय
  final List<L> production;

  /// 5. टीकाकरण + बीमारियाँ
  final List<VaccRow> vaccines;
  final List<L> diseases;

  /// 6. लागत-मुनाफ़ा (एक छोटी unit पर)
  final L economicsUnit;
  final List<MoneyRow> costs;
  final List<MoneyRow> income;
  final L economicsNote;

  /// एक चक्र में कितने महीने लगते हैं — इसी से "साल में कितनी बार" और
  /// "लागत कब निकलेगी" निकलता है।
  ///
  /// ब्रॉयलर 1.5 (45 दिन), बटेर 1.2 (5 हफ़्ते), बकरी 12 (साल भर),
  /// एमू 24 (दो साल)।
  final double cycleMonths;

  /// आँकड़े किस तारीख़ के हैं — दाम पुराने पड़ने पर किसान को पता चले
  final String priceAsOf;

  /// 7. बेचने के रास्ते
  final List<L> selling;

  /// 8. ❌ आम ग़लतियाँ — नया पालक वही 4-5 ग़लतियाँ बार-बार करता है
  final List<L> mistakes;

  /// 9. कहाँ से ख़रीदें — अच्छी नस्ल कहाँ मिलेगी। ठगी यहीं होती है।
  final List<L> whereToBuy;

  /// 10. इस पालन पर मिलने वाली ख़ास सरकारी मदद।
  /// सबको मिलने वाली योजनाएँ (KCC, बीमा) अलग से `kCommonSchemes` में हैं।
  final List<L> schemes;

  /// टीके का रिमाइंडर लगाने के लिए — "बच्चे आने के कितने दिन बाद, कौन सा टीका"।
  /// ख़ाली है तो उस पालन में रिमाइंडर का बटन नहीं दिखता।
  final List<({int day, L what})> reminderPlan;

  const PalanGuide({
    required this.id,
    required this.emoji,
    required this.name,
    required this.tagline,
    required this.color,
    required this.intro,
    required this.breeds,
    required this.housing,
    required this.feed,
    required this.production,
    required this.vaccines,
    required this.diseases,
    required this.economicsUnit,
    required this.costs,
    required this.income,
    required this.economicsNote,
    required this.selling,
    this.feedNotes = const [],
    this.reminderPlan = const [],
    this.cycleMonths = 12,
    this.priceAsOf = 'अगस्त 2026',
    this.mistakes = const [],
    this.whereToBuy = const [],
    this.schemes = const [],
  });

  // ── लागत-मुनाफ़ा का सही हिसाब ────────────────────────────────────

  static int _num(String v) =>
      int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  /// शुरू में एक ही बार लगने वाला ख़र्च (शेड, पिंजरा, जानवर, बाड़)
  int get setupCost =>
      costs.where((c) => c.oneTime).fold(0, (s, c) => s + _num(c.value));

  /// हर चक्र दोबारा लगने वाला ख़र्च (दाना, दवा, चूज़े)
  int get cycleCost =>
      costs.where((c) => !c.oneTime).fold(0, (s, c) => s + _num(c.value));

  /// एक चक्र की आमदनी
  int get cycleIncome => income.fold(0, (s, c) => s + _num(c.value));

  /// एक चक्र का असली मुनाफ़ा — एक बार वाला ख़र्च इसमें नहीं
  int get cycleProfit => cycleIncome - cycleCost;

  /// साल में कितने चक्र
  double get cyclesPerYear => cycleMonths <= 0 ? 1 : 12 / cycleMonths;

  /// साल भर का मुनाफ़ा
  int get yearlyProfit => (cycleProfit * cyclesPerYear).round();

  /// एक बार का ख़र्च निकलने में कितने महीने
  ///
  /// `null` = मुनाफ़ा शून्य या घाटा है, इसलिए लागत कभी नहीं निकलेगी —
  /// ऐसा हो तो UI साफ़ चेतावनी दिखाए, संख्या नहीं।
  double? get paybackMonths {
    if (cycleProfit <= 0) return null;
    return setupCost / cycleProfit * cycleMonths;
  }
}

/// चुनी भाषा के हिसाब से पाठ।
///
/// [isHi] = देवनागरी पढ़ने वाला (हिंदी, भोजपुरी, मराठी)।
/// [lang] = असली भाषा-कोड ('ta', 'te'…)। दिया हो तो पहले
/// [kPalanI18n] की परत देखी जाती है — जिस वाक्य का अनुवाद वहाँ मिल गया,
/// वह उसी भाषा में दिखेगा।
///
/// अनुवाद न मिले तो पहले जैसा ही चलता है (देवनागरी वालों को हिंदी, बाक़ी
/// को अंग्रेज़ी) — इसलिए अनुवाद टुकड़ों में जोड़े जा सकते हैं और बीच में
/// कुछ टूटता नहीं।
String tx(L v, bool isHi, [String lang = '']) {
  if (lang.isNotEmpty) {
    final t = kPalanI18n[v.hi]?[lang];
    if (t != null) return t;
  }
  return isHi ? v.hi : v.en;
}
