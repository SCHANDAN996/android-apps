# 33 — ChatGPT / Codex के लिए हैंडओवर (25 अक्टूबर 2026)

> **किसके लिए:** ChatGPT, Codex या कोई भी AI जो इस repo में आगे काम करे — ख़ासकर चित्र ऐप में लगाना और
> Play upload। लिखा: Claude, 25 अक्टूबर 2026 दोपहर, D-145 के commit के साथ।
> **पहले ये पढ़ें:** `CLAUDE.md` (नियम) → `docs/04_NEXT.md` (अभी क्या) → यह फ़ाइल।
> डेवलपर से हिंदी/हिंग्लिश में बात।

---

## ० · अभी की हालत

- **शाखा:** `vidhivat/granth-kundali` — `main` से 76 commit आगे, **remote पर अभी नहीं** (upstream नहीं बना)।
  Claude की तरफ़ से push 403 पर रुकता है — push डेवलपर करें: `git push -u origin vidhivat/granth-kundali`।
- **ऐप का version:** `app/pubspec.yaml` में `1.2.0+7` (Play पर अभी 1.1.0)।
- **Claude के ताज़ा commit:** D-139 (पंडित-जाँच नहीं, दो छपे गवाह), D-140 (तुलसी विवाह, देव दीपावली, कार्तिक
  पूर्णिमा), D-141 (विधियों के 64 मंत्र), D-144 (ⓘ के «यह भी बोला जाता है» वाले मंत्र), D-145 (व्रत-पन्नों के मंत्र)।
- **दूसरे session (Codex) का काम — अभी बिना commit के, उसी working tree में:** D-135–D-137 (UI), D-142–D-143
  (Admin Panel, `admin/`), बहुत सी `app/lib/screens/*`, `app/lib/widgets/*`, नए `reading_*_v2.webp` चित्र,
  `docs/ADMIN_PANEL_*`, `docs/APP_TEST_2026-10-25.md`, `docs/JAANCH_SAMASYA_PANJI.md`, और docs 01/03/04 में उसकी
  entries। **UX-010 सुलझ चुका** (test की गड़बड़ी थी; पूरा ऐप 1454/1454 — `docs/JAANCH_SAMASYA_PANJI.md`)।
  → **release से पहले यह काम उसी session को अपने नाम से, फ़ाइल-दर-फ़ाइल commit करना है।**
- **25 अक्टूबर शाम:** दूसरे session ने अपना UI और Admin वाला काम commit कर दिया (ab37ef3, ab56473, 9d2c1f1) — उनकी docs वाली entries (D-135–137, D-142–143) अभी बिना commit के हैं। Claude: D-146 (ग्यारह आरतियाँ छपी आरती-पुस्तकों से)।
- **फ़ोन पर नई build अभी नहीं देखी गई।**

---

## १ · काम क — दो नए चित्र ऐप में लगाना

prompt: `docs/24_CHITRA_PROMPT.md` §१० (दोनों अंग्रेज़ी डिब्बे हूबहू ChatGPT में)।

| फ़ाइल | किस पन्ने पर | आज वहाँ क्या है |
|---|---|---|
| `vrat_tulsi_vivah_v1.webp` | व्रत-पन्ना «तुलसी विवाह» (+ होम/सूची की «आने वाले» पट्टी) | साधारण तुलसी (`DevotionalAssets.tulsi`) |
| `vrat_kartik_purnima_v1.webp` | व्रत-पन्ना «कार्तिक पूर्णिमा» | दीया (`DevotionalAssets.diya`) |

**क़दम:**

1. ChatGPT से **1024 × 1024 PNG, पारदर्शी** — सबसे बड़ी नाप में Downloads में।
   जाँचें: पीछे चेकर-बोर्ड (सफ़ेद/धूसर नहीं), कोई अक्षर या चिह्न नहीं, कोई चीज़ किनारे से कटी नहीं।
2. WebP बनाना (repo की जड़ `14 Vidhivat` से):
   ```bash
   python tools/banao_chitra.py "C:/Users/Admin/Downloads/<फ़ाइल>.png" vrat_tulsi_vivah_v1 900
   python tools/banao_chitra.py "C:/Users/Admin/Downloads/<फ़ाइल>.png" vrat_kartik_purnima_v1 900
   ```
   यह `app/assets/images/devotional/` में 900×900, 180 KB से छोटी WebP रखता है। ⚠️ यह सिर्फ़ **लगभग-सफ़ेद**
   पृष्ठभूमि हटाता है — PNG हरे (#00FF00) पर आया हो तो पहले हरा हटाना होगा (script में वह नहीं है)। `pubspec.yaml`
   में पूरा `assets/images/devotional/` फ़ोल्डर दर्ज है — वहाँ कुछ नहीं जोड़ना।
3. `app/lib/vidhi/vrat_artwork.dart` में, बाक़ी `static const _… = DevotionalArtwork(...)` के साथ:
   ```dart
   static const _tulsiVivah = DevotionalArtwork(
       assetPath: 'assets/images/devotional/vrat_tulsi_vivah_v1.webp',
       semanticLabel: 'तुलसी विवाह में मंडप के नीचे सजी तुलसी और शालिग्राम का सजावटी चित्र');
   static const _kartikPurnima = DevotionalArtwork(
       assetPath: 'assets/images/devotional/vrat_kartik_purnima_v1.webp',
       semanticLabel: 'कार्तिक पूर्णिमा में दीपदान के जलते दीयों का सजावटी चित्र');
   ```
   और `_byVratId` में: `'tulsi_vivah': _tulsiVivah,` `'kartik_purnima': _kartikPurnima,` (पुरानी दो पंक्तियों की जगह)।
   `semanticLabel` हिंदी में और «…का सजावटी चित्र» पर ख़त्म — screen reader यही पढ़ता है।
   `Image.asset` को `cacheWidth` **और** `cacheHeight` दोनों कभी नहीं (→ D-057; `artwork_ratio_test` पकड़ता है)।
4. जाँच (`app/` से):
   ```bash
   flutter test test/vrat_artwork_test.dart test/artwork_ratio_test.dart test/devotional_assets_test.dart test/vrat_panna_screen_test.dart
   ```
5. commit — **सिर्फ़ ये तीन फ़ाइलें, नाम लेकर** (`git add <path>`; `git add .` या `-A` कभी नहीं):
   दोनों `.webp` और `vrat_artwork.dart`। `docs/03_PROGRESS.md` में एक पंक्ति।

---

## २ · काम ख — Play पर v1.2.0 (upload)

पूरी फ़ाइल: **`app/play_store_assets/RELEASE_v1_2_0.md`** — §१ में डेवलपर के सात काम क्रम से (Blogger की privacy
post, Data safety, listing, «In-app purchases: No», release, push), §८ में AAB।

**क्रम:**

1. दूसरे session का बचा काम commit (§० देखें)।
2. पूरी जाँच — सब पास होनी चाहिए:
   ```bash
   cd app && flutter analyze && flutter test
   cd .. && python tools/jaancho_vrat.py && python tools/jaancho_granth.py
   cd engine && dart test
   ```
3. **versionCode:** Play Console → App bundle explorer में देखें कि आख़िरी चढ़ा versionCode क्या है। 7 या उससे बड़ा हो
   तो `app/pubspec.yaml` में `version: 1.2.0+<अगला>` (नाम 1.2.0 ही)। RELEASE फ़ाइल §८ में लिखा है कि 6 चढ़ा या
   नहीं, यह दर्ज नहीं — इसलिए Console से पक्का करें।
4. AAB: `cd app && flutter build appbundle --release` → `app/build/app/outputs/bundle/release/app-release.aab`
   (upload key `vidhivat-upload.jks` से signed — key और उसका password डेवलपर के पास; AI कभी नहीं भरेगा)।
5. वही build फ़ोन पर: होम, एक पूरी पूजा (अंत में दक्षिणा का हिस्सा), शरद पूर्णिमा/दीपावली, तुलसी विवाह का व्रत-पन्ना,
   जगह की खोज, ग्रंथालय। फ़ोन पर असली डेटा है — कुछ सहेजें/बदलें नहीं; system permission dialog पर AI न दबाए।
6. Console में upload, Review, Rollout — **डेवलपर** (बाहरी काम: Play, Blogger, email, पैसे — AI तैयार करता है,
   दबाता डेवलपर है)।
7. «What's new» (RELEASE फ़ाइल §२, 409/500) में जगह हो तो यह जोड़ सकते हैं: *"तुलसी विवाह, कार्तिक पूर्णिमा और
   देव दीपावली की तारीख़; विधियों और व्रतों के मंत्र छपी पूजा-पुस्तकों से फिर मिलाए गए।"* — «हर मंत्र» मत लिखिए,
   37 खाने अभी ख़ाली हैं।
8. release के बाद RELEASE फ़ाइल §९ — कौन-सा versionCode चढ़ा, यहीं दर्ज।

---

## ३ · काम ग — बाक़ी काम (Claude इसी क्रम में कर रहा है)

1. ~~विधियों के 37 ख़ाली मंत्र-खाने~~ — जाँचे (D-146): आरती-कदम जान-बूझकर ख़ाली हैं; ग्यारह आरती-पाठ छपी आरती-पुस्तकों से मिलाए। **अगला:** हनुमान चालीसा, सप्तश्लोकी दुर्गा, विश्वकर्मा सूक्त के स्रोत।
2. व्रत के 7 ख़ाली (अहोई, अमावस्या, जीवित्पुत्रिका, कार्तिक पूर्णिमा, ऋषि पंचमी, शुक्रवार, वट सावित्री) — कारण
   लिखा है; दो गवाह मिलें तभी भरना।
3. D-139 का आगे का क्रम: शुभ मुहूर्त → बचे त्योहार → पुराण-कथाएँ (`docs/04_NEXT.md`, `docs/30`)।
4. गुरु/शुक्र अस्त की पट्टी बंद है — डेवलपर के घर के पंचांग से 2026 की चार तारीख़ें चाहिए (`docs/04_NEXT.md`)।
5. दो चित्र (काम क) — डेवलपर ChatGPT से बनवाएँ।

---

## ४ · नियम — जो कोई भी कंटेंट छुए

- **मंत्र और नियम (D-139):** कम से कम **दो अलग छपी पुस्तकें**, पन्ना आँख से पढ़कर। OCR सिर्फ़ जगह ढूँढने के लिए।
  जो दो जगह पक्का न हो — ख़ाली, कारण लिखकर (`sthiti: "khaali"`, कारण विधि में `vikalp` में, व्रत-पन्ने पर `strot`
  में)। याद से कभी नहीं। ऐप कहीं «पंडित जी से पास» नहीं लिखेगा। मंत्रों का ऑडियो नहीं।
- औज़ार: `tools/mantra_jaanch/` (`khoj.py lao` से किताब उतारना, `dhoondo.py` से पन्ना, `jodo.py` से पंक्तियाँ काटकर
  देखना; किताबों की सूची `kitab.json`, पूरा लट्ठा `docs/18` §४२)।
- **बनी-बनाई JSON हाथ से कभी नहीं:** ग्रंथ → `tools/banao_granth.py`; नवरात्रि की विधियाँ और
  `durga_ashtami_kanya_poojan.json` → `tools/banao_navratri_din.py`।
- **व्रत-पन्ने हाथ की लिखावट में हैं** (छोटे object एक पंक्ति में) — पूरी फ़ाइल `json.dumps` से दोबारा मत लिखिए;
  सिर्फ़ बदला हुआ हिस्सा। हर बदलाव के बाद `python tools/jaancho_vrat.py`।
- फ़ाइलों में CRLF और LF दोनों हैं, और कुछ देवनागरी decomposed है — string मिलाकर बदलने से पहले पढ़कर देखें कि
  बदला भी या नहीं।
- ऐप के पाठ में किसी website का नाम नहीं (D-080); विज्ञापन कहीं नहीं (D-053); दक्षिणा पूजा के बीच कभी नहीं।
- ⓘ का पाठ 600 अक्षर तक; रोमन वाले खाने के बाहर अंग्रेज़ी शब्द नहीं (`content_bhasha_test`)।

## ५ · git नियम

- एक ही working tree में दो session — **सिर्फ़ अपनी फ़ाइलें, नाम लेकर stage**। दूसरे की फ़ाइल न छुएँ, न commit करें।
- कभी stage नहीं: `.claude/`, `.ebookcart-fix/`, `app/navratri_*.png`, `app/vidhivat_*.png`, `generated_granth_png/`,
  `tools/granth_paath/mahabharat/milan/vvn/vvn_33.txt` और `vvn_34.txt` (उनका «M» सिर्फ़ line-ending है), और दूसरे ऐप
  (`../01 Mistri Calculator`, `../03 Pro Kisan` …) की फ़ाइलें।
- बड़ा फ़ैसला → `docs/01_DECISIONS.md` में नया D-नंबर (**working copy वाली फ़ाइल देखकर** — अभी आख़िरी D-145);
  काम पूरा → `docs/03_PROGRESS.md` में नीचे जोड़ें; अगला क़दम → `docs/04_NEXT.md`।
