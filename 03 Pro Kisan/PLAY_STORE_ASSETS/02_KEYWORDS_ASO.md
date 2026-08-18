# 🔍 Pro Kisan — Keywords & ASO Strategy

This document contains the categorized keyword list and search search intent mappings for maximum visibility on Google Play Store India.

---

## 🎯 रणनीति — दो फ़ैसले, बाक़ी सब इन्हीं से निकलता है

> 9 अगस्त 2026 को जोड़ा गया

### 1. भारत एक बाज़ार नहीं, **नौ बाज़ार** है

मराठी किसान `दूध हिशोब` लिखता है, तेलुगु वाला `పాల లెక్క`, तमिल वाला
`பால் கணக்கு`। **हिंदी-only listing इनमें से किसी को दिखती ही नहीं।**

ऐप का अनुवाद **पहले से हो चुका है** और नौ भाषाओं की listing भी
`01_LISTINGS_9_BHASHA.md` में **तैयार पड़ी है** — काम सिर्फ़ Console में
`Manage translations` से जोड़ने का है।

**यह किसी भी keyword की जोड़-तोड़ से बड़ा फ़ायदा है।**

### 2. लड़ाई वहाँ लड़िए जो **जीत सकते हैं**

`मंडी भाव` पर सरकारी ऐप (Kisan Suvidha, eNAM) और बड़े agri ऐप बैठे हैं —
वहाँ सीधी टक्कर महँगी है।

पर `दूध का हिसाब` / `दूध डायरी` / `milk diary` —
- खोजने वाला **ठीक वही** चाहता है जो हमारा मुख्य feature है
- मुक़ाबला कम है
- **रोज़ इस्तेमाल होता है** → retention अच्छा → और rank असल में retention
  से टिकता है, एक बार के install से नहीं

➡️ **title और short description `दूध का हिसाब` पर टिकें**; मंडी, मौसम,
योजना full description में साथ चलें। अभी का title यही करता है।

### 3. rank सिर्फ़ खोजे जाने से नहीं बढ़ता

Play install-rate और retention देखता है। इसलिए —
- **screenshots पर पंक्ति लिखी हो** (हो चुका — `screenshots/` देखिए)
- **पहले दो हफ़्ते की rating** पूरी दिशा तय करती है

---

## 🏷️ Title — सबसे भारी संकेत

Console में अब यह लगा है (30/30 अक्षर):

```
प्रो किसान: दूध हिसाब मंडी भाव
```

पहले `Pro Kisan` था — 9 अक्षर, और **कोई किसान वह नहीं खोजता**। 21 अक्षर
बेकार जा रहे थे। अब नाम में ही तीन खोजे जाने वाले शब्द हैं।

> ⚠️ फ़ोन पर icon के नीचे नाम नहीं बदला — वह `android:label` से आता है।
> बदलाव सिर्फ़ Store में है।

## ✅ "20 राज्यों" — यही लिखिए

एक बार यह सुझाव दिया गया था कि "28 राज्य" लिखिए। **वह ग़लत था।**

| कहाँ | कितने राज्य |
|---|---|
| server का database | 28 |
| ऐप का राज्य वाला छाँटा (`_stateDistricts`) | **20** |

किसान 20 में से ही चुन सकता है। "28" लिखना *misleading claim* बन जाता —
वही चीज़ जिससे बचना है।

## ⭐ सबसे ज़रूरी ASO नियम (भाषा = ranking)
1. Play Store में अलग "keyword field" नहीं होता — keywords **Title (30) > Short description (80) > Full description** में naturally आने चाहिए। Title का वज़न सबसे ज़्यादा।
2. **हर भाषा की localized listing = उस भाषा के searches में rank।** "दूध का हिसाब" खोजने वाला hi-IN listing देखेगा, "பால் கணக்கு" खोजने वाला ta-IN। सभी 9 listings (`01_SHORT_&_FULL_DESCRIPTIONS.md`) ज़रूर भरें।
3. पहले 1-2 हफ्तों की ratings ranking तय करती हैं — शुरुआती users से 5⭐ ज़रूर मांगें (app में review prompt पहले से है)।
4. Milk & Dairy खोजों में अतिरिक्त targets: `milk bill app`, `dudh bill`, `hisab kitab app`, `dairy farm app`, `milk collection app`, `दूध बिल`।

---

## 1. Primary Keywords (High Volume — Search Bar Targets)

- **Hindi / Devanagari:** `किसान ऐप`, `दूध का हिसाब`, `खेत कैलकुलेटर`, `मंडी भाव`, `मौसम की जानकारी`, `सरकारी योजना`, `कृषि ऐप`
- **Hinglish:** `kisan app`, `doodh ka hisab`, `khaad calculator`, `mandi bhav`, `mausam app`, `kheti app`, `mandi rate today`
- **English:** `Farmer App`, `Milk Diary`, `Milk Record Book`, `Fertilizer Calculator`, `Cattle Calculator`, `Weather Forecast`, `Mandi Rates`, `Agriculture App`

---

## 2. Secondary Keywords (Feature-Specific Intent)

- **Milk & Dairy:** `दूध का हिसाब किताब`, `दूध डायरी`, `दूधवाला ऐप`, `WhatsApp दूध बिल`, `PDF milk receipt`, `daily milk collection`, `fat rate calculator`
- **Fertilizer & Soil:** `खाद और बीज`, `NPK कैलकुलेटर`, `यूरिया DAP मात्रा`, `soil calculator`, `fertilizer dose calculator`
- **Cattle & Breeding:** `पशु कैलकुलेटर`, `गाभिन कैलकुलेटर`, `ब्याने की तारीख`, `cow calving date`, `buffalo gestation calculator`
- **Market & Government:** `MSP भाव`, `न्यूनतम समर्थन मूल्य`, `PM किसान status`, `फसल बीमा`, `KCC पात्रता`, `कृषि समाचार`

---

## 3. Long-Tail Search Queries (High Download Conversion)

1. `आज का गेहूं का मंडी भाव`
2. `दूध की रोजाना एंट्री कैसे करें`
3. `गाय ब्याने की सही तारीख कैसे निकालें`
4. `1 एकड़ खेत में कितनी बोरी यूरिया डालें`
5. `PM किसान सम्मान निधि पात्रता कैसे देखें`
6. `पशु किसान क्रेडिट कार्ड कैसे बनवाएं`
7. `10 दिन का मौसम पूर्वानुमान कैसे देखें`
8. `ग्राहक को दूध का बिल WhatsApp पर कैसे भेजें`

---

## 4. ❌ Misspelled & Alternate Search Terms (Search Variances)

| Target Word | Common Misspellings / Variances |
|---|---|
| **Kisan** | `Kishan`, `Kisaan`, `Kissan`, `Kisn`, `Kisson` |
| **Pro Kisan** | `Pro Kishan`, `Prokisan`, `Pro Kisaan`, `ProKishan` |
| **Kheti** | `Kheti Badi`, `Kheti-Bari`, `Khetibari`, `Keti` |
| **Doodh** | `Dudh`, `Dhood`, `Doodh`, `Dudha`, `Dud` |
| **Hisab** | `Hisaab`, `Hisab kitab`, `Hisab-Kitab` |
| **Mandi** | `Mandi Bhao`, `Mandi Rate`, `Mandi ka Bhav`, `Mandi ka Rate` |
| **Khaad** | `Khad`, `Khaad`, `Kaad` |
| **Gaabhin** | `Gabhin`, `Gabheen`, `Gavhin` |
| **Mausam** | `Mosam`, `Mausam`, `Mousam` |
| **Krishi** | `Krushi`, `Krisi`, `Krshi` |
