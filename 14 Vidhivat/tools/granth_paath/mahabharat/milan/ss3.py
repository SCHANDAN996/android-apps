# -*- coding: utf-8 -*-
"""सनत्सुजातीय (महाभारत, उद्योगपर्व ४२–४६) — V (गीताप्रेस का महाभारत, आँख से: vss/*.txt) का
मशीन-मिलान चार और पाठों से:

    A = उसी गीताप्रेस वाले पाठ का एक टंकित रूप (OCR) — नया गवाह नहीं; मेरी नक़ल की भूलें पकड़ने को
    C = चित्रशाला प्रेस (पुणे, 1931) का महाभारत, नीलकंठ की टीका सहित — OCR
    D = एक टंकित पाठ (संस्कृत-संग्रह), अध्याय ४१–४६ — किस छपी पुस्तक से टंकित है, यह वहाँ नहीं लिखा;
        अध्याय ४२ में इसके शब्द कई जगह अलग हैं, और टंकण की भूलें भी हैं
    B = समीक्षित संस्करण (पुणे), ५.४२–४५ — सिर्फ़ देखने को कि वहाँ क्या है

    python ss3.py            जहाँ V किसी से अलग है (हर अर्धश्लोक; A/C का OCR-शोर छानकर)
    python ss3.py ginti      सार
    python ss3.py a          सिर्फ़ V बनाम A (मेरी नक़ल की जाँच)
    python ss3.py 44         सिर्फ़ यह अध्याय
    python ss3.py sahara     V के वे अर्धश्लोक जिनमें कोई अक्षर ऐसा है जिसे न A सहारा देता है, न D
                             (दोनों उसी जगह V से अलग हैं) — इन्हीं को पन्ने पर दोबारा देखना ज़रूरी है

स्रोत-फ़ाइलें repo में नहीं हैं; जिस फ़ोल्डर में हों, वह `SS_SRC` में दीजिए (न दें तो यही फ़ोल्डर):
    ss_a.txt (A) · ss_c.txt (C का पूरा OCR) · ss_d.html (D) · ss_b.txt (B: MBh05.txt)
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
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402

DEV = re.compile('[ऀ-ॿ]')
SRC = os.environ.get('SS_SRC') or HERE
ANK = '०१२३४५६७८९'
ADHYAY = (42, 43, 44, 45, 46)

# OCR का शोर — पाठभेद नहीं (gm3.py वाली ही छलनी)
SHOR = {('ṃ', ''), ('', 'ṃ'), ('', 'ḥ'), ('ḥ', ''), ('r', ''), ('', 'r'), ('ṛ', ''), ('', 'a'), ('a', ''),
        ('c', 'n'), ('śc', 'śn'), ('śc', 'śl'), ('c', 'l'), ('ū', 'u'), ('u', 'ū'), ('ī', 'i'), ('i', 'ī'),
        ('ā', 'a'), ('a', 'ā'), ('y', ''), ('', 'y'), ('ṇ', 'n'), ('n', 'ṇ'), ('ṣ', 's'), ('s', 'ṣ'),
        ('ś', 's'), ('s', 'ś'), ('v', 'b'), ('b', 'v'), ('ai', 'e'), ('e', 'ai'), ('au', 'o'), ('o', 'au')}


def v_ardh(adhyay):
    """[(श्लोक-अंक, अर्धश्लोक)] — पाद-पाद छपे छंदों की पंक्तियाँ जोड़कर।"""
    raw = []
    for line in io.open(os.path.join(HERE, 'vss', 'vss_%d.txt' % adhyay), encoding='utf-8'):
        s = line.strip()
        if not s or s[0] in '#@':
            continue
        raw.append(s)
    out, buf = [], ''
    for s in raw:
        m = re.search(r'॥([०-९]+)॥$', s)
        poora = bool(m) or s.endswith('।')
        t = re.sub(r'\s*॥[०-९]+॥$', '', s).rstrip('।').strip()
        buf = (buf[:-1] + t) if buf.endswith('-') else (buf + ' ' + t).strip()
        if poora:
            out.append([int(''.join(str(ANK.index(c)) for c in m.group(1))) if m else None, buf])
            buf = ''
    assert not buf, buf
    nxt = None
    for r in reversed(out):
        if r[0] is None:
            r[0] = nxt
        else:
            nxt = r[0]
    return [tuple(r) for r in out]


def _nfc(naam):
    t = io.open(os.path.join(SRC, naam), encoding='utf-8', errors='replace').read()
    return unicodedata.normalize('NFC', t).replace('‌', '').replace('‍', '')


def _panktiyan(seg):
    seg = re.sub('(?<=[ऀ-ॿ])\\s*[:;]', 'ः', seg)
    seg = re.sub('(?<=[ऀ-ॿ])[5<]+(?=[ऀ-ॿ])', 'ऽ', seg)
    out = []
    for l in seg.split('\n'):
        l = l.strip()
        if len(DEV.findall(l)) >= 6:
            out.append(l)
    return out


def a_panktiyan():
    return _panktiyan(_nfc('ss_a.txt'))


def c_panktiyan():
    t = _nfc('ss_c.txt')
    a = t.find('सनत्सुजातं रहिते')
    b = t.find('समाप्तं सनत्सुजातपर्व', a)
    assert 0 < a < b, (a, b)
    return _panktiyan(t[a - 400:b])


def d_panktiyan():
    t = _nfc('ss_d.html').replace('‑', '')
    a = t.find('ततो राजा धृतराष्ट्रो मनीषी')
    assert a > 0
    t = re.sub(r'॥\s*[०-९]+-[०-९]+', ' ', t[a:])
    return _panktiyan(re.sub('<[^>]+>', '\n', t))


def b_panktiyan():
    out = []
    for l in _nfc('ss_b.txt').split('\n'):
        m = re.match(r'^0504[2-5]\d{3}[a-z]\s+(.*)$', l)
        if m:
            out.append(m.group(1).replace(';', ' '))
    return out


def paas(k, kunjiyan, jod=3):
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


def alag_jagah(k, cand):
    """V की कुंजी `k` की वे जगहें (अक्षर-क्रमांक) जहाँ `cand` अलग है। जोड़ (insert) हो तो दोनों पड़ोसी।"""
    out = set()
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, k, cand, autojunk=False).get_opcodes():
        if tag == 'equal':
            continue
        if i1 == i2:
            out.update((max(0, i1 - 1), min(len(k) - 1, i1)))
        else:
            out.update(range(i1, i2))
    return out


def darja(k, r, i, j, kunjiyan, ocr):
    """'=' हूबहू · '~' सिर्फ़ OCR का शोर · '≠' अलग · '—' नहीं मिली"""
    if r == 1.0:
        return '='
    if r < 0.62:
        return '—'
    if ocr and all(o in SHOR for o in fark(k, ''.join(kunjiyan[i:i + j]))):
        return '~'
    return '≠'


if __name__ == '__main__':
    args = sys.argv[1:]
    mode = next((x for x in args if not x.isdigit()), '')
    kaun = [int(x) for x in args if x.isdigit()] or list(ADHYAY)
    SROT = [('A', a_panktiyan(), True), ('C', c_panktiyan(), True), ('D', d_panktiyan(), False),
            ('B', b_panktiyan(), False)]
    KUNJI = {n: [kunji_dev(x) for x in L] for n, L, _ in SROT}
    g = {n: {'=': 0, '~': 0, '≠': 0, '—': 0} for n, _, _ in SROT}
    kul = 0
    for adhyay in kaun:
        for num, line in v_ardh(adhyay):
            kul += 1
            k = kunji_dev(line)
            if mode == 'sahara':
                jagah = {}
                for n in ('A', 'D'):
                    r, i, j = paas(k, KUNJI[n])
                    jagah[n] = (alag_jagah(k, ''.join(KUNJI[n][i:i + j])) if r >= 0.62 else set(range(len(k))),
                                ' '.join(dict((x[0], x[1]) for x in SROT)[n][i:i + j]) if i is not None else '')
                dono = jagah['A'][0] & jagah['D'][0]
                if dono:
                    g['A']['≠'] += 1
                    print('%d.%-3s V  %s\n       बिना सहारे: «%s»\n       A  %s\n       D  %s'
                          % (adhyay, num, line, ' · '.join(sorted(set(k[max(0, x - 2):x + 3] for x in dono))),
                             jagah['A'][1][:110], jagah['D'][1][:110]))
                continue
            nat = {}
            for n, L, ocr in SROT:
                r, i, j = paas(k, KUNJI[n])
                d = darja(k, r, i, j, KUNJI[n], ocr)
                g[n][d] += 1
                nat[n] = (d, ' '.join(L[i:i + j]) if i is not None else '', fark(k, ''.join(KUNJI[n][i:i + j])) if d == '≠' else '')
            if mode == 'ginti':
                continue
            if mode == 'a':
                if nat['A'][0] in '=~':
                    continue
            elif nat['A'][0] in '=~' and nat['C'][0] in '=~' and nat['D'][0] == '=':
                continue
            print('%d.%-3s V  %s' % (adhyay, num, line))
            for n, _, _ in SROT:
                if mode == 'a' and n != 'A':
                    continue
                d, text, f = nat[n]
                if d in '=~':
                    print('       %s %s' % (n, d))
                elif d == '≠':
                    print('       %s ≠ %s   %s' % (n, text[:120], f))
                else:
                    print('       %s —' % n)
    print('V के अर्धश्लोक %d (अध्याय %s)' % (kul, ', '.join(str(x) for x in kaun)))
    if mode == 'sahara':
        print('जिनमें कोई जगह न A से सधी, न D से: %d' % g['A']['≠'])
        raise SystemExit
    for n, L, _ in SROT:
        print('%s: पंक्तियाँ %d · हूबहू %d · सिर्फ़ OCR का शोर %d · अलग %d · नहीं मिली %d'
              % (n, len(L), g[n]['='], g[n]['~'], g[n]['≠'], g[n]['—']))
