# जमीन नापी v1.1.0 — Play Console पर चढ़ाने की पूरी चेकलिस्ट

> **पैकेज कभी मत बदलिए:** `com.chandansingh.kisan_calculator` ही रहेगा।
> यह पहले से live ऐप की पहचान है — बदलते ही Play इसे बिल्कुल नया ऐप मान लेगा,
> पुराने installs को कभी update नहीं मिलेगा और rating/reviews शून्य से शुरू होंगे।
> पैकेज सिर्फ़ Play के URL में दिखता है, users को नहीं — इसलिए नाम बदलने के लिए
> उसे छूने की ज़रूरत ही नहीं है।

---

## A) पहले ये तीन चीज़ें (सबसे ज़रूरी)

### 1. नई Privacy Policy publish कीजिए ⚠️
जो पेज अभी Play पर linked है वो **आज भी लिखता है कि ऐप में विज्ञापन नहीं हैं** —
जबकि AdMob है। यह Play की नज़र में deceptive claim है और ऐप रुक सकता है।

- `privacy_policy_blogger.txt` का पूरा text कॉपी कीजिए
- Blogger पर उसी पेज को edit कीजिए (URL वही रहे):
  `https://kisancalculatorprivacypolicy.blogspot.com/2026/07/kisan-calculator-privacy-policy.html`
- Publish दबाइए, फिर पेज खोलकर एक बार पढ़ लीजिए कि AdMob वाला हिस्सा दिख रहा है

### 2. Store listing का नाम बदलिए
Play Console अभी भी **"किसान कैलकुलेटर - भूमि नापें"** दिखा रहा है। यही नाम
लोगों को दिखता है (ऐप के अंदर का नाम पहले से "जमीन नापी" है)।

**Play Console → Grow users → Main store listing → App name** में डालिए:
```
जमीन नापी: खेत नाप कैलकुलेटर
```
साथ ही short व full description भी वहीं बदलिए (नीचे section C)।

### 3. नया icon चढ़ाइए
**Main store listing → App icon** में `play_store_assets/icon-512.png` डालिए —
यह नया गोल सुनहरा badge logo है, सफ़ेद background हटाकर बनाया गया।
(ऐप के अंदर का launcher icon AAB में पहले से आ जाएगा।)

---

## B) Data safety form (App content → Data safety)

पहले से सही भरा है तो बस verify कर लीजिए:

- **Does your app collect or share any user data?** → **Yes**
  (AdMob विज्ञापनों के लिए device/advertising ID लेता है)
- **Data types collected:**
  - *Device or other IDs* → **Advertising ID** → Collected: Yes, Shared: Yes
    → Purpose: **Advertising or marketing**
  - बाक़ी सब (Name, Email, Location, Photos, Contacts, Files) → **No**
- **Is data encrypted in transit?** → **Yes**
- **Can users request data deletion?** → कोई व्यक्तिगत डेटा जमा ही नहीं होता

**Permissions:** कोई खतरनाक permission नहीं। `INTERNET`, `ACCESS_NETWORK_STATE`,
`AD_ID` और Ad Services वाली permissions Google Mobile Ads SDK अपने आप जोड़ता है।

---

## C) Listing का text

तीनों फाइलों से सीधा कॉपी-पेस्ट कीजिए — इनकी लंबाई जाँची जा चुकी है:

| कहाँ | फ़ाइल | लंबाई |
|---|---|---|
| App name | `app-name.txt` | 28 / 30 |
| Short description | `short-description.txt` | 65 / 80 |
| Full description | `full-description.txt` | 2592 / 4000 |

दोबारा जाँचना हो तो project की जड़ से:
```
dart run tool/check_store_listing.dart
```
यह Play की तरह UTF-16 में गिनता है (देवनागरी हाथ से गिनने पर धोखा देती है —
पहले short description 86 की निकली थी जबकि guide में 79 लिखा था), और
"कोई परमिशन/डेटा नहीं" जैसे पुराने झूठे दावे भी पकड़ता है।

### क्षेत्रीय listing (Manage translations)
- **Marathi:** `जमीन मोजणी: शेत व प्लॉट कॅल्क्युलेटर`
- **Bengali:** `জমি নাপি: জমির পরিমাপ ও হিসাব`
- **Gujarati:** `જમીન માપણી: ખેતર ક્ષેત્રફળ કેલ્ક્યુલેટર`
- **Punjabi:** `ਜ਼ਮੀਨ ਮਿਣਤੀ: ਖੇਤ ਤੇ ਪਲਾਟ ਕੈਲਕੁਲੇਟਰ`

---

## D) Release notes ("What's new", ज़्यादा से ज़्यादा 500 अक्षर)

**हिंदी:**
```
• अब पूरा ऐप 9 भाषाओं में — हर बटन, नतीजा और रिपोर्ट तक
• ऐप अपने आप आपके फोन की भाषा में खुलता है
• नया लोगो 🌾
• 4-भुजा खेत: विकर्ण किस कोने से नापें, अब साफ़ लिखा है
• बंटवारे में हिस्सेदार हटाने पर नाम-अनुपात गड़बड़ होना ठीक किया
• तमिल, तेलुगु, कन्नड़ में टेक्स्ट कटने की दिक्कत ठीक
```

**English:**
```
• The whole app is now in 9 languages — every button, result and report
• Opens in your phone's language automatically
• New logo 🌾
• 4-sided plot: it now says exactly which corner to measure the diagonal from
• Fixed shareholder names/ratios shifting when one was removed
• Fixed clipped text in Tamil, Telugu and Kannada
```

---

## E) AAB बनाना और चढ़ाना

```
flutter build appbundle --release
```
फ़ाइल यहाँ बनेगी: `build/app/outputs/bundle/release/app-release.aab`

1. **Play Console → Test and release → Production → Create new release**
2. AAB upload कीजिए — Play अपने आप **versionCode 6 / 1.1.0** पकड़ेगा
   (live 5 से ज़्यादा है, इसलिए reject नहीं होगा)
3. Release name: `1.1.0 (6)` · "What's new" में ऊपर वाला text
4. **Save → Review release → Start rollout to Production**

### targetSdk
Play का **31 अगस्त 2026** वाला नोटिस (Update your target API level) इस release से
पूरा हो जाता है — `targetSdk = 36` कर दिया गया है।

---

## F) दो चेतावनियाँ

- **`key.properties` और keystore (`.jks`) कभी किसी को मत भेजिए, GitHub पर मत डालिए।**
  इनमें keystore password है; खो या लीक हुआ तो ऐप दोबारा कभी update नहीं होगा।
  इनका backup 2-3 सुरक्षित जगह रखिए।
- **Screenshots:** पुराने चल जाएँगे, पर अब ऐप 9 भाषाओं में है और logo नया है —
  मौका मिले तो 2-3 नए screenshot डाल दीजिए, install rate बेहतर होता है।
