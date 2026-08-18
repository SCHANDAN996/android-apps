import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../dairy_database.dart';

/// 📐 सेव किए हुए खेतों का Data Access Object
class SavedFieldDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// नया खेत सेव करो
  Future<int> saveField({
    required String name,
    required double areaSqM,
    required double perimeterM,
    required List<LatLng> points,
    String? stateCode,
  }) async {
    final db = await _dbHelper.database;
    final pointsJson = jsonEncode(
      points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );
    return db.insert('saved_fields', {
      'name': name,
      'areaSqM': areaSqM,
      'perimeterM': perimeterM,
      'pointsJson': pointsJson,
      'stateCode': stateCode,
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  /// सभी सेव किए हुए खेत — नए पहले
  Future<List<SavedField>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('saved_fields', orderBy: 'savedAt DESC');
    return maps.map(SavedField.fromMap).toList();
  }

  /// एक खेत डिलीट करो
  Future<int> deleteField(int id) async {
    final db = await _dbHelper.database;
    return db.delete('saved_fields', where: 'id = ?', whereArgs: [id]);
  }

  /// कितने खेत सेव हैं
  Future<int> count() async {
    final db = await _dbHelper.database;
    final r =
        await db.rawQuery('SELECT COUNT(*) c FROM saved_fields');
    return (r.first['c'] as int?) ?? 0;
  }
}

/// सेव किया हुआ खेत — model class
class SavedField {
  final int? id;
  final String name;
  final double areaSqM;
  final double perimeterM;
  final List<LatLng> points;
  final String? stateCode;
  final DateTime savedAt;

  const SavedField({
    this.id,
    required this.name,
    required this.areaSqM,
    required this.perimeterM,
    required this.points,
    this.stateCode,
    required this.savedAt,
  });

  factory SavedField.fromMap(Map<String, dynamic> map) {
    final raw = jsonDecode(map['pointsJson'] as String) as List;
    final pts = raw
        .map((e) => LatLng(
              (e['lat'] as num).toDouble(),
              (e['lng'] as num).toDouble(),
            ))
        .toList();
    return SavedField(
      id: map['id'] as int?,
      name: map['name'] as String,
      areaSqM: (map['areaSqM'] as num).toDouble(),
      perimeterM: (map['perimeterM'] as num).toDouble(),
      points: pts,
      stateCode: map['stateCode'] as String?,
      savedAt: DateTime.tryParse(map['savedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
