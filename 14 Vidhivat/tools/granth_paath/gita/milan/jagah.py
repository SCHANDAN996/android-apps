# -*- coding: utf-8 -*-
"""शब्दों के बीच की ख़ाली जगह — mool.txt बनाम S और G।"""
import io
import re
import sys

from gita_milao2 import S, G, keys
from gita_padho import UVACH

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
MOOL = r'C:\Users\Admin\Desktop\my project\MASS APP\14 Vidhivat\tools\granth_paath\gita\mool.txt'
M = {}
for blk in io.open('mool.txt', encoding='utf-8').read().strip().split('\n\n'):
    L = blk.split('\n')
    a, v = L[0][2:].split('.')
    M[(int(a), int(v))] = L[1:]


def shabd(lines):
    t = ' '.join(x for x in lines if not (UVACH.search(x) and len(x) < 40))
    t = re.sub(r'[।॥]', ' ', t).replace('ऽ', '')
    t = re.sub(r'-\s+', '', t)
    for a, b in (('ङ्', 'ं'), ('ञ्', 'ं'), ('ण्', 'ं'), ('न्', 'ं'), ('म्', 'ं')):
        t = t.replace(a, b)
    return t.split()


alag = []
for k in keys:
    m, s, g = shabd(M[k]), shabd(S[k]), shabd(G[k])
    if ''.join(m) != ''.join(s):
        continue                     # पाठ ही अलग — यहाँ जगह की तुलना बेमानी
    if m != s:
        alag.append((k, m, s, g))
print('जगह अलग (mool बनाम S):', len(alag))
for k, m, s, g in alag:
    ms, ss = set(m), set(s)
    print('%d.%d  mool: %s | S: %s | G-जैसा: %s' % (
        k[0], k[1], ' '.join(x for x in m if x not in ss), ' '.join(x for x in s if x not in ms),
        'S' if ''.join(g) == ''.join(s) and all(x in set(g) for x in s if x not in ms) else
        ('mool' if all(x in set(g) for x in m if x not in ss) else '?')))
