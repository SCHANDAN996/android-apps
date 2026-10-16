# -*- coding: utf-8 -*-
"""विदुर नीति (महाभारत, उद्योग पर्व ३३–४०) → `tools/granth_paath/mahabharat/paath/vn1…vn8.txt`।

मूल: `vvn/vvn_33…40.txt` — गीताप्रेस की पुस्तिका «विदुरनीति» का पाठ; हर पंक्ति `vn3.py` की कसौटी पर
(पाँच और पाठों से मिलाकर), और जहाँ कसौटी नहीं सधी वहाँ पुस्तिका का पन्ना देखकर या गवाहों से तय।
अर्थ हर अध्याय की अपनी फ़ाइल में हैं — `vidur_khand_<अध्याय>.py`: `paath/vn*.txt` हाथ से मत बदलो,
वहाँ बदलो और यही चलाओ।

    python vidur_paath.py           जिन अध्यायों के खंड भरे हैं उनकी paath/vn*.txt

⚠ आठों अध्याय भरे बिना `kram.json` नहीं छुआ जाता — ऐप में आधा ग्रंथ नहीं दिखाना है (docs/30 §६.३)।
"""
import importlib
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get('VIDHIVAT_REPO') or os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'tools'))
sys.path.insert(0, HERE)
from lipi import dev_ank, khula  # noqa: E402

VDIR = os.path.join(HERE, 'vvn')
DST = os.path.join(REPO, 'tools', 'granth_paath', 'mahabharat')
ANK = '०१२३४५६७८९'

# पुस्तिका की छपाई की भूलें — (अध्याय, श्लोक, छपा, लिया)। हर एक: पुस्तिका का पन्ना आँख से, और दूसरी छपी
# पुस्तक (गीताप्रेस का महाभारत, खंड ३ — docs/18 §३६ का P) के पन्ने पर दूसरा रूप आँख से।
SUDHAR = [
    # महाभारत पृ. २१३० (leaf 123) — «अतृणे पतितो वह्निः»
    (33, 56, 'बह्निः', 'वह्निः'),
    # महाभारत पृ. २१३२ (leaf 125) — «ततोऽस्य स्रवति प्रज्ञा», «अरक्षितारं राजानं»
    (33, 82, 'स्त्रवति', 'स्रवति'),
    (33, 85, 'राजांनं', 'राजानं'),
    # «आत्मा नियन्ता, इन्द्रियाँ घोड़े» — पुस्तिका का अपना अनुवाद भी «बुद्धि सारथि है»; महाभारत पृ. २१४० (leaf 133)
    (34, 59, 'नियतेन्द्रियाण्यस्य', 'नियन्तेन्द्रियाण्यस्य'),
    # महाभारत पृ. २१४३ (leaf 136) — «प्राह्लादिं» (प्रह्लाद का पुत्र)
    (35, 13, 'प्रह्लादिं', 'प्राह्लादिं'),
    # महाभारत पृ. २१४४ (leaf 137) — «वहिर्द्वारे»; टंकित पाठों में «बहिर्द्वारे»
    (35, 32, 'बहिद्वरि', 'बहिर्द्वारे'),
    # महाभारत पृ. २१४६ (leaf 141) — «सर्वान् गुणानेष गुणो विभाति»
    (35, 53, 'सर्वान्गुणानेषु', 'सर्वान्गुणानेष'),
    # महाभारत पृ. २१४७ (leaf 142) — «न सा सभा»
    (35, 58, 'न स सभा', 'न सा सभा'),
]

# (अध्याय, कुंजी, श्लोक) — श्लोकों की गिनती पुस्तिका वाली
ADHYAY = [(33, 'vn1', 128), (34, 'vn2', 86), (35, 'vn3', 77), (36, 'vn4', 74),
          (37, 'vn5', 64), (38, 'vn6', 47), (39, 'vn7', 85), (40, 'vn8', 32)]


def padho(adhyay, kul):
    """[(श्लोक-अंक, पंक्ति, वक्ता या '')]"""
    raw = []
    vakta = ''
    for line in io.open(os.path.join(VDIR, 'vvn_%d.txt' % adhyay), encoding='utf-8'):
        s = line.strip()
        if not s or s.startswith('#'):
            continue
        if s.startswith('@'):
            vakta = s[1:].strip()
            continue
        m = re.search(r'॥([०-९]+)॥$', s)
        num = int(''.join(str(ANK.index(c)) for c in m.group(1))) if m else None
        raw.append([num, re.sub(r'\s*॥[०-९]+॥$', ' ॥', s) if m else s, vakta])
        vakta = ''
    nxt = None
    for r in reversed(raw):
        if r[0] is None:
            r[0] = nxt
        else:
            nxt = r[0]
    apne = [x for x in SUDHAR if x[0] == adhyay]
    lage = set()
    for r in raw:
        for _, n, a, b in apne:
            if r[0] == n and a in r[1]:
                r[1] = r[1].replace(a, b)
                lage.add((n, a))
    assert len(lage) == len(apne), [x for x in apne if (x[1], x[2]) not in lage]
    assert [r[0] for r in raw if r[1].endswith('॥')] == list(range(1, kul + 1)), 'श्लोक-अंक क्रम में नहीं: %d' % adhyay
    # छपाई में पाद के अंत पर टूटा शब्द («…न कुर्या-» / «न्न दीर्घसूत्रै…») — दोनों टुकड़े एक पंक्ति में
    out = []
    for r in raw:
        if out and out[-1][1].endswith('-'):
            assert not r[2], r
            out[-1][1] = out[-1][1][:-1] + r[1]
        else:
            out.append(r)
    return out


def khand(adhyay):
    """उस अध्याय के खंड, अगर `vidur_khand_<अध्याय>.py` लिखी जा चुकी है।"""
    if not os.path.exists(os.path.join(HERE, 'vidur_khand_%d.py' % adhyay)):
        return []
    return importlib.import_module('vidur_khand_%d' % adhyay).KHAND


def likho():
    """जिन अध्यायों के खंड भरे हैं, उनकी paath/<कुंजी>.txt। लौटाता है {कुंजी: खंडों की गिनती}।"""
    bane = {}
    for adhyay, key, kul in ADHYAY:
        kh = khand(adhyay)
        if not kh:
            continue
        raw = padho(adhyay, kul)
        ank = []
        for a, b, _, _ in kh:
            ank += list(range(a, b + 1))
        assert ank == list(range(1, kul + 1)), 'अध्याय %d: खंडों में श्लोक 1…%d पूरे/क्रम से नहीं' % (adhyay, kul)
        blocks = []
        for a, b, naam, arth in kh:
            assert not re.match('(श्लोक|मंत्र|अनुवाक|चौपाई|दोहा)', naam), naam
            rng = dev_ank(a) if a == b else '%s–%s' % (dev_ank(a), dev_ank(b))
            lines = ['# %s · श्लोक %s' % (naam, rng)]
            for num, text, vakta in raw:
                if not (a <= num <= b):
                    continue
                if vakta:
                    lines.append(vakta + ' ।')
                lines.append(text)
            assert not re.search('[A-Za-z0-9]', arth), arth
            lines.append('= ' + arth)
            blocks.append('\n'.join(lines))
        out = os.path.join(DST, 'paath', key + '.txt')
        with io.open(out, 'w', encoding='utf-8', newline='\n') as f:
            f.write(khula('\n\n'.join(blocks)) + '\n')
        print('लिखा paath/%s.txt · अध्याय %d · %d श्लोक · %d खंड' % (key, adhyay, kul, len(kh)))
        bane[key] = len(kh)
    return bane


if __name__ == '__main__':
    bane = likho()
    baaki = [key for _, key, _ in ADHYAY if key not in bane]
    print('बने %d · बाक़ी %s' % (len(bane), ' '.join(baaki) or '—'))
