# -*- coding: utf-8 -*-
"""`pu_suchi.py` की हर पंक्ति गवाहों में है या नहीं — और जोड़।

गवाह (इसी फ़ोल्डर में उतरे हुए — `pu_lao.py`, `ia_lao.py`):
  भागवत १२.७, १२.१३ : ws_bhag_12_7.txt, ws_bhag_12_13.txt (देवनागरी) · g_bhag12.htm (IAST) — दो अलग टंकण
  विष्णु ३.६        : ws_vishnu_3_6.txt (देवनागरी) · g_vishnu.htm (समीक्षित संस्करण, IAST) — दो अलग पाठ
  मत्स्य ५३         : ws_matsya_53.txt (= g_matsya.htm, एक ही टंकण) · दो छपी पुस्तकों के OCR (GP, AA)
"""
import difflib
import html
import io
import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.environ.get('VIDHIVAT_TOOLS') or
                os.path.abspath(os.path.join(HERE, '..', '..', '..')))
from milan import kunji_dev, kunji_iast  # noqa: E402
import pu_milan as M  # noqa: E402
import pu_ocr as O  # noqa: E402
from pu_suchi import BHAG_7, BHAG_AUR, MATSYA_AUR, PURAN, VISHNU  # noqa: E402

galti = []


def ws_kunji(naam):
    return ''.join(kunji_dev(x) for x in M.ws_panktiyan(naam))


def g_kunji(naam, pat):
    t = html.unescape(re.sub(r'<[^>]+>', '', M.padho(naam)))
    return ''.join(kunji_iast(m.group(1)) for m in re.finditer(pat, t))


def hai(naam, lines, kunjiyan):
    """हर पंक्ति की कुंजी हर गवाह की कुंजी में (जुड़े हुए पाठ में) मिले।"""
    for l in lines:
        k = kunji_dev(l)
        for gawah, kk in kunjiyan.items():
            if k not in kk:
                galti.append('%s: «%s» %s में नहीं' % (naam, l, gawah))


# ── भागवत ──
b13 = {'W': ws_kunji('ws_bhag_12_13.txt'), 'G': g_kunji('g_bhag12.htm', r'BhP_12\.13\.\d+/\d\s+(.*)')}
b7 = {'W': ws_kunji('ws_bhag_12_7.txt'), 'G': g_kunji('g_bhag12.htm', r'BhP_12\.07\.\d+/\d\s+(.*)')}
for key, naam, bnaam, bl, bn, ml, mn in PURAN:
    hai('भागवत १२.१३ ' + naam, bl, b13)
hai('भागवत १२.१३', BHAG_AUR, b13)
hai('भागवत १२.७', BHAG_7, b7)

# ── विष्णु ──
v = {'W': ws_kunji('ws_vishnu_3_6.txt'),
     'G': g_kunji('g_vishnu.htm', r'(.*?)\s*/?/\s*(?:ViP_3,6\.\d+\s*//)?\s*\n')}
# समीक्षित पाठ के लिए सीधा रास्ता: अध्याय ३.६ की सब पंक्तियाँ
t = html.unescape(re.sub(r'<[^>]+>', '', M.padho('g_vishnu.htm')))
a = t.find('ViP_3,5.')
b = t.find('ViP_3,7.1 ')
seg = t[a:b]
v['G'] = ''.join(kunji_iast(re.sub(r'/+\s*ViP_[^/]*//|/', ' ', l)) for l in seg.split('\n'))
hai('विष्णु ३.६', VISHNU, v)

# ── मत्स्य ── e-पाठ में हूबहू; दोनों OCR में पास (≥ 0.85)
ws = [re.sub(r'\s*(५३\.)?[०-९]+\s*$', '', x) for x in M.ws_panktiyan('ws_matsya_53.txt')]
mk = ''.join(kunji_dev(x) for x in ws)
oc = {k: [kunji_dev(x) for x in O.ocr_panktiyan(k)] for k in O.OCR}
kam = []
for naam, lines in [(p[1], p[5]) for p in PURAN] + [('परिचय', MATSYA_AUR)]:
    for l in lines:
        k = kunji_dev(l)
        if k not in mk:
            galti.append('मत्स्य ५३ %s: «%s» e-पाठ में नहीं' % (naam, l))
        for g in oc:
            r, j = O.paas(k, oc[g])
            if r < 0.85:
                kam.append((naam, l, g, round(r, 2)))

# ── जोड़ ──
bsum = sum(p[4] for p in PURAN)
msum = sum(p[6] for p in PURAN)
print('भागवत की सूची का जोड़', bsum, '· मत्स्य की सूची का जोड़', msum)
alag = [(p[1], p[4], p[6]) for p in PURAN if p[4] != p[6]]
print('जहाँ दोनों सूचियाँ अलग:', alag)
print('OCR में 0.85 से कम पास वाली पंक्तियाँ:', len(kam))
for x in kam:
    print('   ', x)
if galti:
    print('\n'.join('✗ ' + g for g in galti))
    sys.exit(1)
print('✓ %d पुराण — भागवत की %d, विष्णु की %d, मत्स्य की %d पंक्तियाँ गवाहों में मिलीं'
      % (len(PURAN), sum(len(p[3]) for p in PURAN) + len(BHAG_AUR) + len(BHAG_7), len(VISHNU),
         sum(len(p[5]) for p in PURAN) + len(MATSYA_AUR)))
