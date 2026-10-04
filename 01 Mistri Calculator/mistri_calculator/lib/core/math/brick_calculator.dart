import '../utils/purchase.dart';
import '../utils/unit_converter.dart';

/// A brick's nominal size in millimetres.
///
/// Everything about a brick wall follows from this: how many bricks fit in a
/// cubic metre, how much of the wall is mortar, and how thick a half- or
/// full-brick wall comes out. Sizes vary a lot across India, so the user can
/// pick a preset or type their own.
class BrickSize {
  /// Stable id, also the key stored in preferences.
  final String id;
  final double lengthMm;
  final double widthMm;
  final double heightMm;

  const BrickSize({
    required this.id,
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
  });

  /// Mortar joint between two bricks — 10 mm is standard practice.
  static const double mortarJointMm = 10;

  /// 230x110x70 — the common desi brick across North India. Default.
  static const BrickSize desi = BrickSize(
    id: 'desi',
    lengthMm: 230,
    widthMm: 110,
    heightMm: 70,
  );

  /// 190x90x90 — IS 1077 modular brick.
  static const BrickSize modular = BrickSize(
    id: 'modular',
    lengthMm: 190,
    widthMm: 90,
    heightMm: 90,
  );

  /// 250x120x75 — the larger desi brick found in parts of UP/Bihar/Punjab.
  static const BrickSize bigDesi = BrickSize(
    id: 'big',
    lengthMm: 250,
    widthMm: 120,
    heightMm: 75,
  );

  static const List<BrickSize> presets = [desi, modular, bigDesi];

  /// Id used for a user-entered size.
  static const String customId = 'custom';

  bool get isCustom => id == customId;

  /// Volume of one brick including its share of the mortar joint (m³).
  double get volumeWithMortarM3 =>
      ((lengthMm + mortarJointMm) *
          (widthMm + mortarJointMm) *
          (heightMm + mortarJointMm)) /
      1e9;

  /// Volume of the brick itself, no mortar (m³).
  double get volumeM3 => (lengthMm * widthMm * heightMm) / 1e9;

  /// Bricks in one cubic metre of finished wall.
  double get bricksPerM3 => 1 / volumeWithMortarM3;

  /// Share of the wall volume that is mortar, not brick (0–1).
  double get mortarFraction => 1 - (volumeM3 / volumeWithMortarM3);

  /// Half-brick ("4.5 inch") wall — bricks laid lengthwise, so the wall is as
  /// thick as the brick is wide.
  double get halfWallThicknessM => widthMm / 1000;

  /// Full-brick ("9 inch") wall — headers laid across, so the wall is as thick
  /// as the brick is long.
  double get fullWallThicknessM => lengthMm / 1000;

  /// Sanity limits for a custom size, in mm.
  static const double minDimMm = 50;
  static const double maxDimMm = 400;

  /// True when all three dimensions are within [minDimMm]–[maxDimMm] and the
  /// brick is not taller/wider than it is long.
  bool get isValid {
    bool ok(double v) => v >= minDimMm && v <= maxDimMm;
    return ok(lengthMm) &&
        ok(widthMm) &&
        ok(heightMm) &&
        widthMm <= lengthMm &&
        heightMm <= lengthMm;
  }

  static BrickSize custom(double l, double w, double h) =>
      BrickSize(id: customId, lengthMm: l, widthMm: w, heightMm: h);

  static BrickSize? presetById(String id) {
    for (final p in presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  static const double mmPerInch = 25.4;

  /// The brick in inches — the unit masons actually speak in.
  double get lengthIn => lengthMm / mmPerInch;
  double get widthIn => widthMm / mmPerInch;
  double get heightIn => heightMm / mmPerInch;

  /// `9 x 4.25 x 2.75` — inches, for chips and the share text.
  String get label =>
      '${formatInches(lengthIn)} x ${formatInches(widthIn)} x ${formatInches(heightIn)}';

  /// Inches rounded to the nearest quarter — a mason says "9 inch" and
  /// "four and a half", never "9.06".
  static String formatInches(double inches) {
    final q = (inches * 4).roundToDouble() / 4;
    return q == q.roundToDouble()
        ? q.toStringAsFixed(0)
        : q.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }

  /// `230 x 110 x 70` — millimetres, kept for anyone who wants the exact size.
  String get labelMm => '${_n(lengthMm)} x ${_n(widthMm)} x ${_n(heightMm)}';

  static String _n(double v) {
    final rounded = (v * 10).roundToDouble() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
  }
}

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

  /// Whole bags / whole CFT to actually order.
  int get cementBagsToBuy => roundUpToBuy(cementBags);
  int get sandCftToBuy => roundUpToBuy(sandCFT);
}

class BrickCalculator {
  /// Constants
  static const double wastage = 1.05; // 5%
  static const double dryVolumeFactor = 1.33; // dry mortar factor
  static const double mortarWastage = 1.05; // 5% — mortar dropped while laying
  static const double cementBagVolume = 0.0347; // 1 bag = 50kg = 0.0347 m³

  /// Default brick — the desi 230x110x70.
  static const BrickSize defaultBrick = BrickSize.desi;

  /// Calculate brick wall materials.
  ///
  /// [length] and [height] in user's unit (ft or m).
  /// [unit] = 'ft' or 'm'.
  /// [thicknessM] = wall thickness, derived from [brick] (half or full).
  /// [ratioC] and [ratioS] = mortar ratio parts (e.g., 1:6 → c=1, s=6).
  static BrickResult calculate({
    required double length,
    required double height,
    required String unit,
    required double thicknessM,
    required int ratioC,
    required int ratioS,
    BrickSize brick = defaultBrick,
  }) {
    // Convert to meters
    final lengthM = UnitConverter.toMeters(length, unit);
    final heightM = UnitConverter.toMeters(height, unit);

    // Wall volume
    final volume = lengthM * heightM * thicknessM;

    // Bricks (with wastage)
    final bricks = (volume * brick.bricksPerM3 * wastage).ceil();

    // Mortar — whatever the bricks don't fill
    final mortarWet = volume * brick.mortarFraction;
    final mortarDry = mortarWet * dryVolumeFactor * mortarWastage;

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
