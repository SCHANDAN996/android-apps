import 'package:flutter/material.dart';
import 'palan_model.dart';

/// पालन गाइड — भाग 2: बटेर, खरगोश, मछली, मधुमक्खी, टर्की, एमू
///
/// ⚠️ सारे दाम/आँकड़े **अनुमानित** हैं — इलाक़े, नस्ल और बाज़ार से बदलते हैं।
const List<PalanGuide> kPalanPart2 = [
  // ─────────────────────────── 8. बटेर ───────────────────────────
  PalanGuide(
    id: 'quail',
    emoji: '🐦',
    name: (hi: 'बटेर पालन', en: 'Quail Farming'),
    tagline: (hi: 'सबसे कम जगह, 5 हफ़्ते में तैयार', en: 'Least space, ready in 5 weeks'),
    color: Color(0xFF795548),
    intro: (
      hi: 'बटेर (जापानी बटेर) सबसे छोटा और सबसे तेज़ चक्र वाला पक्षी है — 5 हफ़्ते में बिकने लायक़, 6-7 हफ़्ते में अंडे देना शुरू। एक कमरे में 1,000 बटेर आसानी से पल जाती हैं। सरकार से लाइसेंस की ज़रूरत नहीं (जापानी बटेर के लिए)।',
      en: 'Japanese quail is the smallest, fastest bird — sellable in 5 weeks and laying by 6–7 weeks. A single room can hold 1,000 quail. No licence needed for Japanese quail.',
    ),
    breeds: [
      (hi: 'जापानी बटेर (कोटर्निक्स) — भारत में सबसे प्रचलित, अंडा + मांस', en: 'Japanese quail (Coturnix) — most common in India, eggs and meat'),
      (hi: 'व्हाइट ब्रेस्टेड — मांस के लिए भारी नस्ल', en: 'White Breasted — heavier meat line'),
      (hi: 'ब्राउन/तुक्सीडो — अंडे के लिए बेहतर', en: 'Brown/Tuxedo — better for eggs'),
    ],
    housing: [
      (hi: 'पिंजरा (केज) में ही पालें — 5-6 बटेर प्रति वर्ग फुट', en: 'Rear in cages — 5–6 quail per sq ft'),
      (hi: '3-5 मंज़िला पिंजरा — कम जगह में ज़्यादा पक्षी', en: 'Stack cages 3–5 tiers to use space'),
      (hi: 'पिंजरे की जाली बारीक़ — बटेर छोटी होती है, निकल जाती है', en: 'Use fine mesh — quail are small and escape easily'),
      (hi: 'ब्रूडिंग: पहले हफ़्ते 95°F, फिर हर हफ़्ते 5°F कम', en: 'Brooding: 95°F in week one, then 5°F less weekly'),
    ],
    feed: [
      (stage: (hi: 'चूज़ा (0-2 हफ़्ते)', en: 'Chick (0–2 wk)'), feed: (hi: 'स्टार्टर (27% प्रोटीन) — बारीक़ पिसा', en: 'Starter (27% protein), finely ground'), qty: (hi: '8-10 ग्राम/दिन', en: '8–10 g/day')),
      (stage: (hi: 'बढ़त (3-5 हफ़्ते)', en: 'Grower (3–5 wk)'), feed: (hi: 'ग्रोअर (24% प्रोटीन)', en: 'Grower (24% protein)'), qty: (hi: '20-25 ग्राम/दिन', en: '20–25 g/day')),
      (stage: (hi: 'अंडे वाली (6+ हफ़्ते)', en: 'Layer (6+ wk)'), feed: (hi: 'लेयर (22% प्रोटीन) + कैल्शियम', en: 'Layer (22% protein) + calcium'), qty: (hi: '30-35 ग्राम/दिन', en: '30–35 g/day')),
    ],
    feedNotes: [
      (hi: 'बटेर को मुर्गी से ज़्यादा प्रोटीन चाहिए — मुर्गी का दाना देने से बढ़त रुक जाती है।', en: 'Quail need more protein than chickens — chicken feed stunts them.'),
      (hi: 'एक बटेर पूरे जीवन में सिर्फ़ ~1 किग्रा दाना खाती है।', en: 'A quail eats only about 1 kg of feed in its lifetime.'),
    ],
    production: [
      (hi: 'रोशनी 16 घंटे — अंडे की संख्या इसी से बनती है', en: '16 hours of light drives egg numbers'),
      (hi: 'नर:मादा = 1:3 रखें (अंडे से बच्चे चाहिए तब)', en: 'Keep 1 male per 3 females if you want fertile eggs'),
      (hi: 'मांस के लिए 5 हफ़्ते (180-200 ग्राम) पर बेचें', en: 'Sell for meat at 5 weeks (180–200 g)'),
      (hi: 'अंडे देने वाली बटेर 8-10 माह बाद बदलें', en: 'Replace layers after 8–10 months'),
      (hi: 'बटेर को टीके की ज़रूरत लगभग नहीं — बीमारी बहुत कम', en: 'Quail need almost no vaccines — very disease-resistant'),
    ],
    vaccines: [
      (when: (hi: 'सामान्यतः ज़रूरी नहीं', en: 'Usually not required'), what: (hi: 'बटेर में रोग प्रतिरोधक क्षमता ऊँची होती है — सफ़ाई ही बचाव', en: 'Quail have high natural immunity — hygiene is the protection')),
      (when: (hi: 'बड़े फ़ार्म पर, सलाह से', en: 'Large farms, on advice'), what: (hi: 'रानीखेत (RD) — जहाँ आसपास मुर्गी फ़ार्म हों', en: 'Ranikhet where poultry farms are nearby')),
    ],
    diseases: [
      (hi: 'भीड़ से चोंच मारना (कैनिबलिज़्म) — जगह बढ़ाएँ, रोशनी मद्धिम करें।', en: 'Cannibalism from crowding — give space and dim the light.'),
      (hi: 'दस्त — गंदा पानी/सीलन वाला दाना; रोज़ पानी बदलें।', en: 'Diarrhoea from dirty water or damp feed — change water daily.'),
      (hi: 'अल्सरेटिव एंटेराइटिस — गंदे पिंजरे से; नियमित सफ़ाई।', en: 'Ulcerative enteritis from dirty cages — clean regularly.'),
    ],
    economicsUnit: (hi: '1,000 बटेर (मांस, एक चक्र 5 हफ़्ते)', en: '1,000 quail (meat, one 5-week cycle)'),
    costs: [
      (item: (hi: '1,000 चूज़े (₹8)', en: '1,000 chicks at ₹8'), value: '₹8,000', oneTime: false),
      (item: (hi: 'दाना ~900 किग्रा', en: 'Feed ~900 kg'), value: '₹32,000', oneTime: false),
      (item: (hi: 'पिंजरा + शेड (एक बार)', en: 'Cages + shed (one time)'), value: '₹60,000', oneTime: true),
      (item: (hi: 'बिजली-दवा', en: 'Power and medicine'), value: '₹4,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~950 बटेर × ₹55', en: '~950 quail at ₹55'), value: '₹52,000', oneTime: false),
      (item: (hi: 'खाद', en: 'Manure'), value: '₹2,000', oneTime: false),
    ],
    cycleMonths: 1.2,
    economicsNote: (
      hi: 'एक चक्र सिर्फ़ 5 हफ़्ते का — साल में 8-9 चक्र संभव। अंडे वाली बटेर रखें तो 1,000 बटेर से रोज़ ~700 अंडे (₹2-3 प्रति अंडा) की अलग आमदनी।',
      en: 'A cycle is just 5 weeks — 8–9 cycles a year. Layer quail give ~700 eggs a day per 1,000 birds at ₹2–3 each.',
    ),
    selling: [
      (hi: 'बटेर का मांस — ढाबा, बार, विशेष रेस्तराँ में अच्छी माँग', en: 'Quail meat sells well to dhabas, bars and speciality restaurants'),
      (hi: 'बटेर के अंडे — औषधीय गुणों के कारण शहरों में ऊँची माँग', en: 'Quail eggs are in high urban demand for their health value'),
      (hi: 'जीवित बटेर बेचना — दूसरे किसानों को, तुरंत पैसा', en: 'Selling live quail to other farmers gives instant cash'),
    ],
    reminderPlan: [
      (day: 7, what: (hi: 'रानीखेत (जहाँ आसपास मुर्गी फ़ार्म हों)', en: 'Ranikhet if poultry farms nearby')),
      (day: 21, what: (hi: 'पिंजरे की गहरी सफ़ाई + दवा', en: 'Deep cage cleaning and medication')),
    ],
  ),

  // ─────────────────────────── 9. खरगोश ───────────────────────────
  PalanGuide(
    id: 'rabbit',
    emoji: '🐇',
    name: (hi: 'खरगोश पालन', en: 'Rabbit Farming'),
    tagline: (hi: 'घास पर पलता है, तेज़ी से बढ़ता है', en: 'Lives on greens, multiplies fast'),
    color: Color(0xFF9575CD),
    intro: (
      hi: 'खरगोश ज़्यादातर हरी घास और सब्ज़ी के पत्तों पर पल जाता है — दाना कम लगता है। एक मादा साल में 5-6 बार, हर बार 6-8 बच्चे देती है। मांस, ऊन (अंगोरा) और पालतू — तीनों तरह से कमाई। पहाड़ी और ठंडे इलाक़ों में सबसे बेहतर।',
      en: 'Rabbits thrive mostly on greens and vegetable leaves with little concentrate. A doe kindles 5–6 times a year with 6–8 kits each. Income from meat, angora wool or pets. Best in hilly and cooler regions.',
    ),
    breeds: [
      (hi: 'न्यूज़ीलैंड व्हाइट — मांस के लिए सबसे प्रचलित, तेज़ बढ़त', en: 'New Zealand White — top meat breed, fast growth'),
      (hi: 'सोवियत चिनचिला — मांस + खाल दोनों', en: 'Soviet Chinchilla — meat and pelt'),
      (hi: 'ग्रे जायंट — भारी नस्ल, 4-5 किग्रा तक', en: 'Grey Giant — heavy, up to 4–5 kg'),
      (hi: 'अंगोरा — ऊन के लिए (हिमाचल, उत्तराखंड, कश्मीर)', en: 'Angora — for wool (Himachal, Uttarakhand, Kashmir)'),
    ],
    housing: [
      (hi: 'पिंजरे में पालें (केज सिस्टम) — ज़मीन पर रखने से बीमारी और कीड़े लगते हैं', en: 'Use cages — floor rearing brings disease and parasites'),
      (hi: 'जगह: बड़ा खरगोश 3-4 वर्ग फुट, मादा + बच्चे 6 वर्ग फुट', en: 'Space: 3–4 sq ft per adult, 6 sq ft for doe with kits'),
      (hi: 'तापमान 15-25°C सबसे अच्छा — 35°C से ऊपर मौत हो सकती है', en: '15–25°C is ideal; above 35°C can be fatal'),
      (hi: 'हर मादा के लिए अलग नेस्ट बॉक्स (बच्चा देने के लिए)', en: 'A separate nest box for every doe'),
    ],
    feed: [
      (stage: (hi: 'बच्चा (दूध छुड़ाने पर)', en: 'Weaner'), feed: (hi: 'नरम हरी घास + थोड़ा दाना', en: 'Tender greens + a little pellet'), qty: (hi: '50 ग्राम दाना + हरा', en: '50 g pellet plus greens')),
      (stage: (hi: 'बढ़त (2-4 माह)', en: 'Grower (2–4 m)'), feed: (hi: 'हरी घास, बरसीम, गाजर-मूली के पत्ते + दाना', en: 'Greens, berseem, carrot/radish tops + pellet'), qty: (hi: 'हरा 300-400 ग्राम + दाना 80 ग्राम', en: '300–400 g greens + 80 g pellet')),
      (stage: (hi: 'बड़ा खरगोश', en: 'Adult'), feed: (hi: 'हरा चारा + दाना', en: 'Greens + pellet'), qty: (hi: 'हरा 500 ग्राम + दाना 100 ग्राम', en: '500 g greens + 100 g pellet')),
      (stage: (hi: 'दूध पिलाती मादा', en: 'Lactating doe'), feed: (hi: 'ऊपर वाला + प्रोटीन ज़्यादा', en: 'As above with more protein'), qty: (hi: 'दाना 150 ग्राम', en: '150 g pellet')),
    ],
    feedNotes: [
      (hi: 'गीली/ओस वाली घास कभी न दें — दस्त से बच्चे मर जाते हैं।', en: 'Never feed wet or dewy greens — scours kill kits.'),
      (hi: 'कुतरने के लिए लकड़ी का टुकड़ा रखें — दाँत बढ़ते रहते हैं।', en: 'Provide a wooden block to gnaw — their teeth keep growing.'),
    ],
    production: [
      (hi: 'मादा को 5-6 माह की उम्र में पहली बार मिलाएँ', en: 'First mate the doe at 5–6 months'),
      (hi: 'गर्भ सिर्फ़ 30-31 दिन का — साल में 5-6 बार बच्चे', en: 'Gestation is just 30–31 days — 5–6 litters a year'),
      (hi: 'मांस के लिए 3 माह/2-2.5 किग्रा पर बेचें', en: 'Sell for meat at 3 months / 2–2.5 kg'),
      (hi: 'गर्मी में पिंजरे पर गीला बोरा/कूलर — सबसे ज़्यादा मौतें गर्मी से', en: 'Wet sacking or cooler in summer — heat causes most deaths'),
      (hi: 'अंगोरा की ऊन हर 3 माह पर काटें (200-250 ग्राम/बार)', en: 'Harvest angora wool every 3 months (200–250 g each)'),
    ],
    vaccines: [
      (when: (hi: 'सामान्यतः ज़रूरी नहीं (भारत में)', en: 'Usually not required in India'), what: (hi: 'सफ़ाई और कीड़े की दवा ही मुख्य बचाव', en: 'Hygiene and deworming are the main protection')),
      (when: (hi: 'हर 3 माह', en: 'Every 3 months'), what: (hi: 'कृमिनाशक + खुजली (मैंज) की दवा', en: 'Deworming plus mange treatment')),
    ],
    diseases: [
      (hi: 'कोक्सीडियोसिस — दस्त, पेट फूलना; पिंजरा साफ़-सूखा रखें।', en: 'Coccidiosis — diarrhoea and bloating; keep cages clean and dry.'),
      (hi: 'कान की खुजली (इयर मैंज) — कान में पपड़ी; तेल-दवा से ठीक।', en: 'Ear mange — crusts inside ears; treat with medicated oil.'),
      (hi: 'हीट स्ट्रोक — गर्मी में कान लाल, हाँफना; तुरंत ठंडक दें।', en: 'Heat stroke — red ears and panting; cool immediately.'),
      (hi: 'स्नफ़ल्स (नाक बहना) — भीड़ और अमोनिया से; हवा का बहाव बढ़ाएँ।', en: 'Snuffles from crowding and ammonia — improve ventilation.'),
    ],
    economicsUnit: (hi: '10 मादा + 2 नर (एक साल)', en: '10 does + 2 bucks (one year)'),
    costs: [
      (item: (hi: '12 खरगोश (₹700)', en: '12 rabbits at ₹700'), value: '₹8,400', oneTime: true),
      (item: (hi: 'पिंजरे + शेड (एक बार)', en: 'Cages + shed (one time)'), value: '₹35,000', oneTime: true),
      (item: (hi: 'दाना (हरा चारा अपना)', en: 'Pellets (greens from farm)'), value: '₹25,000', oneTime: false),
      (item: (hi: 'दवा', en: 'Medicine'), value: '₹3,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~250 बच्चे × ₹450 (आंशिक बिक्री)', en: '~250 kits at ₹450 (part sold)'), value: '₹1,12,000', oneTime: false),
      (item: (hi: 'खाद (बहुत बढ़िया खाद)', en: 'Manure (excellent quality)'), value: '₹5,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'खरगोश के मांस का बाज़ार अभी सीमित है — शुरू करने से पहले ख़रीदार पक्का करें। पालतू (pet) और अंगोरा ऊन वाले रास्ते ज़्यादा भरोसेमंद हैं।',
      en: 'The rabbit meat market is still limited — secure buyers first. Pet sales and angora wool are more dependable routes.',
    ),
    selling: [
      (hi: 'पालतू जानवर की दुकानें — शहरों में सबसे अच्छा दाम', en: 'Pet shops in cities pay the best price'),
      (hi: 'मांस — होटल/रेस्तराँ से पहले सौदा तय करें', en: 'Meat — fix hotel/restaurant contracts in advance'),
      (hi: 'अंगोरा ऊन — ऊन बोर्ड/सहकारी समिति के ज़रिए', en: 'Angora wool via the wool board or a co-operative'),
      (hi: 'बच्चे (breeding stock) दूसरे किसानों को बेचना', en: 'Selling breeding stock to other farmers'),
    ],
    reminderPlan: [
      (day: 90, what: (hi: 'कीड़े की दवा (हर 3 माह)', en: 'Deworming (every 3 months)')),
      (day: 180, what: (hi: 'कीड़े की दवा + खुजली जाँच', en: 'Deworming and mange check')),
    ],
  ),

  // ─────────────────────────── 10. मछली ───────────────────────────
  PalanGuide(
    id: 'fish',
    emoji: '🐟',
    name: (hi: 'मछली पालन', en: 'Fish Farming'),
    tagline: (hi: 'एक तालाब, साल भर की कमाई', en: 'One pond, year-round income'),
    color: Color(0xFF0277BD),
    intro: (
      hi: 'मछली पालन में एक एकड़ तालाब से साल में 3-4 टन तक उत्पादन हो सकता है। भारतीय मेजर कार्प (रोहू, कतला, मृगल) साथ में पालने से तालाब की हर परत का इस्तेमाल होता है। सरकार से तालाब खुदाई पर अच्छी सब्सिडी मिलती है (PMMSY योजना)।',
      en: 'One acre of pond can yield 3–4 tonnes a year. Polyculture of Indian major carps (rohu, catla, mrigal) uses every layer of the pond. Government subsidy is available for pond digging (PMMSY).',
    ),
    breeds: [
      (hi: 'कतला — ऊपरी सतह का भोजन खाती है, तेज़ बढ़त', en: 'Catla — surface feeder, fast growth'),
      (hi: 'रोहू — बीच की परत, सबसे ज़्यादा माँग और दाम', en: 'Rohu — column feeder, highest demand and price'),
      (hi: 'मृगल — तली का भोजन, तालाब साफ़ रखती है', en: 'Mrigal — bottom feeder, keeps the pond clean'),
      (hi: 'तिलापिया / पंगेसियस — तेज़ बढ़त, कम ऑक्सीजन में भी टिकती है', en: 'Tilapia / Pangasius — fast growth, tolerate low oxygen'),
      (hi: 'देसी मांगुर, सिंघी — छोटे तालाब/बायोफ्लॉक के लिए ऊँचा दाम', en: 'Desi magur, singhi — premium price in small ponds/biofloc'),
    ],
    housing: [
      (hi: 'तालाब की गहराई 5-6 फुट — कम गहरा तालाब गर्मी में गर्म हो जाता है', en: 'Pond depth 5–6 ft — shallow ponds overheat in summer'),
      (hi: 'बीज डालने से पहले चूना डालें (250 किग्रा/एकड़) — पानी का pH ठीक होता है', en: 'Apply lime (250 kg/acre) before stocking to correct pH'),
      (hi: 'गोबर की खाद (2 टन/एकड़) — प्राकृतिक भोजन (प्लवक) बनता है', en: 'Cow dung (2 t/acre) grows natural plankton food'),
      (hi: 'खरपतवार और मांसाहारी मछली पहले हटाएँ', en: 'Remove weeds and predatory fish before stocking'),
    ],
    feed: [
      (stage: (hi: 'बीज (स्पॉन/फ़्राई)', en: 'Spawn/fry'), feed: (hi: 'चावल का चोकर + सरसों खली (1:1), बारीक़', en: 'Rice bran + mustard cake (1:1), fine'), qty: (hi: 'शरीर भार का 8-10%', en: '8–10% of body weight')),
      (stage: (hi: 'फ़िंगरलिंग (1-3 माह)', en: 'Fingerling (1–3 m)'), feed: (hi: 'चोकर + खली + मछली-दाना', en: 'Bran + cake + fish pellet'), qty: (hi: 'शरीर भार का 5%', en: '5% of body weight')),
      (stage: (hi: 'बढ़त (4-10 माह)', en: 'Grow-out (4–10 m)'), feed: (hi: 'तैरने वाला दाना (फ़्लोटिंग पेलेट) 28-30% प्रोटीन', en: 'Floating pellet, 28–30% protein'), qty: (hi: 'शरीर भार का 3%', en: '3% of body weight')),
    ],
    feedNotes: [
      (hi: 'दाना रोज़ एक ही समय, एक ही जगह डालें — मछली आदत बना लेती है, बर्बादी घटती है।', en: 'Feed at the same time and spot daily — fish learn the habit and waste less.'),
      (hi: 'बचा हुआ दाना पानी सड़ाता है — 2 घंटे में न खाए तो मात्रा घटाएँ।', en: 'Uneaten feed rots the water — cut the quantity if not eaten in 2 hours.'),
    ],
    production: [
      (hi: 'मिश्रित पालन: कतला 30% + रोहू 40% + मृगल 30% — हर परत का उपयोग', en: 'Polyculture: catla 30% + rohu 40% + mrigal 30% uses all layers'),
      (hi: 'बीज 5,000-6,000 प्रति एकड़ — ज़्यादा डालने से बढ़त रुक जाती है', en: 'Stock 5,000–6,000 fingerlings per acre — overstocking stunts growth'),
      (hi: 'सुबह मछली सतह पर मुँह खोले = ऑक्सीजन कम; पानी बदलें या एरेटर चलाएँ', en: 'Fish gulping at dawn means low oxygen — exchange water or run an aerator'),
      (hi: 'हर 15 दिन जाल डालकर वज़न जाँचें', en: 'Net-check weight every 15 days'),
      (hi: 'बत्तख या मुर्गी साथ पालें — उनकी बीट से मछली का भोजन बनता है', en: 'Integrate ducks or poultry — their droppings feed the fish'),
    ],
    vaccines: [
      (when: (hi: 'टीका नहीं लगता', en: 'No vaccines used'), what: (hi: 'पानी की गुणवत्ता (pH 7-8, ऑक्सीजन) ही असली बचाव है', en: 'Water quality (pH 7–8, oxygen) is the real protection')),
      (when: (hi: 'हर 2-3 माह', en: 'Every 2–3 months'), what: (hi: 'चूना + नमक से तालाब उपचार', en: 'Lime and salt treatment of the pond')),
    ],
    diseases: [
      (hi: 'EUS (घाव वाली बीमारी) — शरीर पर लाल घाव, सर्दी में; चूना डालें।', en: 'EUS — red ulcers, common in winter; apply lime.'),
      (hi: 'आर्गुलस (जूँ) — मछली किनारे रगड़ती है; नमक/दवा से उपचार।', en: 'Argulus lice — fish rub against banks; treat with salt or medicine.'),
      (hi: 'ऑक्सीजन की कमी — बादल वाले दिन और रात में सबसे ज़्यादा ख़तरा।', en: 'Oxygen depletion — highest risk on cloudy days and at night.'),
    ],
    economicsUnit: (hi: '1 एकड़ तालाब (एक साल)', en: '1 acre pond (one year)'),
    costs: [
      (item: (hi: 'तालाब तैयारी (चूना, खाद, सफ़ाई)', en: 'Pond prep (lime, manure, cleaning)'), value: '₹25,000', oneTime: true),
      (item: (hi: 'बीज 6,000 (₹3 प्रति)', en: '6,000 fingerlings at ₹3'), value: '₹18,000', oneTime: false),
      (item: (hi: 'दाना (साल भर)', en: 'Feed for the year'), value: '₹1,50,000', oneTime: false),
      (item: (hi: 'दवा-बिजली-मज़दूरी', en: 'Medicine, power, labour'), value: '₹30,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~3,000 किग्रा मछली × ₹130/किग्रा', en: '~3,000 kg fish at ₹130/kg'), value: '₹3,90,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'तालाब की खुदाई का ख़र्च (₹2-3 लाख/एकड़) एक ही बार लगता है और PMMSY योजना में 40-60% सब्सिडी मिल सकती है। मछली पकड़ने का समय त्योहार/सर्दी में रखें — दाम ऊँचे रहते हैं।',
      en: 'Pond digging (₹2–3 lakh/acre) is one-time and PMMSY can subsidise 40–60%. Harvest around festivals or winter when prices peak.',
    ),
    mistakes: [
      (hi: '❌ **तालाब की तैयारी छोड़ देना** — चूना और खाद डाले बिना बीज डालने से आधी मछली मर जाती है।', en: '❌ **Skipping pond preparation** — stocking without lime and manure kills half the seed.'),
      (hi: '❌ **पानी में ऑक्सीजन न देखना** — सुबह मछली ऊपर मुँह करे तो ऑक्सीजन कम है, तुरंत पानी हिलाइए।', en: '❌ **Ignoring oxygen** — fish gulping at the surface in the morning means low oxygen; aerate at once.'),
    ],
    whereToBuy: [
      (hi: '🐟 सरकारी मत्स्य बीज फ़ार्म से ही बीज (fingerling) लीजिए। PMMSY योजना में तालाब बनाने पर 40-60% अनुदान मिलता है।', en: '🐟 Buy fingerlings only from a government fish-seed farm. PMMSY gives 40-60% subsidy on pond construction.'),
    ],
    reminderPlan: [
      (day: 30, what: (hi: 'पानी की जाँच — मछली सुबह ऊपर मुँह करे तो ऑक्सीजन कम', en: 'Water check — fish gulping at surface means low oxygen')),
      (day: 90, what: (hi: 'मछली का वज़न देखिए, दाना उसी हिसाब से बढ़ाइए', en: 'Weigh fish and increase feed accordingly')),
      (day: 180, what: (hi: 'जाल डालकर बढ़त जाँचिए, बीमार मछली हटाइए', en: 'Net-check growth, remove sick fish')),
      (day: 270, what: (hi: 'बड़ी मछली छाँटकर बेचना शुरू कीजिए', en: 'Start selling the larger fish')),
      (day: 330, what: (hi: 'तालाब ख़ाली करने और अगली तैयारी की योजना', en: 'Plan harvest and next stocking')),
    ],
    selling: [
      (hi: 'स्थानीय मछली मंडी — सुबह जल्दी सबसे अच्छा दाम', en: 'Local fish market — early morning fetches the best price'),
      (hi: 'तालाब पर ही थोक बिक्री — व्यापारी ख़ुद आकर ले जाते हैं', en: 'Bulk sale at pond side — traders collect themselves'),
      (hi: 'ज़िंदा मछली बेचें — मरी से 20-30% ज़्यादा दाम', en: 'Sell live fish — 20–30% more than dead fish'),
      (hi: 'बीज (फ़िंगरलिंग) बेचना — दूसरे किसानों को, अच्छा मुनाफ़ा', en: 'Selling fingerlings to other farmers is profitable'),
    ],
  ),

  // ─────────────────────────── 11. मधुमक्खी ───────────────────────────
  PalanGuide(
    id: 'bee',
    emoji: '🐝',
    name: (hi: 'मधुमक्खी पालन', en: 'Beekeeping'),
    tagline: (hi: 'ज़मीन की ज़रूरत नहीं — शहद + खेत की पैदावार दोनों बढ़े', en: 'Needs no land — honey plus better crop yields'),
    color: Color(0xFFF9A825),
    intro: (
      hi: 'मधुमक्खी पालन में ज़मीन नहीं चाहिए — बक्से खेत के किनारे या छत पर भी रख सकते हैं। एक बक्से से साल में 30-50 किग्रा शहद मिलता है। सबसे बड़ा छिपा फ़ायदा — परागण (pollination) से सरसों, सूरजमुखी, फल की पैदावार 20-30% बढ़ जाती है।',
      en: 'Beekeeping needs no land — boxes can sit at field edges or on a roof. One box yields 30–50 kg honey a year. The hidden gain is pollination, which raises mustard, sunflower and fruit yields by 20–30%.',
    ),
    breeds: [
      (hi: 'एपिस मेलिफेरा (इटैलियन) — सबसे ज़्यादा शहद, व्यावसायिक पालन के लिए', en: 'Apis mellifera (Italian) — highest honey yield, commercial choice'),
      (hi: 'एपिस सेराना इंडिका (देसी) — कम शहद पर बीमारी कम, पहाड़ों में बेहतर', en: 'Apis cerana indica (native) — less honey but hardier, better in hills'),
      (hi: 'डम्मर मक्खी (स्टिंगलेस) — बहुत कम शहद पर दवा के रूप में ₹3,000+/किग्रा', en: 'Stingless (Dammar) bee — tiny yield but medicinal honey at ₹3,000+/kg'),
    ],
    housing: [
      (hi: 'बक्सा ज़मीन से 1 फुट ऊँचा स्टैंड पर — चींटी और नमी से बचाव', en: 'Keep boxes on a 1-ft stand — protects from ants and damp'),
      (hi: 'बक्से का मुँह पूर्व दिशा में — सुबह की धूप मिले', en: 'Face hive entrance east for morning sun'),
      (hi: 'छाया ज़रूरी — दोपहर की सीधी धूप में मक्खियाँ छत्ता छोड़ देती हैं', en: 'Shade is essential — direct afternoon sun makes bees abscond'),
      (hi: 'दो बक्सों के बीच 8-10 फुट, पानी का स्रोत पास में', en: '8–10 ft between hives, with a water source nearby'),
    ],
    feed: [
      (stage: (hi: 'फूल का मौसम (अक्टूबर-मार्च)', en: 'Flow season (Oct–Mar)'), feed: (hi: 'प्राकृतिक — सरसों, लीची, सूरजमुखी, बेर के फूल', en: 'Natural — mustard, litchi, sunflower, ber blossom'), qty: (hi: 'कुछ नहीं देना पड़ता', en: 'No feeding needed')),
      (stage: (hi: 'सूखा मौसम (जून-सितंबर)', en: 'Dearth (Jun–Sep)'), feed: (hi: 'चीनी का घोल (1 भाग चीनी : 1 भाग पानी)', en: 'Sugar syrup (1:1 sugar to water)'), qty: (hi: '200-500 मिली/सप्ताह प्रति बक्सा', en: '200–500 ml per week per hive')),
      (stage: (hi: 'कॉलोनी बढ़ाते समय', en: 'Building colonies'), feed: (hi: 'चीनी घोल + परागकण विकल्प (सोया आटा)', en: 'Syrup + pollen substitute (soy flour)'), qty: (hi: 'सप्ताह में 2 बार', en: 'Twice weekly')),
    ],
    feedNotes: [
      (hi: 'शहद निकालते समय बक्से में कुछ शहद छोड़ दें — वरना कॉलोनी भूखी मर जाती है।', en: 'Always leave some honey in the hive — a stripped colony starves.'),
      (hi: 'चीनी का घोल शाम को दें — दिन में देने से दूसरी मक्खियाँ लूट लेती हैं।', en: 'Feed syrup in the evening — daytime feeding invites robbing.'),
    ],
    production: [
      (hi: 'बक्से खेत के किनारे रखें — सरसों/सूरजमुखी के मौसम में शहद दुगना', en: 'Place hives beside fields — mustard/sunflower season doubles yield'),
      (hi: 'हर 10-15 दिन बक्सा खोलकर जाँचें — रानी है या नहीं, अंडे दिख रहे हैं या नहीं', en: 'Inspect every 10–15 days — confirm the queen and see eggs'),
      (hi: 'रानी हर 1-2 साल में बदलें — पुरानी रानी कम अंडे देती है', en: 'Replace the queen every 1–2 years as laying declines'),
      (hi: 'शहद तभी निकालें जब 75% कोष्ठक सील हो जाएँ — तभी नमी कम होगी', en: 'Extract only when 75% of cells are capped — moisture stays low'),
      (hi: 'बक्सों को फूलों के पीछे ले जाएँ (माइग्रेटरी) — उत्पादन 2-3 गुना', en: 'Migratory beekeeping following blooms lifts output 2–3×'),
    ],
    vaccines: [
      (when: (hi: 'टीका नहीं लगता', en: 'No vaccines'), what: (hi: 'साफ़ बक्सा और मज़बूत कॉलोनी ही बचाव', en: 'Clean hives and strong colonies are the protection')),
      (when: (hi: 'हर 3-4 माह जाँच', en: 'Check every 3–4 months'), what: (hi: 'वरोआ माइट की जाँच व उपचार', en: 'Check and treat Varroa mite')),
    ],
    diseases: [
      (hi: 'वरोआ माइट — मक्खियों पर लाल-भूरे कण; समय पर उपचार न हो तो कॉलोनी ख़त्म।', en: 'Varroa mite — reddish specks on bees; untreated it wipes out colonies.'),
      (hi: 'मोम कीट (वैक्स मॉथ) — कमज़ोर बक्से में जाला; ख़ाली छत्ते हटाएँ।', en: 'Wax moth webs in weak hives — remove unused combs.'),
      (hi: 'कीटनाशक से मौत — खेत में छिड़काव के दिन बक्से का मुँह बंद रखें।', en: 'Pesticide kills — close hive entrances on spray days.'),
    ],
    economicsUnit: (hi: '20 बक्से (एक साल)', en: '20 hives (one year)'),
    costs: [
      (item: (hi: '20 बक्से + मक्खी कॉलोनी (₹4,000)', en: '20 boxes with colonies at ₹4,000'), value: '₹80,000', oneTime: true),
      (item: (hi: 'औज़ार (एक्स्ट्रैक्टर, सूट, चाकू)', en: 'Tools (extractor, suit, knife)'), value: '₹20,000', oneTime: true),
      (item: (hi: 'चीनी + दवा (साल भर)', en: 'Sugar and medicine'), value: '₹15,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~700 किग्रा शहद × ₹250/किग्रा', en: '~700 kg honey at ₹250/kg'), value: '₹1,75,000', oneTime: false),
      (item: (hi: 'मोम + नई कॉलोनी बिक्री', en: 'Wax and new colony sales'), value: '₹25,000', oneTime: false),
    ],
    cycleMonths: 12,
    economicsNote: (
      hi: 'बक्से और औज़ार का ख़र्च एक ही बार लगता है — दूसरे साल से लगभग पूरा पैसा मुनाफ़ा है। राष्ट्रीय मधुमक्खी बोर्ड (NBB) से प्रशिक्षण और सब्सिडी मिलती है।',
      en: 'Boxes and tools are a one-time cost — from year two almost everything is profit. Training and subsidy are available from the National Bee Board.',
    ),
    mistakes: [
      (hi: '❌ **सर्दी/बरसात में खाना न देना** — फूल न मिलने पर कॉलोनी भूख से ख़त्म हो जाती है। चीनी का घोल दीजिए।', en: '❌ **Not feeding in winter/rains** — without flowers the colony starves. Feed sugar syrup.'),
      (hi: '❌ **पूरा शहद निकाल लेना** — कुछ हिस्सा मक्खियों के लिए छोड़िए, वरना कॉलोनी भाग जाती है।', en: '❌ **Harvesting all the honey** — leave some for the bees or the colony absconds.'),
    ],
    whereToBuy: [
      (hi: '🐝 KVK और राज्य बागवानी विभाग मधुमक्खी बक्से पर अनुदान देते हैं और मुफ़्त प्रशिक्षण भी। पहले प्रशिक्षण लीजिए, फिर बक्से।', en: '🐝 KVKs and state horticulture departments subsidise hives and train free. Take the training first, then buy hives.'),
    ],
    reminderPlan: [
      (day: 20, what: (hi: 'बक्सा खोलकर रानी और अंडे देखिए', en: 'Open hive, check queen and brood')),
      (day: 60, what: (hi: 'शहद का फ़्रेम भरा हो तो निकालिए', en: 'Extract honey if frames are full')),
      (day: 150, what: (hi: 'गर्मी: छाया और पानी का इंतज़ाम कीजिए', en: 'Summer: arrange shade and water')),
      (day: 210, what: (hi: 'बरसात: बक्सा ऊँचा रखें, चीनी का घोल दीजिए', en: 'Monsoon: raise hive, feed sugar syrup')),
      (day: 300, what: (hi: 'सर्दी: कॉलोनी को भोजन दीजिए, वरना भूख से ख़त्म', en: 'Winter: feed the colony or it starves')),
    ],
    selling: [
      (hi: 'सीधे ग्राहक को शुद्ध शहद — ₹400-600/किग्रा तक (कंपनी को ₹200-250)', en: 'Direct-to-customer honey fetches ₹400–600/kg versus ₹200–250 to companies'),
      (hi: 'बड़ी कंपनियाँ (डाबर, पतंजलि) थोक ख़रीदती हैं — पक्का बाज़ार', en: 'Big companies (Dabur, Patanjali) buy in bulk — assured market'),
      (hi: 'एक-फूल वाला शहद (सरसों/लीची/अजवाइन) अलग बेचें — दाम ज़्यादा', en: 'Sell single-flora honey (mustard/litchi/ajwain) separately at a premium'),
      (hi: 'मोम, पराग, रॉयल जेली — अलग से कमाई', en: 'Wax, pollen and royal jelly add extra income'),
    ],
  ),

  // ─────────────────────────── 12. टर्की ───────────────────────────
  PalanGuide(
    id: 'turkey',
    emoji: '🦃',
    name: (hi: 'टर्की पालन', en: 'Turkey Farming'),
    tagline: (hi: 'बड़ा पक्षी, बड़ा वज़न — कम प्रतिस्पर्धा', en: 'Big bird, big weight — little competition'),
    color: Color(0xFF5D4037),
    intro: (
      hi: 'टर्की का वज़न मुर्गी से 4-5 गुना होता है — नर 8-10 किग्रा तक। बीमारी कम लगती है और खुले में चरकर आधा पेट ख़ुद भर लेता है। भारत में प्रतिस्पर्धा कम है, इसलिए दाम अच्छा मिलता है — ख़ासकर क्रिसमस-नववर्ष पर।',
      en: 'Turkeys weigh 4–5× a chicken — toms reach 8–10 kg. They are hardy and forage for half their feed. Competition in India is low, so prices are good, especially at Christmas and New Year.',
    ),
    breeds: [
      (hi: 'ब्रॉड ब्रेस्टेड ब्रॉन्ज़ — भारी नस्ल, सबसे प्रचलित', en: 'Broad Breasted Bronze — heavy, most common'),
      (hi: 'ब्रॉड ब्रेस्टेड व्हाइट — सफ़ेद पंख, साफ़ शव (कारकस)', en: 'Broad Breasted White — white feathers, cleaner carcass'),
      (hi: 'बेल्ट्सविले स्मॉल व्हाइट — छोटी नस्ल, कम जगह', en: 'Beltsville Small White — smaller, needs less space'),
      (hi: 'देसी/नाटी टर्की — कम देखभाल, खुले पालन के लिए', en: 'Desi turkey — low input, suits free-range'),
    ],
    housing: [
      (hi: 'जगह: शेड में 3-4 वर्ग फुट + बाहर 20-25 वर्ग फुट प्रति पक्षी', en: 'Space: 3–4 sq ft indoors plus 20–25 sq ft outdoor run'),
      (hi: 'बैठने के लिए ऊँचा डंडा (पर्च) — टर्की ऊँचाई पर बैठना पसंद करती है', en: 'Provide perches — turkeys like to roost high'),
      (hi: 'बाड़े की जाली ऊँची (5-6 फुट) — टर्की उड़ भी लेती है', en: 'Fence 5–6 ft high — turkeys can fly'),
      (hi: 'बिछावन सूखा — गीले में पैर की बीमारी होती है', en: 'Dry litter — damp causes foot problems'),
    ],
    feed: [
      (stage: (hi: 'चूज़ा (0-4 हफ़्ते)', en: 'Poult (0–4 wk)'), feed: (hi: 'स्टार्टर (28% प्रोटीन) — मुर्गी से ज़्यादा', en: 'Starter (28% protein) — higher than chicks'), qty: (hi: '50-60 ग्राम/दिन', en: '50–60 g/day')),
      (stage: (hi: 'बढ़त (5-16 हफ़्ते)', en: 'Grower (5–16 wk)'), feed: (hi: 'ग्रोअर (22%) + हरी पत्ती/चराई', en: 'Grower (22%) + greens/range'), qty: (hi: '150-250 ग्राम/दिन', en: '150–250 g/day')),
      (stage: (hi: 'फिनिशर (17+ हफ़्ते)', en: 'Finisher (17+ wk)'), feed: (hi: 'फिनिशर (18-20%)', en: 'Finisher (18–20%)'), qty: (hi: '300-400 ग्राम/दिन', en: '300–400 g/day')),
    ],
    feedNotes: [
      (hi: 'चूज़े को पहले 3 दिन दाना पहचानना सिखाना पड़ता है — रंगीन कंचे/चमकदार बर्तन रखें।', en: 'Poults must be taught to eat in the first 3 days — use bright bowls or marbles.'),
      (hi: 'खुले में चराने से 30-40% दाना बचता है — हरी पत्तियाँ शौक़ से खाती है।', en: 'Ranging saves 30–40% feed — turkeys love greens.'),
    ],
    production: [
      (hi: 'नर-मादा अलग पालें — नर तेज़ी से बढ़ते हैं, दाना अलग चाहिए', en: 'Rear toms and hens separately — toms grow faster and need different feed'),
      (hi: 'नर 16-20 हफ़्ते (7-8 किग्रा) पर बेचें', en: 'Sell toms at 16–20 weeks (7–8 kg)'),
      (hi: 'क्रिसमस (दिसंबर) के लिए अगस्त में चूज़े डालें — दाम सबसे ऊँचे', en: 'Place poults in August for the December Christmas peak'),
      (hi: 'मादा साल में 60-100 अंडे देती है — चूज़े बेचकर अलग कमाई', en: 'Hens lay 60–100 eggs a year — selling poults adds income'),
    ],
    vaccines: [
      (when: (hi: '5-7 दिन, फिर 4 हफ़्ते', en: 'Day 5–7, then week 4'), what: (hi: 'रानीखेत (RD)', en: 'Ranikhet')),
      (when: (hi: '8 हफ़्ते', en: 'Week 8'), what: (hi: 'फाउल पॉक्स', en: 'Fowl pox')),
      (when: (hi: 'ज़रूरत पर', en: 'If needed'), what: (hi: 'फाउल कॉलरा', en: 'Fowl cholera')),
    ],
    diseases: [
      (hi: 'ब्लैकहेड (हिस्टोमोनियासिस) — टर्की की सबसे ख़ास बीमारी; मुर्गी के साथ न रखें।', en: 'Blackhead (histomoniasis) — turkey\'s signature disease; never rear with chickens.'),
      (hi: 'कॉक्सीडियोसिस — गीले बिछावन से खून वाला दस्त।', en: 'Coccidiosis — bloody droppings from wet litter.'),
      (hi: 'पैर की कमज़ोरी — तेज़ बढ़त और कैल्शियम की कमी से; खनिज मिलाएँ।', en: 'Leg weakness from fast growth and low calcium — add minerals.'),
    ],
    economicsUnit: (hi: '100 टर्की (एक चक्र, 5 माह)', en: '100 turkeys (one 5-month cycle)'),
    costs: [
      (item: (hi: '100 चूज़े (₹150)', en: '100 poults at ₹150'), value: '₹15,000', oneTime: false),
      (item: (hi: 'दाना (चराई के साथ)', en: 'Feed with ranging'), value: '₹60,000', oneTime: false),
      (item: (hi: 'शेड + जाली (एक बार)', en: 'Shed and fencing (one time)'), value: '₹50,000', oneTime: true),
      (item: (hi: 'दवा-टीका', en: 'Medicine and vaccines'), value: '₹4,000', oneTime: false),
    ],
    income: [
      (item: (hi: '~90 पक्षी × 6 किग्रा × ₹320/किग्रा', en: '~90 birds × 6 kg × ₹320/kg'), value: '₹1,72,000', oneTime: false),
    ],
    cycleMonths: 5,
    economicsNote: (
      hi: 'माँग अभी शहरों और क्रिसमस के आसपास ही ज़्यादा है — पहले ख़रीदार पक्का करें। मुर्गी के साथ कभी न पालें (ब्लैकहेड बीमारी का ख़तरा)।',
      en: 'Demand is mainly urban and around Christmas — secure buyers first. Never rear alongside chickens due to blackhead risk.',
    ),
    selling: [
      (hi: 'क्रिसमस-नववर्ष — दाम सबसे ऊँचे, पहले से बुकिंग लें', en: 'Christmas and New Year pay the most — take advance bookings'),
      (hi: 'शहर के रेस्तराँ, होटल, ईसाई बहुल इलाक़े (गोवा, केरल, पूर्वोत्तर)', en: 'City restaurants, hotels, Christian-majority regions (Goa, Kerala, North-East)'),
      (hi: 'चूज़े (poults) बेचना — दूसरे किसानों को अच्छी क़ीमत पर', en: 'Selling poults to other farmers fetches a good price'),
    ],
    reminderPlan: [
      (day: 6, what: (hi: 'रानीखेत (लासोटा)', en: 'Ranikhet (Lasota)')),
      (day: 28, what: (hi: 'रानीखेत दूसरी ख़ुराक', en: 'Ranikhet second dose')),
      (day: 56, what: (hi: 'फाउल पॉक्स', en: 'Fowl pox')),
    ],
  ),

  // ─────────────────────────── 13. एमू ───────────────────────────
  PalanGuide(
    id: 'emu',
    emoji: '🪶',
    name: (hi: 'एमू पालन', en: 'Emu Farming'),
    tagline: (hi: 'तेल, मांस, खाल — पर बाज़ार पहले पक्का करें', en: 'Oil, meat, leather — but confirm the market first'),
    color: Color(0xFF455A64),
    intro: (
      hi: 'एमू शुतुरमुर्ग जैसा बड़ा पक्षी है — 45-55 किग्रा तक। मांस, तेल (दवा में इस्तेमाल), खाल और अंडे — चारों की क़ीमत मिलती है। ⚠️ चेतावनी: भारत में 2010-15 के आसपास कई फ़र्ज़ी एमू कंपनियों ने किसानों को ठगा था। इसलिए **बाज़ार और ख़रीदार पक्का किए बिना कभी शुरू न करें।**',
      en: 'Emu is a large ratite reaching 45–55 kg, yielding meat, oil (used medicinally), leather and eggs. ⚠️ Warning: fake emu companies defrauded many Indian farmers around 2010–15 — never start without a confirmed buyer.',
    ),
    breeds: [
      (hi: 'एमू (ड्रोमैयस नोवेहॉलैंडिया) — भारत में यही एक नस्ल पाली जाती है', en: 'Emu (Dromaius novaehollandiae) — the only variety farmed in India'),
      (hi: 'शुतुरमुर्ग (ऑस्ट्रिच) — और बड़ा, पर भारत में बहुत कम और महँगा', en: 'Ostrich — larger but rare and costly in India'),
    ],
    housing: [
      (hi: 'खुला बाड़ा ज़रूरी: प्रति जोड़ी 2,500-3,000 वर्ग फुट (दौड़ने की जगह)', en: 'Open pen essential: 2,500–3,000 sq ft per pair for running'),
      (hi: 'बाड़ 6 फुट ऊँची, मज़बूत — एमू ज़ोर से टकराता है', en: 'Strong 6-ft fence — emus collide hard'),
      (hi: 'छाया के लिए शेड + पानी का बड़ा बर्तन', en: 'Shade shed plus a large water trough'),
      (hi: 'ज़मीन पर पत्थर/कील/प्लास्टिक न हो — एमू सब निगल लेता है और मर जाता है', en: 'Clear stones, nails and plastic — emus swallow them and die'),
    ],
    feed: [
      (stage: (hi: 'चूज़ा (0-3 माह)', en: 'Chick (0–3 m)'), feed: (hi: 'एमू स्टार्टर (22-24% प्रोटीन)', en: 'Emu starter (22–24% protein)'), qty: (hi: '250-400 ग्राम/दिन', en: '250–400 g/day')),
      (stage: (hi: 'बढ़त (4-12 माह)', en: 'Grower (4–12 m)'), feed: (hi: 'ग्रोअर + हरी पत्ती, सब्ज़ी', en: 'Grower + greens and vegetables'), qty: (hi: '600-800 ग्राम/दिन', en: '600–800 g/day')),
      (stage: (hi: 'बड़ा एमू', en: 'Adult'), feed: (hi: 'मेंटेनेंस दाना + हरा चारा', en: 'Maintenance feed + greens'), qty: (hi: '800 ग्राम-1 किग्रा/दिन', en: '800 g–1 kg/day')),
      (stage: (hi: 'अंडे देने वाला (प्रजनन)', en: 'Breeder'), feed: (hi: 'ब्रीडर दाना + कैल्शियम', en: 'Breeder feed + calcium'), qty: (hi: '1-1.2 किग्रा/दिन', en: '1–1.2 kg/day')),
    ],
    feedNotes: [
      (hi: 'हरी पत्तियाँ और सब्ज़ी का बचा हिस्सा देने से दाना-ख़र्च काफ़ी घटता है।', en: 'Greens and vegetable waste cut feed cost considerably.'),
      (hi: 'चारा नांद में ऊँचाई पर रखें (2 फुट) — एमू झुककर नहीं खाता।', en: 'Keep feeders about 2 ft high — emus do not stoop to eat.'),
    ],
    production: [
      (hi: 'अंडे सर्दी में (नवंबर-मार्च) — एक मादा 25-40 अंडे प्रति मौसम', en: 'Eggs come in winter (Nov–Mar) — 25–40 per female per season'),
      (hi: 'प्रजनन 18-24 माह की उम्र से शुरू', en: 'Breeding starts at 18–24 months'),
      (hi: 'मांस के लिए 15-18 माह (35-40 किग्रा) पर', en: 'Slaughter for meat at 15–18 months (35–40 kg)'),
      (hi: 'एक एमू से 5-6 लीटर तेल — यही सबसे क़ीमती उत्पाद है', en: 'Each bird yields 5–6 litres of oil — the most valuable product'),
      (hi: 'जोड़े (नर-मादा) में ही रखें — अकेला एमू अंडे नहीं देता', en: 'Keep as pairs — a lone bird will not breed'),
    ],
    vaccines: [
      (when: (hi: 'सामान्यतः ज़रूरी नहीं', en: 'Usually not needed'), what: (hi: 'एमू में रोग बहुत कम — साफ़ बाड़ा ही बचाव', en: 'Emus rarely fall ill — a clean pen is the protection')),
      (when: (hi: 'हर 6 माह', en: 'Every 6 months'), what: (hi: 'कृमिनाशक दवा', en: 'Deworming')),
    ],
    diseases: [
      (hi: 'बाहरी चीज़ निगलना — पत्थर, कील, प्लास्टिक; सबसे आम मौत का कारण।', en: 'Foreign body ingestion — stones, nails, plastic; the commonest cause of death.'),
      (hi: 'पैर मुड़ना (लेग डिफ़ॉर्मिटी) — फिसलन वाले फ़र्श और असंतुलित दाने से।', en: 'Leg deformity from slippery floors and unbalanced feed.'),
      (hi: 'कोक्सीडियोसिस — चूज़ों में, गीली गंदी ज़मीन से।', en: 'Coccidiosis in chicks from wet dirty ground.'),
    ],
    economicsUnit: (hi: '10 जोड़ी एमू (2 साल)', en: '10 emu pairs (2 years)'),
    costs: [
      (item: (hi: '20 एमू चूज़े (₹2,500)', en: '20 emu chicks at ₹2,500'), value: '₹50,000', oneTime: false),
      (item: (hi: 'बाड़ा + बाड़ (एक बार)', en: 'Pen and fencing (one time)'), value: '₹2,00,000', oneTime: true),
      (item: (hi: 'दाना (2 साल)', en: 'Feed for 2 years'), value: '₹1,80,000', oneTime: false),
      (item: (hi: 'दवा-मज़दूरी', en: 'Medicine and labour'), value: '₹20,000', oneTime: false),
    ],
    income: [
      (item: (hi: 'मांस ~18 पक्षी × 20 किग्रा × ₹350', en: 'Meat ~18 birds × 20 kg × ₹350'), value: '₹1,26,000', oneTime: false),
      (item: (hi: 'तेल ~100 लीटर × ₹1,200', en: 'Oil ~100 litres at ₹1,200'), value: '₹1,20,000', oneTime: false),
      (item: (hi: 'खाल + अंडे (सजावट)', en: 'Leather and decorative eggs'), value: '₹40,000', oneTime: false),
    ],
    cycleMonths: 24,
    economicsNote: (
      hi: '⚠️ सबसे ज़रूरी सलाह: एमू का बाज़ार भारत में अभी छोटा और अनिश्चित है। कोई कंपनी "हम वापस ख़रीद लेंगे" कहकर महँगे चूज़े बेचे तो सावधान रहें — यही ठगी का सबसे आम तरीक़ा है। पहले लिखित ख़रीदार, फिर पालन।',
      en: '⚠️ Key caution: India\'s emu market is small and uncertain. Beware companies selling costly chicks with buy-back promises — that is the classic scam. Get a written buyer first.',
    ),
    mistakes: [
      (hi: '❌ **"वापस ख़रीद लेंगे" के वादे पर महँगे चूज़े लेना** — एमू में यही सबसे बड़ी ठगी हुई है। लिखित समझौते और अपने बाज़ार के बिना मत शुरू कीजिए।', en: '❌ **Buying costly chicks on a buy-back promise** — the biggest scam in emu farming. Do not start without a written contract and your own market.'),
    ],
    whereToBuy: [
      (hi: '🦤 एमू शुरू करने से पहले अपने ज़िले में पूछिए कि मांस/तेल कौन ख़रीदता है। ख़रीदार न मिले तो यह धंधा मत कीजिए।', en: '🦤 Before starting emu, find out who buys the meat/oil in your district. No buyer means no business.'),
    ],
    reminderPlan: [
      (day: 1, what: (hi: 'चूज़ों को गर्म रखें (ब्रूडिंग) — पहला हफ़्ता सबसे नाज़ुक', en: 'Keep chicks warm (brooding) — week one is critical')),
      (day: 45, what: (hi: 'रानीखेत (RD) का टीका', en: 'Ranikhet (RD) vaccine')),
      (day: 90, what: (hi: 'पेट के कीड़े की दवा', en: 'Deworming')),
      (day: 180, what: (hi: 'कीड़े की दवा (हर 6 माह)', en: 'Deworming (every 6 months)')),
      (day: 365, what: (hi: 'सालाना जाँच — वज़न और पंजों की हालत', en: 'Yearly check — weight and leg condition')),
    ],
    selling: [
      (hi: 'एमू तेल — आयुर्वेदिक/कॉस्मेटिक कंपनियों को (सबसे बड़ा हिस्सा)', en: 'Emu oil to ayurvedic and cosmetic companies — the biggest share'),
      (hi: 'मांस — बड़े शहरों के विशेष मांस विक्रेता', en: 'Meat to speciality butchers in big cities'),
      (hi: 'खाल — चमड़ा उद्योग (महँगा चमड़ा माना जाता है)', en: 'Leather to the tanning industry — considered premium'),
      (hi: 'ख़ाली अंडे — नक़्क़ाशी/सजावट के लिए ₹500-1,500 प्रति अंडा', en: 'Empty eggs for carving and decor at ₹500–1,500 each'),
    ],
  ),
];
