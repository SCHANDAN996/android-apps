# -*- coding: utf-8 -*-
import sys, io, re, difflib
sys.stdout.reconfigure(encoding='utf-8')
# `tools/` — यह फ़ाइल tools/granth_paath/sukta/milan/ में है; स्रोत की फ़ाइलें repo में
# नहीं हैं (पते docs/18 अध्याय २४ में) — उन्हें एक अस्थायी फ़ोल्डर में उतारकर वहीं से चलाओ
import os as _os
sys.path.insert(0, _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..')))
from milan import html_path, kunji_dev, kunji_iast, nfc, saaf, ANK
def dv(f):
    t = html_path(io.open(f, encoding='utf-8', errors='replace').read())
    return [saaf(x) for x in t.split('\n') if re.search('[\u0900-\u097F]', x)]
def k(x): return kunji_dev(nfc(x).replace('ꣳ', 'ं').replace(':', 'ः').replace('ग्ं', 'ं'))
def mantra(lines):
    i = next(n for n, x in enumerate(lines) if 'hariṇīṃ' in k(x))
    out, buf = {}, []
    for x in lines[i:]:
        x = re.sub(r'^ॐ\s*॥\s*', '', x)
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥?\s*$', x)
        if m:
            buf.append(x[:m.start()]); out[int(m.group(1).translate(ANK))] = buf; buf = []
            if len(out) == 16: break
        else: buf.append(x)
    return out
def K_padho():
    K, buf = {}, []
    for x in io.open('gretil_sa_RgvedakhilAni.txt', encoding='utf-8'):
        x = x.strip()
        m = re.search(r'RvKh_2,6\.(\d+)\s*$', x)
        if m:
            buf.append(re.sub(r'/+\d*\s*RvKh.*$', '', x))
            K[int(m.group(1))] = [re.sub(r'\(.*?\)|[./|]', ' ', y) for y in buf]; buf = []
        elif x: buf.append(x)
        else: buf = []
    return K
def farq(a, b):
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    return ' '.join('%s→%s' % (a[i1:i2] or '∅', b[j1:j2] or '∅') for tag, i1, i2, j1, j2 in sm.get_opcodes() if tag != 'equal')
if __name__ == '__main__':
    SD, N, K = mantra(dv('sd_shri.html')), mantra(dv('sn_shri.html')), K_padho()
    print(sorted(SD), sorted(N), sorted(K)[:17])
    for n in range(1, 17):
        ks = ''.join(k(x) for x in SD[n]); kn = ''.join(k(x) for x in N.get(n, []))
        kk = ''.join(kunji_iast(saaf(x).replace(' ', '')) for x in K.get(n, []))
        print('--', n, ' / '.join(SD[n]))
        print('   SD=N', ks == kn, '' if ks == kn else farq(ks, kn))
        print('   SD~K', farq(ks, kk)[:220])
