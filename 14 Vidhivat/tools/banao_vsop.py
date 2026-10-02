# -*- coding: utf-8 -*-
"""VSOP87D की मूल फ़ाइलें → `engine/lib/src/vsop_data.dart` (→ D-098, docs/29 K1)।

    python tools/banao_vsop.py <VSOP87D फ़ाइलों वाला फ़ोल्डर>

🔑 **VSOP87 की संख्याएँ हाथ से कभी नहीं टाइप होतीं।** हज़ारों पद हैं; एक अंक
ग़लत तो ग्रह चुपचाप खिसक जाता है। यह औज़ार मूल फ़ाइलों से तालिका बनाता है।

## मूल फ़ाइलें कहाँ से
CDS (Strasbourg) का catalogue **VI/81** — Bretagnon & Francou, *Planetary
theories in rectangular and spherical variables: VSOP87 solutions*, Astron.
Astrophys. 202, 309 (1988)। चाहिए: `VSOP87D.mer .ven .ear .mar .jup .sat` और
`vsop87.chk`। (पता `docs/18_SROT_PANJI.md` में।) ये repo में नहीं रखीं —
3.4 MB हैं; नीचे उनके SHA-256 लिखे हैं ताकि वही फ़ाइलें पहचानी जा सकें।

## D रूप क्यों
VSOP87**D** = सूर्य-केंद्रित गोलीय निर्देशांक (L, B, R), **उस दिन के** विषुव और
क्रांतिवृत्त में — वही जो Meeus अध्याय 32 लेता है। पंचांग भी उसी दिन के विषुव
में चलता है, इसलिए अयन-चलन अलग से नहीं लगाना पड़ता।

## छँटाई
पूरी शृंखला में छह पिंडों के ~18,000 पद हैं। यहाँ वे पद छोड़े जाते हैं जिनका
असर 1800–2200 के भीतर [HADD] से छोटा है। छँटाई से कितनी ग़लती आई, यह औज़ार
**नापकर** छापता है (पूरी शृंखला से तुलना, 4000 तारीख़ें प्रति पिंड) — अनुमान से
नहीं। और शुरू में पूरी शृंखला को `vsop87.chk` के मानों से मिलाता है, ताकि
पढ़ने में ही कोई ग़लती हो तो वहीं रुक जाए।
"""
import hashlib
import io
import json
import math
import os
import random
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', 'engine', 'lib', 'src', 'vsop_data.dart')
CHK_OUT = os.path.join(HERE, '..', 'engine', 'test', 'data', 'vsop_chk.json')

PIND = [  # (फ़ाइल का अंत, Dart नाम, chk में नाम)
    ('mer', 'budh', 'MERCURY'),
    ('ven', 'shukra', 'VENUS'),
    ('ear', 'prithvi', 'EARTH'),
    ('mar', 'mangal', 'MARS'),
    ('jup', 'guru', 'JUPITER'),
    ('sat', 'shani', 'SATURN'),
]
# छँटाई की हद: L, B रेडियन में; R खगोलीय इकाई में। 1e-7 रेडियन = 0.02 विकला।
HADD = 1.0e-7
# सहस्राब्दी में समय की हद, जिस पर छोटे पद तौले जाते हैं (J2000 ± 200 वर्ष)।
TAU_HADD = 0.2

SHA = {
    'VSOP87D.mer': None, 'VSOP87D.ven': None, 'VSOP87D.ear': None,
    'VSOP87D.mar': None, 'VSOP87D.jup': None, 'VSOP87D.sat': None,
}


def padho(path):
    """{चर (1=L, 2=B, 3=R): {घात: [(A, B, C), …]}}"""
    out = {1: {}, 2: {}, 3: {}}
    var = alpha = None
    for line in io.open(path, encoding='ascii'):
        if 'VSOP87 VERSION' in line:
            m = re.search(r'VARIABLE (\d) \(LBR\)\s+\*T\*\*(\d)\s+(\d+) TERMS', line)
            var, alpha = int(m.group(1)), int(m.group(2))
            out[var][alpha] = []
            continue
        if not line.strip():
            continue
        # आख़िरी तीन खाने: A (आयाम), B (कला), C (आवृत्ति)
        a, b, c = (float(x) for x in line.split()[-3:])
        out[var][alpha].append((a, b, c))
    return out


def maan(series, tau):
    """Σ_α τ^α Σ A·cos(B + C·τ)"""
    kul = 0.0
    for alpha, pad in series.items():
        s = 0.0
        for a, b, c in pad:
            s += a * math.cos(b + c * tau)
        kul += s * tau ** alpha
    return kul


def chhaanto(series):
    return {alpha: [p for p in pad if abs(p[0]) * TAU_HADD ** alpha >= HADD]
            for alpha, pad in series.items()}


def chk_padho(path):
    """vsop87.chk से VSOP87D के मान: {(नाम, JD): (l, b, r)}"""
    out = {}
    lines = io.open(path, encoding='ascii').read().split('\n')
    for i, line in enumerate(lines):
        m = re.match(r'\s*VSOP87D\s+(\w+)\s+JD(\d+\.\d)', line)
        if m:
            # मान ".4664714751" और "-.0527573409" जैसे छपे हैं — आगे शून्य नहीं
            vals = re.findall(r'\b[lbr]\s+(-?\d*\.\d+)', lines[i + 1])
            out[(m.group(1), float(m.group(2)))] = tuple(float(v) for v in vals)
    return out


def main(folder):
    chk = chk_padho(os.path.join(folder, 'vsop87.chk'))
    random.seed(1987)
    dart = []
    saar = []
    for ant, naam, chk_naam in PIND:
        fname = 'VSOP87D.' + ant
        path = os.path.join(folder, fname)
        SHA[fname] = hashlib.sha256(open(path, 'rb').read()).hexdigest()
        poora = padho(path)

        # 1. पढ़ाई की जाँच — पूरी शृंखला, chk के हर मान से
        mile = 0
        for (cn, jd), (l, b, r) in chk.items():
            if cn != chk_naam:
                continue
            tau = (jd - 2451545.0) / 365250.0
            ml = maan(poora[1], tau) % (2 * math.pi)
            mb = maan(poora[2], tau)
            mr = maan(poora[3], tau)
            assert abs(ml - l) < 2e-9 and abs(mb - b) < 2e-9 and abs(mr - r) < 2e-9, \
                (naam, jd, ml - l, mb - b, mr - r)
            mile += 1
        assert mile >= 8, (naam, mile)

        # 2. छँटाई, और उससे आई ग़लती — नापकर
        chhota = {v: chhaanto(poora[v]) for v in (1, 2, 3)}
        zyada = [0.0, 0.0, 0.0]
        for _ in range(4000):
            tau = random.uniform(-TAU_HADD, TAU_HADD)
            for i, v in enumerate((1, 2, 3)):
                d = abs(maan(poora[v], tau) - maan(chhota[v], tau))
                zyada[i] = max(zyada[i], d)
        n_poora = sum(len(p) for v in poora.values() for p in v.values())
        n_chhota = sum(len(p) for v in chhota.values() for p in v.values())
        vikala = 180 / math.pi * 3600
        saar.append('%-8s %5d → %4d पद · छँटाई से ज़्यादा-से-ज़्यादा ग़लती: '
                    'L %.3f" · B %.3f" · R %.1e AU · chk से %d मान मिले'
                    % (naam, n_poora, n_chhota, zyada[0] * vikala,
                       zyada[1] * vikala, zyada[2], mile))

        for v, akshar in ((1, 'L'), (2, 'B'), (3, 'R')):
            dart.append('const List<List<double>> %s%s = [' % (naam, akshar))
            for alpha in sorted(chhota[v]):
                pad = chhota[v][alpha]
                dart.append('  // τ^%d — %d पद' % (alpha, len(pad)))
                dart.append('  [')
                for a, b, c in pad:
                    dart.append('    %r, %r, %r,' % (a, b, c))
                dart.append('  ],')
            dart.append('];')
            dart.append('')

    sir = [
        '// ⚠️ यह फ़ाइल औज़ार से बनी है — हाथ से मत छूना।',
        '//',
        '//     python tools/banao_vsop.py <VSOP87D फ़ाइलों वाला फ़ोल्डर>',
        '//',
        '// VSOP87D (Bretagnon & Francou, Astron. Astrophys. 202, 309, 1988) —',
        '// सूर्य-केंद्रित L, B (रेडियन) और R (खगोलीय इकाई), उस दिन के विषुव में।',
        '// हर शृंखला τ की एक घात के लिए है; उसमें पद तीन-तीन संख्याओं में हैं:',
        '// A, B, C — मान = Σ A·cos(B + C·τ), τ = J2000 से जूलियन सहस्राब्दी।',
        '//',
        '// छँटाई: |A|·%.1f^α < %.0e वाले पद छोड़े गए। नापी हुई ग़लती:' % (TAU_HADD, HADD),
    ] + ['//   ' + s for s in saar] + [
        '//',
        '// मूल फ़ाइलों के SHA-256:',
    ] + ['//   %s  %s' % (SHA[k], k) for k in sorted(SHA)] + [
        '',
        '// ignore_for_file: prefer_single_quotes',
        '',
    ]
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(sir + dart))

    # जाँच के मान — `graha_test.dart` छँटी हुई तालिका को इन्हीं से मिलाता है।
    # सिर्फ़ वे दो तारीख़ें जो छँटाई के दायरे (J2000 ± 200 वर्ष) में हैं।
    chk_out = {
        '_srot': 'vsop87.chk (CDS VI/81) — VSOP87D, पूरी शृंखला के मान: '
                 'l, b रेडियन में, r खगोलीय इकाई में।',
        '_note': 'tools/banao_vsop.py से बना; हाथ से मत बदलना।',
        'maan': [
            {'pind': naam, 'jde': jd, 'l': chk[(cn, jd)][0],
             'b': chk[(cn, jd)][1], 'r': chk[(cn, jd)][2]}
            for _, naam, cn in PIND for jd in (2451545.0, 2415020.0)
        ],
    }
    with io.open(CHK_OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(chk_out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('\n'.join(saar))
    print('→', os.path.normpath(OUT), '%.0f KB' % (os.path.getsize(OUT) / 1024))


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('चलाने का ढंग: python tools/banao_vsop.py <फ़ोल्डर>')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    main(sys.argv[1])
