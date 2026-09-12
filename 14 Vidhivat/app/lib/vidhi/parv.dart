import 'dart:convert';

import 'vidhi.dart' show VidhiFormatException;

/// पर्व JSON के ढाँचे का वर्तमान संस्करण।
const int parvSchemaVersion = 1;

/// एक पर्व — कई दिन चलने वाला त्योहार, जिसमें हर दिन की अपनी विधि है।
class Parv {
  final String id;
  final String naam;
  final String ekLine;
  final String parichay;
  final String artworkAsset;
  final String artworkLabel;
  final ParvRasta sankshipt;
  final List<ParvDin> din;

  const Parv({
    required this.id,
    required this.naam,
    required this.ekLine,
    required this.parichay,
    required this.artworkAsset,
    required this.artworkLabel,
    required this.sankshipt,
    required this.din,
  });

  factory Parv.fromJson(String file, Map<String, dynamic> j) {
    final version = _int(file, j, 'schemaVersion');
    if (version != parvSchemaVersion) {
      throw VidhiFormatException(
        file,
        'schemaVersion $version है, ऐप $parvSchemaVersion चाहता है',
      );
    }

    final id = _str(file, j, 'id');
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
      throw VidhiFormatException(file, 'id "$id" सुरक्षित नाम नहीं है');
    }
    final din = _list(file, j, 'din')
        .map((value) => ParvDin.fromJson(file, _map(file, value, 'din')))
        .toList(growable: false);
    if (din.isEmpty) {
      throw VidhiFormatException(file, 'पर्व में एक भी दिन नहीं है');
    }
    for (var i = 0; i < din.length; i++) {
      if (din[i].ank != i + 1) {
        throw VidhiFormatException(
          file,
          'दिन क्रम में नहीं हैं: ${i + 1} की जगह ${din[i].ank} मिला',
        );
      }
    }

    return Parv(
      id: id,
      naam: _str(file, j, 'naam'),
      ekLine: _str(file, j, 'ekLine'),
      parichay: _str(file, j, 'parichay'),
      artworkAsset: _asset(file, j, 'artworkAsset'),
      artworkLabel: _str(file, j, 'artworkLabel'),
      sankshipt: ParvRasta.fromJson(
        file,
        _map(file, j['sankshipt'], 'sankshipt'),
      ),
      din: din,
    );
  }

  factory Parv.parse(String file, String source) {
    try {
      final decoded = jsonDecode(source);
      return Parv.fromJson(file, _map(file, decoded, 'फ़ाइल'));
    } on VidhiFormatException {
      rethrow;
    } on FormatException catch (error) {
      throw VidhiFormatException(file, 'JSON नहीं पढ़ा गया: ${error.message}');
    }
  }
}

/// संक्षिप्त रास्ता — एक ही बैठक में होने वाली पूजा।
class ParvRasta {
  final String shirshak;
  final String vivaran;
  final String? vidhiId;
  final int samayMinute;

  const ParvRasta({
    required this.shirshak,
    required this.vivaran,
    required this.vidhiId,
    required this.samayMinute,
  });

  factory ParvRasta.fromJson(String file, Map<String, dynamic> j) {
    final samay = _int(file, j, 'samayMinute');
    if (samay <= 0) {
      throw VidhiFormatException(
          file, 'संक्षिप्त पूजा का समय शून्य से बड़ा हो');
    }
    return ParvRasta(
      shirshak: _str(file, j, 'shirshak'),
      vivaran: _str(file, j, 'vivaran'),
      vidhiId: _nullableId(file, j, 'vidhiId'),
      samayMinute: samay,
    );
  }
}

/// पर्व का एक दिन।
class ParvDin {
  final int ank;
  final String tithiNaam;
  final String shirshak;
  final String ekLine;
  final String bhog;
  final String? vidhiId;
  final String artworkAsset;
  final String artworkLabel;
  final int samayMinute;

  const ParvDin({
    required this.ank,
    required this.tithiNaam,
    required this.shirshak,
    required this.ekLine,
    required this.bhog,
    required this.vidhiId,
    required this.artworkAsset,
    required this.artworkLabel,
    required this.samayMinute,
  });

  factory ParvDin.fromJson(String file, Map<String, dynamic> j) {
    final ank = _int(file, j, 'ank');
    final samay = _int(file, j, 'samayMinute');
    if (ank <= 0) {
      throw VidhiFormatException(file, 'दिन का अंक शून्य से बड़ा हो');
    }
    if (samay <= 0) {
      throw VidhiFormatException(file, 'दिन $ank का समय शून्य से बड़ा हो');
    }
    return ParvDin(
      ank: ank,
      tithiNaam: _str(file, j, 'tithiNaam'),
      shirshak: _str(file, j, 'shirshak'),
      ekLine: _str(file, j, 'ekLine'),
      bhog: _str(file, j, 'bhog'),
      vidhiId: _nullableId(file, j, 'vidhiId'),
      artworkAsset: _asset(file, j, 'artworkAsset'),
      artworkLabel: _str(file, j, 'artworkLabel'),
      samayMinute: samay,
    );
  }
}

/// पंचांग से निकली इस साल के पर्व की वर्तमान स्थिति।
class ParvAaj {
  final int? aajKaDin;
  final int? kitneDinBaad;
  final DateTime? shuruTarikh;
  final DateTime? antTarikh;
  final int kulDin;
  final String? tippani;
  final Set<int> mileHueDin;
  final DateTime? ghatasthapanaShuru;
  final DateTime? ghatasthapanaAnt;
  final DateTime? ghatasthapanaAbhijitShuru;
  final DateTime? ghatasthapanaAbhijitAnt;
  final DateTime? sandhiShuru;
  final DateTime? sandhiAnt;

  const ParvAaj({
    required this.aajKaDin,
    required this.kitneDinBaad,
    required this.shuruTarikh,
    required this.antTarikh,
    required this.kulDin,
    required this.tippani,
    required this.mileHueDin,
    this.ghatasthapanaShuru,
    this.ghatasthapanaAnt,
    this.ghatasthapanaAbhijitShuru,
    this.ghatasthapanaAbhijitAnt,
    this.sandhiShuru,
    this.sandhiAnt,
  });
}

String _str(String file, Map<String, dynamic> j, String key) {
  final value = j[key];
  if (value is! String || value.trim().isEmpty) {
    throw VidhiFormatException(file, '"$key" में भरा हुआ अक्षर-पाठ चाहिए');
  }
  return value;
}

int _int(String file, Map<String, dynamic> j, String key) {
  final value = j[key];
  if (value is! int) {
    throw VidhiFormatException(file, '"$key" में पूर्णांक चाहिए');
  }
  return value;
}

List<dynamic> _list(String file, Map<String, dynamic> j, String key) {
  final value = j[key];
  if (value is! List<dynamic>) {
    throw VidhiFormatException(file, '"$key" में सूची चाहिए');
  }
  return value;
}

Map<String, dynamic> _map(String file, Object? value, String key) {
  if (value is! Map<String, dynamic>) {
    throw VidhiFormatException(file, '"$key" में JSON object चाहिए');
  }
  return value;
}

String _asset(String file, Map<String, dynamic> j, String key) {
  final value = _str(file, j, key);
  if (!value.startsWith('assets/images/devotional/') ||
      !value.endsWith('.webp')) {
    throw VidhiFormatException(file, '"$key" में devotional webp path चाहिए');
  }
  return value;
}

String? _nullableId(String file, Map<String, dynamic> j, String key) {
  final value = j[key];
  if (value == null) return null;
  if (value is! String || !RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
    throw VidhiFormatException(file, '"$key" में सुरक्षित id या null चाहिए');
  }
  return value;
}
