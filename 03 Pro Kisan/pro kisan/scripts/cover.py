"""Kitna anuvaad ho chuka, kitna baaki — aur kya baaki hai.

Chalane ka tarika (project ki jad se):

    python scripts/cover.py            # sirf ginti
    python scripts/cover.py 0 40       # bache hue pehle 40 vaakya bhi dikhao

`todo.json` (project ki jad me) har baar taaza likh deta hai.
"""
import re, json, sys, pathlib

# script khud kahan hai, usi se raaste banate hain — taaki kisi bhi
# directory se chalaya ja sake
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
LANGS = ["ta", "te", "kn", "bn", "gu", "pa", "mr", "bho"]
SQ = r"'((?:[^'\\]|\\.)*)'"

def unescape(s):
    return s.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\").replace("\\n", "\n")

def entries(path):
    """har  'key': { ... },  block nikaalo -> {key: set(langs)}"""
    if not path.exists():
        return {}
    txt = path.read_text(encoding="utf-8")
    out = {}
    # top-level entry: do space indent, key, colon, brace ... closing brace at do space
    for m in re.finditer(r"^  " + SQ + r":\s*\{(.*?)^  \},", txt, re.S | re.M):
        key = unescape(m.group(1))
        body = m.group(2)
        out[key] = set(re.findall(r"'(\w+)':", body))
    return out

have = {}
for f in sorted(ROOT.glob("lib/data/palan/palan_i18n_deep_*.dart")):
    e = entries(f)
    have.update(e)
    done = sum(1 for v in e.values() if all(l in v for l in LANGS))
    print(f"  {f.name:26s} {len(e):4d} entry, {done:4d} poore")

missing_all = json.loads((HERE / "missing.json").read_text(encoding="utf-8"))
complete = {k for k, v in have.items() if all(l in v for l in LANGS)}
todo = [m for m in missing_all if m not in complete]
partial = [k for k, v in have.items() if not all(l in v for l in LANGS)]

print(f"\n  kul chahiye : {len(missing_all)}")
print(f"  ho gaya     : {len(missing_all) - len(todo)}")
print(f"  BAAKI       : {len(todo)}")
if partial:
    print(f"  ⚠️ adhoore  : {len(partial)} -> {partial[:5]}")

(ROOT / "BAAKI_ANUVAAD.json").write_text(
    json.dumps(sorted(todo, key=lambda s: (len(s), s)), ensure_ascii=False, indent=1),
    encoding="utf-8")

if len(sys.argv) > 1:
    lo = int(sys.argv[1]); hi = int(sys.argv[2]) if len(sys.argv) > 2 else lo + 60
    t = sorted(todo, key=lambda s: (len(s), s))
    for j, s in enumerate(t[lo:hi], lo):
        print(f"{j:4d}| {s}")
