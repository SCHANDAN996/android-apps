# कैलेंडर अनुभव — 28 अक्टूबर 2026

उपयोगकर्ता: «calender section ko aur next lavel pe le jana h achha ui ux aur featcherd callender banana h»। मौजूदा offline पंचांग/त्योहार इंजन और धार्मिक निर्णय यथावत; यह काम खोज, navigation और presentation का है।

## इस चरण में लागू

- ऊपर तारीख़ चुनने का बटन: picker से तारीख़/वर्ष चुनने पर महीना और चुना दिन एक साथ बदलते हैं। Cancel से पिछला चयन सुरक्षित है।
- महीने का पूरा शीर्षक अलग पंक्ति में; पिछले/अगले महीने और आज के controls अलग पंक्ति में, ताकि बड़े अक्षरों में शीर्षक बहुत पतला न हो।
- दिन के खाने में अंग्रेज़ी तारीख़ के साथ सूर्योदय की वास्तविक तिथि। आज और चयन की सीमा अलग; त्योहार के संकेत और पूरे दिन के screen-reader विवरण सुरक्षित। पूरे त्योहार नाम चुने दिन के विवरण में मिलते हैं।
- वर्तमान शहर, सूर्योदय की तिथि का संदर्भ और संकेतों की कुंजी। सामान्य grid cell 80dp; बड़े अक्षरों पर 94dp। सात दिन की grid में छोटे तिथि-label उपलब्ध चौड़ाई में fit होते हैं; नीचे का विस्तृत पंचांग बड़े अक्षर रखता है।
- त्योहार/व्रत नाम की खोज, साफ़ करने का बटन, वर्तमान श्रेणी के साथ संयुक्त परिणाम। हिंदी नाम के हिस्से से खोज; transliteration/fuzzy search नहीं जोड़ी।
- केवल आने वाले दिन का filter। आज शामिल है; पिछली primary तारीख़ लेकिन भविष्य की मान्य alternative तारीख़ वाला ambiguous festival नहीं छूटता।
- परिणाम संख्या और महीनेवार क्रमबद्ध सूची; स्पष्ट खाली परिणाम। मौजूदा व्रत/पर्व/ग्रहण श्रेणियाँ, धार्मिक अस्पष्टता और «यह तारीख़ कैसे बनी» का साक्ष्य सुरक्षित।
- अगला महत्वपूर्ण दिन compact card में; «कैलेंडर में देखें» उसी तारीख़ को month tab में चुनता है।

## जाँच

प्रारम्भिक affected run में 24 पास/1 fail: पुराने test ने छोटा grid-label खोजा जो अब तिथि दिखाता है। test को विस्तृत चयनित दिन तक सही vertical list में scroll कराया। एक अगले run में बड़े अक्षर की legend row का वास्तविक overflow मिला; label को Flexible किया। Preview capture का asynchronous wait भी test helper में ठीक किया।

इसके बाद `calendar_experience_test`, `phase6_screens_test`, `phase7_polish_test`, `tyohar_saal_test` का संयुक्त run **30/30 पास**; preview-font वाला अलग run **5/5 पास**। यह पूरे app suite का नया दावा नहीं है। इनके बाद दृश्य निरीक्षण से month heading की final layout refinement हुई; उसका अंतिम परिणाम नीचे जोड़ा जाएगा।

स्थानीय प्रमाण `design_sources/calendar_2026-10-28/` तथा `design_sources/calendar-2026-10-28-*.log` में। कंप्यूटर preview वास्तविक phone/Play screenshots नहीं हैं।

## अगला विस्तार

व्यक्तिगत चुने दिन और reminders को बाद में अलग, tested चरण में रखा जा सकता है: मौजूदा स्थानीय reminder प्रणाली, permission और saved data के साथ जोड़कर। आज नये notifications, calendar sync, login, analytics SDK, online service, धार्मिक नियम या शुभ मुहूर्त flag नहीं जोड़े। वास्तविक फोन पर नये कैलेंडर का परीक्षण इस चरण में अभी नहीं हुआ।

## रिलीज़ की सीमा

पहले तैयार code9 release-input checkpoint इन UI बदलावों से पुराना हो गया है। उस पुराने checkpoint पर बने AAB को इस नये कैलेंडर वाला नहीं कहना है। नया final source checkpoint/build और Console submission अलग सत्यापित होने पर ही upload/published लिखें। पुराने code8 release और उसके दस्तावेज़ सुरक्षित हैं।

## अंतिम परिणाम — 29 अक्टूबर 2026

- अंतिम source पर संयुक्त affected suite **32/32 पास**, `calendar-2026-10-28-final-pass.log`; अतिरिक्त normal/double-font cases के कारण पिछला 30 अब 32 हुआ।
- Final preview run **7/7 पास**, `calendar-2026-10-28-final-preview.log`। आठ PNG (महीना/त्योहार × light/dark × 1×/2×, 320dp) वास्तव में खोलकर देखे। अंतिम शीर्षक अब महीने/वर्ष को पूरी चौड़ाई देता है; digits/icons सहित preview fonts सही load हुए। Grid के नीचे selected-day detail scroll से मिलती है; बड़े अक्षरों पर पूरा महीना/विवरण एक साथ viewport में होने का दावा नहीं।
- `flutter analyze --no-pub`: **No issues found**, 68.5 सेकंड, exit 0 (`calendar-2026-10-29-analyze.log`)।
- `git diff --check` नामित UI/test files पर साफ़। इंजन, धार्मिक assets, flags, notifications और profiles नहीं बदले।
- अंतिम कैलेंडर का नया Android build/device check और Play submission अभी इस entry तक लंबित हैं। पिछले फोन परीक्षण को इस नये UI का परीक्षण नहीं माना है।
