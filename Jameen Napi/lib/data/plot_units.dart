/// खेत/प्लाट की भुजा नापने की इकाइयाँ — सभी मान फीट में।
///
/// पहले ये स्क्रीनों में `'फीट (Feet)'` जैसी strings थीं और factor
/// `unit.contains('गज')` से निकाला जाता था। भाषा बदलते ही वो मिलान टूट जाता,
/// इसलिए अब enum है: दिखने वाला नाम भाषा के हिसाब से बदलता है, गणित नहीं।
enum PlotUnit { feet, gaj, meter, kadi, latha }

extension PlotUnitMath on PlotUnit {
  /// 1 इकाई = कितने फीट
  double get feetFactor {
    switch (this) {
      case PlotUnit.feet:
        return 1.0;
      case PlotUnit.gaj:
        return 3.0;
      case PlotUnit.meter:
        return 3.28084;
      case PlotUnit.kadi:
        return 0.66; // 1 जरीब = 100 कड़ी = 66 फीट
      case PlotUnit.latha:
        return 8.25; // 5.5 हाथ
    }
  }
}

/// लंबाई × चौड़ाई मोड में कड़ी नहीं दिखती (वो जरीब के साथ काम आती है)।
const List<PlotUnit> lengthWidthUnits = [
  PlotUnit.feet,
  PlotUnit.gaj,
  PlotUnit.meter,
  PlotUnit.latha,
];

/// खेत नापने वाली स्क्रीनों की पूरी सूची।
const List<PlotUnit> plotSideUnits = PlotUnit.values;
