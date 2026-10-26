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

  /// विश्वकर्मा पूजा वाला ही चित्र — सूक्त उसी पूजा के आवाहन से खुलता है।
  static const vishwakarma = DevotionalArtwork(
    assetPath: 'assets/images/devotional/vishwakarma_pooja_v1.webp',
    semanticLabel: 'विश्वकर्मा जी और शिल्प-औज़ारों का सजावटी चित्र',
  );

  // Each reading entry owns a distinct titled illustration (D-137).
  static const Map<String, DevotionalArtwork> _byPaathId = {
    'hanuman_chalisa': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_hanuman_chalisa_v2.webp',
        semanticLabel: 'श्री हनुमान चालीसा का नाम सहित सजावटी चित्र'),
    'ganesh_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_ganesh_aarti_v2.webp',
        semanticLabel: 'श्री गणेश जी की आरती का नाम सहित सजावटी चित्र'),
    'hanuman_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_hanuman_aarti_v2.webp',
        semanticLabel: 'श्री हनुमान जी की आरती का नाम सहित सजावटी चित्र'),
    'lakshmi_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_lakshmi_aarti_v2.webp',
        semanticLabel: 'श्री लक्ष्मी जी की आरती का नाम सहित सजावटी चित्र'),
    'durga_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_durga_aarti_v2.webp',
        semanticLabel: 'श्री दुर्गा जी की आरती का नाम सहित सजावटी चित्र'),
    'jagjanani_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_jagjanani_aarti_v2.webp',
        semanticLabel:
            'श्री देवी जी की आरती — जगजननी जय जय का नाम सहित सजावटी चित्र'),
    'saptashloki_durga': DevotionalArtwork(
        assetPath:
            'assets/images/devotional/reading_p_saptashloki_durga_v2.webp',
        semanticLabel: 'सप्तश्लोकी दुर्गा का नाम सहित सजावटी चित्र'),
    'shiv_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_shiv_aarti_v2.webp',
        semanticLabel: 'श्री शिव जी की आरती का नाम सहित सजावटी चित्र'),
    'satyanarayan_aarti': DevotionalArtwork(
        assetPath:
            'assets/images/devotional/reading_p_satyanarayan_aarti_v2.webp',
        semanticLabel: 'श्री सत्यनारायण जी की आरती का नाम सहित सजावटी चित्र'),
    'krishna_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_krishna_aarti_v2.webp',
        semanticLabel: 'श्री कृष्ण जी की आरती का नाम सहित सजावटी चित्र'),
    'ram_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_ram_aarti_v2.webp',
        semanticLabel: 'श्री राम जी की आरती का नाम सहित सजावटी चित्र'),
    'saraswati_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_saraswati_aarti_v2.webp',
        semanticLabel: 'श्री सरस्वती जी की आरती का नाम सहित सजावटी चित्र'),
    'jagdish_aarti': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_p_jagdish_aarti_v2.webp',
        semanticLabel: 'ॐ जय जगदीश हरे का नाम सहित सजावटी चित्र'),
    'vishwakarma_sukta': DevotionalArtwork(
        assetPath:
            'assets/images/devotional/reading_p_vishwakarma_sukta_v2.webp',
        semanticLabel: 'विश्वकर्मा सूक्त का नाम सहित सजावटी चित्र'),
  };

  static const Map<String, DevotionalArtwork> _byGranthId = {
    'gita': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_gita_v2.webp',
        semanticLabel: 'श्रीमद्भगवद्गीता का नाम सहित सजावटी चित्र'),
    'sundarkand': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_sundarkand_v2.webp',
        semanticLabel: 'सुंदरकांड का नाम सहित सजावटी चित्र'),
    'vishnusahasranama': DevotionalArtwork(
        assetPath:
            'assets/images/devotional/reading_g_vishnusahasranama_v2.webp',
        semanticLabel: 'श्री विष्णु सहस्रनाम का नाम सहित सजावटी चित्र'),
    'sukta': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_sukta_v2.webp',
        semanticLabel: 'वेद के सूक्त का नाम सहित सजावटी चित्र'),
    // रुद्राष्टाध्यायी का अपना चित्र नहीं — रुद्राभिषेक वाला शिवलिंग (→ D-156)
    'rudri': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_rudri_v2.webp',
        semanticLabel:
            'रुद्राष्टाध्यायी की पुस्तक, शिवलिंग और दीपक का सजावटी चित्र'),
    'upanishad': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_upanishad_v2.webp',
        semanticLabel: 'उपनिषद का नाम सहित सजावटी चित्र'),
    'mahabharat': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_mahabharat_v2.webp',
        semanticLabel: 'महाभारत का नाम सहित सजावटी चित्र'),
    'puran': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_puran_v2.webp',
        semanticLabel: 'वेद और पुराण — परिचय का नाम सहित सजावटी चित्र'),
    'saptashati': DevotionalArtwork(
        assetPath: 'assets/images/devotional/reading_g_saptashati_v2.webp',
        semanticLabel: 'दुर्गा सप्तशती का नाम सहित सजावटी चित्र'),
  };

  static DevotionalArtwork forPaathId(String id) =>
      _byPaathId[id] ?? DevotionalAssets.diya;
  static DevotionalArtwork forGranthId(String id) =>
      _byGranthId[id] ?? DevotionalAssets.diya;
}
