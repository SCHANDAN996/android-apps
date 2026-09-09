import 'devotional_assets.dart';

/// Stable, presentation-only mapping from a Paath id to bundled artwork.
///
/// Every ready Paath gets an identifiable local thumbnail. The neutral diya
/// remains only as a safe fallback for a future, unmapped Paath id.
abstract final class PaathAssets {
  static const hanuman = DevotionalArtwork(
    assetPath: 'assets/images/devotional/hanuman_realistic_v1.webp',
    semanticLabel: 'हनुमान जी का सजावटी चित्र',
  );

  static const ganesha = DevotionalArtwork(
    assetPath: 'assets/images/devotional/ganesha.webp',
    semanticLabel: 'गणेश जी का सजावटी चित्र',
  );

  static const lakshmi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/lakshmi.webp',
    semanticLabel: 'लक्ष्मी जी का सजावटी चित्र',
  );

  static const durga = DevotionalArtwork(
    assetPath: 'assets/images/devotional/durga_aarti_v1.webp',
    semanticLabel: 'दुर्गा माँ का सजावटी चित्र',
  );

  static const shiva = DevotionalArtwork(
    assetPath: 'assets/images/devotional/shiva.webp',
    semanticLabel: 'शिव जी का सजावटी चित्र',
  );

  static const vishnu = DevotionalArtwork(
    assetPath: 'assets/images/devotional/vishnu.webp',
    semanticLabel: 'विष्णु जी का सजावटी चित्र',
  );

  static const krishna = DevotionalArtwork(
    assetPath: 'assets/images/devotional/krishna_realistic_v1.webp',
    semanticLabel: 'श्री कृष्ण का सजावटी चित्र',
  );

  static const ram = DevotionalArtwork(
    assetPath: 'assets/images/devotional/ram_realistic_v1.webp',
    semanticLabel: 'श्री राम का सजावटी चित्र',
  );

  static const saraswati = DevotionalArtwork(
    assetPath: 'assets/images/devotional/saraswati_realistic_v1.webp',
    semanticLabel: 'सरस्वती जी का सजावटी चित्र',
  );

  static const Map<String, DevotionalArtwork> _byPaathId = {
    'hanuman_chalisa': hanuman,
    'ganesh_aarti': ganesha,
    'hanuman_aarti': hanuman,
    'lakshmi_aarti': lakshmi,
    'durga_aarti': durga,
    'shiv_aarti': shiva,
    'satyanarayan_aarti': vishnu,
    'krishna_aarti': krishna,
    'ram_aarti': ram,
    'saraswati_aarti': saraswati,
    'jagdish_aarti': vishnu,
  };

  static DevotionalArtwork forPaathId(String id) =>
      _byPaathId[id] ?? DevotionalAssets.diya;
}
