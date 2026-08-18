import 'app_language.dart';
import 'plot_units.dart';

/// चारों नापी स्क्रीनों (4-भुजा खेत, बंटवारा, लग्गी, त्रिकोण) की सभी strings।
///
/// ये पहले सीधे स्क्रीनों में हिंदी में लिखी थीं — यानी तमिल या बंगाली चुनने पर
/// भी अंदर सब हिंदी दिखता था। हर string नौ भाषाओं में यहीं एक जगह रहती है।
///
/// नई string जोड़ते समय नौ की नौ भाषाएँ ज़रूर भरें — `widget_test.dart` का
/// "every tool string covers all nine languages" test खाली छूटने पर fail होगा।
extension ToolStrings on AppStrings {
  // ─────────────────────────── साझा (Shared) ───────────────────────────

  String get unitLabel => pick(const {
        AppLang.hindi: 'नाप की इकाई',
        AppLang.english: 'Measurement Unit',
        AppLang.marathi: 'मोजणीचे एकक',
        AppLang.gujarati: 'માપનું એકમ',
        AppLang.punjabi: 'ਮਿਣਤੀ ਦੀ ਇਕਾਈ',
        AppLang.bengali: 'পরিমাপের একক',
        AppLang.telugu: 'కొలత యూనిట్',
        AppLang.tamil: 'அளவீட்டு அலகு',
        AppLang.kannada: 'ಅಳತೆಯ ಘಟಕ',
      });

  String get stateLabel => pick(const {
        AppLang.hindi: 'राज्य',
        AppLang.english: 'State',
        AppLang.marathi: 'राज्य',
        AppLang.gujarati: 'રાજ્ય',
        AppLang.punjabi: 'ਰਾਜ',
        AppLang.bengali: 'রাজ্য',
        AppLang.telugu: 'రాష్ట్రం',
        AppLang.tamil: 'மாநிலம்',
        AppLang.kannada: 'ರಾಜ್ಯ',
      });

  String get reset => pick(const {
        AppLang.hindi: 'रीसेट करें',
        AppLang.english: 'Reset',
        AppLang.marathi: 'रीसेट करा',
        AppLang.gujarati: 'રીસેટ કરો',
        AppLang.punjabi: 'ਰੀਸੈੱਟ ਕਰੋ',
        AppLang.bengali: 'রিসেট করুন',
        AppLang.telugu: 'రీసెట్ చేయండి',
        AppLang.tamil: 'மீட்டமை',
        AppLang.kannada: 'ಮರುಹೊಂದಿಸಿ',
      });

  String get sqFt => pick(const {
        AppLang.hindi: 'वर्ग फीट',
        AppLang.english: 'sq ft',
        AppLang.marathi: 'चौरस फूट',
        AppLang.gujarati: 'ચોરસ ફૂટ',
        AppLang.punjabi: 'ਵਰਗ ਫੁੱਟ',
        AppLang.bengali: 'বর্গ ফুট',
        AppLang.telugu: 'చదరపు అడుగులు',
        AppLang.tamil: 'சதுர அடி',
        AppLang.kannada: 'ಚದರ ಅಡಿ',
      });

  String get sqGaj => pick(const {
        AppLang.hindi: 'वर्ग गज',
        AppLang.english: 'sq yard',
        AppLang.marathi: 'चौरस वार',
        AppLang.gujarati: 'ચોરસ વાર',
        AppLang.punjabi: 'ਵਰਗ ਗਜ਼',
        AppLang.bengali: 'বর্গ গজ',
        AppLang.telugu: 'చదరపు గజాలు',
        AppLang.tamil: 'சதுர கஜம்',
        AppLang.kannada: 'ಚದರ ಗಜ',
      });

  String get inches => pick(const {
        AppLang.hindi: 'इंच',
        AppLang.english: 'inches',
        AppLang.marathi: 'इंच',
        AppLang.gujarati: 'ઇંચ',
        AppLang.punjabi: 'ਇੰਚ',
        AppLang.bengali: 'ইঞ্চি',
        AppLang.telugu: 'అంగుళాలు',
        AppLang.tamil: 'அங்குலம்',
        AppLang.kannada: 'ಇಂಚು',
      });

  String get sqMeter => pick(const {
        AppLang.hindi: 'वर्ग मीटर',
        AppLang.english: 'sq meter',
        AppLang.marathi: 'चौरस मीटर',
        AppLang.gujarati: 'ચોરસ મીટર',
        AppLang.punjabi: 'ਵਰਗ ਮੀਟਰ',
        AppLang.bengali: 'বর্গ মিটার',
        AppLang.telugu: 'చదరపు మీటర్లు',
        AppLang.tamil: 'சதுர மீட்டர்',
        AppLang.kannada: 'ಚದರ ಮೀಟರ್',
      });

  String get sqInch => pick(const {
        AppLang.hindi: 'वर्ग इंच',
        AppLang.english: 'sq inch',
        AppLang.marathi: 'चौरस इंच',
        AppLang.gujarati: 'ચોરસ ઇંચ',
        AppLang.punjabi: 'ਵਰਗ ਇੰਚ',
        AppLang.bengali: 'বর্গ ইঞ্চি',
        AppLang.telugu: 'చదరపు అంగుళాలు',
        AppLang.tamil: 'சதுர அங்குலம்',
        AppLang.kannada: 'ಚದರ ಇಂಚು',
      });

  String get dismil => pick(const {
        AppLang.hindi: 'डिसमिल',
        AppLang.english: 'Dismil',
        AppLang.marathi: 'डिसमिल',
        AppLang.gujarati: 'ડિસમિલ',
        AppLang.punjabi: 'ਡਿਸਮਿਲ',
        AppLang.bengali: 'ডিসমিল',
        AppLang.telugu: 'డిస్మిల్',
        AppLang.tamil: 'டிஸ்மில்',
        AppLang.kannada: 'ಡಿಸ್ಮಿಲ್',
      });

  /// "पंजाब / हरियाणा में मान:" जैसा heading
  String valuesInState(String state) => pick({
        AppLang.hindi: '$state में मान:',
        AppLang.english: 'Values in $state:',
        AppLang.marathi: '$state मधील मूल्ये:',
        AppLang.gujarati: '$state માં મૂલ્યો:',
        AppLang.punjabi: '$state ਵਿੱਚ ਮੁੱਲ:',
        AppLang.bengali: '$state-এ মান:',
        AppLang.telugu: '$stateలో విలువలు:',
        AppLang.tamil: '$state-இல் மதிப்புகள்:',
        AppLang.kannada: '$stateನಲ್ಲಿ ಮೌಲ್ಯಗಳು:',
      });

  String get sharedFromApp => pick(const {
        AppLang.hindi: '— जमीन नापी ऐप से निकाला गया',
        AppLang.english: '— measured with the Jameen Napi app',
        AppLang.marathi: '— जमीन नापी ॲपमधून काढलेले',
        AppLang.gujarati: '— જમીન નાપી ઍપમાંથી કાઢેલું',
        AppLang.punjabi: '— ਜ਼ਮੀਨ ਨਾਪੀ ਐਪ ਤੋਂ ਕੱਢਿਆ ਗਿਆ',
        AppLang.bengali: '— জমি নাপি অ্যাপ থেকে বের করা',
        AppLang.telugu: '— జమీన్ నాపి యాప్ నుండి తీసినది',
        AppLang.tamil: '— ஜமீன் நாபி செயலியில் கணக்கிடப்பட்டது',
        AppLang.kannada: '— ಜಮೀನ್ ನಾಪಿ ಆಪ್‌ನಿಂದ ತೆಗೆದದ್ದು',
      });

  // ──────────────────────── इकाइयों के नाम ────────────────────────

  String plotUnitName(PlotUnit unit) {
    switch (unit) {
      case PlotUnit.feet:
        return pick(const {
          AppLang.hindi: 'फीट',
          AppLang.english: 'Feet',
          AppLang.marathi: 'फूट',
          AppLang.gujarati: 'ફૂટ',
          AppLang.punjabi: 'ਫੁੱਟ',
          AppLang.bengali: 'ফুট',
          AppLang.telugu: 'అడుగు',
          AppLang.tamil: 'அடி',
          AppLang.kannada: 'ಅಡಿ',
        });
      case PlotUnit.gaj:
        return pick(const {
          AppLang.hindi: 'गज',
          AppLang.english: 'Gaj (Yard)',
          AppLang.marathi: 'वार',
          AppLang.gujarati: 'વાર',
          AppLang.punjabi: 'ਗਜ਼',
          AppLang.bengali: 'গজ',
          AppLang.telugu: 'గజం',
          AppLang.tamil: 'கஜம்',
          AppLang.kannada: 'ಗಜ',
        });
      case PlotUnit.meter:
        return pick(const {
          AppLang.hindi: 'मीटर',
          AppLang.english: 'Meter',
          AppLang.marathi: 'मीटर',
          AppLang.gujarati: 'મીટર',
          AppLang.punjabi: 'ਮੀਟਰ',
          AppLang.bengali: 'মিটার',
          AppLang.telugu: 'మీటర్',
          AppLang.tamil: 'மீட்டர்',
          AppLang.kannada: 'ಮೀಟರ್',
        });
      case PlotUnit.kadi:
        return pick(const {
          AppLang.hindi: 'कड़ी',
          AppLang.english: 'Kadi (Link)',
          AppLang.marathi: 'कडी',
          AppLang.gujarati: 'કડી',
          AppLang.punjabi: 'ਕੜੀ',
          AppLang.bengali: 'কড়ি',
          AppLang.telugu: 'కడీ',
          AppLang.tamil: 'கடி',
          AppLang.kannada: 'ಕಡಿ',
        });
      case PlotUnit.latha:
        return pick(const {
          AppLang.hindi: 'लाठी',
          AppLang.english: 'Latha (Laggi)',
          AppLang.marathi: 'काठी',
          AppLang.gujarati: 'લાકડી',
          AppLang.punjabi: 'ਕਰਮ',
          AppLang.bengali: 'লাঠি',
          AppLang.telugu: 'లగ్గి',
          AppLang.tamil: 'லக்கி',
          AppLang.kannada: 'ಲಗ್ಗಿ',
        });
    }
  }

  // ─────────────────── 4-भुजा विषमबाहु खेत ───────────────────

  String get irrEnterFourSides => pick(const {
        AppLang.hindi: 'खेत की 4 भुजाओं की नाप डालें:',
        AppLang.english: 'Enter the 4 sides of the field:',
        AppLang.marathi: 'शेताच्या ४ बाजूंची मोजणी टाका:',
        AppLang.gujarati: 'ખેતરની ૪ બાજુઓનું માપ નાખો:',
        AppLang.punjabi: 'ਖੇਤ ਦੀਆਂ ੪ ਬਾਹੀਆਂ ਦੀ ਮਿਣਤੀ ਪਾਓ:',
        AppLang.bengali: 'জমির ৪টি বাহুর মাপ দিন:',
        AppLang.telugu: 'పొలం యొక్క 4 భుజాల కొలత ఇవ్వండి:',
        AppLang.tamil: 'நிலத்தின் 4 பக்க அளவுகளை உள்ளிடவும்:',
        AppLang.kannada: 'ಜಮೀನಿನ ೪ ಬದಿಗಳ ಅಳತೆ ಹಾಕಿ:',
      });

  String get irrSideNorth => pick(const {
        AppLang.hindi: 'A: उत्तर भुजा (North)',
        AppLang.english: 'A: North side',
        AppLang.marathi: 'A: उत्तर बाजू (North)',
        AppLang.gujarati: 'A: ઉત્તર બાજુ (North)',
        AppLang.punjabi: 'A: ਉੱਤਰ ਬਾਹੀ (North)',
        AppLang.bengali: 'A: উত্তর বাহু (North)',
        AppLang.telugu: 'A: ఉత్తర భుజం (North)',
        AppLang.tamil: 'A: வடக்குப் பக்கம் (North)',
        AppLang.kannada: 'A: ಉತ್ತರ ಬದಿ (North)',
      });

  String get irrSideEast => pick(const {
        AppLang.hindi: 'B: पूर्व भुजा (East)',
        AppLang.english: 'B: East side',
        AppLang.marathi: 'B: पूर्व बाजू (East)',
        AppLang.gujarati: 'B: પૂર્વ બાજુ (East)',
        AppLang.punjabi: 'B: ਪੂਰਬ ਬਾਹੀ (East)',
        AppLang.bengali: 'B: পূর্ব বাহু (East)',
        AppLang.telugu: 'B: తూర్పు భుజం (East)',
        AppLang.tamil: 'B: கிழக்குப் பக்கம் (East)',
        AppLang.kannada: 'B: ಪೂರ್ವ ಬದಿ (East)',
      });

  String get irrSideSouth => pick(const {
        AppLang.hindi: 'C: दक्षिण भुजा (South)',
        AppLang.english: 'C: South side',
        AppLang.marathi: 'C: दक्षिण बाजू (South)',
        AppLang.gujarati: 'C: દક્ષિણ બાજુ (South)',
        AppLang.punjabi: 'C: ਦੱਖਣ ਬਾਹੀ (South)',
        AppLang.bengali: 'C: দক্ষিণ বাহু (South)',
        AppLang.telugu: 'C: దక్షిణ భుజం (South)',
        AppLang.tamil: 'C: தெற்குப் பக்கம் (South)',
        AppLang.kannada: 'C: ದಕ್ಷಿಣ ಬದಿ (South)',
      });

  String get irrSideWest => pick(const {
        AppLang.hindi: 'D: पश्चिम भुजा (West)',
        AppLang.english: 'D: West side',
        AppLang.marathi: 'D: पश्चिम बाजू (West)',
        AppLang.gujarati: 'D: પશ્ચિમ બાજુ (West)',
        AppLang.punjabi: 'D: ਪੱਛਮ ਬਾਹੀ (West)',
        AppLang.bengali: 'D: পশ্চিম বাহু (West)',
        AppLang.telugu: 'D: పశ్చిమ భుజం (West)',
        AppLang.tamil: 'D: மேற்குப் பக்கம் (West)',
        AppLang.kannada: 'D: ಪಶ್ಚಿಮ ಬದಿ (West)',
      });

  String get irrAddDiagonal => pick(const {
        AppLang.hindi: 'विकर्ण (Diagonal / कोना से कोना नाप) जोड़ें — 100% शुद्धता के लिए',
        AppLang.english: 'Add the diagonal (corner to corner) — for a 100% exact area',
        AppLang.marathi: 'कर्ण (Diagonal / कोपऱ्यापासून कोपऱ्यापर्यंत) जोडा — १००% अचूकतेसाठी',
        AppLang.gujarati: 'વિકર્ણ (Diagonal / ખૂણેથી ખૂણા સુધી) ઉમેરો — ૧૦૦% ચોકસાઈ માટે',
        AppLang.punjabi: 'ਵਿਕਰਨ (Diagonal / ਕੋਨੇ ਤੋਂ ਕੋਨੇ ਤੱਕ) ਜੋੜੋ — ੧੦੦% ਸ਼ੁੱਧਤਾ ਲਈ',
        AppLang.bengali: 'কর্ণ (Diagonal / কোণ থেকে কোণ) যোগ করুন — ১০০% নির্ভুলতার জন্য',
        AppLang.telugu: 'కర్ణం (Diagonal / మూల నుండి మూల) జోడించండి — 100% ఖచ్చితత్వం కోసం',
        AppLang.tamil: 'மூலைவிட்டம் (Diagonal / மூலையிலிருந்து மூலை) சேர்க்கவும் — 100% துல்லியத்திற்கு',
        AppLang.kannada: 'ಕರ್ಣ (Diagonal / ಮೂಲೆಯಿಂದ ಮೂಲೆಗೆ) ಸೇರಿಸಿ — ೧೦೦% ನಿಖರತೆಗಾಗಿ',
      });

  String get irrDiagonalLabel => pick(const {
        AppLang.hindi: 'विकर्ण (Diagonal / तिरछी नाप)',
        AppLang.english: 'Diagonal measurement',
        AppLang.marathi: 'कर्ण (Diagonal / तिरकी मोजणी)',
        AppLang.gujarati: 'વિકર્ણ (Diagonal / ત્રાંસુ માપ)',
        AppLang.punjabi: 'ਵਿਕਰਨ (Diagonal / ਤਿਰਛੀ ਮਿਣਤੀ)',
        AppLang.bengali: 'কর্ণ (Diagonal / তেরছা মাপ)',
        AppLang.telugu: 'కర్ణం (Diagonal / వాలు కొలత)',
        AppLang.tamil: 'மூலைவிட்டம் (Diagonal)',
        AppLang.kannada: 'ಕರ್ಣ (Diagonal / ಓರೆ ಅಳತೆ)',
      });

  /// किसान को कौन-सा विकर्ण नापना है — गणित यही माँगता है (A-D कोना → B-C कोना)।
  String get irrDiagonalHelper => pick(const {
        AppLang.hindi: 'उत्तर-पश्चिम कोने (A-D) से दक्षिण-पूर्व कोने (B-C) तक की तिरछी नाप',
        AppLang.english: 'From the north-west corner (A-D) to the south-east corner (B-C)',
        AppLang.marathi: 'वायव्य कोपऱ्यापासून (A-D) आग्नेय कोपऱ्यापर्यंत (B-C) तिरकी मोजणी',
        AppLang.gujarati: 'ઉત્તર-પશ્ચિમ ખૂણાથી (A-D) દક્ષિણ-પૂર્વ ખૂણા (B-C) સુધીનું ત્રાંસુ માપ',
        AppLang.punjabi: 'ਉੱਤਰ-ਪੱਛਮ ਕੋਨੇ (A-D) ਤੋਂ ਦੱਖਣ-ਪੂਰਬ ਕੋਨੇ (B-C) ਤੱਕ ਦੀ ਤਿਰਛੀ ਮਿਣਤੀ',
        AppLang.bengali: 'উত্তর-পশ্চিম কোণ (A-D) থেকে দক্ষিণ-পূর্ব কোণ (B-C) পর্যন্ত তেরছা মাপ',
        AppLang.telugu: 'వాయువ్య మూల (A-D) నుండి ఆగ్నేయ మూల (B-C) వరకు వాలు కొలత',
        AppLang.tamil: 'வடமேற்கு மூலையிலிருந்து (A-D) தென்கிழக்கு மூலை (B-C) வரை',
        AppLang.kannada: 'ವಾಯುವ್ಯ ಮೂಲೆಯಿಂದ (A-D) ಆಗ್ನೇಯ ಮೂಲೆಯವರೆಗೆ (B-C) ಓರೆ ಅಳತೆ',
      });

  String get irrEnterAllSides => pick(const {
        AppLang.hindi: 'चारों भुजाओं की नाप दर्ज करें, क्षेत्रफल अपने आप निकल आएगा।',
        AppLang.english: 'Enter all four sides and the area appears automatically.',
        AppLang.marathi: 'चारही बाजूंची मोजणी टाका, क्षेत्रफळ आपोआप निघेल.',
        AppLang.gujarati: 'ચારેય બાજુઓનું માપ નાખો, ક્ષેત્રફળ આપોઆપ નીકળી આવશે.',
        AppLang.punjabi: 'ਚਾਰੇ ਬਾਹੀਆਂ ਦੀ ਮਿਣਤੀ ਪਾਓ, ਖੇਤਰਫਲ ਆਪੇ ਨਿਕਲ ਆਵੇਗਾ।',
        AppLang.bengali: 'চারটি বাহুর মাপ দিন, ক্ষেত্রফল নিজে থেকেই বেরিয়ে আসবে।',
        AppLang.telugu: 'నాలుగు భుజాల కొలత ఇవ్వండి, వైశాల్యం దానంతట అదే వస్తుంది.',
        AppLang.tamil: 'நான்கு பக்க அளவுகளையும் உள்ளிடுங்கள், பரப்பளவு தானாக வரும்.',
        AppLang.kannada: 'ನಾಲ್ಕೂ ಬದಿಗಳ ಅಳತೆ ಹಾಕಿ, ವಿಸ್ತೀರ್ಣ ತಾನಾಗಿಯೇ ಬರುತ್ತದೆ.',
      });

  String get irrExactArea => pick(const {
        AppLang.hindi: 'सटीक क्षेत्रफल (Heron\'s Formula):',
        AppLang.english: 'Exact area (Heron\'s Formula):',
        AppLang.marathi: 'अचूक क्षेत्रफळ (Heron\'s Formula):',
        AppLang.gujarati: 'ચોક્કસ ક્ષેત્રફળ (Heron\'s Formula):',
        AppLang.punjabi: 'ਸਹੀ ਖੇਤਰਫਲ (Heron\'s Formula):',
        AppLang.bengali: 'সঠিক ক্ষেত্রফল (Heron\'s Formula):',
        AppLang.telugu: 'ఖచ్చితమైన వైశాల్యం (Heron\'s Formula):',
        AppLang.tamil: 'துல்லியமான பரப்பளவு (Heron\'s Formula):',
        AppLang.kannada: 'ನಿಖರ ವಿಸ್ತೀರ್ಣ (Heron\'s Formula):',
      });

  String get irrAverageArea => pick(const {
        AppLang.hindi: 'औसत क्षेत्रफल (Average Method):',
        AppLang.english: 'Average area (Average Method):',
        AppLang.marathi: 'सरासरी क्षेत्रफळ (Average Method):',
        AppLang.gujarati: 'સરેરાશ ક્ષેત્રફળ (Average Method):',
        AppLang.punjabi: 'ਔਸਤ ਖੇਤਰਫਲ (Average Method):',
        AppLang.bengali: 'গড় ক্ষেত্রফল (Average Method):',
        AppLang.telugu: 'సగటు వైశాల్యం (Average Method):',
        AppLang.tamil: 'சராசரி பரப்பளவு (Average Method):',
        AppLang.kannada: 'ಸರಾಸರಿ ವಿಸ್ತೀರ್ಣ (Average Method):',
      });

  String irrTriangleBreakdown(String area1, String area2) => pick({
        AppLang.hindi: '(त्रिभुज 1: $area1 + त्रिभुज 2: $area2)',
        AppLang.english: '(Triangle 1: $area1 + Triangle 2: $area2)',
        AppLang.marathi: '(त्रिकोण १: $area1 + त्रिकोण २: $area2)',
        AppLang.gujarati: '(ત્રિકોણ ૧: $area1 + ત્રિકોણ ૨: $area2)',
        AppLang.punjabi: '(ਤਿਕੋਣ ੧: $area1 + ਤਿਕੋਣ ੨: $area2)',
        AppLang.bengali: '(ত্রিভুজ ১: $area1 + ত্রিভুজ ২: $area2)',
        AppLang.telugu: '(త్రిభుజం 1: $area1 + త్రిభుజం 2: $area2)',
        AppLang.tamil: '(முக்கோணம் 1: $area1 + முக்கோணம் 2: $area2)',
        AppLang.kannada: '(ತ್ರಿಕೋನ ೧: $area1 + ತ್ರಿಕೋನ ೨: $area2)',
      });

  String get irrDiagonalMismatch => pick(const {
        AppLang.hindi: 'विकर्ण (Diagonal) की माप भुजाओं से मेल नहीं खा रही है।',
        AppLang.english: 'The diagonal does not match the four sides.',
        AppLang.marathi: 'कर्णाची (Diagonal) मोजणी बाजूंशी जुळत नाही.',
        AppLang.gujarati: 'વિકર્ણ (Diagonal) નું માપ બાજુઓ સાથે મેળ ખાતું નથી.',
        AppLang.punjabi: 'ਵਿਕਰਨ (Diagonal) ਦੀ ਮਿਣਤੀ ਬਾਹੀਆਂ ਨਾਲ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ।',
        AppLang.bengali: 'কর্ণের (Diagonal) মাপ বাহুগুলির সঙ্গে মিলছে না।',
        AppLang.telugu: 'కర్ణం (Diagonal) కొలత భుజాలతో సరిపోలడం లేదు.',
        AppLang.tamil: 'மூலைவிட்ட அளவு பக்கங்களுடன் பொருந்தவில்லை.',
        AppLang.kannada: 'ಕರ್ಣದ (Diagonal) ಅಳತೆ ಬದಿಗಳಿಗೆ ಹೊಂದುತ್ತಿಲ್ಲ.',
      });

  String get irrPatwariNote => pick(const {
        AppLang.hindi:
            'पटवारी / अमीन नियम: यदि चारों भुजाएं असमान हों, तो विकर्ण (Diagonal) नापकर 2 त्रिभुज बनाकर निकालना ही 100% सही माना जाता है। विकर्ण उत्तर-पश्चिम कोने (जहाँ भुजा A और D मिलती हैं) से दक्षिण-पूर्व कोने (जहाँ भुजा B और C मिलती हैं) तक नापें — ऊपर के नक्शे में नारंगी लाइन वही है।',
        AppLang.english:
            'Patwari / Amin rule: when all four sides are unequal, the only 100% correct way is to measure the diagonal and split the field into 2 triangles. Measure the diagonal from the north-west corner (where sides A and D meet) to the south-east corner (where sides B and C meet) — that is the orange line in the sketch above.',
        AppLang.marathi:
            'तलाठी / अमीन नियम: चारही बाजू असमान असतील, तर कर्ण (Diagonal) मोजून २ त्रिकोण करून काढणे हेच १००% बरोबर मानले जाते. कर्ण वायव्य कोपऱ्यापासून (जिथे बाजू A आणि D मिळतात) आग्नेय कोपऱ्यापर्यंत (जिथे बाजू B आणि C मिळतात) मोजा — वरील नकाशातील नारंगी रेषा तीच आहे.',
        AppLang.gujarati:
            'તલાટી / અમીન નિયમ: ચારેય બાજુઓ અસમાન હોય, તો વિકર્ણ (Diagonal) માપીને ૨ ત્રિકોણ બનાવીને કાઢવું એ જ ૧૦૦% સાચું ગણાય છે. વિકર્ણ ઉત્તર-પશ્ચિમ ખૂણાથી (જ્યાં બાજુ A અને D મળે છે) દક્ષિણ-પૂર્વ ખૂણા (જ્યાં બાજુ B અને C મળે છે) સુધી માપો — ઉપરના નકશામાં નારંગી લીટી એ જ છે.',
        AppLang.punjabi:
            'ਪਟਵਾਰੀ / ਅਮੀਨ ਨਿਯਮ: ਜੇ ਚਾਰੇ ਬਾਹੀਆਂ ਅਸਾਵੀਆਂ ਹੋਣ, ਤਾਂ ਵਿਕਰਨ (Diagonal) ਮਿਣ ਕੇ ੨ ਤਿਕੋਣ ਬਣਾ ਕੇ ਕੱਢਣਾ ਹੀ ੧੦੦% ਸਹੀ ਮੰਨਿਆ ਜਾਂਦਾ ਹੈ। ਵਿਕਰਨ ਉੱਤਰ-ਪੱਛਮ ਕੋਨੇ ਤੋਂ (ਜਿੱਥੇ ਬਾਹੀ A ਅਤੇ D ਮਿਲਦੀਆਂ ਹਨ) ਦੱਖਣ-ਪੂਰਬ ਕੋਨੇ ਤੱਕ (ਜਿੱਥੇ ਬਾਹੀ B ਅਤੇ C ਮਿਲਦੀਆਂ ਹਨ) ਮਿਣੋ — ਉੱਪਰਲੇ ਨਕਸ਼ੇ ਵਿੱਚ ਸੰਤਰੀ ਲਕੀਰ ਓਹੀ ਹੈ।',
        AppLang.bengali:
            'পটোয়ারি / আমিন নিয়ম: চারটি বাহু অসমান হলে, কর্ণ (Diagonal) মেপে ২টি ত্রিভুজ বানিয়ে বের করাই ১০০% সঠিক ধরা হয়। কর্ণ উত্তর-পশ্চিম কোণ (যেখানে বাহু A ও D মেলে) থেকে দক্ষিণ-পূর্ব কোণ (যেখানে বাহু B ও C মেলে) পর্যন্ত মাপুন — উপরের নকশায় কমলা রেখাটিই সেটি।',
        AppLang.telugu:
            'పట్వారీ / అమీన్ నియమం: నాలుగు భుజాలూ అసమానంగా ఉంటే, కర్ణం (Diagonal) కొలిచి 2 త్రిభుజాలుగా విడగొట్టడమే 100% సరైనదిగా భావిస్తారు. కర్ణాన్ని వాయువ్య మూల (భుజాలు A, D కలిసే చోటు) నుండి ఆగ్నేయ మూల (భుజాలు B, C కలిసే చోటు) వరకు కొలవండి — పై చిత్రంలోని నారింజ గీత అదే.',
        AppLang.tamil:
            'பட்வாரி / அமீன் விதி: நான்கு பக்கங்களும் சமமற்றதாக இருந்தால், மூலைவிட்டத்தை அளந்து 2 முக்கோணங்களாகப் பிரிப்பதே 100% சரியானதாகக் கருதப்படுகிறது. மூலைவிட்டத்தை வடமேற்கு மூலையிலிருந்து (பக்கங்கள் A மற்றும் D சந்திக்கும் இடம்) தென்கிழக்கு மூலை வரை (பக்கங்கள் B மற்றும் C சந்திக்கும் இடம்) அளக்கவும் — மேலே உள்ள படத்தில் ஆரஞ்சு கோடு அதுவே.',
        AppLang.kannada:
            'ಪಟ್ವಾರಿ / ಅಮೀನ್ ನಿಯಮ: ನಾಲ್ಕೂ ಬದಿಗಳು ಅಸಮವಾಗಿದ್ದರೆ, ಕರ್ಣವನ್ನು (Diagonal) ಅಳೆದು ೨ ತ್ರಿಕೋನಗಳಾಗಿ ಒಡೆದು ಲೆಕ್ಕ ಹಾಕುವುದೇ ೧೦೦% ಸರಿ ಎಂದು ಪರಿಗಣಿಸಲಾಗುತ್ತದೆ. ಕರ್ಣವನ್ನು ವಾಯುವ್ಯ ಮೂಲೆಯಿಂದ (ಬದಿ A ಮತ್ತು D ಸೇರುವ ಸ್ಥಳ) ಆಗ್ನೇಯ ಮೂಲೆಯವರೆಗೆ (ಬದಿ B ಮತ್ತು C ಸೇರುವ ಸ್ಥಳ) ಅಳೆಯಿರಿ — ಮೇಲಿನ ನಕ್ಷೆಯಲ್ಲಿನ ಕಿತ್ತಳೆ ಗೆರೆ ಅದೇ.',
      });

  String get irrShareTitle => pick(const {
        AppLang.hindi: '🌾 4-भुजा विषमबाहु खेत नापी विवरण 🌾',
        AppLang.english: '🌾 4-sided irregular field measurement 🌾',
        AppLang.marathi: '🌾 ४-बाजूंच्या विषमबाहू शेताची मोजणी 🌾',
        AppLang.gujarati: '🌾 ૪-બાજુના અનિયમિત ખેતરનું માપ 🌾',
        AppLang.punjabi: '🌾 ੪-ਭੁਜਾਵੀਂ ਅਸਾਵੇਂ ਖੇਤ ਦੀ ਮਿਣਤੀ 🌾',
        AppLang.bengali: '🌾 ৪-বাহু অসম জমির পরিমাপ 🌾',
        AppLang.telugu: '🌾 4 భుజాల అసమాన పొలం కొలత 🌾',
        AppLang.tamil: '🌾 4 பக்க ஒழுங்கற்ற நில அளவீடு 🌾',
        AppLang.kannada: '🌾 ೪-ಬದಿಗಳ ಅಸಮ ಜಮೀನಿನ ಅಳತೆ 🌾',
      });

  String get irrShareExact => pick(const {
        AppLang.hindi: '✅ सटीक कुल क्षेत्रफल (Heron सूत्र)',
        AppLang.english: '✅ Exact total area (Heron\'s formula)',
        AppLang.marathi: '✅ अचूक एकूण क्षेत्रफळ (Heron सूत्र)',
        AppLang.gujarati: '✅ ચોક્કસ કુલ ક્ષેત્રફળ (Heron સૂત્ર)',
        AppLang.punjabi: '✅ ਸਹੀ ਕੁੱਲ ਖੇਤਰਫਲ (Heron ਸੂਤਰ)',
        AppLang.bengali: '✅ সঠিক মোট ক্ষেত্রফল (Heron সূত্র)',
        AppLang.telugu: '✅ ఖచ్చితమైన మొత్తం వైశాల్యం (Heron సూత్రం)',
        AppLang.tamil: '✅ துல்லியமான மொத்தப் பரப்பளவு (Heron சூத்திரம்)',
        AppLang.kannada: '✅ ನಿಖರ ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ (Heron ಸೂತ್ರ)',
      });

  String get irrShareAverage => pick(const {
        AppLang.hindi: '📊 औसत कुल क्षेत्रफल',
        AppLang.english: '📊 Average total area',
        AppLang.marathi: '📊 सरासरी एकूण क्षेत्रफळ',
        AppLang.gujarati: '📊 સરેરાશ કુલ ક્ષેત્રફળ',
        AppLang.punjabi: '📊 ਔਸਤ ਕੁੱਲ ਖੇਤਰਫਲ',
        AppLang.bengali: '📊 গড় মোট ক্ষেত্রফল',
        AppLang.telugu: '📊 సగటు మొత్తం వైశాల్యం',
        AppLang.tamil: '📊 சராசரி மொத்தப் பரப்பளவு',
        AppLang.kannada: '📊 ಸರಾಸರಿ ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ',
      });

  // ──────────────────────── जमीन बंटवारा ────────────────────────

  String get batEqualMode => pick(const {
        AppLang.hindi: 'बराबर बंटवारा',
        AppLang.english: 'Equal split',
        AppLang.marathi: 'समान वाटप',
        AppLang.gujarati: 'સરખી વહેંચણી',
        AppLang.punjabi: 'ਬਰਾਬਰ ਵੰਡ',
        AppLang.bengali: 'সমান ভাগ',
        AppLang.telugu: 'సమాన పంపకం',
        AppLang.tamil: 'சமப் பங்கீடு',
        AppLang.kannada: 'ಸಮಾನ ಹಂಚಿಕೆ',
      });

  String get batCustomMode => pick(const {
        AppLang.hindi: 'अलग-अलग हिस्सा',
        AppLang.english: 'Custom shares',
        AppLang.marathi: 'वेगवेगळा हिस्सा',
        AppLang.gujarati: 'અલગ-અલગ હિસ્સો',
        AppLang.punjabi: 'ਵੱਖ-ਵੱਖ ਹਿੱਸਾ',
        AppLang.bengali: 'আলাদা অংশ',
        AppLang.telugu: 'వేర్వేరు వాటా',
        AppLang.tamil: 'வெவ்வேறு பங்கு',
        AppLang.kannada: 'ಬೇರೆ ಬೇರೆ ಪಾಲು',
      });

  String get batTotalLandDetails => pick(const {
        AppLang.hindi: 'कुल जमीन का विवरण:',
        AppLang.english: 'Total land details:',
        AppLang.marathi: 'एकूण जमिनीचा तपशील:',
        AppLang.gujarati: 'કુલ જમીનની વિગત:',
        AppLang.punjabi: 'ਕੁੱਲ ਜ਼ਮੀਨ ਦਾ ਵੇਰਵਾ:',
        AppLang.bengali: 'মোট জমির বিবরণ:',
        AppLang.telugu: 'మొత్తం భూమి వివరాలు:',
        AppLang.tamil: 'மொத்த நில விவரம்:',
        AppLang.kannada: 'ಒಟ್ಟು ಜಮೀನಿನ ವಿವರ:',
      });

  String get batEnterTotalArea => pick(const {
        AppLang.hindi: 'कुल रकबा दर्ज करें',
        AppLang.english: 'Enter total area',
        AppLang.marathi: 'एकूण क्षेत्र टाका',
        AppLang.gujarati: 'કુલ રકબો દાખલ કરો',
        AppLang.punjabi: 'ਕੁੱਲ ਰਕਬਾ ਭਰੋ',
        AppLang.bengali: 'মোট জমির পরিমাণ দিন',
        AppLang.telugu: 'మొత్తం విస్తీర్ణం ఇవ్వండి',
        AppLang.tamil: 'மொத்த பரப்பளவை உள்ளிடவும்',
        AppLang.kannada: 'ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ ನಮೂದಿಸಿ',
      });

  String get batPartnerCount => pick(const {
        AppLang.hindi: 'बराबर हिस्सेदारों की संख्या:',
        AppLang.english: 'Number of equal shareholders:',
        AppLang.marathi: 'समान वाटेकऱ्यांची संख्या:',
        AppLang.gujarati: 'સરખા ભાગીદારોની સંખ્યા:',
        AppLang.punjabi: 'ਬਰਾਬਰ ਹਿੱਸੇਦਾਰਾਂ ਦੀ ਗਿਣਤੀ:',
        AppLang.bengali: 'সমান অংশীদারের সংখ্যা:',
        AppLang.telugu: 'సమాన వాటాదారుల సంఖ్య:',
        AppLang.tamil: 'சமபங்குதாரர்களின் எண்ணிக்கை:',
        AppLang.kannada: 'ಸಮಾನ ಪಾಲುದಾರರ ಸಂಖ್ಯೆ:',
      });

  String get batPartnerFieldLabel => pick(const {
        AppLang.hindi: 'हिस्सेदार (भाई / पार्टनर)',
        AppLang.english: 'Shareholders (brothers / partners)',
        AppLang.marathi: 'वाटेकरी (भाऊ / भागीदार)',
        AppLang.gujarati: 'ભાગીદાર (ભાઈ / પાર્ટનર)',
        AppLang.punjabi: 'ਹਿੱਸੇਦਾਰ (ਭਰਾ / ਪਾਰਟਨਰ)',
        AppLang.bengali: 'অংশীদার (ভাই / পার্টনার)',
        AppLang.telugu: 'వాటాదారులు (సోదరులు / భాగస్వాములు)',
        AppLang.tamil: 'பங்குதாரர் (சகோதரர் / கூட்டாளி)',
        AppLang.kannada: 'ಪಾಲುದಾರರು (ಸಹೋದರ / ಪಾಲುದಾರ)',
      });

  String get batPeopleSuffix => pick(const {
        AppLang.hindi: 'लोग',
        AppLang.english: 'people',
        AppLang.marathi: 'लोक',
        AppLang.gujarati: 'લોકો',
        AppLang.punjabi: 'ਜਣੇ',
        AppLang.bengali: 'জন',
        AppLang.telugu: 'మంది',
        AppLang.tamil: 'பேர்',
        AppLang.kannada: 'ಜನ',
      });

  String batShareChip(int n) => pick({
        AppLang.hindi: '$n हिस्से',
        AppLang.english: '$n shares',
        AppLang.marathi: '$n हिस्से',
        AppLang.gujarati: '$n હિસ્સા',
        AppLang.punjabi: '$n ਹਿੱਸੇ',
        AppLang.bengali: '$n ভাগ',
        AppLang.telugu: '$n వాటాలు',
        AppLang.tamil: '$n பங்குகள்',
        AppLang.kannada: '$n ಪಾಲುಗಳು',
      });

  String get batRatioHeading => pick(const {
        AppLang.hindi: 'हिस्सेदारों का अनुपात / शेयर:',
        AppLang.english: 'Shareholder ratios:',
        AppLang.marathi: 'वाटेकऱ्यांचे प्रमाण / शेअर:',
        AppLang.gujarati: 'ભાગીદારોનો ગુણોત્તર / શેર:',
        AppLang.punjabi: 'ਹਿੱਸੇਦਾਰਾਂ ਦਾ ਅਨੁਪਾਤ / ਸ਼ੇਅਰ:',
        AppLang.bengali: 'অংশীদারদের অনুপাত / শেয়ার:',
        AppLang.telugu: 'వాటాదారుల నిష్పత్తి / షేర్:',
        AppLang.tamil: 'பங்குதாரர்களின் விகிதம் / பங்கு:',
        AppLang.kannada: 'ಪಾಲುದಾರರ ಅನುಪಾತ / ಷೇರು:',
      });

  String get batAdd => pick(const {
        AppLang.hindi: 'जोड़ें',
        AppLang.english: 'Add',
        AppLang.marathi: 'जोडा',
        AppLang.gujarati: 'ઉમેરો',
        AppLang.punjabi: 'ਜੋੜੋ',
        AppLang.bengali: 'যোগ করুন',
        AppLang.telugu: 'జోడించండి',
        AppLang.tamil: 'சேர்',
        AppLang.kannada: 'ಸೇರಿಸಿ',
      });

  String batNameLabel(int index) => pick({
        AppLang.hindi: 'नाम #$index',
        AppLang.english: 'Name #$index',
        AppLang.marathi: 'नाव #$index',
        AppLang.gujarati: 'નામ #$index',
        AppLang.punjabi: 'ਨਾਮ #$index',
        AppLang.bengali: 'নাম #$index',
        AppLang.telugu: 'పేరు #$index',
        AppLang.tamil: 'பெயர் #$index',
        AppLang.kannada: 'ಹೆಸರು #$index',
      });

  String get batRatioLabel => pick(const {
        AppLang.hindi: 'अनुपात / भाग',
        AppLang.english: 'Ratio / share',
        AppLang.marathi: 'प्रमाण / भाग',
        AppLang.gujarati: 'ગુણોત્તર / ભાગ',
        AppLang.punjabi: 'ਅਨੁਪਾਤ / ਭਾਗ',
        AppLang.bengali: 'অনুপাত / ভাগ',
        AppLang.telugu: 'నిష్పత్తి / భాగం',
        AppLang.tamil: 'விகிதம் / பங்கு',
        AppLang.kannada: 'ಅನುಪಾತ / ಭಾಗ',
      });

  String batPartnerDefaultName(int index) => pick({
        AppLang.hindi: 'हिस्सेदार $index',
        AppLang.english: 'Shareholder $index',
        AppLang.marathi: 'वाटेकरी $index',
        AppLang.gujarati: 'ભાગીદાર $index',
        AppLang.punjabi: 'ਹਿੱਸੇਦਾਰ $index',
        AppLang.bengali: 'অংশীদার $index',
        AppLang.telugu: 'వాటాదారు $index',
        AppLang.tamil: 'பங்குதாரர் $index',
        AppLang.kannada: 'ಪಾಲುದಾರ $index',
      });

  String get batEnterAreaFirst => pick(const {
        AppLang.hindi: 'ऊपर कुल रकबा दर्ज करें, बंटवारा अपने आप निकल आएगा।',
        AppLang.english: 'Enter the total area above and the split appears automatically.',
        AppLang.marathi: 'वर एकूण क्षेत्र टाका, वाटप आपोआप निघेल.',
        AppLang.gujarati: 'ઉપર કુલ રકબો દાખલ કરો, વહેંચણી આપોઆપ નીકળી આવશે.',
        AppLang.punjabi: 'ਉੱਪਰ ਕੁੱਲ ਰਕਬਾ ਭਰੋ, ਵੰਡ ਆਪੇ ਨਿਕਲ ਆਵੇਗੀ।',
        AppLang.bengali: 'উপরে মোট জমি দিন, ভাগ নিজে থেকেই বেরিয়ে আসবে।',
        AppLang.telugu: 'పైన మొత్తం విస్తీర్ణం ఇవ్వండి, పంపకం దానంతట అదే వస్తుంది.',
        AppLang.tamil: 'மேலே மொத்தப் பரப்பளவை உள்ளிடுங்கள், பங்கீடு தானாக வரும்.',
        AppLang.kannada: 'ಮೇಲೆ ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ ಹಾಕಿ, ಹಂಚಿಕೆ ತಾನಾಗಿಯೇ ಬರುತ್ತದೆ.',
      });

  String batEachShare(int count) => pick({
        AppLang.hindi: 'प्रत्येक हिस्सेदार का हिस्सा ($count लोग):',
        AppLang.english: 'Each shareholder\'s share ($count people):',
        AppLang.marathi: 'प्रत्येक वाटेकऱ्याचा हिस्सा ($count लोक):',
        AppLang.gujarati: 'દરેક ભાગીદારનો હિસ્સો ($count લોકો):',
        AppLang.punjabi: 'ਹਰ ਹਿੱਸੇਦਾਰ ਦਾ ਹਿੱਸਾ ($count ਜਣੇ):',
        AppLang.bengali: 'প্রত্যেক অংশীদারের ভাগ ($count জন):',
        AppLang.telugu: 'ప్రతి వాటాదారుని వాటా ($count మంది):',
        AppLang.tamil: 'ஒவ்வொரு பங்குதாரரின் பங்கு ($count பேர்):',
        AppLang.kannada: 'ಪ್ರತಿ ಪಾಲುದಾರರ ಪಾಲು ($count ಜನ):',
      });

  String batEachShareInState(String state) => pick({
        AppLang.hindi: 'प्रत्येक हिस्सेदार का राज्यवार मान ($state):',
        AppLang.english: 'Each share in $state units:',
        AppLang.marathi: 'प्रत्येक वाटेकऱ्याचे राज्यानुसार मूल्य ($state):',
        AppLang.gujarati: 'દરેક ભાગીદારનું રાજ્ય મુજબ મૂલ્ય ($state):',
        AppLang.punjabi: 'ਹਰ ਹਿੱਸੇਦਾਰ ਦਾ ਰਾਜ ਅਨੁਸਾਰ ਮੁੱਲ ($state):',
        AppLang.bengali: 'প্রত্যেক ভাগের রাজ্য অনুযায়ী মান ($state):',
        AppLang.telugu: 'ప్రతి వాటా రాష్ట్రం ప్రకారం విలువ ($state):',
        AppLang.tamil: 'ஒவ்வொரு பங்கின் மாநில அலகு மதிப்பு ($state):',
        AppLang.kannada: 'ಪ್ರತಿ ಪಾಲಿನ ರಾಜ್ಯವಾರು ಮೌಲ್ಯ ($state):',
      });

  String get batFinalShares => pick(const {
        AppLang.hindi: 'सभी हिस्सेदारों का अंतिम रकबा:',
        AppLang.english: 'Final area for every shareholder:',
        AppLang.marathi: 'सर्व वाटेकऱ्यांचे अंतिम क्षेत्र:',
        AppLang.gujarati: 'બધા ભાગીદારોનો આખરી રકબો:',
        AppLang.punjabi: 'ਸਾਰੇ ਹਿੱਸੇਦਾਰਾਂ ਦਾ ਆਖ਼ਰੀ ਰਕਬਾ:',
        AppLang.bengali: 'সব অংশীদারের চূড়ান্ত জমি:',
        AppLang.telugu: 'అందరి వాటాదారుల తుది విస్తీర్ణం:',
        AppLang.tamil: 'அனைத்துப் பங்குதாரர்களின் இறுதிப் பரப்பளவு:',
        AppLang.kannada: 'ಎಲ್ಲಾ ಪಾಲುದಾರರ ಅಂತಿಮ ವಿಸ್ತೀರ್ಣ:',
      });

  String batPercentShare(String pct) => pick({
        AppLang.hindi: '$pct% हिस्सा',
        AppLang.english: '$pct% share',
        AppLang.marathi: '$pct% हिस्सा',
        AppLang.gujarati: '$pct% હિસ્સો',
        AppLang.punjabi: '$pct% ਹਿੱਸਾ',
        AppLang.bengali: '$pct% ভাগ',
        AppLang.telugu: '$pct% వాటా',
        AppLang.tamil: '$pct% பங்கு',
        AppLang.kannada: '$pct% ಪಾಲು',
      });

  String get batShareTitle => pick(const {
        AppLang.hindi: '🤝 जमीन बंटवारा विवरण',
        AppLang.english: '🤝 Land partition report',
        AppLang.marathi: '🤝 जमीन वाटप तपशील',
        AppLang.gujarati: '🤝 જમીન વહેંચણી વિગત',
        AppLang.punjabi: '🤝 ਜ਼ਮੀਨ ਵੰਡ ਵੇਰਵਾ',
        AppLang.bengali: '🤝 জমি বণ্টনের বিবরণ',
        AppLang.telugu: '🤝 భూమి పంపకం వివరాలు',
        AppLang.tamil: '🤝 நிலப் பகிர்வு அறிக்கை',
        AppLang.kannada: '🤝 ಜಮೀನು ಹಂಚಿಕೆ ವಿವರ',
      });

  String get batShareTotalArea => pick(const {
        AppLang.hindi: 'कुल रकबा',
        AppLang.english: 'Total area',
        AppLang.marathi: 'एकूण क्षेत्र',
        AppLang.gujarati: 'કુલ રકબો',
        AppLang.punjabi: 'ਕੁੱਲ ਰਕਬਾ',
        AppLang.bengali: 'মোট জমি',
        AppLang.telugu: 'మొత్తం విస్తీర్ణం',
        AppLang.tamil: 'மொத்தப் பரப்பளவு',
        AppLang.kannada: 'ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ',
      });

  String batShareEqualLine(int count) => pick({
        AppLang.hindi: 'कुल हिस्सेदार: $count (बराबर हिस्सा)',
        AppLang.english: 'Shareholders: $count (equal shares)',
        AppLang.marathi: 'एकूण वाटेकरी: $count (समान हिस्सा)',
        AppLang.gujarati: 'કુલ ભાગીદાર: $count (સરખો હિસ્સો)',
        AppLang.punjabi: 'ਕੁੱਲ ਹਿੱਸੇਦਾਰ: $count (ਬਰਾਬਰ ਹਿੱਸਾ)',
        AppLang.bengali: 'মোট অংশীদার: $count (সমান ভাগ)',
        AppLang.telugu: 'మొత్తం వాటాదారులు: $count (సమాన వాటా)',
        AppLang.tamil: 'மொத்தப் பங்குதாரர்: $count (சமப் பங்கு)',
        AppLang.kannada: 'ಒಟ್ಟು ಪಾಲುದಾರರು: $count (ಸಮಾನ ಪಾಲು)',
      });

  String get batShareEachGets => pick(const {
        AppLang.hindi: 'प्रत्येक हिस्सेदार का रकबा:',
        AppLang.english: 'Area for each shareholder:',
        AppLang.marathi: 'प्रत्येक वाटेकऱ्याचे क्षेत्र:',
        AppLang.gujarati: 'દરેક ભાગીદારનો રકબો:',
        AppLang.punjabi: 'ਹਰ ਹਿੱਸੇਦਾਰ ਦਾ ਰਕਬਾ:',
        AppLang.bengali: 'প্রত্যেক অংশীদারের জমি:',
        AppLang.telugu: 'ప్రతి వాటాదారుని విస్తీర్ణం:',
        AppLang.tamil: 'ஒவ்வொரு பங்குதாரரின் பரப்பளவு:',
        AppLang.kannada: 'ಪ್ರತಿ ಪಾಲುದಾರರ ವಿಸ್ತೀರ್ಣ:',
      });

  String get batShareRatioWise => pick(const {
        AppLang.hindi: 'हिस्सेदारों का विवरण (अनुपात अनुसार):',
        AppLang.english: 'Shareholder details (by ratio):',
        AppLang.marathi: 'वाटेकऱ्यांचा तपशील (प्रमाणानुसार):',
        AppLang.gujarati: 'ભાગીદારોની વિગત (ગુણોત્તર મુજબ):',
        AppLang.punjabi: 'ਹਿੱਸੇਦਾਰਾਂ ਦਾ ਵੇਰਵਾ (ਅਨੁਪਾਤ ਅਨੁਸਾਰ):',
        AppLang.bengali: 'অংশীদারদের বিবরণ (অনুপাত অনুযায়ী):',
        AppLang.telugu: 'వాటాదారుల వివరాలు (నిష్పత్తి ప్రకారం):',
        AppLang.tamil: 'பங்குதாரர் விவரம் (விகிதப்படி):',
        AppLang.kannada: 'ಪಾಲುದಾರರ ವಿವರ (ಅನುಪಾತದಂತೆ):',
      });

  String batShareRatioWord(String ratio) => pick({
        AppLang.hindi: 'हिस्सा: $ratio',
        AppLang.english: 'share: $ratio',
        AppLang.marathi: 'हिस्सा: $ratio',
        AppLang.gujarati: 'હિસ્સો: $ratio',
        AppLang.punjabi: 'ਹਿੱਸਾ: $ratio',
        AppLang.bengali: 'ভাগ: $ratio',
        AppLang.telugu: 'వాటా: $ratio',
        AppLang.tamil: 'பங்கு: $ratio',
        AppLang.kannada: 'ಪಾಲು: $ratio',
      });

  // ──────────────────────── लग्गी पैमाना ────────────────────────

  String get lagChooseLaggi => pick(const {
        AppLang.hindi: 'अपने क्षेत्र / गांव की लग्गी (हाथ) चुनें:',
        AppLang.english: 'Choose your village\'s laggi length (in haath):',
        AppLang.marathi: 'आपल्या गावाची काठी (हात) निवडा:',
        AppLang.gujarati: 'તમારા ગામની લગ્ગી (હાથ) પસંદ કરો:',
        AppLang.punjabi: 'ਆਪਣੇ ਪਿੰਡ ਦੀ ਲੱਗੀ (ਹੱਥ) ਚੁਣੋ:',
        AppLang.bengali: 'আপনার গ্রামের লাঘি (হাত) বেছে নিন:',
        AppLang.telugu: 'మీ గ్రామపు లగ్గి (చేతులు) ఎంచుకోండి:',
        AppLang.tamil: 'உங்கள் ஊரின் லக்கி (கை) அளவைத் தேர்ந்தெடுக்கவும்:',
        AppLang.kannada: 'ನಿಮ್ಮ ಊರಿನ ಲಗ್ಗಿ (ಕೈ) ಆರಿಸಿ:',
      });

  String get lagHaathNote => pick(const {
        AppLang.hindi: 'नोट: 1 हाथ = 1.5 फीट = 18 इंच होता है। (1 धुर = लग्गी × लग्गी)',
        AppLang.english: 'Note: 1 haath = 1.5 feet = 18 inches. (1 dhur = laggi × laggi)',
        AppLang.marathi: 'टीप: १ हात = १.५ फूट = १८ इंच. (१ धूर = काठी × काठी)',
        AppLang.gujarati: 'નોંધ: ૧ હાથ = ૧.૫ ફૂટ = ૧૮ ઇંચ. (૧ ધૂર = લગ્ગી × લગ્ગી)',
        AppLang.punjabi: 'ਨੋਟ: ੧ ਹੱਥ = ੧.੫ ਫੁੱਟ = ੧੮ ਇੰਚ। (੧ ਧੁਰ = ਲੱਗੀ × ਲੱਗੀ)',
        AppLang.bengali: 'দ্রষ্টব্য: ১ হাত = ১.৫ ফুট = ১৮ ইঞ্চি। (১ ধুর = লাঘি × লাঘি)',
        AppLang.telugu: 'గమనిక: 1 చేయి = 1.5 అడుగులు = 18 అంగుళాలు. (1 ధూర్ = లగ్గి × లగ్గి)',
        AppLang.tamil: 'குறிப்பு: 1 கை = 1.5 அடி = 18 அங்குலம். (1 துர் = லக்கி × லக்கி)',
        AppLang.kannada: 'ಸೂಚನೆ: ೧ ಕೈ = ೧.೫ ಅಡಿ = ೧೮ ಇಂಚು. (೧ ಧುರ್ = ಲಗ್ಗಿ × ಲಗ್ಗಿ)',
      });

  String lagHaathChip(String haath) => pick({
        AppLang.hindi: '$haath हाथ',
        AppLang.english: '$haath haath',
        AppLang.marathi: '$haath हात',
        AppLang.gujarati: '$haath હાથ',
        AppLang.punjabi: '$haath ਹੱਥ',
        AppLang.bengali: '$haath হাত',
        AppLang.telugu: '$haath చేతులు',
        AppLang.tamil: '$haath கை',
        AppLang.kannada: '$haath ಕೈ',
      });

  String get lagCustomHaath => pick(const {
        AppLang.hindi: 'अन्य हाथ मान दर्ज करें',
        AppLang.english: 'Enter another haath value',
        AppLang.marathi: 'दुसरे हात मूल्य टाका',
        AppLang.gujarati: 'બીજું હાથ મૂલ્ય દાખલ કરો',
        AppLang.punjabi: 'ਹੋਰ ਹੱਥ ਮੁੱਲ ਭਰੋ',
        AppLang.bengali: 'অন্য হাতের মান দিন',
        AppLang.telugu: 'వేరే చేతుల విలువ ఇవ్వండి',
        AppLang.tamil: 'வேறு கை அளவை உள்ளிடவும்',
        AppLang.kannada: 'ಬೇರೆ ಕೈ ಮೌಲ್ಯ ನಮೂದಿಸಿ',
      });

  String get lagHaathSuffix => pick(const {
        AppLang.hindi: 'हाथ',
        AppLang.english: 'haath',
        AppLang.marathi: 'हात',
        AppLang.gujarati: 'હાથ',
        AppLang.punjabi: 'ਹੱਥ',
        AppLang.bengali: 'হাত',
        AppLang.telugu: 'చేతులు',
        AppLang.tamil: 'கை',
        AppLang.kannada: 'ಕೈ',
      });

  String lagTotalLength(String haath) => pick({
        AppLang.hindi: '$haath हाथ की लग्गी की कुल लंबाई:',
        AppLang.english: 'Total length of a $haath-haath laggi:',
        AppLang.marathi: '$haath हात काठीची एकूण लांबी:',
        AppLang.gujarati: '$haath હાથની લગ્ગીની કુલ લંબાઈ:',
        AppLang.punjabi: '$haath ਹੱਥ ਦੀ ਲੱਗੀ ਦੀ ਕੁੱਲ ਲੰਬਾਈ:',
        AppLang.bengali: '$haath হাত লাঘির মোট দৈর্ঘ্য:',
        AppLang.telugu: '$haath చేతుల లగ్గి మొత్తం పొడవు:',
        AppLang.tamil: '$haath கை லக்கியின் மொத்த நீளம்:',
        AppLang.kannada: '$haath ಕೈ ಲಗ್ಗಿಯ ಒಟ್ಟು ಉದ್ದ:',
      });

  String lagAllUnits(String haath) => pick({
        AppLang.hindi: '$haath हाथ की लग्गी से सभी मानक इकाइयां:',
        AppLang.english: 'All standard units for a $haath-haath laggi:',
        AppLang.marathi: '$haath हात काठीनुसार सर्व प्रमाणित एकके:',
        AppLang.gujarati: '$haath હાથની લગ્ગી પ્રમાણે બધા માનક એકમો:',
        AppLang.punjabi: '$haath ਹੱਥ ਦੀ ਲੱਗੀ ਨਾਲ ਸਾਰੀਆਂ ਮਿਆਰੀ ਇਕਾਈਆਂ:',
        AppLang.bengali: '$haath হাত লাঘি অনুসারে সব আদর্শ একক:',
        AppLang.telugu: '$haath చేతుల లగ్గి ప్రకారం అన్ని ప్రామాణిక యూనిట్లు:',
        AppLang.tamil: '$haath கை லக்கியின்படி அனைத்து நிலையான அலகுகள்:',
        AppLang.kannada: '$haath ಕೈ ಲಗ್ಗಿಯ ಪ್ರಕಾರ ಎಲ್ಲಾ ಪ್ರಮಾಣಿತ ಘಟಕಗಳು:',
      });

  String get lagAminFormula => pick(const {
        AppLang.hindi:
            'अमीन सूत्र: लग्गी को फीट में बदलने के लिए (हाथ × 1.5) करें। फिर उसका वर्ग करने पर 1 धुर का वर्ग फीट क्षेत्रफल प्राप्त होता है। (1 कट्ठा = 20 धुर, 1 बीघा = 20 कट्ठा = 400 धुर)',
        AppLang.english:
            'Amin\'s rule: convert the laggi to feet with (haath × 1.5), then square it to get 1 dhur in square feet. (1 katha = 20 dhur, 1 bigha = 20 katha = 400 dhur)',
        AppLang.marathi:
            'अमीन सूत्र: काठी फुटात बदलण्यासाठी (हात × १.५) करा. मग त्याचा वर्ग केल्यास १ धूरचे चौरस फूट क्षेत्रफळ मिळते. (१ कट्ठा = २० धूर, १ बीघा = २० कट्ठा = ४०० धूर)',
        AppLang.gujarati:
            'અમીન સૂત્ર: લગ્ગીને ફૂટમાં બદલવા (હાથ × ૧.૫) કરો. પછી તેનો વર્ગ કરવાથી ૧ ધૂરનું ચોરસ ફૂટ ક્ષેત્રફળ મળે છે. (૧ કઠ્ઠા = ૨૦ ધૂર, ૧ વીઘા = ૨૦ કઠ્ઠા = ૪૦૦ ધૂર)',
        AppLang.punjabi:
            'ਅਮੀਨ ਸੂਤਰ: ਲੱਗੀ ਨੂੰ ਫੁੱਟ ਵਿੱਚ ਬਦਲਣ ਲਈ (ਹੱਥ × ੧.੫) ਕਰੋ। ਫਿਰ ਉਸ ਦਾ ਵਰਗ ਕਰਨ ਨਾਲ ੧ ਧੁਰ ਦਾ ਵਰਗ ਫੁੱਟ ਖੇਤਰਫਲ ਮਿਲਦਾ ਹੈ। (੧ ਕੱਠਾ = ੨੦ ਧੁਰ, ੧ ਬੀਘਾ = ੨੦ ਕੱਠਾ = ੪੦੦ ਧੁਰ)',
        AppLang.bengali:
            'আমিন সূত্র: লাঘিকে ফুটে বদলাতে (হাত × ১.৫) করুন। তারপর তার বর্গ করলে ১ ধুরের বর্গ ফুট ক্ষেত্রফল পাওয়া যায়। (১ কাঠা = ২০ ধুর, ১ বিঘা = ২০ কাঠা = ৪০০ ধুর)',
        AppLang.telugu:
            'అమీన్ సూత్రం: లగ్గిని అడుగుల్లోకి మార్చడానికి (చేతులు × 1.5) చేయండి. దాన్ని వర్గం చేస్తే 1 ధూర్ చదరపు అడుగుల విస్తీర్ణం వస్తుంది. (1 కట్టా = 20 ధూర్, 1 బీగా = 20 కట్టా = 400 ధూర్)',
        AppLang.tamil:
            'அமீன் விதி: லக்கியை அடியாக மாற்ற (கை × 1.5) செய்யவும். பின் அதை வர்க்கம் செய்தால் 1 துர்-இன் சதுர அடி பரப்பளவு கிடைக்கும். (1 கத்தா = 20 துர், 1 பீகா = 20 கத்தா = 400 துர்)',
        AppLang.kannada:
            'ಅಮೀನ್ ಸೂತ್ರ: ಲಗ್ಗಿಯನ್ನು ಅಡಿಗೆ ಬದಲಿಸಲು (ಕೈ × ೧.೫) ಮಾಡಿ. ನಂತರ ಅದರ ವರ್ಗ ಮಾಡಿದರೆ ೧ ಧುರ್‌ನ ಚದರ ಅಡಿ ವಿಸ್ತೀರ್ಣ ಸಿಗುತ್ತದೆ. (೧ ಕಟ್ಠಾ = ೨೦ ಧುರ್, ೧ ಬೀಘಾ = ೨೦ ಕಟ್ಠಾ = ೪೦೦ ಧುರ್)',
      });

  String get lagShareTitle => pick(const {
        AppLang.hindi: '🪵 लग्गी पैमाना विवरण',
        AppLang.english: '🪵 Laggi scale details',
        AppLang.marathi: '🪵 काठी मापाचा तपशील',
        AppLang.gujarati: '🪵 લગ્ગી માપની વિગત',
        AppLang.punjabi: '🪵 ਲੱਗੀ ਪੈਮਾਨੇ ਦਾ ਵੇਰਵਾ',
        AppLang.bengali: '🪵 লাঘি মাপকাঠির বিবরণ',
        AppLang.telugu: '🪵 లగ్గి కొలత వివరాలు',
        AppLang.tamil: '🪵 லக்கி அளவுகோல் விவரம்',
        AppLang.kannada: '🪵 ಲಗ್ಗಿ ಅಳತೆ ವಿವರ',
      });

  String get lagShareLength => pick(const {
        AppLang.hindi: 'लग्गी की लंबाई',
        AppLang.english: 'Laggi length',
        AppLang.marathi: 'काठीची लांबी',
        AppLang.gujarati: 'લગ્ગીની લંબાઈ',
        AppLang.punjabi: 'ਲੱਗੀ ਦੀ ਲੰਬਾਈ',
        AppLang.bengali: 'লাঘির দৈর্ঘ্য',
        AppLang.telugu: 'లగ్గి పొడవు',
        AppLang.tamil: 'லக்கியின் நீளம்',
        AppLang.kannada: 'ಲಗ್ಗಿಯ ಉದ್ದ',
      });

  String get lagInAcre => pick(const {
        AppLang.hindi: '1 एकड़ में',
        AppLang.english: 'In 1 acre',
        AppLang.marathi: '१ एकरात',
        AppLang.gujarati: '૧ એકરમાં',
        AppLang.punjabi: '੧ ਏਕੜ ਵਿੱਚ',
        AppLang.bengali: '১ একরে',
        AppLang.telugu: '1 ఎకరంలో',
        AppLang.tamil: '1 ஏக்கரில்',
        AppLang.kannada: '೧ ಎಕರೆಯಲ್ಲಿ',
      });

  // ──────────────────────── त्रिकोणीय खेत ────────────────────────

  String get triThreeSidesMode => pick(const {
        AppLang.hindi: '3 भुजाएं (हेरॉन सूत्र)',
        AppLang.english: '3 sides (Heron)',
        AppLang.marathi: '३ बाजू (हेरॉन सूत्र)',
        AppLang.gujarati: '૩ બાજુઓ (હેરોન સૂત્ર)',
        AppLang.punjabi: '੩ ਬਾਹੀਆਂ (ਹੇਰੌਨ ਸੂਤਰ)',
        AppLang.bengali: '৩ বাহু (হেরন সূত্র)',
        AppLang.telugu: '3 భుజాలు (హెరాన్)',
        AppLang.tamil: '3 பக்கங்கள் (ஹீரான்)',
        AppLang.kannada: '೩ ಬದಿಗಳು (ಹೆರಾನ್)',
      });

  String get triBaseHeightMode => pick(const {
        AppLang.hindi: 'आधार × ऊंचाई',
        AppLang.english: 'Base × Height',
        AppLang.marathi: 'पाया × उंची',
        AppLang.gujarati: 'પાયો × ઊંચાઈ',
        AppLang.punjabi: 'ਆਧਾਰ × ਉਚਾਈ',
        AppLang.bengali: 'ভূমি × উচ্চতা',
        AppLang.telugu: 'భూమి × ఎత్తు',
        AppLang.tamil: 'அடிப்பகுதி × உயரம்',
        AppLang.kannada: 'ಪಾದ × ಎತ್ತರ',
      });

  String get triEnterThreeSides => pick(const {
        AppLang.hindi: 'तीनों भुजाओं की नाप दर्ज करें:',
        AppLang.english: 'Enter all three sides:',
        AppLang.marathi: 'तिन्ही बाजूंची मोजणी टाका:',
        AppLang.gujarati: 'ત્રણેય બાજુઓનું માપ નાખો:',
        AppLang.punjabi: 'ਤਿੰਨਾਂ ਬਾਹੀਆਂ ਦੀ ਮਿਣਤੀ ਪਾਓ:',
        AppLang.bengali: 'তিনটি বাহুর মাপ দিন:',
        AppLang.telugu: 'మూడు భుజాల కొలత ఇవ్వండి:',
        AppLang.tamil: 'மூன்று பக்க அளவுகளையும் உள்ளிடவும்:',
        AppLang.kannada: 'ಮೂರೂ ಬದಿಗಳ ಅಳತೆ ಹಾಕಿ:',
      });

  String get triSideA => pick(const {
        AppLang.hindi: 'भुजा A (Side 1)',
        AppLang.english: 'Side A',
        AppLang.marathi: 'बाजू A (Side 1)',
        AppLang.gujarati: 'બાજુ A (Side 1)',
        AppLang.punjabi: 'ਬਾਹੀ A (Side 1)',
        AppLang.bengali: 'বাহু A (Side 1)',
        AppLang.telugu: 'భుజం A (Side 1)',
        AppLang.tamil: 'பக்கம் A (Side 1)',
        AppLang.kannada: 'ಬದಿ A (Side 1)',
      });

  String get triSideBBase => pick(const {
        AppLang.hindi: 'भुजा B (आधार / Base)',
        AppLang.english: 'Side B (Base)',
        AppLang.marathi: 'बाजू B (पाया / Base)',
        AppLang.gujarati: 'બાજુ B (પાયો / Base)',
        AppLang.punjabi: 'ਬਾਹੀ B (ਆਧਾਰ / Base)',
        AppLang.bengali: 'বাহু B (ভূমি / Base)',
        AppLang.telugu: 'భుజం B (భూమి / Base)',
        AppLang.tamil: 'பக்கம் B (அடிப்பகுதி / Base)',
        AppLang.kannada: 'ಬದಿ B (ಪಾದ / Base)',
      });

  String get triSideC => pick(const {
        AppLang.hindi: 'भुजा C (Side 3)',
        AppLang.english: 'Side C',
        AppLang.marathi: 'बाजू C (Side 3)',
        AppLang.gujarati: 'બાજુ C (Side 3)',
        AppLang.punjabi: 'ਬਾਹੀ C (Side 3)',
        AppLang.bengali: 'বাহু C (Side 3)',
        AppLang.telugu: 'భుజం C (Side 3)',
        AppLang.tamil: 'பக்கம் C (Side 3)',
        AppLang.kannada: 'ಬದಿ C (Side 3)',
      });

  String get triEnterBaseHeight => pick(const {
        AppLang.hindi: 'आधार और ऊंचाई दर्ज करें:',
        AppLang.english: 'Enter base and height:',
        AppLang.marathi: 'पाया आणि उंची टाका:',
        AppLang.gujarati: 'પાયો અને ઊંચાઈ દાખલ કરો:',
        AppLang.punjabi: 'ਆਧਾਰ ਅਤੇ ਉਚਾਈ ਭਰੋ:',
        AppLang.bengali: 'ভূমি ও উচ্চতা দিন:',
        AppLang.telugu: 'భూమి మరియు ఎత్తు ఇవ్వండి:',
        AppLang.tamil: 'அடிப்பகுதி மற்றும் உயரத்தை உள்ளிடவும்:',
        AppLang.kannada: 'ಪಾದ ಮತ್ತು ಎತ್ತರ ನಮೂದಿಸಿ:',
      });

  String get triBase => pick(const {
        AppLang.hindi: 'आधार (Base)',
        AppLang.english: 'Base',
        AppLang.marathi: 'पाया (Base)',
        AppLang.gujarati: 'પાયો (Base)',
        AppLang.punjabi: 'ਆਧਾਰ (Base)',
        AppLang.bengali: 'ভূমি (Base)',
        AppLang.telugu: 'భూమి (Base)',
        AppLang.tamil: 'அடிப்பகுதி (Base)',
        AppLang.kannada: 'ಪಾದ (Base)',
      });

  String get triHeight => pick(const {
        AppLang.hindi: 'ऊंचाई (Height)',
        AppLang.english: 'Height',
        AppLang.marathi: 'उंची (Height)',
        AppLang.gujarati: 'ઊંચાઈ (Height)',
        AppLang.punjabi: 'ਉਚਾਈ (Height)',
        AppLang.bengali: 'উচ্চতা (Height)',
        AppLang.telugu: 'ఎత్తు (Height)',
        AppLang.tamil: 'உயரம் (Height)',
        AppLang.kannada: 'ಎತ್ತರ (Height)',
      });

  String get triInvalidHint => pick(const {
        AppLang.hindi: 'नाप दर्ज करें। (ध्यान दें: किन्हीं दो भुजाओं का योग तीसरी भुजा से बड़ा होना चाहिए)',
        AppLang.english: 'Enter the measurements. (Note: any two sides must add up to more than the third)',
        AppLang.marathi: 'मोजणी टाका. (टीप: कोणत्याही दोन बाजूंची बेरीज तिसऱ्या बाजूपेक्षा मोठी हवी)',
        AppLang.gujarati: 'માપ દાખલ કરો. (નોંધ: કોઈપણ બે બાજુઓનો સરવાળો ત્રીજી બાજુ કરતાં મોટો હોવો જોઈએ)',
        AppLang.punjabi: 'ਮਿਣਤੀ ਭਰੋ। (ਧਿਆਨ: ਕਿਸੇ ਵੀ ਦੋ ਬਾਹੀਆਂ ਦਾ ਜੋੜ ਤੀਜੀ ਬਾਹੀ ਤੋਂ ਵੱਡਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ)',
        AppLang.bengali: 'মাপ দিন। (মনে রাখুন: যে কোনো দুই বাহুর যোগফল তৃতীয় বাহুর চেয়ে বড় হতে হবে)',
        AppLang.telugu: 'కొలత ఇవ్వండి. (గమనిక: ఏవైనా రెండు భుజాల మొత్తం మూడో భుజం కంటే ఎక్కువ ఉండాలి)',
        AppLang.tamil: 'அளவுகளை உள்ளிடவும். (குறிப்பு: ஏதேனும் இரு பக்கங்களின் கூட்டுத்தொகை மூன்றாவது பக்கத்தை விட அதிகமாக இருக்க வேண்டும்)',
        AppLang.kannada: 'ಅಳತೆ ನಮೂದಿಸಿ. (ಸೂಚನೆ: ಯಾವುದೇ ಎರಡು ಬದಿಗಳ ಮೊತ್ತ ಮೂರನೇ ಬದಿಗಿಂತ ದೊಡ್ಡದಿರಬೇಕು)',
      });

  String get triTotalArea => pick(const {
        AppLang.hindi: 'त्रिभुज का कुल क्षेत्रफल:',
        AppLang.english: 'Total area of the triangle:',
        AppLang.marathi: 'त्रिकोणाचे एकूण क्षेत्रफळ:',
        AppLang.gujarati: 'ત્રિકોણનું કુલ ક્ષેત્રફળ:',
        AppLang.punjabi: 'ਤਿਕੋਣ ਦਾ ਕੁੱਲ ਖੇਤਰਫਲ:',
        AppLang.bengali: 'ত্রিভুজের মোট ক্ষেত্রফল:',
        AppLang.telugu: 'త్రిభుజం మొత్తం వైశాల్యం:',
        AppLang.tamil: 'முக்கோணத்தின் மொத்தப் பரப்பளவு:',
        AppLang.kannada: 'ತ್ರಿಕೋನದ ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ:',
      });

  String get triShareTitle => pick(const {
        AppLang.hindi: '📐 त्रिकोणीय खेत नापी',
        AppLang.english: '📐 Triangular field measurement',
        AppLang.marathi: '📐 त्रिकोणी शेताची मोजणी',
        AppLang.gujarati: '📐 ત્રિકોણીય ખેતરનું માપ',
        AppLang.punjabi: '📐 ਤਿਕੋਣੇ ਖੇਤ ਦੀ ਮਿਣਤੀ',
        AppLang.bengali: '📐 ত্রিকোণাকার জমির পরিমাপ',
        AppLang.telugu: '📐 త్రికోణాకార పొలం కొలత',
        AppLang.tamil: '📐 முக்கோண நில அளவீடு',
        AppLang.kannada: '📐 ತ್ರಿಕೋನ ಜಮೀನಿನ ಅಳತೆ',
      });

  String get shareTotalArea => pick(const {
        AppLang.hindi: 'कुल क्षेत्रफल',
        AppLang.english: 'Total area',
        AppLang.marathi: 'एकूण क्षेत्रफळ',
        AppLang.gujarati: 'કુલ ક્ષેત્રફળ',
        AppLang.punjabi: 'ਕੁੱਲ ਖੇਤਰਫਲ',
        AppLang.bengali: 'মোট ক্ষেত্রফল',
        AppLang.telugu: 'మొత్తం వైశాల్యం',
        AppLang.tamil: 'மொத்தப் பரப்பளவு',
        AppLang.kannada: 'ಒಟ್ಟು ವಿಸ್ತೀರ್ಣ',
      });
}
