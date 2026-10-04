import 'dart:math' as math;

import '../utils/unit_converter.dart';
import 'concrete_calculator.dart';

/// A straight RCC staircase between two floors.
class StairsResult {
  /// Risers — the number of times the foot is lifted.
  final int steps;

  /// Riser after the floor height is divided evenly (m).
  final double riserM;

  /// Horizontal run of the flight (m).
  final double goingM;
  final ConcreteResult concrete;

  StairsResult({
    required this.steps,
    required this.riserM,
    required this.goingM,
    required this.concrete,
  });
}

class StairsCalculator {
  /// A riser much taller than this is tiring and unsafe to climb.
  static const double maxComfortRiserM = 0.19; // ~7.5 inch

  /// [riserM] is the riser the user would like; the real one comes from
  /// dividing [heightM] into a whole number of steps.
  static StairsResult calculate({
    required double heightM,
    required double widthM,
    required double riserM,
    required double treadM,
    required double waistM,
    required ConcreteGrade grade,
  }) {
    if (heightM <= 0 ||
        widthM <= 0 ||
        riserM <= 0 ||
        treadM <= 0 ||
        waistM <= 0) {
      throw ArgumentError('all stair dimensions must be greater than zero');
    }
    final steps = math.max(2, (heightM / riserM).round());
    final riser = heightM / steps;
    // The top riser lands on the floor above, so there is one tread fewer.
    final treads = steps - 1;
    final going = treads * treadM;

    // The sloping slab under the steps, plus one triangular wedge per tread.
    final slopeLength = math.sqrt(going * going + heightM * heightM);
    final waistVolume = slopeLength * widthM * waistM;
    final stepsVolume = treads * 0.5 * riser * treadM * widthM;

    return StairsResult(
      steps: steps,
      riserM: riser,
      goingM: going,
      concrete: ConcreteCalculator.fromVolume(waistVolume + stepsVolume, grade),
    );
  }
}

/// Earth dug out for a foundation, a trench or a pit.
class ExcavationResult {
  final double volumeM3;

  /// Dug soil swells; this is what has to be carted away.
  final double looseVolumeM3;

  ExcavationResult({required this.volumeM3, required this.looseVolumeM3});

  double get volumeCft => UnitConverter.cubicMetersToCFT(volumeM3);
  double get looseVolumeCft => UnitConverter.cubicMetersToCFT(looseVolumeM3);
}

class ExcavationCalculator {
  /// Ordinary soil takes up about a quarter more room once it is dug.
  static const double bulkingFactor = 1.25;

  static ExcavationResult calculate({
    required double lengthM,
    required double widthM,
    required double depthM,
    int count = 1,
  }) {
    if (lengthM <= 0 || widthM <= 0 || depthM <= 0 || count <= 0) {
      throw ArgumentError(
        'all excavation dimensions must be greater than zero',
      );
    }
    final volume = lengthM * widthM * depthM * count;
    return ExcavationResult(
      volumeM3: volume,
      looseVolumeM3: volume * bulkingFactor,
    );
  }
}

/// How much water a tank holds.
class WaterTankCalculator {
  static const double litresPerM3 = 1000;

  static double rectangularLitres({
    required double lengthM,
    required double widthM,
    required double heightM,
  }) => lengthM * widthM * heightM * litresPerM3;

  static double roundLitres({
    required double diameterM,
    required double heightM,
  }) => math.pi * diameterM * diameterM / 4 * heightM * litresPerM3;
}
