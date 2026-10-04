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

## दूसरा ढाँचा — `"dhancha": "khand"` (सप्तशती, सूक्त, उपनिषद …)

गीता में हर अध्याय सिर्फ़ गिने हुए श्लोक हैं। बाक़ी ग्रंथों में ध्यान, विनियोग,
शांति-पाठ जैसे बिना-अंक वाले खंड भी आते हैं, और हर पाठ का अपना परिचय होता है।
उनके लिए:

    kram.json          "dhancha": "khand", "paath": {कुंजी: {...}}, "hisse": [...]
    paath/<कुंजी>.txt  खंड-दर-खंड:
                           # श्लोक १
                           मूल की पंक्तियाँ
                           = अर्थ (एक पंक्ति)

`kram.json` का `assetDir` बताता है कि JSON `app/assets/` के भीतर कहाँ जाएगी।

हिंदी/अवधी का ग्रंथ हो (सुंदरकांड) तो `saanjha` में `"lipi": "hindi"` — रोमन
`roman_hindi` से बनेगा। उसी में जो खंड संस्कृत के हों (मंगलाचरण के श्लोक,
समापन-वाक्य), उनके शीर्षक की शुरुआत `sanskritShirshak` में लिखो।
`"ginoShirshak": ""` — सूची में गिनती सारे खंडों की।
`"yatiPar": ["चौपाई"]` — इन खंडों की हर पंक्ति «अ। ब॥» ऐप में दो पंक्तियों में।
पाठ में `"gintiNaam": "अनुवाक"` — सूची में उस पाठ की गिनती इसी इकाई में (तैत्तिरीय)।
"""
import io
import json
import os
import re
import sys

from lipi import dev_ank, khula, roman_hindi, roman_sanskrit

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


def kram_padho(gid):
    return json.loads(padho(os.path.join(HERE, 'granth_paath', gid, 'kram.json')))


def asset_dir(gid):
    """ऐप में इस ग्रंथ का फ़ोल्डर। `kram.json` में `assetDir` हो तो वही
    (सप्तशती `paath/saptashati` में है — फ़ोन पर बची कुंजियाँ उसी से बँधी हैं)।"""
    rel = kram_padho(gid).get('assetDir', 'granth/' + gid)
    return os.path.join(HERE, '..', 'app', 'assets', *rel.split('/'))


NBSP = chr(0xA0)


def khand_padho(path):
    """`paath/<कुंजी>.txt` → [(शीर्षक, [मूल की पंक्तियाँ], अर्थ)]"""
    out = []
    for blk in re.split(r'\n\s*\n', padho(path).strip()):
        lines = [x.rstrip() for x in blk.split('\n')]
        if not lines[0].startswith('# '):
            ruko('%s: खंड "# शीर्षक" से शुरू नहीं होता: %r' % (path, lines[0]))
        mool = [x.strip() for x in lines[1:] if not x.startswith('= ')]
        arth = [x[2:].strip() for x in lines[1:] if x.startswith('= ')]
        if not mool:
            ruko('%s: "%s" में मूल पाठ नहीं' % (path, lines[0]))
        if len(arth) != 1:
            ruko('%s: "%s" में अर्थ की %d पंक्तियाँ — ठीक एक चाहिए'
                 % (path, lines[0], len(arth)))
        out.append((lines[0][2:].strip(), mool, arth[0]))
    return out


def banao_khand(gid, kram, src, dst):
    """`"dhancha": "khand"` वाले ग्रंथ — हर पाठ की अपनी फ़ाइल, खंड-दर-खंड।"""
    os.makedirs(dst, exist_ok=True)
    saanjha = kram.get('saanjha', {})
    suchi = {}
    kul_khand = kul_akshar = 0
    for key, p in kram['paath'].items():
        pid = '%s_%s' % (gid, key)
        f = dict(saanjha)
        f.update(p)
        strot = f['strot']
        if isinstance(strot, str):
            if strot not in kram['strot']:
                ruko('%s: strot "%s" kram.json के `strot` में नहीं' % (key, strot))
            strot = kram['strot'][strot]
        note = khula(strot['note'])
        if len(note) > kram.get('noteHadd', 600):
            ruko('%s: ⓘ का नोट %d अक्षर — हद पार' % (key, len(note)))
        hindi = f.get('lipi') == 'hindi'
        sanskrit_wale = tuple(f.get('sanskritShirshak', []))
        yati_wale = tuple(f.get('yatiPar', []))
        khand = []
        dekhe = set()
        for shirshak, mool, arth in khand_padho(os.path.join(src, 'paath', key + '.txt')):
            if shirshak in dekhe:
                ruko('%s: शीर्षक "%s" दो बार' % (key, shirshak))
            dekhe.add(shirshak)
            # चौपाई की पंक्ति पुस्तक में «अ। ब॥» एक साथ छपती है; फ़ोन की चौड़ाई
            # में वह बीच से टूटती है। `yatiPar` वाले खंडों में हर पंक्ति «।» पर
            # दो पंक्तियों में जाती है — `paath/*.txt` में पुस्तक वाला रूप ही रहता है।
            if yati_wale and shirshak.startswith(yati_wale):
                tode = []
                for x in mool:
                    aadhe = x.split('। ')
                    if len(aadhe) != 2 or not aadhe[1].endswith('॥'):
                        ruko('%s %s: पंक्ति «अ। ब॥» के रूप में नहीं: %s' % (key, shirshak, x))
                    tode += [aadhe[0] + '।', aadhe[1]]
                mool = tode
            dev = '\n'.join(mool).replace(' ।', NBSP + '।')
            if re.search(r'[A-Za-z0-9]', dev):
                ruko('%s %s: पाठ में अंग्रेज़ी अक्षर/अंक' % (key, shirshak))
            if re.search(r'[A-Za-z0-9]', arth):
                ruko('%s %s: अर्थ में अंग्रेज़ी अक्षर/अंक: %s' % (key, shirshak, arth))
            khand.append({
                'shirshak': shirshak,
                'dev': dev,
                'roman': (roman_hindi(dev)
                          if hindi and not (sanskrit_wale and shirshak.startswith(sanskrit_wale))
                          else roman_sanskrit(dev)),
                'arth': khula(arth),
                'audio': '',
                'sthiti': 'draft',
            })
            kul_akshar += len(dev)
        ginti = sum(1 for k in khand if k['shirshak'].startswith(f.get('ginoShirshak', 'श्लोक')))
        if 'shlok' in p and p['shlok'] != ginti:
            ruko('%s: kram.json में %d, पाठ में %d' % (key, p['shlok'], ginti))
        likho(os.path.join(dst, pid + '.json'), {
            'schemaVersion': 1,
            'id': pid,
            'naam': f['naam'],
            'upnaam': f['upnaam'],
            'prakar': f['prakar'],
            'devta': f['devta'],
            'rachnakar': f['rachnakar'],
            'bhasha': f['bhasha'],
            'parichay': khula(f['parichay']),
            'kabPadhein': khula(f['kabPadhein']),
            'kaisePadhein': khula(f['kaisePadhein']),
            'khand': khand,
            'bharosa': f['bharosa'],
            'strot': {
                'paddhati': strot['paddhati'],
                'kshetra': strot['kshetra'],
                'note': note,
            },
            'jaanch': {'panditNaam': '', 'tarikh': '', 'paas': False},
        })
        suchi[key] = {'id': pid, 'naam': f['naam'], 'ekLine': khula(f['ekLine']),
                      'shlok': ginti}
        # पाठ की अपनी इकाई (तैत्तिरीय में "अनुवाक") — हो तो सूची में ग्रंथ वाली की जगह यही
        if p.get('gintiNaam'):
            suchi[key]['gintiNaam'] = p['gintiNaam']
        kul_khand += len(khand)

    baaki = set(kram['paath']) - {k for h in kram['hisse'] for k in h['paath']}
    if baaki:
        ruko('ये पाठ किसी हिस्से में नहीं: %s' % sorted(baaki))
    likho(os.path.join(dst, '_kram.json'), {
        'schemaVersion': 1,
        'id': gid,
        'naam': kram['naam'],
        'parichay': khula(kram['parichay']),
        'khand': [{'shirshak': h['shirshak'],
                   'paath': [suchi[k] for k in h['paath']]}
                  for h in kram['hisse']],
    })
    print('✓ %s: %d पाठ, %d खंड, मूल %d अक्षर → %s'
          % (gid, len(suchi), kul_khand, kul_akshar, os.path.normpath(dst)))


def banao(gid, dst=None):
    """[dst] न दो तो ऐप के assets में लिखता है; `jaancho_granth.py` इसे एक
    अस्थायी फ़ोल्डर देकर देखता है कि assets हाथ से तो नहीं छुए गए।"""
    src = os.path.join(HERE, 'granth_paath', gid)
    dst = dst or asset_dir(gid)
    kram = json.loads(padho(os.path.join(src, 'kram.json')))
    if kram['id'] != gid:
        ruko('kram.json की id "%s" है, फ़ोल्डर "%s"' % (kram['id'], gid))
    if kram.get('dhancha') == 'khand':
        return banao_khand(gid, kram, src, dst)
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
