# निश्चिंत (Nischint)

घर का हर काम, आप निश्चिंत। पहला वर्ज़न: वाराणसी में घरों पर लगे सोलर की सफ़ाई, जाँच और रिपेयर की बुकिंग, और सोलर वेंडरों के लिए शिकायत दर्ज करना। बुकिंग WhatsApp पर जाती है और फ़ोन में सेव रहती है।

पूरा UI/UX और कंटेंट प्लान: [PLAN.md](PLAN.md) · शुरुआत: [START_HERE.md](START_HERE.md)

## APK कैसे मिलेगा
हर push पर GitHub Actions का **Nischint Android APKs** workflow चलता है। Actions टैब में आख़िरी सफल रन खोलें, नीचे **nischint-customer-debug-apk** (ग्राहक ऐप) या **nischint-partner-debug-apk** (पार्टनर ऐप) डाउनलोड करें, ZIP खोलकर `app-debug.apk` फ़ोन में इंस्टॉल करें।

## अपने कंप्यूटर पर चलाना
`android/` फ़ोल्डर रिपॉज़िटरी में नहीं रखा गया, वह हर ऐप के फ़ोल्डर में `flutter create` से बनता है:

```bash
# ग्राहक ऐप
cd "16 Nischint/apps/customer"
flutter create --platforms=android --org com.schandan996 --project-name nischint .
git checkout -- lib test pubspec.yaml analysis_options.yaml
flutter pub get
flutter run

# पार्टनर ऐप
cd "16 Nischint/apps/partner"
flutter create --platforms=android --org com.schandan996 --project-name nischint_partner .
git checkout -- lib test pubspec.yaml analysis_options.yaml
flutter pub get
flutter run
```

## ढाँचा
- `packages/nischint_core/` — साझा हिस्सा: थीम, रेट और सेवाएँ (`content/catalog.dart`), नंबर और नाम (`content/config.dart`), इलाके, मॉडल, ऐप का डेटा (`AppState`), WhatsApp, साझा विजेट, मदद स्क्रीन
- `apps/customer/` — निश्चिंत (घर वाले): ऑनबोर्डिंग, होम, सेवा, बुकिंग, मेरी बुकिंग, सेटिंग
- `apps/partner/` — निश्चिंत पार्टनर: वेंडर (शिकायतें, रेट कार्ड) और टेक्नीशियन (ट्रेनिंग `lib/training/`, स्क्रीनें `lib/screens/technician/`)

## लॉन्च से पहले
`packages/nischint_core/lib/content/config.dart` में असली WhatsApp और कॉल नंबर डालें।
