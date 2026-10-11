# -*- coding: utf-8 -*-
"""गजेन्द्र मोक्ष (वामन पुराण) — V (पञ्चरत्न गीता, आँख से पढ़ा: v85/*.txt) बनाम
   W (विकिस्रोत, अध्याय ८५ — टंकित), G (गीता प्रेस का वामन पुराण, अध्याय ८४ — OCR),
   K (काशिराज न्यास का समीक्षित संस्करण, अध्याय ५८ — OCR, कमज़ोर)।

    python gm3.py            जहाँ V किसी से अलग है (OCR का शोर छोड़कर)
    python gm3.py ginti      सार
    python gm3.py sab        हर अर्धश्लोक

स्रोत-फ़ाइलें repo में नहीं हैं — `ia_lao.py`/`pu_lao.py` से उतरती हैं; जिस फ़ोल्डर में हों, वह
`GM_SRC` में दीजिए (न दें तो यही फ़ोल्डर):
    ws_vamana_85.txt · ia_vaman-puran-gita-press.txt · ia_in_ernet_dli_2015_313086.txt
"""
import difflib
import glob
import io
import os
import re
import sys
import unicodedata

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get('VIDHIVAT_REPO') or os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'tools'))
from milan import kunji_dev  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')
VDIR = os.path.join(REPO, 'tools', 'granth_paath', 'puran', 'milan', 'v85')
SRC = os.environ.get('GM_SRC') or HERE

# OCR का शोर — पाठभेद नहीं
SHOR = {('ṃ', ''), ('', 'ṃ'), ('', 'ḥ'), ('ḥ', ''), ('r', ''), ('', 'r'), ('ṛ', ''), ('', 'a'), ('a', ''),
        ('c', 'n'), ('śc', 'śn'), ('śc', 'śl'), ('c', 'l'), ('ū', 'u'), ('u', 'ū'), ('ī', 'i'), ('i', 'ī'),
        ('ā', 'a'), ('a', 'ā'), ('y', ''), ('', 'y'), ('ṇ', 'n'), ('n', 'ṇ'), ('ṣ', 's'), ('s', 'ṣ'),
        ('ś', 's'), ('s', 'ś'), ('v', 'b'), ('b', 'v'), ('ai', 'e'), ('e', 'ai'), ('au', 'o'), ('o', 'au')}


def v_ardh():
    """[(श्लोक-अंक, अर्धश्लोक)] — पाद-पाद छपे छंदों की दो पंक्तियाँ जोड़कर।"""
    raw = []
    for f in sorted(glob.glob(os.path.join(VDIR, 'v85_*.txt'))):
        for line in io.open(f, encoding='utf-8'):
            s = line.strip()
            if not s or s[0] in '#@':
                continue
            raw.append(s)
    out, buf = [], ''
    for s in raw:
        m = re.search(r'॥(\d+)॥$', s)
        poora = bool(m) or s.endswith('।')
        t = re.sub(r'\s*॥\d+॥$', '', s).rstrip('।').strip()
        buf = (buf[:-1] + t) if buf.endswith('-') else (buf + ' ' + t).strip()
        if poora:
            out.append([int(m.group(1)) if m else None, buf])
            buf = ''
    assert not buf, buf
    nxt = None
    for r in reversed(out):
        if r[0] is None:
            r[0] = nxt
        else:
            nxt = r[0]
    return [tuple(r) for r in out]


def w_ardh():
    t = io.open(os.path.join(SRC, 'ws_vamana_85.txt'), encoding='utf-8').read()
    t = t[t.find('<poem>'):]
    out = []
    for l in t.split('\n'):
        l = l.strip()
        if not l or 'उवाच' in l or l.startswith('इति') or not DEV.search(l):
            continue
        l = re.sub(r'[।॥\s]*८५\.[०-९\d]+\s*$', '', l)
        l = l.replace('।।', '').rstrip('। ').strip()
        if len(DEV.findall(l)) >= 8:
            out.append(l)
    return out


def ocr_ardh(naam, a, b):
    t = unicodedata.normalize('NFC', io.open(os.path.join(SRC, naam), encoding='utf-8', errors='replace').read())
    seg = t[a:b].replace('\u200c', '').replace('\u200d', '')
    seg = re.sub(r'(?<=[\u0900-\u097f]):', 'ः', seg)
    seg = re.sub(r'(?<=[\u0900-\u097f])[5<]+(?=[\u0900-\u097f])', 'ऽ', seg)
    out = []
    for l in seg.split('\n'):
        l = l.strip()
        if len(DEV.findall(l)) >= 8:
            out.append(l)
    return out


def g_ardh():
    t = unicodedata.normalize('NFC', io.open(os.path.join(SRC, 'ia_vaman-puran-gita-press.txt'),
                                              encoding='utf-8', errors='replace').read())
    a = t.find('चौरासीवाँ अध्याय')
    b = t.find('पचासीवाँ अध्याय', a + 500)
    if b < 0:
        b = a + 40000
    return ocr_ardh('ia_vaman-puran-gita-press.txt', a, b)


def k_ardh():
    return ocr_ardh('ia_in_ernet_dli_2015_313086.txt', 2088000, 2114000)


def paas(k, kunjiyan, jod=2):
    best = (0.0, None, 1)
    for i in range(len(kunjiyan)):
        for j in range(1, jod + 1):
            cand = ''.join(kunjiyan[i:i + j])
            if abs(len(cand) - len(k)) > max(10, len(k) // 3):
                continue
            r = 1.0 if cand == k else difflib.SequenceMatcher(None, k, cand, autojunk=False).ratio()
            if r > best[0]:
                best = (r, i, j)
                if r == 1.0:
                    return best
    return best


def fark(a, b):
    return [(a[i1:i2], b[j1:j2]) for tag, i1, i2, j1, j2 in
            difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes() if tag != 'equal']


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    V = v_ardh()
    W, G, K = w_ardh(), g_ardh(), k_ardh()
    wk, gk, kk = [kunji_dev(x) for x in W], [kunji_dev(x) for x in G], [kunji_dev(x) for x in K]
    g = {'W': [0, 0, 0], 'G': [0, 0, 0, 0], 'K': [0, 0, 0]}
    for num, line in V:
        k = kunji_dev(line)
        rw, iw, jw = paas(k, wk)
        rg, ig, jg = paas(k, gk)
        rk, ik, jk = paas(k, kk)
        g['W'][0 if rw == 1.0 else 1 if rw >= 0.6 else 2] += 1
        g['K'][0 if rk == 1.0 else 1 if rk >= 0.6 else 2] += 1
        if rg == 1.0:
            g['G'][0] += 1
            g_kya = '='
        elif rg >= 0.6:
            ops = fark(k, ''.join(gk[ig:ig + jg]))
            if all(o in SHOR for o in ops):
                g['G'][1] += 1
                g_kya = '~'
            else:
                g['G'][2] += 1
                g_kya = '≠'
        else:
            g['G'][3] += 1
            g_kya = '—'
        if mode == 'ginti':
            continue
        if mode != 'sab' and rw == 1.0 and g_kya in '=~':
            continue
        print('V%-3s %s' % (num, line))
        if rw == 1.0:
            print('   W =')
        elif rw >= 0.6:
            print('   W ≠ %s   %s' % (' '.join(W[iw:iw + jw]), fark(k, ''.join(wk[iw:iw + jw]))))
        else:
            print('   W —  (सबसे पास %.2f)' % rw)
        if g_kya == '=':
            print('   G =')
        elif rg >= 0.6:
            print('   G %s %s   %s' % (g_kya, ' '.join(G[ig:ig + jg])[:110], fark(k, ''.join(gk[ig:ig + jg]))))
        else:
            print('   G —  (सबसे पास %.2f)' % rg)
        if rk >= 0.6:
            print('   K %s %s' % ('=' if rk == 1.0 else '≈', ' '.join(K[ik:ik + jk])[:110]))
        else:
            print('   K —')
    print('V के अर्धश्लोक %d · W के %d · G की पंक्तियाँ %d · K की %d' % (len(V), len(W), len(G), len(K)))
    print('W (विकिस्रोत): हूबहू %d · पास %d · नहीं %d' % tuple(g['W']))
    print('G (गीता प्रेस का पुराण, OCR): हूबहू %d · सिर्फ़ OCR का शोर %d · अलग %d · नहीं मिली %d' % tuple(g['G']))
    print('K (समीक्षित, OCR): हूबहू %d · पास %d · नहीं %d' % tuple(g['K']))
