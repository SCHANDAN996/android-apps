"""Bhari hui ANUVAAD_CHAHIYE.json ko wapas lang files me daalo.

Chalao (project ki jad se):

    python scripts/ui_anuvaad_daalo.py

Har bhasha ke `lib/l10n/langs/lang_<code>.dart` me nayi lines jodta hai.
Jo key pehle se hai use chhuta nahi.

Iske baad zaroor chalaiye:
    flutter analyze --no-pub lib/l10n/
    flutter test
"""
import re, json, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
LANGS = ['ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho']

src = ROOT / 'ANUVAAD_CHAHIYE.json'
if not src.exists():
    sys.exit('ANUVAAD_CHAHIYE.json nahi mili. Pehle ui_anuvaad_baaki.py chalaiye.')

data = json.loads(src.read_text(encoding='utf-8'))

# Dart ki single-quote wali string me ' aur \ bachana zaroori hai
def esc(s):
    return s.replace('\\', '\\\\').replace("'", "\\'")


kul = 0
for lang in LANGS:
    f = ROOT / f'lib/l10n/langs/lang_{lang}.dart'
    if not f.exists():
        print(f'  ! {f.name} nahi mili'); continue
    txt = f.read_text(encoding='utf-8')

    naye = []
    for key, vals in data.items():
        v = (vals.get(lang) or '').strip()
        if not v or v.startswith('('):      # khaali ya "(pehle se hai)"
            continue
        if re.search(r"'" + re.escape(key) + r"':", txt):
            continue                        # pehle se hai, chhuo mat
        naye.append(f"  '{key}': '{esc(v)}',")

    if not naye:
        print(f'  = {lang}: kuch naya nahi')
        continue

    # aakhri `};` se pehle daalo
    i = txt.rstrip().rfind('};')
    if i < 0:
        print(f'  ! {lang}: map ka ant nahi mila'); continue
    txt = txt[:i] + '\n'.join(naye) + '\n' + txt[i:]
    f.write_text(txt, encoding='utf-8')
    kul += len(naye)
    print(f'  + {lang}: {len(naye)} jode')

print(f'\nkul {kul} anuvaad daale.')
print('\nab ye chalaiye:')
print('  flutter analyze --no-pub lib/l10n/')
print('  flutter test')
