# 24 — चित्रों के लिए ChatGPT prompt (नवरात्रि)

> **किसके लिए:** ChatGPT / DALL·E में चिपकाने के लिए। नीचे के डिब्बे
> **हूबहू** चिपकाइए।
> **prompt अंग्रेज़ी में क्यों:** चित्र बनाने वाले मॉडल अंग्रेज़ी में
> कहीं ज़्यादा सटीक निकलते हैं। बाक़ी सब हिंदी में है।
> **तारीख़:** 12 सितम्बर 2026 · योजना `docs/23_NAVRATRI_YOJANA.md`

---

## ⚠️ पहले यह पढ़िए — तीन नियम जो तोड़े तो चित्र बेकार जाएगा

### १. नाप और पृष्ठभूमि

ऐप में दो तरह के चित्र हैं और दोनों के नियम अलग हैं:

| तरह | नाप | आकार | कहाँ लगता है |
|---|---|---|---|
| **देव-चित्र** (hero) | **900 × 900** | 80–180 KB | पूजा का कार्ड, विवरण का पन्ना |
| **निर्देश-चित्र** (guide) | **512 × 512** | 19–57 KB | विधि के किसी एक कदम पर |

**दोनों `.webp` और दोनों पारदर्शी (alpha) हैं।** ऐप की पृष्ठभूमि गहरी
नीली-काली (`#0D1118`) भी होती है और हल्की क्रीम (`#F9F3E9`) भी — इसलिए
चित्र के पीछे **कोई दृश्य, कोई दीवार, कोई फ़र्श नहीं** होना चाहिए।

> ChatGPT पारदर्शी PNG हमेशा ठीक से नहीं देता। इसलिए prompt में
> **"pure white background"** लिखा है — सफ़ेद हटाना आसान है। हटाने और
> `.webp` बनाने की विधि सबसे नीचे §५ में है।

### २. जो कभी नहीं

- **कोई अक्षर नहीं** — न देवनागरी, न अंग्रेज़ी, न watermark, न signature
- **किसी कलाकार या प्रकाशक की नक़ल नहीं** — "in the style of \[नाम\]"
  कभी मत लिखिए
- **कोई असली इंसान नहीं** — कन्या पूजन वाले चित्र में भी चेहरे
  काल्पनिक रहें
- **डरावना कुछ नहीं** — ख़ून, कटा सिर, लाश। कालरात्रि पर यह ख़ास ध्यान
  (§३ देखें)

### ३. ⚠️ इकोनोग्राफ़ी पंडित जी से मिलाइए

नीचे हर देवी का वाहन और आयुध लिखा है — यह **प्रचलित रूप** है (दुर्गा
सप्तशती और देवी कवच की परंपरा से)। पर पद्धतियों में फ़र्क़ मिलता है —
किसी में कात्यायनी का वाहन सिंह, किसी में शेर; कूष्मांडा की भुजाएँ आठ
भी मिलती हैं और दस भी।

> **चित्र बन जाने के बाद पंडित जी को दिखाइए, तब ऐप में डालिए।** मंत्र
> वाला नियम (→ D-041) चित्रों पर भी उतना ही लागू है — बल्कि चित्र तो
> और साफ़ दिखता है।

---

## १ · शैली का आधार — यह हर prompt में जाएगा

ऐप के मौजूदा चित्रों की शैली यही है (सरस्वती, लक्ष्मी, हनुमान वग़ैरह
इसी में बने हैं)। इसे **STYLE BLOCK** कहते हैं और यह हर prompt के अंत
में जुड़ेगा:

```
STYLE: Devotional Indian religious illustration, photorealistic 3D-render
blended with classical Indian calendar-art sensibility. Rich warm palette
of gold, saffron, marigold orange and deep red. Luxuriant silk garments
with fine gold zari borders, detailed traditional temple jewellery with
ruby and emerald settings, delicate floral ornaments. Soft golden rim
lighting; a radiant golden sun-ray halo behind the head. Serene,
benevolent, front-facing expression; calm and dignified, never sensual.
Full figure, centred, isolated on a pure white background with clear
margin on all four sides — absolutely no scenery, no floor, no wall, no
shadow cast onto a surface. Square composition. Ultra detailed, crisp
edges suitable for cut-out. NO text, NO letters, NO watermark, NO
signature, NO border frame.
```

---

## २ · पर्व का मुख्य चित्र — सबसे पहले यही

**फ़ाइल:** `navratri_parv_v1.webp` · **900 × 900**

```
A ceremonial Navratri home altar centrepiece, no human figures.
Centre: a polished brass kalash with an ornate engraved body, a red
kumkum swastika on its front, filled to the brim, its mouth ringed with
five fresh mango leaves, topped by a whole brown coconut wrapped in a
red-and-gold bordered cloth and tied with red mauli thread.
In front of the kalash, slightly lower and to the left: a shallow clay
pot holding moist soil from which fresh bright-green barley sprouts
(jau / jayanti) rise about four inches, dense and healthy.
To the right: a single brass lamp with a tall steady flame — the akhand
jyoti — its wick clearly visible in golden ghee.
Around the base: a garland of orange and yellow marigolds, loose rose
petals, whole rice grains, a small brass bowl of kumkum.
Behind everything: a warm glowing red-and-gold lotus-petal mandala halo,
radiating softly.

STYLE: <ऊपर वाला STYLE BLOCK चिपकाइए>
```

---

## ३ · नौ देवियाँ — दिन १ से ९

हर prompt के आगे यह लिखिए, फिर STYLE BLOCK:

> `A single Hindu goddess figure, full body, seated or standing as described.`

### दिन १ — शैलपुत्री
```
The goddess Shailaputri, daughter of the mountain. Fair complexion,
serene face, wearing a red silk saree with gold zari border. She stands
calmly upon or beside a large white Nandi bull. In her right hand she
holds a golden trident (trishul); in her left hand a fully open pink
lotus. A crescent moon ornament on her crown.
```

### दिन २ — ब्रह्मचारिणी
```
The goddess Brahmacharini, the ascetic. Luminous fair complexion, calm
downcast meditative expression, wearing a plain unadorned white saree
with a thin gold border, minimal jewellery. She walks barefoot, no
vahana. In her right hand a rudraksha japa-mala (prayer beads); in her
left hand a small brass kamandalu (water pot). A soft white aura.
```

### दिन ३ — चंद्रघंटा
```
The goddess Chandraghanta, golden-complexioned and radiant, wearing a
golden-yellow silk saree with red border. A clearly visible bell-shaped
crescent moon set on her forehead above the third eye. She is seated
upon a tiger. She has ten arms holding a trident, mace, sword, bow and
arrow, lotus, bell, kamandalu — two hands in abhaya and varada mudra.
Dignified and majestic, calm face, not angry.
```

### दिन ४ — कूष्मांडा
```
The goddess Kushmanda, whose radiance is like the sun. Bright golden
complexion, warm orange-and-gold silk saree. She is seated upon a lion,
with eight arms holding a kamandalu, a bow, an arrow, a lotus, a nectar
pot (amrita kalash), a discus, a mace, and a japa-mala. A brilliant
solar glow surrounds her entire figure.
```

### दिन ५ — स्कंदमाता
```
The goddess Skandamata, the mother of Skanda. Fair complexion, gentle
maternal expression, wearing a red-and-gold saree. She is seated in
padmasana upon a fully open pink lotus. She has four arms: with two she
cradles the infant Kartikeya on her lap, and in the other two she holds
open lotus flowers. A lion stands beside her. Warm, tender, motherly.
```

### दिन ६ — कात्यायनी
```
The goddess Katyayani, the warrior daughter of sage Katyayana. Brilliant
golden complexion, richly ornamented, wearing deep red silk with heavy
gold work. She is seated upon a lion. She has four arms: a long sword
and a lotus in two, the other two raised in abhaya and varada mudra.
Fierce courage but a composed and beautiful face.
```

### दिन ७ — कालरात्रि ⚠️ सबसे सावधानी वाला
```
The goddess Kalaratri. Deep dark-blue complexion, long flowing open
hair, a bright three-eyed gaze, wearing a simple dark garment with a
gold border and a brilliant lightning-like necklace. She rides a grey
donkey. She has four arms: a curved sword and an iron hook in two, the
other two raised in abhaya (fearlessness) and varada (boon) mudra. A
gentle golden glow surrounds her, and her expression is grave and
protective — awe-inspiring, NOT frightening.
NO blood, NO severed heads, NO corpses, NO gore, NO skulls, no horror
imagery of any kind. This must be safe for a child to see.
```

> **⚠️ इस एक चित्र को दो बार जाँचिए।** कालरात्रि का पारंपरिक वर्णन उग्र
> है, और मॉडल बिना कहे डरावनी चीज़ें जोड़ देता है। ऐप में भयानक चित्र
> नहीं जाएगा — घर में बच्चे भी देखते हैं।

### दिन ८ — महागौरी
```
The goddess Mahagauri, radiantly white. Luminous pearl-white complexion,
wearing a pure white silk saree with a fine gold border, white pearl
jewellery. She is seated upon a white bull. She has four arms: a trident
and a small damaru drum in two, the other two in abhaya and varada
mudra. Extremely serene, peaceful, almost glowing white.
```

### दिन ९ — सिद्धिदात्री
```
The goddess Siddhidatri, the giver of perfections. Fair radiant
complexion, wearing a rich red-and-gold silk saree. She is seated upon a
fully open pink lotus, with a lion beside her. She has four arms holding
a mace, a discus, a conch shell, and an open lotus. Crowned and richly
jewelled, with a golden halo. Completely serene and fulfilled.
```

---

## ४ · बाक़ी चार चित्र

### दिन ९ का हवन — `navratri_havan_v1.webp` · 900 × 900
```
A square copper havan kund set on the floor, no human figures. Inside,
neatly stacked mango-wood sticks with clear bright flames rising. Beside
it: a copper spoon (sruva), a small plate of havan samagri (dried herbs
and grains), a brass bowl of ghee, a coconut wrapped in red cloth for
the purnahuti. A few marigold flowers and whole rice grains scattered
around the rim. Warm firelight glow. Behind it a soft golden mandala
halo.
```

### दशमी / जवारे विसर्जन — `vijayadashami_v1.webp` · 900 × 900
```
A ceremonial arrangement for Vijayadashami, no human figures. Centre: a
bunch of tall fresh green barley sprouts (jayanti / jau) tied with red
mauli thread, lifted from a clay pot, with a few sprigs tucked behind
an ear of a marigold garland. Beside it: a small brass plate with
kumkum, akshat and a lit lamp, and a few shami tree leaves. Warm golden
light, celebratory but calm. Behind it a red-and-gold mandala halo.
```

### निर्देश-चित्र १ — जौ बोना · `jau_bona_guide_v1.webp` · **512 × 512**
```
A simple instructional illustration showing how to sow barley for
Navratri, transparent-friendly on a pure white background.
A cross-section view of a wide shallow clay pot: a layer of moist dark
soil at the bottom, barley seeds scattered evenly across it, a second
thin layer of soil on top, and a gentle sprinkle of water falling from
above. Only two human hands are visible — no face, no body — scattering
the seeds. Warm, clean, uncluttered, minimal props.
NO text, NO numbers, NO arrows with letters.

STYLE: clean instructional illustration, soft realistic rendering, warm
gold and earth palette, centred on pure white, generous margins, no
scenery.
```

### निर्देश-चित्र २ — अखंड ज्योति · `akhand_jyoti_guide_v1.webp` · **512 × 512**
```
A simple instructional illustration of an akhand jyoti lamp for
Navratri. A wide, stable brass lamp with a broad base, filled with
golden ghee, holding a single thick hand-rolled cotton wick that stands
upright with a tall steady flame. A small brass ghee pot with a spoon
beside it for refilling. The lamp sits on a brass plate. Everything
clearly separated and easy to read at small size. Only objects — no
human figures.
NO text, NO numbers.

STYLE: clean instructional illustration, soft realistic rendering, warm
gold palette, centred on pure white, generous margins, no scenery.
```

---

## ५ · बनने के बाद — सफ़ेद हटाकर `.webp` बनाना

ChatGPT से **PNG, सबसे बड़ी नाप में** लीजिए। फिर:

```bash
python tools/banao_chitra.py "C:/path/to/downloaded.png" navratri_parv_v1 900
```

यह script अभी **बनी नहीं है** — बनानी होगी। उसे यह करना है:

1. सफ़ेद पृष्ठभूमि हटाकर alpha बनाना (किनारे साफ़ रखते हुए)
2. चौकोर में काटकर 900×900 (या 512×512) करना
3. `.webp` में सहेजना, गुणवत्ता ऐसी कि **180 KB से कम** रहे
4. `app/assets/images/devotional/` में रखना

> **⚠️ APK का आकार।** अभी APK **23.5 MB** है। तेरह नए चित्र × ~130 KB
> ≈ **1.7 MB** और जुड़ेंगे। ठीक है, पर हर चित्र का आकार जाँचकर ही
> डालिए — 240 KB वाली `vat_savitri_v1.webp` जैसी फ़ाइल दोबारा न बने।

---

## ६ · ऐप में जोड़ते समय — दो जगह, और एक पुराना बग

`app/lib/vidhi/devotional_assets.dart` में हर चित्र की एक entry बनेगी:

```dart
static const navratriShailaputri = DevotionalArtwork(
  assetPath: 'assets/images/devotional/navratri_din_1_shailaputri_v1.webp',
  semanticLabel: 'माँ शैलपुत्री का सजावटी चित्र',
);
```

> `semanticLabel` **ज़रूरी है** — वह screen reader पढ़ता है। हिंदी में,
> और हमेशा "…का सजावटी चित्र" की तरह, ताकि यह साफ़ रहे कि यह सजावट है।

> 🔴 **वो बग जो फ़ोन पर पकड़ा गया था (→ D-057):** `Image.asset` को
> `cacheWidth` **और** `cacheHeight` दोनों देने पर Flutter बिंब को ठीक
> उसी नाप पर खींच देता है — अनुपात नहीं बचता, और `BoxFit.contain` उसे
> सुधार नहीं सकता। चेहरे 1.66 गुना चौड़े दिख रहे थे।
> **इसलिए दोनों में से सिर्फ़ एक दीजिए।** `artwork_ratio_test.dart` अब
> यह हर चित्र पर जाँचता है।

---

## ७ · गिनती

| क्या | कितने | नाप |
|---|---:|---|
| पर्व का मुख्य चित्र | 1 | 900 |
| नौ देवियाँ | 9 | 900 |
| हवन | 1 | 900 |
| दशमी / जवारे | 1 | 900 |
| निर्देश-चित्र | 2 | 512 |
| **कुल** | **14** | ~1.8 MB |
