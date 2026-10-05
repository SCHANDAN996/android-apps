# -*- coding: utf-8 -*-
"""यक्ष प्रश्न — दो पाठ-परंपराएँ आमने-सामने: समीक्षित (C: ३.२९६–२९८) और विकिस्रोत वाला
दाक्षिणात्य (K: ३.३१२–३१५)। हर K-श्लोक C में है या नहीं, और कितना मिलता है।"""
import io
import os
import re
import sys
import time
import unicodedata

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402


def ws(n):
    out = os.path.join(HERE, 'ws_mbh_3_%d.txt' % n)
    if not os.path.exists(out):
        import lao  # सप्तशती के milan/ वाला — पन्ना उतारने के लिए
        t = lao.raw('महाभारतम्-03-आरण्यकपर्व-%d' % n)
        io.open(out, 'w', encoding='utf-8').write(t)
        time.sleep(7)
    return io.open(out, encoding='utf-8').read()


def k_shlok(n):
    """[(अंक, [पंक्तियाँ])] — «3-314-12» वाले निशान तक की पंक्तियाँ एक श्लोक।"""
    t = ws(n)
    i = t.find('<poem>')
    t = t[i:] if i >= 0 else t
    out, buf = [], []
    for line in t.split('\n'):
        line = re.sub(r'<[^>]+>', '', line).strip()
        if not line:
            continue
        m = re.search(r'3-%d-(\d+)(x?)\s*$' % n, line)
        text = re.sub(r'\s*3-%d-\d+x?\s*$' % n, '', line).strip()
        if m and m.group(2) == 'x':     # «उवाच» वाली पंक्ति
            continue
        if text:
            buf.append(text)
        if m:
            out.append(('%d.%s' % (n, m.group(1)), buf))
            buf = []
    return out


def c_shlok():
    out = {}
    for l in io.open(os.path.join(HERE, 'bori_03.txt'), encoding='utf-8', errors='replace'):
        m = re.match(r'^03(29[678])(\d\d\d)([a-z])\s+(.*)$', l)
        if not m:
            continue
        out.setdefault('%s.%d' % (m.group(1), int(m.group(2))), []).append(m.group(4).strip())
    return out


C = c_shlok()
CK = {k: kunji_dev(' '.join(v)) for k, v in C.items()}


def sabse_paas(kk):
    """K के श्लोक की कुंजी के सबसे पास C का कौन सा श्लोक — साझा 8-अक्षर टुकड़ों से।"""
    def tukde(s):
        return {s[i:i + 8] for i in range(0, max(1, len(s) - 7))}
    a = tukde(kk)
    best, bk = 0.0, None
    for k, ck in CK.items():
        b = tukde(ck)
        r = len(a & b) / max(1, min(len(a), len(b)))
        if r > best:
            best, bk = r, k
    return bk, best


if __name__ == '__main__':
    for n in (312, 313, 314, 315):
        K = k_shlok(n)
        mile = sum(1 for _, v in K if sabse_paas(kunji_dev(' '.join(v)))[1] >= 0.5)
        print('K %d: %d श्लोक · C में मिले (≥0.5) %d' % (n, len(K), mile))
    print('C: 296 =', sum(1 for k in C if k.startswith('296')), '· 297 =', sum(1 for k in C if k.startswith('297')),
          '· 298 =', sum(1 for k in C if k.startswith('298')))
    print()
    for num, v in k_shlok(314):
        bk, r = sabse_paas(kunji_dev(' '.join(v)))
        print('%-8s %-8s %.2f  %s' % (num, bk if r >= 0.5 else '—', r, ' / '.join(v)[:95]))
