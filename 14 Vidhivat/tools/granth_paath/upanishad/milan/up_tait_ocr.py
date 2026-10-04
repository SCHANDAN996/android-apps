# -*- coding: utf-8 -*-
"""तैत्तिरीय: अनुवाक लंबे हैं और छपी टीका में टुकड़ों में छपते हैं (बीच में हिंदी अर्थ) —
इसलिए OCR से मिलान वाक्य-समूहों (लगभग 60–120 अक्षर) पर।"""
import difflib
import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U
import up_ocr_milao as O

SAB = 'sab' in sys.argv
for m in json.loads(U.rd('mool_tait.json')):
    vakya = [x.strip() for x in re.split(r'(?<=[।॥])\s+', m['text']) if x.strip()]
    tukde, cur = [], ''
    for v in vakya:
        cur = (cur + ' ' + v).strip()
        if len(cur) >= 70:
            tukde.append(cur); cur = ''
    if cur:
        if tukde and len(cur) < 40:
            tukde[-1] += ' ' + cur
        else:
            tukde.append(cur)
    for n, t in enumerate(tukde, 1):
        a = U.kd(t)
        ops = {}
        for k in 'ABC':
            r, tuk = O.dhoondho(a, O.ocr_kunji(k), beej=8)
            if r < 0.6:
                continue
            ops[k] = [(i1, i2, tuk[j1:j2]) for tag, i1, i2, j1, j2 in
                      difflib.SequenceMatcher(None, a, tuk, autojunk=False).get_opcodes() if tag != 'equal']
        lab = 'tait %d.%s #%d' % (m['sec'], m['num'], n)
        if len(ops) < 2:
            print('??', lab, len(ops), t[:60])
            continue
        gin = {}
        for k, lst in ops.items():
            for i1, i2, b in lst:
                gin.setdefault((i1, i2, b), []).append(k)
        for (i1, i2, b), ks in sorted(gin.items()):
            if (a[i1:i2], b) in O.HALKA and not SAB:
                continue
            if len(ks) >= 2 and 'B' in ks:
                print('  %s  %s  %s[%s]%s -> [%s]' % (lab, ''.join(ks), a[max(0, i1 - 14):i1], a[i1:i2], a[i2:i2 + 14], b))
