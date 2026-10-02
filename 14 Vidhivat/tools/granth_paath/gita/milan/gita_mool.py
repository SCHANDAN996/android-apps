# -*- coding: utf-8 -*-
"""चार स्रोतों के बहुमत से गीता का मूल पाठ → mool.txt

पाठ = चारों में जिस रूप पर सबसे ज़्यादा स्रोत एक हों (कुंजी से)। बराबरी
(2–2) पर proofread संग्रह + समीक्षित संस्करण वाला रूप।

लिखावट = बहुमत वाले देवनागरी स्रोतों में जिसमें सबसे ज़्यादा पंक्तियाँ हों
(त्रिष्टुप् चार पाद में पढ़ा जाता है); बराबरी पर W, फिर S, फिर G।
नासिक्य की वर्तनी (ं बनाम ङ्/ञ्/ण्/न्/म्) और अवग्रह S के चलन पर — यह
पाठ का नहीं, सिर्फ़ लिखने के ढंग का फ़र्क़ है (कुंजी में दोनों एक हैं)।
"""
import difflib
import io
import re
import sys
from collections import Counter

from gita_padho import UVACH, kunji
from gita_milao2 import S, W, G, R, B, keys, kun, S_at

sys.stdout.reconfigure(encoding='utf-8', errors='replace')
NASIKYA = {'ङ्', 'ञ्', 'ण्', 'न्', 'म्'}


def hai_uvach(x):
    return bool(UVACH.search(x)) and len(x) < 40


def saaf_pankti(x):
    return re.sub(r'\s*[।॥]+\s*$', '', x).strip()


def sharir(lines):
    """उवाच हटाकर, विराम हटाकर, जुड़े पाद अलग करके।"""
    b = [saaf_pankti(x) for x in lines if not hai_uvach(x)]
    # "जिजीविषाम- स्तेऽवस्थिताः" — एक पंक्ति में जुड़े दो पाद
    b = [y.strip() for x in b for y in re.split(r'(?<=-)\s+', x)]
    return [x for x in b if x]


def vartani(w_text, s_text):
    """W की लिखावट पर S की नासिक्य-वर्तनी और अवग्रह चढ़ाओ।"""
    sm = difflib.SequenceMatcher(None, w_text, s_text, autojunk=False)
    out = []
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        a, b = w_text[i1:i2], s_text[j1:j2]
        if op == 'equal':
            out.append(a)
        elif op == 'replace' and a == 'ं' and b in NASIKYA:
            out.append(b)
        elif op == 'replace' and a in NASIKYA and b == 'ं':
            out.append(b)
        elif op == 'insert' and b == 'ऽ':
            out.append(b)
        elif op == 'delete' and a == 'ऽ':
            pass
        else:
            out.append(a)          # ख़ाली जगह, पंक्ति-भेद, हाइफ़न — जैसा था
    return ''.join(out)


def shabd(lines):
    """जगह की तुलना के लिए शब्द — विराम, अवग्रह और नासिक्य-वर्तनी हटाकर।"""
    t = re.sub(r'[।॥]', ' ', ' '.join(lines)).replace('ऽ', '')
    t = re.sub(r'-\s+', '', t)
    for a, b in (('ङ्', 'ं'), ('ञ्', 'ं'), ('ण्', 'ं'), ('न्', 'ं'), ('म्', 'ं')):
        t = t.replace(a, b)
    return t.split()


NL = chr(10)
final, srot, tie, kam = {}, Counter(), [], []
for k in keys:
    mat = Counter(kun[n][k] for n in 'SWGRB')
    top, cnt = mat.most_common(1)[0]
    if len([1 for v in mat.values() if v == cnt]) > 1:
        top = kun['S'][k]                      # बराबरी → proofread संग्रह वाला
        assert mat[top] == cnt, k
        tie.append(k)
    if cnt < 3:
        kam.append((k, dict(Counter(mat.values()))))
    cand = [(n, sharir(d[k])) for n, d in (('W', W), ('S', S), ('G', G))
            if kun[n][k] == top]
    naam, body = max(cand, key=lambda c: len(c[1]))
    sb = sharir(S[k])
    if naam != 'S':
        # वर्तनी S की — S बहुमत में न हो तब भी (सिर्फ़ नासिक्य/अवग्रह चढ़ते हैं)
        body = vartani(NL.join(body), NL.join(sb)).split(NL)
        # पाद के बीच टूटे शब्द का हाइफ़न — जिस स्रोत में नहीं था
        if len(sb) == len(body):
            body = [x + '-' if y.endswith('-') and not x.endswith('-') else x
                    for x, y in zip(body, sb)]
    body = [x.replace(':', '').strip() for x in body if x.strip()]
    # शब्दों के बीच की जगह: जहाँ S और G एक हों और चुना हुआ रूप अलग — S का
    # (जैसे १३.१२ "अनादिमत्परं": जगह डालने से अर्थ एक संप्रदाय का हो जाता है)
    if naam != 'S' and kun['S'][k] == top:
        m_, s_, g_ = shabd(body), shabd(sb), shabd(sharir(G[k]))
        if m_ != s_ and ''.join(m_) == ''.join(s_):
            s_alag = [x for x in s_ if x not in set(m_)]
            if s_alag and all(x in set(g_) for x in s_alag):
                body, naam = list(sb), 'S(जगह)'
    assert kunji(body) == top, (k, body)
    srot[naam] += 1
    final[k] = body


# ── उवाच — कितने स्रोतों में, और कहाँ ─────────────────────────────────────
def uv_naam(lines, lipi='dev'):
    if lipi == 'dev':
        u = [saaf_pankti(x) for x in lines if hai_uvach(x)]
        return [re.sub(r'श्री\s+भगवान', 'श्रीभगवान', x) for x in u]
    return [x for x in lines if re.search(r'(uvāca|ūcuḥ)\s*$', x)]


uv_final, uv_farq = {}, []
for k in keys:
    s, w, g, r = uv_naam(S[k]), uv_naam(W[k]), uv_naam(G[k]), uv_naam(R[k], 'iast')
    n = sum(1 for x in (s, w, g, r) if x)
    if n >= 2:
        naam = (s or w or g)[0]
        src = S[k] if s else (W[k] if w else G[k])
        pos = [i for i, x in enumerate(src) if hai_uvach(x)][0]
        uv_final[k] = (pos, naam)
    if 0 < n < 4:
        uv_farq.append('%d.%d:%s' % (k[0], k[1],
                       'S' * bool(s) + 'W' * bool(w) + 'G' * bool(g) + 'R' * bool(r)))
print('उवाच वाले श्लोक:', len(uv_final))
print('वक्ता:', Counter(v[1] for v in uv_final.values()))
print('उवाच — सब स्रोतों में नहीं:', ' '.join(uv_farq))
print('लिखावट किससे:', dict(srot), '· बराबरी:', tie, '· तीन से कम गवाह:', kam)

# ── विराम: 2 पंक्ति → । ॥ ; 3 → । । ॥ ; 4 (त्रिष्टुप्) → _ । _ ॥ ─────────────
VIRAM = {2: ['।', '॥'], 3: ['।', '।', '॥'], 4: ['', '।', '', '॥']}
galat = []
for k in keys:
    v = VIRAM[len(final[k])]
    s_lines = [x for x in S[k] if not hai_uvach(x)]
    if len(s_lines) == len(final[k]):
        s_v = ['।' if re.search(r'।\s*$', x) else '' for x in s_lines[:-1]] + ['॥']
        if s_v != v:
            galat.append((k, s_v))
    final[k] = [x + (' ' + d if d == '।' else d) for x, d in zip(final[k], v)]
print('विराम का नियम S से अलग:', galat)

with io.open('mool.txt', 'w', encoding='utf-8', newline=NL) as f:
    for k in keys:
        body = list(final[k])
        if k in uv_final:
            pos, naam = uv_final[k]
            # बीच वाला उवाच (1.21): S में दूसरी पंक्ति पर — वहीं
            body.insert(min(pos, len(body)), naam)
        f.write('# %d.%d' % k + NL + NL.join(body) + NL + NL)
print('अतिरिक्त १३.१ (नहीं लिया):', S_at)
