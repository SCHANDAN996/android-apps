/// **कौन से दिन टालने हैं** — मुहूर्त का वो हिस्सा जो ऐप सचमुच जानता है।
///
/// ## यह क्यों बना, और यह मुहूर्त क्यों नहीं है
///
/// D-019 में शुभ मुहूर्त का इंजन बनाकर **रोक दिया गया था** — Drik की 37
/// तारीख़ों में से 26 मिलीं, 33 फ़ालतू निकलीं। दो वजहें थीं: गुरु/शुक्र
/// के अस्त की गणना नहीं हो सकती (इंजन में सिर्फ़ सूर्य और चंद्र हैं),
/// और नियम शास्त्र से नहीं, Drik की सूची उलटकर निकाले गए थे।
///
/// **पर उस पूरे सवाल का एक हिस्सा ऐसा है जो पहले से पक्का है।**
///
/// अधिक मास, भद्रा, पंचक, गंडमूल और पितृ पक्ष — ये पाँचों पंचांग से
/// सीधे निकलते हैं, इनमें कोई ग्रह नहीं चाहिए, और `panchang.dart` इन्हें
/// पहले से निकालता है और **Drik से हूबहू मिला चुका है** (→ 08)।
///
/// इसलिए यह फ़ाइल **तारीख़ नहीं सुझाती।** वो अब भी पंडित जी का काम है।
/// यह सिर्फ़ इतना कहती है कि *"इन दिनों में मांगलिक काम नहीं होते"* —
/// और हर दिन के साथ वजह लिखती है, ताकि कोई जाँच सके।
///
/// ```
/// जानते हैं  →  कौन से दिन टालने हैं        ← यह फ़ाइल
/// नहीं जानते →  कौन सा दिन सबसे शुभ है      ← पंडित जी (→ D-019)
/// ```
///
/// ⚠️ **यहाँ कभी कोई नया नियम मत जोड़ना जो पंचांग से सीधे न निकलता हो।**
/// जिस दिन यह "सुझाने" लगेगी, उसी दिन यह वो चीज़ बन जाएगी जिसे D-019 ने
/// जान-बूझकर रोका था।
library;

import 'names.dart';
import 'panchang.dart';
import 'place.dart';

/// एक दिन को टालने की वजह।
enum TaalneKiVajah {
  /// पूरा मास — इसमें कोई मांगलिक काम नहीं होता।
  adhikaMasa,

  /// पितृ पक्ष के पंद्रह दिन — श्राद्ध के, मंगल के नहीं।
  pitruPaksha,

  /// भद्रा — दिन का एक हिस्सा, पूरा दिन नहीं।
  bhadra,

  /// पंचक — पाँच नक्षत्रों का खंड।
  panchak,

  /// गंडमूल नक्षत्र।
  gandmool,
}

extension TaalneKiVajahVivaran on TaalneKiVajah {
  String get naam => switch (this) {
        TaalneKiVajah.adhikaMasa => 'अधिक मास',
        TaalneKiVajah.pitruPaksha => 'पितृ पक्ष',
        TaalneKiVajah.bhadra => 'भद्रा',
        TaalneKiVajah.panchak => 'पंचक',
        TaalneKiVajah.gandmool => 'गंडमूल',
      };

  /// क्यों टाला जाता है — एक पंक्ति में, बिना किसी दावे के।
  String get kyon => switch (this) {
        TaalneKiVajah.adhikaMasa =>
          'तेरहवाँ मास, जो हर तीसरे साल आता है। पूरे मास में मांगलिक '
              'काम नहीं होते — पूजा-पाठ और दान होते हैं।',
        TaalneKiVajah.pitruPaksha =>
          'पंद्रह दिन पितरों के। श्राद्ध और तर्पण इन्हीं दिनों होते हैं, '
              'नए और मांगलिक काम नहीं।',
        TaalneKiVajah.bhadra =>
          'दिन का वह हिस्सा जिसमें शुभ काम नहीं होते। यह पूरा दिन नहीं '
              'होता — समय देखकर उससे पहले या बाद में किया जा सकता है।',
        TaalneKiVajah.panchak =>
          'धनिष्ठा से रेवती तक के पाँच नक्षत्र। कई घरों में इनमें गृह '
              'प्रवेश, छत डालना और दक्षिण की यात्रा टाली जाती है।',
        TaalneKiVajah.gandmool =>
          'छह नक्षत्रों का एक खंड। कुछ घरों में इनमें नया काम शुरू करना '
              'टाला जाता है।',
      };

  /// पूरा दिन टलता है, या दिन का एक हिस्सा?
  ///
  /// ⚠️ यह फ़र्क़ बताना ज़रूरी है। भद्रा वाले दिन को पूरा काट देना ग़लत
  /// होगा — भद्रा दो घंटे की भी हो सकती है।
  bool get pooraDin => this != TaalneKiVajah.bhadra;

  /// कितना पक्का है।
  ///
  /// अधिक मास और पितृ पक्ष पर कोई मतभेद नहीं — वे पूरे भारत में एक जैसे
  /// माने जाते हैं। पंचक और गंडमूल पर घर-घर और क्षेत्र-क्षेत्र में फ़र्क़
  /// है, इसलिए ऐप उन्हें अलग दर्जे में रखता है और वैसा ही लिखता है।
  bool get sabMante => this == TaalneKiVajah.adhikaMasa ||
      this == TaalneKiVajah.pitruPaksha ||
      this == TaalneKiVajah.bhadra;
}

/// एक टालने वाला दिन — और क्यों।
class TaalneWalaDin {
  final DateTime din;

  /// इस दिन की सब वजहें, पक्की पहले।
  final List<TaalneKiVajah> vajahein;

  /// भद्रा का समय — तभी जब [vajahein] में भद्रा हो।
  final Kaal? bhadraKaal;

  const TaalneWalaDin({
    required this.din,
    required this.vajahein,
    this.bhadraKaal,
  });

  /// पूरा दिन टल रहा है, या सिर्फ़ एक हिस्सा (अकेली भद्रा)?
  bool get pooraDinTalta => vajahein.any((v) => v.pooraDin);

  /// सब मानते हैं ऐसी कोई वजह है?
  bool get pakkiVajah => vajahein.any((v) => v.sabMante);
}

/// पितृ पक्ष — भाद्रपद पूर्णिमा से आश्विन अमावस्या तक के पंद्रह दिन।
///
/// ⚠️ **मास-पद्धति यहाँ मायने रखती है।** पूर्णिमांत में ये दिन *आश्विन
/// कृष्ण पक्ष* कहलाते हैं; अमांत में *भाद्रपद कृष्ण पक्ष*। दिन वही हैं,
/// नाम अलग — इसलिए दोनों को अलग-अलग जाँचना पड़ता है, वरना आधे यूज़र के
/// लिए यह चुप रह जाएगा।
bool isPitruPaksha(Panchang p) {
  if (p.paksha != 1) return false; // कृष्ण पक्ष ही
  const ashwin = 6; // masaNames में आश्विन
  const bhadrapada = 5;
  return p.masaSystem == MasaSystem.purnimanta
      ? p.masa == ashwin
      : p.masa == bhadrapada;
}

/// [se] से [tak] तक (दोनों सहित) वे दिन जिन्हें टाला जाता है।
///
/// लौटती सूची में **सिर्फ़ वे दिन आते हैं जिन पर कोई वजह है** — साफ़ दिन
/// इसमें नहीं होते। सूची तारीख़ के क्रम में रहती है।
List<TaalneWalaDin> taalneWaleDin(
  DateTime se,
  DateTime tak,
  Place place, {
  MasaSystem masaSystem = MasaSystem.purnimanta,
}) {
  final out = <TaalneWalaDin>[];
  var din = DateTime(se.year, se.month, se.day);
  final aakhri = DateTime(tak.year, tak.month, tak.day);

  while (!din.isAfter(aakhri)) {
    final p = computePanchang(
      din.year,
      din.month,
      din.day,
      place,
      masaSystem: masaSystem,
    );

    final vajahein = <TaalneKiVajah>[
      if (p.isAdhikaMasa) TaalneKiVajah.adhikaMasa,
      if (isPitruPaksha(p)) TaalneKiVajah.pitruPaksha,
      if (p.bhadra != null) TaalneKiVajah.bhadra,
      if (p.isPanchak) TaalneKiVajah.panchak,
      if (p.isGandmool) TaalneKiVajah.gandmool,
    ];

    if (vajahein.isNotEmpty) {
      out.add(TaalneWalaDin(
        din: din,
        vajahein: vajahein,
        bhadraKaal: vajahein.contains(TaalneKiVajah.bhadra) ? p.bhadra : null,
      ));
    }
    din = din.add(const Duration(days: 1));
  }
  return out;
}

/// उन दिनों की गिनती जिन पर **पूरा दिन** टलता है।
///
/// अकेली भद्रा वाले दिन इसमें नहीं गिने जाते — वे पूरे नहीं टलते।
int pooreDinTalneWale(List<TaalneWalaDin> sab) =>
    sab.where((d) => d.pooraDinTalta).length;
