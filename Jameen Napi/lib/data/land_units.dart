import 'dart:math' as math;

/// भूमि इकाइयों का डेटा — सभी मान वर्ग फीट (sq ft) में आधारित हैं।
///
/// नोट: बीघा/कट्ठा जैसी इकाइयाँ राज्य ही नहीं, ज़िले के स्तर पर भी बदलती हैं।
/// यहाँ हर राज्य के सबसे प्रचलित (राजस्व रिकॉर्ड में इस्तेमाल होने वाले) मान लिए गए हैं।
class LandUnit {
  final String hi;
  final String en;
  final double sqft;

  const LandUnit(this.hi, this.en, this.sqft);

  String get label => '$hi ($en)';
}

/// मानक इकाइयाँ — पूरे भारत में एक जैसी।
const List<LandUnit> standardUnits = [
  LandUnit('वर्ग फीट', 'Sq. Feet', 1),
  LandUnit('वर्ग मीटर', 'Sq. Meter', 10.7639104),
  LandUnit('गज (वर्ग गज)', 'Gaj / Sq. Yard', 9),
  LandUnit('डिसिमिल / डिसमिल', 'Dismil / Decimal', 435.6),
  LandUnit('एकड़', 'Acre', 43560),
  LandUnit('हेक्टेयर', 'Hectare', 107639.104),
];

/// राज्यवार इकाइयाँ — छोटी से बड़ी के क्रम में।
const Map<String, List<LandUnit>> stateUnits = {
  'उत्तर प्रदेश': [
    LandUnit('उन्वांसी', 'Unwansi', 3.375),
    LandUnit('बिस्वांसी', 'Biswansi', 67.5),
    LandUnit('बिस्वा (कच्चा)', 'Biswa Kaccha', 337.5),
    LandUnit('बिस्वा (पक्का)', 'Biswa Pucca', 1350),
    LandUnit('बीघा (कच्चा)', 'Bigha Kaccha', 6750),
    LandUnit('बीघा (पक्का)', 'Bigha Pucca', 27000),
  ],
  'बिहार / झारखंड': [
    LandUnit('धुरकी', 'Dhurki / Farki', 3.403125),
    LandUnit('धुर', 'Dhur', 68.0625),
    LandUnit('कट्ठा', 'Katha', 1361.25),
    LandUnit('बीघा', 'Bigha', 27225),
  ],
  'राजस्थान': [
    LandUnit('बिस्वा (कच्चा)', 'Biswa Kaccha', 871.2),
    LandUnit('बिस्वा (पक्का)', 'Biswa Pucca', 1361.25),
    LandUnit('बीघा (कच्चा)', 'Bigha Kaccha', 17424),
    LandUnit('बीघा (पक्का)', 'Bigha Pucca', 27225),
  ],
  'पंजाब / हरियाणा': [
    LandUnit('सरसाही', 'Sarsahi', 30.25),
    LandUnit('मरला', 'Marla', 272.25),
    LandUnit('कनाल', 'Kanal', 5445),
    LandUnit('बीघा', 'Bigha', 9075),
    // 1 घुमाओ = 8 कनाल = 1 एकड़ (पंजाब/हिमाचल राजस्व रिकॉर्ड)
    LandUnit('घुमाओ', 'Ghumao', 43560),
    LandUnit('किल्ला (एकड़)', 'Killa', 43560),
  ],
  'गुजरात': [
    LandUnit('વિસવાસી (विसवासी)', 'Viswasi', 43.56),
    LandUnit('વાસા (वासा)', 'Vasa', 871.2),
    LandUnit('ગુણઠા (गुंठा)', 'Guntha', 1089),
    LandUnit('વીઘા (बीघा)', 'Vigha', 17424),
  ],
  'महाराष्ट्र': [
    LandUnit('आणा (आना)', 'Anna / Ana', 68.0625),
    LandUnit('गुंठा', 'Guntha', 1089),
    LandUnit('एकर (एकड़)', 'Acre', 43560),
  ],
  'कर्नाटक': [
    LandUnit('ಆಣೆ (आना)', 'Anna / Ane', 68.0625),
    LandUnit('ಸೆಂಟ್ (सेंट)', 'Cent', 435.6),
    LandUnit('ಗುಂಟೆ (गुंठा)', 'Guntha', 1089),
  ],
  'पश्चिम बंगाल': [
    LandUnit('তিল (तिल)', 'Til', 2.25),
    LandUnit('ছটাক (छटाक)', 'Chatak', 45),
    LandUnit('কাঠা (कट्ठा)', 'Katha', 720),
    LandUnit('বিঘা (बीघा)', 'Bigha', 14400),
  ],
  'तमिलनाडु / पुडुचेरी': [
    LandUnit('குழி (कुझी)', 'Kuzhi', 144),
    LandUnit('சென்ட் (सेंट)', 'Cent', 435.6),
    LandUnit('கிரவுண்ட் (ग्राउंड)', 'Ground', 2400),
    LandUnit('மா (मा)', 'Maa', 14400),
    LandUnit('காணி (काणि)', 'Kani', 57600),
  ],
  'आंध्र प्रदेश / तेलंगाना': [
    LandUnit('అంకణం (अंकणम)', 'Ankanam', 72),
    LandUnit('సెంట్ (सेंट)', 'Cent', 435.6),
    LandUnit('కుంట (गुंठा/कुंटा)', 'Guntha / Kunta', 1089),
  ],
  'असम': [
    LandUnit('লেচা (लेचा)', 'Lecha', 144),
    LandUnit('কাঠা (कट्ठा)', 'Katha', 2880),
    LandUnit('বিঘা (बीघा)', 'Bigha', 14400),
  ],
  'मध्य प्रदेश / छत्तीसगढ़': [
    LandUnit('बिस्वा', 'Biswa', 600),
    LandUnit('बीघा', 'Bigha', 12000),
  ],
  'हिमाचल प्रदेश': [
    LandUnit('बिस्वा', 'Biswa', 435.6),
    LandUnit('बीघा', 'Bigha', 8712),
  ],
  'उत्तराखंड': [
    LandUnit('मुट्ठी', 'Muthi', 135),
    LandUnit('नाली', 'Nali', 2160),
  ],
};

const String standardStateKey = 'पूरे भारत की मानक इकाइयाँ';

/// चुने गए राज्य की इकाइयाँ + मानक इकाइयाँ (छोटी से बड़ी के क्रम में)।
List<LandUnit> unitsForState(String state) {
  final regional = stateUnits[state] ?? const <LandUnit>[];
  final all = [...regional, ...standardUnits];
  all.sort((a, b) => a.sqft.compareTo(b.sqft));
  return all;
}

/// भारतीय अंक-समूहन (12,34,567.89) के साथ संख्या फॉर्मेट करें।
String formatIndian(double value) {
  if (value.isNaN || value.isInfinite) return '—';

  final double abs = value.abs();
  String s;
  if (abs >= 1000) {
    s = value.toStringAsFixed(2);
  } else if (abs >= 1) {
    s = value.toStringAsFixed(4);
  } else {
    s = value.toStringAsFixed(6);
  }

  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  final negative = s.startsWith('-');
  if (negative) s = s.substring(1);

  final parts = s.split('.');
  String intPart = parts[0];

  if (intPart.length > 3) {
    final last3 = intPart.substring(intPart.length - 3);
    String rest = intPart.substring(0, intPart.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    intPart = '${groups.join(',')},$last3';
  }

  final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  return negative ? '-$result' : result;
}

/// 4-भुजाओं वाले विषमबाहु खेत का हेरॉन सूत्र (Heron's Formula) द्वारा 100% सटीक क्षेत्रफल
class IrregularPlotResult {
  final double? exactAreaSqFt; // Heron with diagonal
  final double averageAreaSqFt; // Average method
  final double? area1SqFt; // Triangle 1 area
  final double? area2SqFt; // Triangle 2 area
  final bool isValidDiagonal;

  /// विकर्ण दिया तो गया, पर भुजाओं से मेल नहीं खाता।
  /// (संदेश स्क्रीन दिखाती है ताकि वो user की भाषा में हो — देखें
  /// `ToolStrings.irrDiagonalMismatch`.)
  final bool diagonalMismatch;

  const IrregularPlotResult({
    required this.exactAreaSqFt,
    required this.averageAreaSqFt,
    this.area1SqFt,
    this.area2SqFt,
    required this.isValidDiagonal,
    this.diagonalMismatch = false,
  });
}

IrregularPlotResult calculateIrregularPlot({
  required double a, // Side 1 (e.g. North)
  required double b, // Side 2 (e.g. East)
  required double c, // Side 3 (e.g. South)
  required double d, // Side 4 (e.g. West)
  double? diagonal,  // Diagonal between (A,B) and (C,D)
}) {
  // Average method calculation
  final avgLength = (a + c) / 2.0;
  final avgWidth = (b + d) / 2.0;
  final avgArea = avgLength * avgWidth;

  if (diagonal == null || diagonal <= 0) {
    return IrregularPlotResult(
      exactAreaSqFt: null,
      averageAreaSqFt: avgArea,
      isValidDiagonal: false,
    );
  }

  final diag = diagonal;

  // Triangle 1 (A, B, Diagonal)
  final isT1Valid = (a + b > diag) && (a + diag > b) && (b + diag > a);
  // Triangle 2 (C, D, Diagonal)
  final isT2Valid = (c + d > diag) && (c + diag > d) && (d + diag > c);

  if (!isT1Valid || !isT2Valid) {
    return IrregularPlotResult(
      exactAreaSqFt: null,
      averageAreaSqFt: avgArea,
      isValidDiagonal: false,
      diagonalMismatch: true,
    );
  }

  final s1 = (a + b + diag) / 2.0;
  final area1 = math.sqrt(s1 * (s1 - a) * (s1 - b) * (s1 - diag));

  final s2 = (c + d + diag) / 2.0;
  final area2 = math.sqrt(s2 * (s2 - c) * (s2 - d) * (s2 - diag));

  final totalExact = area1 + area2;

  return IrregularPlotResult(
    exactAreaSqFt: totalExact,
    averageAreaSqFt: avgArea,
    area1SqFt: area1,
    area2SqFt: area2,
    isValidDiagonal: true,
  );
}

/// त्रिकोणीय खेत का क्षेत्रफल (Heron's Formula)
double? calculateTriangleHeron(double a, double b, double c) {
  if (a <= 0 || b <= 0 || c <= 0) return null;
  if (a + b <= c || a + c <= b || b + c <= a) return null;
  final s = (a + b + c) / 2.0;
  return math.sqrt(s * (s - a) * (s - b) * (s - c));
}

/// लग्गी पैमाना (Laggi Calculation Results)
class LaggiInfo {
  final double haath;
  final double feet;
  final double inches;
  final double dhurSqFt;
  final double dhurkiSqFt;
  final double kathaSqFt;
  final double bighaSqFt;
  final double kathaPerAcre;
  final double bighaPerAcre;
  final double dismilPerKatha;
  final double dismilPerBigha;

  const LaggiInfo({
    required this.haath,
    required this.feet,
    required this.inches,
    required this.dhurSqFt,
    required this.dhurkiSqFt,
    required this.kathaSqFt,
    required this.bighaSqFt,
    required this.kathaPerAcre,
    required this.bighaPerAcre,
    required this.dismilPerKatha,
    required this.dismilPerBigha,
  });

  factory LaggiInfo.fromHaath(double haath) {
    final feet = haath * 1.5;
    final inches = haath * 18.0;
    final dhurSqFt = feet * feet;
    final dhurkiSqFt = dhurSqFt / 20.0;
    final kathaSqFt = dhurSqFt * 20.0;
    final bighaSqFt = kathaSqFt * 20.0;
    final kathaPerAcre = 43560.0 / kathaSqFt;
    final bighaPerAcre = 43560.0 / bighaSqFt;
    final dismilPerKatha = kathaSqFt / 435.6;
    final dismilPerBigha = bighaSqFt / 435.6;

    return LaggiInfo(
      haath: haath,
      feet: feet,
      inches: inches,
      dhurSqFt: dhurSqFt,
      dhurkiSqFt: dhurkiSqFt,
      kathaSqFt: kathaSqFt,
      bighaSqFt: bighaSqFt,
      kathaPerAcre: kathaPerAcre,
      bighaPerAcre: bighaPerAcre,
      dismilPerKatha: dismilPerKatha,
      dismilPerBigha: dismilPerBigha,
    );
  }
}
