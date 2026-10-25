# -*- coding: utf-8 -*-
"""छपे पन्ने का वह टुकड़ा काटो जिसमें मंत्र है — आँख से पढ़ने के लिए (hOCR की पंक्ति-जगहों से)।

  python -P dekho.py <किताब> <n> <M..|"पाठ"> [ऊपर-नीचे पंक्तियाँ=2]
  → src/kat/<किताब>_<n>_<M>.jpg  (और चुनी पंक्तियों का OCR छापता है)
"""
import html
import io
import json
import os
import re
import sys
import urllib.parse
import urllib.request

from PIL import Image

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, JAD)
import khoj  # noqa: E402
SRC = khoj.SRC

PAGE_RE = re.compile(r'<div class="ocr_page" id="page_(\d+)" title="[^"]*?bbox (\d+) (\d+) (\d+) (\d+)')
LINE_RE = re.compile(r'<span class="ocr_(?:line|caption|header|textfloat)" id="[^"]+" title="bbox (\d+) (\d+) (\d+) (\d+)[^"]*">(.*?)</span>\s*(?=<span class="ocr_(?:line|caption|header|textfloat)"|</p>)', re.S)
WORD_RE = re.compile(r'<span class="ocrx_word"[^>]*>(.*?)</span>', re.S)


def hocr(naam):
    p = os.path.join(SRC, naam + '_hocr.html')
    if not os.path.exists(p):
        ia = khoj.kitabein()[naam]
        files = json.load(urllib.request.urlopen('https://archive.org/metadata/%s/files' % ia, timeout=120))['result']
        n = [f['name'] for f in files if f['name'].endswith('_hocr.html')][0]
        data = urllib.request.urlopen('https://archive.org/download/%s/%s' % (ia, urllib.parse.quote(n)), timeout=900).read()
        io.open(p, 'wb').write(data)
    return io.open(p, encoding='utf-8').read()


def panna_panktiyan(naam, n):
    h = hocr(naam)
    starts = [(m.start(), int(m.group(1)), tuple(int(x) for x in m.group(2, 3, 4, 5))) for m in PAGE_RE.finditer(h)]
    for i, (pos, num, bbox) in enumerate(starts):
        if num == n:
            end = starts[i + 1][0] if i + 1 < len(starts) else len(h)
            chunk = h[pos:end]
            lines = []
            for m in LINE_RE.finditer(chunk):
                words = [html.unescape(w) for w in WORD_RE.findall(m.group(5))]
                lines.append(((int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))), ' '.join(words)))
            return bbox, lines
    raise SystemExit('पन्ना %d नहीं' % n)


def chitra(naam, n):
    d = os.path.join(SRC, 'img')
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, '%s_%d.jpg' % (naam, n))
    if not os.path.exists(p):
        ia = khoj.kitabein()[naam]
        u = 'https://archive.org/download/%s/page/n%d.jpg' % (ia, n)
        io.open(p, 'wb').write(urllib.request.urlopen(u, timeout=300).read())
    return p


def main():
    naam, n, kya = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    pad = int(sys.argv[4]) if len(sys.argv) > 4 else 2
    if re.fullmatch(r'M\d\d', kya):
        suchi = json.load(io.open(os.path.join(JAD, 'suchi_24oct.json'), encoding='utf-8'))
        paath = [m['paath'] for m in suchi if m['id'] == kya][0]
    else:
        paath = kya
    sh = khoj.shabd(paath)
    (px0, py0, px1, py1), lines = panna_panktiyan(naam, n)
    score = []
    for bb, t in lines:
        s = khoj.saaf(t)
        score.append(sum(1 for x in sh if x in s) + sum(0.5 for x in sh if len(x) >= 6 and x not in s and x[:4] in s))
    # सबसे भारी लगातार गुच्छा (बीच में एक ख़ाली पंक्ति चल जाती है)
    best, bi, bj = 0, 0, -1
    for i in range(len(lines)):
        tot, gap = 0, 0
        for j in range(i, len(lines)):
            if score[j] > 0:
                tot += score[j]
                gap = 0
            else:
                gap += 1
                if gap > 1:
                    break
            if tot > best:
                best, bi, bj = tot, i, j
    if bj < 0:
        raise SystemExit('इस पन्ने पर मंत्र के शब्द नहीं')
    i0, j0 = max(0, bi - pad), min(len(lines) - 1, bj + pad)
    y0 = min(lines[k][0][1] for k in range(i0, j0 + 1))
    y1 = max(lines[k][0][3] for k in range(i0, j0 + 1))
    for k in range(i0, j0 + 1):
        print('%s %s' % ('*' if score[k] else ' ', lines[k][1]))
    im = Image.open(chitra(naam, n))
    sx = im.size[0] / float(px1 - px0)
    sy = im.size[1] / float(py1 - py0)
    box = (0, max(0, int((y0 - 25) * sy)), im.size[0], min(im.size[1], int((y1 + 25) * sy)))
    kat = im.crop(box)
    w = 1400
    kat = kat.resize((w, max(1, int(kat.size[1] * w / kat.size[0]))))
    d = os.path.join(SRC, 'kat')
    os.makedirs(d, exist_ok=True)
    out = os.path.join(d, '%s_%d_%s.jpg' % (naam, n, kya if re.fullmatch(r'M\d\d', kya) else 'x'))
    kat.save(out, quality=88)
    print(out)


if __name__ == '__main__':
    main()
