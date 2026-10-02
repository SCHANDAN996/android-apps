# -*- coding: utf-8 -*-
"""सप्तशती के बचे हिस्सों का मूल पाठ — गवाहों से, मशीन से → mool_naye/<कुंजी>.txt

    python naye.py

- तीन रहस्य: लिखावट N की (दूसरा देवनागरी संग्रह); हर पंक्ति S और छपे संस्करण
  (m2024) से मिलाई हुई। जहाँ N अकेला था, वहाँ बहुमत का पाठ — `SUDHAR` में दर्ज।
- क्षमा-प्रार्थना: आठ श्लोक वाला रूप (S, m2024, ns1974, gondal — चारों एक)।
- रात्रि सूक्त (ऋ. १०.१२७), देवी सूक्त (ऋ. १०.१२५): लिखावट विकिस्रोत की (बिना
  स्वर-चिह्न), N (स्वर सहित) और Aufrecht संस्करण (GRETIL) से मिलाई हुई।
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
from ss_padho import N_padho, bina_ank, kunjiyan  # noqa: E402
from stotra_milao import S_padho  # noqa: E402
from milan import ANK, kunji_dev, kunji_iast, nfc, saaf, jodo  # noqa: E402
from lipi import dev_ank  # noqa: E402

OUT = 'mool_naye'
os.makedirs(OUT, exist_ok=True)

# (कुंजी, N की पंक्ति में क्या, उसकी जगह क्या, किस आधार पर)
SUDHAR = [
    ('pradhanik', 'दंष्ट्राञ्चितवरानना', 'दंष्ट्राङ्कितवरानना',
     'm2024 और gondal — दो छपे संस्करण; N अकेला "ञ्चित", S "चित"'),
    ('pradhanik', 'महाकालीं सितां स्त्रियम्', 'महाकाली सितां स्त्रियम्',
     'S, m2024, gondal; और कर्ता महाकाली है — "महाकाली ने … को जन्म दिया"'),
    ('vaikritik', 'प्रदक्षिणनमस्कारान्', 'प्रदक्षिणानमस्कारान्', 'S, m2024, ns1974'),
    ('murti', 'ध्यानम् मया ख्यातं', 'ध्यानं मया ख्यातं', 'वर्तनी; m2024'),
    ('murti', 'तावतीवमनोहरौ', 'तावतीव मनोहरौ', 'जगह; gondal'),
]


def likho(key, khand):
    with io.open(os.path.join(OUT, key + '.txt'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n\n'.join('# %s\n%s' % (sh, '\n'.join(lines)) for sh, lines in khand) + '\n')
    print('✓ %s — %d खंड' % (key, len(khand)))


def rahasya(key):
    lines = N_padho(key)
    khand, buf = [], []
    lage = set()
    for x in lines:
        if x.startswith('अस्य श्री') or x.startswith('इति '):
            continue
        x = re.sub(r'\s*\[[^\]]*\]', '', x).strip()
        if not x:
            continue
        for k, a, b, _ in SUDHAR:
            if k == key and a in x:
                x = x.replace(a, b)
                lage.add(a)
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥\s*$', x)
        if m:
            buf.append(x[:m.start()].rstrip() + '॥')
            khand.append(('श्लोक ' + dev_ank(int(m.group(1).translate(ANK))), buf))
            buf = []
        else:
            buf.append(x)
    assert not buf, buf
    for k, a, _, _ in SUDHAR:
        assert k != key or a in lage, 'सुधार नहीं लगा: ' + a
    ank = [int(sh.split(' ')[1].translate(ANK)) for sh, _ in khand]
    assert ank == list(range(1, len(ank) + 1)), ank
    likho(key, khand)


def kshama():
    S = S_padho('kshama')
    khand, buf = [], []
    for x in S:
        if x.startswith('॥ इति') or 'Proofread' in x:
            break
        x = x.replace('मां मत्त्वा', 'मां मत्वा').replace('त्वप्रसादात्सुरेश्वरि', 'त्वत्प्रसादात्सुरेश्वरि')
        m = re.search(r'\s*॥\s*([०-९]+)॥\s*$', x)
        if m:
            buf.append(x[:m.start()].rstrip() + '॥')
            khand.append(('श्लोक ' + m.group(1), buf))
            buf = []
        else:
            buf.append(x)
    assert len(khand) == 8
    likho('kshama', khand)


def rv_gretil(mandala, sukta):
    out = {}
    buf = []
    for x in io.open('gretil_sa_Rgveda-edAufrecht.txt', encoding='utf-8'):
        x = x.strip()
        m = re.search(r'\|\|\s*RV_(\d+),(\d+)\.(\d+)\s*$', x)
        if m:
            buf.append(x[:m.start()])
            if (int(m.group(1)), int(m.group(2))) == (mandala, sukta):
                out[int(m.group(3))] = buf
            buf = []
        elif x:
            buf.append(x.rstrip('|').strip())
        else:
            buf = []
    return out


def rv_wikisource(f):
    t = nfc(io.open(f, encoding='utf-8').read())
    blk = re.search(r'(?s)<poem>(.*?)</poem>', t).group(1)
    out, buf = {}, []
    for x in blk.split('\n'):
        x = saaf(re.sub(r'<[^>]+>', '', x))
        if not x:
            continue
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥\s*$', x)
        if m:
            buf.append(x[:m.start()].rstrip() + '॥')
            out[int(m.group(1).translate(ANK))] = buf
            buf = []
        else:
            buf.append(x)
    return out


def rv_N(key):
    out, buf = {}, []
    for x in N_padho(key):
        if not re.search('[॒॑᳚]', x):
            continue
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥?\s*$', x)
        if m:
            buf.append(x[:m.start()])
            out[int(m.group(1).translate(ANK))] = buf
            buf = []
        else:
            buf.append(x)
    return out


def sukta(key, mandala, sukt, wfile, nkey):
    W, N, R = rv_wikisource(wfile), rv_N(nkey), rv_gretil(mandala, sukt)
    assert sorted(W) == sorted(R) == list(range(1, 9)), (sorted(W), sorted(R))
    khand = []
    for n in sorted(W):
        kw = ''.join(kunji_dev(x) for x in W[n])
        kr = ''.join(kunji_iast(x) for x in R[n])
        kn = ''.join(kunji_dev(x) for x in N.get(n, []))
        print('  %s मंत्र %d: W=R %s · W=N %s' % (key, n, kw == kr, kw == kn))
        if kw != kr:
            print('     W', kw, '\n     R', kr)
        if kw != kn:
            print('     W', kw, '\n     N', kn)
        khand.append(('मंत्र ' + dev_ank(n), [x.replace('तंतमुग्रं', 'तं तमुग्रं') for x in W[n]]))
    likho(key, khand)


if __name__ == '__main__':
    for k in ('pradhanik', 'vaikritik', 'murti'):
        rahasya(k)
    kshama()
    sukta('ratri_sukta', 10, 127, 'ws_rv10127.txt', 'ratrisukta')
    sukta('devi_sukta', 10, 125, 'ws_rv10125.txt', 'devisukta')
