# -*- coding: utf-8 -*-
"""S + सुधार → mool.json  {'purva': [...], 'naam': [...], 'phal': [...]} — आधे-श्लोक की पंक्तियाँ।"""
import sys, io, json, re
sys.stdout.reconfigure(encoding='utf-8')
from vs_padho import S_padho
# (हिस्सा, श्लोक, पुराना, नया, किस पर)
SUDHAR = [
    ('naam', 54, 'सात्वताम्पतिः ॥ ॥ विनियोज्यः', 'सात्वतां पतिः', 'S में कोष्ठक का कचरा'),
    ('phal', 22, 'जगतः प्रभुमव्ययम्', 'जगतः प्रभवाप्ययम्', 'G + चार छपी पुस्तकें'),
    ('naam', 12, 'समात्माऽसम्मितः', 'समात्मा सम्मितः', 'N, G, छपी पुस्तक (1934)'),
    ('naam', 88, 'न्यग्रोधोऽदुम्बरो', 'न्यग्रोधोदुम्बरो', 'N, G, दो छपी पुस्तकें — नाम उदुम्बरः है'),
]
def main():
    S = S_padho()
    lage = set()
    out = {}
    for h, lines in S.items():
        nl = []
        for i, x in enumerate(lines):
            x = re.sub(r'\s*[॥।]+\s*$', '', x).strip()
            for k, (hh, n, a, b, _) in enumerate(SUDHAR):
                if hh == h and n == i // 2 + 1 and a in x:
                    x = x.replace(a, b); lage.add(k)
            assert '॥' not in x and '(' not in x, x
            nl.append(x)
        out[h] = nl
    assert len(lage) == len(SUDHAR), lage
    json.dump(out, io.open('mool.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    return out
if __name__ == '__main__':
    out = main()
    a, b = (int(x) for x in sys.argv[2:4]) if len(sys.argv) > 3 else (1, 999)
    h = sys.argv[1] if len(sys.argv) > 1 else 'naam'
    L = out[h]
    for n in range(a, min(b, len(L) // 2) + 1):
        print('%d. %s। %s॥' % (n, L[2 * n - 2], L[2 * n - 1]))
