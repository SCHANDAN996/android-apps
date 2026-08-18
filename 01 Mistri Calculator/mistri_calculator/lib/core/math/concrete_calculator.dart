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
  static const double cementBagVolume = 0.0347; // 1 bag = 50kg = 0.0347 m³

  static const List<ConcreteGrade> grades = [
    ConcreteGrade('M15', 1, 2, 4),
    ConcreteGrade('M20', 1, 1.5, 3),
    ConcreteGrade('M25', 1, 1, 2),
  ];

  /// Calculate concrete materials for a slab.
  /// [length], [width], [depth] in user's unit (ft or m).
  static ConcreteResult calculateSlab({
    required double length,
    required double width,
    required double depth,
    required String unit,
    required ConcreteGrade grade,
  }) {
    final l = UnitConverter.toMeters(length, unit);
    final w = UnitConverter.toMeters(width, unit);
    final d = UnitConverter.toMeters(depth, unit);
    final volume = l * w * d;
    return _calculate(volume, grade);
  }

  /// Calculate concrete materials for columns/beams.
  /// [count] = number of columns/beams.
  /// [length], [width], [depth] = dimensions of each.
  static ConcreteResult calculateColumnBeam({
    required int count,
    required double length,
    required double width,
    required double depth,
    required String unit,
    required ConcreteGrade grade,
  }) {
    final l = UnitConverter.toMeters(length, unit);
    final w = UnitConverter.toMeters(width, unit);
    final d = UnitConverter.toMeters(depth, unit);
    final volume = count * l * w * d;
    return _calculate(volume, grade);
  }

  static ConcreteResult _calculate(double wetVolume, ConcreteGrade grade) {
    final dryVolume = wetVolume * dryVolumeFactor;
    final totalParts = grade.totalParts;

    final cementM3 = dryVolume * grade.cement / totalParts;
    final sandM3 = dryVolume * grade.sand / totalParts;
    final aggregateM3 = dryVolume * grade.aggregate / totalParts;

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
