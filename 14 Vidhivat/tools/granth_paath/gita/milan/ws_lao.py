# -*- coding: utf-8 -*-
import io, re, sys, time, urllib.parse, urllib.request
sys.stdout.reconfigure(encoding='utf-8')
idx = io.open('ws_index.txt', encoding='utf-8').read()
titles = re.findall(r'\[\[(भगवद्गीता/[^|\]]+)\|', idx)
print(len(titles))
for n, t in enumerate(titles, 1):
    url = 'https://sa.wikisource.org/w/index.php?title=' + urllib.parse.quote(t) + '&action=raw'
    req = urllib.request.Request(url, headers={'User-Agent': 'VidhivatTextCheck/1.0 (personal offline app; text comparison)'})
    data = urllib.request.urlopen(req, timeout=60).read()
    io.open('ws_%02d.txt' % n, 'wb').write(data)
    print(n, t, len(data))
    time.sleep(1)
