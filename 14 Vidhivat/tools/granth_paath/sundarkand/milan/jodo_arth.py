# -*- coding: utf-8 -*-
"""mool.json (→ sk_dhancha) + arth/NN.txt → paath/NN.txt

    python jodo_arth.py <जहाँ paath/ बनाना है>

`arth/NN.txt` की हर पंक्ति: `कुंजी = अर्थ`। कुंजी: `12.3` (दोहा १२ से पहले की
तीसरी चौपाई), `12d` (दोहा), `39da`/`39db` (दोहा क, ख), `3c1` (छंद), `s1` (श्लोक),
`samapan`। हर खंड का अर्थ होना चाहिए और कोई अर्थ फ़ालतू नहीं — वरना रुकता है।

⚠ यह **एक बार** चला था, `paath/` बनाने के लिए। अब अर्थ वहीं बदले जाते हैं —
`arth/` repo में नहीं है (एक ही बात दो जगह रखने से दोनों बहक जातीं)।
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
from sk_dhancha import banao  # noqa: E402

SAMAPAN = ['इति श्रीमद्रामचरितमानसे सकलकलिकलुषविध्वंसने',
           'पञ्चमः सोपानः समाप्तः।']


def arth_padho(path):
    out = {}
    for n, line in enumerate(io.open(path, encoding='utf-8').read().split('\n'), 1):
        if not line.strip():
            continue
        m = re.match(r'^(\S+) = (.+)$', line)
        assert m, (path, n, line[:40])
        assert m.group(1) not in out, (path, m.group(1))
        out[m.group(1)] = m.group(2).strip()
    return out


def main(dst):
    os.makedirs(os.path.join(dst, 'paath'), exist_ok=True)
    kul = 0
    for p in banao():
        arth = arth_padho(os.path.join('arth', p['key'] + '.txt'))
        khand = list(p['khand'])
        if p['key'] == '12':
            khand.append({'kunji': 'samapan', 'shirshak': 'समापन', 'mool': SAMAPAN})
        chahiye = [k['kunji'] for k in khand]
        assert sorted(chahiye) == sorted(arth), (p['key'], set(chahiye) ^ set(arth))
        blk = []
        for k in khand:
            a = arth[k['kunji']]
            assert not re.search('[A-Za-z0-9]', a), (k['kunji'], a)
            blk.append('# %s\n%s\n= %s' % (k['shirshak'], '\n'.join(k['mool']), a))
        with io.open(os.path.join(dst, 'paath', p['key'] + '.txt'), 'w',
                     encoding='utf-8', newline='\n') as f:
            f.write('\n\n'.join(blk) + '\n')
        kul += len(khand)
        print(p['key'], len(khand))
    print('✓ कुल', kul, 'खंड')


if __name__ == '__main__':
    main(sys.argv[1])
