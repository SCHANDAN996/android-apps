# विधिवत प्रबंधन — v0.2

प्रोजेक्ट के **Open Admin Panel.cmd** को दो बार क्लिक करें। पैनल आपके कंप्यूटर के ब्राउज़र में खुलेगा। बाहर कोई hosting/account नहीं है। इसे उपयोगकर्ताओं के फोन से data नहीं मिलता।

## अभी उपलब्ध

- असली app assets से पूजा/व्रत/आरती/ग्रंथ/पर्व/कथा की सूची, खोज, श्रेणी और pagination।
- पाठ का पढ़ने वाला preview, बड़े अक्षर और light/dark toggle। यह final app render का विकल्प नहीं।
- ग्रंथ की canonical मूल/अर्थ/kram फ़ाइलें; खाली legacy आरती templates को मूल स्रोत नहीं माना जाता। जिन आरतियों का txt खाली है उनकी वर्तमान JSON ही संपादन input रहती है।
- सरल JSON metadata form और पूरी स्रोत फ़ाइल का वैकल्पिक editor; txt के लिए source editor।
- अलग draft save, source hash conflict detection, पहले/बाद की समीक्षा और draft download।
- ड्राफ़्ट की जाँच, सभी प्रभावित फ़ाइलों का मिलान, मालिक की स्रोत-समीक्षा, बैकअप लेकर कार्यप्रति में apply और सीमित restore। ग्रंथ/भरी आरती के लिए generation पहले अलग staging में होता है। पहले से असंगत स्रोत/output या बाद में बदली फ़ाइल पर लागू करना रुकता है।
- चित्र thumbnail, file size, exact duplicate hash और direct code-reference count। Zero direct reference को unused होने का प्रमाण न मानें।
- स्रोत/पंजी/योजना documents और historical test logs पढ़ना।
- तय commands से panel/app/engine tests तथा app analyzer; running log, result और input fingerprint से stale-report पहचान।

वास्तविक स्रोत-जाँच की पुष्टि अपने आप नहीं होती। Source-note लिखना या दो किताबें जोड़ना verified status नहीं बनाता।

## चलाना और बन्द करना

`Start-Admin.ps1` compiled `build/vidhivat-admin.exe` को hidden background process में खोलता है। `.runtime/session.json` में पता/PID है, authentication token नहीं। फिर से खोलने पर उसी workspace का चल रहा panel reuse होता है।

`admin/Stop-Admin.ps1` panel बन्द करता है। चलती जाँच हो तो पहले उसे पूरा होने दें। Browser tab बन्द करना server बन्द नहीं करता। Drafts बने रहते हैं।

ड्राफ़्ट `admin/.workspace/drafts/`, नये test logs `admin/.workspace/reports/`, तैयार मिलान `prepared/`, अस्थायी generation `staging/` और मूल byte-backups `backups/` में हैं। ये सभी `.workspace/` के भीतर Git से ignored हैं। पैनल बन्द करने पर बने रहते हैं। Backup रिकॉर्ड खराब/अधूरा हो तो नया apply रोकता है; रिकॉर्ड हटाकर आगे न बढ़ें, पहले उसकी जाँच करें।

पाठ/अर्थ/नियम बदलने पर दो अलग छपी पुस्तकों के नाम, संस्करण, पृष्ठ और पढ़े होने की मालिक की पुष्टि दर्ज होती है। यह स्वयं स्रोत-जाँच का प्रमाण नहीं है। JSON में केवल स्वरूप बदलने पर भी मिलान और वजह जरूरी हैं। Apply स्थानीय स्रोत/ऐप assets में जाता है; फोन पर अपडेट के लिए अलग APK build/install चाहिए। Image/home editing और release publishing अभी उपलब्ध नहीं हैं।

## Development

Windows Flutter build के C++ components अधूरे मिले; इसीलिए Dart local HTTP process + buildless HTML/CSS/JS प्रयोग किया। Native C++ install जरूरी नहीं। मौजूदा SDK: `C:\src\flutter`। Test-runner SDK paths `lib/jobs.dart` के fixed allowlist में हैं; दूसरे कंप्यूटर पर उन्हें अपनी installed SDK path से बदलें। UI से arbitrary shell command नहीं चलती।

```powershell
cd admin
dart pub get --offline
dart test
dart analyze
dart run bin/admin.dart --workspace "C:\path\to\14 Vidhivat"
```

Compiled launcher के लिए:

```powershell
New-Item -ItemType Directory -Force build
dart compile exe bin/admin.dart -o build/vidhivat-admin.exe
```

Server केवल IPv4 loopback पर है। Foreign Host/Origin, token-विहीन writes, workspace से बाहर paths और linked external files रोके जाते हैं। API में मूल content apply/delete route नहीं है। Secret session token memory में रहता है; local read-only bootstrap से उसी-origin page को मिलता है।

## अगले चरण

Source proof viewer में scan-page तुलना, अधिक typed content forms, reviewed apply/backup/restore, image mapping editor, home configuration और build/release workflow अलग चरण हैं। इस पहले संस्करण में इन्हें उपलब्ध बताने वाला निष्क्रिय button नहीं दिखाया गया।
