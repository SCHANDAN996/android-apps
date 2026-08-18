import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// मौसम — API, cache और "कई जगहें" तीनों का काम यहीं।
///
/// ⚠️ सबसे ज़रूरी बात — **cache पहले**।
/// पहले screen खुलते ही GPS (10 सेकंड तक) → जगह का नाम (4 सेकंड) → मौसम API
/// (15 सेकंड तक) चलता था, और cache सिर्फ़ *गड़बड़ होने पर* पढ़ा जाता था। यानी
/// सबसे बुरी हालत में किसान 29 सेकंड ख़ाली स्क्रीन देखता था।
/// अब: पहले cache से तुरंत दिखाओ, ताज़ा data पीछे-पीछे आकर चुपचाप बदल दे।
class WeatherService {
  static final WeatherService instance = WeatherService._();
  WeatherService._();

  static const String _kPlaces = 'weather_places_v2';
  static const String _kCachePrefix = 'weather_cache_v2_';
  /// पिछली 6 खोजें — search sheet खाली query पर यही दिखाता है
  static const String _kRecent = 'weather_recent_search_v1';
  static const int _maxRecent = 6;

  /// एक साथ इतनी ही जगहें — इससे ज़्यादा में API और उलझन दोनों बढ़ती हैं
  static const int maxPlaces = 8;

  /// इतने पुराने cache को "बासी" मानकर पीछे से ताज़ा कर लेते हैं
  static const Duration freshFor = Duration(minutes: 30);

  // ── जगहों की सूची ──────────────────────────────────────────────────────

  Future<List<WeatherPlace>> getPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPlaces);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => WeatherPlace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlaces(List<WeatherPlace> places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kPlaces, jsonEncode(places.map((p) => p.toJson()).toList()));
  }

  /// नई जगह जोड़ो। पहले से हो तो कुछ नहीं। सीमा भर गई हो तो false।
  Future<bool> addPlace(WeatherPlace place) async {
    final places = await getPlaces();
    if (places.any((p) => p.sameSpotAs(place))) return true;
    if (places.length >= maxPlaces) return false;
    places.add(place);
    await savePlaces(places);
    return true;
  }

  Future<void> removePlace(WeatherPlace place) async {
    final places = await getPlaces();
    places.removeWhere((p) => p.sameSpotAs(place));
    await savePlaces(places);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachePrefix + place.cacheKey);
  }

  // ── cache ──────────────────────────────────────────────────────────────

  Future<CachedWeather?> readCache(WeatherPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCachePrefix + place.cacheKey);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return CachedWeather(
        data: m['data'] as Map<String, dynamic>,
        savedAt: DateTime.fromMillisecondsSinceEpoch(m['at'] as int),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> writeCache(WeatherPlace place, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCachePrefix + place.cacheKey,
      jsonEncode({'data': data, 'at': DateTime.now().millisecondsSinceEpoch}),
    );
  }

  // ── API ────────────────────────────────────────────────────────────────

  /// Open-Meteo से मौसम लाओ। कोई key नहीं चाहिए।
  ///
  /// पहले से ज़्यादा fields माँगते हैं ताकि card पर touch करने पर पूरी
  /// जानकारी दिखाई जा सके — सूर्योदय/सूर्यास्त, हवा की दिशा, "महसूस" तापमान,
  /// बारिश की संभावना वग़ैरह।
  Future<Map<String, dynamic>> fetch(WeatherPlace place) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${place.lat}&longitude=${place.lon}'
      '&current=temperature_2m,apparent_temperature,relative_humidity_2m,'
      'weather_code,wind_speed_10m,wind_direction_10m,uv_index,precipitation'
      '&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,'
      'weather_code,precipitation_probability,precipitation,'
      'wind_speed_10m,wind_direction_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'apparent_temperature_max,apparent_temperature_min,'
      'precipitation_sum,precipitation_probability_max,'
      'wind_speed_10m_max,uv_index_max,sunrise,sunset'
      '&timezone=auto&forecast_days=10',
    );

    final res = await http.get(url).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('weather api ${res.statusCode}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  // ── हाल की खोजें — search sheet के लिए ─────────────────────────────

  Future<List<WeatherPlace>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRecent);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => WeatherPlace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// नई खोज सबसे ऊपर, दुबारा हो तो पुरानी हटाओ, कुल _maxRecent तक।
  Future<void> addRecentSearch(WeatherPlace place) async {
    final list = await getRecentSearches();
    list.removeWhere((p) => p.sameSpotAs(place));
    list.insert(0, place);
    while (list.length > _maxRecent) {
      list.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kRecent, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  /// शहर खोजो (नई जगह जोड़ने के लिए)
  /// शहर/गाँव खोजो — **दो स्रोत एक साथ**, फिर मिलाकर।
  ///
  /// पहले सिर्फ़ Open-Meteo था। उसमें दो कमियाँ थीं:
  ///  • भारत के छोटे गाँव/कस्बे उसमें हैं ही नहीं
  ///  • हिंदी में लिखो (जैसे "वाराणसी") तो कुछ नहीं मिलता
  /// इसलिए अब Nominatim (OpenStreetMap) भी साथ में — उसमें गाँव-कस्बे तक हैं
  /// और वह हिंदी में लिखा नाम भी पहचानता है। दोनों के नतीजे मिलाकर, भारत
  /// वाले ऊपर, और एक जैसी जगहें हटाकर दिखाते हैं।
  Future<List<WeatherPlace>> searchCity(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final results = await Future.wait([
      _searchOpenMeteo(q),
      _searchNominatim(q),
    ]);

    final merged = <WeatherPlace>[];
    final seen = <String>{};
    for (final list in results) {
      for (final p in list) {
        // 0.1° (~11 किमी) के अंदर एक ही नाम = वही जगह, दोबारा मत दिखाओ
        final key = '${p.name.toLowerCase()}|'
            '${p.lat.toStringAsFixed(1)}|${p.lon.toStringAsFixed(1)}';
        if (seen.add(key)) merged.add(p);
      }
    }

    // भारत की जगहें पहले
    merged.sort((a, b) {
      final ai = a.subtitle.contains('India') || a.isIndia ? 0 : 1;
      final bi = b.subtitle.contains('India') || b.isIndia ? 0 : 1;
      return ai.compareTo(bi);
    });
    return merged.take(25).toList();
  }

  Future<List<WeatherPlace>> _searchOpenMeteo(String q) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(q)}&count=20&language=en&format=json',
    );
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return [];
      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null) return [];
      return results.map((r) {
        final m = r as Map<String, dynamic>;
        final admin = (m['admin1'] as String?) ?? '';
        final country = (m['country'] as String?) ?? '';
        return WeatherPlace(
          name: m['name'] as String,
          subtitle: [admin, country].where((e) => e.isNotEmpty).join(', '),
          lat: (m['latitude'] as num).toDouble(),
          lon: (m['longitude'] as num).toDouble(),
          isIndia: (m['country_code'] as String?) == 'IN',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// OpenStreetMap — गाँव, कस्बे, तहसील तक; हिंदी में लिखा नाम भी चलता है।
  Future<List<WeatherPlace>> _searchNominatim(String q) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(q)}&format=json&addressdetails=1'
      '&limit=15&countrycodes=in&accept-language=hi',
    );
    try {
      final res = await http.get(url, headers: {
        'User-Agent': 'ProKisan/1.0 (com.prokisan.app)',
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return [];
      final list = json.decode(res.body) as List;
      final out = <WeatherPlace>[];
      for (final r in list) {
        final m = r as Map<String, dynamic>;
        final a = (m['address'] as Map<String, dynamic>?) ?? {};
        final name = (a['city'] ??
                a['town'] ??
                a['village'] ??
                a['suburb'] ??
                a['county'] ??
                a['state_district'] ??
                m['name'])
            ?.toString();
        if (name == null || name.trim().isEmpty) continue;
        final sub = [
          (a['state_district'] ?? a['county'])?.toString(),
          a['state']?.toString(),
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        out.add(WeatherPlace(
          name: name.trim(),
          subtitle: sub,
          lat: double.tryParse(m['lat'].toString()) ?? 0,
          lon: double.tryParse(m['lon'].toString()) ?? 0,
          isIndia: true,
        ));
      }
      return out;
    } catch (_) {
      return [];
    }
  }

  /// निर्देशांक से शहर का नाम — "मेरी जगह" के लिए।
  ///
  /// ⚠️ Open-Meteo का geocoding सिर्फ़ नाम→निर्देशांक करता है, उल्टा नहीं
  /// (जाँच लिया — निर्देशांक देने पर खाली लौटाता है)। इसलिए reverse के लिए
  /// Nominatim (OpenStreetMap) — यह हिंदी में सही शहर देता है।
  /// [isHi] से भाषा तय होती है।
  Future<String?> reverseGeocode(double lat, double lon,
      {bool isHi = true, String? langCode}) async {
    final lang = langCode ?? (isHi ? 'hi' : 'en');
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lon&format=json&zoom=10'
      '&accept-language=$lang,hi,en',
    );
    try {
      // Nominatim की शर्त: पहचान वाला User-Agent भेजना ज़रूरी
      final res = await http.get(url, headers: {
        'User-Agent': 'ProKisan/1.0 (com.prokisan.app)',
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final a = data['address'] as Map<String, dynamic>?;
      if (a == null) return null;

      // शहर → कस्बा → ज़िला — जो पहले मिले
      final name = (a['city'] ?? a['town'] ?? a['village'] ?? a['county'] ??
              a['state_district'] ?? a['municipality'])
          ?.toString();
      return (name != null && name.trim().isNotEmpty) ? name.trim() : null;
    } catch (_) {
      return null;
    }
  }
}

/// एक जगह — GPS वाली "मेरी जगह" या खोजकर जोड़ा गया शहर।
class WeatherPlace {
  final String name;

  /// राज्य/ज़िला — सूची में नाम के नीचे दिखाने को
  final String subtitle;
  final double lat;
  final double lon;

  /// true = फ़ोन के GPS से आई जगह (सूची में हमेशा पहले, हटाई नहीं जा सकती)
  final bool isCurrent;

  /// खोज के नतीजों में भारत की जगहें ऊपर दिखाने के लिए
  final bool isIndia;

  const WeatherPlace({
    required this.name,
    this.subtitle = '',
    required this.lat,
    required this.lon,
    this.isCurrent = false,
    this.isIndia = false,
  });

  /// cache की चाबी — जगह के निर्देशांक से बनी (2 दशमलव ≈ 1 किमी, काफ़ी है)
  String get cacheKey => isCurrent
      ? 'current'
      : '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  /// दो जगहें एक ही मानी जाएँ अगर ~1 किमी के अंदर हों
  bool sameSpotAs(WeatherPlace o) =>
      (lat - o.lat).abs() < 0.02 && (lon - o.lon).abs() < 0.02;

  Map<String, dynamic> toJson() => {
        'name': name,
        'subtitle': subtitle,
        'lat': lat,
        'lon': lon,
        'isCurrent': isCurrent,
      };

  factory WeatherPlace.fromJson(Map<String, dynamic> m) => WeatherPlace(
        name: (m['name'] ?? '') as String,
        subtitle: (m['subtitle'] ?? '') as String,
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
        isCurrent: (m['isCurrent'] ?? false) as bool,
      );

  WeatherPlace copyWith({String? name, String? subtitle}) => WeatherPlace(
        name: name ?? this.name,
        subtitle: subtitle ?? this.subtitle,
        lat: lat,
        lon: lon,
        isCurrent: isCurrent,
      );
}

class CachedWeather {
  final Map<String, dynamic> data;
  final DateTime savedAt;
  const CachedWeather({required this.data, required this.savedAt});

  bool get isStale => DateTime.now().difference(savedAt) > WeatherService.freshFor;

  /// "5 मिनट पहले" जैसा — UI में दिखाने को
  int get ageMinutes => DateTime.now().difference(savedAt).inMinutes;
}
