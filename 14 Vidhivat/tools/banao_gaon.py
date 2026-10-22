# -*- coding: utf-8 -*-
"""भारत की बसी जगहें (गाँव, क़स्बे, मोहल्ले) → `app/assets/jagah/gaon.txt.gz` (→ D-128)।

    python tools/banao_gaon.py <फ़ोल्डर>        फ़ोल्डर में GeoNames के IN.zip और admin2Codes.txt

स्रोत: GeoNames (geonames.org) — `export/dump/IN.zip`, `admin2Codes.txt`; लाइसेंस CC BY 4.0
(नाम ऐप के लाइसेंस वाले पन्ने पर — `main.dart`)। स्रोत repo में नहीं रखे जाते; पते `docs/18` §४१।
ऐप पूरी तरह ऑफ़लाइन रहता है — सूची ऐप के साथ जाती है, खोज फ़ोन में होती है।

🔑 `gaon.txt.gz` हाथ से कभी नहीं छूनी — यही औज़ार दोबारा चलाओ।

फ़ाइल का ढाँचा (gzip के अंदर UTF-8 पाठ) — ज़िलेवार खंड, ताकि छोटा रहे (5.7 → 3.7 MB):
    पंक्ति 1   राज्यों के हिंदी नाम, «|» से — क्रमांक = `राज्य`
    पंक्ति 2   ज़िलों के नाम (अंग्रेज़ी, बिना चिह्न), «|» से — क्रमांक = `ज़िला`
    #राज्य<TAB>ज़िला     नए खंड की शुरुआत; नीचे की पंक्तियाँ इसी ज़िले की, अक्षांश के क्रम में
    नाम<TAB>Δअक्षांश<TAB>देशांतर<TAB>दर्जा
        अक्षांश = (अंश − 6) × 1000, देशांतर = (अंश − 68) × 1000 — पूर्णांक (≈ 100 मीटर);
        Δअक्षांश = पिछली पंक्ति से अंतर (खंड की पहली पंक्ति पर पूरा)
        दर्जा: 0 ज़िला मुख्यालय/राजधानी · 1 तहसील-स्तर · 2 गाँव/क़स्बा · 3 शहर का मोहल्ला
"""
import gzip
import io
import os
import sys
import unicodedata
import zipfile

sys.stdout.reconfigure(encoding='utf-8')
REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
DST = os.path.join(REPO, 'app', 'assets', 'jagah', 'gaon.txt.gz')

# GeoNames के राज्य-कोड → हिंदी नाम (कोड GeoNames के अपने; admin1CodesASCII.txt)
RAJYA = {
    '01': 'अंडमान और निकोबार', '02': 'आंध्र प्रदेश', '03': 'असम', '05': 'चंडीगढ़', '07': 'दिल्ली',
    '09': 'गुजरात', '10': 'हरियाणा', '11': 'हिमाचल प्रदेश', '12': 'जम्मू और कश्मीर', '13': 'केरल',
    '14': 'लक्षद्वीप', '16': 'महाराष्ट्र', '17': 'मणिपुर', '18': 'मेघालय', '19': 'कर्नाटक',
    '20': 'नागालैंड', '21': 'ओडिशा', '22': 'पुडुचेरी', '23': 'पंजाब', '24': 'राजस्थान',
    '25': 'तमिलनाडु', '26': 'त्रिपुरा', '28': 'पश्चिम बंगाल', '29': 'सिक्किम', '30': 'अरुणाचल प्रदेश',
    '31': 'मिज़ोरम', '33': 'गोवा', '34': 'बिहार', '35': 'मध्य प्रदेश', '36': 'उत्तर प्रदेश',
    '37': 'छत्तीसगढ़', '38': 'झारखंड', '39': 'उत्तराखंड', '40': 'तेलंगाना', '41': 'लद्दाख',
    '52': 'दादरा नगर हवेली और दमन दीव',
}

# बसी जगहें; उजड़ी (PPLQ), ऐतिहासिक (PPLH), नष्ट (PPLW) नहीं
DARJA = {'PPLC': 0, 'PPLA': 0, 'PPLA2': 0, 'PPLA3': 1, 'PPLA4': 1, 'PPLA5': 1,
         'PPL': 2, 'PPLF': 2, 'PPLR': 2, 'PPLS': 2, 'PPLG': 2,
         'PPLX': 3, 'PPLL': 3}


def bina_chihn(s):
    return ''.join(c for c in unicodedata.normalize('NFKD', s) if not unicodedata.combining(c))


def banao(src):
    z = zipfile.ZipFile(os.path.join(src, 'IN.zip'))
    rows = [l.rstrip('\n').split('\t') for l in io.TextIOWrapper(z.open('IN.txt'), encoding='utf-8')]

    zila_naam = {}
    for l in io.open(os.path.join(src, 'admin2Codes.txt'), encoding='utf-8'):
        k, naam = l.split('\t')[:2]
        if k.startswith('IN.'):
            zila_naam[k] = naam

    rajya_kram = sorted(RAJYA)
    zile, zila_kram = [], {}
    dekhe, out = {}, []
    chhode = {'kod': 0, 'rajya': 0, 'seema': 0, 'dohra': 0}
    for r in rows:
        if r[6] != 'P':
            continue
        if r[7] not in DARJA:
            chhode['kod'] += 1
            continue
        naam = r[2].strip()          # asciiname — बिना चिह्न, टाइप करने लायक
        a, d = float(r[4]), float(r[5])
        if not naam or r[10] not in RAJYA:
            chhode['rajya'] += 1
            continue
        if not (6 <= a <= 37.5 and 68 <= d <= 97.5):
            chhode['seema'] += 1
            continue
        zk = 'IN.%s.%s' % (r[10], r[11])
        # ज़िले का नाम भी बिना चिह्न («Rāmanāthapuram» → «Ramanathapuram»)
        zila = bina_chihn(zila_naam.get(zk, ''))
        if zila not in zila_kram:
            zila_kram[zila] = len(zile)
            zile.append(zila)
        ai, di = round((a - 6) * 1000), round((d - 68) * 1000)
        # एक ही ज़िले में एक ही नाम, लगभग दो किलोमीटर के भीतर — एक ही जगह
        kunji = (naam.lower(), r[10], zila)
        pas = dekhe.setdefault(kunji, [])
        if any(abs(ai - x) <= 20 and abs(di - y) <= 20 for x, y in pas):
            chhode['dohra'] += 1
            continue
        pas.append((ai, di))
        out.append((DARJA[r[7]], naam, ai, di, rajya_kram.index(r[10]), zila_kram[zila]))

    # ज़िलेवार खंड, खंड के भीतर अक्षांश के क्रम में — छोटा रहने के लिए (ढाँचा ऊपर)
    out.sort(key=lambda x: (x[4], x[5], x[2], x[3]))
    lines = ['|'.join(RAJYA[k] for k in rajya_kram), '|'.join(zile)]
    khand, pichhla = None, 0
    for dj, n, a, d, ri, zi in out:
        if (ri, zi) != khand:
            lines.append('#%d\t%d' % (ri, zi))
            khand, pichhla = (ri, zi), 0
        lines.append('%s\t%d\t%d\t%d' % (n, a - pichhla, d, dj))
        pichhla = a
    data = ('\n'.join(lines) + '\n').encode('utf-8')
    os.makedirs(os.path.dirname(DST), exist_ok=True)
    # mtime=0 — हर बार एक-से bytes, ताकि बिना बदलाव के git में फ़र्क़ न दिखे
    with open(DST, 'wb') as f:
        with gzip.GzipFile(fileobj=f, mode='wb', compresslevel=9, mtime=0) as g:
            g.write(data)
    print('जगहें %d · ज़िले %d · छोड़ी %s · %.1f MB (खुली %.1f MB)'
          % (len(out), len(zile), chhode, os.path.getsize(DST) / 1e6, len(data) / 1e6))


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('चलाने का ढंग: python tools/banao_gaon.py <IN.zip वाला फ़ोल्डर>')
    banao(sys.argv[1])
