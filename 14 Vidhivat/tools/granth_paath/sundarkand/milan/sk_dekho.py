# -*- coding: utf-8 -*-
import sys
sys.stdout.reconfigure(encoding='utf-8')
from sk_padho import OCR, dhundho
for q in sys.argv[1:]:
    print('##', q)
    for o in OCR:
        r, t, _ = dhundho(q, o)
        print('   %-4s %.2f %s' % (o, r, t[:230]))
