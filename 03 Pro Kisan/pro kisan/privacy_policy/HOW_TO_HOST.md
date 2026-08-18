# Privacy Policy — होस्ट कैसे करें + Play Console के जवाब

## 📄 फ़ाइल तैयार है
`privacy_policy/index.html` — हिंदी + English दोनों में, 11 KB, कोई बाहरी फ़ाइल नहीं चाहिए।

---

## 🌐 इसे इंटरनेट पर डालने का सबसे आसान तरीक़ा — GitHub Pages (मुफ़्त, 5 मिनट)

Play Store को एक **खुला हुआ URL** चाहिए। GitHub Pages मुफ़्त है और हमेशा चलता है।

### कदम-दर-कदम

1. **github.com** पर जाएँ, लॉगिन करें (आपका पहले से है: `SCHANDAN996`)

2. ऊपर दाएँ **+** → **New repository**
   - Repository name: `prokisan-privacy`
   - **Public** चुनें (ज़रूरी — Private में Pages नहीं चलता)
   - ☑️ **Add a README file** पर टिक करें
   - **Create repository** दबाएँ

3. नए repo में **Add file** → **Upload files**
   - `privacy_policy/index.html` को खींचकर डालें
   - नीचे **Commit changes** दबाएँ

4. ऊपर **Settings** → बाएँ मेन्यू में **Pages**
   - Source: **Deploy from a branch**
   - Branch: **main** , फ़ोल्डर: **/ (root)**
   - **Save** दबाएँ

5. 1-2 मिनट रुकें, फिर उसी पन्ने पर हरे रंग में आपका लिंक दिखेगा:
   ```
   https://schandan996.github.io/prokisan-privacy/
   ```

6. उस लिंक को ब्राउज़र में खोलकर देख लें कि पन्ना ठीक खुल रहा है।

### यही URL दो जगह डालना है

**(क) Play Console में**
Console → आपका ऐप → **App content** → **Privacy policy** → URL चिपकाएँ → Save

**(ख) ऐप के अंदर**
`lib/ui/about_screen.dart` में यह पंक्ति खोजें और URL भरें:
```dart
static const String kPrivacyPolicyUrl = '';
```
भरने पर About में "Privacy Policy" की पंक्ति अपने आप दिखने लगेगी (अभी खाली है इसलिए छिपी है)।

---

## 📋 Play Console → Data Safety फ़ॉर्म के जवाब

⚠️ यह फ़ॉर्म privacy policy से **मेल खाना चाहिए**, वरना ऐप रुक जाता है। कोड देखकर लिखे गए सही जवाब:

### "Does your app collect or share any of the required user data types?"
→ **Yes** (सिर्फ़ सुझाव फ़ॉर्म की वजह से)

### डेटा के प्रकार — क्या-क्या टिक करें

| श्रेणी | टिक करें? | विवरण |
|---|---|---|
| **Personal info → Name** | ✅ हाँ | सुझाव फ़ॉर्म में |
| **Personal info → Phone number** | ✅ हाँ | सुझाव फ़ॉर्म में |
| **Location → Approximate location** | ✅ हाँ | मौसम के लिए |
| **Location → Precise location** | ✅ हाँ | खेत नापने के लिए |
| **Photos and videos → Photos** | ✅ हाँ | पशु फ़ोटो, पत्ती की फ़ोटो |
| **Messages** | ❌ नहीं | |
| **Financial info** | ❌ नहीं | दूध का हिसाब फ़ोन में ही रहता है, भेजा नहीं जाता |
| **Contacts** | ❌ नहीं | ग्राहक सूची आप ख़ुद लिखते हैं, फ़ोन की contact list नहीं पढ़ी जाती |
| **App activity / Web history** | ❌ नहीं | |
| **Device ID** | ❌ नहीं | |

### हर चुनी हुई श्रेणी के लिए आगे के जवाब

**Name और Phone number:**
- Collected: **Yes** · Shared: **No**
- Processed ephemerally? **No**
- Required or optional? → **Optional** (उपयोगकर्ता चाहे तो फ़ॉर्म न भरे)
- Purpose: **App functionality** (और चाहें तो Customer support)

**Approximate + Precise location:**
- Collected: **Yes** · Shared: **No**
  *(⚠️ "Shared" का मतलब Google की भाषा में "किसी तीसरे को दिया"। निर्देशांक Open-Meteo को मौसम लाने भेजे जाते हैं, पर वह ऐप की अपनी सेवा चलाने के लिए है — Google इसे "sharing" नहीं मानता। फिर भी policy में यह साफ़ लिखा है, जो सही तरीक़ा है।)*
- Processed ephemerally? **Yes** (जगह सहेजी नहीं जाती, सिर्फ़ मौसम माँगने में इस्तेमाल होती है)
- Required or optional? **Optional**
- Purpose: **App functionality**

**Photos:**
- Collected: **No** ← फ़ोटो फ़ोन से बाहर नहीं जाती
  *(अगर फ़ॉर्म ज़ोर दे तो: Collected **Yes**, Shared **No**, purpose App functionality, और "data is processed on device only" चुनें)*

### बाक़ी सवाल
- **Is all user data encrypted in transit?** → नीचे ⚠️ पढ़ें
- **Do you provide a way for users to request data deletion?** → **Yes**, ईमेल से (policy में लिखा है)

---

## ⚠️ अपलोड से पहले यह ठीक करना ज़रूरी है

### सुझाव फ़ॉर्म अभी काम नहीं कर रहा — और वही एकमात्र जगह है जहाँ निजी जानकारी जाती है

कोड में सर्वर का पता `http://72.61.235.129/prokisan_api` है — **HTTP, HTTPS नहीं**।

दो बातें:

1. **Android 9 से HTTP अपने आप बंद है।** manifest में `usesCleartextTraffic` की कोई घोषणा नहीं है, इसलिए यह call चुपचाप fail होती है और किसान को "सर्वर एरर" दिखता है। यानी फ़ीचर टूटा हुआ है।

2. **Play Store में एक सवाल है: "Is all user data encrypted in transit?"**
   HTTP पर नाम और फ़ोन नंबर भेजना = बिना ताले के भेजना। यहाँ **Yes नहीं कह सकते**, और No कहने पर Google सवाल उठाएगा।

### तीन रास्ते

| रास्ता | क्या करना है | मेहनत |
|---|---|---|
| **A. सर्वर पर HTTPS लगाएँ** ⭐ | VPS पर मुफ़्त Let's Encrypt SSL (certbot से 10 मिनट), फिर `server_config.dart` में `https://` कर दें | कम |
| **B. फ़ीचर अभी हटा दें** | सुझाव फ़ॉर्म को v1.0 से निकाल दें, ईमेल का लिंक काफ़ी है। तब Data Safety में **"No data collected"** — सबसे आसान | बहुत कम |
| **C. cleartext चालू करें** | ❌ **यह मत करिए** — निजी जानकारी बिना सुरक्षा के जाएगी और Play Store में दिक़्क़त होगी | — |

**मेरी सलाह:** अगर VPS पर domain है तो **A** (सही हल)। जल्दी launch करना है तो **B** — फिर privacy policy में से "सुझाव फ़ॉर्म" वाला हिस्सा हटाकर "कोई डेटा एकत्र नहीं" लिख देंगे, और Data Safety का पूरा फ़ॉर्म एक मिनट में भर जाएगा।

बताइए कौन सा — मैं वैसा कर दूँगा।

---

## ✅ Play Store की बची हुई चीज़ें

- [x] App icon 512×512 — `play_store_assets/icon_512.png`
- [x] Feature graphic 1024×500 — `play_store_assets/feature_graphic.png`
- [x] Privacy policy — यह फ़ाइल (host करना बाक़ी)
- [x] Keystore + signed AAB
- [ ] **Screenshots** — फ़ोन से 4-8 लेने हैं
- [ ] **Privacy policy URL** — GitHub Pages पर डालकर दो जगह भरना
- [ ] **सुझाव फ़ॉर्म का फ़ैसला** — ऊपर A या B
- [ ] Content rating questionnaire (Console में, आसान — सब "No")
- [ ] Government apps declaration → **"No, this app is not created for or on behalf of a government entity"**
