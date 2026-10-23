import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/services/osm_khoj.dart';

/// इंटरनेट वाली खोज की क़तार (→ D-129, D-134) — नक़ली सर्वर (Photon का GeoJSON), नक़ली घड़ी।
void main() {
  // Photon के असली जवाब जैसा (23 अक्टूबर 2026 को «bihta» पर देखा): [देशांतर, अक्षांश],
  // `county` में तहसील/ज़िला, राज्य अंग्रेज़ी में और कभी चिह्नों के साथ («Haryāna»)
  const jawab = '''{"type":"FeatureCollection","features":[
    {"geometry":{"type":"Point","coordinates":[84.871,25.559]},
     "properties":{"name":"Bihta","osm_key":"place","osm_value":"village",
       "county":"Bihta","state":"Bihar","countrycode":"IN"}},
    {"geometry":{"type":"Point","coordinates":[76.953,30.276]},
     "properties":{"name":"Bihta","osm_key":"place","osm_value":"village",
       "county":"Saha","state":"Haryāna","countrycode":"IN"}},
    {"geometry":{"type":"Point","coordinates":[85.31,27.71]},
     "properties":{"name":"Bihi","osm_key":"place","osm_value":"hamlet",
       "county":"गोरखा","state":"गण्डकी प्रदेश","countrycode":"NP"}},
    {"geometry":{"type":"Point","coordinates":[85.5,25.5]},
     "properties":{"name":"Bihar","osm_key":"place","osm_value":"state","countrycode":"IN"}}
  ]}''';

  /// नक़ली घड़ी: `ruko` घड़ी आगे बढ़ाता है, असल में रुकता नहीं
  late DateTime ghadi;
  late List<DateTime> kabPucha;
  late List<String> haal;

  setUp(() {
    ghadi = DateTime(2026, 10, 22, 10);
    kabPucha = [];
    haal = [];
  });

  OsmKhoj banao(List<Object> jawaab) {
    var i = 0;
    return OsmKhoj(
      ab: () => ghadi,
      ruko: (d) async => ghadi = ghadi.add(d),
      laao: (uri) async {
        kabPucha.add(ghadi);
        final j = jawaab[i < jawaab.length ? i : jawaab.length - 1];
        i++;
        if (j is Exception) throw j;
        return j as OsmJawab;
      },
    );
  }

  test('जवाब से जगहें: ज़िला, राज्य हिंदी में; नेपाल और «राज्य» जैसी इकाई छूटती है', () {
    final mile = OsmKhoj.padho(jawab);
    expect(mile, hasLength(2));
    expect(mile[0].naam, 'Bihta');
    expect(mile[0].pata, 'बिहार'); // नाम जैसा ज़िला दोबारा नहीं
    expect(mile[0].latitude, closeTo(25.559, 1e-6));
    expect(mile[0].longitude, closeTo(84.871, 1e-6));
    expect(mile[1].pata, 'Saha, हरियाणा'); // «Haryāna» → हरियाणा
  });

  test('🔑 फ़ेल नहीं होती: इंटरनेट न हो, सर्वर व्यस्त हो — इंतज़ार करके दोबारा, जवाब तक', () async {
    final k = banao([
      const SocketException('नहीं'),
      const OsmJawab(503, '', Duration(seconds: 5)),
      const OsmJawab(500, ''),
      const OsmJawab(200, jawab),
    ]);
    final shuru = ghadi;
    final mile = await k.khojo('Rawai', haal: haal.add);
    expect(mile.map((j) => j.pata), ['बिहार', 'Saha, हरियाणा']);
    expect(kabPucha, hasLength(4));
    expect(haal, hasLength(3));
    expect(haal[0], contains('इंटरनेट नहीं मिला'));
    expect(haal[1], contains('भीड़'));
    expect(haal[1], contains('5 सेकंड'));
    // 2 (पहली नाकामी) + 5 (Retry-After) + 8 (तीसरी कोशिश के बाद) = 15 सेकंड
    expect(ghadi.difference(shuru), const Duration(seconds: 15));
  });

  test('दो खोजों के बीच कम से कम फ़ासला — सेवा पर बोझ नहीं', () async {
    final k = banao([const OsmJawab(200, jawab)]);
    await Future.wait([k.khojo('Patna'), k.khojo('Gaya'), k.khojo('Ara')]);
    expect(kabPucha, hasLength(3));
    for (var i = 1; i < kabPucha.length; i++) {
      expect(kabPucha[i].difference(kabPucha[i - 1]),
          greaterThanOrEqualTo(OsmKhoj.kamSeKamFasla));
    }
  });

  test('वही खोज दोबारा — याद से, कोई request नहीं', () async {
    final k = banao([const OsmJawab(200, jawab)]);
    await k.khojo('Rawai');
    await k.khojo('  rawai ');
    expect(kabPucha, hasLength(1));
  });

  test('पन्ना बंद हुआ तो खोज छूटती है, और क़तार अगली खोज के लिए खुली रहती है', () async {
    var band = false;
    final k = banao([
      const SocketException('नहीं'),
      const SocketException('नहीं'),
      const OsmJawab(200, jawab),
    ]);
    final pehli = k.khojo('Rawai', radd: () => band, haal: (_) => band = true);
    await expectLater(pehli, throwsA(isA<OsmRadd>()));
    final doosri = await k.khojo('Patna');
    expect(doosri, isNotEmpty);
  });

  test('एक ही बस्ती की दो प्रविष्टियाँ — एक बार (फ़ोन पर «Bihta» दो बार दिखा था)', () {
    const do_ = '''{"features":[
      {"geometry":{"coordinates":[84.870,25.564]},
       "properties":{"name":"Bihta","osm_value":"village","county":"Patna","state":"Bihar","countrycode":"IN"}},
      {"geometry":{"coordinates":[84.875,25.560]},
       "properties":{"name":"Bihta","osm_value":"town","county":"Patna","state":"Bihar","countrycode":"IN"}},
      {"geometry":{"coordinates":[80.98,24.42]},
       "properties":{"name":"Bihta","osm_value":"village","county":"Unchahara Tahsil","state":"Madhya Pradesh","countrycode":"IN"}}
    ]}''';
    final mile = OsmKhoj.padho(do_);
    expect(mile.map((j) => j.pata),
        ['Patna, बिहार', 'Unchahara Tahsil, मध्य प्रदेश']);
  });

  test('ख़ाली खोज — कोई request नहीं', () async {
    final k = banao([const OsmJawab(200, jawab)]);
    expect(await k.khojo('   '), isEmpty);
    expect(kabPucha, isEmpty);
  });
}
