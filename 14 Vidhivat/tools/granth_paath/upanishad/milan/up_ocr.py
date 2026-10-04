# -*- coding: utf-8 -*-
"""छपी पुस्तकों के OCR में कोई जगह ढूँढना — सिर्फ़ आँख से देखने के लिए।

    python up_ocr.py "पस्प" "नेदिष्ठं"      (हर शब्द-टुकड़े के आस-पास का OCR पाठ)
"""
import os
import re
import sys

import up_saadhan as U

OCR = {
    'A': 'ia_ishadi_nau_upanishad_gita_press_gorakhpu.txt',
    'B': 'ia_ishadi_nau_upanishad_hindi.txt',
    'C': 'ia_HindiBookIshadiNauUpanishadByHarikrishna.txt',
}
_cache = {}


def path(k):
    if k not in _cache:
        t = U.nfc(U.rd(OCR[k]))
        _cache[k] = re.sub(r'[ \t]+', ' ', t)
    return _cache[k]


def dekho(tukda, ghera=70, had=6, kaun='ABC'):
    for k in kaun:
        t = path(k)
        n = 0
        for m in re.finditer(re.escape(tukda), t):
            s = t[max(0, m.start() - ghera):m.end() + ghera].replace('\n', ' ⏎ ')
            print('  %s  …%s…' % (k, s))
            n += 1
            if n >= had:
                break
        if n == 0:
            print('  %s  (नहीं मिला)' % k)


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    for x in sys.argv[1:]:
        print('==', x)
        dekho(x)
