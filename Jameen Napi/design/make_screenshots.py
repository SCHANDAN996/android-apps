"""फोन से लिए screenshots को Play Store के लायक बनाओ.

फोन 720x1600 का है — यानी 9:20. Play फ़ोन के screenshots में ज़्यादा से ज़्यादा
2:1 का अनुपात लेता है, इसलिए सीधा वही तस्वीर चढ़ाने पर Play मना कर सकता है या
अपने-आप काट देता है.

यहाँ हम काटते नहीं — तस्वीर को 1080x1920 (ठीक 9:16) के कैनवास पर बीच में
बैठा देते हैं और दोनों तरफ़ ऐप के अपने हरे रंग की पट्टी लगा देते हैं. इससे कोई
हिस्सा कटता नहीं और अनुपात भी सही हो जाता है.

चलाने का तरीक़ा (project की जड़ से):
    python design/make_screenshots.py <कहाँ से> <कहाँ>
"""

import os
import sys

from PIL import Image

# Play के लिए मानक फ़ोन screenshot
CANVAS = (1080, 1920)

# ऐप के header वाला हरा — पट्टी उसी रंग की, ताकि अलग न लगे
BAND = (27, 94, 32)


def fit(path: str, out_path: str) -> None:
    img = Image.open(path).convert('RGB')

    # ऊँचाई पूरी भरो, चौड़ाई उसी अनुपात में
    scale = CANVAS[1] / img.height
    new_w = int(round(img.width * scale))
    resized = img.resize((new_w, CANVAS[1]), Image.LANCZOS)

    if new_w > CANVAS[0]:
        # बहुत चौड़ी हो तो चौड़ाई से मिलाओ और ऊपर-नीचे पट्टी
        scale = CANVAS[0] / img.width
        new_h = int(round(img.height * scale))
        resized = img.resize((CANVAS[0], new_h), Image.LANCZOS)

    canvas = Image.new('RGB', CANVAS, BAND)
    canvas.paste(
        resized,
        ((CANVAS[0] - resized.width) // 2, (CANVAS[1] - resized.height) // 2),
    )
    canvas.save(out_path, 'PNG', optimize=True)


def main() -> None:
    src_dir = sys.argv[1] if len(sys.argv) > 1 else 'play_store_assets/screenshots/raw'
    out_dir = sys.argv[2] if len(sys.argv) > 2 else 'play_store_assets/screenshots'

    if not os.path.isdir(src_dir):
        print(f'{src_dir} नहीं मिला')
        raise SystemExit(2)

    os.makedirs(out_dir, exist_ok=True)
    names = sorted(n for n in os.listdir(src_dir) if n.lower().endswith('.png'))
    if not names:
        print(f'{src_dir} में कोई png नहीं है')
        raise SystemExit(2)

    for name in names:
        src = os.path.join(src_dir, name)
        out = os.path.join(out_dir, name)
        fit(src, out)
        w, h = Image.open(out).size
        print(f'{name:<28} → {w}x{h}')

    print(f'\n{len(names)} screenshots तैयार — {out_dir}')


if __name__ == '__main__':
    main()
