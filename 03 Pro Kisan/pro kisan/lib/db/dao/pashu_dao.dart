import '../dairy_database.dart';
import '../models/pashu.dart';

/// Data Access Object for the pashu ("मेरे पशु") table.
class PashuDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  Future<int> insert(Pashu p) async {
    final db = await _dbHelper.database;
    return db.insert('pashu', p.toMap());
  }

  Future<int> update(Pashu p) async {
    final db = await _dbHelper.database;
    return db.update('pashu', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  /// Soft delete — रिकॉर्ड रहता है, सूची से हट जाता है।
  Future<int> deactivate(int id) async {
    final db = await _dbHelper.database;
    return db.update('pashu', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete('pashu', where: 'id = ?', whereArgs: [id]);
  }

  /// सूची किसान के लिए क्रम में:
  ///  1) आज या तारीख़ निकल चुकी (सबसे ज़रूरी — पहले)
  ///  2) पास आ रहा ब्याना (कम दिन बचे → पहले)
  ///  3) बाक़ी सब जिनकी AI तारीख़ नहीं (नए-पुराने क्रम में)
  Future<List<Pashu>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('pashu', where: 'active = 1');
    final list = maps.map(Pashu.fromMap).toList();
    list.sort((a, b) {
      final da = a.daysToCalving;
      final db2 = b.daysToCalving;
      if (da == null && db2 == null) return (b.id ?? 0).compareTo(a.id ?? 0);
      if (da == null) return 1;
      if (db2 == null) return -1;
      return da.compareTo(db2);
    });
    return list;
  }

  /// जिन पशुओं का ब्याना आने वाला है — सबसे पास वाला पहले।
  Future<List<Pashu>> getUpcomingCalvings({int withinDays = 30}) async {
    final all = await getAll();
    final list = all.where((p) {
      final d = p.daysToCalving;
      return d != null && d >= 0 && d <= withinDays;
    }).toList();
    list.sort((a, b) => (a.daysToCalving ?? 0).compareTo(b.daysToCalving ?? 0));
    return list;
  }

  Future<int> count() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery('SELECT COUNT(*) c FROM pashu WHERE active = 1');
    return (r.first['c'] as int?) ?? 0;
  }
}
