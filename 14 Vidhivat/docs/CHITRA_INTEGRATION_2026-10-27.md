# छह नए चित्र और संबंधित UI — 27 अक्टूबर 2026

उपयोगकर्ता के दिए prompts से बने छह PNG `Downloads/Vrat-6-images-2026-10-27` में सुरक्षित हैं। उसी अनुमति से उन्हें परियोजना के `tools/banao_chitra.py` द्वारा पारदर्शी WebP में बदला गया। मूल PNG सुरक्षित हैं; पृष्ठभूमि की सफेदी नहीं हटाई गई क्योंकि alpha पहले से मौजूद था।

| चित्र | उपयोग | नाप | bytes |
|---|---|---|---|
| vrat_narak_chaturdashi_v1.webp | नरक चतुर्दशी | 900×900 | 181668 |
| vrat_gopashtami_v1.webp | गोपाष्टमी | 900×900 | 135334 |
| vrat_akshaya_navami_v1.webp | आँवला नवमी | 900×900 | 178742 |
| vrat_holika_dahan_v1.webp | होलिका दहन | 900×900 | 174868 |
| vrat_akshaya_tritiya_v1.webp | अक्षय तृतीया | 900×900 | 177110 |
| reading_g_rudri_v2.webp | ग्रंथालय: रुद्राष्टाध्यायी | 640×640 | 83492 |

इनकी पहचान `VratArtwork` और `PaathAssets` में है; इसी mapping से होम, सूची और व्रत-पन्नों में चित्र पहुँचते हैं। रुद्राष्टाध्यायी की image पट्टी अनुरोध के fallback अनुसार खाली है; सही नाम Flutter के असली text में card के नीचे है। bitmap में नया मंत्र या कथन नहीं डाला गया। धार्मिक तथ्य/मंत्र/पंचांग/भुगतान नहीं बदले; चित्रों को पंडित द्वारा जाँचा हुआ नहीं बताया गया।

## UI
- व्रत cards की fixed height और नाम काटने वाली ellipsis हटाई; बड़ा अक्षर होने पर ऊँचाई content के अनुसार बढ़ती है।
- दो-column व्रत cards के बीच 16dp जगह; चित्र उपलब्ध चौड़ाई के अनुसार वर्गाकार contain में आते हैं।
- पाठ/ग्रंथ cards के चित्र responsive (अधिकतम 160dp); दोनों decode dimensions एक साथ नहीं दिए।
- Screen reader के लिए पाँचों नए चित्रों और रुद्राष्टाध्यायी के हिंदी labels।

## जाँच
छहों WebP: alpha मौजूद, कोई फ़ाइल 180 KiB से बड़ी नहीं। `flutter analyze` में कोई issue नहीं। पाँच प्रभावित पुरानी test files 42/42; नये responsive/hero tests 13/13 (320/360dp, light/dark, 1×/2×)। व्रत और ग्रंथ JSON generator parity जाँचें पास। पूरी suite का अंतिम परिणाम नीचे दर्ज होगा। फ़ोन इस दौर में उपलब्ध नहीं; नए APK/Play upload का दावा नहीं।

## अंतिम जाँच — इसी काम का अगला दौर, 27 अक्टूबर 2026

- पूरी app suite: `cd app; flutter test --reporter expanded` — **1491/1491 पास**, exit 0, 6 मिनट 29 सेकंड। नया run अकेला चलाया गया; दूसरा Flutter command उसके समाप्त होने के बाद ही शुरू हुआ।
- पिछली बार के चार granth navigation / missing `ink_sparkle` shader failures इस run में **दोहराए नहीं गए**। इनके कारण की पुष्टि नहीं हुई; concurrent runs को निश्चित कारण या किसी production fix का दावा नहीं किया गया। Navigation tests सहित पूरी suite पास होने के कारण runtime code में अनुमान पर बदलाव नहीं किया।
- Screenshot mode: image precache के बाद पाँचों त्योहारों के hero previews बने। परीक्षण-फ़ॉन्ट Ahem से विराम-चिह्न/अंकों के चौकोर glyph दिखे थे; केवल optional desktop preview में `PreviewHindi`/स्थानीय Nirmala primary font लगाया, फिर previews दोबारा बनाए। सामान्य tests और Android theme/font में बदलाव नहीं है।
- अंतिम preview command: `VIDHIVAT_QA_SCREENSHOTS=../design_sources/chitra_2026-10-27 flutter test test/festival_artwork_layout_test.dart ../design_sources/chitra_2026-10-27/catalog_preview_test.dart --reporter expanded` — **21/21 पास**: मौजूदा 13 layout/hero checks और अस्थायी 8 catalog preview checks। इसे पूरी suite के 1491 में जोड़कर नया total नहीं कहा गया है। PowerShell में environment variable अलग सेट/हटाया गया।
- दृश्य निरीक्षण: पाँच hero PNG; व्रत सूची तथा ग्रंथालय के 360dp, light/dark, 1×/2× के आठ PNG; छह मूल WebP की contact sheet। सभी 13 अंतिम screen previews खोले/देखे: चित्र लोड हैं, रुद्राष्टाध्यायी का अपना चित्र है, transparent किनारे सही हैं। 2× पर दो-column नाम कई पंक्तियों में (कभी शब्द के बीच भी) टूटते हैं; ellipsis/overflow नहीं मिला। स्क्रॉल की वजह से viewport से बाहर वाले अन्य cards के हिस्से स्वाभाविक रूप से कटते हैं; ये image assets की clipping नहीं है।
- अंतिम `flutter analyze` — **No issues found**, exit 0। `git diff --check` में whitespace error नहीं।
- छहों WebP स्वतंत्र रूप से दोबारा पढ़े: RGBA, alpha extrema 0–255; नाप/bytes ऊपर की तालिका से मिले; सभी ≤180 KiB।
- प्रमाण स्थानीय `design_sources/chitra_2026-10-27/` में: `full-suite.log`, `final-previews.log`, `analyze.log`, `hero-contact-sheet.png`, `catalog-normal.png`, `catalog-large.png`, तथा individual PNG और QA-only `catalog_preview_test.dart`। ये कंप्यूटर पर बने layout previews हैं, वास्तविक फ़ोन/Play Store screenshots नहीं।

### बचा हुआ काम / सीमा

दो बार `adb devices` में कोई device नहीं मिला। इसलिए इस दौर में वास्तविक फ़ोन जाँच नहीं हुई; फ़ोन जुड़ने और इन बदलावों वाली build उपलब्ध होने पर पाँच व्रत-पन्ने, व्रत सूची, रुद्राष्टाध्यायी card तथा सामान्य/बड़े अक्षरों में tap/scroll देखना बाकी है। नया APK/AAB नहीं बनाया, push/Play upload नहीं किया। इन assets को पुरानी code8 release में मौजूद होने का दावा नहीं है।

इस काम के commit में केवल नामित छह artwork assets, चार UI/mapping files, तीन test files और यह दस्तावेज़ शामिल हैं। साझा progress/next में केवल इस दौर की नई entry जोड़ी गई; पहले से पड़े engine, संस्कृत/स्रोत, audit, admin और दूसरे projects के बदलाव सुरक्षित छोड़े हैं।
