import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/instructional_assets.dart';

void main() {
  group('InstructionalAssets', () {
    test('target guided steps map to local action diagrams', () {
      final examples = <(String, String, String)>[
        (
          'nitya_pooja',
          'आचमन और पवित्रीकरण',
          'assets/images/devotional/achman_v1.webp'
        ),
        (
          'nitya_pooja',
          'संकल्प',
          'assets/images/devotional/sankalp_hasta_v1.webp'
        ),
        (
          'kalash_sthapana',
          'कलश स्थापना',
          'assets/images/devotional/kalash_sthapana_guide_v1.webp'
        ),
        (
          'surya_arghya',
          'अर्घ्य',
          'assets/images/devotional/surya_arghya_guide_v1.webp'
        ),
        (
          'vat_savitri',
          'परिक्रमा और सूत लपेटना',
          'assets/images/devotional/vat_sut_guide_v1.webp'
        ),
        ('shraadh', 'तर्पण', 'assets/images/devotional/tarpan_guide_v1.webp'),
        (
          'shraadh',
          'पिंडदान',
          'assets/images/devotional/pindadan_guide_v1.webp'
        ),
        (
          'chhath_pooja',
          'तैयारी — सूप सजाना',
          'assets/images/devotional/chhath_soop_guide_v1.webp'
        ),
      ];

      for (final example in examples) {
        final artwork = InstructionalAssets.forStep(
          vidhiId: example.$1,
          title: example.$2,
        );
        expect(artwork?.assetPath, example.$3);
        expect(File(artwork!.assetPath).existsSync(), isTrue);
      }
    });

    test('unmapped step does not show an instruction image', () {
      expect(
        InstructionalAssets.forStep(vidhiId: 'future', title: 'नई क्रिया'),
        isNull,
      );
    });
  });
}
