import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/devotional_assets.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

void main() {
  group('DevotionalAssets', () {
    test('stable Puja IDs map to their intended local artwork', () {
      expect(
        DevotionalAssets.forVidhiId('ganesh_poojan').assetPath,
        'assets/images/devotional/ganesha.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('rudrabhishek').assetPath,
        'assets/images/devotional/rudrabhishek_v3.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('lakshmi_poojan').assetPath,
        'assets/images/devotional/lakshmi.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('kalash_sthapana').assetPath,
        'assets/images/devotional/kalash_sthapana_v2.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('grih_pravesh').assetPath,
        'assets/images/devotional/grih_pravesh.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('mundan').assetPath,
        'assets/images/devotional/mundan.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('upanayan').assetPath,
        'assets/images/devotional/upanayan.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('karwa_chauth').assetPath,
        'assets/images/devotional/karwa_chauth.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('shraadh').assetPath,
        'assets/images/devotional/shraadh.webp',
      );
      expect(
        DevotionalAssets.forVidhiId('vahan_pooja').assetPath,
        'assets/images/devotional/vahan_pooja_v3.webp',
      );
    });

    // ⚠️ यह जाँच फ़ोन पर मिली एक ग़लती के बाद लिखी गई (3 सित 2026)।
    // दीपावली की तिकड़ी बनी, पर `_byVidhiId` में जोड़ना छूट गया — तीनों
    // card पर एक ही generic दीया दिखने लगा, यानी वही "generic diya
    // repeat" जो D-039 वाले काम में ठीक किया गया था।
    //
    // `analyze` और 620 जाँचें साफ़ थीं; यह सिर्फ़ स्क्रीन पर दिखा।
    // अब कोई भी नई पूजा बिना अपनी तस्वीर नहीं रह सकती।
    test('हर तैयार पूजा की अपनी तस्वीर है — कोई generic दीये पर नहीं', () {
      final suchi = VidhiSuchiEntry.parseAll(
        'assets/vidhi/_suchi.json',
        File('assets/vidhi/_suchi.json').readAsStringSync(),
      );
      for (final e in suchi.where((e) => e.taiyar)) {
        expect(
          DevotionalAssets.forVidhiId(e.id).assetPath,
          isNot(DevotionalAssets.diya.assetPath),
          reason: '"${e.naam}" (${e.id}) के लिए अपनी तस्वीर नहीं है — '
              'devotional_assets.dart के _byVidhiId में जोड़ो',
        );
      }
    });

    test('unknown Puja safely uses the neutral diya fallback', () {
      expect(
        DevotionalAssets.forVidhiId('future_puja').assetPath,
        DevotionalAssets.diya.assetPath,
      );
    });
  });
}
