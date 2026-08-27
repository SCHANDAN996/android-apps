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
import io, json, glob, os, re
from collections import defaultdict, OrderedDict

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
w(sankalp_md, """# संकल्प की संस्कृत — 14 टुकड़े

**हालत:** ⬜ पंडित जी से जाँच बाक़ी — `Sankalp.needsPanditReview` अभी भी `true`
**कोड:** `engine/lib/src/sankalp.dart` · **पूरा ब्यौरा:** `docs/11_SANKALP_VYAKARAN.md`

ऐप पंचांग से आज का पूरा संकल्प ख़ुद बना देता है — संवत्सर, अयन, ऋतु, मास,
पक्ष, तिथि, वार, नक्षत्र सब भरकर। **मानों की जाँच हो चुकी है** (दृक्
पंचांग से बारह तारीख़ें, पाँच शहर)। यहाँ सिर्फ़ **संस्कृत के रूप** देखने
हैं।

## 🔴 तीन जगह हमें ख़ुद शक है

**तिथि** — ऐप "नवमी तिथौ" बनाता है। क्या "नवम्यां तिथौ" होना चाहिए? अगर
हाँ, तो तीसों तिथियों के सही रूप चाहिए।

**गोत्र** — ऐप हमेशा "गोत्रोत्पन्नः" बनाता है, जो पुल्लिंग है। महिला
यजमान के लिए "गोत्रोत्पन्ना" चाहिए — और शायद कुछ और शब्द भी बदलते हैं।

**नाम** — ऐप "…गोत्रोत्पन्नः चन्दन सिंह अहं" बनाता है। बीच में "नाम"
जोड़ना चाहिए ("…नामाहं")?

## पूरी सूची

| # | ऐप क्या बनाता है | व्याकरण | भरोसा |
|---|---|---|---|
| 1 | जम्बूद्वीपे भरतखण्डे भारतवर्षे | तीनों सप्तमी एकवचन | ऊँचा |
| 2 | आर्यावर्तान्तर्गते | आर्यावर्त + अन्तर्गत, सप्तमी | ऊँचा |
| 3 | वाराणसी क्षेत्रे | क्षेत्रे सप्तमी, शहर हिंदी रूप में | मध्यम |
| 4 | सिद्धार्थी नाम संवत्सरे | संवत्सरे सप्तमी | ऊँचा |
| 5 | उत्तरायणे / दक्षिणायने | सप्तमी एकवचन | ऊँचा |
| 6 | वर्षा ऋतौ | सन्धि से "वर्षर्तौ" बनता है — अलग लिखें या जोड़ें? | मध्यम |
| 7 | श्रावण मासे | मासे सप्तमी | ऊँचा |
| 7ब | अधिक ज्येष्ठ मासे | "पुरुषोत्तम मासे" कहना चाहिए? | मध्यम |
| 8 | शुक्ल/कृष्ण पक्षे | पक्षे सप्तमी | ऊँचा |
| **9** | **नवमी तिथौ** | 🔴 ऊपर देखें | **कम** |
| 10 | शुक्रवासरे | वासरे सप्तमी | ऊँचा |
| 11 | अनुराधा नक्षत्रे | नक्षत्रे सप्तमी | मध्यम |
| **12** | **कश्यप गोत्रोत्पन्नः** | 🔴 महिला के लिए ग़लत | **कम** |
| **13** | **चन्दन सिंह अहं** | 🔴 "नाम" छूट रहा | **कम** |
| 14 | श्री सत्यनारायण पूजनं करिष्ये | लृट् लकार, आत्मनेपद | ऊँचा |

## शुरुआत का हिस्सा (हर बार एक जैसा)

```
ॐ विष्णुर्विष्णुर्विष्णुः।
श्रीमद्भगवतो महापुरुषस्य विष्णोराज्ञया प्रवर्तमानस्य
अद्य ब्रह्मणो द्वितीये परार्धे श्वेतवाराहकल्पे
वैवस्वतमन्वन्तरे अष्टाविंशतितमे कलियुगे कलिप्रथमचरणे
मम आत्मनः श्रुतिस्मृतिपुराणोक्तफलप्राप्त्यर्थं
```

## पंडित जी यहाँ लिखें

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
    kadam_lines = []
    for i, c in enumerate(d["charan"], 1):
        mantra_tag = ""
        if c.get("mantra"):
            mantra_tag = " 🕉️ (भरा हुआ)" if c["mantra"].get("devanagari", "").strip() else " 🕉️ (ख़ाली)"
        kadam_lines.append("%d. **%s**%s — %s" % (
            i, c["shirshak"], mantra_tag, c["vivaran"][:120].replace("\n", " ")))

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
