/// Unit conversion utilities for construction calculations.
class UnitConverter {
  // Length
  static const double feetToMetersFactor = 0.3048;
  static const double metersToFeetFactor = 1 / feetToMetersFactor;

  // Volume
  // Derived from the one exact figure (1 ft = 0.3048 m), so 150 cft typed in
  // feet comes back as 150 cft — not 150.0001, which would round up to 151.
  static const double cubicFeetToMetersFactor =
      feetToMetersFactor * feetToMetersFactor * feetToMetersFactor;
  static const double cubicMetersToFeetFactor = 1 / cubicFeetToMetersFactor;

  // Area
  static const double sqFeetToSqMetersFactor =
      feetToMetersFactor * feetToMetersFactor;
  static const double sqMetersToSqFeetFactor = 1 / sqFeetToSqMetersFactor;

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

  /// The unit a mason uses for small sizes — slab thickness, column and beam
  /// cross-section. Nobody says "0.42 ft"; it is "5 inch" (or 125 mm).
  static String smallUnit(String unit) => unit == 'ft' ? 'in' : 'mm';

  /// Convert a [smallUnit] value (inches or mm) to meters.
  static double smallToMeters(double value, String unit) =>
      unit == 'ft' ? inchesToMeters(value) : mmToMeters(value);

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
