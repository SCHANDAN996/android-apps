/// Pure cattle-calculation helpers (गाभिन / आहार). No DB, easy to unit-test.

/// Gestation days.
const int kCowGestationDays = 283;
const int kBuffaloGestationDays = 310;
const int kHeatCycleDays = 21;
const int kPregCheckDays = 75;
const int kDryOffBeforeDeliveryDays = 60;

class PashuMilestones {
  final DateTime expectedDelivery;
  final DateTime nextHeat;      // if not conceived, watch this date
  final DateTime pregnancyCheck;
  final DateTime dryOff;

  const PashuMilestones({
    required this.expectedDelivery,
    required this.nextHeat,
    required this.pregnancyCheck,
    required this.dryOff,
  });
}

/// From an AI/service date, compute the full timeline. [isCow] false = buffalo.
PashuMilestones gaabhinMilestones(DateTime aiDate, {required bool isCow}) =>
    gaabhinMilestonesFor(aiDate, isCow ? kSpeciesCow : kSpeciesBuffalo);

/// गाभिन की गणना के लिए एक पशु की जानकारी।
///
/// गाय-भैंस के अलावा अब बकरी, भेड़ और सुअर भी — इनके गर्भ के दिन बहुत अलग
/// होते हैं (बकरी सिर्फ़ ~150 दिन), इसलिए एक ही 283-दिन वाला हिसाब सबके लिए
/// ग़लत जवाब देता था।
class PashuSpecies {
  final String id;
  final String emoji;
  final String? imageAsset;
  final String nameKey; // AppLocalizations की चाबी
  final int gestationDays;
  final int heatCycleDays;
  final int pregCheckDays;

  /// ब्याने से कितने दिन पहले दूध सुखाना (0 = लागू नहीं)
  final int dryOffBeforeDays;

  const PashuSpecies({
    required this.id,
    required this.emoji,
    this.imageAsset,
    required this.nameKey,
    required this.gestationDays,
    required this.heatCycleDays,
    required this.pregCheckDays,
    required this.dryOffBeforeDays,
  });
}

const kSpeciesCow = PashuSpecies(
  id: 'cow', emoji: '🐄', imageAsset: 'assets/images/3d_cow_profile.webp', nameKey: 'cow',
  gestationDays: kCowGestationDays, heatCycleDays: 21,
  pregCheckDays: 75, dryOffBeforeDays: 60,
);
const kSpeciesBuffalo = PashuSpecies(
  id: 'buffalo', emoji: '🐃', imageAsset: 'assets/images/3d_buffalo_profile.webp', nameKey: 'buffalo',
  gestationDays: kBuffaloGestationDays, heatCycleDays: 21,
  pregCheckDays: 75, dryOffBeforeDays: 60,
);
const kSpeciesGoat = PashuSpecies(
  id: 'goat', emoji: '🐐', imageAsset: 'assets/images/3d_goat.webp', nameKey: 'speciesGoat',
  gestationDays: 150, heatCycleDays: 21,
  pregCheckDays: 45, dryOffBeforeDays: 45,
);
const kSpeciesSheep = PashuSpecies(
  id: 'sheep', emoji: '🐑', imageAsset: 'assets/images/3d_sheep.webp', nameKey: 'speciesSheep',
  gestationDays: 148, heatCycleDays: 17,
  pregCheckDays: 45, dryOffBeforeDays: 0,
);
const kSpeciesPig = PashuSpecies(
  id: 'pig', emoji: '🐷', imageAsset: 'assets/images/3d_pig.webp', nameKey: 'speciesPig',
  gestationDays: 114, heatCycleDays: 21,
  pregCheckDays: 30, dryOffBeforeDays: 0,
);

const List<PashuSpecies> kAllSpecies = [
  kSpeciesCow, kSpeciesBuffalo, kSpeciesGoat, kSpeciesSheep, kSpeciesPig,
];

PashuMilestones gaabhinMilestonesFor(DateTime aiDate, PashuSpecies s) {
  final delivery = aiDate.add(Duration(days: s.gestationDays));
  return PashuMilestones(
    expectedDelivery: delivery,
    nextHeat: aiDate.add(Duration(days: s.heatCycleDays)),
    pregnancyCheck: aiDate.add(Duration(days: s.pregCheckDays)),
    dryOff: s.dryOffBeforeDays > 0
        ? delivery.subtract(Duration(days: s.dryOffBeforeDays))
        : delivery,
  );
}

/// 🐔 मुर्गी पालन का हिसाब — FCR और प्रति अंडा/प्रति किलो लागत।
///
/// FCR (Feed Conversion Ratio) = कितना दाना खिलाकर कितना वज़न/अंडा मिला।
/// जितना कम, उतना अच्छा — ब्रॉयलर में 1.6-1.8 बढ़िया माना जाता है।
class FcrResult {
  final double fcr; // दाना ÷ वज़न (ब्रॉयलर) — लेयर में 0
  final double feedPerUnit; // प्रति किग्रा या प्रति अंडा दाना
  final double feedCostPerUnit; // प्रति किग्रा / प्रति अंडा दाना-लागत
  final double totalFeedCost;
  final double totalIncome;
  final double profit;
  final double profitPerBird;

  const FcrResult({
    required this.fcr,
    required this.feedPerUnit,
    required this.feedCostPerUnit,
    required this.totalFeedCost,
    required this.totalIncome,
    required this.profit,
    required this.profitPerBird,
  });
}

/// ब्रॉयलर: कुल दाना, कुल जीवित वज़न और भाव से पूरा हिसाब।
FcrResult broilerFcr({
  required int birds,
  required double feedKg,
  required double totalWeightKg,
  required double feedRatePerKg,
  required double sellRatePerKg,
}) {
  final fcr = totalWeightKg > 0 ? feedKg / totalWeightKg : 0.0;
  final feedCost = feedKg * feedRatePerKg;
  final income = totalWeightKg * sellRatePerKg;
  final profit = income - feedCost;
  return FcrResult(
    fcr: fcr,
    feedPerUnit: fcr,
    feedCostPerUnit: totalWeightKg > 0 ? feedCost / totalWeightKg : 0,
    totalFeedCost: feedCost,
    totalIncome: income,
    profit: profit,
    profitPerBird: birds > 0 ? profit / birds : 0,
  );
}

/// लेयर: कुल दाना और अंडों की संख्या से प्रति अंडा लागत।
FcrResult layerFcr({
  required int birds,
  required double feedKg,
  required int eggs,
  required double feedRatePerKg,
  required double eggPrice,
}) {
  final feedCost = feedKg * feedRatePerKg;
  final income = eggs * eggPrice;
  final profit = income - feedCost;
  return FcrResult(
    fcr: 0,
    feedPerUnit: eggs > 0 ? (feedKg * 1000) / eggs : 0, // ग्राम प्रति अंडा
    feedCostPerUnit: eggs > 0 ? feedCost / eggs : 0,
    totalFeedCost: feedCost,
    totalIncome: income,
    profit: profit,
    profitPerBird: birds > 0 ? profit / birds : 0,
  );
}

/// Concentrate (दाना) feed in kg/day.
/// Rule of thumb: milk_L / 2.5 + 1.5 (maintenance); +1 kg if in late pregnancy.
double aaharDanaKgPerDay({required double milkLitresPerDay, bool latePregnancy = false}) {
  final res = calculateFullAahar(speciesId: 'cow', milkL: milkLitresPerDay, latePregnancy: latePregnancy);
  return res.danaKg;
}

class FullAaharResult {
  final double danaKg; // दाना (Concentrate Feed) in kg/day
  final double greenFodderKg; // हरा चारा in kg/day
  final double dryFodderKg; // सूखा भूसा in kg/day
  final double mineralGrams; // मिनरल मिक्सचर in grams/day (or sugar syrup in ml/day for bees)
  final String unitNote; // विशेष टिप्पणी

  const FullAaharResult({
    required this.danaKg,
    required this.greenFodderKg,
    required this.dryFodderKg,
    required this.mineralGrams,
    this.unitNote = 'ग्राम/दिन',
  });

  String getUnitNote(bool isHi) {
    if (unitNote == 'मि.ली. चीनी घोल/सप्ताह') {
      return isHi ? 'मि.ली. चीनी घोल/सप्ताह' : 'ml sugar syrup / week';
    }
    return isHi ? 'ग्राम/दिन' : 'g/day';
  }
}

class AaharSpeciesItem {
  final String id;
  final String nameKey;
  final String hindiName;
  final String englishName;
  final String imageAsset;
  final String inputType; // 'milk' | 'weight' | 'count' | 'bee'

  const AaharSpeciesItem({
    required this.id,
    required this.nameKey,
    required this.hindiName,
    required this.englishName,
    required this.imageAsset,
    required this.inputType,
  });
}

const List<AaharSpeciesItem> kAaharSpeciesList = [
  AaharSpeciesItem(id: 'cow', nameKey: 'cow', hindiName: 'गाय', englishName: 'Cow', imageAsset: 'assets/images/3d_cow_profile.webp', inputType: 'milk'),
  AaharSpeciesItem(id: 'buffalo', nameKey: 'buffalo', hindiName: 'भैंस', englishName: 'Buffalo', imageAsset: 'assets/images/3d_buffalo_profile.webp', inputType: 'milk'),
  AaharSpeciesItem(id: 'goat', nameKey: 'goat', hindiName: 'बकरी', englishName: 'Goat', imageAsset: 'assets/images/3d_goat.webp', inputType: 'milk'),
  AaharSpeciesItem(id: 'sheep', nameKey: 'sheep', hindiName: 'भेड़', englishName: 'Sheep', imageAsset: 'assets/images/3d_sheep.webp', inputType: 'weight'),
  AaharSpeciesItem(id: 'pig', nameKey: 'pig', hindiName: 'सुअर', englishName: 'Pig', imageAsset: 'assets/images/3d_pig.webp', inputType: 'weight'),
  AaharSpeciesItem(id: 'broiler', nameKey: 'broiler', hindiName: 'मुर्गी', englishName: 'Poultry', imageAsset: 'assets/images/3d_broiler.webp', inputType: 'count'),
  AaharSpeciesItem(id: 'duck', nameKey: 'duck', hindiName: 'बत्तख', englishName: 'Duck', imageAsset: 'assets/images/3d_duck.webp', inputType: 'count'),
  AaharSpeciesItem(id: 'quail', nameKey: 'quail', hindiName: 'बटेर', englishName: 'Quail', imageAsset: 'assets/images/3d_quail.webp', inputType: 'count'),
  AaharSpeciesItem(id: 'turkey', nameKey: 'turkey', hindiName: 'टर्की', englishName: 'Turkey', imageAsset: 'assets/images/3d_turkey.webp', inputType: 'count'),
  AaharSpeciesItem(id: 'emu', nameKey: 'emu', hindiName: 'एमू', englishName: 'Emu', imageAsset: 'assets/images/3d_emu.webp', inputType: 'count'),
  AaharSpeciesItem(id: 'fish', nameKey: 'fish', hindiName: 'मछली', englishName: 'Fish', imageAsset: 'assets/images/3d_fish.webp', inputType: 'weight'),
  AaharSpeciesItem(id: 'beekeeping', nameKey: 'beekeeping', hindiName: 'मधुमक्खी', englishName: 'Bee', imageAsset: 'assets/images/3d_beekeeping.webp', inputType: 'bee'),
];

FullAaharResult calculateFullAahar({
  required String speciesId,
  double milkL = 0,
  bool latePregnancy = false,
  double weightKg = 0,
  int count = 1,
  bool isOffSeason = false,
}) {
  final c = count <= 0 ? 1 : count;
  switch (speciesId) {
    case 'cow':
      final dana = (1.5 + (milkL * 0.4) + (latePregnancy ? 1.25 : 0)) * c;
      final green = (20.0 + (milkL * 0.5)) * c;
      final dry = 5.0 * c;
      final min = 50.0 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: dry, mineralGrams: min);

    case 'buffalo':
      final dana = (2.0 + (milkL * 0.45) + (latePregnancy ? 1.5 : 0)) * c;
      final green = (25.0 + (milkL * 0.5)) * c;
      final dry = 6.0 * c;
      final min = 60.0 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: dry, mineralGrams: min);

    case 'goat':
      final dana = (0.2 + (milkL * 0.3) + (latePregnancy ? 0.2 : 0)) * c;
      final green = 4.0 * c;
      final dry = 1.0 * c;
      final min = 10.0 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: dry, mineralGrams: min);

    case 'sheep':
      final w = weightKg > 0 ? weightKg : 35.0;
      final dana = (w * 0.01) * c;
      final green = 3.5 * c;
      final dry = 1.0 * c;
      final min = 10.0 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: dry, mineralGrams: min);

    case 'pig':
      final w = weightKg > 0 ? weightKg : 50.0;
      final dana = (w * 0.035) * c;
      final green = 1.5 * c;
      final dry = 0.0;
      final min = 20.0 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: dry, mineralGrams: min);

    case 'broiler':
      final dana = (0.11 * c);
      return FullAaharResult(danaKg: dana, greenFodderKg: 0, dryFodderKg: 0, mineralGrams: 5.0 * c);

    case 'duck':
      final dana = (0.14 * c);
      final green = 0.05 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: 0, mineralGrams: 5.0 * c);

    case 'quail':
      final dana = (0.028 * c);
      return FullAaharResult(danaKg: dana, greenFodderKg: 0, dryFodderKg: 0, mineralGrams: 1.0 * c);

    case 'turkey':
      final dana = (0.25 * c);
      final green = 0.1 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: 0, mineralGrams: 10.0 * c);

    case 'emu':
      final dana = (1.75 * c);
      final green = 0.5 * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: green, dryFodderKg: 0, mineralGrams: 25.0 * c);

    case 'fish':
      final w = weightKg > 0 ? weightKg : 500.0;
      final dana = w * 0.03;
      return FullAaharResult(danaKg: dana, greenFodderKg: 0, dryFodderKg: 0, mineralGrams: w * 0.001 * 1000);

    case 'beekeeping':
      final syrupMl = isOffSeason ? (350.0 * c) : 0.0;
      return FullAaharResult(danaKg: 0, greenFodderKg: 0, dryFodderKg: 0, mineralGrams: syrupMl, unitNote: 'मि.ली. चीनी घोल/सप्ताह');

    default:
      final dana = (1.5 + (milkL * 0.4)) * c;
      return FullAaharResult(danaKg: dana, greenFodderKg: 20.0 * c, dryFodderKg: 5.0 * c, mineralGrams: 50.0 * c);
  }
}
