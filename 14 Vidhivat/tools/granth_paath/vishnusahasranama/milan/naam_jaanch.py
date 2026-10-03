# -*- coding: utf-8 -*-
"""हज़ार नामों की जाँच — repo के भीतर से चलती है, बाहर का कोई स्रोत नहीं चाहिए।

    python tools/granth_paath/vishnusahasranama/milan/naam_jaanch.py

`paath/02.txt` के हर श्लोक के अर्थ में नाम इस रूप में हैं:
    = (नाम ९९३–१०००) शङ्खभृत् — …; नन्दकी — …।
यह देखता है कि
  1. अंक १ से १००० तक बिना टूटे चलते हैं, और हर श्लोक में उतने ही नाम हैं;
  2. हर नाम अपने श्लोक के मूल में है, **उसी क्रम में** (संधि से अंत का अक्षर
     बदलता है और «ऽ» से शुरू का "अ" छिपता है — इसलिए तना एक-दो अक्षर छोटा
     करके भी देखा जाता है)।
तीन-चार अक्षर के नामों (अजः, एकः, असत्) पर दूसरी जाँच ढीली पड़ती है; वे नीचे
`CHHOTE` में लिखे हैं और आँख से देखे गए हैं।
"""
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402

ANK = str.maketrans('०१२३४५६७८९', '0123456789')
CHHOTE = {(22, 'अजः'), (51, 'असत्'), (56, 'अजः'), (78, 'एकः')}


def padho():
    t = io.open(os.path.join(HERE, '..', 'paath', '02.txt'), encoding='utf-8').read()
    out = []
    for blk in t.strip().split('\n\n'):
        lines = blk.split('\n')
        mool = [x for x in lines[1:] if not x.startswith('= ')]
        arth = [x[2:] for x in lines[1:] if x.startswith('= ')][0]
        m = re.match(r'^\(नाम ([०-९]+)–([०-९]+)\) (.+)।$', arth)
        assert m, lines[0]
        naam = [x.split(' — ', 1)[0] for x in m.group(3).split('; ')]
        out.append((int(m.group(1).translate(ANK)), int(m.group(2).translate(ANK)), mool, naam))
    return out


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    galti, agla = 0, 1
    for n, (a, b, mool, naam) in enumerate(padho(), 1):
        if a != agla or len(naam) != b - a + 1:
            galti += 1
            print('✗ श्लोक %d: अंक %d–%d, नाम %d, चाहिए था %d से' % (n, a, b, len(naam), agla))
        agla = b + 1
        vk = kunji_dev(' '.join(mool)).replace('ḥ', '')
        pos = 0
        for x in naam:
            stem = re.sub('(ṃ|m)$', '', kunji_dev(x).replace('ḥ', ''))
            best = None
            for s in (stem, stem[1:], stem[:-1], stem[1:-1], stem[:-2], stem[1:-2]):
                if len(s) >= 3 or (len(s) >= 1 and s == stem):
                    p = vk.find(s, pos)
                    if p >= 0 and p - pos <= 12:
                        c = (p, -len(s))
                        if best is None or c < best[0]:
                            best = (c, p + len(s))
            if best:
                pos = best[1]
            elif (n, x) not in CHHOTE:
                galti += 1
                print('✗ श्लोक %d: "%s" मूल में क्रम से नहीं मिला' % (n, x))
    if agla != 1001:
        galti += 1
        print('✗ कुल नाम %d — हज़ार चाहिए' % (agla - 1))
    print('✓ 107 श्लोक, 1000 नाम — हर नाम अपने श्लोक में, क्रम से' if not galti
          else '✗ %d गड़बड़' % galti)
    sys.exit(1 if galti else 0)


if __name__ == '__main__':
    main()
