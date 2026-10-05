# -*- coding: utf-8 -*-
"""यक्ष प्रश्न — V (छपी पुस्तक, आँख से पढ़ा: v313_*.txt) बनाम K (विकिस्रोत ३.३१४) बनाम C (समीक्षित ३.२९७),
पंक्ति-दर-पंक्ति (अर्धश्लोक)।

    python yaksha3.py            जहाँ V और K अलग हैं (और C क्या कहता है)
    python yaksha3.py ginti      सार
    python yaksha3.py sab        हर पंक्ति
"""
import difflib
import glob
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402
import yaksha1 as Y  # noqa: E402


def v_panktiyan():
    """[(श्लोक-अंक, पंक्ति, वक्ता)] — v313_*.txt से, क्रम में।"""
    raw = []
    vakta = ''
    vdir = os.path.join(HERE, 'v313') if os.path.isdir(os.path.join(HERE, 'v313')) else HERE
    for f in sorted(glob.glob(os.path.join(vdir, 'v313_*.txt'))):
        for line in io.open(f, encoding='utf-8'):
            s = line.strip()
            if not s or s.startswith('#'):
                continue
            if s.startswith('@'):
                vakta = s[1:].strip()
                continue
            m = re.search(r'॥(\d+)॥$', s)
            raw.append([int(m.group(1)) if m else None, re.sub(r'\s*॥\d+॥$', ' ॥', s) if m else s, vakta])
            vakta = ''
    # जिन पंक्तियों पर अंक नहीं, उन्हें अगले अंक वाला श्लोक मिलता है
    nxt = None
    for r in reversed(raw):
        if r[0] is None:
            r[0] = nxt
        else:
            nxt = r[0]
    return [tuple(r) for r in raw]


def k_panktiyan():
    out = []
    for num, lines in Y.k_shlok(314):
        for l in lines:
            if re.match(r'^(यक्ष|युधिष्ठिर|युधिष्टिर|यूधिष्ठिर|वैशंपायन) उवाच', l):
                continue
            l = re.sub(r'^तु\. आश्व.*?\]', '', l)
            out.append((num, l))
    return out


def c_panktiyan():
    out = []
    for l in io.open(os.path.join(HERE, 'bori_03.txt'), encoding='utf-8', errors='replace'):
        m = re.match(r'^03(297)(\d\d\d)([a-z])\s+(.*)$', l)
        if m:
            out.append(('297.%d%s' % (int(m.group(2)), m.group(3)), m.group(4).strip()))
    return out


def paas(k, cand):
    """कुंजी k के सबसे पास cand [(लेबल, पाठ, कुंजी)] में कौन — (अनुपात, लेबल, पाठ)।"""
    best = (0.0, None, '')
    for lab, txt, ck in cand:
        if abs(len(ck) - len(k)) > max(len(k), len(ck)) * 0.6:
            continue
        r = difflib.SequenceMatcher(None, k, ck, autojunk=False).ratio()
        if r > best[0]:
            best = (r, lab, txt)
    return best


def main():
    V = v_panktiyan()
    K = [(n, t, kunji_dev(t)) for n, t in k_panktiyan()]
    C = [(n, t, kunji_dev(t)) for n, t in c_panktiyan()]
    # C में त्रिष्टुभ् «a; b» एक पंक्ति में — आधे-आधे भी उम्मीदवार
    C2 = list(C)
    for n, t, _ in C:
        if ';' in t:
            for i, h in enumerate(t.split(';')):
                C2.append((n + '/%d' % (i + 1), h.strip(), kunji_dev(h)))
    mode = sys.argv[1] if len(sys.argv) > 1 else ''
    ek = alag = kn = cn = 0
    k_mile = set()
    for num, line, vakta in V:
        vk = kunji_dev(line)
        rk, kl, kt = paas(vk, K)
        rc, cl, ct = paas(vk, C2)
        if rk >= 0.6:
            k_mile.add((kl, kt))
        if rk < 0.6:
            kn += 1
        if rc < 0.6:
            cn += 1
        same = rk >= 0.999
        ek += same
        alag += (not same and rk >= 0.6)
        if mode == 'ginti':
            continue
        if mode == 'sab' or not same:
            print('V%-4s %s' % (num, line))
            if rk >= 0.6:
                if not same:
                    print('  K %-8s %s' % (kl, kt))
            else:
                print('  K —  (सबसे पास %.2f: %s)' % (rk, kt[:50]))
            if rc >= 0.6:
                if rc < 0.999:
                    print('  C %-8s %s' % (cl, ct))
                else:
                    print('  C %-8s =' % cl)
            else:
                print('  C —')
    print('V की पंक्तियाँ', len(V), '· K से हूबहू', ek, '· K से अलग', alag, '· K में नहीं', kn, '· C में नहीं', cn)
    baaki = [(n, t) for n, t, _ in K if (n, t) not in k_mile]
    print('K की पंक्तियाँ जो V में नहीं:', len(baaki))
    if mode != 'ginti':
        for n, t in baaki:
            print('  K', n, t)


if __name__ == '__main__':
    main()
