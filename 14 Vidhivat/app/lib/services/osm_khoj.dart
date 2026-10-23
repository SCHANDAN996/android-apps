/// इंटरनेट पर जगह की खोज — OpenStreetMap के डेटा पर, **Photon** सेवा से (→ D-129, D-134)।
///
/// डेवलपर (22 अक्टूबर 2026): *"कोई भी request fail नहीं होनी चाहिए — waiting में लगाकर
/// काम कर लेना।"* और (23 अक्टूबर): *"लिखने से इंटरनेट से auto search होता रहे — बटन दबाकर न
/// खोजना पड़े।"*
///
/// **Photon क्यों, Nominatim क्यों नहीं (D-134):** Nominatim की नीति लिखते-लिखते खोज
/// (autocomplete) साफ़ मना करती है — इसलिए D-129 में बटन/«खोज» दबाना पड़ता था। Photon
/// (komoot की सेवा, वही OpenStreetMap डेटा) बना ही "search-as-you-type" के लिए है। फिर भी
/// शिष्टता से: लिखना रुकने के बाद ही (`jagah_khoj.dart` में ठहराव), दो requests में
/// कम से कम [kamSeKamFasla], और शब्द बदलते ही पुरानी खोज छूट जाती है।
///
/// हर खोज एक **क़तार** में:
/// - इंटरनेट न हो, सर्वर व्यस्त हो (429/5xx), या समय निकल जाए — तो इंतज़ार करके दोबारा,
///   2 → 4 → 8 → 16 → 30 सेकंड, फिर हर 30 सेकंड; सर्वर `Retry-After` बताए तो उतना;
/// - **हार मानकर कभी नहीं लौटती** — जवाब मिलने तक, या जब तक पूछने वाला ख़ुद रद्द न करे
///   (पन्ना बंद हुआ, या शब्द बदल गया)। हर इंतज़ार [haal] से बताया जाता है;
/// - एक ही खोज दोबारा हो तो जवाब याद से (कोई request नहीं)।
///
/// जाता है सिर्फ़ लिखा हुआ शब्द; फ़ोन की जगह नहीं।
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

  static const kamSeKamFasla = Duration(milliseconds: 600);
  static const jawabKaSamay = Duration(seconds: 20);

  /// क़तार की पूँछ। ⚠ पहली खोज के वक़्त बनती है, constructor में नहीं: पहले यहाँ
  /// `Future.value()` था — `OsmKhoj` किसी और zone में बना हो (जाँच का `setUp`) तो
  /// उसके `.then` कभी चलते ही नहीं थे, और खोज चुपचाप अटकी रहती।
  Future<void>? _qatar;
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

    final kaam = (_qatar ?? Future<void>.value())
        .then((_) => _chalao(q, kunji, haal, radd ?? () => false));
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
    // भारत का चौखटा, और सिर्फ़ बस्तियाँ (place=* — शहर, क़स्बा, गाँव, टोला)
    final uri = Uri.https('photon.komoot.io', '/api/', {
      'q': q,
      'limit': '12',
      'bbox': '68,6,97.5,37.5',
      'osm_tag': 'place',
    });

    for (var koshish = 0;; koshish++) {
      if (radd()) throw const OsmRadd();
      // दो requests के बीच फ़ासला — सेवा पर बोझ न बने
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

  /// Photon का GeoJSON → जगहें। भारत के बाहर की (चौखटे में नेपाल भी आता है), और
  /// राज्य/देश जैसी बड़ी इकाइयाँ, छूटती हैं; एक ही बस्ती दो बार नहीं।
  static List<OsmJagah> padho(String body) {
    final d = jsonDecode(body);
    final features = d is Map ? d['features'] : null;
    if (features is! List) return const [];
    final out = <OsmJagah>[];
    for (final f in features) {
      if (f is! Map) continue;
      final p = f['properties'];
      final g = f['geometry'];
      if (p is! Map || g is! Map) continue;
      if ('${p['countrycode'] ?? ''}'.toUpperCase() != 'IN') continue;
      if (const {'state', 'country', 'region', 'province', 'continent'}
          .contains(p['osm_value'])) {
        continue;
      }
      final c = g['coordinates'];
      if (c is! List || c.length < 2) continue;
      final o = (c[0] as num?)?.toDouble();
      final a = (c[1] as num?)?.toDouble();
      if (a == null || o == null || a < 6 || a > 37.5 || o < 68 || o > 97.5) continue;
      final naam = '${p['name'] ?? ''}'.trim();
      if (naam.isEmpty) continue;

      final hisse = <String>[];
      for (final k in ['county', 'district', 'city']) {
        final v = p[k];
        if (v is String && v.trim().isNotEmpty) {
          hisse.add(saafRoman(v.trim()));
          break; // ज़िला/तहसील — एक काफ़ी
        }
      }
      final rajya = p['state'];
      if (rajya is String && rajya.trim().isNotEmpty) hisse.add(rajyaHindi(rajya));
      final saaf = <String>[];
      for (final h in hisse) {
        if (h != naam && !saaf.contains(h)) saaf.add(h);
      }
      final pata = saaf.join(', ');
      // एक ही बस्ती की दो प्रविष्टियाँ (गाँव का बिंदु और उसकी सीमा) — फ़ोन पर «Bihta,
      // पटना» दो बार दिखा था। वही नाम, वही पता, 5 किलोमीटर के भीतर = एक।
      final dohra = out.any((j) =>
          j.naam == naam &&
          j.pata == pata &&
          (j.latitude - a).abs() < 0.05 &&
          (j.longitude - o).abs() < 0.05);
      if (!dohra) out.add(OsmJagah(naam, pata, a, o));
    }
    return out;
  }

  /// «Haryāna» जैसे चिह्न हटाओ — बाक़ी ऐप में बिना चिह्न के नाम हैं।
  static String saafRoman(String s) {
    const badal = {
      'ā': 'a', 'ī': 'i', 'ū': 'u', 'ē': 'e', 'ō': 'o', 'ṛ': 'r', 'ṝ': 'r',
      'ṇ': 'n', 'ñ': 'n', 'ṅ': 'n', 'ṭ': 't', 'ḍ': 'd', 'ś': 's', 'ṣ': 's',
      'ḥ': 'h', 'ṃ': 'm', 'Ā': 'A', 'Ī': 'I', 'Ū': 'U', 'Ś': 'S', 'Ṣ': 'S',
    };
    final b = StringBuffer();
    for (final ch in s.split('')) {
      b.write(badal[ch] ?? ch);
    }
    return b.toString();
  }

  /// राज्य का नाम हिंदी में — ऐप की बाक़ी सूचियों जैसा।
  static String rajyaHindi(String angrezi) {
    final k = saafRoman(angrezi.trim()).toLowerCase();
    return _rajya[k] ?? saafRoman(angrezi.trim());
  }

  static const _rajya = {
    'andhra pradesh': 'आंध्र प्रदेश',
    'arunachal pradesh': 'अरुणाचल प्रदेश',
    'assam': 'असम',
    'bihar': 'बिहार',
    'chhattisgarh': 'छत्तीसगढ़',
    'goa': 'गोवा',
    'gujarat': 'गुजरात',
    'haryana': 'हरियाणा',
    'himachal pradesh': 'हिमाचल प्रदेश',
    'jharkhand': 'झारखंड',
    'karnataka': 'कर्नाटक',
    'kerala': 'केरल',
    'madhya pradesh': 'मध्य प्रदेश',
    'maharashtra': 'महाराष्ट्र',
    'manipur': 'मणिपुर',
    'meghalaya': 'मेघालय',
    'mizoram': 'मिज़ोरम',
    'nagaland': 'नागालैंड',
    'odisha': 'ओडिशा',
    'punjab': 'पंजाब',
    'rajasthan': 'राजस्थान',
    'sikkim': 'सिक्किम',
    'tamil nadu': 'तमिलनाडु',
    'telangana': 'तेलंगाना',
    'tripura': 'त्रिपुरा',
    'uttar pradesh': 'उत्तर प्रदेश',
    'uttarakhand': 'उत्तराखंड',
    'west bengal': 'पश्चिम बंगाल',
    'andaman and nicobar islands': 'अंडमान और निकोबार',
    'chandigarh': 'चंडीगढ़',
    'dadra and nagar haveli and daman and diu': 'दादरा नगर हवेली और दमन दीव',
    'delhi': 'दिल्ली',
    'national capital territory of delhi': 'दिल्ली',
    'jammu and kashmir': 'जम्मू और कश्मीर',
    'ladakh': 'लद्दाख',
    'lakshadweep': 'लक्षद्वीप',
    'puducherry': 'पुडुचेरी',
  };
}

/// असली HTTP — ऐप का नाम User-Agent में, ताकि सेवा चलाने वाले पहचान सकें।
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

/// पूरे ऐप की एक क़तार — ताकि अलग-अलग पन्नों की खोजें भी फ़ासला रखें।
/// (जाँचों में नक़ली सर्वर वाली क़तार से बदली जाती है — असली इंटरनेट नहीं।)
OsmKhoj osmKhoj = OsmKhoj();
