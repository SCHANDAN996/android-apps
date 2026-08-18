# मिस्त्री कैलकुलेटर · Mistri Calculator

घर बनाने का पूरा हिसाब — पूरी तरह **ऑफलाइन**, हिंदी-पहले।
An offline construction estimate app for Indian masons, contractors and homebuilders.

## कैलकुलेटर (Calculators)

| # | मॉड्यूल | क्या निकालता है |
|---|---------|-----------------|
| 1 | ईंट (Brick) | दीवार में ईंट की संख्या + सीमेंट + बालू |
| 2 | कंक्रीट / ढलाई (Concrete) | स्लैब/कॉलम/बीम का सीमेंट, बालू, गिट्टी (M15/M20/M25) |
| 3 | सरिया (Steel/TMT) | लंबाई/छड़/स्लैब से सरिया का वज़न (kg) |
| 4 | प्लास्टर (Plaster) | प्लास्टर में सीमेंट + बालू (12mm/15mm) |
| 5 | टाइल्स (Tiles) | फ़र्श के लिए टाइल्स + बॉक्स की संख्या |
| 6 | पेंट (Paint) | दीवार के लिए पेंट (लीटर) + बाल्टी सुझाव |

साथ में **मेरा रेट** — अपने इलाके के भाव डालें और हर हिसाब में अनुमानित ख़र्चा (₹) पाएँ।

## मुख्य बातें (Features)

- 📴 100% ऑफलाइन — कोई डेटा अपलोड नहीं
- 🌐 द्विभाषी: हिंदी (डिफ़ॉल्ट) + English, लाइव स्विच
- 📐 ft / meter यूनिट टॉगल, भारतीय अंक फ़ॉर्मैट (1,00,000)
- 📤 नतीजा WhatsApp पर शेयर / कॉपी
- 💰 अपने रेट से लागत का अनुमान

## तकनीकी (Tech)

- Flutter (Material 3), `google_fonts` (Noto Sans)
- लोकल स्टोरेज: `shared_preferences`
- मॉनिटाइज़ेशन: `google_mobile_ads` (banner + interstitial), `in_app_review`
- गणना लॉजिक: `lib/core/math/`, यूनिट कन्वर्ज़न: `lib/core/utils/`

## चलाना (Run)

```bash
flutter pub get
flutter run
```

## लॉन्च से पहले ज़रूरी (Pre-launch checklist)

- [ ] AdMob के **असली** App ID + Ad Unit IDs डालें (`lib/core/services/ad_service.dart`, `android/app/src/main/AndroidManifest.xml`) — अभी Google के टेस्ट IDs हैं
- [ ] Privacy Policy का URL जोड़ें + Settings के बटन चालू करें
- [ ] ब्रांडेड ऐप आइकन लगाएँ
- [ ] रिलीज़ signing config (अभी debug key पर है)

> ⚠️ ऐप के सभी नतीजे **अनुमान** हैं — ख़रीद से पहले मिस्त्री/इंजीनियर से सलाह लें।
