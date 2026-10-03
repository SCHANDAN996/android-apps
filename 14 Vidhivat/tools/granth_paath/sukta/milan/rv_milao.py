# -*- coding: utf-8 -*-
"""ऋग्वेद के सूक्त: W (विकिस्रोत, बिना स्वर), V (Aufrecht, IAST), P (वेद-पोर्टल, स्वर सहित)।"""
import io, re, sys, json
sys.stdout.reconfigure(encoding='utf-8')
# `tools/` — यह फ़ाइल tools/granth_paath/sukta/milan/ में है; स्रोत की फ़ाइलें repo में
# नहीं हैं (पते docs/18 अध्याय २४ में) — उन्हें एक अस्थायी फ़ोल्डर में उतारकर वहीं से चलाओ
import os as _os
sys.path.insert(0, _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..')))
from milan import ANK, kunji_dev, kunji_iast, nfc, saaf
import ved_portal
def rv_gretil(mandala, sukta):
    out, buf = {}, []
    for x in io.open('gretil_sa_Rgveda-edAufrecht.txt', encoding='utf-8'):
        x = x.strip()
        m = re.search(r'\|\|\s*RV_(\d+),(\d+)\.(\d+)\s*$', x)
        if m:
            buf.append(x[:m.start()])
            if (int(m.group(1)), int(m.group(2))) == (mandala, sukta):
                out[int(m.group(3))] = buf
            buf = []
        elif x: buf.append(x.rstrip('|').strip())
        else: buf = []
    return out
def rv_wikisource(f):
    t = nfc(io.open(f, encoding='utf-8').read())
    blk = re.search(r'(?s)<poem>(.*?)</poem>', t).group(1)
    out, buf = {}, []
    for x in blk.split('\n'):
        x = saaf(re.sub(r'<[^>]+>', '', x))
        if not x: continue
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥\s*$', x)
        if m:
            buf.append(x[:m.start()].rstrip() + '॥')
            out[int(m.group(1).translate(ANK))] = buf; buf = []
        else: buf.append(x)
    return out
def kp(x):  # पोर्टल: ':' विसर्ग, '३' प्लुत
    return kunji_dev(nfc(x).replace(':', 'ः').replace('३', ''))
def milao(naam, mandala, sukta, wfile, kitne):
    W, V = rv_wikisource(wfile), rv_gretil(mandala, sukta)
    assert sorted(W) == sorted(V) == list(range(1, kitne + 1)), (sorted(W), sorted(V))
    out = []
    for n in range(1, kitne + 1):
        kw = ''.join(kunji_dev(x.replace('३', '')) for x in W[n])
        kv = ''.join(kunji_iast(x.replace('ṁ', 'ṃ')) for x in V[n])
        kq = kp(ved_portal.mantra('rigveda', mandala, sukta, n))
        print('%s %d: W=V %s · W=P %s' % (naam, n, kw == kv, kw == kq))
        if kw != kv: print('   W', kw, '\n   V', kv)
        if kw != kq: print('   W', kw, '\n   P', kq)
        out.append(W[n])
    json.dump(out, io.open('mool_%s.json' % naam, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    return out
if __name__ == '__main__':
    for x in milao('purusha', 10, 90, 'ws_rv10090.txt', 16): print('  ', ' / '.join(x))
    for x in milao('nasadiya', 10, 129, 'ws_rv10129.txt', 7): print('  ', ' / '.join(x))
