/// Land-area unit conversion. All factors are square-feet per 1 unit.
/// बीघा is state-dependent, so it is passed in separately (from IndiaState).
class LandUnit {
  final String code;
  final String hi;
  final double sqFt; // 1 unit = this many square feet
  const LandUnit(this.code, this.hi, this.sqFt);
}

const List<LandUnit> kFixedLandUnits = [
  LandUnit('hectare', 'हेक्टेयर', 107639.0),
  LandUnit('acre', 'एकड़', 43560.0),
  LandUnit('guntha', 'गुंठा', 1089.0),
  LandUnit('sqm', 'वर्ग मीटर', 10.7639),
  LandUnit('sqft', 'वर्ग फुट', 1.0),
];

const double sqFtPerHectare = 107639.0;

/// Convert an area value (in the given unit) to hectares.
/// For बीघा/कट्ठा pass the state's bighaSqFt; katha = bigha/20.
double toHectares({
  required double value,
  required String unitCode,
  double? bighaSqFt,
}) {
  double sqFt;
  switch (unitCode) {
    case 'bigha':
      sqFt = value * (bighaSqFt ?? 27000);
      break;
    case 'katha':
      sqFt = value * ((bighaSqFt ?? 27000) / 20);
      break;
    default:
      final u = kFixedLandUnits.firstWhere(
        (e) => e.code == unitCode,
        orElse: () => kFixedLandUnits[1], // acre fallback
      );
      sqFt = value * u.sqFt;
  }
  return sqFt / sqFtPerHectare;
}
