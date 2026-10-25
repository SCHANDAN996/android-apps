# -*- coding: utf-8 -*-
"""विधियों के सब मंत्र-खाने → अलग-अलग मंत्र, गिनती, फ़ाइलें, भरोसा, स्रोत (→ D-139 #3)।"""
import glob
import io
import json
import os
import re
import sys
import unicodedata

sys.stdout.reconfigure(encoding='utf-8')
VIDHI = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'app', 'assets', 'vidhi')
OUT = os.environ.get('MANTRA_SRC') or __import__('tempfile').gettempdir()   # आज की गिनती — repo वाली suchi_24oct.json नहीं छूती


def saaf(s):
    s = unicodedata.normalize('NFC', s or '')
    return re.sub(r'\s+', ' ', s).strip()


mantra = {}
khaali = []
khane = 0
for path in sorted(glob.glob(os.path.join(VIDHI, '**', '*.json'), recursive=True)):
    naam = os.path.relpath(path, VIDHI).replace('\\', '/')
    if os.path.basename(path).startswith('_'):
        continue
    v = json.load(io.open(path, encoding='utf-8'))
    for i, c in enumerate(v.get('charan', [])):
        m = c.get('mantra')
        if m is None:
            continue
        khane += 1
        t = saaf(m.get('devanagari'))
        if not t:
            khaali.append((naam, i + 1, saaf(c.get('shirshak')), saaf(m.get('strot'))))
            continue
        e = mantra.setdefault(t, {'jagah': [], 'bharosa': set(), 'strot': set(), 'roman': saaf(m.get('roman'))})
        e['jagah'].append('%s#%d' % (naam, i + 1))
        e['bharosa'].add(m.get('bharosa'))
        e['strot'].add(saaf(m.get('strot')))

suchi = sorted(mantra.items(), key=lambda kv: -len(kv[1]['jagah']))
with io.open(os.path.join(OUT, 'suchi.txt'), 'w', encoding='utf-8') as f:
    f.write('खाने %d, भरे %d, ख़ाली %d, अलग मंत्र %d\n\n' % (
        khane, khane - len(khaali), len(khaali), len(mantra)))
    for n, (t, e) in enumerate(suchi, 1):
        f.write('M%02d [%d] %s\n' % (n, len(e['jagah']), '/'.join(sorted(b or '-' for b in e['bharosa']))))
        f.write('   %s\n' % t)
        for s in sorted(e['strot']):
            f.write('   स्रोत: %s\n' % s[:300])
        f.write('   जगह: %s\n\n' % ', '.join(e['jagah'][:6]))
    f.write('\n===== ख़ाली =====\n')
    for k in khaali:
        f.write('%s#%d  %s  —  %s\n' % k)
json.dump([{'id': 'M%02d' % n, 'paath': t, 'jagah': e['jagah'], 'bharosa': sorted(b or '-' for b in e['bharosa']),
            'strot': sorted(e['strot'])} for n, (t, e) in enumerate(suchi, 1)],
          io.open(os.path.join(OUT, 'suchi.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
print(khane, khane - len(khaali), len(khaali), len(mantra))
