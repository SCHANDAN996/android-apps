# 🧹 सर्वर की सफ़ाई — पुरानी/दोहरी फ़ाइलें हटाना

> ⚠️ **यह मिटाने का काम है। नीचे का क्रम मत तोड़िए।**
> पहले नक़ल, फिर जाँच, तब मिटाना। बीच में कुछ भी छोड़ा तो ऐप बंद हो सकता है।

---

## क्यों करना है

डाउनलोड किए गए backup में **दो लगभग एक जैसे folder** मिले:

```
Pro_Kisan_VPS_Server_Backend/    ← admin/, api/, cron/, db.php, schema.sql
vps_mandi_api/                   ← api/, cron/, includes/, sql/
```

दोनों की `api/mandi.php` **बिल्कुल एक जैसी** है। इसका मतलब सर्वर पर या तो
दोनों पड़ी हैं, या एक अधूरी नक़ल है। दोनों हालत ठीक नहीं —

- अगला बदलाव **ग़लत folder** में हो सकता है और "कुछ नहीं बदला" लगेगा
- दो cron एक ही टेबल में लिखें तो बेकार का बोझ पड़ता है
- `db.php` अगर web root में खुली पड़ी है तो **डेटाबेस का पासवर्ड** बाहर है

---

## क़दम 1 — पहले देखिए कि सर्वर पर असल में क्या है

**कुछ मत मिटाइए।** पहले सूची बनाइए:

```bash
# कहाँ-कहाँ prokisan वाली फ़ाइलें पड़ी हैं
find /var/www /home -maxdepth 4 -iname "*prokisan*" -o -maxdepth 4 -iname "*mandi_api*" 2>/dev/null

# हर मिले folder का ब्योरा
for d in $(find /var/www /home -maxdepth 4 -type d \( -iname "*prokisan*" -o -iname "*mandi_api*" \) 2>/dev/null); do
  echo "───────────────────────────────────────"
  echo "$d"
  ls -la "$d"
done
```

**यह सूची सामने रखिए।** इसके बिना आगे मत बढ़िए।

---

## क़दम 2 — पता कीजिए कि ऐप असल में किसे पूछता है

ऐप का पता है:

```
https://72.61.235.129/prokisan_api/api/mandi.php
```

तो असली folder वही है जिस पर यह URL जाता है। पता कीजिए:

```bash
# nginx में root कहाँ है
grep -rn "root\s" /etc/nginx/sites-enabled/ /etc/nginx/conf.d/ 2>/dev/null

# Apache में
grep -rn "DocumentRoot" /etc/apache2/sites-enabled/ 2>/dev/null
```

मान लीजिए `root /var/www;` निकला — तब **असली folder है**
`/var/www/prokisan_api/` और बाक़ी सब बेकार की नक़लें हैं।

पक्का करने के लिए एक निशानी डालकर देखिए:

```bash
# असली folder में एक जाँच फ़ाइल बनाइए
echo "MAIN" > /var/www/prokisan_api/api/_which.txt

# अब बाहर से पूछिए — "MAIN" आना चाहिए
curl -sk https://localhost/prokisan_api/api/_which.txt

# जाँच के बाद हटा दीजिए
rm /var/www/prokisan_api/api/_which.txt
```

अगर `MAIN` आया — वही असली है। **अब पक्का हो गया।**

---

## क़दम 3 — पूरी नक़ल रखिए (सबसे ज़रूरी क़दम)

```bash
mkdir -p /root/prokisan_backup
cd /root/prokisan_backup

# हर मिले folder की एक-एक नक़ल, तारीख़ के साथ
tar czf prokisan_api_$(date +%F).tar.gz -C /var/www prokisan_api

# डेटाबेस की भी नक़ल — यही असली माल है
mysqldump -u prokisan_user -p pro_kisan_db > pro_kisan_db_$(date +%F).sql

ls -lh /root/prokisan_backup/
```

**दोनों फ़ाइलें दिखनी चाहिए और आकार शून्य नहीं होना चाहिए।** न दिखें तो
आगे मत बढ़िए।

---

## क़दम 4 — अभी मत मिटाइए, पहले नाम बदलिए

सीधे मिटाने के बजाय **नाम बदल दीजिए**। अगर कुछ टूटा तो एक सेकंड में वापस।

```bash
# मान लीजिए /var/www/vps_mandi_api बेकार की नक़ल निकली
mv /var/www/vps_mandi_api /var/www/_PURANA_vps_mandi_api

# इसी तरह बाक़ी नक़लें
mv /var/www/Pro_Kisan_VPS_Server_Backend /var/www/_PURANA_Pro_Kisan_VPS_Server_Backend
```

अब **3-4 दिन ऐप चलाकर देखिए।** सब ठीक चले तो क़दम 6 पर जाइए।

---

## क़दम 5 — दोहरे cron हटाइए

```bash
crontab -l
```

अगर एक ही काम की दो पंक्तियाँ दिखें (अलग-अलग रास्तों से), तो **सिर्फ़ असली
folder वाली रखिए**, बाक़ी हटा दीजिए:

```bash
# पहले नक़ल
crontab -l > /root/prokisan_backup/crontab_$(date +%F).txt

# फिर बदलिए
crontab -e
```

`root` के अलावा दूसरे उपयोगकर्ता का cron भी देख लीजिए:

```bash
for u in $(cut -d: -f1 /etc/passwd); do
  echo "── $u"; crontab -u "$u" -l 2>/dev/null | grep -i prokisan
done
```

---

## क़दम 6 — 3-4 दिन बाद, तब मिटाइए

ऐप ठीक चल रहा हो, मंडी भाव आ रहे हों, तभी:

```bash
rm -rf /var/www/_PURANA_vps_mandi_api
rm -rf /var/www/_PURANA_Pro_Kisan_VPS_Server_Backend
```

**नक़ल `/root/prokisan_backup/` में रहने दीजिए।** वह कुछ MB की है, जगह नहीं
घेरती, और किसी दिन काम आ सकती है।

---

## 🔐 क़दम 7 — सफ़ाई के साथ यह भी कर लीजिए

### (क) `db.php` बाहर से खुल तो नहीं रही?

उसमें **डेटाबेस का पासवर्ड** है।

```bash
curl -skI https://localhost/prokisan_api/db.php | head -1
```

`403` या `404` आना चाहिए। अगर `200` आया — पासवर्ड बाहर है, तुरंत बंद कीजिए:

**nginx:**
```nginx
location ~ ^/prokisan_api/(cron|includes|sql|admin)/ { deny all; return 403; }
location = /prokisan_api/db.php { deny all; return 403; }
```

**Apache** — `/var/www/prokisan_api/.htaccess` में:
```apache
<Files "db.php">
    Require all denied
</Files>
RedirectMatch 403 ^/prokisan_api/(cron|includes|sql)/
```

फिर: `systemctl reload nginx` (या `apache2`)

### (ख) `admin/panel.php` पर ताला है?

```bash
curl -skI https://localhost/prokisan_api/admin/panel.php | head -1
```

बिना पासवर्ड खुल रही हो तो HTTP Basic Auth लगाइए:

```bash
apt install apache2-utils -y
htpasswd -c /etc/nginx/.prokisan_admin admin
```

```nginx
location ~ ^/prokisan_api/admin/ {
    auth_basic "Pro Kisan Admin";
    auth_basic_user_file /etc/nginx/.prokisan_admin;
}
```

### (ग) API key कोड से हटाइए

`cron/mandi_sync.php` में `DEFAULT_KEY` के आगे असली data.gov.in key लिखी है।
फ़ाइल ख़ुद कहती है कि यह ग़लत तरीक़ा है।

```bash
# key को cron की पंक्ति में दीजिए
crontab -e
```

```cron
DATA_GOV_KEY=आपकी-असली-key
0 18 * * * /usr/bin/php /var/www/prokisan_api/cron/mandi_sync.php >> /var/log/prokisan_mandi.log 2>&1
```

फिर कोड में `DEFAULT_KEY` की असली value हटाकर ख़ाली छोड़ दीजिए:

```php
const DEFAULT_KEY = '';   // key ab crontab me hai
```

> ⚠️ **यह folder किसी को भेजने से पहले ज़रूर कीजिए** — अभी key फ़ाइल में
> साफ़ लिखी हुई है।

---

## ✅ सफ़ाई के बाद की जाँच

```bash
# 1. ऐप वाला रास्ता चल रहा है?
curl -sk "https://localhost/prokisan_api/api/mandi.php?limit=1" | head -c 200

# 2. भाव आ रहे हैं?
curl -sk "https://localhost/prokisan_api/api/mandi.php" | python3 -c "import sys,json;d=json.load(sys.stdin);print(len(d),'bhaav')"

# 3. निजी रास्ते बंद हैं? (तीनों पर 403 आना चाहिए)
for u in db.php cron/mandi_sync.php includes/mandi_map.php; do
  printf "%-28s " "$u"; curl -skI "https://localhost/prokisan_api/$u" | head -1
done

# 4. cron में एक ही पंक्ति है?
crontab -l | grep -c mandi_sync

# 5. sujhav और notices भी चल रहे हैं?
curl -skI https://localhost/prokisan_api/api/notices.php | head -1
```

अंत में **ऐप खोलकर** देखिए — खेती → मंडी भाव। भाव और तारीख़ दोनों दिखने
चाहिए।

---

## ❌ जो कभी मत कीजिए

| मत कीजिए | क्यों |
|---|---|
| `rm -rf` बिना backup के | ऐप बंद हो जाएगा और वापस लाने का रास्ता नहीं बचेगा |
| `DROP TABLE mandi_rates` | पूरा इतिहास चला जाएगा। साफ़ करना ही हो तो `TRUNCATE` (sync 2 मिनट में भर देता है) |
| `api/sujhav.php` या `notices.php` हटाना | ऐप इन्हें भी पूछता है |
| `includes/mandi_map.php` हटाना | उसमें राज्य/फ़सल का पूरा नक्शा है — बिना उसके sync कुछ नहीं सहेजेगा |
| सब कुछ एक साथ बदलना | कुछ टूटे तो पता ही न चले कि किस बदलाव से |

---

## 📌 एक बात

अगर सफ़ाई में कुछ गड़बड़ हो जाए, **घबराइए मत** — ऐप टूटेगा नहीं। वह अपने भीतर
के अनुमानित भाव दिखाता रहेगा और ऊपर साफ़ लिखा रहेगा कि ये असली मंडी भाव नहीं
हैं। किसान का काम रुकेगा नहीं।

नक़ल से वापस लाना:

```bash
cd /var/www
tar xzf /root/prokisan_backup/prokisan_api_YYYY-MM-DD.tar.gz
mysql -u prokisan_user -p pro_kisan_db < /root/prokisan_backup/pro_kisan_db_YYYY-MM-DD.sql
```
