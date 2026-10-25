# -*- coding: utf-8 -*-
"""टुकड़े (सब के सब) जिस पन्ने पर हों — हर किताब में।  python -P dhoondo.py टुकड़ा1 [टुकड़ा2 …]"""
import sys
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import khoj
sys.stdout.reconfigure(encoding='utf-8')
ks = [khoj.saaf(k) for k in sys.argv[1:]]
for b in khoj.kitabein():
    for i, p in enumerate(khoj.panne(b)):
        s = khoj.saaf(p)
        if all(k in s for k in ks):
            j = s.find(ks[0])
            print(b, i, '|', s[max(0, j - 30):j + 110])
