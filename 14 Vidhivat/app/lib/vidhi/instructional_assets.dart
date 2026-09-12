import 'devotional_assets.dart';

/// Small, action-first visuals for specific guided-puja steps.
///
/// Text and step order remain in the UI; these transparent illustrations only
/// clarify the physical action.
abstract final class InstructionalAssets {
  static const achman = DevotionalArtwork(
    assetPath: 'assets/images/devotional/achman_v1.webp',
    semanticLabel: 'आचमन के लिए हथेली में जल लेने का चित्र',
  );

  static const sankalp = DevotionalArtwork(
    assetPath: 'assets/images/devotional/sankalp_hasta_v1.webp',
    semanticLabel: 'संकल्प के लिए जल, अक्षत और फूल का चित्र',
  );

  static const kalash = DevotionalArtwork(
    assetPath: 'assets/images/devotional/kalash_sthapana_guide_v1.webp',
    semanticLabel: 'कलश स्थापना का सजावटी निर्देश चित्र',
  );

  static const suryaArghya = DevotionalArtwork(
    assetPath: 'assets/images/devotional/surya_arghya_guide_v1.webp',
    semanticLabel: 'सूर्य की दिशा में अर्घ्य देने का चित्र',
  );

  static const vatSut = DevotionalArtwork(
    assetPath: 'assets/images/devotional/vat_sut_guide_v1.webp',
    semanticLabel: 'बरगद पर सूत लपेटने का चित्र',
  );

  static const tarpan = DevotionalArtwork(
    assetPath: 'assets/images/devotional/tarpan_guide_v1.webp',
    semanticLabel: 'तर्पण में तिल-जल अर्पित करने का चित्र',
  );

  static const pindadan = DevotionalArtwork(
    assetPath: 'assets/images/devotional/pindadan_guide_v1.webp',
    semanticLabel: 'पिंडदान में पिंड रखने का चित्र',
  );

  static const chhathSoop = DevotionalArtwork(
    assetPath: 'assets/images/devotional/chhath_soop_guide_v1.webp',
    semanticLabel: 'छठ के सूप सजाने का चित्र',
  );

  static const jauBona = DevotionalArtwork(
    assetPath: 'assets/images/devotional/jau_bona_guide_v1.webp',
    semanticLabel: 'नवरात्रि के जौ बोने का निर्देश चित्र',
  );

  static const akhandJyoti = DevotionalArtwork(
    assetPath: 'assets/images/devotional/akhand_jyoti_guide_v1.webp',
    semanticLabel: 'अखंड ज्योति की सुरक्षित व्यवस्था का निर्देश चित्र',
  );

  static DevotionalArtwork? forStep({
    required String vidhiId,
    required String title,
  }) {
    if (title == 'आचमन और पवित्रीकरण') return achman;
    if (title == 'संकल्प') return sankalp;
    if (title.startsWith('कलश स्थापना')) return kalash;
    if (title.contains('जौ बोना')) return jauBona;
    if (title.contains('अखंड ज्योति')) return akhandJyoti;
    if (vidhiId == 'surya_arghya' && title == 'अर्घ्य') return suryaArghya;
    if (vidhiId == 'vat_savitri' && title == 'परिक्रमा और सूत लपेटना') {
      return vatSut;
    }
    if (vidhiId == 'shraadh' && title == 'तर्पण') return tarpan;
    if (vidhiId == 'shraadh' && title == 'पिंडदान') return pindadan;
    if (vidhiId == 'chhath_pooja' && title == 'तैयारी — सूप सजाना') {
      return chhathSoop;
    }
    return null;
  }
}
