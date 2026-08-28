"""Screenshot में से नीचे वाली back/home पट्टी काटकर ठीक 1080x1920 बनाओ.

फोन को `wm size 1080x2036` पर रखकर तस्वीर ली जाती है — नीचे की 116px की
navigation पट्टी काटने पर ऊपर ठीक 1080x1920 ऐप का हिस्सा बचता है, जो Play के
फ़ोन screenshots का 9:16 अनुपात है.

चलाइए:  python design/crop_navbar.py play_store_assets/screenshots
"""

import os
import sys

from PIL import Image

TARGET = (1080, 1920)


def nav_height(img: Image.Image) -> int:
    """नीचे की गहरी पट्टी कितनी ऊँची है, यह नापो."""
    px = img.load()
    w, h = img.size
    y = h - 1
    while y > 0 and sum(px[60, y]) / 3 < 70:
        y -= 1
    return h - (y + 1)


def main() -> None:
    folder = sys.argv[1] if len(sys.argv) > 1 else 'play_store_assets/screenshots'
    names = sorted(
        n for n in os.listdir(folder)
        if n.lower().endswith('.png') and os.path.isfile(os.path.join(folder, n))
    )
    if not names:
        print(f'{folder} में कोई png नहीं')
        raise SystemExit(2)

    for name in names:
        path = os.path.join(folder, name)
        img = Image.open(path).convert('RGB')

        if img.size == TARGET:
            print(f'{name:<26} पहले से सही')
            continue

        nav = nav_height(img)
        cropped = img.crop((0, 0, img.width, img.height - nav))

        if cropped.size != TARGET:
            print(f'{name:<26} ⚠ {cropped.size[0]}x{cropped.size[1]} '
                  f'(नाप {TARGET[0]}x{TARGET[1]} होनी चाहिए थी)')
            continue

        cropped.save(path, 'PNG', optimize=True)
        print(f'{name:<26} → {cropped.size[0]}x{cropped.size[1]}  '
              f'(पट्टी {nav}px कटी)')


if __name__ == '__main__':
    main()
