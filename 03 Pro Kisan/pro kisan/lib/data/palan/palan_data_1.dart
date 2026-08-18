import 'package:flutter/material.dart';
import 'palan_model.dart';

/// पालन गाइड — भाग 1: बकरी, लेयर मुर्गी, ब्रॉयलर, कड़कनाथ, बत्तख, सुअर, भेड़
///
/// ⚠️ सारे दाम/आँकड़े **अनुमानित** हैं — इलाक़े, नस्ल और बाज़ार से बदलते हैं।
/// बीमारी दिखे तो पशु-चिकित्सक ही अंतिम सलाह देगा।
const List<PalanGuide> kPalanPart1 = [
  // ─────────────────────────── 1. बकरी ───────────────────────────
  PalanGuide(
    id: 'bakri',
    emoji: '🐐',
    name: (hi: 'बकरी पालन', en: 'Goat Farming'),
    tagline: (hi: 'कम लागत, कम जगह — "गरीब की गाय"', en: 'Low cost, small space — the poor man\'s cow'),
    color: Color(0xFF8D6E63),
    intro: (
      hi: 'बकरी पालन छोटे किसान के लिए सबसे सुरक्षित धंधा है — कम जगह, कम पूँजी और साल भर माँग। मांस (मटन) की क़ीमत कभी ज़्यादा नहीं गिरती, और त्योहारों पर दाम बढ़ जाते हैं। एक बकरी साल में 1.5 बार तक बच्चे देती है, अक्सर 2 बच्चे।',
      en: 'Goat farming is the safest small-farmer business — little land, low capital and year-round demand. Mutton prices rarely fall and rise during festivals. A doe kids up to 1.5 times a year, often twins.',
    ),
    breeds: [
      (hi: 'बरबरी — छोटी, कम चारे में पलती, मांस के लिए बढ़िया, शहर के पास पालने लायक़', en: 'Barbari — small, thrives on little feed, good for meat, suits peri-urban units'),
      (hi: 'सिरोही (राजस्थान) — मज़बूत, बीमारी कम, तेज़ी से वज़न बढ़ता है', en: 'Sirohi (Rajasthan) — hardy, fewer diseases, fast weight gain'),
      (hi: 'जमुनापारी — सबसे बड़ी देसी नस्ल, दूध + मांस दोनों', en: 'Jamunapari — largest Indian breed, both milk and meat'),
      (hi: 'ब्लैक बंगाल — पूर्वी भारत, बहुत स्वादिष्ट मांस, खाल की अलग क़ीमत', en: 'Black Bengal — eastern India, tasty meat, skin fetches extra'),
      (hi: 'उस्मानाबादी — महाराष्ट्र, जुड़वाँ बच्चे देने में आगे', en: 'Osmanabadi — Maharashtra, high twinning rate'),
    ],
    housing: [
      (hi: 'ज़मीन से 1-1.5 फुट ऊँचा लकड़ी/बाँस का फ़र्श — मल-मूत्र नीचे गिरे, खुर सड़ते नहीं', en: 'Raised wooden/bamboo floor 1–1.5 ft above ground so dung falls through and hooves stay dry'),
      (hi: 'जगह: बड़ी बकरी 10-12 वर्ग फुट, बच्चा 4-5 वर्ग फुट', en: 'Space: adult 10–12 sq ft, kid 4–5 sq ft'),
      (hi: 'तीन तरफ़ दीवार, एक तरफ़ जाली — हवा चले पर सीधी ठंडी हवा न लगे', en: 'Three walls plus one mesh side — airflow without cold draughts'),
      (hi: 'नर (बकरा) को अलग बाड़े में रखें, वरना दूध/मांस में गंध आती है', en: 'Keep the buck separately, else milk and meat pick up odour'),
    ],
    feed: [
      (stage: (hi: 'बच्चा (0-3 माह)', en: 'Kid (0–3 m)'), feed: (hi: 'माँ का दूध + नरम पत्ती, थोड़ा दाना', en: 'Mother\'s milk + tender leaves, little concentrate'), qty: (hi: 'दाना 50-100 ग्राम/दिन', en: 'Concentrate 50–100 g/day')),
      (stage: (hi: 'बढ़ती बकरी (3-9 माह)', en: 'Grower (3–9 m)'), feed: (hi: 'हरा चारा (बरसीम, नेपियर, पत्तियाँ) + दाना', en: 'Green fodder (berseem, napier, leaves) + concentrate'), qty: (hi: 'हरा 2-3 किग्रा + दाना 200 ग्राम', en: 'Green 2–3 kg + concentrate 200 g')),
      (stage: (hi: 'बड़ी बकरी', en: 'Adult doe'), feed: (hi: 'हरा + सूखा चारा + दाना मिश्रण', en: 'Green + dry fodder + concentrate mix'), qty: (hi: 'हरा 4-5 किग्रा + दाना 300-400 ग्राम', en: 'Green 4–5 kg + concentrate 300–400 g')),
      (stage: (hi: 'गाभिन/दूध वाली', en: 'Pregnant / milking'), feed: (hi: 'ऊपर वाला + कैल्शियम-खनिज मिश्रण', en: 'As above + calcium-mineral mixture'), qty: (hi: 'दाना 500 ग्राम + खनिज 10 ग्राम', en: 'Concentrate 500 g + mineral 10 g')),
    ],
    feedNotes: [
      (hi: 'दिन में 2 बार चारा — सुबह और शाम। साफ़ पानी हमेशा सामने रखें।', en: 'Feed twice daily, morning and evening. Keep clean water always available.'),
      (hi: 'दाना मिश्रण: मक्का 40% + खली 30% + चोकर 25% + खनिज-नमक 5%', en: 'Concentrate mix: maize 40% + oil cake 30% + bran 25% + mineral-salt 5%'),
      (hi: 'बारिश में गीला चारा न दें — पेट फूलने (अफारा) से मौत हो सकती है।', en: 'Avoid wet fodder in rains — bloat can kill.'),
    ],
    production: [
      (hi: 'अच्छी नस्ल का बकरा रखें या किराए पर लें — बच्चों की गुणवत्ता 50% उसी से तय होती है', en: 'Use a good-breed buck (own or rented) — half the kid quality comes from him'),
      (hi: 'बकरी को 10-12 माह की उम्र या 25 किग्रा वज़न पर ही गाभिन कराएँ, जल्दी नहीं', en: 'Breed does at 10–12 months or 25 kg — not earlier'),
      (hi: 'हर 3 माह पर पेट के कीड़े की दवा — इसके बिना खाया चारा बेकार जाता है', en: 'Deworm every 3 months — without it feed is wasted'),
      (hi: 'बकरे को 8-9 माह/30-35 किग्रा पर बेचें — उसके बाद चारा ज़्यादा, बढ़त कम', en: 'Sell bucks at 8–9 months / 30–35 kg — later feed cost outruns growth'),
      (hi: 'ईद/नवरात्रि-दशहरा से 2-3 माह पहले वज़न बढ़ाने पर ध्यान दें — दाम सबसे ऊँचे', en: 'Push weight gain 2–3 months before Eid/Dussehra when prices peak'),
    ],
    vaccines: [
      (when: (hi: '3 माह की उम्र, फिर हर साल', en: '3 months, then yearly'), what: (hi: 'PPR (बकरी प्लेग) — सबसे ज़रूरी टीका', en: 'PPR (goat plague) — the most important vaccine')),
      (when: (hi: '4 माह, फिर हर साल (बरसात से पहले)', en: '4 months, then yearly before monsoon'), what: (hi: 'ET (आंत्र विषाक्तता / एंटेरोटॉक्सीमिया)', en: 'ET (enterotoxaemia)')),
      (when: (hi: 'हर साल (जहाँ बीमारी फैलती हो)', en: 'Yearly in endemic areas'), what: (hi: 'खुरपका-मुँहपका (FMD) व गलघोंटू (HS)', en: 'FMD and Haemorrhagic Septicaemia')),
    ],
    diseases: [
      (hi: 'PPR — तेज़ बुख़ार, नाक-आँख बहना, दस्त। तुरंत अलग करें और डॉक्टर बुलाएँ।', en: 'PPR — high fever, nasal/eye discharge, diarrhoea. Isolate and call the vet.'),
      (hi: 'अफारा (पेट फूलना) — बाईं कोख फूली, बेचैनी। गीला/अधिक हरा चारा इसकी वजह।', en: 'Bloat — swollen left flank, restlessness. Caused by wet or excess green fodder.'),
      (hi: 'खुजली/जुएँ — खाल पर पपड़ी, बाल झड़ना। बाड़े की सफ़ाई और दवा से ठीक।', en: 'Mange/lice — scabs and hair loss. Clean shed plus medication.'),
      (hi: 'निमोनिया — ठंडी हवा/नमी से। बच्चों में सबसे ज़्यादा जान जाती है।', en: 'Pneumonia — from cold draughts/damp; the biggest killer of kids.'),
    ],
    economicsUnit: (hi: '10 बकरी + 1 बकरा (साल भर)', en: '10 does + 1 buck (per year)'),
    costs: [
      (item: (hi: '10 बकरी + 1 बकरा ख़रीद', en: 'Buying 10 does + 1 buck'), value: '₹85,000', oneTime: true),
      (item: (hi: 'शेड (देसी, बाँस-टीन)', en: 'Shed (bamboo-tin)'), value: '₹25,000', oneTime: true),
      (item: (hi: 'चारा-दाना (साल भर)', en: 'Feed for the year'), value: '₹40,000', oneTime: false),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹5,000', oneTime: false),
    ],
    income: [
      (item: (hi: '15-18 बच्चे बिक्री (₹6,000 औसत)', en: '15–18 kids sold (avg ₹6,000)'), value: '₹1,00,000', oneTime: false),
      (item: (hi: 'खाद (मेंगनी) बिक्री', en: 'Manure sales'), value: '₹6,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'पहले साल शेड का ख़र्च एक ही बार लगता है, इसलिए दूसरे साल से मुनाफ़ा लगभग दुगना दिखता है। दाम इलाक़े और त्योहार पर निर्भर करते हैं।',
      en: 'Shed cost comes only once, so profit roughly doubles from the second year. Prices depend on region and festivals.',
    ),
    mistakes: [
      (hi: '❌ **बकरी को 6-8 माह में ही गाभिन करा देना** — शरीर बना नहीं होता, बच्चा कमज़ोर और बकरी ख़राब। 10-12 माह या 25 किग्रा से पहले कभी नहीं।', en: '❌ **Breeding does at 6-8 months** — the body is not ready; weak kids and a ruined doe. Never before 10-12 months or 25 kg.'),
      (hi: '❌ **बकरे को झुंड में ही रखना** — दूध और मांस में गंध आ जाती है, दाम गिर जाता है।', en: '❌ **Keeping the buck with the herd** — milk and meat pick up odour and fetch less.'),
    ],
    whereToBuy: [
      (hi: '🐐 बकरी के लिए CIRG मखदूम (मथुरा) — भारत का बकरी अनुसंधान संस्थान, शुद्ध सिरोही/जमुनापारी मिलती है।', en: '🐐 CIRG Makhdoom (Mathura) — India\'s goat research institute; pure Sirohi/Jamunapari available.'),
    ],
    selling: [
      (hi: 'स्थानीय बकरा मंडी — ईद-बकरीद, नवरात्रि-दशहरा पर सबसे ऊँचे दाम', en: 'Local goat market — best prices at Eid and Dussehra'),
      (hi: 'गाँव के क़साई/होटल से सीधा सौदा — बिचौलिया हटता है', en: 'Sell direct to local butchers/hotels — cuts the middleman'),
      (hi: 'ज़िंदा वज़न (live weight) पर बेचें, आँख के अंदाज़े से नहीं', en: 'Sell on live weight, not by eye estimate'),
      (hi: 'बकरी का दूध — जहाँ माँग है वहाँ ₹60-80/लीटर तक मिलता है', en: 'Goat milk fetches ₹60–80/litre where there is demand'),
    ],
    reminderPlan: [
      (day: 90, what: (hi: 'PPR (बकरी प्लेग) का टीका', en: 'PPR (goat plague) vaccine')),
      (day: 120, what: (hi: 'ET (आंत्र विषाक्तता) का टीका', en: 'ET (enterotoxaemia) vaccine')),
      (day: 150, what: (hi: 'खुरपका-मुँहपका (FMD) का टीका', en: 'FMD vaccine')),
      (day: 180, what: (hi: 'पेट के कीड़े की दवा', en: 'Deworming')),
      (day: 270, what: (hi: 'कीड़े की दवा (हर 3 माह)', en: 'Deworming (every 3 months)')),
      (day: 455, what: (hi: 'PPR बूस्टर (सालाना)', en: 'PPR booster (yearly)')),
    ],
  ),

  // ────────────────────── 2. लेयर मुर्गी (अंडा) ──────────────────────
  PalanGuide(
    id: 'layer',
    emoji: '🥚',
    name: (hi: 'लेयर मुर्गी (अंडा)', en: 'Layer Poultry (Eggs)'),
    tagline: (hi: 'रोज़ की कमाई — हर दिन अंडा, हर दिन पैसा', en: 'Daily income — eggs every day'),
    color: Color(0xFFEF6C00),
    intro: (
      hi: 'लेयर मुर्गी सिर्फ़ अंडे के लिए पाली जाती है। एक अच्छी मुर्गी 72 हफ़्ते में लगभग 300-330 अंडे देती है। सबसे बड़ा फ़ायदा — रोज़ नक़द आमदनी। सबसे बड़ी बात — दाना समय पर और रोशनी का पूरा ध्यान।',
      en: 'Layers are kept purely for eggs — a good hen lays about 300–330 eggs in 72 weeks. The big advantage is daily cash. Success depends on punctual feeding and correct lighting.',
    ),
    breeds: [
      (hi: 'BV-300 / Bovans — सबसे प्रचलित, 320+ अंडे', en: 'BV-300 / Bovans — most common, 320+ eggs'),
      (hi: 'Lohmann Brown — भूरे अंडे, ऊँचा दाम', en: 'Lohmann Brown — brown eggs, premium price'),
      (hi: 'White Leghorn — कम दाना, सफ़ेद अंडे', en: 'White Leghorn — less feed, white eggs'),
      (hi: 'गिरिराजा / वनराजा — देसी जैसी, गाँव में खुले में पालने लायक़', en: 'Giriraja / Vanaraja — dual-purpose, good for free-range villages'),
    ],
    housing: [
      (hi: 'पिंजरा (केज) प्रणाली: प्रति मुर्गी 450-500 वर्ग सेमी — अंडे साफ़ रहते हैं', en: 'Cage system: 450–500 sq cm per bird — cleaner eggs'),
      (hi: 'डीप लिटर: प्रति मुर्गी 1.5-2 वर्ग फुट + 2 इंच भूसी का बिछावन', en: 'Deep litter: 1.5–2 sq ft per bird with 2-inch husk bedding'),
      (hi: 'शेड की लंबाई पूर्व-पश्चिम — दोपहर की सीधी धूप अंदर न आए', en: 'Orient shed east–west so midday sun stays out'),
      (hi: 'रोशनी: कुल 16 घंटा (दिन + बल्ब) — इसी से अंडे की संख्या बनती है', en: 'Light: 16 hours total (day + bulb) — this drives egg numbers'),
    ],
    feed: [
      (stage: (hi: 'चूज़ा (0-8 हफ़्ते)', en: 'Chick (0–8 wk)'), feed: (hi: 'चिक स्टार्टर (20% प्रोटीन)', en: 'Chick starter (20% protein)'), qty: (hi: '35-40 ग्राम/दिन', en: '35–40 g/day')),
      (stage: (hi: 'ग्रोअर (9-18 हफ़्ते)', en: 'Grower (9–18 wk)'), feed: (hi: 'ग्रोअर दाना (16% प्रोटीन)', en: 'Grower feed (16% protein)'), qty: (hi: '60-75 ग्राम/दिन', en: '60–75 g/day')),
      (stage: (hi: 'लेयर (19+ हफ़्ते)', en: 'Layer (19+ wk)'), feed: (hi: 'लेयर दाना + कैल्शियम (सीप चूर्ण)', en: 'Layer feed + calcium (shell grit)'), qty: (hi: '110-120 ग्राम/दिन', en: '110–120 g/day')),
    ],
    feedNotes: [
      (hi: 'कैल्शियम कम हुआ तो अंडे का छिलका पतला — सीप का चूर्ण अलग कटोरी में रखें।', en: 'Low calcium means thin shells — offer shell grit in a separate bowl.'),
      (hi: 'गर्मी में दाना सुबह जल्दी और शाम को दें, दोपहर में मुर्गी कम खाती है।', en: 'In summer feed early morning and evening; birds eat little at noon.'),
      (hi: 'पानी कभी ख़त्म न हो — 2 घंटे प्यास से अंडा उत्पादन गिर जाता है।', en: 'Never let water run out — two hours of thirst drops production.'),
    ],
    production: [
      (hi: 'रोशनी घटाएँ नहीं — 16 घंटे नियम से; बल्ब बंद-चालू का समय एक जैसा रखें', en: 'Never cut light hours — keep the 16-hour schedule at fixed times'),
      (hi: 'अंडे दिन में 2-3 बार उठाएँ — टूटन और गंदगी कम होगी', en: 'Collect eggs 2–3 times a day — less breakage and soiling'),
      (hi: 'गर्मी में शेड की छत पर घास/सफ़ेदी और पानी का छिड़काव — गर्मी से उत्पादन गिरता है', en: 'Cool the roof (thatch/whitewash/sprinkler) — heat cuts production'),
      (hi: '72 हफ़्ते बाद झुंड बदल दें — उसके बाद दाना ज़्यादा, अंडे कम', en: 'Replace the flock after 72 weeks — feed rises, eggs fall'),
      (hi: 'बीमार मुर्गी तुरंत अलग — एक से पूरा शेड बिगड़ता है', en: 'Isolate sick birds at once — one bird can infect the shed'),
    ],
    vaccines: [
      (when: (hi: 'पहला दिन', en: 'Day 1'), what: (hi: 'मरेक्स (हैचरी में)', en: 'Marek\'s (at hatchery)')),
      (when: (hi: '5-7 दिन, फिर 4 व 8 हफ़्ते', en: 'Day 5–7, then 4 and 8 weeks'), what: (hi: 'रानीखेत (RD/लासोटा) — सबसे ज़रूरी', en: 'Ranikhet / Newcastle (Lasota) — most important')),
      (when: (hi: '14 व 28 दिन', en: 'Day 14 and 28'), what: (hi: 'गम्बोरो (IBD)', en: 'Gumboro (IBD)')),
      (when: (hi: '8 हफ़्ते', en: '8 weeks'), what: (hi: 'फाउल पॉक्स (चेचक)', en: 'Fowl pox')),
    ],
    diseases: [
      (hi: 'रानीखेत — गर्दन टेढ़ी, हरा दस्त, अचानक बहुत मौतें। टीका ही बचाव है।', en: 'Ranikhet — twisted neck, green droppings, sudden heavy mortality. Vaccination is the only defence.'),
      (hi: 'कॉक्सीडियोसिस — खून वाला दस्त, गीले बिछावन से। बिछावन सूखा रखें।', en: 'Coccidiosis — bloody droppings from wet litter. Keep litter dry.'),
      (hi: 'CRD (सर्दी-ज़ुकाम) — छींक, घरघराहट। भीड़ और अमोनिया की बदबू इसकी जड़।', en: 'CRD — sneezing and rales; caused by crowding and ammonia build-up.'),
    ],
    economicsUnit: (hi: '500 लेयर मुर्गी (एक चक्र, ~18 माह)', en: '500 layers (one cycle, ~18 months)'),
    costs: [
      (item: (hi: '500 चूज़े', en: '500 chicks'), value: '₹25,000', oneTime: false),
      (item: (hi: 'दाना (पूरा चक्र)', en: 'Feed for the cycle'), value: '₹3,60,000', oneTime: false),
      (item: (hi: 'शेड + पिंजरा (एक बार)', en: 'Shed + cages (one time)'), value: '₹1,50,000', oneTime: true),
      (item: (hi: 'दवा-टीका-बिजली', en: 'Medicine, vaccine, power'), value: '₹25,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~1,35,000 अंडे (₹5.5 औसत)', en: '~1,35,000 eggs at ₹5.5'), value: '₹7,42,000', oneTime: false),
      (item: (hi: 'पुरानी मुर्गी बिक्री', en: 'Spent hen sales'), value: '₹75,000', oneTime: false),
      (item: (hi: 'खाद', en: 'Manure'), value: '₹15,000', oneTime: false),
    ],
    cycleMonths: 18,
    economicsNote: (
      hi: 'दाना कुल ख़र्च का लगभग 70% है — इसलिए दाने का सही दाम और बर्बादी रोकना ही असली मुनाफ़ा है। शेड का ख़र्च एक बार का है।',
      en: 'Feed is about 70% of cost — buying feed well and avoiding wastage is where the profit is. Shed cost is one-time.',
    ),
    mistakes: [
      (hi: '❌ **रोशनी में कटौती** — 16 घंटे से कम रोशनी मिलते ही अंडे गिरने लगते हैं। बिजली जाए तो भी इंतज़ाम रखिए।', en: '❌ **Cutting light hours** — below 16 hours egg numbers drop at once. Keep a backup for power cuts.'),
      (hi: '❌ **कैल्शियम कम देना** — छिलका पतला होगा, अंडे टूटेंगे। सीप चूर्ण अलग से सामने रखिए।', en: '❌ **Too little calcium** — thin shells and breakage. Offer shell grit separately.'),
    ],
    whereToBuy: [
      (hi: '🥚 सरकारी हैचरी या मान्यता प्राप्त हैचरी से ही चूज़े लीजिए — टीका लगा हुआ, रोग-मुक्त।', en: '🥚 Buy chicks only from a government or certified hatchery — vaccinated and disease-free.'),
    ],
    selling: [
      (hi: 'रोज़ का अंडा — स्थानीय दुकान, ठेला, होटल से पक्का सौदा करें', en: 'Fix daily supply deals with local shops, carts and hotels'),
      (hi: 'NECC का दैनिक भाव देखकर दाम तय करें, कम में न दें', en: 'Price using the daily NECC rate — do not sell below it'),
      (hi: 'देसी/भूरे अंडे अलग बेचें — ₹1-2 ज़्यादा मिलता है', en: 'Sell brown/desi eggs separately for ₹1–2 more'),
      (hi: 'सर्दी में माँग और दाम दोनों बढ़ते हैं — झुंड की उम्र उसी हिसाब से रखें', en: 'Winter brings higher demand and price — time your flock accordingly'),
    ],
    reminderPlan: [
      (day: 6, what: (hi: 'रानीखेत (लासोटा) — आँख/नाक में बूँद', en: 'Ranikhet (Lasota) eye/nasal drop')),
      (day: 14, what: (hi: 'गम्बोरो (IBD) पहली ख़ुराक', en: 'Gumboro (IBD) first dose')),
      (day: 28, what: (hi: 'गम्बोरो (IBD) दूसरी ख़ुराक', en: 'Gumboro (IBD) second dose')),
      (day: 35, what: (hi: 'रानीखेत बूस्टर', en: 'Ranikhet booster')),
      (day: 56, what: (hi: 'फाउल पॉक्स (चेचक)', en: 'Fowl pox')),
      (day: 112, what: (hi: 'रानीखेत (R2B) — अंडे से पहले', en: 'Ranikhet R2B before lay')),
    ],
  ),

  // ─────────────────────────── 3. ब्रॉयलर ───────────────────────────
  PalanGuide(
    id: 'broiler',
    emoji: '🍗',
    name: (hi: 'ब्रॉयलर मुर्गी (मांस)', en: 'Broiler Poultry (Meat)'),
    tagline: (hi: '40-45 दिन में तैयार — सबसे तेज़ चक्र', en: 'Ready in 40–45 days — the fastest cycle'),
    color: Color(0xFFD84315),
    intro: (
      hi: 'ब्रॉयलर सिर्फ़ मांस के लिए है — 40-45 दिन में 2-2.5 किग्रा तैयार। साल में 6 चक्र तक हो सकते हैं। पूँजी जल्दी लौटती है, पर दाम बाज़ार के साथ ऊपर-नीचे होता है, इसलिए बेचने का सौदा पहले तय करना समझदारी है।',
      en: 'Broilers are meat-only birds — 2–2.5 kg in 40–45 days, up to 6 cycles a year. Capital returns fast, but prices swing, so fix your buyer in advance.',
    ),
    breeds: [
      (hi: 'Cobb-400 — भारत में सबसे प्रचलित, तेज़ बढ़त', en: 'Cobb-400 — most used in India, fast growth'),
      (hi: 'Ross-308 — बढ़िया FCR (कम दाने में ज़्यादा वज़न)', en: 'Ross-308 — excellent FCR'),
      (hi: 'Vencobb — गर्मी सहने में बेहतर', en: 'Vencobb — better heat tolerance'),
      (hi: 'Hubbard — मज़बूत, बीमारी कम', en: 'Hubbard — hardy, fewer disease issues'),
    ],
    housing: [
      (hi: 'जगह: 1 वर्ग फुट प्रति चूज़ा (शुरू में), बड़े होने पर 1.5 वर्ग फुट', en: 'Space: 1 sq ft per chick, 1.5 sq ft as they grow'),
      (hi: 'ब्रूडिंग: पहले हफ़्ते 95°F, हर हफ़्ते 5°F कम — बल्ब/गैस ब्रूडर से', en: 'Brooding: 95°F week one, reduce 5°F weekly using bulbs/gas brooder'),
      (hi: 'बिछावन 3-4 इंच भूसी, गीला होते ही पलटें या बदलें', en: '3–4 inch husk litter; turn or replace as soon as it dampens'),
      (hi: 'शेड के परदे — सर्दी में बंद, गर्मी में खुले; अमोनिया की बदबू न बने', en: 'Side curtains: closed in winter, open in summer; avoid ammonia smell'),
    ],
    feed: [
      (stage: (hi: 'प्री-स्टार्टर (0-10 दिन)', en: 'Pre-starter (0–10 d)'), feed: (hi: 'क्रम्ब, 23% प्रोटीन', en: 'Crumbs, 23% protein'), qty: (hi: '~250 ग्राम कुल', en: '~250 g total')),
      (stage: (hi: 'स्टार्टर (11-24 दिन)', en: 'Starter (11–24 d)'), feed: (hi: '21-22% प्रोटीन', en: '21–22% protein'), qty: (hi: '~1.2 किग्रा कुल', en: '~1.2 kg total')),
      (stage: (hi: 'फ़िनिशर (25-42 दिन)', en: 'Finisher (25–42 d)'), feed: (hi: '19% प्रोटीन, ऊर्जा ज़्यादा', en: '19% protein, higher energy'), qty: (hi: '~2.5 किग्रा कुल', en: '~2.5 kg total')),
    ],
    feedNotes: [
      (hi: 'कुल दाना लगभग 3.5-4 किग्रा प्रति पक्षी — FCR 1.6-1.8 अच्छा माना जाता है।', en: 'About 3.5–4 kg feed per bird; FCR 1.6–1.8 is good.'),
      (hi: 'दाना कभी ख़त्म न हो — भूखा रहने पर वज़न की भरपाई नहीं होती।', en: 'Never let feeders run empty — lost growth is never recovered.'),
      (hi: 'बेचने से 8-10 घंटे पहले दाना बंद, पानी चालू रखें।', en: 'Stop feed 8–10 hours before sale but keep water on.'),
    ],
    production: [
      (hi: 'चूज़े अच्छी हैचरी से ही लें — कमज़ोर चूज़ा पूरा चक्र बिगाड़ देता है', en: 'Buy chicks only from a good hatchery — weak chicks ruin the cycle'),
      (hi: 'पहले 7 दिन सबसे अहम — गर्मी, रोशनी और साफ़ पानी में कोई कमी न हो', en: 'The first 7 days decide everything — heat, light and clean water'),
      (hi: 'हर हफ़्ते वज़न तोलें — बढ़त कम हो तो तुरंत कारण ढूँढ़ें', en: 'Weigh weekly — if growth lags, find the cause immediately'),
      (hi: 'एक शेड में एक ही उम्र के पक्षी (ऑल-इन ऑल-आउट) — बीमारी नहीं फैलती', en: 'All-in all-out with same-age birds — stops disease carry-over'),
      (hi: 'दो चक्रों के बीच 15 दिन शेड ख़ाली और चूना-सफ़ाई ज़रूरी', en: 'Keep the shed empty and limed for 15 days between cycles'),
    ],
    vaccines: [
      (when: (hi: '5-7 दिन', en: 'Day 5–7'), what: (hi: 'रानीखेत (लासोटा) — आँख/नाक में बूँद', en: 'Ranikhet (Lasota) — eye/nasal drop')),
      (when: (hi: '14 दिन', en: 'Day 14'), what: (hi: 'गम्बोरो (IBD)', en: 'Gumboro (IBD)')),
      (when: (hi: '21-24 दिन', en: 'Day 21–24'), what: (hi: 'रानीखेत बूस्टर', en: 'Ranikhet booster')),
    ],
    diseases: [
      (hi: 'गम्बोरो — सुस्ती, सफ़ेद दस्त, 3-4 हफ़्ते में। टीका समय पर ही बचाव।', en: 'Gumboro — lethargy and white droppings around 3–4 weeks; timely vaccination is the defence.'),
      (hi: 'कॉक्सीडियोसिस — खून वाला दस्त, गीले बिछावन से।', en: 'Coccidiosis — bloody droppings from wet litter.'),
      (hi: 'हीट स्ट्रोक — गर्मी में हाँफना, पंख फैलाना। पानी और हवा बढ़ाएँ।', en: 'Heat stress — panting and spread wings; increase water and airflow.'),
    ],
    economicsUnit: (hi: '1,000 ब्रॉयलर (एक चक्र, 45 दिन)', en: '1,000 broilers (one 45-day cycle)'),
    costs: [
      (item: (hi: '1,000 चूज़े (₹40)', en: '1,000 chicks at ₹40'), value: '₹40,000', oneTime: false),
      (item: (hi: 'दाना ~3,800 किग्रा', en: 'Feed ~3,800 kg'), value: '₹1,52,000', oneTime: false),
      (item: (hi: 'दवा-टीका-बिछावन-बिजली', en: 'Medicine, vaccine, litter, power'), value: '₹18,000', oneTime: false),
      (item: (hi: 'शेड (एक बार, 1000 पक्षी)', en: 'Shed (one time, 1000 birds)'), value: '₹2,00,000', oneTime: true),
    ],
    income: [
      (item: (hi: '~950 पक्षी × 2.2 किग्रा × ₹105/किग्रा', en: '~950 birds × 2.2 kg × ₹105/kg'), value: '₹2,19,000', oneTime: false),
    ],
    cycleMonths: 1.5,
    economicsNote: (
      hi: 'एक चक्र में लगभग ₹8-10 प्रति पक्षी बचता है — यानी 1000 पक्षी पर ₹8,000-10,000, साल में 6 चक्र। बाज़ार गिरे तो घाटा भी होता है, इसलिए contract farming (कंपनी के साथ) नए किसान के लिए सुरक्षित रहता है।',
      en: 'Roughly ₹8–10 profit per bird per cycle (₹8,000–10,000 per 1,000 birds), up to 6 cycles a year. Prices can fall, so contract farming is safer for beginners.',
    ),
    mistakes: [
      (hi: '❌ **बिना बाज़ार तय किए चूज़े डाल देना** — 45 दिन में पक्षी तैयार हो जाता है, उसके बाद हर दिन का दाना घाटा है।', en: '❌ **Placing chicks without a fixed buyer** — birds are ready in 45 days; every extra day of feed is a loss.'),
      (hi: '❌ **पहले हफ़्ते गर्मी (ब्रूडिंग) में लापरवाही** — सबसे ज़्यादा चूज़े यहीं मरते हैं। पहले दिन 32-35°C ज़रूरी।', en: '❌ **Careless brooding in week one** — most chick deaths happen here. Day one needs 32-35°C.'),
    ],
    whereToBuy: [
      (hi: '🐔 contract farming पर सोचिए — कंपनी चूज़ा, दाना और दवा देती है और तय दाम पर वापस लेती है। दाम गिरने का ख़तरा नहीं रहता।', en: '🐔 Consider contract farming — the company supplies chicks, feed and medicine and buys back at a fixed rate, removing price risk.'),
    ],
    selling: [
      (hi: 'बेचने का सौदा चूज़ा डालने से पहले तय करें — भाव गिरने का जोखिम घटता है', en: 'Fix the buyer before placing chicks to reduce price risk'),
      (hi: 'contract farming — कंपनी चूज़ा-दाना देती है, आप पालते हैं, तय पैसा मिलता है', en: 'Contract farming — company supplies chicks and feed, you get a fixed rearing fee'),
      (hi: 'स्थानीय चिकन दुकान/ढाबा से सीधा सौदा — बिचौलिए का कमीशन बचता है', en: 'Sell direct to local chicken shops and dhabas'),
    ],
    reminderPlan: [
      (day: 6, what: (hi: 'रानीखेत (लासोटा) — आँख/नाक में बूँद', en: 'Ranikhet (Lasota) eye/nasal drop')),
      (day: 14, what: (hi: 'गम्बोरो (IBD)', en: 'Gumboro (IBD)')),
      (day: 22, what: (hi: 'रानीखेत बूस्टर', en: 'Ranikhet booster')),
    ],
  ),

  // ─────────────────────────── 4. कड़कनाथ ───────────────────────────
  PalanGuide(
    id: 'kadaknath',
    emoji: '🐓',
    name: (hi: 'कड़कनाथ मुर्गी', en: 'Kadaknath Poultry'),
    tagline: (hi: 'काला मांस, ऊँचा दाम — देसी GI नस्ल', en: 'Black meat, premium price — GI-tagged native breed'),
    color: Color(0xFF37474F),
    intro: (
      hi: 'कड़कनाथ मध्य प्रदेश (झाबुआ) की GI-टैग वाली देसी नस्ल है। मांस, हड्डी और खून तक काले होते हैं। प्रोटीन ज़्यादा, चर्बी कम — इसीलिए दाम आम मुर्गी से 4-5 गुना। बढ़त धीमी है (5-6 माह), पर मुनाफ़े का प्रतिशत ऊँचा।',
      en: 'Kadaknath is a GI-tagged native breed from Jhabua (MP) with black meat, bones and blood. High protein, low fat — priced 4–5× normal chicken. Growth is slow (5–6 months) but margins are high.',
    ),
    breeds: [
      (hi: 'जेट ब्लैक — पूरी तरह काला, सबसे ज़्यादा माँग', en: 'Jet Black — fully black, most in demand'),
      (hi: 'पेंसिल्ड — गर्दन पर हल्की धारियाँ', en: 'Pencilled — light neck streaks'),
      (hi: 'गोल्डन — गर्दन-पंख पर सुनहरी झलक', en: 'Golden — golden tinge on neck and wings'),
    ],
    housing: [
      (hi: 'अर्ध-खुला पालन सबसे अच्छा — दिन में बाड़े में घूमे, रात में शेड में', en: 'Semi free-range works best — run by day, shed at night'),
      (hi: 'जगह: शेड में 2 वर्ग फुट + बाहर 8-10 वर्ग फुट प्रति पक्षी', en: 'Space: 2 sq ft indoors plus 8–10 sq ft outdoor run'),
      (hi: 'बाड़े पर ऊपर से जाली — चील/बिल्ली से बचाव (सबसे बड़ा नुक़सान यही)', en: 'Net the run overhead — hawks and cats are the main loss'),
    ],
    feed: [
      (stage: (hi: 'चूज़ा (0-8 हफ़्ते)', en: 'Chick (0–8 wk)'), feed: (hi: 'स्टार्टर दाना', en: 'Starter feed'), qty: (hi: '30-40 ग्राम/दिन', en: '30–40 g/day')),
      (stage: (hi: 'बढ़त (2-5 माह)', en: 'Grower (2–5 m)'), feed: (hi: 'ग्रोअर + चरागाह (कीड़े, घास, दाना)', en: 'Grower feed + range (insects, greens, grain)'), qty: (hi: '60-80 ग्राम/दिन', en: '60–80 g/day')),
      (stage: (hi: 'अंडे वाली मुर्गी', en: 'Laying hen'), feed: (hi: 'लेयर दाना + कैल्शियम', en: 'Layer feed + calcium'), qty: (hi: '90-100 ग्राम/दिन', en: '90–100 g/day')),
    ],
    feedNotes: [
      (hi: 'खुले में चरने से दाने का ख़र्च 30-40% तक घटता है — यही इसका असली फ़ायदा।', en: 'Ranging cuts feed cost by 30–40% — the breed\'s real advantage.'),
      (hi: 'रसोई का बचा अनाज/साग भी दे सकते हैं, पर सड़ा हुआ नहीं।', en: 'Kitchen grain and greens are fine, but never spoiled feed.'),
    ],
    production: [
      (hi: 'शुद्ध नस्ल का बीज (चूज़ा) सरकारी/कृषि विज्ञान केंद्र से लें — नकली बहुत बिकते हैं', en: 'Buy pure chicks from government farms or KVK — fakes are common'),
      (hi: 'मुर्गी साल में 80-110 अंडे देती है — अंडे भी ₹25-40 में बिकते हैं', en: 'Hens lay 80–110 eggs a year; eggs sell at ₹25–40 each'),
      (hi: 'नर 5-6 माह/1-1.5 किग्रा पर बेचें', en: 'Sell cockerels at 5–6 months / 1–1.5 kg'),
      (hi: 'अपनी हैचरी (छोटा इनक्यूबेटर) लगाएँ — चूज़ा बेचने में सबसे ज़्यादा मुनाफ़ा', en: 'A small incubator pays best — selling chicks is the top margin'),
    ],
    vaccines: [
      (when: (hi: '5-7 दिन, 4 व 8 हफ़्ते', en: 'Day 5–7, weeks 4 and 8'), what: (hi: 'रानीखेत (RD)', en: 'Ranikhet')),
      (when: (hi: '14 व 28 दिन', en: 'Day 14 and 28'), what: (hi: 'गम्बोरो (IBD)', en: 'Gumboro')),
      (when: (hi: '8-10 हफ़्ते', en: 'Weeks 8–10'), what: (hi: 'फाउल पॉक्स', en: 'Fowl pox')),
    ],
    diseases: [
      (hi: 'रानीखेत — देसी नस्ल में भी उतना ही ख़तरा, टीका न छोड़ें।', en: 'Ranikhet — native breeds are equally at risk; never skip the vaccine.'),
      (hi: 'कीड़े (कृमि) — खुले में चरने से ज़्यादा; हर 2-3 माह दवा दें।', en: 'Worms — common in ranging birds; deworm every 2–3 months.'),
      (hi: 'शिकारी जानवर — चील, बिल्ली, कुत्ता; जाली और रात का दरवाज़ा पक्का करें।', en: 'Predators — hawks, cats, dogs; secure netting and night doors.'),
    ],
    economicsUnit: (hi: '100 कड़कनाथ (6 माह)', en: '100 Kadaknath (6 months)'),
    costs: [
      (item: (hi: '100 चूज़े (₹80)', en: '100 chicks at ₹80'), value: '₹8,000', oneTime: false),
      (item: (hi: 'दाना (6 माह)', en: 'Feed for 6 months'), value: '₹18,000', oneTime: false),
      (item: (hi: 'शेड + जाली (एक बार)', en: 'Shed + netting (one time)'), value: '₹20,000', oneTime: true),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹2,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~90 पक्षी × 1.2 किग्रा × ₹700/किग्रा', en: '~90 birds × 1.2 kg × ₹700/kg'), value: '₹75,000', oneTime: false),
      (item: (hi: 'अंडे (यदि मुर्गियाँ रखें)', en: 'Eggs if hens are retained'), value: '₹15,000+', oneTime: false),
    ],
    cycleMonths: 6,
    economicsNote: (
      hi: 'दाम ₹600-1000/किग्रा तक जाता है, पर ख़रीदार सीमित हैं — पहले बाज़ार पक्का करें, फिर पालन बढ़ाएँ। शहर, जिम और online बिक्री सबसे अच्छे ख़रीदार हैं।',
      en: 'Prices reach ₹600–1000/kg but buyers are limited — secure the market first. Cities, gyms and online sales are the best channels.',
    ),
    selling: [
      (hi: 'शहर के बड़े ग्राहक, जिम/फ़िटनेस वाले, विशेष रेस्तराँ', en: 'Urban buyers, gym-goers, speciality restaurants'),
      (hi: 'WhatsApp/Facebook पर सीधे ग्राहक — बिचौलिया नहीं, पूरा दाम आपका', en: 'Direct customers via WhatsApp/Facebook — full price, no middleman'),
      (hi: 'चूज़े बेचना — दूसरे किसानों को, सबसे तेज़ मुनाफ़ा', en: 'Selling chicks to other farmers gives the quickest margin'),
    ],
    reminderPlan: [
      (day: 6, what: (hi: 'रानीखेत (लासोटा)', en: 'Ranikhet (Lasota)')),
      (day: 14, what: (hi: 'गम्बोरो (IBD)', en: 'Gumboro (IBD)')),
      (day: 28, what: (hi: 'रानीखेत दूसरी ख़ुराक', en: 'Ranikhet second dose')),
      (day: 56, what: (hi: 'फाउल पॉक्स', en: 'Fowl pox')),
      (day: 90, what: (hi: 'कीड़े की दवा', en: 'Deworming')),
    ],
  ),

  // ─────────────────────────── 5. बत्तख ───────────────────────────
  PalanGuide(
    id: 'duck',
    emoji: '🦆',
    name: (hi: 'बत्तख पालन', en: 'Duck Farming'),
    tagline: (hi: 'पानी वाले इलाक़े का सबसे आसान धंधा', en: 'Easiest business for waterlogged areas'),
    color: Color(0xFF00838F),
    intro: (
      hi: 'बत्तख मुर्गी से ज़्यादा मज़बूत होती है — बीमारी कम, देखभाल आसान। तालाब/धान के खेत वाले इलाक़ों (बंगाल, असम, केरल, बिहार) के लिए सबसे उपयुक्त। अंडा मुर्गी के अंडे से बड़ा और महँगा बिकता है।',
      en: 'Ducks are hardier than chickens — fewer diseases, easier care. Ideal for pond and paddy areas (Bengal, Assam, Kerala, Bihar). Duck eggs are larger and sell higher than hen eggs.',
    ),
    breeds: [
      (hi: 'खाकी कैंपबेल — साल में 280-300 अंडे, सबसे प्रचलित', en: 'Khaki Campbell — 280–300 eggs a year, most popular'),
      (hi: 'इंडियन रनर — अंडे के लिए, खड़ी चाल', en: 'Indian Runner — egg breed, upright stance'),
      (hi: 'पेकिन — मांस के लिए, तेज़ बढ़त', en: 'Pekin — meat breed, fast growth'),
      (hi: 'देसी (नागेश्वरी/चारा) — कम देखभाल, स्थानीय जलवायु में मज़बूत', en: 'Desi (Nageswari/Chara) — low input, locally hardy'),
    ],
    housing: [
      (hi: 'जगह: 3-4 वर्ग फुट प्रति बत्तख (रात के शेड में)', en: 'Space: 3–4 sq ft per duck in the night shed'),
      (hi: 'पानी की जगह ज़रूरी — तालाब न हो तो 6 इंच गहरी नांद/नाली भी काफ़ी', en: 'Water access needed — a 6-inch deep channel works if there is no pond'),
      (hi: 'बिछावन सूखा रखें, बत्तख पानी छलकाती है — रोज़ बदलें', en: 'Keep litter dry — ducks splash water; change it daily'),
      (hi: 'घोंसले की जगह ज़मीन पर — बत्तख ज़्यादातर सुबह 9 बजे से पहले अंडा देती है', en: 'Ground-level nests — most eggs are laid before 9 am'),
    ],
    feed: [
      (stage: (hi: 'बच्चा (0-8 हफ़्ते)', en: 'Duckling (0–8 wk)'), feed: (hi: 'स्टार्टर दाना (20% प्रोटीन)', en: 'Starter (20% protein)'), qty: (hi: '40-60 ग्राम/दिन', en: '40–60 g/day')),
      (stage: (hi: 'बढ़त (9-20 हफ़्ते)', en: 'Grower (9–20 wk)'), feed: (hi: 'ग्रोअर + चावल की भूसी, घोंघे, जलीय पौधे', en: 'Grower + rice bran, snails, aquatic plants'), qty: (hi: '80-100 ग्राम/दिन', en: '80–100 g/day')),
      (stage: (hi: 'अंडे वाली (21+ हफ़्ते)', en: 'Layer (21+ wk)'), feed: (hi: 'लेयर दाना + कैल्शियम', en: 'Layer feed + calcium'), qty: (hi: '120-140 ग्राम/दिन', en: '120–140 g/day')),
    ],
    feedNotes: [
      (hi: 'तालाब/धान के खेत में घोंघे और कीड़े खाकर दाने का ख़र्च आधा तक घट जाता है।', en: 'Snails and insects from ponds/paddy can halve feed cost.'),
      (hi: 'दाना हमेशा गीला करके दें — बत्तख सूखा दाना ठीक से नहीं निगल पाती।', en: 'Serve feed moist — ducks swallow dry mash poorly.'),
    ],
    production: [
      (hi: 'धान के खेत में बत्तख छोड़ें — कीड़े-घोंघे खाती है, खाद भी देती है (धान+बत्तख प्रणाली)', en: 'Integrate with paddy — ducks eat pests and snails and manure the field'),
      (hi: 'तालाब में मछली + बत्तख साथ — बत्तख की बीट मछली का भोजन बनती है', en: 'Fish + duck integration — droppings feed the fish'),
      (hi: 'सुबह देर से बाहर निकालें ताकि अंडे शेड में ही मिलें', en: 'Release them late morning so eggs are laid inside the shed'),
      (hi: '2 साल बाद झुंड बदलें — उसके बाद अंडे घट जाते हैं', en: 'Replace the flock after two years as laying declines'),
    ],
    vaccines: [
      (when: (hi: '2-4 हफ़्ते, फिर हर 6 माह', en: 'Weeks 2–4, then every 6 months'), what: (hi: 'डक प्लेग (डक वायरल एंटेराइटिस)', en: 'Duck plague (viral enteritis)')),
      (when: (hi: '8 हफ़्ते', en: 'Week 8'), what: (hi: 'डक कॉलरा (पेस्च्युरेलोसिस)', en: 'Duck cholera (pasteurellosis)')),
    ],
    diseases: [
      (hi: 'डक प्लेग — अचानक मौतें, हरा दस्त। टीका ही बचाव।', en: 'Duck plague — sudden deaths and green droppings; vaccinate.'),
      (hi: 'एफ़्लाटॉक्सिन — सीलन वाला/फफूँदी दाना खाने से; दाना सूखा रखें।', en: 'Aflatoxin from mouldy feed — store feed dry.'),
      (hi: 'बॉटुलिज़्म — गंदे रुके पानी से; पानी बदलते रहें।', en: 'Botulism from stagnant dirty water — keep water fresh.'),
    ],
    economicsUnit: (hi: '200 खाकी कैंपबेल (एक साल)', en: '200 Khaki Campbell (one year)'),
    costs: [
      (item: (hi: '200 बच्चे (₹60)', en: '200 ducklings at ₹60'), value: '₹12,000', oneTime: false),
      (item: (hi: 'दाना (साल भर)', en: 'Feed for the year'), value: '₹1,10,000', oneTime: false),
      (item: (hi: 'शेड + जाली (एक बार)', en: 'Shed + netting (one time)'), value: '₹40,000', oneTime: true),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹4,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~50,000 अंडे (₹8 औसत)', en: '~50,000 eggs at ₹8'), value: '₹4,00,000', oneTime: false),
      (item: (hi: 'पुरानी बत्तख बिक्री', en: 'Spent duck sales'), value: '₹40,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'तालाब/धान के खेत वाले किसान का दाना-ख़र्च आधा रह जाता है, तब मुनाफ़ा और बढ़ता है। बत्तख का अंडा मुर्गी से ₹2-4 महँगा बिकता है।',
      en: 'With pond or paddy access feed cost halves and profit rises further. Duck eggs sell ₹2–4 above hen eggs.',
    ),
    selling: [
      (hi: 'अंडा — स्थानीय बाज़ार, बंगाली/असमी/केरल के इलाक़ों में सबसे ऊँची माँग', en: 'Eggs — highest demand in Bengal, Assam and Kerala markets'),
      (hi: 'मांस — सर्दी के मौसम में दाम ऊँचे', en: 'Meat sells best in winter'),
      (hi: 'बत्तख के बच्चे बेचना — हैचरी से जुड़कर अच्छी कमाई', en: 'Selling ducklings via a hatchery tie-up pays well'),
    ],
    reminderPlan: [
      (day: 21, what: (hi: 'डक प्लेग का टीका', en: 'Duck plague vaccine')),
      (day: 56, what: (hi: 'डक कॉलरा का टीका', en: 'Duck cholera vaccine')),
      (day: 200, what: (hi: 'डक प्लेग बूस्टर (हर 6 माह)', en: 'Duck plague booster (6-monthly)')),
    ],
  ),

  // ─────────────────────────── 6. सुअर ───────────────────────────
  PalanGuide(
    id: 'pig',
    emoji: '🐷',
    name: (hi: 'सुअर पालन', en: 'Pig Farming'),
    tagline: (hi: 'सबसे तेज़ वज़न बढ़ने वाला पशु', en: 'The fastest weight-gaining livestock'),
    color: Color(0xFFAD1457),
    intro: (
      hi: 'सुअर पालन में पूँजी सबसे जल्दी बढ़ती है — एक सुअरी साल में 2 बार, हर बार 8-12 बच्चे देती है। 8-10 माह में 90-100 किग्रा तैयार। पूर्वोत्तर भारत, झारखंड, बिहार और बंगाल में माँग बहुत ऊँची है।',
      en: 'Pigs multiply capital fastest — a sow farrows twice a year with 8–12 piglets each, reaching 90–100 kg in 8–10 months. Demand is very high in the North-East, Jharkhand, Bihar and Bengal.',
    ),
    breeds: [
      (hi: 'लार्ज व्हाइट यॉर्कशायर — सबसे प्रचलित, तेज़ बढ़त', en: 'Large White Yorkshire — most common, fast growth'),
      (hi: 'लैंडरेस — लंबा शरीर, ज़्यादा मांस', en: 'Landrace — long body, more meat'),
      (hi: 'घुंगरू (उ.प्र./बिहार देसी) — कम देखभाल, बचे-खुचे पर भी पलता है', en: 'Ghungroo (UP/Bihar native) — low input, thrives on scraps'),
      (hi: 'क्रॉसब्रीड (देसी × यॉर्कशायर) — नए किसान के लिए सबसे संतुलित', en: 'Crossbred (desi × Yorkshire) — most balanced for beginners'),
    ],
    housing: [
      (hi: 'पक्का फ़र्श, ढलान के साथ — रोज़ धोना आसान हो', en: 'Concrete sloping floor for easy daily washing'),
      (hi: 'जगह: बड़ा सुअर 20-25 वर्ग फुट, सुअरी + बच्चे 40-50 वर्ग फुट', en: 'Space: 20–25 sq ft per grower, 40–50 sq ft for sow with litter'),
      (hi: 'नहाने का हौद/छिड़काव — सुअर को पसीना नहीं आता, गर्मी में मर सकता है', en: 'Wallow or sprinkler — pigs cannot sweat and die of heat'),
      (hi: 'बस्ती से दूर, हवा की दिशा देखकर — बदबू की शिकायत न हो', en: 'Site away from homes and downwind to avoid odour complaints'),
    ],
    feed: [
      (stage: (hi: 'बच्चा (दूध छुड़ाने पर)', en: 'Weaner'), feed: (hi: 'क्रीप दाना (20% प्रोटीन)', en: 'Creep feed (20% protein)'), qty: (hi: '400-600 ग्राम/दिन', en: '400–600 g/day')),
      (stage: (hi: 'बढ़त (3-6 माह)', en: 'Grower (3–6 m)'), feed: (hi: 'ग्रोअर दाना + चावल-गेहूँ चोकर, सब्ज़ी का बचा', en: 'Grower feed + bran, vegetable waste'), qty: (hi: '1.5-2 किग्रा/दिन', en: '1.5–2 kg/day')),
      (stage: (hi: 'फिनिशर (7-10 माह)', en: 'Finisher (7–10 m)'), feed: (hi: 'ऊर्जा वाला दाना', en: 'High-energy feed'), qty: (hi: '2.5-3 किग्रा/दिन', en: '2.5–3 kg/day')),
      (stage: (hi: 'सुअरी (गाभिन/दूध वाली)', en: 'Sow (pregnant/lactating)'), feed: (hi: 'संतुलित दाना + खनिज', en: 'Balanced feed + minerals'), qty: (hi: '3-4 किग्रा/दिन', en: '3–4 kg/day')),
    ],
    feedNotes: [
      (hi: 'होटल/शादी का बचा भोजन सबसे सस्ता चारा है — पर उबालकर ही दें (बीमारी से बचाव)।', en: 'Hotel and wedding leftovers are the cheapest feed — always boil before feeding.'),
      (hi: 'कुल दाना ~3.5 किग्रा प्रति किग्रा वज़न बढ़त (FCR 3.5) सामान्य है।', en: 'About 3.5 kg feed per kg gain (FCR 3.5) is normal.'),
    ],
    production: [
      (hi: 'सुअरी को 8-10 माह/100 किग्रा पर पहली बार गाभिन कराएँ', en: 'First breed the gilt at 8–10 months / 100 kg'),
      (hi: 'बच्चों को 3 दिन के अंदर लोहे का इंजेक्शन — ख़ून की कमी से मौत रुकती है', en: 'Give piglets an iron injection within 3 days to prevent anaemia deaths'),
      (hi: 'दूध 4-5 हफ़्ते में छुड़ाएँ — सुअरी जल्दी दोबारा गाभिन होगी', en: 'Wean at 4–5 weeks so the sow rebreeds sooner'),
      (hi: 'गर्मी में दोपहर को पानी छिड़कें — बढ़त और गर्भ दोनों बचते हैं', en: 'Sprinkle water at midday in summer to protect growth and pregnancy'),
    ],
    vaccines: [
      (when: (hi: '2 माह, फिर हर साल', en: '2 months, then yearly'), what: (hi: 'स्वाइन फ़ीवर (क्लासिकल) — सबसे ज़रूरी', en: 'Classical swine fever — most important')),
      (when: (hi: '4 माह, हर साल', en: '4 months, yearly'), what: (hi: 'खुरपका-मुँहपका (FMD)', en: 'FMD')),
      (when: (hi: 'बरसात से पहले', en: 'Before monsoon'), what: (hi: 'गलघोंटू (HS)', en: 'Haemorrhagic septicaemia')),
    ],
    diseases: [
      (hi: 'स्वाइन फ़ीवर — तेज़ बुख़ार, खाल पर लाल चकत्ते, बहुत मौतें। टीका अनिवार्य।', en: 'Swine fever — high fever, red skin blotches, heavy mortality; vaccinate.'),
      (hi: 'दस्त (कोलाई) — बच्चों में; ठंडे-गीले फ़र्श से बचाएँ।', en: 'E. coli scours in piglets — avoid cold wet floors.'),
      (hi: 'कीड़े व खुजली — हर 3 माह दवा और चूने से सफ़ाई।', en: 'Worms and mange — deworm every 3 months, lime the pens.'),
    ],
    economicsUnit: (hi: '2 सुअरी + 1 सुअर (एक साल)', en: '2 sows + 1 boar (one year)'),
    costs: [
      (item: (hi: '2 सुअरी + 1 नर', en: '2 sows + 1 boar'), value: '₹45,000', oneTime: true),
      (item: (hi: 'दाना (साल भर, बच्चों सहित)', en: 'Feed including litters'), value: '₹1,20,000', oneTime: false),
      (item: (hi: 'शेड (पक्का, एक बार)', en: 'Concrete shed (one time)'), value: '₹80,000', oneTime: true),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹8,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~32 बच्चे × 90 किग्रा × ₹130/किग्रा (आंशिक बिक्री)', en: '~32 pigs × 90 kg × ₹130/kg (part sold)'), value: '₹2,80,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'सब बच्चे एक साथ नहीं बिकते — कुछ को बड़ा करके बेचना ज़्यादा फ़ायदेमंद रहता है। बचा हुआ भोजन मिल जाए तो दाना-ख़र्च आधा हो जाता है।',
      en: 'Not all piglets are sold at once — growing some to weight pays more. Access to food waste halves feed cost.',
    ),
    mistakes: [
      (hi: '❌ **जूठन/कचरा खिलाना** — सस्ता लगता है पर बीमारी और ख़राब मांस देता है। साफ़ दाना ही दीजिए।', en: '❌ **Feeding hotel waste** — looks cheap but brings disease and poor meat. Use clean feed.'),
    ],
    whereToBuy: [
      (hi: '🐖 ICAR-NRC सुअर (गुवाहाटी) और राज्य के सुअर प्रजनन फ़ार्म — बेहतर नस्ल (लार्ज व्हाइट यॉर्कशायर, हैम्पशायर)।', en: '🐖 ICAR-NRC on Pig (Guwahati) and state pig breeding farms — better breeds (Large White Yorkshire, Hampshire).'),
    ],
    selling: [
      (hi: 'पूर्वोत्तर (नागालैंड, मिज़ोरम, असम) में सबसे ऊँचे दाम', en: 'Highest prices in the North-East (Nagaland, Mizoram, Assam)'),
      (hi: 'स्थानीय मांस दुकान से महीने का पक्का सौदा', en: 'Monthly supply contracts with local meat shops'),
      (hi: 'छोटे बच्चे (पिगलेट) बेचना — जल्दी पैसा, कम जोखिम', en: 'Selling piglets gives quick cash with less risk'),
      (hi: 'त्योहार/शादी के मौसम में दाम 20-30% ऊपर', en: 'Festival and wedding seasons pay 20–30% more'),
    ],
    reminderPlan: [
      (day: 60, what: (hi: 'स्वाइन फ़ीवर का टीका', en: 'Classical swine fever vaccine')),
      (day: 90, what: (hi: 'कीड़े की दवा', en: 'Deworming')),
      (day: 120, what: (hi: 'खुरपका-मुँहपका (FMD)', en: 'FMD vaccine')),
      (day: 180, what: (hi: 'गलघोंटू (HS) — बरसात से पहले', en: 'HS vaccine before monsoon')),
      (day: 425, what: (hi: 'स्वाइन फ़ीवर बूस्टर (सालाना)', en: 'Swine fever booster (yearly)')),
    ],
  ),

  // ─────────────────────────── 7. भेड़ ───────────────────────────
  PalanGuide(
    id: 'sheep',
    emoji: '🐑',
    name: (hi: 'भेड़ पालन', en: 'Sheep Farming'),
    tagline: (hi: 'सूखे इलाक़े का भरोसेमंद पशु — मांस + ऊन', en: 'Reliable in dry areas — meat plus wool'),
    color: Color(0xFF6D4C41),
    intro: (
      hi: 'भेड़ कम चारे और सूखे इलाक़े (राजस्थान, महाराष्ट्र, कर्नाटक, तेलंगाना) में भी टिकती है। मुख्य कमाई मांस से है; ऊन अब कम दाम देती है। झुंड में चराने से लागत बहुत कम रहती है।',
      en: 'Sheep survive on sparse fodder in dry regions (Rajasthan, Maharashtra, Karnataka, Telangana). Meat is the main income; wool now fetches little. Flock grazing keeps costs very low.',
    ),
    breeds: [
      (hi: 'मारवाड़ी (राजस्थान) — सूखा सहने वाली, मांस के लिए', en: 'Marwari (Rajasthan) — drought hardy, meat type'),
      (hi: 'नाली — अच्छी ऊन और मांस दोनों', en: 'Nali — good wool and meat'),
      (hi: 'दक्कनी — दक्षिण भारत, चरने में माहिर', en: 'Deccani — south India, excellent grazer'),
      (hi: 'मैरिनो क्रॉस — बढ़िया ऊन, ठंडे इलाक़ों के लिए', en: 'Merino cross — fine wool, for cooler regions'),
    ],
    housing: [
      (hi: 'जगह: 10-12 वर्ग फुट प्रति भेड़; बाड़ा हवादार और सूखा', en: 'Space: 10–12 sq ft per sheep; dry, airy pen'),
      (hi: 'फ़र्श सूखा — नमी से खुर सड़ने (फुट रॉट) की बीमारी होती है', en: 'Keep floors dry — damp causes foot rot'),
      (hi: 'रात में बाड़े में बंद — कुत्ते/सियार से बचाव', en: 'Pen them at night against dogs and jackals'),
    ],
    feed: [
      (stage: (hi: 'मेमना (0-3 माह)', en: 'Lamb (0–3 m)'), feed: (hi: 'माँ का दूध + नरम घास', en: 'Ewe milk + tender grass'), qty: (hi: 'दाना 100 ग्राम/दिन', en: 'Concentrate 100 g/day')),
      (stage: (hi: 'बढ़त (3-9 माह)', en: 'Grower (3–9 m)'), feed: (hi: 'चराई + थोड़ा दाना', en: 'Grazing + light concentrate'), qty: (hi: 'चराई 6-8 घंटे + 150 ग्राम दाना', en: '6–8 h grazing + 150 g concentrate')),
      (stage: (hi: 'बड़ी भेड़', en: 'Adult ewe'), feed: (hi: 'चराई + सूखा चारा', en: 'Grazing + dry fodder'), qty: (hi: 'हरा 3-4 किग्रा या 8 घंटे चराई', en: '3–4 kg green or 8 h grazing')),
      (stage: (hi: 'गाभिन भेड़', en: 'Pregnant ewe'), feed: (hi: 'ऊपर वाला + दाना-खनिज', en: 'As above + concentrate and minerals'), qty: (hi: 'दाना 300 ग्राम + खनिज 10 ग्राम', en: 'Concentrate 300 g + mineral 10 g')),
    ],
    feedNotes: [
      (hi: 'सुबह ओस सूखने के बाद ही चराएँ — गीली घास से अफारा होता है।', en: 'Graze only after dew dries — wet grass causes bloat.'),
      (hi: 'नमक की डली बाड़े में रखें — भेड़ ख़ुद ज़रूरत के अनुसार चाटती है।', en: 'Keep a salt lick — sheep self-regulate their intake.'),
    ],
    production: [
      (hi: 'मेढ़ा (नर) हर 2 साल में बदलें — नज़दीकी रिश्ते से नस्ल कमज़ोर होती है', en: 'Change the ram every 2 years to avoid inbreeding'),
      (hi: 'साल में 2 बार ऊन कतरें (मार्च और सितंबर)', en: 'Shear twice a year, March and September'),
      (hi: 'मेमने 6-8 माह/25-30 किग्रा पर बेचें', en: 'Sell lambs at 6–8 months / 25–30 kg'),
      (hi: 'हर 3 माह कृमिनाशक — चरने वाले पशु में कीड़े सबसे बड़ा नुक़सान', en: 'Deworm every 3 months — worms are the top loss in grazers'),
    ],
    vaccines: [
      (when: (hi: '3 माह, फिर हर साल', en: '3 months, then yearly'), what: (hi: 'PPR', en: 'PPR')),
      (when: (hi: 'बरसात से पहले, हर साल', en: 'Before monsoon, yearly'), what: (hi: 'ET (आंत्र विषाक्तता) + HS', en: 'Enterotoxaemia + HS')),
      (when: (hi: 'हर साल', en: 'Yearly'), what: (hi: 'शीप पॉक्स (चेचक)', en: 'Sheep pox')),
    ],
    diseases: [
      (hi: 'फुट रॉट — गीली ज़मीन से खुर सड़ना, लंगड़ाना। नीले थोथे के पानी से धोएँ।', en: 'Foot rot from wet ground — lameness; wash with copper sulphate solution.'),
      (hi: 'PPR — तेज़ बुख़ार, दस्त; टीका ही बचाव।', en: 'PPR — fever and diarrhoea; vaccination is the defence.'),
      (hi: 'लिवर फ़्लूक — रुके पानी वाले चरागाह से; समय पर दवा दें।', en: 'Liver fluke from marshy pasture — deworm on schedule.'),
    ],
    economicsUnit: (hi: '25 भेड़ + 1 मेढ़ा (एक साल)', en: '25 ewes + 1 ram (one year)'),
    costs: [
      (item: (hi: '25 भेड़ + 1 मेढ़ा', en: '25 ewes + 1 ram'), value: '₹1,60,000', oneTime: true),
      (item: (hi: 'चारा-दाना (चराई के साथ)', en: 'Feed alongside grazing'), value: '₹50,000', oneTime: false),
      (item: (hi: 'बाड़ा (एक बार)', en: 'Pen (one time)'), value: '₹40,000', oneTime: true),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹8,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~28 मेमने × ₹7,000', en: '~28 lambs at ₹7,000'), value: '₹1,96,000', oneTime: false),
      (item: (hi: 'ऊन + खाद', en: 'Wool and manure'), value: '₹12,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'जहाँ मुफ़्त चराई मिलती है वहाँ लागत आधी रह जाती है — यही भेड़ पालन की असली ताक़त है। बकरे की तुलना में भेड़ का दाम थोड़ा कम रहता है।',
      en: 'Free grazing halves the cost — the real strength of sheep farming. Prices run slightly below goats.',
    ),
    selling: [
      (hi: 'ईद-बकरीद और स्थानीय मेलों में सबसे ऊँचे दाम', en: 'Best prices at Eid and local fairs'),
      (hi: 'ज़िंदा वज़न पर सौदा करें, अंदाज़े से नहीं', en: 'Deal on live weight, not by estimate'),
      (hi: 'ऊन — सहकारी समिति (co-operative) से बेचें, अकेले से बेहतर दाम', en: 'Sell wool through a co-operative for a better rate'),
    ],
    reminderPlan: [
      (day: 90, what: (hi: 'PPR का टीका', en: 'PPR vaccine')),
      (day: 120, what: (hi: 'ET + गलघोंटू (HS)', en: 'ET + HS vaccine')),
      (day: 150, what: (hi: 'शीप पॉक्स (चेचक)', en: 'Sheep pox')),
      (day: 180, what: (hi: 'कीड़े की दवा', en: 'Deworming')),
      (day: 455, what: (hi: 'PPR बूस्टर (सालाना)', en: 'PPR booster (yearly)')),
    ],
  ),
];
