# 🚀 Pro Kisan — Play Store का सारा सामान एक जगह

> 9 अगस्त 2026 · **यही अकेली फ़ाइल खोलिए, बाक़ी यहीं से मिल जाएगा**

App पहले से Console में **Draft** में है — `com.prokisan.app`

---

## 📁 इस folder में क्या है

| फ़ाइल | किस काम की |
|---|---|
| `01_LISTINGS_9_BHASHA.md` | **नौ भाषाओं की पूरी listing** — title, short, full |
| `02_KEYWORDS_ASO.md` | ASO की रणनीति और keyword सूची |
| `03_DATA_SAFETY.md` | Console के App content वाले सारे जवाब |
| `04_RELEASE_NOTES.md` | release notes |
| `05_SCREENSHOTS.md` | कौन सी screenshot किस क्रम में, और कैसे बनीं |
| `06_FAQ.md` | अक्सर पूछे जाने वाले सवाल |
| `07_BANNER_AI_PROMPT.md` | banner बनवाने का prompt |
| `graphics/` | `icon_512.png` · `feature_graphic.png` |
| `screenshots/` | 8 screenshot, पंक्ति लिखी हुई, 1080×1920 |
| `privacy_policy.html` | privacy पन्ना |

---

# ✅ अभी क्या हो चुका है

| काम | हाल |
|---|---|
| App name (30/30) | ✅ Console में लग चुका |
| Short description (68/80) | ✅ लग चुका |
| Full description (2049/4000) | ✅ लग चुका |
| Screenshots (8, पंक्ति सहित) | ✅ बन चुकीं — चढ़ाना बाक़ी |
| icon + feature graphic | ✅ तैयार — चढ़ाना बाक़ी |
| AAB | ✅ बन चुकी — चढ़ाना बाक़ी |

---

# 📋 अब क्या करना है — क्रम से

## 1. Store listing पूरी कीजिए

Console → **Store presence → Store listings**

तीनों लिखने वाले खाने भर चुके हैं। बचा सिर्फ़ **Graphics**:

| जगह | फ़ाइल |
|---|---|
| App icon | `graphics/icon_512.png` |
| Feature graphic | `graphics/feature_graphic.png` |
| Phone screenshots | `screenshots/` की सभी 8, क्रम में |
| 7-inch tablet | **वही 8 दोबारा** |
| 10-inch tablet | **वही 8 दोबारा** |

फिर **Save**। (Save से कुछ public नहीं होता — सिर्फ़ review के लिए तैयार होता है।)

## 2. AAB चढ़ाइए

```
03 Pro Kisan\pro kisan\build\app\outputs\bundle\release\app-release.aab
```

**9 अगस्त, 12:55 वाली** · 55.5 MB · versionCode 2

> 🔴 **9 अगस्त की सुबह वाली AAB मत चढ़ाइए** — उसमें वह बग है जिससे पशु
> जोड़ते ही ऐप अटक जाती थी।

**Track: पहले Internal testing।** अपने फ़ोन पर install करके पशु जोड़कर
देख लीजिए, फिर Production में promote कीजिए। एक बार public हुआ तो वापस
नहीं होता।

## 3. App content भरिए

`03_DATA_SAFETY.md` से — **भाग 4अ ज़रूर पढ़िए**, वह Google Drive backup
जुड़ने के बाद जोड़ा गया है और बाक़ी फ़ाइल उससे पुरानी है।

## 4. बाक़ी 8 भाषाओं की listing जोड़िए

Console → Store listings → **Manage translations → Add translation**

पूरी listing `01_LISTINGS_9_BHASHA.md` में **तैयार पड़ी है** — बस
copy-paste। यह ASO का सबसे बड़ा फ़ायदा है (देखें `02_KEYWORDS_ASO.md`)।

> यह live होने के लिए ज़रूरी नहीं। पहले live हो जाइए, भाषाएँ उसके बाद
> जोड़ते रहिए — हर एक नया बाज़ार खोलती है।

---

# 🔴 दो चीज़ें जो ग़लत न हों

**1. privacy पन्ना और Data Safety मेल खाएँ**

Drive backup के बाद Data Safety में "data collected = Yes" कहना है। तब
privacy पन्ने में भी Drive का ज़िक्र होना चाहिए। Play दोनों साथ पढ़ता है।

blogspot पर 9 अगस्त वाला संस्करण चढ़ा है या नहीं, एक बार देख लीजिए।

**2. "पत्ती की फोटो से रोग पहचान" कहीं न लिखा हो**

वह feature ऐप में **है ही नहीं**। पुराने
`pro kisan/docs/PLAY_STORE_CHECKLIST.md` में यह पंक्ति थी — वह फ़ाइल हटा दी
गई है, पर कहीं और copy हो गई हो तो हटा दीजिए। Play इसी पर listing रोकता है।

---

# 📌 जो अभी बाक़ी है (कोई launch नहीं रोकता)

| क्या | असर |
|---|---|
| मंडी में बाक़ी 8 राज्य | हिमाचल/गोवा/दिल्ली/त्रिपुरा के किसान अपना राज्य नहीं छाँट सकते |
| backup → साफ़ install → पहली-बार का tour | Drive restore असली फ़ोन पर अभी नहीं परखा गया |
| `--split-debug-info` | download ~5 MB छोटा हो जाएगा |
| बाक़ी 12 पन्नों की जाँच | ग्राहक, एंट्री, समाचार, FAQ वग़ैरह |
