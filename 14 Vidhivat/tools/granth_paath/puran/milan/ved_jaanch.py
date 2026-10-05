# -*- coding: utf-8 -*-
"""`ved_suchi.py` की हर गिनती डिजिटल पाठों में दोबारा गिनना; विष्णु ३.४ की पंक्तियाँ दो गवाहों में।

गवाह (इसी फ़ोल्डर में उतरे हुए — `pu_lao.py url …`):
  g_rv_auf.txt, g_rv.htm   ऋग्वेद के दो डिजिटल पाठ (निशान «RV_m,sss.vv») — एक ही टंकण-परिवार
  g_sv.txt                 सामवेद, कौथुम — चलती गिनती «.. N»
  g_av.htm                 अथर्ववेद, शौनक — निशान «AVŚ_k,s.v»
  g_vishnu.htm, ws_vishnu_3_4.txt   विष्णु पुराण ३.४ — समीक्षित e-पाठ और विकिस्रोत
  और जाल से (`jaal` लिखने पर): विकिस्रोत के पन्नों की सूची — ऋग्वेद के सूक्त, यजुर्वेद के अध्याय/काण्ड

    python ved_jaanch.py          सिर्फ़ उतरी हुई फ़ाइलों से
    python ved_jaanch.py jaal     साथ में विकिस्रोत की सूचियाँ भी
"""
import collections
import difflib
import html
import io
import json
import os
import re
import sys
import time
import urllib.parse

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev, kunji_iast  # noqa: E402
import ved_suchi as V  # noqa: E402

galti = []


def padho(naam):
    t = io.open(os.path.join(HERE, naam), encoding='utf-8', errors='replace').read()
    if naam.endswith('.htm'):
        t = html.unescape(re.sub(r'<[^>]+>', '', t))
    return t


def barabar(naam, mila, chahiye):
    ok = mila == chahiye
    print('%s %s: %s' % ('✓' if ok else '✗', naam, mila if ok else '%s ≠ तालिका %s' % (mila, chahiye)))
    if not ok:
        galti.append(naam)


# ── ऋग्वेद ──
for f in ('g_rv_auf.txt', 'g_rv.htm'):
    refs = re.findall(r'RV_(\d+),(\d+)\.(\d+)', padho(f))
    sukta = collections.defaultdict(set)
    mantra = collections.defaultdict(set)
    for m, s, v in refs:
        sukta[int(m)].add(int(s))
        mantra[int(m)].add((int(s), int(v)))
    barabar('ऋग्वेद %s — मण्डल-वार (सूक्त, मंत्र)' % f,
            [(m, len(sukta[m]), len(mantra[m])) for m in sorted(sukta)], V.RV_MANDAL)
    barabar('ऋग्वेद %s — ऐप वाले सूक्तों के मंत्र' % f,
            [(m, s, len([x for x in mantra[m] if x[0] == s])) for m, s, n in V.RV_APP], V.RV_APP)
assert sum(a for m, a, b in V.RV_MANDAL) == V.RV_SUKTA and sum(b for m, a, b in V.RV_MANDAL) == V.RV_MANTRA

# ── सामवेद ──
t = padho('g_sv.txt')
marks = [(m.start(), int(m.group(1))) for m in re.finditer(r'\.\.\s+(\d+)\b', t)]


def ant(pat):
    off = re.search(pat, t).start()
    return max(n for p, n in marks if p < off and n > 4)


chhand = ant(r'pūrvārcikaḥ \.\.')
aranya = ant(r'āraṇyaṃ parva kāṇḍam \.\.')
mahanamni = ant(r'iti mahānāmnyārcikaḥ')
kul = max(n for p, n in marks)
barabar('सामवेद — कुल (चलती गिनती का आख़िरी अंक)', kul, V.SV_KUL)
barabar('सामवेद — छन्द आर्चिक, आरण्य, महानाम्नी', (chhand, aranya - chhand, mahanamni - aranya), V.SV_TUKDE)
barabar('सामवेद — पूर्वार्चिक (तीनों मिलाकर), उत्तरार्चिक', (mahanamni, kul - mahanamni),
        (V.SV_PURVARCHIK, V.SV_UTTARARCHIK))

# ── अथर्ववेद ──
refs = re.findall(r'\(AVŚ_(\d+),(\d+)(?:\[(\d+)\])?\.(\d+)', padho('g_av.htm'))
rw = collections.defaultdict(set)
for k, s, b, v in refs:
    rw[int(k)].add(int(s))
barabar('अथर्ववेद — काण्ड', len(rw), V.AV_KAND)
barabar('अथर्ववेद — सूक्त (इस संस्करण की गिनती)', sum(len(x) for x in rw.values()), V.AV_SUKTA_EK_SANSKARAN)

# ── विष्णु ३.४ ──
vt = padho('g_vishnu.htm')
seg = vt[vt.find('ViP_3,3.31'):vt.find('ViP_3,4.16 ')]
vg = ''.join(kunji_iast(re.sub(r'/+\s*ViP_[^/]*//|/', ' ', l)) for l in seg.split('\n'))
wt = io.open(os.path.join(HERE, 'ws_vishnu_3_4.txt'), encoding='utf-8').read()
wl = [kunji_dev(re.sub(r'।।\s*[०-९]+\s*।।|।', '', l)) for l in wt.split('\n') if re.search('[\u0900-\u097f]', l)]
kam = []
for l in V.VISHNU_3_4:
    k = kunji_dev(l)
    if k not in vg:
        galti.append('विष्णु ३.४ «%s» समीक्षित पाठ में नहीं' % l)
    best = 0.0
    for w in wl:
        if len(w) >= len(k):
            sm = difflib.SequenceMatcher(None, k, w, autojunk=False)
            blk = sm.find_longest_match(0, len(k), 0, len(w))
            a = max(0, blk.b - blk.a)
            r = difflib.SequenceMatcher(None, k, w[a:a + len(k)], autojunk=False).ratio()
        else:
            r = difflib.SequenceMatcher(None, k, w, autojunk=False).ratio()
        best = max(best, r)
    if best < 0.8:
        kam.append((l, round(best, 2)))
print('%s विष्णु ३.४ — %d पंक्तियाँ समीक्षित पाठ में हूबहू; विकिस्रोत (टंकण-भूलों वाला) में 0.8 से कम पास: %s'
      % ('✓' if not kam else '✗', len(V.VISHNU_3_4), kam))
if kam:
    galti.append('विष्णु ३.४ विकिस्रोत')

# ── जाल: विकिस्रोत के पन्नों की सूचियाँ (अलग गवाह) ──
if len(sys.argv) > 1 and sys.argv[1] == 'jaal':
    # `lao` (पन्ना उतारने वाला) सप्तशती के milan/ में है
    sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'saptashati', 'milan')))
    import lao  # noqa: E402

    ANK = str.maketrans('०१२३४५६७८९', '0123456789')
    DEV = str.maketrans('0123456789', '०१२३४५६७८९')

    def sab(prefix):
        out, cont = [], {}
        while True:
            kw = dict(action='query', list='allpages', apprefix=prefix, aplimit=500, format='json')
            kw.update(cont)
            d = json.loads(lao.lao('https://sa.wikisource.org/w/api.php?' + urllib.parse.urlencode(kw)).decode('utf-8'))
            out += [r['title'] for r in d['query']['allpages']]
            if 'continue' not in d:
                return out
            cont = d['continue']
            time.sleep(1)

    mila = []
    for m in range(1, 11):
        nums = set()
        for x in sab('ऋग्वेदः सूक्तं %s.' % str(m).translate(DEV)):
            mm = re.match(r'^ऋग्वेदः सूक्तं [०-९]+\.([०-९]+)$', x)
            if mm:
                nums.add(int(mm.group(1).translate(ANK)))
        assert nums == set(range(1, max(nums) + 1)), m
        mila.append((m, len(nums)))
        time.sleep(1)
    barabar('ऋग्वेद — विकिस्रोत की सूची से मण्डल-वार सूक्त', mila, [(m, a) for m, a, b in V.RV_MANDAL])
    adh = set()
    for x in sab('शुक्लयजुर्वेदः/अध्यायः'):
        mm = re.match(r'^शुक्लयजुर्वेदः/अध्यायः ([०-९]{2})$', x)
        if mm:
            adh.add(int(mm.group(1).translate(ANK)))
    barabar('शुक्ल यजुर्वेद — विकिस्रोत की सूची से अध्याय', (len(adh), max(adh)), (V.YV_SHUKLA_ADHYAY, V.YV_SHUKLA_ADHYAY))
    k = collections.defaultdict(set)
    for x in sab('तैत्तिरीयसंहिता(विस्वरः)/काण्डम्'):
        mm = re.match(r'^तैत्तिरीयसंहिता\(विस्वरः\)/काण्डम् ([०-९]+)/प्रपाठकः ([०-९]+)', x)
        if mm:
            k[int(mm.group(1).translate(ANK))].add(int(mm.group(2).translate(ANK)))
    barabar('तैत्तिरीय संहिता — विकिस्रोत की सूची से (काण्ड, प्रपाठक)',
            (len(k), sum(len(v) for v in k.values())), (V.YV_TAITTIRIYA_KAND, V.YV_TAITTIRIYA_PRAPATHAK))
    ks = set()
    for x in sab('अथर्ववेदः/काण्डं'):
        mm = re.match(r'^अथर्ववेदः/काण्डं ([०-९]+)', x)
        if mm:
            ks.add(int(mm.group(1).translate(ANK)))
    barabar('अथर्ववेद — विकिस्रोत की सूची से काण्ड', len(ks), V.AV_KAND)

if galti:
    print('✗', galti)
    sys.exit(1)
print('✓ तालिका की हर गिनती पाठों में मिली')
