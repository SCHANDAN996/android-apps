import 'devotional_assets.dart';

/// Frontend-only catalogue entries for Puja guides that are still planned.
///
/// These entries deliberately do not live in `assets/vidhi/_suchi.json`:
/// that file is the authoritative, openable content catalogue. Keeping this
/// list separate prevents a name and artwork from being mistaken for a
/// verified ritual or mantra.
class PlannedPujaEntry {
  final String id;
  final String name;
  final DevotionalArtwork artwork;

  const PlannedPujaEntry({
    required this.id,
    required this.name,
    required this.artwork,
  });
}

class PlannedPujaSection {
  final String title;
  final String supportingText;
  final List<PlannedPujaEntry> entries;

  const PlannedPujaSection({
    required this.title,
    required this.supportingText,
    required this.entries,
  });
}

/// The display order follows `docs/14_PUJA_LIBRARY_EXPANSION_PLAN.md`.
/// No ritual content, authority claim or completion route is attached.
const plannedPujaSections = <PlannedPujaSection>[
  PlannedPujaSection(
    title: 'त्योहार संग्रह',
    supportingText: 'पर्व के अनुसार व्यवस्थित आने वाली पूजा और मार्गदर्शिकाएँ',
    entries: [
      PlannedPujaEntry(
        id: 'dhanteras_pooja',
        name: 'धनतेरस पूजा',
        artwork: DevotionalAssets.lakshmi,
      ),
      PlannedPujaEntry(
        id: 'govardhan_annakut',
        name: 'गोवर्धन पूजा / अन्नकूट',
        artwork: DevotionalAssets.krishna,
      ),
      PlannedPujaEntry(
        id: 'bhai_dooj_pooja',
        name: 'भाई दूज पूजा',
        artwork: DevotionalAssets.nityaPooja,
      ),
      PlannedPujaEntry(
        id: 'raksha_bandhan_pooja',
        name: 'रक्षाबंधन पूजा',
        artwork: DevotionalAssets.nityaPooja,
      ),
      PlannedPujaEntry(
        id: 'makar_sankranti_pooja',
        name: 'मकर संक्रांति पूजा',
        artwork: DevotionalAssets.suryaArghya,
      ),
      PlannedPujaEntry(
        id: 'vasant_panchami_collection',
        name: 'वसंत पंचमी',
        artwork: DevotionalAssets.saraswati,
      ),
      PlannedPujaEntry(
        id: 'ram_navami_collection',
        name: 'राम नवमी',
        artwork: DevotionalAssets.ram,
      ),
      PlannedPujaEntry(
        id: 'janmashtami_collection',
        name: 'जन्माष्टमी',
        artwork: DevotionalAssets.krishna,
      ),
    ],
  ),
  PlannedPujaSection(
    title: 'व्रत और क्षेत्रीय परंपराएँ',
    supportingText: 'क्षेत्र और परिवार के अनुसार बदलने वाली मार्गदर्शिकाएँ',
    entries: [
      PlannedPujaEntry(
        id: 'hartalika_teej',
        name: 'हरितालिका तीज',
        artwork: DevotionalAssets.shiva,
      ),
      PlannedPujaEntry(
        id: 'vat_savitri',
        name: 'वट सावित्री',
        artwork: DevotionalAssets.tulsi,
      ),
      PlannedPujaEntry(
        id: 'chhath_pooja',
        name: 'छठ पूजा',
        artwork: DevotionalAssets.suryaArghya,
      ),
      PlannedPujaEntry(
        id: 'varalakshmi_vrat',
        name: 'वरलक्ष्मी व्रत',
        artwork: DevotionalAssets.lakshmi,
      ),
      PlannedPujaEntry(
        id: 'karwa_chauth_expanded',
        name: 'करवा चौथ विस्तृत मार्गदर्शिका',
        artwork: DevotionalAssets.karwaChauth,
      ),
      PlannedPujaEntry(
        id: 'durga_ashtami_kanya_poojan',
        name: 'दुर्गा अष्टमी / कन्या पूजन',
        artwork: DevotionalAssets.kalash,
      ),
    ],
  ),
  PlannedPujaSection(
    title: 'विशेषज्ञ सहायता वाली विधियाँ',
    supportingText:
        'इनकी मुख्य विधि पंडित, आचार्य या प्रशिक्षित विशेषज्ञ के साथ',
    entries: [
      PlannedPujaEntry(
        id: 'purna_havan',
        name: 'पूर्ण हवन',
        artwork: DevotionalAssets.diya,
      ),
      PlannedPujaEntry(
        id: 'purna_rudrabhishek',
        name: 'पूर्ण रुद्राभिषेक',
        artwork: DevotionalAssets.rudrabhishek,
      ),
      PlannedPujaEntry(
        id: 'vivah_sanskar',
        name: 'विवाह संस्कार',
        artwork: DevotionalAssets.kalash,
      ),
      PlannedPujaEntry(
        id: 'havan_grih_pravesh',
        name: 'हवनयुक्त गृह प्रवेश',
        artwork: DevotionalAssets.grihPravesh,
      ),
    ],
  ),
];

int get plannedPujaCount => plannedPujaSections.fold(
      0,
      (total, section) => total + section.entries.length,
    );
