# -*- coding: utf-8 -*-
"""NASA JPL Horizons से ग्रहों की आभासी स्थिति → `engine/test/data/horizons_graha.json`

    python tools/horizons_lao.py

यह **जाँच का डेटा** है, ऐप का नहीं — ऐप कभी नेटवर्क नहीं छूता। यह औज़ार
एक बार चलता है; उसका नतीजा repo में रहता है और `graha_test.dart` उसी से
मिलाता है। दोबारा तभी चलाना जब तारीख़ें या पिंड बदलने हों।

## क्या माँगा जाता है
- पृथ्वी के केंद्र से (`500@399`) — कुंडली और पंचांग दोनों भू-केंद्रित हैं।
- मात्रा 31: *observer ecliptic longitude & latitude* — आभासी स्थिति (प्रकाश
  का समय, aberration, नतांश सब शामिल), **उस दिन के** क्रांतिवृत्त और विषुव
  में। ठीक वही चीज़ जो इंजन का `grahaApparent()` देता है।
- समय TT में, जूलियन दिन से — ताकि ΔT का सवाल ही न उठे; इंजन भी JDE लेता है।

तारीख़ें 1930 से 2040 तक बराबर फ़ासले पर — जन्म-कुंडली का पूरा दायरा।
"""
import io
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', 'engine', 'test', 'data', 'horizons_graha.json')

PIND = {
    'surya': '10', 'chandra': '301', 'budh': '199', 'shukra': '299',
    'mangal': '499', 'guru': '599', 'shani': '699',
}
# 20 तारीख़ें: JD(TT) 2426000.25 (जनवरी 1930) से, हर 2113.37 दिन पर
JD = [2426000.25 + 2113.37 * i for i in range(20)]
# नाक्षत्र काल के लिए: दो शहर, छह क्षण (UT) — 1972 से 2036, दिन के अलग पहर
STHAN = [('patna', 85.1376, 25.5941), ('delhi', 77.2090, 28.6139)]
JD_UT = [2441500.125 + 4700.371 * i for i in range(6)]
# चंद्र के पात के लिए: 30 क्षण, 1972 से 2030 — हर 733.31 दिन पर, ताकि पात के
# 173 दिन वाले झूले की हर कला पर कोई न कोई क्षण पड़े
JD_PAAT = [2441500.5 + 733.31 * i for i in range(30)]


def maango(command):
    q = {
        'format': 'text', 'COMMAND': "'%s'" % command, 'OBJ_DATA': "'NO'",
        'MAKE_EPHEM': "'YES'", 'EPHEM_TYPE': "'OBSERVER'", 'CENTER': "'500@399'",
        'TLIST': "'%s'" % ' '.join('%.2f' % j for j in JD), 'TLIST_TYPE': "'JD'",
        'TIME_TYPE': "'TT'", 'QUANTITIES': "'31'", 'ANG_FORMAT': "'DEG'",
        'CSV_FORMAT': "'YES'",
    }
    url = 'https://ssd.jpl.nasa.gov/api/horizons.api?' + urllib.parse.urlencode(q)
    # curl से, urllib से नहीं: इस मशीन पर Python का अपना प्रमाणपत्र-भंडार NASA
    # की कड़ी नहीं पहचानता, जबकि Windows का भंडार (जो curl लेता है) पहचानता
    # है। प्रमाणपत्र की जाँच बंद करना ग़लत इलाज होता — यह जाँच का डेटा है।
    return subprocess.run(['curl', '-sS', '--fail', '-m', '120', url],
                          check=True, capture_output=True).stdout.decode('utf-8')


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    out = {
        '_srot': 'NASA JPL Horizons API — observer table, geocentric (500@399), '
                 'quantity 31 (ObsEcLon, ObsEcLat), TIME_TYPE=TT, of-date ecliptic.',
        '_note': 'जाँच का डेटा। tools/horizons_lao.py से बना; हाथ से मत बदलना।',
        'jdTt': JD,
        'pind': {},
    }
    for naam, cmd in PIND.items():
        t = maango(cmd)
        if '$$SOE' not in t:
            sys.exit('Horizons ने तालिका नहीं दी (%s):\n%s' % (naam, t[:1500]))
        sarni = t[t.index('$$SOE') + 5:t.index('$$EOE')].strip().split('\n')
        rows = []
        for line in sarni:
            f = [x.strip() for x in line.split(',')]
            # date, (solar presence), (lunar presence), ObsEcLon, ObsEcLat
            sankhya = [x for x in f[1:] if re.match(r'^-?\d+\.\d+$', x)]
            rows.append([float(sankhya[0]), float(sankhya[1])])
        assert len(rows) == len(JD), (naam, len(rows))
        out['pind'][naam] = rows
        m = re.search(r'Target body name: (.*?)\s{2,}', t)
        print('%-8s %2d पंक्तियाँ · %s · पहली: %s' % (naam, len(rows), m.group(1) if m else '?', rows[0]))
        if naam == 'surya':
            out['_samay'] = [x.split(',')[0].strip() for x in sarni]
            head = t[:t.index('$$SOE')]
            out['_horizonsSir'] = [l.strip() for l in head.split('\n')
                                   if 'Time' in l and 'TT' in l][:2]
        time.sleep(1.5)

    # ── स्थानीय आभासी नाक्षत्र काल — लग्न की जड़ (→ kundali_test.dart) ──
    # मात्रा 7, धरती की सतह के एक बिंदु से, समय UT में। लग्न का सूत्र इसी
    # एक संख्या + तिरछाहट + अक्षांश से बनता है; यह मिल जाए तो लग्न मिल गया।
    out['lst'] = []
    for naam, lon, lat in STHAN:
        q = {
            'format': 'text', 'COMMAND': "'10'", 'OBJ_DATA': "'NO'",
            'MAKE_EPHEM': "'YES'", 'EPHEM_TYPE': "'OBSERVER'",
            'CENTER': "'coord@399'", 'COORD_TYPE': "'GEODETIC'",
            'SITE_COORD': "'%s,%s,0'" % (lon, lat),
            'TLIST': "'%s'" % ' '.join('%.3f' % j for j in JD_UT),
            'TLIST_TYPE': "'JD'", 'TIME_TYPE': "'UT'", 'QUANTITIES': "'7'",
            'ANG_FORMAT': "'DEG'", 'CSV_FORMAT': "'YES'",
        }
        url = 'https://ssd.jpl.nasa.gov/api/horizons.api?' + urllib.parse.urlencode(q)
        t = subprocess.run(['curl', '-sS', '--fail', '-m', '120', url],
                           check=True, capture_output=True).stdout.decode('utf-8')
        if '$$SOE' not in t:
            sys.exit('Horizons ने नाक्षत्र काल नहीं दिया (%s):\n%s' % (naam, t[:1500]))
        sarni = t[t.index('$$SOE') + 5:t.index('$$EOE')].strip().split('\n')
        ghante = []
        for line in sarni:
            f = [x.strip() for x in line.split(',')]
            sankhya = [x for x in f[1:] if re.match(r'^-?\d+\.\d+$', x)]
            ghante.append(float(sankhya[0]))        # घंटों में
        assert len(ghante) == len(JD_UT), (naam, len(ghante))
        out['lst'].append({'sthan': naam, 'longitude': lon, 'latitude': lat,
                           'jdUt': JD_UT, 'ghante': ghante})
        print('%-8s नाक्षत्र काल, %d क्षण · पहला: %s घंटे' % (naam, len(ghante), ghante[0]))
        time.sleep(1.5)

    # ── चंद्र-कक्षा का आरोही पात (क्षण-विशेष का) — स्पष्ट राहु की जाँच ──────
    # कक्षा के तत्व (ELEMENTS), पृथ्वी-केंद्रित, J2000 के क्रांतिवृत्त में। `OM`
    # ही पात है। उस दिन के विषुव में लाने के लिए जाँच इसमें अयन-चलन जोड़ती है।
    q = {
        'format': 'text', 'COMMAND': "'301'", 'OBJ_DATA': "'NO'",
        'MAKE_EPHEM': "'YES'", 'EPHEM_TYPE': "'ELEMENTS'", 'CENTER': "'500@399'",
        'REF_PLANE': "'ECLIPTIC'",
        'TLIST': "'%s'" % ' '.join('%.2f' % j for j in JD_PAAT),
        'TLIST_TYPE': "'JD'", 'CSV_FORMAT': "'YES'",
    }
    url = 'https://ssd.jpl.nasa.gov/api/horizons.api?' + urllib.parse.urlencode(q)
    t = subprocess.run(['curl', '-sS', '--fail', '-m', '120', url],
                       check=True, capture_output=True).stdout.decode('utf-8')
    if '$$SOE' not in t:
        sys.exit('Horizons ने चंद्र-कक्षा के तत्व नहीं दिए:\n%s' % t[:1500])
    sarni = t[t.index('$$SOE') + 5:t.index('$$EOE')].strip().split('\n')
    # JDTDB, तारीख़, EC, QR, IN, OM, …
    paat = [float(line.split(',')[5]) for line in sarni]
    assert len(paat) == len(JD_PAAT)
    out['chandraPaat'] = {
        '_note': 'OM — osculating ascending node, ecliptic & equinox J2000.',
        'jdTdb': JD_PAAT, 'omJ2000': paat,
    }
    print('चंद्र का पात, %d क्षण · पहला: %s°' % (len(paat), paat[0]))

    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('→', os.path.normpath(OUT))


if __name__ == '__main__':
    main()
