# विधिवत — Android emulator kit

यह folder वीडियो/QA के लिए दोहराकर बनाया जा सकने वाला Android emulator देता है।
Emulator, Android system image, APK और recordings इस Git repo में नहीं रखे जाते — वे कई GB के और machine-specific होते हैं। यह kit उन्हें आपके Windows PC पर फिर से बनाने के लिए है।

## एक बार की तैयारी

1. Android Studio install करें और कम-से-कम एक बार खोलें।
2. PowerShell खोलकर चलाएँ:

    Set-ExecutionPolicy -Scope Process Bypass
    .\setup_windows.ps1

इससे `VidhivatVideo` नाम का Pixel 6, API 35, Google APIs x86_64 emulator बनेगा। यह video capture के लिए 4 GB RAM और 8 GB storage रखता है।

## APK install और clean recording

Play Console से निकली हुई release APK इसी folder में न रखें; कोई अलग local folder चुनें। फिर:

    .\install_and_record.ps1 -ApkPath "C:\path\to\vidhivat-release.apk"

Script emulator चालू करेगी, APK install करेगी, animations बंद करेगी और recording के लिए तैयार करेगी। फिर app में अपनी ज़रूरी यात्रा चलाएँ; recording रोकने और फ़ाइल खींचने के लिए script में छपा command चलाएँ।

## महत्वपूर्ण

- Play Console की `.aab` सीधे install नहीं होती; recording के लिए `.apk` चाहिए।
- Store build और GitHub build अलग हो सकते हैं। Video हमेशा उसी APK से लें जो दर्शक को वास्तव में मिलने वाला है।
- Keystore, APK, `.avd`, Android system image और MP4 files कभी commit न करें।
- Emulator का पहला boot धीमा हो सकता है; बाद के boot snapshot से तेज़ होंगे।
- यहाँ `Gemini Notebook` या दूसरे video tool का watermark नहीं आएगा क्योंकि recording सीधे emulator से निकलती है।
