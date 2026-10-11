# -*- coding: utf-8 -*-
"""अनुस्मृति — V (पञ्चरत्न गीता की पुस्तिका, आँख से: vanu/*.txt) बनाम वे दो ग्रंथ जिनमें यही
पाठ अपने-अपने ढाँचे में मिलता है:

    D  = महाभारत, दाक्षिणात्य पाठ, शांति पर्व अध्याय २१० (विकिस्रोत — टंकित)
    VD = विष्णुधर्म, अध्याय ७० «अनुस्मृतिः» (विकिस्रोत — टंकित; अनुस्वार «म्» से लिखा है)

ये पुस्तिका के *गवाह नहीं* हैं — अलग ग्रंथ हैं, जिनमें श्लोक कम-ज़्यादा और शब्द अलग हैं।
इनसे दो काम लिए गए: (१) यह पक्का करना कि अनुस्मृति का मूल कहाँ है; (२) जहाँ दोनों छपी
पंचरत्न पुस्तकें (V और NS — `anusmriti_milan.py`) आपस में अलग हैं, वहाँ देखना कि ये किस ओर हैं।

    python anu3.py            V की हर पंक्ति: D और VD में है या नहीं, और कैसी
    python anu3.py ginti      सार
    python anu3.py bhed       सिर्फ़ वे पंक्तियाँ जहाँ V और NS अलग हैं

स्रोत-फ़ाइलें repo में नहीं हैं (`pu_lao.py ws …` से उतरती हैं); जिस फ़ोल्डर में हों, वह
`ANU_SRC` में दीजिए (न दें तो यही फ़ोल्डर):  ws_12_210.txt · ws_vdh_061_070.txt
"""
import difflib
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402
from anusmriti_milan import ardh, fark, jodi  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')
SRC = os.environ.get('ANU_SRC') or HERE


def d_ardh():
    t = io.open(os.path.join(SRC, 'ws_12_210.txt'), encoding='utf-8').read()
    out = []
    for m in re.finditer(r'<tr><td>\s*(.*?)\s*<td>\s*(12-210-[0-9a-zx]+)', t, flags=re.S):
        ref = m.group(2)
        if ref.endswith('x'):
            continue
        for l in re.split(r'<BR>', m.group(1), flags=re.I):
            l = re.sub(r"[`']", '', l).replace('।', ' ').strip()
            if len(DEV.findall(l)) >= 8:
                out.append((ref, l))
    return out


def vd_ardh():
    t = io.open(os.path.join(SRC, 'ws_vdh_061_070.txt'), encoding='utf-8').read()
    # «सप्ततितमोऽध्यायः» पिछले अध्याय के समापन («एकोनसप्ततितमो…») में भी है — शीर्षक वाली पंक्ति लो
    a = t.find('\nसप्ततितमोऽध्यायः')
    b = t.find('इति विष्णुधर्मे अनुस्मृतिर्नाम', a)
    assert 0 <= a < b, (a, b)
    seg = t[a:b]
    # इस टंकण में शब्द के अंत का अनुस्वार «म्» से लिखा है — मिलान के लिए अनुस्वार
    seg = re.sub('म्(?=\\s+[\u0915-\u0939])', 'ं', seg)
    out, ank = [], '?'
    for l in seg.split('\n'):
        m = re.search(r'\|\|\s*([०-९0-9]+)\s*\|\|', l)
        l2 = re.sub(r'\|\|\s*[०-९0-9]+\s*\|\|', '', l).replace('|', ' ').strip()
        if len(DEV.findall(l2)) >= 8 and 'उवाच' not in l2:
            out.append(['~', l2])
        if m:
            ank = m.group(1)
            for r in reversed(out):
                if r[0] != '~':
                    break
                r[0] = ank
    return [tuple(r) for r in out]


def paas(k, kunjiyan):
    best = (0.0, None)
    for i, c in enumerate(kunjiyan):
        if abs(len(c) - len(k)) > max(10, len(k) // 3):
            continue
        r = 1.0 if c == k else difflib.SequenceMatcher(None, k, c, autojunk=False).ratio()
        if r > best[0]:
            best = (r, i)
            if r == 1.0:
                break
    return best


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    V, N = ardh('vanu/vanu_*.txt'), ardh('nanu/nanu_*.txt')
    D, VD = d_ardh(), vd_ardh()
    dk, vk = [kunji_dev(x[1]) for x in D], [kunji_dev(x[1]) for x in VD]
    ns_alag = {i: j for i, j, r in jodi(V, N) if r < 1.0}
    g = {'D': [0, 0, 0], 'VD': [0, 0, 0]}
    akele = []          # जो पंक्तियाँ न D में हैं न VD में — सिर्फ़ दोनों पंचरत्न पुस्तकों में
    for i, (num, line) in enumerate(V):
        k = kunji_dev(line)
        rd, jd = paas(k, dk)
        rv, jv = paas(k, vk)
        g['D'][0 if rd == 1.0 else 1 if rd >= 0.62 else 2] += 1
        g['VD'][0 if rv == 1.0 else 1 if rv >= 0.62 else 2] += 1
        if rd < 0.62 and rv < 0.62:
            akele.append(num)
        if mode == 'ginti' or (mode == 'bhed' and i not in ns_alag):
            continue
        print('V%-4s %s' % (num, line))
        if i in ns_alag:
            print('   NS ≠ %s' % N[ns_alag[i]][1])
        for naam, r, j, L, K in (('D ', rd, jd, D, dk), ('VD', rv, jv, VD, vk)):
            if r == 1.0:
                print('   %s = (%s)' % (naam, L[j][0]))
            elif r >= 0.62:
                print('   %s ≈ %s (%s)   %s' % (naam, L[j][1], L[j][0], fark(k, K[j])))
            else:
                print('   %s —' % naam)
    print('V के अर्धश्लोक %d · D (दाक्षिणात्य १२.२१०) की पंक्तियाँ %d · VD (विष्णुधर्म ७०) की %d'
          % (len(V), len(D), len(VD)))
    print('D : हूबहू %d · पास %d · नहीं %d' % tuple(g['D']))
    print('VD: हूबहू %d · पास %d · नहीं %d' % tuple(g['VD']))
    print('न D में, न VD में (सिर्फ़ दोनों पंचरत्न पुस्तकों में): %d अर्धश्लोक — श्लोक %s'
          % (len(akele), ', '.join(str(n) for n in sorted(set(akele)))))
