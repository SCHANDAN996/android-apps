/// फ़सल का चित्र, emoji और श्रेणी — एक ही जगह।
///
/// पहले यह जानकारी `khaad_screen.dart` के बीच में एक लंबे `switch` में पड़ी थी।
/// नए फ़सल-चुनने वाले पन्ने को भी यही चाहिए, इसलिए यहाँ ले आए — दो जगह एक ही
/// सूची रखने से एक दिन दोनों अलग हो जातीं।
library;

import 'crops.dart';

/// फ़सल की श्रेणी — चुनने वाले पन्ने की चिप्पियाँ इसी से बनती हैं।
enum CropGroup { anaj, dalhan, tilhan, sabzi, nakdi }

extension CropGroupLabel on CropGroup {
  String label(bool isHi) => switch (this) {
        CropGroup.anaj => isHi ? 'अनाज' : 'Cereals',
        CropGroup.dalhan => isHi ? 'दलहन' : 'Pulses',
        CropGroup.tilhan => isHi ? 'तिलहन' : 'Oilseeds',
        CropGroup.sabzi => isHi ? 'सब्ज़ी' : 'Vegetables',
        CropGroup.nakdi => isHi ? 'नक़दी' : 'Cash crops',
      };
}

const Map<String, CropGroup> _groups = {
  // अनाज
  'wheat': CropGroup.anaj, 'paddy': CropGroup.anaj, 'maize': CropGroup.anaj,
  'barley': CropGroup.anaj, 'bajra': CropGroup.anaj, 'jowar': CropGroup.anaj,
  'ragi': CropGroup.anaj,
  // दलहन
  'gram': CropGroup.dalhan, 'lentil': CropGroup.dalhan, 'moong': CropGroup.dalhan,
  'urad': CropGroup.dalhan, 'pigeonpea': CropGroup.dalhan,
  // तिलहन
  'mustard': CropGroup.tilhan, 'groundnut': CropGroup.tilhan,
  'sesame': CropGroup.tilhan, 'soybean': CropGroup.tilhan,
  // सब्ज़ी
  'potato': CropGroup.sabzi, 'tomato': CropGroup.sabzi, 'onion': CropGroup.sabzi,
  'chilli': CropGroup.sabzi, 'cabbage': CropGroup.sabzi, 'brinjal': CropGroup.sabzi,
  'okra': CropGroup.sabzi,
  // नक़दी / बाग़ानी / मसाला
  'sugarcane': CropGroup.nakdi, 'cotton': CropGroup.nakdi, 'banana': CropGroup.nakdi,
  'turmeric': CropGroup.nakdi, 'ginger': CropGroup.nakdi, 'coconut': CropGroup.nakdi,
  'blackpepper': CropGroup.nakdi,
};

const Map<String, String> _emojis = {
  'wheat': '🌾', 'paddy': '🌾', 'maize': '🌽', 'mustard': '🌻', 'potato': '🥔',
  'gram': '🫘', 'lentil': '🫘', 'pigeonpea': '🫛', 'sugarcane': '🎋',
  'bajra': '🌾', 'jowar': '🌾', 'groundnut': '🥜', 'soybean': '🫘',
  'onion': '🧅', 'tomato': '🍅', 'ragi': '🌾', 'barley': '🌾', 'moong': '🫛',
  'urad': '🫘', 'sesame': '🌱', 'cotton': '☁️', 'turmeric': '🫚', 'ginger': '🫚',
  'chilli': '🌶️', 'cabbage': '🥬', 'brinjal': '🍆', 'okra': '🫛', 'banana': '🍌',
  'coconut': '🥥', 'blackpepper': '⚫',
};

/// जिन फ़सलों का अपना चित्र फ़ोल्डर में है।
const Set<String> _withImage = {
  'wheat', 'barley', 'bajra', 'jowar', 'ragi', 'paddy', 'maize', 'sugarcane',
  'mustard', 'sesame', 'potato', 'tomato', 'onion', 'groundnut', 'banana',
  'chilli', 'turmeric', 'cotton', 'gram', 'lentil', 'moong', 'urad',
  'pigeonpea', 'soybean', 'ginger', 'cabbage', 'brinjal', 'okra', 'coconut',
  'blackpepper',
};

/// फ़सल का चित्र — न हो तो `null` (तब emoji दिखाइए, कोई और फ़सल का चित्र नहीं)।
String? cropImage(String id) =>
    _withImage.contains(id) ? 'assets/images/3d_crop_$id.webp' : null;

String cropEmoji(String id) => _emojis[id] ?? '🌾';

CropGroup cropGroup(String id) => _groups[id] ?? CropGroup.anaj;

/// खोज — हिंदी नाम, अंग्रेज़ी नाम और id, तीनों से।
///
/// "gehu" लिखने पर भी गेहूं मिलना चाहिए, इसलिए कुछ आम रोमन वर्तनी भी जोड़ी हैं।
const Map<String, String> _romanAliases = {
  'wheat': 'gehu gehun kanak',
  'paddy': 'dhan chawal rice basmati',
  'maize': 'makka makai corn bhutta',
  'mustard': 'sarso sarson rai raya',
  'potato': 'aloo alu batata',
  'gram': 'chana channa chola bengal',
  'lentil': 'masoor masur',
  'pigeonpea': 'arhar tur toor rahar',
  'sugarcane': 'ganna ikh us',
  'bajra': 'bajra bajri pearl millet',
  'jowar': 'jowar juar sorghum cholam',
  'groundnut': 'mungfali moongfali peanut singdana',
  'soybean': 'soyabean soya bhat',
  'onion': 'pyaz pyaaz kanda',
  'tomato': 'tamatar tamater',
  'ragi': 'ragi mandua nachni finger millet',
  'barley': 'jau jaun',
  'moong': 'moong mung green gram',
  'urad': 'urad urd black gram mash',
  'sesame': 'til tili gingelly',
  'cotton': 'kapas rui narma',
  'turmeric': 'haldi haldee',
  'ginger': 'adrak adarak',
  'chilli': 'mirch mirchi lal',
  'cabbage': 'patta gobhi gobi band',
  'brinjal': 'baingan began eggplant',
  'okra': 'bhindi bhendi ladyfinger',
  'banana': 'kela kela',
  'coconut': 'nariyal narial',
  'blackpepper': 'kali mirch kalimirch',
};

/// खोज से मेल खाती है या नहीं।
bool cropMatches(Crop c, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return c.hi.toLowerCase().contains(q) ||
      c.en.toLowerCase().contains(q) ||
      c.id.contains(q) ||
      (_romanAliases[c.id] ?? '').contains(q);
}
