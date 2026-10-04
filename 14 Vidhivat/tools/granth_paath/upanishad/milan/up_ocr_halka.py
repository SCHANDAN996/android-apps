# -*- coding: utf-8 -*-
"""`up_ocr_milao.py` जो "हल्की" भूलें छोड़ देता है, उनमें से वे जो उलटी दिशा की हैं —
हमारे पाठ में अनुस्वार/विसर्ग/रेफ **नहीं** है और छपी पुस्तक के दो OCR में **है**।
OCR चिह्न छोड़ता है, जोड़ता कम है — इसलिए ऐसी जगह हमारे पाठ की भूल हो सकती है।

    python up_ocr_halka.py shveta katha …
"""
import difflib
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402
import up_ocr_milao as O  # noqa: E402

JODE = {('', 'ṃ'), ('', 'ḥ'), ('', 'r'), ('i', 'ī'), ('u', 'ū'), ('a', 'ā'), ('ā', 'a')}

for nm in sys.argv[1:]:
    print('════', nm)
    for m in json.loads(U.rd('mool_%s.json' % nm)):
        a = U.kd(' '.join(m['lines']))
        gin = {}
        for k in 'ABC':
            r, tuk = O.dhoondho(a, O.ocr_kunji(k))
            if r < 0.6:
                continue
            for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, tuk, autojunk=False).get_opcodes():
                if tag != 'equal' and (a[i1:i2], tuk[j1:j2]) in JODE:
                    gin.setdefault((i1, i2, tuk[j1:j2]), []).append(k)
        for (i1, i2, b), ks in sorted(gin.items()):
            if len(ks) >= 2 and 'B' in ks:
                print('  %s %d.%s  %s  %s[%s]%s → [%s]' % (nm, m['sec'], m['num'], ''.join(ks),
                                                         a[max(0, i1 - 14):i1], a[i1:i2], a[i2:i2 + 14], b))
