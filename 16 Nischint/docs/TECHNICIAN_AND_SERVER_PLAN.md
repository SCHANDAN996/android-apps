# टेक्नीशियन मोड, फ़ोटो अपलोड और सर्वर का प्लान (v0.2–v0.3)

स्थिति (2 नवंबर 2026): **अभी बना नहीं है।** सर्वर की जानकारी चंदन अपने PC पर प्रोजेक्ट खोलकर देंगे, उसके बाद यह हिस्सा बनेगा। यह फ़ाइल वही सब बताती है जो बनाना है, ताकि कोई भी AI या डेवलपर सीधे काम शुरू कर सके।

---

## 1. चंदन की माँग (उनके शब्दों का सार)
- पार्टनर ऐप में **टेक्नीशियन** को सब दिखे: कहाँ जाना है, ग्राहक कौन है, पूरा पता, और **काम उठाते ही पूरा हिसाब-किताब** — कितना पैसा मिलेगा, कितना ग्राहक से लेना है, कितना कंपनी को जमा करना है।
- **वेंडर कोई शिकायत डाले तो सीधे टेक्नीशियन को** पता चल जाए कि कहाँ जाना है।
- टेक्नीशियन **इसी ऐप से फ़ोटो** खींचकर अपलोड करे, और वह फ़ोटो **वेंडर के पास** (पार्टनर ऐप में उसी शिकायत में) पहुँच जाए। ग्राहक की बुकिंग हो तो ग्राहक के ऐप में।
- चंदन के पास **अपना वेब सर्वर** है जिस पर फ़ोटो रख सकते हैं।

---

## 2. पूरा फ़्लो
1. **काम बनता है:** ग्राहक निश्चिंत ऐप में बुकिंग करता है, या वेंडर पार्टनर ऐप में शिकायत डालता है → सर्वर पर `job` बनती है (status `new`)।
2. **काम बाँटना:** एडमिन (चंदन) पार्टनर ऐप के एडमिन मोड में नया काम देखता है → टेक्नीशियन चुनता है (बाद में: पास वाले टेक्नीशियन को अपने-आप) → status `assigned`।
3. **टेक्नीशियन को सूचना:** "नया काम: Shivpur, सोलर सफ़ाई, आपकी कमाई ₹230"।
4. **काम उठाना:** टेक्नीशियन "काम उठाएँ" दबाता है (status `accepted`) → दिखता है: ग्राहक का नाम, कॉल बटन, पूरा पता + लैंडमार्क, **"रास्ता देखें" (Google Maps)**, सेवा, दिक्कत, kW, वेंडर का नाम, **हिसाब बॉक्स**।
5. **काम के क़दम:** पहुँच गया (`arrived`) → पहले की फ़ोटो → काम → बाद की फ़ोटो → (पार्ट चाहिए: फ़ोटो + ख़र्च → वेंडर/ग्राहक की हाँ) → ग्राहक का OTP → पूरा (`done`)।
6. **रिपोर्ट:** फ़ोटो वेंडर/ग्राहक के ऐप में; कमाई टेक्नीशियन की "मेरी कमाई" में; वेंडर के महीने के बिल में विज़िट जुड़ जाती है।

---

## 3. टेक्नीशियन का हिसाब (सुझाए रेट — `nischint_core` के एक config में रखें, बदल सकें)

| नियम | रकम |
| --- | --- |
| हर विज़िट की मेहनत | ₹200 |
| पेट्रोल भत्ता | ₹30 प्रति विज़िट |
| जल्दी वाली (48 घंटे) विज़िट | +₹50 |
| 3 kW से बड़े सिस्टम की सफ़ाई | +₹50 प्रति अतिरिक्त kW (ग्राहक से +₹150/kW लेते हैं) |

**काम की स्क्रीन पर हिसाब बॉक्स:**
- ग्राहक की नकद बुकिंग (सफ़ाई 3 kW): ग्राहक से लेना ₹600 · आपकी कमाई ₹200 + ₹30 = ₹230 · कंपनी को जमा ₹370
- वेंडर की शिकायत: ग्राहक से लेना ₹0 (वेंडर बिल से देगा) · आपकी कमाई ₹230 (जल्दी वाली पर ₹280)
- UPI से ग्राहक ने सीधे कंपनी को दिया: ग्राहक से लेना ₹0 · आपकी कमाई ₹230

**"मेरी कमाई" स्क्रीन:** आज / इस हफ़्ते / इस महीने की कमाई, पूरे काम की सूची, "कंपनी को जमा बाकी" (नकद जो टेक्नीशियन के पास है), हर हफ़्ते का भुगतान।

---

## 4. सर्वर — तीन रास्ते (फ़ैसला बाकी)

| रास्ता | क्या मिलेगा | नोट |
| --- | --- | --- |
| **A. Supabase (सलाह)** | Postgres डेटाबेस, OTP लॉगिन, फ़ोटो स्टोरेज (मुफ़्त में 1 GB ≈ 5,000 फ़ोटो), Realtime (नया काम तुरंत) | चंदन अपने `mechanic_tracker` प्रोजेक्ट में Supabase पहले इस्तेमाल कर चुके हैं। Flutter पैकेज: `supabase_flutter` |
| **B. चंदन का अपना वेब सर्वर** | डेटा और फ़ोटो अपने सर्वर पर | चाहिए: सर्वर का प्रकार (VPS/होस्टिंग/Flask), डोमेन, डेटाबेस, कोड डालने की पहुँच। REST API (Flask या NestJS — चंदन दोनों में काम कर चुके हैं) |
| **C. मिला-जुला** | काम, लॉगिन, Realtime Supabase पर; फ़ोटो चंदन के वेब सर्वर पर (upload endpoint) | फ़ोटो का खर्च/जगह अपने हाथ में |

Firebase से बचें: नए प्रोजेक्ट में Cloud Storage के लिए Blaze (पेड) प्लान चाहिए।

---

## 5. डेटा मॉडल (रास्ता A के लिए; B/C में भी यही टेबल)

```sql
-- लोग: ग्राहक, वेंडर, टेक्नीशियन, एडमिन
create table profiles (
  id uuid primary key references auth.users,
  role text check (role in ('customer','vendor','technician','admin')) not null,
  name text, phone text unique, firm_name text, area text,
  created_at timestamptz default now()
);

-- एक काम = ग्राहक की बुकिंग या वेंडर की शिकायत
create table jobs (
  id uuid primary key default gen_random_uuid(),
  ref_code text unique not null,       -- NB-0211-4821 / VC-0211-1934 (ऐप वाले नंबर; दिखाने के लिए)
  -- ध्यान: ऐप वाले नंबर में साल नहीं और सिर्फ़ 4 रैंडम अंक हैं — कई फ़ोन से एक ही नंबर बन सकता है।
  -- इसलिए primary key uuid; ref_code सर्वर पर बनाएँ (साल + क्रम संख्या, जैसे VC-26-000123) या टकराने पर नया बनाएँ।
  source text check (source in ('customer','vendor')) not null,
  service_id text not null,            -- solar_cleaning / solar_repair / solar_amc / vendor_complaint
  customer_name text, customer_phone text, address text, landmark text, area text,
  lat double precision, lng double precision,
  system_kw int, problem text, note text,
  vendor_id uuid references profiles, portal_complaint_id text, complaint_date date,
  urgent boolean default false,
  scheduled_date date, time_slot text,
  technician_id uuid references profiles,
  status text check (status in ('new','assigned','accepted','arrived','in_progress','waiting_approval','done','cancelled')) default 'new',
  price_customer int default 0,        -- ग्राहक से लेना
  bill_to_vendor int default 0,        -- वेंडर के बिल में
  tech_earning int default 0,          -- टेक्नीशियन की कमाई (मेहनत)
  tech_petrol int default 30,
  cash_collected int default 0,        -- टेक्नीशियन ने नकद लिया
  otp text,                            -- ग्राहक का OTP
  created_at timestamptz default now(), done_at timestamptz
);

create table job_photos (
  id bigserial primary key,
  job_id uuid references jobs on delete cascade,
  kind text check (kind in ('before','after','part','other')),
  url text not null,                   -- Supabase Storage या चंदन के सर्वर का URL
  taken_at timestamptz default now(),
  uploaded_by uuid references profiles
);

create table part_requests (
  id bigserial primary key, job_id uuid references jobs,
  part_name text, amount int, photo_url text,
  status text check (status in ('pending','approved','rejected')) default 'pending',
  approved_by uuid references profiles, created_at timestamptz default now()
);
```

**पहुँच के नियम (RLS):** ग्राहक सिर्फ़ अपनी बुकिंग; वेंडर सिर्फ़ अपने `vendor_id` वाले काम और उनकी फ़ोटो; टेक्नीशियन सिर्फ़ अपने को दिए गए काम; एडमिन सब।
**स्टोरेज:** bucket `job-photos/{job_id}/{kind}-{timestamp}.jpg`।

---

## 6. ऐप में क्या बदलेगा
- **साझा पैकेज `nischint_core`:** `AppState` की जगह एक `Repository` इंटरफ़ेस (LocalRepository = अभी वाला SharedPreferences, RemoteRepository = Supabase/अपना सर्वर)। स्क्रीनें इंटरफ़ेस से बात करें, ताकि सर्वर बदलने पर स्क्रीनें न बदलें।
- **पार्टनर ऐप:** OTP लॉगिन → भूमिका सर्वर से (vendor/technician/admin):
  - वेंडर: शिकायतें अब सर्वर पर, हर शिकायत में "फ़ोटो रिपोर्ट" और "टेक्नीशियन कहाँ है" (status)।
  - टेक्नीशियन: आज के काम, काम की जानकारी + हिसाब, क़दम-दर-क़दम चेकलिस्ट, फ़ोटो (`image_picker`, `imageQuality: 60`, `maxWidth: 1280` → करीब 200 KB), ग्राहक OTP, मेरी कमाई।
  - एडमिन: नए काम, टेक्नीशियन को देना, पार्ट की मंज़ूरी, वेंडर का महीने का बिल।
- **ग्राहक ऐप:** OTP लॉगिन, बुकिंग सर्वर पर, स्टेटस और फ़ोटो रिपोर्ट देखना। WhatsApp बटन बना रहे (भरोसे के लिए)।
- **रास्ता:** `https://www.google.com/maps/dir/?api=1&destination=<lat,lng या पता>` url_launcher से।
- **सूचना:** Supabase Realtime से ऐप खुला हो तो तुरंत; बंद ऐप के लिए बाद में FCM (Firebase Cloud Messaging सिर्फ़ नोटिफ़िकेशन के लिए, मुफ़्त)।

---

## 7. PC पर सर्वर सेटअप के दिन की चेकलिस्ट
1. रास्ता चुनें (A/B/C)।
2. A/C: Supabase प्रोजेक्ट बनाएँ (Mumbai region), URL और anon key दें; ऊपर की SQL चलाएँ; bucket `job-photos` बनाएँ।
3. B/C: वेब सर्वर का पता, upload endpoint, और API बनाने/डालने की पहुँच दें।
4. बिज़नेस का असली WhatsApp और कॉल नंबर `packages/nischint_core/lib/content/config.dart` में।
5. टेक्नीशियन के रेट पक्के करें (ऊपर सेक्शन 3)।
6. फिर AI से कहें: "docs/TECHNICIAN_AND_SERVER_PLAN.md के हिसाब से v0.2 बनाओ"।
