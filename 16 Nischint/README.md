# निश्चिंत (Nischint)

घर का हर काम, आप निश्चिंत। पहला वर्ज़न: वाराणसी में घरों पर लगे सोलर की सफ़ाई, जाँच और रिपेयर की बुकिंग, और सोलर वेंडरों के लिए शिकायत दर्ज करना। बुकिंग WhatsApp पर जाती है और फ़ोन में सेव रहती है।

पूरा UI/UX और कंटेंट प्लान: [PLAN.md](PLAN.md)

## APK कैसे मिलेगा
हर push पर GitHub Actions का **Nischint Android APK** workflow चलता है। Actions टैब में उस रन को खोलें, नीचे **nischint-debug-apk** डाउनलोड करें, ZIP खोलकर `app-debug.apk` फ़ोन में इंस्टॉल करें।

## अपने कंप्यूटर पर चलाना
`android/` फ़ोल्डर रिपॉज़िटरी में नहीं रखा गया, वह `flutter create` से बनता है:

```bash
cd "16 Nischint"
flutter create --platforms=android --org com.schandan996 --project-name nischint .
git checkout -- lib test pubspec.yaml analysis_options.yaml
flutter pub get
flutter run
```

## ढाँचा
- `lib/content/` — रेट, सेवाएँ, इलाके, WhatsApp नंबर (`config.dart`)
- `lib/models/` — बुकिंग, शिकायत, प्रोफ़ाइल
- `lib/app/` — थीम, ऐप का डेटा (`AppState`), नीचे के टैब
- `lib/screens/customer/` — घर वाले की स्क्रीनें
- `lib/screens/vendor/` — वेंडर की स्क्रीनें
- `lib/screens/common/` — मदद, सेटिंग
- `lib/widgets/common.dart` — बटन, कार्ड, चिप जैसे साझा हिस्से

## लॉन्च से पहले
`lib/content/config.dart` में असली WhatsApp और कॉल नंबर डालें।
