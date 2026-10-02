# -*- coding: utf-8 -*-
"""NASA JPL Horizons से तिथि-समाप्ति के **असली क्षण** → `engine/test/data/horizons_tithi.json`

    python tools/horizons_tithi.py

`reference_dates.json` में संदर्भ-पंचांग के छपे समय हैं — मिनट तक, और (जैसा इसी
औज़ार से निकला) असली क्षण से लगभग एक मिनट पहले। यह औज़ार उन्हीं तारीख़ों के लिए
Horizons से चंद्र और सूर्य का आभासी देशांतर (मात्रा 31, भू-केंद्रित, **UT** में,
हर मिनट) लेता है और देखता है कि दोनों का अंतर 12° के गुणज को किस क्षण पार करता
है। वही तिथि का अंत है — किसी पंचांग के सूत्र से नहीं, NASA की स्थितियों से।

जाँच का डेटा है, ऐप का नहीं (→ `tools/horizons_lao.py` की टिप्पणी)।
"""
import datetime
import io
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
REF = os.path.join(HERE, '..', 'engine', 'test', 'data', 'reference_dates.json')
OUT = os.path.join(HERE, '..', 'engine', 'test', 'data', 'horizons_tithi.json')
IST = datetime.timedelta(hours=5, minutes=30)


def hz(cmd, start, stop):
    q = {'format': 'text', 'COMMAND': "'%s'" % cmd, 'OBJ_DATA': "'NO'", 'MAKE_EPHEM': "'YES'",
         'EPHEM_TYPE': "'OBSERVER'", 'CENTER': "'500@399'", 'START_TIME': "'%s'" % start,
         'STOP_TIME': "'%s'" % stop, 'STEP_SIZE': "'1m'", 'QUANTITIES': "'31'",
         'ANG_FORMAT': "'DEG'", 'CSV_FORMAT': "'YES'", 'TIME_TYPE': "'UT'"}
    url = 'https://ssd.jpl.nasa.gov/api/horizons.api?' + urllib.parse.urlencode(q)
    t = None
    for koshish in range(4):               # NASA का द्वार कभी-कभी देर करता है
        r = subprocess.run(['curl', '-sS', '--fail', '-m', '90', url], capture_output=True)
        if r.returncode == 0 and b'$$SOE' in r.stdout:
            t = r.stdout.decode('utf-8')
            break
        time.sleep(5 * (koshish + 1))
    if t is None:
        sys.exit('Horizons ने जवाब नहीं दिया: %s %s' % (cmd, start))
    rows = []
    for line in t[t.index('$$SOE') + 5:t.index('$$EOE')].strip().split('\n'):
        f = [x.strip() for x in line.split(',')]
        nums = [x for x in f[1:] if re.match(r'^-?\d+\.\d+$', x)]
        rows.append(float(nums[0]))
    time.sleep(1.0)
    return rows


def paar(ut_andaaz):
    """`ut_andaaz` के आसपास 12° के गुणज का पार होना → UT (datetime) या None"""
    shuru = ut_andaaz - datetime.timedelta(minutes=5)
    a = shuru.strftime('%Y-%m-%d %H:%M')
    b = (ut_andaaz + datetime.timedelta(minutes=7)).strftime('%Y-%m-%d %H:%M')
    moon, sun = hz('301', a, b), hz('10', a, b)
    el = [(m - s) % 360.0 for m, s in zip(moon, sun)]
    for i in range(len(el) - 1):
        if el[i] // 12 != el[i + 1] // 12 or el[i + 1] < el[i]:
            target = (el[i] // 12 + 1) * 12
            frac = (target - el[i]) / ((el[i + 1] - el[i]) % 360)
            return shuru + datetime.timedelta(minutes=i + frac)
    return None


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    ref = json.load(io.open(REF, encoding='utf-8'))
    out = {
        '_srot': 'NASA JPL Horizons API — चंद्र (301) और सूर्य (10), observer table, '
                 'geocentric (500@399), quantity 31 (ObsEcLon), TIME_TYPE=UT, हर मिनट; '
                 'अंतर 12° के गुणज को जहाँ पार करे (दो मिनटों के बीच सीधी रेखा से)।',
        '_note': 'जाँच का डेटा। tools/horizons_tithi.py से बना; हाथ से मत बदलना। '
                 'tithiAntIst — तिथि का अंत, भारतीय समय में, सेकंड तक। '
                 'sandarbh — संदर्भ-पंचांग का छपा समय (मिनट तक), तुलना के लिए।',
        'entries': [],
    }
    for e in ref['entries']:
        x = e.get('expected')
        if not x or 'tithiEndsAt' not in x:
            continue
        hh, mm = map(int, x['tithiEndsAt'].split(':'))
        ist = datetime.datetime.strptime(e['date'], '%Y-%m-%d') + datetime.timedelta(hours=hh, minutes=mm)
        mila = None
        for din in (0, 1):                 # अंत अगले दिन भोर में भी हो सकता है
            mila = paar(ist - IST + datetime.timedelta(days=din))
            if mila:
                break
        if not mila:
            print('✗', e['date'], '— पार नहीं मिला')
            continue
        ant = mila + IST
        farq = round((ant - (ist + datetime.timedelta(days=din))).total_seconds())
        out['entries'].append({
            'date': e['date'], 'city': e['city'],
            'tithiAntIst': ant.strftime('%Y-%m-%dT%H:%M:%S'),
            'sandarbh': x['tithiEndsAt'], 'sandarbhSeFarqSec': farq,
        })
        print('%s %-8s NASA %s · संदर्भ %s · संदर्भ से %+d से'
              % (e['date'], e['city'], ant.strftime('%d %H:%M:%S'), x['tithiEndsAt'], farq))
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('→', os.path.normpath(OUT), len(out['entries']))


if __name__ == '__main__':
    main()
