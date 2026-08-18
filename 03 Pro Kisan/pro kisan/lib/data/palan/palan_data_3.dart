import 'package:flutter/material.dart';
import 'palan_model.dart';

/// पालन गाइड — भाग 3: गाय और भैंस
///
/// ये दोनों सबसे बाद में जोड़े गए, पर भारत में **सबसे ज़्यादा पशुपालक यही
/// करते हैं**। पहले ऐप में इनके लिए सिर्फ़ कैलकुलेटर थे (मेरे पशु, गाभिन,
/// आहार) — नस्ल, आवास, टीका, बीमारी, लागत-मुनाफ़ा कुछ नहीं था।
///
/// ⚠️ दाम अनुमानित हैं (अगस्त 2026)। दूध का रेट, चारे का दाम और पशु की क़ीमत
/// इलाक़े से बहुत बदलती है — शुरू करने से पहले अपने यहाँ का भाव देखिए।
///
/// स्रोत: ICAR-NDRI करनाल · NDDB आनंद (टीकाकरण अनुसूची, संतुलित आहार) ·
/// DAHD की NADCP · दाना का हिसाब ऐप के अपने आहार कैलकुलेटर जैसा ही
/// (1.5 किग्रा रखरखाव + 0.4 किग्रा प्रति लीटर दूध)।
const List<PalanGuide> kPalanPart3 = [
  // ─────────────────────────── गाय ───────────────────────────
  PalanGuide(
    id: 'gaay',
    emoji: '🐄',
    name: (hi: 'गाय पालन (दूध)', en: 'Cow Dairy Farming'),
    tagline: (hi: 'रोज़ की पक्की कमाई — दूध कभी बिना बिका नहीं रहता',
        en: 'Steady daily income — milk always sells'),
    color: Color(0xFF00796B),
    intro: (
      hi: 'गाय पालन भारत का सबसे बड़ा ग्रामीण धंधा है। सबसे बड़ा फ़ायदा — दूध रोज़ बिकता है, यानी रोज़ नक़द। दो बातें तय करती हैं कि मुनाफ़ा होगा या घाटा: **दाना दूध के हिसाब से देना** और **ब्याने का अंतर 13-14 महीने से ज़्यादा न बढ़ने देना**। जो पशुपालक इन दो बातों पर ध्यान देता है, उसी को कमाई होती है।',
      en: 'Cow dairying is India\'s biggest rural business — milk sells every day, so cash comes daily. Two things decide profit or loss: **feeding concentrate in proportion to milk yield** and **keeping the calving interval within 13-14 months**. Farmers who watch these two earn; others do not.',
    ),
    breeds: [
      (hi: 'साहीवाल — देसी, 8-12 लीटर/दिन, गर्मी सहती है, बीमारी कम। छोटे किसान के लिए सबसे सुरक्षित।', en: 'Sahiwal — indigenous, 8-12 L/day, heat tolerant, fewer diseases. Safest for smallholders.'),
      (hi: 'गिर — देसी, 10-15 लीटर/दिन, A2 दूध का ऊँचा दाम मिलता है', en: 'Gir — indigenous, 10-15 L/day, A2 milk fetches a premium'),
      (hi: 'रेड सिंधी / थारपारकर — कम चारे में भी टिकती हैं, सूखे इलाक़े के लिए', en: 'Red Sindhi / Tharparkar — survive on less feed, suited to dry areas'),
      (hi: 'HF संकर (होल्स्टीन) — 15-25 लीटर/दिन, पर गर्मी बर्दाश्त नहीं। पंखा-पानी और अच्छा दाना ज़रूरी, वरना घाटा।', en: 'HF crossbred — 15-25 L/day but cannot take heat. Needs fans, water and good feed, else it loses money.'),
      (hi: 'जर्सी संकर — 10-15 लीटर, HF से कम नाज़ुक, दूध में फ़ैट ज़्यादा', en: 'Jersey crossbred — 10-15 L, hardier than HF, higher fat'),
    ],
    housing: [
      (hi: 'जगह: एक गाय को 40 वर्ग फुट ढका + 80 वर्ग फुट खुला', en: 'Space: 40 sq ft covered + 80 sq ft open per cow'),
      (hi: 'फ़र्श पक्का पर खुरदुरा रखें और 1 इंच ढलान दें — फिसलन से थन और पैर की चोट सबसे आम है', en: 'Rough concrete floor with a 1-inch slope — slipping causes most udder and leg injuries'),
      (hi: 'छत की ऊँचाई 10-12 फुट, लंबाई पूर्व-पश्चिम — गर्मी में यही बचाता है', en: 'Roof 10-12 ft high, shed oriented east-west — this is the main heat protection'),
      (hi: 'गर्मी में पंखा और फुहारा (स्प्रिंकलर) — 35°C से ऊपर दूध सीधे 20-25% गिर जाता है', en: 'Fans and sprinklers in summer — above 35°C milk drops 20-25%'),
      (hi: 'साफ़ पानी हमेशा सामने — गाय दिन में 60-80 लीटर पानी पीती है। पानी कम तो दूध कम।', en: 'Clean water always available — a cow drinks 60-80 L a day. Less water means less milk.'),
    ],
    feed: [
      (stage: (hi: 'बछिया (0-6 माह)', en: 'Heifer calf (0-6 m)'), feed: (hi: 'दूध/मिल्क रिप्लेसर + काफ़ स्टार्टर + नरम हरा', en: 'Milk/replacer + calf starter + tender green'), qty: (hi: 'दूध 3-4 ली + दाना 0.5-1 किग्रा', en: 'Milk 3-4 L + starter 0.5-1 kg')),
      (stage: (hi: 'बढ़ती बछिया (6-24 माह)', en: 'Growing heifer (6-24 m)'), feed: (hi: 'हरा + सूखा चारा + दाना', en: 'Green + dry fodder + concentrate'), qty: (hi: 'हरा 10-15 किग्रा + दाना 1-2 किग्रा', en: 'Green 10-15 kg + concentrate 1-2 kg')),
      (stage: (hi: 'दूध देती गाय', en: 'Milking cow'), feed: (hi: 'हरा + सूखा + दाना (दूध के हिसाब से)', en: 'Green + dry + concentrate by yield'), qty: (hi: 'हरा 25-30 + भूसा 5-6 किग्रा · दाना = 1.5 किग्रा + हर लीटर दूध पर 400 ग्राम', en: 'Green 25-30 + straw 5-6 kg · concentrate = 1.5 kg + 400 g per litre of milk')),
      (stage: (hi: 'गाभिन / सूखी गाय', en: 'Pregnant / dry cow'), feed: (hi: 'हरा + सूखा + दाना + खनिज', en: 'Green + dry + concentrate + minerals'), qty: (hi: 'दाना 2-3 किग्रा (आख़िरी 2 माह में +1 किग्रा)', en: 'Concentrate 2-3 kg (+1 kg in last 2 months)')),
    ],
    feedNotes: [
      (hi: '📌 दाना का सीधा हिसाब: **1.5 किग्रा (रखरखाव) + हर लीटर दूध पर 400 ग्राम**। 10 लीटर देने वाली गाय = 1.5 + 4 = साढ़े 5 किग्रा दाना।', en: '📌 Simple rule: **1.5 kg (maintenance) + 400 g per litre of milk**. A 10-litre cow needs 1.5 + 4 = 5.5 kg concentrate.'),
      (hi: 'खनिज मिश्रण 50 ग्राम रोज़ — यह सबसे सस्ता ख़र्च है और गर्मी में आने (हीट) की सबसे बड़ी वजह। छोड़ा तो गाय समय पर गाभिन नहीं होगी।', en: 'Mineral mixture 50 g daily — the cheapest input and the key to regular heat. Skip it and the cow will not conceive on time.'),
      (hi: 'दाना मिश्रण: मक्का/जौ 35% + खली 30% + चोकर 30% + खनिज-नमक 5%', en: 'Concentrate mix: maize/barley 35% + oil cake 30% + bran 30% + mineral-salt 5%'),
      (hi: 'हरा चारा बदलते रहिए — बरसीम/लूसर्न (जाड़ा) और नेपियर/मक्का (गर्मी)। अकेला बरसीम ज़्यादा देने से अफारा होता है।', en: 'Rotate green fodder — berseem/lucerne in winter, napier/maize in summer. Too much berseem alone causes bloat.'),
    ],
    production: [
      (hi: '🎯 **ब्याने का अंतर 13-14 माह रखिए** — यही मुनाफ़े की असली चाबी है। ब्याने के 60-90 दिन के अंदर दोबारा गाभिन कराइए।', en: '🎯 **Keep the calving interval at 13-14 months** — this is the real key to profit. Re-breed within 60-90 days of calving.'),
      (hi: 'गर्मी (हीट) पर नज़र रखिए — सुबह-शाम 20 मिनट देखिए। हीट दिखने के 12-18 घंटे बाद कृत्रिम गर्भाधान (AI) कराइए।', en: 'Watch for heat — observe 20 minutes morning and evening. Inseminate 12-18 hours after heat is seen.'),
      (hi: 'दूध निकालने का समय रोज़ एक ही रखें और 5-7 मिनट में पूरा निकालें — बचा दूध थनैला (mastitis) बुलाता है।', en: 'Milk at the same time daily and finish in 5-7 minutes — leftover milk invites mastitis.'),
      (hi: 'ब्याने से 60 दिन पहले दूध बंद (ड्राई) कर दीजिए — अगला ब्यांत 15-20% ज़्यादा दूध देगा।', en: 'Dry off 60 days before calving — the next lactation yields 15-20% more.'),
      (hi: 'हर 6 माह पर पेट के कीड़े की दवा — बिना इसके खाया चारा बेकार जाता है।', en: 'Deworm every 6 months — without it the feed is wasted.'),
      (hi: 'बछिया 15-18 माह/250 किग्रा पर ही गाभिन कराएँ। जल्दी कराने से गाय जीवन भर छोटी रह जाती है।', en: 'Breed heifers at 15-18 months / 250 kg. Earlier breeding stunts her for life.'),
    ],
    vaccines: [
      (when: (hi: '4 माह की उम्र, 1 माह बाद बूस्टर, फिर हर 6 माह', en: '4 months, booster after 1 month, then every 6 months'), what: (hi: 'खुरपका-मुँहपका (FMD) — सबसे ज़रूरी', en: 'FMD — the most important')),
      (when: (hi: '4-8 माह की बछिया को जीवन में एक ही बार', en: 'Female calves 4-8 months — once in a lifetime'), what: (hi: 'ब्रूसेलोसिस (गर्भपात रोकने वाला टीका)', en: 'Brucellosis (prevents abortion)')),
      (when: (hi: '6 माह से ऊपर, फिर हर साल बरसात से पहले', en: 'Above 6 months, then yearly before monsoon'), what: (hi: 'गलघोंटू (HS)', en: 'Haemorrhagic Septicaemia (HS)')),
      (when: (hi: '6 माह से ऊपर, फिर हर साल', en: 'Above 6 months, then yearly'), what: (hi: 'लंगड़ी बुखार (BQ)', en: 'Black Quarter (BQ)')),
      (when: (hi: 'जहाँ बीमारी फैली हो, डॉक्टर की सलाह पर', en: 'In affected areas, on vet advice'), what: (hi: 'लंपी स्किन डिजीज (LSD)', en: 'Lumpy Skin Disease (LSD)')),
    ],
    diseases: [
      (hi: 'थनैला (मैस्टाइटिस) — थन गरम-सूजा, दूध में फटकन। **डेयरी का सबसे बड़ा नुक़सान यही है।** बचाव: दूध निकालने से पहले-बाद थन धोना और पूरा दूध निकालना।', en: 'Mastitis — hot swollen udder, clots in milk. **The single biggest loss in dairy.** Prevention: wash the udder before and after, and milk out completely.'),
      (hi: 'खुरपका-मुँहपका (FMD) — मुँह और खुर में छाले, दूध एकदम गिर जाता है। टीका ही एकमात्र बचाव।', en: 'FMD — blisters in mouth and hooves, milk collapses. Vaccination is the only protection.'),
      (hi: 'दुग्ध ज्वर (मिल्क फ़ीवर) — ब्याने के तुरंत बाद गाय बैठ जाती है, उठ नहीं पाती। कैल्शियम की कमी। तुरंत डॉक्टर बुलाइए, देर की तो जान जाती है।', en: 'Milk fever — the cow goes down right after calving. Calcium deficiency. Call the vet at once; delay kills.'),
      (hi: 'अफारा (पेट फूलना) — बाईं कोख फूली, साँस तेज़। ज़्यादा बरसीम या गीला चारा वजह।', en: 'Bloat — swollen left flank, fast breathing. Caused by excess berseem or wet fodder.'),
      (hi: 'लंपी स्किन डिजीज — खाल पर गाँठें, बुख़ार। मच्छर-मक्खी से फैलती है, इसलिए शेड की सफ़ाई ज़रूरी।', en: 'Lumpy Skin Disease — nodules on the skin with fever. Spread by flies, so shed hygiene matters.'),
    ],
    economicsUnit: (hi: '5 दूध देती गाय (एक साल)', en: '5 milking cows (one year)'),
    costs: [
      (item: (hi: '5 गाय ख़रीद (₹60,000 औसत)', en: 'Buying 5 cows (avg ₹60,000)'), value: '₹3,00,000', oneTime: true),
      (item: (hi: 'शेड (5 गाय, पक्का फ़र्श)', en: 'Shed (5 cows, concrete floor)'), value: '₹1,50,000', oneTime: true),
      (item: (hi: 'चारा काटने की मशीन + बर्तन', en: 'Chaff cutter + utensils'), value: '₹40,000', oneTime: true),
      (item: (hi: 'दाना + हरा-सूखा चारा (साल भर)', en: 'Concentrate + green/dry fodder (year)'), value: '₹3,60,000', oneTime: false),
      (item: (hi: 'दवा-टीका-AI-डॉक्टर', en: 'Medicine, vaccines, AI, vet'), value: '₹25,000', oneTime: false),
      (item: (hi: 'बिजली-पानी-मज़दूरी', en: 'Power, water, labour'), value: '₹40,000', oneTime: false),
    ],
    income: [
      (item: (hi: 'दूध — 5 गाय × 10 ली × 300 दिन × ₹38', en: 'Milk — 5 cows × 10 L × 300 days × ₹38'), value: '₹5,70,000', oneTime: false),
      (item: (hi: 'गोबर की खाद / गोबर गैस', en: 'Dung manure / biogas'), value: '₹25,000', oneTime: false),
      (item: (hi: 'बछिया-बछड़े की बिक्री', en: 'Sale of calves'), value: '₹40,000', oneTime: false),
    ],
    economicsNote: (
      hi: 'दूध का रेट (यहाँ ₹38/लीटर) और चारे का दाम इलाक़े से बहुत बदलता है — अपने यहाँ का भाव डालकर ख़ुद जोड़िए। सबसे बड़ी बात: अपना हरा चारा बोइए। ख़रीदा चारा लागत लगभग दोगुनी कर देता है।',
      en: 'The milk rate (₹38/L here) and fodder cost vary a lot by area — redo the maths with your local rates. Most important: grow your own green fodder. Bought fodder nearly doubles the cost.',
    ),
    cycleMonths: 12,
    selling: [
      (hi: 'दूध सहकारी समिति (अमूल/सुधा/नंदिनी जैसी) — रोज़ का पक्का भुगतान और फ़ैट के हिसाब से दाम', en: 'Dairy cooperative (Amul/Sudha/Nandini type) — assured payment, price by fat content'),
      (hi: 'घर-घर सीधी बिक्री — सबसे ऊँचा दाम (₹50-60/लीटर) पर रोज़ की मेहनत ज़्यादा', en: 'Direct home delivery — best price (₹50-60/L) but daily effort'),
      (hi: 'दूध से पनीर, दही, घी बनाकर बेचिए — दाम डेढ़-दो गुना हो जाता है', en: 'Make paneer, curd, ghee — value goes up 1.5-2 times'),
      (hi: 'गोबर की खाद और गोबर गैस — कई पशुपालक इसे भूल जाते हैं, यह मुफ़्त की कमाई है', en: 'Dung manure and biogas — many forget this free income'),
      (hi: 'A2 दूध (साहीवाल/गिर) की अलग माँग है — शहर में ₹80-120/लीटर तक मिलता है', en: 'A2 milk (Sahiwal/Gir) has its own market — ₹80-120/L in cities'),
    ],
    mistakes: [
      (hi: '❌ **दूध के हिसाब से दाना न देना** — 15 लीटर देने वाली गाय को 5 लीटर वाला दाना देंगे तो वह अपना शरीर गलाकर दूध बनाएगी, फिर दुबली होकर गाभिन नहीं होगी।', en: '❌ **Not matching concentrate to yield** — feed a 15-litre cow like a 5-litre one and she milks off her own body, goes thin and fails to conceive.'),
      (hi: '❌ **ब्याने का अंतर बढ़ने देना** — 18-20 महीने का अंतर मतलब साल भर का दूध कम। हर महीने की देरी सीधा घाटा है।', en: '❌ **Letting the calving interval slip** — an 18-20 month interval means a lost year of milk. Every month of delay is direct loss.'),
      (hi: '❌ **खनिज मिश्रण न देना** — 50 ग्राम रोज़ का ख़र्च बचाकर हज़ारों का नुक़सान। गाय समय पर हीट में नहीं आएगी।', en: '❌ **Skipping mineral mixture** — saving 50 g a day costs thousands. She will not come into heat on time.'),
      (hi: '❌ **HF गाय बिना पंखे-पानी के पालना** — वह ठंडे देश की नस्ल है। 35°C से ऊपर उसका दूध और सेहत दोनों गिरते हैं।', en: '❌ **Keeping HF cows without cooling** — a temperate breed. Above 35°C both milk and health drop.'),
      (hi: '❌ **थन की सफ़ाई में लापरवाही** — थनैला एक बार हुआ तो वह थन अक्सर हमेशा के लिए ख़राब हो जाता है।', en: '❌ **Careless udder hygiene** — once mastitis strikes, that quarter is often lost forever.'),
    ],
    whereToBuy: [
      (hi: '🐄 गाय ख़रीदते समय **दूसरे या तीसरे ब्यांत की** गाय लीजिए — तब वह सबसे ज़्यादा दूध देती है और उसका रिकॉर्ड भी देखा जा सकता है।', en: '🐄 Buy a cow in her **second or third lactation** — peak yield and a visible track record.'),
      (hi: '⚠️ ख़रीदने से पहले **अपने सामने दूध निकलवाइए** (सुबह और शाम दोनों बार)। दलाल की बताई संख्या पर कभी भरोसा मत कीजिए।', en: '⚠️ **Milk her yourself before buying**, both morning and evening. Never trust the dealer\'s figure.'),
      (hi: '🏛️ गोकुल ग्राम, सरकारी पशु फ़ार्म और NDDB की सहकारी समितियाँ — शुद्ध देसी नस्ल के लिए।', en: '🏛️ Gokul Gram, government cattle farms and NDDB cooperatives — for pure indigenous breeds.'),
      (hi: '💉 कृत्रिम गर्भाधान (AI) से बछिया लीजिए — बढ़िया साँड़ का वीर्य ₹50-300 में मिलता है, और अगली पीढ़ी ज़्यादा दूध देती है। सेक्स-सॉर्टेड वीर्य से 90% बछिया ही होती है।', en: '💉 Breed your own heifers by AI — quality bull semen costs ₹50-300 and the next generation yields more. Sex-sorted semen gives ~90% female calves.'),
    ],
    schemes: [
      (hi: '🐄 **राष्ट्रीय गोकुल मिशन (RGM)** — देसी नस्ल सुधार, मुफ़्त/सस्ता कृत्रिम गर्भाधान और सेक्स-सॉर्टेड वीर्य पर अनुदान।', en: '🐄 **Rashtriya Gokul Mission** — indigenous breed improvement, free/subsidised AI and support for sex-sorted semen.'),
      (hi: '🥛 **डेयरी सहकारी समिति की सदस्यता** — रोज़ का पक्का भुगतान, पशु आहार सस्ते दाम पर, और मुफ़्त पशु चिकित्सा सेवा। सबसे पहले यही कीजिए।', en: '🥛 **Join a dairy cooperative** — assured daily payment, subsidised cattle feed and free veterinary service. Do this first.'),
      (hi: '🏦 **AHIDF (पशुपालन अवसंरचना विकास निधि)** — डेयरी इकाई, दूध प्रसंस्करण और चारा संयंत्र पर 3% ब्याज छूट के साथ कर्ज़।', en: '🏦 **AHIDF** — loans with 3% interest subvention for dairy units, milk processing and feed plants.'),
    ],
    reminderPlan: [
      (day: 120, what: (hi: 'FMD (खुरपका-मुँहपका) का पहला टीका', en: 'First FMD vaccine')),
      (day: 150, what: (hi: 'FMD बूस्टर + ब्रूसेलोसिस (सिर्फ़ बछिया को, जीवन में एक बार)', en: 'FMD booster + Brucellosis (heifers only, once in life)')),
      (day: 180, what: (hi: 'गलघोंटू (HS) और लंगड़ी बुख़ार (BQ) का टीका', en: 'HS and BQ vaccines')),
      (day: 210, what: (hi: 'पेट के कीड़े की दवा', en: 'Deworming')),
      (day: 300, what: (hi: 'FMD (हर 6 माह पर)', en: 'FMD (every 6 months)')),
      (day: 390, what: (hi: 'कीड़े की दवा + खनिज की जाँच', en: 'Deworming + mineral check')),
      (day: 545, what: (hi: 'HS/BQ सालाना बूस्टर (बरसात से पहले)', en: 'HS/BQ yearly booster (before monsoon)')),
    ],
    priceAsOf: 'अगस्त 2026',
  ),

  // ─────────────────────────── भैंस ───────────────────────────
  PalanGuide(
    id: 'bhains',
    emoji: '🐃',
    name: (hi: 'भैंस पालन (दूध)', en: 'Buffalo Dairy Farming'),
    tagline: (hi: 'गाढ़ा दूध, ऊँचा दाम — फ़ैट पर पैसा मिलता है',
        en: 'Rich milk, higher rate — you get paid for fat'),
    color: Color(0xFF37474F),
    intro: (
      hi: 'भारत का आधे से ज़्यादा दूध भैंस से आता है। भैंस के दूध में फ़ैट 6-8% होता है (गाय में 3.5-4%), और डेयरी फ़ैट के हिसाब से पैसा देती है — इसलिए प्रति लीटर दाम ₹10-15 ज़्यादा मिलता है। भैंस गर्मी कम बर्दाश्त करती है पर घटिया चारा गाय से बेहतर पचा लेती है।',
      en: 'More than half of India\'s milk comes from buffaloes. Buffalo milk has 6-8% fat (cow 3.5-4%) and dairies pay by fat, so the rate is ₹10-15 higher per litre. Buffaloes take heat poorly but digest coarse fodder better than cows.',
    ),
    breeds: [
      (hi: 'मुर्रा (हरियाणा) — सबसे अच्छी नस्ल, 10-15 लीटर/दिन, पूरे भारत में चलती है', en: 'Murrah (Haryana) — the best breed, 10-15 L/day, works all over India'),
      (hi: 'नीली-रावी (पंजाब) — 8-12 लीटर, मुर्रा जैसी पर थोड़ी कम', en: 'Nili-Ravi (Punjab) — 8-12 L, similar to Murrah but slightly less'),
      (hi: 'जाफ़राबादी (गुजरात) — सबसे भारी, 10-12 लीटर, फ़ैट सबसे ज़्यादा', en: 'Jaffarabadi (Gujarat) — heaviest, 10-12 L, highest fat'),
      (hi: 'मेहसाणा — मुर्रा × सूरती, गुजरात-राजस्थान में लोकप्रिय, 8-10 लीटर', en: 'Mehsana — Murrah × Surti, popular in Gujarat/Rajasthan, 8-10 L'),
      (hi: 'सूरती / भदावरी — छोटी, कम चारा, फ़ैट 8% तक — घी बनाने के लिए सबसे बढ़िया', en: 'Surti / Bhadawari — small, less feed, fat up to 8% — best for ghee'),
    ],
    housing: [
      (hi: 'जगह: एक भैंस को 50 वर्ग फुट ढका + 100 वर्ग फुट खुला (गाय से ज़्यादा, भैंस बड़ी होती है)', en: 'Space: 50 sq ft covered + 100 sq ft open per buffalo (more than a cow)'),
      (hi: '**नहाने या भीगने का इंतज़ाम ज़रूरी** — भैंस को पसीना नहीं आता, इसलिए गर्मी में दिन में 2-3 बार पानी डालिए। यही सबसे बड़ी बात है।', en: '**Wallowing or hosing is essential** — buffaloes cannot sweat, so hose them 2-3 times a day in summer. This matters most.'),
      (hi: 'छाया के लिए पेड़ या घनी छत — सीधी धूप में भैंस का दूध सबसे तेज़ गिरता है', en: 'Trees or a thick roof for shade — buffalo milk falls fastest in direct sun'),
      (hi: 'फ़र्श पक्का, खुरदुरा और ढलान वाला — भैंस भारी होती है, फिसली तो चोट गंभीर होती है', en: 'Rough sloped concrete floor — buffaloes are heavy and a slip causes serious injury'),
      (hi: 'साफ़ पानी हमेशा — भैंस दिन में 80-100 लीटर पानी पीती है', en: 'Clean water always — a buffalo drinks 80-100 L a day'),
    ],
    feed: [
      (stage: (hi: 'पड़िया (0-6 माह)', en: 'Female calf (0-6 m)'), feed: (hi: 'दूध + काफ़ स्टार्टर + नरम हरा', en: 'Milk + calf starter + tender green'), qty: (hi: 'दूध 3-4 ली + दाना 0.5-1 किग्रा', en: 'Milk 3-4 L + starter 0.5-1 kg')),
      (stage: (hi: 'बढ़ती पड़िया (6-30 माह)', en: 'Growing heifer (6-30 m)'), feed: (hi: 'हरा + सूखा + दाना', en: 'Green + dry + concentrate'), qty: (hi: 'हरा 12-18 किग्रा + दाना 1-2 किग्रा', en: 'Green 12-18 kg + concentrate 1-2 kg')),
      (stage: (hi: 'दूध देती भैंस', en: 'Milking buffalo'), feed: (hi: 'हरा + सूखा + दाना (दूध के हिसाब से)', en: 'Green + dry + concentrate by yield'), qty: (hi: 'हरा 30-35 + भूसा 6-8 किग्रा · दाना = 2 किग्रा + हर लीटर दूध पर 450 ग्राम', en: 'Green 30-35 + straw 6-8 kg · concentrate = 2 kg + 450 g per litre')),
      (stage: (hi: 'गाभिन / सूखी भैंस', en: 'Pregnant / dry buffalo'), feed: (hi: 'हरा + सूखा + दाना + खनिज', en: 'Green + dry + concentrate + minerals'), qty: (hi: 'दाना 2.5-3.5 किग्रा (आख़िरी 2 माह में +1 किग्रा)', en: 'Concentrate 2.5-3.5 kg (+1 kg in last 2 months)')),
    ],
    feedNotes: [
      (hi: '📌 भैंस का दाना गाय से ज़्यादा: **2 किग्रा (रखरखाव) + हर लीटर पर 450 ग्राम** — क्योंकि दूध में फ़ैट ज़्यादा बनाना पड़ता है। ऐप का आहार कैलकुलेटर भी यही हिसाब लगाता है।', en: '📌 Buffaloes need more than cows: **2 kg (maintenance) + 450 g per litre** — the milk carries more fat. The app\'s feed calculator uses the same rule.'),
      (hi: 'खनिज मिश्रण 50-60 ग्राम रोज़ — भैंस में "गर्मी में न आना" (साइलेंट हीट) की सबसे बड़ी वजह खनिज की कमी है।', en: 'Mineral mixture 50-60 g daily — mineral deficiency is the main cause of silent heat in buffaloes.'),
      (hi: 'भैंस भूसा और घटिया चारा गाय से बेहतर पचाती है — यही उसका बड़ा फ़ायदा है।', en: 'Buffaloes digest straw and coarse fodder better than cows — that is their big advantage.'),
      (hi: 'बरसीम अकेला ज़्यादा मत दीजिए, भूसे में मिलाकर दीजिए — वरना अफारा हो जाता है।', en: 'Do not feed berseem alone in bulk; mix with straw or bloat follows.'),
    ],
    production: [
      (hi: '🎯 **साइलेंट हीट भैंस की सबसे बड़ी समस्या है** — वह गर्मी में आती है पर लक्षण नहीं दिखते। इसलिए सुबह जल्दी और रात को देखिए, और खनिज मिश्रण कभी मत छोड़िए।', en: '🎯 **Silent heat is the buffalo\'s biggest problem** — she comes into heat without visible signs. Watch early morning and at night, and never skip minerals.'),
      (hi: 'भैंस को गर्मियों में ब्याने से बचाइए — सर्दियों में ब्याई भैंस ज़्यादा दूध देती है', en: 'Avoid summer calving — buffaloes calving in winter give more milk'),
      (hi: 'ब्याने का अंतर 14-15 माह रखिए (गाय से थोड़ा ज़्यादा चलता है)', en: 'Keep the calving interval at 14-15 months (slightly longer than cows is normal)'),
      (hi: 'दिन में 2-3 बार पानी डालना = 1-2 लीटर ज़्यादा दूध। यह सबसे सस्ता उपाय है।', en: 'Hosing 2-3 times a day = 1-2 litres more milk. The cheapest improvement there is.'),
      (hi: 'ब्याने से 60 दिन पहले दूध बंद कीजिए', en: 'Dry off 60 days before calving'),
      (hi: 'हर 6 माह पर पेट के कीड़े की दवा', en: 'Deworm every 6 months'),
    ],
    vaccines: [
      (when: (hi: '4 माह की उम्र, 1 माह बाद बूस्टर, फिर हर 6 माह', en: '4 months, booster after 1 month, then every 6 months'), what: (hi: 'खुरपका-मुँहपका (FMD)', en: 'FMD')),
      (when: (hi: '4-8 माह की पड़िया को जीवन में एक बार', en: 'Female calves 4-8 months — once in a lifetime'), what: (hi: 'ब्रूसेलोसिस', en: 'Brucellosis')),
      (when: (hi: '6 माह से ऊपर, हर साल बरसात से पहले', en: 'Above 6 months, yearly before monsoon'), what: (hi: 'गलघोंटू (HS) — भैंस में यह सबसे जानलेवा है', en: 'Haemorrhagic Septicaemia (HS) — deadliest in buffaloes')),
      (when: (hi: '6 माह से ऊपर, हर साल', en: 'Above 6 months, yearly'), what: (hi: 'लंगड़ी बुख़ार (BQ)', en: 'Black Quarter (BQ)')),
    ],
    diseases: [
      (hi: 'गलघोंटू (HS) — तेज़ बुख़ार, गले में सूजन, साँस लेने में तकलीफ़। **भैंस में यह कुछ ही घंटों में जान ले लेती है।** बरसात से पहले टीका ज़रूर लगवाइए।', en: 'HS — high fever, throat swelling, breathing distress. **In buffaloes it can kill within hours.** Vaccinate before the monsoon.'),
      (hi: 'थनैला (मैस्टाइटिस) — थन गरम-सूजा, दूध में फटकन। भैंस के थन ज़मीन के पास होते हैं इसलिए सफ़ाई और भी ज़रूरी।', en: 'Mastitis — hot swollen udder, clots. Buffalo udders sit low, so hygiene matters even more.'),
      (hi: 'लू लगना (हीट स्ट्रेस) — हाँफना, दूध गिरना, चारा छोड़ना। भैंस को पसीना नहीं आता — पानी डालना ही इलाज है।', en: 'Heat stress — panting, milk drop, off feed. Buffaloes cannot sweat; hosing is the remedy.'),
      (hi: 'दुग्ध ज्वर — ब्याने के बाद बैठ जाना। कैल्शियम की कमी, तुरंत डॉक्टर।', en: 'Milk fever — going down after calving. Calcium deficiency; call the vet immediately.'),
      (hi: 'अफारा — बाईं कोख फूली। ज़्यादा हरा/गीला चारा वजह।', en: 'Bloat — swollen left flank from excess green or wet fodder.'),
    ],
    economicsUnit: (hi: '5 दूध देती भैंस (एक साल)', en: '5 milking buffaloes (one year)'),
    costs: [
      (item: (hi: '5 भैंस ख़रीद (₹85,000 औसत)', en: 'Buying 5 buffaloes (avg ₹85,000)'), value: '₹4,25,000', oneTime: true),
      (item: (hi: 'शेड (5 भैंस, पानी के इंतज़ाम सहित)', en: 'Shed (5 buffaloes, with wallow/hosing)'), value: '₹1,75,000', oneTime: true),
      (item: (hi: 'चारा मशीन + बर्तन', en: 'Chaff cutter + utensils'), value: '₹40,000', oneTime: true),
      (item: (hi: 'दाना + हरा-सूखा चारा (साल भर)', en: 'Concentrate + fodder (year)'), value: '₹4,00,000', oneTime: false),
      (item: (hi: 'दवा-टीका-AI-डॉक्टर', en: 'Medicine, vaccines, AI, vet'), value: '₹25,000', oneTime: false),
      (item: (hi: 'बिजली-पानी-मज़दूरी', en: 'Power, water, labour'), value: '₹45,000', oneTime: false),
    ],
    income: [
      (item: (hi: 'दूध — 5 भैंस × 8 ली × 280 दिन × ₹52', en: 'Milk — 5 buffaloes × 8 L × 280 days × ₹52'), value: '₹5,82,000', oneTime: false),
      (item: (hi: 'गोबर की खाद / गोबर गैस', en: 'Dung manure / biogas'), value: '₹30,000', oneTime: false),
      (item: (hi: 'पड़िया-पड़वा की बिक्री', en: 'Sale of calves'), value: '₹50,000', oneTime: false),
    ],
    economicsNote: (
      hi: 'भैंस का दूध फ़ैट के हिसाब से बिकता है — 7% फ़ैट पर ₹50-58/लीटर तक मिल जाता है, जबकि गाय के दूध पर ₹35-40। इसीलिए कम लीटर देने पर भी भैंस की कमाई बराबर या ज़्यादा रहती है। पर गर्मी में पानी का इंतज़ाम न हो तो दूध 25-30% गिर जाता है और यह पूरा हिसाब बदल जाता है।',
      en: 'Buffalo milk is paid by fat — at 7% fat it fetches ₹50-58/L versus ₹35-40 for cow milk. So even with fewer litres, earnings match or beat cows. But without summer cooling, milk drops 25-30% and this whole calculation changes.',
    ),
    cycleMonths: 12,
    selling: [
      (hi: 'दूध सहकारी समिति — भैंस के दूध पर फ़ैट के कारण सबसे अच्छा दाम मिलता है', en: 'Dairy cooperative — buffalo milk gets the best rate because of fat'),
      (hi: 'घी और खोया बनाकर बेचिए — भैंस के दूध का घी सबसे अच्छा माना जाता है, दाम डेढ़-दो गुना', en: 'Make ghee and khoya — buffalo ghee is prized, 1.5-2× the value'),
      (hi: 'मिठाई की दुकान और होटल से सीधा सौदा — पनीर-खोया के लिए भैंस का दूध ही चाहिए', en: 'Sell direct to sweet shops and hotels — they need buffalo milk for paneer and khoya'),
      (hi: 'गोबर की खाद और गोबर गैस — भैंस गाय से ज़्यादा गोबर देती है', en: 'Dung manure and biogas — buffaloes give more dung than cows'),
      (hi: 'अच्छी मुर्रा पड़िया की अलग माँग है — ₹50,000-80,000 तक बिक जाती है', en: 'Good Murrah heifers sell separately for ₹50,000-80,000'),
    ],
    mistakes: [
      (hi: '❌ **गर्मी में पानी का इंतज़ाम न करना** — भैंस को पसीना नहीं आता। यह अकेली ग़लती दूध 25-30% गिरा देती है। दिन में 2-3 बार पानी डालना सबसे सस्ता मुनाफ़ा है।', en: '❌ **No summer cooling** — buffaloes cannot sweat. This one mistake cuts milk 25-30%. Hosing 2-3 times a day is the cheapest profit there is.'),
      (hi: '❌ **साइलेंट हीट पकड़ न पाना** — भैंस बिना लक्षण दिखाए गर्मी में आ जाती है। सुबह जल्दी और रात को देखिए, वरना ब्याने का अंतर 20 महीने हो जाएगा।', en: '❌ **Missing silent heat** — she cycles without visible signs. Watch early morning and at night, else the calving interval stretches to 20 months.'),
      (hi: '❌ **गलघोंटू (HS) का टीका छोड़ देना** — भैंस में यह बीमारी कुछ घंटों में जान ले लेती है। बरसात से पहले हर साल ज़रूरी।', en: '❌ **Skipping the HS vaccine** — it can kill a buffalo within hours. Mandatory every year before the monsoon.'),
      (hi: '❌ **दूध के हिसाब से दाना न देना** — भैंस को गाय से ज़्यादा दाना चाहिए (2 किग्रा + 450 ग्राम प्रति लीटर), क्योंकि फ़ैट बनाने में ज़्यादा ताक़त लगती है।', en: '❌ **Under-feeding concentrate** — buffaloes need more than cows (2 kg + 450 g per litre) because making fat takes more energy.'),
    ],
    whereToBuy: [
      (hi: '🐃 **दूसरे या तीसरे ब्यांत की भैंस** लीजिए और ब्याने के 1-2 महीने के अंदर वाली — तब उसका असली दूध दिख जाता है।', en: '🐃 Buy in the **second or third lactation**, within 1-2 months of calving — you can see the true yield.'),
      (hi: '⚠️ **अपने सामने दोनों समय दूध निकलवाइए।** भैंस बेचते समय दलाल अक्सर एक बार का दूध बताकर दोगुना दाम माँगते हैं।', en: '⚠️ **Have her milked in front of you, both times.** Dealers often quote one milking and double the price.'),
      (hi: '🏛️ CIRB हिसार (केंद्रीय भैंस अनुसंधान संस्थान) और हरियाणा-पंजाब के सरकारी फ़ार्म — शुद्ध मुर्रा के लिए।', en: '🏛️ CIRB Hisar (Central Buffalo Research Institute) and Haryana/Punjab government farms — for pure Murrah.'),
      (hi: '💉 मुर्रा साँड़ के वीर्य से कृत्रिम गर्भाधान कराइए — अगली पीढ़ी 2-3 लीटर ज़्यादा दूध देगी।', en: '💉 Use Murrah bull semen for AI — the next generation yields 2-3 litres more.'),
    ],
    schemes: [
      (hi: '🐃 **राष्ट्रीय गोकुल मिशन** में भैंस की नस्ल सुधार भी शामिल है — मुर्रा वीर्य और कृत्रिम गर्भाधान पर अनुदान।', en: '🐃 **Rashtriya Gokul Mission** also covers buffalo breed improvement — subsidy on Murrah semen and AI.'),
      (hi: '🥛 **डेयरी सहकारी समिति** — भैंस के दूध पर फ़ैट के हिसाब से सबसे अच्छा दाम यहीं मिलता है। सदस्यता सबसे पहले लीजिए।', en: '🥛 **Dairy cooperative** — the best fat-based rate for buffalo milk. Join first.'),
      (hi: '🏦 **AHIDF** — डेयरी इकाई और दूध प्रसंस्करण पर 3% ब्याज छूट वाला कर्ज़।', en: '🏦 **AHIDF** — loans with 3% interest subvention for dairy units and processing.'),
    ],
    reminderPlan: [
      (day: 120, what: (hi: 'FMD (खुरपका-मुँहपका) का पहला टीका', en: 'First FMD vaccine')),
      (day: 150, what: (hi: 'FMD बूस्टर + ब्रूसेलोसिस (सिर्फ़ पड़िया को, जीवन में एक बार)', en: 'FMD booster + Brucellosis (heifers only, once in life)')),
      (day: 180, what: (hi: 'गलघोंटू (HS) — भैंस में सबसे ज़रूरी टीका', en: 'HS vaccine — the most critical for buffaloes')),
      (day: 195, what: (hi: 'लंगड़ी बुख़ार (BQ) का टीका', en: 'Black Quarter (BQ) vaccine')),
      (day: 210, what: (hi: 'पेट के कीड़े की दवा', en: 'Deworming')),
      (day: 300, what: (hi: 'FMD (हर 6 माह पर)', en: 'FMD (every 6 months)')),
      (day: 390, what: (hi: 'कीड़े की दवा + खनिज की जाँच', en: 'Deworming + mineral check')),
      (day: 520, what: (hi: 'HS/BQ सालाना बूस्टर — बरसात से पहले ज़रूर', en: 'HS/BQ yearly booster — must be before monsoon')),
    ],
    priceAsOf: 'अगस्त 2026',
  ),
];
