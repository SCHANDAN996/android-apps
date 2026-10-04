# -*- coding: utf-8 -*-
"""उपनिषद के मिलान के साझा औज़ार।"""
import difflib
import io
import os
import re
import sys

# ऐप का repo: ये औज़ार यहीं (repo के भीतर) रखे हैं, पर चलते एक अस्थायी फ़ोल्डर से हैं जहाँ
# स्रोत उतारे गए हों — वहाँ से चलाते समय VIDHIVAT_REPO में repo का रास्ता दो।
REPO = os.environ.get('VIDHIVAT_REPO') or os.path.normpath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'tools'))
import milan  # noqa: E402
from milan import html_path, kunji_iast, nfc, saaf  # noqa: E402,F401

HERE = os.path.dirname(os.path.abspath(__file__))
ANK = str.maketrans('०१२३४५६७८९', '0123456789')


def rd(name):
    return io.open(os.path.join(HERE, name), encoding='utf-8', errors='replace').read()


def wr(name, text):
    with io.open(os.path.join(HERE, name), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def kd(s):
    """देवनागरी → कुंजी। `ꣳ` (वैदिक अनुस्वार) को सादा अनुस्वार मानकर।"""
    s = nfc(s).replace('\ua8f3', 'ं').replace('\u1cf2', 'ः')
    s = re.sub(r'[०-९]+', ' ', s)
    return milan.kunji_dev(s)


def ki(s):
    return kunji_iast(s)


# ── आधार (S): मंत्र-दर-मंत्र ────────────────────────────────────────────────
ANT = re.compile(r'॥\s*((?:[०-९]+\.)*[०-९]+)\s*॥\s*$')
SHIRSH = re.compile(
    r'^\s*॥\s*(अथ |इति |इत्य|ॐ शान्तिः|श्रीः)'
    r'|^\s*(इति |इत्य)[^।]*(खण्डः|वल्ली|प्रश्नः|अध्यायः|अनुवाकः|समाप्ता?)\s*[।॥]*\s*$'
    r'|^\s*(Part|Canto|Encoded|Proofread|From |var )|^\s*[०-९]+\s*$|खण्डः\s*॥\s*$'
    r'|^\s*\S+\s+प्रश्नः\s*।?\s*$|^\s*\S+ऽध्यायः\s*।?\s*$')
KOSHTHAK = re.compile(r'\s*\([^()]*\)\s*$')     # S की पाठभेद-टिप्पणी: «॥ २॥ (…)»


def s_mantra(name, shirsh=SHIRSH):
    """[(खंड-क्रम, अंक, [पंक्तियाँ])]; शुरू का (शांति पाठ आदि) हिस्सा खंड 0 में, अंक ''।"""
    out, buf, sec = [], [], 0
    pehla = True
    for line in rd(name).split('\n'):
        line = KOSHTHAK.sub('', line)
        s = line.strip()
        if not s:
            if pehla and buf:
                out.append((0, '', buf)); buf = []
            continue
        if shirsh.search(s) and not ANT.search(s):
            if buf:
                out.append((0 if pehla else sec, '', buf)); buf = []
            if re.search(r'^\s*(॥\s*)?(इति |इत्य)', s) or re.search(r'खण्डः|वल्ली|प्रश्नः|अध्यायः', s):
                pass
            continue
        m = ANT.search(s)
        if m:
            buf.append(ANT.sub('॥', s).strip())
            num = m.group(1).translate(ANK)
            n = int(num.split('.')[-1])
            if pehla or n == 1:
                sec += 1
                pehla = False
            out.append((sec, num, buf)); buf = []
        else:
            buf.append(s)
    if buf:
        out.append((sec, '', buf))
    return out


# ── मिलान ─────────────────────────────────────────────────────────────────
def kato(aadhar, b):
    """आधार की कुंजियों की सूची और गवाह की पूरी कुंजी → गवाह के टुकड़े, उसी क्रम में।"""
    a = ''.join(aadhar)
    kat, pos = [0], 0
    for x in aadhar:
        pos += len(x)
        kat.append(pos)
    j = milan._seema(a, b, kat)
    return [b[j[i]:j[i + 1]] for i in range(len(aadhar))]


def fark(a, b, ghera=10):
    """दो कुंजियों के फ़र्क़ — [(a का टुकड़ा, b का टुकड़ा)] आस-पास के अक्षरों सहित।"""
    out = []
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if tag != 'equal':
            out.append((a[max(0, i1 - ghera):i1] + '[' + a[i1:i2] + ']' + a[i2:i2 + ghera],
                        b[max(0, j1 - ghera):j1] + '[' + b[j1:j2] + ']' + b[j2:j2 + ghera]))
    return out


def _ops(a, b):
    return [(i1, i2, b[j1:j2]) for tag, i1, i2, j1, j2 in
            difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes() if tag != 'equal']


def milao(aadhar, gawah, dikhao='vivad', kam=2):
    """aadhar: [(लेबल, देवनागरी पाठ)]; gawah: {नाम: पूरी कुंजी}।

    dikhao='sab'   — हर फ़र्क़
    dikhao='vivad' — सिर्फ़ वे जगहें जहाँ आधार के ख़िलाफ़ `kam` या ज़्यादा गवाह हैं
                     (अकेले गवाह का फ़र्क़ उसकी अपनी भूल माना — गिनती में आता है)
    """
    keys = [kd(t) for _, t in aadhar]
    tukde = {n: kato(keys, b) for n, b in gawah.items()}
    ek = {n: 0 for n in gawah}
    sab = samarthit = 0
    vivad = []
    for i, (lab, _) in enumerate(aadhar):
        ops = {}
        for n in gawah:
            if tukde[n][i] == keys[i]:
                ek[n] += 1
            else:
                ops[n] = _ops(keys[i], tukde[n][i])
        if not ops:
            sab += 1
            continue
        if len(ops) < len(gawah):
            samarthit += 1      # कम से कम एक गवाह पूरे मंत्र पर आधार के साथ
        # जगह-दर-जगह: कितने गवाह यहाँ आधार से अलग हैं
        ginti = [0] * (len(keys[i]) + 2)
        for n, lst in ops.items():
            chhua = set()
            for i1, i2, _ in lst:
                for p in range(max(0, i1 - 1), min(len(keys[i]), i2 + 1) + 1):
                    chhua.add(p)
            for p in chhua:
                ginti[p] += 1
        bada = max(ginti)
        if dikhao == 'sab' or bada >= kam:
            vivad.append(lab)
            print('--', lab, '| अलग:', ' '.join(ops), '| एक जगह पर सबसे ज़्यादा', bada)
            for n, lst in ops.items():
                for i1, i2, bb in lst:
                    g = max(ginti[max(0, i1 - 1):i2 + 2])
                    if dikhao != 'sab' and g < kam:
                        continue
                    a = keys[i]
                    print('      %-3s %s[%s]%s → [%s]' % (n, a[max(0, i1 - 12):i1], a[i1:i2], a[i2:i2 + 12], bb))
    print('कुल %d · सब गवाहों में एक %d · कम से कम एक गवाह पूरा साथ %d · विवाद वाले %d · '
          % (len(aadhar), sab, sab + samarthit, len(vivad))
          + ' · '.join('%s %d' % (n, ek[n]) for n in gawah))
    return tukde
