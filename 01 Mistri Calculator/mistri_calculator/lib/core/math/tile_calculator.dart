import '../utils/unit_converter.dart';

/// Tile calculation result.
class TileResult {
  final double floorArea; // in m² or sq ft based on unit
  final double tileArea; // single tile area
  final int totalTiles;
  final int totalBoxes;

  TileResult({
    required this.floorArea,
    required this.tileArea,
    required this.totalTiles,
    required this.totalBoxes,
  });
}

/// Predefined tile size options.
class TileSize {
  final String label;
  final double lengthMm;
  final double widthMm;

  const TileSize(this.label, this.lengthMm, this.widthMm);

  double get areaM2 => (lengthMm / 1000) * (widthMm / 1000);
}

class TileCalculator {
  static const double wastage = 1.10; // 10%

  static const List<TileSize> standardSizes = [
    TileSize('1×1 ft (300×300mm)', 300, 300),
    TileSize('2×2 ft (600×600mm)', 600, 600),
    TileSize('300×600mm', 300, 600),
    TileSize('800×800mm', 800, 800),
    TileSize('1200×600mm', 1200, 600),
  ];

  /// Calculate tile requirement.
  ///
  /// [floorLength], [floorWidth] in user unit (ft or m).
  /// [tileSize] = predefined or custom TileSize.
  /// [tilesPerBox] = how many tiles in one box.
  static TileResult calculate({
    required double floorLength,
    required double floorWidth,
    required String unit,
    required TileSize tileSize,
    required int tilesPerBox,
  }) {
    final l = UnitConverter.toMeters(floorLength, unit);
    final w = UnitConverter.toMeters(floorWidth, unit);
    final floorAreaM2 = l * w;

    final tileAreaM2 = tileSize.areaM2;

    // Tiles with wastage
    final tiles = (floorAreaM2 / tileAreaM2 * wastage).ceil();

    // Boxes
    final boxes = (tiles / tilesPerBox).ceil();

    return TileResult(
      floorArea: floorAreaM2,
      tileArea: tileAreaM2,
      totalTiles: tiles,
      totalBoxes: boxes,
    );
  }
}
