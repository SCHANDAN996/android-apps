import '../utils/unit_converter.dart';

/// Brick wall calculation result.
class BrickResult {
  final double wallVolume; // m³
  final int brickCount;
  final double cementBags;
  final double sandM3;
  final double sandCFT;
  final double cementM3; // for cost calc

  BrickResult({
    required this.wallVolume,
    required this.brickCount,
    required this.cementBags,
    required this.sandM3,
    required this.sandCFT,
    required this.cementM3,
  });
}

class BrickCalculator {
  /// Constants
  static const double bricksPerM3 = 500;
  static const double wastage = 1.05; // 5%
  static const double mortarFraction = 0.25; // mortar is 25% of wall volume
  static const double dryVolumeFactor = 1.33; // dry mortar factor
  static const double cementBagVolume = 0.0347; // 1 bag = 50kg = 0.0347 m³

  /// Thickness options in meters
  static const double halfBrickThickness = 0.115; // 4.5 inch
  static const double fullBrickThickness = 0.23; // 9 inch

  /// Calculate brick wall materials.
  ///
  /// [length] and [height] in user's unit (ft or m).
  /// [unit] = 'ft' or 'm'.
  /// [thicknessM] = 0.115 (4.5") or 0.23 (9").
  /// [ratioC] and [ratioS] = mortar ratio parts (e.g., 1:6 → c=1, s=6).
  static BrickResult calculate({
    required double length,
    required double height,
    required String unit,
    required double thicknessM,
    required int ratioC,
    required int ratioS,
  }) {
    // Convert to meters
    final lengthM = UnitConverter.toMeters(length, unit);
    final heightM = UnitConverter.toMeters(height, unit);

    // Wall volume
    final volume = lengthM * heightM * thicknessM;

    // Bricks (with wastage)
    final bricks = (volume * bricksPerM3 * wastage).ceil();

    // Mortar
    final mortarWet = volume * mortarFraction;
    final mortarDry = mortarWet * dryVolumeFactor;

    // Split by ratio
    final totalParts = ratioC + ratioS;
    final cementM3 = mortarDry * ratioC / totalParts;
    final sandM3 = mortarDry * ratioS / totalParts;

    // Cement bags
    final cementBags = cementM3 / cementBagVolume;

    // Sand in CFT
    final sandCFT = UnitConverter.cubicMetersToCFT(sandM3);

    return BrickResult(
      wallVolume: volume,
      brickCount: bricks,
      cementBags: cementBags,
      sandM3: sandM3,
      sandCFT: sandCFT,
      cementM3: cementM3,
    );
  }
}
