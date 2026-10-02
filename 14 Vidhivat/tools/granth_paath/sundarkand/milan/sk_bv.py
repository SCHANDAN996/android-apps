# -*- coding: utf-8 -*-
"""ब/व वाले शब्द: जहाँ चार या ज़्यादा छपे संस्करण दूसरा अक्षर पढ़ें।"""
import sys, io, json, re, difflib, collections
sys.stdout.reconfigure(encoding='utf-8')
from sk_padho import OCR, _lo, kunji
DEV = re.compile('[ऀ-ॏक़-य़॰-ॿ]+')
def shabd(line): return [w for w in DEV.findall(line.replace('-', ' ')) if kunji(w)]
def bv(k): return k.replace('v', 'b')
def khidki(q, naam):
    lines, keys, idx = _lo(naam)
    qk = kunji(q); vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()): vote[n] = vote.get(n, 0) + 1
    if not vote: return []
    n = max(vote, key=vote.get)
    return [w for x in lines[max(0, n - 1):n + 2] for w in shabd(x)]
d = json.load(io.open('mool.json', encoding='utf-8'))
for u in d['ikai']:
    for kism, lines in u['bhag']:
        for x in lines:
            ws = shabd(x)
            if not any(('ब' in w or 'व' in w) for w in ws): continue
            mat = collections.defaultdict(list)
            for o in OCR:
                es = khidki(x, o)
                wk = [bv(kunji(w)) for w in ws]; ek = [bv(kunji(w)) for w in es]
                sm = difflib.SequenceMatcher(None, wk, ek, autojunk=False)
                for tag, i1, i2, j1, j2 in sm.get_opcodes():
                    if tag == 'equal':
                        for t in range(i2 - i1): mat[i1 + t].append(es[j1 + t])
            for i, w in enumerate(ws):
                if 'ब' not in w and 'व' not in w: continue
                alag = [e for e in mat[i] if kunji(e) != kunji(w)]
                if len(alag) >= 4:
                    print(u['doha'], '|', w, '→', collections.Counter(alag).most_common(2), '|', x)
