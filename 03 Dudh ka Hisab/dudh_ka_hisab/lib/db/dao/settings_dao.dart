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

  /// Set a setting value. Creates if not exists, updates if exists.
  Future<void> setValue(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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
}
