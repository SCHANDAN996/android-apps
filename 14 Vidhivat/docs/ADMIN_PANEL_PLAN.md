# विधिवत Admin Panel — प्रस्तावित योजना

तारीख़:25 अक्टूबर2026। स्थिति: **पहला स्थानीय संस्करण तैयार।** उपयोगकर्ता ने «कंटेंट और ऐप प्रबंधन» चुना और «करो» कहा। संग्रह/स्रोत/चित्र/report viewer, canonical draft editor, समीक्षा/download और controlled test runner बन गए हैं। Reviewed apply/restore, scan-page तुलना, image/home editing और release workflow अगले चरण हैं।

## 1. पैनल कहाँ और किसलिए

पहला संस्करण आपके Windows कंप्यूटर पर चलने वाला अलग **«विधिवत प्रबंधन»** पैनल हो। मोबाइल ऐप अपने मौजूदा offline ढाँचे पर रहे। सामग्री, छपे स्रोत, चित्र, जाँच और रिलीज़ की तैयारी एक जगह मिलें। पैनल रोज़ खोलना जरूरी न हो।

यह स्थानीय परियोजना के लिए है। अभी ऐप के उपयोगकर्ताओं की केंद्रीय सूची या उनकी निजी कुंडलियों का सर्वर नहीं है; उन्हें dashboard पर दिखाने का आधार उपलब्ध नहीं। वास्तविक दक्षिणा/भुगतान की जानकारी का मौजूदा स्रोत PayU dashboard है। केंद्रीय user/payment management चाहिए तो उसे अलग ऑनलाइन प्रणाली और अलग scope के रूप में तय करना होगा।

## 2. मुख्य पन्ने

| पन्ना | क्या दिखे/क्या किया जा सके |
|---|---|
| काम की स्थिति | कुल सामग्री, अधूरे drafts, खुले J-/U-/UX-issues, स्रोत-जाँच बाकी, चित्र mapping की कमी, आखिरी जाँच और build |
| पूजा और व्रत | परिचय, सामग्री, पूजा के चरण, मंत्र/अर्थ, संबंधित पाठ और चित्र का draft संपादन; त्योहार की तारीख engine से |
| आरती, चालीसा और ग्रंथ | श्रेणी, अध्याय/खंड का क्रम, मूल पाठ, अर्थ, स्रोत-नोट; chapter और verse ID सुरक्षित |
| स्रोत और समस्या-पंजी | किताब/संस्करण/प्रकाशक, छपा पृष्ठ और scan page, exact श्लोक-सीमा; source-image और app text साथ; issue, evidence, मतभेद और समाधान |
| चित्र संग्रह | master/export/nameplate, विषय और mapping, कहाँ-कहाँ इस्तेमाल, duplicate/missing image, light/dark और छोटे कार्ड का preview |
| प्रीव्यू और जाँच | 320/360 चौड़ाई, बड़े अक्षर, light/dark; जरूरी validations और संबंधित tests; परिणाम तथा उसकी ताज़गी |
| अपडेट की तैयारी | source/asset diff, चुनी फ़ाइलें, check report, version/build जानकारी और APK का स्थान |

स्क्रीन के नाम/बटन हिंदी में हों: **खोजें, नया ड्राफ़्ट, प्रीव्यू, स्रोत देखें, जाँच चलाएँ, बदलाव देखें, लागू करें**। तकनीकी raw JSON सामान्य फॉर्म के पीछे वैकल्पिक दृश्य में रहे।

## 3. पहला स्क्रीन-ढाँचा

बाईं ओर ऊपर वाले पन्नों की सूची। ऊपर एक खोज और चुने प्रोजेक्ट का नाम। बीच में सामग्री की सूची/संपादन। दाईं ओर आवश्यकता पर मोबाइल प्रीव्यू या स्रोत का पृष्ठ।

मुख्य पन्ने पर चार छोटे सारांश: **सामग्री**, **स्रोत-जाँच बाकी**, **खुले मुद्दे**, **जाँच की स्थिति**। इनके नीचे «अगला जरूरी काम» और हाल के drafts। किसी संख्या को अनुमान से न भरें; स्थानीय सामग्री/रिपोर्ट से निकालें।

## 4. संपादन और लागू करने का क्रम

1. पूजा/अध्याय चुनें और उसकी असली स्रोत फ़ाइल पहचानें।
2. बदलाव अलग draft में लिखें; app assets तुरन्त न बदलें।
3. पुराने/नये पाठ और मोबाइल preview साथ देखें।
4. जिस मंत्र/नियम में बदलाव हुआ, उसके छपे स्रोत-पृष्ठ और समीक्षा दर्ज करें।
5. नियमों की जाँच और जरूरत के संबंधित tests चलाएँ।
6. तैयार होने पर चुने draft के बदलाव देखें; backup लेकर उन्हीं फ़ाइलों पर लागू करें।
7. ऐप अपडेट में जाने के लिए नया build/release चाहिए। केवल पैनल में Save करने से पहले से installed phones का content नहीं बदलता।

एक ही स्थानीय मालिक के लिए यह workflow हो; काल्पनिक editor/reviewer टीम या कई logins की जरूरत पहले संस्करण में नहीं। Source-reviewed status वास्तविक पढ़ने/मिलान के रिकॉर्ड से आये। दो स्रोत जोड़ देना शुद्धता का स्वचालित प्रमाण नहीं है।

## 5. इस repository के लिए जरूरी तकनीकी चुनाव

**लागू तकनीक:** `admin/` में अलग Dart local process और HTML/CSS/JS interface; browser इसी कंप्यूटर के loopback पते पर खुलता है। प्रारम्भिक Flutter Windows प्रस्ताव बदला क्योंकि installed Visual Studio में जरूरी C++/CMake/SDK घटक अधूरे मिले। Pure Dart executable बनाकर चलाया गया; native toolchain install या बाहर hosting नहीं की।

सबसे जरूरी बात **मूल सामग्री और generated assets का फर्क** है:

- ग्रंथ का authoritative input `tools/granth_paath/<id>/` है; `banao_granth.py` उससे `app/assets/...` बनाता है। Generated JSON सीधे edit करना मौजूदा pipeline के विरुद्ध होगा।
- आरती के input `tools/aarti_paath/` और उसके भरने वाले औज़ार हैं; हर सामग्री के लिए source adapter अलग पहचाना जाए।
- हाथ से सँभाली जाने वाली पूजा/व्रत सामग्री और generated सामग्री के लिए एक ही अंधा JSON editor न हो। हर श्रेणी की canonical फ़ाइलों का manifest पहले बने।
- Image masters/export manifests उपलब्ध हैं; वर्तमान कई mappings Dart में हैं। पहले संस्करण में उनका निरीक्षण/preview; बाद में सुरक्षित data manifest और उसके generator की migration अलग tested change होगी।
- Home sections भी अभी code से चलते हैं। Drag-and-drop home editor को पहले दिन का वादा न करें; उसके लिए अलग validated configuration और app integration चाहिए। पंचांग की गणना/तारीख को manual content field न बनाएँ।
- Preview पहले draft का local दृश्य होगा; final approval में असली app widget/screenshot tests जोड़ें। App के parsers/theme साझा करने के लिए पहले उनकी dependency जाँचें; अलग editor में नियमों की नकल करके दो असंगत schema न बनें।

**प्रस्तावित डेटा:** content manifest में stable ID/type/source-path/asset-path/generation-mode; draft में base-file hashes/बदलाव; source evidence में edition/page/verse-range/वास्तविक inspected status; test report में command/result/time और checked files का fingerprint।

## 6. गलती और बदलाव की सुरक्षा

- Backup और पुराने/नये का diff; draft discard और लागू हुए बदलाव की वापसी।
- किसी फ़ाइल में बाहर से बदलाव हो तो hash mismatch दिखे और नया diff बने; concurrent edits overwrite न हों।
- आवेदन से पहले stable IDs, chapter order, schema, missing fields, image paths और source evidence की जाँच। संदिग्ध अर्थ/संस्करण-भेद अलग status में रहें।
- Generator पहले अस्थायी output में चले। Expected files के diff की समीक्षा के बाद ही चुना output project में जाए।
- Test runner सिर्फ़ पहले से तय commands चलाये; edit किये JSON/text से shell command न बने।
- पैनल तय workspace के भीतर अनुमत फ़ाइलें ही लिखे। Drafts/backups अलग रहें; restore पूरे project पर अंधाधुंध overwrite न करे।
- Checked files बदलें तो पिछली green report «पुरानी जाँच» हो जाए।25 अक्टूबर के2077pass को हर नये draft की सफलता न दिखाएँ।

## 7. किस क्रम में बने

**पहला चरण — उपयोगी निरीक्षण पैनल:** workspace चुनना, source/asset inventory, खोज, missing mapping, issue/source-report viewer और मौजूदा test logs। इस चरण में production editor नहीं। सफलता: किसी ग्रंथ/पूजा का मूल स्रोत, app output, चित्र और खुला issue एक जगह मिल जाए।

**दूसरा चरण — एक पूरा संपादन रास्ता:** पहले एक सीमित, स्पष्ट canonical-format वाली सामग्री श्रेणी। Draft → स्रोत/preview → validation → temporary generation → diff → backup/apply। इसे सफल करके बाकी पूजा/आरती/ग्रंथ adapters जोड़ें।

**तीसरा चरण — चित्र और home प्रबंधन:** image चुनना/नाम/duplicate समीक्षा/export, tested mapping manifest; फिर home configuration का सीमित editor।

**चौथा चरण — पूरी जाँच और build सुविधा:** relevant/full test runs, stale-report पहचान, build logs/APK स्थान और manual release checklist। Build बनना publication नहीं; Play पर upload/publish अलग स्पष्ट कार्रवाई हो।

## 8. अभी योजना के बाहर

पहले संस्करण में user tracking, user जन्म-विवरण पढ़ना, live remote app control, login/account backend, स्वतः संस्कृत/तिथि बदलना और automatic publishing शामिल नहीं हैं। ये वर्तमान offline project-management जरूरत का हिस्सा नहीं मिले।

## 9. योजना का आधार — वास्तव में पढ़ी फ़ाइलें

- `CLAUDE.md`: अकेले डेवलपर का कम रखरखाव/offline ढाँचा; D-139 के स्रोत नियम।
- `tools/banao_granth.py`, `tools/jaancho_granth.py`: canonical source से generation, temporary verification और content checks।
- `tools/bharo_aarti.py`: आरती के txt inputs और draft handling।
- `tools/granth_paath/gita/kram.json`, `app/assets/granth/gita/_kram.json`: source और app index की अलग भूमिकाएँ।
- `app/assets/vidhi/ganesh_poojan.json`: मौजूदा पूजा फ़ॉर्म के वास्तविक fields।
- `app/lib/vidhi/paath_assets.dart`, `design_sources/reading_art_v1/*manifest*.json`: image mapping और masters/exports।
- `app/lib/state/kundali_profiles.dart`: निजी जन्म-विवरण फ़ोन पर स्थानीय हैं।
- `app/lib/services/dakshina_service.dart`: payment confirmation ऐप के पास नहीं; PayU का मौजूदा रास्ता।
- `docs/APP_TEST_2026-10-25.md`:2077pass का तारीख़ वाला वास्तविक baseline।

## 10. लागू पहले संस्करण का प्रमाण

`admin/README.md` में खोलने/बन्द करने और उपलब्ध सुविधाओं का विवरण है। Root का `Open Admin Panel.cmd` compiled local panel खोलता है।27 नए tests पास; Dart analyzer साफ़; JavaScript syntax check साफ़; लगभग7.1MB executable बना और launcher से चला। Browser में draft save→reload→review, original SHA256 unchanged, Hindi chapter search/pagination, image search/detail, source register और UI से वास्तविक admin test run जाँचे। पुरानी report input बदलने पर stale दिखी; नया27pass run fresh रहा।

इस run में mobile app/engine/canonical content नहीं बदले। Sample draft में केवल परीक्षण का स्रोत-नोट है; मूल पाठ/अर्थ वही हैं। पुराने2077 app/engine cases unchanged होने से दोहराये नहीं। Native phone या full-width desktop screenshot इस admin run का प्रमाण नहीं है; browser के उपलब्ध संकरे viewport में UI workflows जाँचे। `admin/verification/` और `admin/screenshots/overview.png` evidence हैं।

## v0.2 — समीक्षा, बैकअप और वापसी (25 अक्टूबर 2026)

User के अगले «करो» पर draft→prepare→review→backup/apply→restore पूरा किया। Direct पूजा/पाठ/व्रत/पर्व/कथा JSON को ऐप के असली छह pure-Dart parsers से validate किया जाता है। ग्रंथ और populated आरती source generation अलग staging में; पहले baseline को वर्तमान output से मिलाता है। ID, schema, खंड/चरण संख्या तथा generated अर्थ/roman खोने पर रोक। नये/हटे अध्याय इस सीमित editor से नहीं जुड़ते।

Review में हर प्रभावित फ़ाइल का before/after, वजह, पुष्टि और semantic बदलाव पर दो अलग पुस्तकों/संस्करण/पृष्ठ की owner attestation है। यह अपने आप printed-source verification नहीं है। Plan/draft/input/model/helper hashes तथा file-set दुबारा मिलते हैं। पहले durable byte-backup, प्रति-फ़ाइल guarded replacement, failed write पर guarded rollback। Crash/अधूरी वापसी का रिकॉर्ड रहता है; recovery और corrupt record होने पर नया apply रुकता है। बाद में बाहर से बदली फ़ाइल overwrite नहीं होती।

57 admin tests पास, analyzer साफ़, JS syntax साफ़, नया compiled executable बना/launcher से चला। अलग QA workspace में browser save→prepare→review→apply→backup→restore चला; fake QA पुस्तक records स्पष्ट simulated थे। Original धार्मिक corpus इस विकास/QA से नहीं बदला। Image/home editor, scan-page viewer और build/release अगला चरण हैं। प्रमाण docs/ADMIN_PANEL_QA.md में।
