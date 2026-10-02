# -*- coding: utf-8 -*-
"""repo के लिए पूरी पुष्पिका — हर अध्याय की तीन पंक्तियाँ, स्रोत से।

पंक्ति: "अंक<TAB>पहली / दूसरी / तीसरी"
S का रूप; अध्याय 5 का नाम W से ("कर्मसंन्यासयोगो" — S में "संन्यासयोगो")।
"""
import io
import re
import sys

import pushpika as P

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
out = []
for n in range(1, 19):
    s = re.sub(r'श्रीकृष्णार्जुन\s+संवादे', 'श्रीकृष्णार्जुनसंवादे', P.S[n])
    s = re.sub(r'\s*॥\s*[०-९]+\s*॥\s*$', '', s)
    m = re.match(r'^(ॐ तत्सदिति \S+) (ब्रह्मविद्यायां योगशास्त्रे श्रीकृष्णार्जुनसंवादे) (.*ऽध्यायः)$', s)
    assert m, (n, s)
    naam = m.group(3)
    if n == 5:
        w = re.search(r'संवादे\s*(.*?ऽध्यायः)', P.W[n]).group(1).strip()
        naam = w
    out.append('%d\t%s / %s / %s' % (n, m.group(1), m.group(2), naam))
io.open(r'C:\Users\Admin\Desktop\my project\MASS APP\14 Vidhivat\tools\granth_paath\gita\pushpika.txt',
        'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
print('\n'.join(out[:2] + out[4:5]))
