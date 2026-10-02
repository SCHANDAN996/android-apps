import 'devotional_assets.dart';

/// व्रत सूची और व्रत-पन्ने के चित्र। नाम देखकर देवता का अनुमान नहीं।
abstract final class VratArtwork {
  static const _vishnu = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vishnu.webp',
      semanticLabel: 'भगवान विष्णु का सजावटी चित्र');
  static const _ganesha = DevotionalArtwork(
      assetPath: 'assets/images/devotional/ganesha.webp',
      semanticLabel: 'श्रीगणेश का सजावटी चित्र');
  static const _satyanarayan = DevotionalArtwork(
      assetPath: 'assets/images/devotional/satyanarayan_v1.webp',
      semanticLabel: 'सत्यनारायण पूजा का सजावटी चित्र');
  static const _shraadh = DevotionalArtwork(
      assetPath: 'assets/images/devotional/shraadh.webp',
      semanticLabel: 'पितृ तर्पण का सजावटी चित्र');
  static const _hartalika = DevotionalArtwork(
      assetPath: 'assets/images/devotional/hartalika_teej_v1.webp',
      semanticLabel: 'शिव-पार्वती की हरितालिका पूजा का सजावटी चित्र');
  static const _vatSavitri = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vat_savitri_v1.webp',
      semanticLabel: 'वट सावित्री पूजा का सजावटी चित्र');
  static const _chhath = DevotionalArtwork(
      assetPath: 'assets/images/devotional/chhath_pooja_v1.webp',
      semanticLabel: 'छठ पूजा में सूर्य अर्घ्य का सजावटी चित्र');
  static const _varalakshmi = DevotionalArtwork(
      assetPath: 'assets/images/devotional/varalakshmi_vrat_v1.webp',
      semanticLabel: 'वरलक्ष्मी व्रत का सजावटी चित्र');
  static const _santoshi = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_santoshi_mata_v1.webp',
      semanticLabel: 'संतोषी माता का सजावटी चित्र');
  static const _ahoi = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_ahoi_ashtami_v1.webp',
      semanticLabel: 'अहोई अष्टमी का पारंपरिक पूजन-चित्र');
  static const _jivitputrika = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_jivitputrika_v1.webp',
      semanticLabel:
          'जीवित्पुत्रिका व्रत में जीमूतवाहन की कथा का सजावटी चित्र');
  static const _rishiPanchami = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_rishi_panchami_v1.webp',
      semanticLabel: 'ऋषि पंचमी में सप्तर्षि और अरुंधती का सजावटी चित्र');
  static const _gangaur = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_gangaur_v1.webp',
      semanticLabel: 'गणगौर में ईसर और गौरी का सजावटी चित्र');
  static const _sakatChauth = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_sakat_chauth_v2.webp',
      semanticLabel: 'सकट चौथ में गणेश और तिल-गुड़ भोग का सजावटी चित्र');
  static const _shanivarHanuman = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_shanivar_hanuman_v1.webp',
      semanticLabel: 'शनिवार व्रत में हनुमान उपासना का सजावटी चित्र');
  static const _anantSutra = DevotionalArtwork(
      assetPath: 'assets/images/devotional/vrat_anant_sutra_v2.webp',
      semanticLabel: 'अनंत चतुर्दशी का चौदह गांठ वाला अनंत सूत्र');

  static const Map<String, DevotionalArtwork> _byVratId = {
    'somvar': DevotionalAssets.shiva,
    'mangalvar': DevotionalAssets.hanuman,
    'brihaspativar': _vishnu,
    'ravivar': DevotionalAssets.suryaArghya,
    'budhvar': _ganesha,
    'shukravar': _santoshi,
    'shanivar': _shanivarHanuman,
    'solah_somvar': DevotionalAssets.shiva,
    'ekadashi': _vishnu,
    'pradosh': DevotionalAssets.shiva,
    'sankashti': _ganesha,
    'purnima': _satyanarayan,
    'amavasya': _shraadh,
    'masik_shivratri': DevotionalAssets.shiva,
    'vinayak_chaturthi': _ganesha,
    'masik_durgashtami': DevotionalAssets.navratriParv,
    'ekadashi_varsh': _vishnu,
    'hartalika': _hartalika,
    'karwa_chauth': DevotionalAssets.karwaChauth,
    'vat_savitri': _vatSavitri,
    'chhath': _chhath,
    'varalakshmi': _varalakshmi,
    'navratri': DevotionalAssets.navratriParv,
    'mahashivratri': DevotionalAssets.rudrabhishek,
    'janmashtami': DevotionalAssets.krishna,
    'ahoi_ashtami': _ahoi,
    'jivitputrika': _jivitputrika,
    'gangaur': _gangaur,
    'rishi_panchami': _rishiPanchami,
    'anant_chaturdashi': _anantSutra,
    'sakat_chauth': _sakatChauth,
  };

  static DevotionalArtwork forVratId(String id) =>
      _byVratId[id] ?? DevotionalAssets.diya;
}
