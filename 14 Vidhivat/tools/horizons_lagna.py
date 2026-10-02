# -*- coding: utf-8 -*-
"""NASA JPL Horizons से **लग्न की जाँच का डेटा** → `engine/test/data/horizons_lagna.json`

    python tools/horizons_lagna.py

## विचार
लग्न = क्रांतिवृत्त का वह बिंदु जो पूर्वी क्षितिज पर उग रहा है। सूर्य हमेशा
क्रांतिवृत्त पर रहता है (अक्षांश 1.2 विकला से कम)। इसलिए जिस क्षण सूर्य का
केंद्र **ज्यामितीय** क्षितिज पर हो (बिना वायुमंडल के, ऊँचाई ठीक 0°):

    उगते समय   लग्न = सूर्य का सायन देशांतर
    डूबते समय  लग्न = सूर्य का सायन देशांतर + 180°

Horizons दोनों देता है — किसी शहर से सूर्य की ऊँचाई (मात्रा 4, airless) और उसका
आभासी देशांतर (मात्रा 31)। यानी लग्न का "सही जवाब" पूरा NASA से आता है; हमारे
सूत्र का उसमें कोई हाथ नहीं। साल भर के सूर्योदय-सूर्यास्त लग्न के पूरे 360°
ढक लेते हैं।

जाँच का डेटा है, ऐप का नहीं।
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
OUT = os.path.join(HERE, '..', 'engine', 'test', 'data', 'horizons_lagna.json')

# (नाम, देशांतर पूर्व, अक्षांश, सूर्योदय के आसपास UT घंटा, सूर्यास्त के आसपास UT घंटा)
STHAN = [
    ('patna', 85.1376, 25.5941),
    ('delhi', 77.2090, 28.6139),
    ('chennai', 80.2707, 13.0827),
    ('srinagar', 74.7973, 34.0837),
]
# हर शहर के लिए ये तारीख़ें — चार दशक, बारहों महीने
TARIKH = ['1975-01-15', '1988-03-21', '1996-05-10', '2003-07-04', '2011-08-28',
          '2019-10-17', '2026-11-30', '1964-02-09', '1952-06-21', '2034-12-22',
          '1947-04-13', '2000-09-23']


def hz(lon, lat, start, stop):
    q = {'format': 'text', 'COMMAND': "'10'", 'OBJ_DATA': "'NO'", 'MAKE_EPHEM': "'YES'",
         'EPHEM_TYPE': "'OBSERVER'", 'CENTER': "'coord@399'", 'COORD_TYPE': "'GEODETIC'",
         'SITE_COORD': "'%s,%s,0'" % (lon, lat), 'START_TIME': "'%s'" % start,
         'STOP_TIME': "'%s'" % stop, 'STEP_SIZE': "'1m'", 'QUANTITIES': "'4,31'",
         'ANG_FORMAT': "'DEG'", 'CSV_FORMAT': "'YES'", 'TIME_TYPE': "'UT'",
         'APPARENT': "'AIRLESS'"}
    url = 'https://ssd.jpl.nasa.gov/api/horizons.api?' + urllib.parse.urlencode(q)
    for koshish in range(4):
        r = subprocess.run(['curl', '-sS', '--fail', '-m', '90', url], capture_output=True)
        if r.returncode == 0 and b'$$SOE' in r.stdout:
            t = r.stdout.decode('utf-8')
            rows = []
            for line in t[t.index('$$SOE') + 5:t.index('$$EOE')].strip().split('\n'):
                f = [x.strip() for x in line.split(',')]
                nums = [float(x) for x in f[1:] if re.match(r'^-?\d+\.\d+$', x)]
                # Azi, Elev, ObsEcLon, ObsEcLat
                rows.append((f[0], nums[1], nums[2]))
            time.sleep(1.0)
            return rows
        time.sleep(5 * (koshish + 1))
    sys.exit('Horizons ने जवाब नहीं दिया: %s' % start)


def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    out = {
        '_srot': 'NASA JPL Horizons API — सूर्य (10), observer table, शहर की सतह से '
                 '(coord@399, geodetic), quantities 4 (airless elevation) और 31 (ObsEcLon), '
                 'TIME_TYPE=UT, हर मिनट; ऊँचाई जहाँ शून्य पार करे (दो मिनटों के बीच सीधी रेखा)।',
        '_note': 'जाँच का डेटा। tools/horizons_lagna.py से बना; हाथ से मत बदलना। '
                 'lagnaSayan — उस क्षण लग्न का सायन देशांतर: उगते समय सूर्य का देशांतर, '
                 'डूबते समय +180°।',
        'entries': [],
    }
    for naam, lon, lat in STHAN:
        for din in TARIKH:
            d0 = datetime.datetime.strptime(din, '%Y-%m-%d')
            # भारत में सूर्योदय ~00:30 UT (±1.5 घं), सूर्यास्त ~12:30 UT (±1.5 घं)
            for kism, beech in (('uday', 0.5), ('ast', 12.5)):
                a = d0 + datetime.timedelta(hours=beech - 2.0)
                b = d0 + datetime.timedelta(hours=beech + 2.0)
                rows = hz(lon, lat, a.strftime('%Y-%m-%d %H:%M'), b.strftime('%Y-%m-%d %H:%M'))
                mila = None
                for i in range(len(rows) - 1):
                    e0, e1 = rows[i][1], rows[i + 1][1]
                    if (kism == 'uday' and e0 < 0 <= e1) or (kism == 'ast' and e0 >= 0 > e1):
                        frac = (0 - e0) / (e1 - e0)
                        ut = a + datetime.timedelta(minutes=i + frac)
                        l0, l1 = rows[i][2], rows[i + 1][2]
                        lam = l0 + ((l1 - l0 + 540) % 360 - 180) * frac
                        mila = (ut, lam % 360)
                        break
                if not mila:
                    print('✗ %s %s %s — क्षितिज पार नहीं मिला' % (naam, din, kism))
                    continue
                ut, lam = mila
                lagna = lam if kism == 'uday' else (lam + 180) % 360
                out['entries'].append({
                    'sthan': naam, 'longitude': lon, 'latitude': lat, 'kism': kism,
                    'ut': ut.strftime('%Y-%m-%dT%H:%M:%S.') + '%03d' % (ut.microsecond // 1000),
                    'lagnaSayan': round(lagna, 5),
                })
                print('%-8s %s %-4s UT %s  लग्न %.4f°' % (naam, din, kism, ut.strftime('%H:%M:%S'), lagna))
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print('→', os.path.normpath(OUT), len(out['entries']))


if __name__ == '__main__':
    main()
