# -*- coding: utf-8 -*-
"""सप्तशती के गवाह पढ़ना — हर पाठ के लिए पंक्तियों की सूची।

A = ऐप का मौजूदा पाठ (tools/granth_paath/saptashati/paath/*.txt) — S से बना था
N = दूसरा देवनागरी संग्रह (sn_*.html)
M = विकिस्रोत, मार्कण्डेय पुराण 81–93 (ws_mkp_*.txt)
R = GRETIL, मार्कण्डेय पुराण (gretil_mkp.txt) — IAST
W = विकिस्रोत के अंग (ws_kavach/argala/keelak.txt)
"""
import io
import os
import re
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'tools'))
from milan import ANK, html_path, kunji_dev, kunji_iast, nfc, saaf  # noqa: E402

PAATH = os.path.join(REPO, 'tools', 'granth_paath', 'saptashati', 'paath')
ADHYAY = ['%02d' % n for n in range(1, 14)]


def A_padho(key):
    """[(शीर्षक, पंक्ति)]"""
    out = []
    t = io.open(os.path.join(PAATH, key + '.txt'), encoding='utf-8').read()
    for blk in re.split(r'\n\s*\n', t.strip()):
        lines = blk.split('\n')
        sh = lines[0][2:].strip()
        for x in lines[1:]:
            if not x.startswith('= '):
                out.append((sh, nfc(x.strip())))
    return out


def N_padho(key):
    f = 'sn_%s.html' % key
    lines = [saaf(x) for x in html_path(io.open(f, encoding='utf-8').read()).split('\n')]
    lines = [x for x in lines if x]
    s = [n for n, x in enumerate(lines) if x.startswith('स्तोत्रनिधि →')][0]
    out = []
    for x in lines[s + 1:]:
        if x.startswith('सम्पूर्ण श्री दुर्गा सप्तशती') or re.match(r'^(इतर|और|గమనిక)', x):
            break
        if re.search(r'[\u0C00-\u0C7F]', x):       # तेलुगु की सूचना-पंक्तियाँ
            break
        out.append(x)
    return out


_M = None


def M_padho(key):
    """key '01'…'13' → पंक्तियाँ"""
    global _M
    if _M is None:
        t = ''
        for f in ('ws_mkp_a.txt', 'ws_mkp_b.txt', 'ws_mkp_c.txt'):
            t += '\n' + nfc(io.open(f, encoding='utf-8').read())
        _M = {}
        cur = None
        for x in t.split('\n'):
            x = saaf(re.sub(r"'''|''|<[^>]+>", '', x))
            if not x:
                continue
            m = re.match(r'^(\d+)\s*\(\s*\d+\s*\)', x)
            if m:
                cur = int(m.group(1))
                _M[cur] = []
                continue
            if cur is None or x.startswith('{{') or x.startswith('|') or x.startswith('[') or x.startswith('}}'):
                continue
            _M[cur].append(x)
    return _M.get(80 + int(key), [])


_R = None


def R_padho(key):
    global _R
    if _R is None:
        t = io.open('gretil_mkp.txt', encoding='utf-8').read()
        _R = {}
        cur = None
        for x in t.split('\n'):
            x = x.strip()
            m = re.search(r"'dhyāyaḥ- (\d+)", x)
            if m:
                cur = int(m.group(1))
                _R[cur] = []
                continue
            if cur is None or not x:
                continue
            _R[cur].append(re.sub(r'markp_\d+\.\d+', '', x))
    return _R.get(80 + int(key), [])


def W_padho(key):
    t = nfc(io.open('ws_%s.txt' % key, encoding='utf-8').read())
    out = []
    for blk in re.findall(r'(?s)<poem>(.*?)</poem>', t):
        for x in blk.split('\n'):
            x = re.sub(r'\[https?://\S+\s+([^\]]+)\]', r'\1', x)
            x = saaf(re.sub(r"'''|''|<[^>]+>", '', x))
            if x:
                out.append(x)
    return out


def bina_ank(x):
    """पंक्ति के अंत का "॥ १२ ॥" हटाओ"""
    return re.sub(r'[॥।|/]+\s*[०-९0-9.\-–]+\s*[॥।|/]*\s*$', '', x).strip()


def kunjiyan(lines, lipi='dev'):
    out = []
    for x in lines:
        if lipi == 'dev':
            k = kunji_dev(bina_ank(x))
        else:
            k = kunji_iast(x)
        out.append(k)
    return out
