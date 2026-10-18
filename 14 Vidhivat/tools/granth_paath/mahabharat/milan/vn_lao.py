# -*- coding: utf-8 -*-
"""विदुर नीति के स्रोत उतारना — `vn3.py` इन्हीं से चलता है। स्रोत repo में नहीं रखे जाते (पते `docs/18` §३६);
जिस फ़ोल्डर में उतारने हों, वह `VN_SRC` में दो। (13–16 अक्टूबर के स्रोत temp-फ़ोल्डर में थे और वह साफ़ हो
गया — इसलिए यह फ़ाइल।)

    python vn_lao.py                       छहों स्रोत (जो पहले से हैं, वे दोबारा नहीं)
    python vn_lao.py panna 61 62 …         पुस्तिका के पन्नों के चित्र → VN_SRC/panne/g_<leaf>.jpg  (leaf = छपा पृष्ठ + 17)
    python vn_lao.py mbh 136 137 …         गीताप्रेस के महाभारत (खंड ३) के पन्ने → VN_SRC/panne/m_<leaf>.jpg
    python vn_lao.py kaat out.png g_78:x0:y0:x1:y1 [m_136:…] [--w 1400]
                                           पन्ने का टुकड़ा काटकर बड़ा करना (x, y अनुपात में 0–1; कई टुकड़े एक के नीचे एक)
    python vn_lao.py chhota g_78           पूरा पन्ना आधे आकार में (पहली नज़र के लिए) → panne/g_78_chhota.png

उतारना `curl` से — Windows के Python में कुछ जगह SSL अटकता है।
"""
import io
import json
import os
import subprocess
import sys
import time
import urllib.parse

sys.stdout.reconfigure(encoding='utf-8')
SRC = os.environ.get('VN_SRC') or os.path.dirname(os.path.abspath(__file__))
PANNE = os.path.join(SRC, 'panne')

G_ID = 'vidur-niti-from-maha-bharat-udyog-parva-gita-press-gorakhpur'
P_ID = 'Zqzh_mahabharat-udyog-parva-aur-bhsihma-parva-vol-3-gita-press-gorakhpur'
C_ID = 'nhZm_shrimad-mahabharat-part-4-5-6-virat-udyog-and-bhishma-parv-with-bharat-bhavdip-t'

# (फ़ाइल, archive.org की पहचान या पूरा पता, archive.org में फ़ाइल का नाम — None = उसकी इकलौती _djvu.txt)
SROT = [
    ('vn_g.txt', G_ID, None),
    ('vn_a.txt', '03vanparva_202307', '05udyogparva_djvu.txt'),
    ('vn_vocr.txt', P_ID, None),
    ('vn_c.txt', C_ID, None),
    ('vn_d.html', 'https://sanskritdocuments.org/doc_z_misc_major_works/viduraniti.html', None),
    ('vn_b.txt', 'https://bombay.indology.info/mahabharata/text/UD/MBh05.txt', None),
]


UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'


def curl(url):
    # संस्कृत-संग्रह का सर्वर अधूरे headers पर 406 लौटाता है
    r = subprocess.run(['curl', '-sSL', '--fail', '--retry', '3', '-A', UA,
                        '-H', 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                        '-H', 'Accept-Language: en-US,en;q=0.9', url],
                       capture_output=True, timeout=600)
    if r.returncode:
        raise RuntimeError('%s — %s' % (url, r.stderr.decode('utf-8', 'replace')[:200]))
    return r.stdout


def djvu_naam(ident):
    m = json.loads(curl('https://archive.org/metadata/' + ident).decode('utf-8'))
    naam = [f['name'] for f in m['files'] if f['name'].endswith('_djvu.txt')]
    assert len(naam) == 1, (ident, naam)
    return naam[0]


def srot():
    os.makedirs(SRC, exist_ok=True)
    for naam, kahan, file in SROT:
        out = os.path.join(SRC, naam)
        if os.path.exists(out) and os.path.getsize(out) > 100000:
            print('पहले से', naam, os.path.getsize(out))
            continue
        if kahan.startswith('http'):
            url = kahan
        else:
            url = 'https://archive.org/download/%s/%s' % (kahan, urllib.parse.quote(file or djvu_naam(kahan)))
        data = curl(url)
        with open(out, 'wb') as f:
            f.write(data)
        print('✓', naam, len(data))
        time.sleep(2)


def chitra(ident, upsarg, leaves):
    os.makedirs(PANNE, exist_ok=True)
    for leaf in leaves:
        out = os.path.join(PANNE, '%s_%s.jpg' % (upsarg, leaf))
        if os.path.exists(out) and os.path.getsize(out) > 20000:
            continue
        with open(out, 'wb') as f:
            f.write(curl('https://archive.org/download/%s/page/n%s.jpg' % (ident, leaf)))
        print('✓', os.path.basename(out))
        time.sleep(1)


def kaat(out, specs, chaudai=1400):
    from PIL import Image
    tukde = []
    for spec in specs:
        naam, x0, y0, x1, y1 = spec.split(':')
        im = Image.open(os.path.join(PANNE, naam + '.jpg')).convert('RGB')
        w, h = im.size
        c = im.crop((int(float(x0) * w), int(float(y0) * h), int(float(x1) * w), int(float(y1) * h)))
        tukde.append(c.resize((chaudai, max(1, int(c.height * chaudai / c.width))), Image.LANCZOS))
    canvas = Image.new('RGB', (chaudai, sum(t.height for t in tukde) + 6 * (len(tukde) - 1)), (255, 0, 0))
    y = 0
    for t in tukde:
        canvas.paste(t, (0, y))
        y += t.height + 6
    path = os.path.join(PANNE, out)
    canvas.save(path)
    print(path, canvas.size)


if __name__ == '__main__':
    arg = sys.argv[1:]
    if not arg:
        srot()
    elif arg[0] == 'panna':
        chitra(G_ID, 'g', arg[1:])
    elif arg[0] == 'mbh':
        chitra(P_ID, 'm', arg[1:])
    elif arg[0] == 'kaat':
        w = 1400
        if '--w' in arg:
            i = arg.index('--w')
            w = int(arg[i + 1])
            del arg[i:i + 2]
        kaat(arg[1], arg[2:], w)
    elif arg[0] == 'chhota':
        from PIL import Image
        for naam in arg[1:]:
            im = Image.open(os.path.join(PANNE, naam + '.jpg'))
            im.convert('L').resize((im.width // 2, im.height // 2)).save(os.path.join(PANNE, naam + '_chhota.png'))
            print(naam + '_chhota.png')
