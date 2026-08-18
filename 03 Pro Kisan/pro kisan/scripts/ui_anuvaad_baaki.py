"""UI ke jo shabd 8 bhashaon me anuvaad hone baaki hain, unki file banao.

Chalao (project ki jad se):

    python scripts/ui_anuvaad_baaki.py

`ANUVAAD_CHAHIYE.json` likhta hai — sirf wahi keys jo kisi bhasha me
chhooti hain. Jo pehle se ho chuki hain wo isme nahi aatin.

Bharne ke baad wapas daalne ke liye:

    python scripts/ui_anuvaad_daalo.py
"""
import re, json, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent

LANGS = ['ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho']
SQ = r"'((?:[^'\\]|\\.)*)'"


def maan(src, key):
    """`'key': '...'` ka pehla maan"""
    m = re.search(r"'" + re.escape(key) + r"':\s*" + SQ, src)
    return m.group(1).replace("\\'", "'") if m else None


def sab_maan(src, key):
    p = re.compile(r"'" + re.escape(key) + r"':\s*" + SQ)
    return [m.group(1).replace("\\'", "'") for m in p.finditer(src)]


main_src = (ROOT / 'lib/l10n/app_localizations.dart').read_text(encoding='utf-8')

# hindi map me jo bhi key hai, wo sab ui ke shabd hain
hi_keys = re.findall(r"^      '(\w+)':", main_src, re.M)
# pehla aadha hindi map ka hai, doosra english ka - isliye set le lo
hi_keys = list(dict.fromkeys(hi_keys))

lang_src = {}
for l in LANGS:
    f = ROOT / f'lib/l10n/langs/lang_{l}.dart'
    lang_src[l] = f.read_text(encoding='utf-8') if f.exists() else ''

# ⚠️ gap wali file me har bhasha ka apna map hota hai (kTaGap3, kTeGap3 …).
# Pehle poori file har bhasha me jod di jaati thi — isse Tamil ka anuvaad
# Bangla ke liye bhi "ho chuka" gina jaata tha, aur ginti galat aati thi.
# Ab sirf usi bhasha ka map uthate hain.
MAP_NAAM = {'ta': 'Ta', 'te': 'Te', 'kn': 'Kn', 'bn': 'Bn',
            'gu': 'Gu', 'pa': 'Pa', 'mr': 'Mr', 'bho': 'Bho'}

for extra in sorted(ROOT.glob('lib/l10n/langs/lang_gap*.dart')):
    txt = extra.read_text(encoding='utf-8')
    for l in LANGS:
        # const Map<String, String> kTaGap3 = { … };
        pat = re.compile(
            r'const Map<String,\s*String>\s+k' + MAP_NAAM[l] +
            r'\w*\s*=\s*\{(.*?)\n\};', re.S)
        for m in pat.finditer(txt):
            lang_src[l] += '\n' + m.group(1)

out = {}
for k in hi_keys:
    vals = sab_maan(main_src, k)
    hi = vals[0] if vals else None
    en = vals[1] if len(vals) > 1 else None
    if not hi:
        continue
    chhoot = [l for l in LANGS if maan(lang_src[l], k) is None]
    if not chhoot:
        continue  # sab bhashaon me ho chuki
    entry = {'hi': hi, 'en': en or ''}
    for l in LANGS:
        entry[l] = '' if l in chhoot else '(pehle se hai)'
    out[k] = entry

(ROOT / 'ANUVAAD_CHAHIYE.json').write_text(
    json.dumps(out, ensure_ascii=False, indent=2), encoding='utf-8')

print(f"kul UI shabd    : {len(hi_keys)}")
print(f"ANUVAAD BAAKI   : {len(out)}")
print("\nlikha -> ANUVAAD_CHAHIYE.json")
for k in list(out)[:15]:
    print(f"  {k}")
if len(out) > 15:
    print(f"  … aur {len(out) - 15}")
