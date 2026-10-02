# -*- coding: utf-8 -*-
"""विकिस्रोत (और कोई भी पन्ना) उतारने के छोटे औज़ार — सिर्फ़ मिलान के लिए।"""
import io
import json
import os
import subprocess
import sys
import time
import urllib.parse
import urllib.request

UA = 'VidhivatTextCheck/1.0 (personal offline app; text comparison)'
BROWSER = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                  '(KHTML, like Gecko) Chrome/126.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9,hi;q=0.8',
}


def lao(url, headers=None, tries=4, wait=2.0):
    last = None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers=headers or {'User-Agent': UA})
            return urllib.request.urlopen(req, timeout=90).read()
        except Exception as e:  # noqa
            last = e
            time.sleep(wait * (i + 1))
    raise last


def curl(url, browser=False):
    cmd = ['curl', '-sS', '--fail', '-L', '-m', '120']
    if browser:
        for k, v in BROWSER.items():
            cmd += ['-H', '%s: %s' % (k, v)]
    else:
        cmd += ['-A', UA]
    cmd.append(url)
    return subprocess.run(cmd, check=True, capture_output=True).stdout


def api(site, **kw):
    kw['format'] = 'json'
    url = 'https://%s/w/api.php?%s' % (site, urllib.parse.urlencode(kw))
    return json.loads(lao(url).decode('utf-8'))


def search(q, site='sa.wikisource.org', n=15):
    d = api(site, action='query', list='search', srsearch=q, srlimit=n)
    return [(r['title'], r['size']) for r in d['query']['search']]


def prefix(p, site='sa.wikisource.org', n=200):
    d = api(site, action='query', list='allpages', apprefix=p, aplimit=n)
    return [r['title'] for r in d['query']['allpages']]


def raw(title, site='sa.wikisource.org'):
    url = 'https://%s/w/index.php?title=%s&action=raw' % (site, urllib.parse.quote(title))
    return lao(url).decode('utf-8')


def bachao(path, text):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    mode = sys.argv[1]
    if mode == 's':
        for q in sys.argv[2:]:
            print('==', q)
            for t, s in search(q):
                print('   ', t, s)
            time.sleep(1)
    elif mode == 'p':
        for q in sys.argv[2:]:
            print('==', q)
            for t in prefix(q):
                print('   ', t)
            time.sleep(1)
    elif mode == 'r':
        t = raw(sys.argv[2])
        bachao(sys.argv[3], t)
        print(len(t))
