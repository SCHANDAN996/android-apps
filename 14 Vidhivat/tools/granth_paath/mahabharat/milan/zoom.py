# -*- coding: utf-8 -*-
"""कई पन्नों की पट्टियाँ काटकर एक चित्र में — संदिग्ध शब्द आँख से देखने के लिए।

    python zoom.py out.png  leaf:y0:y1 [leaf:y0:y1 …]   (उपसर्ग vp; दूसरा हो तो naam/leaf:y0:y1)
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
out = sys.argv[1]
strips = []
for spec in sys.argv[2:]:
    naam = 'vp'
    if '/' in spec:
        naam, spec = spec.split('/')
    leaf, y0, y1 = spec.split(':')
    im = Image.open(os.path.join(HERE, 'panne', '%s_%s.jpg' % (naam, leaf))).convert('RGB')
    w, h = im.size
    y0, y1 = int(y0), int(y1)
    if y1 <= 1:   # अनुपात
        y0, y1 = int(y0 * h), int(y1 * h)
    c = im.crop((0, y0, w, y1))
    f = 1500 / c.width
    strips.append(c.resize((1500, int(c.height * f)), Image.LANCZOS))
H = sum(s.height for s in strips) + 8 * (len(strips) - 1)
canvas = Image.new('RGB', (1500, H), 'red')
y = 0
for s in strips:
    canvas.paste(s, (0, y))
    y += s.height + 8
canvas.save(os.path.join(HERE, 'panne', out))
print(canvas.size)
