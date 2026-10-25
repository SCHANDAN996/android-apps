# -*- coding: utf-8 -*-
"""कई कटे टुकड़े एक चित्र में — ऊपर किताब/पन्ना/मंत्र की पट्टी।

  python -P jodo.py <बाहर.jpg> <किताब:n:M[:पंक्तियाँ]> ...
"""
import os
import subprocess
import sys

from PIL import Image, ImageDraw

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))

bahar = sys.argv[1]
tukde = []
for arg in sys.argv[2:]:
    parts = arg.split(':')
    kitab, n, m = parts[0], parts[1], parts[2]
    pad = parts[3] if len(parts) > 3 else '1'
    r = subprocess.run([sys.executable, '-P', os.path.join(JAD, 'dekho.py'), kitab, n, m, pad],
                       capture_output=True, text=True, encoding='utf-8')
    if r.returncode:
        print('✗', arg, r.stderr.strip()[-200:] or r.stdout.strip()[-200:])
        continue
    path = r.stdout.strip().splitlines()[-1]
    tukde.append(('%s n%s %s' % (kitab, n, m), Image.open(path)))
    print('✓', arg)

if tukde:
    W = 1400
    H = sum(im.size[1] + 34 for _, im in tukde)
    c = Image.new('RGB', (W, H), 'white')
    d = ImageDraw.Draw(c)
    y = 0
    for label, im in tukde:
        d.rectangle([0, y, W, y + 30], fill=(40, 40, 120))
        d.text((10, y + 8), label, fill='white')
        c.paste(im, (0, y + 34))
        y += im.size[1] + 34
    c.save(bahar, quality=88)
    print(bahar, c.size)
    # लंबा हो तो टुकड़ों में — एक चित्र ~2300 से ऊँचा हो तो अक्षर छोटे पड़ते हैं
    if H > 2400:
        k, y0 = 0, 0
        while y0 < H:
            k += 1
            part = '%s_%d.jpg' % (bahar[:-4], k)
            c.crop((0, y0, W, min(H, y0 + 2300))).save(part, quality=88)
            print(part)
            y0 += 2240
