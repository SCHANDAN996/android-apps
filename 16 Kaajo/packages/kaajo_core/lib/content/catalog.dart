import 'package:flutter/material.dart';

import '../models/service_item.dart';

/// सारी सेवाएँ और रेट एक जगह। रेट बदलना हो तो सिर्फ़ यहीं बदलें।
class Catalog {
  Catalog._();

  static const ServiceItem solarCleaning = ServiceItem(
    id: 'solar_cleaning',
    title: 'सोलर पैनल सफ़ाई',
    shortLine: 'धूल और गंदगी हटाकर पूरी बिजली',
    icon: Icons.cleaning_services,
    priceFrom: 600,
    priceLabel: '₹600 से',
    priceNote: '3 kW तक ₹600, उससे बड़े सिस्टम पर ₹150 प्रति अतिरिक्त kW',
    duration: '45 मिनट से 1 घंटा',
    extraPerKwAbove3: 150,
    includes: [
      'साफ़ पानी और मुलायम ब्रश से हर पैनल की सफ़ाई',
      'पक्षी की बीट और जमी हुई धूल हटाना',
      'ढीले तार और कनेक्टर की नज़र से जाँच',
      'सफ़ाई से पहले और बाद की फ़ोटो आपके WhatsApp पर',
    ],
    faqs: [
      Faq('कितने दिन में सफ़ाई करानी चाहिए?',
          'वाराणसी की धूल में हर 2–3 महीने में एक बार। गर्मी और कटाई के मौसम में जल्दी।'),
      Faq('क्या सफ़ाई से पैनल को नुकसान हो सकता है?',
          'नहीं। हम सिर्फ़ साफ़ पानी और मुलायम ब्रश इस्तेमाल करते हैं, कोई केमिकल या कड़ा ब्रश नहीं।'),
      Faq('सफ़ाई किस समय करानी चाहिए?',
          'सुबह या शाम। दोपहर में गर्म पैनल पर ठंडा पानी डालना ठीक नहीं।'),
    ],
  );

  static const ServiceItem solarRepair = ServiceItem(
    id: 'solar_repair',
    title: 'सोलर जाँच और रिपेयर',
    shortLine: 'कम बिजली, इन्वर्टर एरर, तार की ख़राबी',
    icon: Icons.build,
    priceFrom: 500,
    priceLabel: '₹500 विज़िट',
    priceNote: 'पार्ट्स का पैसा अलग, पक्के बिल पर। खर्च पहले बताएँगे, आपकी हाँ के बाद ही काम।',
    duration: '1 से 2 घंटे',
    needsProblem: true,
    includes: [
      'इन्वर्टर का एरर और कम बिजली बनने की वजह पता करना',
      'तार, कनेक्टर, अर्थिंग और नेट मीटर की जाँच',
      'ख़राबी की फ़ोटो और खर्च का अनुमान पहले',
      'वारंटी वाले पार्ट कंपनी से बदलवाने में मदद',
    ],
    faqs: [
      Faq('पार्ट बदलना पड़ा तो?',
          'पहले फ़ोटो के साथ खर्च बताएँगे। आपकी हाँ के बाद ही पार्ट लगेगा, और पुराना पार्ट आपको लौटा देंगे।'),
      Faq('मेरा सिस्टम वारंटी में है, फिर भी पैसा लगेगा?',
          'वारंटी वाला पार्ट कंपनी से मुफ़्त आता है। हम सिर्फ़ विज़िट और लगाने की मेहनत का पैसा लेते हैं।'),
      Faq('क्या आप किसी भी कंपनी का सिस्टम देखते हैं?',
          'हाँ, किसी भी वेंडर या कंपनी का लगाया सिस्टम।'),
    ],
  );

  static const ServiceItem solarAmc = ServiceItem(
    id: 'solar_amc',
    title: 'सालाना देखभाल (AMC)',
    shortLine: 'साल भर देखभाल: 4 सफ़ाई + हेल्थ चेक',
    icon: Icons.verified_user,
    priceFrom: 2400,
    priceLabel: '₹2,400 / साल',
    priceNote: '3 kW तक। हर 3 महीने में एक विज़िट।',
    duration: 'साल में 4 विज़िट',
    includes: [
      'साल में 4 बार पैनल की सफ़ाई',
      'हर विज़िट पर इन्वर्टर और तारों का हेल्थ चेक',
      'शिकायत आने पर सबसे पहले विज़िट',
      'हर विज़िट की फ़ोटो रिपोर्ट',
    ],
    faqs: [
      Faq('AMC से क्या बचत है?',
          '4 बार अलग-अलग सफ़ाई ₹2,400 की पड़ती है, AMC में उसी रेट पर हेल्थ चेक और प्राथमिकता भी मिलती है।'),
      Faq('विज़िट की तारीख कौन तय करेगा?',
          'हम हर 3 महीने पर ख़ुद याद दिलाएँगे और आपकी सुविधा का समय लेंगे।'),
    ],
  );

  /// अभी चालू सेवाएँ (घर वाले के होम पर)।
  static const List<ServiceItem> active = [solarCleaning, solarRepair, solarAmc];

  /// जल्द आने वाली सेवाएँ।
  static const List<ServiceItem> comingSoon = [
    ServiceItem(
      id: 'bathroom_cleaning', title: 'बाथरूम सफ़ाई',
      shortLine: 'बाथरूम की गहरी सफ़ाई', icon: Icons.cleaning_services,
      priceFrom: 0, priceLabel: 'जल्द', available: false,
    ),
    ServiceItem(
      id: 'plumbing', title: 'प्लंबर',
      shortLine: 'नल, पाइप और पानी की दिक्कत', icon: Icons.plumbing,
      priceFrom: 0, priceLabel: 'जल्द', available: false,
    ),
    ServiceItem(
      id: 'home_help', title: 'घर के काम में मदद',
      shortLine: 'रोज़मर्रा के घरेलू काम', icon: Icons.home_repair_service,
      priceFrom: 0, priceLabel: 'जल्द', available: false,
    ),
    ServiceItem(
      id: 'tank_cleaning',
      title: 'पानी की टंकी सफ़ाई',
      shortLine: 'साफ़ टंकी, साफ़ पानी',
      icon: Icons.water_drop,
      priceFrom: 0,
      priceLabel: 'जल्द',
      available: false,
    ),
    ServiceItem(
      id: 'inverter_repair',
      title: 'इन्वर्टर और बैटरी',
      shortLine: 'रिपेयर और बैटरी जाँच',
      icon: Icons.battery_charging_full,
      priceFrom: 0,
      priceLabel: 'जल्द',
      available: false,
    ),
    ServiceItem(
      id: 'electrical',
      title: 'इलेक्ट्रिशियन',
      shortLine: 'पंखा, वायरिंग, स्विच',
      icon: Icons.electrical_services,
      priceFrom: 0,
      priceLabel: 'जल्द',
      available: false,
    ),
    ServiceItem(
      id: 'labour',
      title: 'मज़दूर बुकिंग',
      shortLine: 'घर के काम के लिए मज़दूर',
      icon: Icons.engineering,
      priceFrom: 0,
      priceLabel: 'जल्द',
      available: false,
    ),
  ];

  static ServiceItem? byId(String id) {
    for (final s in [...active, ...comingSoon]) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// रिपेयर में चुनने वाली दिक्कतें।
  static const List<String> problems = [
    'बिजली कम बन रही है',
    'इन्वर्टर बंद है या एरर दिखा रहा है',
    'तार या कनेक्टर की दिक्कत',
    'मीटर या नेट मीटर की दिक्कत',
    'पैनल टूटा या खिसका है',
    'कुछ और',
  ];

  /// सिस्टम के साइज़ के विकल्प (kW)।
  static const List<int> kwOptions = [1, 2, 3, 4, 5, 6];

  /// kW विकल्प का लेबल (6 = "5 से ज़्यादा")।
  static String kwLabel(int kw) => kw >= 6 ? '5+ kW' : '$kw kW';

  /// समय की पालियाँ।
  static const List<String> timeSlots = ['सुबह 7–10', 'सुबह 10–1', 'शाम 3–6'];

  /// पैनल सफ़ाई की पालियाँ: दोपहर नहीं (गर्म पैनल पर पानी से शीशे पर ज़ोर)।
  static const List<String> cleaningTimeSlots = ['सुबह 7–10', 'शाम 3–6'];

  /// वेंडर के लिए रेट कार्ड (रेट कार्ड स्क्रीन)।
  static const List<RateRow> vendorRates = [
    RateRow('शिकायत-विज़िट (जाँच और छोटी मरम्मत)', '₹500–600 प्रति विज़िट', 'काम के बाद, हफ़्ते या महीने का बिल'),
    RateRow('पार्ट्स', 'पक्के बिल पर, तय रेट लिस्ट से', '₹500 से ऊपर के पार्ट पर पहले आपकी हाँ'),
    RateRow('48 घंटे वाली जल्दी की विज़िट', 'सामान्य से थोड़ा ज़्यादा', 'काम के बाद'),
    RateRow('हमेशा तैयार रहने की पक्की फ़ीस (विकल्प)', '₹5,000 / महीना', 'महीने की शुरुआत में'),
    RateRow('वारंटी वाला पैनल या इन्वर्टर', 'सिर्फ़ लगाने की मेहनत', 'पार्ट कंपनी से आएगा'),
  ];

  /// वेंडर के हर काम का तरीका (रेट कार्ड पर दिखता है)।
  static const List<String> vendorProcess = [
    'जाँच करना',
    'ख़राबी की फ़ोटो आपको भेजना',
    'खर्च बताना',
    'आपकी हाँ लेना',
    'काम करना',
    'पुराना पार्ट आपको लौटाना',
    'ग्राहक से OTP लेकर काम पूरा',
  ];
}

/// रेट कार्ड की एक पंक्ति।
class RateRow {
  const RateRow(this.item, this.rate, this.when);

  final String item;
  final String rate;
  final String when;
}
