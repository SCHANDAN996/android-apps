# -*- coding: utf-8 -*-
"""archive.org में पुस्तक ढूँढना।  python ia_khoj.py "<query>" [कितने]"""
import json
import os
import sys
import urllib.parse

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
# `lao` (पन्ना उतारने वाला) सप्तशती के milan/ में है
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'saptashati', 'milan')))
import lao  # noqa: E402

q = sys.argv[1]
n = int(sys.argv[2]) if len(sys.argv) > 2 else 25
url = ('https://archive.org/advancedsearch.php?q=%s&fl[]=identifier&fl[]=title&fl[]=year&fl[]=language'
       '&fl[]=licenseurl&fl[]=downloads&rows=%d&output=json&sort[]=downloads+desc'
       % (urllib.parse.quote(q + ' AND mediatype:texts'), n))
d = json.loads(lao.curl(url).decode('utf-8'))
for x in d['response']['docs']:
    print(x.get('identifier'), '·', str(x.get('title'))[:90], '·', x.get('year'), '·', x.get('language'),
          '·', x.get('downloads'), '·', (x.get('licenseurl') or '')[-30:])
