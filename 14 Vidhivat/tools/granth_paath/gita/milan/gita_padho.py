# -*- coding: utf-8 -*-
"""गीता — चारों स्रोतों को {(अध्याय, श्लोक): [पंक्तियाँ]} में तोड़ो।

S = proofread संस्कृत-संग्रह (sd_gita.html)        — "॥ १-१॥"
W = संस्कृत विकिस्रोत, 18 पन्ने (ws_NN.txt)        — <poem> … ॥१-१॥
G = सार्वजनिक (Unlicense) JSON (gh_verse.json)     — "।।1.1।।"
R = BORI समीक्षित संस्करण, IAST (gretil_lines.txt) — "Bhg_01.001a"

उवाच वाली पंक्ति उसी श्लोक की पहली पंक्ति मानी जाती है जिसके ठीक पहले
आती है — 700 की गिनती में उवाच नहीं गिने जाते।
"""
import html
import io
import json
import re
import unicodedata

ANK = str.maketrans('०१२३४५६७८९', '0123456789')
UVACH = re.compile(r'(उवाच|ुवाच|ऊचुः)\s*[।॥]?\s*$')


def nfc(t):
    return unicodedata.normalize('NFC', t).replace('‌', '').replace('‍', '')


def saaf(x):
    return re.sub(r'\s+', ' ', x).strip()


def S_padho(path='sd_gita.html'):
    raw = io.open(path, encoding='utf-8', errors='replace').read()
    t = html.unescape(re.sub(r'(?s)<script.*?</script>|<style.*?</style>', '', raw))
    t = nfc(re.sub(r'(?s)<[^>]+>', '\n', t))
    out, buf, vikalp = {}, [], {}
    shuru = False
    for x in (saaf(l) for l in t.split('\n')):
        if not x:
            continue
        if x.startswith('अथ प्रथमोऽध्यायः'):
            shuru = True
            continue
        if not shuru:
            continue
        if x.startswith('%'):
            break
        if re.match(r'^अथ.*ऽध्यायः', x) or x.startswith('ॐ तत्सदिति') \
                or x.startswith('ब्रह्मविद्यायां') or re.search(r'ऽध्यायः ॥\s*[०-९]+॥$', x):
            buf = []
            continue
        m = re.search(r'॥\s*([०-९]+)-([०-९]+)॥\s*(\(.*\))?\s*$', x)
        if m:
            key = (int(m.group(1).translate(ANK)), int(m.group(2).translate(ANK)))
            if m.group(3):
                vikalp[key] = m.group(3)
            buf.append(re.sub(r'\s*॥\s*[०-९]+-[०-९]+॥.*$', '', x))
            out[key] = buf
            buf = []
        else:
            # पंक्ति के अंत में कोष्ठक वाला पाठभेद
            m2 = re.search(r'\s*(\([^)]*\))\s*$', x)
            if m2 and re.search(r'[ऀ-ॿ]', m2.group(1)):
                x = x[:m2.start()].strip()
            buf.append(x)
    return out, vikalp


def W_padho():
    out = {}
    for n in range(1, 19):
        t = nfc(io.open('ws_%02d.txt' % n, encoding='utf-8').read())
        buf = []
        for blk in re.findall(r'(?s)<poem>(.*?)</poem>', t):
            for x in blk.split('\n'):
                x = saaf(x.replace("'''", '').replace("''", ''))
                if not x:
                    continue
                if 'ऽध्याय' in x or x in ('ॐ', 'श्रीपरमात्मने नमः', 'अथ श्रीमद्भगवद्गीता') \
                        or x.startswith('ॐ तत्सदिति') or 'ब्रह्मविद्यायां' in x:
                    continue
                m = re.search(r'॥\s*([०-९0-9]+)\s*[-.–]\s*([०-९0-9]+)\s*॥\s*$', x)
                if m:
                    key = (int(m.group(1).translate(ANK)), int(m.group(2).translate(ANK)))
                    buf.append(re.sub(r'\s*॥\s*[०-९0-9]+\s*[-.–]\s*[०-९0-9]+\s*॥\s*$', '', x))
                    if key[0] == n:
                        out.setdefault(key, buf)
                    buf = []
                else:
                    buf.append(x)
    return out


def G_padho(path='gh_verse.json'):
    out = {}
    for v in json.load(io.open(path, encoding='utf-8')):
        t = nfc(v['text'])
        t = re.sub(r'।।\s*[0-9]+\.[0-9]+\s*।।', '', t)
        lines = [saaf(x) for x in t.split('\n') if saaf(x)]
        out[(v['chapter_number'], v['verse_number'])] = lines
    return out


def R_padho(path='gretil_lines.txt'):
    """IAST — पंक्तियाँ वैसी ही; कुंजी Bhg_cc.vvv से।"""
    out = {}
    lagi = []           # अगले श्लोक से पहले आई उवाच पंक्ति
    for x in io.open(path, encoding='utf-8').read().split('\n'):
        m = re.search(r'^(.*?)\s+Bhg_(\d+)\.(\d+)([a-z]?)\b', x)
        if not m:
            continue
        key = (int(m.group(2)), int(m.group(3)))
        out.setdefault(key, []).append(m.group(1).strip())
    return out


# ── तुलना की कुंजी — लिपि और वर्तनी के फ़र्क़ हटाकर ─────────────────────────

VY = {'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ṅ', 'च': 'c', 'छ': 'ch',
      'ज': 'j', 'झ': 'jh', 'ञ': 'ñ', 'ट': 'ṭ', 'ठ': 'ṭh', 'ड': 'ḍ', 'ढ': 'ḍh',
      'ण': 'ṇ', 'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n', 'प': 'p',
      'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm', 'य': 'y', 'र': 'r', 'ल': 'l',
      'व': 'v', 'श': 'ś', 'ष': 'ṣ', 'स': 's', 'ह': 'h', 'ळ': 'l'}
SW = {'अ': 'a', 'आ': 'ā', 'इ': 'i', 'ई': 'ī', 'उ': 'u', 'ऊ': 'ū', 'ऋ': 'ṛ',
      'ॠ': 'ṝ', 'ऌ': 'ḷ', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au'}
MA = {'ा': 'ā', 'ि': 'i', 'ी': 'ī', 'ु': 'u', 'ू': 'ū', 'ृ': 'ṛ', 'ॄ': 'ṝ',
      'ॢ': 'ḷ', 'े': 'e', 'ै': 'ai', 'ो': 'o', 'ौ': 'au'}


def iast(dev):
    out, i = [], 0
    while i < len(dev):
        c = dev[i]
        n = dev[i + 1] if i + 1 < len(dev) else ''
        if c in VY:
            if n == '्':
                out.append(VY[c]); i += 2; continue
            if n in MA:
                out.append(VY[c] + MA[n]); i += 2; continue
            out.append(VY[c] + 'a'); i += 1; continue
        if c in SW:
            out.append(SW[c])
        elif c in 'ंँ':
            out.append('ṃ')
        elif c == 'ः':
            out.append('ḥ')
        i += 1
    return ''.join(out)


VYANJAN = 'kgṅcjñṭḍṇtdnpbmyrlvśṣsh'


def kunji_iast(s):
    """IAST → तुलना की कुंजी: ख़ाली जगह, अवग्रह, विराम हटाओ; व्यंजन से पहले
    का हर नासिक्य और अंत का म् → ṃ; दोहरे व्यंजन (र्त्त) एक।"""
    s = unicodedata.normalize('NFC', s.lower())
    s = re.sub(r"[^a-zāīūṛṝḷṅñṭḍṇśṣṃḥ]", '', s)
    s = re.sub(r'[ṅñṇnmṃ](?=[' + VYANJAN + '])', 'ṃ', s)
    s = re.sub(r'm$', 'ṃ', s)
    s = re.sub(r'r([kgcjṭḍtdpbmyvl])\1', r'r\1', s)      # र्त्त → र्त
    s = s.replace('cch', 'ch')
    return s


def kunji(lines, lipi='dev'):
    """उवाच वाली पंक्तियाँ कुंजी में नहीं — वे हर स्रोत में अलग जगह लगी हैं।"""
    out = []
    for x in lines:
        if lipi == 'dev':
            if UVACH.search(x) and len(x) < 40:
                continue
            x = x.replace('ॐ', '')
            out.append(iast(x))
        else:
            if re.search(r'\b(uvāca|ūcuḥ)\s*$', x):
                continue
            out.append(x)
    return kunji_iast(''.join(out))
