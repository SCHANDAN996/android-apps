import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/services/osm_khoj.dart';

/// इंटरनेट वाली खोज की क़तार (→ D-129) — नक़ली सर्वर, नक़ली घड़ी।
void main() {
  const jawab = '''[
    {"lat":"25.6093","lon":"85.1235","name":"पटना","display_name":"पटना, बिहार, भारत",
     "address":{"state_district":"पटना","state":"बिहार","country_code":"in"}},
    {"lat":"27.4770","lon":"77.7260","name":"Rawai","display_name":"Rawai, Mathura, Uttar Pradesh",
     "address":{"county":"Mathura","state":"उत्तर प्रदेश"}},
    {"lat":"51.5","lon":"-0.12","name":"London","display_name":"London"}
  ]''';

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

  test('जवाब से जगहें: हिंदी नाम, ज़िला-राज्य; भारत के बाहर वाली छूटती है', () {
    final mile = OsmKhoj.padho(jawab);
    expect(mile, hasLength(2));
    expect(mile[0].naam, 'पटना');
    expect(mile[0].pata, 'बिहार'); // नाम जैसा ज़िला दोबारा नहीं
    expect(mile[1].naam, 'Rawai');
    expect(mile[1].pata, 'Mathura, उत्तर प्रदेश');
    expect(mile[1].latitude, closeTo(27.477, 1e-6));
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
    expect(mile.map((j) => j.naam), ['पटना', 'Rawai']);
    expect(kabPucha, hasLength(4));
    expect(haal, hasLength(3));
    expect(haal[0], contains('इंटरनेट नहीं मिला'));
    expect(haal[1], contains('भीड़'));
    expect(haal[1], contains('5 सेकंड'));
    // 2 (पहली नाकामी) + 5 (Retry-After) + 8 (तीसरी कोशिश के बाद) = 15 सेकंड
    expect(ghadi.difference(shuru), const Duration(seconds: 15));
  });

  test('दो खोजों के बीच कम से कम 1.1 सेकंड — Nominatim की नीति', () async {
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
    const do_ = '''[
      {"lat":"25.5640","lon":"84.8700","name":"Bihta",
       "address":{"state_district":"पटना जिला","state":"बिहार"}},
      {"lat":"25.5600","lon":"84.8750","name":"Bihta",
       "address":{"state_district":"पटना जिला","state":"बिहार"}},
      {"lat":"24.4200","lon":"80.9800","name":"Bihta",
       "address":{"county":"सतना","state":"मध्य प्रदेश"}}
    ]''';
    final mile = OsmKhoj.padho(do_);
    expect(mile.map((j) => j.pata), ['पटना जिला, बिहार', 'सतना, मध्य प्रदेश']);
  });

  test('ख़ाली खोज — कोई request नहीं', () async {
    final k = banao([const OsmJawab(200, jawab)]);
    expect(await k.khojo('   '), isEmpty);
    expect(kabPucha, isEmpty);
  });
}
