# -*- coding: utf-8 -*-
"""पुराणों की अपनी सूचियाँ — स्रोत उतारना (सिर्फ़ पढ़ने/मिलाने के लिए)।

    python pu_lao.py khoj <शब्द>         विकिस्रोत में ढूँढो
    python pu_lao.py ws <शीर्षक> <फ़ाइल>   विकिस्रोत का पन्ना → फ़ाइल
    python pu_lao.py url <पता> <फ़ाइल>    कोई भी पन्ना → फ़ाइल
"""
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
# `lao` (पन्ना उतारने वाला) सप्तशती के milan/ में है
sys.path.insert(0, os.path.abspath(os.path.join(HERE, '..', '..', 'saptashati', 'milan')))
sys.stdout.reconfigure(encoding='utf-8')
import lao  # noqa: E402

cmd = sys.argv[1]
if cmd == 'khoj':
    for t, n in lao.search(' '.join(sys.argv[2:]), n=25):
        print(n, t)
elif cmd == 'prefix':
    for t in lao.prefix(sys.argv[2]):
        print(t)
elif cmd == 'ws':
    t = lao.raw(sys.argv[2])
    io.open(os.path.join(HERE, sys.argv[3]), 'w', encoding='utf-8').write(t)
    print(len(t), 'अक्षर →', sys.argv[3])
elif cmd == 'url':
    try:
        b = lao.lao(sys.argv[2], tries=2)
    except Exception as e:  # noqa
        print('सीधा नहीं:', e)
        b = lao.curl(sys.argv[2], browser=True)
    io.open(os.path.join(HERE, sys.argv[3]), 'wb').write(b)
    print(len(b), 'bytes →', sys.argv[3])
