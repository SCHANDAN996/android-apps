# -*- coding: utf-8 -*-
"""छपी किताबों (archive.org) के पन्ने-वार OCR में मंत्र ढूँढना — सिर्फ़ जगह ढूँढने को; पाठ पन्ने से आँख से।

मंत्र-जाँच (→ D-141, docs/18 §४२)। OCR, hOCR और पन्नों के चित्र repo में नहीं रखे जाते — वे
`MANTRA_SRC` फ़ोल्डर में उतरते हैं (न दिया तो temp में): `python -P khoj.py lao <id> <नाम>`।
किताबों की सूची `kitab.json` में; हर एक दोबारा उतारनी हो तो उसी से।

  python -P khoj.py lao <id> [<छोटा नाम>]         — searchtext + pageindex उतारो
  python -P khoj.py sab                            — suchi.json के हर मंत्र को हर किताब में
  python -P khoj.py ek <M..> [किताब]                — एक मंत्र, ऊपर के पन्ने
  python -P khoj.py panna <किताब> <leaf>            — उस पन्ने का OCR
"""
import gzip
import io
import json
import os
import re
import sys
import tempfile
import unicodedata
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))
SRC = os.environ.get('MANTRA_SRC') or os.path.join(tempfile.gettempdir(), 'vidhivat_mantra_src')
os.makedirs(SRC, exist_ok=True)
KITAB = os.path.join(JAD, 'kitab.json')   # छोटा नाम → archive id (repo में)


def kitabein():
    if os.path.exists(KITAB):
        return json.load(io.open(KITAB, encoding='utf-8'))
    return {}


def lao(ia_id, naam):
    url = 'https://archive.org/metadata/%s/files' % ia_id
    files = json.load(urllib.request.urlopen(url, timeout=120))['result']
    st = [f['name'] for f in files if f['name'].endswith('_hocr_searchtext.txt.gz')]
    pi = [f['name'] for f in files if f['name'].endswith('_hocr_pageindex.json.gz')]
    if not st or not pi:
        raise SystemExit('searchtext/pageindex नहीं: %s' % ia_id)
    for n, ext in ((st[0], '.txt'), (pi[0], '.json')):
        u = 'https://archive.org/download/%s/%s' % (ia_id, urllib.parse.quote(n))
        data = gzip.decompress(urllib.request.urlopen(u, timeout=600).read())
        io.open(os.path.join(SRC, naam + ext), 'wb').write(data)
    k = kitabein()
    k[naam] = ia_id
    json.dump(k, io.open(KITAB, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('उतरा', naam, ia_id)


def panne(naam):
    s = io.open(os.path.join(SRC, naam + '.txt'), encoding='utf-8').read()
    idx = json.load(io.open(os.path.join(SRC, naam + '.json'), encoding='utf-8'))
    # pageindex: हर पन्ने के [शुरू, अंत, …] अक्षर-स्थान
    out = []
    for i, e in enumerate(idx):
        out.append(s[e[0]:e[1]])
    return out


def saaf(t):
    t = unicodedata.normalize('NFC', t)
    t = re.sub(r'[^ऀ-ॿ]', '', t)        # सिर्फ़ देवनागरी
    t = re.sub(r'[।॥।॥०-९ऽ]', '', t)
    return t


def shabd(mantra):
    w = re.split(r'[\s।॥|,;—\-!?()]+', unicodedata.normalize('NFC', mantra))
    w = [saaf(x) for x in w]
    w = [x for x in w if len(x) >= 4 and x not in ('नमः', 'स्वाहा', 'समर्पयामि')]
    seen = []
    for x in w:
        if x not in seen:
            seen.append(x)
    return seen


def ank(mantra, naam, upar=3):
    pp = [saaf(p) for p in panne(naam)]
    sh = shabd(mantra)
    if not sh:
        return []
    res = []
    for i, p in enumerate(pp):
        mile = [x for x in sh if x in p]
        # टुकड़े भी: शब्द का आगे-पीछे का 4-अक्षर हिस्सा (OCR की भूल सहने को)
        aadhe = sum(1 for x in sh if x not in mile and len(x) >= 6 and (x[:4] in p and x[-4:] in p))
        score = (len(mile) + 0.5 * aadhe) / len(sh)
        if score > 0:
            res.append((score, i, len(mile), len(sh)))
    res.sort(reverse=True)
    return res[:upar]


def main():
    a = sys.argv[1:]
    if a[0] == 'lao':
        lao(a[1], a[2] if len(a) > 2 else a[1])
    elif a[0] in ('sab', 'ek'):
        suchi = json.load(io.open(os.path.join(JAD, 'suchi_24oct.json'), encoding='utf-8'))
        k = kitabein()
        naamein = [a[2]] if a[0] == 'ek' and len(a) > 2 else list(k)
        for m in suchi:
            if a[0] == 'ek' and m['id'] != a[1]:
                continue
            line = [m['id']]
            for n in naamein:
                r = ank(m['paath'], n, 3 if a[0] == 'ek' else 1)
                if a[0] == 'ek':
                    print(n, r)
                elif r:
                    line.append('%s:%d(%.2f)' % (n, r[0][1], r[0][0]))
            if a[0] == 'sab':
                print('  '.join(line))
    elif a[0] == 'panna':
        print(panne(a[1])[int(a[2])])


if __name__ == '__main__':
    main()
