# 🔑 Google Drive backup चालू करने की विधि

> कोड तैयार है, पर **तब तक चुप रहेगा** जब तक नीचे का setup न हो जाए।
> तब तक ऐप पहले जैसा चलता रहेगा — कुछ टूटेगा नहीं।
>
> कुल समय: **20-30 मिनट**। यह काम सिर्फ़ आप कर सकते हैं, क्योंकि इसमें
> आपके Google खाते में लॉगिन करना पड़ता है।

---

## पहले समझ लीजिए — data जाएगा कहाँ

किसान का हिसाब **उसके अपने Google खाते** में जाता है, हमारे सर्वर पर नहीं।

Drive के एक **छिपे हुए फ़ोल्डर** (`appDataFolder`) में, जो —

- किसान की Drive में कहीं **दिखता नहीं** (उसकी फ़ाइलें गंदी नहीं होतीं)
- सिर्फ़ **यही ऐप** पढ़ सकता है, कोई दूसरा ऐप नहीं
- ऐप uninstall करने पर भी **बचा रहता है** ← यही असली फ़ायदा है

हमें उसका data दिखता भी नहीं। हम सिर्फ़ रास्ता बनाते हैं।

---

> ℹ️ **Console का रूप बदल गया है।** पहले यह "APIs & Services → OAuth consent
> screen" था; अब बाईं ओर **"Google Auth Platform"** नाम से अलग जगह है।
> नीचे नए रूप के हिसाब से लिखा है।

## क़दम 1 — Google Cloud में project बनाइए ✅

1. खोलिए: **https://console.cloud.google.com/**
2. ऊपर बाईं ओर project चुनने वाली पट्टी → **New Project**
3. नाम: `Pro Kisan` → **Create**
4. बनने के बाद उसी project को चुन लीजिए

---

## क़दम 2 — Google Auth Platform भरिए

बाएँ मेन्यू में **Google Auth Platform → Overview** पर *"not configured yet"*
लिखा दिखेगा। **Get started** दबाइए और यह भरिए:

### 1️⃣ App Information
| खाना | क्या डालें |
|---|---|
| App name | `Pro Kisan` |
| User support email | `all.chandansingh@gmail.com` |

→ **Next**

### 2️⃣ Audience
**External** चुनिए → **Next**

> (Internal सिर्फ़ Google Workspace वालों के लिए है — आम Gmail खाते पर वह
> विकल्प काम नहीं करता।)

### 3️⃣ Contact Information
`all.chandansingh@gmail.com` → **Next**

### 4️⃣ Finish
Google की policy वाला बक्सा चुनिए → **Create**

---

## क़दम 3 — Drive API चालू कीजिए

1. ऊपर खोज पट्टी में लिखिए: `Google Drive API`
2. उस पर जाइए → **Enable**

> यह न किया तो sign-in तो हो जाएगा पर backup चढ़ेगा नहीं।

---

## क़दम 4 — scope जोड़िए (सबसे ज़रूरी)

**Google Auth Platform → Data Access** → **Add or remove scopes**

नीचे "Manually add scopes" वाले खाने में यह चिपकाइए:

```
https://www.googleapis.com/auth/drive.appdata
```

→ **Add to table** → **Update** → **Save**

> ⚠️ **सिर्फ़ यही एक scope।** पूरी Drive वाला (`.../auth/drive` या
> `drive.file`) मत चुनिए — उस पर Google हर साल **महँगा security assessment**
> करवाता है और मंज़ूरी में महीनों लगते हैं। `drive.appdata` उस झंझट से
> पूरी तरह बाहर है।

---

## क़दम 5 — अपने आप को test user बनाइए

**Google Auth Platform → Audience** → नीचे **Test users** → **Add users**
→ `all.chandansingh@gmail.com` → Save

> जब तक ऐप "Testing" हालत में है, सिर्फ़ यहाँ लिखे ईमेल ही sign-in कर पाएँगे।
> बाद में **Publish app** दबाकर सबके लिए खोल दीजिएगा।

---

## क़दम 6 — OAuth client बनाइए (यहीं SHA-1 चाहिए)

**Google Auth Platform → Clients** → **+ Create client**

- Application type: **Android**
- Package name: **`com.prokisan.app`**
- SHA-1: नीचे वाली पंक्ति चिपकाइए

यह **दो बार** कीजिए — दो अलग client, दो अलग SHA-1:

### आपके SHA-1 (7 अगस्त 2026 को निकाले हुए)

**(क) रिलीज़ वाला** — जो Play Store पर जाएगा
```
56:C4:25:96:99:75:85:61:78:B6:A7:68:9E:2C:7D:F1:C1:51:32:AC
```
Name: `Pro Kisan Release`

**(ख) जाँच वाला** — अपने फ़ोन/कंप्यूटर से test करने के लिए
```
FD:8B:87:92:B8:4A:92:1C:99:2E:C2:A7:CD:FC:16:FD:BD:F0:CB:2E
```
Name: `Pro Kisan Debug`

> ये अपने आप निकाले गए थे इन आदेशों से (कभी दोबारा चाहिए तो):
> ```bash
> keytool -list -v -keystore android/app/prokisan-upload.jks -alias prokisan
> keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
> ```

### ⚠️ (ग) तीसरा SHA-1 — Play Store वाला

अगर आपने **Play App Signing** चालू किया है (आम तौर पर होता है), तो Play
अपनी अलग key से दोबारा दस्तख़त करता है। वह SHA-1 यहाँ मिलेगा:

**Play Console → आपका ऐप → Setup → App integrity → App signing key certificate**

**यह भी डालना ज़रूरी है** — वरना आपके फ़ोन पर तो चलेगा, पर **Play Store से
install करने वाले किसानों के यहाँ sign-in चलेगा ही नहीं**। यह सबसे आम और
सबसे देर से पकड़ में आने वाली ग़लती है।

> ऐप अभी Play Store पर चढ़ा नहीं है, इसलिए यह अभी नहीं मिलेगा। **पहली बार
> AAB चढ़ाने के बाद** यहाँ आकर तीसरा client बना दीजिएगा।

> इसमें कोई फ़ाइल download करके ऐप में डालने की ज़रूरत **नहीं** है।
> Android पर `google_sign_in` package package-name + SHA-1 से ही पहचान
> लेता है। इसीलिए कोड में कोई key नहीं रखी।

---

## क़दम 7 — जाँचिए

1. नई APK बनाइए और फ़ोन में डालिए
2. ऐप → **सेटिंग** → *"Google खाते में सुरक्षित रखें"* → खाता चुनिए
3. जुड़ जाए तो वहीं ईमेल दिखने लगेगा
4. ऐप बंद कीजिए, फिर खोलिए — *"आख़िरी बार सुरक्षित: अभी"* दिखना चाहिए

**न चले तो:** SHA-1 दोबारा मिलाइए। 90% गड़बड़ी वहीं होती है — या तो ग़लत
keystore का लिया गया, या Play वाला डालना छूट गया।

---

## ⚠️ क़दम 8 — Play Store के दो फ़ॉर्म बदलने होंगे

**यह छोड़ा तो policy का उल्लंघन होगा।** अभी ऐप कहता है कि data कहीं नहीं
जाता — Drive backup चालू होते ही वह बात सच नहीं रहेगी।

### (क) Privacy policy

आपका पन्ना: **https://prokishan.blogspot.com/2026/07/pro-kishan.html**

अभी वहाँ लिखा है:

> We do not upload, share, sync, or sell any data.

उसे बदलकर कुछ ऐसा कीजिए:

> **Google Drive backup (आपकी मर्ज़ी से)**
>
> अगर आप अपना Google खाता जोड़ते हैं, तो आपके हिसाब की एक backup फ़ाइल
> **आपकी अपनी Google Drive** के छिपे हुए app फ़ोल्डर में रखी जाती है।
>
> • यह फ़ाइल सिर्फ़ आपकी है — हम उसे पढ़ नहीं सकते
> • वह किसी और सर्वर पर नहीं जाती
> • खाता न जोड़ें तो कुछ भी upload नहीं होता
> • जोड़ा हुआ खाता आप सेटिंग से कभी भी हटा सकते हैं

### (ख) Data Safety फ़ॉर्म

**Play Console → App content → Data safety** में बदलिए:

| सवाल | जवाब |
|---|---|
| Does your app collect or share user data? | **Yes** |
| Data types | **Personal info → Email address** (सिर्फ़ खाता जोड़ने के लिए) · **App activity → Other** (हिसाब का backup) |
| Is data transferred off device? | **Yes** — उपयोगकर्ता की अपनी Google Drive में |
| Is data encrypted in transit? | **Yes** (HTTPS) |
| Can users request deletion? | **Yes** — सेटिंग से खाता हटाकर |
| Is this collection optional? | **Yes** — किसान चाहे तभी |

---

## अगर आप यह सब न करना चाहें

कोई बात नहीं। कोड चुप पड़ा रहेगा और ऐप बिल्कुल पहले जैसा चलेगा —

- फ़ोन में backup होता रहेगा (जैसे अभी होता है)
- Android Auto Backup चलता रहेगा (जिनके फ़ोन में Google खाता है)
- **हफ़्ते में एक बार WhatsApp वाली याद** दिखती रहेगी

तब Play Store के फ़ॉर्म भी बदलने की ज़रूरत नहीं — क्योंकि तब सचमुच कुछ
upload नहीं हो रहा।
