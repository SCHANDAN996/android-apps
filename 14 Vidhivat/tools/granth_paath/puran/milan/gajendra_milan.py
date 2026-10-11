# -*- coding: utf-8 -*-
"""गजेन्द्र मोक्ष (वामन पुराण, अध्याय ८५) — दो छपी पुस्तकों का मिलान।

    V  = श्रीपञ्चरत्नगीता (गीताप्रेस) की पुस्तिका         → v85/v85_*.txt
    KH = श्रीवामनपुराणम्, खेमराज श्रीकृष्णदास की पोथी   → kh85/kh85.txt

दोनों फ़ाइलें छपे पन्ने आँख से पढ़कर लिखी गई हैं। यह script उन्हें अर्धश्लोक-दर-अर्धश्लोक
मिलाता है। अनुस्वार/पंचम वर्ण और अवग्रह का फ़र्क़ `milan.kunji_dev` में घुल जाता है —
जो बचे, वही असली फ़र्क़ है।

    python gajendra_milan.py            जहाँ दोनों अलग हैं
    python gajendra_milan.py ginti      सिर्फ़ गिनती
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


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    V, K = ardh('v85/v85_*.txt'), ardh('kh85/kh85.txt')
    assert len(V) == len(K), (len(V), len(K))
    alag = 0
    for (nv, lv), (nk, lk) in zip(V, K):
        assert nv == nk, (nv, nk)
        a, b = kunji_dev(lv), kunji_dev(lk)
        if a == b:
            continue
        alag += 1
        if mode != 'ginti':
            print('%-3s V  %s\n    KH %s\n       %s' % (nv, lv, lk, fark(a, b)))
    print('अर्धश्लोक %d · हूबहू %d · अलग %d' % (len(V), len(V) - alag, alag))
