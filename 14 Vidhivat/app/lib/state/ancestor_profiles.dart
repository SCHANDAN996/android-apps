import 'dart:convert';

import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vidhi/pitru_schedule.dart';

/// 0 = तिथि अज्ञात, 1–15 = कृष्ण प्रतिपदा–अमावस्या, 16 = पूर्णिमा।
class AncestorProfile {
  final String id;
  final String relation;
  final String name;
  final int tithi;
  final String source;
  final DateTime? deathLocal;
  final String placeName;
  final double latitude;
  final double longitude;
  final int utcOffsetMinutes;
  final bool reminder;
  final bool showNameOnLockScreen;

  const AncestorProfile({
    required this.id,
    required this.relation,
    required this.name,
    required this.tithi,
    required this.source,
    required this.deathLocal,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetMinutes,
    required this.reminder,
    required this.showNameOnLockScreen,
  });

  Place get place => Place(
        name: placeName,
        latitude: latitude,
        longitude: longitude,
        timeZoneOffset: Duration(minutes: utcOffsetMinutes),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'relation': relation,
        'name': name,
        'tithi': tithi,
        'source': source,
        'deathLocal': deathLocal?.toIso8601String(),
        'placeName': placeName,
        'latitude': latitude,
        'longitude': longitude,
        'utcOffsetMinutes': utcOffsetMinutes,
        'reminder': reminder,
        'showNameOnLockScreen': showNameOnLockScreen,
      };

  factory AncestorProfile.fromJson(Map<String, dynamic> j) => AncestorProfile(
        id: j['id'] as String,
        relation: j['relation'] as String,
        name: j['name'] as String? ?? '',
        tithi: j['tithi'] as int,
        source: j['source'] as String? ?? 'manual',
        deathLocal: DateTime.tryParse(j['deathLocal'] as String? ?? ''),
        placeName: j['placeName'] as String? ?? 'दिल्ली',
        latitude: (j['latitude'] as num?)?.toDouble() ?? 28.6139,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 77.2090,
        utcOffsetMinutes: j['utcOffsetMinutes'] as int? ?? 330,
        reminder: j['reminder'] == true,
        showNameOnLockScreen: j['showNameOnLockScreen'] == true,
      );

  /// देहांत के स्थानीय क्षण की वास्तविक चंद्र तिथि। अंग्रेज़ी तारीख़ मात्र
  /// से अनुमान नहीं लगाया जाता। अलग जगह/समय पर नतीजा बदल सकता है।
  static int tithiAtDeath(DateTime local, Place place) {
    final utc = DateTime.utc(
            local.year, local.month, local.day, local.hour, local.minute)
        .subtract(place.timeZoneOffset);
    final index = (elongationAt(julianDayFromUtc(utc)) / 12).floor() % 30;
    if (index == 14) return 16; // पूर्णिमा श्राद्ध अलग entry है।
    return index % 15 + 1;
  }

  FestivalDate? nextDay(DateTime now, {Place? observingPlace}) {
    for (final year in [now.year, now.year + 1]) {
      final schedule = pitruSchedule(year, observingPlace ?? place);
      final wantedTithi = tithi == 0
          ? 15
          : tithi == 16
              ? 15
              : tithi;
      final wantedPaksha = tithi == 16 ? 0 : 1;
      final matches = schedule.where((date) =>
          date.rule.tithi == wantedTithi && date.rule.paksha == wantedPaksha);
      if (matches.isEmpty) continue;
      final found = matches.first;
      if (!found.date.isBefore(DateTime(now.year, now.month, now.day))) {
        return found;
      }
    }
    return null;
  }
}

class AncestorProfiles {
  static const _key = 'ancestor_profiles_v1';
  final List<AncestorProfile> _items = [];

  List<AncestorProfile> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _items.clear();
    try {
      final raw = jsonDecode(prefs.getString(_key) ?? '[]');
      if (raw is List) {
        for (final item in raw) {
          try {
            _items.add(AncestorProfile.fromJson(
                Map<String, dynamic>.from(item as Map)));
          } catch (_) {
            // एक ख़राब entry से बाकी परिवार की तिथियाँ नहीं खोनी चाहिए।
          }
        }
      }
    } catch (_) {
      // पुराने/अधूरे local data से स्क्रीन खुलना बंद न हो।
    }
  }

  Future<void> save(AncestorProfile profile) async {
    _items.removeWhere((item) => item.id == profile.id);
    _items.add(profile);
    await _persist();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_items.map((p) => p.toJson()).toList()));
  }
}

final ancestorProfiles = AncestorProfiles();
