# -*- coding: utf-8 -*-
"""भीष्म स्तवराज — V (पञ्चरत्न गीता, आँख से पढ़ा: v47/*.txt) बनाम
   S (गीता प्रेस का शांति पर्व, अध्याय ४७ — OCR), K (विकिस्रोत, दाक्षिणात्य १२.४६), C (समीक्षित १२.४७)।

    python bs3.py            जहाँ V किसी से अलग है (OCR का शोर छोड़कर)
    python bs3.py ginti      सार
    python bs3.py sab        हर पंक्ति
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
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402
import bs_k as BK  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')
VDIR = os.path.join(HERE, 'v47') if os.path.isdir(os.path.join(HERE, 'v47')) else HERE

# OCR का शोर — पाठभेद नहीं (अनुस्वार, विसर्ग, रेफ, मिलते-जुलते अक्षर)
SHOR = {('ṃ', ''), ('', 'ṃ'), ('', 'ḥ'), ('ḥ', ''), ('r', ''), ('', 'r'), ('ṛ', ''), ('', 'a'), ('a', ''),
        ('c', 'n'), ('śc', 'śn'), ('śc', 'śl'), ('c', 'l'), ('ū', 'u'), ('u', 'ū'), ('ī', 'i'), ('i', 'ī'),
        ('ā', 'a'), ('a', 'ā'), ('y', ''), ('', 'y'), ('ṇ', 'n'), ('n', 'ṇ'), ('ṣ', 's'), ('s', 'ṣ'),
        ('ś', 's'), ('s', 'ś'), ('v', 'b'), ('b', 'v'), ('ai', 'e'), ('e', 'ai'), ('au', 'o'), ('o', 'au')}


def v_panktiyan():
    """[(श्लोक-अंक, पंक्ति)] — v47_*.txt से, क्रम में।"""
    raw = []
    for f in sorted(glob.glob(os.path.join(VDIR, 'v47_*.txt'))):
        for line in io.open(f, encoding='utf-8'):
            s = line.strip()
            if not s or s[0] in '#@':
                continue
            m = re.search(r'॥(\d+)॥$', s)
            raw.append([int(m.group(1)) if m else None, re.sub(r'\s*॥\d+॥$', ' ॥', s) if m else s])
    nxt = None
    for r in reversed(raw):
        if r[0] is None:
            r[0] = nxt
        else:
            nxt = r[0]
    return [tuple(r) for r in raw]


def s_panktiyan():
    """गीता प्रेस के शांति पर्व का OCR — अध्याय ४७ की देवनागरी पंक्तियाँ (हिंदी अनुवाद समेत; मिलान उन्हें छाँट देता है)।"""
    t = unicodedata.normalize('NFC', io.open(os.path.join(HERE, 'ia_12shantiparva.txt'),
                                              encoding='utf-8', errors='replace').read())
    a = t.find('भीष्मद्वारा भगवान्')
    b = t.find('सप्तचत्वारिंशो', a + 200)
    seg = t[a:b].replace('\u200c', '').replace('\u200d', '')
    seg = re.sub(r'(?<=[\u0900-\u097f]):', 'ः', seg)
    seg = re.sub(r'(?<=[\u0900-\u097f])[5<]+(?=[\u0900-\u097f])', 'ऽ', seg)
    out = []
    for l in seg.split('\n'):
        l = l.strip()
        if len(DEV.findall(l)) >= 8:
            out.append(l)
    return out


def paas(k, kunjiyan, jod=1):
    """k के सबसे पास वाली पंक्ति (या `jod` पंक्तियों का जोड़)। → (अनुपात, सूचक, कितनी पंक्तियाँ)"""
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
    V = v_panktiyan()
    S = s_panktiyan()
    K = [(n, l) for n, l in BK.k_panktiyan() if not re.search(r'उवाच', l)]
    C = BK.c_panktiyan()
    sk = [kunji_dev(x) for x in S]
    kk = [kunji_dev(l) for n, l in K]
    ck = [kunji_dev(l) for n, l in C]
    g = {'S': [0, 0, 0, 0], 'K': [0, 0, 0], 'C': [0, 0, 0]}   # हूबहू, (शोर), अलग, नहीं
    for num, line in V:
        k = kunji_dev(line)
        rs, i, j = paas(k, sk)
        rk, ik, jk = paas(k, kk)
        rc, ic, jc = paas(k, ck, jod=2)
        s_line = S[i] if i is not None else ''
        k_line = ' '.join(l for n, l in K[ik:ik + jk]) if ik is not None else ''
        c_line = ' '.join(l for n, l in C[ic:ic + jc]) if ic is not None else ''
        # S
        if rs == 1.0:
            g['S'][0] += 1
            s_kya = '='
        elif rs >= 0.7:
            ops = fark(k, sk[i])
            if all(o in SHOR for o in ops):
                g['S'][1] += 1
                s_kya = '~'
            else:
                g['S'][2] += 1
                s_kya = '≠'
        else:
            g['S'][3] += 1
            s_kya = '—'
        for nm, r, gg in (('K', rk, g['K']), ('C', rc, g['C'])):
            gg[0 if r == 1.0 else 1 if r >= 0.7 else 2] += 1
        if mode == 'ginti':
            continue
        if mode != 'sab' and s_kya in '=~' and rk == 1.0:
            continue
        print('V%-4s %s' % (num, line))
        print('   S %s %s' % (s_kya, '' if s_kya == '=' else '%s   %s' % (s_line[:90], fark(k, sk[i]) if i is not None else '')))
        print('   K %s' % ('=' if rk == 1.0 else ('%s %s' % (K[ik][0], k_line[:90]) if rk >= 0.7 else '—  (सबसे पास %.2f)' % rk)))
        print('   C %s' % ('=' if rc == 1.0 else ('%s %s' % (C[ic][0], c_line[:90]) if rc >= 0.7 else '—')))
    print('V की पंक्तियाँ %d' % len(V))
    print('S (शांति पर्व का OCR): हूबहू %d · सिर्फ़ OCR का शोर %d · अलग %d · नहीं मिली %d' % tuple(g['S']))
    print('K (दाक्षिणात्य): हूबहू %d · पास %d · नहीं %d' % tuple(g['K']))
    print('C (समीक्षित): हूबहू %d · पास %d · नहीं %d' % tuple(g['C']))
