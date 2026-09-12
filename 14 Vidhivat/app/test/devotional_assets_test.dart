import 'dart:io';
import 'dart:ui' as ui;

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
        'assets/images/devotional/lakshmi_ganesh_poojan_v1.webp',
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
        'assets/images/devotional/vahan_pooja_v4.webp',
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
        expect(
          File(DevotionalAssets.forVidhiId(e.id).assetPath).existsSync(),
          isTrue,
          reason: 'mapped artwork file must be bundled locally',
        );
      }
    });

    test('unknown Puja safely uses the neutral diya fallback', () {
      expect(
        DevotionalAssets.forVidhiId('future_puja').assetPath,
        DevotionalAssets.diya.assetPath,
      );
    });

    test('नवरात्रि की हर नई विधि सही स्थानीय artwork खोलती है', () {
      final expected = <String, DevotionalArtwork>{
        'navratri_sankshipt': DevotionalAssets.navratriParv,
        'navratri_din_2': DevotionalAssets.navratriBrahmacharini,
        'navratri_din_3': DevotionalAssets.navratriChandraghanta,
        'navratri_din_4': DevotionalAssets.navratriKushmanda,
        'navratri_din_5': DevotionalAssets.navratriSkandamata,
        'navratri_din_6': DevotionalAssets.navratriKatyayani,
        'navratri_din_7': DevotionalAssets.navratriKalaratri,
        'navratri_navami_havan': DevotionalAssets.navratriHavan,
        'vijayadashami': DevotionalAssets.vijayadashami,
      };
      for (final entry in expected.entries) {
        expect(DevotionalAssets.forVidhiId(entry.key), same(entry.value));
        expect(File(entry.value.assetPath).existsSync(), isTrue);
      }
    });

    test('सभी नवरात्रि WebP सही नाप और हल्के bundle में हैं', () async {
      final paths = <String>{
        DevotionalAssets.navratriParv.assetPath,
        DevotionalAssets.navratriShailaputri.assetPath,
        DevotionalAssets.navratriBrahmacharini.assetPath,
        DevotionalAssets.navratriChandraghanta.assetPath,
        DevotionalAssets.navratriKushmanda.assetPath,
        DevotionalAssets.navratriSkandamata.assetPath,
        DevotionalAssets.navratriKatyayani.assetPath,
        DevotionalAssets.navratriKalaratri.assetPath,
        DevotionalAssets.navratriMahagauri.assetPath,
        DevotionalAssets.navratriSiddhidatri.assetPath,
        DevotionalAssets.navratriHavan.assetPath,
        DevotionalAssets.vijayadashami.assetPath,
        'assets/images/devotional/jau_bona_guide_v1.webp',
        'assets/images/devotional/akhand_jyoti_guide_v1.webp',
      };
      expect(paths, hasLength(14));
      for (final path in paths) {
        final file = File(path);
        expect(file.lengthSync(), lessThanOrEqualTo(180 * 1024), reason: path);
        final codec = await ui.instantiateImageCodec(file.readAsBytesSync());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, anyOf(900, 512), reason: path);
        expect(frame.image.height, anyOf(900, 512), reason: path);
        frame.image.dispose();
        codec.dispose();
      }
    });
  });
}
