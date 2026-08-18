"""Palan/crop data ke saare Hindi vaakya nikaalo aur dekho kitne anuvaadit hain."""
import re, sys, json, pathlib

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent

# Dart single-quoted string: 'text' with \' escapes
SQ = r"'((?:[^'\\]|\\.)*)'"

# ⚠️ Dart me lage hue string literal apne aap jud jaate hain:
#
#     hi: '❌ naya jaanwar seedhe jhund me... — 2-3 hafte alag rakhiye '
#         '(quarantine), warna wo bimari laata hai.',
#
# `v.hi` chalte waqt **poora juda hua** vaakya hota hai. Isliye ek hi
# literal pakadna galat hai — chaabi adhoori banegi aur anuvaad kabhi
# match hi nahi karega. Neeche `SQ_JOINED` saare lage hue tukde uthata hai.
SQ_JOINED = SQ + r"(?:\s*" + SQ + r")*"

def unescape(s):
    return s.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\").replace("\\n", "\n")

def joined_at(txt, pos):
    """`pos` se shuru hote hue saare lage literal jodkar ek string banao."""
    parts, i = [], pos
    while True:
        m = re.compile(SQ).match(txt, i)
        if not m:
            break
        parts.append(unescape(m.group(1)))
        # agla literal sirf whitespace ke baad aaye tabhi joda jaata hai
        j = m.end()
        while j < len(txt) and txt[j] in " \t\r\n":
            j += 1
        if j < len(txt) and txt[j] == "'":
            i = j
        else:
            break
    return "".join(parts)

def hi_strings(path):
    """har  hi: '...'  aur  xxxHi: '...'  nikaalo (lage hue tukde jodkar).

    crops.dart alag shakl me likhi hai — wahan `whenHi:`, `spacingHi:`,
    `seedTreatHi:`, `splitsHi:`, `nameHi:`, `descHi:` hote hain, `hi:` nahi.
    """
    txt = path.read_text(encoding="utf-8")
    out = []
    for m in re.finditer(r"\b(?:hi|\w+Hi):\s*(?=')", txt):
        out.append(joined_at(txt, m.end()))
    # splitsHi/spacingHi jaisi list<String> bhi ho sakti hai
    for lm in re.finditer(r"\b\w+Hi:\s*\[", txt):
        # list ka band hona dhundo
        depth, k = 1, lm.end()
        while k < len(txt) and depth:
            if txt[k] == "[": depth += 1
            elif txt[k] == "]": depth -= 1
            k += 1
        body = txt[lm.end():k]
        for sm in re.finditer(r"(?<![\\\w])(?=')", body):
            s = joined_at(body, sm.start())
            if s:
                out.append(s)
    return [s for s in out if s.strip()]

data_files = [
    ROOT / "lib/data/palan/palan_data_1.dart",
    ROOT / "lib/data/palan/palan_data_2.dart",
    ROOT / "lib/data/palan/palan_data_3.dart",
    ROOT / "lib/data/palan/palan_common.dart",
    ROOT / "lib/data/crops.dart",
]

all_hi = []
per_file = {}
for f in data_files:
    if not f.exists():
        print("MISSING:", f); continue
    s = hi_strings(f)
    per_file[f.name] = len(s)
    all_hi.extend(s)

uniq = sorted(set(all_hi))

# ab kPalanI18n ki chaabiyan
i18n = (ROOT / "lib/data/palan/palan_i18n.dart").read_text(encoding="utf-8")
# top-level keys:   'text': {
keys = [unescape(m) for m in re.findall(r"^\s{2}" + SQ + r":\s*\{", i18n, re.M)]
have = set(keys)

# har chaabi me kaunsi bhashayein hain
LANGS = ["ta", "te", "kn", "bn", "gu", "pa", "mr", "bho"]
blocks = re.findall(SQ + r":\s*\{(.*?)\n\s{2}\},", i18n, re.S)
complete = set()
for k, body in blocks:
    present = set(re.findall(r"'(\w+)':", body))
    if all(l in present for l in LANGS):
        complete.add(unescape(k))

missing = [h for h in uniq if h not in have]

print("=== file-wise Hindi vaakya (dohre sahit) ===")
for k, v in per_file.items():
    print(f"  {k:24s} {v:5d}")
print(f"\n  kul (dohre sahit) : {len(all_hi)}")
print(f"  alag-alag         : {len(uniq)}")
print(f"\n  i18n me chaabiyan : {len(have)}")
print(f"  8 bhasha poori    : {len(complete)}")
print(f"  ANUVAAD BAAKI     : {len(missing)}")

# lambai ke hisaab se baanto - chhote naam vs lambe vaakya
short = [m for m in missing if len(m) <= 60]
long_ = [m for m in missing if len(m) > 60]
print(f"\n  chhote (<=60 akshar): {len(short)}")
print(f"  lambe  (> 60 akshar): {len(long_)}")
print(f"  kul akshar baaki    : {sum(len(m) for m in missing):,}")

out = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else None
if out:
    out.write_text(json.dumps(missing, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"\n  likha -> {out}")
