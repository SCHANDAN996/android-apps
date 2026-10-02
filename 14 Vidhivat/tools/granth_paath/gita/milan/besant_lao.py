import io, os, sys, time, json, re, html, urllib.parse, urllib.request
sys.stdout.reconfigure(encoding='utf-8')
def parse(title):
    url = 'https://en.wikisource.org/w/api.php?action=parse&format=json&prop=text&page=' + urllib.parse.quote(title)
    req = urllib.request.Request(url, headers={'User-Agent': 'VidhivatTextCheck/1.0 (personal offline app; text comparison)'})
    return json.loads(urllib.request.urlopen(req, timeout=90).read())['parse']['text']['*']
for n in range(1, 19):
    f = 'besant_%02d.txt' % n
    if os.path.exists(f) and os.path.getsize(f) > 5000:
        continue
    for koshish in range(4):
        try:
            h = parse('Bhagavad-Gita (Besant 4th)/Discourse %d' % n)
            break
        except Exception as e:
            print(n, 'ruko', e); time.sleep(25 * (koshish + 1))
    else:
        continue
    h = re.sub(r'(?s)<(script|style).*?</\1>', '', h)
    h = re.sub(r'(?s)<sup.*?</sup>', '', h)
    t = html.unescape(re.sub(r'(?s)<[^>]+>', '\n', h))
    t = re.sub(r'\n\s*\n+', '\n', t)
    io.open(f, 'w', encoding='utf-8').write(t)
    print(n, len(t))
    time.sleep(8)
