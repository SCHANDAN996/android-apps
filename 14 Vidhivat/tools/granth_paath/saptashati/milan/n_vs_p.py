# -*- coding: utf-8 -*-
import sys
sys.stdout.reconfigure(encoding='utf-8')
from ss_padho import N_padho, bina_ank
from ocr2 import dhundho
from milan import kunji_dev
for key in sys.argv[1:]:
    ok = bad = 0
    for line in N_padho(key):
        qk = kunji_dev(bina_ank(line))
        if not qk: continue
        r, tuk, k = dhundho(bina_ank(line), 'm2024')
        if k == qk: ok += 1; continue
        bad += 1
        # OCR का वही हिस्सा: बीच वाली पंक्ति
        print('%s N: %s\n      P %.2f: %s' % (key, line, r, tuk[:220]))
    print(key, 'm2024 से हूबहू', ok, 'अलग', bad, '\n')
