# -*- coding: utf-8 -*-
"""मूल (mool_naye/) + अर्थ (arth_naye/) → tools/granth_paath/saptashati/paath/<कुंजी>.txt

    python jodo_arth.py kavach keelak pradhanik vaikritik murti kshama ratri_sukta devi_sukta

अर्थ की हर पंक्ति: "१. अर्थ" (श्लोक/मंत्र का अंक) या "विनियोग. अर्थ"।
गिनती न मिले तो रुक जाता है।
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
DST = os.path.join(REPO, 'tools', 'granth_paath', 'saptashati', 'paath')


def jodo(key):
    mool = io.open(os.path.join('mool_naye', key + '.txt'), encoding='utf-8').read().strip()
    arth = {}
    for n, line in enumerate(io.open(os.path.join('arth_naye', key + '.txt'), encoding='utf-8'), 1):
        line = line.strip()
        if not line:
            continue
        m = re.match(r'^([^.]+)\.\s+(.+)$', line)
        assert m, (key, n, line[:40])
        assert m.group(1) not in arth, (key, m.group(1))
        arth[m.group(1)] = m.group(2)
    out, lage = [], set()
    for blk in re.split(r'\n\s*\n', mool):
        lines = blk.split('\n')
        sh = lines[0][2:].strip()
        ank = sh.split(' ')[-1]
        k = sh if sh in arth else ank
        assert k in arth, (key, sh)
        assert not re.search(r'[A-Za-z0-9]', arth[k]), (key, sh, arth[k])
        lage.add(k)
        out.append('\n'.join(lines) + '\n= ' + arth[k])
    assert lage == set(arth), (key, sorted(set(arth) - lage))
    with io.open(os.path.join(DST, key + '.txt'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n\n'.join(out) + '\n')
    print('✓ %s — %d खंड' % (key, len(out)))


if __name__ == '__main__':
    for k in sys.argv[1:]:
        jodo(k)
