import 'dart:math' as math;

import 'angles.dart';
import 'julian.dart';
import 'moon.dart';
import 'moonrise.dart';
import 'prahar.dart';
import 'place.dart';

/// **चंद्रग्रहण।**
///
/// ## यह ऐप में सबसे नाज़ुक गणना है
///
/// ग्रहण सिर्फ़ एक तारीख़ नहीं है — उससे **सूतक काल** जुड़ा है। चंद्रग्रहण
/// में सूतक ग्रहण शुरू होने से **तीन प्रहर पहले** लगता है। उस दौरान बहुत
/// घरों में खाना नहीं बनता, मंदिर बंद रहते हैं, पूजा नहीं होती।
///
/// ⚠️ **तीन प्रहर "नौ घंटे" नहीं है** — देखो `prahar.dart` और D-054।
///
/// > **ग़लत सूतक बताने का मतलब है किसी के घर का चूल्हा ग़लत वक़्त पर बंद
/// > कराना।** यह "मंत्र ग़लत होना" वाले दर्जे की ग़लती है।
///
/// ⚠️ **और सूतक तभी लगता है जब ग्रहण उस जगह से दिखे।** जो ग्रहण भारत में
/// दिखता ही नहीं, उसका सूतक भी नहीं होता। इसलिए यहाँ सिर्फ़ तारीख़ नहीं,
/// **उस शहर से चंद्रमा क्षितिज के ऊपर है या नहीं** — वो भी देखा जाता है।
///
/// ## गणित कहाँ से
///
/// Meeus, *Astronomical Algorithms*, अध्याय 54 (Eclipses)। वही तरीक़ा जो
/// NASA के ग्रहण-पन्ने और छपे पंचांग इस्तेमाल करते हैं:
///
/// 1. `k` से **पूर्णिमा** का क्षण निकालो (k में .5 इसीलिए जुड़ता है)
/// 2. `F` — चंद्रमा का अक्षांश-कोण। `|sin F| > 0.36` हो तो ग्रहण है ही नहीं
/// 3. सुधार लगाकर **ग्रहण का मध्य** (greatest eclipse)
/// 4. `gamma` — छाया की धुरी से चंद्रमा की सबसे कम दूरी
/// 5. उससे **मान** (magnitude) और अवधि
///
/// ⚠️ **सूर्यग्रहण यहाँ नहीं है, और जान-बूझकर नहीं है।** उसमें "यह शहर से
/// दिखेगा या नहीं" का जवाब Besselian elements माँगता है — वो अलग और बड़ा
/// गणित है। आधा सही बताने से न बताना बेहतर (→ D-052)।

/// ग्रहण किस दर्जे का है।
enum GrahanPrakar {
  /// चंद्रमा सिर्फ़ उपछाया (penumbra) में — आँख से लगभग कुछ नहीं दिखता।
  ///
  /// ⚠️ **इस पर सूतक नहीं माना जाता**, क्योंकि यह दिखता ही नहीं।
  upachhaya('उपछाया चंद्रग्रहण'),

  /// चंद्रमा का कुछ हिस्सा असली छाया (umbra) में।
  khandgras('खंडग्रास चंद्रग्रहण'),

  /// पूरा चंद्रमा असली छाया में।
  khagras('खग्रास चंद्रग्रहण');

  final String naam;
  const GrahanPrakar(this.naam);
}

/// एक चंद्रग्रहण।
class ChandraGrahan {
  final GrahanPrakar prakar;

  /// ग्रहण का मध्य — **असली पल** (UTC)।
  final DateTime madhya;

  /// असली छाया का स्पर्श और मोक्ष। उपछाया ग्रहण में दोनों `null`।
  final DateTime? sparsha;
  final DateTime? moksha;

  /// उपछाया का स्पर्श और मोक्ष — हमेशा रहते हैं।
  final DateTime upachhayaSparsha;
  final DateTime upachhayaMoksha;

  /// असली छाया का मान। उपछाया ग्रहण में `0` या उससे कम।
  final double maan;

  /// छाया की धुरी से चंद्रमा की सबसे कम दूरी, पृथ्वी की त्रिज्या में।
  final double gamma;

  const ChandraGrahan({
    required this.prakar,
    required this.madhya,
    required this.sparsha,
    required this.moksha,
    required this.upachhayaSparsha,
    required this.upachhayaMoksha,
    required this.maan,
    required this.gamma,
  });

  /// ग्रहण कब शुरू होता है — जो पहले दिखे वही।
  ///
  /// उपछाया ग्रहण में उपछाया का स्पर्श ही शुरुआत है; बाक़ी में असली छाया का।
  DateTime get shuru => sparsha ?? upachhayaSparsha;

  /// कब ख़त्म।
  DateTime get khatm => moksha ?? upachhayaMoksha;
}

/// ग्रहण, एक जगह से देखा हुआ — यानी **सूतक के साथ**।
class GrahanDarshan {
  final ChandraGrahan grahan;

  /// इस जगह से दिखेगा या नहीं।
  ///
  /// चंद्रग्रहण वहीं दिखता है जहाँ उस समय **चंद्रमा क्षितिज के ऊपर** हो।
  final bool dikhega;

  /// यहाँ से ग्रहण कब **दिखना शुरू** होता है।
  ///
  /// आम तौर पर यही स्पर्श का समय है। पर अगर स्पर्श के वक़्त चंद्रमा अभी
  /// उगा ही नहीं, तो ग्रहण **चंद्रोदय के साथ** शुरू दिखता है — तब यह
  /// चंद्रोदय का समय होता है। उपछाया ग्रहण में `null`।
  final DateTime? sthaniyaShuru;

  /// यहाँ से ग्रहण कब **दिखना बंद** होता है — मोक्ष, या चंद्रास्त, जो
  /// पहले आए।
  final DateTime? sthaniyaKhatm;

  /// सूतक कब शुरू होता है — **तीन प्रहर पहले** (→ D-054)।
  ///
  /// ⚠️ यह "नौ घंटे घटा दो" नहीं है। प्रहर मौसम के साथ छोटा-बड़ा होता है,
  /// और सूतक उस प्रहर की **शुरुआत** पर लगता है जो ग्रहण वाले प्रहर से तीन
  /// प्रहर पीछे है।
  ///
  /// ⚠️ `null` तब, जब ग्रहण यहाँ **दिखता ही नहीं**, या वो उपछाया ग्रहण है।
  /// दोनों हालतों में सूतक नहीं माना जाता।
  final DateTime? sutakShuru;

  /// सूतक ग्रहण के **स्थानीय अंत** पर उतरता है।
  final DateTime? sutakKhatm;

  /// बच्चों, बूढ़ों और बीमारों के लिए सूतक — सिर्फ़ **एक प्रहर** पहले।
  ///
  /// छपी पद्धतियाँ उन्हें पूरे तीन प्रहर भूखा रहने को नहीं कहतीं।
  final DateTime? komalSutakShuru;

  const GrahanDarshan({
    required this.grahan,
    required this.dikhega,
    required this.sthaniyaShuru,
    required this.sthaniyaKhatm,
    required this.sutakShuru,
    required this.sutakKhatm,
    required this.komalSutakShuru,
  });

  /// ग्रहण चंद्रोदय के साथ ही शुरू दिखेगा — यानी उगते चाँद पर ग्रहण।
  bool get chandrodayParShuru =>
      sthaniyaShuru != null &&
      grahan.sparsha != null &&
      sthaniyaShuru!.isAfter(grahan.sparsha!);

  /// ग्रहण छूटने से पहले ही चाँद डूब जाएगा।
  bool get chandrastParKhatm =>
      sthaniyaKhatm != null &&
      grahan.moksha != null &&
      sthaniyaKhatm!.isBefore(grahan.moksha!);
}

/// ⚠️ `k` में यह जुड़ता है, इसीलिए **पूर्णिमा** मिलती है, अमावस्या नहीं।
const double _purnimaKaAdha = 0.5;

/// इससे बड़ा `|sin F|` हो तो उस पूर्णिमा पर ग्रहण है ही नहीं (Meeus 54.1)।
const double _grahanKiHadd = 0.36;

/// एक पूर्णिमा पर ग्रहण है या नहीं — और है तो कैसा।
///
/// [k] Meeus का चंद्र-चक्र गिनने वाला अंक। पूर्णिमा के लिए इसमें `.5` जुड़ा
/// होना चाहिए।
ChandraGrahan? _grahanEkPurnimaPar(double k) {
  final t = k / 1236.85;
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  // ── माध्य पूर्णिमा का क्षण (Meeus 49.1) ──
  var jde = 2451550.09766 +
      29.530588861 * k +
      0.00015437 * t2 -
      0.000000150 * t3 +
      0.00000000073 * t4;

  // सूर्य का माध्य विसंगति-कोण
  final m = norm360(2.5534 +
      29.10535670 * k -
      0.0000014 * t2 -
      0.00000011 * t3);
  // चंद्रमा का माध्य विसंगति-कोण
  final mPrime = norm360(201.5643 +
      385.81693528 * k +
      0.0107582 * t2 +
      0.00001238 * t3 -
      0.000000058 * t4);
  // चंद्रमा का अक्षांश-कोण
  final f = norm360(160.7108 +
      390.67050284 * k -
      0.0016118 * t2 -
      0.00000227 * t3 +
      0.000000011 * t4);
  // आरोही पात (ascending node)
  final omega = norm360(124.7746 -
      1.56375588 * k +
      0.0020672 * t2 +
      0.00000215 * t3);

  // ── यहीं तय होता है कि ग्रहण है या नहीं (Meeus 54) ──
  if (sinD(f).abs() > _grahanKiHadd) return null;

  final e = 1 - 0.002516 * t - 0.0000074 * t2;

  // Meeus 54: A1 और F1
  final f1 = f - 0.02665 * sinD(omega);
  final a1 = norm360(299.77 + 0.107408 * k - 0.009173 * t2);

  // ── ग्रहण के मध्य का सुधार (Meeus 54) ─────────────────────────
  //
  // ⚠️ यह **अध्याय 49 वाली सूची नहीं है।** पहली बार मैंने वही लगा दी
  // थी (जो *पूर्णिमा का सटीक क्षण* देती है) और NASA से मिलाने पर समय
  // दस से चौदह मिनट तक खिसका मिला।
  //
  // दो अलग चीज़ें हैं: **पूर्णिमा का क्षण** और **ग्रहण का मध्य** (जब
  // चंद्रमा छाया की धुरी के सबसे पास आता है)। दोनों एक ही पल नहीं
  // होते। अध्याय 54 की अपनी सूची सीधे *ग्रहण का मध्य* देती है।
  //
  // सबसे बड़ा फ़र्क़ यही रहा: 49 में `+0.01043 sin 2F`, 54 में
  // `−0.0097 sin 2F1` — **चिह्न ही उल्टा**, यानी अकेले इसी से आधे घंटे
  // तक का झूला।
  jde += -0.4075 * sinD(mPrime) +
      0.1721 * e * sinD(m) +
      0.0161 * sinD(2 * mPrime) -
      0.0097 * sinD(2 * f1) +
      0.0073 * e * sinD(mPrime - m) -
      0.0050 * e * sinD(mPrime + m) -
      0.0023 * sinD(mPrime - 2 * f1) +
      0.0021 * e * sinD(2 * m) +
      0.0012 * sinD(mPrime + 2 * f1) +
      0.0006 * e * sinD(2 * mPrime + m) -
      0.0004 * sinD(3 * mPrime) -
      0.0003 * e * sinD(m + 2 * f1) +
      0.0003 * sinD(a1) -
      0.0002 * e * sinD(m - 2 * f1) -
      0.0002 * e * sinD(2 * mPrime - m) -
      0.0002 * sinD(omega);

  // ── P, Q, W, gamma, u (Meeus 54) ──
  final p = 0.2070 * e * sinD(m) +
      0.0024 * e * sinD(2 * m) -
      0.0392 * sinD(mPrime) +
      0.0116 * sinD(2 * mPrime) -
      0.0073 * e * sinD(mPrime + m) +
      0.0067 * e * sinD(mPrime - m) +
      0.0118 * sinD(2 * f1);

  final q = 5.2207 -
      0.0048 * e * cosD(m) +
      0.0020 * e * cosD(2 * m) -
      0.3299 * cosD(mPrime) -
      0.0060 * e * cosD(mPrime + m) +
      0.0041 * e * cosD(mPrime - m);

  final w = cosD(f1).abs();
  final gamma = (p * cosD(f1) + q * sinD(f1)) * (1 - 0.0048 * w);
  final u = 0.0059 +
      0.0046 * e * cosD(m) -
      0.0182 * cosD(mPrime) +
      0.0004 * cosD(2 * mPrime) -
      0.0005 * e * cosD(m + mPrime);

  // ── मान (magnitude) ──
  final gAbs = gamma.abs();
  final upachhayaMaan = (1.5573 + u - gAbs) / 0.5450;
  final chhayaMaan = (1.0128 - u - gAbs) / 0.5450;

  // उपछाया भी न छुए तो ग्रहण है ही नहीं।
  //
  // ⚠️ यहाँ एक बार `-0.01` की छूट डालकर देखी गई थी, ताकि 18 जुलाई 2027
  // वाला छिछला उपछाया ग्रहण भी पकड़ में आए। **वो काम नहीं आई** — क्योंकि
  // असली अड़चन मान नहीं, अवधि है: उस दिन |γ| = 1.5801 और उपछाया की
  // त्रिज्या 1.5766, यानी वर्गमूल के अंदर ऋण। छूट हटा दी गई; नक़ली छूट
  // रखने से बेहतर है सच लिखना (→ D-052 में पूरा ब्यौरा)।
  if (upachhayaMaan <= 0) return null;

  // ── अवधियाँ (Meeus 54.2) — मिनट में ────────────────────────────
  //
  // ⚠️ यहाँ **छाया की त्रिज्या नहीं** लगती। पहली बार मैंने ρ = 1.2848+u
  // और σ = 0.7403−u लगा दिए थे — वो छाया की अपनी त्रिज्याएँ हैं। पर
  // स्पर्श तब होता है जब **चंद्रमा का किनारा** छाया को छुए, इसलिए उसमें
  // चंद्रमा का अपना अर्धव्यास भी जुड़ता है। Meeus इसीलिए अलग मान देता है:
  //
  //     H = 1.5573 + u   उपछाया का स्पर्श–मोक्ष
  //     P = 1.0128 − u   असली छाया का स्पर्श–मोक्ष
  //     T = 0.4678 − u   खग्रास (पूरा ढका) कब तक
  //
  // जाँच ने यही पकड़ा: 12 जनवरी 2028 का ग्रहण खंडग्रास निकला (मान 0.06)
  // पर उसका स्पर्श `null` आ रहा था — क्योंकि γ = 0.985 σ से बड़ा है,
  // पर P से छोटा। यानी मान कह रहा था "छाया छू रही है" और अवधि कह रही
  // थी "नहीं छू रही"। दोनों एक ही बात हैं; अब एक ही सूत्र से आती हैं।
  // ⚠️ `n` स्थिर नहीं है। पहली बार मैंने इसे सिर्फ़ 0.5458 रखा था और
  // NASA से मिलाने पर अवधि **चौबीस मिनट** तक ग़लत निकली (362 मिनट में
  // से 24 — यानी लगभग सात प्रतिशत)। Meeus में इसका दूसरा पद है:
  //
  //     n = 0.5458 + 0.0400 cos M'
  //
  // `cos M'` एक से शून्य से ऋण-एक तक घूमता है, इसलिए यही पद अवधि को
  // ±7% तक हिलाता है — ठीक उतना ही जितना फ़र्क़ दिख रहा था।
  final n = 0.5458 + 0.0400 * cosD(mPrime);

  double? adhaAvadhi(double maanak) {
    final andar = maanak * maanak - gamma * gamma;
    if (andar <= 0) return null;
    return 60 / n * math.sqrt(andar);
  }

  final upachhayaAdha = adhaAvadhi(1.5573 + u);
  if (upachhayaAdha == null) return null;
  final chhayaAdha = adhaAvadhi(1.0128 - u);

  // ⚠️ JDE (ephemeris time) से UT में लाना पड़ता है, वरना जवाब ΔT जितना
  // खिसक जाएगा — 2026 में लगभग 70 सेकंड।
  final varsh = utcFromJulianDay(jde).year;
  final deltaT = deltaTSeconds(varsh, 1) / 86400.0;
  DateTime samay(double dinBaad) =>
      utcFromJulianDay(jde - deltaT + dinBaad / 1440.0);

  final prakar = chhayaMaan >= 1
      ? GrahanPrakar.khagras
      : chhayaMaan > 0
          ? GrahanPrakar.khandgras
          : GrahanPrakar.upachhaya;

  return ChandraGrahan(
    prakar: prakar,
    madhya: samay(0),
    sparsha: chhayaAdha == null ? null : samay(-chhayaAdha),
    moksha: chhayaAdha == null ? null : samay(chhayaAdha),
    upachhayaSparsha: samay(-upachhayaAdha),
    upachhayaMoksha: samay(upachhayaAdha),
    maan: chhayaMaan,
    gamma: gamma,
  );
}

/// दो तारीख़ों के बीच पड़ने वाले सारे चंद्रग्रहण।
///
/// साल में आम तौर पर दो, कभी-कभी तीन।
List<ChandraGrahan> chandraGrahan({
  required DateTime se,
  required DateTime tak,
}) {
  // k = 0 → 2000 जनवरी की अमावस्या। पूर्णिमा के लिए .5 जोड़ते हैं।
  double kFor(DateTime d) {
    final varsh = d.year + (d.month - 0.5) / 12.0;
    return (varsh - 2000) * 12.3685;
  }

  final mile = <ChandraGrahan>[];
  // दोनों तरफ़ दो-दो चक्र की गुंजाइश — किनारे वाला ग्रहण छूटे नहीं।
  final shuruK = kFor(se).floor() - 2;
  final antK = kFor(tak).ceil() + 2;

  for (var n = shuruK; n <= antK; n++) {
    final g = _grahanEkPurnimaPar(n + _purnimaKaAdha);
    if (g == null) continue;
    if (g.madhya.isBefore(se) || g.madhya.isAfter(tak)) continue;
    mile.add(g);
  }

  mile.sort((a, b) => a.madhya.compareTo(b.madhya));
  return mile;
}

/// चंद्रग्रहण का सूतक कितने प्रहर पहले लगता है।
const int chandraGrahanKeSutakKePrahar = 3;

/// उस पल चंद्रमा **देखने वाले के** क्षितिज से कितना ऊपर, डिग्री।
///
/// ## यहाँ लंबन (parallax) घटाना पड़ता है, और यह छोटी बात नहीं है
///
/// `moonAltitude` **भूकेंद्रीय** ऊँचाई देता है — यानी पृथ्वी के केंद्र से
/// देखने पर। पर ग्रहण देखने वाला केंद्र में नहीं, सतह पर खड़ा है, और
/// चंद्रमा इतना पास है कि यह फ़र्क़ पूरे **एक डिग्री** का पड़ता है — चाँद
/// के अपने आकार से दुगना। क्षितिज पर वो पूरा का पूरा लगता है:
///
///     h′ = h − π · cos h        (π ≈ 0.95°, क्षैतिज लंबन)
///
/// नतीजा: चंद्रोदय लगभग **पाँच मिनट बाद** होता है।
///
/// ⚠️ **यह पाँच मिनट सूतक में तीन घंटे बन जाते हैं।** 3 मार्च 2026 को
/// दिल्ली में ग्रहण चंद्रोदय के साथ शुरू होता है, और चंद्रोदय सूर्यास्त
/// के दस सेकंड के भीतर पड़ता है। लंबन के बिना चंद्रोदय सूर्यास्त से *पहले*
/// आ जाता था — यानी ग्रहण "दिन के चौथे प्रहर" में गिना जाता, रात के पहले
/// में नहीं, और सूतक पूरा एक प्रहर पीछे खिसक जाता (→ D-054)।
///
/// ⚠️ **`moonrise.dart` अब भी भूकेंद्रीय दहलीज़ (Meeus 15.1) पर है** —
/// वहाँ D-014 का फ़ैसला लागू है, और उसे यहाँ से नहीं बदला जा रहा। वो
/// अलग सवाल है, अलग जाँच माँगता है।
double _chandraKitnaUpar(DateTime pal, Place place) {
  final jd = julianDayFromUtc(pal);
  final bhukendriya = moonAltitude(jd, place);
  final lamban = moonParallax(toEphemerisTime(jd));
  return bhukendriya - lamban * cosD(bhukendriya);
}

/// चाँद क्षितिज कब पार करता है — [upar] पर वो ऊपर है, [neeche] पर नीचे।
///
/// दोनों में से कोई भी पहले हो सकता है: [upar] बाद में हो तो यह **चंद्रोदय**
/// है, पहले हो तो **चंद्रास्त**। लौटता हमेशा ऊपर वाला सिरा है — यानी वो
/// पहला/आख़िरी पल जब चाँद निकला हुआ है।
DateTime _kshitijPar(DateTime upar, DateTime neeche, Place place) {
  var u = upar;
  var n = neeche;
  // चौबीस बार आधा करने पर दो मिनट का अंतराल एक सेकंड से नीचे आ जाता है।
  for (var i = 0; i < 24; i++) {
    final beech = n.add(u.difference(n) ~/ 2);
    if (beech == u || beech == n) break;
    if (_chandraKitnaUpar(beech, place) > 0) {
      u = beech;
    } else {
      n = beech;
    }
  }
  return u;
}

/// असली छाया वाला ग्रहण यहाँ से **कब से कब तक** दिखेगा।
///
/// स्पर्श से मोक्ष तक का वो हिस्सा जिसमें चाँद क्षितिज के ऊपर है। पूरा
/// नीचे रहे तो `null`।
({DateTime shuru, DateTime khatm})? _sthaniyaGrahan(
  ChandraGrahan g,
  Place place,
) {
  final sparsha = g.sparsha;
  final moksha = g.moksha;
  if (sparsha == null || moksha == null) return null;

  // दो मिनट के क़दम — चाँद इतनी देर में क्षितिज पार करके वापस नहीं आ सकता।
  const kadam = Duration(minutes: 2);
  DateTime? pehlaUpar;
  DateTime? antimUpar;
  for (var t = sparsha; t.isBefore(moksha); t = t.add(kadam)) {
    if (_chandraKitnaUpar(t, place) > 0) {
      pehlaUpar ??= t;
      antimUpar = t;
    }
  }
  final antPar = _chandraKitnaUpar(moksha, place) > 0;
  if (antPar) {
    pehlaUpar ??= moksha;
    antimUpar = moksha;
  }
  if (pehlaUpar == null || antimUpar == null) return null;

  // शुरुआत: स्पर्श पर चाँद ऊपर था तो स्पर्श ही, वरना चंद्रोदय।
  final shuru = pehlaUpar == sparsha
      ? sparsha
      : _kshitijPar(pehlaUpar, pehlaUpar.subtract(kadam), place);

  // अंत: मोक्ष तक ऊपर रहा तो मोक्ष ही, वरना चंद्रास्त।
  final agla = antimUpar.add(kadam);
  final khatm = antPar
      ? moksha
      : _kshitijPar(antimUpar, agla.isAfter(moksha) ? moksha : agla, place);

  return (shuru: shuru, khatm: khatm);
}

/// यह ग्रहण इस जगह से दिखेगा या नहीं — और दिखेगा तो सूतक कब से।
///
/// चंद्रग्रहण वहीं दिखता है जहाँ उस समय **चंद्रमा क्षितिज के ऊपर** हो।
///
/// ## सूतक — नौ घंटे नहीं, **तीन प्रहर** (→ D-054)
///
/// पहले यहाँ सीधा नौ घंटे घटाए जाते थे। Drik Panchang के तीन ग्रहण से
/// मिलाने पर वो ग़लत निकला। असली नियम यह है:
///
/// > सूतक उस प्रहर की **शुरुआत** पर लगता है जो ग्रहण वाले प्रहर से तीन
/// > प्रहर पीछे है।
///
/// और गिनती **स्थानीय** शुरुआत से होती है — यानी अगर स्पर्श के वक़्त चाँद
/// उगा ही नहीं, तो चंद्रोदय से। सूतक स्थानीय अंत पर उतरता है — मोक्ष, या
/// चंद्रास्त, जो पहले आए।
///
/// ⚠️ **उपछाया ग्रहण पर सूतक नहीं।** वो आँख से दिखता ही नहीं — चंद्रमा
/// बस थोड़ा धुँधला पड़ता है। छपी पंचांग-पद्धतियाँ भी उस पर सूतक नहीं मानतीं।
GrahanDarshan dekhaJayega(ChandraGrahan g, Place place) {
  final sthaniya = _sthaniyaGrahan(g, place);

  // उपछाया ग्रहण में असली छाया होती ही नहीं, इसलिए वहाँ "दिखेगा" का
  // मतलब सिर्फ़ इतना है कि उस वक़्त चाँद ऊपर था।
  final dikhega = g.prakar == GrahanPrakar.upachhaya
      ? _chandraKitnaUpar(g.shuru, place) > 0 ||
          _chandraKitnaUpar(g.madhya, place) > 0 ||
          _chandraKitnaUpar(g.khatm, place) > 0
      : sthaniya != null;

  final sutakLagega = sthaniya != null && g.prakar != GrahanPrakar.upachhaya;

  return GrahanDarshan(
    grahan: g,
    dikhega: dikhega,
    sthaniyaShuru: sthaniya?.shuru,
    sthaniyaKhatm: sthaniya?.khatm,
    sutakShuru: sutakLagega
        ? praharPeeche(sthaniya.shuru, place, chandraGrahanKeSutakKePrahar)
        : null,
    sutakKhatm: sutakLagega ? sthaniya.khatm : null,
    komalSutakShuru: sutakLagega
        ? praharPeeche(sthaniya.shuru, place, komalJanoKeSutakKePrahar)
        : null,
  );
}
