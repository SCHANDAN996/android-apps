/// Stable, presentation-only mapping from a Vidhi id to bundled artwork.
///
/// IDs come from `assets/vidhi/_suchi.json`; no display-name guessing is used.
/// Unknown/future Pujas intentionally receive the neutral diya instead of an
/// assumed deity association.
class DevotionalArtwork {
  final String assetPath;
  final String semanticLabel;

  const DevotionalArtwork({
    required this.assetPath,
    required this.semanticLabel,
  });
}

abstract final class DevotionalAssets {
  static const diya = DevotionalArtwork(
    assetPath: 'assets/images/devotional/diya.png',
    semanticLabel: 'सजावटी दीपक का चित्र',
  );

  static const completion = DevotionalArtwork(
    assetPath: 'assets/images/devotional/diya.png',
    semanticLabel: 'मार्गदर्शिका पूर्ण होने का सजावटी दीपक चित्र',
  );

  static const nityaPooja = DevotionalArtwork(
    assetPath: 'assets/images/devotional/nitya_pooja.png',
    semanticLabel: 'नित्य पूजा की थाली का सजावटी चित्र',
  );

  static const lakshmi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/lakshmi.png',
    semanticLabel: 'लक्ष्मी जी का सजावटी चित्र',
  );

  static const kalash = DevotionalArtwork(
    assetPath: 'assets/images/devotional/kalash_sthapana_v2.png',
    semanticLabel: 'पूजा कलश का सजावटी चित्र',
  );

  static const karwaChauth = DevotionalArtwork(
    assetPath: 'assets/images/devotional/karwa_chauth.png',
    semanticLabel: 'करवा चौथ पूजा का सजावटी चित्र',
  );

  static const shiva = DevotionalArtwork(
    assetPath: 'assets/images/devotional/shiva.png',
    semanticLabel: 'शिव जी का सजावटी चित्र',
  );

  static const rudrabhishek = DevotionalArtwork(
    assetPath: 'assets/images/devotional/rudrabhishek_v3.png',
    semanticLabel: 'रुद्राभिषेक के लिए शिवलिंग का सजावटी चित्र',
  );

  static const grihPravesh = DevotionalArtwork(
    assetPath: 'assets/images/devotional/grih_pravesh.png',
    semanticLabel: 'गृह प्रवेश के लिए कलश का सजावटी चित्र',
  );

  static const hanuman = DevotionalArtwork(
    assetPath: 'assets/images/devotional/hanuman_realistic_v1.png',
    semanticLabel: 'हनुमान जी का यथार्थपरक सजावटी चित्र',
  );

  static const suryaArghya = DevotionalArtwork(
    assetPath: 'assets/images/devotional/surya_arghya_realistic_v1.png',
    semanticLabel: 'सूर्य अर्घ्य का यथार्थपरक सजावटी चित्र',
  );

  static const tulsi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/tulsi_realistic_v1.png',
    semanticLabel: 'तुलसी पूजा का यथार्थपरक सजावटी चित्र',
  );

  static const saraswati = DevotionalArtwork(
    assetPath: 'assets/images/devotional/saraswati_realistic_v1.png',
    semanticLabel: 'सरस्वती जी का यथार्थपरक सजावटी चित्र',
  );

  static const ram = DevotionalArtwork(
    assetPath: 'assets/images/devotional/ram_realistic_v1.png',
    semanticLabel: 'श्री राम का यथार्थपरक सजावटी चित्र',
  );

  static const krishna = DevotionalArtwork(
    assetPath: 'assets/images/devotional/krishna_realistic_v1.png',
    semanticLabel: 'श्री कृष्ण का यथार्थपरक सजावटी चित्र',
  );

  static const Map<String, DevotionalArtwork> _byVidhiId = {
    'nitya_pooja': nityaPooja,
    'satyanarayan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/vishnu.png',
      semanticLabel: 'सत्यनारायण पूजा के लिए विष्णु का सजावटी चित्र',
    ),
    'ganesh_poojan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/ganesha.png',
      semanticLabel: 'गणेश पूजन का सजावटी चित्र',
    ),
    'grih_pravesh': grihPravesh,
    'lakshmi_poojan': lakshmi,
    'kalash_sthapana': kalash,
    'mundan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/mundan.png',
      semanticLabel: 'मुंडन संस्कार का सजावटी चित्र',
    ),
    'karwa_chauth': karwaChauth,
    'shraadh': DevotionalArtwork(
      assetPath: 'assets/images/devotional/shraadh.png',
      semanticLabel: 'श्राद्ध और तर्पण का सजावटी चित्र',
    ),
    'rudrabhishek': rudrabhishek,
    'vahan_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/vahan_pooja_v3.png',
      semanticLabel: 'वाहन पूजा का सजावटी चित्र',
    ),
    'upanayan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/upanayan.png',
      semanticLabel: 'उपनयन संस्कार का सजावटी चित्र',
    ),
    // Phase A की छह पूजाएँ (→ docs/14_PUJA_LIBRARY_EXPANSION_PLAN.md)।
    // चित्र पहले से बने हुए थे, तब ये सिर्फ़ planned सूची में थीं।
    'hanuman_pooja': hanuman,
    'surya_arghya': suryaArghya,
    'tulsi_pooja': tulsi,
    'saraswati_pooja': saraswati,
    'ram_pooja': ram,
    'krishna_pooja': krishna,
  };

  static DevotionalArtwork forVidhiId(String id) => _byVidhiId[id] ?? diya;
}
