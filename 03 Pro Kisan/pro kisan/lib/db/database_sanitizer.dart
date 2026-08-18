import 'dairy_database.dart';

/// DatabaseSanitizer — runs self-healing checks and purges orphaned records on startup.
class DatabaseSanitizer {
  DatabaseSanitizer._();
  static final DatabaseSanitizer instance = DatabaseSanitizer._();

  Future<void> sanitizeDatabase() async {
    try {
      final db = await DairyDatabase.instance.database;

      // 1. Run PRAGMA integrity check
      final integrityResult = await db.rawQuery('PRAGMA integrity_check');
      if (integrityResult.isNotEmpty) {
        final status = integrityResult.first.values.first.toString();
        if (status != 'ok') {
          // Attempt automatic vacuum repair
          await db.execute('VACUUM');
        }
      }

      // 2. Clean up orphaned milk entries referencing deleted customers
      await db.execute('''
        DELETE FROM entries 
        WHERE customerId IS NOT NULL 
        AND customerId NOT IN (SELECT id FROM customers)
      ''');

      // 3. Clean up orphaned payments referencing deleted customers
      await db.execute('''
        DELETE FROM payments 
        WHERE customerId NOT IN (SELECT id FROM customers)
      ''');

    } catch (e) {
      // Diagnostic fallback — failsafe so startup is never blocked
    }
  }
}
