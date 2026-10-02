# -*- coding: utf-8 -*-
"""पाठ-मिलान के साझा औज़ार — कई स्रोतों (गवाहों) को पंक्ति-दर-पंक्ति मिलाना।

गीता (→ D-099) में ये `granth_paath/gita/milan/gita_padho.py` के भीतर थे; अब
हर ग्रंथ इन्हीं को बरतता है।

    from milan import kunji_dev, kunji_iast, jodo, html_path

## तुलना की कुंजी
लिपि और वर्तनी के फ़र्क़ हटाकर हर पंक्ति को एक रूप में लाती है, ताकि देवनागरी
और IAST, संधि जोड़कर या तोड़कर लिखा पाठ — सब आपस में मिलाए जा सकें:

- ख़ाली जगह, अवग्रह, विराम, अंक नहीं गिने जाते;
- व्यंजन से पहले का हर नासिक्य एक (सञ्जय = संजय), शब्द के अंत का म् = ं;
- `र्त्त` = `र्त`, `च्छ` = `छ`;
- ॐ और बीजाक्षर (ऐं ह्रीं क्लीं) कुंजी में नहीं — वे हर संस्करण में अलग जगह हैं।

## पंक्तियों को जोड़ना — `jodo()`
आधार की हर पंक्ति के लिए दूसरे गवाह का वही टुकड़ा ढूँढता है, चाहे उसने
पंक्तियाँ अलग जगह तोड़ी हों: पहले पूरी-पूरी मिलती पंक्तियाँ लंगर बनती हैं, फिर
उनके बीच के हिस्से अक्षर-दर-अक्षर।
"""
import difflib
import html
import re
import unicodedata

VY = {'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ṅ', 'च': 'c', 'छ': 'ch',
      'ज': 'j', 'झ': 'jh', 'ञ': 'ñ', 'ट': 'ṭ', 'ठ': 'ṭh', 'ड': 'ḍ', 'ढ': 'ḍh',
      'ण': 'ṇ', 'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n', 'प': 'p',
      'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm', 'य': 'y', 'र': 'r', 'ल': 'l',
      'व': 'v', 'श': 'ś', 'ष': 'ṣ', 'स': 's', 'ह': 'h', 'ळ': 'l'}
SW = {'अ': 'a', 'आ': 'ā', 'इ': 'i', 'ई': 'ī', 'उ': 'u', 'ऊ': 'ū', 'ऋ': 'ṛ',
      'ॠ': 'ṝ', 'ऌ': 'ḷ', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au'}
MA = {'ा': 'ā', 'ि': 'i', 'ी': 'ī', 'ु': 'u', 'ू': 'ū', 'ृ': 'ṛ', 'ॄ': 'ṝ',
      'ॢ': 'ḷ', 'े': 'e', 'ै': 'ai', 'ो': 'o', 'ौ': 'au'}
VYANJAN = 'kgṅcjñṭḍṇtdnpbmyrlvśṣsh'
ANK = str.maketrans('०१२३४५६७८९', '0123456789')
ZW = dict.fromkeys([0x200C, 0x200D, 0xFEFF, 0x00AD])
# वैदिक स्वर-चिह्न: उदात्त/अनुदात्त/स्वरित की रेखाएँ — कुंजी में नहीं
SWAR = dict.fromkeys([0x0951, 0x0952, 0x1CDA, 0x1CD0, 0x1CD1, 0x1CD2, 0xA8F3]
                     + list(range(0x1CD4, 0x1CFA)))


def nfc(t):
    return unicodedata.normalize('NFC', t).translate(ZW)


def saaf(x):
    return re.sub(r'\s+', ' ', x).strip()


def html_path(raw):
    """HTML → पंक्तियों वाला सादा पाठ (script/style हटाकर)।"""
    t = re.sub(r'(?is)<script.*?</script>|<style.*?</style>|<!--.*?-->', '', raw)
    t = re.sub(r'(?i)<br\s*/?>', '\n', t)
    t = re.sub(r'(?i)</p>|</div>|</h\d>|</li>|</tr>', '\n', t)
    t = re.sub(r'<[^>]+>', '', t)
    return nfc(html.unescape(t))


def iast(dev):
    out, i = [], 0
    while i < len(dev):
        c = dev[i]
        n = dev[i + 1] if i + 1 < len(dev) else ''
        if c in VY:
            if n == '्':
                out.append(VY[c]); i += 2; continue
            if n in MA:
                out.append(VY[c] + MA[n]); i += 2; continue
            out.append(VY[c] + 'a'); i += 1; continue
        if c in SW:
            out.append(SW[c])
        elif c in 'ंँ':
            out.append('ṃ')
        elif c == 'ः':
            out.append('ḥ')
        i += 1
    return ''.join(out)


def kunji_iast(s):
    s = unicodedata.normalize('NFC', s.lower())
    s = s.replace('ṁ', 'ṃ').replace('ḻ', 'l')            # वेद-संस्करणों की लिखावट
    s = re.sub(r"[^a-zāīūṛṝḷṅñṭḍṇśṣṃḥ]", '', s)
    s = re.sub(r'[ṅñṇnmṃ](?=[' + VYANJAN + '])', 'ṃ', s)
    s = re.sub(r'm$', 'ṃ', s)
    s = re.sub(r'r([kgcjṭḍtdpbmyvl])\1', r'r\1', s)      # र्त्त → र्त
    s = s.replace('cch', 'ch').replace('ttv', 'tv')     # तत्त्व = तत्व
    return s


_BEEJ = re.compile(r'(?<![ऀ-ॿ])(ॐ|ओं|ओम्|ऐं|ह्रीं|क्लीं|श्रीं)(?![ऀ-ॿ])')


def kunji_dev(line):
    x = nfc(line).translate(SWAR)
    x = _BEEJ.sub(' ', x)
    return kunji_iast(iast(x))


def _seema(a, b, kat):
    """दो कुंजी-डोरियों का अक्षर-मिलान; `kat` (a की कटान-जगहें) → b की जगहें।"""
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    ops = sm.get_opcodes()
    out = []
    for k in kat:
        j = None
        for tag, i1, i2, j1, j2 in ops:
            if i1 <= k <= i2:
                if tag == 'equal':
                    j = j1 + (k - i1)
                elif k == i1:
                    j = j1
                elif k == i2:
                    j = j2
                else:                       # बदले हुए टुकड़े के बीच में — अनुपात से
                    j = j1 + round((k - i1) * (j2 - j1) / max(1, i2 - i1))
                if tag == 'equal' or k < i2:
                    break
        out.append(len(b) if j is None else j)
    return out


def jodo(aadhar, doosra):
    """आधार की हर पंक्ति-कुंजी के लिए दूसरे गवाह का वही टुकड़ा।

    `aadhar`, `doosra` — कुंजियों की सूचियाँ। लौटाता है
    [(दूसरे का टुकड़ा (कुंजी), दूसरे की पंक्तियों की (शुरू, अंत) सीमा)], आधार के क्रम में।
    """
    sm = difflib.SequenceMatcher(None, aadhar, doosra, autojunk=False)
    out = [None] * len(aadhar)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == 'equal':
            for d in range(i2 - i1):
                out[i1 + d] = (doosra[j1 + d], (j1 + d, j1 + d + 1))
            continue
        if i1 == i2:
            continue
        a = ''.join(aadhar[i1:i2])
        b = ''.join(doosra[j1:j2])
        kat, pos = [0], 0
        for x in aadhar[i1:i2]:
            pos += len(x)
            kat.append(pos)
        jagah = _seema(a, b, kat)
        # b की अक्षर-जगह → दूसरे की पंक्ति का अंक
        seema, pos = [], 0
        for x in doosra[j1:j2]:
            seema.append((pos, pos + len(x)))
            pos += len(x)

        def pankti(p, ant=False):
            for n, (s, e) in enumerate(seema):
                if (s <= p < e) or (ant and s < p <= e):
                    return j1 + n
            return j2 - 1 if seema else j1
        for d in range(i2 - i1):
            s, e = jagah[d], jagah[d + 1]
            tuk = b[s:e]
            if seema and e > s:
                rng = (pankti(s), pankti(e, ant=True) + 1)
            else:
                rng = (j1, j1)
            out[i1 + d] = (tuk, rng)
    return out
