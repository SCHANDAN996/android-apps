# 🎨 Feature Graphic — AI इमेज prompt (सुधरा हुआ)

## ⚠️ सबसे बड़ी बात पहले

आपके पुराने prompt में **यह नहीं लिखा था कि "तस्वीर में कोई अक्षर मत लिखना"** —
और यही 90% banner ख़राब करता है।

AI इमेज बनाने वाले औज़ार अक्षर **हमेशा टूटे-फूटे** बनाते हैं — "Pro Kisan" की जगह
"Pra Kisqn", और देवनागरी तो पूरी बेढंगी। Play Store पर वह सस्ता दिखता है।

**सही तरीक़ा:** AI से सिर्फ़ **चित्र** बनवाओ (बिना किसी अक्षर के), और नाम/लेख
बाद में साफ़ font से ऊपर चढ़ाओ। लेख चढ़ाने का काम मैं कोड से कर दूँगा — बिल्कुल
साफ़, सही जगह, दसों भाषाओं में।

---

## ✅ सुधरा हुआ prompt (यही copy करें)

```text
A wide landscape banner illustration, exactly 1024x500 pixels (2.05:1 aspect ratio),
for an Indian agriculture mobile app.

COMPOSITION (very important):
- LEFT 45% of the frame: mostly EMPTY, calm background — just the green field and
  warm sky, no important objects. This space is reserved for text that will be
  added later.
- RIGHT 55%: a happy Indian farmer (age 35-45, simple kurta and turban, warm
  genuine smile) standing at the edge of a lush green crop field, holding a
  modern smartphone in one hand. Behind him: 2-3 healthy cows near a clean small
  dairy shed, and a few wheat stalks in the foreground corner.

LIGHTING & MOOD: warm golden-hour sunrise from the right, soft long shadows,
optimistic and prosperous feeling.

COLOR PALETTE (match these exactly):
- Deep farm green #24802F as the dominant background tone
- Fresh leaf green #4CAF50 for crops
- Golden wheat / sun #FABE2E
- Soft sky blue #7EC8E3 only in the upper sky
- Warm cream #EAF6E4 for highlights

STYLE: clean modern corporate vector illustration, flat design with soft subtle
gradients, smooth shapes, minimal fine detail, high clarity even when the image
is viewed small. Similar to premium fintech / agritech app banners.

STRICT RULES — DO NOT INCLUDE:
- NO text, NO letters, NO words, NO numbers, NO logos, NO watermarks anywhere
  in the image (text will be added separately)
- NO detailed UI on the phone screen — keep the screen a simple soft green glow
- NO photorealism, NO 3D render look, NO clutter
- NO distorted hands, NO extra fingers, NO malformed faces
- NO borders or frames around the image
```

---

## 🖼️ बनने के बाद क्या करना है

1. बनी हुई तस्वीर इसी folder में `banner_ai_raw.png` नाम से रख दीजिए
2. मुझसे कहिए — मैं उस पर **साफ़ font में** नाम, tagline और logo चढ़ाकर
   ठीक 1024×500 का `feature_graphic.png` बना दूँगा
3. चाहें तो उसमें ऐप की असली स्क्रीन वाला फ़ोन भी जोड़ सकता हूँ

---

## 🔁 और भी बेहतर करने की तरकीबें

- **तीन बार बनवाइए**, फिर सबसे अच्छी चुनिए — AI हर बार अलग बनाता है
- चेहरा बिगड़ जाए तो prompt में जोड़िए: *"farmer seen from the side, face
  turned slightly away"* — बगल से चेहरा कम बिगड़ता है
- गायें अजीब लगें तो: *"cows shown as simple flat silhouettes in the far
  background"*
- Gemini/ChatGPT में बनवाएँ तो अंत में यह भी लिखिए:
  *"Output must be a single wide banner image, 1024x500 pixels, no text."*

---

## 📱 दूसरा रास्ता (बिना AI के — अभी तैयार है)

`feature_graphic.png` का एक नमूना कोड से बना है जिसमें दाईं ओर फ़ोन है और उसमें
**ऐप की असली दूध-dashboard** दिख रही है (वही teal header, सुबह/शाम की पट्टियाँ,
महीने के खाने, हरा एंट्री बटन, ग्राहकों की सूची)।

फ़ायदा: जो banner में दिखता है, ऐप खोलने पर हूबहू वही मिलता है — Play Store पर
इसी को "ईमानदार banner" माना जाता है और install-दर बेहतर रहती है।
