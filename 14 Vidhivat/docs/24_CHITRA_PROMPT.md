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

---

## ८ · विश्वकर्मा पूजा (17 सित 2026 · → D-078)

विधि ऐप में जुड़ चुकी है; तब तक कार्ड पर दीया दिखता है।
`app/test/devotional_assets_test.dart` के `chitraBaaki` में इसका नाम लिखा है —
चित्र जोड़ने पर वहाँ से हटाना है, वरना जाँच टूटेगी।

### देव-चित्र — `vishwakarma_v1.webp` · 900 × 900

> ⚠️ **इकोनोग्राफ़ी घर-घर में अलग है।** उत्तर भारत के कैलेंडरों में विश्वकर्मा
> जी वृद्ध, सफ़ेद दाढ़ी वाले, चार भुजाओं वाले और हंस पर बैठे दिखते हैं; बंगाल में
> युवा, मूँछों वाले, हाथी के साथ। नीचे पहला रूप है — अपने इलाक़े का चलन अलग हो
> तो वही बनवाइए।

```
Lord Vishwakarma, the divine architect and craftsman of the gods, seated
calmly on a white swan (hamsa). A dignified elderly sage-like figure with
a full neat white beard, a tall ornate golden crown, and four arms.
Upper right hand holds a long measuring rod; upper left hand holds a
palm-leaf manuscript; lower right hand holds a small hammer; lower left
hand holds a brass water pot (kamandalu). Yellow and saffron silk
dhoti and angavastram with gold borders, rudraksha and gold necklaces.
At his feet, neatly arranged: a carpenter's chisel, a set square, a
spirit level and a small cogwheel — clean and polished, symbolising all
crafts and machines. Gentle, wise, benevolent expression.

STYLE: <ऊपर वाला STYLE BLOCK चिपकाइए>
```

**बनने के बाद:**

```bash
python tools/banao_chitra.py "C:/path/to/downloaded.png" vishwakarma_v1 900
```

फिर `devotional_assets.dart` में `vishwakarma` की entry (`semanticLabel:
'भगवान विश्वकर्मा का सजावटी चित्र'`), `_byVidhiId` में
`'vishwakarma_pooja': vishwakarma`, और `chitraBaaki` से नाम हटाइए।


---

## जोड़ — 11 अक्टूबर 2026: दस चित्र लगे (→ D-120)

`docs/30` §७ और §१० के prompt से बने दस चित्र ऐप में हैं; फ़ाइलों के नाम `_v2` पर हैं
(`granth_ved_sukta_v2`, `granth_upanishad_v2`, `granth_mahabharat_v2`, `granth_ved_puran_v2`,
`granth_sundarkand_v2`, `vrat_pradosh_v2`, `vrat_ekadashi_v2`, `vrat_sankashti_v2`,
`vrat_purnima_v2`, `vrat_janmashtami_v2`)। कहाँ लगे — `01_DECISIONS` D-120।

⚠ `vrat_sankashti_v2` में चाँद पतली कला का बना है, जबकि prompt में लगभग पूरा चाँद माँगा गया
था। दोबारा बनवाएँ तो prompt में यह वाक्य और कस दीजिए: *"a large, almost completely round
waning moon — NOT a crescent"*।


---

## ९ · शरद पूर्णिमा (23 अक्टूबर 2026 · → D-130)

**फ़ाइल:** `vrat_sharad_purnima_v1.webp` · ऐप में **900 × 900**, पारदर्शी · लगेगा: व्रत-पन्ना «शरद पूर्णिमा»,
होम और पूजा-सूची की «आने वाली» पट्टी। आज वहाँ पूर्णिमा वाला चित्र (चाँद + कलश) है।

**ChatGPT से क्या माँगना है:** चौकोर **1024 × 1024 PNG**, **पारदर्शी पृष्ठभूमि** (सबसे बड़ी नाप में डाउनलोड)।
900 × 900 WebP बनाना AI का काम है (`python tools/banao_chitra.py <png> vrat_sharad_purnima_v1 900`)।

⚠️ **इस चित्र में सफ़ेद पृष्ठभूमि ख़तरनाक है** — `banao_chitra.py` लगभग-सफ़ेद हर रंग को पारदर्शी कर देता है, और यहाँ
खीर और चाँद ख़ुद सफ़ेद-से हैं; उनमें छेद हो जाएँगे। इसलिए prompt पारदर्शी माँगता है, और खीर «क्रीम/हाथी-दाँत»,
चाँद «हल्का चाँदी-सुनहरा» रखता है। ChatGPT पारदर्शी न दे तो दूसरी बार यह जोड़कर माँगें: *"Use a flat solid pure
green (#00FF00) background instead"* — हरा AI हटा देगा।

**पूर्णिमा वाले चित्र से अलग क्यों दिखे:** उसमें कलश और नारियल है — यहाँ **कलश, नारियल नहीं**; बीच में खीर का कटोरा।

```
A devotional still-life illustration for the Hindu festival of Sharad Purnima
(Kojagari Purnima), as a clean cut-out object group on a TRANSPARENT
background (PNG with alpha channel). Square 1:1 canvas, 1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- BACK, upper centre: a large luminous full moon disc, pale silver-gold
  (not pure white), with soft visible lunar craters and a gentle cool glow.
  Around the moon an ornate golden mandala / sun-ray halo ring with fine
  filigree petals, like a temple aureole.
- FRONT, centre (the hero object): a wide, shallow, polished brass urli bowl
  filled to the brim with creamy ivory rice kheer (warm cream colour, not
  pure white), garnished with saffron strands, slivered almonds, green
  pistachio flakes and a few green cardamom pods. A soft silvery moonlight
  sheen glows on the surface of the kheer. A thin, translucent cream muslin
  cloth is draped over one side of the bowl rim, half covering it, so the
  kheer is still clearly visible.
- Around the bowl, in a low symmetrical arc: three to five small lit brass
  diyas with calm, steady golden flames; two or three fresh pink lotus
  flowers in full bloom and one lotus bud; a small brass plate with a neat
  heap of unbroken rice grains (akshat); a few orange marigolds and fresh
  green leaves forming a base under the arrangement.

LIGHTING AND MOOD: calm, sacred night feeling. Cool silvery-blue moonlight
falling from above, balanced by the warm golden glow of the diyas. Soft
golden rim light on the brass. Peaceful, auspicious, abundant.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Rich warm palette of
gold, saffron, marigold orange and lotus pink, with moonlit silver accents.
Ultra detailed, crisp clean edges suitable for cut-out, consistent with a
set of festival icons.

STRICTLY AVOID: any background scene, sky, stars, clouds, rooftop, courtyard,
floor, table, wall, or shadow cast onto a surface; any human or deity figure,
hands or faces; kalash or coconut; any text, letters, numbers, watermark,
signature or border frame; anything scary.
```

**बनने के बाद देखें:** (१) पीछे सचमुच पारदर्शी है (चेकर-बोर्ड दिखे) — सफ़ेद या धूसर नहीं; (२) कहीं कोई अक्षर
या चिह्न नहीं; (३) चाँद, खीर और दीयों के किनारे साफ़ हैं, कोई चीज़ किनारे से कटी नहीं; (४) PNG सबसे बड़ी नाप में
उतारें और फ़ाइल का नाम बताकर भेजें।

---

## १० · तुलसी विवाह और कार्तिक पूर्णिमा (25 अक्टूबर 2026 · → D-140)

दोनों व्रत-पन्ने ऐप में हैं; आज तुलसी विवाह पर साधारण तुलसी वाला चित्र और कार्तिक पूर्णिमा पर दीया लगा है
(`app/lib/vidhi/vrat_artwork.dart`)। नाप-नियम §९ वाले: ChatGPT से **1024 × 1024 PNG, पारदर्शी**, सबसे बड़ी नाप में;
900 × 900 WebP AI बनाएगा (`python tools/banao_chitra.py <png> <नाम> 900`), फिर `vrat_artwork.dart` में दो entry।

चित्र सजावट है, विधि नहीं — इसलिए इसमें कोई मंत्र, अक्षर या «ऐसे ही करना है» वाली चीज़ नहीं। पारदर्शी न मिले तो
दूसरी बार जोड़ें: *"Use a flat solid pure green (#00FF00) background instead"*।

### तुलसी विवाह — `vrat_tulsi_vivah_v1.webp` · 900 × 900

तुलसी वाले पुराने चित्र (`tulsi_realistic_v1`) से अलग दिखे: यहाँ **विवाह** है — चुनरी, मंडप, शालिग्राम।

```
A devotional still-life illustration for the Hindu festival of Tulsi Vivah,
as a clean cut-out object group on a TRANSPARENT background (PNG with alpha
channel). Square 1:1 canvas, 1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- CENTRE (the hero): a healthy, bushy holy basil (tulsi) plant growing in a
  traditional square terracotta tulsi planter (tulsi vrindavan) painted
  cream and ochre with simple red and yellow border bands. The plant is
  dressed as a bride: a small sheer red chunri with a gold border draped
  over its top, a tiny gold-and-red bead necklace, and a few red glass
  bangles hung on a twig.
- Over the planter: a small wedding canopy (mandap) made of four tall green
  sugarcane stalks standing at the corners, their leafy tops tied together
  above with red mauli thread and a marigold garland.
- To the right of the planter, on a small polished brass plate: a smooth
  round black shaligram stone with a tiny marigold garland and a small
  yellow cloth beside it.
- In front, in a low symmetrical arc: three to five small lit clay diyas
  with calm golden flames, a small heap of rice grains (akshat), a brass
  bowl of red kumkum, loose orange marigolds and rose petals.
- Behind everything: a soft golden mandala / sun-ray halo ring with fine
  filigree petals, like a temple aureole.

LIGHTING AND MOOD: warm evening glow, festive and auspicious, gentle golden
rim light on the brass and leaves. Peaceful and sacred, like a wedding at
home.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Rich warm palette of
gold, saffron, marigold orange, bridal red and fresh tulsi green. Ultra
detailed, crisp clean edges suitable for cut-out, consistent with a set of
festival icons.

STRICTLY AVOID: any background scene, sky, courtyard, floor, table, wall, or
shadow cast onto a surface; any human or deity figure, hands or faces;
kalash or coconut; any text, letters, numbers, watermark, signature or
border frame; anything scary.
```

### कार्तिक पूर्णिमा / देव दीपावली — `vrat_kartik_purnima_v1.webp` · 900 × 900

पूर्णिमा (चाँद + कलश) और शरद पूर्णिमा (चाँद + खीर) से अलग दिखे: यहाँ **दीपदान** मुख्य है — बहुत से दीये, और पानी
पर तैरता दीया।

```
A devotional still-life illustration for the Hindu festival of Kartik
Purnima and Dev Deepawali (the festival of lamp offerings), as a clean
cut-out object group on a TRANSPARENT background (PNG with alpha channel).
Square 1:1 canvas, 1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- CENTRE (the hero): a wide, shallow, polished brass urli bowl filled with
  clear water. Floating on the water: two or three small lamp-boats made of
  green leaves (dona), each holding a lit clay diya with a steady golden
  flame, plus a few floating orange marigold heads and rose petals.
  Gentle golden reflections of the flames on the water surface.
- Around and behind the bowl: about eleven small terracotta clay diyas
  arranged in a neat rising pyramid / tiered arc, every one lit with a
  calm, steady golden flame — the lamps are the main subject.
- In front: a small sprig of fresh tulsi leaves on a brass plate, a small
  heap of rice grains (akshat), a few marigolds.
- BACK, upper centre, smaller than the lamps: a pale silver-gold full moon
  disc (not pure white) with a soft glow, inside a delicate golden
  mandala / sun-ray halo ring.

LIGHTING AND MOOD: sacred festive night, countless warm flames, a cool
silver moon glow from above balanced by the golden light of the lamps.
Peaceful, luminous, auspicious.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Rich warm palette of
gold, saffron, marigold orange and terracotta, with moonlit silver accents.
Ultra detailed, crisp clean edges suitable for cut-out, consistent with a
set of festival icons.

STRICTLY AVOID: any background scene, river bank, ghat steps, temple,
buildings, sky, stars, clouds, floor, table, wall, or shadow cast onto a
surface; any human or deity figure, hands or faces; kalash or coconut;
fireworks; any text, letters, numbers, watermark, signature or border frame;
anything scary.
```

**बनने के बाद देखें:** (१) पीछे सचमुच पारदर्शी है (चेकर-बोर्ड दिखे); (२) कहीं कोई अक्षर या चिह्न नहीं; (३) दीयों
की लौ और पत्तों के किनारे साफ़, कोई चीज़ किनारे से कटी नहीं; (४) PNG Downloads में रखकर फ़ाइल का नाम बताइए।

## ११ · नरक चतुर्दशी, गोपाष्टमी, आँवला नवमी (26 अक्टूबर 2026 · → D-154)

तीनों व्रत-पन्ने ऐप में हैं; आज तीनों पर साधारण दीया लगा है (`VratArtwork.forVratId` का fallback)। नाप-नियम §९
वाले: ChatGPT से **1024 × 1024 PNG, पारदर्शी**; 900 × 900 WebP AI बनाएगा (`python -P tools/banao_chitra.py <png>
<नाम> 900`), फिर `app/lib/vidhi/vrat_artwork.dart` में तीन entry। पारदर्शी न मिले तो दूसरी बार जोड़ें:
*"Use a flat solid pure green (#00FF00) background instead"*। चित्र सजावट है — कोई अक्षर, मंत्र, देव-आकृति नहीं।

### नरक चतुर्दशी — `vrat_narak_chaturdashi_v1.webp` · 900 × 900

कार्तिक पूर्णिमा (बहुत से दीये + पानी) से अलग दिखे: यहाँ **भोर** और **चार बत्तियों वाला एक दीपक** मुख्य है।

```
A devotional still-life illustration for the Hindu festival of Narak
Chaturdashi (Roop Chaudas, the dawn before Diwali), as a clean cut-out object
group on a TRANSPARENT background (PNG with alpha channel). Square 1:1 canvas,
1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- CENTRE (the hero): one large terracotta clay lamp with FOUR wicks pointing
  in four directions, all four lit with calm steady golden flames, standing
  on a small polished brass plate.
- Left: a small brass bowl of golden sesame oil and a small brass bowl of
  yellow-orange ubtan paste (turmeric and gram flour), with a few white and
  black sesame seeds scattered in front.
- Right: a small bunch of apamarg (prickly chaff-flower) twigs with their
  long thin spikes, and a small dried bottle-gourd (tumbi), placed neatly.
- Front, in a low arc: a few small lit clay diyas, loose orange marigolds.
- BACK, upper centre, small and soft: a thin pale crescent moon low on a
  hint of deep-blue pre-dawn glow, inside a soft golden mandala halo ring.

LIGHTING AND MOOD: early dawn before sunrise, deep blue fading to warm gold
around the lamp, quiet and purifying.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Palette of deep
indigo, warm gold, saffron and terracotta. Ultra detailed, crisp clean edges
suitable for cut-out, consistent with a set of festival icons.

STRICTLY AVOID: any background scene, sky landscape, floor, table, wall, or
shadow cast onto a surface; any human or deity figure, demon, Yama or
skeleton, hands or faces; firecrackers or explosions; any text, letters,
numbers, watermark, signature or border frame; anything scary.
```

### गोपाष्टमी — `vrat_gopashtami_v1.webp` · 900 × 900

गोवर्धन वाले चित्र (पर्वत, अन्नकूट) से अलग दिखे: यहाँ **सजी हुई गाय और बछड़ा** ही मुख्य हैं।

```
A devotional illustration for the Hindu festival of Gopashtami (worship of
cows), as a clean cut-out group on a TRANSPARENT background (PNG with alpha
channel). Square 1:1 canvas, 1024 x 1024 pixels.

COMPOSITION (centred, everything inside the central 85% of the canvas with
clear empty margin on all four sides; nothing touches or is cut by the
edges):
- CENTRE (the hero): a gentle white Indian cow (Gir or Tharparkar look)
  standing calmly, three-quarter view, decorated for worship: a marigold
  garland around the neck, a red-and-gold embroidered cloth on her back,
  small brass bells, a dot of red kumkum and turmeric on the forehead, horns
  lightly painted with soft ochre bands.
- Beside her, close to her side: a small light-brown calf with a tiny
  marigold garland, looking up at the mother.
- Front, in a low arc: a small brass plate with a lit clay diya, a heap of
  fresh green fodder, a small piece of jaggery and two plain rotis, loose
  marigolds.
- Behind: a soft golden mandala / sun-ray halo ring.

LIGHTING AND MOOD: soft warm morning light, peaceful, tender and auspicious.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Palette of white,
cream, marigold orange, red and fresh green. Ultra detailed, crisp clean
edges suitable for cut-out, consistent with a set of festival icons.

STRICTLY AVOID: any background scene, field, cowshed, ground or shadow cast
onto a surface; any human or deity figure, cowherd, hands or faces; ropes
tying the cow, injury or thinness; any text, letters, numbers, watermark,
signature or border frame.
```

### आँवला नवमी — `vrat_akshaya_navami_v1.webp` · 900 × 900

```
A devotional still-life illustration for the Hindu festival of Amla Navami
(Akshaya Navami, worship of the Indian gooseberry tree), as a clean cut-out
object group on a TRANSPARENT background (PNG with alpha channel). Square 1:1
canvas, 1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- CENTRE (the hero): a short young amla (Indian gooseberry) tree trunk with
  a lush rounded canopy of fine feathery leaves and clusters of round pale
  green amla fruits; several rounds of raw white cotton thread (kachcha
  soot) wound neatly around the trunk, with a red mauli knot, and a small
  dot of kumkum on the bark.
- At the foot of the trunk: a small brass lota pouring a thin stream of
  milk onto the roots, collecting in a small clay basin around the trunk.
- Front, in a low arc: a lit clay diya, a small brass plate with a few amla
  fruits, rice grains and marigolds, and a small ripe yellow pumpkin
  (kushmanda) with a red thread tied on it.
- Behind: a soft golden mandala / sun-ray halo ring.

LIGHTING AND MOOD: clear warm morning light, fresh, calm and auspicious.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Palette of fresh
green, pale lime, white, gold and marigold orange. Ultra detailed, crisp
clean edges suitable for cut-out, consistent with a set of festival icons.

STRICTLY AVOID: any background scene, ground, garden, soil landscape or
shadow cast onto a surface; any human or deity figure, hands or faces; any
text, letters, numbers, watermark, signature or border frame.
```

## १२ · होलिका दहन और अक्षय तृतीया (26 अक्टूबर 2026 · → D-155)

नाप-नियम §९–§११ वाले (1024 × 1024 PNG पारदर्शी → `python -P tools/banao_chitra.py <png> <नाम> 900` →
`vrat_artwork.dart`)। दोनों पन्नों पर आज दीया है।

### होलिका दहन — `vrat_holika_dahan_v1.webp` · 900 × 900

```
A devotional still-life illustration for the Hindu festival of Holika Dahan
(the bonfire on the night before Holi), as a clean cut-out object group on a
TRANSPARENT background (PNG with alpha channel). Square 1:1 canvas,
1024 x 1024 pixels.

COMPOSITION (centred, everything inside the central 85% of the canvas with
clear empty margin on all four sides; nothing touches or is cut by the
edges):
- CENTRE (the hero): a neat conical stack of dry wood logs and round cow-dung
  cakes (upla) with a tall straight wooden pole standing in the middle,
  wrapped with raw white cotton thread; warm controlled golden-orange flames
  rising from the base of the stack, with soft glowing sparks.
- Front-left: a few green stalks of wheat and barley with ripe ears, and a
  small bunch of green chickpea plants, ready to be roasted.
- Front-right: a small brass plate with a lit clay diya, a heap of rice
  grains, a small bowl of red kumkum, a few marigolds and a coconut.
- Behind: a soft golden mandala / sun-ray halo ring, subtle.

LIGHTING AND MOOD: night, warm firelight glow, joyful and auspicious, safe
and controlled — not a wildfire.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Palette of warm
orange, gold, ember red, wheat yellow and fresh green. Ultra detailed, crisp
clean edges suitable for cut-out, consistent with a set of festival icons.

STRICTLY AVOID: any human, demon or deity figure (no Holika, no Prahlad), no
hands or faces, no burning person, no smoke clouds covering the scene, no
background scene, ground or sky; no colours/gulal; any text, letters,
numbers, watermark, signature or border frame; anything scary.
```

### अक्षय तृतीया — `vrat_akshaya_tritiya_v1.webp` · 900 × 900

```
A devotional still-life illustration for the Hindu festival of Akshaya
Tritiya (the day of imperishable charity in early summer), as a clean
cut-out object group on a TRANSPARENT background (PNG with alpha channel).
Square 1:1 canvas, 1024 x 1024 pixels.

COMPOSITION (centred, symmetrical, everything inside the central 85% of the
canvas with clear empty margin on all four sides; nothing touches or is cut
by the edges):
- CENTRE (the hero): a round earthen water pot (matka / dharmaghat) filled
  with water, a few rounds of raw white cotton thread wound around its neck,
  a small red-and-gold cloth tied on it, mango leaves and a small coconut on
  its mouth; tiny drops of condensation on the clay.
- Around it on brass plates, in a low arc: a heap of golden barley grains, a
  small bowl of sattu (roasted gram flour), two fresh tender cucumbers, a
  bowl of soaked yellow chana dal, a small bowl of curd-rice, and a stalk of
  sugarcane.
- Front centre: a lit clay diya and a few sandalwood-paste (chandan) tilak
  marks on a small brass plate, with fresh jasmine flowers.
- Behind: a soft golden mandala / sun-ray halo ring.

LIGHTING AND MOOD: bright, fresh early-summer morning light; pure, generous
and auspicious.

STYLE: Devotional Indian religious illustration, photorealistic 3D render
blended with classical Indian calendar-art sensibility. Palette of earthen
terracotta, gold, cream, fresh green and sandalwood. Ultra detailed, crisp
clean edges suitable for cut-out, consistent with a set of festival icons.

STRICTLY AVOID: gold jewellery, coins or shopping imagery; any human or
deity figure, hands or faces; any background scene, ground or shadow cast
onto a surface; any text, letters, numbers, watermark, signature or border
frame.
```
