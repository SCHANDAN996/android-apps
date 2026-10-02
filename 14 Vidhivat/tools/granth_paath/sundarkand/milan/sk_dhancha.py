# -*- coding: utf-8 -*-
"""mool.json → dhancha.json: प्रसंग (पाठ) → खंड (कुंजी, शीर्षक, मूल)।"""
import sys, io, json
sys.stdout.reconfigure(encoding='utf-8')
ANK = str.maketrans('0123456789', '०१२३४५६७८९')
def da(n): return str(n).translate(ANK)
# (फ़ाइल, पहला दोहा, आख़िरी दोहा)
PRASANG = [('01', 1, 3), ('02', 4, 8), ('03', 9, 12), ('04', 13, 17), ('05', 18, 20),
           ('06', 21, 24), ('07', 25, 27), ('08', 28, 34), ('09', 35, 41), ('10', 42, 50),
           ('11', 51, 57), ('12', 58, 60)]
SORATHA = {12}
def banao():
    d = json.load(io.open('mool.json', encoding='utf-8'))
    ik = {u['doha']: u['bhag'] for u in d['ikai']}
    out = []
    for key, a, b in PRASANG:
        kh = []
        if key == '01':
            s = d['shlok']
            for i in range(3):
                kh.append({'kunji': 's%d' % (i + 1), 'shirshak': 'श्लोक ' + da(i + 1), 'mool': s[i * 4:i * 4 + 4]})
        for n in range(a, b + 1):
            for kism, ls in ik[n]:
                if kism == 'चौपाई':
                    g = [ls[i:i + 2] for i in range(0, len(ls), 2)]
                    for i, m in enumerate(g, 1):
                        kh.append({'kunji': '%d.%d' % (n, i), 'shirshak': 'चौपाई %s.%s' % (da(n), da(i)), 'mool': m})
                elif kism == 'छंद':
                    assert len(ls) % 4 == 0
                    g = [ls[i:i + 4] for i in range(0, len(ls), 4)]
                    for i, m in enumerate(g, 1):
                        sh = 'छंद %s' % da(n) if len(g) == 1 else 'छंद %s.%s' % (da(n), da(i))
                        kh.append({'kunji': '%dc%d' % (n, i), 'shirshak': sh, 'mool': m})
                else:
                    naam = 'सोरठा' if n in SORATHA else 'दोहा'
                    if len(ls) == 2:
                        kh.append({'kunji': '%dd' % n, 'shirshak': '%s %s' % (naam, da(n)), 'mool': ls})
                    else:
                        assert len(ls) == 4
                        kh.append({'kunji': '%dda' % n, 'shirshak': '%s %s (क)' % (naam, da(n)), 'mool': ls[:2]})
                        kh.append({'kunji': '%ddb' % n, 'shirshak': '%s %s (ख)' % (naam, da(n)), 'mool': ls[2:]})
        out.append({'key': key, 'pehla': a, 'aakhiri': b, 'khand': kh})
    return out
if __name__ == '__main__':
    out = banao()
    json.dump(out, io.open('dhancha.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print([(p['key'], len(p['khand'])) for p in out], sum(len(p['khand']) for p in out))
    for p in out:
        if p['key'] in sys.argv[1:]:
            for k in p['khand']:
                print('[%s]' % k['kunji'], ' / '.join(k['mool']))
