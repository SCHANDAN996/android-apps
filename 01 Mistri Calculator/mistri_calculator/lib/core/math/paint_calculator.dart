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
}

class PaintCalculator {
  /// Coverage: 1 litre covers ~10 sq m (per coat).
  static const double coveragePerLitre = 10.0; // m² per litre per coat
  static const double openingsDeduction = 0.10; // 10% for doors/windows

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

  /// Suggest optimal bucket combination.
  static Map<String, int> _suggestBuckets(double litres) {
    final buckets = <String, int>{};
    var remaining = litres;

    for (final size in bucketSizes) {
      if (remaining >= size) {
        final count = (remaining / size).floor();
        buckets['${size}L'] = count;
        remaining -= count * size;
      }
    }

    // If there's a remainder, add one 1L bucket
    if (remaining > 0) {
      buckets['1L'] = (buckets['1L'] ?? 0) + 1;
    }

    return buckets;
  }
}
