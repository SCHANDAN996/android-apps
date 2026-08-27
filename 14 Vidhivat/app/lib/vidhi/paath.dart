/// चालीसा और स्तोत्र का ढाँचा — **पूजा से अलग चीज़** (→ D-039)।
///
/// पूजा एक *काम* है: सामग्री जुटाओ, कदम-दर-कदम करो, बीच में मंत्र बोलो।
/// चालीसा एक *पाठ* है: बैठो और शुरू से आख़िर तक पढ़ो। दोनों को एक ही
/// ढाँचे में डालने की कोशिश दोनों को बिगाड़ती —
///
/// - `Vidhi` में मंत्र किसी *कदम के साथ* आता है। चालीसा में कोई कदम नहीं,
///   सिर्फ़ 43 पद हैं जो क्रम से पढ़े जाते हैं।
/// - `Vidhi` में सामग्री, समय और संकल्प होते हैं। पाठ में कुछ नहीं चाहिए।
/// - पूजा का दायरा (`Scope`) तय करता है कि विधि खुले या नहीं। पाठ हमेशा
///   खुलता है — पढ़ने में कोई जोखिम नहीं।
///
/// इसलिए यह अपना ढाँचा है, पर **वही अनुशासन** — `MantraSthiti`,
/// `Bharosa`, `Strot` और `Jaanch` सीधे `vidhi.dart` से लिए गए हैं ताकि
/// ऐप में एक ही भाषा चले।
///
/// ## पाठ अंदाज़े से नहीं लिखा जाता
/// चालीसा गाई जाने वाली रचना है, बिल्कुल आरती की तरह। ऐप में वही पाठ
/// जाएगा जो घर में पढ़ा जाता है — अपनी चालीसा-पुस्तिका से या पंडित जी से।
/// इसीलिए हर पद पर [PaathKhand.sthiti] और [PaathKhand.strot] उतने ही
/// ज़रूरी हैं जितने मंत्र पर (→ D-022)।
library;

import 'dart:convert';

import 'vidhi.dart' show Bharosa, Jaanch, MantraSthiti, Strot, VidhiFormatException;

/// इस ढाँचे का नंबर। JSON में भी यही लिखा होना चाहिए।
const int paathSchemaVersion = 1;

/// पाठ किस तरह का है।
enum PaathPrakar {
  /// चालीस चौपाइयों वाली रचना — नाम ही "चालीसा" इसी से है।
  chalisa('चालीसा'),

  /// स्तोत्र, स्तुति, कवच — जिसमें पदों की संख्या तय नहीं।
  stotra('स्तोत्र'),

  /// आरती — गाई जाती है।
  aarti('आरती');

  final String naam;
  const PaathPrakar(this.naam);

  static PaathPrakar parse(String file, String raw) =>
      PaathPrakar.values.firstWhere(
        (p) => p.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'prakar "$raw" ग़लत है। चलेंगी: '
          '${PaathPrakar.values.map((p) => p.name).join(", ")}',
        ),
      );
}

/// पाठ का एक पद — एक दोहा या एक चौपाई।
class PaathKhand {
  /// "दोहा १", "चौपाई ५" — पढ़ते वक़्त यही ऊपर दिखता है।
  final String shirshak;

  /// देवनागरी पाठ। ख़ाली हो सकता है — तब [sthiti] `khaali` होगी।
  final String dev;

  /// रोमन — सिर्फ़ पढ़ने की सहायता, उच्चारण का नियम नहीं।
  final String roman;

  /// सरल हिंदी अर्थ — **अपना लिखा हुआ**, किसी प्रकाशक की टीका से नहीं।
  final String arth;

  /// रिकॉर्डिंग की फ़ाइल, `assets/paath/audio/` के अंदर का नाम।
  final String audio;

  final MantraSthiti sthiti;

  const PaathKhand({
    required this.shirshak,
    required this.dev,
    required this.roman,
    required this.arth,
    required this.audio,
    required this.sthiti,
  });

  bool get hasPath => dev.trim().isNotEmpty;
  bool get hasAudio => audio.trim().isNotEmpty;
  bool get needsPanditReview => sthiti != MantraSthiti.paas;

  factory PaathKhand.fromJson(String file, Map<String, dynamic> j) {
    final shirshak = _str(file, j, 'shirshak');
    final sthiti = MantraSthiti.parse(file, _str(file, j, 'sthiti'));
    final dev = _str(file, j, 'dev', required: false);

    // वही तीन नियम जो मंत्र पर लगते हैं (→ D-021)।
    if (sthiti != MantraSthiti.khaali && dev.trim().isEmpty) {
      throw VidhiFormatException(
        file,
        '"$shirshak" की sthiti "${sthiti.name}" है पर पाठ ख़ाली है। '
        'पाठ नहीं लिखा तो sthiti "khaali" रखो।',
      );
    }
    if (sthiti == MantraSthiti.khaali && dev.trim().isNotEmpty) {
      throw VidhiFormatException(
        file,
        '"$shirshak" में पाठ लिखा है पर sthiti "khaali" है। '
        'पाठ लिखा है तो कम से कम "draft" करो।',
      );
    }

    return PaathKhand(
      shirshak: shirshak,
      dev: dev,
      roman: _str(file, j, 'roman', required: false),
      arth: _str(file, j, 'arth', required: false),
      audio: _str(file, j, 'audio', required: false),
      sthiti: sthiti,
    );
  }
}

/// एक पूरा पाठ — चालीसा, स्तोत्र या आरती।
class Paath {
  final String id;
  final String naam;

  /// और किन नामों से खोजा जाता है।
  final List<String> upnaam;

  final PaathPrakar prakar;

  /// किस देवता का — "हनुमान जी", "दुर्गा माँ"।
  final String devta;

  /// किसने रचा — **कॉपीराइट के लिए यह ज़रूरी है।** तुलसीदास जैसी पुरानी
  /// रचना सार्वजनिक है; किसी आधुनिक रचयिता का पाठ बिना अनुमति नहीं।
  final String rachnakar;

  /// किस भाषा में — अवधी, संस्कृत, ब्रज।
  final String bhasha;

  /// दो-तीन लाइन — यह पाठ क्या है।
  final String parichay;

  /// कब पढ़ा जाता है।
  final String kabPadhein;

  /// कैसे पढ़ें — बैठने का ढंग, कितनी बार, पहले-बाद क्या।
  final String kaisePadhein;

  final List<PaathKhand> khand;
  final Strot strot;
  final Jaanch jaanch;

  /// पाठ पर कितना भरोसा — पंडित जी की जाँच से पहले।
  final Bharosa bharosa;

  const Paath({
    required this.id,
    required this.naam,
    required this.upnaam,
    required this.prakar,
    required this.devta,
    required this.rachnakar,
    required this.bhasha,
    required this.parichay,
    required this.kabPadhein,
    required this.kaisePadhein,
    required this.khand,
    required this.strot,
    required this.jaanch,
    required this.bharosa,
  });

  bool get needsPanditReview => !jaanch.paas;

  int get khandKul => khand.length;
  int get khandBhareHue => khand.where((k) => k.hasPath).length;
  int get khandAudioWale => khand.where((k) => k.hasAudio).length;

  /// एक भी पद भरा है या नहीं — ख़ाली पाठ पर "पढ़ना शुरू करें" नहीं दिखता।
  bool get kuchBharaHai => khandBhareHue > 0;

  /// चौपाइयों की गिनती — "चालीसा" नाम का वादा यही है।
  int get chaupaiGinti =>
      khand.where((k) => k.shirshak.trim().startsWith('चौपाई')).length;

  factory Paath.fromJson(String file, Map<String, dynamic> j) {
    final version = _int(file, j, 'schemaVersion');
    if (version != paathSchemaVersion) {
      throw VidhiFormatException(
        file,
        'schemaVersion $version है, ऐप $paathSchemaVersion चाहता है',
      );
    }

    final khand = _list(file, j, 'khand')
        .map((k) => PaathKhand.fromJson(file, _map(file, k, 'khand')))
        .toList(growable: false);
    if (khand.isEmpty) {
      throw VidhiFormatException(file, 'एक भी पद नहीं — पाठ ख़ाली है');
    }

    final prakar = PaathPrakar.parse(file, _str(file, j, 'prakar'));

    // ── "चालीसा" का मतलब चालीस है ──
    //
    // नाम ही गिनती का वादा करता है, इसलिए ढाँचा उसे जाँचता है। पद अभी
    // ख़ाली हों तो चलेगा, पर चालीस जगहें बनी होनी चाहिए — वरना पता ही
    // नहीं चलेगा कि कौन सी चौपाई छूट गई।
    final chaupai =
        khand.where((k) => k.shirshak.trim().startsWith('चौपाई')).length;
    if (prakar == PaathPrakar.chalisa && chaupai != 40) {
      throw VidhiFormatException(
        file,
        'यह चालीसा है पर इसमें $chaupai चौपाइयाँ हैं, चालीस होनी चाहिए।',
      );
    }

    final jaanch = Jaanch.fromJson(file, _map(file, j['jaanch'], 'jaanch'));
    if (jaanch.paas) {
      final kachche = khand.where((k) => k.needsPanditReview).map((k) => k.shirshak);
      if (kachche.isNotEmpty) {
        throw VidhiFormatException(
          file,
          'पाठ "paas" है पर ये पद अभी पास नहीं: ${kachche.join(", ")}',
        );
      }
    }

    return Paath(
      id: _str(file, j, 'id'),
      naam: _str(file, j, 'naam'),
      upnaam: _strList(file, j, 'upnaam'),
      prakar: prakar,
      devta: _str(file, j, 'devta'),
      rachnakar: _str(file, j, 'rachnakar'),
      bhasha: _str(file, j, 'bhasha'),
      parichay: _str(file, j, 'parichay'),
      kabPadhein: _str(file, j, 'kabPadhein'),
      kaisePadhein: _str(file, j, 'kaisePadhein'),
      khand: khand,
      strot: Strot.fromJson(file, _map(file, j['strot'], 'strot')),
      jaanch: jaanch,
      bharosa: Bharosa.parse(
        file,
        _str(file, j, 'bharosa', required: false, fallback: 'kam'),
      ),
    );
  }

  factory Paath.parse(String file, String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON ही ग़लत है — $e');
    }
    return Paath.fromJson(file, _map(file, decoded, 'फ़ाइल'));
  }
}

// ─────────────────────────────────────────────────────────────
// सूची — कौन-कौन से पाठ हैं
// ─────────────────────────────────────────────────────────────

/// सूची में एक पाठ का छोटा परिचय।
///
/// पूरी फ़ाइल तभी पढ़ी जाती है जब यूज़र उसे खोले — वही ढंग जो पूजाओं की
/// सूची में है। `paath_test.dart` हर बार दोनों को मिलाकर देखता है।
class PaathSuchiEntry {
  final String id;
  final String naam;
  final PaathPrakar prakar;
  final String devta;

  /// एक लाइन — सूची में नाम के नीचे दिखेगी।
  final String ekLine;

  /// पाठ जुड़ चुका है या नहीं।
  final bool taiyar;

  /// पंडित जी से पास हो चुका है या नहीं।
  final bool paas;

  const PaathSuchiEntry({
    required this.id,
    required this.naam,
    required this.prakar,
    required this.devta,
    required this.ekLine,
    required this.taiyar,
    required this.paas,
  });

  factory PaathSuchiEntry.fromJson(String file, Map<String, dynamic> j) {
    final taiyar = _bool(file, j, 'taiyar');
    final paas = _bool(file, j, 'paas');
    if (paas && !taiyar) {
      throw VidhiFormatException(
        file,
        'पाठ "paas" है पर "taiyar" नहीं — जो जुड़ा ही नहीं वो पास कैसे हुआ?',
      );
    }
    return PaathSuchiEntry(
      id: _str(file, j, 'id'),
      naam: _str(file, j, 'naam'),
      prakar: PaathPrakar.parse(file, _str(file, j, 'prakar')),
      devta: _str(file, j, 'devta'),
      ekLine: _str(file, j, 'ekLine'),
      taiyar: taiyar,
      paas: paas,
    );
  }

  static List<PaathSuchiEntry> parseAll(String file, String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON ही ग़लत है — $e');
    }
    final root = _map(file, decoded, 'फ़ाइल');
    final version = _int(file, root, 'schemaVersion');
    if (version != paathSchemaVersion) {
      throw VidhiFormatException(
        file,
        'schemaVersion $version है, ऐप $paathSchemaVersion चाहता है',
      );
    }
    final list = _list(file, root, 'paath')
        .map((e) => PaathSuchiEntry.fromJson(file, _map(file, e, 'paath')))
        .toList(growable: false);

    final ids = <String>{};
    for (final e in list) {
      if (!ids.add(e.id)) {
        throw VidhiFormatException(file, 'id "${e.id}" दो बार आई है');
      }
    }
    return list;
  }
}

// ─────────────────────────────────────────────────────────────
// JSON पढ़ने के छोटे औज़ार
//
// `vidhi.dart` में इन्हीं जैसे हैं, पर वे private हैं। उन्हें public
// करने से पूरे ऐप में उनका नाम खुल जाता; यहाँ अलग रखना सस्ता पड़ा और
// उस जाँची हुई फ़ाइल को छूना नहीं पड़ा।
// ─────────────────────────────────────────────────────────────

Map<String, dynamic> _map(String file, dynamic value, String kahan) {
  if (value is! Map) {
    throw VidhiFormatException(
        file, '"$kahan" में object चाहिए था, मिला: $value');
  }
  return value.cast<String, dynamic>();
}

List<dynamic> _list(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) return const [];
  if (v is! List) {
    throw VidhiFormatException(file, '"$key" में सूची चाहिए थी, मिला: $v');
  }
  return v;
}

String _str(
  String file,
  Map<String, dynamic> j,
  String key, {
  bool required = true,
  String fallback = '',
}) {
  final v = j[key];
  if (v == null) {
    if (required) throw VidhiFormatException(file, '"$key" है ही नहीं');
    return fallback;
  }
  if (v is! String) {
    throw VidhiFormatException(file, '"$key" में लिखावट चाहिए थी, मिला: $v');
  }
  if (required && v.trim().isEmpty) {
    throw VidhiFormatException(file, '"$key" ख़ाली है');
  }
  return v;
}

int _int(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) throw VidhiFormatException(file, '"$key" है ही नहीं');
  if (v is! int) {
    throw VidhiFormatException(file, '"$key" में पूर्णांक चाहिए था, मिला: $v');
  }
  return v;
}

bool _bool(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) throw VidhiFormatException(file, '"$key" है ही नहीं');
  if (v is! bool) {
    throw VidhiFormatException(file, '"$key" में true/false चाहिए था, मिला: $v');
  }
  return v;
}

List<String> _strList(String file, Map<String, dynamic> j, String key) =>
    _list(file, j, key).map((e) {
      if (e is! String) {
        throw VidhiFormatException(file, '"$key" में लिखावट चाहिए थी, मिला: $e');
      }
      return e;
    }).toList(growable: false);
