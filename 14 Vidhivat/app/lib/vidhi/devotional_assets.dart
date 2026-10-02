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

  static const completionGanesha = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_ganesha_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते गणेश जी का सजावटी चित्र',
  );

  static const completionVishwakarma = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_vishwakarma_v1.webp',
    semanticLabel: 'आशीर्वाद देते भगवान विश्वकर्मा का सजावटी चित्र',
  );

  static const completionShiva = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_shiva_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते शिव जी का सजावटी चित्र',
  );

  static const completionHanuman = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_hanuman_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते हनुमान जी का सजावटी चित्र',
  );

  static const completionSatyanarayan = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_satyanarayan_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते श्री सत्यनारायण का चित्र',
  );
  static const completionSaraswati = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_saraswati_blessing_v1.webp',
    semanticLabel: 'आशीर्वाद मुद्रा में माँ सरस्वती का सजावटी चित्र',
  );
  static const completionRam = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_ram_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते श्रीराम का सजावटी चित्र',
  );
  static const completionKrishna = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_krishna_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते श्रीकृष्ण का सजावटी चित्र',
  );
  static const completionSurya = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_surya_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते सूर्यदेव का सजावटी चित्र',
  );
  static const completionDurga = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_durga_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देती माँ दुर्गा का सजावटी चित्र',
  );
  static const completionLakshmi = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_lakshmi_blessing_v1.webp',
    semanticLabel: 'अभय-वरद मुद्रा में माँ लक्ष्मी का सजावटी चित्र',
  );
  static const completionDhanvantari = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_dhanvantari_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देते धन्वंतरि भगवान का चित्र',
  );
  static const completionGayatri = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_gayatri_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देती गायत्री माता का चित्र',
  );
  static const completionTulsiDevi = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_tulsi_devi_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में आशीर्वाद देती तुलसी देवी का चित्र',
  );
  static const completionShivaParvati = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_shiva_parvati_blessing_v1.webp',
    semanticLabel: 'आशीर्वाद देते शिव-पार्वती का सजावटी चित्र',
  );
  static const completionGovardhanAnnakut = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_govardhan_annakut_blessing_v1.webp',
    semanticLabel: 'गोवर्धन धारण कर आशीर्वाद देते श्रीकृष्ण का चित्र',
  );
  static const completionMakarSankranti = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_makar_sankranti_blessing_v1.webp',
    semanticLabel: 'सप्ताश्व रथ पर आशीर्वाद देते सूर्यदेव का चित्र',
  );
  static const completionChhath = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_chhath_blessing_v1.webp',
    semanticLabel: 'छठी मैया और सूर्यदेव के आशीर्वाद का चित्र',
  );
  static const completionVatSavitri = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_vat_savitri_blessing_v1.webp',
    semanticLabel: 'बरगद के नीचे आशीर्वाद देती माता सावित्री का चित्र',
  );
  static const completionKarwaChauth = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_karwa_chauth_blessing_v1.webp',
    semanticLabel: 'करवा चौथ पर आशीर्वाद देते शिव-पार्वती का चित्र',
  );
  static const completionHartalikaTeej = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_hartalika_teej_blessing_v1.webp',
    semanticLabel: 'हरतालिका तीज पर आशीर्वाद देते शिव-पार्वती का चित्र',
  );
  static const completionKalashSthapana = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_kalash_sthapana_blessing_v1.webp',
    semanticLabel:
        'कलश और जवारों के साथ आशीर्वाद देती अष्टभुजा दुर्गा का चित्र',
  );
  static const completionLakshmiPoojan = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_lakshmi_poojan_blessing_v1.webp',
    semanticLabel: 'अभय मुद्रा में माँ लक्ष्मी और श्रीगणेश का चित्र',
  );
  static const completionNityaPooja = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_nitya_pooja_blessing_v1.webp',
    semanticLabel: 'नित्य पूजा के पंचदेव आशीर्वाद का चित्र',
  );
  static const completionGrihPravesh = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_grih_pravesh_blessing_v1.webp',
    semanticLabel: 'मंगल कलश के साथ आशीर्वाद देते श्रीगणेश का चित्र',
  );
  static const completionMundan = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_mundan_blessing_v1.webp',
    semanticLabel: 'मुंडन संस्कार पर आशीर्वाद देते श्रीगणेश का चित्र',
  );
  static const completionVahanPooja = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_vahan_pooja_blessing_v1.webp',
    semanticLabel: 'वाहन पूजा पर आशीर्वाद देते श्रीगणेश का चित्र',
  );
  static const completionShraadh = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_shraadh_blessing_v1.webp',
    semanticLabel: 'श्राद्ध कर्म पर आशीर्वाद देते भगवान विष्णु का चित्र',
  );
  static const completionBhaiDooj = DevotionalArtwork(
    assetPath: 'assets/images/devotional/completion_bhai_dooj_blessing_v1.webp',
    semanticLabel: 'भाई दूज पर आशीर्वाद देते यमराज और यमुना का चित्र',
  );
  static const completionRakshaBandhan = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_raksha_bandhan_blessing_v1.webp',
    semanticLabel: 'रक्षा बंधन पर आशीर्वाद देते श्रीकृष्ण और सुभद्रा का चित्र',
  );
  static const completionNavratriSankshipt = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_sankshipt_blessing_v1.webp',
    semanticLabel: 'संक्षिप्त नवरात्रि पूजा पर अष्टभुजा दुर्गा का चित्र',
  );
  static const completionNavratriBrahmacharini = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_brahmacharini_blessing_v1.webp',
    semanticLabel: 'माँ ब्रह्मचारिणी का जपमाला-कमंडल सहित चित्र',
  );
  static const completionNavratriChandraghanta = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_chandraghanta_blessing_v1.webp',
    semanticLabel: 'दशभुजा माँ चंद्रघंटा का चित्र',
  );
  static const completionNavratriKushmanda = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_kushmanda_blessing_v1.webp',
    semanticLabel: 'अष्टभुजा माँ कूष्मांडा का चित्र',
  );
  static const completionNavratriSkandamata = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_skandamata_blessing_v1.webp',
    semanticLabel: 'बाल स्कंद के साथ माँ स्कंदमाता का चित्र',
  );
  static const completionNavratriKatyayani = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_katyayani_blessing_v1.webp',
    semanticLabel: 'चतुर्भुजा माँ कात्यायनी का चित्र',
  );
  static const completionNavratriKalaratri = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_kalaratri_blessing_v1.webp',
    semanticLabel: 'रक्षक रूप में माँ कालरात्रि का चित्र',
  );
  static const completionNavratriNavamiHavan = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_navratri_navami_havan_blessing_v1.webp',
    semanticLabel: 'हवनकुंड के साथ माँ सिद्धिदात्री का चित्र',
  );
  static const completionVijayadashami = DevotionalArtwork(
    assetPath:
        'assets/images/devotional/completion_vijayadashami_blessing_v1.webp',
    semanticLabel: 'जवारों के साथ विजयी दुर्गा का चित्र',
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

  static const navratriParv = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_parv_v1.webp',
    semanticLabel: 'नवरात्रि कलश, जौ और अखंड ज्योति का सजावटी चित्र',
  );

  static const navratriShailaputri = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_1_shailaputri_v1.webp',
    semanticLabel: 'माँ शैलपुत्री का सजावटी चित्र',
  );
  static const navratriBrahmacharini = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_2_brahmacharini_v1.webp',
    semanticLabel: 'माँ ब्रह्मचारिणी का सजावटी चित्र',
  );
  static const navratriChandraghanta = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_3_chandraghanta_v1.webp',
    semanticLabel: 'माँ चंद्रघंटा का सजावटी चित्र',
  );
  static const navratriKushmanda = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_4_kushmanda_v1.webp',
    semanticLabel: 'माँ कूष्मांडा का सजावटी चित्र',
  );
  static const navratriSkandamata = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_5_skandamata_v1.webp',
    semanticLabel: 'माँ स्कंदमाता का सजावटी चित्र',
  );
  static const navratriKatyayani = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_6_katyayani_v1.webp',
    semanticLabel: 'माँ कात्यायनी का सजावटी चित्र',
  );
  static const navratriKalaratri = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_7_kalaratri_v1.webp',
    semanticLabel: 'माँ कालरात्रि का सजावटी चित्र',
  );
  static const navratriMahagauri = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_8_mahagauri_v1.webp',
    semanticLabel: 'माँ महागौरी का सजावटी चित्र',
  );
  static const navratriSiddhidatri = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_din_9_siddhidatri_v1.webp',
    semanticLabel: 'माँ सिद्धिदात्री का सजावटी चित्र',
  );
  static const navratriHavan = DevotionalArtwork(
    assetPath: 'assets/images/devotional/navratri_havan_v1.webp',
    semanticLabel: 'नवमी हवन का सजावटी चित्र',
  );
  static const vijayadashami = DevotionalArtwork(
    assetPath: 'assets/images/devotional/vijayadashami_v1.webp',
    semanticLabel: 'विजयादशमी के जवारों का सजावटी चित्र',
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
    'vishwakarma_pooja': DevotionalArtwork(
      assetPath: 'assets/images/devotional/vishwakarma_pooja_v1.webp',
      semanticLabel: 'विश्वकर्मा पूजा और शिल्प-औज़ारों का सजावटी चित्र',
    ),
    'navratri_sankshipt': navratriParv,
    'navratri_din_2': navratriBrahmacharini,
    'navratri_din_3': navratriChandraghanta,
    'navratri_din_4': navratriKushmanda,
    'navratri_din_5': navratriSkandamata,
    'navratri_din_6': navratriKatyayani,
    'navratri_din_7': navratriKalaratri,
    'navratri_navami_havan': navratriHavan,
    'vijayadashami': vijayadashami,
  };

  static DevotionalArtwork forVidhiId(String id) => _byVidhiId[id] ?? diya;

  /// पूजा पूरी होने पर उसी आराध्य का आशीर्वाद-दर्शन।
  ///
  /// जिस विधि का अलग, जाँचा हुआ चित्र अभी नहीं बना है वहाँ neutral दीपक
  /// ही रखा जाता है; केवल नाम देखकर देवता का अनुमान नहीं लगाया जाता।
  static const Map<String, DevotionalArtwork> _completionByVidhiId = {
    'ganesh_poojan': completionGanesha,
    'hanuman_pooja': completionHanuman,
    'rudrabhishek': completionShiva,
    'satyanarayan': completionSatyanarayan,
    'saraswati_pooja': completionSaraswati,
    'ram_pooja': completionRam,
    'krishna_pooja': completionKrishna,
    'surya_arghya': completionSurya,
    'durga_ashtami_kanya_poojan': completionDurga,
    'vishwakarma_pooja': completionVishwakarma,
    'varalakshmi_vrat': completionLakshmi,
    'dhanteras': completionDhanvantari,
    'upanayan': completionGayatri,
    'tulsi_pooja': completionTulsiDevi,
    'hartalika_teej': completionHartalikaTeej,
    'karwa_chauth': completionKarwaChauth,
    'govardhan_annakut': completionGovardhanAnnakut,
    'makar_sankranti_pooja': completionMakarSankranti,
    'chhath_pooja': completionChhath,
    'vat_savitri': completionVatSavitri,
    'kalash_sthapana': completionKalashSthapana,
    'lakshmi_poojan': completionLakshmiPoojan,
    'nitya_pooja': completionNityaPooja,
    'grih_pravesh': completionGrihPravesh,
    'mundan': completionMundan,
    'vahan_pooja': completionVahanPooja,
    'shraadh': completionShraadh,
    'bhai_dooj_pooja': completionBhaiDooj,
    'raksha_bandhan_pooja': completionRakshaBandhan,
    'navratri_sankshipt': completionNavratriSankshipt,
    'navratri_din_2': completionNavratriBrahmacharini,
    'navratri_din_3': completionNavratriChandraghanta,
    'navratri_din_4': completionNavratriKushmanda,
    'navratri_din_5': completionNavratriSkandamata,
    'navratri_din_6': completionNavratriKatyayani,
    'navratri_din_7': completionNavratriKalaratri,
    'navratri_navami_havan': completionNavratriNavamiHavan,
    'vijayadashami': completionVijayadashami,
  };

  static DevotionalArtwork completionForVidhiId(String id) =>
      _completionByVidhiId[id] ?? completion;
}
