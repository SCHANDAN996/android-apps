# -*- coding: utf-8 -*-
"""कोई पंक्ति छपी पुस्तकों के OCR में कैसी छपी है — आँख से देखने के लिए।"""
import sys, io, re, difflib
sys.stdout.reconfigure(encoding='utf-8')
from vs_padho import kd, nfc
OCR = {'gp34': 'ia_gp1934.txt', 'gph': 'ia_DuUQ_vishnu-.txt', 'gpg': 'ia_blgm-bhagava.txt',
       'nsp': 'ia_ybcm_gita-ga.txt', 'vnk': 'ia_djrD_vishnu-.txt'}
_C = {}
def lo(naam):
    if naam not in _C:
        t = nfc(io.open(OCR[naam], encoding='utf-8', errors='replace').read())
        lines = [x for x in t.split('\n') if re.search('[ऀ-ॿ]', x)]
        keys = [kd(x) for x in lines]
        idx = {}
        for n, k in enumerate(keys):
            for i in range(0, max(0, len(k) - 5)):
                idx.setdefault(k[i:i + 6], set()).add(n)
        _C[naam] = (lines, keys, idx)
    return _C[naam]
def dhundho(q, naam, kitne=1):
    lines, keys, idx = lo(naam)
    qk = kd(q); vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()): vote[n] = vote.get(n, 0) + 1
    out = []
    for n, v in sorted(vote.items(), key=lambda x: -x[1])[:kitne]:
        out.append((v / max(1, len(qk) - 5), ' / '.join(x.strip() for x in lines[max(0, n - 1):n + 2])))
    return out
if __name__ == '__main__':
    for q in sys.argv[1:]:
        print('##', q)
        for o in OCR:
            for r, t in dhundho(q, o, 2):
                if r > 0.25: print('   %-5s %.2f %s' % (o, r, t[:260]))
