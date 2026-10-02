/// **व्रत का पन्ना** — हर व्रत, बारह खानों में (→ D-075, D-076)।
///
/// ## यह [VratNiyam] से अलग क्यों है
///
/// इंजन का `VratNiyam` सिर्फ़ यह जानता है कि व्रत **किस दिन** पड़ता है।
/// यह पन्ना बताता है कि व्रत **क्या है** — भाव, नियम, भोजन, पारण, पूजा,
/// मंत्र, कथा, सावधानी। कंटेंट `assets/vrat/` की JSON में है; दोनों एक
/// ही `id` से जुड़ते हैं (`kab.niyam.engine`)।
///
/// ## ⚠️ "फ़ायदे" दो खानों में बँटे हैं
///
/// [VratPanna.bhav] ऐप की अपनी बात है — बिना किसी फल के।
/// [VratPanna.mahatmyaKathan] ग्रंथ या कथा का कथन है, और उसके साथ हमेशा
/// [VratPanna.mahatmyaStrot] चलता है। दोनों को एक डिब्बे में मिलाना ग़लत
/// होता — कथा का वाक्य ऐप का वादा बन जाता (→ D-051)।
library;

import 'dart:convert';

import 'vidhi.dart' show Bharosa, Mantra, VidhiFormatException;

/// व्रत का समूह — सूची इसी से बँटती है।
enum VratSamuh {
  vaar('हर हफ़्ते'),
  tithi('हर महीने'),
  ekadashiVarsh('साल की एकादशियाँ'),
  varshik('साल के बड़े व्रत');

  final String naam;
  const VratSamuh(this.naam);

  static VratSamuh parse(String file, String raw) => switch (raw) {
        'vaar' => VratSamuh.vaar,
        'tithi' => VratSamuh.tithi,
        'ekadashi_varsh' => VratSamuh.ekadashiVarsh,
        'varshik' => VratSamuh.varshik,
        _ => throw VidhiFormatException(file, 'samuh "$raw" अनजाना है'),
      };
}

/// `_suchi.json` की एक पंक्ति।
class VratSuchiEntry {
  final String id;
  final String naam;
  final VratSamuh samuh;
  final String devta;

  /// इंजन के `VratNiyam` की id — जिनकी तारीख़ पंचांग से गिनी जाती है।
  final String? engine;

  /// व्रत-पन्ने की जगह अलग ढाँचे वाली फ़ाइल (जैसे साल की एकादशियाँ)।
  final String? faail;

  final bool taiyar;

  const VratSuchiEntry({
    required this.id,
    required this.naam,
    required this.samuh,
    required this.devta,
    required this.engine,
    required this.faail,
    required this.taiyar,
  });

  static List<VratSuchiEntry> parseAll(String file, String source) {
    final raw = _object(file, source);
    final list = raw['vrat'];
    if (list is! List) throw VidhiFormatException(file, '"vrat" सूची नहीं है');
    return [
      for (final e in list)
        if (e is Map<String, dynamic>)
          VratSuchiEntry(
            id: _str(file, e, 'id'),
            naam: _str(file, e, 'naam'),
            samuh: VratSamuh.parse(file, _str(file, e, 'samuh')),
            devta: _str(file, e, 'devta'),
            engine: e['engine'] as String?,
            faail: e['faail'] as String?,
            taiyar: e['taiyar'] == true,
          )
        else
          throw VidhiFormatException(file, 'सूची की हर पंक्ति object हो'),
    ];
  }
}

/// भोजन का एक रूप — फलाहार, एक समय, निर्जल।
class VratBhojan {
  final String roop;
  final String vivaran;

  const VratBhojan(this.roop, this.vivaran);

  bool get nirjal => roop == 'निर्जल';
}

/// पूजा का एक कदम।
class VratKadam {
  final int kram;
  final String shirshak;
  final String vivaran;

  const VratKadam(this.kram, this.shirshak, this.vivaran);
}

/// एक सवाल-जवाब।
class VratSawaal {
  final String sawaal;
  final String jawaab;

  const VratSawaal(this.sawaal, this.jawaab);
}

/// एक पूरा व्रत-पन्ना।
class VratPanna {
  final String id;
  final String naam;
  final String devta;
  final VratSamuh samuh;
  final String ekLine;

  // ── कब करें
  final String kabSaral;
  final String shuruKab;
  final String kitniBaar;

  /// तिथि दो दिन हो, या दिन का नियम अलग हो — तब क्या। ख़ाली भी हो सकता है।
  final String doDin;

  /// इंजन के `VratNiyam` की id, जिनकी तारीख़ ऐप गिनता है।
  final String? engine;

  // ── भाव और माहात्म्य
  final String bhav;
  final String mahatmyaKathan;
  final String mahatmyaStrot;
  final Bharosa mahatmyaBharosa;

  // ── नियम
  final String pehleDin;
  final List<String> vratKeDin;
  final List<String> naKarein;

  final List<VratBhojan> bhojan;
  final String paran;
  final List<VratKadam> puja;
  final Mantra mantra;

  final List<String> kathaIds;

  /// कथा जान-बूझकर न ली हो तो क्यों (→ D-076)। ख़ाली = कथा है।
  final String kathaKyonNahi;

  final List<String> paath;
  final String? vidhiId;
  final String udyapan;
  final List<String> savdhani;
  final List<VratSawaal> sawaal;
  final List<String> strot;

  const VratPanna({
    required this.id,
    required this.naam,
    required this.devta,
    required this.samuh,
    required this.ekLine,
    required this.kabSaral,
    required this.shuruKab,
    required this.kitniBaar,
    required this.doDin,
    required this.engine,
    required this.bhav,
    required this.mahatmyaKathan,
    required this.mahatmyaStrot,
    required this.mahatmyaBharosa,
    required this.pehleDin,
    required this.vratKeDin,
    required this.naKarein,
    required this.bhojan,
    required this.paran,
    required this.puja,
    required this.mantra,
    required this.kathaIds,
    required this.kathaKyonNahi,
    required this.paath,
    required this.vidhiId,
    required this.udyapan,
    required this.savdhani,
    required this.sawaal,
    required this.strot,
  });

  factory VratPanna.parse(String file, String source) {
    final j = _object(file, source);
    if (j['schemaVersion'] != 1) {
      throw VidhiFormatException(file, 'schemaVersion 1 चाहिए');
    }
    final kab = _map(file, j, 'kab');
    final niyamKab = _map(file, kab, 'niyam');
    final mahatmya = _map(file, j, 'mahatmya');
    final niyam = _map(file, j, 'niyam');

    final bhojan = [
      for (final b in _list(file, j, 'bhojan'))
        VratBhojan(_str(file, b, 'roop'), _str(file, b, 'vivaran')),
    ];
    // ⚠️ निर्जल कभी पहला रूप नहीं — ऐप उसका सुझाव नहीं देता (→ D-075)।
    if (bhojan.isEmpty || bhojan.first.nirjal) {
      throw VidhiFormatException(file, 'भोजन का पहला रूप निर्जल नहीं हो सकता');
    }

    final kathaIds = [for (final k in j['kathaIds'] as List? ?? []) '$k'];
    final kathaKyonNahi = _str(file, j, 'kathaKyonNahi', required: false);
    if (kathaIds.isEmpty && kathaKyonNahi.trim().isEmpty) {
      throw VidhiFormatException(file, 'कथा नहीं है तो kathaKyonNahi लिखो');
    }

    return VratPanna(
      id: _str(file, j, 'id'),
      naam: _str(file, j, 'naam'),
      devta: _str(file, j, 'devta'),
      samuh: VratSamuh.parse(file, _str(file, j, 'samuh')),
      ekLine: _str(file, j, 'ekLine'),
      kabSaral: _str(file, kab, 'saral'),
      shuruKab: _str(file, kab, 'shuruKab'),
      kitniBaar: _str(file, kab, 'kitniBaar'),
      doDin: _str(file, kab, 'doDin', required: false),
      engine: niyamKab['engine'] as String?,
      bhav: _str(file, j, 'bhav'),
      mahatmyaKathan: _str(file, mahatmya, 'kathan'),
      mahatmyaStrot: _str(file, mahatmya, 'strot'),
      mahatmyaBharosa: Bharosa.parse(file, _str(file, mahatmya, 'bharosa')),
      pehleDin: _str(file, niyam, 'pehleDin'),
      vratKeDin: _strList(file, niyam, 'vratKeDin'),
      naKarein: _strList(file, niyam, 'naKarein', required: false),
      bhojan: bhojan,
      paran: _str(file, j, 'paran'),
      puja: [
        for (final p in _list(file, j, 'puja'))
          VratKadam(
            p['kram'] as int? ?? 0,
            _str(file, p, 'shirshak'),
            _str(file, p, 'vivaran'),
          ),
      ],
      mantra: Mantra.fromJson(file, _map(file, j, 'mantra')),
      kathaIds: kathaIds,
      kathaKyonNahi: kathaKyonNahi,
      paath: [for (final p in j['paath'] as List? ?? []) '$p'],
      vidhiId: j['vidhiId'] as String?,
      udyapan: _str(file, j, 'udyapan'),
      savdhani: _strList(file, j, 'savdhani'),
      sawaal: [
        for (final s in _list(file, j, 'sawaal'))
          VratSawaal(_str(file, s, 'sawaal'), _str(file, s, 'jawaab')),
      ],
      strot: _strList(file, j, 'strot'),
    );
  }
}

/// साल की एक एकादशी (`_ekadashi_varsh.json`)।
class EkadashiVarsh {
  final int kram;
  final String id;
  final String naam;

  /// पूर्णिमांत महीना — उत्तर भारत की गणना।
  final String maas;

  /// अमांत गणना में वही एकादशी किस महीने में गिनी जाती है।
  final String amantMaas;

  /// `true` = कृष्ण पक्ष।
  final bool krishna;

  /// सिर्फ़ अधिक मास वाले साल में।
  final bool adhik;

  final String kathaId;
  final String ekLine;
  final String vishesh;

  const EkadashiVarsh({
    required this.kram,
    required this.id,
    required this.naam,
    required this.maas,
    required this.amantMaas,
    required this.krishna,
    required this.adhik,
    required this.kathaId,
    required this.ekLine,
    required this.vishesh,
  });

  String get pakshaNaam => krishna ? 'कृष्ण पक्ष' : 'शुक्ल पक्ष';

  /// "मार्गशीर्ष कृष्ण पक्ष" · "अधिक मास, शुक्ल पक्ष"
  String get kabLikha => adhik ? 'अधिक मास, $pakshaNaam' : '$maas $pakshaNaam';

  static List<EkadashiVarsh> parseAll(String file, String source) {
    final raw = _object(file, source);
    return [
      for (final e in _list(file, raw, 'ekadashi'))
        EkadashiVarsh(
          kram: e['kram'] as int? ?? 0,
          id: _str(file, e, 'id'),
          naam: _str(file, e, 'naam'),
          maas: _str(file, e, 'maas'),
          amantMaas: _str(file, e, 'amantMaas'),
          krishna: e['paksha'] == 1,
          adhik: e['adhik'] == true,
          kathaId: _str(file, e, 'kathaId'),
          ekLine: _str(file, e, 'ekLine'),
          vishesh: _str(file, e, 'vishesh'),
        ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────

Map<String, dynamic> _object(String file, String source) {
  final Object? raw;
  try {
    raw = jsonDecode(source);
  } on FormatException catch (e) {
    throw VidhiFormatException(file, 'JSON पढ़ा नहीं जा सका — ${e.message}');
  }
  if (raw is! Map<String, dynamic>) {
    throw VidhiFormatException(file, 'सबसे ऊपर एक object होना चाहिए');
  }
  return raw;
}

Map<String, dynamic> _map(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! Map<String, dynamic>) {
    throw VidhiFormatException(file, '"$key" object होना चाहिए');
  }
  return v;
}

List<Map<String, dynamic>> _list(
    String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is! List) throw VidhiFormatException(file, '"$key" सूची होनी चाहिए');
  return [
    for (final e in v)
      e is Map<String, dynamic>
          ? e
          : throw VidhiFormatException(file, '"$key" की हर पंक्ति object हो'),
  ];
}

List<String> _strList(String file, Map<String, dynamic> j, String key,
    {bool required = true}) {
  final v = j[key];
  if (v is! List || (required && v.isEmpty)) {
    if (!required && v == null) return const [];
    throw VidhiFormatException(file, '"$key" भरी सूची होनी चाहिए');
  }
  return [for (final s in v) '$s'.replaceAll('**', '')];
}

/// ⚠️ `**मोटे**` के तारे पढ़ते ही हटते हैं — ऐप में markdown renderer
/// नहीं है, वरना कच्चे तारे दिखते (वही वजह जो `vidhi.dart` में लिखी है)।
String _str(String file, Map<String, dynamic> j, String key,
    {bool required = true}) {
  final v = j[key];
  if (v == null && !required) return '';
  if (v is! String || (required && v.trim().isEmpty)) {
    throw VidhiFormatException(file, '"$key" भरा होना चाहिए');
  }
  return v.replaceAll('**', '');
}
