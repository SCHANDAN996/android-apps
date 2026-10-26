# -*- coding: utf-8 -*-
"""रुद्राष्टाध्यायी — डिजिटल संहिता से टाइप का आधार, और छपे पन्नों के पते (→ docs/18 अध्याय ४६)।

पाठ छपे पन्नों से आँख से जँचता है; यह औज़ार सिर्फ़ आधार देता है और बताता है कि कौन-सा पन्ना देखना है।

    python milan/rudri_milan.py dikhao 1      — अध्याय १ के हर मंत्र का वेद-पोर्टल पाठ (स्वर हटाकर)

स्रोत repo में नहीं: वेद-पोर्टल का cache (`vp_cache.json`) चलाने वाले फ़ोल्डर में बनता है।
`ved_portal.py` सूक्त के `milan/` में है।

## गवाह

| कुंजी | क्या | पन्ने (archive.org) |
|---|---|---|
| GP | गीताप्रेस, «रुद्राष्टाध्यायी सानुवाद» — मूल + हिंदी अनुवाद | `RudrashtadhyayiGItaPressGorakhpur`, leaf (पाठ के पन्ने विषम, अनुवाद सम) |
| SV | «शिवपूजा विधि — रुद्री सहित» (वाराणसी), मूल | `yDiG_shiv-puja-vidhi-…`, leaf |
| P | वेद-पोर्टल, शुक्ल यजुर्वेद संहिता (स्वर सहित, डिजिटल) — टाइप का आधार | |
| YV | शुक्ल यजुर्वेद माध्यन्दिन संहिता, छपी (नेपाल) — जहाँ GP और SV अलग हों | `jiqr-shukla-yajurveda-…` |
"""
import io
import os
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'sukta', 'milan')))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'saptashati', 'milan')))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))

# अध्याय → [(संहिता-अध्याय, मंत्र), …] — क्रम GP और SV के छपे पाठ का
KRAM = {
    1: [(23, 19), (23, 33), (23, 34), (34, 49)] + [(34, n) for n in range(1, 7)],
    2: [(31, n) for n in range(1, 23)],
    3: [(17, n) for n in range(33, 50)],
    # ३३.३०–३३, फिर ७.१२, ७.१६, ७.४२ (विकिस्रोत में इन तीन की सिर्फ़ प्रतीक), फिर ३३.३४–४३
    4: [(33, n) for n in range(30, 34)] + [(7, 12), (7, 16), (7, 42)] + [(33, n) for n in range(34, 44)],
    5: [(16, n) for n in range(1, 67)],
    6: [(3, n) for n in range(56, 64)],
    7: [(39, n) for n in range(7, 14)],
    8: [(18, n) for n in range(1, 30)],
}

# पन्ने — GP के पाठ वाले leaf, SV के leaf (आँख से पढ़े)
PANNE = {
    1: {'GP': [73, 75, 77], 'GP_arth': [74, 76, 78], 'SV': [54, 55, 56, 57, 58]},
    2: {'GP': [79, 81, 83, 85, 87], 'GP_arth': [80, 82, 84, 86, 88], 'SV': list(range(58, 66))},
    3: {'GP': [89, 91, 93, 95], 'GP_arth': [90, 92, 94, 96], 'SV': list(range(65, 71)), 'YV': [315, 316, 317]},
    4: {'GP': [97, 99, 101, 103], 'GP_arth': [98, 100, 102, 104], 'SV': list(range(70, 77))},
    5: {'GP': list(range(105, 144, 2)), 'GP_arth': list(range(106, 145, 2)), 'SV': list(range(77, 107))},
}

SVAR = {0x0951, 0x0952, 0x0953, 0x0954, 0x1CDA}


def saaf(x):
    """स्वर-चिह्न हटाओ; ꣳ → ं; माध्यन्दिन लिखावट का स्वरों के बीच वाला ऽ (पुरुषऽएवेदं) हटे।"""
    # ꣳ स्वर-खंड (A8E0…) में है — पहले बदलो; वेद-पोर्टल वही अनुस्वार कहीं-कहीं अपने निजी glyph
    # U+F15C से छापता है (अयक्ष्म, तेषा) — वह भी अनुस्वार है, गिराना नहीं
    x = unicodedata.normalize('NFC', x).replace('ꣳ', 'ं').replace('', 'ं')
    out = []
    for ch in x:
        c = ord(ch)
        if (c in SVAR or 0x1CD0 <= c <= 0x1CFF or 0xA8E0 <= c <= 0xA8FF
                or 0x0300 <= c <= 0x036F):
            continue
        out.append(ch)
    x = ''.join(out)
    # ऽ के बाद स्वतंत्र स्वर (अ … औ, ऋ) — माध्यन्दिन लिखावट; ऐप में वहाँ शब्द-विराम
    x = ''.join(' ' if ch == 'ऽ' and i + 1 < len(x) and 0x0905 <= ord(x[i + 1]) <= 0x0914 else ch
                for i, ch in enumerate(x))
    return ' '.join(x.split())


def dikhao(adhyay):
    import ved_portal as vp
    for i, (a, m) in enumerate(KRAM[adhyay], 1):
        print('%d  [%d.%d]  %s' % (i, a, m, saaf(vp.mantra('yajurveda', a, m))))
    p = PANNE.get(adhyay, {})
    print('\nपन्ने — GP पाठ', p.get('GP'), '· GP अनुवाद', p.get('GP_arth'), '· SV', p.get('SV'))


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) >= 3 and sys.argv[1] == 'dikhao':
        dikhao(int(sys.argv[2]))
    else:
        print(__doc__)
