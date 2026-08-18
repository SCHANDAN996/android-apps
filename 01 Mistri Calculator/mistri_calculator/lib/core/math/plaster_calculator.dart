import '../utils/unit_converter.dart';

/// Plaster calculation result.
class PlasterResult {
  final double area; // m²
  final double cementBags;
  final double sandM3;
  final double sandCFT;

  PlasterResult({
    required this.area,
    required this.cementBags,
    required this.sandM3,
    required this.sandCFT,
  });
}

class PlasterCalculator {
  static const double dryVolumeFactor = 1.33;
  static const double cementBagVolume = 0.0347;

  /// Thickness options in meters
  static const double innerThickness = 0.012; // 12mm
  static const double outerThickness = 0.015; // 15mm

  /// Calculate plaster materials.
  ///
  /// [areaM2] = plastering area in m².
  /// [thicknessM] = 0.012 (inner) or 0.015 (outer).
  /// [ratioC], [ratioS] = mortar ratio (e.g., 1:4 or 1:6).
  static PlasterResult calculate({
    required double areaM2,
    required double thicknessM,
    required int ratioC,
    required int ratioS,
  }) {
    final wetVolume = areaM2 * thicknessM;
    final dryVolume = wetVolume * dryVolumeFactor;

    final totalParts = ratioC + ratioS;
    final cementM3 = dryVolume * ratioC / totalParts;
    final sandM3 = dryVolume * ratioS / totalParts;

    final cementBags = cementM3 / cementBagVolume;
    final sandCFT = UnitConverter.cubicMetersToCFT(sandM3);

    return PlasterResult(
      area: areaM2,
      cementBags: cementBags,
      sandM3: sandM3,
      sandCFT: sandCFT,
    );
  }

  /// Calculate area from length and width.
  static double areaFromDimensions(double length, double width, String unit) {
    final l = UnitConverter.toMeters(length, unit);
    final w = UnitConverter.toMeters(width, unit);
    return l * w;
  }
}
