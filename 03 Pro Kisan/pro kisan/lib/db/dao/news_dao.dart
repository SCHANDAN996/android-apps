import 'package:sqflite/sqflite.dart';
import '../dairy_database.dart';

class NewsDao {
  final DairyDatabase _dbHelper = DairyDatabase();

  /// Cache a list of news items into SQLite
  Future<void> cacheNews(List<Map<String, String>> newsList) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var item in newsList) {
      batch.insert(
        'news_cache',
        {
          'title': item['title'] ?? '',
          'desc': item['desc'] ?? '',
          'fullDesc': item['fullDesc'] ?? '',
          'date': item['date'] ?? '',
          'link': item['link'] ?? '',
          'image': item['image'] ?? '',
          'source': item['source'] ?? '',
          'category': item['category'] ?? 'all',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Fetch cached news items from SQLite
  Future<List<Map<String, String>>> getCachedNews() async {
    final db = await _dbHelper.database;
    final maps = await db.query('news_cache', orderBy: 'id DESC', limit: 100);
    return maps.map((m) => {
      'title': m['title']?.toString() ?? '',
      'desc': m['desc']?.toString() ?? '',
      'fullDesc': m['fullDesc']?.toString() ?? '',
      'date': m['date']?.toString() ?? '',
      'link': m['link']?.toString() ?? '',
      'image': m['image']?.toString() ?? '',
      'source': m['source']?.toString() ?? '',
      'category': m['category']?.toString() ?? 'all',
    }).toList();
  }

  /// Toggle bookmark / save news
  Future<bool> toggleSaveNews(Map<String, String> item) async {
    final db = await _dbHelper.database;
    final link = item['link'] ?? '';
    final existing = await db.query('saved_news', where: 'link = ?', whereArgs: [link]);
    if (existing.isNotEmpty) {
      await db.delete('saved_news', where: 'link = ?', whereArgs: [link]);
      return false; // Unsaved
    } else {
      await db.insert('saved_news', {
        'title': item['title'] ?? '',
        'desc': item['desc'] ?? '',
        'fullDesc': item['fullDesc'] ?? '',
        'date': item['date'] ?? '',
        'link': link,
        'image': item['image'] ?? '',
        'source': item['source'] ?? '',
        'savedAt': DateTime.now().toIso8601String(),
      });
      return true; // Saved
    }
  }

  /// Check if a news item is saved
  Future<bool> isNewsSaved(String link) async {
    if (link.isEmpty) return false;
    final db = await _dbHelper.database;
    final res = await db.query('saved_news', where: 'link = ?', whereArgs: [link]);
    return res.isNotEmpty;
  }

  /// Get all saved / bookmarked news items
  Future<List<Map<String, String>>> getSavedNews() async {
    final db = await _dbHelper.database;
    final maps = await db.query('saved_news', orderBy: 'id DESC');
    return maps.map((m) => {
      'title': m['title']?.toString() ?? '',
      'desc': m['desc']?.toString() ?? '',
      'fullDesc': m['fullDesc']?.toString() ?? '',
      'date': m['date']?.toString() ?? '',
      'link': m['link']?.toString() ?? '',
      'image': m['image']?.toString() ?? '',
      'source': m['source']?.toString() ?? '',
    }).toList();
  }
}
