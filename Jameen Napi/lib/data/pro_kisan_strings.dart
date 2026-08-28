import 'app_language.dart';

/// "प्रो किसान" वाले promo page की सारी strings, नौ भाषाओं में।
///
/// जो लिखा है वो Pro Kisan की अपनी Play listing से लिया गया है — बढ़ा-चढ़ाकर
/// कुछ नहीं। इंटरनेट और डेटा वाली दोनों lines जान-बूझकर रखी हैं: पहले से बता
/// देने पर खराब reviews नहीं आते।
extension ProKisanStrings on AppStrings {
  /// Home के promo card के ऊपर छोटा लेबल — साफ़ रहे कि यह दूसरा ऐप है,
  /// इसी ऐप का कोई tool नहीं।
  String get pkOurOtherApp => pick(const {
        AppLang.hindi: 'हमारा दूसरा ऐप',
        AppLang.english: 'Our other app',
        AppLang.marathi: 'आमचे दुसरे ॲप',
        AppLang.gujarati: 'અમારી બીજી ઍપ',
        AppLang.punjabi: 'ਸਾਡੀ ਦੂਜੀ ਐਪ',
        AppLang.bengali: 'আমাদের আরেকটি অ্যাপ',
        AppLang.telugu: 'మా మరో యాప్',
        AppLang.tamil: 'எங்கள் மற்றொரு செயலி',
        AppLang.kannada: 'ನಮ್ಮ ಇನ್ನೊಂದು ಆಪ್',
      });

  String get pkName => pick(const {
        AppLang.hindi: 'प्रो किसान',
        AppLang.english: 'Pro Kisan',
        AppLang.marathi: 'प्रो किसान',
        AppLang.gujarati: 'પ્રો કિસાન',
        AppLang.punjabi: 'ਪ੍ਰੋ ਕਿਸਾਨ',
        AppLang.bengali: 'প্রো কিসান',
        AppLang.telugu: 'ప్రో కిసాన్',
        AppLang.tamil: 'ப்ரோ கிசான்',
        AppLang.kannada: 'ಪ್ರೊ ಕಿಸಾನ್',
      });

  String get pkTagline => pick(const {
        AppLang.hindi: 'दूध का हिसाब, खाद, पशु, मौसम, मंडी भाव — सब एक ऐप में',
        AppLang.english: 'Milk diary, fertiliser, cattle, weather, mandi rates — all in one app',
        AppLang.marathi: 'दूध हिशेब, खत, पशू, हवामान, बाजारभाव — सर्व एका ॲपमध्ये',
        AppLang.gujarati: 'દૂધ હિસાબ, ખાતર, પશુ, હવામાન, બજારભાવ — બધું એક ઍપમાં',
        AppLang.punjabi: 'ਦੁੱਧ ਹਿਸਾਬ, ਖਾਦ, ਪਸ਼ੂ, ਮੌਸਮ, ਮੰਡੀ ਭਾਅ — ਸਭ ਇੱਕ ਐਪ ਵਿੱਚ',
        AppLang.bengali: 'দুধের হিসাব, সার, পশু, আবহাওয়া, মান্ডি দর — সব এক অ্যাপে',
        AppLang.telugu: 'పాల లెక్క, ఎరువులు, పశువులు, వాతావరణం, మార్కెట్ ధరలు — అన్నీ ఒకే యాప్‌లో',
        AppLang.tamil: 'பால் கணக்கு, உரம், கால்நடை, வானிலை, சந்தை விலை — அனைத்தும் ஒரே செயலியில்',
        AppLang.kannada: 'ಹಾಲಿನ ಲೆಕ್ಕ, ಗೊಬ್ಬರ, ಜಾನುವಾರು, ಹವಾಮಾನ, ಮಾರುಕಟ್ಟೆ ದರ — ಎಲ್ಲವೂ ಒಂದೇ ಆಪ್‌ನಲ್ಲಿ',
      });

  String get pkFree => pick(const {
        AppLang.hindi: 'पूरी तरह मुफ़्त',
        AppLang.english: 'Completely free',
        AppLang.marathi: 'पूर्णपणे मोफत',
        AppLang.gujarati: 'સંપૂર્ણ મફત',
        AppLang.punjabi: 'ਪੂਰੀ ਤਰ੍ਹਾਂ ਮੁਫ਼ਤ',
        AppLang.bengali: 'সম্পূর্ণ বিনামূল্যে',
        AppLang.telugu: 'పూర్తిగా ఉచితం',
        AppLang.tamil: 'முற்றிலும் இலவசம்',
        AppLang.kannada: 'ಸಂಪೂರ್ಣ ಉಚಿತ',
      });

  String get pkTenLanguages => pick(const {
        AppLang.hindi: '10 भाषाएँ',
        AppLang.english: '10 languages',
        AppLang.marathi: '१० भाषा',
        AppLang.gujarati: '૧૦ ભાષાઓ',
        AppLang.punjabi: '੧੦ ਭਾਸ਼ਾਵਾਂ',
        AppLang.bengali: '১০টি ভাষা',
        AppLang.telugu: '10 భాషలు',
        AppLang.tamil: '10 மொழிகள்',
        AppLang.kannada: '೧೦ ಭಾಷೆಗಳು',
      });

  String get pkWhatItDoes => pick(const {
        AppLang.hindi: 'यह ऐप क्या करता है',
        AppLang.english: 'What this app does',
        AppLang.marathi: 'हे ॲप काय करते',
        AppLang.gujarati: 'આ ઍપ શું કરે છે',
        AppLang.punjabi: 'ਇਹ ਐਪ ਕੀ ਕਰਦੀ ਹੈ',
        AppLang.bengali: 'এই অ্যাপ কী করে',
        AppLang.telugu: 'ఈ యాప్ ఏం చేస్తుంది',
        AppLang.tamil: 'இந்தச் செயலி என்ன செய்கிறது',
        AppLang.kannada: 'ಈ ಆಪ್ ಏನು ಮಾಡುತ್ತದೆ',
      });

  // ─────────────── features ───────────────

  String get pkMilkTitle => pick(const {
        AppLang.hindi: 'दूध का हिसाब (दूध डायरी)',
        AppLang.english: 'Milk diary',
        AppLang.marathi: 'दूध हिशेब (दूध डायरी)',
        AppLang.gujarati: 'દૂધનો હિસાબ (દૂધ ડાયરી)',
        AppLang.punjabi: 'ਦੁੱਧ ਦਾ ਹਿਸਾਬ (ਦੁੱਧ ਡਾਇਰੀ)',
        AppLang.bengali: 'দুধের হিসাব (দুধ ডায়েরি)',
        AppLang.telugu: 'పాల లెక్క (పాల డైరీ)',
        AppLang.tamil: 'பால் கணக்கு (பால் நாட்குறிப்பு)',
        AppLang.kannada: 'ಹಾಲಿನ ಲೆಕ್ಕ (ಹಾಲು ಡೈರಿ)',
      });

  String get pkMilkBody => pick(const {
        AppLang.hindi:
            'ग्राहक चुनो → लीटर डालो → OK। फैट/SNF दर या फ़्लैट रेट, अपनी भाषा में PDF बिल, एक क्लिक में व्हाट्सएप पर भेजें। बकाया अपने आप जुड़ता रहता है।',
        AppLang.english:
            'Pick a customer → enter litres → done. Fat/SNF or flat rate, PDF bills in your own language, send on WhatsApp in one tap. Dues add up automatically.',
        AppLang.marathi:
            'ग्राहक निवडा → लिटर टाका → झाले. फॅट/SNF किंवा सरळ दर, तुमच्या भाषेत PDF बिल, एका क्लिकवर व्हॉट्सॲपवर पाठवा. येणे रक्कम आपोआप जमा होते.',
        AppLang.gujarati:
            'ગ્રાહક પસંદ કરો → લિટર નાખો → થઈ ગયું. ફેટ/SNF કે ફ્લેટ દર, તમારી ભાષામાં PDF બિલ, એક ક્લિકે વૉટ્સએપ પર મોકલો. બાકી રકમ આપોઆપ ઉમેરાય છે.',
        AppLang.punjabi:
            'ਗਾਹਕ ਚੁਣੋ → ਲਿਟਰ ਭਰੋ → ਹੋ ਗਿਆ। ਫੈਟ/SNF ਜਾਂ ਸਿੱਧਾ ਰੇਟ, ਆਪਣੀ ਭਾਸ਼ਾ ਵਿੱਚ PDF ਬਿੱਲ, ਇੱਕ ਕਲਿੱਕ ਵਿੱਚ ਵਟਸਐਪ ਉੱਤੇ ਭੇਜੋ। ਬਕਾਇਆ ਆਪੇ ਜੁੜਦਾ ਰਹਿੰਦਾ ਹੈ।',
        AppLang.bengali:
            'গ্রাহক বাছুন → লিটার লিখুন → হয়ে গেল। ফ্যাট/SNF বা ফ্ল্যাট রেট, নিজের ভাষায় PDF বিল, এক ক্লিকে হোয়াটসঅ্যাপে পাঠান। বকেয়া নিজে থেকেই যোগ হয়।',
        AppLang.telugu:
            'కస్టమర్ ఎంచుకోండి → లీటర్లు వేయండి → అయిపోయింది. ఫ్యాట్/SNF లేదా ఫ్లాట్ రేటు, మీ భాషలో PDF బిల్లు, ఒకే క్లిక్‌లో వాట్సాప్‌లో పంపండి. బాకీ దానంతట అదే కలుస్తుంది.',
        AppLang.tamil:
            'வாடிக்கையாளரைத் தேர்வு செய்யுங்கள் → லிட்டர் இடுங்கள் → முடிந்தது. ஃபேட்/SNF அல்லது நிலையான விலை, உங்கள் மொழியில் PDF பில், ஒரே தட்டலில் வாட்ஸ்அப்பில் அனுப்புங்கள். நிலுவைத் தொகை தானாகவே சேரும்.',
        AppLang.kannada:
            'ಗ್ರಾಹಕರನ್ನು ಆರಿಸಿ → ಲೀಟರ್ ಹಾಕಿ → ಮುಗಿಯಿತು. ಫ್ಯಾಟ್/SNF ಅಥವಾ ಫ್ಲಾಟ್ ದರ, ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ PDF ಬಿಲ್, ಒಂದೇ ಕ್ಲಿಕ್‌ನಲ್ಲಿ ವಾಟ್ಸ್‌ಆ್ಯಪ್‌ನಲ್ಲಿ ಕಳುಹಿಸಿ. ಬಾಕಿ ತಾನಾಗಿಯೇ ಸೇರುತ್ತದೆ.',
      });

  String get pkFertTitle => pick(const {
        AppLang.hindi: 'खाद-बीज कैलकुलेटर',
        AppLang.english: 'Fertiliser calculator',
        AppLang.marathi: 'खत-बियाणे कॅल्क्युलेटर',
        AppLang.gujarati: 'ખાતર-બિયારણ કેલ્ક્યુલેટર',
        AppLang.punjabi: 'ਖਾਦ-ਬੀਜ ਕੈਲਕੁਲੇਟਰ',
        AppLang.bengali: 'সার-বীজ ক্যালকুলেটর',
        AppLang.telugu: 'ఎరువులు-విత్తన క్యాలిక్యులేటర్',
        AppLang.tamil: 'உரம்-விதை கால்குலேட்டர்',
        AppLang.kannada: 'ಗೊಬ್ಬರ-ಬೀಜ ಕ್ಯಾಲ್ಕುಲೇಟರ್',
      });

  String get pkFertBody => pick(const {
        AppLang.hindi:
            '30+ फ़सलें — गेहूँ, धान, मक्का, सरसों, आलू, गन्ना, कपास। एकड़, बीघा या हेक्टेयर के हिसाब से यूरिया, DAP और MOP की सही बोरी और किलो मात्रा।',
        AppLang.english:
            '30+ crops — wheat, paddy, maize, mustard, potato, sugarcane, cotton. Exact bags and kilos of urea, DAP and MOP per acre, bigha or hectare.',
        AppLang.marathi:
            '३०+ पिके — गहू, भात, मका, मोहरी, बटाटा, ऊस, कापूस. एकर, बीघा किंवा हेक्टरनुसार युरिया, DAP आणि MOP च्या अचूक गोणी व किलो.',
        AppLang.gujarati:
            '૩૦+ પાક — ઘઉં, ડાંગર, મકાઈ, રાઈ, બટાટા, શેરડી, કપાસ. એકર, વીઘા કે હેક્ટર પ્રમાણે યુરિયા, DAP અને MOP ની સાચી બોરી અને કિલો.',
        AppLang.punjabi:
            '੩੦+ ਫ਼ਸਲਾਂ — ਕਣਕ, ਝੋਨਾ, ਮੱਕੀ, ਸਰ੍ਹੋਂ, ਆਲੂ, ਗੰਨਾ, ਕਪਾਹ। ਏਕੜ, ਬੀਘਾ ਜਾਂ ਹੈਕਟੇਅਰ ਮੁਤਾਬਕ ਯੂਰੀਆ, DAP ਤੇ MOP ਦੇ ਸਹੀ ਥੈਲੇ ਤੇ ਕਿਲੋ।',
        AppLang.bengali:
            '৩০+ ফসল — গম, ধান, ভুট্টা, সরিষা, আলু, আখ, তুলা। একর, বিঘা বা হেক্টর অনুযায়ী ইউরিয়া, DAP ও MOP-র সঠিক বস্তা ও কিলো।',
        AppLang.telugu:
            '30+ పంటలు — గోధుమ, వరి, మొక్కజొన్న, ఆవాలు, బంగాళదుంప, చెరకు, పత్తి. ఎకరం, బీగా లేదా హెక్టారు ప్రకారం యూరియా, DAP, MOP సరైన బస్తాలు, కిలోలు.',
        AppLang.tamil:
            '30+ பயிர்கள் — கோதுமை, நெல், சோளம், கடுகு, உருளைக்கிழங்கு, கரும்பு, பருத்தி. ஏக்கர், பீகா அல்லது ஹெக்டேர் அடிப்படையில் யூரியா, DAP, MOP-இன் சரியான மூட்டை மற்றும் கிலோ.',
        AppLang.kannada:
            '೩೦+ ಬೆಳೆಗಳು — ಗೋಧಿ, ಭತ್ತ, ಜೋಳ, ಸಾಸಿವೆ, ಆಲೂಗಡ್ಡೆ, ಕಬ್ಬು, ಹತ್ತಿ. ಎಕರೆ, ಬೀಗಾ ಅಥವಾ ಹೆಕ್ಟೇರ್ ಪ್ರಕಾರ ಯೂರಿಯಾ, DAP, MOP ಸರಿಯಾದ ಚೀಲ ಮತ್ತು ಕಿಲೋ.',
      });

  String get pkCattleTitle => pick(const {
        AppLang.hindi: 'पशु व गाभिन कैलकुलेटर',
        AppLang.english: 'Cattle & pregnancy calculator',
        AppLang.marathi: 'पशू व गाभण कॅल्क्युलेटर',
        AppLang.gujarati: 'પશુ અને ગાભણ કેલ્ક્યુલેટર',
        AppLang.punjabi: 'ਪਸ਼ੂ ਤੇ ਗੱਭਣ ਕੈਲਕੁਲੇਟਰ',
        AppLang.bengali: 'পশু ও গর্ভ ক্যালকুলেটর',
        AppLang.telugu: 'పశువులు, చూలు క్యాలిక్యులేటర్',
        AppLang.tamil: 'கால்நடை & கருவுறுதல் கால்குலேட்டர்',
        AppLang.kannada: 'ಜಾನುವಾರು ಮತ್ತು ಗರ್ಭ ಕ್ಯಾಲ್ಕುಲೇಟರ್',
      });

  String get pkCattleBody => pick(const {
        AppLang.hindi:
            'गर्भाधान (AI) की तारीख़ डालिए — ब्याने की तारीख़, गर्भ जाँच और दूध सुखाने का दिन तुरंत। ब्याने से 7 दिन पहले फोन पर रिमाइंडर। रोज़ के दूध के हिसाब से दाना कैलकुलेटर।',
        AppLang.english:
            'Enter the AI date — get the calving date, pregnancy check and dry-off day at once. A reminder 7 days before calving. Feed calculator based on daily milk.',
        AppLang.marathi:
            'रेतन (AI) ची तारीख टाका — व्यायची तारीख, गर्भ तपासणी आणि दूध आटवण्याचा दिवस लगेच. व्यायच्या ७ दिवस आधी स्मरणपत्र. रोजच्या दुधानुसार खुराक कॅल्क्युलेटर.',
        AppLang.gujarati:
            'ગર્ભાધાન (AI) ની તારીખ નાખો — વિયાણની તારીખ, ગર્ભ ચકાસણી અને દૂધ સૂકવવાનો દિવસ તરત. વિયાણના ૭ દિવસ પહેલાં રિમાઇન્ડર. રોજના દૂધ પ્રમાણે દાણ કેલ્ક્યુલેટર.',
        AppLang.punjabi:
            'ਗਰਭਧਾਰਨ (AI) ਦੀ ਤਾਰੀਖ਼ ਭਰੋ — ਸੂਣ ਦੀ ਤਾਰੀਖ਼, ਗਰਭ ਜਾਂਚ ਤੇ ਦੁੱਧ ਸੁਕਾਉਣ ਦਾ ਦਿਨ ਤੁਰੰਤ। ਸੂਣ ਤੋਂ ੭ ਦਿਨ ਪਹਿਲਾਂ ਯਾਦ-ਪੱਤਰ। ਰੋਜ਼ ਦੇ ਦੁੱਧ ਮੁਤਾਬਕ ਖ਼ੁਰਾਕ ਕੈਲਕੁਲੇਟਰ।',
        AppLang.bengali:
            'প্রজননের (AI) তারিখ দিন — বাচ্চা দেওয়ার তারিখ, গর্ভ পরীক্ষা ও দুধ শুকানোর দিন সঙ্গে সঙ্গে। বাচ্চা দেওয়ার ৭ দিন আগে মনে করিয়ে দেবে। রোজকার দুধ অনুযায়ী খাবারের হিসাব।',
        AppLang.telugu:
            'కృత్రిమ గర్భధారణ (AI) తేదీ వేయండి — ఈనే తేదీ, గర్భ పరీక్ష, పాలు ఆపే రోజు వెంటనే. ఈనడానికి 7 రోజుల ముందు రిమైండర్. రోజువారీ పాల ప్రకారం దాణా క్యాలిక్యులేటర్.',
        AppLang.tamil:
            'செயற்கை கருவூட்டல் (AI) தேதியை இடுங்கள் — ஈனும் தேதி, கர்ப்பப் பரிசோதனை, பால் நிறுத்தும் நாள் உடனே. ஈனுவதற்கு 7 நாட்கள் முன் நினைவூட்டல். தினசரி பாலின் அடிப்படையில் தீவன கால்குலேட்டர்.',
        AppLang.kannada:
            'ಕೃತಕ ಗರ್ಭಧಾರಣೆ (AI) ದಿನಾಂಕ ಹಾಕಿ — ಕರು ಹಾಕುವ ದಿನಾಂಕ, ಗರ್ಭ ಪರೀಕ್ಷೆ, ಹಾಲು ನಿಲ್ಲಿಸುವ ದಿನ ತಕ್ಷಣ. ಕರು ಹಾಕುವ ೭ ದಿನ ಮೊದಲು ಜ್ಞಾಪನೆ. ದಿನದ ಹಾಲಿನ ಪ್ರಕಾರ ಆಹಾರ ಕ್ಯಾಲ್ಕುಲೇಟರ್.',
      });

  String get pkWeatherTitle => pick(const {
        AppLang.hindi: '10 दिन का मौसम',
        AppLang.english: '10-day weather',
        AppLang.marathi: '१० दिवसांचे हवामान',
        AppLang.gujarati: '૧૦ દિવસનું હવામાન',
        AppLang.punjabi: '੧੦ ਦਿਨਾਂ ਦਾ ਮੌਸਮ',
        AppLang.bengali: '১০ দিনের আবহাওয়া',
        AppLang.telugu: '10 రోజుల వాతావరణం',
        AppLang.tamil: '10 நாள் வானிலை',
        AppLang.kannada: '೧೦ ದಿನಗಳ ಹವಾಮಾನ',
      });

  String get pkWeatherBody => pick(const {
        AppLang.hindi: 'अपने गाँव का या किसी भी शहर का — बारिश, हवा की गति, तापमान और आँधी-तूफ़ान का अलर्ट।',
        AppLang.english: 'For your village or any city — rain, wind speed, temperature and storm alerts.',
        AppLang.marathi: 'तुमच्या गावाचे किंवा कोणत्याही शहराचे — पाऊस, वाऱ्याचा वेग, तापमान आणि वादळाचा इशारा.',
        AppLang.gujarati: 'તમારા ગામનું કે કોઈ પણ શહેરનું — વરસાદ, પવનની ઝડપ, તાપમાન અને વાવાઝોડાની ચેતવણી.',
        AppLang.punjabi: 'ਆਪਣੇ ਪਿੰਡ ਦਾ ਜਾਂ ਕਿਸੇ ਵੀ ਸ਼ਹਿਰ ਦਾ — ਮੀਂਹ, ਹਵਾ ਦੀ ਰਫ਼ਤਾਰ, ਤਾਪਮਾਨ ਤੇ ਤੂਫ਼ਾਨ ਦੀ ਚੇਤਾਵਨੀ।',
        AppLang.bengali: 'আপনার গ্রামের বা যেকোনো শহরের — বৃষ্টি, বাতাসের গতি, তাপমাত্রা ও ঝড়ের সতর্কতা।',
        AppLang.telugu: 'మీ ఊరిది లేదా ఏ నగరానిదైనా — వర్షం, గాలి వేగం, ఉష్ణోగ్రత, తుఫాను హెచ్చరిక.',
        AppLang.tamil: 'உங்கள் கிராமம் அல்லது எந்த நகரமும் — மழை, காற்றின் வேகம், வெப்பநிலை, புயல் எச்சரிக்கை.',
        AppLang.kannada: 'ನಿಮ್ಮ ಹಳ್ಳಿಯ ಅಥವಾ ಯಾವುದೇ ನಗರದ — ಮಳೆ, ಗಾಳಿಯ ವೇಗ, ತಾಪಮಾನ, ಬಿರುಗಾಳಿ ಎಚ್ಚರಿಕೆ.',
      });

  String get pkMandiTitle => pick(const {
        AppLang.hindi: 'मंडी भाव और MSP',
        AppLang.english: 'Mandi rates & MSP',
        AppLang.marathi: 'बाजारभाव आणि MSP',
        AppLang.gujarati: 'બજારભાવ અને MSP',
        AppLang.punjabi: 'ਮੰਡੀ ਭਾਅ ਤੇ MSP',
        AppLang.bengali: 'মান্ডি দর ও MSP',
        AppLang.telugu: 'మార్కెట్ ధరలు, MSP',
        AppLang.tamil: 'சந்தை விலை & MSP',
        AppLang.kannada: 'ಮಾರುಕಟ್ಟೆ ದರ ಮತ್ತು MSP',
      });

  String get pkMandiBody => pick(const {
        AppLang.hindi: 'देश की बड़ी मंडियों के ताज़ा भाव, और न्यूनतम समर्थन मूल्य से तुलना।',
        AppLang.english: 'Latest rates from major mandis, compared against the minimum support price.',
        AppLang.marathi: 'देशातील मोठ्या बाजारांचे ताजे भाव, आणि हमीभावाशी तुलना.',
        AppLang.gujarati: 'દેશની મોટી બજારોના તાજા ભાવ, અને ટેકાના ભાવ સાથે સરખામણી.',
        AppLang.punjabi: 'ਦੇਸ਼ ਦੀਆਂ ਵੱਡੀਆਂ ਮੰਡੀਆਂ ਦੇ ਤਾਜ਼ਾ ਭਾਅ, ਤੇ ਘੱਟੋ-ਘੱਟ ਸਮਰਥਨ ਮੁੱਲ ਨਾਲ ਤੁਲਨਾ।',
        AppLang.bengali: 'দেশের বড় মান্ডির তাজা দর, আর ন্যূনতম সহায়ক মূল্যের সঙ্গে তুলনা।',
        AppLang.telugu: 'దేశంలోని పెద్ద మార్కెట్ల తాజా ధరలు, కనీస మద్దతు ధరతో పోలిక.',
        AppLang.tamil: 'நாட்டின் பெரிய சந்தைகளின் சமீபத்திய விலைகள், குறைந்தபட்ச ஆதரவு விலையுடன் ஒப்பீடு.',
        AppLang.kannada: 'ದೇಶದ ದೊಡ್ಡ ಮಾರುಕಟ್ಟೆಗಳ ತಾಜಾ ದರ, ಕನಿಷ್ಠ ಬೆಂಬಲ ಬೆಲೆಯೊಂದಿಗೆ ಹೋಲಿಕೆ.',
      });

  String get pkSchemeTitle => pick(const {
        AppLang.hindi: 'सरकारी योजनाएँ',
        AppLang.english: 'Government schemes',
        AppLang.marathi: 'सरकारी योजना',
        AppLang.gujarati: 'સરકારી યોજનાઓ',
        AppLang.punjabi: 'ਸਰਕਾਰੀ ਸਕੀਮਾਂ',
        AppLang.bengali: 'সরকারি প্রকল্প',
        AppLang.telugu: 'ప్రభుత్వ పథకాలు',
        AppLang.tamil: 'அரசுத் திட்டங்கள்',
        AppLang.kannada: 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
      });

  String get pkSchemeBody => pick(const {
        AppLang.hindi: 'PM किसान, फसल बीमा, KCC और मृदा कार्ड की पात्रता जाँचिए। जैविक खेती और कीट नियंत्रण की सलाह भी।',
        AppLang.english: 'Check eligibility for PM Kisan, crop insurance, KCC and soil card. Organic farming and pest control advice too.',
        AppLang.marathi: 'पीएम किसान, पीक विमा, KCC आणि मृदा कार्डची पात्रता तपासा. सेंद्रिय शेती व कीड नियंत्रणाचा सल्लाही.',
        AppLang.gujarati: 'પીએમ કિસાન, પાક વીમો, KCC અને મૃદા કાર્ડની પાત્રતા ચકાસો. જૈવિક ખેતી અને જીવાત નિયંત્રણની સલાહ પણ.',
        AppLang.punjabi: 'ਪੀਐਮ ਕਿਸਾਨ, ਫ਼ਸਲ ਬੀਮਾ, KCC ਤੇ ਮਿੱਟੀ ਕਾਰਡ ਦੀ ਯੋਗਤਾ ਜਾਂਚੋ। ਜੈਵਿਕ ਖੇਤੀ ਤੇ ਕੀਟ ਕੰਟਰੋਲ ਦੀ ਸਲਾਹ ਵੀ।',
        AppLang.bengali: 'পিএম কিসান, ফসল বিমা, KCC ও মাটি কার্ডের যোগ্যতা দেখুন। জৈব চাষ ও পোকা দমনের পরামর্শও।',
        AppLang.telugu: 'పీఎం కిసాన్, పంట బీమా, KCC, భూసార కార్డు అర్హత చూసుకోండి. సేంద్రియ వ్యవసాయం, పురుగు నియంత్రణ సలహాలు కూడా.',
        AppLang.tamil: 'பிஎம் கிசான், பயிர் காப்பீடு, KCC, மண் அட்டை தகுதியைப் பாருங்கள். இயற்கை விவசாயம், பூச்சி கட்டுப்பாட்டு ஆலோசனையும்.',
        AppLang.kannada: 'ಪಿಎಂ ಕಿಸಾನ್, ಬೆಳೆ ವಿಮೆ, KCC, ಮಣ್ಣು ಕಾರ್ಡ್ ಅರ್ಹತೆ ಪರಿಶೀಲಿಸಿ. ಸಾವಯವ ಕೃಷಿ, ಕೀಟ ನಿಯಂತ್ರಣ ಸಲಹೆಯೂ.',
      });

  String get pkGpsTitle => pick(const {
        AppLang.hindi: 'GPS से खेत नापें',
        AppLang.english: 'Measure fields by GPS',
        AppLang.marathi: 'GPS ने शेत मोजा',
        AppLang.gujarati: 'GPS થી ખેતર માપો',
        AppLang.punjabi: 'GPS ਨਾਲ ਖੇਤ ਮਿਣੋ',
        AppLang.bengali: 'GPS দিয়ে জমি মাপুন',
        AppLang.telugu: 'GPS తో పొలం కొలవండి',
        AppLang.tamil: 'GPS மூலம் நிலம் அளக்கவும்',
        AppLang.kannada: 'GPS ಮೂಲಕ ಜಮೀನು ಅಳೆಯಿರಿ',
      });

  String get pkGpsBody => pick(const {
        AppLang.hindi: 'खेत के चारों ओर घूमिए, एकड़ या बीघा में क्षेत्रफल अपने आप।',
        AppLang.english: 'Walk around the field and get the area in acres or bigha automatically.',
        AppLang.marathi: 'शेताभोवती फिरा, एकर किंवा बीघ्यात क्षेत्रफळ आपोआप.',
        AppLang.gujarati: 'ખેતરની આસપાસ ફરો, એકર કે વીઘામાં ક્ષેત્રફળ આપોઆપ.',
        AppLang.punjabi: 'ਖੇਤ ਦੇ ਆਲੇ-ਦੁਆਲੇ ਘੁੰਮੋ, ਏਕੜ ਜਾਂ ਬੀਘੇ ਵਿੱਚ ਖੇਤਰਫਲ ਆਪੇ।',
        AppLang.bengali: 'জমির চারপাশে হাঁটুন, একর বা বিঘায় ক্ষেত্রফল নিজে থেকেই।',
        AppLang.telugu: 'పొలం చుట్టూ నడవండి, ఎకరాలు లేదా బీగాలలో వైశాల్యం దానంతట అదే.',
        AppLang.tamil: 'நிலத்தைச் சுற்றி நடங்கள், ஏக்கர் அல்லது பீகாவில் பரப்பளவு தானாகவே.',
        AppLang.kannada: 'ಜಮೀನಿನ ಸುತ್ತ ನಡೆಯಿರಿ, ಎಕರೆ ಅಥವಾ ಬೀಗಾದಲ್ಲಿ ವಿಸ್ತೀರ್ಣ ತಾನಾಗಿಯೇ.',
      });

  // ─────────────── ईमानदारी वाली दो बातें ───────────────

  String get pkDataNote => pick(const {
        AppLang.hindi: 'आपका बहीखाता आपके फोन में रहता है — किसी सर्वर पर नहीं जाता। चाहें तो अपनी ही Google Drive में बैकअप रखिए।',
        AppLang.english: 'Your ledger stays on your phone — it never goes to a server. You can back it up to your own Google Drive if you want.',
        AppLang.marathi: 'तुमचा हिशोब तुमच्या फोनमध्येच राहतो — कोणत्याही सर्व्हरवर जात नाही. हवे असल्यास स्वतःच्या Google Drive मध्ये बॅकअप ठेवा.',
        AppLang.gujarati: 'તમારો હિસાબ તમારા ફોનમાં જ રહે છે — કોઈ સર્વર પર જતો નથી. ઇચ્છો તો પોતાની Google Drive માં બેકઅપ રાખો.',
        AppLang.punjabi: 'ਤੁਹਾਡਾ ਹਿਸਾਬ ਤੁਹਾਡੇ ਫ਼ੋਨ ਵਿੱਚ ਰਹਿੰਦਾ ਹੈ — ਕਿਸੇ ਸਰਵਰ ਉੱਤੇ ਨਹੀਂ ਜਾਂਦਾ। ਚਾਹੋ ਤਾਂ ਆਪਣੀ Google Drive ਵਿੱਚ ਬੈਕਅੱਪ ਰੱਖੋ।',
        AppLang.bengali: 'আপনার হিসাব আপনার ফোনেই থাকে — কোনো সার্ভারে যায় না। চাইলে নিজের Google Drive-এ ব্যাকআপ রাখুন।',
        AppLang.telugu: 'మీ లెక్క మీ ఫోన్‌లోనే ఉంటుంది — ఏ సర్వర్‌కూ వెళ్లదు. కావాలంటే మీ సొంత Google Drive లో బ్యాకప్ ఉంచుకోండి.',
        AppLang.tamil: 'உங்கள் கணக்கு உங்கள் தொலைபேசியிலேயே இருக்கும் — எந்த சர்வருக்கும் செல்லாது. வேண்டுமானால் உங்கள் Google Drive-இல் காப்புப் பிரதி வைக்கலாம்.',
        AppLang.kannada: 'ನಿಮ್ಮ ಲೆಕ್ಕ ನಿಮ್ಮ ಫೋನಿನಲ್ಲೇ ಇರುತ್ತದೆ — ಯಾವ ಸರ್ವರ್‌ಗೂ ಹೋಗುವುದಿಲ್ಲ. ಬೇಕಿದ್ದರೆ ನಿಮ್ಮ Google Drive ನಲ್ಲಿ ಬ್ಯಾಕಪ್ ಇಡಿ.',
      });

  String get pkInternetNote => pick(const {
        AppLang.hindi: 'दूध, खाद, पशु और खेत की नाप बिना इंटरनेट चलती है। मौसम, मंडी भाव और समाचार के लिए ही इंटरनेट चाहिए।',
        AppLang.english: 'Milk, fertiliser, cattle and field measuring work without internet. Only weather, mandi rates and news need it.',
        AppLang.marathi: 'दूध, खत, पशू आणि शेत मोजणी इंटरनेटशिवाय चालते. फक्त हवामान, बाजारभाव आणि बातम्यांसाठी इंटरनेट लागते.',
        AppLang.gujarati: 'દૂધ, ખાતર, પશુ અને ખેતર માપણી ઇન્ટરનેટ વગર ચાલે છે. માત્ર હવામાન, બજારભાવ અને સમાચાર માટે ઇન્ટરનેટ જોઈએ.',
        AppLang.punjabi: 'ਦੁੱਧ, ਖਾਦ, ਪਸ਼ੂ ਤੇ ਖੇਤ ਮਿਣਤੀ ਬਿਨਾਂ ਇੰਟਰਨੈੱਟ ਚੱਲਦੀ ਹੈ। ਸਿਰਫ਼ ਮੌਸਮ, ਮੰਡੀ ਭਾਅ ਤੇ ਖ਼ਬਰਾਂ ਲਈ ਇੰਟਰਨੈੱਟ ਚਾਹੀਦਾ ਹੈ।',
        AppLang.bengali: 'দুধ, সার, পশু ও জমি মাপা ইন্টারনেট ছাড়াই চলে। কেবল আবহাওয়া, মান্ডি দর ও খবরের জন্য ইন্টারনেট লাগে।',
        AppLang.telugu: 'పాలు, ఎరువులు, పశువులు, పొలం కొలత ఇంటర్నెట్ లేకుండా పనిచేస్తాయి. వాతావరణం, మార్కెట్ ధరలు, వార్తలకు మాత్రమే ఇంటర్నెట్ కావాలి.',
        AppLang.tamil: 'பால், உரம், கால்நடை, நில அளவீடு இணையம் இல்லாமல் வேலை செய்யும். வானிலை, சந்தை விலை, செய்திகளுக்கு மட்டுமே இணையம் தேவை.',
        AppLang.kannada: 'ಹಾಲು, ಗೊಬ್ಬರ, ಜಾನುವಾರು, ಜಮೀನು ಅಳತೆ ಇಂಟರ್ನೆಟ್ ಇಲ್ಲದೆ ನಡೆಯುತ್ತದೆ. ಹವಾಮಾನ, ಮಾರುಕಟ್ಟೆ ದರ, ಸುದ್ದಿಗೆ ಮಾತ್ರ ಇಂಟರ್ನೆಟ್ ಬೇಕು.',
      });

  // ─────────────── button ───────────────

  String get pkInstallNow => pick(const {
        AppLang.hindi: 'अभी इंस्टॉल करें',
        AppLang.english: 'Install now',
        AppLang.marathi: 'आताच इंस्टॉल करा',
        AppLang.gujarati: 'હમણાં જ ઇન્સ્ટૉલ કરો',
        AppLang.punjabi: 'ਹੁਣੇ ਇੰਸਟਾਲ ਕਰੋ',
        AppLang.bengali: 'এখনই ইনস্টল করুন',
        AppLang.telugu: 'ఇప్పుడే ఇన్‌స్టాల్ చేయండి',
        AppLang.tamil: 'இப்போதே நிறுவவும்',
        AppLang.kannada: 'ಈಗಲೇ ಇನ್‌ಸ್ಟಾಲ್ ಮಾಡಿ',
      });

  String get pkOpenApp => pick(const {
        AppLang.hindi: 'ऐप खोलें',
        AppLang.english: 'Open app',
        AppLang.marathi: 'ॲप उघडा',
        AppLang.gujarati: 'ઍપ ખોલો',
        AppLang.punjabi: 'ਐਪ ਖੋਲ੍ਹੋ',
        AppLang.bengali: 'অ্যাপ খুলুন',
        AppLang.telugu: 'యాప్ తెరవండి',
        AppLang.tamil: 'செயலியைத் திற',
        AppLang.kannada: 'ಆಪ್ ತೆರೆಯಿರಿ',
      });

  String get pkKnowMore => pick(const {
        AppLang.hindi: 'और जानें',
        AppLang.english: 'Know more',
        AppLang.marathi: 'अधिक जाणा',
        AppLang.gujarati: 'વધુ જાણો',
        AppLang.punjabi: 'ਹੋਰ ਜਾਣੋ',
        AppLang.bengali: 'আরও জানুন',
        AppLang.telugu: 'మరింత తెలుసుకోండి',
        AppLang.tamil: 'மேலும் அறிக',
        AppLang.kannada: 'ಇನ್ನಷ್ಟು ತಿಳಿಯಿರಿ',
      });

  String get pkCouldNotOpen => pick(const {
        AppLang.hindi: 'Play Store नहीं खुल पाया',
        AppLang.english: 'Could not open the Play Store',
        AppLang.marathi: 'Play Store उघडता आले नाही',
        AppLang.gujarati: 'Play Store ખૂલી શક્યું નહીં',
        AppLang.punjabi: 'Play Store ਨਹੀਂ ਖੁੱਲ੍ਹ ਸਕਿਆ',
        AppLang.bengali: 'Play Store খোলা গেল না',
        AppLang.telugu: 'Play Store తెరవలేకపోయాము',
        AppLang.tamil: 'Play Store-ஐத் திறக்க முடியவில்லை',
        AppLang.kannada: 'Play Store ತೆರೆಯಲಾಗಲಿಲ್ಲ',
      });
}
