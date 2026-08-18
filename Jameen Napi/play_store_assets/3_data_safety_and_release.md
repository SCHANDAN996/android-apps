# जमीन नापी — Data Safety + Release Notes + Update Steps

## A) Data Safety form (Play Console → App content → Data safety)
यह app offline है और AdMob इस्तेमाल करता है। जवाब:

- **Does your app collect or share any user data?** → **Yes**
  (क्योंकि AdMob ads के लिए device/advertising ID इकट्ठा करता है)
- **Data types collected:**
  - *Device or other IDs* → **Advertising ID** → Collected: Yes, Shared: Yes → Purpose: **Advertising or marketing**
  - बाक़ी सब (Name, Email, Location, Photos, Contacts, Files आदि) → **No** (app कुछ नहीं माँगता)
- **Is data encrypted in transit?** → **Yes**
- **Can users request data deletion?** → No personal data collected (AdMob के हिसाब से standard)
- **Is all collected data optional?** → Ads SDK के हिसाब से जवाब दें
> अगर आपने पिछली बार (v1.0.3) यही form भरा था और AdMob तभी से था, तो कुछ बदलने की ज़रूरत नहीं — बस verify कर लें।

## B) Permissions
यह app कोई खतरनाक permission नहीं माँगता (INTERNET सिर्फ़ ads के लिए)। कुछ declare करने की ज़रूरत नहीं।

## C) Release Notes (Play Console → Production → नया release → "What's new", max 500 अक्षर)

**हिंदी:**
```
• ऐप का नया नाम: अब "जमीन नापी" 🌾
• जमीन/खेत नाप और भी आसान और तेज़
• छोटे-मोटे सुधार और बग फिक्स
```

**English:**
```
• New name: now "Jameen Napi"
• Faster and easier land measurement
• Minor improvements and bug fixes
```

## D) Update करने के पक्के Steps (Play Console)

1. **Play Console → आपका app (किसान कैलकुलेटर) → Test and release → Production → Create new release**
2. **App bundle upload करें:** `Jameen Napi v1.0.4 (code5).aab` (मैंने build करके folder में रख दिया है)
   - Play अपने-आप versionCode 5 पकड़ लेगा (live 4 से ज़्यादा — इसलिए अब reject नहीं होगा)
3. Release name: `1.0.4 (5)` · "What's new" में ऊपर वाला text डालें
4. **Save → Review release → Start rollout to Production** (100%)
5. **नाम बदलने के लिए अलग से:** Play Console → **Main store listing → App name** को **"जमीन नापी - खेत नाप कैलकुलेटर"** करें → नई short/full description (file 1 से) डालें → Save
6. Icon पहले से जमीन-थीम का है तो रहने दें; बदलना हो तो 512×512 बताइए मैं spec दे दूँगा।

## E) दो चेतावनियाँ
- **Package कभी मत बदलिए** — `com.chandansingh.kisan_calculator` ही रहेगा (यही update होने की शर्त है)।
- **`key.properties` और `kisan-upload.jks` कभी GitHub/किसी को मत भेजिए** — इनमें keystore password है; खो/लीक हुआ तो app को दोबारा कभी update नहीं कर पाएँगे। इनका backup 2-3 सुरक्षित जगह रखें।
