# -*- coding: utf-8 -*-
"""ग्रंथ का कच्चा पाठ → ऐप की JSON (→ D-098, docs/29)।

    python tools/banao_granth.py gita

पढ़ता है  `tools/granth_paath/<id>/`
    kram.json      नाम, हिस्से, हर अध्याय का सार और श्लोक-गिनती
    mool.txt       मूल पाठ — "# अध्याय.श्लोक" और उसके नीचे पंक्तियाँ
    arth/NN.txt    अर्थ — हर पंक्ति "श्लोक-अंक. अर्थ"
    pushpika.txt   (हो तो) अध्याय का समापन-वाक्य

लिखता है  `app/assets/granth/<id>/`
    _kram.json     अध्यायों का क्रम
    <id>_NN.json   हर अध्याय — वही `Paath` ढाँचा जो चालीसा-आरती का है

🔑 **ऐप वाली JSON हाथ से कभी नहीं छूनी** (→ D-071)। पाठ या अर्थ बदलना हो
तो ऊपर वाली फ़ाइलें बदलो और यह औज़ार दोबारा चलाओ।

यह औज़ार चुपचाप कुछ नहीं भरता: गिनती न मिले, कोई अर्थ छूटे, या अर्थ में
अंग्रेज़ी अक्षर/अंक हों — तो रुक जाता है।
"""
import io
import json
import os
import re
import sys

from lipi import dev_ank, khula, roman_sanskrit

HERE = os.path.dirname(os.path.abspath(__file__))
KRAMVACHAK = ['पहला', 'दूसरा', 'तीसरा', 'चौथा', 'पाँचवाँ', 'छठा', 'सातवाँ',
              'आठवाँ', 'नौवाँ', 'दसवाँ', 'ग्यारहवाँ', 'बारहवाँ', 'तेरहवाँ',
              'चौदहवाँ', 'पंद्रहवाँ', 'सोलहवाँ', 'सत्रहवाँ', 'अठारहवाँ']


def padho(path):
    with io.open(path, encoding='utf-8') as f:
        return f.read()


def ruko(msg):
    sys.exit('✗ ' + msg)


def mool_padho(path):
    """{(अध्याय, श्लोक): [पंक्तियाँ]}"""
    out = {}
    for blk in padho(path).strip().split('\n\n'):
        lines = blk.split('\n')
        m = re.match(r'^# (\d+)\.(\d+)$', lines[0])
        if not m:
            ruko('mool.txt में शीर्ष-पंक्ति नहीं पहचानी: %r' % lines[0])
        out[(int(m.group(1)), int(m.group(2)))] = [x.strip() for x in lines[1:]]
    return out


def arth_padho(path):
    """{श्लोक: अर्थ}"""
    out = {}
    for n, line in enumerate(padho(path).split('\n'), 1):
        if not line.strip():
            continue
        m = re.match(r'^(\d+)\.\s+(.+)$', line)
        if not m:
            ruko('%s पंक्ति %d: "अंक. अर्थ" का रूप नहीं' % (path, n))
        v = int(m.group(1))
        if v in out:
            ruko('%s: श्लोक %d दो बार' % (path, v))
        out[v] = m.group(2).strip()
    return out


def likho(path, data):
    text = json.dumps(data, ensure_ascii=False, indent=2) + '\n'
    with io.open(path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)


def naam_se(pushpika_naam):
    """"अर्जुनविषादयोगो नाम प्रथमोऽध्यायः" → "अर्जुनविषादयोग" """
    m = re.match(r'^(.*?योग)ो नाम', pushpika_naam)
    if not m:
        ruko('अध्याय का नाम नहीं निकला: %r' % pushpika_naam)
    return m.group(1)


def asset_dir(gid):
    return os.path.join(HERE, '..', 'app', 'assets', 'granth', gid)


def banao(gid, dst=None):
    """[dst] न दो तो ऐप के assets में लिखता है; `jaancho_granth.py` इसे एक
    अस्थायी फ़ोल्डर देकर देखता है कि assets हाथ से तो नहीं छुए गए।"""
    src = os.path.join(HERE, 'granth_paath', gid)
    dst = dst or asset_dir(gid)
    kram = json.loads(padho(os.path.join(src, 'kram.json')))
    if kram['id'] != gid:
        ruko('kram.json की id "%s" है, फ़ोल्डर "%s"' % (kram['id'], gid))
    mool = mool_padho(os.path.join(src, 'mool.txt'))

    pushpika = {}
    pp = os.path.join(src, 'pushpika.txt')
    if os.path.exists(pp):
        for line in padho(pp).strip().split('\n'):
            n, text = line.split('\t')
            pushpika[int(n)] = [x.strip() for x in text.split(' / ')]

    os.makedirs(dst, exist_ok=True)
    adhyay = {a['ank']: a for a in kram['adhyay']}
    ikai = kram.get('ikai', 'अध्याय')
    suchi = {}
    kul_shlok = kul_akshar = 0

    for ank in sorted(adhyay):
        a = adhyay[ank]
        pid = '%s_%02d' % (gid, ank)
        arth = arth_padho(os.path.join(src, 'arth', '%02d.txt' % ank))
        shlok = sorted(v for (c, v) in mool if c == ank)
        if shlok != list(range(1, a['shlok'] + 1)):
            ruko('%s %d: mool.txt में %d श्लोक, kram.json में %d'
                 % (ikai, ank, len(shlok), a['shlok']))
        if sorted(arth) != shlok:
            ruko('%s %d: अर्थ %d श्लोकों का, पाठ %d का — छूटे/फ़ालतू: %s'
                 % (ikai, ank, len(arth), len(shlok),
                    sorted(set(shlok) ^ set(arth))))

        khand = []
        for v in shlok:
            # पूर्णविराम से पहले की जगह **न टूटने वाली** (U+00A0): बड़े अक्षरों में
            # पंक्ति लपेटने पर अकेला "।" अगली पंक्ति में नहीं गिरता — अपने शब्द
            # के साथ ही जाता है। `mool.txt` में सादी जगह ही रहती है।
            dev = '\n'.join(mool[(ank, v)]).replace(' ।', chr(0xA0) + '।')
            if re.search(r'[A-Za-z0-9]', dev):
                ruko('%d.%d के पाठ में अंग्रेज़ी अक्षर/अंक' % (ank, v))
            if re.search(r'[A-Za-z0-9]', arth[v]):
                ruko('%d.%d के अर्थ में अंग्रेज़ी अक्षर/अंक: %s' % (ank, v, arth[v]))
            khand.append({
                'shirshak': 'श्लोक ' + dev_ank(v),
                'dev': dev,
                'roman': roman_sanskrit(dev),
                'arth': khula(arth[v]),
                'audio': '',
                'sthiti': 'draft',
            })
            kul_akshar += len(dev)

        if ank in pushpika:
            sk_naam = naam_se(pushpika[ank][-1])
            dev = '\n'.join(pushpika[ank]) + '॥'
            khand.append({
                'shirshak': 'समापन',
                'dev': dev,
                'roman': roman_sanskrit(dev),
                'arth': khula(
                    'इस तरह उपनिषद रूप श्रीमद्भगवद्गीता में, जो ब्रह्मविद्या और '
                    'योगशास्त्र है, श्रीकृष्ण और अर्जुन के संवाद में "%s" नाम का '
                    '%s अध्याय पूरा हुआ।' % (sk_naam, KRAMVACHAK[ank - 1])),
                'audio': '',
                'sthiti': 'draft',
            })
        else:
            sk_naam = a['naam']

        naam = '%s %s — %s' % (ikai, dev_ank(ank), sk_naam)
        note = [kram['strot']['notePaath']]
        if a.get('noteAur'):
            note.append(a['noteAur'])
        note.append(kram['strot']['noteArth'])
        note = khula('\n\n'.join(note))
        if len(note) > 600:
            ruko('%s %d: ⓘ का नोट %d अक्षर — 600 की हद पार' % (ikai, ank, len(note)))

        upnaam = ['%s %s %s' % (kram['naam'], ikai, dev_ank(ank)),
                  'गीता %s %s' % (ikai, dev_ank(ank))]
        if ank in pushpika:
            upnaam.append(pushpika[ank][-1])

        likho(os.path.join(dst, pid + '.json'), {
            'schemaVersion': 1,
            'id': pid,
            'naam': naam,
            'upnaam': upnaam,
            'prakar': 'granth',
            'devta': kram['devta'],
            'rachnakar': kram['rachnakar'],
            'bhasha': kram['bhasha'],
            'parichay': khula(a['parichay']),
            'kabPadhein': khula(kram['kabPadhein']),
            'kaisePadhein': khula(kram['kaisePadhein']),
            'khand': khand,
            'bharosa': kram['bharosa'],
            'strot': {
                'paddhati': kram['strot']['paddhati'],
                'kshetra': kram['strot']['kshetra'],
                'note': note,
            },
            'jaanch': {'panditNaam': '', 'tarikh': '', 'paas': False},
        })
        suchi[ank] = {'id': pid, 'naam': naam, 'ekLine': khula(a['ekLine']),
                      'shlok': len(shlok)}
        kul_shlok += len(shlok)

    baaki = set(adhyay) - {n for h in kram['hisse'] for n in h['adhyay']}
    if baaki:
        ruko('ये %s किसी हिस्से में नहीं: %s' % (ikai, sorted(baaki)))
    likho(os.path.join(dst, '_kram.json'), {
        'schemaVersion': 1,
        'id': gid,
        'naam': kram['naam'],
        'parichay': khula(kram['parichay']),
        'khand': [{'shirshak': h['shirshak'],
                   'paath': [suchi[n] for n in h['adhyay']]}
                  for h in kram['hisse']],
    })
    print('✓ %s: %d %s, %d श्लोक, मूल %d अक्षर → %s'
          % (gid, len(adhyay), ikai, kul_shlok, kul_akshar, os.path.normpath(dst)))


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('चलाने का ढंग: python tools/banao_granth.py <id>   (जैसे gita)')
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    banao(sys.argv[1])
