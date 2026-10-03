# -*- coding: utf-8 -*-
"""S, N, G — आधे-श्लोक की हर पंक्ति पर तीनों की कुंजी मिलाना।"""
import sys, difflib
sys.stdout.reconfigure(encoding='utf-8')
from vs_padho import S_padho, N_padho, G_padho, kd, ki, HISSE
S, N, G = S_padho(), N_padho(), G_padho()
def farq(a, b):
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    return ' '.join('%s→%s' % (a[i1:i2] or '∅', b[j1:j2] or '∅') for tag, i1, i2, j1, j2 in sm.get_opcodes() if tag != 'equal')
kul = alag = 0
for h in HISSE:
    print('=====', h)
    for i, (s, n, g) in enumerate(zip(S[h], N[h], G[h])):
        kul += 1
        ks, kn, kg = [k.replace('ḥs', 'ss').replace('ḥś', 'śś') for k in (kd(s), kd(n), ki(g))]
        if ks == kn == kg: continue
        alag += 1
        base = 1 if h == 'purva' else 1
        print('%s %d%s' % (h, i // 2 + 1, 'ab'[i % 2]))
        print('   S', s); print('   N', n); print('   G', g)
        if ks != kn: print('      S≠N', farq(ks, kn))
        if ks != kg: print('      S≠G', farq(ks, kg))
print('कुल', kul, 'अलग', alag)
