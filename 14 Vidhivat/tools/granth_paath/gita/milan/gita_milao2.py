# -*- coding: utf-8 -*-
import io, sys, difflib
from collections import Counter
from gita_padho import S_padho, W_padho, G_padho, R_padho, kunji
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
GINTI = [47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 34, 27, 20, 24, 28, 78]

def ghatao13(d):
    """जिस स्रोत में 13वें अध्याय में 35 श्लोक हैं, उसका पहला अतिरिक्त है।"""
    if (13, 35) not in d:
        return d, None
    out, atirikt = {}, None
    for (a, v), t in d.items():
        if a == 13:
            if v == 1:
                atirikt = t
            else:
                out[(13, v - 1)] = t
        else:
            out[(a, v)] = t
    return out, atirikt

S, S_vikalp = S_padho()
S, S_at = ghatao13(S)
W, G, R = W_padho(), G_padho(), R_padho()
G, G_at = ghatao13(G)
# B = Besant (छपा संस्करण, 1922) — पाँचवाँ गवाह; उसमें भी 13वें में 35 हैं
import besant as _besant
B, _ = _besant.padho()
B, B_at = ghatao13(B)
keys = [(a, v) for a in range(1, 19) for v in range(1, GINTI[a - 1] + 1)]
sab = {'S': S, 'W': W, 'G': G, 'R': R, 'B': B}
kun = {n: {k: kunji(d[k], 'iast' if n == 'R' else 'dev') for k in keys} for n, d in sab.items()}

if __name__ == '__main__':
    print('S अतिरिक्त:', S_at); print('G अतिरिक्त:', G_at)
    c = Counter()
    for k in keys:
        grp = {}
        for n in 'SWGR':
            grp.setdefault(kun[n][k], []).append(n)
        sig = ' | '.join(sorted(''.join(v) for v in grp.values()))
        c[sig] += 1
        dev = {kun[n][k] for n in 'SWG'}
        if sig not in ('SWGRB', 'R | SWGB', 'G | SWRB', 'B | SWGR') and len(grp) > 2 or max(len(v) for v in grp.values()) < 4:
            print('\n==', k, sig)
            for n in 'SWG':
                print('  ', n, ' / '.join(sab[n][k]))
            print('  ', 'R', ' / '.join(R[k]))
            print('  ', 'B', ' / '.join(B[k]))
    print(c)
