import 'angles.dart';
import 'ayanamsa.dart';
import 'graha.dart';
import 'julian.dart';
import 'moon.dart';
import 'names.dart';
import 'nutation.dart';
import 'place.dart';
import 'sun.dart';
import 'sunrise.dart';

/// जन्म कुंडली का **गणित** — लग्न, नौ ग्रह, भाव, नवमांश
/// (→ D-098, docs/29 चरण K2)।
///
/// ## यह क्या है, और क्या नहीं
/// यह बताता है कि किसी क्षण, किसी जगह से आकाश कैसा था: कौन सी राशि उग रही
/// थी, कौन सा ग्रह किस राशि-नक्षत्र में था। यह **खगोल** है — जाँचा जा सकता
/// है, और जाँचा गया है।
///
/// यह **नहीं** बताता कि उसका किसी के जीवन पर क्या असर होगा। फलादेश,
/// राशिफल, उपाय — इस फ़ाइल में नहीं हैं और कभी नहीं आएँगे (`CLAUDE.md`:
/// *"भविष्यवाणी के दावे कभी नहीं"*)।
///
/// ## ✅ जाँच — किससे, और क्या बाक़ी (→ D-105, docs/08 §18)
/// [kundaliIsReady] 2 अक्टूबर 2026 को `true` हुआ, जब `docs/29` §9 की कसौटी
/// (लग्न 2 कला के भीतर) NASA JPL Horizons से पूरी हुई:
///
/// | क्या | किससे | नतीजा |
/// |---|---|---|
/// | नौ ग्रह | Horizons, 20 तारीख़ें, 1930–2040 | सूर्य 0.3″ · चंद्र 9.9″ · पाँच ग्रह 0.63″ |
/// | **लग्न** | Horizons: सूर्य के ज्यामितीय उगने-डूबने के क्षण पर लग्न = सूर्य (±180°) — 4 शहर, 96 क्षण, 1947–2034 | **15 विकला** |
/// | नाक्षत्र काल | Horizons, 12 क्षण | 0.38 सेकंड |
///
/// **परंपरा के तीन चुनाव** गणित से तय नहीं होते; वे ये हैं, और स्क्रीन के ⓘ
/// में लिखे हैं:
///
/// - **राहु — औसत पात।** पारंपरिक पंचांग यही देते हैं। स्पष्ट पात भी इंजन में
///   है ([computeKundali] का `spashtRahu`), और ⓘ में उसका मान दिखता है — क्योंकि
///   कुछ सॉफ़्टवेयर वही छापते हैं, और फ़र्क़ 1.7° तक जाता है।
/// - **दशा का साल — 365.25 दिन** (ज़्यादातर सॉफ़्टवेयर का चलन)।
/// - **भाव — एक राशि, एक भाव।**
///
/// ⚠️ घर की छपी जन्मपत्री से मिलान अब भी नहीं हुआ है — वह डेवलपर के पास है।
/// वह *परंपरा* की जाँच होगी (ऊपर के तीन चुनाव), गणित की नहीं।

/// कुंडली की स्क्रीनें इसी पर टिकी हैं — `false` करते ही `अधिक` से हट जाती हैं।
const bool kundaliIsReady = true;

/// कुंडली के नौ ग्रह, परंपरागत क्रम में।
enum KundaliGraha {
  surya('सूर्य'),
  chandra('चंद्र'),
  mangal('मंगल'),
  budh('बुध'),
  guru('गुरु'),
  shukra('शुक्र'),
  shani('शनि'),
  rahu('राहु'),
  ketu('केतु');

  final String naam;
  const KundaliGraha(this.naam);
}

/// एक राशि 30° की; एक नक्षत्र 13°20′ का; एक चरण 3°20′ का; नवमांश भी 3°20′ का।
const double _nakshatraAnsh = 360.0 / 27.0;
const double _charanAnsh = 360.0 / 108.0;

/// निरयन देशांतर से निकली चीज़ें — राशि, अंश, नक्षत्र, चरण, नवमांश।
///
/// लग्न और हर ग्रह, दोनों के लिए यही — सब कुछ एक ही संख्या से निकलता है।
class RashiSthiti {
  /// निरयन देशांतर, 0–360°।
  final double nirayan;

  const RashiSthiti(this.nirayan);

  /// राशि — 0 = मेष … 11 = मीन।
  int get rashi => (nirayan ~/ 30) % 12;
  String get rashiNaam => rashiNames[rashi];

  /// राशि के भीतर कितने अंश (0–30)।
  double get ansh => nirayan - 30.0 * (nirayan ~/ 30);

  /// नक्षत्र — 0 = अश्विनी … 26 = रेवती।
  int get nakshatra => (nirayan ~/ _nakshatraAnsh) % 27;
  String get nakshatraNaam => nakshatraNames[nakshatra];

  /// नक्षत्र का चरण — 1 से 4।
  int get charan => ((nirayan % _nakshatraAnsh) ~/ _charanAnsh) + 1;

  /// नवमांश की राशि — 0 = मेष … 11 = मीन।
  ///
  /// 108 चरण मेष से गिनते चले जाते हैं; यही नियम दूसरे शब्दों में: अग्नि
  /// राशियों के नवमांश मेष से शुरू, पृथ्वी के मकर से, वायु के तुला से,
  /// जल के कर्क से।
  int get navamsha => (nirayan ~/ _charanAnsh) % 12;
  String get navamshaNaam => rashiNames[navamsha];

  /// राशि की सीमा से कितने अंश दूर — दोनों में जो पास हो।
  double get rashiSeemaSeDoori => ansh < 15 ? ansh : 30 - ansh;
}

/// कुंडली में एक ग्रह।
class GrahaSthiti extends RashiSthiti {
  final KundaliGraha graha;

  /// रोज़ की चाल, डिग्री। औसत राहु-केतु की हमेशा ऋणात्मक।
  final double gati;

  const GrahaSthiti(this.graha, super.nirayan, this.gati);

  /// वक्री — सूर्य और चंद्र कभी नहीं; राहु-केतु उलटे ही चलते हैं (स्पष्ट
  /// पात कभी-कभी कुछ दिन सीधा भी), पर उन्हें "वक्री" नहीं लिखा जाता।
  bool get vakri =>
      gati < 0 && graha != KundaliGraha.rahu && graha != KundaliGraha.ketu;
}

/// पूरी कुंडली — एक क्षण, एक जगह।
class Kundali {
  /// जन्म का क्षण, UTC में।
  final DateTime janmUtc;
  final Place place;

  /// लग्न — पूर्वी क्षितिज पर उगता हुआ बिंदु।
  final RashiSthiti lagna;

  /// नौ ग्रह, [KundaliGraha] के क्रम में।
  final List<GrahaSthiti> grahas;

  /// उस क्षण का लाहिड़ी अयनांश, डिग्री।
  final double ayanamsa;

  const Kundali({
    required this.janmUtc,
    required this.place,
    required this.lagna,
    required this.grahas,
    required this.ayanamsa,
  });

  GrahaSthiti operator [](KundaliGraha g) => grahas[g.index];

  /// ग्रह किस भाव में है — 1 से 12, लग्न से गिनकर।
  ///
  /// *एक राशि = एक भाव* — उत्तर भारतीय कुंडली का चलन: लग्न की पूरी राशि
  /// पहला भाव, अगली राशि दूसरा। भाव-चलित यहाँ नहीं है।
  int bhav(KundaliGraha g) => (this[g].rashi - lagna.rashi + 12) % 12 + 1;

  /// चंद्र कुंडली में ग्रह का भाव — चंद्र की राशि से गिनकर।
  int chandraSeBhav(KundaliGraha g) =>
      (this[g].rashi - this[KundaliGraha.chandra].rashi + 12) % 12 + 1;

  /// नवमांश कुंडली में ग्रह का भाव — लग्न के नवमांश से गिनकर।
  int navamshaBhav(KundaliGraha g) =>
      (this[g].navamsha - lagna.navamsha + 12) % 12 + 1;

  /// किसी भाव में बैठे ग्रह (लग्न कुंडली)।
  List<KundaliGraha> bhavMein(int bhavAnk) =>
      [for (final g in KundaliGraha.values) if (bhav(g) == bhavAnk) g];

  /// लग्न राशि की सीमा के इतना पास है कि जन्म-समय के कुछ मिनट इधर-उधर
  /// होने से राशि बदल जाएगी।
  ///
  /// लग्न लगभग 4 मिनट में 1° चलता है। [minute] मिनट की अनिश्चितता मानकर —
  /// सीमा उतने ही अंश के भीतर हो तो `true`। स्क्रीन पर यह **खुली** चेतावनी
  /// बनेगी, ⓘ के पीछे नहीं।
  bool lagnaSandhiMein({double minute = 4}) =>
      lagna.rashiSeemaSeDoori < minute / 4.0;
}

/// स्थानीय **आभासी** नाक्षत्र काल, डिग्री। JD (UT) चाहिए।
///
/// = ग्रीनविच का माध्य नाक्षत्र काल + नतांश का असर (Δψ·cos ε) + देशांतर।
double localSiderealTime(double jdUt, Place place) {
  final jde = toEphemerisTime(jdUt);
  return norm360(greenwichMeanSiderealTime(jdUt) +
      nutationInLongitude(jde) * cosD(trueObliquity(jde)) +
      place.longitude);
}

/// लग्न का **सायन** देशांतर, डिग्री — पूर्वी क्षितिज पर उगता हुआ
/// क्रांतिवृत्त का बिंदु। JD (UT) चाहिए।
///
/// ```
/// λ = atan2( cos θ ,  −(sin θ · cos ε + tan φ · sin ε) )
/// ```
/// θ = स्थानीय नाक्षत्र काल, ε = क्रांतिवृत्त की तिरछाहट, φ = अक्षांश।
///
/// जाँच (`kundali_test.dart`): इस बिंदु की ऊँचाई हर जगह, हर समय शून्य
/// निकलती है और वह पूर्व में होता है — यानी वह सचमुच उग रहा है।
double lagnaSayan(double jdUt, Place place) {
  final theta = localSiderealTime(jdUt, place);
  final eps = trueObliquity(toEphemerisTime(jdUt));
  return norm360(atan2D(
    cosD(theta),
    -(sinD(theta) * cosD(eps) + tanD(place.latitude) * sinD(eps)),
  ));
}

/// लग्न का **निरयन** (लाहिड़ी) देशांतर, डिग्री।
double lagnaNirayan(double jdUt, Place place) =>
    toSidereal(lagnaSayan(jdUt, place), toEphemerisTime(jdUt));

/// किसी क्षण और जगह की कुंडली। [janmUtc] UTC में होना चाहिए।
///
/// सूर्य और चंद्र **वही** हैं जो पंचांग में हैं (`sun.dart`, `moon.dart`) —
/// ताकि जन्म-पंचांग और कुंडली कभी अलग नक्षत्र न बताएँ। पाँच तारा-ग्रह
/// `graha.dart` से।
///
/// [spashtRahu] — राहु औसत पात (डिफ़ॉल्ट) या स्पष्ट पात। कौन सा लेना है, यह
/// अभी तय नहीं (→ [kundaliIsReady]); दोनों इसलिए हैं कि छपी जन्मपत्री से
/// मिलाते वक़्त दोनों सामने रहें।
Kundali computeKundali(DateTime janmUtc, Place place,
    {bool spashtRahu = false}) {
  assert(janmUtc.isUtc, 'जन्म का समय UTC में चाहिए');
  final jdUt = julianDayFromUtc(janmUtc);
  final jde = toEphemerisTime(jdUt);

  double chaal(double Function(double) f) =>
      norm180(f(jde + 0.5) - f(jde - 0.5));

  GrahaSthiti tara(KundaliGraha k, Graha g) =>
      GrahaSthiti(k, grahaNirayan(g, jde), grahaGati(g, jde));

  final rahu = spashtRahu ? rahuSpashtNirayan(jde) : rahuMadhyaNirayan(jde);
  final rahuGati = chaal(spashtRahu ? rahuSpasht : rahuMadhya);

  return Kundali(
    janmUtc: janmUtc,
    place: place,
    lagna: RashiSthiti(lagnaNirayan(jdUt, place)),
    ayanamsa: lahiriAyanamsa(jde),
    grahas: [
      GrahaSthiti(KundaliGraha.surya,
          toSidereal(sunApparentLongitude(jde), jde), chaal(sunApparentLongitude)),
      GrahaSthiti(KundaliGraha.chandra, toSidereal(moonLongitude(jde), jde),
          chaal(moonLongitude)),
      tara(KundaliGraha.mangal, Graha.mangal),
      tara(KundaliGraha.budh, Graha.budh),
      tara(KundaliGraha.guru, Graha.guru),
      tara(KundaliGraha.shukra, Graha.shukra),
      tara(KundaliGraha.shani, Graha.shani),
      GrahaSthiti(KundaliGraha.rahu, rahu, rahuGati),
      GrahaSthiti(KundaliGraha.ketu, ketuSe(rahu), rahuGati),
    ],
  );
}
