# Play Store — v1.2.0 (versionCode 7): इस update की हर चीज़ एक जगह

**बना:** 24 अक्टूबर 2026 · **किसके लिए:** डेवलपर — Play Console, Blogger और ASO, सब इसी फ़ाइल से।
**हालत:** पाठ, ASO, privacy, जवाब — तैयार। **AAB अभी नहीं बनी** — डेवलपर का फ़ैसला: दूसरे session का UI काम
(D-135…D-137) भी इसी release में, इसलिए वह commit हो जाए, और उसमें मिला regression **UX-010** (सप्तशती, छोटे फ़ोन पर
अध्याय-कार्ड) ठीक हो जाए — तब (§८)।

> Console में markdown नहीं चलता — डिब्बों का पाठ जस का तस चिपकाइए। यह फ़ाइल `listing_v1_2.md` (2–5 अक्टूबर) की जगह लेती है।

---

## ० · इस update में क्या-क्या है (v1.1.0 → v1.2.0)

- **ग्रंथालय:** पूरी गीता, सुंदरकांड, विष्णु सहस्रनाम, नौ उपनिषद, पुरुष/श्री/नारायण सूक्त, दुर्गा सप्तशती (पूरी, अर्थ सहित);
  महाभारत से विदुर नीति (आठों अध्याय), सनत्सुजातीय, यक्ष प्रश्न, भीष्म स्तवराज, अनुस्मृति, अठारह पर्वों का सार;
  गजेन्द्र मोक्ष; वेद-पुराण परिचय — हर श्लोक का रोमन और हिंदी अर्थ।
- **जन्म कुंडली** (सिर्फ़ गणित): लग्न/चंद्र/नवमांश चित्र, ग्रह, विंशोत्तरी दशा, अवकहड़ा, गुण मिलान।
- **जगह:** एक खाना → फ़ोन की जगह, या नाम लिखते ही खोज — ऐप के अंदर 5.4 लाख शहर-गाँव, और इंटरनेट हो तो वहाँ से भी।
- **त्योहार:** बीसों नियम सात साल पर जाँचे, पाँच धर्मसिंधु से; **शरद पूर्णिमा** नई; दीपावली का एक किनारा ठीक (D-138)।
- **दक्षिणा:** हर पूजा के बाद हिस्सा (दे चुके को धन्यवाद); कभी न देने वाले से 10वीं बार आने पर एक छोटी विनती।
- **UI** (दूसरा session): पढ़ने वाला पाठ justify, नया होम, चित्र वाले पाठ-कार्ड।

---

## १ · आपके काम — इसी क्रम में

| # | कहाँ | क्या |
|---|---|---|
| 1 | **Blogger** — post «https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html» | post **edit** करें (नई post नहीं — पता वही रहे) → HTML view → `app/play_store_assets/privacy_policy_blogger.html` का पूरा पाठ चिपकाएँ → Update। फिर पता खोलकर देखें कि «आख़िरी बदलाव: 23 अक्टूबर 2026» दिखे (§५) |
| 2 | Console → App content → **Data safety** | §६ के जवाब |
| 3 | Console → **Main store listing** | §२: छोटा विवरण, पूरा विवरण (**त्योहार वाला क्रम**), screenshots §४ |
| 4 | Console → App content → बाक़ी | §७ — ख़ासकर **In-app purchases: No** (पुराने `docs/19` में «हाँ» लिखा था; D-090 के बाद Play पर कोई product नहीं) |
| 5 | Console → **Production → Create new release** | AAB (§८) + What's new (§२) → Review → Rollout |
| 6 | git | `git push origin vidhivat/granth-kundali` |
| 7 | 16 नवंबर के बाद | §९ — विवरण का सामान्य क्रम वापस |

⚠ **दक्षिणा (PayU) — याद रहे** (D-090): भुगतान ऐप के बाहर PayU के पन्ने पर; Play की नीति में "धूसर इलाक़ा"। देने वाले को
कुछ अतिरिक्त नहीं मिलता — यही बचाव। Review में सवाल आए तो यही जवाब: स्वैच्छिक, 100% डेवलपर को, बदले में कुछ नहीं खुलता।

---

## २ · Store listing

### नाम — 29/30 (वही)

```
Vidhivat: Puja Vidhi Panchang
```

### छोटा विवरण — 79/80

```
Puja vidhi, Panchang, Gita, Vidur Niti, Saptashati arth sahit, Kundali, offline
```

### What's new — 409/500

```
नया: ग्रंथालय — गीता, सुंदरकांड, विष्णु सहस्रनाम, नौ उपनिषद, वेद के सूक्त; महाभारत से विदुर नीति, सनत्सुजातीय, यक्ष प्रश्न, भीष्म स्तवराज; गजेन्द्र मोक्ष — हर श्लोक का सरल हिंदी अर्थ। जन्म कुंडली — चित्र, ग्रह, दशा, गुण मिलान; सिर्फ़ गणित, फलादेश नहीं। जगह अब गाँव तक — फ़ोन से, या नाम लिखते ही खोज। शरद पूर्णिमा की पूरी जानकारी। पूजा पूरी होने पर दक्षिणा का हिस्सा हर बार। त्योहारों के नियम सात साल पर जाँचे।
```

### पूरा विवरण — त्योहार के मौसम वाला क्रम — 3989/4000 ← **अभी यही डालें**

करवा चौथ (29 अक्तू), धनतेरस (6 नव), दीपावली (8 नव), छठ (15 नव) — इन दिनों लोग इन्हीं नामों से खोजते हैं; यह हिस्सा
दूसरे नंबर पर, और बीत चुकी नवरात्रि नीचे। (`docs/19` §4 की चाल: «त्योहार से पहले उसका नाम ऊपर»।)

```
घर का पुरोहित, अब आपकी जेब में।

पूजा करनी है पर विधि याद नहीं? संकल्प में क्या-क्या बोलना है, यही अटक जाता है? विधिवत यही सुलझाता है — कदम-दर-कदम, आपकी अपनी भाषा में।


★ संकल्प अपने आप बनता है

हर पूजा संकल्प से शुरू होती है, और उसी पर सबसे ज़्यादा लोग अटकते हैं। विधिवत आज का पूरा संकल्प ख़ुद बना देता है — विक्रम संवत्, अयन, ऋतु, मास, पक्ष, तिथि, वार, नक्षत्र, गोत्र और आपका नाम, सब भरकर। संस्कृत में भी, सरल हिंदी में भी।


★ करवा चौथ, दीपावली, छठ — तारीख़ अपने आप

सबसे ऊपर — आज और आगे कौन सी पूजा है। शरद पूर्णिमा, करवा चौथ, धनतेरस, दीपावली, छठ, पितृ पक्ष, हरतालिका तीज, वट सावित्री — सबकी तारीख़ व्यापिनी नियम से।


★ नया — ग्रंथालय: गीता, सुंदरकांड, विदुर नीति

पूरी श्रीमद्भगवद्गीता — सात सौ श्लोक। पूरा सुंदरकांड। विष्णु सहस्रनाम। नौ उपनिषद। पुरुष, श्री और नारायण सूक्त। महाभारत से विदुर नीति (आठों अध्याय), सनत्सुजातीय, यक्ष प्रश्न, भीष्म स्तवराज, अनुस्मृति; गजेन्द्र मोक्ष; वेद-पुराण परिचय। हर श्लोक के नीचे रोमन और सरल हिंदी अर्थ। जहाँ छोड़ा, वहीं से आगे।


★ पूरी दुर्गा सप्तशती, हर श्लोक का अर्थ

देवी कवच, अर्गला, कीलक, रात्रि सूक्त; तेरहों अध्याय — प्रथम, मध्यम और उत्तम चरित्र; फिर देवी सूक्त, तीन रहस्य और क्षमा प्रार्थना। हर श्लोक के नीचे रोमन और सरल हिंदी अर्थ।


★ नया — जन्म कुंडली (सिर्फ़ गणित)

जन्म की तारीख़, समय, जगह भरिए — लग्न, चंद्र और नवमांश कुंडली का चित्र, नौ ग्रहों की राशि-अंश-नक्षत्र, विंशोत्तरी दशा, नाम का अक्षर और जन्म का पंचांग। गुण मिलान के अंक भी। जन्म-स्थान गाँव तक खोजिए। पूरे परिवार की कुंडलियाँ रखिए; चित्र भेजिए। जन्म का ब्यौरा सिर्फ़ आपके फ़ोन में रहता है। ऐप फल, दोष या उपाय नहीं बताता — वह आपके पंडित जी का काम है।


★ 29 पूजा विधि — कदम-दर-कदम

नित्य पूजा, गणेश पूजन, सत्यनारायण कथा, लक्ष्मी पूजन, रुद्राभिषेक, हनुमान पूजा, गृह प्रवेश, वाहन पूजा, कलश स्थापना, करवा चौथ, तुलसी पूजा, सूर्य अर्घ्य, मुंडन, उपनयन, श्राद्ध, छठ पूजा, हरतालिका तीज, वट सावित्री, रक्षाबंधन, भाई दूज, धनतेरस, गोवर्धन पूजा, विश्वकर्मा पूजा और भी।

हर पूजा में:
• सामग्री की पूरी सूची — टिक लगाकर तैयारी करें
• हर कदम पर क्या करना है, बड़े अक्षरों में
• मंत्र देवनागरी में, रोमन उच्चारण और अर्थ के साथ
• "क्या नहीं चढ़ाना" — गणेश जी को तुलसी नहीं, शिव जी को केतकी नहीं


★ पंचांग — आपके शहर के सूर्योदय से

तिथि, नक्षत्र, योग, करण, वार। सूर्योदय, सूर्यास्त, चंद्रोदय। राहुकाल, यमगंड, गुलिक, भद्रा, अभिजित मुहूर्त। चौघड़िया और होरा। पूर्णिमांत और अमांत दोनों। गणना दृक् गणित और लाहिड़ी अयनांश से।


★ व्रत, त्योहार और ग्रहण

एकादशी, प्रदोष, संकष्टी चतुर्थी, मासिक शिवरात्रि, पूर्णिमा, अमावस्या — आगे के सारे व्रत। साल भर के त्योहार। चंद्रग्रहण और सूर्यग्रहण — आपके शहर से दिखेगा या नहीं, और सूतक कब से कब तक।


★ व्रत कथाएँ, चालीसा और आरती

श्री सत्यनारायण व्रत कथा — पाँचों अध्याय। हरतालिका तीज, वट सावित्री, करवा चौथ की कथा। हनुमान चालीसा अर्थ सहित। दुर्गा, गणेश, लक्ष्मी, शिव, राम, कृष्ण, सरस्वती, हनुमान, सत्यनारायण जी की आरती और ॐ जय जगदीश हरे।


★ शारदीय नवरात्रि

नौ दिन, नौ रूप — घटस्थापना से विजयादशमी तक हर दिन की पूरी विधि, संक्षिप्त पूजा भी। कन्या पूजन, संधि पूजा, हवन और पारण। तारीख़ें आपके शहर के पंचांग से।


★ बिना इंटरनेट भी चलता है

पंचांग की पूरी गणना फ़ोन पर ही होती है। साढ़े पाँच लाख शहर-गाँव ऐप के अंदर; इंटरनेट हो तो जगह का नाम वहाँ भी खोजता है। कोई लॉगिन नहीं, कोई अकाउंट नहीं, कोई विज्ञापन नहीं। स्थान सिर्फ़ सूर्योदय और पंचांग के लिए, और वह फ़ोन से बाहर नहीं जाता।


★ जो यह ऐप नहीं करता

• भविष्य नहीं बताता, राशिफल नहीं देता — कुंडली में भी सिर्फ़ गणना है, फलादेश नहीं
• कोई उपाय या टोटका नहीं
• "यह करने से यह मिलेगा" जैसा कोई दावा नहीं

विधिवत सिर्फ़ विधि और समय बताता है। आपके घर या क्षेत्र की परंपरा अलग हो तो वही सही है। किसी भी ज़रूरी काम का अंतिम निर्णय अपने पंडित जी से करें।


Puja vidhi, panchang, Bhagavad Gita, Vidur Niti, Upanishads, Sundarkand, Vishnu Sahasranama and Durga Saptashati with Hindi meaning, janam kundali (lagna chart, navamsha, vimshottari dasha, gun milan), Navratri puja vidhi, shradh pitru paksha, karwa chauth, chhath puja, sankalp, choghadiya, shubh muhurat, vrat tyohar, Hanuman Chalisa aur aarti — sab ek jagah, offline. Hindu calendar with tithi, nakshatra, yoga, karana and rahu kaal for your city.
```

### पूरा विवरण — सामान्य क्रम — 3976/4000 (16 नवंबर के बाद)

```
घर का पुरोहित, अब आपकी जेब में।

पूजा करनी है पर विधि याद नहीं? संकल्प में क्या-क्या बोलना है, यही अटक जाता है? विधिवत यही सुलझाता है — कदम-दर-कदम, आपकी अपनी भाषा में।


★ संकल्प अपने आप बनता है

हर पूजा संकल्प से शुरू होती है, और उसी पर सबसे ज़्यादा लोग अटकते हैं। विधिवत आज का पूरा संकल्प ख़ुद बना देता है — विक्रम संवत्, अयन, ऋतु, मास, पक्ष, तिथि, वार, नक्षत्र, गोत्र और आपका नाम, सब भरकर। संस्कृत में भी, सरल हिंदी में भी।


★ नया — ग्रंथालय: गीता, सुंदरकांड, विदुर नीति

पूरी श्रीमद्भगवद्गीता — सात सौ श्लोक। पूरा सुंदरकांड। विष्णु सहस्रनाम। नौ उपनिषद। पुरुष, श्री और नारायण सूक्त। महाभारत से विदुर नीति (आठों अध्याय), सनत्सुजातीय, यक्ष प्रश्न, भीष्म स्तवराज, अनुस्मृति; गजेन्द्र मोक्ष; वेद-पुराण परिचय। हर श्लोक के नीचे रोमन और सरल हिंदी अर्थ। जहाँ छोड़ा, वहीं से आगे।


★ पूरी दुर्गा सप्तशती, हर श्लोक का अर्थ

देवी कवच, अर्गला, कीलक, रात्रि सूक्त; तेरहों अध्याय — प्रथम, मध्यम और उत्तम चरित्र; फिर देवी सूक्त, तीन रहस्य और क्षमा प्रार्थना। हर श्लोक के नीचे रोमन और सरल हिंदी अर्थ।


★ नया — जन्म कुंडली (सिर्फ़ गणित)

जन्म की तारीख़, समय, जगह भरिए — लग्न, चंद्र और नवमांश कुंडली का चित्र, नौ ग्रहों की राशि-अंश-नक्षत्र, विंशोत्तरी दशा, नाम का अक्षर और जन्म का पंचांग। गुण मिलान के अंक भी। जन्म-स्थान गाँव तक खोजिए। पूरे परिवार की कुंडलियाँ रखिए; चित्र भेजिए। जन्म का ब्यौरा सिर्फ़ आपके फ़ोन में रहता है। ऐप फल, दोष या उपाय नहीं बताता — वह आपके पंडित जी का काम है।


★ शारदीय नवरात्रि

नौ दिन, नौ रूप — घटस्थापना से विजयादशमी तक हर दिन की पूरी विधि, संक्षिप्त पूजा भी। कन्या पूजन, संधि पूजा, हवन और पारण। तारीख़ें आपके शहर के पंचांग से।


★ आने वाली पूजाएँ — अपने आप

सबसे ऊपर — आज और आगे कौन सी पूजा है। शरद पूर्णिमा, करवा चौथ, धनतेरस, दीपावली, छठ, पितृ पक्ष, हरतालिका तीज, वट सावित्री — सबकी तारीख़ व्यापिनी नियम से।


★ 29 पूजा विधि — कदम-दर-कदम

नित्य पूजा, गणेश पूजन, सत्यनारायण कथा, लक्ष्मी पूजन, रुद्राभिषेक, हनुमान पूजा, गृह प्रवेश, वाहन पूजा, कलश स्थापना, करवा चौथ, तुलसी पूजा, सूर्य अर्घ्य, मुंडन, उपनयन, श्राद्ध, छठ पूजा, हरतालिका तीज, वट सावित्री, रक्षाबंधन, भाई दूज, धनतेरस, गोवर्धन पूजा, विश्वकर्मा पूजा और भी।

हर पूजा में:
• सामग्री की पूरी सूची — टिक लगाकर तैयारी करें
• हर कदम पर क्या करना है, बड़े अक्षरों में
• मंत्र देवनागरी में, रोमन उच्चारण और अर्थ के साथ
• "क्या नहीं चढ़ाना" — गणेश जी को तुलसी नहीं, शिव जी को केतकी नहीं


★ पंचांग — आपके शहर के सूर्योदय से

तिथि, नक्षत्र, योग, करण, वार। सूर्योदय, सूर्यास्त, चंद्रोदय। राहुकाल, यमगंड, गुलिक, भद्रा, अभिजित मुहूर्त। चौघड़िया और होरा। पूर्णिमांत और अमांत दोनों। गणना दृक् गणित और लाहिड़ी अयनांश से।


★ व्रत, त्योहार और ग्रहण

एकादशी, प्रदोष, संकष्टी चतुर्थी, मासिक शिवरात्रि, पूर्णिमा, अमावस्या — आगे के सारे व्रत। साल भर के त्योहार। चंद्रग्रहण और सूर्यग्रहण — आपके शहर से दिखेगा या नहीं, और सूतक कब से कब तक।


★ व्रत कथाएँ, चालीसा और आरती

श्री सत्यनारायण व्रत कथा — पाँचों अध्याय। हरतालिका तीज, वट सावित्री, करवा चौथ की कथा। हनुमान चालीसा अर्थ सहित। दुर्गा, गणेश, लक्ष्मी, शिव, राम, कृष्ण, सरस्वती, हनुमान, सत्यनारायण जी की आरती और ॐ जय जगदीश हरे।


★ बिना इंटरनेट भी चलता है

पंचांग की पूरी गणना फ़ोन पर ही होती है। साढ़े पाँच लाख शहर-गाँव ऐप के अंदर; इंटरनेट हो तो जगह का नाम वहाँ भी खोजता है। कोई लॉगिन नहीं, कोई अकाउंट नहीं, कोई विज्ञापन नहीं। स्थान सिर्फ़ सूर्योदय और पंचांग के लिए, और वह फ़ोन से बाहर नहीं जाता।


★ जो यह ऐप नहीं करता

• भविष्य नहीं बताता, राशिफल नहीं देता — कुंडली में भी सिर्फ़ गणना है, फलादेश नहीं
• कोई उपाय या टोटका नहीं
• "यह करने से यह मिलेगा" जैसा कोई दावा नहीं

विधिवत सिर्फ़ विधि और समय बताता है। आपके घर या क्षेत्र की परंपरा अलग हो तो वही सही है। किसी भी ज़रूरी काम का अंतिम निर्णय अपने पंडित जी से करें।


Puja vidhi, panchang, Bhagavad Gita, Vidur Niti, Upanishads, Sundarkand, Vishnu Sahasranama and Durga Saptashati with Hindi meaning, janam kundali (lagna chart, navamsha, vimshottari dasha, gun milan), Navratri puja vidhi, shradh pitru paksha, karwa chauth, chhath puja, sankalp, choghadiya, shubh muhurat, vrat tyohar, Hanuman Chalisa aur aarti — sab ek jagah, offline. Hindu calendar with tithi, nakshatra, yoga, karana and rahu kaal for your city.
```

---

## ३ · ASO — कौन-सा शब्द कहाँ (script से गिना)

Play का अलग keyword खाना नहीं — नाम, छोटा विवरण और पूरा विवरण ही। हर शब्द हिंदी और रोमन, दोनों रूप गिने:

| शब्द | नाम | छोटा | पूरा (त्योहार क्रम) |
|---|---|---|---|
| पूजा विधि · puja vidhi | 1 | 1 | 3 |
| पंचांग · panchang | 1 | 1 | 6 |
| संकल्प · sankalp | 0 | 0 | 5 |
| चौघड़िया · choghadiya | 0 | 0 | 2 |
| मुहूर्त · muhurat | 0 | 0 | 2 |
| राहुकाल · rahu kaal | 0 | 0 | 2 |
| व्रत · vrat | 0 | 0 | 6 |
| त्योहार · tyohar | 0 | 0 | 3 |
| कुंडली · kundali | 0 | 1 | 4 |
| गुण मिलान · gun milan | 0 | 0 | 2 |
| गीता · gita | 0 | 1 | 3 |
| सुंदरकांड · sundarkand | 0 | 0 | 3 |
| विदुर नीति · vidur niti | 0 | 1 | 3 |
| उपनिषद · upanishad | 0 | 0 | 2 |
| विष्णु सहस्रनाम · vishnu sahasranama | 0 | 0 | 2 |
| सप्तशती · saptashati | 0 | 1 | 2 |
| हनुमान चालीसा · hanuman chalisa | 0 | 0 | 2 |
| आरती · aarti | 0 | 0 | 3 |
| सत्यनारायण · satyanarayan | 0 | 0 | 3 |
| नवरात्रि · navratri | 0 | 0 | 2 |
| करवा चौथ · karwa chauth | 0 | 0 | 5 |
| दीपावली · diwali | 0 | 0 | 2 |
| धनतेरस · dhanteras | 0 | 0 | 2 |
| छठ · chhath | 0 | 0 | 4 |
| शरद पूर्णिमा · sharad purnima | 0 | 0 | 1 |
| श्राद्ध · shradh | 0 | 0 | 2 |
| ग्रहण · grahan | 0 | 0 | 3 |

**सब शब्द कम से कम एक जगह हैं।**

**नियम (`docs/19` §4, D-105):**
- **नाम में** «Puja Vidhi» और «Panchang» — सबसे ज़्यादा खोजे जाने वाले दो; बदलें नहीं (नाम बदलने से पुरानी ranking हिलती है)।
- **छोटे विवरण में** नई बड़ी चीज़ें: Gita, Vidur Niti, Saptashati, Kundali — रोमन में, क्योंकि लोग अंग्रेज़ी keyboard से खोजते हैं।
- **पूरे विवरण के अंत की अंग्रेज़ी पंक्ति** रोमन-खोज वालों के लिए — उसमें शब्द बस एक बार, ठूँसे नहीं।
- **कभी नहीं:** राशिफल, भविष्यवाणी, उपाय, टोटका, वशीकरण, मांगलिक, horoscope prediction, astrology remedies — ऐप में
  नहीं हैं; डालना listing policy तोड़ेगा और uninstall बढ़ाएगा। (विवरण में «राशिफल नहीं देता», «दोष या उपाय नहीं बताता» —
  सिर्फ़ इनकार में, जैसे पहले।)
- **कुंडली** अब लिख सकते हैं — सिर्फ़ गणित, फलादेश नहीं (D-105)।
- किसी वेबसाइट या दूसरे ऐप का नाम नहीं (D-080 का भाव)।

---

## ४ · Screenshots और चित्र

**क्रम** (पहले दो सबसे ज़्यादा देखे जाते हैं; नया UI commit होने के बाद फ़ोन से लें — `docs/19` §7):

| # | पन्ना | ऊपर लिखा (overlay) |
|---|---|---|
| 1 | संकल्प — बना हुआ पूरा संकल्प | संकल्प अपने आप बनता है |
| 2 | होम — आने वाले त्योहार (दीपावली/छठ दिखे) | हर त्योहार की तारीख़, आपके शहर से |
| 3 | ग्रंथालय — चित्र वाले कार्ड | गीता, सुंदरकांड, विदुर नीति — अर्थ सहित |
| 4 | कोई पाठ «अर्थ दिखाएँ» के साथ (गीता २ या विदुर नीति) | हर श्लोक का सरल हिंदी अर्थ |
| 5 | विधि प्लेयर — मंत्र वाला कदम | कदम-दर-कदम, बड़े अक्षरों में |
| 6 | आज का पंचांग | तिथि, नक्षत्र, राहुकाल, चौघड़िया |
| 7 | जन्म कुंडली का चित्र (**बनावटी नाम और ब्यौरा**) | जन्म कुंडली — सिर्फ़ गणित |
| 8 | जगह की खोज — कोई गाँव | गाँव तक की जगह |

⛔ दक्षिणा वाली स्क्रीन नहीं; किसी असली व्यक्ति का नाम/जन्म-ब्यौरा नहीं; «दोष» या फ़ैसला दिखाने वाली कोई तस्वीर नहीं।
**Feature graphic / icon:** `vidhivat_feature_graphic_1024x500.png`, `vidhivat_play_icon_512.png` — वही रहें।

---

## ५ · Privacy policy

**पता:** https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html (Console के «Privacy policy URL» में यही — बदलना नहीं)।
**फ़ाइल:** `app/play_store_assets/privacy_policy_blogger.html` (Blogger के लिए) · `privacy_policy.html` (पूरी प्रति, वही पाठ)।
**आख़िरी बदलाव:** 23 अक्टूबर 2026।

**इस update में क्या बदला (§4 «इंटरनेट»):**
- पहले: «इंटरनेट सिर्फ़ दक्षिणा के लिए; ऐप ख़ुद कुछ नहीं भेजता»।
- अब: इंटरनेट दो काम में — (१) **जगह की खोज:** लिखा हुआ नाम Photon (komoot GmbH, OpenStreetMap डेटा) को जाता है; GPS,
  नाम, जन्म-ब्यौरा नहीं; उनकी नीति का link; (२) **दक्षिणा:** PayU का पन्ना। बाक़ी सब वैसा ही — स्थान सिर्फ़ फ़ोन पर, कोई
  खाता नहीं, कोई विज्ञापन नहीं, पितृ-स्मरण की सूचनाएँ फ़ोन पर ही।
- ऐप के अंदर «लाइसेंस» पन्ने पर: गाँवों की सूची (GeoNames, CC BY 4.0) और OpenStreetMap (ODbL) का श्रेय।

<details><summary><b>पूरा पाठ — जैसा Blogger पर दिखेगा (हिंदी + English)</b></summary>

```
आख़िरी बदलाव: 23 अक्टूबर 2026 · ऐप: विधिवत (com.vidhivat)

एक वाक्य में: विधिवत का अपना कोई सर्वर नहीं है, और जो कुछ
आप भरते हैं — नाम, गोत्र, कुंडली, पूर्वजों की तिथियाँ — वो आपके फ़ोन में ही
रहता है। ऐप से बाहर सिर्फ़ एक चीज़ जाती है: जगह खोजते समय लिखा हुआ नाम,
खोज-सेवा को (§4)।

#### 1. ऐप क्या इकट्ठा करता है

हमारे पास कुछ नहीं आता। विधिवत में कोई लॉगिन नहीं, कोई खाता नहीं,
कोई विज्ञापन नहीं, और कोई analytics नहीं है। ऐप का कोई सर्वर नहीं है,
इसलिए आपका डेटा हम तक पहुँचने की कोई जगह ही नहीं है। अकेला अपवाद: जगह
खोजते समय जो नाम आप लिखते हैं, वह सीधे खोज-सेवा (Photon) को जाता है —
विवरण §4 में।

#### 2. जो आपके फ़ोन में रहता है

ऐप को चलाने के लिए कुछ बातें फ़ोन में सहेजी जाती हैं। ये
सिर्फ़ आपके फ़ोन के अंदर रहती हैं — न हमें दिखती हैं,
न किसी और को।

क्या | किसलिए

आपका नाम और गोत्र | संकल्प का वाक्य बनाने के लिए

घर के दूसरे लोगों के नाम, और संकल्प का रूप (पुरुष / स्त्री) | हर सदस्य के लिए उसका अपना संकल्प बनाने के लिए

चुना हुआ शहर या जगह का नाम | सूर्योदय और पंचांग सही निकालने के लिए

जगह का प्रकार (नगर / तीर्थ) | संकल्प में जगह के लिए सही शब्द बोलने के लिए

मास-पद्धति (पूर्णिमांत / अमांत) | आपके क्षेत्र का पंचांग

सामग्री की टिक | तैयारी याद रखने के लिए

पूजा में आप कहाँ तक पहुँचे | बीच से दोबारा शुरू करने के लिए

पाठ में कहाँ तक पढ़ा (जैसे दुर्गा सप्तशती का अध्याय) | अगली बार वहीं से खोलने के लिए

पूर्वजों के नाम, रिश्ता, पुण्यतिथि (तिथि या तारीख़) और जगह — अगर आप भरें | श्राद्ध की तिथि निकालने और याद दिलाने के लिए

जन्म कुंडली के लिए नाम, जन्म की तारीख़, समय और जगह — अगर आप भरें | कुंडली का गणित (लग्न, ग्रह, दशा की तारीख़ें) इसी फ़ोन में निकालने के लिए

ऐप हटाने पर यह सब आपके फ़ोन से मिट जाता है। आप चाहें तो Android की
सेटिंग में जाकर ऐप का डेटा कभी भी साफ़ कर सकते हैं।

#### 3. स्थान (location) की अनुमति

ऐप स्थान की अनुमति माँगता है, और यह बताना ज़रूरी है कि क्यों।

- किसलिए: सूर्योदय, सूर्यास्त, तिथि और चौघड़िया जगह
के साथ बदलते हैं। बिना जगह जाने पंचांग ग़लत निकलेगा।

- कब: सिर्फ़ तब जब ऐप खुला हो और आप ख़ुद
"मेरी जगह अपने आप पहचानें" दबाएँ। पीछे चलते हुए (background)
ऐप कभी आपका स्थान नहीं लेता।

- कहाँ जाता है: कहीं नहीं। अक्षांश-देशांतर
सिर्फ़ आपके फ़ोन में रहते हैं और उन्हीं से गणना होती है।

- मना करने पर: ऐप पूरा चलता रहेगा — आप अपना शहर हाथ से
चुन सकते हैं, या अपनी जगह का नाम ख़ुद लिख सकते हैं।

#### 4. इंटरनेट

पूरी गणना — पंचांग, तिथि, मुहूर्त, ग्रहण, संकल्प — आपके फ़ोन पर
ही होती है। सारी पूजा-विधियाँ, मंत्र, कथाएँ और चालीसा ऐप के अंदर
पहले से मौजूद हैं। ऐप बिना इंटरनेट के पूरा चलता है।

इंटरनेट सिर्फ़ दो कामों में लगता है:

- जगह की खोज: शहर, गाँव या जन्म-स्थान का नाम लिखते समय लिखा
हुआ नाम OpenStreetMap के डेटा पर चलने वाली खोज-सेवा Photon (komoot GmbH) को
जाता है, ताकि मिलती-जुलती जगहें और उनके अक्षांश-देशांतर दिखें। आपकी जगह (GPS),
नाम, जन्म का ब्यौरा या कुछ और नहीं जाता। हर इंटरनेट सेवा की तरह वहाँ आपके फ़ोन
का इंटरनेट पता (IP) दिखता है — उसकी नीति:
komoot.com/privacy (https://www.komoot.com/privacy)।
बिना इंटरनेट के भी ऐप के अंदर की सूची (लगभग साढ़े पाँच लाख शहर-गाँव) से खोज होती है।

- दक्षिणा: जब आप ख़ुद स्वेच्छा से दक्षिणा देना चुनें। तब PayU का
भुगतान पन्ना आपके browser या UPI ऐप में खुलता है (नीचे देखें)।

इनके सिवा ऐप ख़ुद कुछ नहीं भेजता।

#### 4क. याद दिलाने वाली सूचनाएँ (notifications)

- पूर्वजों की पुण्यतिथि (श्राद्ध) याद दिलाने के लिए ऐप सूचना दिखा सकता है —
सिर्फ़ तब जब आप ख़ुद यह switch चालू करें। तभी Android
सूचना की अनुमति माँगी जाती है।

- सूचनाएँ आपके फ़ोन पर ही तय होती हैं — किसी सर्वर से
नहीं आतीं, कहीं नहीं जातीं।

- सूचना में पूर्वज का नाम तभी आता है जब आप ख़ुद चुनें;
वरना सिर्फ़ "आज परिवार का स्मरण-दिन है"।

#### 5. दक्षिणा (in-app purchase)

- दक्षिणा पूरी तरह वैकल्पिक है। देने या न देने से ऐप
में कुछ नहीं बदलता — कोई पूजा, कोई पाठ, कोई सुविधा बंद नहीं होती।

- भुगतान PayU (PayU Payments Private Limited) के अपने
पन्ने पर होता है, विधिवत में नहीं। ऐप को आपके कार्ड, UPI, बैंक या नाम
का कोई विवरण नहीं मिलता।

- ऐप को यह भी पता नहीं चलता कि भुगतान हुआ या नहीं। लौटकर आप ख़ुद
"दक्षिणा दे दी" दबाएँ, तो फ़ोन में बस इतना दर्ज होता है — ताकि आपसे
छह महीने तक दोबारा न पूछा जाए। यह भी फ़ोन से बाहर नहीं जाता।

- भुगतान के पन्ने पर PayU की अपनी नीति लागू होती है:
payu.in/privacy-policy (https://payu.in/privacy-policy/)

#### 6. तीसरे पक्ष

ऐप में कोई विज्ञापन SDK नहीं, कोई analytics नहीं, कोई
crash-reporting सेवा नहीं, और कोई social login नहीं है। Advertising ID
का इस्तेमाल नहीं होता।

इकलौता तीसरा पक्ष PayU का भुगतान पन्ना है, और वो भी
सिर्फ़ तब जब आप ख़ुद दक्षिणा देना चुनें — वह ऐप के बाहर, आपके browser या
UPI ऐप में खुलता है।

#### 7. बच्चे

यह ऐप सब उम्र के लोगों के लिए है, पर बच्चों को लक्ष्य करके नहीं
बनाया गया। यह किसी से उम्र नहीं पूछता, क्योंकि यह किसी से कुछ
पूछता ही नहीं।

#### 8. आपके अधिकार

चूँकि हमारे पास आपका कोई डेटा है ही नहीं, हमसे कुछ मिटवाने या माँगने की
ज़रूरत नहीं पड़ती। फ़ोन में रखी हर चीज़ पूरी तरह आपके नियंत्रण में है —
Android की सेटिंग से ऐप का डेटा साफ़ कीजिए, या ऐप हटा दीजिए।

#### 9. बदलाव

नीति बदलेगी तो ऊपर की तारीख़ बदल जाएगी। कोई बड़ा बदलाव हुआ तो ऐप के
अपडेट-नोट में भी लिखा जाएगा।

#### 10. संपर्क

कोई सवाल हो तो लिखिए — all.chandansingh@gmail.com (mailto:all.chandansingh@gmail.com)

#### Vidhivat — Privacy Policy

Last updated: 23 October 2026 · App: Vidhivat (com.vidhivat)

In one line: Vidhivat has no server of its own, and
whatever you enter — names, gotra, birth charts, ancestors' dates — stays on
your phone. Only one thing leaves the app: the place name you type while
searching for a place, sent to a search service (§4).

#### 1. What we collect

Nothing reaches us. There is no login, no account, no
advertising and no analytics in Vidhivat. The app has no server, so there is
nowhere for your data to reach us. The one exception: the place name you type
while searching for a place goes directly to a search service (Photon) — see §4.

#### 2. What stays on your phone

A few things are saved on the device so the app can work. They stay
inside your phone only — we cannot see them, and neither
can anyone else.

What | Why

Your name and gotra | To compose the sankalp sentence

Names of other family members, and the sankalp form (male / female) | To compose each member's own sankalp

Chosen city or place name | To compute sunrise and the panchang correctly

Type of place (town / tirtha) | To use the right word for the place in the sankalp

Month system (Purnimanta / Amanta) | Regional panchang convention

Material checklist ticks | To remember your preparation

Progress through a puja | To resume where you left off

How far you have read a text (e.g. a Durga Saptashati chapter) | To reopen it at the same place

Ancestors' names, relation, death anniversary (tithi or date) and place — only if you enter them | To compute the shraddha tithi and remind you

For a birth chart: name, date, time and place of birth — only if you enter them | To compute the chart (ascendant, planets, dasha dates) on this phone

Uninstalling the app removes all of it. You can also clear the app's data
at any time from Android settings.

#### 3. Location permission

- Why: sunrise, sunset, tithi and choghadiya all change
with place. Without a location the panchang would be wrong.

- When: only while the app is open and only when you tap
"detect my location" yourself. The app never accesses location in the
background.

- Where it goes: nowhere. The coordinates
stay on your phone and are used for the calculation there.

- If you decline: the app works fully. You can pick a city
by hand, or type your own place name.

#### 4. Internet

All calculation — panchang, tithi, muhurat, eclipses, sankalp — happens
on your phone. Every puja procedure, mantra, katha and
chalisa is bundled inside the app. It works fully offline.

The internet is used for two things only:

- Place search: while you type the name of a city, village or
birth place, the name you typed is sent to Photon (komoot GmbH), a
search service built on OpenStreetMap data, to suggest matching places and their
coordinates. Your location (GPS), name, birth details or anything else are
not sent. Like any internet service it sees your phone's IP address — its
policy: komoot.com/privacy (https://www.komoot.com/privacy).
Without the internet, search still works from the list inside the app
(about 5.4 lakh cities and villages).

- Dakshina: when you choose to offer a voluntary dakshina.
PayU's payment page then opens in your browser or UPI app.

Apart from these, the app itself sends nothing.

#### 4a. Reminder notifications

- The app can remind you of an ancestor's shraddha day — only if
you turn this switch on yourself. Only then is Android's
notification permission requested.

- Reminders are scheduled on your phone — they come from no
server and go nowhere.

- An ancestor's name appears in the notification only if you
choose so; otherwise just "today is the family's remembrance day".

#### 5. Dakshina (in-app purchase)

- Dakshina is entirely optional. Giving or not giving
changes nothing in the app — no puja, no text, no feature is withheld.

- Payment happens on the own page of PayU (PayU Payments
Private Limited), not inside Vidhivat. The app receives no card,
UPI, bank or name details.

- The app does not even learn whether a payment was made. If you come back
and tap "I have given", the phone records only that — so you are not
asked again for six months. That too stays on the phone.

- PayU's own policy applies on the payment page:
payu.in/privacy-policy (https://payu.in/privacy-policy/)

#### 6. Third parties

There is no advertising SDK, no analytics, no crash
reporting service and no social login. The Advertising ID is not used. The
only third party is PayU's payment page, and only if you
choose to give a dakshina — it opens outside the app, in your browser or UPI
app.

#### 7. Children

The app is suitable for all ages but is not directed at
children. It never asks anyone's age, because it never asks
anything.

#### 8. Your rights

Since we hold no data about you, there is nothing to request or delete
from us. Everything on the device is fully under your control — clear the
app's data from Android settings, or uninstall the app.

#### 9. Changes

If this policy changes, the date at the top changes. Anything significant
will also be noted in the app's release notes.

#### 10. Contact

all.chandansingh@gmail.com (mailto:all.chandansingh@gmail.com)

विधिवत · Vidhivat
```

</details>

---

## ६ · Data safety — जवाब

| सवाल | जवाब | क्यों |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | जगह की खोज में लिखा नाम ऐप से सीधे Photon सेवा को जाता है (D-129, D-134) |
| Data type | **App activity → In-app search history** — सिर्फ़ यही | नाम, ईमेल, फ़ोन, संपर्क, फ़ोटो, फ़ाइलें — कुछ नहीं |
| Location (Approximate / Precise) | **Not collected** | GPS वाली जगह सिर्फ़ फ़ोन पर पंचांग के लिए; कहीं नहीं भेजी जाती |
| Collected / Shared | **Collected: Yes · Shared: No** | यूज़र के लिखने पर उसी सेवा को, जिससे वह खोज रहा है |
| Processed ephemerally? | **Yes** | ऐप उसे कहीं नहीं रखता |
| Required or optional? | **Optional** | बिना इसके ऐप की अपनी सूची से खोज होती है |
| Purpose | **App functionality** | — |
| Encrypted in transit? | **Yes** | https |
| Users can request deletion? | **No** | ऐप के पास कोई खाता या सर्वर नहीं |
| Financial info / Purchase history | **Not collected** | दक्षिणा PayU के अपने पन्ने पर |
| Ads / Advertising ID | **No** | ऐप में कोई विज्ञापन नहीं (D-053) |

⚠ Console की भाषा बदलती रहती है — जो खाना ऊपर न दिखे, उसमें "Not collected"।

---

## ७ · Console के बाक़ी खाने

| खाना | जवाब |
|---|---|
| App category | **Lifestyle** (वही) |
| Tags | Religious text · Lifestyle · Calendar · Books & reference — **Horoscope नहीं** |
| Contains ads | **No** |
| In-app purchases | **No** — Play पर कोई product नहीं (D-090: दक्षिणा PayU से, ऐप के बाहर) |
| Target audience | जो पहले भरा, वही |
| Content rating | हिंसा, यौन, नशा, जुआ — सब «नहीं»; यूज़र आपस में बात नहीं करते; यूज़र की जगह दूसरों से साझा नहीं → **Everyone / 3+** |
| News / Government / Financial / Health | No / No / None / None |
| Permissions | स्थान (पंचांग), सूचनाएँ + boot (पितृ-स्मरण, यूज़र के चालू करने पर), **INTERNET — नया** (जगह की खोज, दक्षिणा का पन्ना)। कोई संवेदनशील अनुमति (SMS, call log, सब फ़ाइलें) नहीं — declaration form नहीं |
| Privacy policy URL | https://vidhivatpuja.blogspot.com/2026/09/vidhivat-privacy-policy-root-bg-12151c.html |

---

## ८ · AAB — कब और कैसे (AI का काम, आपके कहने पर)

1. दूसरा session अपना UI काम commit करे, और **UX-010** ठीक हो (`docs/JAANCH_SAMASYA_PANJI.md`)।
2. `flutter analyze`, पूरा `flutter test` (अभी 1443 में 1 फ़ेल — वही UX-010), `python tools/jaancho_granth.py`,
   `python tools/jaancho_vrat.py`, `cd engine && dart test`।
3. `flutter build appbundle --release` → `app/build/app/outputs/bundle/release/app-release.aab` — upload key
   (`vidhivat-upload.jks`) से signed, **versionCode 7**।
4. वही build फ़ोन पर: होम, एक पूरी पूजा (अंत में दक्षिणा का हिस्सा), शरद पूर्णिमा/दीपावली, जगह की खोज, ग्रंथालय।
5. यह फ़ाइल «AAB बनी: तारीख़, आकार, commit» से अद्यतन।

**versionCode 7 क्यों:** 6 वाली AAB 2–8 अक्टूबर में कई बार बनी, पर Play पर चढ़ी या नहीं — repo में दर्ज नहीं। 7 हर हाल में
सुरक्षित। नाम `1.2.0` ही — Play पर अभी 1.1.0।

---

## ९ · release के बाद

- **16 नवंबर (छठ के बाद):** पूरा विवरण §२ के «सामान्य क्रम» पर लौटाएँ। अगला मौसम: **मकर संक्रांति (14 जनवरी)** और
  **वसंत पंचमी** से दो हफ़्ते पहले उनका हिस्सा ऊपर।
- पहले हफ़्ते की crash/ANR (Console → Quality) देखें; review में आए सवाल यहाँ लिखें।
- Play पर कौन-सा versionCode चढ़ा — यहीं दर्ज करें (इस बार की उलझन दोबारा न हो)।
