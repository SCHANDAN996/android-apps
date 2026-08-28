# Screenshots — Play Console पर चढ़ाने के लिए

आठों तस्वीरें **1080×1920** (ठीक 9:16) हैं और **किसी में विज्ञापन नहीं** है।
Play के फ़ोन screenshots के लिए यही चाहिए।

| फ़ाइल | क्या दिखता है |
|---|---|
| `01_home.png` | होम — छहों tools |
| `02_khet_napi.png` | 4-भुजा खेत — नक्शा और भुजाओं की नाप |
| `03_natija.png` | नतीजा — हेरॉन सूत्र से सटीक क्षेत्रफल, सब इकाइयों में |
| `04_aur_tools.png` | बाकी tools |
| `05_bantwara.png` | बंटवारा — बराबर हिस्से |
| `06_lambai.png` | लंबाई कन्वर्टर |
| `07_pro_kisan.png` | प्रो किसान का परिचय (हमारा दूसरा ऐप) |
| `08_laggi.png` | लग्गी पैमाना |

## विज्ञापन कैसे हटे

`--dart-define=SCREENSHOTS=true` लगाकर build किया — तब न banner दिखता है न
interstitial (देखें `lib/data/app_flags.dart`)। Play की listing policy में
screenshots के अंदर ads मना हैं, और वैसे भी ad वाली तस्वीर देखकर install करने
का मन कम होता है।

**असली release build पर इसका कोई असर नहीं** — flag न दें तो विज्ञापन पहले जैसे
चलते हैं।

## दोबारा लेने हों

```bash
flutter build apk --debug --dart-define=SCREENSHOTS=true
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# फोन को ठीक 9:16 पर लाइए (नीचे की back/home पट्टी 116px की है,
# इसलिए 1920 + 116 = 2036)
adb shell wm size 1080x2036
adb shell wm density 450

# ...screenshots लीजिए (adb exec-out screencap -p > file.png)...

python design/crop_navbar.py     # नीचे की पट्टी काटकर ठीक 1080x1920

# फोन वापस अपनी हालत में — यह भूलिएगा मत
adb shell wm size reset
adb shell wm density reset
```

## `purane_mat_chadhaiye/`

उसमें पुराने "किसान कैलकुलेटर" के screenshots हैं — EMI, सूद और फसल मुनाफ़ा
वाली स्क्रीनें, जो अब ऐप में हैं ही नहीं। **वे मत चढ़ाइए**, वरना user को वो
चीज़ें दिखेंगी जो ऐप खोलने पर मिलेंगी नहीं और खराब review आएँगे।
