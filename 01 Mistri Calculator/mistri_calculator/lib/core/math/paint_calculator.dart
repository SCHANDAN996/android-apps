import '../utils/purchase.dart';
import '../utils/unit_converter.dart';

/// Paint calculation result.
class PaintResult {
  final double areaM2;
  final int coats;
  final double totalLitres;
  final Map<String, int> bucketSuggestion; // e.g., {'20L': 1, '4L': 1, '1L': 2}

  PaintResult({
    required this.areaM2,
    required this.coats,
    required this.totalLitres,
    required this.bucketSuggestion,
  });

  /// One coat of primer under the paint.
  double get primerLitres => areaM2 / PaintCalculator.primerCoveragePerLitre;

  /// Two coats of wall putty to level the plaster.
  double get puttyKg => areaM2 / PaintCalculator.puttyCoveragePerKg;
}

class PaintCalculator {
  /// Coverage: 1 litre covers ~10 sq m (per coat).
  static const double coveragePerLitre = 10.0; // m² per litre per coat
  static const double openingsDeduction = 0.10; // 10% for doors/windows

  /// Rough shop figures: a litre of primer does about 10 m² in one coat, and
  /// a kilo of putty about 20 sq ft (1.86 m²) in two coats.
  static const double primerCoveragePerLitre = 10.0;
  static const double puttyCoveragePerKg = 1.86;

  /// Bucket sizes in litres
  static const List<int> bucketSizes = [20, 10, 4, 1];

  /// Calculate paint by direct area (m²).
  static PaintResult calculateByArea({
    required double areaM2,
    required int coats,
  }) {
    final litres = areaM2 * coats / coveragePerLitre;
    final buckets = _suggestBuckets(litres);

    return PaintResult(
      areaM2: areaM2,
      coats: coats,
      totalLitres: litres,
      bucketSuggestion: buckets,
    );
  }

  /// Calculate paint by room dimensions.
  /// Auto wall area = 2(L+W)×H minus 10% openings.
  static PaintResult calculateByRoom({
    required double length,
    required double width,
    required double height,
    required String unit,
    required int coats,
  }) {
    final l = UnitConverter.toMeters(length, unit);
    final w = UnitConverter.toMeters(width, unit);
    final h = UnitConverter.toMeters(height, unit);

    final wallArea = 2 * (l + w) * h;
    final areaAfterOpenings = wallArea * (1 - openingsDeduction);

    return calculateByArea(areaM2: areaAfterOpenings, coats: coats);
  }

  /// Suggest the bucket combination to buy.
  ///
  /// Paint is sold in whole tins, so the need is rounded up to a whole litre
  /// first — 9.5 L becomes one 10 L bucket, not 4 + 4 + 1 + 1.
  static Map<String, int> _suggestBuckets(double litres) {
    final buckets = <String, int>{};
    var remaining = roundUpToBuy(litres);

    for (final size in bucketSizes) {
      final count = remaining ~/ size;
      if (count > 0) {
        buckets['${size}L'] = count;
        remaining -= count * size;
      }
    }

    return buckets;
  }
}
