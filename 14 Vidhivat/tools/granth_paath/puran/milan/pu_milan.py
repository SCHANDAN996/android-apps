# -*- coding: utf-8 -*-
"""पुराणों की अपनी सूचियाँ — विकिस्रोत (देवनागरी) बनाम दूसरा डिजिटल संग्रह (IAST), अर्धश्लोक-दर-अर्धश्लोक।

    python pu_milan.py matsya | bhag13 | bhag7 | vishnu
"""
import difflib
import html
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev, kunji_iast  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')


def padho(naam):
    return io.open(os.path.join(HERE, naam), encoding='utf-8', errors='replace').read()


def ws_panktiyan(naam, shuru=None, ant=None):
    """<poem> के भीतर की देवनागरी पंक्तियाँ (अंक और विराम हटाकर नहीं — जैसी हैं)।"""
    t = padho(naam)
    a = t.find('<poem>')
    b = t.find('</poem>')
    t = t[a + 6:b if b > 0 else None]
    t = re.sub(r'<[^>]+>', '', t)
    out = []
    for l in t.split('\n'):
        l = l.strip()
        if not DEV.search(l):
            continue
        if re.match(r'^\(.*\)$', l) or re.search(r'उवाच\s*-?$|ऊचुः$', l) or l.startswith('इति श्री'):
            continue
        out.append(l)
    return out


def g_panktiyan(naam, pat):
    """GRETIL: वे पंक्तियाँ जिन पर `pat` (regex, group 1 = श्लोक-अंक) का निशान है; हर श्लोक की सब पंक्तियाँ।"""
    t = html.unescape(re.sub(r'<[^>]+>', '', padho(naam)))
    out = []
    buf = []
    for l in t.split('\n'):
        l = l.strip()
        if not l:
            continue
        m = re.search(pat, l)
        if m:
            buf.append(re.sub(pat, '', l).strip())
            out.append((m.group(1), list(buf)))
            buf = []
        elif buf or out:
            # बिना निशान की पंक्ति — अगले निशान वाले श्लोक की पहली पंक्ति (मत्स्य/विष्णु में)
            buf.append(l)
    return out


def milao(ws, g, dikhao_sab=False):
    """ws: [देवनागरी पंक्ति]; g: [(अंक, IAST पंक्ति)] — कुंजी पर जोड़कर फ़र्क़ छापो।"""
    kw = [kunji_dev(x) for x in ws]
    kg = [kunji_iast(x[1]) for x in g]
    sm = difflib.SequenceMatcher(None, kw, kg, autojunk=False)
    ek = alag = 0
    used_g = set()
    for i, k in enumerate(kw):
        # सबसे पास वाली g पंक्ति
        best, bj = 0, None
        for j, kk in enumerate(kg):
            if j in used_g:
                continue
            r = 1.0 if kk == k else difflib.SequenceMatcher(None, k, kk, autojunk=False).ratio()
            if r > best:
                best, bj = r, j
                if r == 1.0:
                    break
        if bj is not None and best >= 0.6:
            used_g.add(bj)
            if best == 1.0:
                ek += 1
                if dikhao_sab:
                    print('=  %-8s %s' % (g[bj][0], ws[i]))
            else:
                alag += 1
                print('≠  %-8s W %s' % (g[bj][0], ws[i]))
                print('            G %s' % g[bj][1])
                ops = [(k[a:b], kg[bj][c:d]) for tag, a, b, c, d in
                       difflib.SequenceMatcher(None, k, kg[bj], autojunk=False).get_opcodes() if tag != 'equal']
                print('            ', ops)
        else:
            alag += 1
            print('W— %s   (G में नहीं; सबसे पास %.2f)' % (ws[i], best))
    for j, x in enumerate(g):
        if j not in used_g:
            print('G— %-8s %s   (W में नहीं)' % x)
    print('W की पंक्तियाँ %d · G से हूबहू %d · अलग/नहीं %d · G की पंक्तियाँ %d' % (len(ws), ek, alag, len(g)))


def chapter_g(naam, pat, rakho):
    out = []
    for num, lines in g_panktiyan(naam, pat):
        if rakho(num):
            for l in lines:
                # एक पंक्ति में दो पाद «  » या « / » से अलग हों तो भी एक ही अर्धश्लोक है
                out.append((num, l))
    return out


if __name__ == '__main__':
    kya = sys.argv[1]
    sab = len(sys.argv) > 2
    if kya == 'matsya':
        ws = ws_panktiyan('ws_matsya_53.txt')
        ws = [re.sub(r'\s*(५३\.)?[०-९]+\s*$', '', x) for x in ws]
        g = chapter_g('g_matsya.htm', r'\s*//\s*MatsP_(53\.\d+\*?)\s*//', lambda n: True)
        milao(ws, g, sab)
    elif kya == 'bhag13':
        ws = ws_panktiyan('ws_bhag_12_13.txt')
        ws = [re.sub(r'\s*॥\s*[०-९]+\s*॥\s*$', '', x).rstrip(' ।') for x in ws]
        t = html.unescape(re.sub(r'<[^>]+>', '', padho('g_bhag12.htm')))
        g = [(m.group(1), m.group(2).strip()) for m in re.finditer(r'BhP_(12\.13\.\d+/\d)\s+(.*)', t)]
        milao(ws, g, sab)
    elif kya == 'bhag7':
        ws = ws_panktiyan('ws_bhag_12_7.txt')
        ws = [re.sub(r'\s*॥\s*[०-९]+\s*॥\s*$', '', x).rstrip(' ।') for x in ws]
        t = html.unescape(re.sub(r'<[^>]+>', '', padho('g_bhag12.htm')))
        g = [(m.group(1), m.group(2).strip()) for m in re.finditer(r'BhP_(12\.07\.\d+/\d)\s+(.*)', t)]
        milao(ws, g, sab)
    elif kya == 'vishnu':
        ws = ws_panktiyan('ws_vishnu_3_6.txt')
        ws = [re.sub(r'\s*।।\s*[०-९]+\s*।।\s*$', '', x).rstrip(' ।') for x in ws]
        g = chapter_g('g_vishnu.htm', r'\s*//\s*ViP_(3,6\.\d+(?:\*\d+:\d+)?)\s*//', lambda n: True)
        milao(ws, g, sab)
