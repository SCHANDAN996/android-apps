# -*- coding: utf-8 -*-
"""चौपाइयों के समूह — छपे संस्करणों में जहाँ ॥१॥ ॥२॥ … लगा है वहीं समूह पूरा।
नतीजा: samooh.json  {दोहा: [समूह का आकार, …]}"""
import sys, io, json, re, difflib, collections
sys.stdout.reconfigure(encoding='utf-8')
from sk_padho import OCR, _lo, kunji
ANK = re.compile('[०-९0-9]')
def ant_ank(q2, naam):
    """q2 = पंक्ति का दूसरा आधा। उस OCR पंक्ति के अंत में अंक है? (None = मिला ही नहीं)"""
    lines, keys, idx = _lo(naam)
    qk = kunji(q2); vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()): vote[n] = vote.get(n, 0) + 1
    best = None
    for n, v in sorted(vote.items(), key=lambda x: -x[1])[:4]:
        k = keys[n]
        sm = difflib.SequenceMatcher(None, qk, k, autojunk=False)
        blocks = [b for b in sm.get_matching_blocks() if b.size]
        if not blocks: continue
        cov = sum(b.size for b in blocks) / len(qk)
        if cov < 0.8: continue
        if best is None or cov > best[0]: best = (cov, n)
    if best is None: return None
    x = lines[best[1]]
    # q2 के बाद का हिस्सा
    last = [m.end() for m in re.finditer('[ऀ-ॏ]', x)]
    # पंक्ति में q2 के आख़िरी शब्द के बाद
    w = re.findall('[ऀ-ॿ]+', q2.replace('॥', ' ').replace('।', ' '))[-1]
    p = x.rfind(w[:max(2, len(w) - 1)])
    tail = x[p + len(w):] if p >= 0 else x[-8:]
    return bool(ANK.search(tail[:12]))
d = json.load(io.open('mool.json', encoding='utf-8'))
out = {}
for u in d['ikai']:
    for kism, ls in u['bhag']:
        if kism != 'चौपाई': continue
        ends = []
        for x in ls:
            q2 = x.split('।')[1]
            v = [ant_ank(q2, o) for o in ('gp', 'gp2', 'gp3', 'm')]
            ha = sum(1 for t in v if t); na = sum(1 for t in v if t is False)
            ends.append((ha, na))
        size, cur = [], 0
        for i, (ha, na) in enumerate(ends):
            cur += 1
            if ha >= 2 or i == len(ends) - 1:
                size.append(cur); cur = 0
        out[u['doha']] = size
        flag = '' if all(1 <= s <= 3 for s in size) and (size.count(2) >= len(size) - 2) else '  <<<'
        print(u['doha'], len(ls), size, ''.join('%d' % h for h, n in ends), flag)
json.dump(out, io.open('samooh.json', 'w', encoding='utf-8'))
