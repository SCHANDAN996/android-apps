import 'package:sqflite/sqflite.dart';
import '../dairy_database.dart';
import '../db_change_bus.dart';
import '../models/milk_entry.dart';

/// Data Access Object for entries table — handles daily milk record operations.
class EntryDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Insert a new milk entry. Returns the new row id.
  Future<int> insertEntry(MilkEntry entry) async {
    final db = await _dbHelper.database;
    final id = await db.insert('entries', entry.toMap());
    notifyDbChanged();
    return id;
  }

  /// Update an existing entry.
  Future<int> updateEntry(MilkEntry entry) async {
    final db = await _dbHelper.database;
    final n = await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
    notifyDbChanged();
    return n;
  }

  /// Delete an entry permanently.
  Future<int> deleteEntry(int id) async {
    final db = await _dbHelper.database;
    final n = await db.delete('entries', where: 'id = ?', whereArgs: [id]);
    notifyDbChanged();
    return n;
  }

  /// Check if a duplicate entry exists for the same date + shift + customer.
  Future<MilkEntry?> findDuplicate(
    String date,
    String shift,
    int? customerId,
  ) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;

    if (customerId != null) {
      maps = await db.query(
        'entries',
        where: 'date = ? AND shift = ? AND customerId = ?',
        whereArgs: [date, shift, customerId],
      );
    } else {
      maps = await db.query(
        'entries',
        where: 'date = ? AND shift = ? AND customerId IS NULL',
        whereArgs: [date, shift],
      );
    }
    if (maps.isEmpty) return null;
    return MilkEntry.fromMap(maps.first);
  }

  /// Get today's entries (किसान mode — no customerId filter).
  Future<List<MilkEntry>> getEntriesByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'shift ASC',
    );
    return maps.map((m) => MilkEntry.fromMap(m)).toList();
  }

  /// Get entries for a specific customer in a given month (MM-YYYY).
  Future<List<MilkEntry>> getCustomerMonthlyEntries(
    int customerId,
    String month, // MM-YYYY
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: "customerId = ? AND substr(date, 4) = ?",
      whereArgs: [customerId, month],
      orderBy: 'date ASC, shift ASC',
    );
    return maps.map((m) => MilkEntry.fromMap(m)).toList();
  }

  /// Get all entries for a month (किसान mode).
  Future<List<MilkEntry>> getMonthlyEntries(String month) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      where: "substr(date, 4) = ?",
      whereArgs: [month],
      orderBy: 'date ASC, shift ASC',
    );
    return maps.map((m) => MilkEntry.fromMap(m)).toList();
  }

  /// Get entries between start Date and end Date (inclusive) for reports.
  Future<List<MilkEntry>> getCustomDateRangeEntries(
    DateTime startDate,
    DateTime endDate, {
    int? customerId,
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps;
    if (customerId != null) {
      maps = await db.query(
        'entries',
        where: 'customerId = ?',
        whereArgs: [customerId],
        orderBy: 'id ASC',
      );
    } else {
      maps = await db.query('entries', orderBy: 'id ASC');
    }

    final startComparable = DateTime(startDate.year, startDate.month, startDate.day);
    final endComparable = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return maps.map((m) => MilkEntry.fromMap(m)).where((e) {
      try {
        final parts = e.date.split('-');
        if (parts.length != 3) return false;
        final d = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        return (d.isAfter(startComparable) || d.isAtSameMomentAs(startComparable)) &&
            (d.isBefore(endComparable) || d.isAtSameMomentAs(endComparable));
      } catch (_) {
        return false;
      }
    }).toList();
  }

  /// Get recent N entries (for home screen).
  Future<List<MilkEntry>> getRecentEntries({int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'entries',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map((m) => MilkEntry.fromMap(m)).toList();
  }

  /// Monthly totals: { totalLitres, totalAmount, avgFat, entryCount }
  Future<Map<String, double>> getMonthlyTotals(String month) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(qtyL), 0) as totalLitres,
        COALESCE(SUM(amount), 0) as totalAmount,
        COALESCE(AVG(fatPct), 0) as avgFat,
        COUNT(*) as entryCount
      FROM entries
      WHERE substr(date, 4) = ?
    ''', [month]);

    if (result.isEmpty) {
      return {
        'totalLitres': 0,
        'totalAmount': 0,
        'avgFat': 0,
        'entryCount': 0,
      };
    }

    final row = result.first;
    return {
      'totalLitres': (row['totalLitres'] as num).toDouble(),
      'totalAmount': (row['totalAmount'] as num).toDouble(),
      'avgFat': (row['avgFat'] as num).toDouble(),
      'entryCount': (row['entryCount'] as num).toDouble(),
    };
  }

  /// Directional monthly totals: { totalSell, totalBuy, netAmount, totalLitres, avgFat, entryCount }
  Future<Map<String, double>> getMonthlyDirectionalTotals(String month) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN direction = 'sell' THEN amount ELSE 0 END), 0) as totalSell,
        COALESCE(SUM(CASE WHEN direction = 'buy' THEN amount ELSE 0 END), 0) as totalBuy,
        COALESCE(SUM(qtyL), 0) as totalLitres,
        COALESCE(AVG(fatPct), 0) as avgFat,
        COUNT(*) as entryCount
      FROM entries
      WHERE substr(date, 4) = ?
    ''', [month]);

    if (result.isEmpty) {
      return {
        'totalSell': 0,
        'totalBuy': 0,
        'netAmount': 0,
        'totalLitres': 0,
        'avgFat': 0,
        'entryCount': 0,
      };
    }

    final row = result.first;
    final sell = (row['totalSell'] as num).toDouble();
    final buy = (row['totalBuy'] as num).toDouble();

    return {
      'totalSell': sell,
      'totalBuy': buy,
      'netAmount': sell - buy,
      'totalLitres': (row['totalLitres'] as num).toDouble(),
      'avgFat': (row['avgFat'] as num).toDouble(),
      'entryCount': (row['entryCount'] as num).toDouble(),
    };
  }

  /// Monthly totals for a specific customer.
  Future<Map<String, double>> getCustomerMonthlyTotals(
    int customerId,
    String month,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(qtyL), 0) as totalLitres,
        COALESCE(SUM(amount), 0) as totalAmount,
        COALESCE(AVG(fatPct), 0) as avgFat,
        COUNT(*) as entryCount
      FROM entries
      WHERE customerId = ? AND substr(date, 4) = ?
    ''', [customerId, month]);

    if (result.isEmpty) {
      return {
        'totalLitres': 0,
        'totalAmount': 0,
        'avgFat': 0,
        'entryCount': 0,
      };
    }

    final row = result.first;
    return {
      'totalLitres': (row['totalLitres'] as num).toDouble(),
      'totalAmount': (row['totalAmount'] as num).toDouble(),
      'avgFat': (row['avgFat'] as num).toDouble(),
      'entryCount': (row['entryCount'] as num).toDouble(),
    };
  }

  /// Get all entries (for backup).
  Future<List<MilkEntry>> getAllEntries() async {
    final db = await _dbHelper.database;
    final maps = await db.query('entries', orderBy: 'id ASC');
    return maps.map((m) => MilkEntry.fromMap(m)).toList();
  }

  /// Total entry count (for review prompt trigger).
  Future<int> getTotalEntryCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM entries');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
