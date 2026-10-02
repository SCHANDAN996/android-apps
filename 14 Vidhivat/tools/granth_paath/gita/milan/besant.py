# -*- coding: utf-8 -*-
"""Besant (1905; चौथा संस्करण 1922) — छपी पुस्तक का संस्कृत पाठ और अंग्रेज़ी
अनुवाद, श्लोक-दर-श्लोक। दो काम:

1. संस्कृत पाठ **पाँचवाँ गवाह** — एक छपा संस्करण — mool.txt से मिलान।
2. अंग्रेज़ी अनुवाद — कठिन श्लोकों के अर्थ की जाँच के लिए (उठाने के लिए नहीं)।

    python besant.py            मिलान के आँकड़े
    python besant.py 2.16 13.12 ये श्लोक छापो
"""
import io
import re
import sys

from gita_padho import nfc, kunji, UVACH

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
ANK = str.maketrans('०१२३४५६७८९', '0123456789')
DEV = re.compile('[ऀ-ॿ]')


def padho():
    skt, eng = {}, {}
    for n in range(1, 19):
        t = nfc(io.open('pd/besant_%02d.txt' % n, encoding='utf-8').read())
        lines = [x.strip().replace('​', '') for x in t.split('\n')]
        lines = [x for x in lines if x]
        sbuf, ebuf = [], []
        for x in lines:
            m = re.search(r'॥\s*([०-९]+)\s*॥\s*$', x)
            if m and DEV.search(x):
                sbuf.append(re.sub(r'\s*॥\s*[०-९]+\s*॥\s*$', '', x))
                v = int(m.group(1).translate(ANK))
                # छह पाद वाले श्लोक में बीच की पंक्ति पर भी ॥ आ सकता है — नहीं;
                # यहाँ संख्या वाला ॥ ही श्लोक का अंत है।
                skt[(n, v)] = sbuf
                sbuf, ebuf = [], []
                continue
            m2 = re.match(r'^\((\d+)\)$', x)
            if m2:
                eng[(n, int(m2.group(1)))] = ' '.join(ebuf).strip()
                ebuf = []
                continue
            if DEV.search(x):
                sbuf.append(x)
            elif re.search(r'[A-Za-z]', x):
                ebuf.append(x)
    return skt, eng


if __name__ == '__main__':
    skt, eng = padho()
    if len(sys.argv) > 1:
        for a in sys.argv[1:]:
            c, v = a.split('.')
            k = (int(c), int(v))
            print('%s  %s' % (a, eng.get(k, '—')))
        sys.exit()

    M = {}
    for blk in io.open('mool.txt', encoding='utf-8').read().strip().split('\n\n'):
        L = blk.split('\n')
        a, v = L[0][2:].split('.')
        M[(int(a), int(v))] = L[1:]
    print('Besant: संस्कृत %d श्लोक, अंग्रेज़ी %d' % (len(skt), len(eng)))
    ek = alag = nahin = 0
    farq = []
    for k in M:
        if k not in skt:
            nahin += 1
            continue
        if kunji(skt[k]) == kunji(M[k]):
            ek += 1
        else:
            alag += 1
            farq.append(k)
    print('mool से हूबहू (कुंजी): %d · अलग: %d · Besant में नहीं मिला: %d' % (ek, alag, nahin))
    import difflib
    with io.open('besant_farq.txt', 'w', encoding='utf-8') as f:
        for k in farq:
            a, b = kunji(M[k]), kunji(skt[k])
            tuk = ['[%s→%s]' % (a[i1:i2], b[j1:j2]) for op, i1, i2, j1, j2
                   in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes() if op != 'equal']
            f.write('%d.%d  %s\n' % (k[0], k[1], ' '.join(tuk)[:300]))
