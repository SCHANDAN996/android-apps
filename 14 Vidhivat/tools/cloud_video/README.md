# Cloud app recording — Firebase Test Lab

यह व्यवस्था Vidhivat को किसी local PC या Android emulator के बिना चलाती है:

```
GitHub Actions → debug APK build → Firebase Test Lab में APK install
               → Robo UI journey + video recording → GitHub Actions artifact
```

Workflow: `.github/workflows/vidhivat-cloud-video.yml`

## एक बार की सुरक्षित सेटिंग

Google Cloud / Firebase में एक project और Cloud Storage bucket चाहिए। यह खर्च/कोटा वाला third-party service है, इसलिए workflow जान-बूझकर केवल manual run पर चलता है, हर push पर नहीं।

GitHub repository **Settings → Secrets and variables → Actions** में ये दो secrets बनाएं:

| Secret | Value |
|---|---|
| `GOOGLE_CLOUD_SERVICE_ACCOUNT_KEY` | उस Firebase/Google Cloud project के service-account JSON का पूरा content |
| `FIREBASE_RESULTS_BUCKET` | results रखने वाला Cloud Storage bucket नाम, बिना `gs://` |

Service account को Firebase Test Lab चलाने और उसी results bucket को read/write करने की अनुमति चाहिए। Secret, keystore और APK को कभी git में commit न करें।

## चलाना

1. GitHub repository का **Actions** tab खोलें।
2. **Vidhivat cloud app video** workflow चुनें।
3. **Run workflow** दबाएँ।
4. Firebase Test Lab के device model ID और Android API level भरें। Available IDs देखने के लिए जिस मशीन/Cloud Shell में `gcloud` authenticated हो, वहाँ चलाएँ:

```bash
gcloud firebase test android models list
gcloud firebase test android versions list
```

5. Run पूरा होने पर **Artifacts** में `vidhivat-testlab-video-<run-id>` डाउनलोड करें। इसमें `.mp4`, screenshots और logs होंगे।

## क्या install होता है

यह workflow repository source से `app-debug.apk` बनाता है और वही APK Firebase के temporary Android device पर install करता है। यह Play Store से APK नहीं निकालता और किसी आपके real phone पर install नहीं करता।

Robo Test Lab app को auto-explore करता है और recording बनाता है। किसी खास कहानी—जैसे *रोज़ की पूजा में संकल्प*—के लिए अगला सुधार Robo script जोड़ना है, ताकि taps की sequence हर बार एक जैसी रहे। उसके बाद recording में हमारी original voice और approved B-roll को FFmpeg workflow से जोड़ा जा सकता है।
