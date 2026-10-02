# -*- coding: utf-8 -*-
"""छोटे पाठ (अंग, रहस्य, क्षमा-प्रार्थना): आधार बनाम दूसरे गवाह, पंक्ति-दर-पंक्ति।

    python stotra_milao.py kavach argala keelak pradhanik vaikritik murti kshama

जहाँ कोई गवाह अलग पढ़े, वहाँ छपे संस्करणों के OCR से भी वही पंक्ति ढूँढकर दिखाता है।
"""
import io
import sys

sys.stdout.reconfigure(encoding='utf-8')
from ss_padho import A_padho, N_padho, W_padho, kunjiyan  # noqa: E402
from milan import html_path, jodo, kunji_dev, saaf  # noqa: E402
from ocr2 import dhundho  # noqa: E402

SD = {'pradhanik': 'sd_prAdhAnikarahasyam.html', 'vaikritik': 'sd_vaikRitikarahasyam.html',
      'murti': 'sd_mUrtirahasyam.html', 'kshama': 'sd_devIkShamApanastotram.html'}


def S_padho(key):
    lines = [saaf(x) for x in html_path(io.open(SD[key], encoding='utf-8').read()).split('\n')]
    lines = [x for x in lines if x]
    out = []
    for x in lines[13:]:
        if x.startswith('%') or x.startswith('This text is prepared'):
            break
        if x.startswith('श्रीगणेशाय नमः'):
            continue
        out.append(x)
    return out


def gavah(key):
    if key in ('kavach', 'argala', 'keelak'):
        return [('A', [x for _, x in A_padho(key)]), ('N', N_padho(key)), ('W', W_padho(key))]
    return [('S', S_padho(key)), ('N', N_padho(key))]


def milao(key, ocr=('m2024', 'ns1974', 'gondal')):
    g = gavah(key)
    (bn, base), baaki = g[0], g[1:]
    bk = kunjiyan(base)
    jod = {}
    for n, lines in baaki:
        ks = kunjiyan(lines)
        rakho = [(k, l) for k, l in zip(ks, lines) if k]
        jod[n] = (jodo(bk, [k for k, _ in rakho]), [l for _, l in rakho])
    ek = alag = 0
    for i, line in enumerate(base):
        if not bk[i]:
            continue
        padh = {n: jod[n][0][i] for n in jod}
        if all(p and p[0] == bk[i] for p in padh.values()):
            ek += 1
            continue
        alag += 1
        print('%s #%d\n  %s: %s' % (key, i, bn, line))
        for n, p in padh.items():
            if p is None or p[0] == bk[i]:
                print('  %s: =' % n)
            else:
                s, e = p[1]
                print('  %s: %s' % (n, ' ⏎ '.join(jod[n][1][s:e])[:200]))
        for o in ocr:
            r, tuk, k = dhundho(line, o)
            if k == bk[i]:
                print('     %-6s = %s' % (o, bn))
            elif r > 0.6:
                print('     %-6s %.2f %s' % (o, r, tuk[:170]))
    print('%s: %d पंक्तियाँ एक, %d अलग\n' % (key, ek, alag))


if __name__ == '__main__':
    for k in sys.argv[1:]:
        milao(k)
