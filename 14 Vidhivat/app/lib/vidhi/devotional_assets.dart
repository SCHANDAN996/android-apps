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
    assetPath: 'assets/images/devotional/diya.webp',
    semanticLabel: 'सजावटी दीपक का चित्र',
  );

  static const completion = DevotionalArtwork(
    assetPath: 'assets/images/devotional/diya.webp',
    semanticLabel: 'मार्गदर्शिका पूर्ण होने का सजावटी दीपक चित्र',
  );

  static const nityaPooja = DevotionalArtwork(
    assetPath: 'assets/images/devotional/nitya_pooja.webp',
    semanticLabel: 'नित्य पूजा की थाली का सजावटी चित्र',
  );

  static const lakshmi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/lakshmi.webp',
    semanticLabel: 'लक्ष्मी जी का सजावटी चित्र',
  );

  static const kalash = DevotionalArtwork(
    assetPath: 'assets/images/devotional/kalash_sthapana_v2.webp',
    semanticLabel: 'पूजा कलश का सजावटी चित्र',
  );

  static const karwaChauth = DevotionalArtwork(
    assetPath: 'assets/images/devotional/karwa_chauth.webp',
    semanticLabel: 'करवा चौथ पूजा का सजावटी चित्र',
  );

  static const shiva = DevotionalArtwork(
    assetPath: 'assets/images/devotional/shiva.webp',
    semanticLabel: 'शिव जी का सजावटी चित्र',
  );

  static const rudrabhishek = DevotionalArtwork(
    assetPath: 'assets/images/devotional/rudrabhishek_v3.webp',
    semanticLabel: 'रुद्राभिषेक के लिए शिवलिंग का सजावटी चित्र',
  );

  static const grihPravesh = DevotionalArtwork(
    assetPath: 'assets/images/devotional/grih_pravesh.webp',
    semanticLabel: 'गृह प्रवेश के लिए कलश का सजावटी चित्र',
  );

  static const hanuman = DevotionalArtwork(
    assetPath: 'assets/images/devotional/hanuman_realistic_v1.webp',
    semanticLabel: 'हनुमान जी का यथार्थपरक सजावटी चित्र',
  );

  static const suryaArghya = DevotionalArtwork(
    assetPath: 'assets/images/devotional/surya_arghya_realistic_v1.webp',
    semanticLabel: 'सूर्य अर्घ्य का यथार्थपरक सजावटी चित्र',
  );

  static const tulsi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/tulsi_realistic_v1.webp',
    semanticLabel: 'तुलसी पूजा का यथार्थपरक सजावटी चित्र',
  );

  static const saraswati = DevotionalArtwork(
    assetPath: 'assets/images/devotional/saraswati_realistic_v1.webp',
    semanticLabel: 'सरस्वती जी का यथार्थपरक सजावटी चित्र',
  );

  static const ram = DevotionalArtwork(
    assetPath: 'assets/images/devotional/ram_realistic_v1.webp',
    semanticLabel: 'श्री राम का यथार्थपरक सजावटी चित्र',
  );

  static const krishna = DevotionalArtwork(
    assetPath: 'assets/images/devotional/krishna_realistic_v1.webp',
    semanticLabel: 'श्री कृष्ण का यथार्थपरक सजावटी चित्र',
  );

  static const Map<String, DevotionalArtwork> _byVidhiId = {
    'nitya_pooja': nityaPooja,
    'satyanarayan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/satyanarayan_v1.webp',
      semanticLabel: 'सत्यनारायण पूजा की वेदी का सजावटी चित्र',
    ),
    'ganesh_poojan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/ganesha.webp',
      semanticLabel: 'गणेश पूजन का सजावटी चित्र',
    ),
    'grih_pravesh': grihPravesh,
    'lakshmi_poojan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/lakshmi_ganesh_poojan_v1.webp',
      semanticLabel: 'लक्ष्मी गणेश पूजन का सजावटी चित्र',
    ),
    'kalash_sthapana': kalash,
    'mundan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/mundan.webp',
      semanticLabel: 'मुंडन संस्कार का सजावटी चित्र',
    ),
    'karwa_chauth': karwaChauth,
    'shraadh': DevotionalArtwork(
      assetPath: 'assets/images/devotional/shraadh.webp',
      semanticLabel: 'श्राद्ध और तर्पण का सजावटी चित्र',
    ),
    'rudrabhishek': rudrabhishek,
    'vahan_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/vahan_pooja_v4.webp',
      semanticLabel: 'कार और स्कूटर की वाहन पूजा का सजावटी चित्र',
    ),
    'upanayan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/upanayan.webp',
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
    // दीपावली की तिकड़ी। ⚠️ फ़ोन पर पकड़ा गया कि इनके बिना तीनों card
    // पर एक ही generic दीया दिखता था — वही चीज़ जो D-039 वाले काम में
    // ठीक की गई थी। नई पूजा बनाते वक़्त यहाँ जोड़ना भूलना नहीं है;
    // `devotional_assets_test.dart` की जाँच अब इसका पहरा देती है।
    'dhanteras': DevotionalArtwork(
      assetPath: 'assets/images/devotional/dhanteras_v1.webp',
      semanticLabel: 'धनतेरस के धन्वंतरि कलश का सजावटी चित्र',
    ),
    'govardhan_annakut': DevotionalArtwork(
      assetPath: 'assets/images/devotional/govardhan_annakut_v1.webp',
      semanticLabel: 'गोवर्धन अन्नकूट का सजावटी चित्र',
    ),
    'bhai_dooj_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/bhai_dooj_v1.webp',
      semanticLabel: 'भाई दूज तिलक का सजावटी चित्र',
    ),
    // बची हुई सात घरेलू पूजाएँ (4 सित 2026)।
    'raksha_bandhan_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/raksha_bandhan_v1.webp',
      semanticLabel: 'रक्षाबंधन की राखी का सजावटी चित्र',
    ),
    'makar_sankranti_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/makar_sankranti_v1.webp',
      semanticLabel: 'मकर संक्रांति के सूर्य अर्घ्य का सजावटी चित्र',
    ),
    'hartalika_teej': DevotionalArtwork(
      assetPath: 'assets/images/devotional/hartalika_teej_v1.webp',
      semanticLabel: 'हरितालिका तीज में पार्वती पूजा का सजावटी चित्र',
    ),
    'vat_savitri': DevotionalArtwork(
      assetPath: 'assets/images/devotional/vat_savitri_v1.webp',
      semanticLabel: 'बरगद के वट वृक्ष की वट सावित्री पूजा का सजावटी चित्र',
    ),
    'chhath_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/chhath_pooja_v1.webp',
      semanticLabel: 'छठ पूजा में सूर्य को अर्घ्य का सजावटी चित्र',
    ),
    'varalakshmi_vrat': DevotionalArtwork(
      assetPath: 'assets/images/devotional/varalakshmi_vrat_v1.webp',
      semanticLabel: 'वरलक्ष्मी व्रत के कलश का सजावटी चित्र',
    ),
    'durga_ashtami_kanya_poojan': DevotionalArtwork(
      assetPath: 'assets/images/devotional/kanya_poojan_v1.webp',
      semanticLabel: 'कन्या पूजन का सजावटी चित्र',
    ),
  };

  static DevotionalArtwork forVidhiId(String id) => _byVidhiId[id] ?? diya;
}
