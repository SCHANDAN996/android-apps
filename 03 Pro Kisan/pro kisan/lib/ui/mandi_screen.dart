import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'theme/dairy_theme.dart';
import '../config/server_config.dart';
import '../l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

/// ---------------------------------------------------------------------------
///  मंडी भाव — MSP Comparison + State/District/Mandi Filters
/// ---------------------------------------------------------------------------
class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> {
  String? _selectedState;
  String? _selectedDistrict;
  String _searchQuery = '';

  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);

  // Hindi→English display maps (data logic still keys off the Hindi names).
  static const Map<String, String> _stateEn = {
    'उत्तर प्रदेश': 'Uttar Pradesh', 'मध्य प्रदेश': 'Madhya Pradesh', 'बिहार': 'Bihar',
    'राजस्थान': 'Rajasthan', 'हरियाणा': 'Haryana', 'पंजाब': 'Punjab', 'महाराष्ट्र': 'Maharashtra',
    'पश्चिम बंगाल': 'West Bengal', 'तेलंगाना': 'Telangana', 'आंध्र प्रदेश': 'Andhra Pradesh',
    'कर्नाटक': 'Karnataka', 'तमिलनाडु': 'Tamil Nadu', 'गुजरात': 'Gujarat', 'छत्तीसगढ़': 'Chhattisgarh',
    'झारखंड': 'Jharkhand', 'उत्तराखंड': 'Uttarakhand', 'केरल': 'Kerala', 'ओडिशा': 'Odisha',
    'असम': 'Assam', 'जम्मू और कश्मीर': 'Jammu & Kashmir',
  };
  static const Map<String, String> _cropEn = {
    'गेहूं': 'Wheat', 'धान (Common)': 'Paddy (Common)', 'धान (Grade A)': 'Paddy (Grade A)',
    'मक्का': 'Maize', 'चना': 'Gram', 'सरसों': 'Mustard', 'सोयाबीन': 'Soybean', 'मूंगफली': 'Groundnut',
    'अरहर (तूर)': 'Pigeon Pea (Tur)', 'मसूर': 'Lentil', 'बाजरा': 'Pearl Millet', 'ज्वार': 'Sorghum',
    'जौ': 'Barley', 'मूंग': 'Green Gram', 'उड़द': 'Black Gram', 'आलू': 'Potato', 'प्याज': 'Onion', 'टमाटर': 'Tomato',
    'रागी': 'Ragi', 'तिल': 'Sesame', 'कपास': 'Cotton', 'हल्दी': 'Turmeric', 'अदरक': 'Ginger', 'मिर्च': 'Chilli',
    'पत्ता गोभी': 'Cabbage', 'भिंडी': 'Okra', 'बैंगन': 'Brinjal', 'केला': 'Banana', 'नारियल': 'Coconut',
    'काली मिर्च': 'Black Pepper', 'लहसुन': 'Garlic', 'फूलगोभी': 'Cauliflower', 'मूली': 'Radish', 'गाजर': 'Carrot', 'धनिया': 'Coriander',
  };
  static const Map<String, String> _districtEn = {
    // UP
    'लखनऊ': 'Lucknow', 'कानपुर': 'Kanpur', 'आगरा': 'Agra', 'वाराणसी': 'Varanasi',
    'गोरखपुर': 'Gorakhpur', 'बरेली': 'Bareilly', 'मेरठ': 'Meerut', 'प्रयागराज': 'Prayagraj',
    'अलीगढ़': 'Aligarh', 'झाँसी': 'Jhansi',
    // MP
    'इंदौर': 'Indore', 'भोपाल': 'Bhopal', 'जबलपुर': 'Jabalpur', 'ग्वालियर': 'Gwalior',
    'उज्जैन': 'Ujjain', 'सागर': 'Sagar', 'रीवा': 'Rewa', 'सतना': 'Satna',
    'छिंदवाड़ा': 'Chhindwara', 'रतलाम': 'Ratlam',
    // BR
    'पटना': 'Patna', 'गया': 'Gaya', 'मुजफ्फरपुर': 'Muzaffarpur', 'भागलपुर': 'Bhagalpur',
    'दरभंगा': 'Darbhanga', 'पूर्णिया': 'Purnia', 'सहरसा': 'Saharsa', 'बेगूसराय': 'Begusarai',
    'आरा': 'Ara', 'बिहारशरीफ': 'Bihar Sharif',
    // RJ
    'जयपुर': 'Jaipur', 'जोधपुर': 'Jodhpur', 'कोटा': 'Kota', 'उदयपुर': 'Udaipur',
    'अजमेर': 'Ajmer', 'बीकानेर': 'Bikaner', 'श्रीगंगानगर': 'Sriganganagar', 'अलवर': 'Alwar',
    'भरतपुर': 'Bharatpur', 'सीकर': 'Sikar',
    // HR
    'करनाल': 'Karnal', 'हिसार': 'Hisar', 'सिरसा': 'Sirsa', 'रोहतक': 'Rohtak',
    'पानीपत': 'Panipat', 'अंबाला': 'Ambala', 'कुरुक्षेत्र': 'Kurukshetra', 'जींद': 'Jind',
    'सोनीपत': 'Sonipat', 'फरीदाबाद': 'Faridabad',
    // PB
    'लुधियाना': 'Ludhiana', 'अमृतसर': 'Amritsar', 'पटियाला': 'Patiala', 'जालंधर': 'Jalandhar',
    'बठिंडा': 'Bathinda', 'मोगा': 'Moga', 'होशियारपुर': 'Hoshiarpur', 'पठानकोट': 'Pathankot',
    'गुरदासपुर': 'Gurdaspur', 'संगरूर': 'Sangrur',
    // MH
    'पुणे': 'Pune', 'नागपुर': 'Nagpur', 'नासिक': 'Nashik', 'औरंगाबाद': 'Aurangabad',
    'सोलापुर': 'Solapur', 'कोल्हापुर': 'Kolhapur', 'अमरावती': 'Amravati', 'अकोला': 'Akola',
    'जलगाँव': 'Jalgaon', 'लातूर': 'Latur',
    // WB
    'कोलकाता': 'Kolkata', 'हावड़ा': 'Howrah', 'बर्धमान': 'Bardhaman', 'मेदिनीपुर': 'Medinipur',
    'मुर्शिदाबाद': 'Murshidabad', 'सिलीगुड़ी': 'Siliguri', 'मालदा': 'Malda', 'दार्जिलिंग': 'Darjeeling',
    'हुगली': 'Hooghly', 'कूचबिहार': 'Cooch Behar',
    // TS
    'हैदराबाद': 'Hyderabad', 'वारंगल': 'Warangal', 'करीमनगर': 'Karimnagar', 'खम्मम': 'Khammam',
    'निजामाबाद': 'Nizamabad', 'महबूबनगर': 'Mahabubnagar', 'नलगोंडा': 'Nalgonda', 'आदिलाबाद': 'Adilabad',
    // AP
    'विशाखापत्तनम': 'Visakhapatnam', 'विजयवाड़ा': 'Vijayawada', 'गुंटूर': 'Guntur', 'नेल्लोर': 'Nellore',
    'कुरनूल': 'Kurnool', 'राजमहेंद्रवरम': 'Rajamahendravaram', 'तिरुपति': 'Tirupati', 'कडपा': 'Kadapa',
    // KA
    'बेंगलुरु': 'Bengaluru', 'हुबली-धारवाड़': 'Hubli-Dharwad', 'मैसूर': 'Mysore', 'बेलगाम': 'Belgaum',
    'मंगलौर': 'Mangalore', 'गुलबर्गा': 'Gulbarga', 'दावणगेरे': 'Davanagere', 'शिमोगा': 'Shimoga',
    // TN
    'चेन्नई': 'Chennai', 'कोयंबटूर': 'Coimbatore', 'मदुरै': 'Madurai', 'त्रिची': 'Trichy',
    'सलेम': 'Salem', 'तिरुनेलवेली': 'Tirunelveli', 'वेल्लोर': 'Vellore', 'तंजावुर': 'Thanjavur',
    // GJ
    'अहमदाबाद': 'Ahmedabad', 'सूरत': 'Surat', 'वडोदरा': 'Vadodara', 'राजकोट': 'Rajkot',
    'जामनगर': 'Jamnagar', 'जूनागढ़': 'Junagadh', 'आणंद': 'Anand', 'मेहसाणा': 'Mehsana',
    'भुज': 'Bhuj',
    // CG
    'रायपुर': 'Raipur', 'बिलासपुर': 'Bilaspur', 'दुर्ग': 'Durg', 'भिलाई': 'Bhilai',
    'राजनांदगांव': 'Rajnandgaon', 'कोरबा': 'Korba', 'रायगढ़': 'Raigarh', 'जगदलपुर': 'Jagdalpur',
    // JH
    'रांची': 'Ranchi', 'जमशेदपुर': 'Jamshedpur', 'धनबाद': 'Dhanbad', 'बोकारो': 'Bokaro',
    'हजारीबाग': 'Hazaribagh', 'देवघर': 'Deoghar', 'गिरिडीह': 'Giridih', 'दुमका': 'Dumka',
    // UK
    'देहरादून': 'Dehradun', 'हरिद्वार': 'Haridwar', 'हल्द्वानी': 'Haldwani', 'रुड़की': 'Roorkee',
    'रुद्रपुर': 'Rudrapur', 'काशीपुर': 'Kashipur', 'अल्मोड़ा': 'Almora', 'पिथौरागढ़': 'Pithoragarh',
    // KL
    'तिरुवनंतपुरम': 'Thiruvananthapuram', 'कोच्चि': 'Kochi', 'कोझिकोड': 'Kozhikode', 'त्रिशूर': 'Thrissur',
    'कोल्लम': 'Kollam', 'अलाप्पुझा': 'Alappuzha', 'पलक्कड़': 'Palakkad', 'कन्नूर': 'Kannur',
    // OD
    'भुवनेश्वर': 'Bhubaneswar', 'कटक': 'Cuttack', 'राउरकेला': 'Rourkela', 'संबलेपुर': 'Sambalpur',
    'ब्रह्मपुर': 'Berhampur', 'पुरी': 'Puri', 'बालासोर': 'Balasore', 'भद्रक': 'Bhadrak',
    // AS
    'गुवाहाटी': 'Guwahati', 'डिब्रूगढ़': 'Dibrugarh', 'सिलचर': 'Silchar', 'जोरहाट': 'Jorhat',
    'नागांव': 'Nagaon', 'तिनसुकिया': 'Tinsukia', 'तेजपुर': 'Tezpur', 'धुबरी': 'Dhubri',
    // JK
    'श्रीनगर': 'Srinagar', 'जम्मू': 'Jammu', 'अनंतनाग': 'Anantnag', 'बारामूला': 'Baramulla',
    'कठुआ': 'Kathua', 'सांबा': 'Samba', 'उधमपुर': 'Udhampur', 'पुंछ': 'Poonch',
  };
  String _stateName(String hi) => _isHi ? hi : (_stateEn[hi] ?? hi);
  String _cropName(String hi) => _isHi ? hi : (_cropEn[hi] ?? hi);
  /// ज़िले का नाम दिखाना।
  ///
  /// ⚠️ सर्वर ज़िला **अंग्रेज़ी में ही** भेजता है (जैसा AGMARKNET से आता है) —
  /// "Salem", "Mau(Maunathbhanjan)"। वहाँ 519 अलग वर्तनियाँ हैं, इसलिए सर्वर
  /// पर अनुवाद करने से आधे बदलते और आधे नहीं, और एक ही ज़िला दो नामों से
  /// सूची में दिख जाता।
  ///
  /// इसलिए नाम एक ही रूप में सहेजा जाता है और **दिखाते समय** बदला जाता है —
  /// जिन 177 ज़िलों का हिंदी नाम ऐप के पास है वहाँ हिंदी, बाक़ी जगह वही नाम।
  String _districtName(String d) {
    if (!_isHi) return _districtEn[d] ?? d;
    // पहले से हिंदी में है (पुराने भाव) तो वैसा ही रहने दो
    if (_districtEn.containsKey(d)) return d;
    return _districtHi[d] ?? d;
  }

  /// अंग्रेज़ी → हिंदी — ऊपर के `_districtEn` को उलटकर बना, इसलिए दोनों
  /// हमेशा एक जैसे रहेंगे (एक जगह नाम बदला तो दूसरी अपने आप बदल जाएगी)।
  static final Map<String, String> _districtHi = {
    for (final e in _districtEn.entries) e.value: e.key,
  };

  static const _monthsHi = [
    '', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुल', 'अग', 'सित', 'अक्टू', 'नव', 'दिस'
  ];
  static const _monthsEn = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _shortDate(DateTime d) =>
      '${d.day} ${(_isHi ? _monthsHi : _monthsEn)[d.month]}';

  /// "आज", "कल" या "3 दिन पुराना" — किसान को उम्र तुरंत पता चले
  String _ageNote(DateTime d) {
    final today = DateTime.now();
    final days = DateTime(today.year, today.month, today.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (days <= 0) return _isHi ? ' (आज)' : ' (today)';
    if (days == 1) return _isHi ? ' (कल)' : ' (yesterday)';
    return _isHi ? ' ($days दिन पुराना)' : ' ($days days old)';
  }

  /// "3 अग, शाम 6:15" — तारीख़ के साथ समय भी
  String _dateTimeText(DateTime d) {
    final h24 = d.hour;
    final mm = d.minute.toString().padLeft(2, '0');
    if (!_isHi) {
      final ampm = h24 < 12 ? 'AM' : 'PM';
      final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
      return '${_shortDate(d)}, $h12:$mm $ampm';
    }
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final part = h24 < 4
        ? 'रात'
        : h24 < 12
            ? 'सुबह'
            : h24 < 16
                ? 'दोपहर'
                : h24 < 20
                    ? 'शाम'
                    : 'रात';
    return '${_shortDate(d)}, $part $h12:$mm';
  }

  /// सूची में सबसे नई तारीख़ — "भाव X तक के" पट्टी के लिए
  DateTime? _latestDate(List<_MandiRate> list) {
    DateTime? latest;
    for (final r in list) {
      if (r.date == null) continue;
      if (latest == null || r.date!.isAfter(latest)) latest = r.date;
    }
    return latest;
  }

  /// ⚠️ चेतावनी और स्रोत की पट्टी **इसी से** तय होती है।
  ///
  /// पहले एक `_hasRealRates` झंडा था जो सिर्फ़ इतना बताता था कि सर्वर से
  /// *कहीं का* भाव आया या नहीं।
  /// पर किसान पूरा भारत नहीं देखता — वह अपना राज्य/ज़िला/फ़सल छाँटकर देखता है।
  ///
  /// पहली माँग पूरे भारत की होती है और सर्वर उसे `LIMIT` पर काट देता है
  /// (राज्य के अकारादि क्रम में) — यानी शुरू के 7-8 राज्यों के बाद वाले
  /// किसान को सूची में एक भी असली भाव नहीं मिलता। फिर भी पहले ऊपर "स्रोत:
  /// Agmarknet, भारत सरकार" लिखा आता था और चेतावनी ग़ायब हो जाती थी, क्योंकि
  /// कहीं और (जैसे उत्तर प्रदेश) का असली भाव आ चुका था।
  ///
  /// इसलिए अब गिनती **जो परदे पर दिख रहा है उसी की** होती है।
  int _realCount(List<_MandiRate> list) {
    var n = 0;
    for (final r in list) {
      if (r.isReal) n++;
    }
    return n;
  }

  // ── MSP Rates 2024-25 (Government of India official) ──────────────────
  static const Map<String, double> mspRates = {
    'गेहूं': 2275,
    'धान (Common)': 2300,
    'धान (Grade A)': 2320,
    'मक्का': 2225,
    'चना': 5440,
    'सरसों': 5650,
    'सोयाबीन': 4892,
    'मूंगफली': 6377,
    'अरहर (तूर)': 7000,
    'मसूर': 6425,
    'बाजरा': 2625,
    'ज्वार': 3371,
    'जौ': 1850,
    'मूंग': 8558,
    'उड़द': 6950,
    'रागी': 4290,
    'तिल': 8300,
    'कपास': 7120,
  };

  // ── State → District mapping ──────────────────────────────────────────
  static const Map<String, List<String>> _stateDistricts = {
    'उत्तर प्रदेश': ['लखनऊ', 'कानपुर', 'आगरा', 'वाराणसी', 'गोरखपुर', 'बरेली', 'मेरठ', 'प्रयागराज', 'अलीगढ़', 'झाँसी'],
    'मध्य प्रदेश': ['इंदौर', 'भोपाल', 'जबलपुर', 'ग्वालियर', 'उज्जैन', 'सागर', 'रीवा', 'सतना', 'छिंदवाड़ा', 'रतलाम'],
    'बिहार': ['पटना', 'गया', 'मुजफ्फरपुर', 'भागलपुर', 'दरभंगा', 'पूर्णिया', 'सहरसा', 'बेगूसराय', 'आरा', 'बिहारशरीफ'],
    'राजस्थान': ['जयपुर', 'जोधपुर', 'कोटा', 'उदयपुर', 'अजमेर', 'बीकानेर', 'श्रीगंगानगर', 'अलवर', 'भरतपुर', 'सीकर'],
    'हरियाणा': ['करनाल', 'हिसार', 'सिरसा', 'रोहतक', 'पानीपत', 'अंबाला', 'कुरुक्षेत्र', 'जींद', 'सोनीपत', 'फरीदाबाद'],
    'पंजाब': ['लुधियाना', 'अमृतसर', 'पटियाला', 'जालंधर', 'बठिंडा', 'मोगा', 'होशियारपुर', 'पठानकोट', 'गुरदासपुर', 'संगरूर'],
    'महाराष्ट्र': ['पुणे', 'नागपुर', 'नासिक', 'औरंगाबाद', 'सोलापुर', 'कोल्हापुर', 'अमरावती', 'अकोला', 'जलगाँव', 'लातूर'],
    'पश्चिम बंगाल': ['कोलकाता', 'हावड़ा', 'बर्धमान', 'मेदिनीपुर', 'मुर्शिदाबाद', 'सिलीगुड़ी', 'मालदा', 'दार्जिलिंग', 'हुगली', 'कूचबिहार'],
    'तेलंगाना': ['हैदराबाद', 'वारंगल', 'करीमनगर', 'खम्मम', 'निजामाबाद', 'महबूबनगर', 'नलगोंडा', 'आदिलाबाद'],
    'आंध्र प्रदेश': ['विशाखापत्तनम', 'विजयवाड़ा', 'गुंटूर', 'नेल्लोर', 'कुरनूल', 'राजमहेंद्रवरम', 'तिरुपति', 'कडपा'],
    'कर्नाटक': ['बेंगलुरु', 'हुबली-धारवाड़', 'मैसूर', 'बेलगाम', 'मंगलौर', 'गुलबर्गा', 'दावणगेरे', 'शिमोगा'],
    'तमिलनाडु': ['चेन्नई', 'कोयंबटूर', 'मदुरै', 'त्रिची', 'सलेम', 'तिरुनेलवेली', 'वेल्लोर', 'तंजावुर'],
    'गुजरात': ['अहमदाबाद', 'सूरत', 'वडोदरा', 'राजकोट', 'जामनगर', 'जूनागढ़', 'आणंद', 'मेहसाणा', 'भुज'],
    'छत्तीसगढ़': ['रायपुर', 'बिलासपुर', 'दुर्ग', 'भिलाई', 'राजनांदगांव', 'कोरबा', 'रायगढ़', 'जगदलपुर'],
    'झारखंड': ['रांची', 'जमशेदपुर', 'धनबाद', 'बोकारो', 'हजारीबाग', 'देवघर', 'गिरिडीह', 'दुमका'],
    'उत्तराखंड': ['देहरादून', 'हरिद्वार', 'हल्द्वानी', 'रुड़की', 'रुद्रपुर', 'काशीपुर', 'अल्मोड़ा', 'पिथौरागढ़'],
    'केरल': ['तिरुवनंतपुरम', 'कोच्चि', 'कोझिकोड', 'त्रिशूर', 'कोल्लम', 'अलाप्पुझा', 'पलक्कड़', 'कन्नूर'],
    'ओडिशा': ['भुवनेश्वर', 'कटक', 'राउरकेला', 'संबलेपुर', 'ब्रह्मपुर', 'पुरी', 'बालासोर', 'भद्रक'],
    'असम': ['गुवाहाटी', 'डिब्रूगढ़', 'सिलचर', 'जोरहाट', 'नागांव', 'तिनसुकिया', 'तेजपुर', 'धुबरी'],
    'जम्मू और कश्मीर': ['श्रीनगर', 'जम्मू', 'अनंतनाग', 'बारामूला', 'कठुआ', 'सांबा', 'उधमपुर', 'पुंछ'],
  };

  // ── Representative Mandi Prices (sample data — refreshed structure) ───
  // In a production app, this would come from data.gov.in API
  late List<_MandiRate> _allRates;

  bool _isLoadingReal = false;

  /// सर्वर ने ये भाव कब उठाए थे (सर्वर भेजता है, "YYYY-MM-DD HH:MM" IST)।
  ///
  /// यह **तारीख़ से अलग चीज़** है। `date` = मंडी में सौदा किस दिन हुआ।
  /// `_fetchedAt` = हमारे सर्वर ने वह भाव कब उठाया। किसान को दोनों जानना
  /// ज़रूरी है — 2 दिन पुराना भाव ताज़ा दिख सकता है अगर सिर्फ़ उठाने का समय
  /// दिखे, और उठाने का समय न दिखे तो पता ही न चले कि जानकारी बासी है।
  DateTime? _fetchedAt;

  /// पहली बार तैयारी हो चुकी या नहीं — `didChangeDependencies` कई बार चलता है
  bool _didInit = false;

  // ⚠️ यह तैयारी पहले `initState()` में थी, पर वहाँ से नहीं हो सकती।
  //
  // `_generateSampleRates()` भीतर `_isHi` पढ़ता है, और `_isHi` का मतलब है
  // `AppLocalizations.isHindiLike(context)` — यानी context से भाषा पूछना।
  // Flutter में `initState()` के दौरान context से कुछ पूछना मना है (वहाँ
  // inherited widget अभी जुड़े नहीं होते), इसलिए debug में assertion टूटती थी:
  //
  //     dependOnInheritedWidgetOfExactType<_LocalizationsScope>() was called
  //     before _MandiScreenState.initState() completed.
  //
  // release build में assertion बंद रहती है इसलिए यह छिपा हुआ था — ऐप चलता
  // दिखता था। `didChangeDependencies` वही जगह है जहाँ Flutter context पढ़ने
  // देता है, और यह पहली `build()` से पहले चलता है, इसलिए `_allRates` समय पर
  // भर जाता है।
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    _allRates = _generateSampleRates();
    _fetchRealMandiData();
  }

  /// सर्वर की एक पंक्ति → `_MandiRate`।
  ///
  /// यहाँ से बना हर भाव **असली** है (`isReal: true`) — नमूना भाव
  /// `_generateSampleRates()` में अलग बनते हैं। दोनों जगह एक ही जगह से
  /// निशान लगे, इसलिए यह मेल एक ही जगह रखा है।
  _MandiRate _rateFromJson(dynamic item) => _MandiRate(
        state: item['state'] ?? '',
        district: item['district'] ?? '',
        mandi: (item['mandi'] ?? item['district'] ?? '') +
            (_isHi ? ' मंडी' : ' Mandi'),
        commodity: item['commodity'] ?? '',
        minPrice: (item['minPrice'] ?? 0).toDouble(),
        maxPrice: (item['maxPrice'] ?? 0).toDouble(),
        modalPrice: (item['modalPrice'] ?? 0).toDouble(),
        msp: (item['msp'] ?? 0).toDouble(),
        // server "yyyy-MM-dd" भेजता है; न आए/ग़लत हो तो null
        date: DateTime.tryParse((item['date'] ?? '').toString()),
        isReal: true,
      );

  Future<void> _fetchRealMandiData() async {
    if (mounted) setState(() => _isLoadingReal = true);
    try {
      // सर्वर के डिफ़ॉल्ट (7 दिन, 2000 पंक्तियाँ) पर छोड़ने के बजाय ख़ुद
      // माँग लेते हैं — तब पता रहता है कि ऐप को क्या चाहिए, और सर्वर का
      // डिफ़ॉल्ट कभी बदले तो भी ऐप का बर्ताव नहीं बदलेगा।
      //
      // ⚠️ 2000 से बढ़ाकर 3000 (सर्वर की हद) किया। सर्वर राज्य के अकारादि
      // क्रम में काटता है, इसलिए 2000 पर केरल और गुजरात पूरे कट जाते थे —
      // अकेले केरल के 697 असली भाव ऐप तक कभी नहीं पहुँचते थे।
      //
      // यह पूरा हल नहीं है, बस पहली झलक ठीक करता है — डेटाबेस बढ़ेगा तो
      // कटाई फिर होगी। इसीलिए राज्य चुनते ही `_fetchStateRates()` उसी
      // राज्य का भाव अलग से माँगता है, जहाँ कटाई का सवाल ही नहीं उठता।
      final url = Uri.parse(ServerConfig.mandiUrl)
          .replace(queryParameters: {'days': '7', 'limit': '3000'});
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final fetched = data.map(_rateFromJson).toList();
        // हर पंक्ति में एक ही होता है — पहली से ले लो
        if (data.isNotEmpty) {
          _fetchedAt = DateTime.tryParse(
              (data.first['fetchedAt'] ?? '').toString().replaceFirst(' ', 'T'));
        }
        if (fetched.isNotEmpty && mounted) {
          setState(() {
            _allRates = [...fetched, ..._allRates];
            _isLoadingReal = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingReal = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingReal = false);
    }
  }

  List<_MandiRate> _generateSampleRates() {
    // Generate representative rates for major crops across states
    final List<_MandiRate> rates = [];
    final crops = [
      _CropPrice('गेहूं', mspRates['गेहूं'] ?? 2275, [2200, 2350, 2290]),
      _CropPrice('धान (Common)', mspRates['धान (Common)'] ?? 2300, [2250, 2400, 2320]),
      _CropPrice('मक्का', mspRates['मक्का'] ?? 2225, [2100, 2300, 2180]),
      _CropPrice('चना', mspRates['चना'] ?? 5440, [5200, 5800, 5500]),
      _CropPrice('सरसों', mspRates['सरसों'] ?? 5650, [5500, 6200, 5800]),
      _CropPrice('सोयाबीन', mspRates['सोयाबीन'] ?? 4892, [4700, 5100, 4900]),
      _CropPrice('अरहर (तूर)', mspRates['अरहर (तूर)'] ?? 7000, [6800, 7500, 7100]),
      _CropPrice('मसूर', mspRates['मसूर'] ?? 6425, [6200, 6800, 6500]),
      _CropPrice('बाजरा', mspRates['बाजरा'] ?? 2625, [2500, 2750, 2600]),
      _CropPrice('ज्वार', mspRates['ज्वार'] ?? 3371, [3200, 3500, 3350]),
      _CropPrice('जौ', mspRates['जौ'] ?? 1850, [1700, 1950, 1800]),
      _CropPrice('मूंग', mspRates['मूंग'] ?? 8558, [8000, 8900, 8500]),
      _CropPrice('उड़द', mspRates['उड़द'] ?? 6950, [6500, 7200, 6800]),
      _CropPrice('आलू', 0, [800, 1500, 1100]),
      _CropPrice('प्याज', 0, [1200, 2500, 1800]),
      _CropPrice('टमाटर', 0, [600, 2000, 1200]),
      _CropPrice('रागी', mspRates['रागी'] ?? 4290, [4100, 4500, 4300]),
      _CropPrice('तिल', mspRates['तिल'] ?? 8300, [8000, 8600, 8250]),
      _CropPrice('कपास', mspRates['कपास'] ?? 7120, [6800, 7400, 7100]),
      _CropPrice('हल्दी', 0, [6500, 7500, 7000]),
      _CropPrice('अदरक', 0, [4000, 6000, 5000]),
      _CropPrice('मिर्च', 0, [8000, 12000, 10000]),
      _CropPrice('पत्ता गोभी', 0, [800, 1500, 1100]),
      _CropPrice('भिंडी', 0, [1500, 3000, 2200]),
      _CropPrice('बैंगन', 0, [1000, 2000, 1500]),
      _CropPrice('केला', 0, [1500, 2500, 2000]),
      _CropPrice('नारियल', 0, [2000, 3000, 2500]),
      _CropPrice('काली मिर्च', 0, [45000, 55000, 50000]),
      _CropPrice('लहसुन', 0, [8000, 15000, 12000]),
      _CropPrice('फूलगोभी', 0, [1000, 2500, 1800]),
      _CropPrice('मूली', 0, [500, 1200, 800]),
      _CropPrice('गाजर', 0, [800, 1800, 1200]),
      _CropPrice('धनिया', 0, [5000, 8000, 6500]),
    ];

    for (final entry in _stateDistricts.entries) {
      final state = entry.key;
      for (final district in entry.value) {
        for (final crop in crops) {
          // Add slight variance per district
          final hash = (state.hashCode + district.hashCode + crop.name.hashCode).abs();
          final variance = (hash % 200) - 100; // -100 to +100
          rates.add(_MandiRate(
            state: state,
            district: district,
            mandi: '$district ${_isHi ? 'मंडी' : 'Mandi'}',
            commodity: crop.name,
            minPrice: crop.prices[0] + variance,
            maxPrice: crop.prices[1] + variance,
            modalPrice: crop.prices[2] + variance,
            msp: crop.msp,
            isReal: false,   // ऐप का बनाया हुआ — हर कार्ड पर साफ़ लिखा जाएगा
          ));
        }
      }
    }
    return rates;
  }

  List<_MandiRate> get _filteredRates {
    var list = _allRates;
    if (_selectedState != null) {
      list = list.where((r) => r.state == _selectedState).toList();
    }
    if (_selectedDistrict != null) {
      list = list.where((r) => r.district == _selectedDistrict).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) {
        final commodityEng = _cropEn[r.commodity]?.toLowerCase() ?? '';
        final commodityHin = r.commodity.toLowerCase();
        return commodityHin.contains(q) || commodityEng.contains(q);
      }).toList();
    }
    return list;
  }

  /// चुने हुए राज्य के ज़िले।
  ///
  /// ⚠️ पहले यह सिर्फ़ नीचे लिखी हुई `_stateDistricts` सूची से बनता था —
  /// हर राज्य के 8-10 ज़िले, कुल 177। पर सर्वर पर **519 ज़िलों** का भाव है।
  /// यानी किसान का ज़िला सूची में होता ही नहीं था, और अगर होता भी तो सर्वर
  /// अंग्रेज़ी नाम ("Salem") भेजता है जबकि सूची में हिंदी ("सलेम") था —
  /// इसलिए छाँटने पर सूची **ख़ाली** मिलती थी।
  ///
  /// अब सूची **असली भाव से** बनती है। जो ज़िला डेटा में है वही दिखता है,
  /// इसलिए छँटाई कभी ख़ाली नहीं जाती। भाव न आए हों (नमूना भाव चल रहे हों)
  /// तो पुरानी सूची पर लौट जाते हैं।
  List<String> get _availableDistricts {
    if (_selectedState == null) return [];

    final fromData = _allRates
        .where((r) => r.state == _selectedState && r.district.trim().isNotEmpty)
        .map((r) => r.district)
        .toSet()
        .toList()
      ..sort();

    if (fromData.isNotEmpty) return fromData;
    return _stateDistricts[_selectedState] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRates;

    // इस समय परदे पर कितने असली, कितने नमूना — तीनों पट्टियाँ इसी से तय होती हैं
    final realHere = _realCount(filtered);
    final sampleHere = filtered.length - realHere;
    final allReal = sampleHere == 0 && realHere > 0;
    final noneReal = realHere == 0;

    // सूची के सिर पर लगने वाली सूचनाएँ — ये अब चिपकी नहीं रहतीं
    final upariSoochna =
        _upariSoochnaayen(realHere, sampleHere, allReal, noneReal);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('moreMandi')),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoadingReal)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
          // ── Filters ──
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ── राज्य + ज़िला चुनने के कार्ड (खोज-सहित शीट खोलते हैं) ──
                Row(
                  children: [
                    Expanded(
                      child: _pickerCard(
                        icon: Icons.location_on_rounded,
                        label: _t('mandiStateLabel'),
                        value: _selectedState == null
                            ? null
                            : _stateName(_selectedState!),
                        onTap: _pickState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _pickerCard(
                        icon: Icons.holiday_village_rounded,
                        label: _t('mandiDistrictLabel'),
                        value: _selectedDistrict == null
                            ? null
                            : _districtName(_selectedDistrict!),
                        // राज्य चुने बिना ज़िला नहीं
                        onTap: _selectedState == null ? null : _pickDistrict,
                      ),
                    ),
                  ],
                ),

                // कोई filter लगा हो तो "साफ़ करें"
                if (_selectedState != null ||
                    _selectedDistrict != null ||
                    _searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _selectedState = null;
                        _selectedDistrict = null;
                        _searchQuery = '';
                      }),
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      label: Text(_t('mandiClearFilter')),
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Crop Search Bar
                TextField(
                  onChanged: (v) => setState(() { _searchQuery = v; }),
                  decoration: InputDecoration(
                    hintText: _t('mandiSearchHint'),
                    hintStyle: const TextStyle(fontSize: 15),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),

          // ── MSP Legend ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text(_t('mspAbove'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(width: 16),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text(_t('mspBelow'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(width: 16),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text(_t('mspNA'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const Spacer(),
                Text('${filtered.length} ${_t('mandiResults')}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),

          // ── भाव कब के हैं और कब आए ────────────────────────────────
          //
          // दो अलग बातें, दोनों ज़रूरी:
          //  📅 मंडी में सौदा किस दिन हुआ (सबसे नई तारीख़)
          //  🕒 हमारे सर्वर ने वह भाव कब उठाया
          //
          // सिर्फ़ उठाने का समय दिखे तो 2 दिन पुराना भाव ताज़ा लगेगा।
          // सिर्फ़ तारीख़ दिखे तो पता नहीं चलेगा कि जानकारी कितनी बासी है।
          if (_latestDate(filtered) != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              color: DairyTheme.primaryTeal.withValues(alpha: 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 ${_t('mandiRatesAsOf')} ${_shortDate(_latestDate(filtered)!)}'
                    '${_ageNote(_latestDate(filtered)!)}',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DairyTheme.primaryTeal),
                  ),
                  // "ऐप में आए" तभी लिखो जब इस सूची में सचमुच सर्वर का भाव हो।
                  // नमूना भावों को कोई सर्वर नहीं उठाता — वहाँ यह समय लिखना
                  // झूठ है और उन्हें ताज़ा दिखा देता है।
                  if (_fetchedAt != null && realHere > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '🕒 ${_isHi ? "ऐप में आए" : "Fetched"}: ${_dateTimeText(_fetchedAt!)}',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                      ),
                    ),
                ],
              ),
            ),

          // ── नीचे की सूचनाएँ अब सूची के **साथ सरकती** हैं ───────────
          //
          // 8 अगस्त 2026, असली फ़ोन (1080×1920) पर पकड़ा गया: छाननी और ये
          // तीनों डिब्बे मिलकर ऊपर की ~1280px घेर लेते थे। यानी भाव — जिसके
          // लिए किसान यह पन्ना खोलता है — के लिए मुश्किल से एक कार्ड जितनी
          // जगह बचती थी, और वह भी आधा कटा हुआ।
          //
          // ⚠️ भरोसे की गारंटी इससे टूटती नहीं: हर कार्ड पर अपना 🟢/🟠
          // निशान है (देखें `_buildRateCard`) और वह हमेशा साथ रहता है।
          // ये डिब्बे एक बार पढ़ने की चीज़ हैं — हमेशा घूरने की नहीं।
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(_t('mandiNoResult'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_t('mandiNoResultHint'),
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: upariSoochna.length + filtered.length,
                    itemBuilder: (context, index) =>
                        index < upariSoochna.length
                            ? upariSoochna[index]
                            : _buildRateCard(
                                filtered[index - upariSoochna.length]),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  /// सूची के सिर पर लगने वाली सूचनाएँ — स्रोत, चेतावनी, अस्वीकरण
  List<Widget> _upariSoochnaayen(
      int realHere, int sampleHere, bool allReal, bool noneReal) {
    return [
      // ── ⭑ स्रोत — ये आँकड़े कहाँ से आए ─────────────────────────
      //
      // खाद कैलकुलेटर की तरह यहाँ भी ज़िम्मेदारी साफ़ लिखी रहे।
      //
      // ⚠️ तीन अलग हालतें हैं, और तीसरी सबसे ख़तरनाक थी:
      //   1. सब असली      → Agmarknet का नाम लिखो
      //   2. सब नमूना     → साफ़ लिखो कि भाव असली नहीं
      //   3. **मिले-जुले** → पहले यहाँ हालत 1 वाला वाक्य छपता था, यानी
      //      ऐप के बनाए भाव भी "भारत सरकार के Agmarknet से" कहलाते थे।
      //      अब गिनती लिखते हैं ताकि किसान को पता रहे कि सूची में सब
      //      असली नहीं है, और हर कार्ड पर अलग निशान भी है।
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: DairyTheme.primaryTeal.withValues(alpha: 0.05),
          border: const Border(
            left: BorderSide(color: DairyTheme.primaryTeal, width: 3),
          ),
        ),
        child: Text(
          allReal
              ? (_isHi
                  ? '⭑ स्रोत: Agmarknet (कृषि एवं किसान कल्याण मंत्रालय, भारत सरकार) — data.gov.in से। MSP: कृषि लागत एवं मूल्य आयोग (CACP) 2024-25।'
                  : '⭑ Source: Agmarknet (Ministry of Agriculture & Farmers Welfare, Govt. of India) via data.gov.in. MSP: CACP 2024-25.')
              : noneReal
                  ? (_isHi
                      ? '⭑ ये भाव ऐप के भीतर रखे अनुमान हैं (MSP के आसपास बनाए गए)। MSP के आँकड़े कृषि लागत एवं मूल्य आयोग (CACP) 2024-25 से हैं और सही हैं — पर मंडी का भाव असली नहीं है।'
                      : '⭑ These are indicative rates built into the app around MSP. The MSP figures are genuine (CACP 2024-25) but the mandi rates are not live.')
                  : (_isHi
                      ? '⭑ इस सूची में $realHere भाव असली हैं (Agmarknet — कृषि मंत्रालय, भारत सरकार) और $sampleHere ऐप के अपने अनुमान। असली वालों पर हरा 🟢 निशान है, अनुमान वालों पर नारंगी। MSP: CACP 2024-25।'
                      : '⭑ $realHere rates here are live (Agmarknet, Govt. of India) and $sampleHere are the app\'s own estimates. Live ones carry a green 🟢 mark, estimates an orange one. MSP: CACP 2024-25.'),
          style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: allReal
                  ? Colors.teal.shade900
                  : Colors.grey.shade800),
        ),
      ),

      // ⚠️ जब सूची में एक भी **नमूना** भाव हो तो चेतावनी दिखाओ।
      //
      // पहले शर्त `!_hasRealRates` थी — यानी सर्वर से *कहीं का भी* भाव आ
      // जाए तो चेतावनी ग़ायब। पर पहली माँग `LIMIT` पर कट जाती है, इसलिए
      // अकारादि क्रम में बाद आने वाले राज्यों (महाराष्ट्र, राजस्थान,
      // पंजाब…) का किसान पूरी सूची नक़ली देखता — बिना किसी चेतावनी के,
      // ऊपर "भारत सरकार" लिखा हुआ। अब शर्त उसी पर है जो परदे पर दिख रहा है।
      if (sampleHere > 0)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: Colors.orange.withValues(alpha: 0.13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  noneReal
                      ? (_isHi
                          ? 'ये अनुमानित भाव हैं, असली मंडी भाव नहीं। बेचने से पहले अपनी मंडी या eNAM (enam.gov.in) से आज का भाव ज़रूर पता कीजिए।'
                          : 'These are indicative rates, not live mandi prices. Check your mandi or eNAM (enam.gov.in) before selling.')
                      : (_isHi
                          ? 'नारंगी निशान वाले $sampleHere भाव ऐप के अनुमान हैं, असली मंडी भाव नहीं। बेचने से पहले अपनी मंडी या eNAM (enam.gov.in) से आज का भाव ज़रूर पता कीजिए।'
                          : '$sampleHere rates marked orange are app estimates, not live mandi prices. Check your mandi or eNAM (enam.gov.in) before selling.'),
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepOrange.shade900),
                ),
              ),
            ],
          ),
        ),

      // सामान्य अस्वीकरण — **सिर्फ़ तब**, जब ऊपर वाली नारंगी चेतावनी न दिखी हो।
      //
      // दोनों एक ही बात कहते हैं ("बेचने से पहले मंडी में पुष्टि करें")। पहले
      // दोनों एक साथ दिखते थे और मिलकर आधी screen खा जाते थे। नारंगी वाली
      // ज़्यादा काम की है क्योंकि उसमें गिनती भी होती है — वह हो तो यह नहीं।
      if (sampleHere == 0)
        Card(
          color: Colors.orange.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.orange.shade200, width: 0.5),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.orange.shade800, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _t('mandiDisclaimer'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _buildRateCard(_MandiRate rate) {
    final hasMsp = rate.msp > 0;
    final diff = hasMsp ? rate.modalPrice - rate.msp : 0.0;
    final isAboveMsp = diff >= 0;

    return Card(
      elevation: 2,
      // ⚠️ नमूना भाव का कार्ड देखने में ही अलग रहे। इस ऐप के बहुत से किसान
      // पढ़ नहीं पाते (देखें docs/purane/ANPADH_FRIENDLY_UI_PLAN.md) — उनके
      // लिए नारंगी किनारा और नारंगी रंग ही असली चेतावनी है, लिखा हुआ वाक्य
      // नहीं। असली भाव का कार्ड सफ़ेद और सादा रहता है।
      color: rate.isReal ? null : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: rate.isReal
            ? BorderSide.none
            : BorderSide(color: Colors.orange.shade300, width: 1.2),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Commodity + MSP Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    _cropName(rate.commodity),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (hasMsp)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAboveMsp ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isAboveMsp ? Colors.green : Colors.red, width: 0.5),
                    ),
                    child: Text(
                      isAboveMsp
                          ? (_isHi ? '▲ MSP से ₹${diff.abs().toStringAsFixed(0)} ऊपर' : '▲ ₹${diff.abs().toStringAsFixed(0)} above MSP')
                          : (_isHi ? '▼ MSP से ₹${diff.abs().toStringAsFixed(0)} कम ⚠️' : '▼ ₹${diff.abs().toStringAsFixed(0)} below MSP ⚠️'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAboveMsp ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Location + तारीख़
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📍 ${_districtName(rate.district)} ${_isHi ? 'मंडी' : 'Mandi'} · ${_stateName(rate.state)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
                if (rate.date != null) ...[
                  const SizedBox(width: 8),
                  Text('📅 ${_shortDate(rate.date!)}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500)),
                ],
              ],
            ),

            // ── 🟢 असली या 🟠 अनुमान — हर कार्ड पर, कभी छूटे नहीं ──────
            //
            // सर्वर के पास हर राज्य का भाव नहीं है, इसलिए एक ही सूची में
            // दोनों तरह के भाव मिल जाते हैं। ऊपर की पट्टी पूरी सूची की बात
            // करती है; किसान तो एक कार्ड देखकर फ़ैसला करता है, इसलिए निशान
            // यहाँ भी चाहिए।
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: rate.isReal ? Colors.green.shade50 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: rate.isReal
                        ? Colors.green.shade300
                        : Colors.deepOrange.shade300,
                    width: 0.8),
              ),
              child: Text(
                rate.isReal
                    ? (_isHi ? '🟢 असली मंडी भाव' : '🟢 Live mandi rate')
                    : (_isHi ? '🟠 ऐप का अनुमान — असली भाव नहीं' : '🟠 App estimate — not a live rate'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: rate.isReal
                      ? Colors.green.shade900
                      : Colors.deepOrange.shade900,
                ),
              ),
            ),
            const Divider(height: 16),

            // Prices Row
            Row(
              children: [
                _priceColumn(_t('pMin'), rate.minPrice, Colors.orange),
                _priceColumn(_t('pMax'), rate.maxPrice, Colors.blue),
                _priceColumn(_t('pModal'), rate.modalPrice, DairyTheme.primaryTeal),
                if (hasMsp)
                  _priceColumn('MSP', rate.msp, Colors.purple),
              ],
            ),

            const SizedBox(height: 8),

            // Share Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  final shareMsg = _isHi
                      ? '📊 *मंडी भाव (Pro Kisan)*\n\n'
                        '🌾 *${rate.commodity}*\n'
                        '📍 ${rate.district} मंडी, ${rate.state}\n\n'
                        '💰 न्यूनतम: ₹${rate.minPrice.toStringAsFixed(0)}/क्विंटल\n'
                        '💰 अधिकतम: ₹${rate.maxPrice.toStringAsFixed(0)}/क्विंटल\n'
                        '💰 मॉडल भाव: ₹${rate.modalPrice.toStringAsFixed(0)}/क्विंटल\n'
                        '${hasMsp ? "🏷️ MSP: ₹${rate.msp.toStringAsFixed(0)}/क्विंटल\n" : ""}\n'
                        '📲 *प्रो किसान ऐप* से भेजा गया'
                      : '📊 *Mandi Rates (Pro Kisan)*\n\n'
                        '🌾 *${_cropName(rate.commodity)}*\n'
                        '📍 ${_districtName(rate.district)} Mandi, ${_stateName(rate.state)}\n\n'
                        '💰 Min: ₹${rate.minPrice.toStringAsFixed(0)}/quintal\n'
                        '💰 Max: ₹${rate.maxPrice.toStringAsFixed(0)}/quintal\n'
                        '💰 Modal: ₹${rate.modalPrice.toStringAsFixed(0)}/quintal\n'
                        '${hasMsp ? "🏷️ MSP: ₹${rate.msp.toStringAsFixed(0)}/quintal\n" : ""}\n'
                        '📲 Sent via *Pro Kisan App*';
                  Share.share(shareMsg);
                },
                icon: const Icon(Icons.share_rounded, size: 16, color: Colors.green),
                label: Text(_t('mandiShareBtn'), style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// राज्य/ज़िला चुनने का कार्ड — साफ़, बड़ा, tap पर खोज-शीट खोलता है।
  /// पहले सादे dropdown थे; 20 राज्य + 200 ज़िले scroll में ढूँढना कठिन था।
  Widget _pickerCard({
    required IconData icon,
    required String label,
    required String? value,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: value != null
                  ? Colors.blue.shade400
                  : Colors.grey.shade300,
              width: value != null ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: disabled ? Colors.grey.shade400 : Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                  Text(
                    value ?? _t('mandiSelectAll'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: value != null
                            ? Colors.black87
                            : Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded,
                color: disabled ? Colors.grey.shade300 : Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Future<void> _pickState() async {
    final picked = await _showSearchPicker(
      title: _t('mandiStateLabel'),
      options: _stateDistricts.keys.toList(),
      display: _stateName,
      current: _selectedState,
    );
    if (picked == null) return;
    setState(() {
      // "सभी" चुना (खाली) तो राज्य हटा दो
      _selectedState = picked.isEmpty ? null : picked;
      _selectedDistrict = null; // राज्य बदला → ज़िला रीसेट
    });

    // ⚠️ अब उसी राज्य का भाव सर्वर से अलग से माँगो।
    //
    // पहली माँग पूरे भारत की होती है और सर्वर उसे `LIMIT` पर काट देता है
    // (`ORDER BY arrival_date DESC, state, …`), यानी राज्य के अकारादि क्रम
    // में शुरू के 7-8 राज्य आते हैं और बाक़ी सब कट जाते हैं।
    //
    // 5 अगस्त 2026 की जाँच: डेटाबेस में सारे **28 राज्यों** का भाव मौजूद है
    // (1,04,128 पंक्तियाँ — अकेले तमिलनाडु की 40,103), पर बिना छाँटे माँगने
    // पर ऐप तक सिर्फ़ 7 राज्य पहुँचते थे। तमिलनाडु/महाराष्ट्र/पंजाब का किसान
    // पूरी नक़ली सूची देखता, जबकि उसका असली भाव सर्वर पर पड़ा था।
    //
    // राज्य के नाम से माँगने पर कटाई का सवाल ही नहीं उठता — जाँच में
    // तमिलनाडु 3000, महाराष्ट्र 3000, बिहार 317, राजस्थान 1251 पंक्तियाँ आईं।
    if (_selectedState != null) _fetchStateRates(_selectedState!);
  }

  /// एक राज्य (या राज्य + ज़िले) का भाव सर्वर से लाकर सूची में जोड़ो।
  ///
  /// उसी दायरे के पुराने **असली** भाव हटा देते हैं (ताज़ा जवाब ही सही है),
  /// पर **नमूना** भाव छोड़ देते हैं — सर्वर के पास उस राज्य के सारे ज़िले
  /// नहीं होते, और नमूना हटा दें तो किसान को ख़ाली सूची मिलेगी।
  Future<void> _fetchStateRates(String state, {String? district}) async {
    if (mounted) setState(() => _isLoadingReal = true);
    try {
      final url = Uri.parse(ServerConfig.mandiUrl).replace(queryParameters: {
        'state': state,
        if (district != null) 'district': district,
        'days': '7',
        'limit': '3000',
      });
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(() => _isLoadingReal = false);
        return;
      }
      final List data = jsonDecode(response.body);
      final fetched = data.map(_rateFromJson).toList();
      setState(() {
        _isLoadingReal = false;
        if (fetched.isEmpty) return;
        _allRates = [
          ...fetched,
          // उसी दायरे की पुरानी असली पंक्तियाँ हटाओ — दोहरी न दिखें।
          // ज़िला माँगा था तो सिर्फ़ उसी ज़िले की हटाओ, वरना पूरे राज्य की।
          ..._allRates.where((r) => !(r.isReal &&
              r.state == state &&
              (district == null || r.district == district))),
        ];
        _fetchedAt = DateTime.tryParse(
            (data.first['fetchedAt'] ?? '').toString().replaceFirst(' ', 'T'));
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingReal = false);
    }
  }

  Future<void> _pickDistrict() async {
    final picked = await _showSearchPicker(
      title: _t('mandiDistrictLabel'),
      options: _availableDistricts,
      display: _districtName,
      current: _selectedDistrict,
    );
    if (picked == null) return;
    setState(() => _selectedDistrict = picked.isEmpty ? null : picked);

    // ⚠️ बड़े राज्य 3000 की हद पर भी कट जाते हैं (तमिलनाडु के 40,103 भाव हैं),
    // इसलिए ज़िला चुनते ही उसी ज़िले का भाव अलग से माँगो। एक ज़िले की
    // पंक्तियाँ कभी 3000 से ऊपर नहीं जातीं, इसलिए यहाँ कटाई नहीं होती।
    if (_selectedState != null && _selectedDistrict != null) {
      _fetchStateRates(_selectedState!, district: _selectedDistrict);
    }
  }

  /// खोज-सहित चयन शीट। खाली string = "सभी" (filter हटाओ)।
  Future<String?> _showSearchPicker({
    required String title,
    required List<String> options,
    required String Function(String) display,
    required String? current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchPickerSheet(
        title: title,
        options: options,
        display: display,
        current: current,
        allLabel: _t('mandiSelectAll'),
        searchHint: _t('mandiPickerSearch'),
      ),
    );
  }

  Widget _priceColumn(String label, double price, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
          Text(_t('perQuintal'), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────
class _MandiRate {
  final String state, district, mandi, commodity;
  final double minPrice, maxPrice, modalPrice, msp;

  /// भाव किस तारीख़ का है (server से आता है; नमूना भावों में null)
  final DateTime? date;

  /// ⚠️ यह भाव **सचमुच मंडी का है** (सर्वर → Agmarknet) या ऐप का बनाया हुआ
  /// नमूना है।
  ///
  /// सर्वर पर भाव तो सारे राज्यों का है (5 अगस्त 2026 को 28 राज्य, 1,04,128
  /// पंक्तियाँ), पर एक बार में सब नहीं आ सकता — सर्वर `LIMIT` पर काट देता है।
  /// इसलिए ऐप में हमेशा कुछ जगह नमूना भाव भरे रहते हैं, ताकि सूची ख़ाली न लगे।
  ///
  /// दोनों एक ही सूची में मिल जाते हैं, इसलिए **हर पंक्ति पर** यह निशान
  /// ज़रूरी है — वरना किसान ऐप का बनाया हुआ भाव "भारत सरकार के Agmarknet से"
  /// समझकर फ़सल लेकर मंडी चला जाएगा।
  final bool isReal;

  const _MandiRate({
    required this.state, required this.district, required this.mandi,
    required this.commodity, required this.minPrice, required this.maxPrice,
    required this.modalPrice, required this.msp, this.date,
    this.isReal = false,
  });
}

class _CropPrice {
  final String name;
  final double msp;
  final List<double> prices; // [min, max, modal]

  const _CropPrice(this.name, this.msp, this.prices);
}

/// राज्य/ज़िला चुनने की खोज-सहित शीट।
/// ऊपर "सभी" (filter हटाओ), फिर खोज बार, फिर सूची।
class _SearchPickerSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final String Function(String) display;
  final String? current;
  final String allLabel;
  final String searchHint;

  const _SearchPickerSheet({
    required this.title,
    required this.options,
    required this.display,
    required this.current,
    required this.allLabel,
    required this.searchHint,
  });

  @override
  State<_SearchPickerSheet> createState() => _SearchPickerSheetState();
}

class _SearchPickerSheetState extends State<_SearchPickerSheet> {
  final _ctrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // खोज — हिंदी और अंग्रेज़ी दोनों नाम पर मिलान
    final q = _q.trim().toLowerCase();
    final filtered = widget.options.where((o) {
      if (q.isEmpty) return true;
      return o.toLowerCase().contains(q) ||
          widget.display(o).toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  // "सभी" — filter हटाने के लिए (खाली string लौटाता है)
                  ListTile(
                    leading: Icon(Icons.public_rounded,
                        color: Colors.blue.shade700),
                    title: Text(widget.allLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: widget.current == null
                        ? Icon(Icons.check_rounded, color: Colors.blue.shade700)
                        : null,
                    onTap: () => Navigator.pop(context, ''),
                  ),
                  const Divider(height: 1),
                  ...filtered.map((o) {
                    final sel = o == widget.current;
                    return ListTile(
                      title: Text(widget.display(o),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w500)),
                      trailing: sel
                          ? Icon(Icons.check_rounded,
                              color: Colors.blue.shade700)
                          : null,
                      onTap: () => Navigator.pop(context, o),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
