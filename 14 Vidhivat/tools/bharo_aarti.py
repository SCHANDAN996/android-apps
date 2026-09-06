# -*- coding: utf-8 -*-
"""आरती के पाठ .txt से JSON में भरो — हाथ से JSON छूने की ज़रूरत नहीं।

    cd "14 Vidhivat" && python tools/bharo_aarti.py

## क्यों

आरती **गाई जाने वाली रचना** है और घर-घर में शब्द थोड़े बदलते हैं। ऐप
में वही पाठ जाएगा जो आपके घर में गाया जाता है — अपनी आरती-पुस्तिका से।
यह फ़ैसला शुरू से है (देखो हर `paath/*.json` का `strot.note`)।

पर उसके लिए 11 JSON फ़ाइलें हाथ से खोलना और `khand` का ढाँचा सही रखना
झंझट है। इसलिए यह औज़ार:

  1. `tools/aarti_paath/` में हर आरती की एक सादी `.txt` फ़ाइल बनी है
  2. आप उसमें अपनी पुस्तिका से पाठ लिख/चिपका दीजिए
  3. यही स्क्रिप्ट चलाइए — पाठ सही ढाँचे में JSON में चला जाएगा

## .txt कैसे लिखें

- **एक ख़ाली लाइन** से पद अलग होते हैं (जैसे markdown में पैराग्राफ़)
- हर पद अपने आप एक `khand` बन जाएगा
- पद के अंदर की लाइनें वैसी ही रहेंगी
- `#` से शुरू होने वाली लाइन टिप्पणी है, वो नहीं जाएगी
- फ़ाइल ख़ाली छोड़ देंगे तो वो आरती **वैसी ही ख़ाली** रहेगी (कुछ
  बिगड़ेगा नहीं) — जो भर सकें उतनी भरिए, बाक़ी बाद में

## जो यह स्क्रिप्ट **नहीं** करती

- **रोमन और अर्थ अपने आप नहीं भरती।** वो ख़ाली रहेंगे और ऐप उन्हें
  चुपचाप छोड़ देगा। चाहें तो बाद में जोड़िए — या रहने दीजिए, आरती गाई
  जाती है, पढ़ी नहीं जाती।
- **`sthiti` "draft" ही रखती है, "paas" नहीं।** पास करना आपका फ़ैसला है
  (→ D-041)।
"""
import io, json, os, re, sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(_HERE)
PAATH = os.path.join(ROOT, "app", "assets", "paath")
TXT = os.path.join(_HERE, "aarti_paath")


def padho_txt(path):
    """.txt से पद निकालो — ख़ाली लाइन से अलग, # वाली लाइनें छोड़कर।"""
    raw = io.open(path, encoding="utf-8").read()
    lines = [l for l in raw.splitlines() if not l.lstrip().startswith("#")]
    blocks = re.split(r"\n\s*\n", "\n".join(lines))
    return [b.strip() for b in blocks if b.strip()]


def bharo(pid, pad):
    jpath = os.path.join(PAATH, "%s.json" % pid)
    d = json.load(io.open(jpath, encoding="utf-8"))

    ek = len(pad) == 1
    d["khand"] = [
        {
            "shirshak": "पूरी आरती" if ek else "पद %d" % (i + 1),
            "dev": p,
            "roman": "",
            "arth": "",
            "audio": "",
            "sthiti": "draft",
        }
        for i, p in enumerate(pad)
    ]
    # पाठ आ गया तो वो "अभी नहीं जोड़ा गया" वाली चेतावनी हटा दो
    note = d["strot"].get("note", "")
    if "पाठ अभी नहीं जोड़ा गया" in note:
        d["strot"]["note"] = (
            "यह पाठ डेवलपर ने अपनी आरती-पुस्तिका से भरा है "
            "(`tools/bharo_aarti.py` से)।\n\n"
            "⚠️ आरती गाई जाने वाली रचना है और घर-घर में शब्द थोड़े "
            "बदलते हैं — यह वो रूप है जो इस घर में गाया जाता है। "
            "**अभी किसी पंडित जी या छपी पुस्तिका से मिलाया नहीं गया**, "
            "इसलिए हर पद पर \"जाँच बाकी\" दिखता है।"
        )
    io.open(jpath, "w", encoding="utf-8", newline="\n").write(
        json.dumps(d, ensure_ascii=False, indent=2) + "\n")
    return len(pad)


def main():
    if not os.path.isdir(TXT):
        raise SystemExit("%s है ही नहीं — पहले वो फ़ोल्डर बनाइए" % TXT)

    files = sorted(f for f in os.listdir(TXT) if f.endswith(".txt"))
    if not files:
        raise SystemExit("%s में कोई .txt नहीं मिली" % TXT)

    bhare, khaali = 0, []
    for f in files:
        pid = f[:-4]
        jpath = os.path.join(PAATH, "%s.json" % pid)
        if not os.path.exists(jpath):
            print("⚠️  छोड़ा: %-20s — इस नाम का कोई पाठ नहीं है" % pid)
            continue
        pad = padho_txt(os.path.join(TXT, f))
        if not pad:
            khaali.append(pid)
            continue
        n = bharo(pid, pad)
        bhare += 1
        print("✅ भरा: %-20s %d पद" % (pid, n))

    if khaali:
        print()
        print("अभी ख़ाली (%d) — इनकी .txt में कुछ लिखा नहीं है:" % len(khaali))
        for pid in khaali:
            print("   ·", pid)

    print()
    print("भरी %d · ख़ाली %d" % (bhare, len(khaali)))
    if bhare:
        print()
        print("अब यह चलाइए ताकि जाँचें और पंडित शीट भी नई हालत देखें:")
        print("   cd app && flutter test")
        print("   python tools/banao_pandit_sheet.py")


if __name__ == "__main__":
    main()
