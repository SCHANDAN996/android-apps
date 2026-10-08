# -*- coding: utf-8 -*-
"""भीष्म स्तवराज — विकिस्रोत (दाक्षिणात्य १२.४६) और समीक्षित (१२.४७) को पंक्तियों में काटना; आमने-सामने नाप।

    python bs_k.py ginti      दोनों की पंक्तियाँ, और K की कितनी पंक्तियाँ C में हैं
    python bs_k.py k          K की सब पंक्तियाँ (श्लोक-अंक के साथ)
"""
import difflib
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev  # noqa: E402

DEV = re.compile('[\u0900-\u097f]')


def k_panktiyan():
    """[(श्लोक-अंक, पंक्ति, वक्ता?)] — विकिस्रोत की तालिका से।"""
    t = io.open(os.path.join(HERE, 'ws_12_046.txt'), encoding='utf-8').read()
    t = t[:t.index('</table>')]   # तालिका के बाद टिप्पणियाँ हैं — पाठ नहीं
    out = []
    for cell in re.split(r'<tr>', t)[1:]:
        m = re.search(r'12-46-(\d+)([a-zA-Z]?)', cell)
        num = (m.group(1) + m.group(2)) if m else ''
        body = re.sub(r'<td>\s*12-46-[^\n<]*', '', cell)
        body = re.sub(r"'''|</?t[rd]>|</table>", '', body)
        for l in re.split(r'<BR>|\n', body):
            l = l.strip()
            if not DEV.search(l):
                continue
            out.append([num, l])
    # जिन पंक्तियों पर अंक नहीं (अंक अगली कोठरी में आता है) — अगला अंक
    nxt = ''
    for r in reversed(out):
        if r[0]:
            nxt = r[0]
        else:
            r[0] = nxt
    return [tuple(r) for r in out]


def c_panktiyan():
    # समीक्षित संस्करण का शांति पर्व (bori_12.txt) — इसी फ़ोल्डर में उतारकर रखो
    t = io.open(os.path.join(HERE, 'bori_12.txt'), encoding='utf-8').read()
    out = []
    for m in re.finditer(r'^12047(\d{3})([a-z]?)\s+(.*)$', t, re.M):
        if not m.group(2):
            continue   # वक्ता वाली पंक्ति
        for part in m.group(3).split(';'):
            out.append(('%d%s' % (int(m.group(1)), m.group(2)), part.strip()))
    return out


if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else 'ginti'
    K = k_panktiyan()
    C = c_panktiyan()
    if mode == 'k':
        for n, l in K:
            print('%-6s %s' % (n, l))
    else:
        ck = [kunji_dev(l) for n, l in C]
        ek = pas = nahi = 0
        nahi_l = []
        for n, l in K:
            if re.search(r'उवाच', l):
                continue
            # K की एक पंक्ति में अक्सर दो पाद «।» से जुड़े — C में वे अलग पंक्तियाँ हैं
            k = kunji_dev(l)
            best = 0.0
            for i in range(len(ck)):
                for j in (1, 2):
                    cand = ''.join(ck[i:i + j])
                    if abs(len(cand) - len(k)) > max(10, len(k) // 3):
                        continue
                    r = 1.0 if cand == k else difflib.SequenceMatcher(None, k, cand, autojunk=False).ratio()
                    best = max(best, r)
            if best == 1.0:
                ek += 1
            elif best >= 0.75:
                pas += 1
            else:
                nahi += 1
                nahi_l.append((n, l, round(best, 2)))
        nums = sorted({int(re.match(r'\d+', n).group(0)) for n, l in K if n})
        print('K: पंक्तियाँ', len(K), '· श्लोक-अंक', nums[0], '…', nums[-1])
        print('C: पंक्तियाँ', len(C), '· श्लोक', 72)
        print('K की पंक्तियाँ — C में हूबहू %d · पास %d · C में नहीं %d' % (ek, pas, nahi))
        if mode == 'nahi':
            for x in nahi_l:
                print('  ', x)
