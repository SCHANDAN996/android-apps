# -*- coding: utf-8 -*-
"""देवी कवच और कीलक का मूल पाठ — तीन गवाहों के बहुमत से → mool_naye/<कुंजी>.txt

    python ang_naye.py

गवाह: W (विकिस्रोत), N (दूसरा देवनागरी संग्रह), P (छपा संस्करण m2024, OCR)।
लिखावट W की; जहाँ W अकेला है या उसमें छपाई की ग़लती है, वहाँ `BADLO` का रूप।
पुराना ऐप-पाठ (S का अलग पाठ-रूप) इन तीनों से जहाँ अलग था, वह `docs/18` §२० में दर्ज है।
"""
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
from ss_padho import REPO, A_padho, W_padho, kunjiyan  # noqa: E402
from milan import ANK, kunji_dev  # noqa: E402
from lipi import dev_ank, pancham  # noqa: E402

OUT = 'mool_naye'

# (W में क्या, उसकी जगह क्या, किस पर)
BADLO = {
    'kavach': [
        ('ॐ अस्य श्रीचण्डीकवचस्य ब्रह्मा ऋषिः अनुष्टुप छन्दः चामुण्डा देवता अङ्गन्यासोक्तमातरो बीजम् दिग्बन्धदेवतास्तत्वम्',
         'ॐ अस्य श्रीचण्डीकवचस्य ब्रह्मा ऋषिः, अनुष्टुप् छन्दः, चामुण्डा देवता,\nअङ्गन्यासोक्तमातरो बीजम्, दिग्बन्धदेवतास्तत्त्वम्,', 'वर्तनी; शब्द W, N, P में एक'),
        ('पच्चमं स्कन्दमातेति', 'पञ्चमं स्कन्दमातेति', 'W की छपाई; N, P'),
        ('गजसमारुढा', 'गजसमारूढा', 'वर्तनी (आरूढ); N'),
        ('ब्राहमी हंससमारुढा', 'ब्राह्मी हंससमारूढा', 'W की छपाई; N'),
        ('शत्रुणां भयवर्द्धिनि', 'शत्रूणां भयवर्धिनि', 'N, P'),
        ('नैऋत्यां', 'नैरृत्यां', 'वर्तनी; N'),
        ('विजया पातु पृष्टतः', 'विजया पातु पृष्ठतः', 'W की छपाई; N, P'),
        ('जिव्हायां', 'जिह्वायां', 'W की छपाई; N, P'),
        ('दन्तान रक्षतु', 'दन्तान् रक्षतु', 'W की छपाई; N, P'),
        ('स्कन्धयोः खङ्गिनी', 'स्कन्धयोः खड्गिनी', 'W की छपाई; N, P'),
        ('गुह्यं गुहेश्वरी', 'गुह्यं गुह्येश्वरी', 'N, P'),
        ('पादपृष्ठे तु तैजसि', 'पादपृष्ठे तु तैजसी', 'P'),
        ('अहंकारं मनो बुद्धिं', 'अहङ्कारं मनो बुद्धिं', 'वर्तनी — पंचम वर्ण'),
        ('रसे रुपे च', 'रसे रूपे च', 'वर्तनी; N'),
        ('आयु रक्षतु वाराही', 'आयू रक्षतु वाराही', 'N, P'),
        ('पुत्रान रक्षेन्', 'पुत्रान् रक्षेन्', 'W की छपाई; N, P'),
        ('भूतले पुमान ॥', 'भूतले पुमान् ॥', 'W की छपाई; N, P'),
        ('कवचेनावृतः पुमान ॥', 'कवचेनावृतः पुमान् ॥', 'W की छपाई; N, P'),
        ('जङगमं चैव', 'जङ्गमं चैव', 'W की छपाई; N, P'),
        ('खेचराश्वैव', 'खेचराश्चैव', 'W की छपाई; N, P'),
        ('सहसा कुलजा माला', 'सहजा कुलजा माला', 'N, P'),
        ('शिवेन सह मोदते ॥ॐ ॥', 'शिवेन सह मोदते ॥', 'अंत का ॐ पाठ का हिस्सा नहीं'),
        ('महाघोर पराक्रमे', 'महाघोरपराक्रमे', 'जगह — एक ही समास; N'),
        ('मनः शोकविनाशिनी', 'मनःशोकविनाशिनी', 'जगह — एक ही समास'),
        ('सत्वं रजस्तमश्चैव', 'सत्त्वं रजस्तमश्चैव', 'वर्तनी; N, P'),
        ('प्राप्नोति निश्चितम्।', 'प्राप्नोति निश्चितम् ।', 'जगह'),
    ],
    'keelak': [
        ('ॐ अस्य श्रीकीलकमन्त्रस्य शिव ऋषिः अनुष्टुप छन्दः महासरस्वती देवता श्रीजगदम्बाप्रीत्यर्थं सप्तशतीपाठाङ्गत्वेन विनियोगः ।',
         'ॐ अस्य श्रीकीलकमन्त्रस्य शिव ऋषिः, अनुष्टुप् छन्दः,\nश्रीमहासरस्वती देवता, श्रीजगदम्बाप्रीत्यर्थं\nसप्तशतीपाठाङ्गत्वेन जपे विनियोगः ।', 'P और पुराना पाठ — "श्री", "जपे"'),
        ('स्तुवतां देवि स्तोत्रमात्रेण', 'स्तुवतां देवीं स्तोत्रमात्रेण', 'N, P'),
        ('न किच्ञिदपि विद्यते', 'न किञ्चिदपि विद्यते', 'W की छपाई; N, P'),
        ('सर्वमेवं न संशयः |', 'सर्वमेव न संशयः ।', 'N, P'),
        ('इत्थंरुपेण कीलेन', 'इत्थं रूपेण कीलेन', 'N, P'),
        ('भयं क्कापीह जायते', 'भयं क्वापीह जायते', 'W की छपाई'),
        ('यत्किच्चिद् दृश्यते', 'यत्किञ्चिद् दृश्यते', 'W की छपाई; N, P'),
        ('तत्तप्रसादेन', 'तत्प्रसादेन', 'W की छपाई; N, P'),
        ('शत्रुहानिःपरो मोक्षः', 'शत्रुहानिः परो मोक्षः', 'जगह; N, P'),
    ],
}


def banao(key):
    W = W_padho(key)
    lage = set()
    khand, buf, viniyog = [], [], []
    for x in W:
        if x.startswith('अथ ') or x.startswith('इति '):
            continue
        for a, b, _ in BADLO[key]:
            if a in x:
                x = x.replace(a, b)
                lage.add(a)
        x = pancham(x.replace(' |', ' ।').replace('।।', '॥'))
        if 'विनियोगः' in x or x.startswith('ॐ अस्य'):
            viniyog += x.split('\n')
            continue
        m = re.search(r'\s*॥\s*([०-९]+)\s*॥\s*$', x)
        if m:
            buf.append(x[:m.start()].rstrip() + '॥')
            khand.append(('श्लोक ' + dev_ank(int(m.group(1).translate(ANK))), buf))
            buf = []
        elif re.search(r'वाच$', x):
            buf.append(x + ' ।')
        elif x.startswith('ॐ नमश्चण्डिकायै'):
            buf.append('ॐ नमश्चण्डिकायै ।')
        else:
            buf.append(x)
    assert not buf, buf
    for a, _, _ in BADLO[key]:
        assert a in lage, 'नहीं लगा: ' + a
    ank = [int(sh.split(' ')[1].translate(ANK)) for sh, _ in khand]
    assert ank == list(range(1, len(ank) + 1)), ank
    khand.insert(0, ('विनियोग', viniyog))
    for sh, lines in khand:
        for l in lines:
            assert not re.search(r'[A-Za-z0-9|.]', l), (sh, l)
    with io.open(os.path.join(OUT, key + '.txt'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n\n'.join('# %s\n%s' % (sh, '\n'.join(lines)) for sh, lines in khand) + '\n')
    print('✓ %s — %d खंड' % (key, len(khand)))
    return khand


def purana_arth(key, khand):
    """नए हर खंड के लिए पुराने पाठ का सबसे मिलता खंड; कुंजी हूबहू हो तो अर्थ वही।"""
    t = io.open(os.path.join(REPO,
                             'tools', 'granth_paath', 'saptashati', 'paath', key + '.txt'),
                encoding='utf-8').read()
    pur = []
    for blk in re.split(r'\n\s*\n', t.strip()):
        ls = blk.split('\n')
        mool = [x for x in ls[1:] if not x.startswith('= ')]
        arth = [x[2:] for x in ls[1:] if x.startswith('= ')][0]
        pur.append((ls[0][2:], mool, arth, ''.join(kunji_dev(x) for x in mool)))
    import difflib
    out = []
    for sh, lines in khand:
        k = ''.join(kunji_dev(x) for x in lines)
        best = max(pur, key=lambda p: difflib.SequenceMatcher(None, k, p[3], autojunk=False).ratio())
        r = difflib.SequenceMatcher(None, k, best[3], autojunk=False).ratio()
        out.append((sh, lines, best, r, k == best[3]))
    return out


if __name__ == '__main__':
    for key in ('kavach', 'keelak'):
        kh = banao(key)
        res = purana_arth(key, kh)
        with io.open(os.path.join(OUT, key + '_arth_purana.txt'), 'w', encoding='utf-8', newline='\n') as f:
            for sh, lines, best, r, same in res:
                f.write('%s. %s\n' % (sh, best[2].strip()))
        n = 0
        for sh, lines, best, r, same in res:
            if same:
                continue
            n += 1
            print('--- %s (पुराना %s, मेल %.2f)\n  नया  : %s\n  पुराना: %s\n  अर्थ  : %s'
                  % (sh, best[0], r, ' / '.join(lines), ' / '.join(best[1]), best[2]))
        print(key, 'अर्थ देखने लायक़:', n, 'of', len(res))
