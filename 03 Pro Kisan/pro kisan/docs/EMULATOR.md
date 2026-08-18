# 📱 अपना Android emulator — बना हुआ है, पर धीमा है

> 8 अगस्त 2026 · जाँच पूरी

इस कंप्यूटर पर कोई असली Android फ़ोन जुड़ा नहीं है। screenshot और जाँच के
लिए emulator बना दिया गया है। **वह चलता है** — पर इस मशीन पर बहुत धीमा।
नीचे पूरी वजह और इलाज लिखा है।

---

## चलाने का तरीक़ा

```powershell
.\scripts\emulator.ps1 -Install     # चालू करो + ऐप डालो
.\scripts\emulator.ps1 -Shot ghar   # screenshot -> screenshots\ghar.png
.\scripts\emulator.ps1 -Band        # बंद करो
```

पहली बार में AVD अपने आप बन जाती है। कुछ हाथ से नहीं करना।

---

## 🔴 असली दिक़्क़त क्या है

```
Found physical GPU 'Intel(R) HD Graphics 620' — apiVersion: 1.3.215
WARNING | unsupported Vulkan API level (1.3.215, min required: 1.3.240)
INFO    | Host Vulkan driver is not supported.
INFO    | vulkan_mode_selected: lavapipe   gles_mode_selected: host
```

सीधी बात: इस कंप्यूटर में अलग graphics card नहीं है (i3 7th gen, Intel HD
620)। उसका Vulkan driver **1.3.215** देता है, पर जो अकेला system image
यहाँ पड़ा है — **Android 37** — कम से कम **1.3.240** माँगता है।

इसलिए emulator Vulkan को `lavapipe` पर डाल देता है, यानी **सारा rendering
CPU पर**। GLES तो पहले से असली GPU पर है — सिर्फ़ Vulkan software पर गिरा
है, और Android 15 के बाद screen वहीं से बनती है।

### इसका नतीजा — जो आँख से दिखता है

| | इस emulator पर | असली फ़ोन पर |
|---|---|---|
| ऐप खुलने में | **1 मिनट 15 सेकंड** | 2–3 सेकंड |
| CPU | 97% एक ही process पर | सामान्य |
| "isn't responding" | बार-बार (SystemUI, Launcher) | कभी नहीं |

> ⚠️ **ये ऐप की ख़राबी नहीं है।** logcat ने साफ़ लिखा —
> `Fully drawn com.prokisan.app/.MainActivity: +1m15s579ms` — यानी ऐप
> पूरा बना, बस धीरे। भाषा चुनने वाली screen तक पहुँचकर देख लिया गया।

---

## ✅ इलाज — एक बार का काम

**Android Studio → SDK Manager → SDK Platforms → "Show Package Details"**
→ किसी **API 33 या 34** का *Google Play x86_64* image उतार लीजिए (~1 GB)।

वे Vulkan नहीं माँगते — GLES से चलते हैं, यानी **असली Intel GPU पर**।
उतरते ही script अपने आप उसे उठा लेगी (सबसे पुराना API पहले चुनती है,
क्योंकि पुराना = हल्का)।

फिर एक बार नई AVD बनवा लीजिए:

```powershell
.\scripts\emulator.ps1 -Nayi -Install
```

---

## जो रास्ते काम नहीं करते (आज़मा लिए गए)

| कोशिश | क्या हुआ |
|---|---|
| `-gpu swiftshader_indirect` | और भी धीमा — पूरा software। SystemUI ANR |
| `-gpu angle_indirect` | इस emulator में वह option है ही नहीं — `not valid, switching to auto` |
| `-gpu host` | GLES तो host पर गया, पर Vulkan फिर भी lavapipe |
| Intel driver update | HD 620 पुराना है; Intel अब इसमें Vulkan नहीं बढ़ाता |

---

## छोटी-छोटी बातें जो script में जोड़ दी गईं

- **`avdmanager` इस SDK में है ही नहीं** (`cmdline-tools\latest\bin` ख़ाली
  है)। इसलिए AVD हाथ से लिखी जाती है — वह असल में सिर्फ़ दो text फ़ाइल है।
- **एक ही AVD पर दो emulator** चलें तो `FATAL` आता है। script पहले पुराने
  process बंद करती है।
- **`hide_error_dialogs 1`** — वरना "isn't responding" वाला डिब्बा हर
  screenshot में आ जाता है।
- **animation बंद + screen हमेशा चालू** — धीमी मशीन पर बहुत फ़र्क़ पड़ता है।
- screen **1080×1920** रखी है — यह ठीक 9:16 है, Play Store इसे बिना सवाल
  लेता है।

---

## 📌 अभी screenshot की क्या ज़रूरत है

Play Store के लिए कम से कम **2** phone screenshot चाहिए, अच्छा हो तो 6:
घर · दूध · खाद-बीज · मंडी भाव · पालन गाइड · मौसम।

जब तक हल्का image न उतरे, सबसे तेज़ रास्ता यही है कि APK असली फ़ोन में
डालकर वहीं screenshot ले लिए जाएँ — तरीक़ा `docs/SCREENSHOT_KAISE_LEN.md`
में लिखा है।
