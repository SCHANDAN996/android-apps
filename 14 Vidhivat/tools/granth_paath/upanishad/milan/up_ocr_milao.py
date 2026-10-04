# -*- coding: utf-8 -*-
"""छपी टीका (गीता प्रेस, "ईशादि नौ उपनिषद्") के तीन OCR से मशीन-मिलान।

एक ही संस्करण की तीन अलग scan-प्रतियाँ हैं; हर OCR की अपनी भूलें हैं, पर एक ही
जगह दो OCR एक ही बात कहें तो वह छपी पुस्तक का पाठ है। यह औज़ार हर मंत्र के लिए
तीनों OCR में उसका सबसे मिलता टुकड़ा ढूँढता है और वही जगहें दिखाता है जहाँ
कम से कम दो OCR हमारे पाठ से **एक ही तरह** अलग हैं।

    python up_ocr_milao.py shveta
"""
import difflib
import json
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402
import up_ocr  # noqa: E402

_K = {}

# OCR की वे भूलें जो तीनों प्रतियों में एक-सी दोहराती हैं (एक ही OCR-इंजन) —
# अनुस्वार/विसर्ग/रेफ का छूटना, मात्रा का छोटा-बड़ा होना। ये "पाठभेद" नहीं गिने जाते।
HALKA = {('ṃ', ''), ('', 'ṃ'), ('r', ''), ('ḥ', ''), ('', 'ḥ'), ('ai', 'e'), ('au', 'o'),
         ('ī', 'i'), ('i', 'ī'), ('ū', 'u'), ('u', 'ū'), ('ṛ', ''), ('m', 'ṃ'), ('ṃ', 'm'),
         ('n', 'ṃ'), ('ṃ', 'n')}


def ocr_kunji(k):
    """OCR का पूरा पाठ → कुंजी (एक बार बनाकर फ़ाइल में रखी जाती है)।"""
    if k not in _K:
        fn = 'ocrkunji_%s.txt' % k
        if not os.path.exists(os.path.join(U.HERE, fn)):
            t = up_ocr.path(k)
            # पंक्ति-दर-पंक्ति, ताकि लंबे पाठ पर भी तेज़ रहे
            U.wr(fn, ''.join(U.kd(line) for line in t.split('\n')))
        _K[k] = U.rd(fn)
    return _K[k]


def dhoondho(a, K, beej=10):
    """कुंजी `a` का सबसे मिलता टुकड़ा `K` में — (अनुपात, टुकड़ा)।"""
    cand = {}
    for off in range(0, max(1, len(a) - beej), max(4, len(a) // 12)):
        seed = a[off:off + beej]
        start = 0
        n = 0
        while n < 6:
            p = K.find(seed, start)
            if p < 0:
                break
            cand[max(0, p - off)] = cand.get(max(0, p - off), 0) + 1
            start = p + 1
            n += 1
    best = (0.0, '')
    # आस-पास की जगहों को एक मानकर सबसे ज़्यादा बीज वाली कुछ जगहें जाँचो
    groups = {}
    for p, c in cand.items():
        groups[p // 40] = groups.get(p // 40, 0) + c
    for g, _ in sorted(groups.items(), key=lambda x: -x[1])[:6]:
        s = max(0, g * 40 - 30)
        win = K[s:s + len(a) + 100]
        sm = difflib.SequenceMatcher(None, a, win, autojunk=False)
        blocks = [b for b in sm.get_matching_blocks() if b.size]
        if not blocks:
            continue
        j1, j2 = blocks[0].b, blocks[-1].b + blocks[-1].size
        # सिरों पर जो छूटा है उतना और ले लो
        j1 = max(0, j1 - blocks[0].a)
        j2 = min(len(win), j2 + (len(a) - blocks[-1].a - blocks[-1].size))
        tuk = win[j1:j2]
        r = difflib.SequenceMatcher(None, a, tuk, autojunk=False).ratio()
        if r > best[0]:
            best = (r, tuk)
    return best


def milao(nm, kam=2, sab=False):
    mool = json.loads(U.rd('mool_%s.json' % nm))
    mile = {k: 0 for k in 'ABC'}
    for m in mool:
        lab = '%s %d.%s' % (nm, m['sec'], m['num'])
        a = U.kd(' '.join(m['lines']))
        ops = {}
        for k in 'ABC':
            r, tuk = dhoondho(a, ocr_kunji(k))
            if r < 0.60:
                continue
            mile[k] += 1
            ops[k] = [(i1, i2, tuk[j1:j2]) for tag, i1, i2, j1, j2 in
                      difflib.SequenceMatcher(None, a, tuk, autojunk=False).get_opcodes() if tag != 'equal']
        if len(ops) < 2:
            print('??', lab, '— सिर्फ़', len(ops), 'OCR में मिला')
            continue
        # एक ही जगह, एक ही बदलाव — कितने OCR में
        gin = {}
        for k, lst in ops.items():
            for i1, i2, b in lst:
                gin.setdefault((i1, i2, b), []).append(k)
        dikha = False
        for (i1, i2, b), ks in sorted(gin.items()):
            if not sab and (a[i1:i2], b) in HALKA:
                continue
            # B सबसे साफ़ OCR है; A और C एक ही पुरानी छपाई के हैं और एक-सी भूलें करते हैं
            if (len(ks) >= kam and 'B' in ks) or (sab and len(ops) >= 2):
                if not dikha:
                    print('--', lab, '| OCR', ''.join(sorted(ops)))
                    dikha = True
                print('      %s  %s[%s]%s → [%s]' % (''.join(ks), a[max(0, i1 - 12):i1], a[i1:i2], a[i2:i2 + 12], b))
    print('कुल', len(mool), '· OCR में मिले:', mile)


if __name__ == '__main__':
    for nm in sys.argv[1:]:
        if nm in ('sab',):
            continue
        print('════', nm)
        milao(nm, sab='sab' in sys.argv)
