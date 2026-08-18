"""Har bhasha ka text apni hi lipi me hai ya nahi — dusri lipi ghus to nahi gayi.

Kyun zaroori: machine anuvaad me kabhi-kabhi ek bhasha ke beech dusri lipi ke
akshar reh jaate hain (jaise Marathi me Gujarati ka 'ક્ટ', ya Telugu me Tamil
ka 'மீ'). Kisan ke liye wo akshar padhne layak nahi rehte, aur dekhne me
turant pata bhi nahi chalta.

Chalao:  python scripts/script_check.py
"""
import re, sys, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent

# har lipi ka Unicode ilaaka
BLOCKS = {
    "deva": (0x0900, 0x097F),   # Devanagari — hi, mr, bho
    "beng": (0x0980, 0x09FF),   # Bengali    — bn
    "guru": (0x0A00, 0x0A7F),   # Gurmukhi   — pa
    "gujr": (0x0A80, 0x0AFF),   # Gujarati   — gu
    "taml": (0x0B80, 0x0BFF),   # Tamil      — ta
    "telu": (0x0C00, 0x0C7F),   # Telugu     — te
    "knda": (0x0C80, 0x0CFF),   # Kannada    — kn
}

# kis bhasha ko kaunsi lipi chahiye
WANT = {
    "ta": "taml", "te": "telu", "kn": "knda", "bn": "beng",
    "gu": "gujr", "pa": "guru", "mr": "deva", "bho": "deva",
}

SQ = r"'((?:[^'\\]|\\.)*)'"


# ⚠️ ye chihn Devanagari ke ilaake me hain par saari Indic lipiyon me chalte
# hain — Bangla aur Punjabi bhi danda (।) lagate hain. Inhe galti mat maano.
SHARED = {
    0x0964,  # ।  danda
    0x0965,  # ॥  double danda
    0x0970,  # ॰  abbreviation sign
    0x00B7,  # ·  middle dot
}


def script_of(ch):
    cp = ord(ch)
    if cp in SHARED:
        return None
    for name, (lo, hi) in BLOCKS.items():
        if lo <= cp <= hi:
            return name
    return None


def unescape(s):
    return s.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\")


bad = []
for f in sorted(ROOT.glob("lib/data/palan/palan_i18n_deep_*.dart")):
    txt = f.read_text(encoding="utf-8")
    # har  'key': { ... },  block
    for m in re.finditer(r"^  " + SQ + r":\s*\{(.*?)^  \},", txt, re.S | re.M):
        key = unescape(m.group(1))
        for lm in re.finditer(r"'(\w+)':\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", m.group(2)):
            lang = lm.group(1)
            if lang not in WANT:
                continue
            text = "".join(unescape(x) for x in re.findall(SQ, lm.group(2)))
            want = WANT[lang]
            wrong = {}
            for ch in text:
                s = script_of(ch)
                if s and s != want:
                    wrong.setdefault(s, []).append(ch)
            if wrong:
                bad.append((f.name, lang, want, wrong, key, text))

if not bad:
    print("✅ Sab theek — har bhasha apni hi lipi me hai.")
    sys.exit(0)

# `--raw` par ek line me poora text — sudharne ke liye
if "--raw" in sys.argv:
    for fname, lang, want, wrong, key, text in bad:
        print(f"{fname}\t{lang}\t{text}")
    sys.exit(1)

print(f"⚠️  {len(bad)} jagah dusri lipi ghus gayi hai:\n")
for fname, lang, want, wrong, key, text in bad:
    got = ", ".join(f"{s}({''.join(sorted(set(c)))})" for s, c in wrong.items())
    print(f"  {fname} · [{lang}] chahiye {want}, mila {got}")
    print(f"    chaabi : {key[:70]}")
    print(f"    anuvaad: {text[:90]}\n")
sys.exit(1)
