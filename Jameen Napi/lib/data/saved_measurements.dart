import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../geo/measure_session.dart';

/// नक्शे से किया गया एक सहेजा हुआ नाप।
///
/// सब कुछ फ़ोन में ही (`shared_preferences`) रहता है — कहीं भेजा नहीं जाता।
/// Privacy policy में यही लिखा है; इसे server पर भेजने से पहले policy और
/// Play का Data Safety फ़ॉर्म दोनों बदलने होंगे।
class SavedMeasurement {
  const SavedMeasurement({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.session,
  });

  final String id;
  final String name;
  final DateTime savedAt;
  final MeasureSession session;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'savedAt': savedAt.millisecondsSinceEpoch,
        'session': session.toJson(),
      };

  static SavedMeasurement? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'], name = json['name'], at = json['savedAt'];
    final session = MeasureSession.fromJson(json['session']);
    if (id is! String || name is! String || at is! int || session == null) {
      return null;
    }
    return SavedMeasurement(
      id: id,
      name: name,
      savedAt: DateTime.fromMillisecondsSinceEpoch(at),
      session: session,
    );
  }
}

class SavedMeasurementStore {
  SavedMeasurementStore._();
  static final SavedMeasurementStore instance = SavedMeasurementStore._();

  static const String prefKey = 'saved_map_measurements_v1';

  /// नया सबसे ऊपर
  Future<List<SavedMeasurement>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return decode(prefs.getString(prefKey));
  }

  /// [replaceId] देने पर उसी सहेजे हुए नाप को बदलिए, नया duplicate मत बनाइए।
  Future<SavedMeasurement> save(
    String name,
    MeasureSession session, {
    String? replaceId,
  }) async {
    final all = await loadAll();
    final now = DateTime.now();
    final item = SavedMeasurement(
      id: replaceId ?? now.microsecondsSinceEpoch.toString(),
      name: name,
      savedAt: now,
      session: session,
    );
    await _write([item, ...all.where((m) => m.id != item.id)]);
    return item;
  }

  Future<void> delete(String id) async {
    final all = await loadAll();
    await _write(all.where((m) => m.id != id).toList());
  }

  Future<void> _write(List<SavedMeasurement> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, encode(items));
  }

  static String encode(List<SavedMeasurement> items) =>
      jsonEncode([for (final m in items) m.toJson()]);

  /// टूटी entries चुपचाप छोड़ दी जाती हैं — एक ख़राब entry की वजह से
  /// बाक़ी सारे नाप ग़ायब नहीं होने चाहिए।
  static List<SavedMeasurement> decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .map(SavedMeasurement.fromJson)
          .whereType<SavedMeasurement>()
          .toList();
    } on FormatException {
      return [];
    }
  }
}
