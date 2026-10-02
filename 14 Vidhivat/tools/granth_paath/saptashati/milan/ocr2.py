# -*- coding: utf-8 -*-
"""छपे संस्करणों के OCR पाठ में किसी पंक्ति का सबसे मिलता टुकड़ा ढूँढना।

OCR में ग़लतियाँ होती हैं, इसलिए ये गवाह सिर्फ़ वहाँ देखे जाते हैं जहाँ बाक़ी
गवाह आपस में अलग हों — और आँख से।
"""
import difflib
import io
import os
import re
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'tools'))
from milan import kunji_dev, nfc  # noqa: E402

OCR = {'m2024': 'ia_m2024.txt', 'ds2019': 'ia_ds2019.txt', 'ns1974': 'ia_ns1974.txt',
       'gondal': 'ia_gondal1944.txt'}
_C = {}


def _lo(naam):
    if naam not in _C:
        t = nfc(io.open(OCR[naam], encoding='utf-8').read())
        lines = [x for x in t.split('\n') if re.search('[\u0900-\u097F]', x)]
        keys = [kunji_dev(x.replace('-', '')) for x in lines]
        idx = {}
        for n, k in enumerate(keys):
            for i in range(0, max(0, len(k) - 5)):
                idx.setdefault(k[i:i + 6], set()).add(n)
        _C[naam] = (lines, keys, idx)
    return _C[naam]


def dhundho(q, naam):
    """q — देवनागरी पंक्ति। लौटाता है (मेल 0–1, OCR का टुकड़ा, उसकी कुंजी)।"""
    lines, keys, idx = _lo(naam)
    qk = kunji_dev(q)
    vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()):
            vote[n] = vote.get(n, 0) + 1
    best = (0.0, '', '')
    for n, _ in sorted(vote.items(), key=lambda x: -x[1])[:6]:
        lo, hi = max(0, n - 1), min(len(lines), n + 2)
        win = ''.join(keys[lo:hi])
        sm = difflib.SequenceMatcher(None, qk, win, autojunk=False)
        blocks = [b for b in sm.get_matching_blocks() if b.size]
        if not blocks:
            continue
        s, e = blocks[0].b, blocks[-1].b + blocks[-1].size
        tuk = win[s:e]
        r = difflib.SequenceMatcher(None, qk, tuk, autojunk=False).ratio()
        if r > best[0]:
            best = (r, ' / '.join(x.strip() for x in lines[lo:hi]), tuk)
    return best


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    for q in sys.argv[1:]:
        print('==', q)
        for naam in OCR:
            r, tuk, k = dhundho(q, naam)
            print('  %-7s %.2f %s' % (naam, r, tuk[:200]))
