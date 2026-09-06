# -*- coding: utf-8 -*-
"""पंडित जी के लिए अलग-अलग .md फ़ाइलें बनाओ — एक फ़ोल्डर, हर चीज़ की अपनी फ़ाइल।

क्यों .md और अलग फ़ाइलें (शीट के अलावा):
शीट (docs/12_PANDIT_SHEET.html) एक ही बैठक में पूरी छापने के लिए है।
पर डेवलपर को कभी सिर्फ़ "एक मंत्र" या "एक पूजा" किसी को WhatsApp पर भेजनी
हो, या पंडित जी टुकड़ों में जवाब दें — तब पूरी शीट भेजना अजीब है।
इसलिए वही डेटा, अलग-अलग छोटी फ़ाइलों में भी — दोनों JSON से बनती हैं,
इसलिए दोनों हमेशा एक जैसी बात कहेंगी।

बनता है: docs/pandit_jaanch/
  00_README.md              किस फ़ाइल में क्या है, कैसे इस्तेमाल करें
  मंत्र/01_....md .. १५     हर अलग मंत्र-पाठ की अपनी फ़ाइल
  संकल्प.md                 चौदह रूप
  खाली-मंत्र/....md         हर ख़ाली जगह की अपनी फ़ाइल (कदम के हिसाब से समूह में)
  पूजा/....md                हर पूजा की अपनी फ़ाइल — दायरा, कदम, सामग्री
"""
import io, json, glob, os, re, sys
from collections import defaultdict, OrderedDict

# Windows का console डिफ़ॉल्ट रूप से cp1252 है, जिसमें देवनागरी नहीं छपती।
# फ़ाइलें तो बन जाती हैं, पर आख़िरी print पर UnicodeEncodeError आकर
# स्क्रिप्ट exit code 1 दे जाती है — यानी सफल चलना भी असफल दिखता है।
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = r"C:\Users\Admin\Desktop\my project\MASS APP\14 Vidhivat"
APP = os.path.join(ROOT, "app")
OUT = os.path.join(ROOT, "docs", "pandit_jaanch")

BHAROSA_NAAM = {"uncha": "ऊँचा", "madhyam": "मध्यम", "kam": "कम"}
SCOPE_NAAM = {
    "self_guided": "घर पर अपने आप",
    "regional_profile": "क्षेत्रीय परंपरा",
    "preparation_only": "सिर्फ़ तैयारी",
    "expert_assisted": "पंडित जी के साथ",
}

def safe(name):
    """फ़ाइल के नाम लायक — स्पेस को अंडरस्कोर, / को -."""
    return re.sub(r"[\\/:*?\"<>|]", "-", name).replace(" ", "_")

def w(path, text):
    d = os.path.dirname(path)
    if d and not os.path.isdir(d):
        os.makedirs(d)
    io.open(path, "w", encoding="utf-8", newline="\n").write(text.rstrip() + "\n")

# ── पढ़ो ──
files = [p for p in sorted(glob.glob(os.path.join(APP, "assets", "vidhi", "*.json")))
         if not p.endswith("_suchi.json")]
pujas = [json.load(io.open(p, encoding="utf-8")) for p in files]
pujas.sort(key=lambda d: (list(SCOPE_NAAM).index(d.get("scope", "self_guided")), d["naam"]))

bhare = OrderedDict()
khaali = defaultdict(list)
for d in pujas:
    for c in d["charan"]:
        m = c.get("mantra")
        if not m:
            continue
        if m.get("devanagari", "").strip():
            k = m["devanagari"].strip()
            bhare.setdefault(k, {"m": m, "uses": []})["uses"].append((d["naam"], c["shirshak"]))
        else:
            khaali[c["shirshak"]].append((d["naam"], m.get("vikalp", "").strip() or "वजह नहीं लिखी"))
bhare = OrderedDict(sorted(bhare.items(), key=lambda kv: -len(kv[1]["uses"])))
khaali_sorted = sorted(khaali.items(), key=lambda kv: -len(kv[1]))

files_written = []

# ══════════════════════════════════════════ मंत्र — एक फ़ाइल हर पाठ की
for i, (paath, info) in enumerate(bhare.items(), 1):
    m = info["m"]
    uses = info["uses"]
    naam_pehla = uses[0][1]
    fn = os.path.join(OUT, "मंत्र", "%02d_%s.md" % (i, safe(naam_pehla)))
    jagah = "\n".join("- %s — *%s*" % (p, c) for p, c in uses)
    body = f"""# मंत्र {i} — {naam_pehla}

**भरोसा:** {BHAROSA_NAAM.get(m.get('bharosa','kam'),'कम')} · **हालत:** ⬜ पंडित जी से पास नहीं

## पाठ

```
{paath}
```

## रोमन (सिर्फ़ पढ़ने की सहायता, उच्चारण का नियम नहीं)

```
{m.get('roman','').strip() or '—'}
```

## अर्थ (अपना लिखा हुआ)

{m.get('arth','').strip() or '—'}

## दूसरा चलन

{m.get('vikalp','').strip() or 'कोई दर्ज नहीं'}

## स्रोत

{m.get('strot','').strip() or '—'}

## यह पाठ कहाँ-कहाँ चलता है ({len(uses)} जगह)

{jagah}

---

## पंडित जी यहाँ लिखें

- [ ] पाठ सही है, ऐसे ही रहने दें
- [ ] सुधार चाहिए — नीचे लिखें

```




```
"""
    w(fn, body)
    files_written.append(fn)

# ══════════════════════════════════════════ संकल्प
sankalp_md = os.path.join(OUT, "संकल्प.md")
w(sankalp_md, """# संकल्प की संस्कृत

**कोड:** `engine/lib/src/sankalp.dart` · **स्रोत:** `docs/18_SROT_PANJI.md` अध्याय १

ऐप पंचांग से आज का पूरा संकल्प ख़ुद बना देता है — संवत्सर, अयन, ऋतु, मास,
पक्ष, तिथि, वार, नक्षत्र सब भरकर। **मानों की जाँच हो चुकी है** (दृक्
पंचांग से बारह तारीख़ें, पाँच शहर)। यहाँ **संस्कृत के रूप** हैं।

## 🔑 यह पन्ना अब पहले जैसा नहीं है (→ D-041)

पहले यहाँ तीन 🔴 शक लिखे थे और सब कुछ "पंडित जी से पास होना बाक़ी" था।
**वह इंतज़ार छोड़ दिया गया** — डेवलपर ने 10–15 पंडितों को दिखाया और वे
आपस में ही नहीं मिले। अब नियम यह है:

* जो **व्याकरण** से सिद्ध है — ठीक कर दिया गया
* जिसका **छपा स्रोत** मिला — उसी रूप में, स्रोत दर्ज करके
* जहाँ **कई प्रकाशित रूप** मिले — ऐप चुनता नहीं, दोनों दर्ज हैं
* जहाँ **कुछ नहीं मिला** — ख़ाली, वजह लिखी हुई

## आज का बना हुआ संकल्प

```
ॐ विष्णुर्विष्णुर्विष्णुः।
श्रीमद्भगवतो महापुरुषस्य विष्णोराज्ञया प्रवर्तमानस्य
अद्य ब्रह्मणो द्वितीये परार्धे श्वेतवाराहकल्पे
वैवस्वतमन्वन्तरे अष्टाविंशतितमे कलियुगे कलिप्रथमचरणे
जम्बूद्वीपे भरतखण्डे भारतवर्षे आर्यावर्तान्तर्गते
दिल्लीनाम्नि नगरे
सिद्धार्थी नाम संवत्सरे दक्षिणायने
वर्षर्तौ श्रावणमासे शुक्लपक्षे
अष्टम्यां तिथौ गुरुवासरे विशाखानक्षत्रे
कश्यपगोत्रोत्पन्नः चन्दन सिंह नामाहम्
मम आत्मनः श्रुतिस्मृतिपुराणोक्तफलप्राप्त्यर्थं
श्री सत्यनारायण पूजनं करिष्ये।
```

## जो सुधारा गया

| क्या | पहले | अब | आधार |
|---|---|---|---|
| तिथि | नवमी तिथौ | **नवम्यां तिथौ** | 🟢 व्याकरण — सप्तमी विभक्ति |
| यजमान (स्त्री) | गोत्रोत्पन्नः | **गोत्रोत्पन्ना** | 🟢 व्याकरण — विशेषण कर्ता से मिलता है |
| नाम | चन्दन सिंह अहं | **…नामाहम्** | 🔵 छपी पद्धति (`अमुकनामा`) |
| जगह | दिल्ली क्षेत्रे | **दिल्लीनाम्नि नगरे** | 🔵 छपी पद्धति (`अमुकनाम्नि नगरे`) |
| ऋतु | वर्षा ऋतौ | **वर्षर्तौ** | 🟢 गुण सन्धि |
| मास, पक्ष, नक्षत्र | अलग-अलग | **समास बनाकर** | 🟢 व्याकरण |
| गोत्र न पता हो | चुपचाप कश्यप | **पूछकर, श्लोक के साथ** | 🔵 हेमाद्रि चन्द्रिका |

## 🟠 जहाँ कई रूप मिले — ऐप ने चुना नहीं

| क्या | ऐप में | दूसरे रूप जो मिले |
|---|---|---|
| भूगोल | जम्बूद्वीपे भरतखण्डे भारतवर्षे | तीन प्रकाशित पद्धतियाँ, तीनों का क्रम अलग |
| अधिक मास | अधिकज्येष्ठमासे | पुरुषोत्तममासे भी चलता है |
| पूर्णिमा | पौर्णमास्यां | पूर्णिमायाम् भी शुद्ध है |
| ऋतु | वर्षर्तौ (सन्धि) | वर्षा ऋतौ (पदपाठ) भी मिलता है |
| गोत्र का नाम | कश्यप (जैसा यूज़र जानता है) | काश्यप (शास्त्रीय वृद्धि रूप) |

## ⬜ जो अब भी नहीं है

- **दम्पति (द्विवचन)** का रूप — प्रामाणिक पाठ नहीं मिला
- **विदेश** में रहने वाले यजमान का देश-संकल्प

## पंडित जी कुछ जोड़ना चाहें तो

```




```
""")
files_written.append(sankalp_md)

# ══════════════════════════════════════════ ख़ाली मंत्र — कदम के हिसाब से
for i, (shirshak, uses) in enumerate(khaali_sorted, 1):
    fn = os.path.join(OUT, "खाली-मंत्र", "%02d_%s.md" % (i, safe(shirshak)))
    rows = "\n".join("- **%s** — %s" % (p, vajah) for p, vajah in uses)
    body = f"""# ख़ाली मंत्र — {shirshak}

**{len(uses)} पूजा में यह कदम है, और मंत्र जान-बूझकर ख़ाली है।**

अंदाज़े से मंत्र लिखना इस ऐप में मना है (मंत्र ग़लत होना तिथि ग़लत होने से
भी बुरा माना गया है)। हर पूजा के आगे वजह लिखी है।

## किन पूजाओं में, और क्यों

{rows}

## पंडित जी यहाँ लिखें

- [ ] यह चरण इस पद्धति में होता ही नहीं — हटा दें
- [ ] होता है — मंत्र नीचे लिखें

```




```
"""
    w(fn, body)
    files_written.append(fn)

# ══════════════════════════════════════════ हर पूजा — अपनी फ़ाइल
for d in pujas:
    ms = [c.get("mantra") for c in d["charan"] if c.get("mantra")]
    mb = [x for x in ms if x.get("devanagari", "").strip()]
    samagri_lines = []
    seen_samuh = []
    for s in d["samagri"]:
        if s["samuh"] not in seen_samuh:
            seen_samuh.append(s["samuh"])
            samagri_lines.append("\n**%s**" % s["samuh"])
        maap = " ".join(x for x in [s.get("matra", ""), s.get("ikai", "")] if x.strip())
        zaruri = "" if s["zaruri"] else " (वैकल्पिक)"
        samagri_lines.append("- %s%s%s" % (s["vastu"], (" — " + maap) if maap else "", zaruri))
    # वर्ज्य द्रव्य — क्या नहीं चढ़ाना (→ A10)। हर पूजा में नहीं होता।
    varjya_lines = []
    for v in d.get("varjya", []):
        varjya_lines.append(
            "- **%s** — %s\n  *स्रोत:* %s (भरोसा: %s)"
            % (v["vastu"], v["kyon"], v["strot"],
               BHAROSA_NAAM.get(v.get("bharosa", "kam"), "कम")))

    kadam_lines = []
    for i, c in enumerate(d["charan"], 1):
        mantra_tag = ""
        if c.get("mantra"):
            mantra_tag = " 🕉️ (भरा हुआ)" if c["mantra"].get("devanagari", "").strip() else " 🕉️ (ख़ाली)"
        # ⚠️ यहाँ कदम का विवरण कभी मत काटो (पहले `[:120]` लगा था)।
        # पंडित जी जिस पाठ पर मुहर लगाएँगे, वो पूरा दिखना चाहिए —
        # आधा-अधूरा पाठ पास कराना इस पूरे फ़ोल्डर के मक़सद के ख़िलाफ़ है।
        # विवरण में नई पंक्तियाँ हों तो उन्हें सूची के अंदर ही रखो
        # (तीन स्पेस से indent, ताकि markdown क्रम-संख्या न तोड़े)।
        vivaran = c["vivaran"].strip().replace("\n", "\n   ")
        kadam_lines.append("%d. **%s**%s — %s" % (
            i, c["shirshak"], mantra_tag, vivaran))

    varjya_block = (
        "\n## क्या नहीं चढ़ाना (%d)\n\n%s\n"
        % (len(varjya_lines), chr(10).join(varjya_lines))
    ) if varjya_lines else ""

    fn = os.path.join(OUT, "पूजा", "%s.md" % safe(d["naam"]))
    body = f"""# {d['naam']}

**दायरा:** {SCOPE_NAAM.get(d.get('scope'), '—')} · **कठिनाई:** {d['kathinai']} · **समय:** लगभग {d['samayMinute']} मिनट
**हालत:** ⬜ पंडित जी से पास नहीं (`jaanch.paas: false`)
**मंत्र:** {len(mb)} / {len(ms)} भरे हुए

## परिचय

{d['parichay']}

## कब करें

{d['kabKarein']['saral']}

{d['kabKarein'].get('note','')}

## कदम ({len(d['charan'])})

{chr(10).join(kadam_lines)}

## सामग्री ({len(d['samagri'])})
{chr(10).join(samagri_lines)}
{varjya_block}
## स्रोत

**पद्धति:** {d['strot']['paddhati']} · **क्षेत्र:** {d['strot']['kshetra']}

{d['strot'].get('note','')}

## पंडित जी यहाँ लिखें

- [ ] दायरा ("{SCOPE_NAAM.get(d.get('scope'))}") सही है
- [ ] कदमों का क्रम सही है
- [ ] सामग्री में कुछ छूटा/फ़ालतू है — नीचे लिखें
- [ ] मंत्रों के लिए अलग फ़ाइलें देखें (`मंत्र/` और `खाली-मंत्र/` फ़ोल्डर)

```




```
"""
    w(fn, body)
    files_written.append(fn)

# ══════════════════════════════════════════ README
readme = os.path.join(OUT, "00_README.md")
kul_slot = sum(len(v["uses"]) for v in bhare.values()) + sum(len(v) for v in khaali.values())
w(readme, f"""# पंडित जी की जाँच — फ़ाइल के हिसाब से

> **यह फ़ोल्डर JSON से अपने आप बनता है** — इसे हाथ से मत बदलिए।
> दोबारा बनाने के लिए: `python tools/banao_pandit_folder.py`
>
> पूरी बात **एक ही पन्ने** में चाहिए तो `docs/12_PANDIT_SHEET.html`
> (छापने लायक, A4) देखिए — यहाँ वही डेटा टुकड़ों में बँटा है, ताकि एक
> बार में सिर्फ़ एक चीज़ भेजी या पढ़ी जा सके।

## फ़ोल्डर में क्या है

| फ़ोल्डर/फ़ाइल | क्या | कितनी फ़ाइलें |
|---|---|---|
| `मंत्र/` | हर **अलग** मंत्र-पाठ की अपनी फ़ाइल — पाठ, अर्थ, स्रोत, दूसरा चलन, कहाँ-कहाँ चलता है | {len(bhare)} |
| `संकल्प.md` | संकल्प के 14 रूप, तीन शक वाले सवालों समेत | 1 |
| `खाली-मंत्र/` | हर ख़ाली जगह की अपनी फ़ाइल — किन पूजाओं में, क्यों नहीं लिखा | {len(khaali)} |
| `पूजा/` | हर पूजा की अपनी फ़ाइल — दायरा, कदम, सामग्री, स्रोत | {len(pujas)} |

## संख्या में

- {len(pujas)} पूजाएँ, कुल {kul_slot} जगह मंत्र आता है
- वे असल में सिर्फ़ **{len(bhare)} अलग पाठ** हैं (`मंत्र/` की फ़ाइलें उतनी ही हैं)
- {sum(len(v['uses']) for v in bhare.values())} जगह भरी हुई, {sum(len(v) for v in khaali.values())} जगह जान-बूझकर ख़ाली

## कैसे इस्तेमाल करें

**अगर एक बार में एक ही मंत्र किसी को भेजना/दिखाना हो** — `मंत्र/` में
जाकर वो एक फ़ाइल भेज दीजिए। सबसे ऊपर की फ़ाइलें (01, 02, 03...) सबसे
ज़्यादा जगह चलती हैं — उन्हें पहले पास कराएँ, फ़ायदा सबसे ज़्यादा होगा।

**अगर एक पूजा की पूरी बात चाहिए** — `पूजा/<पूजा का नाम>.md` खोलिए। वहाँ
कदम, सामग्री और स्रोत हैं; मंत्रों के लिए वहाँ से `मंत्र/` और
`खाली-मंत्र/` की फ़ाइलों का हवाला मिलेगा।

**जाँच हो जाने के बाद** — जो पास हुआ उसे `app/assets/vidhi/*.json` में
`sthiti: "paas"` करके डालिए, फिर `python tools/banao_pandit_sheet.py`
और `python tools/banao_pandit_folder.py` दोनों दोबारा चला दीजिए ताकि
यह फ़ोल्डर और वो शीट भी नई हालत दिखाएँ।

⚠️ **आधा-अधूरा पास मत करवाइए।** एक मंत्र या एक रूप अटका रह जाए तो उसे
ख़ाली छोड़ दीजिए — ऐप वहाँ साफ़ लिख देगा कि यह अभी नहीं आया।
""")
files_written.append(readme)

print("बना: %d फ़ाइलें (मंत्र %d, ख़ाली %d, पूजा %d, संकल्प+README 2)"
      % (len(files_written), len(bhare), len(khaali), len(pujas)))
