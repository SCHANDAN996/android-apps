import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/parv.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

void main() {
  Map<String, dynamic> sahiJson() => {
        'schemaVersion': 1,
        'id': 'navratri',
        'naam': 'शारदीय नवरात्रि',
        'ekLine': 'नौ दिन, नौ रूप',
        'parichay': 'माँ दुर्गा के नौ रूपों की आराधना।',
        'artworkAsset': 'assets/images/devotional/navratri_parv_v1.webp',
        'artworkLabel': 'नवरात्रि का सजावटी चित्र',
        'sankshipt': {
          'shirshak': 'संक्षिप्त नवरात्रि पूजा',
          'vivaran': 'एक ही बैठक में पूरी पूजा',
          'vidhiId': null,
          'samayMinute': 30,
        },
        'din': [
          {
            'ank': 1,
            'tithiNaam': 'प्रतिपदा',
            'shirshak': 'शैलपुत्री',
            'ekLine': 'घटस्थापना और जौ बोना',
            'bhog': 'गाय का घी',
            'vidhiId': 'kalash_sthapana',
            'artworkAsset': 'assets/images/devotional/navratri_din_1.webp',
            'artworkLabel': 'माँ शैलपुत्री का सजावटी चित्र',
            'samayMinute': 84,
          },
        ],
      };

  test('सही पर्व JSON पूरा पढ़ता है', () {
    final parv = Parv.parse('navratri.json', jsonEncode(sahiJson()));

    expect(parv.id, 'navratri');
    expect(parv.sankshipt.samayMinute, 30);
    expect(parv.din.single.shirshak, 'शैलपुत्री');
    expect(parv.din.single.vidhiId, 'kalash_sthapana');
  });

  test('ग़लत schemaVersion साफ़ त्रुटि देता है', () {
    final json = sahiJson()..['schemaVersion'] = 2;

    expect(
      () => Parv.parse('navratri.json', jsonEncode(json)),
      throwsA(isA<VidhiFormatException>()),
    );
  });

  test('दिन का टूटा क्रम स्वीकार नहीं होता', () {
    final json = sahiJson();
    final pehla = Map<String, dynamic>.from(
      (json['din'] as List<dynamic>).first as Map,
    );
    json['din'] = <dynamic>[
      ...(json['din'] as List<dynamic>),
      {...pehla, 'ank': 3},
    ];

    expect(
      () => Parv.parse('navratri.json', jsonEncode(json)),
      throwsA(isA<VidhiFormatException>()),
    );
  });

  test('ग़लत चित्र path स्वीकार नहीं होता', () {
    final json = sahiJson()..['artworkAsset'] = 'https://example.test/a.png';

    expect(
      () => Parv.parse('navratri.json', jsonEncode(json)),
      throwsA(isA<VidhiFormatException>()),
    );
  });

  testWidgets('असली नवरात्रि asset भंडार से पढ़ती है', (tester) async {
    final parv = await parvBhandar.parv('navratri');

    expect(parv.din, hasLength(10));
    expect(parv.din.first.vidhiId, 'kalash_sthapana');
    expect(parv.din[7].vidhiId, 'durga_ashtami_kanya_poojan');
    expect(parv.din.last.shirshak, 'विजयादशमी');

    final sabhiId = <String>{
      parv.sankshipt.vidhiId!,
      for (final din in parv.din)
        if (din.vidhiId != null) din.vidhiId!,
    };
    for (final id in sabhiId) {
      expect((await vidhiBhandar.vidhi(id)).id, id);
    }
  });
}
