import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/vidhi/devotional_assets.dart';

void main() {
  group('DevotionalAssets', () {
    test('stable Puja IDs map to their intended local artwork', () {
      expect(
        DevotionalAssets.forVidhiId('ganesh_poojan').assetPath,
        'assets/images/devotional/ganesha.png',
      );
      expect(
        DevotionalAssets.forVidhiId('rudrabhishek').assetPath,
        'assets/images/devotional/rudrabhishek_v3.png',
      );
      expect(
        DevotionalAssets.forVidhiId('lakshmi_poojan').assetPath,
        'assets/images/devotional/lakshmi.png',
      );
      expect(
        DevotionalAssets.forVidhiId('kalash_sthapana').assetPath,
        'assets/images/devotional/kalash_sthapana_v2.png',
      );
      expect(
        DevotionalAssets.forVidhiId('grih_pravesh').assetPath,
        'assets/images/devotional/grih_pravesh.png',
      );
      expect(
        DevotionalAssets.forVidhiId('mundan').assetPath,
        'assets/images/devotional/mundan.png',
      );
      expect(
        DevotionalAssets.forVidhiId('upanayan').assetPath,
        'assets/images/devotional/upanayan.png',
      );
      expect(
        DevotionalAssets.forVidhiId('karwa_chauth').assetPath,
        'assets/images/devotional/karwa_chauth.png',
      );
      expect(
        DevotionalAssets.forVidhiId('shraadh').assetPath,
        'assets/images/devotional/shraadh.png',
      );
      expect(
        DevotionalAssets.forVidhiId('vahan_pooja').assetPath,
        'assets/images/devotional/vahan_pooja_v3.png',
      );
    });

    test('unknown Puja safely uses the neutral diya fallback', () {
      expect(
        DevotionalAssets.forVidhiId('future_puja').assetPath,
        DevotionalAssets.diya.assetPath,
      );
    });
  });
}
