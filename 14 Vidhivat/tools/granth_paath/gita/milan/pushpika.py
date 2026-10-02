# -*- coding: utf-8 -*-
"""अध्याय-समापन (पुष्पिका) — S और W से, मिलाकर।"""
import html
import io
import re
import sys

from gita_padho import nfc, saaf, iast, kunji_iast

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

raw = io.open('sd_gita.html', encoding='utf-8', errors='replace').read()
t = nfc(re.sub(r'(?s)<[^>]+>', '\n', html.unescape(raw)))
lines = [saaf(x) for x in t.split('\n') if saaf(x)]
S = {}
for i, x in enumerate(lines):
    if x.startswith('ॐ तत्सदिति'):
        blk = [x]
        j = i + 1
        while not re.search(r'॥\s*[०-९]+॥$', blk[-1]):
            blk.append(lines[j])
            j += 1
        S[len(S) + 1] = ' '.join(blk)
print('S', len(S))

W = {}
for n in range(1, 19):
    w = nfc(io.open('ws_%02d.txt' % n, encoding='utf-8').read())
    m = re.search(r'(ॐ तत्सदिति.*?ऽध्यायः[^\n]*)', w, re.S)
    W[n] = saaf(m.group(1).replace("'''", '')) if m else ''
print('W', sum(1 for v in W.values() if v))

for n in range(1, 19):
    ks = kunji_iast(iast(re.sub(r'[०-९]', '', S[n])))
    kw = kunji_iast(iast(re.sub(r'[०-९]', '', W[n])))
    print(n, 'एक' if ks == kw else 'अलग')
    print('  S', S[n])
    if ks != kw:
        print('  W', W[n])

# ── repo के लिए: अध्याय का संस्कृत नाम-वाक्य, एक अध्याय एक पंक्ति ──────────
# S का रूप; अध्याय 5 में W का ("कर्मसंन्यासयोगो" — S में "संन्यासयोगो")।
out = []
for n in range(1, 19):
    src = W[n] if n == 5 else S[n]
    m = re.search(r'श्रीकृष्णार्जुन\s*संवादे\s*(.*?ऽध्यायः)', src)
    out.append('%d\t%s' % (n, m.group(1).strip()))
io.open(r'C:\Users\Admin\Desktop\my project\MASS APP\14 Vidhivat\tools\granth_paath\gita\pushpika.txt',
        'w', encoding='utf-8', newline='\n').write('\n'.join(out) + '\n')
print('\n'.join(out))
