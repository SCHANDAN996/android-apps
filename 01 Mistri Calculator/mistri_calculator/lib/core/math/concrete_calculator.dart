import '../utils/purchase.dart';
import '../utils/unit_converter.dart';

/// Concrete calculation result.
class ConcreteResult {
  final double wetVolume; // m³
  final double dryVolume; // m³
  final double cementBags;
  final double sandM3;
  final double sandCFT;
  final double aggregateM3;
  final double aggregateCFT;

  ConcreteResult({
    required this.wetVolume,
    required this.dryVolume,
    required this.cementBags,
    required this.sandM3,
    required this.sandCFT,
    required this.aggregateM3,
    required this.aggregateCFT,
  });

  /// Whole bags / whole CFT to actually order.
  int get cementBagsToBuy => roundUpToBuy(cementBags);
  int get sandCftToBuy => roundUpToBuy(sandCFT);
  int get aggregateCftToBuy => roundUpToBuy(aggregateCFT);
}

/// Concrete grade definitions (cement : sand : aggregate)
class ConcreteGrade {
  final String name;
  final double cement;
  final double sand;
  final double aggregate;

  const ConcreteGrade(this.name, this.cement, this.sand, this.aggregate);

  double get totalParts => cement + sand + aggregate;
}

class ConcreteCalculator {
  static const double dryVolumeFactor = 1.54;
  static const double wastage = 1.05; // 5% — spillage while mixing and pouring
  static const double cementBagVolume = 0.0347; // 1 bag = 50kg = 0.0347 m³

  static const List<ConcreteGrade> grades = [
    // Lean mixes for PCC — floor base, under a foundation. Never for a slab.
    ConcreteGrade('M7.5', 1, 4, 8),
    ConcreteGrade('M10', 1, 3, 6),
    ConcreteGrade('M15', 1, 2, 4),
    ConcreteGrade('M20', 1, 1.5, 3),
    ConcreteGrade('M25', 1, 1, 2),
  ];

  /// The usual house mix, and the default everywhere.
  static final ConcreteGrade m20 = grades.firstWhere((g) => g.name == 'M20');

  /// Grades strong enough to carry load — slabs, columns, beams, stairs.
  static final List<ConcreteGrade> structuralGrades = [
    for (final g in grades)
      if (g.name != 'M7.5' && g.name != 'M10') g,
  ];

  /// Materials for a known volume of finished concrete (m³).
  static ConcreteResult fromVolume(double wetVolumeM3, ConcreteGrade grade) =>
      _calculate(wetVolumeM3, grade);

  /// Calculate concrete materials for a slab.
  /// [length] and [width] in user's unit (ft or m); [thicknessM] in meters,
  /// because a slab is measured in inches or mm, not in feet.
  static ConcreteResult calculateSlab({
    required double length,
    required double width,
    required double thicknessM,
    required String unit,
    required ConcreteGrade grade,
  }) {
    final l = UnitConverter.toMeters(length, unit);
    final w = UnitConverter.toMeters(width, unit);
    final volume = l * w * thicknessM;
    return _calculate(volume, grade);
  }

  /// Calculate concrete materials for columns/beams.
  /// [count] = number of columns/beams.
  /// [length] = height of a column / run of a beam, in user's unit (ft or m).
  /// [widthM], [depthM] = cross-section in meters ("9 x 12 inch").
  static ConcreteResult calculateColumnBeam({
    required int count,
    required double length,
    required double widthM,
    required double depthM,
    required String unit,
    required ConcreteGrade grade,
  }) {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'must be greater than zero');
    }
    final l = UnitConverter.toMeters(length, unit);
    final volume = count * l * widthM * depthM;
    return _calculate(volume, grade);
  }

  static ConcreteResult _calculate(double wetVolume, ConcreteGrade grade) {
    final dryVolume = wetVolume * dryVolumeFactor;
    final totalParts = grade.totalParts;

    final materialVolume = dryVolume * wastage;
    final cementM3 = materialVolume * grade.cement / totalParts;
    final sandM3 = materialVolume * grade.sand / totalParts;
    final aggregateM3 = materialVolume * grade.aggregate / totalParts;

    final cementBags = cementM3 / cementBagVolume;
    final sandCFT = UnitConverter.cubicMetersToCFT(sandM3);
    final aggregateCFT = UnitConverter.cubicMetersToCFT(aggregateM3);

    return ConcreteResult(
      wetVolume: wetVolume,
      dryVolume: dryVolume,
      cementBags: cementBags,
      sandM3: sandM3,
      sandCFT: sandCFT,
      aggregateM3: aggregateM3,
      aggregateCFT: aggregateCFT,
    );
  }
}
