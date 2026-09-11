# -*- coding: utf-8 -*-
"""फ़ोन पर दिखने वाला ऐप icon — Play वाले logo से ही बनाओ।

⚠️ **यह फ़ाइल एक Play rejection से आई है** (11 सित 2026)। ऐप का
launcher icon अब भी Flutter का डिफ़ॉल्ट "F" था, जबकि store listing
में दीपक वाला logo था। Google ने इसे *Misleading Claims — App store
listing mismatch* कहकर ऐप लौटा दिया।

इसलिए अब दोनों एक ही तस्वीर से बनते हैं:

    app/play_store_assets/selected/vidhivat_diya_logo_512.png

logo बदले तो यह script दोबारा चलाइए — वरना फिर वही rejection आएगा:

    python tools/banao_launcher_icon.py

क्या बनता है
------------
1. **adaptive icon** (Android 8+, और आज के सारे फ़ोन) — पीछे logo का
   ही गहरा नीला रंग, आगे दीपक। Android icon को गोल/squircle में
   काटता है और सिर्फ़ बीच का 66dp हिस्सा पक्का दिखता है — इसलिए
   दीपक को उस घेरे के अंदर छोटा करके रखा जाता है, वरना उसके हत्थे
   कट जाते।
2. **पुराना चौकोर icon** (Android 7 और उससे पहले) — पूरा logo।
"""
import os
from PIL import Image, ImageDraw, ImageFilter

YAHAN = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOGO = os.path.join(YAHAN, 'app', 'play_store_assets', 'selected',
                    'vidhivat_diya_logo_512.png')
RES = os.path.join(YAHAN, 'app', 'android', 'app', 'src', 'main', 'res')

# logo के कोनों से लिया गया रंग — adaptive icon की पृष्ठभूमि यही है।
PEECHHE = (4, 9, 22)

GHANATVA = {  # नाम: (पुराना 48dp, adaptive 108dp)
    'mdpi': (48, 108),
    'hdpi': (72, 162),
    'xhdpi': (96, 216),
    'xxhdpi': (144, 324),
    'xxxhdpi': (192, 432),
}

# 108dp के कैनवस पर logo कितना बड़ा रखें। 80% पर दीपक का आधा-चौड़ाई
# ≈ 28dp बैठता है — 33dp वाले सुरक्षित घेरे के अंदर, थोड़ी जगह छोड़कर।
LOGO_KA_HISSA = 0.80


def narm_kinare(size):
    """logo के किनारों को पृष्ठभूमि में घोल दो, ताकि चौकोर सीवन न दिखे।"""
    mask = Image.new('L', (size, size), 0)
    d = ImageDraw.Draw(mask)
    pad = int(size * 0.06)
    d.ellipse([pad, pad, size - pad, size - pad], fill=255)
    return mask.filter(ImageFilter.GaussianBlur(size * 0.06))


def adaptive_foreground(logo, px):
    canvas = Image.new('RGBA', (px, px), PEECHHE + (0,))
    andar = int(px * LOGO_KA_HISSA)
    chhota = logo.resize((andar, andar), Image.LANCZOS).convert('RGBA')
    chhota.putalpha(narm_kinare(andar))
    o = (px - andar) // 2
    canvas.alpha_composite(chhota, (o, o))
    return canvas


def main():
    logo = Image.open(LOGO).convert('RGB')
    for naam, (purana, adaptive) in GHANATVA.items():
        d = os.path.join(RES, 'mipmap-' + naam)
        os.makedirs(d, exist_ok=True)
        logo.resize((purana, purana), Image.LANCZOS).save(
            os.path.join(d, 'ic_launcher.png'))
        adaptive_foreground(logo, adaptive).save(
            os.path.join(d, 'ic_launcher_foreground.png'))

    v26 = os.path.join(RES, 'mipmap-anydpi-v26')
    os.makedirs(v26, exist_ok=True)
    with open(os.path.join(v26, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<!-- tools/banao_launcher_icon.py से बनता है — हाथ से मत बदलिए -->\n'
                '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
                '    <background android:drawable="@color/ic_launcher_background"/>\n'
                '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
                '</adaptive-icon>\n')

    with open(os.path.join(RES, 'values', 'ic_launcher_background.xml'),
              'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<resources>\n'
                '    <!-- logo के कोनों का रंग — tools/banao_launcher_icon.py -->\n'
                '    <color name="ic_launcher_background">#%02X%02X%02X</color>\n'
                '</resources>\n' % PEECHHE)

    print('बने: पाँचों घनत्व के icon + adaptive icon')


if __name__ == '__main__':
    main()
