# -*- coding: utf-8 -*-
"""वेद-पोर्टल से एक-एक मंत्र (स्वर सहित) — सिर्फ़ मिलान के लिए। नतीजा cache में।"""
import io, json, os, re, sys, time
# `tools/` — यह फ़ाइल tools/granth_paath/sukta/milan/ में है; स्रोत की फ़ाइलें repo में
# नहीं हैं (पते docs/18 अध्याय २४ में) — उन्हें एक अस्थायी फ़ोल्डर में उतारकर वहीं से चलाओ
import os as _os
sys.path.insert(0, _os.path.abspath(_os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', '..', '..')))
import lao
from milan import html_path
CACHE = 'vp_cache.json'
_c = json.load(io.open(CACHE, encoding='utf-8')) if os.path.exists(CACHE) else {}
def mantra(veda, *ank):
    key = veda + '/' + '/'.join(str(a) for a in ank)
    if key not in _c:
        for koshish in range(5):
            try:
                b = lao.curl('https://xn--j2b3a4c.com/' + key, browser=True)
                break
            except Exception:
                if koshish == 4:
                    raise
                time.sleep(5 * (koshish + 1))
        t = html_path(b.decode('utf-8', 'replace'))
        dv = [x.strip() for x in t.split('\n') if x.strip()]
        i = next(k for k, x in enumerate(dv) if 'बार पढ़ा गया' in x)
        _c[key] = dv[i + 1]
        json.dump(_c, io.open(CACHE, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
        time.sleep(1.5)
    return _c[key]
if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    veda = sys.argv[1]; a = [int(x) for x in sys.argv[2:]]
    for n in range(1, a[-1] + 1):
        print(n, mantra(veda, *a[:-1], n))
