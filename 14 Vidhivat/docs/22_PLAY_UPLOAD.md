# 22 — Play Store पर चढ़ाने की पूरी विधि

> **यह फ़ाइल एक बार का काम है।** पहली upload के बाद इसकी ज़रूरत सिर्फ़
> तब पड़ेगी जब कोई नया product या नया track जोड़ना हो।

**बना:** 9 सितम्बर 2026

---

## 🎯 अभी की हालत — एक नज़र में

| क्या | हालत | कौन करेगा |
|---|---|---|
| ऐप का कोड | ✅ तैयार, 905 जाँचें पास | — |
| Icon 512×512 | ✅ बना हुआ | — |
| Feature graphic 1024×500 | ✅ बना हुआ | — |
| **Privacy policy** | ✅ Blogger पर publish हो चुकी, खुलकर दिखती है | — |
| Listing का पूरा पाठ | ✅ `docs/19_PLAY_LISTING.md` | — |
| Data safety के जवाब | ✅ `docs/19` §6 | — |
| Screenshot (8) | ✅ `app/play_store_assets/screenshots/play/` — 1080 × 1920 | — |
| Release signing config | ✅ `android/app/build.gradle.kts` में लगा | — |
| **चाबी (keystore)** | 🔴 **नहीं बनी** | 🔴 **आप** |
| version | ✅ `1.0.0+1` कर दिया | — |
| **`.aab` बनाना** | ⬜ चाबी के बाद | — |
| **Play Console का सारा काम** | 🔴 बाक़ी | 🔴 **आप** |

---

# चरण 1 — चाबी बनाइए 🔴 यह सिर्फ़ आप कर सकते हैं

> ### ⚠️ यह सबसे ज़रूरी चरण है, और सबसे ज़्यादा ग़लती यहीं होती है
>
> **यह चाबी खो गई तो ऐप कभी अपडेट नहीं हो पाएगा।** न आप, न Google —
> कोई कुछ नहीं कर सकता। नया ऐप बनाना पड़ेगा, और सारे यूज़र छूट जाएँगे।
>
> इसीलिए यह काम मैंने नहीं किया — पासवर्ड आपका है, और वो आपके पास ही
> रहना चाहिए, किसी चैट में नहीं।

एक बार यह चलाइए (PowerShell में, `14 Vidhivat\app\android` के अंदर):

```bash
keytool -genkey -v -keystore vidhivat-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vidhivat
```

यह पूछेगा:

| सवाल | क्या भरें |
|---|---|
| Enter keystore password | **अपना पासवर्ड** — याद रखिए, लिख लीजिए |
| Re-enter new password | वही |
| first and last name | Chandan Singh |
| organizational unit | MASS APP |
| organization | MASS APP |
| City / State / Country code | अपना शहर, राज्य, `IN` |
| Is CN=… correct? | `yes` |

फिर `14 Vidhivat\app\android\key.properties` नाम की फ़ाइल बनाइए:

```properties
storePassword=<जो पासवर्ड ऊपर डाला>
keyPassword=<वही पासवर्ड>
keyAlias=vidhivat
storeFile=vidhivat-upload.jks
```

> 🟠 **`storeFile` का रास्ता किस जगह से नापा जाता है?**
>
> gradle का अपना `file()` रास्ता `android/app/` से नापता है, जबकि चाबी
> और `key.properties` दोनों `android/` में रहती हैं। **9 सितम्बर को
> पहला build इसी पर गिरा** — और ग़लती दस मिनट के build के आख़िर में पता
> चली:
>
> ```
> Keystore file '...ndroidppidhivat-upload.jks' not found
> ```
>
> ✅ **अब `build.gradle.kts` तीनों जगह ढूँढ़ता है** — पूरा रास्ता,
> `android/`, और `android/app/`। इसलिए ऊपर वाला सादा नाम अब चलता है।
> न मिले तो गड़बड़ी साफ़ लिखकर आती है कि कहाँ-कहाँ देखा गया।

### 🔒 तीन बातें, और तीनों ज़रूरी

1. **`.jks` और `key.properties` git में कभी नहीं जाएँगी** — `.gitignore`
   में पहले से हैं। जाँच लीजिए: `git status` में इनका नाम न दिखे।
2. **दोनों का बैकअप लीजिए** — pen drive, या अपने Google Drive के निजी
   फ़ोल्डर में। घर के कंप्यूटर के साथ खो गईं तो ऐप गया।
3. **पासवर्ड कहीं और भी लिख लीजिए** — डायरी में, या password manager में।

> ✅ **Play App Signing:** Google आजकल अपनी अलग चाबी से ऐप को दोबारा sign
> करता है। ऊपर वाली आपकी **upload key** है। यह अच्छी बात है — अगर upload
> key खो जाए तो Google से बदलवाई जा सकती है। पर **तब भी बैकअप ज़रूरी है**,
> क्योंकि बदलवाने में दिन लगते हैं।

---

# चरण 2 — version ✅ हो चुका

`app/pubspec.yaml` में अब:

```yaml
version: 1.0.0+1
```

- `1.0.0` = यूज़र को दिखने वाला **versionName**
- `+1` = Play का **versionCode** — हर अगली upload पर **बढ़ाना ज़रूरी है**
  (1 → 2 → 3…)। वही नंबर दोबारा भेजने पर Play मना कर देता है।

> ⚠️ जमीन नापी में यही चूक हो चुकी है (→ अलग repo)। हर upload से पहले
> `+` वाला अंक बढ़ा है या नहीं, यह देख लेना।

---

# चरण 3 — `.aab` बनाइए

चाबी बन जाने के बाद:

```bash
flutter build appbundle --release
```

फ़ाइल यहाँ मिलेगी:

```
14 Vidhivat\app\build\app\outputs\bundle\release\app-release.aab
```

### ⚠️ `.aab` का आकार देखकर घबराइए मत

फ़ाइल लगभग **58 MB** दिखेगी *(9 सितम्बर को नापी: 58.4 MB)*। **यूज़र को
इतना नहीं जाता।** उसमें तीनों ABI और debug-symbols हैं — Play हर फ़ोन को
सिर्फ़ उसका हिस्सा भेजता है।

```
यूज़र का असली डाउनलोड ≈ 15 MB
```

*(नापा हुआ — `docs/04_NEXT.md` का "APK का आकार" वाला हिस्सा देखिए।
सिर्फ़ arm64 वाली APK 23.5 MB बनी थी।)*

⛔ **`.apk` मत डालिए, `.aab` ही डालिए।**

### ⏱ इसमें वक़्त लगता है — बहुत

इस कंप्यूटर पर तीनों ABI वाला bundle बनने में **लगभग पौने दो घंटे**
लगे। यह अटका नहीं है, बस धीमा है। सिर्फ़ arm64 वाली APK आठ मिनट में
बनती है — पर **वो Play के लिए नहीं है**, सिर्फ़ फ़ोन पर जाँचने के लिए।

### 🟠 एक चेतावनी जो आएगी, और जिससे रुकना नहीं

```
Release app bundle failed to strip debug symbols from native libraries.
```

build फिर भी पूरा होता है और `.aab` बन जाती है — इसी वजह से वो 58 MB की
है, दबने के बाद और छोटी होती। Play इसे मना नहीं करता। ठीक करना हो तो
NDK का `llvm-strip` रास्ते में लाना पड़ेगा; अभी उसकी ज़रूरत नहीं।

---

# चरण 4 — Privacy policy ✅ Blogger पर चढ़ चुकी

**यही पता Play Console में डालना है** (9 सित को जाँचा — खुलकर दिखता है,
दोनों भाषाएँ, तालिका समेत):

```
https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html
```

> 🟠 पते में `root-bg-12151c` इसलिए है कि पहली बार शीर्षक वाले ख़ाने में
> CSS चली गई थी। **पन्ना ठीक है, सिर्फ़ पता भद्दा है।** बदलना हो तो
> **Play Console में डालने से पहले** बदलिए — बाद में बदला तो Play के
> पास मरा हुआ लिंक रह जाएगा।

<details>
<summary>पहली बार कैसे चढ़ाई थी (आगे कभी दोबारा करनी पड़े तो)</summary>


Play बिना privacy policy URL के listing नहीं लेता।

**डेवलपर का फ़ैसला (9 सित): नीति Blogger पर जाएगी**, GitHub Pages पर
नहीं। इसलिए चिपकाने लायक़ रूप बनाकर रखा है:

```
app/play_store_assets/privacy_policy_blogger.html
```

### कैसे चढ़ाएँ

1. Blogger → **नई पोस्ट**
2. शीर्षक: *विधिवत — गोपनीयता नीति / Vidhivat Privacy Policy*
3. ऊपर बाएँ **"Compose" की जगह "HTML view"** चुनिए
   *(यह क़दम छूटा तो सारे टैग अक्षरों की तरह छप जाएँगे)*
4. ऊपर वाली फ़ाइल का सब कुछ वहाँ चिपकाइए → **Publish**
5. जो पता मिले वही Play Console के **Privacy policy URL** में डालिए

### ⚠️ नीति अब दो जगह है, और दोनों को साथ चलना है

| फ़ाइल | किसके लिए |
|---|---|
| `privacy_policy.html` | **असली** — पूरी फ़ाइल, ब्राउज़र में सीधे खुलती है |
| `privacy_policy_blogger.html` | Blogger में चिपकाने वाला रूप — **अपने आप बनता है** |

नीति बदलनी हो तो **पहले असली बदलिए**, फिर:

```bash
python tools/banao_blogger_niti.py
```

फिर Blogger की पोस्ट भी दोबारा चिपकाइए। यह भूले तो reviewer वही पढ़ेगा
जो Blogger पर पड़ा है — यानी पुरानी बात।

⚠️ **URL खुलकर दिखना चाहिए** — Play का reviewer उसे खोलकर देखता है।
पोस्ट **Publish** हुई है या सिर्फ़ Draft में पड़ी है, यह ज़रूर जाँच
लीजिए; draft का पता बाहर वालों के लिए नहीं खुलता।

---

</details>

---

# चरण 5 — Play Console 🔴 पूरा हिस्सा आपका

### 5.1 ऐप बनाइए
**Create app** → नाम `Vidhivat` · भाषा हिंदी · **App** · **Free**

### 5.2 Store listing
सारा पाठ `docs/19_PLAY_LISTING.md` से copy-paste है:

| खाना | कहाँ से |
|---|---|
| App name | §1 |
| Short description | §2 |
| Full description | §3 (3,578 अक्षर) |
| App icon | `play_store_assets/selected/vidhivat_diya_logo_512.png` |
| Feature graphic | `play_store_assets/selected/vidhivat_ganesh_banner_1024x500.png` |
| Phone screenshots | `play_store_assets/screenshots/` |

### 5.3 Data safety
`docs/19` §6 — तीनों जवाब **"नहीं"**।

⚠️ **स्थान की अनुमति** को "collected" मत कहिए — वो फ़ोन से बाहर जाती ही
नहीं। फ़ॉर्म में उसे *app functionality, on-device only* की तरह समझाइए।

### 5.4 Content rating
प्रश्नावली भरिए — हिंसा नहीं, यौन सामग्री नहीं, नशा नहीं, जुआ नहीं।
**"Reference to religion"** पर हाँ। नतीजा आमतौर पर **Everyone / 3+** आता है।

### 5.5 App content के बाक़ी खाने
- **Ads:** ❌ नहीं (→ D-053)
- **Target audience:** 18+ रखना सबसे सीधा है (बच्चों वाली नीतियाँ बचती हैं)
- **News app:** नहीं
- **Government app:** नहीं
- **Financial features:** नहीं
- **Privacy policy URL:** चरण 4 वाला

---

# चरण 6 — 🔴 दक्षिणा के सात products

**यह किए बिना दक्षिणा का बटन मरा हुआ रहेगा** — `queryProductDetails`
ख़ाली लौटेगा और यूज़र को *"अभी Play से बात नहीं हो पा रही"* दिखेगा।

### 6.1 पहले payments profile
**Setup → Payments profile** — बैंक और टैक्स की जानकारी। इसमें Google की
तरफ़ से जाँच में कुछ दिन लगते हैं, इसलिए **यह सबसे पहले शुरू कीजिए।**

### 6.2 फिर सातों products
**Monetize → In-app products → Create product**, सब **Consumable**:

| Product ID | दाम |
|---|---|
| `dakshina_11` | ₹11 |
| `dakshina_21` | ₹21 |
| `dakshina_51` | ₹51 |
| `dakshina_101` | ₹101 |
| `dakshina_251` | ₹251 |
| `dakshina_501` | ₹501 |
| `dakshina_1100` | ₹1100 |

⚠️ **ID हूबहू यही रखिए।** एक अक्षर भी बदला तो वो चिप काम नहीं करेगी —
ये ID कोड में लिखी हैं (`lib/services/dakshina_service.dart`)।

---

# चरण 7 — internal testing, अलग account के बिना

> **"internal testing वाला account नहीं है"** — इसकी ज़रूरत ही नहीं।
> **आपका अपना Gmail ही tester बन सकता है**, वही जिससे Play Console
> चलता है। Google इसे मना नहीं करता।

### 7.1 शर्त — फ़ोन पर वही Gmail चालू हो

🔑 **यह इकलौती असली अड़चन है।** internal testing का लिंक उसी Google
account से खुलता है जो **tester की सूची में है और फ़ोन के Play Store
में चालू है।**

आपके यहाँ दो पते हैं — Play Console वाला, और
`all.chandansingh@gmail.com`। फ़ोन में Play Store → ऊपर दाएँ अपनी
तस्वीर दबाकर देख लीजिए कि **कौन सा चालू है**, और *वही* tester में
डालिए। ग़लत डाला तो लिंक खुलेगा ही नहीं और लगेगा कि Play ने कुछ
बिगाड़ दिया।

*(दोनों पते tester की सूची में डाल देना सबसे सुरक्षित है — कोई नुक़सान
नहीं।)*

### 7.2 ख़रीद मुफ़्त में जाँचने का तरीक़ा — License testing

**Setup → License testing** में अपना Gmail डाल दीजिए।

इसके बाद ₹11 वाली दक्षिणा **सचमुच पैसे नहीं काटेगी** — Play अपना
"test card" दिखाएगा, ख़रीद पूरी होगी, ऐप को वही जवाब मिलेगा जो असली
ख़रीद में मिलता, और बैंक से कुछ नहीं जाएगा।

⚠️ **यह करना ही चाहिए।** वरना जाँचने के लिए हर बार अपने ही पैसे कटवाने
पड़ेंगे, और refund माँगना पड़ेगा।

### 7.3 क्रम

1. **Testing → Internal testing → Create new release**
2. `.aab` upload कीजिए *(`.apk` नहीं)*
3. **Testers** में अपनी सूची बनाइए, उसमें अपना Gmail डालिए
4. ऊपर **Copy link** से लिंक लेकर फ़ोन में खोलिए → *"Become a tester"*
5. वहीं से Play Store पर ऐप मिलेगा → install
6. एक पूजा पूरी कीजिए → दक्षिणा का पन्ना → **₹11 पर ख़रीद करके देखिए**

> ⚠️ **In-app purchase debug build में कभी नहीं चलती।** असली track,
> असली Play account, असली फ़ोन — तभी पता चलेगा कि सातों product सही
> ID से बने हैं। दक्षिणा जाँचने का यही इकलौता तरीक़ा है।

7. सब ठीक लगे तभी **Production → Create new release**

### 🔴 7.4 एक नियम जो पूरा हफ़्ता खा सकता है — पहले देख लीजिए

नवंबर 2023 के बाद बने **निजी (personal) डेवलपर account** पर Google एक
शर्त लगाता है: production से पहले **12 tester, लगातार 14 दिन** closed
testing।

**आपके account पर शायद यह लागू नहीं** — जमीन नापी उसी account से Play
पर चढ़ चुकी है, यानी वो पुराना और आज़माया हुआ है। पर मान मत लीजिए:

> ऐप बनाने के बाद Play Console के **Dashboard** पर देखिए। अगर
> *"Run a closed test with 12 testers for 14 days"* जैसी कोई शर्त
> दिखे — तो production का रास्ता उसी से होकर जाएगा, और **14 दिन पहले
> से गिनने शुरू कर देने चाहिए।**

अगर शर्त दिखे तो internal testing के साथ-साथ closed testing भी उसी दिन
शुरू कर दीजिए — दोनों साथ चल सकते हैं।

---

## 📋 चढ़ाने से ठीक पहले की आख़िरी सूची

- [ ] चाबी बनी, और उसका **बैकअप** भी हुआ
- [ ] `key.properties` बनी, और `git status` में नहीं दिखती
- [x] version `1.0.0+1` किया ✅
- [ ] `flutter test` — 905 जाँचें पास
- [ ] `.aab` बनी (`.apk` नहीं)
- [ ] Privacy policy का URL ब्राउज़र में खुलकर दिखता है
- [ ] Data safety में तीनों "नहीं"
- [ ] सातों products बने, ID हूबहू
- [ ] payments profile मंज़ूर हुआ
- [ ] internal testing में **एक असली ख़रीद** करके देखी

---

## जो इस रिलीज़ में जान-बूझकर नहीं है

ये कमियाँ नहीं, फ़ैसले हैं — कोई पूछे तो जवाब तैयार रहे:

- **शुभ मुहूर्त की तारीख़ें** — इंजन बना है पर रोका हुआ है (→ D-019)।
  गुरु/शुक्र का अस्त नहीं निकलता। ऐप सिर्फ़ *"कौन से दिन टालने हैं"*
  बताता है (→ D-059)।
- **मंत्रों की रिकॉर्डिंग** — एक भी नहीं है, और ऐप कहीं वादा भी नहीं
  करता (→ D-056)।
- **17 कदमों पर मंत्र ख़ाली** — 5 आचार्य के काम हैं, 6 लोकाचार जिनका
  मंत्र है ही नहीं (→ D-056, `docs/21`)।
- **पंडित जी की मुहर बाक़ी** — `docs/17_PANDIT_JI_KE_LIYE.md` की बैठक
  अभी होनी है।
