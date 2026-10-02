# -*- coding: utf-8 -*-
"""ग्रंथ की जाँच — बिना Flutter के (→ D-098)।

    python tools/jaancho_granth.py          सारे ग्रंथ
    python tools/jaancho_granth.py gita     सिर्फ़ यह

दो चीज़ें देखता है:

1. **ऐप वाली JSON हाथ से तो नहीं छुई गई।** औज़ार (`banao_granth.py`) को एक
   अस्थायी फ़ोल्डर में दोबारा चलाकर हर फ़ाइल अक्षर-दर-अक्षर मिलाता है। फ़र्क़
   मिले तो या किसी ने JSON सीधे बदली है, या `tools/granth_paath/` बदलकर औज़ार
   चलाना भूल गया।
2. **कंटेंट के नियम** — कोई अर्थ ख़ाली नहीं; अर्थ में अंग्रेज़ी अक्षर/अंक नहीं;
   रोमन में देवनागरी नहीं बची; नुक़्ता खुले रूप में (ज + ़); ⓘ का नोट 600
   अक्षर के भीतर; दिखने वाले पाठ में किसी वेबसाइट का नाम नहीं (→ D-080)।

`flutter test test/granth_test.dart` यही सब ऐप की तरफ़ से भी देखता है; यह
औज़ार इसलिए है कि कंटेंट लिखते वक़्त जवाब सेकंड में मिले।
"""
import io
import json
import os
import re
import sys
import tempfile

import banao_granth

HERE = os.path.dirname(os.path.abspath(__file__))
# जुड़ा हुआ नुक़्ता (U+0958…) — अक्षर यहाँ अंकों से बनाए हैं, ताकि कोई संपादक
# इस नियम को ही "खोल" न दे।
JUDA = re.compile('[%s]' % ''.join(
    chr(c) for c in list(range(0x0958, 0x0960)) + [0x0929, 0x0931, 0x0934]))
DEV = re.compile('[%s-%s]' % (chr(0x0900), chr(0x097F)))
LATIN = re.compile(r'[A-Za-z0-9]')
WEB = re.compile(r'https?://|www\.|\.com\b|\.org\b|\.in\b', re.I)


def padho(path):
    # git का autocrlf checkout पर CRLF कर देता है — मिलान पंक्ति-अंत से स्वतंत्र
    with io.open(path, encoding='utf-8', newline='') as f:
        return f.read().replace('\r\n', '\n')


def jaancho(gid):
    galti = []
    asl = banao_granth.asset_dir(gid)

    # 1. दोबारा बनाकर मिलाओ
    with tempfile.TemporaryDirectory() as tmp:
        purana_out = sys.stdout
        sys.stdout = io.StringIO()            # औज़ार की अपनी "✓" पंक्ति नहीं चाहिए
        try:
            banao_granth.banao(gid, dst=tmp)
        finally:
            sys.stdout = purana_out
        naye = sorted(os.listdir(tmp))
        asli = sorted(f for f in os.listdir(asl) if f.endswith('.json'))
        if naye != asli:
            galti.append('फ़ाइलों की सूची अलग: %s' % sorted(set(naye) ^ set(asli)))
        for f in naye:
            if f in asli and padho(os.path.join(tmp, f)) != padho(os.path.join(asl, f)):
                galti.append('%s — ऐप की फ़ाइल औज़ार के नतीजे से अलग है' % f)

    # 2. कंटेंट के नियम
    kul = 0
    for f in sorted(os.listdir(asl)):
        if not f.endswith('.json') or f.startswith('_'):
            continue
        d = json.loads(padho(os.path.join(asl, f)))
        if len(d['strot']['note']) > 600:
            galti.append('%s — ⓘ का नोट %d अक्षर' % (f, len(d['strot']['note'])))
        for khaana in ('parichay', 'kabPadhein', 'kaisePadhein'):
            if JUDA.search(d[khaana]):
                galti.append('%s %s — जुड़ा हुआ नुक़्ता' % (f, khaana))
            if WEB.search(d[khaana]):
                galti.append('%s %s — वेबसाइट का नाम' % (f, khaana))
        if WEB.search(json.dumps(d['strot'], ensure_ascii=False)):
            galti.append('%s strot — वेबसाइट का नाम' % f)
        for k in d['khand']:
            kahan = '%s %s' % (f, k['shirshak'])
            kul += 1
            if not k['dev'].strip() or not k['arth'].strip() or not k['roman'].strip():
                galti.append(kahan + ' — पाठ/रोमन/अर्थ ख़ाली')
            if LATIN.search(k['dev']) or LATIN.search(k['arth']):
                galti.append(kahan + ' — अंग्रेज़ी अक्षर/अंक')
            if DEV.search(k['roman']):
                galti.append(kahan + ' — रोमन में देवनागरी बची')
            if JUDA.search(k['arth']):
                galti.append(kahan + ' — जुड़ा हुआ नुक़्ता')
    return kul, galti


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    ids = sys.argv[1:] or sorted(
        d for d in os.listdir(os.path.join(HERE, 'granth_paath'))
        if os.path.isdir(os.path.join(HERE, 'granth_paath', d)))
    bura = False
    for gid in ids:
        kul, galti = jaancho(gid)
        if galti:
            bura = True
            print('✗ %s — %d गड़बड़:' % (gid, len(galti)))
            for g in galti[:40]:
                print('   ' + g)
        else:
            print('✓ %s — %d खंड, ऐप की JSON औज़ार के नतीजे से हूबहू' % (gid, kul))
    sys.exit(1 if bura else 0)


if __name__ == '__main__':
    main()
