# -*- coding: utf-8 -*-
"""व्रत-पन्नों (app/assets/vrat/*.json) के मंत्र — वही दो-गवाह नियम (D-139; → D-145)।

हर गवाह-पन्ना आँख से पढ़ा (`jodo.py`); पृष्ठ-अंक `lagao.prishth_ank` से, यानी तभी जब पन्ने के सिरे पर छपा दिखे।
जो मंत्र किसी विधि में D-141 में जँच चुका, उसका स्रोत-वाक्य वहीं से उठता है — दो जगह अलग बात न लिखी हो।

  MANTRA_SRC=<फ़ोल्डर> python -P vrat_sudhar.py dikhao    — नया स्रोत-वाक्य छापो, कुछ मत लिखो
  MANTRA_SRC=<फ़ोल्डर> python -P vrat_sudhar.py likho     — लिखो
"""
import glob
import io
import json
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, JAD)
from lagao import KHAALI, NAAM, gawah_vakya, prishth_ank  # noqa: E402

VRAT = os.path.join(JAD, '..', '..', 'app', 'assets', 'vrat')
VIDHI = os.path.join(JAD, '..', '..', 'app', 'assets', 'vidhi')

# (किताब, n, क्या दिखा) — सब आँख से, 25 अक्टूबर 2026
G_VASUDEV = [('vp', 205, '«ॐ नमो भगवते वासुदेवाय» के सौ, हजार… जप'), ('kkp', 653, '«…नमो भगवते वासुदेवायेति मन्त्रेण»')]
G_SHIV = [('nkpp', 303, 'पार्थिव-पूजन: «ॐ नमः शिवाय, श्रीभगवते साम्बसदाशिवाय नमः»'),
          ('vp', 295, '«ॐ नमः शिवाय» से शिवजी का'), ('vp', 310, '«ॐ नमः शिवाय» के उच्चारण के साथ'),
          ('kkp', 675, 'वैकुण्ठ चतुर्दशी: «ॐ नमः शिवायेति मन्त्रेण»')]
G_SURYA = [('ntp', 189, ''), ('bsr', 477, ''), ('nkk', 125, ''), ('nkpp', 337, '')]       # D-141 का M18
G_BUDH = [('ntp', 190, 'नवग्रहस्तोत्र ४'), ('bsr', 477, '४'), ('nkk', 249, '४')]
G_SHANI = [('ntp', 190, 'नवग्रहस्तोत्र ७'), ('bsr', 477, '७'), ('nkk', 126, 'शनि की प्रार्थना')]
G_LAKSHMI = [('vp', 154, 'महालक्ष्मी-व्रत: «लक्ष्म्यै नमः» से गाँठ का पूजन'),
             ('nkpp', 233, '«ॐ भूर्भुवः स्वः लक्ष्म्यै नमः, लक्ष्मीमावाहयामि»')]


def pr(k, n):
    p = prishth_ank(k, n)
    return (NAAM[k] + ', पृ. ' + p) if p else NAAM[k]


GAM_STROT = ('गणपति का नाम-मंत्र, बीज «गं» के साथ। छपी पुस्तकों में, दुर्गा-पूजा के साथ गणपति के पूजन पर: '
             + pr('dpv', 58) + ' («ॐ गं गणपतये नमः, गणपतिमावाहयामि»); ' + pr('dpp', 85)
             + ' («गं गणपतये नमः»)। यही ऐप की गणेश पूजन विधि में दूर्वा चढ़ाते समय।')

STROT = {
    'vasudev': 'द्वादशाक्षर मंत्र। छपी पुस्तकों में अक्षरशः: ' + gawah_vakya(G_VASUDEV) + '। यही ऐप की कृष्ण पूजा में।',
    'shiv': 'शिव का पंचाक्षर मंत्र। छपी पुस्तकों में अक्षरशः: ' + gawah_vakya(G_SHIV) + '। यही ऐप की हरितालिका तीज विधि में।',
    'gam': GAM_STROT,
    'surya': 'नवग्रहस्तोत्र, श्लोक १। छपी पुस्तकों में अक्षरशः: ' + gawah_vakya(G_SURYA) + '। यही ऐप की सूर्य अर्घ्य विधि में।',
    'shani': ('नवग्रहस्तोत्र, श्लोक ७। छपी पुस्तकों में अक्षरशः: ' + gawah_vakya(G_SHANI)
              + '। फ़र्क़ सिर्फ़ लिखावट का — «नीलांजन / नीलाञ्जन», «संभूतं / सम्भूतं»।'),
    'lakshmi': ('लक्ष्मी का नाम-मंत्र — यही नाम पूजा में इसी रूप में: ' + gawah_vakya(G_LAKSHMI)
                + '। धर्मसिंधु के कोजागर-व्रत वाले प्रसंग में भी लक्ष्मी का पूजन इसी नाम से; उसी पन्ने का पुष्पांजलि-श्लोक '
                'दूसरी छपी पुस्तक से नहीं मिला, इसलिए नहीं दिया।'),
}

PANNA = {
    'anant_chaturdashi': 'vasudev', 'brihaspativar': 'vasudev', 'ekadashi': 'vasudev', 'janmashtami': 'vasudev',
    'purnima': 'vasudev',
    'mahashivratri': 'shiv', 'masik_shivratri': 'shiv', 'pradosh': 'shiv', 'solah_somvar': 'shiv', 'somvar': 'shiv',
    'budhvar': 'gam', 'sakat_chauth': 'gam', 'sankashti': 'gam', 'vinayak_chaturthi': 'gam',
    'ravivar': 'surya', 'shanivar': 'shani', 'sharad_purnima': 'lakshmi',
}

# विधि वाला जँचा मंत्र ही (पाठ बदला हो तो पाठ भी) — (विधि, उसमें पहचान का टुकड़ा, कौन-से खाने)
VIDHI_SE = {
    'chhath': ('chhath_pooja', 'ॐ आदित्याय नमः', ('devanagari', 'roman', 'arth', 'strot', 'bharosa')),
    'varalakshmi': ('varalakshmi_vrat', 'ॐ श्रियै नमः', ('devanagari', 'roman', 'arth', 'strot', 'bharosa')),
    'karwa_chauth': ('durga_ashtami_kanya_poojan', 'सर्वमङ्गलमाङ्गल्ये', ('strot', 'bharosa')),
    'masik_durgashtami': ('durga_ashtami_kanya_poojan', 'सर्वमङ्गलमाङ्गल्ये', ('strot', 'bharosa')),
    'navratri': ('durga_ashtami_kanya_poojan', 'सर्वमङ्गलमाङ्गल्ये', ('strot', 'bharosa')),
    'mangalvar': ('hanuman_pooja', 'मनोजवं', ('strot', 'bharosa')),
    'gangaur': ('hartalika_teej', 'ॐ उमायै नमः', ('strot', 'bharosa')),
    'hartalika': ('hartalika_teej', 'ॐ उमायै नमः', ('strot', 'bharosa')),
}

# वट-परिक्रमा — विधि में D-141 से ख़ाली (M62); व्रत-पन्ने पर वही
KHAALI_PANNA = {'vat_savitri': KHAALI['M62']}

VIKALP = {
    'budhvar': ('(नवग्रह स्तोत्र का प्रचलित पाठ, स्तोत्र वेदव्यास रचित कहा गया)',
                '(नवग्रहस्तोत्र, श्लोक ४ — ' + gawah_vakya(G_BUDH) + ' में अक्षरशः)'),
    'shanivar': ('"ॐ हं हनुमते नमः"', '«ॐ हनुमते नमः»'),
}


def vidhi_mantra(naam, tukda):
    v = json.load(io.open(os.path.join(VIDHI, naam + '.json'), encoding='utf-8'))
    mil = [c['mantra'] for c in v['charan'] if tukda in ((c.get('mantra') or {}).get('devanagari') or '')]
    assert mil, (naam, tukda)
    return mil[0]


def badlo(naam, m):
    m = dict(m)
    if naam in PANNA:
        m['strot'] = STROT[PANNA[naam]]
        m['bharosa'] = 'uncha'
    if naam in VIDHI_SE:
        vn, tukda, khaane = VIDHI_SE[naam]
        src = vidhi_mantra(vn, tukda)
        for k in khaane:
            m[k] = src[k]
    if naam in KHAALI_PANNA:
        m.update(devanagari='', roman='', arth='', audio='', strot=KHAALI_PANNA[naam], bharosa='kam', sthiti='khaali')
    if naam in VIKALP:
        a, b = VIKALP[naam]
        if b not in m['vikalp']:     # दोबारा चलाने पर कुछ न बदले
            assert m['vikalp'].count(a) == 1, naam
            m['vikalp'] = m['vikalp'].replace(a, b)
    return m


def main(likho):
    badle = 0
    for path in sorted(glob.glob(os.path.join(VRAT, '*.json'))):
        naam = os.path.basename(path)[:-5]
        if naam.startswith('_'):
            continue
        raw = io.open(path, encoding='utf-8', newline='').read()
        v = json.loads(raw)
        purana = v.get('mantra')
        if not purana:
            continue
        naya = badlo(naam, purana)
        if naya == purana:
            continue
        badle += 1
        print('##', naam)
        for k in ('devanagari', 'strot', 'bharosa', 'sthiti', 'vikalp'):
            if naya.get(k) != purana.get(k):
                print('  %s: %s' % (k, (naya.get(k) or '∅').replace('\n', ' ')))
        if likho:
            # व्रत-पन्ने हाथ की लिखावट में हैं (छोटे object एक पंक्ति में) — सिर्फ़ "mantra" वाला हिस्सा बदलो
            nl = '\r\n' if '\r\n' in raw else '\n'
            t = raw.replace('\r\n', '\n')
            i = t.index('\n  "mantra": {\n')
            j = t.index('\n  },\n', i) + len('\n  }')
            blok = json.dumps(naya, ensure_ascii=False, indent=2).replace('\n', '\n  ')
            t = t[:i] + '\n  "mantra": ' + blok + t[j:]
            v['mantra'] = naya
            assert json.loads(t) == v, naam
            io.open(path, 'w', encoding='utf-8', newline='').write(t.replace('\n', nl))
    print('बदले पन्ने:', badle)


if __name__ == '__main__':
    main(len(sys.argv) > 1 and sys.argv[1] == 'likho')
