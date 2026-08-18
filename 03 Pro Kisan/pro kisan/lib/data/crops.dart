import 'palan/palan_i18n.dart';

/// किस इकाई में खुराक लिखी है।
///
/// ज़्यादातर फ़सलों की सिफ़ारिश **किलो प्रति हेक्टेयर** होती है, पर बाग़ानी
/// फ़सलों (नारियल, काली मिर्च, केला) की सिफ़ारिश **ग्राम प्रति पेड़ प्रति साल**
/// होती है। पहले दोनों को एक ही मानकर गुणा कर दिया जाता था — इससे नारियल पर
/// लगभग 6 गुना ज़्यादा खाद बताई जा रही थी।
enum DoseUnit {
  /// kg / hectare
  perHectare,

  /// gram / plant / year — [Crop.plantsPerHa] से हेक्टेयर में बदलते हैं
  perPlant,
}

/// "बीज" हर फ़सल में बीज नहीं होता — कहीं कंद, कहीं टुकड़े, कहीं पौधे।
enum SeedKind {
  seed,      // सामान्य बीज — किलो
  tuber,     // कंद (आलू, हल्दी, अदरक) — क्विंटल
  setts,     // टुकड़े (गन्ना) — टन + संख्या
  saplings,  // पौधे (केला, नारियल, काली मिर्च) — संख्या
}

/// एक बार खाद डालने का चरण — "कब" और "कितने प्रतिशत"।
///
/// पहले सिर्फ़ लिखा हुआ था ("N: आधा बुवाई पर")। किसान को असली किलो चाहिए,
/// इसलिए अब प्रतिशत रखते हैं और रक़बे के हिसाब से किलो निकाल देते हैं।
class SplitDose {
  final String whenHi;
  final String whenEn;
  /// इस चरण में कुल N / P / K का कितना प्रतिशत (0-100)
  final double nPct;
  final double pPct;
  final double kPct;

  const SplitDose({
    required this.whenHi,
    required this.whenEn,
    required this.nPct,
    this.pPct = 0,
    this.kPct = 0,
  });

  String when(bool isHindi) => isHindi ? whenHi : whenEn;
}

/// Crop fertilizer + seed recommendations.
///
/// पुराने खाने (npk, seedKgHa, splitsHi…) जस के तस हैं ताकि मौजूदा screen
/// चलती रहे। नए खाने सब **वैकल्पिक** हैं — जिस फ़सल का शोध हो चुका है उसमें
/// भरे हैं, बाक़ी में ख़ाली। इसलिए बीच में ऐप कभी नहीं टूटता।
class Crop {
  final String id;
  final String hi;
  final String en;
  final List<double> npkMin;  // [N, P, K] — इकाई [doseUnit] के हिसाब से
  final List<double> npk;     // [N, P, K] — सिफ़ारिश की खुराक
  final List<double> npkMax;  // [N, P, K] — ज़्यादा से ज़्यादा
  final double seedKgHa;
  final String splitsHi;
  final String splitsEn;
  final String season;
  final String seasonEn;

  // ── खुराक की इकाई ──────────────────────────────────────────────
  final DoseUnit doseUnit;
  /// [DoseUnit.perPlant] वाली फ़सलों के लिए — प्रति हेक्टेयर कितने पेड़/बेल
  final int plantsPerHa;

  // ── बीज ────────────────────────────────────────────────────────
  final SeedKind seedKind;
  /// बीज की कम-से-कम / ज़्यादा-से-ज़्यादा मात्रा (kg/ha)। 0 = अभी शोध नहीं हुआ
  final double seedMinKgHa;
  final double seedMaxKgHa;
  final String? spacingHi;
  final String? spacingEn;
  final String? seedTreatHi;
  final String? seedTreatEn;

  // ── सूक्ष्म तत्व और गोबर खाद (kg/ha; FYM टन/ha) ─────────────────
  final double fymTonHa;
  final double sulphurKgHa;
  final double zincSulphateKgHa;
  final double boraxKgHa;

  /// तिलहन/दलहन में DAP की जगह SSP देना चाहिए — उसमें गंधक भी मिलता है।
  final bool preferSSP;

  /// "कब कितना डालें" — ख़ाली हो तो सिर्फ़ [splitsHi] का लिखा हुआ दिखाएँ।
  final List<SplitDose> splitPlan;

  /// आँकड़े कहाँ से आए। ख़ाली = अभी सत्यापित नहीं।
  final String source;

  const Crop({
    required this.id,
    required this.hi,
    required this.en,
    required this.npkMin,
    required this.npk,
    required this.npkMax,
    required this.seedKgHa,
    required this.splitsHi,
    required this.splitsEn,
    required this.season,
    required this.seasonEn,
    this.doseUnit = DoseUnit.perHectare,
    this.plantsPerHa = 0,
    this.seedKind = SeedKind.seed,
    this.seedMinKgHa = 0,
    this.seedMaxKgHa = 0,
    this.spacingHi,
    this.spacingEn,
    this.seedTreatHi,
    this.seedTreatEn,
    this.fymTonHa = 0,
    this.sulphurKgHa = 0,
    this.zincSulphateKgHa = 0,
    this.boraxKgHa = 0,
    this.preferSSP = false,
    this.splitPlan = const [],
    this.source = '',
  });

  /// फ़सल का नाम चुनी भाषा में।
  ///
  /// [lang] दिया हो तो पहले [kCropI18n] की परत देखी जाती है — तमिल किसान को
  /// "கோதுமை", तेलुगु को "గోధుమ"। अनुवाद न मिले तो पहले जैसा ही चलता है
  /// (देवनागरी वालों को [hi], बाक़ी को [en]) — इसलिए अनुवाद टुकड़ों में
  /// जोड़े जा सकते हैं और बीच में कुछ टूटता नहीं।
  String name(bool isHindi, [String lang = '']) {
    if (lang.isNotEmpty) {
      final t = kCropI18n[hi]?[lang];
      if (t != null) return t;
    }
    return isHindi ? hi : en;
  }
  String splits(bool isHindi) => isHindi ? splitsHi : splitsEn;
  String seasonName(bool isHindi) => isHindi ? season : seasonEn;
  String? spacing(bool isHindi) => isHindi ? spacingHi : spacingEn;
  String? seedTreatment(bool isHindi) => isHindi ? seedTreatHi : seedTreatEn;

  /// प्रति-पेड़ वाली खुराक को kg/hectare में बदलने का गुणक।
  /// ग्राम → किलो (÷1000) और प्रति पेड़ → प्रति हेक्टेयर (×पेड़ों की संख्या)।
  double get _toKgPerHa =>
      doseUnit == DoseUnit.perPlant ? plantsPerHa / 1000.0 : 1.0;

  /// हमेशा **kg/hectare** में — गणना इन्हीं का इस्तेमाल करे।
  double get n => npk[0] * _toKgPerHa;
  double get p => npk[1] * _toKgPerHa;
  double get k => npk[2] * _toKgPerHa;

  double get nMin => npkMin[0] * _toKgPerHa;
  double get pMin => npkMin[1] * _toKgPerHa;
  double get kMin => npkMin[2] * _toKgPerHa;

  double get nMax => npkMax[0] * _toKgPerHa;
  double get pMax => npkMax[1] * _toKgPerHa;
  double get kMax => npkMax[2] * _toKgPerHa;

  /// जैसा लिखा गया था, वैसा ही — "प्रति पेड़ 500 ग्राम" दिखाने के लिए।
  double get nRaw => npk[0];
  double get pRaw => npk[1];
  double get kRaw => npk[2];

  bool get isPerPlant => doseUnit == DoseUnit.perPlant;

  /// शोध पूरा हुआ या नहीं — UI इसी से तय करे कि नए खाने दिखाने हैं या नहीं।
  bool get isVerified => source.isNotEmpty;
}

/// NPK nutrient descriptions in simple Hindi for farmers.
class NutrientInfo {
  final String symbol;
  final String nameHi;
  final String nameEn;
  final String descHi;
  final String descEn;
  final String fertilizer;
  final String emoji;

  const NutrientInfo({
    required this.symbol,
    required this.nameHi,
    required this.nameEn,
    required this.descHi,
    required this.descEn,
    required this.fertilizer,
    required this.emoji,
  });

  String name(bool isHindi) => isHindi ? nameHi : nameEn;
  String desc(bool isHindi) => isHindi ? descHi : descEn;
}

const List<NutrientInfo> kNutrientInfo = [
  NutrientInfo(
    symbol: 'N',
    nameHi: 'नाइट्रोजन',
    nameEn: 'Nitrogen',
    descHi: 'पौधे को हरा-भरा और लंबा बनाता है। पत्तियों का विकास करता है।',
    descEn: 'Makes the plant green and tall. Grows the leaves.',
    fertilizer: 'यूरिया',
    emoji: '🌿',
  ),
  NutrientInfo(
    symbol: 'P',
    nameHi: 'फॉस्फोरस',
    nameEn: 'Phosphorus',
    descHi: 'जड़ें मज़बूत करता है, फूल और बीज बनाता है।',
    descEn: 'Strengthens roots, forms flowers and seeds.',
    fertilizer: 'DAP',
    emoji: '🧪',
  ),
  NutrientInfo(
    symbol: 'K',
    nameHi: 'पोटाश',
    nameEn: 'Potash',
    descHi: 'फल मीठा और बड़ा बनाता है, बीमारी से बचाता है।',
    descEn: 'Makes fruit sweet and big, protects from disease.',
    fertilizer: 'MOP',
    emoji: '🔶',
  ),
];

/// 3-tier dose values: कम से कम (~65-70% of recommended),
/// recommended (ICAR standard), ज्यादा से ज्यादा (~125-130% of recommended).
const String _allBasal = 'पूरा उर्वरक बुवाई के समय।';
const String _allBasalEn = 'Apply all fertilizer at sowing.';

const List<Crop> kCrops = [
  // ═══════════════════════════════════════════════════════════════════
  // समूह 1 — अनाज (7)।  स्रोत: ICAR-IIWBR करनाल, ICAR-NRRI कटक,
  // ICAR-IIMR लुधियाना, ICAR-IIMR हैदराबाद (millets.res.in), AICRP
  // ═══════════════════════════════════════════════════════════════════
  Crop(
    id: 'wheat', hi: 'गेहूं', en: 'Wheat',
    // कम = बारानी (बिना सिंचाई), सही = सिंचित समय पर, ज़्यादा = ऊँची उपज वाले क्षेत्र
    npkMin: [60, 30, 20], npk: [120, 60, 40], npkMax: [150, 75, 60],
    seedKgHa: 100, seedMinKgHa: 100, seedMaxKgHa: 125,
    spacingHi: 'कतार 20-22.5 सेमी · गहराई 5 सेमी · देर से बुवाई पर बीज 125 किलो',
    spacingEn: 'Rows 20-22.5 cm · depth 5 cm · late sowing needs 125 kg seed',
    seedTreatHi: 'कार्बेन्डाजिम/थीरम 2 ग्राम या ट्राइकोडर्मा 4 ग्राम प्रति किलो बीज · फिर एज़ोटोबैक्टर + PSB',
    seedTreatEn: 'Carbendazim/Thiram 2 g or Trichoderma 4 g per kg seed · then Azotobacter + PSB',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: आधा बुवाई पर, चौथाई पहली सिंचाई (21 दिन), चौथाई दूसरी सिंचाई (45 दिन)। P व K: पूरा बुवाई के समय।',
    splitsEn: 'N: half at sowing, 1/4 at first irrigation (21 d), 1/4 at second (45 d). P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'पहली सिंचाई — 21 दिन (CRI अवस्था)', whenEn: 'First irrigation — 21 days (CRI)', nPct: 25),
      SplitDose(whenHi: 'दूसरी सिंचाई — 45 दिन', whenEn: 'Second irrigation — 45 days', nPct: 25),
    ],
    fymTonHa: 10, zincSulphateKgHa: 25,
    source: 'ICAR-IIWBR करनाल — सिंचित 120:60:40, बारानी 60:30:20, ज़िंक सल्फ़ेट 25 किलो/हे. (कमी वाली मिट्टी में बुवाई से 15 दिन पहले)',
  ),
  Crop(
    id: 'paddy', hi: 'धान', en: 'Paddy (Rice)',
    npkMin: [80, 40, 40], npk: [120, 60, 60], npkMax: [150, 75, 75],
    seedKgHa: 20, seedMinKgHa: 20, seedMaxKgHa: 25,
    spacingHi: 'रोपाई 20 × 15 सेमी · नर्सरी के लिए 1 हे. हेतु 20-25 किलो बीज · 25-30 दिन की पौध',
    spacingEn: 'Transplant 20 × 15 cm · 20-25 kg seed for 1 ha nursery · 25-30 day seedlings',
    seedTreatHi: 'बीज 8 घंटे पानी में भिगोकर ट्राइकोडर्मा 10 ग्राम प्रति किलो · या कार्बेन्डाजिम 2 ग्राम',
    seedTreatEn: 'Soak seed 8 hours, then Trichoderma 10 g per kg · or Carbendazim 2 g',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: तीन बार (रोपाई, कल्ले फूटते 21 दिन, बाली आते 45 दिन)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (transplanting, tillering 21 d, panicle 45 d). P & K: full at transplanting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'कल्ले फूटते समय — 21 दिन', whenEn: 'Tillering — 21 days', nPct: 25),
      SplitDose(whenHi: 'बाली आते समय — 45 दिन', whenEn: 'Panicle initiation — 45 days', nPct: 25),
    ],
    fymTonHa: 10, zincSulphateKgHa: 25,
    source: 'ICAR-NRRI कटक — 120:60:60; ज़िंक सल्फ़ेट 25 किलो/हे. रोपे खेत में (भारत की 40%+ मिट्टी में ज़िंक की कमी)',
  ),
  Crop(
    id: 'maize', hi: 'मक्का', en: 'Maize',
    npkMin: [80, 40, 25], npk: [120, 60, 40], npkMax: [180, 80, 60],
    seedKgHa: 20, seedMinKgHa: 18, seedMaxKgHa: 25,
    spacingHi: 'कतार 60-75 सेमी × पौधा 20-25 सेमी · गहराई 4-5 सेमी',
    spacingEn: 'Rows 60-75 cm × plants 20-25 cm · depth 4-5 cm',
    seedTreatHi: 'थीरम 3 ग्राम या ट्राइकोडर्मा 10 ग्राम प्रति किलो बीज · एज़ोस्पिरिलम + PSB',
    seedTreatEn: 'Thiram 3 g or Trichoderma 10 g per kg seed · Azospirillum + PSB',
    season: 'खरीफ/रबी', seasonEn: 'Kharif/Rabi',
    splitsHi: 'N: तीन भाग में (बुवाई, घुटने तक 30 दिन, फूल आने पर 50 दिन)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: in 3 splits (sowing, knee-high 30 d, tasseling 50 d). P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 33, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'घुटने तक ऊँचा हो — 30 दिन', whenEn: 'Knee-high stage — 30 days', nPct: 34),
      SplitDose(whenHi: 'फूल/झालर आते समय — 50 दिन', whenEn: 'Tasseling — 50 days', nPct: 33),
    ],
    fymTonHa: 10, zincSulphateKgHa: 25,
    source: 'ICAR-IIMR लुधियाना — संकर मक्का 120-180:60:40; ज़िंक सल्फ़ेट 25 किलो/हे.',
  ),
  // ⚠️ सरसों गंधक-प्रेमी फ़सल है। 40 किलो गंधक से तेल 2% और उपज 25% तक बढ़ती है।
  // इसलिए DAP की जगह SSP — उसमें फ़ॉस्फ़ोरस के साथ गंधक भी आता है।
  Crop(
    id: 'mustard', hi: 'सरसों', en: 'Mustard',
    npkMin: [60, 25, 25], npk: [80, 40, 40], npkMax: [100, 50, 50],
    seedKgHa: 5, seedMinKgHa: 4, seedMaxKgHa: 6,
    spacingHi: 'कतार 30 सेमी × पौधा 10-15 सेमी · गहराई 2-3 सेमी',
    spacingEn: 'Rows 30 cm × plants 10-15 cm · depth 2-3 cm',
    seedTreatHi: 'थीरम या कार्बेन्डाजिम 2.5 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Thiram or Carbendazim 2.5 g per kg seed',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: आधा बुवाई, आधा पहली सिंचाई (30-35 दिन)। P, K व गंधक: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing, half at first irrigation (30-35 days). P, K & S: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'पहली सिंचाई — 30-35 दिन', whenEn: 'First irrigation — 30-35 days', nPct: 50),
    ],
    fymTonHa: 10, sulphurKgHa: 40, zincSulphateKgHa: 25, boraxKgHa: 10,
    preferSSP: true,
    source: 'ICAR-DRMR भरतपुर — N:P:K 80:40:40 (देर से बुवाई 100:50:50), गंधक 40, ज़िंक सल्फ़ेट 25, बोरेक्स 10 किलो/हे.',
  ),
  // ═══════════════════════════════════════════════════════════════════
  // समूह 4 — सब्ज़ी और मसाला (9)।  स्रोत: ICAR-CPRI शिमला, ICAR-DOGR पुणे,
  // ICAR-IIVR वाराणसी, ICAR-IISR कोझिकोड, TNAU
  //
  // ⚠️ आलू, हल्दी, अदरक का "बीज" कंद है — किलो नहीं, **क्विंटल** में सोचिए।
  // ⚠️ गोभी में बोरॉन ज़रूरी है — कमी से फूल का बीच खोखला और भूरा हो जाता है।
  // ═══════════════════════════════════════════════════════════════════
  Crop(
    id: 'potato', hi: 'आलू', en: 'Potato',
    npkMin: [120, 60, 70], npk: [180, 80, 100], npkMax: [240, 100, 130],
    seedKgHa: 2500, seedKind: SeedKind.tuber,
    seedMinKgHa: 2000, seedMaxKgHa: 3000,
    spacingHi: 'कतार 60 सेमी × कंद 20 सेमी · गहराई 5-7 सेमी · बीज 20-30 क्विंटल/हेक्टेयर (कंद 30-40 ग्राम के)',
    spacingEn: 'Rows 60 cm × tubers 20 cm · depth 5-7 cm · seed 20-30 quintal/ha (30-40 g tubers)',
    seedTreatHi: 'कंद को मैंकोज़ेब 0.25% या बोरिक अम्ल 3% के घोल में 10 मिनट डुबोकर छाँव में सुखाएँ',
    seedTreatEn: 'Dip tubers in Mancozeb 0.25% or Boric acid 3% for 10 min, dry in shade',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: आधा बुवाई, आधा मिट्टी चढ़ाते समय (25-30 दिन)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: half at planting, half at earthing-up (25-30 days). P & K: full at planting.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At planting', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'मिट्टी चढ़ाते समय — 25-30 दिन', whenEn: 'At earthing-up — 25-30 days', nPct: 50),
    ],
    fymTonHa: 25,
    source: 'ICAR-CPRI शिमला — जलोढ़ मिट्टी में 180-240 N : 60-90 P₂O₅ : 85-130 K₂O; गोबर खाद 15-30 टन/हे.',
  ),
  // ═══════════════════════════════════════════════════════════════════
  // समूह 2 — दलहन (6)।  स्रोत: ICAR-IIPR कानपुर, DPD भोपाल "Ready Reckoner
  // of Pulses 2020", राज्य कृषि विश्वविद्यालय
  //
  // ⚠️ दलहन अपनी 80% नाइट्रोजन ख़ुद हवा से बनाती है — बशर्ते जड़ों में
  // राइज़ोबियम जीवाणु हों। इसलिए **राइज़ोबियम का बीज उपचार** सबसे सस्ता और
  // सबसे असरदार क़दम है, और इनमें नाइट्रोजन जान-बूझकर कम रखी जाती है।
  // ज़्यादा यूरिया डालने से गाँठें (nodules) बनना बंद हो जाती हैं।
  // ═══════════════════════════════════════════════════════════════════
  Crop(
    id: 'gram', hi: 'चना', en: 'Gram (Chickpea)',
    npkMin: [15, 40, 15], npk: [20, 60, 20], npkMax: [25, 80, 30],
    seedKgHa: 80, seedMinKgHa: 75, seedMaxKgHa: 100,
    spacingHi: 'कतार 30 सेमी × पौधा 10 सेमी · गहराई 5-7 सेमी · देसी 75-80 किलो, काबुली 100 किलो',
    spacingEn: 'Rows 30 cm × plants 10 cm · depth 5-7 cm · desi 75-80 kg, kabuli 100 kg',
    seedTreatHi: 'पहले ट्राइकोडर्मा 5 ग्राम/किलो · फिर राइज़ोबियम + PSB 5-10 ग्राम/किलो बीज (छाँव में सुखाकर तुरंत बोएँ)',
    seedTreatEn: 'First Trichoderma 5 g/kg · then Rhizobium + PSB 5-10 g/kg seed (dry in shade, sow immediately)',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'पूरा उर्वरक बुवाई के समय। यूरिया ज़्यादा मत डालिए — गाँठें बनना रुक जाती हैं।',
    splitsEn: 'All fertilizer at sowing. Do not add extra urea — it stops root nodule formation.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 10, sulphurKgHa: 20,
    preferSSP: true,
    source: 'ICAR-IIPR कानपुर / DPD Ready Reckoner of Pulses — 20:60:20 + गंधक 20 किलो/हे.; चना अपनी 80% नाइट्रोजन राइज़ोबियम से बनाता है',
  ),
  Crop(
    id: 'lentil', hi: 'मसूर', en: 'Lentil',
    npkMin: [15, 30, 15], npk: [20, 40, 20], npkMax: [25, 50, 25],
    seedKgHa: 45, seedMinKgHa: 40, seedMaxKgHa: 60,
    spacingHi: 'कतार 25-30 सेमी · गहराई 4-5 सेमी · छोटा दाना 40-45 किलो, मोटा दाना 55-60 किलो',
    spacingEn: 'Rows 25-30 cm · depth 4-5 cm · small seed 40-45 kg, bold seed 55-60 kg',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम/किलो · फिर राइज़ोबियम + PSB 5-10 ग्राम/किलो बीज',
    seedTreatEn: 'Trichoderma 5 g/kg · then Rhizobium + PSB 5-10 g/kg seed',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'पूरा उर्वरक बुवाई के समय।',
    splitsEn: 'All fertilizer at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 8, sulphurKgHa: 20,
    preferSSP: true,
    source: 'ICAR-IIPR कानपुर — 20:40:20 + गंधक 20 किलो/हे.; बीज दाने के आकार से 40-60 किलो',
  ),
  Crop(
    id: 'pigeonpea', hi: 'अरहर', en: 'Pigeon Pea (Arhar)',
    npkMin: [15, 35, 15], npk: [20, 50, 30], npkMax: [30, 60, 40],
    seedKgHa: 15, seedMinKgHa: 10, seedMaxKgHa: 25,
    spacingHi: 'लंबी अवधि 90 × 30 सेमी (10-15 किलो) · जल्दी पकने वाली 45 × 15 सेमी (20-25 किलो)',
    spacingEn: 'Long duration 90 × 30 cm (10-15 kg) · short duration 45 × 15 cm (20-25 kg)',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम/किलो · फिर राइज़ोबियम + PSB 5-10 ग्राम/किलो बीज',
    seedTreatEn: 'Trichoderma 5 g/kg · then Rhizobium + PSB 5-10 g/kg seed',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'पूरा उर्वरक बुवाई के समय।',
    splitsEn: 'All fertilizer at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 10, sulphurKgHa: 40,
    preferSSP: true,
    source: 'DPD भोपाल Pigeonpea PoP — N:P:K:S = 20:50:30:40 किलो/हे. बुवाई पर; बीज अवधि के हिसाब से 10-25 किलो',
  ),
  // ⚠️ पहले यहाँ seedKgHa: 0 था — ऐप गन्ने का बीज "0" बताता था।
  // गन्ना बीज से नहीं, तीन-आँख वाले टुकड़ों (setts) से बोया जाता है।
  Crop(
    id: 'sugarcane', hi: 'गन्ना', en: 'Sugarcane',
    npkMin: [100, 40, 40], npk: [150, 60, 60], npkMax: [250, 80, 80],
    seedKgHa: 6000, seedKind: SeedKind.setts,
    seedMinKgHa: 5000, seedMaxKgHa: 7500,
    spacingHi: 'कतार 90 सेमी · 35,000-45,000 तीन-आँख वाले टुकड़े प्रति हेक्टेयर',
    spacingEn: 'Rows 90 cm · 35,000-45,000 three-budded setts per hectare',
    seedTreatHi: 'टुकड़ों को कार्बेन्डाजिम (0.1%) के घोल में 10 मिनट डुबोएँ',
    seedTreatEn: 'Dip setts in Carbendazim (0.1%) solution for 10 minutes',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'N: तीन भाग में (बुवाई, 60 दिन, 120 दिन)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: in 3 splits (planting, 60 days, 120 days). P & K: full at planting.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At planting', nPct: 33, pPct: 100, kPct: 100),
      SplitDose(whenHi: '60 दिन बाद (कल्ले फूटते समय)', whenEn: 'After 60 days (tillering)', nPct: 34),
      SplitDose(whenHi: '120 दिन बाद (मिट्टी चढ़ाते समय)', whenEn: 'After 120 days (earthing-up)', nPct: 33),
    ],
    fymTonHa: 25,
    source: 'ICAR-IISR Lucknow / caneadvisory.ac.in — 35,000-45,000 तीन-आँख टुकड़े (≈ 5-7.5 टन/हे.)',
  ),
  Crop(
    id: 'bajra', hi: 'बाजरा', en: 'Pearl Millet (Bajra)',
    npkMin: [40, 20, 20], npk: [80, 40, 40], npkMax: [100, 50, 50],
    // ⚠️ बीज दर बुवाई के तरीक़े से बदलती है — कतार में 4-5, छिटककर 12-15 किलो
    seedKgHa: 5, seedMinKgHa: 4, seedMaxKgHa: 15,
    spacingHi: 'कतार 45 सेमी × पौधा 12-15 सेमी · कतार में बुवाई 4-5 किलो, छिटककर 12-15 किलो',
    spacingEn: 'Rows 45 cm × plants 12-15 cm · line sowing 4-5 kg, broadcast 12-15 kg',
    seedTreatHi: 'थीरम 2 ग्राम प्रति किलो बीज · एज़ोस्पिरिलम मिलाने पर नाइट्रोजन 60 किलो ही काफ़ी',
    seedTreatEn: 'Thiram 2 g per kg seed · with Azospirillum only 60 kg N needed',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: आधा बुवाई, आधा 25-30 दिन बाद। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing, half after 25-30 days. P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '25-30 दिन बाद (निराई के साथ)', whenEn: 'After 25-30 days (with weeding)', nPct: 50),
    ],
    fymTonHa: 8,
    source: 'ICAR-AICRP बाजरा (aicpmip.res.in) / millets.res.in — संकर 80-100:40-50:40-50; बीज: कतार 4-5, छिटककर 12-15 किलो/हे.',
  ),
  Crop(
    id: 'jowar', hi: 'ज्वार', en: 'Sorghum (Jowar)',
    npkMin: [40, 20, 20], npk: [80, 40, 40], npkMax: [100, 50, 50],
    seedKgHa: 10, seedMinKgHa: 8, seedMaxKgHa: 18,
    spacingHi: 'कतार 45 सेमी × पौधा 12-15 सेमी · बारानी 12-18 किलो, सिंचित कतार में 10 किलो',
    spacingEn: 'Rows 45 cm × plants 12-15 cm · rainfed 12-18 kg, irrigated line 10 kg',
    seedTreatHi: 'थीरम 3 ग्राम प्रति किलो बीज · एज़ोस्पिरिलम + एज़ोफ़ॉस',
    seedTreatEn: 'Thiram 3 g per kg seed · Azospirillum + Azophos',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: आधा बुवाई, आधा 30 दिन बाद। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing, half after 30 days. P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 50),
    ],
    fymTonHa: 12.5,
    source: 'ICAR-IIMR हैदराबाद — 80:40:40; गोबर खाद 12.5 टन/हे.; बीज बारानी 12-18, सिंचित 10 किलो/हे.',
  ),
  Crop(
    id: 'groundnut', hi: 'मूंगफली', en: 'Groundnut',
    npkMin: [15, 40, 25], npk: [20, 60, 40], npkMax: [25, 80, 50],
    seedKgHa: 100, seedMinKgHa: 80, seedMaxKgHa: 120,
    spacingHi: 'कतार 30 सेमी × पौधा 10 सेमी · गहराई 5 सेमी',
    spacingEn: 'Rows 30 cm × plants 10 cm · depth 5 cm',
    seedTreatHi: 'राइज़ोबियम + PSB 5 ग्राम/किलो बीज · ट्राइकोडर्मा 5 ग्राम/किलो',
    seedTreatEn: 'Rhizobium + PSB 5 g/kg seed · Trichoderma 5 g/kg',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: _allBasal, splitsEn: _allBasalEn,
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 10, sulphurKgHa: 30, boraxKgHa: 5,
    preferSSP: true,
    source: 'ICAR-DGR जूनागढ़ — गंधक 30 किलो/हे. (जिप्सम 200 किलो), बोरॉन 5 किलो',
  ),
  Crop(
    id: 'soybean', hi: 'सोयाबीन', en: 'Soybean',
    npkMin: [20, 40, 25], npk: [30, 60, 40], npkMax: [40, 80, 50],
    seedKgHa: 75, seedMinKgHa: 65, seedMaxKgHa: 80,
    spacingHi: 'कतार 45 सेमी × पौधा 5 सेमी · गहराई 3-4 सेमी',
    spacingEn: 'Rows 45 cm × plants 5 cm · depth 3-4 cm',
    seedTreatHi: 'राइज़ोबियम जपोनिकम + PSB 5 ग्राम/किलो बीज',
    seedTreatEn: 'Rhizobium japonicum + PSB 5 g/kg seed',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: _allBasal, splitsEn: _allBasalEn,
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 10, sulphurKgHa: 25,
    preferSSP: true,
    source: 'ICAR-IISR इंदौर — गंधक 20-30 किलो/हे., राइज़ोबियम बीज उपचार अनिवार्य',
  ),
  Crop(
    id: 'onion', hi: 'प्याज', en: 'Onion',
    npkMin: [70, 35, 35], npk: [100, 50, 50], npkMax: [130, 65, 65],
    seedKgHa: 8, seedMinKgHa: 7, seedMaxKgHa: 10,
    spacingHi: 'रोपाई 15 × 10 सेमी · 1 हेक्टेयर के लिए नर्सरी हेतु 7-10 किलो बीज · 6-7 हफ़्ते की पौध',
    spacingEn: 'Transplant 15 × 10 cm · 7-10 kg seed for 1 ha nursery · 6-7 week seedlings',
    seedTreatHi: 'थीरम/कार्बेन्डाजिम 2 ग्राम प्रति किलो बीज · ट्राइकोडर्मा 5 ग्राम',
    seedTreatEn: 'Thiram/Carbendazim 2 g per kg seed · Trichoderma 5 g',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: तीन भाग में (रोपाई, 30 दिन, 45 दिन)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (transplanting, 30 d, 45 d). P & K: full at transplanting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 34, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 33),
      SplitDose(whenHi: '45 दिन बाद', whenEn: 'After 45 days', nPct: 33),
    ],
    fymTonHa: 20, sulphurKgHa: 30,
    source: 'ICAR-DOGR पुणे — 100:50:50; गंधक 15 किलो (मिट्टी में गंधक 25 से ऊपर) या 30 किलो (25 से नीचे); N तीन भाग में — रोपाई, 30 व 45 दिन',
  ),
  Crop(
    id: 'tomato', hi: 'टमाटर', en: 'Tomato',
    npkMin: [80, 40, 40], npk: [120, 60, 60], npkMax: [200, 100, 100],
    seedKgHa: 0.4, seedMinKgHa: 0.3, seedMaxKgHa: 0.5,
    spacingHi: 'रोपाई 60 × 45 सेमी · 1 हेक्टेयर के लिए नर्सरी हेतु 300-500 ग्राम बीज · 25-30 दिन की पौध',
    spacingEn: 'Transplant 60 × 45 cm · 300-500 g seed for 1 ha nursery · 25-30 day seedlings',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम या थीरम 2 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Trichoderma 5 g or Thiram 2 g per kg seed',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'N: तीन भाग में (रोपाई, 30 दिन, फूल आते समय)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (transplanting, 30 d, flowering). P & K: full at transplanting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 34, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 33),
      SplitDose(whenHi: 'फूल आते समय — 50-55 दिन', whenEn: 'At flowering — 50-55 days', nPct: 33),
    ],
    fymTonHa: 25, boraxKgHa: 10,
    source: 'ICAR-IIVR वाराणसी / TNAU — देसी 120:60:60, संकर 200:100:100; बोरेक्स 10 किलो/हे. (फल फटने से बचाव)',
  ),

  // ---- 15 new crops (South/East/West India + cash & horticulture) ----
  Crop(
    id: 'ragi', hi: 'रागी (मंडुआ)', en: 'Finger Millet (Ragi)',
    npkMin: [40, 20, 20], npk: [60, 30, 30], npkMax: [80, 40, 40],
    seedKgHa: 8, seedMinKgHa: 4, seedMaxKgHa: 10,
    spacingHi: 'रोपाई 22.5 × 10 सेमी · छिटककर 8-10 किलो, कतार में 8 किलो, रोपाई के लिए 4-6 किलो',
    spacingEn: 'Transplant 22.5 × 10 cm · broadcast 8-10 kg, line 8 kg, transplanting 4-6 kg',
    seedTreatHi: 'कार्बेन्डाजिम 2 ग्राम प्रति किलो बीज · एज़ोस्पिरिलम + PSB',
    seedTreatEn: 'Carbendazim 2 g per kg seed · Azospirillum + PSB',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: आधा बुवाई/रोपाई पर, आधा 25-30 दिन बाद। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing/transplanting, half after 25-30 days. P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई/रोपाई के दिन', whenEn: 'At sowing/transplanting', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '25-30 दिन बाद', whenEn: 'After 25-30 days', nPct: 50),
    ],
    fymTonHa: 10,
    source: 'ICAR-IIMR / AICRP छोटे अनाज — मिट्टी जाँच न हो तो 60:30:30 kg/ha; बीज विधि के हिसाब से 4-10 किलो',
  ),
  Crop(
    id: 'barley', hi: 'जौ', en: 'Barley',
    npkMin: [40, 20, 15], npk: [60, 30, 20], npkMax: [90, 45, 30],
    seedKgHa: 90, seedMinKgHa: 75, seedMaxKgHa: 100,
    spacingHi: 'कतार 22.5 सेमी · गहराई 5 सेमी · देर से बुवाई पर 100 किलो बीज',
    spacingEn: 'Rows 22.5 cm · depth 5 cm · late sowing 100 kg seed',
    seedTreatHi: 'थीरम/कार्बेन्डाजिम 2 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Thiram/Carbendazim 2 g per kg seed',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: आधा बुवाई, आधा पहली सिंचाई (30-35 दिन)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing, half at first irrigation (30-35 days). P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'पहली सिंचाई — 30-35 दिन', whenEn: 'First irrigation — 30-35 days', nPct: 50),
    ],
    fymTonHa: 10,
    source: 'ICAR-IIWBR करनाल (जौ भी यहीं से) — सिंचित 60:30:20, बारानी 40:20:15',
  ),
  Crop(
    id: 'moong', hi: 'मूंग', en: 'Green Gram (Moong)',
    npkMin: [10, 30, 15], npk: [20, 40, 20], npkMax: [25, 50, 25],
    // ⚠️ खरीफ में 15-20 किलो, पर गर्मी/रबी में 25-30 किलो चाहिए
    seedKgHa: 20, seedMinKgHa: 15, seedMaxKgHa: 30,
    spacingHi: 'खरीफ: कतार 45 सेमी, बीज 15-20 किलो · गर्मी/रबी: कतार 30 सेमी, बीज 25-30 किलो',
    spacingEn: 'Kharif: rows 45 cm, seed 15-20 kg · Summer/Rabi: rows 30 cm, seed 25-30 kg',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम/किलो · फिर राइज़ोबियम + PSB 5-10 ग्राम/किलो बीज',
    seedTreatEn: 'Trichoderma 5 g/kg · then Rhizobium + PSB 5-10 g/kg seed',
    season: 'खरीफ/ज़ायद', seasonEn: 'Kharif/Zaid',
    splitsHi: 'पूरा उर्वरक बुवाई के समय।',
    splitsEn: 'All fertilizer at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 8, sulphurKgHa: 20,
    preferSSP: true,
    source: 'ICAR-IIPR / DPD — 20:40:20 + गंधक 20; बीज खरीफ 15-20, गर्मी 25-30 किलो/हे.',
  ),
  Crop(
    id: 'urad', hi: 'उड़द', en: 'Black Gram (Urad)',
    npkMin: [10, 30, 15], npk: [20, 40, 40], npkMax: [25, 50, 50],
    seedKgHa: 20, seedMinKgHa: 15, seedMaxKgHa: 25,
    spacingHi: 'कतार 30-45 सेमी × पौधा 10 सेमी · गहराई 4-5 सेमी',
    spacingEn: 'Rows 30-45 cm × plants 10 cm · depth 4-5 cm',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम/किलो · फिर राइज़ोबियम + PSB 5-10 ग्राम/किलो बीज',
    seedTreatEn: 'Trichoderma 5 g/kg · then Rhizobium + PSB 5-10 g/kg seed',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'पूरा उर्वरक बुवाई के समय।',
    splitsEn: 'All fertilizer at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन (पूरा)', whenEn: 'At sowing (full dose)', nPct: 100, pPct: 100, kPct: 100),
    ],
    fymTonHa: 8, sulphurKgHa: 20,
    preferSSP: true,
    source: 'indiaagronet / DPD Ready Reckoner — उड़द 20:40:40 किलो/हे. + गंधक 20',
  ),
  Crop(
    id: 'sesame', hi: 'तिल', en: 'Sesame (Til)',
    npkMin: [30, 15, 15], npk: [40, 20, 20], npkMax: [60, 30, 30],
    seedKgHa: 5, seedMinKgHa: 3, seedMaxKgHa: 6,
    spacingHi: 'कतार 30 सेमी × पौधा 10-15 सेमी · गहराई 2-3 सेमी',
    spacingEn: 'Rows 30 cm × plants 10-15 cm · depth 2-3 cm',
    seedTreatHi: 'थीरम 2 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Thiram 2 g per kg seed',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: आधा बुवाई, आधा 30 दिन बाद। P, K व गंधक: पूरा बुवाई पर।',
    splitsEn: 'N: half at sowing, half after 30 days. P, K & S: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 50),
    ],
    fymTonHa: 8, sulphurKgHa: 20,
    preferSSP: true,
    source: 'ICAR-IIOR हैदराबाद — गंधक 20 किलो/हे.',
  ),
  // ⚠️ कपास में बीज दर किस्म से बहुत बदलती है — देसी/सीधी किस्म 15-20 किलो,
  // पर Bt संकर सिर्फ़ 1.5-2 किलो (450 ग्राम के 3-4 पैकेट)। पहले सिर्फ़ "15"
  // लिखा था, जिससे Bt बोने वाला किसान 8 गुना ज़्यादा बीज ख़रीद लेता।
  Crop(
    id: 'cotton', hi: 'कपास', en: 'Cotton',
    npkMin: [60, 30, 30], npk: [120, 60, 60], npkMax: [160, 80, 80],
    seedKgHa: 2, seedMinKgHa: 1.5, seedMaxKgHa: 20,
    spacingHi: 'Bt संकर: 90-120 × 60 सेमी, बीज 1.5-2 किलो (450 ग्राम के 3-4 पैकेट) · देसी: 60 × 30 सेमी, बीज 15-20 किलो',
    spacingEn: 'Bt hybrid: 90-120 × 60 cm, seed 1.5-2 kg (3-4 packets of 450 g) · Desi: 60 × 30 cm, seed 15-20 kg',
    seedTreatHi: 'Bt बीज पहले से उपचारित आता है — दोबारा मत कीजिए। देसी बीज: थीरम 3 ग्राम + एज़ोटोबैक्टर प्रति किलो',
    seedTreatEn: 'Bt seed comes pre-treated — do not re-treat. Desi seed: Thiram 3 g + Azotobacter per kg',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: तीन भाग में (बुवाई, 30-40 दिन फूल आते, 60-70 दिन बॉल बनते)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: in 3 splits (sowing, 30-40 d flowering, 60-70 d boll formation). P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 33, pPct: 100, kPct: 100),
      SplitDose(whenHi: 'फूल आते समय — 30-40 दिन', whenEn: 'Flowering — 30-40 days', nPct: 34),
      SplitDose(whenHi: 'बॉल बनते समय — 60-70 दिन', whenEn: 'Boll formation — 60-70 days', nPct: 33),
    ],
    fymTonHa: 5, zincSulphateKgHa: 25,
    source: 'ICAR-CICR नागपुर (POP-RJ-01) — बारानी 60:30:30, सिंचित 120:60:60; गोबर खाद 5 टन/हे. हर साल; नाइट्रोजन सबसे ज़्यादा असर डालती है (कमी से 28% उपज घटती है)',
  ),
  Crop(
    id: 'turmeric', hi: 'हल्दी', en: 'Turmeric',
    npkMin: [40, 30, 60], npk: [60, 50, 100], npkMax: [80, 60, 120],
    seedKgHa: 2000, seedKind: SeedKind.tuber,
    seedMinKgHa: 1500, seedMaxKgHa: 2500,
    spacingHi: 'कतार 30 सेमी × गाँठ 20 सेमी · गहराई 5 सेमी · बीज 15-25 क्विंटल/हेक्टेयर (गाँठ 25-30 ग्राम की)',
    spacingEn: 'Rows 30 cm × rhizomes 20 cm · depth 5 cm · seed 15-25 quintal/ha (25-30 g rhizomes)',
    seedTreatHi: 'गाँठों को मैंकोज़ेब 0.3% + क्विनालफ़ॉस 0.075% के घोल में 30 मिनट डुबोएँ',
    seedTreatEn: 'Dip rhizomes in Mancozeb 0.3% + Quinalphos 0.075% for 30 minutes',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N व K: तीन भाग में (रोपाई, 45 दिन, 90 दिन)। P: पूरा रोपाई पर।',
    splitsEn: 'N & K: in 3 splits (planting, 45 d, 90 d). P: full at planting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At planting', nPct: 34, pPct: 100, kPct: 34),
      SplitDose(whenHi: '45 दिन बाद (मिट्टी चढ़ाते समय)', whenEn: 'After 45 days (earthing-up)', nPct: 33, kPct: 33),
      SplitDose(whenHi: '90 दिन बाद', whenEn: 'After 90 days', nPct: 33, kPct: 33),
    ],
    fymTonHa: 30,
    source: 'ICAR-IISR कोझिकोड — 60:50:100 (पोटाश सबसे ज़्यादा); बीज गाँठ 15-25 क्विंटल/हे.; गोबर खाद 30 टन/हे.',
  ),
  Crop(
    id: 'ginger', hi: 'अदरक', en: 'Ginger',
    npkMin: [50, 30, 30], npk: [75, 50, 50], npkMax: [100, 60, 60],
    seedKgHa: 1500, seedKind: SeedKind.tuber,
    seedMinKgHa: 1200, seedMaxKgHa: 1800,
    spacingHi: 'कतार 25 सेमी × गाँठ 20 सेमी · गहराई 4-5 सेमी · बीज 12-18 क्विंटल/हेक्टेयर (गाँठ 20-25 ग्राम की)',
    spacingEn: 'Rows 25 cm × rhizomes 20 cm · depth 4-5 cm · seed 12-18 quintal/ha (20-25 g rhizomes)',
    seedTreatHi: 'गाँठों को मैंकोज़ेब 0.3% के घोल में 30 मिनट डुबोकर छाँव में सुखाएँ',
    seedTreatEn: 'Dip rhizomes in Mancozeb 0.3% for 30 minutes, dry in shade',
    season: 'खरीफ', seasonEn: 'Kharif',
    splitsHi: 'N: तीन भाग में (रोपाई, 45 दिन, 90 दिन)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (planting, 45 d, 90 d). P & K: full at planting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At planting', nPct: 34, pPct: 100, kPct: 100),
      SplitDose(whenHi: '45 दिन बाद (मिट्टी चढ़ाते समय)', whenEn: 'After 45 days (earthing-up)', nPct: 33),
      SplitDose(whenHi: '90 दिन बाद', whenEn: 'After 90 days', nPct: 33),
    ],
    fymTonHa: 30,
    source: 'ICAR-IISR कोझिकोड — 75:50:50; बीज गाँठ 12-18 क्विंटल/हे.; गोबर खाद 25-30 टन/हे.',
  ),
  Crop(
    id: 'chilli', hi: 'मिर्च', en: 'Chilli',
    npkMin: [60, 30, 30], npk: [100, 50, 50], npkMax: [150, 75, 75],
    seedKgHa: 1, seedMinKgHa: 1, seedMaxKgHa: 1.5,
    spacingHi: 'रोपाई 60 × 45 सेमी · 1 हेक्टेयर के लिए नर्सरी हेतु 1-1.5 किलो बीज · 35-40 दिन की पौध',
    spacingEn: 'Transplant 60 × 45 cm · 1-1.5 kg seed for 1 ha nursery · 35-40 day seedlings',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम या थीरम 2 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Trichoderma 5 g or Thiram 2 g per kg seed',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'N: तीन भाग में (रोपाई, 30 दिन, 60 दिन)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (transplanting, 30 d, 60 d). P & K: full at transplanting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 34, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 33),
      SplitDose(whenHi: '60 दिन बाद', whenEn: 'After 60 days', nPct: 33),
    ],
    fymTonHa: 25,
    source: 'ICAR-IIVR वाराणसी — 100:50:50 (संकर 150:75:75); नर्सरी हेतु 1-1.5 किलो बीज/हे.',
  ),
  // ⚠️ गोभी में बोरॉन की कमी सबसे आम है — तना खोखला हो जाता है और बीच भूरा।
  Crop(
    id: 'cabbage', hi: 'पत्ता गोभी', en: 'Cabbage',
    npkMin: [80, 40, 40], npk: [120, 60, 60], npkMax: [150, 80, 80],
    seedKgHa: 0.5, seedMinKgHa: 0.4, seedMaxKgHa: 0.6,
    spacingHi: 'रोपाई 45 × 45 सेमी · 1 हेक्टेयर के लिए नर्सरी हेतु 400-600 ग्राम बीज · 4-5 हफ़्ते की पौध',
    spacingEn: 'Transplant 45 × 45 cm · 400-600 g seed for 1 ha nursery · 4-5 week seedlings',
    seedTreatHi: 'थीरम 2 ग्राम या ट्राइकोडर्मा 5 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Thiram 2 g or Trichoderma 5 g per kg seed',
    season: 'रबी', seasonEn: 'Rabi',
    splitsHi: 'N: दो भाग में (रोपाई, 30 दिन)। P व K: पूरा रोपाई पर। बोरेक्स ज़रूर डालें।',
    splitsEn: 'N: in 2 splits (transplanting, 30 d). P & K: full at transplanting. Borax is essential.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 50),
    ],
    fymTonHa: 25, boraxKgHa: 10,
    source: 'ICAR — 120:60:60; बोरेक्स 10 किलो/हे. (≈ 1 किलो बोरॉन)। बोरॉन की कमी से तना खोखला और बीच भूरा हो जाता है',
  ),
  Crop(
    id: 'brinjal', hi: 'बैंगन', en: 'Brinjal (Eggplant)',
    npkMin: [70, 35, 35], npk: [100, 50, 50], npkMax: [150, 75, 75],
    seedKgHa: 0.4, seedMinKgHa: 0.35, seedMaxKgHa: 0.5,
    spacingHi: 'रोपाई 60 × 60 सेमी · 1 हेक्टेयर के लिए नर्सरी हेतु 350-500 ग्राम बीज · 30-35 दिन की पौध',
    spacingEn: 'Transplant 60 × 60 cm · 350-500 g seed for 1 ha nursery · 30-35 day seedlings',
    seedTreatHi: 'ट्राइकोडर्मा 5 ग्राम या थीरम 2 ग्राम प्रति किलो बीज',
    seedTreatEn: 'Trichoderma 5 g or Thiram 2 g per kg seed',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'N: तीन भाग में (रोपाई, 30 दिन, 60 दिन)। P व K: पूरा रोपाई पर।',
    splitsEn: 'N: in 3 splits (transplanting, 30 d, 60 d). P & K: full at transplanting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At transplanting', nPct: 34, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद', whenEn: 'After 30 days', nPct: 33),
      SplitDose(whenHi: '60 दिन बाद', whenEn: 'After 60 days', nPct: 33),
    ],
    fymTonHa: 25,
    source: 'ICAR-IIVR वाराणसी — 100:50:50 (संकर 150:75:75); नर्सरी हेतु 350-500 ग्राम बीज/हे.',
  ),
  // ⚠️ भिंडी की बीज दर मौसम से दोगुनी हो जाती है — गर्मी में अंकुरण कम होता है।
  Crop(
    id: 'okra', hi: 'भिंडी', en: 'Okra (Lady Finger)',
    npkMin: [40, 20, 20], npk: [60, 30, 30], npkMax: [100, 50, 50],
    seedKgHa: 10, seedMinKgHa: 8, seedMaxKgHa: 18,
    spacingHi: 'खरीफ: 60 × 30 सेमी, बीज 8-10 किलो · गर्मी (ज़ायद): 45 × 30 सेमी, बीज 15-18 किलो',
    spacingEn: 'Kharif: 60 × 30 cm, seed 8-10 kg · Summer (Zaid): 45 × 30 cm, seed 15-18 kg',
    seedTreatHi: 'बीज को 24 घंटे पानी में भिगोएँ · फिर थीरम 3 ग्राम प्रति किलो',
    seedTreatEn: 'Soak seed 24 hours · then Thiram 3 g per kg',
    season: 'ज़ायद/खरीफ', seasonEn: 'Zaid/Kharif',
    splitsHi: 'N: दो भाग में (बुवाई, 30 दिन)। P व K: पूरा बुवाई पर।',
    splitsEn: 'N: in 2 splits (sowing, 30 d). P & K: full at sowing.',
    splitPlan: [
      SplitDose(whenHi: 'बुवाई के दिन', whenEn: 'At sowing', nPct: 50, pPct: 100, kPct: 100),
      SplitDose(whenHi: '30 दिन बाद (पहली तुड़ाई से पहले)', whenEn: 'After 30 days (before first picking)', nPct: 50),
    ],
    fymTonHa: 20, boraxKgHa: 5,
    source: 'ICAR-IIVR वाराणसी — 60:30:30 से 100:50:50; बीज खरीफ 8-10, गर्मी 15-18 किलो/हे.; बोरॉन 0.5-1 किलो/हे.',
  ),
  // ⚠️ नीचे की तीन बाग़ानी फ़सलों की सिफ़ारिश **ग्राम प्रति पेड़ प्रति साल** है,
  // किलो प्रति हेक्टेयर नहीं। पहले इन्हें kg/ha मानकर रक़बे से गुणा किया जा रहा
  // था — इससे नारियल पर लगभग 6 गुना ज़्यादा खाद बताई जा रही थी।
  // अब `doseUnit: perPlant` + `plantsPerHa` से सही हेक्टेयर-खुराक निकलती है।
  Crop(
    id: 'banana', hi: 'केला', en: 'Banana',
    npkMin: [150, 60, 200], npk: [200, 60, 300], npkMax: [250, 90, 400],
    doseUnit: DoseUnit.perPlant, plantsPerHa: 2500,
    seedKgHa: 0, seedKind: SeedKind.saplings,
    spacingHi: '1.8 × 1.8 मीटर (≈ 2,500 पौधे/हेक्टेयर)',
    spacingEn: '1.8 × 1.8 m (≈ 2,500 plants/ha)',
    seedTreatHi: 'बीज नहीं — रोग-मुक्त सकर या टिश्यू-कल्चर पौध लगाएँ (गड्ढा 45×45×45 सेमी)',
    seedTreatEn: 'No seed — plant disease-free suckers or tissue-culture plants (pit 45×45×45 cm)',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'N व K: चार भागों में (रोपाई के 2, 4, 6, 8 माह बाद)। P: पूरा रोपाई पर।',
    splitsEn: 'N & K: in 4 splits (2, 4, 6, 8 months after planting). P: full at planting.',
    splitPlan: [
      SplitDose(whenHi: 'रोपाई के दिन', whenEn: 'At planting', nPct: 0, pPct: 100, kPct: 0),
      SplitDose(whenHi: '2 माह बाद', whenEn: 'After 2 months', nPct: 25, kPct: 25),
      SplitDose(whenHi: '4 माह बाद', whenEn: 'After 4 months', nPct: 25, kPct: 25),
      SplitDose(whenHi: '6 माह बाद', whenEn: 'After 6 months', nPct: 25, kPct: 25),
      SplitDose(whenHi: '8 माह बाद', whenEn: 'After 8 months', nPct: 25, kPct: 25),
    ],
    fymTonHa: 25,
    source: 'ICAR / NRCB Trichy — 200 g N, 60-70 g P₂O₅, 300 g K₂O प्रति पौधा',
  ),
  Crop(
    id: 'coconut', hi: 'नारियल', en: 'Coconut',
    npkMin: [300, 200, 800], npk: [500, 320, 1200], npkMax: [700, 400, 1400],
    doseUnit: DoseUnit.perPlant, plantsPerHa: 175,
    seedKgHa: 0, seedKind: SeedKind.saplings,
    spacingHi: '7.5 × 7.5 मीटर (≈ 175 पेड़/हेक्टेयर)',
    spacingEn: '7.5 × 7.5 m (≈ 175 palms/ha)',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'प्रति पेड़ साल में दो बार — मानसून से पहले (मई-जून) और बाद (सितंबर)।',
    splitsEn: 'Per palm, twice a year — pre-monsoon (May-June) and post-monsoon (September).',
    splitPlan: [
      SplitDose(whenHi: 'मानसून से पहले — मई-जून', whenEn: 'Pre-monsoon — May-June', nPct: 33, pPct: 100, kPct: 33),
      SplitDose(whenHi: 'मानसून के बाद — सितंबर', whenEn: 'Post-monsoon — September', nPct: 67, kPct: 67),
    ],
    seedTreatHi: 'बीज नहीं — 9-12 माह की स्वस्थ पौध लगाएँ (गड्ढा 1×1×1 मीटर)',
    seedTreatEn: 'No seed — plant healthy 9-12 month seedlings (pit 1×1×1 m)',
    fymTonHa: 8.75, // 50 kg/पेड़ × 175 पेड़
    source: 'ICAR-CPCRI — 500 g N, 320 g P₂O₅, 1200 g K₂O प्रति पेड़ प्रति साल + 50 किलो गोबर खाद',
  ),
  Crop(
    id: 'blackpepper', hi: 'काली मिर्च', en: 'Black Pepper',
    npkMin: [50, 25, 100], npk: [100, 40, 140], npkMax: [140, 55, 270],
    doseUnit: DoseUnit.perPlant, plantsPerHa: 1100,
    seedKgHa: 0, seedKind: SeedKind.saplings,
    spacingHi: '3 × 3 मीटर सहारे के पेड़ के साथ (≈ 1,100 बेल/हेक्टेयर)',
    spacingEn: '3 × 3 m with support tree (≈ 1,100 vines/ha)',
    season: 'सालभर', seasonEn: 'Year-round',
    splitsHi: 'प्रति बेल दो भागों में — मई-जून और सितंबर-अक्टूबर।',
    splitsEn: 'Per vine in 2 splits — May-June and September-October.',
    splitPlan: [
      SplitDose(whenHi: 'मई-जून (मानसून से पहले)', whenEn: 'May-June (pre-monsoon)', nPct: 50, pPct: 100, kPct: 50),
      SplitDose(whenHi: 'सितंबर-अक्टूबर', whenEn: 'September-October', nPct: 50, kPct: 50),
    ],
    seedTreatHi: 'बीज नहीं — जड़दार कटिंग (2-3 गाँठ वाली) लगाएँ, सहारे के पेड़ के साथ',
    seedTreatEn: 'No seed — plant rooted cuttings (2-3 nodes) along a support tree',
    fymTonHa: 11, // 10 kg/बेल × 1100
    source: 'ICAR-IISR Kozhikode — 100 g N, 40 g P₂O₅, 140 g K₂O प्रति बेल',
  ),
];

/// Fertilizer bag sizes (kg per bag).
const double kUreaBagKg = 45;
const double kDapBagKg = 50;
const double kMopBagKg = 50;

/// SSP = सिंगल सुपर फ़ॉस्फ़ेट — 16% P₂O₅ **और 11% गंधक**।
/// तिलहन-दलहन में DAP की जगह यही देना चाहिए।
const double kSspBagKg = 50;
const double kSspP2O5 = 0.16;
const double kSspSulphur = 0.11;

/// Result of a fertilizer-dose calculation.
class KhaadResult {
  final double ureaKg;
  final double dapKg;
  final double mopKg;

  /// SSP रास्ता (तिलहन-दलहन के लिए) — DAP के बजाय।
  /// [sspKg] = 0 हो तो यह रास्ता नहीं दिखाना।
  final double sspKg;
  /// SSP लेने पर बचा हुआ यूरिया (SSP में नाइट्रोजन नहीं होती, इसलिए ज़्यादा)
  final double ureaWithSspKg;
  /// SSP से मुफ़्त में मिलने वाला गंधक (किलो)
  final double sulphurFromSspKg;
  /// फिर भी कितना गंधक अलग से चाहिए (जिप्सम/बेंटोनाइट से)
  final double gypsumKg;

  const KhaadResult(
    this.ureaKg,
    this.dapKg,
    this.mopKg, {
    this.sspKg = 0,
    this.ureaWithSspKg = 0,
    this.sulphurFromSspKg = 0,
    this.gypsumKg = 0,
  });

  double get ureaBags => ureaKg / kUreaBagKg;
  double get dapBags => dapKg / kDapBagKg;
  double get mopBags => mopKg / kMopBagKg;
  double get sspBags => sspKg / kSspBagKg;
  double get ureaWithSspBags => ureaWithSspKg / kUreaBagKg;

  bool get hasSspRoute => sspKg > 0;
}

/// 3-tier result — minimum, recommended, maximum.
class KhaadResult3Tier {
  final KhaadResult min;
  final KhaadResult recommended;
  final KhaadResult max;
  const KhaadResult3Tier(this.min, this.recommended, this.max);
}

/// Compute urea/DAP/MOP for a given N, P2O5, K2O requirement (already scaled to area).
/// DAP supplies P (46%) and some N (18%); urea supplies the remaining N (46%);
/// MOP supplies K (60%).
///
/// [sulphurNeedKg] दिया हो तो SSP वाला दूसरा रास्ता भी निकालता है — SSP में
/// 16% फ़ॉस्फ़ोरस के साथ 11% गंधक होता है, इसलिए तिलहन-दलहन के लिए वही सही है।
KhaadResult computeKhaad({
  required double n,
  required double p,
  required double k,
  double sulphurNeedKg = 0,
  bool preferSSP = false,
}) {
  final dap = p / 0.46;
  final nFromDap = dap * 0.18;
  var urea = (n - nFromDap) / 0.46;
  if (urea < 0) urea = 0;
  final mop = k / 0.60;

  double ssp = 0, ureaWithSsp = 0, sFromSsp = 0, gypsum = 0;
  if (preferSSP && p > 0) {
    ssp = p / kSspP2O5;
    // SSP में नाइट्रोजन नहीं होती, इसलिए पूरी N यूरिया से
    ureaWithSsp = n / 0.46;
    sFromSsp = ssp * kSspSulphur;
    // गंधक अब भी कम पड़े तो जिप्सम से (जिप्सम में ≈18.6% गंधक)
    final short = sulphurNeedKg - sFromSsp;
    gypsum = short > 0 ? short / 0.186 : 0;
  } else if (sulphurNeedKg > 0) {
    gypsum = sulphurNeedKg / 0.186;
  }

  return KhaadResult(
    _round05(urea),
    _round05(dap),
    _round05(mop),
    sspKg: _round05(ssp),
    ureaWithSspKg: _round05(ureaWithSsp),
    sulphurFromSspKg: _round05(sFromSsp),
    gypsumKg: _round05(gypsum),
  );
}

/// Compute all 3 tiers at once.
KhaadResult3Tier computeKhaad3Tier({
  required Crop crop,
  required double areaHa,
}) {
  final s = crop.sulphurKgHa * areaHa;
  KhaadResult t(double n, double p, double k) => computeKhaad(
        n: n * areaHa,
        p: p * areaHa,
        k: k * areaHa,
        sulphurNeedKg: s,
        preferSSP: crop.preferSSP,
      );
  return KhaadResult3Tier(
    t(crop.nMin, crop.pMin, crop.kMin),
    t(crop.n, crop.p, crop.k),
    t(crop.nMax, crop.pMax, crop.kMax),
  );
}

/// गोबर खाद + सूक्ष्म तत्व — रक़बे के हिसाब से।
class ExtraInputs {
  final double fymTon;          // गोबर की खाद (टन)
  final double zincSulphateKg;  // ज़िंक सल्फ़ेट (किलो)
  final double boraxKg;         // बोरेक्स (किलो)
  final double sulphurKg;       // कुल गंधक की ज़रूरत (किलो)
  const ExtraInputs(this.fymTon, this.zincSulphateKg, this.boraxKg, this.sulphurKg);

  bool get isEmpty =>
      fymTon == 0 && zincSulphateKg == 0 && boraxKg == 0 && sulphurKg == 0;
}

/// एक चरण में असल में कितनी बोरी/किलो डालनी है।
class SplitRow {
  final String whenHi;
  final String whenEn;
  final double ureaKg;
  final double dapKg;
  final double mopKg;
  const SplitRow(this.whenHi, this.whenEn, this.ureaKg, this.dapKg, this.mopKg);

  String when(bool isHindi) => isHindi ? whenHi : whenEn;
  bool get isEmpty => ureaKg == 0 && dapKg == 0 && mopKg == 0;
}

/// "कब कितना डालें" — प्रतिशत को असली किलो में बदलता है।
///
/// DAP और पोटाश हमेशा पूरा बुवाई पर जाता है, इसलिए उन्हें `pPct`/`kPct` के
/// हिसाब से बाँटते हैं। यूरिया `nPct` के हिसाब से।
List<SplitRow> computeSplitPlan({
  required Crop crop,
  required double areaHa,
  KhaadResult? tier,
}) {
  if (crop.splitPlan.isEmpty) return const [];
  final r = tier ?? computeKhaad3Tier(crop: crop, areaHa: areaHa).recommended;
  return [
    for (final s in crop.splitPlan)
      SplitRow(
        s.whenHi,
        s.whenEn,
        _round05(r.ureaKg * s.nPct / 100),
        _round05(r.dapKg * s.pPct / 100),
        _round05(r.mopKg * s.kPct / 100),
      ),
  ];
}

ExtraInputs computeExtras({required Crop crop, required double areaHa}) =>
    ExtraInputs(
      _round05(crop.fymTonHa * areaHa),
      _round05(crop.zincSulphateKgHa * areaHa),
      _round05(crop.boraxKgHa * areaHa),
      _round05(crop.sulphurKgHa * areaHa),
    );

double _round05(double v) => (v * 2).round() / 2.0;
