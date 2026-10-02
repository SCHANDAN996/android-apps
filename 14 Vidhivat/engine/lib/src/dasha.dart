import 'kundali.dart';

/// विंशोत्तरी दशा — **तारीख़ों का गणित** (→ D-098, docs/29 चरण K2)।
///
/// जन्म के समय चंद्रमा जिस नक्षत्र में हो, उसी के स्वामी की दशा चल रही होती
/// है; और चंद्रमा उस नक्षत्र में जितना आगे निकल चुका हो, दशा का उतना हिस्सा
/// बीत चुका माना जाता है। आगे नौ ग्रहों की दशाएँ तय क्रम में, कुल 120 साल।
///
/// यह फ़ाइल सिर्फ़ यह बताती है कि **कौन सी दशा कब से कब तक** है। उस दशा में
/// "क्या होगा" — यह यहाँ नहीं है और कभी नहीं आएगा (→ `kundali.dart`)।
///
/// ## दो बातें जो स्क्रीन पर लिखी जाएँगी
/// 1. **तारीख़ें कुछ दिन आगे-पीछे हो सकती हैं।** चंद्र के देशांतर का 1 कला
///    का फ़र्क़ शुक्र की दशा में ~9 दिन बन जाता है; जन्म-समय का 1 मिनट
///    ~4½ दिन।
/// 2. **साल कितने दिन का** — यहाँ 365.25 (सौर वर्ष)। कुछ पद्धतियाँ 360 दिन
///    का सावन वर्ष लेती हैं; संदर्भ से मिलान के बाद ही यह तय माना जाएगा
///    (→ `kundaliIsReady`)।

/// विंशोत्तरी के स्वामी, क्रम से — अश्विनी का स्वामी केतु, फिर भरणी का
/// शुक्र… हर नौ नक्षत्र बाद वही क्रम दोहराता है।
const List<KundaliGraha> vimshottariKram = [
  KundaliGraha.ketu,
  KundaliGraha.shukra,
  KundaliGraha.surya,
  KundaliGraha.chandra,
  KundaliGraha.mangal,
  KundaliGraha.rahu,
  KundaliGraha.guru,
  KundaliGraha.shani,
  KundaliGraha.budh,
];

/// हर स्वामी की महादशा कितने साल की — [vimshottariKram] के क्रम में। कुल 120।
const List<int> vimshottariVarsh = [7, 20, 6, 10, 7, 18, 16, 19, 17];

/// दशा का सौर वर्ष, दिनों में।
const double dashaVarshDin = 365.25;

/// किसी नक्षत्र (0 = अश्विनी) का विंशोत्तरी स्वामी।
KundaliGraha nakshatraSwami(int nakshatra) => vimshottariKram[nakshatra % 9];

/// एक दशा या अंतर्दशा — किसकी, कब से कब तक (UTC)।
class DashaKhand {
  final KundaliGraha swami;
  final DateTime shuru;
  final DateTime ant;

  const DashaKhand(this.swami, this.shuru, this.ant);

  /// यह क्षण इस खंड के भीतर है?
  bool mein(DateTime kshan) => !kshan.isBefore(shuru) && kshan.isBefore(ant);

  @override
  String toString() => '${swami.naam}: $shuru → $ant';
}

DateTime _jodo(DateTime t, double din) =>
    t.add(Duration(milliseconds: (din * 86400000).round()));

/// जन्म से 120 साल आगे तक की महादशाएँ।
///
/// [chandraNirayan] जन्म के समय चंद्रमा का निरयन देशांतर है। पहली दशा जन्म से
/// **पहले** शुरू हुई होती है — उसका [DashaKhand.shuru] वही पुरानी तारीख़ है,
/// ताकि "जन्म पर कितनी बची थी" साफ़ निकले।
List<DashaKhand> vimshottariMahadasha(DateTime janmUtc, double chandraNirayan) {
  assert(janmUtc.isUtc, 'जन्म का समय UTC में चाहिए');
  const nakshatraAnsh = 360.0 / 27.0;
  final nakshatra = (chandraNirayan ~/ nakshatraAnsh) % 27;
  // नक्षत्र का कितना हिस्सा चंद्रमा पार कर चुका — 0 से 1
  final beeta = (chandraNirayan % nakshatraAnsh) / nakshatraAnsh;

  final pehla = nakshatra % 9;
  var shuru = _jodo(janmUtc, -beeta * vimshottariVarsh[pehla] * dashaVarshDin);

  final out = <DashaKhand>[];
  // नौ दशाएँ = पूरा 120 साल का चक्र; एक और, ताकि जन्म से पूरे 120 साल ढकें
  for (var i = 0; i <= 9; i++) {
    final k = (pehla + i) % 9;
    final ant = _jodo(shuru, vimshottariVarsh[k] * dashaVarshDin);
    out.add(DashaKhand(vimshottariKram[k], shuru, ant));
    shuru = ant;
  }
  return out;
}

/// किसी महादशा की नौ अंतर्दशाएँ।
///
/// अंतर्दशा उसी स्वामी से शुरू होती है जिसकी महादशा है, फिर वही क्रम; हर
/// एक की लंबाई = महादशा के साल × अंतर्दशा के साल ÷ 120।
List<DashaKhand> vimshottariAntardasha(DashaKhand maha) {
  final m = vimshottariKram.indexOf(maha.swami);
  var shuru = maha.shuru;
  final out = <DashaKhand>[];
  for (var i = 0; i < 9; i++) {
    final k = (m + i) % 9;
    final din =
        vimshottariVarsh[m] * vimshottariVarsh[k] / 120.0 * dashaVarshDin;
    // आख़िरी अंतर्दशा ठीक महादशा के अंत पर ख़त्म हो — गोलाई से एक
    // मिलीसेकंड का छेद न रहे
    final ant = i == 8 ? maha.ant : _jodo(shuru, din);
    out.add(DashaKhand(vimshottariKram[k], shuru, ant));
    shuru = ant;
  }
  return out;
}

/// जन्म के समय चल रही महादशा कितनी **बची** थी — साल में।
double janmParDashaShesh(double chandraNirayan) {
  const nakshatraAnsh = 360.0 / 27.0;
  final nakshatra = (chandraNirayan ~/ nakshatraAnsh) % 27;
  final beeta = (chandraNirayan % nakshatraAnsh) / nakshatraAnsh;
  return (1 - beeta) * vimshottariVarsh[nakshatra % 9];
}
