class FarmingAdvisory {
  final String id;
  final String category; // 'organic', 'soil', 'irrigation', 'pest', 'crop_mgmt', 'vegetable', 'fruit', 'spice', 'livestock', 'subsidy'
  final String titleHi;
  final String titleEn;
  final String detailHi;
  final String detailEn;
  final List<String> applicableCrops; // list of crop ids like ['paddy', 'wheat', 'sugarcane']

  const FarmingAdvisory({
    required this.id,
    required this.category,
    required this.titleHi,
    required this.titleEn,
    required this.detailHi,
    required this.detailEn,
    this.applicableCrops = const [],
  });

  String title(bool isHindi) => isHindi ? titleHi : titleEn;
  String detail(bool isHindi) => isHindi ? detailHi : detailEn;
}

const List<FarmingAdvisory> kFarmingAdvisories = [
  // ── ORGANIC ──
  FarmingAdvisory(
    id: 'gobar_manure',
    category: 'organic',
    titleHi: '🐄 गोबर की खाद (Farmyard Manure) बनाने व प्रयोग का सही तरीका',
    titleEn: '🐄 Right way to make and use Gobar Manure',
    detailHi: 'गोबर को धूप में खुला छोड़ने से उसके पोषक तत्व नष्ट हो जाते हैं। इसके लिए छायादार गड्ढा बनाएं। 3-4 महीने में सड़ी हुई भुरभुरी खाद तैयार होगी। इसे बुवाई से 15-20 दिन पहले 2 से 3 टन प्रति बीघा की दर से मिट्टी में अच्छी तरह मिला लें।',
    detailEn: 'Leaving manure open in the sun destroys nutrients. Make a shaded pit. In 3-4 months, well-rotted dark manure will be ready. Apply 2-3 tons per bigha and mix well into the soil 15-20 days before sowing.',
  ),
  FarmingAdvisory(
    id: 'vermi_compost',
    category: 'organic',
    titleHi: '🌱 केंचुआ खाद (Vermicompost) बेड तैयार करना',
    titleEn: '🌱 Preparing Vermicompost Bed at home',
    detailHi: 'ठंडी छायादार जगह पर 3 फीट चौड़ा और 1.5 फीट ऊंचा बेड बनाएं। नीचे सूखे अवशेष और गोबर डालें। पानी छिड़ककर नमी बनाए रखें और केंचुए छोड़ें। ऊपर से बोरी ढक दें। 45-60 दिन में चाय की पत्ती जैसी चायदार उपजाऊ खाद मिलेगी।',
    detailEn: 'Make a 3ft wide and 1.5ft high bed in a cool shaded area. Layer agricultural waste and half-rotted cow dung. Maintain moisture and release earthworms. Cover with gunny bags. Fertile vermicompost will be ready in 45-60 days.',
  ),
  FarmingAdvisory(
    id: 'jeevamrit',
    category: 'organic',
    titleHi: '🧪 जीवामृत: मिट्टी की उपजाऊ शक्ति बढ़ाने का अमृत',
    titleEn: '🧪 Jeevamrut: Microbial booster for soil health',
    detailHi: '200 लीटर पानी के ड्रम में 10 किलो गोबर, 10 लीटर गोमूत्र, 2 किलो गुड़, 2 किलो बेसन और 1 मुट्ठी खेत की मेड़ की मिट्टी मिलाएं। 5-7 दिन तक छाया में सुबह-शाम डंडे से चलाएं। तैयार जीवामृत को पानी के साथ खेतों में छिड़कें।',
    detailEn: 'In a 200L water drum, mix 10kg cow dung, 10L cow urine, 2kg jaggery, 2kg chickpea flour, and a handful of farm soil. Stir daily in the shade for 5-7 days. Apply this solution with irrigation water.',
  ),
  FarmingAdvisory(
    id: 'neem_astra',
    category: 'organic',
    titleHi: '🌿 नीम-अस्त्र: प्राकृतिक जैविक कीटनाशक बनाने की विधि',
    titleEn: '🌿 Neem-astra: Organic pest control recipe',
    detailHi: '10 लीटर गोमूत्र में 5 किलो नीम की पत्तियों की चटनी और 1 किलो गोबर घोलें। 48 घंटे के लिए छाया में फर्मेंट होने दें। छानकर 100 लीटर पानी में 2 लीटर नीम-अस्त्र मिलाकर छिड़काव करें। रस चूसने वाले कीटों के लिए यह रामबाण है।',
    detailEn: 'Mix 10L cow urine, 5kg crushed neem leaves, and 1kg cow dung. Ferment in the shade for 48 hours. Filter the mix. Dilute 2L Neem-astra in 100L water and spray. Excellent against sucking pests.',
  ),
  FarmingAdvisory(
    id: 'dashparni_ark',
    category: 'organic',
    titleHi: '🍃 दशपर्णी अर्क: विभिन्न रोगों व कीटों से फसल सुरक्षा',
    titleEn: '🍃 Dashparni Ark: Ultimate organic pesticide',
    detailHi: 'नीम, करंज, अरंडी, धतूरा, बेल, आक सहित 10 अलग-अलग औषधीय पौधों की 2-2 किलो पत्तियां लें। इन्हें गोमूत्र और गोबर के साथ ड्रम में 30-45 दिन फर्मेंट होने दें। 200 लीटर पानी में 3 लीटर अर्क मिलाकर छिड़काव करें।',
    detailEn: 'Take 2kg leaves from 10 different medicinal plants (neem, datura, castor, etc.). Ferment with cow urine and dung in a drum for 30-45 days. Mix 3L of this extract in 200L of water and spray.',
  ),
  FarmingAdvisory(
    id: 'green_manure',
    category: 'organic',
    titleHi: '🌾 हरी खाद (ढैंचा / सनई) का खेतों में उपयोग',
    titleEn: '🌾 Green Manuring (Dhaincha/Sunnhemp) benefits',
    detailHi: 'धान या गेहूं की बुवाई से 45-50 दिन पहले ढैंचा या सनई की बुवाई करें। जब इनमें फूल आने लगें, तब रोटावेटर या हैरो से इसे खेत की मिट्टी में दबा दें। यह मिट्टी को भरपूर नाइट्रोजन और कार्बनिक तत्व प्रदान करता है।',
    detailEn: 'Sow Dhaincha or Sunnhemp 45-50 days before main crop. Just before flowering, plough them back into the soil with a rotavator. It adds nitrogen and organic matter to the soil.',
  ),
  FarmingAdvisory(
    id: 'ghan_jeevamrut',
    category: 'organic',
    titleHi: '🔶 घनजीवामृत (ठोस जैविक खाद) भंडारण और प्रयोग',
    titleEn: '🔶 Ghanjeevamrut (Solid Organic Fertilizer)',
    detailHi: '100 किलो सूखे गोबर के चूर्ण में 5 लीटर जीवामृत मिलाकर अच्छी तरह मिला लें। इसे फैलाकर छांव में सुखा लें। यह ठोस खाद 6 महीने तक खराब नहीं होती। बुवाई के समय इसे 100 किलो प्रति एकड़ की दर से मिट्टी में डालें।',
    detailEn: 'Mix 100kg dry cow dung powder with 5L Jeevamrut. Spread and dry under shade. This solid fertilizer stays good for 6 months. Apply 100kg per acre into the soil during sowing.',
  ),

  // ── SOIL ──
  FarmingAdvisory(
    id: 'soil_sample',
    category: 'soil',
    titleHi: '🧪 मिट्टी जांच (Soil Test) के लिए नमूना कैसे लें',
    titleEn: '🧪 How to collect soil sample for testing',
    detailHi: 'खेत के 5 अलग-अलग कोनों से उपरी सूखी घास हटाएं। V-आकार में 6 इंच गहरा गड्ढा खोदकर दोनों तरफ की मिट्टी खुरचें। इन्हें मिलाकर आधा किलो नमूना तैयार करें। इसे सुखाकर मिट्टी जांच प्रयोगशाला या KVK भेजें।',
    detailEn: 'Remove top grass from 5 spots on your farm. Dig a 6-inch V-shaped pit and scrape soil from the sides. Mix all samples to get a 0.5kg sample. Dry and send to KVK for test.',
  ),
  FarmingAdvisory(
    id: 'gypsum_treatment',
    category: 'soil',
    titleHi: '🧂 क्षारीय/ऊसर मिट्टी सुधार में जिप्सम का उपयोग',
    titleEn: '🧂 Using Gypsum for alkaline soil correction',
    detailHi: 'अगर आपकी मिट्टी का pH 8.5 से अधिक है (क्षारीय या ऊसर), तो मिट्टी जांच रिपोर्ट के अनुसार जिप्सम का छिड़काव करें। जिप्सम डालने के बाद खेत में पानी भरकर रखें। इससे मिट्टी का सोडियम घुलकर बाहर निकल जाता है।',
    detailEn: 'If soil pH is above 8.5 (alkaline), apply gypsum based on soil test. Keep field flooded after application. This leaches out sodium and improves soil structure.',
  ),

  // ── IRRIGATION ──
  FarmingAdvisory(
    id: 'drip_savings',
    category: 'irrigation',
    titleHi: '💧 बूंद-बूंद (Drip) सिंचाई से पानी व खाद की बचत',
    titleEn: '💧 Drip Irrigation: Save water and fertilizer',
    detailHi: 'ड्रिप सिंचाई से पानी सीधे पौधों की जड़ों में जाता है। इससे 40-50% पानी की बचत होती है। ड्रिप लाइन के जरिए घुलनशील खादों (Fertigation) को देना सबसे आसान होता है, जिससे खाद सीधे जड़ क्षेत्र में उपयोग होती है।',
    detailEn: 'Drip systems deliver water directly to the plant root zone. Saves 40-50% water. You can apply soluble fertilizers directly through drip lines (fertigation) for maximum uptake.',
  ),
  FarmingAdvisory(
    id: 'sprinkler_use',
    category: 'irrigation',
    titleHi: '🌧️ स्प्रिंकलर (फव्वारा) सिंचाई: ऊंचे-नीचे खेतों के लिए उत्तम',
    titleEn: '🌧️ Sprinkler Irrigation for uneven farms',
    detailHi: 'ऊंची-नीची (ढलान वाली) जमीनों और रेतीली मिट्टी के लिए स्प्रिंकलर सिंचाई सबसे उपयुक्त है। गेहूं, सरसों और चने जैसी फसलों में यह कम पानी में बेहतरीन पैदावार देती है। हवा की गति कम होने पर ही स्प्रिंकलर चलाएं।',
    detailEn: 'Sprinklers are ideal for uneven sandy soils. Delivers uniform water to crops like wheat, mustard, and gram with low water usage. Operate sprinklers when wind is low.',
  ),

  // ── PEST ──
  FarmingAdvisory(
    id: 'yellow_sticky_trap',
    category: 'pest',
    titleHi: '🟨 पीला स्टिकी ट्रैप (Yellow Sticky Trap) का उपयोग',
    titleEn: '🟨 Yellow Sticky Trap for whitefly and aphids',
    detailHi: 'खेत में उड़ने वाले छोटे कीट (जैसे सफेद मक्खी, हरा तेला, थ्रिप्स) को नियंत्रित करने के लिए पीले कार्डबोर्ड पर ग्रीस या मोबिल ऑयल लगाकर लटकाएं। कीट पीले रंग से आकर्षित होकर चिपक जाते हैं। प्रति एकड़ 8-10 ट्रैप लगाएं।',
    detailEn: 'Hang yellow plastic sheets coated with grease or engine oil. Flying pests (whitefly, aphids, thrips) are attracted to yellow color and get stuck. Place 8-10 traps per acre.',
  ),
  FarmingAdvisory(
    id: 'trichoderma_treatment',
    category: 'pest',
    titleHi: '🛡️ ट्राइकोडर्मा (Trichoderma) से जड़ गलन रोग की रोकथाम',
    titleEn: '🛡️ Preventing Root Rot with Trichoderma',
    detailHi: 'ट्राइकोडर्मा एक मित्र फफूंद है। बुवाई से पहले 5-10 ग्राम ट्राइकोडर्मा प्रति किलो बीज की दर से बीजोपचार करें। गोबर की खाद में मिलाकर इसे सीधे मिट्टी में भी डाला जा सकता है। यह फफूंदजनित रोगों को खत्म करता है।',
    detailEn: 'Trichoderma is a beneficial bio-fungicide. Treat seeds with 5-10g per kg of seeds before sowing. It can also be mixed with Gobar manure and applied to soil to control fungal diseases.',
  ),

  // ── CROP MGMT ──
  FarmingAdvisory(
    id: 'crop_rotation_legume',
    category: 'crop_mgmt',
    titleHi: '🌾 दलहनी फसलों का फसल चक्र में महत्व',
    titleEn: '🌾 Importance of legume crop rotation',
    detailHi: 'अनाज (धान, गेहूं, मक्का) के बाद चना, मूंग या उड़द जैसी दलहनी फसलें अवश्य लगाएं। दलहनी फसलों की जड़ें हवा की नाइट्रोजन को मिट्टी में संचित (Nitrogen Fixation) करती हैं, जिससे अगली फसल में यूरिया कम लगता है।',
    detailEn: 'Always rotate cereal crops (paddy, wheat, maize) with pulses (gram, moong, urad). Legumes fix atmospheric nitrogen in soil, reducing urea requirements for next crop.',
    applicableCrops: ['wheat', 'paddy', 'maize', 'gram', 'moong', 'urad', 'lentil', 'pigeonpea'],
  ),
  FarmingAdvisory(
    id: 'wheat_first_irrigation',
    category: 'crop_mgmt',
    titleHi: '🌾 गेहूं में मुकुट जड़ बनते समय (CRI Stage) पहली सिंचाई',
    titleEn: '🌾 Wheat: First irrigation at CRI stage',
    detailHi: 'गेहूं की बुवाई के 20-25 दिन बाद मुकुट जड़ (CRI) निकलती हैं। इस समय खेत में पानी की कमी होने से पैदावार काफी कम हो जाती है। पहली सिंचाई बहुत हल्की करें और तुरंत बाद यूरिया की पहली टॉप-ड्रेसिंग करें।',
    detailEn: 'Wheat Crown Root Initiation (CRI) occurs 20-25 days after sowing. Water stress at this stage severely drops yield. Give a light first irrigation and top-dress urea.',
    applicableCrops: ['wheat'],
  ),
  FarmingAdvisory(
    id: 'paddy_weed_mgmt',
    category: 'crop_mgmt',
    titleHi: '🌾 धान की रोपाई के शुरुआती दिनों में खरपतवार नियंत्रण',
    titleEn: '🌾 Paddy (Rice) weed management tip',
    detailHi: 'धान रोपाई के पहले 3-4 हफ्तों तक खेत में 2-3 इंच पानी भरकर रखें। इससे खरपतवार नहीं उग पाते। खरपतवार नाशक (जैसे Pretilachlor) का प्रयोग रोपाई के 3 दिन के भीतर गीली मिट्टी में ही करें।',
    detailEn: 'Keep 2-3 inches of standing water in paddy fields for the first 3-4 weeks to naturally suppress weed growth. Apply pre-emergence herbicide within 3 days of transplanting.',
    applicableCrops: ['paddy'],
  ),

  // ── VEGETABLE ──
  FarmingAdvisory(
    id: 'onion_nursery',
    category: 'vegetable',
    titleHi: '🧅 प्याज की नर्सरी (Nursery) तैयार करने की विधि',
    titleEn: '🧅 Preparing Onion Nursery beds',
    detailHi: 'प्याज की नर्सरी के लिए उठी हुई क्यारियां (Raised Beds) बनाएं। बीजों को फफूंदनाशक से उपचारित कर 2 इंच की दूरी पर बोएं। ऊपर से सड़ी गोबर की पतली परत ढकें। 6-7 सप्ताह में पौधे रोपाई के लिए तैयार हो जाएंगे।',
    detailEn: 'Sow onion seeds on raised nursery beds. Treat seeds with fungicide. Space seeds 2 inches apart and cover with a thin layer of compost. Seedlings will be ready in 6-7 weeks.',
    applicableCrops: ['onion'],
  ),
  FarmingAdvisory(
    id: 'tomato_staking',
    category: 'vegetable',
    titleHi: '🍅 टमाटर के पौधों को सहारा (Staking) देना',
    titleEn: '🍅 Staking Tomato plants for clean yield',
    detailHi: 'टमाटर के पौधों को बांस और रस्सी के सहारे सीधा खड़ा रखें। इससे फल मिट्टी और पानी के संपर्क में नहीं आते, जिससे वे सड़ने से बचते हैं और फलों की गुणवत्ता चमकदार व बाजार में अच्छी कीमत दिलाने वाली होती है।',
    detailEn: 'Stake tomato vines with bamboo poles and thread. Staking keeps fruits off the ground, reducing fruit rot and improving shape, color and market price.',
    applicableCrops: ['tomato'],
  ),

  // ── FRUIT ──
  FarmingAdvisory(
    id: 'banana_bahar',
    category: 'fruit',
    titleHi: '🍌 केले की फसल में मिट्टी चढ़ाना और सूखी पत्तियां काटना',
    titleEn: '🍌 Banana: Earthing up and pruning dry leaves',
    detailHi: 'केले के तने के आसपास की मिट्टी चढ़ाएं ताकि तेज हवा में पौधा गिरे नहीं। पुरानी और सूखी पीली पत्तियों को समय-समय पर काटते रहें। इससे धूप अंदर तक पहुंचती है और कीटों का प्रकोप काफी कम हो जाता है।',
    detailEn: 'Earth up soil around banana stems to provide support against high winds. Prune dry and yellow leaves regularly. This improves sunlight penetration and reduces pest pressure.',
    applicableCrops: ['banana'],
  ),
  FarmingAdvisory(
    id: 'coconut_basin',
    category: 'fruit',
    titleHi: '🥥 नारियल के थाले (Basin) का प्रबंधन व उर्वरक डालना',
    titleEn: '🥥 Coconut basin management and manuring',
    detailHi: 'पेड़ के चारों ओर 1.8 मीटर त्रिज्या का थाला बनाएं। साल में दो बार (मानसून पूर्व और बाद) प्रत्येक पेड़ में 50 किलो गोबर की खाद, 1.3 किलो यूरिया, 2 किलो सुपर फॉस्फेट और 2 किलो पोटाश डालें और मिट्टी से ढक दें।',
    detailEn: 'Maintain a 1.8m radius basin around the coconut tree base. Apply 50kg compost, 1.3kg urea, 2kg super phosphate, and 2kg potash per palm twice a year (pre- and post-monsoon).',
    applicableCrops: ['coconut'],
  ),

  // ── SPICE ──
  FarmingAdvisory(
    id: 'turmeric_mulch',
    category: 'spice',
    titleHi: '🟨 हल्दी की खेती में पुआल का मल्चिंग (Mulching)',
    titleEn: '🟨 Mulching in Turmeric with straw',
    detailHi: 'हल्दी की बुवाई के तुरंत बाद सूखी पत्तियों या पुआल से क्यारियों को ढक दें (मल्चिंग)। इससे मिट्टी की नमी बनी रहती है, खरपतवार नहीं उग पाते और हल्दी के कंदों (rhizomes) का आकार तेजी से बड़ा होता है।',
    detailEn: 'Cover turmeric beds with green leaves or straw immediately after sowing. Mulching conserves moisture, prevents weeds, and promotes rapid rhizome development.',
    applicableCrops: ['turmeric'],
  ),
  FarmingAdvisory(
    id: 'pepper_standard',
    category: 'spice',
    titleHi: '🌿 काली मिर्च के लिए सहायक पेड़ों (Standards) की छंटाई',
    titleEn: '🌿 Pruning support trees for Black Pepper vines',
    detailHi: 'काली मिर्च की बेल जिन पेड़ों (जैसे सिल्विया, ग्लिरिसिडिया) पर चढ़ती है, उनकी शाखाओं की मानसून से पहले छंटाई करें। इससे काली मिर्च की बेलों को भरपूर धूप मिलती है और फंगल रोगों (जैसे क्विक विल्ट) का खतरा कम होता है।',
    detailEn: 'Prune branches of support trees (like gliricidia) before monsoon. This ensures the climbing pepper vines receive adequate sunlight and reduces quick wilt disease risk.',
    applicableCrops: ['blackpepper'],
  ),

  // ── LIVESTOCK ──
  FarmingAdvisory(
    id: 'green_fodder',
    category: 'livestock',
    titleHi: '🐄 दुधारू पशुओं के लिए हरे चारे (Green Fodder) का महत्व',
    titleEn: '🐄 Importance of Green Fodder for dairy cows',
    detailHi: 'दूध उत्पादन बढ़ाने के लिए पशुओं को रोजाना 15-20 किलो हरा चारा (जैसे बरसीम, नेपियर, बाजरा) जरूर दें। हरे चारे में भरपूर विटामिन-ए और खनिज लवण होते हैं, जो पशुओं के स्वास्थ्य और फैट प्रतिशत को सुधारते हैं।',
    detailEn: 'Feed 15-20kg green fodder (berseem, napier, bajra) daily. Green fodder provides vitamin A and minerals, improving cattle milk yield and fat percentage.',
  ),
  FarmingAdvisory(
    id: 'cattle_mastitis',
    category: 'livestock',
    titleHi: '🐄 थनैला रोग (Mastitis) से बचाव के आसान उपाय',
    titleEn: '🐄 Preventing Mastitis (Thanal) in dairy cattle',
    detailHi: 'थनैला रोग दूध निकालने के बाद थनों में गंदगी जाने से होता है। दूध दुहने से पहले और बाद में थनों को पोटेशियम परमैंगनेट के घोल से धोएं। दुहने के 30 मिनट बाद तक पशु को बैठने न दें (हरे चारे की व्यवस्था करें)।',
    detailEn: 'Mastitis is caused by bacteria entering udder after milking. Wash teats with antiseptic before and after milking. Keep the cow standing for 30 minutes after milking.',
  ),

  // ── SUBSIDY ──
  FarmingAdvisory(
    id: 'kcc_interest_subvention',
    category: 'subsidy',
    titleHi: '💰 किसान क्रेडिट कार्ड (KCC) ब्याज माफी योजना',
    titleEn: '💰 KCC Interest Subvention Scheme benefit',
    detailHi: 'KCC पर ब्याज दर 9% होती है, लेकिन सरकार 2% छूट देती है जिससे यह 7% रह जाता है। यदि आप 1 साल के भीतर समय पर लोन चुका देते हैं, तो 3% अतिरिक्त छूट (Prompt Repayment) मिलती है। लोन सिर्फ 4% ब्याज पर पड़ता है।',
    detailEn: 'KCC interest is 9%, but Gov offers 2% discount making it 7%. If you repay within 1 year, you get 3% extra discount. Net interest rate drops to only 4% per year.',
  ),
  FarmingAdvisory(
    id: 'custom_hiring_subsidy',
    category: 'subsidy',
    titleHi: '🚜 कृषि यंत्रों पर 50-80% सब्सिडी (Custom Hiring Centre)',
    titleEn: '🚜 Get 50-80% subsidy on Agri Machinery',
    detailHi: 'छोटे ट्रैक्टर, रोटावेटर, कंबाइन आदि खरीदने के लिए सरकार सीमांत किसानों और सहकारी समितियों को 50 से 80% तक सब्सिडी देती है। आवेदन करने के लिए अपने राज्य के DBT कृषि पोर्टल पर ऑनलाइन पंजीकरण करें।',
    detailEn: 'Government offers 50-80% subsidy on buying rotavator, tractor, combine harvester under custom hiring schemes. Apply online on state DBT agriculture portal.',
  ),
];
