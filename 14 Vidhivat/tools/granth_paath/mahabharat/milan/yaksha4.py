# -*- coding: utf-8 -*-
"""यक्ष प्रश्न — V (वेंकटेश्वर, आँख से) बनाम GP (गीता प्रेस वन पर्व का OCR, अध्याय ३१३), साथ में K और C।

    python yaksha4.py          जहाँ V और GP अलग हैं
    python yaksha4.py ginti
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
import yaksha3 as Y3  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')


def gp_saaf(s):
    s = unicodedata.normalize('NFC', s)
    s = s.replace('\u200c', '').replace('\u200d', '')
    s = re.sub(r'(?<=[\u0900-\u097f]):', 'ः', s)      # विसर्ग की जगह «:»
    s = re.sub(r'(?<=[\u0900-\u097f])[5<]\s?(?=[\u0900-\u097f])', 'ऽ', s)   # अवग्रह की जगह 5 या <
    s = s.replace('दृष्टवा', 'दृष्ट्वा').replace('श्व', 'श्च') if False else s
    return s


def gp_panktiyan():
    """गीता प्रेस के अध्याय ३१३ की संस्कृत-जैसी पंक्तियाँ: [(क्रम, पाठ)]"""
    t = io.open(os.path.join(HERE, 'gp_03vanparva.txt'), encoding='utf-8', errors='replace').read()
    t = gp_saaf(t)
    ms = [m.start() for m in re.finditer('त्रयोदशाधिकत्रिशत', t)]
    assert len(ms) >= 2, ms
    # अध्याय का शीर्षक पहला मिलान, समापन-वाक्य दूसरा; थोड़ा आगे-पीछे लेकर
    seg = t[ms[0] - 200: ms[1] + 300]
    out = []
    for i, line in enumerate(seg.split('\n')):
        s = line.strip()
        if len(DEV.findall(s)) < 8:
            continue
        s = re.sub(r'\s*[।|]{1,3}\s*[०-९0-9]*\s*[।|]*\s*$', '', s)   # अंत का दंड और अंक
        out.append((i, s))
    return out


# OCR का शोर — पाठभेद नहीं
SHOR = {('ṃ', ''), ('', 'ṃ'), ('c', 'n'), ('śc', 'kṣ'), ('c', 'ṣ'), ('', 'ḥ'), ('ḥ', ''), ('r', ''), ('ṛ', ''),
        ('ṛ', 'a'), ('ṛ', 'u'), ('ṛ', 'ū'), ('ṝ', 'ṛ'), ('ai', 'e'), ('ṃ', 'ḍ'), ('', 'ḍa'), ('ṃ', 'j'), ('', 'u'),
        ('ra', 'ū'), ('cai', ''), ('', 'aj'), ('d', 'ḍat'), ('r', 'v'), ('ṃ', 'na'), ('', 'na'), ('p', 'm'),
        ('y', 'th'), ('bh', 'śr'), ('v', ''), ('v', 'dh'), ('ye', 'ī'), ('au', 'o'), ('ī', 'i'), ('i', 'ī'),
        ('ū', 'u'), ('u', 'ū'), ('n', 'ṃ'), ('ṃ', 'n'), ('m', 'ṃ'), ('ṃ', 'm'), ('', 'r')}


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    V = Y3.v_panktiyan()
    K = [(n, t, kunji_dev(t)) for n, t in Y3.k_panktiyan()]
    C = [(n, t, kunji_dev(t)) for n, t in Y3.c_panktiyan()]
    G = [(n, t, kunji_dev(t)) for n, t in gp_panktiyan()]
    # GP में कई बार दो चरण एक पंक्ति में, कई बार अलग — जोड़ियाँ भी उम्मीदवार
    G2 = list(G)
    for (n1, t1, _), (n2, t2, _) in zip(G, G[1:]):
        G2.append((n1, t1 + ' ' + t2, kunji_dev(t1 + ' ' + t2)))
    ek = alag = nahin = shor = 0
    for num, line, vakta in V:
        vk = kunji_dev(line)
        rg, gl, gt = Y3.paas(vk, G2)
        if rg >= 0.999:
            ek += 1
            continue
        if rg < 0.6:
            nahin += 1
        else:
            alag += 1
        if mode == 'ginti':
            continue
        rk, kl, kt = Y3.paas(vk, K)
        rc, cl, ct = Y3.paas(vk, C)
        if rg >= 0.6 and mode != 'sab':
            gk0 = kunji_dev(gt)
            ops0 = [(vk[i1:i2], gk0[j1:j2]) for tag, i1, i2, j1, j2 in
                    difflib.SequenceMatcher(None, vk, gk0, autojunk=False).get_opcodes() if tag != 'equal']
            if all(o in SHOR for o in ops0):
                shor += 1
                continue
        print('V%-4s %s' % (num, line))
        if rg >= 0.6:
            ops = [(vk[i1:i2], gk[j1:j2]) for gk in [kunji_dev(gt)]
                   for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, vk, gk, autojunk=False).get_opcodes()
                   if tag != 'equal']
            print('  G      %s      %s' % (gt, ops))
        else:
            print('  G —  (सबसे पास %.2f: %s)' % (rg, gt[:60]))
        print('  K %s' % ('=' if rk >= 0.999 else (kt if rk >= 0.6 else '—')))
        print('  C %s' % ('=' if rc >= 0.999 else (ct if rc >= 0.6 else '—')))
    print('सिर्फ़ OCR का शोर:', shor)
    print('V की पंक्तियाँ', len(V), '· GP से हूबहू', ek, '· अलग', alag, '· GP में नहीं मिली', nahin, '· GP की पंक्तियाँ', len(G))


if __name__ == '__main__':
    main()
