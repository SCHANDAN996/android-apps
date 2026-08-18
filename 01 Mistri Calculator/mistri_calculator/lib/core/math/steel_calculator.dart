/// Steel / Saria (TMT bar) calculation result.
class SteelResult {
  final double weightKg;
  final double weightPerMeter; // kg/m
  final double totalLength; // meters

  SteelResult({
    required this.weightKg,
    required this.weightPerMeter,
    required this.totalLength,
  });
}

class SteelCalculator {
  static const double wastage = 1.03; // 3%
  static const double slabSteelRate = 80.0; // kg/m³ for residential slab

  /// Available diameters in mm
  static const List<int> diameters = [8, 10, 12, 16, 20];

  /// Weight per meter: d²/162
  static double weightPerMeter(int diameterMm) {
    return (diameterMm * diameterMm) / 162.0;
  }

  /// Calculate steel by total length in meters.
  static SteelResult calculateByLength({
    required int diameterMm,
    required double totalLengthM,
  }) {
    final kgPerM = weightPerMeter(diameterMm);
    final weight = totalLengthM * kgPerM * wastage;
    return SteelResult(
      weightKg: weight,
      weightPerMeter: kgPerM,
      totalLength: totalLengthM,
    );
  }

  /// Calculate steel by number of standard 12m rods.
  static SteelResult calculateByRods({
    required int diameterMm,
    required int rodCount,
  }) {
    final totalLength = rodCount * 12.0; // each rod = 12m
    return calculateByLength(
      diameterMm: diameterMm,
      totalLengthM: totalLength,
    );
  }

  /// Quick slab mode: slab volume → steel weight (80 kg/m³ residential).
  static SteelResult calculateBySlab({
    required double slabVolumeM3,
  }) {
    final weight = slabVolumeM3 * slabSteelRate * wastage;
    return SteelResult(
      weightKg: weight,
      weightPerMeter: 0,
      totalLength: 0,
    );
  }
}
