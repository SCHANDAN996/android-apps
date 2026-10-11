import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/vrat_artwork.dart';

void main() {
  test('नए व्रत चित्र सही IDs पर और local assets में हैं', () {
    const ids = ['pradosh', 'ekadashi', 'sankashti', 'purnima', 'janmashtami'];
    final paths = ids.map((id) => VratArtwork.forVratId(id).assetPath).toList();
    expect(paths.toSet(), hasLength(ids.length));
    for (final path in paths) {
      expect(path, endsWith('_v2.webp'));
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(VratArtwork.forVratId('solah_somvar').assetPath, paths[0]);
    expect(VratArtwork.forVratId('masik_shivratri').assetPath, paths[0]);
    expect(VratArtwork.forVratId('ekadashi_varsh').assetPath, paths[1]);
    expect(VratArtwork.forVratId('vinayak_chaturthi').assetPath,
        isNot(paths[2]));
  });
}
