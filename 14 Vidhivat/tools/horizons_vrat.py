# -*- coding: utf-8 -*-
"""आठ व्रत-नियमों की तारीख़ें — गणित की जाँच NASA JPL Horizons से (→ D-116, docs/30 §४)।

    cd engine && dart run tool/vrat_saal.dart 2029 2030 > ../tools/_vrat_saal.json
    python tools/horizons_vrat.py tools/_vrat_saal.json

`vrat_saal.dart` इंजन की तारीख़, तिथि का आरंभ-अंत और व्यापिनी की खिड़की देता है। यह औज़ार
हर तिथि के आरंभ और अंत का **असली क्षण** Horizons से निकालता है (वही तरीक़ा जो
`horizons_tithi.py` का — चंद्र और सूर्य के देशांतर का अंतर 12° के गुणज को कब पार करता है)
और बताता है:

- इंजन का समय NASA से कितने सेकंड अलग है;
- तिथि की सीमा व्यापिनी की खिड़की से कितनी दूर है (**हाशिया**) — हाशिया छोटा हो तो वह
  तारीख़ "किनारे का मामला" है और संदर्भ-पंचांग से अलग से मिलानी चाहिए;
- NASA के समय से भी वही दिन चुना जाता या नहीं।

नतीजा → `engine/test/data/horizons_vrat.json` (जाँच का डेटा, ऐप का नहीं)।
"""
import datetime
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import horizons_tithi as H  # noqa: E402

OUT = os.path.join(HERE, '..', 'engine', 'test', 'data', 'horizons_vrat.json')
IST = datetime.timedelta(hours=5, minutes=30)
KINARA_MIN = 20          # इतने मिनट से कम हाशिया → किनारे का मामला


def dt(s):
    return datetime.datetime.strptime(s, '%Y-%m-%dT%H:%M:%S')


def nasa(ist):
    """इंजन के बताए क्षण (IST) के आसपास NASA का पार → IST, या None"""
    m = H.paar(ist - IST)
    return None if m is None else m + IST


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    src = sys.argv[1]
    saal = [int(x) for x in sys.argv[2:]] or None
    raw = io.open(src, 'rb').read()
    text = raw.decode('utf-16') if raw[:2] in (b'\xff\xfe', b'\xfe\xff') else raw.decode('utf-8-sig')
    d = json.loads(text)
    out = {
        '_srot': 'NASA JPL Horizons API — चंद्र (301) और सूर्य (10), geocentric, quantity 31, UT, हर मिनट; '
                 'अंतर 12° के गुणज को जहाँ पार करे। इंजन की तारीख़ें: engine/tool/vrat_saal.dart (दिल्ली)।',
        '_note': 'जाँच का डेटा। tools/horizons_vrat.py से बना; हाथ से मत बदलना। समय भारतीय (IST)। '
                 'hashiyaMin — तिथि की सीमा व्यापिनी की खिड़की से कितने मिनट दूर (इंजन के समय से)।',
        'entries': [],
    }
    for x in d:
        if not x.get('mila') or (saal and x['saal'] not in saal):
            continue
        ts, te = dt(x['tithiStart']), dt(x['tithiEnd'])
        ks, ke = dt(x['kaalStart']), dt(x['kaalEnd'])
        ns, ne = nasa(ts), nasa(te)
        fs = None if ns is None else round((ts - ns).total_seconds())
        fe = None if ne is None else round((te - ne).total_seconds())
        # हाशिया: खिड़की के सबसे पास वाली तिथि-सीमा कितनी दूर है (तिथि खिड़की को ढकती हो तब)
        hashiya = None
        if not x.get('vaarPehle') and ts.date() <= ks.date() <= te.date():
            hashiya = round(min(abs((ks - ts).total_seconds()), abs((te - ks).total_seconds()),
                                abs((ke - ts).total_seconds()), abs((te - ke).total_seconds())) / 60)
        e = {
            'id': x['id'], 'saal': x['saal'], 'date': x['date'], 'vyapini': x['vyapini'],
            'tithiStart': x['tithiStart'], 'tithiEnd': x['tithiEnd'],
            'nasaTithiStart': None if ns is None else ns.strftime('%Y-%m-%dT%H:%M:%S'),
            'nasaTithiEnd': None if ne is None else ne.strftime('%Y-%m-%dT%H:%M:%S'),
            'aarambhFarqSec': fs, 'antFarqSec': fe,
            'kaalStart': x['kaalStart'], 'kaalEnd': x['kaalEnd'], 'hashiyaMin': hashiya,
            'kinara': hashiya is not None and hashiya < KINARA_MIN,
            'missedKaal': x['missedKaal'], 'ambiguous': x['ambiguous'],
            'otherCandidate': x['otherCandidate'], 'shiftedForBhadra': x['shiftedForBhadra'],
        }
        out['entries'].append(e)
        print('%d %-20s %s · आरंभ %+4s से · अंत %+4s से · हाशिया %s मि%s%s%s' % (
            x['saal'], x['id'], x['date'],
            '—' if fs is None else fs, '—' if fe is None else fe,
            '—' if hashiya is None else hashiya,
            '  ⚠ किनारा' if e['kinara'] else '',
            '  · दो दावेदार → %s' % x['otherCandidate'] if x['ambiguous'] else '',
            '  · काल छूटा' if x['missedKaal'] else ''))
    farq = [abs(v) for e in out['entries'] for v in (e['aarambhFarqSec'], e['antFarqSec']) if v is not None]
    print('तारीख़ें %d · सीमाएँ %d · इंजन बनाम NASA: सबसे बड़ा फ़र्क़ %d से, औसत %.1f से'
          % (len(out['entries']), len(farq), max(farq), sum(farq) / len(farq)))
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('→', os.path.normpath(OUT))


if __name__ == '__main__':
    main()
