# -*- coding: utf-8 -*-
"""मत्स्य ५३ — e-पाठ (विकिस्रोत = दूसरा संग्रह, एक ही टंकण) बनाम दो छपी पुस्तकों के OCR।

    python pu_ocr.py            हर पंक्ति: दोनों OCR में सबसे पास वाली पंक्ति और फ़र्क़
    python pu_ocr.py ginti
"""
import difflib
import io
import os
import re
import sys
import unicodedata

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402
import pu_milan as M  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')
OCR = {
    'GP': ('ia_matsya-puran-gita-press.txt', 'पुराणसंख्या', 0, 24000),
    'AA': ('ia_ozcr-matsya-purana-aa-54-ananda-ashram.txt', 'पुराणसंख्या', 1, 14000),
}


def ocr_panktiyan(kunji):
    naam, lang, kaun, lambai = OCR[kunji]
    s = unicodedata.normalize('NFC', io.open(os.path.join(HERE, naam), encoding='utf-8', errors='replace').read())
    pos = [m.start() for m in re.finditer(lang, s)][kaun]
    t = s[max(0, pos - 300):pos + lambai]
    t = t.replace('\u200c', '').replace('\u200d', '')
    out = []
    for l in t.split('\n'):
        l = l.strip()
        if len(DEV.findall(l)) < 8:
            continue
        # एक OCR पंक्ति में कई बार दोनों पाद «।» से अलग — पूरी पंक्ति और उसके टुकड़े, दोनों रखो
        out.append(l)
    return out


def paas(k, ocr_k):
    best, bj = 0.0, None
    for j, kk in enumerate(ocr_k):
        if abs(len(kk) - len(k)) > max(12, len(k) // 2):
            # लंबी OCR पंक्ति के भीतर ढूँढो
            if len(kk) > len(k):
                sm = difflib.SequenceMatcher(None, k, kk, autojunk=False)
                blk = sm.find_longest_match(0, len(k), 0, len(kk))
                a = max(0, blk.b - blk.a)
                r = difflib.SequenceMatcher(None, k, kk[a:a + len(k)], autojunk=False).ratio()
            else:
                continue
        else:
            r = difflib.SequenceMatcher(None, k, kk, autojunk=False).ratio()
        if r > best:
            best, bj = r, j
            if r == 1.0:
                break
    return best, bj


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    ws = M.ws_panktiyan('ws_matsya_53.txt')
    ws = [re.sub(r'\s*(५३\.)?[०-९]+\s*$', '', x) for x in ws]
    kw = [kunji_dev(x) for x in ws]
    oc = {k: ocr_panktiyan(k) for k in OCR}
    ok = {k: [kunji_dev(x) for x in v] for k, v in oc.items()}
    gin = {k: [0, 0, 0] for k in OCR}
    for i, line in enumerate(ws):
        res = {}
        for k in OCR:
            r, j = paas(kw[i], ok[k])
            res[k] = (r, oc[k][j] if j is not None else '')
            gin[k][0 if r == 1.0 else 1 if r >= 0.8 else 2] += 1
        if mode != 'ginti':
            print('%3d %s' % (i + 1, line))
            for k in OCR:
                r, t = res[k]
                print('      %s %.2f %s' % (k, r, '=' if r == 1.0 else t[:120]))
    for k in OCR:
        print(k, 'हूबहू %d · पास (≥0.8) %d · दूर %d' % tuple(gin[k]), '· OCR पंक्तियाँ', len(oc[k]))
