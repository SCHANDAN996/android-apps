import '../dairy_database.dart';
import '../models/dairy_product_entry.dart';

/// Data Access Object for dairy_product_entries table.
class DairyProductDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Insert a new dairy product entry.
  Future<int> insertEntry(DairyProductEntry entry) async {
    final db = await _dbHelper.database;
    return await db.insert('dairy_product_entries', entry.toMap());
  }

  /// Update an existing entry.
  Future<int> updateEntry(DairyProductEntry entry) async {
    final db = await _dbHelper.database;
    return await db.update(
      'dairy_product_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Delete an entry.
  Future<int> deleteEntry(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('dairy_product_entries', where: 'id = ?', whereArgs: [id]);
  }

  /// Get all entries for today.
  Future<List<DairyProductEntry>> getEntriesByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dairy_product_entries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return maps.map((m) => DairyProductEntry.fromMap(m)).toList();
  }

  /// Get all entries for a month (MM-yyyy format).
  Future<List<DairyProductEntry>> getMonthlyEntries(String month) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dairy_product_entries',
      where: "substr(date, 4) = ?",
      whereArgs: [month],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => DairyProductEntry.fromMap(m)).toList();
  }

  /// Get monthly summary totals.
  Future<Map<String, double>> getMonthlyTotals(String month) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(milkUsedL), 0) as totalMilkUsed,
        COALESCE(SUM(productQtyKg), 0) as totalProductQty,
        COALESCE(SUM(totalAmount), 0) as totalAmount,
        COUNT(*) as entryCount
      FROM dairy_product_entries
      WHERE substr(date, 4) = ?
    ''', [month]);

    if (result.isEmpty) {
      return {
        'totalMilkUsed': 0,
        'totalProductQty': 0,
        'totalAmount': 0,
        'entryCount': 0,
      };
    }

    final row = result.first;
    return {
      'totalMilkUsed': (row['totalMilkUsed'] as num).toDouble(),
      'totalProductQty': (row['totalProductQty'] as num).toDouble(),
      'totalAmount': (row['totalAmount'] as num).toDouble(),
      'entryCount': (row['entryCount'] as num).toDouble(),
    };
  }

  /// Get recent entries for home screen.
  Future<List<DairyProductEntry>> getRecentEntries({int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'dairy_product_entries',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map((m) => DairyProductEntry.fromMap(m)).toList();
  }

  /// Get all entries (for backup).
  Future<List<DairyProductEntry>> getAllEntries() async {
    final db = await _dbHelper.database;
    final maps = await db.query('dairy_product_entries', orderBy: 'id ASC');
    return maps.map((m) => DairyProductEntry.fromMap(m)).toList();
  }
}
