/// भारत की बसी जगहें — गाँव, क़स्बे, मोहल्ले — ऐप के अंदर, बिना इंटरनेट (→ D-128)।
///
/// डेवलपर (21 अक्टूबर 2026): *"सिर्फ़ 500 शहर से काम नहीं चल पाएगा — ऐसा सिस्टम
/// बनाना चाहिए कि यूज़र किसी भी लोकल जगह को सर्च करे तो वो भी आ सके।"*
///
/// सूची `assets/jagah/gaon.txt.gz` — लगभग साढ़े पाँच लाख जगहें, `tools/banao_gaon.py`
/// से बनी (ढाँचा वहीं लिखा है; फ़ाइल हाथ से मत छुओ)। नाम अंग्रेज़ी अक्षरों में हैं,
/// जैसे स्रोत में; हिंदी में लिखी खोज भी चलती है — दोनों तरफ़ व्यंजनों का वही ढाँचा
/// बनता है जो शहरों की खोज में (→ [romanDhancha], [devDhanche])।
///
/// याददाश्त बचाने के लिए नाम और ढाँचे एक-एक लंबी byte-पंक्ति में रखे हैं, जगह-जगह
/// के `String` नहीं। सूची पहली खोज पर अलग isolate में खुलती है (लगभग एक सेकंड)।
library;

import 'dart:convert' show Utf8Decoder;
import 'dart:io' show gzip;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'shahar.dart';

const gaonAsset = 'assets/jagah/gaon.txt.gz';

/// एक मिली हुई जगह।
class Gaon {
  final String naam; // अंग्रेज़ी अक्षरों में, जैसे सूची में
  final String zila; // अंग्रेज़ी अक्षरों में; अनजाना हो तो ख़ाली
  final String rajya; // हिंदी में
  final double latitude;
  final double longitude;

  /// 0 ज़िला मुख्यालय/राजधानी · 1 तहसील-स्तर · 2 गाँव/क़स्बा · 3 शहर का मोहल्ला
  final int darja;

  const Gaon(this.naam, this.zila, this.rajya, this.latitude, this.longitude,
      this.darja);

  /// सूची में दिखाने लायक़ पता — «Rampur — Bareilly, उत्तर प्रदेश»
  String get pata => zila.isEmpty ? rajya : '$zila, $rajya';

  /// कुंडली और पंचांग के लिए [City] — नाम वही अंग्रेज़ी वाला, राज्य की जगह पूरा पता
  City get city => City(naam, pata, latitude, longitude);
}

/// खुली हुई सूची। [GaonSuchi.khulo] से — एक ही बार खुलती है।
class GaonSuchi {
  final Uint8List _naam; // सब नाम, लगातार
  final Int32List _naamShuru; // n + 1
  final Uint8List _saaf; // छोटे अक्षर, सिर्फ़ a–z
  final Int32List _saafShuru;
  final Uint8List _dhancha; // व्यंजनों का ढाँचा
  final Int32List _dhanchaShuru;
  final Int32List _lat, _lon; // (अंश − 6/68) × 1000
  final Uint8List _rajya, _darja;
  final Uint16List _zila;
  final List<String> rajyaNaam, zilaNaam;
  final List<List<String>> _zilaDhancha, _rajyaDhancha;

  GaonSuchi._(
    this._naam,
    this._naamShuru,
    this._saaf,
    this._saafShuru,
    this._dhancha,
    this._dhanchaShuru,
    this._lat,
    this._lon,
    this._rajya,
    this._darja,
    this._zila,
    this.rajyaNaam,
    this.zilaNaam,
  )   : _zilaDhancha = [for (final z in zilaNaam) [romanDhancha(z)]],
        _rajyaDhancha = [for (final r in rajyaNaam) devDhanche(r)];

  int get length => _lat.length;

  static Future<GaonSuchi>? _khul;

  /// सूची खोलो (पहली बार asset पढ़कर, अलग isolate में; बाद में वही)।
  static Future<GaonSuchi> khulo([AssetBundle? bundle]) => _khul ??= () async {
        final data = await (bundle ?? rootBundle).load(gaonAsset);
        final gz = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        return Isolate.run(() => padho(gz));
      }();

  /// gzip वाली bytes से सूची — जाँच में सीधे भी चलती है।
  static GaonSuchi padho(Uint8List gz) {
    final b = Uint8List.fromList(gzip.decode(gz));
    var i = 0;
    String line() {
      final s = i;
      while (b[i] != 10) {
        i++;
      }
      final out = String.fromCharCodes(b, s, i); // «#…» वाली पंक्तियाँ ASCII हैं
      i++;
      return out;
    }

    // पहली दो पंक्तियाँ UTF-8 (हिंदी) — इन्हें ठीक से खोलो
    int s0 = i;
    while (b[i] != 10) {
      i++;
    }
    final rajya = _utf8(b, s0, i).split('|');
    i++;
    s0 = i;
    while (b[i] != 10) {
      i++;
    }
    final zile = _utf8(b, s0, i).split('|');
    i++;

    // बाक़ी ASCII — एक बार गिनो, फिर भरो
    var n = 0;
    for (var k = i; k < b.length; k++) {
      if (b[k] == 10) n++;
    }
    final naam = BytesBuilder(copy: false);
    // ⚠ copy: true — नीचे वही छोटे buffer हर नाम पर दोबारा भरते हैं
    final saaf = BytesBuilder();
    final dh = BytesBuilder();
    final naamShuru = Int32List(n + 1), saafShuru = Int32List(n + 1), dhShuru = Int32List(n + 1);
    final lat = Int32List(n), lon = Int32List(n), darja = Uint8List(n), rj = Uint8List(n);
    final zl = Uint16List(n);
    var m = 0, nLen = 0, sLen = 0, dLen = 0;
    var curR = 0, curZ = 0, pichhla = 0;
    final saafBuf = Uint8List(256), dhBuf = Uint8List(256);
    while (i < b.length) {
      if (b[i] == 35) {
        // «#राज्य<TAB>ज़िला»
        final f = line().substring(1).split('\t');
        curR = int.parse(f[0]);
        curZ = int.parse(f[1]);
        pichhla = 0;
        continue;
      }
      // नाम<TAB>Δअक्षांश<TAB>देशांतर<TAB>दर्जा
      final s = i;
      while (b[i] != 9) {
        i++;
      }
      final e = i;
      i++;
      int num() {
        var v = 0, neg = false;
        if (b[i] == 45) {
          neg = true;
          i++;
        }
        while (b[i] >= 48 && b[i] <= 57) {
          v = v * 10 + b[i] - 48;
          i++;
        }
        i++; // TAB या \n
        return neg ? -v : v;
      }

      final dA = num(), d = num(), dj = num();
      pichhla += dA;
      naam.add(Uint8List.sublistView(b, s, e));
      nLen += e - s;
      final sl = saafKaro(b, s, e, saafBuf);
      saaf.add(Uint8List.sublistView(saafBuf, 0, sl));
      sLen += sl;
      final dl = dhanchaBytes(b, s, e, dhBuf);
      dh.add(Uint8List.sublistView(dhBuf, 0, dl));
      dLen += dl;
      lat[m] = pichhla;
      lon[m] = d;
      darja[m] = dj;
      rj[m] = curR;
      zl[m] = curZ;
      m++;
      naamShuru[m] = nLen;
      saafShuru[m] = sLen;
      dhShuru[m] = dLen;
    }
    return GaonSuchi._(
      naam.takeBytes(),
      naamShuru.sublist(0, m + 1),
      saaf.takeBytes(),
      saafShuru.sublist(0, m + 1),
      dh.takeBytes(),
      dhShuru.sublist(0, m + 1),
      lat.sublist(0, m),
      lon.sublist(0, m),
      rj.sublist(0, m),
      darja.sublist(0, m),
      zl.sublist(0, m),
      rajya,
      zile,
    );
  }

  Gaon _gaon(int k) => Gaon(
        String.fromCharCodes(_naam, _naamShuru[k], _naamShuru[k + 1]),
        zilaNaam[_zila[k]],
        rajyaNaam[_rajya[k]],
        _lat[k] / 1000 + 6,
        _lon[k] / 1000 + 68,
        _darja[k],
      );

  /// जगह खोजो — हिंदी या अंग्रेज़ी में। «गाँव, ज़िला» लिखो तो उसी ज़िले/राज्य की।
  ///
  /// क्रम: अंग्रेज़ी वर्तनी पूरी मिली → ढाँचा पूरा मिला → वर्तनी की शुरुआत मिली →
  /// ढाँचे की शुरुआत मिली; बराबरी पर बड़ी जगह (मुख्यालय) पहले, फिर छोटा नाम।
  List<Gaon> khojo(String khoj, {int kitne = 15}) {
    final hisse = khoj.split(RegExp('[,،]'));
    final q = hisse.first.trim();
    if (q.isEmpty) return const [];
    final dev = _devanagari.hasMatch(q);
    final dhanche = <Uint8List>[
      for (final d in (dev ? devDhanche(q) : [romanDhancha(q)]))
        if (d.isNotEmpty) Uint8List.fromList(d.codeUnits),
    ];
    if (dhanche.isEmpty) return const [];
    final saafQ = dev ? null : Uint8List.fromList(_saafString(q).codeUnits);

    // ज़िले/राज्य की छलनी
    Set<int>? zileChalni, rajyaChalni;
    if (hisse.length > 1 && hisse[1].trim().isNotEmpty) {
      final f = hisse[1].trim();
      final fd = _devanagari.hasMatch(f) ? devDhanche(f) : [romanDhancha(f)];
      bool mile(List<String> naamDh) =>
          naamDh.any((x) => fd.any((y) => y.isNotEmpty && x.startsWith(y)));
      zileChalni = {
        for (var z = 0; z < zilaNaam.length; z++)
          if (mile(_zilaDhancha[z])) z,
      };
      rajyaChalni = {
        for (var r = 0; r < rajyaNaam.length; r++)
          if (mile(_rajyaDhancha[r])) r,
      };
    }

    // सबसे अच्छे [kitne] — (दर्जा-ए-मेल, जगह का दर्जा, नाम की लंबाई, क्रमांक)
    final best = <List<int>>[];
    for (var k = 0; k < length; k++) {
      int? mel;
      if (saafQ != null) {
        final c = _tulna(_saaf, _saafShuru[k], _saafShuru[k + 1], saafQ);
        if (c == 2) {
          mel = 0;
        } else if (c == 1) {
          mel = 2;
        }
      }
      if (mel != 0) {
        for (final dq in dhanche) {
          final c = _tulna(_dhancha, _dhanchaShuru[k], _dhanchaShuru[k + 1], dq);
          final m = c == 2 ? 1 : (c == 1 ? 3 : null);
          if (m != null && (mel == null || m < mel)) mel = m;
        }
      }
      if (mel == null) continue;
      if (zileChalni != null &&
          !zileChalni.contains(_zila[k]) &&
          !rajyaChalni!.contains(_rajya[k])) {
        continue;
      }
      final row = [mel, _darja[k], _naamShuru[k + 1] - _naamShuru[k], k];
      if (best.length == kitne && !_chhota(row, best.last)) continue;
      var j = best.length;
      while (j > 0 && _chhota(row, best[j - 1])) {
        j--;
      }
      best.insert(j, row);
      if (best.length > kitne) best.removeLast();
    }
    return [for (final r in best) _gaon(r[3])];
  }
}

bool _chhota(List<int> a, List<int> b) {
  for (var i = 0; i < 4; i++) {
    if (a[i] != b[i]) return a[i] < b[i];
  }
  return false;
}

/// 2 = पूरा मेल, 1 = शुरुआत मिली, 0 = नहीं
int _tulna(Uint8List buf, int s, int e, Uint8List q) {
  final len = e - s;
  if (len < q.length) return 0;
  for (var i = 0; i < q.length; i++) {
    if (buf[s + i] != q[i]) return 0;
  }
  return len == q.length ? 2 : 1;
}

final _devanagari = RegExp(r'[ऀ-ॿ]');

String _utf8(Uint8List b, int s, int e) =>
    const Utf8Decoder().convert(b, s, e);

String _saafString(String s) {
  final b = Uint8List.fromList(s.codeUnits.map((c) => c > 255 ? 32 : c).toList());
  final out = Uint8List(b.length);
  final n = saafKaro(b, 0, b.length, out);
  return String.fromCharCodes(out, 0, n);
}
