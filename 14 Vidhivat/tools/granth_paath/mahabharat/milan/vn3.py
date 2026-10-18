# -*- coding: utf-8 -*-
"""विदुर नीति (महाभारत, उद्योगपर्व ३३–४०) — पाठ बनाना और जाँचना।

तरीक़ा (docs/30 §६.३): OCR पहले, आँख वहीं जहाँ फ़र्क़ हो; और दो नहीं, **तीन** पाठ।

    छपे हुए (OCR):
    G = गीताप्रेस की «विदुरनीति» पुस्तिका (हिंदी अनुवाद सहित) — **आधार**: पंक्तियाँ और श्लोक-अंक इसी के
    A = गीताप्रेस के महाभारत (उद्योगपर्व) का दूसरा, नया छपा रूप
    P = गीताप्रेस के पुराने छपे महाभारत (खंड ३) का scan
    C = चित्रशाला प्रेस (पुणे, 1931) का महाभारत, नीलकंठ की टीका सहित
    टंकित (हाथ से टाइप किए हुए — इनमें OCR वाली भूलें नहीं होतीं):
    D = संस्कृत-संग्रह का «विदुर नीति» (अंक समीक्षित संस्करण वाले; बीच में छपी पुस्तकों के श्लोक)
    B = समीक्षित संस्करण (पुणे) ५.३३–४०

## कसौटी — `khot()` = `jaanch()` + बनावट + छंद
OCR की भूलें दो तरह की हैं। बेतरतीब भूल दो अलग OCR में एक-सी नहीं होती; पर **चिह्न गिराना**
(अनुस्वार, विसर्ग, मात्रा की लंबाई, हलंत) और कुछ ख़ास उलट-फेर (ह्य → हा) हर OCR में एक जैसे होते हैं —
G, A, P तीनों में «हावमन्यन्ते» मिलना इस बात का सबूत नहीं कि पुस्तक में «ह्यवमन्यन्ते» नहीं है। इसलिए
«तीन गवाह» काफ़ी नहीं; हर अक्षर पर (उसके आस-पास के सात अक्षरों की खिड़की लेकर):

  क. छपे गवाहों का कोई गुट आपस में एक हो और हमसे अलग — गुट में G या A हो, या तीन हों — और वह हमारे
     साथ वाले छपे गवाहों से बड़ा हो: नहीं सधता, टंकित पाठ हमारे साथ हो तब भी।
     («तत्राधिगतः» G और टंकित में था; A, P, C में «तत्राभिगतः» — पन्ने पर «भि» ही निकला।)
  ख. कोई टंकित पाठ ठीक वही कहे, और कम से कम एक छपा पाठ उससे टकराए नहीं — सधा।
  ग. टंकित पाठ से फ़र्क़ सिर्फ़ चिह्न का हो और चिह्न उसमें ज़्यादा हो, या फ़र्क़ ह्य / हा का हो — कभी
     नहीं सधता; देखना ही पड़ेगा।
  घ. टंकित पाठ अलग कहे (या उसके पास पंक्ति ही न हो) — यह छपी परंपरा का अपना पाठ है; तब तीन छपे
     गवाह ठीक वही कहें, और उनमें P या C हो (G और A का OCR एक ही घराने का है)। फ़र्क़ एक-दो अक्षर
     का हो और कोई छपा गवाह टंकित के साथ खड़ा हो — नहीं सधता।

  + पंक्ति के सिरे पर छूटा शब्द (`kinare`) · अक्षरों की बनावट (`roop_bura`) · छंद के अक्षरों की गिनती
    (`chhand_bura` — गिरा हलंत यहीं पकड़ा जाता है) · अवग्रह · नासिक्य की लिखावट पुस्तिका जैसी (`shaili`)।

जो कुंजी में नहीं दिखता, वह इस कसौटी से भी नहीं दिखता: शब्दों के बीच की जगह, और «त्त्व / त्व»,
«च्छ / छ», «र्त्त / र्त» जैसी दोहरी लिखावट। ये पुस्तिका के OCR से जैसे आए, वैसे हैं।

    python vn3.py ginti              हर स्रोत में हर अध्याय की पंक्तियाँ
    python vn3.py banao 33           G की संस्कृत पंक्तियों से `vvn_33.txt` का मसौदा (stdout): जो पंक्ति
                                     कसौटी पर खरी, वह जस की तस; नहीं तो A की, या G-A के शब्द मिलाकर;
                                     फिर भी नहीं तो «#?» और सब गवाह — हाथ से तय करने को
    python vn3.py dikhao 33 [naya]   वही मसौदा, सिर्फ़ टिप्पणी वाली पंक्तियाँ, (श्लोक, पंक्ति) के साथ — इन्हीं
                                     कुंजियों से `vvn/hath_33.py` में हाथ के फ़ैसले लिखे जाते हैं
    python vn3.py likho 33 [naya]    मसौदा + `vvn/hath_33.py` → `vvn/vvn_33.txt`  (naya = मसौदा फिर से बनाओ)
    python vn3.py sahara [33]        `vvn/vvn_<अध्याय>.txt` की हर पंक्ति उसी कसौटी पर; + अक्षरों की बनावट,
                                     अवग्रह, श्लोक-अंकों का क्रम। जो पंक्ति कसौटी से नहीं सधती उस पर
                                     «# आँख: …» (पन्ना देखा) या «# तय: …» (गवाहों से, वजह के साथ) चाहिए

स्रोत-फ़ाइलें repo में नहीं हैं; जिस फ़ोल्डर में हों, वह `VN_SRC` में दीजिए (न दें तो यही फ़ोल्डर):
    vn_g.txt · vn_a.txt · vn_vocr.txt · vn_c.txt · vn_d.html · vn_b.txt
"""
import difflib
import importlib
import io
import itertools
import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402
from lipi import pancham  # noqa: E402

SRC = os.environ.get('VN_SRC') or HERE
VDIR = os.path.join(HERE, 'vvn')
ADHYAY = list(range(33, 41))
# पुस्तिका (G) में हर अध्याय के श्लोक
SHLOK = {33: 128, 34: 86, 35: 77, 36: 74, 37: 64, 38: 47, 39: 85, 40: 32}
# जिन अध्यायों में महाभारत वाले रूप (A) के श्लोक-अंक पुस्तिका जैसे ही हैं
A_GINTI_SAMAN = set(range(34, 41))
ANK = '०१२३४५६७८९'
DEV = re.compile('[ऀ-ॿ]')
AKSHAR = 'ऄ-हक़-ॡॐ'
ANT = re.compile(r'\s*[।|॥]+\s*([०-९]+(?:\s*[-–]+\s*[०-९]+)?)?[\s।|॥\.]*$')
# «धृतराष्ट्र उवाच» — और संधि से जुड़े «केशिन्युवाच», «सुधन्वोवाच» भी
VAKTA = re.compile(r'^(\S+(?:\s\S+)?\s*(?:उवाच|ऊचुः)|\S+(?:युवाच|ोवाच))\s*।?$')
SWAR = re.compile('ai|au|[aāiīuūṛṝḷeo]')


def akshar(text):
    """पंक्ति के अक्षर (syllable) — शब्द-दर-शब्द गिनकर; पूरी पंक्ति की जुड़ी कुंजी में «श्रेष्ठ इति»
    का a + i एक «ai» बनकर एक गिना जाता।"""
    return sum(len(SWAR.findall(kunji_dev(w))) for w in text.split())
# एक सधा हुआ अक्षर: (व्यंजन + हलंत)* व्यंजन [मात्रा] [अनुस्वार] [विसर्ग] | स्वर … | अवग्रह | शब्द के अंत का हलंत
# (या ऋ से पहले का — «निर्ऋतिं»)
ROOP = re.compile('^(?:(?:[क-ह]्)*[क-ह][ा-ौ]?[ंँ]?ः?|[अ-औॠ][ंँ]?ः?|ऽ|[क-ह]्(?= |-|$|ऋ)| |-$)+$')
OCR = ('G', 'A', 'P', 'C')
TANKIT = ('D', 'B')
SAB = OCR + TANKIT


def dev2int(s):
    return int(''.join(str(ANK.index(c)) for c in s))


def int2dev(n):
    return ''.join(ANK[int(c)] for c in str(n))


def nfc(naam):
    t = io.open(os.path.join(SRC, naam), encoding='utf-8', errors='replace').read()
    return unicodedata.normalize('NFC', t).replace('‌', '').replace('‍', '').replace('‑', '')


def saaf(l):
    """OCR के जाने-पहचाने निशान: विसर्ग की जगह «:», अवग्रह की जगह «5»/«<», भटके स्वर-चिह्न।"""
    l = re.sub('(?<=[ऀ-ॿ])\\s*[:;]', 'ः', l)
    l = re.sub('(?<=[ऀ-ॿ])\\s*[5<]+\\s*(?=[ऀ-ॿ])', 'ऽ', l)
    l = re.sub('[॒॑_~\\*`\'"]', '', l)
    return re.sub('\\s+', ' ', l).strip()


def kato(l):
    """गवाह की पंक्ति: (पाठ, श्लोक-अंक या '', अंत: '॥' | '।' | '')"""
    l = re.sub('^[^%s]+' % AKSHAR, '', l.strip())
    m = ANT.search(l)
    if not m:
        return saaf(l), '', ''
    text = saaf(ANT.sub('', l))
    poonch = l[m.start():]
    if m.group(1):
        return text, re.sub('\\s', '', m.group(1)), '॥'
    return text, '', ('॥' if '॥' in poonch else '।')


def g_kato(l):
    """आधार की पंक्ति — पहले दंड पर कटती है, उसके आगे का सब (अंक, OCR का कचरा) पूँछ है।
    (पाठ, पूँछ में मिले अंक की डोरी, पूँछ में दोहरा दंड?, पूँछ है?)"""
    l = re.sub('^[^%s]+' % AKSHAR, '', l.strip())
    m = re.search('[।॥|]', l)
    text, poonch = (l[:m.start()], l[m.start():]) if m else (l, '')
    text = saaf(text)
    text = re.sub('[०-९]|[^ऀ-ॿ \\-]', '', text)
    text = re.sub(' *- +', ' ', text)
    text = re.sub(' +', ' ', text).strip()
    ank = ''.join(re.findall('[०-९]+', poonch))
    return text, ank, '॥' in poonch, bool(poonch)


# ───────────────────────── स्रोत ─────────────────────────
def _colophon_se(t, shuru, ant):
    a = t.find(shuru)
    b = t.find(ant, a + 1000) if ant else len(t)
    assert 0 <= a < b, (shuru, a, b)
    out, cur, n = {}, [], 0
    samapan = 0         # समापन-वाक्य कई पंक्तियों में टूटा होता है — «…ऽध्यायः ॥ ३३ ॥» तक की पंक्तियाँ उसी की हैं
    for l in t[a:b].split('\n'):
        l = l.strip()
        if not l or 'Digitized by' in l:
            continue
        if l.startswith('इति श्री') and n < len(ADHYAY):
            out[ADHYAY[n]] = cur
            cur, n = [], n + 1
            samapan = 0 if 'ध्यायः' in l else 3
            continue
        if samapan:
            samapan = 0 if 'ध्यायः' in l else samapan - 1
            continue
        cur.append(l)
    assert n == len(ADHYAY), (shuru, n)
    return out


def g_tukde():
    t = nfc('vn_g.txt')
    a = t.find('हिन्दी-अनुवादसहित')
    return _colophon_se(t[a:], 'पहला अध्याय', None)


def a_tukde():
    return _colophon_se(nfc('vn_a.txt'), '(प्रजागरपर्व)', '(सनत्सुजातपर्व)')


def d_padho():
    """{अध्याय: [('v', वक्ता) | ('s', पंक्ति)]}"""
    t = nfc('vn_d.html')
    a = t.find('द्वाःस्थं प्राह')
    a = t.rfind('\n', 0, t.rfind('उवाच', 0, a))
    out, adhyay = {33: []}, 33
    for l in re.sub('<[^>]+>', '\n', t[a:]).split('\n'):
        l = l.strip()
        if not l or not DEV.search(l):
            continue
        if 'Text title' in l:
            break
        m = re.search(r'अध्यायः\s*([०-९]+)\s*$', l) or re.match(r'^५\.([०-९]+)', l)
        if m and not l.startswith('इति') and len(l) < 40:
            n = dev2int(m.group(1))
            if 33 <= n <= 40:
                adhyay = n
                out.setdefault(n, [])
            continue
        if l.startswith('इति ') or l.startswith('॥ श्रीः') or 'उद्योगपर्व - अध्याय' in l:
            continue
        if VAKTA.match(l):
            out[adhyay].append(('v', l.rstrip('।').strip()))
            continue
        text = re.sub(r'\s*॥\s*(?:[०-९]+-)?[०-९]*\s*[॥\-]*\s*$', '', l).rstrip('।॥- ').strip()
        if len(DEV.findall(text)) >= 4:
            out[adhyay].append(('s', text))
    return out


def tukda(naam, shuru, ant, pehle=0):
    t = nfc(naam)
    a = t.find(shuru, pehle)
    b = t.find(ant, a + 50000)
    assert 0 <= a < b, (naam, a, b)
    return [l.strip() for l in t[a:b].split('\n') if len(DEV.findall(l)) >= 6]


def b_padho():
    out = defaultdict(list)
    for l in nfc('vn_b.txt').split('\n'):
        m = re.match(r'^050(3[3-9]|40)\d{3}[a-z]\s+(.*)$', l)
        if m:
            for x in m.group(2).split(';'):
                out[int(m.group(1))].append(x.strip())
    return out


class Kosh:
    """पंक्तियों का ढेर, जिसमें किसी कुंजी के सबसे पास वाली पंक्ति (या दो सटी पंक्तियाँ) जल्दी मिल जाए।"""

    def __init__(self, lines, katne=kato):
        self.t = [katne(x)[0] for x in lines]
        self.n = [katne(x)[1] for x in lines]     # पंक्ति के अंत का श्लोक-अंक (हो तो)
        self.k = [kunji_dev(x) for x in self.t]
        self._jod = {}
        self.idx = defaultdict(set)
        for i, k in enumerate(self.k):
            for j in range(len(k) - 2):
                self.idx[k[j:j + 3]].add(i)

    def paas(self, k, jod=2):
        cnt = Counter()
        for j in range(len(k) - 2):
            for i in self.idx.get(k[j:j + 3], ()):
                cnt[i] += 1
        best = (0.0, None, 1)
        dekhe = set()
        for i, _ in cnt.most_common(8):
            for s in (i - 1, i):
                for jd in range(1, jod + 1):
                    if s < 0 or s + jd > len(self.k) or not (s <= i < s + jd) or (s, jd) in dekhe:
                        continue
                    dekhe.add((s, jd))
                    cand = self.kunji(s, jd)
                    if abs(len(cand) - len(k)) > max(10, len(k) // 3):
                        continue
                    r = 1.0 if cand == k else difflib.SequenceMatcher(None, k, cand, autojunk=False).ratio()
                    if r > best[0]:
                        best = (r, s, jd)
        return best

    def path(self, s, jd):
        """दो सटी पंक्तियाँ जोड़कर; पहली «-» पर ख़त्म हो तो शब्द जुड़ा हुआ है।"""
        out = ''
        for x in self.t[s:s + jd]:
            out = (out[:-1] + x) if out.endswith('-') else (out + ' ' + x).strip()
        return out

    def kunji(self, s, jd):
        """कुंजी जुड़े हुए *पाठ* की — दो कुंजियाँ जोड़ने से शब्द की सीमा पर झूठा फ़र्क़ आता है।"""
        if jd == 1:
            return self.k[s]
        if (s, jd) not in self._jod:
            self._jod[(s, jd)] = kunji_dev(self.path(s, jd))
        return self._jod[(s, jd)]


_KOSH = {}


def kosh(adhyay):
    """{नाम: Kosh} — छहों गवाह।"""
    if 'saajha' not in _KOSH:
        _KOSH['saajha'] = {
            'P': Kosh(tukda('vn_vocr.txt', 'प्रजागरप', 'सनत्सुजात', 300000)),
            'C': Kosh(tukda('vn_c.txt', 'प्रजागरप', 'सनत्सुजातं रहिते', 500000)),
        }
        _KOSH['G'], _KOSH['A'], _KOSH['D'], _KOSH['B'] = g_tukde(), a_tukde(), d_padho(), b_padho()
    if adhyay not in _KOSH:
        d = dict(_KOSH['saajha'])
        d['G'] = Kosh(_KOSH['G'][adhyay], katne=g_kato)
        d['A'] = Kosh(_KOSH['A'][adhyay])
        d['D'] = Kosh([x[1] for x in _KOSH['D'][adhyay] if x[0] == 's'])
        d['B'] = Kosh(_KOSH['B'][adhyay])
        _KOSH[adhyay] = d
    return _KOSH[adhyay]


def gawah(k, K):
    """हर गवाह की सबसे पास वाली पंक्ति: {नाम: (समानता, पाठ, कुंजी, कितनी पंक्तियाँ जुड़ीं)}; न मिले तो पाठ ''।"""
    out = {}
    for n in SAB:
        r, s, jd = K[n].paas(k)
        out[n] = (r, K[n].path(s, jd), K[n].kunji(s, jd), jd) if r >= 0.62 else (r, '', '', 0)
    return out


# ───────────────────────── कसौटी ─────────────────────────
_CHHOTA = str.maketrans('āīūṝ', 'aiuṛ')
KHIDKI = 3          # किसी अक्षर के दोनों ओर इतने अक्षर — कुल सात की खिड़की


def halka(s):
    """चिह्न हटाकर — अनुस्वार, विसर्ग, मात्रा की लंबाई।"""
    return s.replace('ṃ', '').replace('ḥ', '').translate(_CHHOTA)


def dheela(s):
    """`halka` + वे उलट-फेर जो हर OCR एक-सा करता है («ह्य» को «हा» पढ़ना)। सिर्फ़ वहाँ बरता जाता है
    जहाँ टंकित पाठ पहले ही हमारे साथ हो और बस यह देखना हो कि छपा पाठ उससे टकराता तो नहीं।
    → (ढीली डोरी, [मूल की हर जगह ढीली डोरी में कहाँ पड़ती है] — लंबाई + 1)"""
    out, jagah = [], []
    for i, c in enumerate(s):
        jagah.append(len(out))
        # «ह्य» का य — पर «थ्य», «ध्य» … का नहीं (उनकी कुंजी में भी h के बाद y आता है)
        if c in 'ṃḥ' or (c == 'y' and i and s[i - 1] == 'h' and (i < 2 or s[i - 2] not in 'kgcjṭḍtdpb')):
            continue
        out.append(c.translate(_CHHOTA))
    jagah.append(len(out))
    return ''.join(out), jagah


def bhaar(s):
    return sum(s.count(c) for c in 'ṃḥāīūṝ')


def fark(k, wk):
    """{जगह: (क़िस्म, गवाह का उस जगह का टुकड़ा)} — `k` की वे जगहें जहाँ गवाह `wk` अलग है।
    'kam'    = फ़र्क़ सिर्फ़ चिह्न का (अनुस्वार, विसर्ग, दीर्घ) या ह्य / हा का — जिसे OCR नहीं सुलझा सकता
    'zyada'  = फ़र्क़ सिर्फ़ चिह्न का, और चिह्न हमारी पंक्ति में ज़्यादा (गवाह OCR हो तो यह उसका गिराया चिह्न है;
               टंकित हो तो छपे गवाह तय करेंगे — OCR अपनी ओर से चिह्न नहीं जोड़ता)
    'chhota' = एक-दो अक्षर का फ़र्क़ (क्रु / कु, प्राज्ञो / प्राप्तो)
    'bada'   = तीन या ज़्यादा अक्षर — दूसरा शब्द"""
    out = {}
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, k, wk, autojunk=False).get_opcodes():
        if tag == 'equal':
            continue
        a, b = k[i1:i2], wk[j1:j2]
        # दो अक्षर बाईं ओर के साथ में — «ह्य» का «ह» फ़र्क़ के बाहर रहता है (और «थ्य» का «थ» पहचानने को)
        ca, cb = k[max(0, i1 - 2):i2], wk[max(0, j1 - 2):j2]
        if dheela(ca)[0] == dheela(cb)[0]:
            kism = 'zyada' if (halka(a) == halka(b) and bhaar(a) > bhaar(b)) else 'kam'
        else:
            kism = 'chhota' if max(len(a), len(b)) <= 2 else 'bada'
        tukda = wk[max(0, j1 - KHIDKI):j2 + KHIDKI]
        for x in (range(i1, i2) if i2 > i1 else (max(0, i1 - 1), min(len(k) - 1, i1))):
            if x not in out or out[x][0] != 'bada':
                out[x] = (kism, tukda)
    # छोटा फ़र्क़ किसी बड़े फ़र्क़ से सटा हो तो वह उसी दूसरे शब्द का हिस्सा है
    bade = [x for x in out if out[x][0] == 'bada']
    for x in out:
        if out[x][0] != 'bada' and any(abs(x - y) <= 3 for y in bade):
            out[x] = ('bada', out[x][1])
    return out


def kinare(k, wk, pehle, baad):
    """गवाह की पंक्ति में हमारी पंक्ति से पहले / बाद कुछ ऐसा है जो हमारी पड़ोसी पंक्तियों में नहीं? → (शुरू में, अंत में)
    (पंक्ति के सिरे का छूटा शब्द — «एकः पापानि…» का «एकः» — खिड़की से नहीं पकड़ा जाता।)"""
    ops = difflib.SequenceMatcher(None, k, wk, autojunk=False).get_opcodes()

    def samjha(e, pados):
        return bool(pados) and difflib.SequenceMatcher(None, e, pados, autojunk=False).ratio() >= 0.6

    shuru = ant = False
    tag, i1, i2, j1, j2 = ops[0]
    if tag == 'insert' and i1 == 0:
        shuru = not samjha(wk[j1:j2], pehle[-(j2 - j1):])
    tag, i1, i2, j1, j2 = ops[-1]
    if tag == 'insert' and i1 == len(k):
        ant = not samjha(wk[j1:j2], baad[:j2 - j1])
    return shuru, ant


def jaanch(k, g, pehle='', baad=''):
    """{जगह: वजह} — `k` के वे अक्षर जो कसौटी (ऊपर, docstring) पर नहीं सधते।
    `pehle`, `baad` — हमारी अगल-बगल की पंक्तियों की कुंजियाँ (गवाह पंक्ति कहीं और तोड़े तो)।"""
    n = len(k)
    hai_g = [m for m in g if g[m][1]]
    dk = {m: dheela(g[m][2])[0] for m in hai_g}
    apna, jagah = dheela(k)
    f = {m: fark(k, g[m][2]) for m in hai_g}
    kin = {m: kinare(k, g[m][2], pehle, baad) for m in hai_g}

    def hai(m, x, w, dheele=False):
        """गवाह `m` में जगह `x` के आस-पास के सात अक्षर जस के तस हैं? (dheele: चिह्नों को छोड़कर)
        अक्षर-दर-अक्षर मिलान धोखा देता है — «अजाततशत्रोः» का फ़ालतू «त» हर गवाह में अलग जगह गिना
        जाता है, और ग़लत पंक्ति से जुड़ा गवाह संयोग से «हाँ» कह देता है — इसलिए खिड़की।"""
        if m not in kin or (x - KHIDKI <= 0 and kin[m][0]) or (x + KHIDKI + 1 >= n and kin[m][1]):
            return False
        if dheele:
            return apna[jagah[max(0, x - KHIDKI)]:jagah[min(n, x + KHIDKI + 1)]] in dk[m]
        return w in g[m][2]

    out = {}
    for x in range(n):
        w = k[max(0, x - KHIDKI):x + KHIDKI + 1]
        # (क) दो छपे गवाह आपस में एक, और हमसे अलग — टंकित हमारे साथ हो तब भी देखना होगा
        #     («तत्राधिगतः» G में और टंकित में; बाक़ी तीन छपे «तत्राभिगतः» — ध/भ की भूल G के OCR की भी हो सकती है)
        #     P और C का OCR एक-सी भूलें करता है (रेफ गिराना, ै → े) — इसलिए उलटे गुट में G या A हो, या तीन हों;
        #     और वह गुट हमारे साथ वाले छपे गवाहों से बड़ा हो।
        ulte = ()
        for m in OCR:
            if m in f and x in f[m] and f[m][x][0] in ('chhota', 'bada') and len(f[m][x][1]) >= 5:
                gut = [m] + [m2 for m2 in OCR if m2 != m and m2 in hai_g and f[m][x][1] in g[m2][2]]
                if len(gut) > len(ulte):
                    ulte = gut
        saath = [m for m in OCR if hai(m, x, w)]
        if len(ulte) >= 2 and (len(ulte) >= 3 or {'G', 'A'} & set(ulte)) and len(ulte) > len(saath):
            out[x] = 'छपे गवाह %s आपस में एक, हमसे अलग' % ''.join(ulte)
            continue
        if any(hai(m, x, w) for m in TANKIT):
            if not any(hai(m, x, w, True) for m in OCR):
                out[x] = 'टंकित का रूप; छपे किसी पाठ में नहीं'
            continue
        tf = [f[m][x] for m in TANKIT if m in f and x in f[m]]
        if any(q[0] == 'kam' for q in tf):
            out[x] = 'टंकित में चिह्न ज़्यादा (या ह्य / हा)'
            continue
        pakke = [m for m in OCR if hai(m, x, w)]
        chhote = [q[1] for q in tf if q[0] in ('chhota', 'zyada')]
        tankit_ke_saath = [m for m in OCR if m in hai_g and any(len(q) >= 5 and q in g[m][2] for q in chhote)]
        if tankit_ke_saath:
            out[x] = 'टंकित से एक-दो अक्षर का फ़र्क़, और छपा %s टंकित के साथ' % ''.join(tankit_ke_saath)
        elif len(pakke) < 3 or not ({'P', 'C'} & set(pakke)):
            out[x] = 'टंकित अलग; तीन छपे गवाह नहीं (%s)' % (''.join(pakke) or '—')
    return out


def chhand_bura(text, g):
    """पंक्ति में अक्षर (syllable) उतने नहीं जितने चाहिए? हलंत गिरने से एक अक्षर बढ़ जाता है, और तीन OCR
    एक-सी भूल करें («षड जीवलोकस्य») तो खिड़की वाली कसौटी उसे नहीं पकड़ती। ठीक तब, जब गिनती किसी
    टंकित पाठ की उसी पंक्ति जितनी हो, या 16 (अनुष्टुप् का आधा श्लोक) / 11 (त्रिष्टुप् का पाद) हो।"""
    n = akshar(text)
    tankit = [akshar(g[m][1]) for m in TANKIT if g[m][1] and g[m][0] >= 0.8 and g[m][3] == 1]
    if n in tankit or n in (11, 16):
        return ''
    return 'अक्षर %d%s' % (n, (' (टंकित में %s)' % '/'.join(str(x) for x in sorted(set(tankit)))) if tankit else '')


_NASIKYA = re.compile('[ंँ]|[ङञणनम]्(?=[क-म])|म्$')


def shaili(text, gtext):
    """नासिक्य की लिखावट (सञ्जय / संजय, माम् / मां) कुंजी में नहीं दिखती। जहाँ हमारा शब्द और पुस्तिका (G)
    का शब्द कुंजी में एक हैं पर लिखावट में अलग — [(हमारा, G का)]।"""
    wv, wg = text.split(), gtext.split()
    if len(wv) != len(wg):
        wv, wg = [text], [gtext]
    return [(a, b) for a, b in zip(wv, wg)
            if kunji_dev(a) == kunji_dev(b) and _NASIKYA.findall(a) != _NASIKYA.findall(b)]


def g_shaili(wa, wg):
    """A का शब्द लेते समय: पुस्तिका के (बिगड़े पढ़े गए) शब्द में पंचम वर्ण दिखे तो वही लिखावट।"""
    if re.search('[ङञणनम]्[क-म]', wg) and re.search('ं[क-म]', wa):
        return pancham(wa)
    return wa


def tukde_dikhao(k, bure):
    """{वजह: [कुंजी के टुकड़े]} → एक पंक्ति।"""
    d = defaultdict(set)
    for x, v in bure.items():
        d[v].add(k[max(0, x - 3):x + 4])
    return ' ┃ '.join('%s: %s' % (v, ' · '.join(sorted(s))) for v, s in d.items())


def roop_bura(text):
    """अक्षरों की बनावट में खोट (दोहरा हलंत, अकेली मात्रा, पराया चिह्न …) हो तो बताओ।"""
    if ROOP.match(text):
        return ''
    for w in text.split(' '):
        if not ROOP.match(w):
            return w
    return text


def avagraha(text):
    """अवग्रह के आस-पास की कुंजी — {'…पहले|बाद…'}"""
    out = set()
    for m in re.finditer('ऽ', text):
        a, b = kunji_dev(text[:m.start()]), kunji_dev(text[m.end():])
        out.add(a[-4:] + '|' + b[:3])
    return out


def avagraha_fark(text, g):
    """(हमारे में है पर किसी गवाह में नहीं, टंकित में है पर हमारे में नहीं)"""
    apne = avagraha(text)
    sab = set().union(*[avagraha(g[n][1]) for n in g if g[n][1]]) if any(g[n][1] for n in g) else set()
    tankit = set().union(*[avagraha(g[n][1]) for n in TANKIT if g[n][1]])
    k = kunji_dev(text)
    chhoote = set(x for x in tankit - apne if x.replace('|', '') in k)
    return apne - sab, chhoote


def khot(text, g, pehle='', baad=''):
    """पंक्ति की सारी खोट एक जगह — (कसौटी {जगह: वजह}, अक्षरों की बनावट, छंद की गिनती); तीनों ख़ाली = खरी।"""
    k = kunji_dev(text)
    return jaanch(k, g, pehle, baad), roop_bura(text), chhand_bura(text, g)


# ───────────────────────── banao ─────────────────────────
def _milao(wg, wa, g, ant_hyphen, pehle, baad):
    """G और A के शब्द मिलाकर ऐसी पंक्ति जो कसौटी पर खरी उतरे (G के शब्द जितने ज़्यादा, उतना अच्छा)।"""
    alag = [i for i in range(len(wg)) if kunji_dev(wg[i]) != kunji_dev(wa[i])]
    if not alag or len(alag) > 6:
        return None
    for kitne in range(1, len(alag) + 1):
        for chune in itertools.combinations(alag, kitne):
            w = [g_shaili(wa[i].rstrip('-'), wg[i]) if i in chune else wg[i] for i in range(len(wg))]
            cand = ' '.join(w)
            if ant_hyphen and not cand.endswith('-'):
                cand += '-'
            if not any(khot(cand, g, pehle, baad)):
                return cand
    return None


HINDI = {'है', 'हैं', 'के', 'की', 'में', 'और', 'से', 'भी', 'ने', 'नहीं', 'था', 'थे', 'यह', 'वह', 'जो', 'लिये', 'करते', 'करता',
         'सकता', 'सकते', 'जाता', 'जाते', 'होता', 'होते', 'उसका', 'उसके', 'उनके', 'जिसके', 'जिसका',
         'अपनी', 'अपने', 'अपना'}


def hindi_shabd(text):
    """पंक्ति हिंदी की लगती है? — हिंदी का कोई अलग शब्द (कि / का / को नहीं गिने: संस्कृत में भी आते हैं, और OCR
    «किं» को «कि» पढ़ता है); या शब्द के अंत में «ें» (गीताप्रेस का हिंदी «राजासे», «चिन्तामें» जोड़कर लिखता है —
    संस्कृत में शब्द «ें» पर ख़त्म नहीं होता); या ड़ / ढ़ / नुक़्ता; या संवाद का «--»।"""
    if '--' in text or '—' in text or re.search('[ड़ढ़़]', text):
        return True
    for w in text.split():
        w = w.strip('।॥,;!?-—')
        if w in HINDI or w.endswith('ें') or w in ('हुए', 'हुआ', 'गया', 'गये', 'दिया', 'करके', 'जाकर'):
            return True
    return False


def poonch_do(panktiyan, n):
    """श्लोक `n` की पंक्तियों के अंत के दंड — पंक्तियों की बनावट से (OCR के दंड भरोसे के नहीं)।"""
    out, pad = [], 0
    for i, text in enumerate(panktiyan):
        if i == len(panktiyan) - 1:
            out.append(' ॥%s॥' % int2dev(n))
        elif akshar(text) >= 15:          # आधा श्लोक एक पंक्ति में
            out.append(' ।')
            pad = 0
        else:                                                   # एक पंक्ति = एक पाद
            pad += 1
            out.append(' ।' if pad % 2 == 0 and not text.endswith('-') else '')
    return out


def masauda(adhyay):
    """G की पंक्तियों से मसौदा: ([('@', वक्ता) | ('s', श्लोक, श्लोक में कौन-सी पंक्ति, पाठ, [टिप्पणियाँ])], गिनती)"""
    K = kosh(adhyay)
    G = g_tukde()[adhyay]
    ginti = Counter()
    shlok = []          # चालू श्लोक की पंक्तियाँ: [पाठ, टिप्पणियाँ]
    agla = 1
    out = []

    def band(n):
        for i, (text, tip) in enumerate(shlok):
            out.append(('s', n, i, text, tip))
        del shlok[:]

    def bant(pehla, aakhri):
        """रुकी पंक्तियाँ श्लोक `pehla`…`aakhri` में — अक्षरों के हिसाब से लगभग बराबर।"""
        kitne = aakhri - pehla + 1
        akshar_ = [akshar(x[0]) for x in shlok]
        kul = float(sum(akshar_))
        katan, jod = [], 0
        for i, a in enumerate(akshar_[:-1]):
            jod += a
            if len(katan) < kitne - 1 and jod >= kul * (len(katan) + 1) / kitne - 2 and len(shlok) - i - 1 >= kitne - len(katan) - 1:
                katan.append(i + 1)
        while len(katan) < kitne - 1:          # पंक्तियाँ कम पड़ीं — बचे श्लोक एक-एक पंक्ति के
            katan.append(min(len(shlok) - 1, (katan[-1] + 1) if katan else 1))
        sab = list(shlok)
        sima = [0] + katan + [len(sab)]
        for j in range(kitne):
            shlok[:] = sab[sima[j]:sima[j + 1]]
            band(pehla + j)

    # पहला फेरा: G की कौन-सी पंक्तियाँ संस्कृत की हैं (बाक़ी हिंदी अनुवाद है)
    sanskrit, haal = [], []         # haal: G की हर पंक्ति का हाल क्रम से — 'pakki' | 'A' | 'nahi' | '@'
    for l in G:
        m = VAKTA.match(l)
        if m and len(l) < 40:
            sanskrit.append(('@', re.sub(r'\s+', ' ', l.rstrip('।').strip())))
            haal.append('@')
            continue
        text, ank, dohra, poonch = g_kato(l)
        if len(DEV.findall(text)) < 6:
            continue
        k = kunji_dev(text)
        g = gawah(k, K)
        # संस्कृत की पंक्ति तभी, जब कोई संस्कृत-ही वाला पाठ (D, C, B) उसे पहचाने — या, जो पंक्ति सिर्फ़ छपी
        # परंपरा में है (टंकित में नहीं; चित्रशाला का OCR कमज़ोर), जब उसी प्रकाशक का A उसे ठीक पहचाने, उसमें
        # हिंदी का निशान न हो, और उसके ठीक बाद की पंक्ति पक्की संस्कृत हो (नीचे) — हिंदी अनुवाद A में भी है
        if max(g[n][0] for n in ('D', 'C', 'B')) >= 0.72:
            haal.append('pakki')
        elif g['A'][0] >= 0.9 and akshar(text) >= 8 and not hindi_shabd(text):
            haal.append('A')
        else:
            haal.append('nahi')
            continue
        if True:
            # उसी प्रकाशक के महाभारत (A) में यही पंक्ति श्लोक के अंत पर हो तो उसका अंक — G का अंक OCR में छूटे तो
            # वही काम आता है (अध्याय ३३ में A की गिनती पाँच कम है, इसलिए वहाँ नहीं)
            r, s, jd = K['A'].paas(k)
            a_ank = K['A'].n[s + jd - 1] if (adhyay in A_GINTI_SAMAN and s is not None and r >= 0.85) else ''
            a_ank = re.findall('[०-९]+', a_ank)[-1] if a_ank else ''
            sanskrit.append(('s', l, text, ank, dohra, k, g, a_ank))
            sanskrit[-1] = sanskrit[-1] + (len(haal) - 1,)
    # सिर्फ़ A से पहचानी पंक्ति तभी रहे जब उसके ठीक बाद की पंक्ति पक्की संस्कृत हो
    sanskrit = [x for x in sanskrit
                if x[0] == '@' or haal[x[8]] == 'pakki' or (x[8] + 1 < len(haal) and haal[x[8] + 1] == 'pakki')]
    sanskrit = [x if x[0] == '@' else x[:8] for x in sanskrit]
    kunjiyan = [x[5] if x[0] == 's' else None for x in sanskrit]

    def pados(i, kadam):
        j = i + kadam
        while 0 <= j < len(kunjiyan) and kunjiyan[j] is None:
            j += kadam
        return kunjiyan[j] if 0 <= j < len(kunjiyan) else ''

    # दूसरा फेरा: हर पंक्ति कसौटी पर
    for i, x in enumerate(sanskrit):
        if x[0] == '@':
            if shlok:           # वक्ता बदला और श्लोक खुला है — उसका अंक OCR में नहीं पढ़ा गया
                shlok[-1][1].append('#! अगली पंक्ति वक्ता की है और श्लोक का अंक नहीं पढ़ा गया — यहीं बंद माना (%d)' % agla)
                band(agla)
                agla += 1
            out.append(x)
            continue
        _, l, text, ank, dohra, k, g, a_ank = x
        pehle, baad = pados(i, -1), pados(i, 1)
        ginti['पंक्तियाँ'] += 1
        tip = []
        if '(' in l or ')' in l:
            tip.append('#( पुस्तिका में यहाँ कोष्ठक: %s' % ('(' if '(' in l else ')'))
        chuna, kaise = None, ''
        if not any(khot(text, g, pehle, baad)):
            chuna, kaise = text, 'G'
        elif g['A'][1]:
            ta = g['A'][1] + ('-' if text.endswith('-') and not g['A'][1].endswith('-') else '')
            if len(ta.split()) == len(text.split()):
                ta = ' '.join(g_shaili(x, y) for x, y in zip(ta.split(), text.split()))
            if not any(khot(ta, g, pehle, baad)):
                chuna, kaise = ta, 'A'
            elif len(ta.split()) == len(text.split()):
                chuna = _milao(text.split(), ta.split(), g, text.endswith('-'), pehle, baad)
                kaise = 'GA'
        if chuna is None:
            ginti['हाथ'] += 1
            bure, rb, cb = khot(text, g, pehle, baad)
            tip.append('#? ' + ' ┃ '.join(x for x in (tukde_dikhao(k, bure), rb and 'बनावट: ' + rb, cb and 'छंद: ' + cb) if x))
            for n in SAB[1:]:
                if g[n][1]:
                    tip.append('#   %s %.2f %s' % (n, g[n][0], g[n][1][:120]))
            chuna = text
        else:
            ginti[kaise] += 1
            extra, chhoote = avagraha_fark(chuna, g)
            if extra or chhoote:
                ginti['अवग्रह'] += 1
                tip.append('#ऽ अवग्रह: हमारे में ही %s · टंकित में है, हमारे में नहीं %s — D: %s'
                           % (sorted(extra) or '—', sorted(chhoote) or '—', g['D'][1][:90]))
        kunjiyan[i] = kunji_dev(chuna)
        shlok.append([chuna, tip])
        # श्लोक का अंत? अंक OCR में बिगड़ते हैं, इसलिए क्रम से मिलाकर; A का अंक गवाह
        apeksha = int2dev(agla)
        a_haan = bool(a_ank) and dev2int(a_ank) == agla
        a_naa = bool(a_ank) and dev2int(a_ank) != agla
        if ank:
            n = dev2int(ank)
            ek_ank = len(ank) == len(apeksha) and sum(1 for a, b in zip(ank, apeksha) if a != b) <= 1
            if n == agla or a_haan or ((ek_ank or ank.startswith(apeksha)) and not a_naa):
                if n != agla:
                    tip.append('#! अंक «%s» छपा पढ़ा गया; क्रम से %s%s' % (ank, apeksha, ' (A में भी)' if a_haan else ''))
                band(agla)
                agla += 1
            elif adhyay in A_GINTI_SAMAN and agla < n <= agla + 3 and (n == agla + 1 or (a_ank and dev2int(a_ank) == n)):
                # बीच के श्लोक(ओं) का अंक OCR में छूटा — रुकी पंक्तियों को अक्षर गिनकर बराबर बाँटो, और पन्ने से जाँचो
                tip.append('#! अंक «%s» पढ़ा गया, क्रम से %s चाहिए था — बीच का अंक छूटा; पंक्तियाँ अक्षर गिनकर %d '
                           'श्लोकों में बाँटीं (पन्ने से जाँचो)' % (ank, apeksha, n - agla + 1))
                bant(agla, n)
                agla = n + 1
            else:
                tip.append('#! यहाँ «%s» पढ़ा गया, क्रम से %s चाहिए — श्लोक का अंत नहीं माना' % (ank, apeksha))
        elif a_haan:
            tip.append('#! अंक OCR में नहीं पढ़ा गया — A में यहाँ श्लोक %s ख़त्म होता है' % apeksha)
            band(agla)
            agla += 1
        elif dohra and not a_naa:
            tip.append('#! दोहरा दंड, अंक नहीं — श्लोक का अंत माना (%d)' % agla)
            band(agla)
            agla += 1
    if shlok:
        shlok[-1][1].append('#! आख़िरी पंक्तियाँ बिना अंक के रह गईं')
        band(agla)
        agla += 1
    ginti['श्लोक'] = agla - 1
    return out, ginti


def likho(items):
    """मसौदे (या हाथ से सुधरे मसौदे) की पंक्तियाँ — `vvn_<अध्याय>.txt` के रूप में।"""
    out, i = [], 0
    while i < len(items):
        if items[i][0] == '@':
            out.append('@' + items[i][1])
            i += 1
            continue
        j = i
        while j < len(items) and items[j][0] == 's' and items[j][1] == items[i][1]:
            j += 1
        for x, p in zip(items[i:j], poonch_do([x[3] for x in items[i:j]], items[i][1])):
            out.extend(x[4])
            out.append(x[3] + p)
        i = j
    return out


def banao(adhyay):
    items, ginti = masauda(adhyay)
    print('# अध्याय %d — मसौदा। पंक्तियाँ %d · G जस की तस %d · A की पंक्ति %d · G-A के शब्द मिलाकर %d · '
          'हाथ से तय करनी हैं %d · अवग्रह देखने हैं %d · श्लोक %d (चाहिए %d)'
          % (adhyay, ginti['पंक्तियाँ'], ginti['G'], ginti['A'], ginti['GA'], ginti['हाथ'], ginti['अवग्रह'],
             ginti['श्लोक'], SHLOK[adhyay]))
    print('\n'.join(likho(items)))


# ───────────────────────── हाथ के फ़ैसले ─────────────────────────
def _masauda_rakha(adhyay, naya=False):
    """मसौदा बनाना धीमा है (हर पंक्ति छह पाठों में ढूँढी जाती है) — `VN_SRC/masauda_<अध्याय>.json` में रख लेते हैं।"""
    cache = os.path.join(SRC, 'masauda_%d.json' % adhyay)
    if os.path.exists(cache) and not naya:
        return [tuple(x) for x in json.load(io.open(cache, encoding='utf-8'))]
    items, ginti = masauda(adhyay)
    json.dump(items, io.open(cache, 'w', encoding='utf-8'), ensure_ascii=False)
    print('# नया मसौदा:', dict(ginti))
    return items


def dikhao(adhyay, naya=False):
    """मसौदे की वे पंक्तियाँ जिन पर टिप्पणी है — (श्लोक, श्लोक में पंक्ति) के साथ; `hath_<अध्याय>.py` इन्हीं कुंजियों से लिखी जाती है।"""
    for x in _masauda_rakha(adhyay, naya):
        if x[0] == 's' and x[4]:
            print('(%d, %d)  %s' % (x[1], x[2], x[3]))
            for t in x[4]:
                print('      ' + t)


def hath_lagao(adhyay, naya=False):
    """मसौदा + `vvn/hath_<अध्याय>.py` (SIR = शीर्ष की टिप्पणियाँ; HATH = {(श्लोक, पंक्ति): 'पाठ' | ('पाठ', 'टिप्पणी')};
    पाठ में पंक्ति-अंत (\\n) हो तो वहाँ एक से ज़्यादा पंक्तियाँ — OCR की छोड़ी हुई पंक्ति इसी तरह जुड़ती है)
    → `vvn/vvn_<अध्याय>.txt`। जिस पंक्ति पर फ़ैसला नहीं, उसकी «#?» टिप्पणी फ़ाइल में रह जाती है।
    वक्ता का नाम OCR में बिगड़ा हो तो hath फ़ाइल में VAKTA = {'जैसा पढ़ा गया': 'जैसा छपा है'}।"""
    sys.path.insert(0, VDIR)
    H = importlib.import_module('hath_%d' % adhyay)
    vakta = getattr(H, 'VAKTA', {})
    out, lage, vakta_lage = [], set(), set()
    for x in _masauda_rakha(adhyay, naya):
        if x[0] == '@':
            if x[1] in vakta:
                vakta_lage.add(x[1])
                x = ('@', vakta[x[1]])
            out.append(x)
        elif (x[1], x[2]) in H.HATH:
            f = H.HATH[(x[1], x[2])]
            text, tip = (f, None) if isinstance(f, str) else f
            # कई पंक्तियाँ = OCR में छूटी पंक्ति यहीं जोड़ी गई
            for j, pankti in enumerate(text.split('\n')):
                out.append(('s', x[1], x[2], pankti, [tip] if tip else []))
            lage.add((x[1], x[2]))
        else:
            out.append(('s', x[1], x[2], x[3], [t for t in x[4] if t.startswith('#?') or t.startswith('#  ')]))
    assert lage == set(H.HATH), 'ये फ़ैसले किसी पंक्ति पर नहीं लगे: %s' % sorted(set(H.HATH) - lage)
    assert vakta_lage == set(vakta), 'ये वक्ता-नाम कहीं नहीं मिले: %s' % sorted(set(vakta) - vakta_lage)
    os.makedirs(VDIR, exist_ok=True)
    with io.open(os.path.join(VDIR, 'vvn_%d.txt' % adhyay), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(H.SIR + [''] + likho(out)) + '\n')
    print('लिखा vvn/vvn_%d.txt · हाथ के फ़ैसले %d · अब भी «#?» %d'
          % (adhyay, len(lage), sum(1 for x in out if x[0] == 's' and x[4] and x[4][0].startswith('#?'))))


# ───────────────────────── sahara ─────────────────────────
def v_padho(adhyay):
    """[(पाठ, अंक या None, छूट: '' | 'आँख' | 'तय')] — `# आँख:` / `# तय:` अगली पंक्ति पर लागू।"""
    out, chhoot = [], ''
    for line in io.open(os.path.join(VDIR, 'vvn_%d.txt' % adhyay), encoding='utf-8'):
        s = line.strip()
        if s.startswith('# आँख'):
            chhoot = 'आँख'
            continue
        if s.startswith('# तय'):
            chhoot = 'तय'
            continue
        if not s or s[0] in '#@':
            continue
        m = re.search(r'॥([०-९]+)॥$', s)
        text = re.sub(r'\s*(॥[०-९]+॥|।)$', '', s)
        out.append((text, dev2int(m.group(1)) if m else None, chhoot))
        chhoot = ''
    return out


def shlok_akshar(V):
    """{श्लोक: (उसकी सब पंक्तियों के अक्षर, कितनी पंक्तियाँ पाद भर की)} — अनुष्टुप् में 32, त्रिष्टुप् में 44 के आसपास।"""
    out, ruka = {}, []
    for text, n, _ in V:
        ruka.append(akshar(text))
        if n is not None:
            out[n] = (sum(ruka), sum(1 for a in ruka if a < 15))
            ruka = []
    return out


def sahara(adhyay):
    K = kosh(adhyay)
    V = v_padho(adhyay)
    ginti = Counter()
    bure_kul = 0
    ank = [n for _, n, _ in V if n is not None]
    if ank != list(range(1, SHLOK[adhyay] + 1)):
        bure_kul += 1
        print('%d  श्लोक-अंक क्रम में नहीं: %s' % (adhyay, [n for i, n in enumerate(ank) if n != i + 1][:10]))
    # OCR पूरी पंक्ति छोड़ दे तो हर बची पंक्ति अपने आप में खरी होती है — श्लोक के अक्षर गिनकर पकड़ो:
    # अनुष्टुप् का श्लोक 32 से कम नहीं, और पाद-पाद वाली पंक्तियाँ (त्रिष्टुप्) जोड़ी में
    for n, (kul, paad) in shlok_akshar(V).items():
        if kul < 32 or paad % 2:
            bure_kul += 1
            print('%d  श्लोक %d — कुल %d अक्षर, पाद वाली पंक्तियाँ %d — कोई पंक्ति छूटी?' % (adhyay, n, kul, paad))
    kunjiyan = [kunji_dev(x[0]) for x in V]
    for i, (text, _, chhoot) in enumerate(V):
        ginti['पंक्तियाँ'] += 1
        k = kunjiyan[i]
        g = gawah(k, K)
        bure, rb, cb = khot(text, g, kunjiyan[i - 1] if i else '', kunjiyan[i + 1] if i + 1 < len(V) else '')
        if rb or '-' in text[:-1]:          # बनावट की खोट पर कोई छूट नहीं
            bure_kul += 1
            print('%d  बनावट: «%s» — %s' % (adhyay, rb or '-', text))
            continue
        extra, chhoote = avagraha_fark(text, g)
        sh = shaili(text, g['G'][1]) if g['G'][1] else []
        if not (bure or cb or extra or chhoote or sh):
            if chhoot == 'तय':
                ginti['बेज़रूरत'] += 1
                print('%d  «# तय» की ज़रूरत नहीं — पंक्ति कसौटी पर खरी है: %s' % (adhyay, text))
            elif chhoot:
                ginti['आँख, वैसे भी खरी'] += 1
            continue
        if chhoot:
            ginti[chhoot] += 1
            continue
        bure_kul += 1
        print('%d  V  %s' % (adhyay, text))
        if bure:
            print('      %s' % tukde_dikhao(k, bure))
        if cb:
            print('      छंद: %s' % cb)
        if extra or chhoote:
            print('      अवग्रह: हमारे में ही %s · टंकित में है, हमारे में नहीं %s' % (sorted(extra) or '—', sorted(chhoote) or '—'))
        if sh:
            print('      नासिक्य की लिखावट पुस्तिका से अलग: %s' % ' · '.join('%s / %s' % x for x in sh))
        for n in SAB:
            if g[n][1]:
                print('      %s %.2f %s' % (n, g[n][0], g[n][1][:120]))
    print('अध्याय %d · पंक्तियाँ %d · कसौटी पर खरी %d (इनमें पन्ना भी देखा %d) · सिर्फ़ पन्ना देखकर (आँख) %d · '
          'गवाहों से तय %d · बेज़रूरत «# तय» %d · बाक़ी %d'
          % (adhyay, ginti['पंक्तियाँ'], ginti['पंक्तियाँ'] - ginti['आँख'] - ginti['तय'] - bure_kul,
             ginti['आँख, वैसे भी खरी'], ginti['आँख'], ginti['तय'], ginti['बेज़रूरत'], bure_kul))
    return bure_kul + ginti['बेज़रूरत']


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else 'ginti'
    kaun = [int(x) for x in sys.argv[2:] if x.isdigit()]
    if mode == 'ginti':
        G, A, D, B = g_tukde(), a_tukde(), d_padho(), b_padho()
        for a in ADHYAY:
            print('अध्याय %d · G की सब पंक्तियाँ %d · A की %d · D की संस्कृत %d · B की %d'
                  % (a, len(G[a]), len(A[a]), len([x for x in D[a] if x[0] == 's']), len(B[a])))
    elif mode == 'banao':
        banao(kaun[0])
    elif mode == 'dikhao':
        dikhao(kaun[0], 'naya' in sys.argv)
    elif mode == 'likho':
        hath_lagao(kaun[0], 'naya' in sys.argv)
    elif mode == 'sahara':
        bure = sum(sahara(a) for a in (kaun or [a for a in ADHYAY
                                               if os.path.exists(os.path.join(VDIR, 'vvn_%d.txt' % a))]))
        sys.exit(1 if bure else 0)
