# -*- coding: utf-8 -*-
"""विष्णु सहस्रनाम के गवाह पढ़ना।

S = संस्कृत-संग्रह (देवनागरी HTML)                         sd_vs.html
N = स्तोत्र-संग्रह                                          sn_vs.html
G = महाभारत का शोध-संस्करण, अनुशासन पर्व १३५ (IAST)          gretil_mbh13.htm
    (W = विकिस्रोत — S से ही बना है, स्वतंत्र गवाह नहीं)

तीन हिस्से, हर एक आधे-श्लोक की पंक्तियों की सूची:
    'purva'  श्रुत्वा धर्मान् … तानि वक्ष्यामि भूतये           13 श्लोक = 26 पंक्तियाँ
    'naam'   विश्वं विष्णुर् … सर्वप्रहरणायुधः                107 श्लोक = 214
    'phal'   इतीदं कीर्तनीयस्य … न ते यान्ति पराभवम्            22 श्लोक = 44
"""
import io
import os
import re
import sys

# `tools/` — यह फ़ाइल tools/granth_paath/vishnusahasranama/milan/ में है। स्रोत की
# फ़ाइलें (sd_vs.html, sn_vs.html, gretil_mbh13.htm, ia_*.txt) repo में नहीं हैं;
# उन्हें एक अस्थायी फ़ोल्डर में उतारकर वहीं से चलाओ (पते docs/18 अध्याय २३ में)।
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import html_path, kunji_dev, kunji_iast, nfc, saaf  # noqa: E402

HISSE = {
    'purva': ('श्रुत्वा धर्मानशेषेण', 'तानि वक्ष्यामि भूतये', 26),
    'naam': ('विष्णुर्वषट्कारो', 'सर्वप्रहरणायुधः', 214),
    'phal': ('इतीदं कीर्तनीयस्य', 'न ते यान्ति पराभवम्', 44),
}


def dev_panktiyan(fname):
    t = html_path(io.open(fname, encoding='utf-8', errors='replace').read())
    return [saaf(x) for x in t.split('\n') if re.search('[\u0900-\u097F]', x)]


def _saaf(x):
    x = re.sub(r'\(.*?\)', '', x)                 # S के कोष्ठक वाले पाठभेद
    x = re.sub(r'[०-९0-9]+', '', x)
    x = x.replace('ॐ', '').replace('ओं', '') if x.startswith(('ॐ ', 'ओं ')) else x
    return saaf(re.sub(r'\s*[॥।|]+\s*$', '', saaf(x)))


def dev_hissa(lines, naam):
    shuru, ant, kitni = HISSE[naam]
    i = next(k for k, x in enumerate(lines) if shuru in x and 'इत्य' not in x and 'इति ' not in x)
    j = next(k for k in range(i, len(lines)) if ant in lines[k])
    out = []
    for x in lines[i:j + 1]:
        if 'उवाच' in x or x.startswith('['):
            continue
        y = _saaf(x)
        if y:
            out.append(y)
    assert len(out) == kitni, (naam, len(out), kitni)
    return out


def S_padho():
    L = dev_panktiyan('sd_vs.html')
    return {k: dev_hissa(L, k) for k in HISSE}


def N_padho():
    L = dev_panktiyan('sn_vs.html')
    return {k: dev_hissa(L, k) for k in HISSE}


def G_padho():
    t = io.open('gretil_mbh13.htm', encoding='utf-8', errors='replace').read()
    rows = re.findall(r'13,135\.(\d{3})([ac])\t([^<]+)<BR>', t)
    out = {'purva': [], 'naam': [], 'phal': []}
    for n, pada, text in rows:
        n = int(n)
        k = 'purva' if n <= 13 else 'naam' if n <= 120 else 'phal'
        out[k].append(saaf(text))
    for k, (_, _, kitni) in HISSE.items():
        assert len(out[k]) == kitni, (k, len(out[k]))
    return out


def kd(x):
    return kunji_dev(x)


def ki(x):
    return kunji_iast(nfc(x).replace("'", ''))
