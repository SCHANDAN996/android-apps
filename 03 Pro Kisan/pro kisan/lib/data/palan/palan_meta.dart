/// पालन का चित्र, श्रेणी और खोज — एक जगह।
///
/// पहले चित्रों का `switch` तीन जगह अलग-अलग पड़ा था (grid, detail screen,
/// species picker)। एक दिन तीनों अलग हो जाते, इसलिए यहाँ ले आए।
library;

import 'palan_model.dart';

/// चुनने वाले पन्ने की चिप्पियाँ इसी से बनती हैं
enum PalanGroup { pashu, pakshi, anya }

extension PalanGroupLabel on PalanGroup {
  String label(bool isHi) => switch (this) {
        PalanGroup.pashu => isHi ? 'पशु' : 'Animals',
        PalanGroup.pakshi => isHi ? 'पक्षी' : 'Birds',
        PalanGroup.anya => isHi ? 'अन्य' : 'Others',
      };
}

const Map<String, PalanGroup> _groups = {
  'gaay': PalanGroup.pashu,
  'bhains': PalanGroup.pashu,
  'bakri': PalanGroup.pashu,
  'sheep': PalanGroup.pashu,
  'pig': PalanGroup.pashu,
  'rabbit': PalanGroup.pashu,
  'layer': PalanGroup.pakshi,
  'broiler': PalanGroup.pakshi,
  'kadaknath': PalanGroup.pakshi,
  'duck': PalanGroup.pakshi,
  'quail': PalanGroup.pakshi,
  'turkey': PalanGroup.pakshi,
  'emu': PalanGroup.pakshi,
  'fish': PalanGroup.anya,
  'bee': PalanGroup.anya,
};

const Map<String, String> _images = {
  'gaay': 'assets/images/3d_cow_profile.webp',
  'bhains': 'assets/images/3d_buffalo_profile.webp',
  'bakri': 'assets/images/3d_goat.webp',
  'sheep': 'assets/images/3d_sheep.webp',
  'layer': 'assets/images/3d_egg.webp',
  'broiler': 'assets/images/3d_broiler.webp',
  'kadaknath': 'assets/images/3d_kadaknath.webp',
  'quail': 'assets/images/3d_quail.webp',
  'duck': 'assets/images/3d_duck.webp',
  'turkey': 'assets/images/3d_turkey.webp',
  'emu': 'assets/images/3d_emu.webp',
  'pig': 'assets/images/3d_pig.webp',
  'rabbit': 'assets/images/3d_rabbit.webp',
  'bee': 'assets/images/3d_beekeeping.webp',
  'fish': 'assets/images/3d_fish.webp',
};

PalanGroup palanGroup(String id) => _groups[id] ?? PalanGroup.anya;

/// चित्र — न मिले तो `null` (तब emoji दिखाइए)
String? palanImage(String id) => _images[id];

/// रोमन में लिखने पर भी मिले — "bakri", "murgi", "machhli"
const Map<String, String> _aliases = {
  'gaay': 'gaay gay gai cow cattle dudh milk dairy sahiwal gir desi',
  'bhains': 'bhains bhaisn buffalo murrah bhens dudh milk dairy',
  'bakri': 'bakri bakari goat chevre chhagal',
  'layer': 'layer murgi anda egg poultry andaa',
  'broiler': 'broiler murgi chicken meat poultry',
  'kadaknath': 'kadaknath kali murgi black chicken',
  'duck': 'duck batakh batak',
  'pig': 'pig suar sooar shukar piggery',
  'sheep': 'sheep bhed bher bhedh wool oon',
  'quail': 'quail bater batair',
  'rabbit': 'rabbit khargosh kharagosh',
  'fish': 'fish machhli machli matsya pond talab',
  'bee': 'bee madhumakkhi shahad honey madhu',
  'turkey': 'turkey tarki',
  'emu': 'emu imu',
};

/// खोज — हिंदी नाम, अंग्रेज़ी नाम, tagline और रोमन वर्तनी, सबसे
bool palanMatches(PalanGuide g, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return g.name.hi.toLowerCase().contains(q) ||
      g.name.en.toLowerCase().contains(q) ||
      g.tagline.hi.toLowerCase().contains(q) ||
      g.id.contains(q) ||
      (_aliases[g.id] ?? '').contains(q);
}
