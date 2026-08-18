import 'package:sqflite/sqflite.dart';
import '../dairy_database.dart';

/// Data Access Object for settings table — key-value store for app config.
class SettingsDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Get a setting value by key. Returns null if not found.
  Future<String?> getValue(String key) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<String?> getSetting(String key) => getValue(key);

  /// Set a setting value. Creates if not exists, updates if exists.
  Future<void> setValue(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setSetting(String key, String value) => setValue(key, value);

  /// Get the current mode: 'kisan' or 'doodhwala'.
  Future<String> getMode() async {
    return await getValue('mode') ?? 'kisan';
  }

  /// Set the current mode.
  Future<void> setMode(String mode) async {
    await setValue('mode', mode);
  }

  /// Get the current flat rate.
  Future<double> getFlatRate() async {
    final val = await getValue('flatRate');
    return double.tryParse(val ?? '60') ?? 60.0;
  }

  /// Set the flat rate.
  Future<void> setFlatRate(double rate) async {
    await setValue('flatRate', rate.toString());
  }

  /// Get the rate per fat point (for fat-based pricing).
  Future<double> getRatePerFatPoint() async {
    final val = await getValue('ratePerFatPoint');
    return double.tryParse(val ?? '6.8') ?? 6.8;
  }

  /// Set the rate per fat point.
  Future<void> setRatePerFatPoint(double rate) async {
    await setValue('ratePerFatPoint', rate.toString());
  }

  /// Get the current language code.
  Future<String> getLanguage() async {
    return await getValue('language') ?? 'hi';
  }

  /// Set the current language code.
  Future<void> setLanguage(String langCode) async {
    await setValue('language', langCode);
  }

  /// Get total entry count (for review prompt).
  Future<int> getEntryCount() async {
    final val = await getValue('entryCount');
    return int.tryParse(val ?? '0') ?? 0;
  }

  /// Increment entry count.
  Future<void> incrementEntryCount() async {
    final current = await getEntryCount();
    await setValue('entryCount', (current + 1).toString());
  }

  /// Check if review prompt has been shown.
  Future<bool> isReviewShown() async {
    final val = await getValue('reviewShown');
    return val == 'true';
  }

  /// Mark review prompt as shown.
  Future<void> setReviewShown() async {
    await setValue('reviewShown', 'true');
  }

  /// Check if first run (mode selection needed).
  Future<bool> isFirstRun() async {
    final val = await getValue('firstRunComplete');
    return val != 'true';
  }

  /// Mark first run as complete.
  Future<void> setFirstRunComplete() async {
    await setValue('firstRunComplete', 'true');
  }

  /// Get rate type: 'flat' or 'fat'.
  Future<String> getRateType() async {
    return await getValue('rateType') ?? 'flat';
  }

  /// Set rate type.
  Future<void> setRateType(String type) async {
    await setValue('rateType', type);
  }

  /// Get the selected state code (राज्य). Default: उत्तर प्रदेश.
  Future<String> getStateCode() async {
    return await getValue('stateCode') ?? 'UP';
  }

  /// Set the selected state code.
  Future<void> setStateCode(String code) async {
    await setValue('stateCode', code);
  }

  /// Get occupations as a list (e.g. ['dudh','pashu','kheti']).
  Future<List<String>> getOccupations() async {
    final val = await getValue('occupations') ?? '';
    if (val.isEmpty) return const [];
    return val.split(',').where((e) => e.isNotEmpty).toList();
  }

  /// Set occupations (stored comma-separated).
  Future<void> setOccupations(List<String> occ) async {
    await setValue('occupations', occ.join(','));
  }

  /// Get if morning reminder is enabled.
  Future<bool> isMorningReminderEnabled() async {
    final val = await getValue('morningReminderEnabled');
    return val != 'false'; // default true
  }

  /// Set if morning reminder is enabled.
  Future<void> setMorningReminderEnabled(bool enabled) async {
    await setValue('morningReminderEnabled', enabled.toString());
  }

  /// Get morning reminder time (format: HH:mm).
  Future<String> getMorningReminderTime() async {
    return await getValue('morningReminderTime') ?? '08:30';
  }

  /// Set morning reminder time.
  Future<void> setMorningReminderTime(String time) async {
    await setValue('morningReminderTime', time);
  }

  /// Get if evening reminder is enabled.
  Future<bool> isEveningReminderEnabled() async {
    final val = await getValue('eveningReminderEnabled');
    return val != 'false'; // default true
  }

  /// Set if evening reminder is enabled.
  Future<void> setEveningReminderEnabled(bool enabled) async {
    await setValue('eveningReminderEnabled', enabled.toString());
  }

  /// Get evening reminder time (format: HH:mm).
  Future<String> getEveningReminderTime() async {
    return await getValue('eveningReminderTime') ?? '20:30';
  }

  /// Set evening reminder time.
  Future<void> setEveningReminderTime(String time) async {
    await setValue('eveningReminderTime', time);
  }

  /// Get all settings as a map (for backup).
  Future<Map<String, String>> getAllSettings() async {
    final db = await _dbHelper.database;
    final maps = await db.query('settings');
    final result = <String, String>{};
    for (final m in maps) {
      result[m['key'] as String] = m['value'] as String? ?? '';
    }
    return result;
  }
  /// Entry Screen Tour
  Future<bool> hasSeenEntryTour() async {
    final val = await getValue('has_seen_entry_tour');
    return val == 'true';
  }
  Future<void> setSeenEntryTour() async {
    await setValue('has_seen_entry_tour', 'true');
  }

  /// Khaad Screen Tour
  Future<bool> hasSeenKhaadTour() async {
    final val = await getValue('has_seen_khaad_tour');
    return val == 'true';
  }
  Future<void> setSeenKhaadTour() async {
    await setValue('has_seen_khaad_tour', 'true');
  }

  /// Customer Screen Tour
  Future<bool> hasSeenCustomerTour() async {
    final val = await getValue('has_seen_customer_tour');
    return val == 'true';
  }
  Future<void> setSeenCustomerTour() async {
    await setValue('has_seen_customer_tour', 'true');
  }
}
