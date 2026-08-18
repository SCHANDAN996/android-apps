# मंडी भाव API — VPS पर लगाने की guide

`mandi.php` सर्वर पर नहीं था (HTTP 404), इसलिए ऐप अपने भीतर के नमूना भाव दिखा रहा था।
यह फ़ोल्डर वही कमी पूरी करता है।

---

## 📁 क्या-क्या है

| फ़ाइल | काम | कहाँ रखें |
|---|---|---|
| `sql/mandi_schema.sql` | टेबल + 12 शुरुआती भाव | एक बार चलानी है |
| `api/mandi.php` | ऐप जो API कॉल करता है | `/var/www/prokisan_api/api/` |
| `includes/mandi_map.php` | अंग्रेज़ी ⇄ हिंदी नाम + MSP | `/var/www/prokisan_api/includes/` |
| `cron/mandi_sync.php` | सरकारी data रोज़ खींचने वाली स्क्रिप्ट | `/var/www/prokisan_api/cron/` |

---

## ⚙️ लगाने के 5 कदम

### 1. फ़ाइलें अपलोड करें

```bash
# अपने कंप्यूटर से (यह पूरा फ़ोल्डर)
scp -r vps_mandi_api/api/mandi.php       root@72.61.235.129:/var/www/prokisan_api/api/
scp -r vps_mandi_api/includes            root@72.61.235.129:/var/www/prokisan_api/
scp -r vps_mandi_api/cron                root@72.61.235.129:/var/www/prokisan_api/
scp    vps_mandi_api/sql/mandi_schema.sql root@72.61.235.129:/tmp/
```

### 2. टेबल बनाएँ

```bash
ssh root@72.61.235.129
mysql -u prokisan_user -p pro_kisan_db < /tmp/mandi_schema.sql
```

जाँचें कि बनी:
```bash
mysql -u prokisan_user -p pro_kisan_db -e "SELECT COUNT(*) AS भाव FROM mandi_rates;"
```
12 दिखना चाहिए (नमूना भाव)।

### 3. अभी API चलाकर देखें

```bash
curl -k "https://72.61.235.129/prokisan_api/api/mandi.php" | head -c 400
```

ऐसा JSON आना चाहिए:
```json
[{"state":"उत्तर प्रदेश","district":"वाराणसी","mandi":"वाराणसी","commodity":"गेहूं",
  "minPrice":2200,"maxPrice":2350,"modalPrice":2290,"msp":2275}]
```

**इतना होते ही ऐप में असली भाव दिखने लगेंगे।** आगे के कदम "रोज़ अपने आप अपडेट" के लिए हैं।

### 4. API key — पहले से लगी है ✅

आपकी असली data.gov.in key `cron/mandi_sync.php` में डाल दी गई है। मैंने जाँचकर
देखा — `limit=1000` पर पूरे **1000 रिकॉर्ड** देती है (नमूना key सिर्फ़ 10 देती थी)।

⚠️ **key निजी चीज़ है** — इस फ़ोल्डर को सार्वजनिक git repo में मत डालना।
सर्वर पर और सुरक्षित तरीक़ा यह है कि फ़ाइल के बजाय पर्यावरण चर से दें:

```bash
echo 'DATA_GOV_KEY="579b464db66ec23bdd000001bf22cca7d4ba4ba9737cdc8c54b12815"' >> /etc/environment
source /etc/environment
```
ऐसा करने पर स्क्रिप्ट फ़ाइल वाली key की जगह इसी को लेगी।

### 5. एक बार sync चलाकर देखें

```bash
cd /var/www/prokisan_api
php cron/mandi_sync.php
```

ऐसा दिखेगा:
```
═══ मंडी sync शुरू — 23/07/2026 14:30:00 ═══
  उत्तर प्रदेश          847 भाव
  बिहार                 312 भाव
  ...
───────────────────────────────────────
आए        : 4820
सहेजे     : 3104
छोड़े      : 1716 (ऐप में वह फसल नहीं है)
पुराने हटे: 0
समय       : 38.4s
═══ पूरा ═══
```

---

## ⏰ रोज़ अपने आप चलाना

```bash
crontab -e
```

यह लाइन जोड़ें (सुबह 6 और शाम 6 बजे):
```
0 6,18 * * * /usr/bin/php /var/www/prokisan_api/cron/mandi_sync.php >> /var/log/prokisan_mandi.log 2>&1
```

log देखने के लिए:
```bash
tail -50 /var/log/prokisan_mandi.log
```

---

## 🔒 सुरक्षा — nginx में यह ज़रूर जोड़ें

`cron/` फ़ोल्डर ब्राउज़र से नहीं खुलना चाहिए। PHP फ़ाइल में भी जाँच है
(`PHP_SAPI !== 'cli'` पर रुक जाती है), पर दोहरी सुरक्षा बेहतर है।

`/etc/nginx/sites-available/` वाली अपनी फ़ाइल में server ब्लॉक के अंदर:

```nginx
# cron स्क्रिप्ट सिर्फ़ कमांड लाइन से चलें, वेब से नहीं
location ^~ /prokisan_api/cron/ {
    deny all;
    return 404;
}

# includes भी सीधे न खुलें
location ^~ /prokisan_api/includes/ {
    deny all;
    return 404;
}
```

फिर:
```bash
nginx -t && systemctl reload nginx
```

जाँचें कि बंद हो गया:
```bash
curl -k -o /dev/null -w "%{http_code}\n" "https://72.61.235.129/prokisan_api/cron/mandi_sync.php"
# 404 आना चाहिए
```

---

## 🧩 ऐप के साथ मेल — यह सबसे ज़रूरी बात

ऐप (`lib/ui/mandi_screen.dart`) राज्य, ज़िला और फसल को **हिंदी नामों से** छाँटता है।
इसलिए API से भी हिंदी में ही आना चाहिए:

| ✅ सही | ❌ ग़लत |
|---|---|
| `"state": "उत्तर प्रदेश"` | `"state": "Uttar Pradesh"` |
| `"commodity": "गेहूं"` | `"commodity": "Wheat"` |
| `"mandi": "वाराणसी"` | `"mandi": "वाराणसी मंडी"` |

अंग्रेज़ी भेजने पर भाव तो दिखेगा, पर **राज्य से छाँटने पर ग़ायब** हो जाएगा —
क्योंकि ऐप `_stateDistricts` की हिंदी कुंजियों से मिलान करता है।

`mandi` में "मंडी" शब्द मत जोड़ना — ऐप ख़ुद जोड़ता है (वरना "वाराणसी मंडी मंडी" दिखेगा)।

यह सारा अनुवाद `includes/mandi_map.php` करता है। उसमें **31 राज्य, 71 फसलें,
18 MSP दरें** हैं — और अंग्रेज़ी नाम **असली feed से जाँचकर** लिए गए हैं
(23/07/2026 को 3000 पंक्तियाँ देखकर), अंदाज़े से नहीं।

यह जाँच ज़रूरी थी। पहली बार में 7 नाम ग़लत निकले:

| मैंने लिखा था | feed असल में कहता है |
|---|---|
| `Paddy(Dhan)(Common)` | `Paddy(Common)` |
| `Barley (Jau)` | `Barley(Jau)` |
| `Green Gram (Moong)(Whole)` | `Green Gram(Moong)(Whole)` |
| `Arhar (Tur/Red Gram)(Whole)` | `Red gram/Arhar/Tur(whole)` |
| `Ragi (Finger Millet)` | `Ragi(Finger Millet)` |
| `Kerala` | `Keralam` |
| `Jammu & Kashmir` | `Jammu and Kashmir` |

एक स्पेस का फ़र्क़ भी हो तो वह फसल कभी सहेजी नहीं जाती। सुधार के बाद
पकड़ **48% से 81%** हो गई।

---

## ➕ नई फसल जोड़नी हो तो

दो जगह एक साथ बदलना पड़ेगा, वरना बेमेल हो जाएगा:

1. **सर्वर पर** `includes/mandi_map.php` → `CROP_HI` में
   `'AGMARKNET का नाम' => 'हिंदी नाम',`
2. **ऐप में** `lib/ui/mandi_screen.dart` → `_cropEn` में
   `'हिंदी नाम': 'English name',`

AGMARKNET में फसल का ठीक नाम क्या है, यह देखने के लिए:
```bash
curl -s "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=आपकी-key&format=json&limit=100" \
  | python3 -c "import sys,json; print(sorted({r['commodity'] for r in json.load(sys.stdin)['records']}))"
```

---

## 🔍 गड़बड़ी हो तो

| दिक़्क़त | कारण | हल |
|---|---|---|
| API खाली `[]` लौटाता है | टेबल खाली है | `mandi_schema.sql` चलाया? sync चलाया? |
| HTTP 500 | db.php नहीं मिला या MySQL बंद | `tail -50 /var/log/nginx/error.log` |
| sync में "10 भाव" ही आते हैं | key बदल गई या ग़लत है | data.gov.in पर key जाँचें |
| ऐप में भाव दिखते हैं पर राज्य से छाँटने पर ग़ायब | नाम अंग्रेज़ी में जा रहे | `mandi_map.php` की जाँच करें |
| भाव पुराने दिखते हैं | cron नहीं चल रहा | `crontab -l` और log देखें |

---

## 📊 API के वैकल्पिक parameters

ऐप अभी सिर्फ़ सादा `GET` करता है, पर आगे काम आ सकते हैं:

```
/api/mandi.php?state=उत्तर प्रदेश
/api/mandi.php?district=वाराणसी&commodity=गेहूं
/api/mandi.php?days=7          पिछले 7 दिन के भाव (डिफ़ॉल्ट 3)
/api/mandi.php?limit=1000      कितने रिकॉर्ड (डिफ़ॉल्ट 500, अधिकतम 2000)
```
