# -*- coding: utf-8 -*-
"""अनुनासिक और नुक़्ते की जाँच: शब्द-दर-शब्द, पाँच छपे संस्करणों से।"""
import sys, io, json, re, difflib, collections
sys.stdout.reconfigure(encoding='utf-8')
from sk_padho import OCR, _lo, kunji
DEV = re.compile('[ऀ-ॏक़-य़॰-ॿ]+')
def shabd(line): return [w for w in DEV.findall(line.replace('-', ' ')) if kunji(w)]
def khidki(q, naam):
    lines, keys, idx = _lo(naam)
    qk = kunji(q); vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()): vote[n] = vote.get(n, 0) + 1
    if not vote: return []
    n = max(vote, key=vote.get)
    return [w for x in lines[max(0, n - 1):n + 2] for w in shabd(x)]
def nn(w): return w.replace('ँ', 'ं')
def hai(w): return ('ं' in w) or ('ँ' in w)
d = json.load(io.open('mool.json', encoding='utf-8'))
kam, zyada, nukta = [], [], []
for u in d['ikai']:
    for kism, lines in u['bhag']:
        for x in lines:
            ws = shabd(x)
            mat = collections.defaultdict(list)
            for o in OCR:
                es = khidki(x, o)
                wk = [kunji(w) for w in ws]; ek = [kunji(w) for w in es]
                sm = difflib.SequenceMatcher(None, wk, ek, autojunk=False)
                for tag, i1, i2, j1, j2 in sm.get_opcodes():
                    if tag == 'equal':
                        for t in range(i2 - i1): mat[i1 + t].append(es[j1 + t])
            for i, w in enumerate(ws):
                es = mat[i]
                if len(es) < 3: continue
                c = collections.Counter(nn(e) for e in es)
                top, cnt = c.most_common(1)[0]
                same = c.get(nn(w), 0)
                if top != nn(w) and cnt >= 2 and same == 0:
                    tn = top.replace('ं', ''); wn = nn(w).replace('ं', '')
                    if tn == wn:
                        (kam if top.count('ं') > nn(w).count('ं') else zyada).append((u['doha'], w, top, cnt, same, len(es), x))
                    elif tn.replace('़', '') == wn.replace('़', ''):
                        nukta.append((u['doha'], w, top, cnt, same, len(es), x))
print('== W में अनुनासिक कम (संस्करणों में है):', len(kam))
for r in kam: print('  %d | %s → %s (%d/%d, W जैसा %d) | %s' % (r[0], r[1], r[2], r[3], r[5], r[4], r[6]))
print('== W में अनुनासिक ज़्यादा:', len(zyada))
for r in zyada: print('  %d | %s → %s (%d/%d, W जैसा %d) | %s' % (r[0], r[1], r[2], r[3], r[5], r[4], r[6]))
print('== नुक़्ता:', len(nukta))
for r in nukta: print('  %d | %s → %s (%d/%d, W जैसा %d) | %s' % (r[0], r[1], r[2], r[3], r[5], r[4], r[6]))
