import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/paath.dart';
import 'package:vidhivat/vidhi/paath_assets.dart';

void main() {
  group('PaathAssets', () {
    test('हर तैयार पाठ को अपनी local thumbnail मिलती है', () {
      final entries = PaathSuchiEntry.parseAll(
        'assets/paath/_suchi.json',
        File('assets/paath/_suchi.json').readAsStringSync(),
      );

      for (final entry in entries.where((entry) => entry.taiyar)) {
        final artwork = PaathAssets.forPaathId(entry.id);
        expect(
          artwork.assetPath,
          isNot('assets/images/devotional/diya.webp'),
          reason: '${entry.id} को dedicated Paath artwork चाहिए',
        );
        expect(
          File(artwork.assetPath).existsSync(),
          isTrue,
          reason: '${entry.id} का mapped artwork local होना चाहिए',
        );
      }
    });

    test('unknown Paath safely uses the neutral diya fallback', () {
      expect(
        PaathAssets.forPaathId('future_paath').assetPath,
        'assets/images/devotional/diya.webp',
      );
    });

    test('ग्रंथालय के नए चित्र मौजूद हैं और अलग-अलग हैं', () {
      const ids = ['sukta', 'upanishad', 'mahabharat', 'puran', 'sundarkand'];
      final paths = ids.map((id) => PaathAssets.forGranthId(id).assetPath).toList();
      expect(paths.toSet(), hasLength(ids.length));
      for (final path in paths) {
        expect(path, endsWith('_v2.webp'));
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });
  });
}
