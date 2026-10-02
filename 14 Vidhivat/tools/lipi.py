# -*- coding: utf-8 -*-
"""देवनागरी → रोमन, ऐप की अपनी सरल शैली में (aa, ee, oo, sh, ch)।

यह IAST नहीं है — स्क्रीन पर रोमन सिर्फ़ पढ़ने की सहायता है, उच्चारण
का नियम नहीं। सप्तशती (→ D-084) इसी नियम से बनी थी; यह फ़ाइल उसी का
repo वाला रूप है, ताकि अगला ग्रंथ उसी शैली में बने।

    from lipi import roman_sanskrit, khula

`khula()` — precomposed नुक़्ता वाले अक्षर (ज़ = U+095B) को repo के चलन
(ज + ़) में खोलता है। दोनों आँख से एक दिखते हैं पर बराबर नहीं होते;
`find.text` वाली जाँचें चुपचाप फेल होती हैं (→ docs/04_NEXT)।
"""
import re

SK_VYANJAN = {
    'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'n',
    'च': 'ch', 'छ': 'chh', 'ज': 'j', 'झ': 'jh', 'ञ': 'n',
    'ट': 't', 'ठ': 'th', 'ड': 'd', 'ढ': 'dh', 'ण': 'n',
    'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n',
    'प': 'p', 'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm',
    'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v', 'ळ': 'l',
    'श': 'sh', 'ष': 'sh', 'स': 's', 'ह': 'h',
}
SK_SWAR = {'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ee', 'उ': 'u', 'ऊ': 'oo',
           'ऋ': 'ri', 'ॠ': 'ree', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au'}
SK_MATRA = {'ा': 'aa', 'ि': 'i', 'ी': 'ee', 'ु': 'u', 'ू': 'oo', 'ृ': 'ri',
            'ॄ': 'ree', 'े': 'e', 'ै': 'ai', 'ो': 'o', 'ौ': 'au'}
SK_ANT = {'ं': 'm', 'ः': 'h', 'ँ': 'n'}


def roman_sanskrit(s):
    """संस्कृत — शब्द के अंत का 'अ' बोला जाता है।"""
    out, i = [], 0
    while i < len(s):
        c = s[i]
        nxt = s[i + 1] if i + 1 < len(s) else ''
        if c in SK_VYANJAN:
            if nxt == '्':
                out.append(SK_VYANJAN[c])
                i += 2
                continue
            # अनुस्वार/विसर्ग स्वर की **जगह नहीं लेते**, उसके बाद आते हैं
            # ("अपहंसि" → apahamsi, apahmsi नहीं)।
            if nxt in SK_ANT:
                out.append(SK_VYANJAN[c] + 'a' + SK_ANT[nxt])
                i += 2
                continue
            if nxt in SK_MATRA:
                out.append(SK_VYANJAN[c] + SK_MATRA[nxt])
                i += 2
                continue
            out.append(SK_VYANJAN[c] + 'a')
            i += 1
            continue
        if c in SK_SWAR:
            out.append(SK_SWAR[c])
        elif c in SK_ANT:
            out.append(SK_ANT[c])
        elif c == 'ऽ':
            out.append("'")
        elif c == '।':
            out.append(' |')
        elif c == '॥':
            out.append(' ||')
        elif c == 'ॐ':
            out.append('om')
        elif c in '\n -':
            out.append(c)
        i += 1
    lines = [re.sub(r' +', ' ', x).strip() for x in ''.join(out).split('\n')]
    return '\n'.join(lines).strip()


# precomposed → base + नुक़्ता
_KHULA = {
    0x0958: 'क़', 0x0959: 'ख़', 0x095A: 'ग़',
    0x095B: 'ज़', 0x095C: 'ड़', 0x095D: 'ढ़',
    0x095E: 'फ़', 0x095F: 'य़', 0x0929: 'ऩ',
    0x0931: 'ऱ', 0x0934: 'ऴ',
}


def khula(s):
    return s.translate(_KHULA)


_ANK = str.maketrans('0123456789', '०१२३४५६७८९')


def dev_ank(n):
    """12 → '१२'"""
    return str(n).translate(_ANK)


_VARG = {'ङ': 'कखगघ', 'ञ': 'चछजझ', 'ण': 'टठडढ', 'न': 'तथदध', 'म': 'पफबभ'}
_PANCHAM = {v: n for n, vs in _VARG.items() for v in vs}


def pancham(s):
    """शब्द के भीतर का अनुस्वार → उसी वर्ग का पंचम वर्ण (संकट → सङ्कट)।

    ऐप की संस्कृत इसी चलन में है (→ docs/18 §१८.३)। य र ल व श ष स ह से पहले
    का अनुस्वार और शब्द के अंत का अनुस्वार जस का तस रहता है।"""
    out = []
    for i, c in enumerate(s):
        nxt = s[i + 1] if i + 1 < len(s) else ''
        if c == 'ं' and nxt in _PANCHAM:
            out.append(_PANCHAM[nxt] + '्')
        else:
            out.append(c)
    return ''.join(out)
