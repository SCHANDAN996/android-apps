# -*- coding: utf-8 -*-
"""अनुस्मृति — दो छपी पुस्तकों का मिलान।

    V  = श्रीपञ्चरत्नगीता (गीताप्रेस) की पुस्तिका                → vanu/vanu_*.txt
    NS = श्रीमद्भगवद्गीता और पञ्चरत्न गीता (निर्णय सागर, 1894)  → nanu/nanu_*.txt

दोनों फ़ाइलें छपे पन्ने आँख से पढ़कर लिखी गई हैं। यह script उन्हें अर्धश्लोक-दर-अर्धश्लोक
मिलाता है। दोनों पुस्तकों के श्लोक-अंक ५६ से आगे अलग पड़ते हैं और दो श्लोकों का क्रम उलटा
है — इसलिए मिलान अंक से नहीं, पंक्ति की कुंजी से होता है। अनुस्वार/पंचम वर्ण और अवग्रह
का फ़र्क़ `milan.kunji_dev` में घुल जाता है — जो बचे, वही असली फ़र्क़ है।

    python anusmriti_milan.py            जहाँ दोनों अलग हैं
    python anusmriti_milan.py ginti      सिर्फ़ गिनती
"""
import difflib
import glob
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402


def ardh(pattern):
    """[(श्लोक-अंक, अर्धश्लोक)] — पाद-पाद छपे छंदों की पंक्तियाँ जोड़कर।"""
    raw = []
    for f in sorted(glob.glob(os.path.join(HERE, pattern))):
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


def fark(a, b):
    return [(a[i1:i2], b[j1:j2]) for tag, i1, i2, j1, j2 in
            difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes() if tag != 'equal']


def jodi(V, N):
    """V की हर पंक्ति के लिए N की सबसे पास वाली, अब तक न ली गई पंक्ति (आस-पास की खिड़की में)।"""
    nk = [kunji_dev(x[1]) for x in N]
    liya = set()
    out = []
    for i, (nv, lv) in enumerate(V):
        k = kunji_dev(lv)
        best = (0.0, None)
        for j in range(max(0, i - 6), min(len(N), i + 7)):
            if j in liya:
                continue
            r = 1.0 if nk[j] == k else difflib.SequenceMatcher(None, k, nk[j], autojunk=False).ratio()
            if r > best[0]:
                best = (r, j)
        liya.add(best[1])
        out.append((i, best[1], best[0]))
    return out


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    V, N = ardh('vanu/vanu_*.txt'), ardh('nanu/nanu_*.txt')
    assert len(V) == len(N), (len(V), len(N))
    alag = ulta = 0
    for i, j, r in jodi(V, N):
        nv, lv = V[i]
        nn, ln = N[j]
        if i != j:
            ulta += 1
        if r == 1.0:
            continue
        alag += 1
        if mode != 'ginti':
            print('V %-3s %s\nNS %-3s %s\n       %s' % (nv, lv, nn, ln, fark(kunji_dev(lv), kunji_dev(ln))))
    print('अर्धश्लोक %d · हूबहू %d · अलग %d · जिनकी जगह दूसरी पुस्तक में अलग है %d'
          % (len(V), len(V) - alag, alag, ulta))
