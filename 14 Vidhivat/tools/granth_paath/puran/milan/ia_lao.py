# -*- coding: utf-8 -*-
"""archive.org की किसी पुस्तक का OCR पाठ (_djvu.txt) उतारना। python ia_lao.py <id> [<id> …]"""
import json
import os
import sys
import time
import urllib.parse

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
# `lao` (पन्ना उतारने वाला) सप्तशती के milan/ में है
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'saptashati', 'milan')))
import lao  # noqa: E402

for ident in sys.argv[1:]:
    try:
        m = json.loads(lao.curl('https://archive.org/metadata/' + ident).decode('utf-8'))
    except Exception as e:  # noqa
        print('✗', ident, str(e)[:100])
        continue
    md = m.get('metadata', {})
    print('—', ident, '·', md.get('title'), '·', md.get('language'), '·', md.get('ocr'), '·', md.get('licenseurl'))
    for f in m.get('files', []):
        n = f['name']
        if n.endswith('_djvu.txt'):
            out = os.path.join(HERE, 'ia_' + ident[:40].replace('.', '_') + '.txt')
            if os.path.exists(out):
                print('    पहले से', os.path.getsize(out))
                continue
            try:
                data = lao.curl('https://archive.org/download/%s/%s' % (ident, urllib.parse.quote(n)))
                with open(out, 'wb') as g:
                    g.write(data)
                print('    ✓', n, len(data))
            except Exception as e:  # noqa
                print('    ✗', n, str(e)[:100])
            time.sleep(2)
    time.sleep(2)
