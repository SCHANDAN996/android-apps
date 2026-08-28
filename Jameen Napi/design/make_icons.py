"""Badge logo se saare icon banao — safed background hataakar.

Logo ek 1024x1024 JPEG hai jisme gol sunehra badge safed background par hai.
JPEG me transparency hoti hi nahi, isliye:
  1. badge ka gol daayra dhoondo (safed kinaron ko chhod kar)
  2. us daayre ke bahar sab kuch transparent kar do
  3. kinare par halka anti-alias rakho taki dhaar kat-i hui na lage
"""

import io
import os
from PIL import Image, ImageDraw, ImageFilter

SRC = 'logo'
OUT_ICON = 'assets/icon/icon.png'
OUT_FG = 'assets/icon/icon_foreground.png'
OUT_PLAY = 'play_store_assets/icon-512.png'

WHITE_CUTOFF = 238  # isse upar sab kuch "safed background" mana jayega


def find_badge_box(img):
    """Safed background chhod kar badge ka bounding box nikalo."""
    rgb = img.convert('RGB')
    w, h = rgb.size
    px = rgb.load()

    def is_white(x, y):
        r, g, b = px[x, y]
        return r >= WHITE_CUTOFF and g >= WHITE_CUTOFF and b >= WHITE_CUTOFF

    left, right, top, bottom = w, 0, h, 0
    step = 2
    for y in range(0, h, step):
        for x in range(0, w, step):
            if not is_white(x, y):
                if x < left:
                    left = x
                if x > right:
                    right = x
                if y < top:
                    top = y
                if y > bottom:
                    bottom = y
    return left, top, right, bottom


def circular_cutout(img, box, feather=1.5):
    """Badge ko gol kaat kar transparent background wala PNG banao."""
    left, top, right, bottom = box
    cx = (left + right) / 2.0
    cy = (top + bottom) / 2.0
    # Badge gol hai — dono taraf ka bada naap lo taki kuch kat na jaye
    radius = max(right - left, bottom - top) / 2.0

    # thoda sa bahar tak lo, kyunki drop-shadow bhi badge ka hissa hai
    radius *= 1.005

    size = int(round(radius * 2))
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    if feather:
        mask = mask.filter(ImageFilter.GaussianBlur(feather))

    crop_box = (
        int(round(cx - radius)),
        int(round(cy - radius)),
        int(round(cx - radius)) + size,
        int(round(cy - radius)) + size,
    )
    badge = img.convert('RGBA').crop(crop_box)
    out = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    out.paste(badge, (0, 0), mask)
    return out


def save_square(badge, path, canvas, scale, background=None):
    """Badge ko `canvas` px ke chaukor me `scale` hisse par baithao."""
    target = int(canvas * scale)
    resized = badge.resize((target, target), Image.LANCZOS)
    if background is None:
        out = Image.new('RGBA', (canvas, canvas), (0, 0, 0, 0))
    else:
        out = Image.new('RGBA', (canvas, canvas), background)
    off = (canvas - target) // 2
    out.paste(resized, (off, off), resized)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out.save(path, 'PNG')
    return out


def main():
    img = Image.open(SRC)
    print(f'source: {img.size[0]}x{img.size[1]} {img.mode}')

    box = find_badge_box(img)
    print(f'badge box: {box}')

    badge = circular_cutout(img, box)
    print(f'badge cutout: {badge.size[0]}x{badge.size[1]} (transparent background)')

    # 1. App icon — badge poora chaukor bharta hai (thodi si hawa ke saath)
    save_square(badge, OUT_ICON, 1024, 0.98)

    # 2. Adaptive icon ka foreground — Android kinare kaat deta hai, isliye
    #    badge ko safe zone (~66%) me rakhna zaroori hai
    save_square(badge, OUT_FG, 1024, 0.66)

    # 3. Play Store ka 512x512
    save_square(badge, OUT_PLAY, 512, 0.98)

    for p in (OUT_ICON, OUT_FG, OUT_PLAY):
        im = Image.open(p)
        alpha = im.getchannel('A')
        clear = sum(1 for v in alpha.getdata() if v == 0)
        total = im.size[0] * im.size[1]
        print(f'{p}: {im.size[0]}x{im.size[1]} — {clear * 100 // total}% transparent')


if __name__ == '__main__':
    main()
