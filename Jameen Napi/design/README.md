# जमीन नापी — logo और icons

## फ़ाइलें

| फ़ाइल | क्या है |
|---|---|
| `badge_logo_source.jpg` | असली badge logo, 1024×1024 JPEG। **सफ़ेद background के साथ** — यही मूल है, इसे मत बदलिए |
| `make_icons.py` | इससे सारे icon बनते हैं (सफ़ेद background हटाकर) |

`assets/icon/` और `play_store_assets/icon-512.png` इसी script से बने हैं —
उन्हें हाथ से मत बदलिए, वरना अगली बार script चलाते ही मिट जाएँगे।

## Icon दोबारा बनाने हों

```bash
python design/make_icons.py     # project की जड़ से चलाइए
dart run flutter_launcher_icons  # Android के mipmap दोबारा बनाएँ
```

बनते क्या हैं:

| फ़ाइल | नाप | कहाँ जाता है |
|---|---|---|
| `assets/icon/icon.png` | 1024², badge 99% | ऐप के अंदर (home व onboarding का logo) |
| `assets/icon/icon_foreground.png` | 1024², badge 66% | Android adaptive icon की foreground layer |
| `play_store_assets/icon-512.png` | 512² | Play Console → Main store listing → App icon |

## सफ़ेद background क्यों और कैसे हटता है

JPEG में transparency होती ही नहीं, इसलिए script:

1. बीच से चारों दिशाओं में किरणें चलाकर सुनहरे छल्ले की असली त्रिज्या नापती है
   (सिर्फ़ bounding box लेने पर JPEG की परछाईं भी आ जाती थी और किनारे पर
   **सफ़ेद छल्ला** दिखता था)
2. उसी दायरे का गोल mask बनाकर बाहर सब कुछ transparent कर देती है
3. किनारे पर हल्का सा feather रखती है ताकि धार कटी-फटी न लगे

## Adaptive icon में 66% ही क्यों

Android launcher adaptive icon के किनारे काट देता है (गोल, चौकोर, squircle —
हर फोन अलग)। इसलिए badge को safe zone में रखना पड़ता है, वरना सुनहरा छल्ला
कट जाता है। पीछे का हरा रंग `pubspec.yaml` में `adaptive_icon_background`
(`#1B5E20`) से आता है।
