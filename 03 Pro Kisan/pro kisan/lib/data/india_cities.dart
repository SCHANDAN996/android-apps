/// मौसम search के लिए भारत के 200+ बड़े शहर + ज़िला केंद्र।
///
/// Open-Meteo का geocoding बहुत छोटे गाँव/मंडी नहीं जानता, इसलिए यह
/// offline list पहले सुझाव देती है — internet न भी हो तो user कोई भी
/// प्रमुख शहर तुरंत चुन सकता है।
///
/// क्रम: राज्य-वार, हर राज्य में राजधानी + बड़े ज़िले।
/// हर एंट्री में हिंदी + English नाम — user कुछ भी लिखे, मिल जाए।
library;

class IndiaCity {
  final String hi;
  final String en;
  /// राज्य का हिंदी नाम (सुझाव में subtitle के तौर पर दिखेगा)
  final String stateHi;
  final String stateEn;
  final double lat;
  final double lon;

  const IndiaCity({
    required this.hi,
    required this.en,
    required this.stateHi,
    required this.stateEn,
    required this.lat,
    required this.lon,
  });

  /// खोज के लिए — दोनों भाषा में मिलान करो (case + space insensitive)
  bool matches(String q) {
    final needle = q.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return hi.toLowerCase().contains(needle) ||
        en.toLowerCase().contains(needle);
  }

  String name(bool isHi) => isHi ? hi : en;
  String stateName(bool isHi) => isHi ? stateHi : stateEn;
}

/// 200+ भारतीय शहर/ज़िले — सभी राज्यों को शामिल किया है ताकि हर किसान को
/// अपने पास का कम-से-कम एक शहर मिल जाए।
const List<IndiaCity> kIndiaCities = [
  // ── उत्तर प्रदेश (सबसे बड़ा — 25+) ──
  IndiaCity(hi:'लखनऊ', en:'Lucknow', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.85, lon:80.95),
  IndiaCity(hi:'कानपुर', en:'Kanpur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.45, lon:80.33),
  IndiaCity(hi:'आगरा', en:'Agra', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.18, lon:78.02),
  IndiaCity(hi:'वाराणसी', en:'Varanasi', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:25.32, lon:82.97),
  IndiaCity(hi:'प्रयागराज', en:'Prayagraj', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:25.44, lon:81.85),
  IndiaCity(hi:'गोरखपुर', en:'Gorakhpur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.76, lon:83.37),
  IndiaCity(hi:'मेरठ', en:'Meerut', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.98, lon:77.71),
  IndiaCity(hi:'बरेली', en:'Bareilly', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.36, lon:79.42),
  IndiaCity(hi:'अलीगढ़', en:'Aligarh', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.88, lon:78.08),
  IndiaCity(hi:'मुरादाबाद', en:'Moradabad', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.83, lon:78.78),
  IndiaCity(hi:'गाज़ियाबाद', en:'Ghaziabad', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.67, lon:77.45),
  IndiaCity(hi:'नोएडा', en:'Noida', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.54, lon:77.39),
  IndiaCity(hi:'सहारनपुर', en:'Saharanpur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:29.97, lon:77.55),
  IndiaCity(hi:'फ़िरोज़ाबाद', en:'Firozabad', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.15, lon:78.40),
  IndiaCity(hi:'झाँसी', en:'Jhansi', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:25.45, lon:78.57),
  IndiaCity(hi:'मुज़फ़्फ़रनगर', en:'Muzaffarnagar', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:29.47, lon:77.71),
  IndiaCity(hi:'मथुरा', en:'Mathura', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.49, lon:77.67),
  IndiaCity(hi:'अयोध्या', en:'Ayodhya', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.79, lon:82.20),
  IndiaCity(hi:'रामपुर', en:'Rampur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:28.81, lon:79.02),
  IndiaCity(hi:'शाहजहाँपुर', en:'Shahjahanpur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.88, lon:79.91),
  IndiaCity(hi:'फ़ैज़ाबाद', en:'Faizabad', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.77, lon:82.13),
  IndiaCity(hi:'फ़र्रुख़ाबाद', en:'Farrukhabad', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.39, lon:79.58),
  IndiaCity(hi:'मैनपुरी', en:'Mainpuri', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.24, lon:79.03),
  IndiaCity(hi:'हरदोई', en:'Hardoi', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.40, lon:80.13),
  IndiaCity(hi:'सीतापुर', en:'Sitapur', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:27.57, lon:80.68),
  IndiaCity(hi:'बलिया', en:'Ballia', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:25.75, lon:84.15),
  IndiaCity(hi:'देवरिया', en:'Deoria', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.50, lon:83.78),
  IndiaCity(hi:'बस्ती', en:'Basti', stateHi:'उत्तर प्रदेश', stateEn:'Uttar Pradesh', lat:26.81, lon:82.72),

  // ── बिहार ──
  IndiaCity(hi:'पटना', en:'Patna', stateHi:'बिहार', stateEn:'Bihar', lat:25.59, lon:85.14),
  IndiaCity(hi:'गया', en:'Gaya', stateHi:'बिहार', stateEn:'Bihar', lat:24.79, lon:85.00),
  IndiaCity(hi:'भागलपुर', en:'Bhagalpur', stateHi:'बिहार', stateEn:'Bihar', lat:25.24, lon:87.00),
  IndiaCity(hi:'मुज़फ़्फ़रपुर', en:'Muzaffarpur', stateHi:'बिहार', stateEn:'Bihar', lat:26.12, lon:85.36),
  IndiaCity(hi:'दरभंगा', en:'Darbhanga', stateHi:'बिहार', stateEn:'Bihar', lat:26.15, lon:85.90),
  IndiaCity(hi:'पूर्णिया', en:'Purnia', stateHi:'बिहार', stateEn:'Bihar', lat:25.78, lon:87.47),
  IndiaCity(hi:'आरा', en:'Arrah', stateHi:'बिहार', stateEn:'Bihar', lat:25.55, lon:84.66),
  IndiaCity(hi:'बेगूसराय', en:'Begusarai', stateHi:'बिहार', stateEn:'Bihar', lat:25.42, lon:86.13),
  IndiaCity(hi:'कटिहार', en:'Katihar', stateHi:'बिहार', stateEn:'Bihar', lat:25.54, lon:87.58),
  IndiaCity(hi:'सहरसा', en:'Saharsa', stateHi:'बिहार', stateEn:'Bihar', lat:25.88, lon:86.60),
  IndiaCity(hi:'छपरा', en:'Chhapra', stateHi:'बिहार', stateEn:'Bihar', lat:25.78, lon:84.75),
  IndiaCity(hi:'बेतिया', en:'Bettiah', stateHi:'बिहार', stateEn:'Bihar', lat:26.80, lon:84.50),
  IndiaCity(hi:'नालंदा', en:'Nalanda', stateHi:'बिहार', stateEn:'Bihar', lat:25.14, lon:85.44),
  IndiaCity(hi:'मुंगेर', en:'Munger', stateHi:'बिहार', stateEn:'Bihar', lat:25.37, lon:86.47),

  // ── मध्य प्रदेश ──
  IndiaCity(hi:'भोपाल', en:'Bhopal', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:23.26, lon:77.41),
  IndiaCity(hi:'इंदौर', en:'Indore', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:22.72, lon:75.86),
  IndiaCity(hi:'ग्वालियर', en:'Gwalior', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:26.22, lon:78.18),
  IndiaCity(hi:'जबलपुर', en:'Jabalpur', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:23.18, lon:79.98),
  IndiaCity(hi:'उज्जैन', en:'Ujjain', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:23.18, lon:75.78),
  IndiaCity(hi:'सागर', en:'Sagar', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:23.83, lon:78.73),
  IndiaCity(hi:'सतना', en:'Satna', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:24.57, lon:80.83),
  IndiaCity(hi:'रीवा', en:'Rewa', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:24.53, lon:81.30),
  IndiaCity(hi:'रतलाम', en:'Ratlam', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:23.33, lon:75.03),
  IndiaCity(hi:'देवास', en:'Dewas', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:22.97, lon:76.05),
  IndiaCity(hi:'मुरैना', en:'Morena', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:26.50, lon:78.00),
  IndiaCity(hi:'खंडवा', en:'Khandwa', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:21.83, lon:76.35),
  IndiaCity(hi:'छिंदवाड़ा', en:'Chhindwara', stateHi:'मध्य प्रदेश', stateEn:'Madhya Pradesh', lat:22.06, lon:78.94),

  // ── राजस्थान ──
  IndiaCity(hi:'जयपुर', en:'Jaipur', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:26.91, lon:75.79),
  IndiaCity(hi:'जोधपुर', en:'Jodhpur', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:26.24, lon:73.03),
  IndiaCity(hi:'कोटा', en:'Kota', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:25.22, lon:75.86),
  IndiaCity(hi:'बीकानेर', en:'Bikaner', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:28.02, lon:73.31),
  IndiaCity(hi:'अजमेर', en:'Ajmer', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:26.45, lon:74.64),
  IndiaCity(hi:'उदयपुर', en:'Udaipur', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:24.58, lon:73.68),
  IndiaCity(hi:'भिलवाड़ा', en:'Bhilwara', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:25.35, lon:74.63),
  IndiaCity(hi:'अलवर', en:'Alwar', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:27.55, lon:76.63),
  IndiaCity(hi:'श्रीगंगानगर', en:'Sri Ganganagar', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:29.92, lon:73.88),
  IndiaCity(hi:'सीकर', en:'Sikar', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:27.62, lon:75.14),
  IndiaCity(hi:'भरतपुर', en:'Bharatpur', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:27.22, lon:77.49),
  IndiaCity(hi:'पाली', en:'Pali', stateHi:'राजस्थान', stateEn:'Rajasthan', lat:25.77, lon:73.32),

  // ── महाराष्ट्र ──
  IndiaCity(hi:'मुंबई', en:'Mumbai', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:19.08, lon:72.88),
  IndiaCity(hi:'पुणे', en:'Pune', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:18.52, lon:73.86),
  IndiaCity(hi:'नागपुर', en:'Nagpur', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:21.15, lon:79.09),
  IndiaCity(hi:'नाशिक', en:'Nashik', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:19.99, lon:73.79),
  IndiaCity(hi:'औरंगाबाद', en:'Aurangabad', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:19.88, lon:75.34),
  IndiaCity(hi:'सोलापुर', en:'Solapur', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:17.66, lon:75.91),
  IndiaCity(hi:'अमरावती', en:'Amravati', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:20.94, lon:77.78),
  IndiaCity(hi:'कोल्हापुर', en:'Kolhapur', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:16.70, lon:74.24),
  IndiaCity(hi:'ठाणे', en:'Thane', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:19.22, lon:72.98),
  IndiaCity(hi:'सांगली', en:'Sangli', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:16.85, lon:74.57),
  IndiaCity(hi:'अकोला', en:'Akola', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:20.71, lon:77.00),
  IndiaCity(hi:'जलगाँव', en:'Jalgaon', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:21.00, lon:75.56),
  IndiaCity(hi:'लातूर', en:'Latur', stateHi:'महाराष्ट्र', stateEn:'Maharashtra', lat:18.40, lon:76.58),

  // ── गुजरात ──
  IndiaCity(hi:'गांधीनगर', en:'Gandhinagar', stateHi:'गुजरात', stateEn:'Gujarat', lat:23.22, lon:72.65),
  IndiaCity(hi:'अहमदाबाद', en:'Ahmedabad', stateHi:'गुजरात', stateEn:'Gujarat', lat:23.02, lon:72.57),
  IndiaCity(hi:'सूरत', en:'Surat', stateHi:'गुजरात', stateEn:'Gujarat', lat:21.17, lon:72.83),
  IndiaCity(hi:'वडोदरा', en:'Vadodara', stateHi:'गुजरात', stateEn:'Gujarat', lat:22.31, lon:73.18),
  IndiaCity(hi:'राजकोट', en:'Rajkot', stateHi:'गुजरात', stateEn:'Gujarat', lat:22.30, lon:70.80),
  IndiaCity(hi:'भावनगर', en:'Bhavnagar', stateHi:'गुजरात', stateEn:'Gujarat', lat:21.76, lon:72.15),
  IndiaCity(hi:'जामनगर', en:'Jamnagar', stateHi:'गुजरात', stateEn:'Gujarat', lat:22.47, lon:70.06),
  IndiaCity(hi:'जूनागढ़', en:'Junagadh', stateHi:'गुजरात', stateEn:'Gujarat', lat:21.52, lon:70.46),
  IndiaCity(hi:'आणंद', en:'Anand', stateHi:'गुजरात', stateEn:'Gujarat', lat:22.55, lon:72.95),
  IndiaCity(hi:'मेहसाणा', en:'Mehsana', stateHi:'गुजरात', stateEn:'Gujarat', lat:23.60, lon:72.40),
  IndiaCity(hi:'भुज', en:'Bhuj', stateHi:'गुजरात', stateEn:'Gujarat', lat:23.25, lon:69.67),

  // ── पश्चिम बंगाल ──
  IndiaCity(hi:'कोलकाता', en:'Kolkata', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:22.57, lon:88.36),
  IndiaCity(hi:'हावड़ा', en:'Howrah', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:22.59, lon:88.31),
  IndiaCity(hi:'सिलीगुड़ी', en:'Siliguri', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:26.72, lon:88.43),
  IndiaCity(hi:'दुर्गापुर', en:'Durgapur', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:23.55, lon:87.31),
  IndiaCity(hi:'आसनसोल', en:'Asansol', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:23.68, lon:86.99),
  IndiaCity(hi:'बर्धमान', en:'Bardhaman', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:23.26, lon:87.86),
  IndiaCity(hi:'मालदा', en:'Malda', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:25.00, lon:88.14),
  IndiaCity(hi:'दार्जिलिंग', en:'Darjeeling', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:27.04, lon:88.26),
  IndiaCity(hi:'कूचबिहार', en:'Cooch Behar', stateHi:'पश्चिम बंगाल', stateEn:'West Bengal', lat:26.32, lon:89.44),

  // ── हरियाणा ──
  IndiaCity(hi:'चंडीगढ़', en:'Chandigarh', stateHi:'हरियाणा', stateEn:'Haryana', lat:30.73, lon:76.78),
  IndiaCity(hi:'फ़रीदाबाद', en:'Faridabad', stateHi:'हरियाणा', stateEn:'Haryana', lat:28.41, lon:77.31),
  IndiaCity(hi:'गुरुग्राम', en:'Gurugram', stateHi:'हरियाणा', stateEn:'Haryana', lat:28.46, lon:77.03),
  IndiaCity(hi:'पानीपत', en:'Panipat', stateHi:'हरियाणा', stateEn:'Haryana', lat:29.39, lon:76.97),
  IndiaCity(hi:'हिसार', en:'Hisar', stateHi:'हरियाणा', stateEn:'Haryana', lat:29.15, lon:75.72),
  IndiaCity(hi:'रोहतक', en:'Rohtak', stateHi:'हरियाणा', stateEn:'Haryana', lat:28.90, lon:76.60),
  IndiaCity(hi:'करनाल', en:'Karnal', stateHi:'हरियाणा', stateEn:'Haryana', lat:29.69, lon:76.99),
  IndiaCity(hi:'अंबाला', en:'Ambala', stateHi:'हरियाणा', stateEn:'Haryana', lat:30.37, lon:76.77),
  IndiaCity(hi:'सोनीपत', en:'Sonipat', stateHi:'हरियाणा', stateEn:'Haryana', lat:28.99, lon:77.02),
  IndiaCity(hi:'सिरसा', en:'Sirsa', stateHi:'हरियाणा', stateEn:'Haryana', lat:29.53, lon:75.02),

  // ── पंजाब ──
  IndiaCity(hi:'लुधियाना', en:'Ludhiana', stateHi:'पंजाब', stateEn:'Punjab', lat:30.90, lon:75.85),
  IndiaCity(hi:'अमृतसर', en:'Amritsar', stateHi:'पंजाब', stateEn:'Punjab', lat:31.63, lon:74.87),
  IndiaCity(hi:'जालंधर', en:'Jalandhar', stateHi:'पंजाब', stateEn:'Punjab', lat:31.33, lon:75.58),
  IndiaCity(hi:'पटियाला', en:'Patiala', stateHi:'पंजाब', stateEn:'Punjab', lat:30.34, lon:76.39),
  IndiaCity(hi:'बठिंडा', en:'Bathinda', stateHi:'पंजाब', stateEn:'Punjab', lat:30.21, lon:74.95),
  IndiaCity(hi:'मोहाली', en:'Mohali', stateHi:'पंजाब', stateEn:'Punjab', lat:30.70, lon:76.72),
  IndiaCity(hi:'होशियारपुर', en:'Hoshiarpur', stateHi:'पंजाब', stateEn:'Punjab', lat:31.53, lon:75.91),
  IndiaCity(hi:'फ़िरोज़पुर', en:'Firozpur', stateHi:'पंजाब', stateEn:'Punjab', lat:30.93, lon:74.61),

  // ── दिल्ली ──
  IndiaCity(hi:'नई दिल्ली', en:'New Delhi', stateHi:'दिल्ली', stateEn:'Delhi', lat:28.61, lon:77.21),
  IndiaCity(hi:'दिल्ली', en:'Delhi', stateHi:'दिल्ली', stateEn:'Delhi', lat:28.70, lon:77.10),

  // ── उत्तराखंड ──
  IndiaCity(hi:'देहरादून', en:'Dehradun', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:30.32, lon:78.03),
  IndiaCity(hi:'हरिद्वार', en:'Haridwar', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:29.95, lon:78.16),
  IndiaCity(hi:'रुड़की', en:'Roorkee', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:29.87, lon:77.89),
  IndiaCity(hi:'हल्द्वानी', en:'Haldwani', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:29.22, lon:79.52),
  IndiaCity(hi:'नैनीताल', en:'Nainital', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:29.38, lon:79.45),
  IndiaCity(hi:'ऋषिकेश', en:'Rishikesh', stateHi:'उत्तराखंड', stateEn:'Uttarakhand', lat:30.09, lon:78.27),

  // ── हिमाचल प्रदेश ──
  IndiaCity(hi:'शिमला', en:'Shimla', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:31.11, lon:77.17),
  IndiaCity(hi:'मंडी', en:'Mandi', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:31.72, lon:76.93),
  IndiaCity(hi:'धर्मशाला', en:'Dharamshala', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:32.22, lon:76.32),
  IndiaCity(hi:'सोलन', en:'Solan', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:30.90, lon:77.10),
  IndiaCity(hi:'कुल्लू', en:'Kullu', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:31.96, lon:77.11),
  IndiaCity(hi:'मनाली', en:'Manali', stateHi:'हिमाचल प्रदेश', stateEn:'Himachal Pradesh', lat:32.24, lon:77.19),

  // ── जम्मू-कश्मीर ──
  IndiaCity(hi:'श्रीनगर', en:'Srinagar', stateHi:'जम्मू-कश्मीर', stateEn:'Jammu & Kashmir', lat:34.08, lon:74.80),
  IndiaCity(hi:'जम्मू', en:'Jammu', stateHi:'जम्मू-कश्मीर', stateEn:'Jammu & Kashmir', lat:32.73, lon:74.87),
  IndiaCity(hi:'अनंतनाग', en:'Anantnag', stateHi:'जम्मू-कश्मीर', stateEn:'Jammu & Kashmir', lat:33.73, lon:75.15),
  IndiaCity(hi:'बारामूला', en:'Baramulla', stateHi:'जम्मू-कश्मीर', stateEn:'Jammu & Kashmir', lat:34.20, lon:74.35),

  // ── छत्तीसगढ़ ──
  IndiaCity(hi:'रायपुर', en:'Raipur', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:21.25, lon:81.63),
  IndiaCity(hi:'बिलासपुर', en:'Bilaspur', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:22.08, lon:82.15),
  IndiaCity(hi:'भिलाई', en:'Bhilai', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:21.19, lon:81.31),
  IndiaCity(hi:'दुर्ग', en:'Durg', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:21.18, lon:81.30),
  IndiaCity(hi:'कोरबा', en:'Korba', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:22.34, lon:82.68),
  IndiaCity(hi:'राजनांदगाँव', en:'Rajnandgaon', stateHi:'छत्तीसगढ़', stateEn:'Chhattisgarh', lat:21.09, lon:81.03),

  // ── झारखंड ──
  IndiaCity(hi:'रांची', en:'Ranchi', stateHi:'झारखंड', stateEn:'Jharkhand', lat:23.34, lon:85.31),
  IndiaCity(hi:'जमशेदपुर', en:'Jamshedpur', stateHi:'झारखंड', stateEn:'Jharkhand', lat:22.80, lon:86.20),
  IndiaCity(hi:'धनबाद', en:'Dhanbad', stateHi:'झारखंड', stateEn:'Jharkhand', lat:23.79, lon:86.43),
  IndiaCity(hi:'बोकारो', en:'Bokaro', stateHi:'झारखंड', stateEn:'Jharkhand', lat:23.67, lon:86.15),
  IndiaCity(hi:'हज़ारीबाग़', en:'Hazaribagh', stateHi:'झारखंड', stateEn:'Jharkhand', lat:23.99, lon:85.36),
  IndiaCity(hi:'देवघर', en:'Deoghar', stateHi:'झारखंड', stateEn:'Jharkhand', lat:24.48, lon:86.70),

  // ── ओडिशा ──
  IndiaCity(hi:'भुवनेश्वर', en:'Bhubaneswar', stateHi:'ओडिशा', stateEn:'Odisha', lat:20.30, lon:85.82),
  IndiaCity(hi:'कटक', en:'Cuttack', stateHi:'ओडिशा', stateEn:'Odisha', lat:20.46, lon:85.88),
  IndiaCity(hi:'राउरकेला', en:'Rourkela', stateHi:'ओडिशा', stateEn:'Odisha', lat:22.26, lon:84.85),
  IndiaCity(hi:'ब्रह्मपुर', en:'Berhampur', stateHi:'ओडिशा', stateEn:'Odisha', lat:19.31, lon:84.79),
  IndiaCity(hi:'सम्बलपुर', en:'Sambalpur', stateHi:'ओडिशा', stateEn:'Odisha', lat:21.47, lon:83.98),
  IndiaCity(hi:'पुरी', en:'Puri', stateHi:'ओडिशा', stateEn:'Odisha', lat:19.81, lon:85.83),

  // ── आंध्र प्रदेश ──
  IndiaCity(hi:'अमरावती', en:'Amaravati', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:16.51, lon:80.52),
  IndiaCity(hi:'विशाखापत्तनम', en:'Visakhapatnam', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:17.68, lon:83.22),
  IndiaCity(hi:'विजयवाड़ा', en:'Vijayawada', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:16.51, lon:80.65),
  IndiaCity(hi:'गुंटूर', en:'Guntur', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:16.30, lon:80.44),
  IndiaCity(hi:'नेल्लोर', en:'Nellore', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:14.44, lon:79.99),
  IndiaCity(hi:'कुरनूल', en:'Kurnool', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:15.83, lon:78.04),
  IndiaCity(hi:'तिरुपति', en:'Tirupati', stateHi:'आंध्र प्रदेश', stateEn:'Andhra Pradesh', lat:13.63, lon:79.42),

  // ── तेलंगाना ──
  IndiaCity(hi:'हैदराबाद', en:'Hyderabad', stateHi:'तेलंगाना', stateEn:'Telangana', lat:17.39, lon:78.49),
  IndiaCity(hi:'वारंगल', en:'Warangal', stateHi:'तेलंगाना', stateEn:'Telangana', lat:17.97, lon:79.60),
  IndiaCity(hi:'निज़ामाबाद', en:'Nizamabad', stateHi:'तेलंगाना', stateEn:'Telangana', lat:18.67, lon:78.09),
  IndiaCity(hi:'करीमनगर', en:'Karimnagar', stateHi:'तेलंगाना', stateEn:'Telangana', lat:18.44, lon:79.13),
  IndiaCity(hi:'खम्मम', en:'Khammam', stateHi:'तेलंगाना', stateEn:'Telangana', lat:17.25, lon:80.15),

  // ── कर्नाटक ──
  IndiaCity(hi:'बेंगलुरु', en:'Bengaluru', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:12.97, lon:77.59),
  IndiaCity(hi:'मैसूर', en:'Mysore', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:12.30, lon:76.65),
  IndiaCity(hi:'मंगलौर', en:'Mangaluru', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:12.87, lon:74.88),
  IndiaCity(hi:'हुबली', en:'Hubli', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:15.36, lon:75.12),
  IndiaCity(hi:'बेलगाम', en:'Belgaum', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:15.85, lon:74.50),
  IndiaCity(hi:'गुलबर्गा', en:'Gulbarga', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:17.33, lon:76.83),
  IndiaCity(hi:'दावणगेरे', en:'Davanagere', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:14.47, lon:75.92),
  IndiaCity(hi:'शिवमोगा', en:'Shivamogga', stateHi:'कर्नाटक', stateEn:'Karnataka', lat:13.93, lon:75.57),

  // ── तमिलनाडु ──
  IndiaCity(hi:'चेन्नई', en:'Chennai', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:13.08, lon:80.27),
  IndiaCity(hi:'कोयंबटूर', en:'Coimbatore', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:11.02, lon:76.96),
  IndiaCity(hi:'मदुरै', en:'Madurai', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:9.93, lon:78.12),
  IndiaCity(hi:'त्रिची', en:'Tiruchirappalli', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:10.79, lon:78.70),
  IndiaCity(hi:'सलेम', en:'Salem', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:11.66, lon:78.15),
  IndiaCity(hi:'तिरुनेलवेली', en:'Tirunelveli', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:8.72, lon:77.72),
  IndiaCity(hi:'वेल्लोर', en:'Vellore', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:12.92, lon:79.14),
  IndiaCity(hi:'तंजावुर', en:'Thanjavur', stateHi:'तमिलनाडु', stateEn:'Tamil Nadu', lat:10.79, lon:79.14),

  // ── केरल ──
  IndiaCity(hi:'तिरुवनंतपुरम', en:'Thiruvananthapuram', stateHi:'केरल', stateEn:'Kerala', lat:8.52, lon:76.94),
  IndiaCity(hi:'कोच्चि', en:'Kochi', stateHi:'केरल', stateEn:'Kerala', lat:9.93, lon:76.27),
  IndiaCity(hi:'कोझिकोड', en:'Kozhikode', stateHi:'केरल', stateEn:'Kerala', lat:11.26, lon:75.78),
  IndiaCity(hi:'त्रिशूर', en:'Thrissur', stateHi:'केरल', stateEn:'Kerala', lat:10.53, lon:76.21),
  IndiaCity(hi:'कोल्लम', en:'Kollam', stateHi:'केरल', stateEn:'Kerala', lat:8.89, lon:76.61),
  IndiaCity(hi:'पलक्कड़', en:'Palakkad', stateHi:'केरल', stateEn:'Kerala', lat:10.79, lon:76.65),
  IndiaCity(hi:'कन्नूर', en:'Kannur', stateHi:'केरल', stateEn:'Kerala', lat:11.87, lon:75.37),

  // ── असम व पूर्वोत्तर ──
  IndiaCity(hi:'गुवाहाटी', en:'Guwahati', stateHi:'असम', stateEn:'Assam', lat:26.14, lon:91.74),
  IndiaCity(hi:'डिब्रूगढ़', en:'Dibrugarh', stateHi:'असम', stateEn:'Assam', lat:27.47, lon:94.91),
  IndiaCity(hi:'सिलचर', en:'Silchar', stateHi:'असम', stateEn:'Assam', lat:24.83, lon:92.78),
  IndiaCity(hi:'जोरहाट', en:'Jorhat', stateHi:'असम', stateEn:'Assam', lat:26.74, lon:94.20),
  IndiaCity(hi:'तेजपुर', en:'Tezpur', stateHi:'असम', stateEn:'Assam', lat:26.65, lon:92.79),
  IndiaCity(hi:'ईटानगर', en:'Itanagar', stateHi:'अरुणाचल प्रदेश', stateEn:'Arunachal Pradesh', lat:27.10, lon:93.62),
  IndiaCity(hi:'इंफाल', en:'Imphal', stateHi:'मणिपुर', stateEn:'Manipur', lat:24.82, lon:93.94),
  IndiaCity(hi:'शिलांग', en:'Shillong', stateHi:'मेघालय', stateEn:'Meghalaya', lat:25.58, lon:91.89),
  IndiaCity(hi:'आइज़ॉल', en:'Aizawl', stateHi:'मिज़ोरम', stateEn:'Mizoram', lat:23.73, lon:92.72),
  IndiaCity(hi:'कोहिमा', en:'Kohima', stateHi:'नागालैंड', stateEn:'Nagaland', lat:25.67, lon:94.10),
  IndiaCity(hi:'अगरतला', en:'Agartala', stateHi:'त्रिपुरा', stateEn:'Tripura', lat:23.83, lon:91.28),
  IndiaCity(hi:'गंगटोक', en:'Gangtok', stateHi:'सिक्किम', stateEn:'Sikkim', lat:27.33, lon:88.62),

  // ── गोवा और केंद्रशासित ──
  IndiaCity(hi:'पणजी', en:'Panaji', stateHi:'गोवा', stateEn:'Goa', lat:15.49, lon:73.83),
  IndiaCity(hi:'मडगाँव', en:'Margao', stateHi:'गोवा', stateEn:'Goa', lat:15.28, lon:73.96),
  IndiaCity(hi:'पोर्ट ब्लेयर', en:'Port Blair', stateHi:'अंडमान', stateEn:'Andaman', lat:11.62, lon:92.72),
  IndiaCity(hi:'कवरत्ती', en:'Kavaratti', stateHi:'लक्षद्वीप', stateEn:'Lakshadweep', lat:10.57, lon:72.64),
  IndiaCity(hi:'दमन', en:'Daman', stateHi:'दमन-दीव', stateEn:'Daman & Diu', lat:20.40, lon:72.83),
  IndiaCity(hi:'पुडुचेरी', en:'Puducherry', stateHi:'पुडुचेरी', stateEn:'Puducherry', lat:11.94, lon:79.83),
  IndiaCity(hi:'लेह', en:'Leh', stateHi:'लद्दाख', stateEn:'Ladakh', lat:34.15, lon:77.58),
];

/// query से मिलती-जुलती जगहें — शुरुआत में जो नाम शुरू हो वो सबसे ऊपर
List<IndiaCity> searchIndiaCities(String query, {int limit = 12}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final starts = <IndiaCity>[];
  final contains = <IndiaCity>[];
  for (final c in kIndiaCities) {
    final hi = c.hi.toLowerCase();
    final en = c.en.toLowerCase();
    if (hi.startsWith(q) || en.startsWith(q)) {
      starts.add(c);
    } else if (hi.contains(q) || en.contains(q)) {
      contains.add(c);
    }
  }
  final combined = [...starts, ...contains];
  return combined.take(limit).toList();
}
