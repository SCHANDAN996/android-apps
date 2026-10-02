# -*- coding: utf-8 -*-
"""सप्तशती के 13 अध्याय: ऐप का पाठ (A) बनाम N, R, M — पंक्ति-दर-पंक्ति।

    python ss_milao.py            गिनती
    python ss_milao.py 05         एक अध्याय का पूरा ब्यौरा
"""
import io
import sys

sys.stdout.reconfigure(encoding='utf-8')
from ss_padho import ADHYAY, A_padho, M_padho, N_padho, R_padho, kunjiyan  # noqa: E402
from milan import jodo  # noqa: E402


def ek_adhyay(key, dikhao=False, out=None):
    A = A_padho(key)
    ak = kunjiyan([x for _, x in A])
    gav = {}
    for naam, lines, lipi in (('N', N_padho(key), 'dev'), ('R', R_padho(key), 'iast'),
                              ('M', M_padho(key), 'dev')):
        ks = kunjiyan(lines, lipi)
        rakho = [(k, l) for k, l in zip(ks, lines) if k]
        gav[naam] = ([k for k, _ in rakho], [l for _, l in rakho])
    jod = {n: jodo(ak, gav[n][0]) for n in gav}
    ginti = {'ek': 0, 'N akela': 0, 'A akela': 0, 'sab alag': 0, 'A=N, puran alag': 0}
    for i, (sh, line) in enumerate(A):
        if not ak[i]:
            continue
        n, r, m = (jod[x][i][0] if jod[x][i] else '' for x in ('N', 'R', 'M'))
        if ak[i] == n:
            if (r and r != ak[i]) and (m and m != ak[i]):
                ginti['A=N, puran alag'] += 1
            else:
                ginti['ek'] += 1
            continue
        if ak[i] in (r, m):
            kism = 'N akela'
        elif n and n in (r, m):
            kism = 'A akela'
        else:
            kism = 'sab alag'
        ginti[kism] += 1
        if out is not None and kism != 'N akela':
            s, e = jod['N'][i][1]
            rs, re_ = jod['R'][i][1]
            out.append('%s %s [%s]\n  A: %s\n  N: %s\n  R: %s\n  M: %s\n  kunji A=%s\n        N=%s\n        R=%s\n        M=%s\n'
                       % (key, sh, kism, line, ' ⏎ '.join(gav['N'][1][s:e]),
                          ' ⏎ '.join(gav['R'][1][rs:re_]),
                          ' ⏎ '.join(gav['M'][1][jod['M'][i][1][0]:jod['M'][i][1][1]]),
                          ak[i], n, r, m))
        elif out is not None and dikhao:
            s, e = jod['N'][i][1]
            out.append('%s %s [N akela]\n  A: %s\n  N: %s\n' % (key, sh, line, ' ⏎ '.join(gav['N'][1][s:e])))
    return ginti


if __name__ == '__main__':
    keys = sys.argv[1:] or ADHYAY
    out = []
    kul = {}
    for k in keys:
        g = ek_adhyay(k, dikhao=bool(sys.argv[1:]), out=out)
        print(k, g)
        for a, b in g.items():
            kul[a] = kul.get(a, 0) + b
    print('कुल', kul)
    with io.open('ss_fark.txt', 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out))
    print('ब्यौरा → ss_fark.txt (%d)' % len(out))
