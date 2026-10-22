/// इंटरनेट पर जगह की खोज — OpenStreetMap (Nominatim) से (→ D-129)।
///
/// डेवलपर (22 अक्टूबर 2026): *"OpenStreetMap use कर लो, और ऐसा करो कि कोई भी request
/// fail नहीं होनी चाहिए — waiting में लगाकर काम कर लेना।"*
///
/// इसलिए हर खोज एक **क़तार** में जाती है:
/// - दो requests के बीच कम से कम [kamSeKamFasla] (Nominatim की नीति: एक सेकंड में एक);
/// - इंटरनेट न हो, सर्वर व्यस्त हो (429/5xx), या समय निकल जाए — तो इंतज़ार करके दोबारा,
///   2 → 4 → 8 → 16 → 30 सेकंड, फिर हर 30 सेकंड; सर्वर `Retry-After` बताए तो उतना;
/// - **हार मानकर कभी नहीं लौटती** — जवाब मिलने तक, या जब तक पूछने वाला ख़ुद रद्द न करे
///   (खोज का पन्ना बंद हुआ)। हर इंतज़ार [haal] से बताया जाता है;
/// - एक ही खोज दोबारा हो तो जवाब याद से (कोई request नहीं)।
///
/// ⚠ Nominatim की नीति हर अक्षर पर अपने-आप खोज (autocomplete) मना करती है — यह खोज
/// सिर्फ़ यूज़र के कहने पर चलती है (keyboard का «खोज» या बटन)। जाता है सिर्फ़ लिखा हुआ
/// शब्द; फ़ोन की जगह नहीं।
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../app_version.dart';

/// सर्वर का जवाब — असली HTTP या जाँच में नक़ली।
class OsmJawab {
  final int status;
  final String body;
  final Duration? retryAfter;
  const OsmJawab(this.status, this.body, [this.retryAfter]);
}

typedef OsmLaao = Future<OsmJawab> Function(Uri uri);

/// इंटरनेट से मिली एक जगह।
class OsmJagah {
  /// OpenStreetMap में हिंदी नाम हो तो वही, नहीं तो जो है
  final String naam;

  /// ज़िला, राज्य — जितना मिला
  final String pata;
  final double latitude;
  final double longitude;
  const OsmJagah(this.naam, this.pata, this.latitude, this.longitude);
}

/// पूछने वाले ने खोज छोड़ दी (पन्ना बंद) — गड़बड़ी नहीं।
class OsmRadd implements Exception {
  const OsmRadd();
}

class OsmKhoj {
  final OsmLaao _laao;
  final DateTime Function() _ab;
  final Future<void> Function(Duration) _ruko;

  OsmKhoj({OsmLaao? laao, DateTime Function()? ab, Future<void> Function(Duration)? ruko})
      : _laao = laao ?? _httpLaao,
        _ab = ab ?? DateTime.now,
        _ruko = ruko ?? ((d) => Future<void>.delayed(d));

  static const kamSeKamFasla = Duration(milliseconds: 1100);
  static const jawabKaSamay = Duration(seconds: 20);

  Future<void> _qatar = Future.value();
  DateTime? _pichhli;
  final _yaad = <String, List<OsmJagah>>{};

  /// खोज क़तार में डालो। [haal] — इंतज़ार की बात यूज़र को बताने के लिए;
  /// [radd] — `true` लौटाए तो खोज छोड़ दो ([OsmRadd] फेंकती है)।
  Future<List<OsmJagah>> khojo(
    String khoj, {
    void Function(String haal)? haal,
    bool Function()? radd,
  }) {
    final q = khoj.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (q.isEmpty) return Future.value(const []);
    final kunji = q.toLowerCase();
    final yaad = _yaad[kunji];
    if (yaad != null) return Future.value(yaad);

    final kaam = _qatar.then((_) => _chalao(q, kunji, haal, radd ?? () => false));
    // पिछला काम कैसे भी ख़त्म हो, क़तार आगे चले
    _qatar = kaam.then((_) {}, onError: (_) {});
    return kaam;
  }

  Future<List<OsmJagah>> _chalao(
    String q,
    String kunji,
    void Function(String)? haal,
    bool Function() radd,
  ) async {
    final yaad = _yaad[kunji]; // क़तार में रहते किसी और ने यही खोज ली हो
    if (yaad != null) return yaad;
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'jsonv2',
      'countrycodes': 'in',
      'addressdetails': '1',
      'featureType': 'settlement',
      'limit': '10',
      'accept-language': 'hi,en',
    });

    for (var koshish = 0;; koshish++) {
      if (radd()) throw const OsmRadd();
      // Nominatim: एक सेकंड में एक से ज़्यादा नहीं
      final pichhli = _pichhli;
      if (pichhli != null) {
        final bacha = kamSeKamFasla - _ab().difference(pichhli);
        if (bacha > Duration.zero) await _rukoJabTak(bacha, radd);
      }
      _pichhli = _ab();

      Duration intezaar;
      String baat;
      try {
        final r = await _laao(uri).timeout(jawabKaSamay);
        if (r.status == 200) {
          final mile = padho(r.body);
          _yaad[kunji] = mile;
          return mile;
        }
        if (r.status == 429 || r.status == 503) {
          intezaar = r.retryAfter ?? _peechhe(koshish, kam: 10);
          baat = 'सर्वर पर भीड़ है';
        } else {
          intezaar = _peechhe(koshish);
          baat = 'सर्वर से जवाब नहीं बना (${r.status})';
        }
      } on TimeoutException {
        intezaar = _peechhe(koshish);
        baat = 'जवाब आने में देर';
      } catch (_) {
        intezaar = _peechhe(koshish);
        baat = 'इंटरनेट नहीं मिला';
      }
      haal?.call('$baat — ${intezaar.inSeconds} सेकंड में फिर कोशिश…');
      await _rukoJabTak(intezaar, radd);
    }
  }

  /// 2, 4, 8, 16, 30, 30… सेकंड
  static Duration _peechhe(int koshish, {int kam = 2}) {
    final s = kam << (koshish > 4 ? 4 : koshish);
    return Duration(seconds: s > 30 ? 30 : s);
  }

  /// रुको — पर आधे-आधे सेकंड पर देखते रहो कि खोज छोड़ी तो नहीं गई,
  /// ताकि छोड़ी हुई खोज क़तार न रोके।
  Future<void> _rukoJabTak(Duration d, bool Function() radd) async {
    var bacha = d;
    const tukda = Duration(milliseconds: 500);
    while (bacha > Duration.zero) {
      if (radd()) throw const OsmRadd();
      final ab = bacha < tukda ? bacha : tukda;
      await _ruko(ab);
      bacha -= ab;
    }
  }

  /// Nominatim `jsonv2` → जगहें। भारत के बाहर की, और बिना अक्षांश वाली, छूटती हैं।
  static List<OsmJagah> padho(String body) {
    final d = jsonDecode(body);
    if (d is! List) return const [];
    final out = <OsmJagah>[];
    for (final x in d) {
      if (x is! Map) continue;
      final a = double.tryParse('${x['lat']}');
      final o = double.tryParse('${x['lon']}');
      if (a == null || o == null || a < 6 || a > 37.5 || o < 68 || o > 97.5) continue;
      final pata = (x['address'] is Map) ? x['address'] as Map : const {};
      final naam = '${x['name'] ?? ''}'.trim().isNotEmpty
          ? '${x['name']}'.trim()
          : '${x['display_name'] ?? ''}'.split(',').first.trim();
      if (naam.isEmpty) continue;
      final hisse = <String>[
        for (final k in ['state_district', 'county', 'state'])
          if (pata[k] is String && (pata[k] as String).trim().isNotEmpty) (pata[k] as String).trim(),
      ];
      final saaf = <String>[];
      for (final h in hisse) {
        if (h != naam && !saaf.contains(h)) saaf.add(h);
      }
      out.add(OsmJagah(naam, saaf.join(', '), a, o));
    }
    return out;
  }
}

/// असली HTTP — Nominatim की नीति के मुताबिक़ ऐप का नाम User-Agent में।
Future<OsmJawab> _httpLaao(Uri uri) async {
  final c = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final req = await c.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader,
        'Vidhivat/$appVersion (Android app com.vidhivat; place search)');
    req.headers.set(HttpHeaders.acceptLanguageHeader, 'hi,en');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final ra = int.tryParse(res.headers.value('retry-after') ?? '');
    return OsmJawab(res.statusCode, body, ra == null ? null : Duration(seconds: ra));
  } finally {
    c.close();
  }
}

/// पूरे ऐप की एक क़तार — ताकि अलग-अलग पन्नों की खोजें भी एक सेकंड का फ़ासला रखें।
final osmKhoj = OsmKhoj();
