import 'app_language.dart';

/// "नक्शे से नापें" (tap / चलकर / सड़क की दूरी) की सारी strings, नौ भाषाओं में।
///
/// नई string जोड़ते समय नौ की नौ भाषाएँ भरें — `widget_test.dart` इस फ़ाइल
/// के हर pick map की चाबियाँ गिनता है। parameter वाली strings में
/// `${...}` की जगह `$name` लिखें: test का regex पहले `})` पर रुकता है।
extension MapStrings on AppStrings {
  // ─────────────────────────── Home card ───────────────────────────

  String get toolMap => pick(const {
        AppLang.hindi: 'नक्शे / GPS से नापें',
        AppLang.english: 'Measure on Map / GPS',
        AppLang.marathi: 'नकाशा / GPS ने मोजा',
        AppLang.gujarati: 'નકશા / GPS થી માપો',
        AppLang.punjabi: 'ਨਕਸ਼ੇ / GPS ਨਾਲ ਮਿਣੋ',
        AppLang.bengali: 'ম্যাপ / GPS দিয়ে মাপুন',
        AppLang.telugu: 'మ్యాప్ / GPS తో కొలవండి',
        AppLang.tamil: 'வரைபடம் / GPS மூலம் அளவிடு',
        AppLang.kannada: 'ನಕ್ಷೆ / GPS ನಿಂದ ಅಳೆಯಿರಿ',
      });

  String get toolMapSub => pick(const {
        AppLang.hindi: 'नक्शे पर टैप करके, खेत के चारों ओर चलकर, या सड़क की दूरी',
        AppLang.english: 'Tap on the map, walk around the field, or measure road distance',
        AppLang.marathi: 'नकाशावर टॅप करून, शेताभोवती चालून, किंवा रस्त्याचे अंतर',
        AppLang.gujarati: 'નકશા પર ટૅપ કરીને, ખેતરની ફરતે ચાલીને, અથવા રસ્તાનું અંતર',
        AppLang.punjabi: 'ਨਕਸ਼ੇ ਉੱਤੇ ਟੈਪ ਕਰਕੇ, ਖੇਤ ਦੁਆਲੇ ਤੁਰ ਕੇ, ਜਾਂ ਸੜਕ ਦੀ ਦੂਰੀ',
        AppLang.bengali: 'ম্যাপে ট্যাপ করে, জমির চারপাশে হেঁটে, বা রাস্তার দূরত্ব',
        AppLang.telugu: 'మ్యాప్‌పై ట్యాప్ చేసి, పొలం చుట్టూ నడిచి, లేదా రోడ్డు దూరం',
        AppLang.tamil: 'வரைபடத்தில் தட்டி, வயலைச் சுற்றி நடந்து, அல்லது சாலை தூரம்',
        AppLang.kannada: 'ನಕ್ಷೆಯ ಮೇಲೆ ಟ್ಯಾಪ್ ಮಾಡಿ, ಹೊಲದ ಸುತ್ತ ನಡೆದು, ಅಥವಾ ರಸ್ತೆ ದೂರ',
      });

  String get badgeMap => pick(const {
        AppLang.hindi: 'नया • GPS',
        AppLang.english: 'New • GPS',
        AppLang.marathi: 'नवीन • GPS',
        AppLang.gujarati: 'નવું • GPS',
        AppLang.punjabi: 'ਨਵਾਂ • GPS',
        AppLang.bengali: 'নতুন • GPS',
        AppLang.telugu: 'కొత్తది • GPS',
        AppLang.tamil: 'புதியது • GPS',
        AppLang.kannada: 'ಹೊಸದು • GPS',
      });

  // ─────────────────────────── Hub (तीन तरीक़े) ───────────────────────────

  String get mapTapTitle => pick(const {
        AppLang.hindi: 'नक्शे पर उंगली से नापें',
        AppLang.english: 'Tap on the map',
        AppLang.marathi: 'नकाशावर बोटाने मोजा',
        AppLang.gujarati: 'નકશા પર આંગળીથી માપો',
        AppLang.punjabi: 'ਨਕਸ਼ੇ ਉੱਤੇ ਉਂਗਲ ਨਾਲ ਮਿਣੋ',
        AppLang.bengali: 'ম্যাপে আঙুল দিয়ে মাপুন',
        AppLang.telugu: 'మ్యాప్‌పై వేలితో కొలవండి',
        AppLang.tamil: 'வரைபடத்தில் விரலால் அளவிடு',
        AppLang.kannada: 'ನಕ್ಷೆಯ ಮೇಲೆ ಬೆರಳಿನಿಂದ ಅಳೆಯಿರಿ',
      });

  String get mapTapBody => pick(const {
        AppLang.hindi: 'सैटेलाइट नक्शे पर खेत के कोनों या रास्ते के मोड़ों पर टैप करें। खेत पर जाने की ज़रूरत नहीं।',
        AppLang.english: 'Tap the field corners or road turns on the satellite map. No need to visit the field.',
        AppLang.marathi: 'सॅटेलाइट नकाशावर शेताच्या कोपऱ्यांवर किंवा रस्त्याच्या वळणांवर टॅप करा. शेतात जाण्याची गरज नाही.',
        AppLang.gujarati: 'સેટેલાઇટ નકશા પર ખેતરના ખૂણા કે રસ્તાના વળાંક પર ટૅપ કરો. ખેતરે જવાની જરૂર નથી.',
        AppLang.punjabi: 'ਸੈਟੇਲਾਈਟ ਨਕਸ਼ੇ ਉੱਤੇ ਖੇਤ ਦੇ ਕੋਨਿਆਂ ਜਾਂ ਸੜਕ ਦੇ ਮੋੜਾਂ ਉੱਤੇ ਟੈਪ ਕਰੋ। ਖੇਤ ਜਾਣ ਦੀ ਲੋੜ ਨਹੀਂ।',
        AppLang.bengali: 'স্যাটেলাইট ম্যাপে জমির কোণ বা রাস্তার বাঁকে ট্যাপ করুন। জমিতে যাওয়ার দরকার নেই।',
        AppLang.telugu: 'శాటిలైట్ మ్యాప్‌లో పొలం మూలలు లేదా రోడ్డు మలుపులపై ట్యాప్ చేయండి. పొలానికి వెళ్ళనక్కర్లేదు.',
        AppLang.tamil: 'செயற்கைக்கோள் வரைபடத்தில் வயல் மூலைகள் அல்லது சாலை திருப்பங்களில் தட்டவும். வயலுக்குப் போக வேண்டியதில்லை.',
        AppLang.kannada: 'ಉಪಗ್ರಹ ನಕ್ಷೆಯಲ್ಲಿ ಹೊಲದ ಮೂಲೆಗಳು ಅಥವಾ ರಸ್ತೆ ತಿರುವುಗಳ ಮೇಲೆ ಟ್ಯಾಪ್ ಮಾಡಿ. ಹೊಲಕ್ಕೆ ಹೋಗಬೇಕಿಲ್ಲ.',
      });

  String get mapWalkTitle => pick(const {
        AppLang.hindi: 'खेत के चारों ओर चलकर नापें',
        AppLang.english: 'Walk around the field',
        AppLang.marathi: 'शेताभोवती चालून मोजा',
        AppLang.gujarati: 'ખેતરની ફરતે ચાલીને માપો',
        AppLang.punjabi: 'ਖੇਤ ਦੁਆਲੇ ਤੁਰ ਕੇ ਮਿਣੋ',
        AppLang.bengali: 'জমির চারপাশে হেঁটে মাপুন',
        AppLang.telugu: 'పొలం చుట్టూ నడిచి కొలవండి',
        AppLang.tamil: 'வயலைச் சுற்றி நடந்து அளவிடு',
        AppLang.kannada: 'ಹೊಲದ ಸುತ್ತ ನಡೆದು ಅಳೆಯಿರಿ',
      });

  String get mapWalkBody => pick(const {
        AppLang.hindi: 'हर कोने पर रुककर बटन दबाएँ। इंटरनेट न हो तब भी चलता है।',
        AppLang.english: 'Stop at each corner and press the button. Works without internet too.',
        AppLang.marathi: 'प्रत्येक कोपऱ्यावर थांबून बटण दाबा. इंटरनेट नसतानाही चालते.',
        AppLang.gujarati: 'દરેક ખૂણે રોકાઈને બટન દબાવો. ઇન્ટરનેટ વગર પણ ચાલે છે.',
        AppLang.punjabi: 'ਹਰ ਕੋਨੇ ਉੱਤੇ ਰੁਕ ਕੇ ਬਟਨ ਦਬਾਓ। ਇੰਟਰਨੈੱਟ ਤੋਂ ਬਿਨਾਂ ਵੀ ਚੱਲਦਾ ਹੈ।',
        AppLang.bengali: 'প্রতিটি কোণে থেমে বোতাম চাপুন। ইন্টারনেট ছাড়াও চলে।',
        AppLang.telugu: 'ప్రతి మూల వద్ద ఆగి బటన్ నొక్కండి. ఇంటర్నెట్ లేకున్నా పనిచేస్తుంది.',
        AppLang.tamil: 'ஒவ்வொரு மூலையிலும் நின்று பொத்தானை அழுத்தவும். இணையம் இல்லாமலும் இயங்கும்.',
        AppLang.kannada: 'ಪ್ರತಿ ಮೂಲೆಯಲ್ಲಿ ನಿಂತು ಬಟನ್ ಒತ್ತಿರಿ. ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆಯೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ.',
      });

  String get mapRoadTitle => pick(const {
        AppLang.hindi: 'सड़क / रास्ते की दूरी',
        AppLang.english: 'Road / path distance',
        AppLang.marathi: 'रस्ता / वाटेचे अंतर',
        AppLang.gujarati: 'રસ્તા / માર્ગનું અંતર',
        AppLang.punjabi: 'ਸੜਕ / ਰਸਤੇ ਦੀ ਦੂਰੀ',
        AppLang.bengali: 'রাস্তা / পথের দূরত্ব',
        AppLang.telugu: 'రోడ్డు / దారి దూరం',
        AppLang.tamil: 'சாலை / பாதை தூரம்',
        AppLang.kannada: 'ರಸ್ತೆ / ದಾರಿಯ ದೂರ',
      });

  String get mapRoadBody => pick(const {
        AppLang.hindi: 'पैदल, बाइक या गाड़ी से चलते जाइए — दूरी अपने आप जुड़ती जाएगी।',
        AppLang.english: 'Walk, ride or drive along it — the distance adds up on its own.',
        AppLang.marathi: 'चालत, बाईकने किंवा गाडीने जा — अंतर आपोआप जोडले जाईल.',
        AppLang.gujarati: 'ચાલીને, બાઇક કે ગાડીથી જાઓ — અંતર આપમેળે ઉમેરાશે.',
        AppLang.punjabi: 'ਪੈਦਲ, ਬਾਈਕ ਜਾਂ ਗੱਡੀ ਨਾਲ ਚੱਲਦੇ ਜਾਓ — ਦੂਰੀ ਆਪਣੇ ਆਪ ਜੁੜਦੀ ਜਾਵੇਗੀ।',
        AppLang.bengali: 'হেঁটে, বাইকে বা গাড়িতে চলুন — দূরত্ব নিজে থেকেই যোগ হবে।',
        AppLang.telugu: 'నడిచి, బైక్ లేదా వాహనంలో వెళ్ళండి — దూరం దానంతట అదే కలుస్తుంది.',
        AppLang.tamil: 'நடந்து, பைக் அல்லது வாகனத்தில் செல்லுங்கள் — தூரம் தானாகக் கூடும்.',
        AppLang.kannada: 'ನಡೆದು, ಬೈಕ್ ಅಥವಾ ವಾಹನದಲ್ಲಿ ಹೋಗಿ — ದೂರ ತಾನಾಗಿಯೇ ಸೇರುತ್ತದೆ.',
      });

  String get mapSavedTitle => pick(const {
        AppLang.hindi: 'सहेजे हुए नाप',
        AppLang.english: 'Saved measurements',
        AppLang.marathi: 'जतन केलेली मोजमापे',
        AppLang.gujarati: 'સાચવેલાં માપ',
        AppLang.punjabi: 'ਸੰਭਾਲੇ ਹੋਏ ਨਾਪ',
        AppLang.bengali: 'সংরক্ষিত মাপ',
        AppLang.telugu: 'సేవ్ చేసిన కొలతలు',
        AppLang.tamil: 'சேமித்த அளவீடுகள்',
        AppLang.kannada: 'ಉಳಿಸಿದ ಅಳತೆಗಳು',
      });

  String get mapNoSaved => pick(const {
        AppLang.hindi: 'अभी कोई नाप सहेजा नहीं गया है',
        AppLang.english: 'No saved measurements yet',
        AppLang.marathi: 'अजून कोणतेही मोजमाप जतन केलेले नाही',
        AppLang.gujarati: 'હજી કોઈ માપ સાચવ્યું નથી',
        AppLang.punjabi: 'ਅਜੇ ਕੋਈ ਨਾਪ ਸੰਭਾਲਿਆ ਨਹੀਂ ਗਿਆ',
        AppLang.bengali: 'এখনও কোনো মাপ সংরক্ষণ করা হয়নি',
        AppLang.telugu: 'ఇంకా ఏ కొలతా సేవ్ చేయలేదు',
        AppLang.tamil: 'இன்னும் எந்த அளவீடும் சேமிக்கப்படவில்லை',
        AppLang.kannada: 'ಇನ್ನೂ ಯಾವುದೇ ಅಳತೆ ಉಳಿಸಿಲ್ಲ',
      });

  String get mapAccuracyNote => pick(const {
        AppLang.hindi: 'GPS और नक्शे की नाप कुछ मीटर ऊपर-नीचे हो सकती है। रजिस्ट्री या कोर्ट के काम में अमीन की नापी ही मानें।',
        AppLang.english: 'GPS and map measurements can be off by a few metres. For registry or court matters, rely on an official survey.',
        AppLang.marathi: 'GPS आणि नकाशाचे मोजमाप काही मीटर कमी-जास्त असू शकते. नोंदणी किंवा कोर्टाच्या कामासाठी सरकारी मोजणीच माना.',
        AppLang.gujarati: 'GPS અને નકશાનું માપ થોડા મીટર આઘુંપાછું હોઈ શકે. દસ્તાવેજ કે કોર્ટના કામ માટે સરકારી માપણી જ માન્ય ગણો.',
        AppLang.punjabi: 'GPS ਅਤੇ ਨਕਸ਼ੇ ਦਾ ਨਾਪ ਕੁਝ ਮੀਟਰ ਉੱਪਰ-ਹੇਠਾਂ ਹੋ ਸਕਦਾ ਹੈ। ਰਜਿਸਟਰੀ ਜਾਂ ਅਦਾਲਤ ਦੇ ਕੰਮ ਲਈ ਪਟਵਾਰੀ ਦੀ ਮਿਣਤੀ ਹੀ ਮੰਨੋ।',
        AppLang.bengali: 'GPS ও ম্যাপের মাপ কয়েক মিটার এদিক-ওদিক হতে পারে। রেজিস্ট্রি বা আদালতের কাজে সরকারি আমিনের মাপই মানুন।',
        AppLang.telugu: 'GPS, మ్యాప్ కొలతలు కొన్ని మీటర్లు తేడా రావచ్చు. రిజిస్ట్రేషన్ లేదా కోర్టు పనులకు ప్రభుత్వ సర్వేనే నమ్మండి.',
        AppLang.tamil: 'GPS மற்றும் வரைபட அளவு சில மீட்டர் கூடக் குறைய இருக்கலாம். பதிவு அல்லது நீதிமன்ற வேலைக்கு அரசு அளவையே நம்புங்கள்.',
        AppLang.kannada: 'GPS ಮತ್ತು ನಕ್ಷೆಯ ಅಳತೆ ಕೆಲವು ಮೀಟರ್ ಹೆಚ್ಚು-ಕಡಿಮೆ ಆಗಬಹುದು. ನೋಂದಣಿ ಅಥವಾ ನ್ಯಾಯಾಲಯದ ಕೆಲಸಕ್ಕೆ ಸರ್ಕಾರಿ ಸರ್ವೆಯನ್ನೇ ನಂಬಿ.',
      });

  String get mapInternetNote => pick(const {
        AppLang.hindi: 'नक्शा इंटरनेट से आता है। चलकर नापना बिना इंटरनेट भी हो जाता है।',
        AppLang.english: 'The map needs internet. Walking measurements work offline too.',
        AppLang.marathi: 'नकाशासाठी इंटरनेट लागते. चालून मोजणे इंटरनेटशिवायही होते.',
        AppLang.gujarati: 'નકશા માટે ઇન્ટરનેટ જોઈએ. ચાલીને માપવાનું ઇન્ટરનેટ વગર પણ થાય છે.',
        AppLang.punjabi: 'ਨਕਸ਼ਾ ਇੰਟਰਨੈੱਟ ਤੋਂ ਆਉਂਦਾ ਹੈ। ਤੁਰ ਕੇ ਮਿਣਨਾ ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ ਵੀ ਹੋ ਜਾਂਦਾ ਹੈ।',
        AppLang.bengali: 'ম্যাপের জন্য ইন্টারনেট লাগে। হেঁটে মাপা ইন্টারনেট ছাড়াও হয়।',
        AppLang.telugu: 'మ్యాప్‌కు ఇంటర్నెట్ కావాలి. నడిచి కొలవడం ఇంటర్నెట్ లేకుండా కూడా అవుతుంది.',
        AppLang.tamil: 'வரைபடத்துக்கு இணையம் தேவை. நடந்து அளவிடுவது இணையம் இல்லாமலும் நடக்கும்.',
        AppLang.kannada: 'ನಕ್ಷೆಗೆ ಇಂಟರ್ನೆಟ್ ಬೇಕು. ನಡೆದು ಅಳೆಯುವುದು ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆಯೂ ಆಗುತ್ತದೆ.',
      });

  // ─────────────────────────── नक्शे वाली screen ───────────────────────────

  String get mapKindArea => pick(const {
        AppLang.hindi: 'रकबा',
        AppLang.english: 'Area',
        AppLang.marathi: 'क्षेत्रफळ',
        AppLang.gujarati: 'ક્ષેત્રફળ',
        AppLang.punjabi: 'ਰਕਬਾ',
        AppLang.bengali: 'আয়তন',
        AppLang.telugu: 'వైశాల్యం',
        AppLang.tamil: 'பரப்பளவு',
        AppLang.kannada: 'ವಿಸ್ತೀರ್ಣ',
      });

  String get mapKindDistance => pick(const {
        AppLang.hindi: 'दूरी',
        AppLang.english: 'Distance',
        AppLang.marathi: 'अंतर',
        AppLang.gujarati: 'અંતર',
        AppLang.punjabi: 'ਦੂਰੀ',
        AppLang.bengali: 'দূরত্ব',
        AppLang.telugu: 'దూరం',
        AppLang.tamil: 'தூரம்',
        AppLang.kannada: 'ದೂರ',
      });

  String get mapTapHintArea => pick(const {
        AppLang.hindi: 'खेत के कोनों पर क्रम से टैप करें। बिंदु को खींचकर सरका सकते हैं।',
        AppLang.english: 'Tap the field corners in order. Drag a point to adjust it.',
        AppLang.marathi: 'शेताच्या कोपऱ्यांवर क्रमाने टॅप करा. बिंदू ओढून हलवता येतो.',
        AppLang.gujarati: 'ખેતરના ખૂણા પર ક્રમમાં ટૅપ કરો. બિંદુને ખેંચીને ખસેડી શકાય.',
        AppLang.punjabi: 'ਖੇਤ ਦੇ ਕੋਨਿਆਂ ਉੱਤੇ ਤਰਤੀਬ ਨਾਲ ਟੈਪ ਕਰੋ। ਬਿੰਦੂ ਨੂੰ ਖਿੱਚ ਕੇ ਹਿਲਾ ਸਕਦੇ ਹੋ।',
        AppLang.bengali: 'জমির কোণগুলোতে ক্রমানুসারে ট্যাপ করুন। বিন্দু টেনে সরানো যায়।',
        AppLang.telugu: 'పొలం మూలలపై వరుసగా ట్యాప్ చేయండి. బిందువును లాగి జరపవచ్చు.',
        AppLang.tamil: 'வயல் மூலைகளில் வரிசையாகத் தட்டவும். புள்ளியை இழுத்து நகர்த்தலாம்.',
        AppLang.kannada: 'ಹೊಲದ ಮೂಲೆಗಳ ಮೇಲೆ ಕ್ರಮವಾಗಿ ಟ್ಯಾಪ್ ಮಾಡಿ. ಬಿಂದುವನ್ನು ಎಳೆದು ಸರಿಸಬಹುದು.',
      });

  String get mapTapHintDistance => pick(const {
        AppLang.hindi: 'रास्ते के शुरू से हर मोड़ पर क्रम से टैप करें।',
        AppLang.english: 'Tap from the start of the road, at every turn, in order.',
        AppLang.marathi: 'रस्त्याच्या सुरुवातीपासून प्रत्येक वळणावर क्रमाने टॅप करा.',
        AppLang.gujarati: 'રસ્તાની શરૂઆતથી દરેક વળાંક પર ક્રમમાં ટૅપ કરો.',
        AppLang.punjabi: 'ਰਸਤੇ ਦੇ ਸ਼ੁਰੂ ਤੋਂ ਹਰ ਮੋੜ ਉੱਤੇ ਤਰਤੀਬ ਨਾਲ ਟੈਪ ਕਰੋ।',
        AppLang.bengali: 'রাস্তার শুরু থেকে প্রতিটি বাঁকে ক্রমানুসারে ট্যাপ করুন।',
        AppLang.telugu: 'దారి మొదలు నుండి ప్రతి మలుపుపై వరుసగా ట్యాప్ చేయండి.',
        AppLang.tamil: 'பாதையின் தொடக்கத்திலிருந்து ஒவ்வொரு திருப்பத்திலும் வரிசையாகத் தட்டவும்.',
        AppLang.kannada: 'ದಾರಿಯ ಆರಂಭದಿಂದ ಪ್ರತಿ ತಿರುವಿನಲ್ಲಿ ಕ್ರಮವಾಗಿ ಟ್ಯಾಪ್ ಮಾಡಿ.',
      });

  String get mapWalkHint => pick(const {
        AppLang.hindi: 'खेत के एक कोने पर खड़े होकर "कोना जोड़ें" दबाएँ, फिर अगले कोने पर चलें।',
        AppLang.english: 'Stand at a field corner and press "Add corner", then walk to the next one.',
        AppLang.marathi: 'शेताच्या एका कोपऱ्यावर उभे राहून "कोपरा जोडा" दाबा, मग पुढच्या कोपऱ्यावर जा.',
        AppLang.gujarati: 'ખેતરના એક ખૂણે ઊભા રહીને "ખૂણો ઉમેરો" દબાવો, પછી બીજા ખૂણે જાઓ.',
        AppLang.punjabi: 'ਖੇਤ ਦੇ ਇੱਕ ਕੋਨੇ ਉੱਤੇ ਖੜ੍ਹ ਕੇ "ਕੋਨਾ ਜੋੜੋ" ਦਬਾਓ, ਫਿਰ ਅਗਲੇ ਕੋਨੇ ਵੱਲ ਤੁਰੋ।',
        AppLang.bengali: 'জমির এক কোণে দাঁড়িয়ে "কোণ যোগ করুন" চাপুন, তারপর পরের কোণে যান।',
        AppLang.telugu: 'పొలం ఒక మూల వద్ద నిలబడి "మూల జోడించు" నొక్కండి, తర్వాత తదుపరి మూలకు నడవండి.',
        AppLang.tamil: 'வயலின் ஒரு மூலையில் நின்று "மூலை சேர்" அழுத்தவும், பிறகு அடுத்த மூலைக்கு நடக்கவும்.',
        AppLang.kannada: 'ಹೊಲದ ಒಂದು ಮೂಲೆಯಲ್ಲಿ ನಿಂತು "ಮೂಲೆ ಸೇರಿಸಿ" ಒತ್ತಿರಿ, ನಂತರ ಮುಂದಿನ ಮೂಲೆಗೆ ನಡೆಯಿರಿ.',
      });

  String get mapTrackHint => pick(const {
        AppLang.hindi: '"शुरू करें" दबाकर चलना शुरू करें। रुकना हो तो "रोकें" दबाएँ।',
        AppLang.english: 'Press "Start" and begin moving. Press "Pause" to take a break.',
        AppLang.marathi: '"सुरू करा" दाबून चालायला सुरुवात करा. थांबायचे असल्यास "थांबवा" दाबा.',
        AppLang.gujarati: '"શરૂ કરો" દબાવીને ચાલવાનું શરૂ કરો. રોકાવું હોય તો "રોકો" દબાવો.',
        AppLang.punjabi: '"ਸ਼ੁਰੂ ਕਰੋ" ਦਬਾ ਕੇ ਤੁਰਨਾ ਸ਼ੁਰੂ ਕਰੋ। ਰੁਕਣਾ ਹੋਵੇ ਤਾਂ "ਰੋਕੋ" ਦਬਾਓ।',
        AppLang.bengali: '"শুরু করুন" চেপে চলা শুরু করুন। থামতে চাইলে "থামান" চাপুন।',
        AppLang.telugu: '"ప్రారంభించు" నొక్కి కదలడం మొదలుపెట్టండి. ఆగాలంటే "ఆపు" నొక్కండి.',
        AppLang.tamil: '"தொடங்கு" அழுத்தி நகரத் தொடங்குங்கள். நிற்க வேண்டுமானால் "நிறுத்து" அழுத்தவும்.',
        AppLang.kannada: '"ಪ್ರಾರಂಭಿಸಿ" ಒತ್ತಿ ಚಲಿಸಲು ಶುರು ಮಾಡಿ. ನಿಲ್ಲಿಸಬೇಕಾದರೆ "ನಿಲ್ಲಿಸಿ" ಒತ್ತಿರಿ.',
      });

  String get mapAddCorner => pick(const {
        AppLang.hindi: 'कोना जोड़ें',
        AppLang.english: 'Add corner',
        AppLang.marathi: 'कोपरा जोडा',
        AppLang.gujarati: 'ખૂણો ઉમેરો',
        AppLang.punjabi: 'ਕੋਨਾ ਜੋੜੋ',
        AppLang.bengali: 'কোণ যোগ করুন',
        AppLang.telugu: 'మూల జోడించు',
        AppLang.tamil: 'மூலை சேர்',
        AppLang.kannada: 'ಮೂಲೆ ಸೇರಿಸಿ',
      });

  String mapHoldStill(int seconds) => pick({
        AppLang.hindi: 'हिलें नहीं… $seconds',
        AppLang.english: 'Hold still… $seconds',
        AppLang.marathi: 'हलू नका… $seconds',
        AppLang.gujarati: 'હલશો નહીં… $seconds',
        AppLang.punjabi: 'ਹਿੱਲੋ ਨਾ… $seconds',
        AppLang.bengali: 'নড়বেন না… $seconds',
        AppLang.telugu: 'కదలకండి… $seconds',
        AppLang.tamil: 'அசையாதீர்கள்… $seconds',
        AppLang.kannada: 'ಅಲುಗಾಡಬೇಡಿ… $seconds',
      });

  String get mapCornersMode => pick(const {
        AppLang.hindi: 'कोने-कोने',
        AppLang.english: 'Corners',
        AppLang.marathi: 'कोपरे',
        AppLang.gujarati: 'ખૂણે-ખૂણે',
        AppLang.punjabi: 'ਕੋਨੇ-ਕੋਨੇ',
        AppLang.bengali: 'কোণে কোণে',
        AppLang.telugu: 'మూలలు',
        AppLang.tamil: 'மூலைகள்',
        AppLang.kannada: 'ಮೂಲೆಗಳು',
      });

  String get mapContinuousMode => pick(const {
        AppLang.hindi: 'लगातार (टेढ़ा खेत)',
        AppLang.english: 'Continuous (curved field)',
        AppLang.marathi: 'सलग (वाकडे शेत)',
        AppLang.gujarati: 'સતત (વાંકું ખેતર)',
        AppLang.punjabi: 'ਲਗਾਤਾਰ (ਟੇਢਾ ਖੇਤ)',
        AppLang.bengali: 'একটানা (বাঁকা জমি)',
        AppLang.telugu: 'నిరంతరం (వంకర పొలం)',
        AppLang.tamil: 'தொடர்ச்சி (வளைந்த வயல்)',
        AppLang.kannada: 'ನಿರಂತರ (ವಕ್ರ ಹೊಲ)',
      });

  String get mapDivideShort => pick(const {
        AppLang.hindi: 'बँटवारा',
        AppLang.english: 'Divide',
        AppLang.marathi: 'वाटणी',
        AppLang.gujarati: 'વહેંચણી',
        AppLang.punjabi: 'ਵੰਡ',
        AppLang.bengali: 'ভাগ',
        AppLang.telugu: 'పంపకం',
        AppLang.tamil: 'பிரிவினை',
        AppLang.kannada: 'ಹಂಚಿಕೆ',
      });

  String get mapStart => pick(const {
        AppLang.hindi: 'शुरू करें',
        AppLang.english: 'Start',
        AppLang.marathi: 'सुरू करा',
        AppLang.gujarati: 'શરૂ કરો',
        AppLang.punjabi: 'ਸ਼ੁਰੂ ਕਰੋ',
        AppLang.bengali: 'শুরু করুন',
        AppLang.telugu: 'ప్రారంభించు',
        AppLang.tamil: 'தொடங்கு',
        AppLang.kannada: 'ಪ್ರಾರಂಭಿಸಿ',
      });

  String get mapPause => pick(const {
        AppLang.hindi: 'रोकें',
        AppLang.english: 'Pause',
        AppLang.marathi: 'थांबवा',
        AppLang.gujarati: 'રોકો',
        AppLang.punjabi: 'ਰੋਕੋ',
        AppLang.bengali: 'থামান',
        AppLang.telugu: 'ఆపు',
        AppLang.tamil: 'நிறுத்து',
        AppLang.kannada: 'ನಿಲ್ಲಿಸಿ',
      });

  String get mapResume => pick(const {
        AppLang.hindi: 'फिर शुरू करें',
        AppLang.english: 'Resume',
        AppLang.marathi: 'पुन्हा सुरू करा',
        AppLang.gujarati: 'ફરી શરૂ કરો',
        AppLang.punjabi: 'ਮੁੜ ਸ਼ੁਰੂ ਕਰੋ',
        AppLang.bengali: 'আবার শুরু করুন',
        AppLang.telugu: 'మళ్ళీ ప్రారంభించు',
        AppLang.tamil: 'மீண்டும் தொடங்கு',
        AppLang.kannada: 'ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಿ',
      });

  String get mapUndo => pick(const {
        AppLang.hindi: 'पिछला हटाएँ',
        AppLang.english: 'Undo',
        AppLang.marathi: 'मागचा काढा',
        AppLang.gujarati: 'છેલ્લું હટાવો',
        AppLang.punjabi: 'ਪਿਛਲਾ ਹਟਾਓ',
        AppLang.bengali: 'শেষটা মুছুন',
        AppLang.telugu: 'చివరిది తీసివేయి',
        AppLang.tamil: 'கடைசியை நீக்கு',
        AppLang.kannada: 'ಹಿಂದಿನದು ತೆಗೆಯಿರಿ',
      });

  String get mapSatellite => pick(const {
        AppLang.hindi: 'सैटेलाइट नक्शा',
        AppLang.english: 'Satellite map',
        AppLang.marathi: 'सॅटेलाइट नकाशा',
        AppLang.gujarati: 'સેટેલાઇટ નકશો',
        AppLang.punjabi: 'ਸੈਟੇਲਾਈਟ ਨਕਸ਼ਾ',
        AppLang.bengali: 'স্যাটেলাইট ম্যাপ',
        AppLang.telugu: 'శాటిలైట్ మ్యాప్',
        AppLang.tamil: 'செயற்கைக்கோள் வரைபடம்',
        AppLang.kannada: 'ಉಪಗ್ರಹ ನಕ್ಷೆ',
      });

  String get mapPlain => pick(const {
        AppLang.hindi: 'सादा नक्शा',
        AppLang.english: 'Street map',
        AppLang.marathi: 'साधा नकाशा',
        AppLang.gujarati: 'સાદો નકશો',
        AppLang.punjabi: 'ਸਾਦਾ ਨਕਸ਼ਾ',
        AppLang.bengali: 'সাধারণ ম্যাপ',
        AppLang.telugu: 'సాధారణ మ్యాప్',
        AppLang.tamil: 'சாதாரண வரைபடம்',
        AppLang.kannada: 'ಸಾಮಾನ್ಯ ನಕ್ಷೆ',
      });

  String get mapMyLocation => pick(const {
        AppLang.hindi: 'मेरी जगह',
        AppLang.english: 'My location',
        AppLang.marathi: 'माझे ठिकाण',
        AppLang.gujarati: 'મારું સ્થાન',
        AppLang.punjabi: 'ਮੇਰੀ ਥਾਂ',
        AppLang.bengali: 'আমার অবস্থান',
        AppLang.telugu: 'నా స్థానం',
        AppLang.tamil: 'என் இருப்பிடம்',
        AppLang.kannada: 'ನನ್ನ ಸ್ಥಳ',
      });

  String get mapPerimeter => pick(const {
        AppLang.hindi: 'चारों ओर की लंबाई',
        AppLang.english: 'Perimeter',
        AppLang.marathi: 'परिमिती',
        AppLang.gujarati: 'પરિમિતિ',
        AppLang.punjabi: 'ਘੇਰਾ',
        AppLang.bengali: 'পরিসীমা',
        AppLang.telugu: 'చుట్టుకొలత',
        AppLang.tamil: 'சுற்றளவு',
        AppLang.kannada: 'ಸುತ್ತಳತೆ',
      });

  String mapPointCount(int n) => pick({
        AppLang.hindi: '$n बिंदु',
        AppLang.english: '$n points',
        AppLang.marathi: '$n बिंदू',
        AppLang.gujarati: '$n બિંદુ',
        AppLang.punjabi: '$n ਬਿੰਦੂ',
        AppLang.bengali: '$nটি বিন্দু',
        AppLang.telugu: '$n బిందువులు',
        AppLang.tamil: '$n புள்ளிகள்',
        AppLang.kannada: '$n ಬಿಂದುಗಳು',
      });

  String get mapNeedThreePoints => pick(const {
        AppLang.hindi: 'रकबे के लिए कम से कम 3 बिंदु चाहिए',
        AppLang.english: 'At least 3 points are needed for area',
        AppLang.marathi: 'क्षेत्रफळासाठी किमान 3 बिंदू हवेत',
        AppLang.gujarati: 'ક્ષેત્રફળ માટે ઓછામાં ઓછા 3 બિંદુ જોઈએ',
        AppLang.punjabi: 'ਰਕਬੇ ਲਈ ਘੱਟੋ-ਘੱਟ 3 ਬਿੰਦੂ ਚਾਹੀਦੇ ਹਨ',
        AppLang.bengali: 'আয়তনের জন্য অন্তত 3টি বিন্দু দরকার',
        AppLang.telugu: 'వైశాల్యానికి కనీసం 3 బిందువులు కావాలి',
        AppLang.tamil: 'பரப்பளவுக்கு குறைந்தது 3 புள்ளிகள் தேவை',
        AppLang.kannada: 'ವಿಸ್ತೀರ್ಣಕ್ಕೆ ಕನಿಷ್ಠ 3 ಬಿಂದುಗಳು ಬೇಕು',
      });

  String get mapNeedTwoPoints => pick(const {
        AppLang.hindi: 'दूरी के लिए कम से कम 2 बिंदु चाहिए',
        AppLang.english: 'At least 2 points are needed for distance',
        AppLang.marathi: 'अंतरासाठी किमान 2 बिंदू हवेत',
        AppLang.gujarati: 'અંતર માટે ઓછામાં ઓછા 2 બિંદુ જોઈએ',
        AppLang.punjabi: 'ਦੂਰੀ ਲਈ ਘੱਟੋ-ਘੱਟ 2 ਬਿੰਦੂ ਚਾਹੀਦੇ ਹਨ',
        AppLang.bengali: 'দূরত্বের জন্য অন্তত 2টি বিন্দু দরকার',
        AppLang.telugu: 'దూరానికి కనీసం 2 బిందువులు కావాలి',
        AppLang.tamil: 'தூரத்துக்கு குறைந்தது 2 புள்ளிகள் தேவை',
        AppLang.kannada: 'ದೂರಕ್ಕೆ ಕನಿಷ್ಠ 2 ಬಿಂದುಗಳು ಬೇಕು',
      });

  String get mapAllUnits => pick(const {
        AppLang.hindi: 'सभी इकाइयों में देखें',
        AppLang.english: 'See in all units',
        AppLang.marathi: 'सर्व एककांमध्ये पहा',
        AppLang.gujarati: 'બધા એકમોમાં જુઓ',
        AppLang.punjabi: 'ਸਾਰੀਆਂ ਇਕਾਈਆਂ ਵਿੱਚ ਵੇਖੋ',
        AppLang.bengali: 'সব এককে দেখুন',
        AppLang.telugu: 'అన్ని యూనిట్లలో చూడండి',
        AppLang.tamil: 'அனைத்து அலகுகளிலும் பார்',
        AppLang.kannada: 'ಎಲ್ಲಾ ಘಟಕಗಳಲ್ಲಿ ನೋಡಿ',
      });

  String get mapSave => pick(const {
        AppLang.hindi: 'सहेजें',
        AppLang.english: 'Save',
        AppLang.marathi: 'जतन करा',
        AppLang.gujarati: 'સાચવો',
        AppLang.punjabi: 'ਸੰਭਾਲੋ',
        AppLang.bengali: 'সংরক্ষণ',
        AppLang.telugu: 'సేవ్ చేయి',
        AppLang.tamil: 'சேமி',
        AppLang.kannada: 'ಉಳಿಸಿ',
      });

  String get mapSaveName => pick(const {
        AppLang.hindi: 'नाप का नाम',
        AppLang.english: 'Name this measurement',
        AppLang.marathi: 'मोजमापाचे नाव',
        AppLang.gujarati: 'માપનું નામ',
        AppLang.punjabi: 'ਨਾਪ ਦਾ ਨਾਂ',
        AppLang.bengali: 'মাপের নাম',
        AppLang.telugu: 'కొలత పేరు',
        AppLang.tamil: 'அளவீட்டின் பெயர்',
        AppLang.kannada: 'ಅಳತೆಯ ಹೆಸರು',
      });

  String get mapSaveHint => pick(const {
        AppLang.hindi: 'जैसे: नदी वाला खेत',
        AppLang.english: 'e.g. Field near the river',
        AppLang.marathi: 'उदा: नदीजवळचे शेत',
        AppLang.gujarati: 'જેમ કે: નદી પાસેનું ખેતર',
        AppLang.punjabi: 'ਜਿਵੇਂ: ਨਦੀ ਵਾਲਾ ਖੇਤ',
        AppLang.bengali: 'যেমন: নদীর ধারের জমি',
        AppLang.telugu: 'ఉదా: నది దగ్గరి పొలం',
        AppLang.tamil: 'எ.கா: ஆற்றங்கரை வயல்',
        AppLang.kannada: 'ಉದಾ: ನದಿ ಹತ್ತಿರದ ಹೊಲ',
      });

  String get mapSavedOk => pick(const {
        AppLang.hindi: 'नाप सहेज लिया गया',
        AppLang.english: 'Measurement saved',
        AppLang.marathi: 'मोजमाप जतन झाले',
        AppLang.gujarati: 'માપ સાચવી લીધું',
        AppLang.punjabi: 'ਨਾਪ ਸੰਭਾਲ ਲਿਆ ਗਿਆ',
        AppLang.bengali: 'মাপ সংরক্ষিত হয়েছে',
        AppLang.telugu: 'కొలత సేవ్ అయింది',
        AppLang.tamil: 'அளவீடு சேமிக்கப்பட்டது',
        AppLang.kannada: 'ಅಳತೆ ಉಳಿಸಲಾಗಿದೆ',
      });

  String get mapCancel => pick(const {
        AppLang.hindi: 'रद्द करें',
        AppLang.english: 'Cancel',
        AppLang.marathi: 'रद्द करा',
        AppLang.gujarati: 'રદ કરો',
        AppLang.punjabi: 'ਰੱਦ ਕਰੋ',
        AppLang.bengali: 'বাতিল',
        AppLang.telugu: 'రద్దు చేయి',
        AppLang.tamil: 'ரத்து செய்',
        AppLang.kannada: 'ರದ್ದುಮಾಡಿ',
      });

  String get mapDelete => pick(const {
        AppLang.hindi: 'हटाएँ',
        AppLang.english: 'Delete',
        AppLang.marathi: 'हटवा',
        AppLang.gujarati: 'કાઢી નાખો',
        AppLang.punjabi: 'ਮਿਟਾਓ',
        AppLang.bengali: 'মুছুন',
        AppLang.telugu: 'తొలగించు',
        AppLang.tamil: 'நீக்கு',
        AppLang.kannada: 'ಅಳಿಸಿ',
      });

  String mapDeleteConfirm(String name) => pick({
        AppLang.hindi: '"$name" हमेशा के लिए हटाएँ?',
        AppLang.english: 'Delete "$name" permanently?',
        AppLang.marathi: '"$name" कायमचे हटवायचे?',
        AppLang.gujarati: '"$name" કાયમ માટે કાઢી નાખવું?',
        AppLang.punjabi: '"$name" ਹਮੇਸ਼ਾ ਲਈ ਮਿਟਾਉਣਾ ਹੈ?',
        AppLang.bengali: '"$name" চিরতরে মুছে ফেলবেন?',
        AppLang.telugu: '"$name" శాశ్వతంగా తొలగించాలా?',
        AppLang.tamil: '"$name" நிரந்தரமாக நீக்கவா?',
        AppLang.kannada: '"$name" ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಬೇಕೇ?',
      });

  String get mapDoBatwara => pick(const {
        AppLang.hindi: 'इस ज़मीन का बँटवारा करें',
        AppLang.english: 'Divide this land',
        AppLang.marathi: 'या जमिनीची वाटणी करा',
        AppLang.gujarati: 'આ જમીનની વહેંચણી કરો',
        AppLang.punjabi: 'ਇਸ ਜ਼ਮੀਨ ਦੀ ਵੰਡ ਕਰੋ',
        AppLang.bengali: 'এই জমি ভাগ করুন',
        AppLang.telugu: 'ఈ భూమిని పంచండి',
        AppLang.tamil: 'இந்த நிலத்தைப் பிரி',
        AppLang.kannada: 'ಈ ಜಮೀನನ್ನು ಹಂಚಿ',
      });

  String get mapCrossWarning => pick(const {
        AppLang.hindi: 'सीमा की रेखाएँ एक-दूसरे को काट रही हैं। कोने क्रम से लगाएँ, वरना रकबा ग़लत (कम) आएगा।',
        AppLang.english: 'The boundary lines cross each other. Place corners in order, or the area will come out wrong (too small).',
        AppLang.marathi: 'सीमेच्या रेषा एकमेकांना छेदत आहेत. कोपरे क्रमाने लावा, नाहीतर क्षेत्रफळ चुकीचे (कमी) येईल.',
        AppLang.gujarati: 'સીમાની રેખાઓ એકબીજાને કાપે છે. ખૂણા ક્રમમાં મૂકો, નહીં તો ક્ષેત્રફળ ખોટું (ઓછું) આવશે.',
        AppLang.punjabi: 'ਹੱਦ ਦੀਆਂ ਲਕੀਰਾਂ ਇੱਕ-ਦੂਜੇ ਨੂੰ ਕੱਟ ਰਹੀਆਂ ਹਨ। ਕੋਨੇ ਤਰਤੀਬ ਨਾਲ ਲਾਓ, ਨਹੀਂ ਤਾਂ ਰਕਬਾ ਗਲਤ (ਘੱਟ) ਆਵੇਗਾ।',
        AppLang.bengali: 'সীমানার রেখাগুলো একে অপরকে কাটছে। কোণগুলো ক্রমানুসারে দিন, নইলে আয়তন ভুল (কম) আসবে।',
        AppLang.telugu: 'సరిహద్దు గీతలు ఒకదానినొకటి దాటుతున్నాయి. మూలలను వరుసగా పెట్టండి, లేకుంటే వైశాల్యం తప్పుగా (తక్కువగా) వస్తుంది.',
        AppLang.tamil: 'எல்லைக் கோடுகள் ஒன்றையொன்று வெட்டுகின்றன. மூலைகளை வரிசையாக வையுங்கள், இல்லையெனில் பரப்பளவு தவறாக (குறைவாக) வரும்.',
        AppLang.kannada: 'ಗಡಿ ರೇಖೆಗಳು ಒಂದನ್ನೊಂದು ಕತ್ತರಿಸುತ್ತಿವೆ. ಮೂಲೆಗಳನ್ನು ಕ್ರಮವಾಗಿ ಇಡಿ, ಇಲ್ಲದಿದ್ದರೆ ವಿಸ್ತೀರ್ಣ ತಪ್ಪಾಗಿ (ಕಡಿಮೆ) ಬರುತ್ತದೆ.',
      });

  String mapSmallFieldWarning(int percent) => pick({
        AppLang.hindi: 'खेत छोटा है — GPS से रकबा लगभग ±$percent% तक ग़लत हो सकता है। फीते से नापना बेहतर रहेगा।',
        AppLang.english: 'Small field — the GPS area may be off by about ±$percent%. Measuring with a tape will be better.',
        AppLang.marathi: 'शेत लहान आहे — GPS चे क्षेत्रफळ सुमारे ±$percent% चुकू शकते. टेपने मोजणे चांगले.',
        AppLang.gujarati: 'ખેતર નાનું છે — GPS નું ક્ષેત્રફળ આશરે ±$percent% ખોટું હોઈ શકે. ટેપથી માપવું વધુ સારું.',
        AppLang.punjabi: 'ਖੇਤ ਛੋਟਾ ਹੈ — GPS ਨਾਲ ਰਕਬਾ ਲਗਭਗ ±$percent% ਤੱਕ ਗਲਤ ਹੋ ਸਕਦਾ ਹੈ। ਫੀਤੇ ਨਾਲ ਮਿਣਨਾ ਬਿਹਤਰ ਰਹੇਗਾ।',
        AppLang.bengali: 'জমি ছোট — GPS-এর আয়তন প্রায় ±$percent% ভুল হতে পারে। ফিতে দিয়ে মাপা ভালো।',
        AppLang.telugu: 'పొలం చిన్నది — GPS వైశాల్యం సుమారు ±$percent% తేడా రావచ్చు. టేపుతో కొలవడం మంచిది.',
        AppLang.tamil: 'வயல் சிறியது — GPS பரப்பளவு சுமார் ±$percent% தவறலாம். டேப்பால் அளப்பது நல்லது.',
        AppLang.kannada: 'ಹೊಲ ಚಿಕ್ಕದು — GPS ವಿಸ್ತೀರ್ಣ ಸುಮಾರು ±$percent% ತಪ್ಪಾಗಬಹುದು. ಟೇಪಿನಿಂದ ಅಳೆಯುವುದು ಉತ್ತಮ.',
      });

  String get mapUseTape => pick(const {
        AppLang.hindi: 'भुजाएँ डालकर नापें',
        AppLang.english: 'Enter side lengths',
        AppLang.marathi: 'बाजू टाकून मोजा',
        AppLang.gujarati: 'બાજુઓ નાખીને માપો',
        AppLang.punjabi: 'ਬਾਹੀਆਂ ਭਰ ਕੇ ਮਿਣੋ',
        AppLang.bengali: 'বাহুর মাপ দিয়ে হিসাব করুন',
        AppLang.telugu: 'భుజాల కొలతలు ఇచ్చి లెక్కించండి',
        AppLang.tamil: 'பக்க நீளங்களை உள்ளிட்டு கணக்கிடு',
        AppLang.kannada: 'ಬದಿಗಳ ಉದ್ದ ನಮೂದಿಸಿ ಲೆಕ್ಕಿಸಿ',
      });

  String get mapGpsSearching => pick(const {
        AppLang.hindi: 'GPS ढूँढ रहा है…',
        AppLang.english: 'Finding GPS…',
        AppLang.marathi: 'GPS शोधत आहे…',
        AppLang.gujarati: 'GPS શોધી રહ્યું છે…',
        AppLang.punjabi: 'GPS ਲੱਭ ਰਿਹਾ ਹੈ…',
        AppLang.bengali: 'GPS খুঁজছে…',
        AppLang.telugu: 'GPS వెతుకుతోంది…',
        AppLang.tamil: 'GPS தேடுகிறது…',
        AppLang.kannada: 'GPS ಹುಡುಕುತ್ತಿದೆ…',
      });

  String mapGpsAccuracy(int meters) => pick({
        AppLang.hindi: 'GPS ±$meters मी',
        AppLang.english: 'GPS ±$meters m',
        AppLang.marathi: 'GPS ±$meters मी',
        AppLang.gujarati: 'GPS ±$meters મી',
        AppLang.punjabi: 'GPS ±$meters ਮੀ',
        AppLang.bengali: 'GPS ±$meters মি',
        AppLang.telugu: 'GPS ±$meters మీ',
        AppLang.tamil: 'GPS ±$meters மீ',
        AppLang.kannada: 'GPS ±$meters ಮೀ',
      });

  String get mapGpsWeak => pick(const {
        AppLang.hindi: 'GPS कमज़ोर है — पेड़ों/छत से हटकर खुले में जाएँ',
        AppLang.english: 'Weak GPS — move away from trees/roofs into the open',
        AppLang.marathi: 'GPS कमजोर आहे — झाडे/छतापासून दूर मोकळ्या जागी जा',
        AppLang.gujarati: 'GPS નબળું છે — ઝાડ/છતથી દૂર ખુલ્લામાં જાઓ',
        AppLang.punjabi: 'GPS ਕਮਜ਼ੋਰ ਹੈ — ਰੁੱਖਾਂ/ਛੱਤ ਤੋਂ ਹਟ ਕੇ ਖੁੱਲ੍ਹੇ ਵਿੱਚ ਜਾਓ',
        AppLang.bengali: 'GPS দুর্বল — গাছ/ছাদ থেকে সরে খোলা জায়গায় যান',
        AppLang.telugu: 'GPS బలహీనంగా ఉంది — చెట్లు/పైకప్పు నుండి దూరంగా బయటకు వెళ్ళండి',
        AppLang.tamil: 'GPS பலவீனம் — மரங்கள்/கூரையிலிருந்து விலகி திறந்த இடத்துக்குச் செல்லுங்கள்',
        AppLang.kannada: 'GPS ದುರ್ಬಲವಾಗಿದೆ — ಮರಗಳು/ಚಾವಣಿಯಿಂದ ದೂರ ಬಯಲಿಗೆ ಹೋಗಿ',
      });

  String get mapWeakCorner => pick(const {
        AppLang.hindi: 'GPS कमज़ोर था — यह कोना कुछ मीटर खिसका हो सकता है। नक्शे पर खींचकर ठीक कर सकते हैं।',
        AppLang.english: 'GPS was weak — this corner may be a few metres off. You can drag it on the map to fix it.',
        AppLang.marathi: 'GPS कमजोर होते — हा कोपरा काही मीटर सरकलेला असू शकतो. नकाशावर ओढून दुरुस्त करता येईल.',
        AppLang.gujarati: 'GPS નબળું હતું — આ ખૂણો થોડા મીટર ખસેલો હોઈ શકે. નકશા પર ખેંચીને સુધારી શકાય.',
        AppLang.punjabi: 'GPS ਕਮਜ਼ੋਰ ਸੀ — ਇਹ ਕੋਨਾ ਕੁਝ ਮੀਟਰ ਖਿਸਕਿਆ ਹੋ ਸਕਦਾ ਹੈ। ਨਕਸ਼ੇ ਉੱਤੇ ਖਿੱਚ ਕੇ ਠੀਕ ਕਰ ਸਕਦੇ ਹੋ।',
        AppLang.bengali: 'GPS দুর্বল ছিল — এই কোণটি কয়েক মিটার সরে থাকতে পারে। ম্যাপে টেনে ঠিক করা যায়।',
        AppLang.telugu: 'GPS బలహీనంగా ఉంది — ఈ మూల కొన్ని మీటర్లు జరిగి ఉండవచ్చు. మ్యాప్‌లో లాగి సరిచేయవచ్చు.',
        AppLang.tamil: 'GPS பலவீனமாக இருந்தது — இந்த மூலை சில மீட்டர் விலகியிருக்கலாம். வரைபடத்தில் இழுத்து சரிசெய்யலாம்.',
        AppLang.kannada: 'GPS ದುರ್ಬಲವಾಗಿತ್ತು — ಈ ಮೂಲೆ ಕೆಲವು ಮೀಟರ್ ಸರಿದಿರಬಹುದು. ನಕ್ಷೆಯಲ್ಲಿ ಎಳೆದು ಸರಿಪಡಿಸಬಹುದು.',
      });

  String get mapGpsOff => pick(const {
        AppLang.hindi: 'फ़ोन की लोकेशन (GPS) बंद है',
        AppLang.english: 'Phone location (GPS) is turned off',
        AppLang.marathi: 'फोनचे लोकेशन (GPS) बंद आहे',
        AppLang.gujarati: 'ફોનનું લોકેશન (GPS) બંધ છે',
        AppLang.punjabi: 'ਫ਼ੋਨ ਦੀ ਲੋਕੇਸ਼ਨ (GPS) ਬੰਦ ਹੈ',
        AppLang.bengali: 'ফোনের লোকেশন (GPS) বন্ধ আছে',
        AppLang.telugu: 'ఫోన్ లొకేషన్ (GPS) ఆఫ్‌లో ఉంది',
        AppLang.tamil: 'போனின் இருப்பிடம் (GPS) அணைக்கப்பட்டுள்ளது',
        AppLang.kannada: 'ಫೋನ್ ಲೊಕೇಶನ್ (GPS) ಆಫ್ ಆಗಿದೆ',
      });

  String get mapTurnOnGps => pick(const {
        AppLang.hindi: 'GPS चालू करें',
        AppLang.english: 'Turn on GPS',
        AppLang.marathi: 'GPS सुरू करा',
        AppLang.gujarati: 'GPS ચાલુ કરો',
        AppLang.punjabi: 'GPS ਚਾਲੂ ਕਰੋ',
        AppLang.bengali: 'GPS চালু করুন',
        AppLang.telugu: 'GPS ఆన్ చేయండి',
        AppLang.tamil: 'GPS இயக்கு',
        AppLang.kannada: 'GPS ಆನ್ ಮಾಡಿ',
      });

  String get mapPermissionDenied => pick(const {
        AppLang.hindi: 'लोकेशन की अनुमति नहीं मिली। चलकर नापने के लिए यह ज़रूरी है।',
        AppLang.english: 'Location permission was not given. It is needed to measure by walking.',
        AppLang.marathi: 'लोकेशनची परवानगी मिळाली नाही. चालून मोजण्यासाठी ती आवश्यक आहे.',
        AppLang.gujarati: 'લોકેશનની પરવાનગી ન મળી. ચાલીને માપવા માટે તે જરૂરી છે.',
        AppLang.punjabi: 'ਲੋਕੇਸ਼ਨ ਦੀ ਇਜਾਜ਼ਤ ਨਹੀਂ ਮਿਲੀ। ਤੁਰ ਕੇ ਮਿਣਨ ਲਈ ਇਹ ਜ਼ਰੂਰੀ ਹੈ।',
        AppLang.bengali: 'লোকেশনের অনুমতি পাওয়া যায়নি। হেঁটে মাপার জন্য এটি দরকার।',
        AppLang.telugu: 'లొకేషన్ అనుమతి ఇవ్వలేదు. నడిచి కొలవడానికి ఇది అవసరం.',
        AppLang.tamil: 'இருப்பிட அனுமதி கிடைக்கவில்லை. நடந்து அளவிட இது தேவை.',
        AppLang.kannada: 'ಲೊಕೇಶನ್ ಅನುಮತಿ ಸಿಗಲಿಲ್ಲ. ನಡೆದು ಅಳೆಯಲು ಇದು ಅಗತ್ಯ.',
      });

  String get mapOpenSettings => pick(const {
        AppLang.hindi: 'सेटिंग खोलें',
        AppLang.english: 'Open settings',
        AppLang.marathi: 'सेटिंग्ज उघडा',
        AppLang.gujarati: 'સેટિંગ્સ ખોલો',
        AppLang.punjabi: 'ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ',
        AppLang.bengali: 'সেটিংস খুলুন',
        AppLang.telugu: 'సెట్టింగ్‌లు తెరవండి',
        AppLang.tamil: 'அமைப்புகளைத் திற',
        AppLang.kannada: 'ಸೆಟ್ಟಿಂಗ್ಸ್ ತೆರೆಯಿರಿ',
      });

  String get mapTryAgain => pick(const {
        AppLang.hindi: 'फिर कोशिश करें',
        AppLang.english: 'Try again',
        AppLang.marathi: 'पुन्हा प्रयत्न करा',
        AppLang.gujarati: 'ફરી પ્રયાસ કરો',
        AppLang.punjabi: 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
        AppLang.bengali: 'আবার চেষ্টা করুন',
        AppLang.telugu: 'మళ్ళీ ప్రయత్నించండి',
        AppLang.tamil: 'மீண்டும் முயற்சி செய்',
        AppLang.kannada: 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      });

  String get mapDisclosureTitle => pick(const {
        AppLang.hindi: 'लोकेशन की अनुमति क्यों?',
        AppLang.english: 'Why location permission?',
        AppLang.marathi: 'लोकेशनची परवानगी का?',
        AppLang.gujarati: 'લોકેશનની પરવાનગી શા માટે?',
        AppLang.punjabi: 'ਲੋਕੇਸ਼ਨ ਦੀ ਇਜਾਜ਼ਤ ਕਿਉਂ?',
        AppLang.bengali: 'লোকেশনের অনুমতি কেন?',
        AppLang.telugu: 'లొకేషన్ అనుమతి ఎందుకు?',
        AppLang.tamil: 'இருப்பிட அனுமதி ஏன்?',
        AppLang.kannada: 'ಲೊಕೇಶನ್ ಅನುಮತಿ ಏಕೆ?',
      });

  String get mapDisclosureBody => pick(const {
        AppLang.hindi: 'चलकर नापने और नक्शे पर आपकी जगह दिखाने के लिए ऐप को आपकी लोकेशन (GPS) चाहिए।\n\n• लोकेशन सिर्फ़ तभी ली जाती है जब यह नापने वाली स्क्रीन खुली हो — ऐप बंद होने पर नहीं।\n• इसका हिसाब सिर्फ़ आपके फ़ोन में होता है। लोकेशन हमारे पास या किसी और को नहीं भेजी जाती।\n• सहेजे हुए नाप सिर्फ़ आपके फ़ोन में रहते हैं।',
        AppLang.english: 'The app needs your location (GPS) to measure while you walk and to show where you are on the map.\n\n• Location is used only while this measuring screen is open — never when the app is closed.\n• All calculations happen on your phone. Your location is not sent to us or anyone else.\n• Saved measurements stay only on your phone.',
        AppLang.marathi: 'चालून मोजण्यासाठी आणि नकाशावर तुमचे ठिकाण दाखवण्यासाठी ॲपला तुमचे लोकेशन (GPS) हवे.\n\n• लोकेशन फक्त ही मोजणीची स्क्रीन उघडी असतानाच घेतले जाते — ॲप बंद असताना नाही.\n• सर्व हिशेब तुमच्या फोनमध्येच होतो. लोकेशन आम्हाला किंवा इतर कोणालाही पाठवले जात नाही.\n• जतन केलेली मोजमापे फक्त तुमच्या फोनमध्ये राहतात.',
        AppLang.gujarati: 'ચાલીને માપવા અને નકશા પર તમારું સ્થાન બતાવવા ઍપને તમારું લોકેશન (GPS) જોઈએ.\n\n• લોકેશન ફક્ત આ માપવાની સ્ક્રીન ખુલ્લી હોય ત્યારે જ લેવાય છે — ઍપ બંધ હોય ત્યારે નહીં.\n• બધી ગણતરી તમારા ફોનમાં જ થાય છે. લોકેશન અમને કે બીજા કોઈને મોકલાતું નથી.\n• સાચવેલાં માપ ફક્ત તમારા ફોનમાં રહે છે.',
        AppLang.punjabi: 'ਤੁਰ ਕੇ ਮਿਣਨ ਅਤੇ ਨਕਸ਼ੇ ਉੱਤੇ ਤੁਹਾਡੀ ਥਾਂ ਵਿਖਾਉਣ ਲਈ ਐਪ ਨੂੰ ਤੁਹਾਡੀ ਲੋਕੇਸ਼ਨ (GPS) ਚਾਹੀਦੀ ਹੈ।\n\n• ਲੋਕੇਸ਼ਨ ਸਿਰਫ਼ ਉਦੋਂ ਲਈ ਜਾਂਦੀ ਹੈ ਜਦੋਂ ਇਹ ਮਿਣਤੀ ਵਾਲੀ ਸਕ੍ਰੀਨ ਖੁੱਲ੍ਹੀ ਹੋਵੇ — ਐਪ ਬੰਦ ਹੋਣ ਉੱਤੇ ਨਹੀਂ।\n• ਸਾਰਾ ਹਿਸਾਬ ਤੁਹਾਡੇ ਫ਼ੋਨ ਵਿੱਚ ਹੀ ਹੁੰਦਾ ਹੈ। ਲੋਕੇਸ਼ਨ ਸਾਨੂੰ ਜਾਂ ਕਿਸੇ ਹੋਰ ਨੂੰ ਨਹੀਂ ਭੇਜੀ ਜਾਂਦੀ।\n• ਸੰਭਾਲੇ ਹੋਏ ਨਾਪ ਸਿਰਫ਼ ਤੁਹਾਡੇ ਫ਼ੋਨ ਵਿੱਚ ਰਹਿੰਦੇ ਹਨ।',
        AppLang.bengali: 'হেঁটে মাপতে এবং ম্যাপে আপনার অবস্থান দেখাতে অ্যাপের আপনার লোকেশন (GPS) দরকার।\n\n• লোকেশন শুধু এই মাপার স্ক্রিন খোলা থাকলেই নেওয়া হয় — অ্যাপ বন্ধ থাকলে নয়।\n• সব হিসাব আপনার ফোনেই হয়। লোকেশন আমাদের বা অন্য কাউকে পাঠানো হয় না।\n• সংরক্ষিত মাপ শুধু আপনার ফোনেই থাকে।',
        AppLang.telugu: 'నడుస్తూ కొలవడానికి, మ్యాప్‌లో మీరు ఎక్కడ ఉన్నారో చూపడానికి యాప్‌కు మీ లొకేషన్ (GPS) కావాలి.\n\n• ఈ కొలత స్క్రీన్ తెరిచి ఉన్నప్పుడు మాత్రమే లొకేషన్ తీసుకుంటుంది — యాప్ మూసినప్పుడు కాదు.\n• లెక్కలన్నీ మీ ఫోన్‌లోనే జరుగుతాయి. మీ లొకేషన్ మాకు లేదా ఇంకెవరికీ పంపబడదు.\n• సేవ్ చేసిన కొలతలు మీ ఫోన్‌లోనే ఉంటాయి.',
        AppLang.tamil: 'நடந்தபடி அளவிடவும், வரைபடத்தில் நீங்கள் இருக்கும் இடத்தைக் காட்டவும் செயலிக்கு உங்கள் இருப்பிடம் (GPS) தேவை.\n\n• இந்த அளவீட்டுத் திரை திறந்திருக்கும்போது மட்டுமே இருப்பிடம் பயன்படுத்தப்படும் — செயலி மூடியிருக்கும்போது இல்லை.\n• எல்லாக் கணக்கும் உங்கள் போனிலேயே நடக்கும். உங்கள் இருப்பிடம் எங்களுக்கோ வேறு யாருக்குமோ அனுப்பப்படாது.\n• சேமித்த அளவீடுகள் உங்கள் போனில் மட்டுமே இருக்கும்.',
        AppLang.kannada: 'ನಡೆಯುತ್ತಾ ಅಳೆಯಲು ಮತ್ತು ನಕ್ಷೆಯಲ್ಲಿ ನೀವು ಎಲ್ಲಿದ್ದೀರಿ ಎಂದು ತೋರಿಸಲು ಆಪ್‌ಗೆ ನಿಮ್ಮ ಲೊಕೇಶನ್ (GPS) ಬೇಕು.\n\n• ಈ ಅಳತೆಯ ಸ್ಕ್ರೀನ್ ತೆರೆದಿರುವಾಗ ಮಾತ್ರ ಲೊಕೇಶನ್ ಬಳಸಲಾಗುತ್ತದೆ — ಆಪ್ ಮುಚ್ಚಿದಾಗ ಅಲ್ಲ.\n• ಎಲ್ಲಾ ಲೆಕ್ಕ ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲೇ ಆಗುತ್ತದೆ. ನಿಮ್ಮ ಲೊಕೇಶನ್ ನಮಗೆ ಅಥವಾ ಬೇರೆ ಯಾರಿಗೂ ಕಳುಹಿಸುವುದಿಲ್ಲ.\n• ಉಳಿಸಿದ ಅಳತೆಗಳು ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲಿ ಮಾತ್ರ ಇರುತ್ತವೆ.',
      });

  String get mapDisclosureContinue => pick(const {
        AppLang.hindi: 'ठीक है, आगे बढ़ें',
        AppLang.english: 'OK, continue',
        AppLang.marathi: 'ठीक आहे, पुढे चला',
        AppLang.gujarati: 'બરાબર, આગળ વધો',
        AppLang.punjabi: 'ਠੀਕ ਹੈ, ਅੱਗੇ ਵਧੋ',
        AppLang.bengali: 'ঠিক আছে, এগিয়ে যান',
        AppLang.telugu: 'సరే, కొనసాగించు',
        AppLang.tamil: 'சரி, தொடர்',
        AppLang.kannada: 'ಸರಿ, ಮುಂದುವರಿಸಿ',
      });

  String get mapNotNow => pick(const {
        AppLang.hindi: 'अभी नहीं',
        AppLang.english: 'Not now',
        AppLang.marathi: 'आत्ता नाही',
        AppLang.gujarati: 'હમણાં નહીં',
        AppLang.punjabi: 'ਹੁਣੇ ਨਹੀਂ',
        AppLang.bengali: 'এখন নয়',
        AppLang.telugu: 'ఇప్పుడు కాదు',
        AppLang.tamil: 'இப்போது வேண்டாம்',
        AppLang.kannada: 'ಈಗ ಬೇಡ',
      });

  String get mapTilesFailing => pick(const {
        AppLang.hindi: 'नक्शा लोड नहीं हो रहा (इंटरनेट?) — GPS से नापना फिर भी चलेगा',
        AppLang.english: 'Map is not loading (internet?) — GPS measuring still works',
        AppLang.marathi: 'नकाशा लोड होत नाही (इंटरनेट?) — GPS ने मोजणे तरीही चालेल',
        AppLang.gujarati: 'નકશો લોડ થતો નથી (ઇન્ટરનેટ?) — GPS થી માપવાનું તો પણ ચાલશે',
        AppLang.punjabi: 'ਨਕਸ਼ਾ ਲੋਡ ਨਹੀਂ ਹੋ ਰਿਹਾ (ਇੰਟਰਨੈੱਟ?) — GPS ਨਾਲ ਮਿਣਨਾ ਫਿਰ ਵੀ ਚੱਲੇਗਾ',
        AppLang.bengali: 'ম্যাপ লোড হচ্ছে না (ইন্টারনেট?) — GPS দিয়ে মাপা তবুও চলবে',
        AppLang.telugu: 'మ్యాప్ లోడ్ కావడం లేదు (ఇంటర్నెట్?) — GPS కొలత అయినా పనిచేస్తుంది',
        AppLang.tamil: 'வரைபடம் ஏறவில்லை (இணையம்?) — GPS அளவீடு அப்போதும் இயங்கும்',
        AppLang.kannada: 'ನಕ್ಷೆ ಲೋಡ್ ಆಗುತ್ತಿಲ್ಲ (ಇಂಟರ್ನೆಟ್?) — GPS ಅಳತೆ ಆದರೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ',
      });

  String get mapOnFoot => pick(const {
        AppLang.hindi: 'पैदल',
        AppLang.english: 'On foot',
        AppLang.marathi: 'चालत',
        AppLang.gujarati: 'પગપાળા',
        AppLang.punjabi: 'ਪੈਦਲ',
        AppLang.bengali: 'হেঁটে',
        AppLang.telugu: 'నడక',
        AppLang.tamil: 'நடை',
        AppLang.kannada: 'ಕಾಲ್ನಡಿಗೆ',
      });

  String get mapByVehicle => pick(const {
        AppLang.hindi: 'बाइक / गाड़ी',
        AppLang.english: 'Bike / vehicle',
        AppLang.marathi: 'बाईक / गाडी',
        AppLang.gujarati: 'બાઇક / ગાડી',
        AppLang.punjabi: 'ਬਾਈਕ / ਗੱਡੀ',
        AppLang.bengali: 'বাইক / গাড়ি',
        AppLang.telugu: 'బైక్ / వాహనం',
        AppLang.tamil: 'பைக் / வாகனம்',
        AppLang.kannada: 'ಬೈಕ್ / ವಾಹನ',
      });

  String get mapLeaveTitle => pick(const {
        AppLang.hindi: 'नाप सहेजे बिना बाहर जाएँ?',
        AppLang.english: 'Leave without saving?',
        AppLang.marathi: 'मोजमाप जतन न करता बाहेर जायचे?',
        AppLang.gujarati: 'માપ સાચવ્યા વગર બહાર જવું?',
        AppLang.punjabi: 'ਨਾਪ ਸੰਭਾਲੇ ਬਿਨਾਂ ਬਾਹਰ ਜਾਣਾ ਹੈ?',
        AppLang.bengali: 'মাপ সংরক্ষণ না করে বেরিয়ে যাবেন?',
        AppLang.telugu: 'కొలత సేవ్ చేయకుండా బయటకు వెళ్ళాలా?',
        AppLang.tamil: 'அளவீட்டைச் சேமிக்காமல் வெளியேறவா?',
        AppLang.kannada: 'ಅಳತೆ ಉಳಿಸದೆ ಹೊರಹೋಗಬೇಕೇ?',
      });

  String get mapLeave => pick(const {
        AppLang.hindi: 'बाहर जाएँ',
        AppLang.english: 'Leave',
        AppLang.marathi: 'बाहेर जा',
        AppLang.gujarati: 'બહાર જાઓ',
        AppLang.punjabi: 'ਬਾਹਰ ਜਾਓ',
        AppLang.bengali: 'বেরিয়ে যান',
        AppLang.telugu: 'బయటకు వెళ్ళు',
        AppLang.tamil: 'வெளியேறு',
        AppLang.kannada: 'ಹೊರಹೋಗಿ',
      });

  String get mapShareTitle => pick(const {
        AppLang.hindi: '📍 नक्शे / GPS से नाप',
        AppLang.english: '📍 Map / GPS measurement',
        AppLang.marathi: '📍 नकाशा / GPS मोजमाप',
        AppLang.gujarati: '📍 નકશા / GPS માપ',
        AppLang.punjabi: '📍 ਨਕਸ਼ਾ / GPS ਨਾਪ',
        AppLang.bengali: '📍 ম্যাপ / GPS মাপ',
        AppLang.telugu: '📍 మ్యాప్ / GPS కొలత',
        AppLang.tamil: '📍 வரைபடம் / GPS அளவீடு',
        AppLang.kannada: '📍 ನಕ್ಷೆ / GPS ಅಳತೆ',
      });

  String get mapShareMapLink => pick(const {
        AppLang.hindi: 'नक्शे पर जगह',
        AppLang.english: 'Location on map',
        AppLang.marathi: 'नकाशावर ठिकाण',
        AppLang.gujarati: 'નકશા પર સ્થાન',
        AppLang.punjabi: 'ਨਕਸ਼ੇ ਉੱਤੇ ਥਾਂ',
        AppLang.bengali: 'ম্যাপে অবস্থান',
        AppLang.telugu: 'మ్యాప్‌లో స్థానం',
        AppLang.tamil: 'வரைபடத்தில் இடம்',
        AppLang.kannada: 'ನಕ್ಷೆಯಲ್ಲಿ ಸ್ಥಳ',
      });

  String get mapKilometer => pick(const {
        AppLang.hindi: 'किमी',
        AppLang.english: 'km',
        AppLang.marathi: 'किमी',
        AppLang.gujarati: 'કિમી',
        AppLang.punjabi: 'ਕਿਮੀ',
        AppLang.bengali: 'কিমি',
        AppLang.telugu: 'కి.మీ',
        AppLang.tamil: 'கி.மீ',
        AppLang.kannada: 'ಕಿ.ಮೀ',
      });

  String get mapScreenStaysOn => pick(const {
        AppLang.hindi: 'नापते समय स्क्रीन चालू रहेगी। फ़ोन जेब में रखना हो तो भी यह स्क्रीन खुली रखें।',
        AppLang.english: 'The screen stays on while measuring. Keep this screen open even if the phone is in your pocket.',
        AppLang.marathi: 'मोजताना स्क्रीन सुरू राहील. फोन खिशात ठेवला तरी ही स्क्रीन उघडी ठेवा.',
        AppLang.gujarati: 'માપતી વખતે સ્ક્રીન ચાલુ રહેશે. ફોન ખિસ્સામાં રાખો તો પણ આ સ્ક્રીન ખુલ્લી રાખો.',
        AppLang.punjabi: 'ਮਿਣਦੇ ਸਮੇਂ ਸਕ੍ਰੀਨ ਚਾਲੂ ਰਹੇਗੀ। ਫ਼ੋਨ ਜੇਬ ਵਿੱਚ ਰੱਖਣਾ ਹੋਵੇ ਤਾਂ ਵੀ ਇਹ ਸਕ੍ਰੀਨ ਖੁੱਲ੍ਹੀ ਰੱਖੋ।',
        AppLang.bengali: 'মাপার সময় স্ক্রিন চালু থাকবে। ফোন পকেটে রাখলেও এই স্ক্রিন খোলা রাখুন।',
        AppLang.telugu: 'కొలిచేటప్పుడు స్క్రీన్ ఆన్‌లో ఉంటుంది. ఫోన్ జేబులో ఉన్నా ఈ స్క్రీన్ తెరిచే ఉంచండి.',
        AppLang.tamil: 'அளவிடும்போது திரை இயக்கத்தில் இருக்கும். போனை பையில் வைத்தாலும் இந்தத் திரையைத் திறந்தே வையுங்கள்.',
        AppLang.kannada: 'ಅಳೆಯುವಾಗ ಸ್ಕ್ರೀನ್ ಆನ್ ಇರುತ್ತದೆ. ಫೋನ್ ಜೇಬಿನಲ್ಲಿಟ್ಟರೂ ಈ ಸ್ಕ್ರೀನ್ ತೆರೆದೇ ಇಡಿ.',
      });
}
