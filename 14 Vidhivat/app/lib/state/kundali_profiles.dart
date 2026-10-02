import 'dart:convert';

import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// जन्म का ब्यौरा — एक आदमी, एक कुंडली (→ D-105, docs/29 चरण K3)।
///
/// **सिर्फ़ फ़ोन में** (`SharedPreferences`), `AncestorProfiles` वाला ही ढाँचा।
/// ऐप में सर्वर है ही नहीं; यह कहीं नहीं जाता।
///
/// कुंडली ख़ुद **सहेजी नहीं जाती** — हर बार जन्म के ब्यौरे से दोबारा निकलती
/// है। इससे इंजन का कोई सुधार पुरानी कुंडलियों तक अपने आप पहुँचता है।
class KundaliProfile {
  final String id;
  final String naam;

  /// जन्म — **घड़ी का समय** (साल, महीना, दिन, घंटा, मिनट)। समय-क्षेत्र का
  /// निशान इसमें नहीं है; वह [place] से आता है।
  final DateTime janm;

  final String sthanNaam;
  final double latitude;
  final double longitude;

  const KundaliProfile({
    required this.id,
    required this.naam,
    required this.janm,
    required this.sthanNaam,
    required this.latitude,
    required this.longitude,
  });

  /// जन्म की जगह — और उस क्षण भारत की घड़ी का UTC से अंतर। 1941–45 के दो
  /// दौर में घड़ी एक घंटा आगे थी (→ `bharat_samay.dart`)।
  Place get place => Place(
        name: sthanNaam,
        latitude: latitude,
        longitude: longitude,
        timeZoneOffset: bharatSamayAntar(janm),
      );

  /// जन्म का क्षण, UTC में — इंजन यही लेता है।
  DateTime get janmUtc =>
      DateTime.utc(janm.year, janm.month, janm.day, janm.hour, janm.minute)
          .subtract(bharatSamayAntar(janm));

  bool get yuddhKal => yuddhKalKiGhadi(janm);

  Map<String, Object?> toJson() => {
        'id': id,
        'naam': naam,
        'janm': DateTime(janm.year, janm.month, janm.day, janm.hour, janm.minute)
            .toIso8601String(),
        'sthanNaam': sthanNaam,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory KundaliProfile.fromJson(Map<String, dynamic> j) => KundaliProfile(
        id: j['id'] as String,
        naam: j['naam'] as String? ?? '',
        janm: DateTime.parse(j['janm'] as String),
        sthanNaam: j['sthanNaam'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );
}

class KundaliProfiles {
  static const _key = 'kundali_profiles_v1';
  final List<KundaliProfile> _items = [];

  List<KundaliProfile> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _items.clear();
    try {
      final raw = jsonDecode(prefs.getString(_key) ?? '[]');
      if (raw is List) {
        for (final item in raw) {
          try {
            _items.add(
                KundaliProfile.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (_) {
            // एक ख़राब entry से बाक़ी परिवार की कुंडलियाँ नहीं खोनी चाहिए।
          }
        }
      }
    } catch (_) {
      // पुराने/अधूरे local data से स्क्रीन खुलना बंद न हो।
    }
  }

  Future<void> save(KundaliProfile profile) async {
    final i = _items.indexWhere((item) => item.id == profile.id);
    if (i >= 0) {
      _items[i] = profile;
    } else {
      _items.add(profile);
    }
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

final kundaliProfiles = KundaliProfiles();
