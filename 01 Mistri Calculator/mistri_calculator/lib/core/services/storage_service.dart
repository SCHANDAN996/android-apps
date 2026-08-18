import 'package:shared_preferences/shared_preferences.dart';

/// Persists language, unit preference, rates, and calculation count.
class StorageService {
  late SharedPreferences _prefs;

  // Keys
  static const String _langKey = 'language';
  static const String _unitKey = 'default_unit';
  static const String _calcCountKey = 'calc_count';
  static const String _reviewShownKey = 'review_shown';

  // Rate keys
  static const String _brickRateKey = 'rate_brick';
  static const String _cementRateKey = 'rate_cement';
  static const String _sandRateKey = 'rate_sand';
  static const String _aggregateRateKey = 'rate_aggregate';
  static const String _steelRateKey = 'rate_steel';
  static const String _tileRateKey = 'rate_tile';
  static const String _paintRateKey = 'rate_paint';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Language ---
  String get language => _prefs.getString(_langKey) ?? 'hi';
  Future<void> setLanguage(String lang) => _prefs.setString(_langKey, lang);

  // --- Unit ---
  String get defaultUnit => _prefs.getString(_unitKey) ?? 'ft';
  Future<void> setDefaultUnit(String unit) => _prefs.setString(_unitKey, unit);

  // --- Calculation counter (for ad + review trigger) ---
  int get calcCount => _prefs.getInt(_calcCountKey) ?? 0;
  Future<void> incrementCalcCount() =>
      _prefs.setInt(_calcCountKey, calcCount + 1);

  // --- Review ---
  bool get reviewShown => _prefs.getBool(_reviewShownKey) ?? false;
  Future<void> setReviewShown() => _prefs.setBool(_reviewShownKey, true);

  // --- Rates ---
  double? get brickRate => _prefs.getDouble(_brickRateKey);
  double? get cementRate => _prefs.getDouble(_cementRateKey);
  double? get sandRate => _prefs.getDouble(_sandRateKey);
  double? get aggregateRate => _prefs.getDouble(_aggregateRateKey);
  double? get steelRate => _prefs.getDouble(_steelRateKey);
  double? get tileRate => _prefs.getDouble(_tileRateKey);
  double? get paintRate => _prefs.getDouble(_paintRateKey);

  Future<void> setBrickRate(double v) => _prefs.setDouble(_brickRateKey, v);
  Future<void> setCementRate(double v) => _prefs.setDouble(_cementRateKey, v);
  Future<void> setSandRate(double v) => _prefs.setDouble(_sandRateKey, v);
  Future<void> setAggregateRate(double v) =>
      _prefs.setDouble(_aggregateRateKey, v);
  Future<void> setSteelRate(double v) => _prefs.setDouble(_steelRateKey, v);
  Future<void> setTileRate(double v) => _prefs.setDouble(_tileRateKey, v);
  Future<void> setPaintRate(double v) => _prefs.setDouble(_paintRateKey, v);

  /// Returns a map of all set rates (non-null only).
  Map<String, double> get allRates {
    final rates = <String, double>{};
    if (brickRate != null) rates['brick'] = brickRate!;
    if (cementRate != null) rates['cement'] = cementRate!;
    if (sandRate != null) rates['sand'] = sandRate!;
    if (aggregateRate != null) rates['aggregate'] = aggregateRate!;
    if (steelRate != null) rates['steel'] = steelRate!;
    if (tileRate != null) rates['tile'] = tileRate!;
    if (paintRate != null) rates['paint'] = paintRate!;
    return rates;
  }
}
