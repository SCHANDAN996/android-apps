/// Unit conversion utilities for construction calculations.
class UnitConverter {
  // Length
  static const double feetToMetersFactor = 0.3048;
  static const double metersToFeetFactor = 3.28084;

  // Volume
  static const double cubicMetersToFeetFactor = 35.3147; // 1 m³ = 35.31 CFT
  static const double cubicFeetToMetersFactor = 0.0283168;

  // Area
  static const double sqFeetToSqMetersFactor = 0.092903;
  static const double sqMetersToSqFeetFactor = 10.7639;

  // --- Length ---
  static double feetToMeters(double ft) => ft * feetToMetersFactor;
  static double metersToFeet(double m) => m * metersToFeetFactor;

  // --- Volume ---
  static double cubicMetersToCFT(double m3) => m3 * cubicMetersToFeetFactor;
  static double cftToCubicMeters(double cft) => cft * cubicFeetToMetersFactor;

  // --- Area ---
  static double sqFeetToSqMeters(double sqft) => sqft * sqFeetToSqMetersFactor;
  static double sqMetersToSqFeet(double sqm) => sqm * sqMetersToSqFeetFactor;

  // --- Inches to Meters ---
  static double inchesToMeters(double inches) => inches * 0.0254;
  static double mmToMeters(double mm) => mm / 1000.0;

  /// Convert a value to meters based on current unit.
  static double toMeters(double value, String unit) {
    switch (unit) {
      case 'ft':
        return feetToMeters(value);
      case 'm':
        return value;
      default:
        return value;
    }
  }

  /// Convert a value to square meters based on current unit.
  static double toSqMeters(double value, String unit) {
    switch (unit) {
      case 'ft':
        return sqFeetToSqMeters(value);
      case 'm':
        return value;
      default:
        return value;
    }
  }
}
