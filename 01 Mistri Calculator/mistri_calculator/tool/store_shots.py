"""Turns the phone screenshots into Play Store pictures (1080 x 1920, 9:16).

Inputs, both under build/:
  screenshots/<name>.png   from the on-device test (flutter drive ...)
  store/caption_<name>.png from `flutter test tool/store_captions_test.dart`

Output: ../play_store_assets/screenshots/<name>.png

Run from the mistri_calculator folder:  python tool/store_shots.py
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFilter

W, H = 1080, 1920
CAPTION_H = 300
TOP_CROP = 70  # the empty strip behind the phone's status bar
SHOT_H = H - CAPTION_H - 50  # the screenshot runs off the bottom edge a little
RADIUS = 44
ORANGE_TOP, ORANGE_BOTTOM = (230, 81, 0), (255, 143, 0)  # the app's brand colours

OUT = os.path.join('..', 'play_store_assets', 'screenshots')
os.makedirs(OUT, exist_ok=True)


def gradient():
    img = Image.new('RGB', (W, H))
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        draw.line(
            [(0, y), (W, y)],
            fill=tuple(round(a + (b - a) * t) for a, b in zip(ORANGE_TOP, ORANGE_BOTTOM)),
        )
    return img


def rounded_top(size, radius):
    """Mask: rounded top corners, square bottom (it runs off the canvas)."""
    mask = Image.new('L', size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, size[0] - 1, size[1] + radius], radius, fill=255)
    return mask


for path in sorted(glob.glob('build/screenshots/*.png')):
    name = os.path.splitext(os.path.basename(path))[0]
    caption = f'build/store/caption_{name}.png'
    if not os.path.exists(caption):
        print('no caption for', name, '- skipped')
        continue

    shot = Image.open(path).convert('RGB')
    shot = shot.crop((0, TOP_CROP, shot.width, shot.height))
    scale = SHOT_H / shot.height
    shot = shot.resize((round(shot.width * scale), SHOT_H), Image.LANCZOS)
    x, y = (W - shot.width) // 2, CAPTION_H

    canvas = gradient()

    # A soft shadow so the screen lifts off the background.
    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x, y + 12, x + shot.width, H + RADIUS], RADIUS, fill=(60, 20, 0, 110))
    canvas.paste(shadow.filter(ImageFilter.GaussianBlur(24)), (0, 0),
                 shadow.filter(ImageFilter.GaussianBlur(24)))

    canvas.paste(shot, (x, y), rounded_top(shot.size, RADIUS))

    cap = Image.open(caption).convert('RGBA')
    canvas.paste(cap, (0, 0), cap)

    out = os.path.join(OUT, f'{name}.png')
    canvas.save(out, optimize=True)
    print(out, canvas.size, f'{os.path.getsize(out) // 1024} KB')
