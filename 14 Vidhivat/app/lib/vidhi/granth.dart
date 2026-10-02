/// कई अध्यायों वाले ग्रंथ का क्रम — श्रीमद्भगवद्गीता, दुर्गा सप्तशती,
/// सुंदरकांड (→ D-084, D-098, D-106)।
///
/// हर अध्याय अपने आप में एक साधारण [Paath] है और उसी पढ़ने वाले पन्ने से
/// खुलता है। यह फ़ाइल सिर्फ़ **क्रम** बताती है — किस हिस्से में कौन से
/// पाठ, किस क्रम में — ताकि ग्रंथ का अपना पन्ना बन सके और "चालीसा और
/// आरती" की सूची में अठारह या सोलह नाम न भरें।
///
/// ## यह सप्तशती से निकला है
/// पहले यही ढाँचा `saptashati.dart` में सिर्फ़ सप्तशती के लिए था। गीता
/// आई तो वही चीज़ दोबारा लिखने की जगह उसे एक नाम ऊपर उठा दिया गया;
/// `SaptashatiKram` अब इसी का दूसरा नाम है।
library;

import 'dart:convert';

import 'vidhi.dart' show VidhiFormatException;

/// एक ग्रंथ का पूरा क्रम — `<ग्रंथ का फ़ोल्डर>/_kram.json`।
class GranthKram {
  /// ग्रंथ की id — हर पाठ की id इसी से शुरू होती है (`gita_01`)।
  final String id;
  final String naam;
  final String parichay;
  final List<GranthHissa> hisse;

  const GranthKram({
    required this.id,
    required this.naam,
    required this.parichay,
    required this.hisse,
  });

  /// सारे पाठ, पढ़ने के क्रम में — "अगला अध्याय" इसी से निकलता है।
  List<GranthPaath> get kram => [for (final h in hisse) ...h.paath];

  factory GranthKram.parse(String file, String source) {
    final Object? j;
    try {
      j = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON नहीं पढ़ा गया: ${e.message}');
    }
    if (j is! Map<String, dynamic>) {
      throw VidhiFormatException(file, 'JSON object चाहिए');
    }
    if (j['schemaVersion'] != 1) {
      throw VidhiFormatException(file, 'schemaVersion 1 चाहिए');
    }
    final id = _str(file, j, 'id');
    if (!RegExp(r'^[a-z][a-z0-9]*$').hasMatch(id)) {
      throw VidhiFormatException(file, 'ग्रंथ की id "$id" छोटे अक्षरों में हो');
    }
    final hisse = [
      for (final h in _list(file, j, 'khand'))
        GranthHissa._fromJson(file, id, _map(file, h)),
    ];
    if (hisse.isEmpty) {
      throw VidhiFormatException(file, 'एक भी हिस्सा नहीं');
    }
    final kram = GranthKram(
      id: id,
      naam: _str(file, j, 'naam'),
      parichay: _str(file, j, 'parichay'),
      hisse: hisse,
    );
    final ids = kram.kram.map((p) => p.id).toList();
    if (ids.toSet().length != ids.length) {
      throw VidhiFormatException(file, 'कोई पाठ दो बार लिखा है');
    }
    return kram;
  }
}

/// एक हिस्सा — "पाठ से पहले", "प्रथम चरित्र — महाकाली", "अध्याय १ से ६"…
class GranthHissa {
  final String shirshak;
  final List<GranthPaath> paath;

  const GranthHissa({required this.shirshak, required this.paath});

  factory GranthHissa._fromJson(
      String file, String granthId, Map<String, dynamic> j) {
    final paath = [
      for (final p in _list(file, j, 'paath'))
        GranthPaath._fromJson(file, granthId, _map(file, p)),
    ];
    if (paath.isEmpty) {
      throw VidhiFormatException(file, '"${j['shirshak']}" में कोई पाठ नहीं');
    }
    return GranthHissa(shirshak: _str(file, j, 'shirshak'), paath: paath);
  }
}

/// क्रम में एक पाठ — नाम सूची में दिखाने के लिए, पूरा पाठ खोलने पर आता है।
class GranthPaath {
  final String id;
  final String naam;
  final String ekLine;

  /// कितने श्लोक — सूची में दिखता है ताकि पता रहे कि अध्याय कितना लंबा है।
  final int shlok;

  const GranthPaath({
    required this.id,
    required this.naam,
    required this.ekLine,
    required this.shlok,
  });

  factory GranthPaath._fromJson(
      String file, String granthId, Map<String, dynamic> j) {
    final id = _str(file, j, 'id');
    if (!RegExp('^${granthId}_[a-z0-9_]+\$').hasMatch(id)) {
      throw VidhiFormatException(file, 'id "$id" ${granthId}_ से शुरू हो');
    }
    final shlok = j['shlok'];
    if (shlok is! int || shlok <= 0) {
      throw VidhiFormatException(file, '"$id" में श्लोक-गिनती चाहिए');
    }
    return GranthPaath(
      id: id,
      naam: _str(file, j, 'naam'),
      ekLine: _str(file, j, 'ekLine'),
      shlok: shlok,
    );
  }
}

/// ग्रंथालय की सूची में एक ग्रंथ — `assets/granth/_suchi.json`।
///
/// पूरा क्रम तभी पढ़ा जाता है जब यूज़र ग्रंथ खोले। यहाँ सिर्फ़ उतना है
/// जितना सूची और पढ़ने वाले पन्ने की पट्टी को चाहिए।
class GranthSuchiEntry {
  final String id;
  final String naam;

  /// पट्टी में दिखने वाला छोटा नाम — "गीता", "सप्तशती"।
  final String chhotaNaam;

  /// सूची में नाम के नीचे की एक लाइन।
  final String ekLine;

  /// ग्रंथ का एक टुकड़ा क्या कहलाता है — गीता में "अध्याय"; सप्तशती में
  /// "पाठ", क्योंकि वहाँ कवच-अर्गला-कीलक भी क्रम में हैं।
  final String ikai;

  /// पाठ के भीतर एक खंड क्या कहलाता है — "श्लोक" या "पाठ"।
  final String khandIkai;

  /// क्रम की सूची में हर पाठ के नीचे "४७ श्लोक" लिखा आता है; वहाँ गिनती
  /// किस चीज़ की है। सुंदरकांड में दोहा, चौपाई, छंद सब गिने जाते हैं,
  /// इसलिए वहाँ "पद" (→ D-106)।
  final String gintiNaam;

  /// क्रम की सूची में हर पाठ के नीचे उसकी एक लाइन दिखे या नहीं। सप्तशती
  /// में वह संस्कृत का अध्याय-नाम है, जो ऊपर हिंदी में पहले से लिखा है।
  final bool ekLineDikhao;

  const GranthSuchiEntry({
    required this.id,
    required this.naam,
    required this.chhotaNaam,
    required this.ekLine,
    required this.ikai,
    required this.khandIkai,
    this.gintiNaam = 'श्लोक',
    this.ekLineDikhao = true,
  });

  /// दुर्गा सप्तशती — उसका पाठ `assets/paath/saptashati/` में ही रहा, इसलिए
  /// वह `_suchi.json` में नहीं, यहाँ लिखी है।
  static const saptashati = GranthSuchiEntry(
    id: 'saptashati',
    naam: 'दुर्गा सप्तशती',
    chhotaNaam: 'सप्तशती',
    ekLine: 'तेरह अध्याय — कवच, अर्गला और कीलक सहित',
    ikai: 'पाठ',
    khandIkai: 'पाठ',
    ekLineDikhao: false,
  );

  factory GranthSuchiEntry._fromJson(String file, Map<String, dynamic> j) =>
      GranthSuchiEntry(
        id: _str(file, j, 'id'),
        naam: _str(file, j, 'naam'),
        chhotaNaam: _str(file, j, 'chhotaNaam'),
        ekLine: _str(file, j, 'ekLine'),
        ikai: _str(file, j, 'ikai'),
        khandIkai: _str(file, j, 'khandIkai'),
        gintiNaam: j.containsKey('gintiNaam')
            ? _str(file, j, 'gintiNaam')
            : 'श्लोक',
      );

  static List<GranthSuchiEntry> parseAll(String file, String source) {
    final Object? j;
    try {
      j = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON नहीं पढ़ा गया: ${e.message}');
    }
    if (j is! Map<String, dynamic>) {
      throw VidhiFormatException(file, 'JSON object चाहिए');
    }
    if (j['schemaVersion'] != 1) {
      throw VidhiFormatException(file, 'schemaVersion 1 चाहिए');
    }
    final list = [
      for (final g in _list(file, j, 'granth'))
        GranthSuchiEntry._fromJson(file, _map(file, g)),
    ];
    final ids = list.map((g) => g.id).toList();
    if (ids.toSet().length != ids.length) {
      throw VidhiFormatException(file, 'कोई ग्रंथ दो बार लिखा है');
    }
    return list;
  }
}

String _str(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! String || v.trim().isEmpty) {
    throw VidhiFormatException(file, '"$key" भरा होना चाहिए');
  }
  return v;
}

List<dynamic> _list(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! List) throw VidhiFormatException(file, '"$key" सूची होनी चाहिए');
  return v;
}

Map<String, dynamic> _map(String file, Object? v) {
  if (v is! Map<String, dynamic>) {
    throw VidhiFormatException(file, 'JSON object चाहिए');
  }
  return v;
}
