# -*- coding: utf-8 -*-
"""archive का पन्ना n → किताब का छपा पृष्ठ (page_numbers.json से)।  python -P prishth.py <किताब> <n> …"""
import io
import json
import os
import sys
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, JAD)
import khoj  # noqa: E402
SRC = khoj.SRC


def naksha(naam):
    p = os.path.join(SRC, naam + '_pn.json')
    if not os.path.exists(p):
        ia = khoj.kitabein()[naam]
        files = json.load(urllib.request.urlopen('https://archive.org/metadata/%s/files' % ia, timeout=120))['result']
        n = [f['name'] for f in files if f['name'].endswith('_page_numbers.json')]
        if not n:
            json.dump({}, io.open(p, 'w', encoding='utf-8'))
            return {}
        try:
            d = json.load(urllib.request.urlopen('https://archive.org/download/%s/%s' % (ia, urllib.parse.quote(n[0])), timeout=300))
        except Exception:
            return {}          # अगली बार फिर कोशिश — ख़ाली नक़्शा सहेजा नहीं
        json.dump(d, io.open(p, 'w', encoding='utf-8'), ensure_ascii=False)
    return json.load(io.open(p, encoding='utf-8'))


def prishth(naam, n):
    d = naksha(naam)
    pages = d.get('pages', [])
    # hOCR/searchtext का क्रम = pages का क्रम (0 से)
    if 0 <= n < len(pages):
        return pages[n].get('pageNumber') or ''
    return ''


if __name__ == '__main__':
    k = sys.argv[1]
    for n in sys.argv[2:]:
        print(k, n, '→', repr(prishth(k, int(n))))
