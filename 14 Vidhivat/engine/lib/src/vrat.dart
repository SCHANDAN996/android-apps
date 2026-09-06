import 'names.dart';
import 'panchang.dart';
import 'place.dart';

/// **व्रत — जो हर महीने लौटते हैं।**
///
/// ## यह `festival.dart` से अलग क्यों है
///
/// त्योहार साल में एक बार आता है, इसलिए उसका नियम पक्का होता है:
/// *"फाल्गुन कृष्ण चतुर्दशी"*। व्रत ऐसे नहीं — **एकादशी हर महीने दो
/// बार** पड़ती है, प्रदोष भी दो बार, संकष्टी हर कृष्ण चतुर्थी को।
/// इसलिए इनका नियम मास से नहीं, सिर्फ़ **तिथि और पक्ष** से बनता है।
///
/// ## तारीख़ कैसे निकलती है
///
/// वही व्यापिनी नियम जो त्योहारों में लगता है — **सूर्योदय के समय जो
/// तिथि चल रही हो, वही उस दिन की तिथि है।** इसलिए यहाँ कोई नया गणित
/// नहीं है; दिन-दर-दिन `computePanchang` से पूछा जाता है और जिस दिन
/// तिथि मिल जाए वही व्रत का दिन है।
///
/// > 🔑 **एक भी तारीख़ हाथ से नहीं लिखी।** दस साल बाद भी यह सूची अपने
/// > आप सही रहेगी — यही इस प्रोजेक्ट का सुनहरा नियम है।
///
/// ⚠️ **यहाँ फल या लाभ का दावा नहीं है।** ऐप सिर्फ़ यह बताता है कि व्रत
/// किस दिन पड़ता है। *"यह व्रत करने से क्या मिलेगा"* — वो दावा ऐप कभी
/// नहीं करेगा।
class VratNiyam {
  final String id;
  final String naam;

  /// एक लाइन — व्रत किस दिन पड़ता है, यही बताती है।
  final String kabPadta;

  /// पक्ष के भीतर तिथि, 1 से 15 (पूर्णिमा/अमावस्या = 15)।
  final int tithi;

  /// `0` = शुक्ल, `1` = कृष्ण, `null` = **दोनों पक्षों में**।
  final int? paksha;

  const VratNiyam({
    required this.id,
    required this.naam,
    required this.kabPadta,
    required this.tithi,
    this.paksha,
  });
}

/// जो व्रत ऐप गिनता है।
///
/// ⚠️ यह सूची जान-बूझकर छोटी है — इसमें सिर्फ़ वे हैं जो **तिथि से ही
/// पूरे तय हो जाते हैं**। जिनमें नक्षत्र, वार या क्षेत्र की शर्त भी
/// लगती है (जैसे प्रदोष का वार-भेद, या सोमवार व्रत) वे यहाँ नहीं हैं —
/// आधा सही बताने से न बताना बेहतर है।
const List<VratNiyam> vratNiyam = [
  VratNiyam(
    id: 'ekadashi',
    naam: 'एकादशी',
    kabPadta: 'हर महीने दोनों पक्षों की ग्यारस',
    tithi: 11,
  ),
  VratNiyam(
    id: 'pradosh',
    naam: 'प्रदोष व्रत',
    kabPadta: 'हर महीने दोनों पक्षों की त्रयोदशी',
    tithi: 13,
  ),
  VratNiyam(
    id: 'sankashti',
    naam: 'संकष्टी चतुर्थी',
    kabPadta: 'हर महीने कृष्ण पक्ष की चौथ',
    tithi: 4,
    paksha: 1,
  ),
  VratNiyam(
    id: 'masik_shivratri',
    naam: 'मासिक शिवरात्रि',
    kabPadta: 'हर महीने कृष्ण पक्ष की चतुर्दशी',
    tithi: 14,
    paksha: 1,
  ),
  VratNiyam(
    id: 'purnima',
    naam: 'पूर्णिमा',
    kabPadta: 'हर महीने की पूर्णिमा',
    tithi: 15,
    paksha: 0,
  ),
  VratNiyam(
    id: 'amavasya',
    naam: 'अमावस्या',
    kabPadta: 'हर महीने की अमावस्या',
    tithi: 15,
    paksha: 1,
  ),
];

/// एक व्रत, एक दिन पर।
class VratDin {
  final VratNiyam niyam;

  /// स्थानीय तारीख़ — समय बेमानी है, सिर्फ़ दिन देखो।
  final DateTime tarikh;

  /// आज से कितने दिन बाद। 0 = आज, 1 = कल।
  final int kitneDinBaad;

  /// उस दिन का पूरा तिथि-नाम, जैसे "कृष्ण एकादशी"।
  final String tithiNaam;

  const VratDin({
    required this.niyam,
    required this.tarikh,
    required this.kitneDinBaad,
    required this.tithiNaam,
  });

  /// "आज" · "कल" · "परसों" · "12 दिन बाद"
  String get kabLikha => switch (kitneDinBaad) {
        0 => 'आज',
        1 => 'कल',
        2 => 'परसों',
        _ => '$kitneDinBaad दिन बाद',
      };
}

/// आगे आने वाले व्रत, नज़दीक से दूर के क्रम में।
///
/// [dinAage] — कितने दिन आगे तक देखना है।
/// [kitne] — ज़्यादा से ज़्यादा कितने लौटाने हैं।
///
/// ⚠️ यह हर दिन का पंचांग बनाता है, इसलिए सस्ता नहीं है। इसे build के
/// अंदर मत बुलाओ — एक बार निकालकर रख लो।
List<VratDin> aaneWaleVrat({
  required Place place,
  required MasaSystem masaSystem,
  DateTime? aaj,
  int dinAage = 45,
  int kitne = 12,
}) {
  final shuru = aaj ?? DateTime.now();
  final pehlaDin = DateTime(shuru.year, shuru.month, shuru.day);
  final mile = <VratDin>[];

  for (var i = 0; i <= dinAage && mile.length < kitne; i++) {
    final din = pehlaDin.add(Duration(days: i));
    final p = computePanchang(
      din.year,
      din.month,
      din.day,
      place,
      masaSystem: masaSystem,
    );

    // तिथि 0..29 से गिनी जाती है; पक्ष के भीतर 1..15 चाहिए।
    final pakshaKaTithi = (p.tithi.index % 15) + 1;

    for (final niyam in vratNiyam) {
      if (niyam.tithi != pakshaKaTithi) continue;
      if (niyam.paksha != null && niyam.paksha != p.paksha) continue;

      mile.add(VratDin(
        niyam: niyam,
        tarikh: din,
        kitneDinBaad: i,
        tithiNaam: '${p.pakshaName} ${p.tithi.name}',
      ));
      if (mile.length == kitne) break;
    }
  }

  return mile;
}
