# -*- coding: utf-8 -*-
"""सुंदरकांड के गवाह पढ़ना।

W = सार्वजनिक JSON (Unlicense) — दोहे-दर-दोहा, 60 इकाइयाँ           gh_W.json
D = दूसरा JSON (ODbL) — उसी पाठ-परिवार का; श्लोक इसी में हैं        gh_D.json
छपे संस्करण (OCR) — सिर्फ़ मिलान के लिए:
  gp   गीता प्रेस, पूरा मानस (2024)        ia_gp2024.txt
  gp2  गीता प्रेस, सुंदरकांड (कोड 1349)    ia_d1349.txt
  gp3  सुंदरकांड (कोड 1919)               ia_w1919.txt
  m    2020 की पदच्छेद वाली पुस्तक          ia_m2024.txt
  tp   ठाकुर प्रसाद एंड संस                 ia_tp.txt
"""
import difflib
import io
import json
import os
import re
import sys

# `tools/` — यह फ़ाइल tools/granth_paath/sundarkand/milan/ में है। स्रोत की
# फ़ाइलें (gh_W.json, ia_*.txt …) repo में नहीं हैं; उन्हें एक अस्थायी फ़ोल्डर
# में उतारकर वहीं से चलाओ (पते docs/18 अध्याय २२ में)।
sys.path.insert(0, os.path.abspath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..', '..', '..')))
from milan import kunji_dev, nfc, saaf  # noqa: E402

OCR = {'gp': 'ia_gp2024.txt', 'gp2': 'ia_d1349.txt', 'gp3': 'ia_w1919.txt',
       'm': 'ia_m2024.txt', 'tp': 'ia_tp.txt'}


def kunji(line):
    """अवधी के लिए: अनुनासिक (ँ, ं) संस्करणों में सबसे ज़्यादा बदलता है और OCR में
    सबसे पहले गिरता है — कुंजी में नहीं गिना जाता।"""
    k = kunji_dev(re.sub(r'[०-९0-9]', '', line))
    return k.replace('ṃ', '')


def saaf_pankti(x):
    x = nfc(x).replace('।।', '॥')
    x = re.sub(r'॥\s*[0-9०-९]+\s*॥?', '॥', x)
    return saaf(x)


def W_padho():
    """[(दोहा-अंक, [(प्रकार, [पंक्तियाँ])])] — प्रकार: चौपाई / छंद / दोहा / सोरठा"""
    d = json.load(io.open('gh_W.json', encoding='utf-8'))
    out = []
    for n, e in enumerate(d, 1):
        bhag, cur = [], None
        for x in e['content'].replace('\r', '').split('\n'):
            x = saaf_pankti(x)
            if not x:
                continue
            if x in ('चौपाई', 'छंद', 'दोहा/सोरठा', 'दोहा', 'सोरठा', 'श्लोक'):
                cur = (x, [])
                bhag.append(cur)
                continue
            assert cur is not None, (n, x)
            cur[1].append(x)
        out.append((n, bhag))
    return out


def D_padho():
    d = json.load(io.open('gh_D.json', encoding='utf-8'))
    return [(e['type'], [saaf_pankti(x) for x in e['content'].split('\n') if x.strip()]) for e in d]


_C = {}


def _lo(naam):
    if naam not in _C:
        t = nfc(io.open(OCR[naam], encoding='utf-8').read())
        lines = [x for x in t.split('\n') if re.search('[\u0900-\u097F]', x)]
        keys = [kunji(x.replace('-', '')) for x in lines]
        idx = {}
        for n, k in enumerate(keys):
            for i in range(0, max(0, len(k) - 5)):
                idx.setdefault(k[i:i + 6], set()).add(n)
        _C[naam] = (lines, keys, idx)
    return _C[naam]


def dhundho(q, naam):
    """q — देवनागरी पंक्ति। (मेल 0–1, OCR का टुकड़ा, उसकी कुंजी)"""
    lines, keys, idx = _lo(naam)
    qk = kunji(q)
    vote = {}
    for i in range(0, max(0, len(qk) - 5)):
        for n in idx.get(qk[i:i + 6], ()):
            vote[n] = vote.get(n, 0) + 1
    best = (0.0, '', '')
    for n, _ in sorted(vote.items(), key=lambda x: -x[1])[:6]:
        lo, hi = max(0, n - 1), min(len(lines), n + 2)
        win = ''.join(keys[lo:hi])
        sm = difflib.SequenceMatcher(None, qk, win, autojunk=False)
        blocks = [b for b in sm.get_matching_blocks() if b.size]
        if not blocks:
            continue
        s, e = blocks[0].b, blocks[-1].b + blocks[-1].size
        tuk = win[s:e]
        r = difflib.SequenceMatcher(None, qk, tuk, autojunk=False).ratio()
        if r > best[0]:
            best = (r, ' / '.join(x.strip() for x in lines[lo:hi]), tuk)
    return best
