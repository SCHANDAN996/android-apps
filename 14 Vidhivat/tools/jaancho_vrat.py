# -*- coding: utf-8 -*-
"""व्रत के पन्नों की जाँच (→ D-075, docs/26_VRAT_YOJANA.md)।

UI बनने से पहले ही कंटेंट का ढाँचा और ईमानदारी जाँचता है:
  python tools/jaancho_vrat.py

कुछ भी ग़लत मिला तो हर ग़लती छापकर exit 1।
"""
import io
import json
import os
import sys
import unicodedata

JAD = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(JAD, "app", "assets")
VRAT = os.path.join(ASSETS, "vrat")
KATHA = os.path.join(ASSETS, "katha")

# वही सूची जो app/test/paath_vrat_sections_test.dart में व्रत के पन्ने पर है
# (→ D-051), और "लाभ होगा" ग्रहण वाली सूची से।
DAAWE = ["मनोकामना", "पूरी होती", "लाभ होता", "लाभ होगा", "फल मिलता",
         "पुण्य मिलता", "कष्ट दूर"]

# बारहों खाने — JSON की कुंजी में
KHAANE = ["naam", "devta", "samuh", "ekLine", "kab", "bhav", "mahatmya",
          "niyam", "bhojan", "paran", "puja", "mantra", "kathaIds", "paath",
          "udyapan", "savdhani", "sawaal", "strot"]

SUCHNA_SEEMA = 600  # ⓘ के पीछे का पाठ (→ D-050)
BHAROSA = {"uncha", "madhyam", "kam"}
SAMUH = {"vaar", "tithi", "ekadashi_varsh", "varshik"}
ENGINE = {"ekadashi", "pradosh", "sankashti", "masik_shivratri", "purnima",
          "amavasya"}

galti = []


def nfc(s):
    return unicodedata.normalize("NFC", s)


def padho(path):
    with io.open(path, encoding="utf-8") as f:
        return json.load(f)


def sab_paath(x):
    """JSON के हर string को एक-एक करके देता है।"""
    if isinstance(x, str):
        yield x
    elif isinstance(x, dict):
        for v in x.values():
            yield from sab_paath(v)
    elif isinstance(x, list):
        for v in x:
            yield from sab_paath(v)


def daawa_jaancho(naam, data):
    for s in sab_paath(data):
        s = nfc(s)
        for d in DAAWE:
            if nfc(d) in s:
                galti.append(f"{naam}: फल-दावे वाला शब्द \"{d}\" — …{s[:60]}…")


def khaali(v):
    return v is None or (isinstance(v, (str, list, dict)) and len(v) == 0)


def shabd(s):
    return len(s.split())


def katha_jaancho(kid, vaar_ka):
    path = os.path.join(KATHA, kid + ".json")
    if not os.path.exists(path):
        galti.append(f"katha/{kid}: फ़ाइल नहीं है")
        return
    k = padho(path)
    naam = f"katha/{kid}"
    if k.get("id") != kid:
        galti.append(f"{naam}: id \"{k.get('id')}\" फ़ाइल के नाम से नहीं मिलता")
    if k.get("roop") != "bhavarth":
        galti.append(f"{naam}: roop bhavarth नहीं")
    if len(k.get("strot", "").strip()) <= 60:
        galti.append(f"{naam}: स्रोत 60 अक्षर से छोटा")
    if len(k.get("kabSunayen", "").strip()) <= 30:
        galti.append(f"{naam}: \"कब सुनाएँ\" 30 अक्षर से छोटा")
    if vaar_ka and "लोक-कथा" not in nfc(k.get("strot", "")):
        galti.append(f"{naam}: वार के व्रत की कथा पर \"लोक-कथा\" लिखा होना चाहिए")
    adhyay = k.get("adhyay", [])
    if not adhyay:
        galti.append(f"{naam}: कोई अध्याय नहीं")
    for i, a in enumerate(adhyay):
        if a.get("kram") != i + 1:
            galti.append(f"{naam}: अध्याय {i + 1} का kram {a.get('kram')}")
        if khaali(a.get("shirshak")) or khaali(a.get("saar")):
            galti.append(f"{naam}: अध्याय {i + 1} में शीर्षक या सार ख़ाली")
        if shabd(a.get("gadya", "")) <= 200:
            galti.append(f"{naam}: अध्याय {i + 1} 200 शब्द से छोटा")
    daawa_jaancho(naam, k)


def vrat_jaancho(e, paath_ids):
    vid = e["id"]
    naam = f"vrat/{vid}"
    v = padho(os.path.join(VRAT, vid + ".json"))

    if v.get("schemaVersion") != 1:
        galti.append(f"{naam}: schemaVersion 1 नहीं")
    if v.get("id") != vid:
        galti.append(f"{naam}: id \"{v.get('id')}\" फ़ाइल के नाम से नहीं मिलता")
    for kunji in KHAANE:
        # पाठ ख़ाली हो सकता है — हर व्रत की आरती ऐप में नहीं है, पर खाना हो
        if kunji == "paath" and isinstance(v.get(kunji), list):
            continue
        # कथा जान-बूझकर न ली हो तो कारण लिखा होना चाहिए (→ D-076)
        if kunji == "kathaIds" and v.get(kunji) == [] and len(nfc(v.get("kathaKyonNahi") or "").strip()) > 60:
            continue
        if kunji not in v or khaali(v[kunji]):
            galti.append(f"{naam}: खाना \"{kunji}\" नहीं है या ख़ाली है")
    for kunji in ("naam", "samuh", "devta"):
        if v.get(kunji) != e.get(kunji):
            galti.append(f"{naam}: {kunji} सूची से नहीं मिलता")
    if v.get("samuh") not in SAMUH:
        galti.append(f"{naam}: samuh \"{v.get('samuh')}\" अनजाना")

    # कब करें
    kab = v.get("kab", {})
    for kunji in ("saral", "shuruKab", "kitniBaar"):
        if khaali(kab.get(kunji)):
            galti.append(f"{naam}: kab.{kunji} ख़ाली")
    niyam = kab.get("niyam", {})
    if v.get("samuh") == "vaar":
        if niyam.get("vaar") not in range(1, 8) or niyam.get("vaar") != e.get("vaar"):
            galti.append(f"{naam}: kab.niyam.vaar सूची से नहीं मिलता")
    if v.get("samuh") == "tithi":
        if niyam.get("engine") != e.get("engine"):
            galti.append(f"{naam}: kab.niyam.engine सूची से नहीं मिलता")
        elif niyam.get("engine") is None:
            # इंजन अभी यह व्रत नहीं गिनता — तिथि-पक्ष लिखा हो, और "अपने पंचांग से
            # देखें" वाली बात भी, ताकि ऐप तारीख़ का दिखावा न करे
            if niyam.get("tithi") not in range(1, 16) or niyam.get("paksha") not in (0, 1):
                galti.append(f"{naam}: इंजन नहीं है तो kab.niyam में tithi और paksha हों")
            if "पंचांग" not in nfc(kab.get("doDin") or ""):
                galti.append(f"{naam}: इंजन नहीं है तो doDin में अपने पंचांग से देखने की बात हो")
        elif niyam.get("engine") not in ENGINE:
            galti.append(f"{naam}: kab.niyam.engine इंजन के व्रतों में नहीं")

    if v.get("samuh") == "varshik":
        if khaali(niyam.get("maas")) or not (niyam.get("tithi") in range(1, 16) or niyam.get("vaar") in range(1, 8)):
            galti.append(f"{naam}: साल के व्रत में kab.niyam में maas और tithi (या vaar) हों")
        if "festival" not in niyam:
            galti.append(f"{naam}: kab.niyam.festival लिखा हो (इंजन का त्योहार, या null)")
        elif niyam.get("festival") is None and "पंचांग" not in nfc(kab.get("doDin") or ""):
            galti.append(f"{naam}: त्योहार-इंजन नहीं है तो doDin में अपने पंचांग से देखने की बात हो")

    # माहात्म्य — हमेशा स्रोत के साथ
    m = v.get("mahatmya", {})
    if khaali(m.get("kathan")) or khaali(m.get("strot")):
        galti.append(f"{naam}: माहात्म्य का कथन या स्रोत ख़ाली")
    if m.get("bharosa") not in BHAROSA:
        galti.append(f"{naam}: माहात्म्य का भरोसा \"{m.get('bharosa')}\" अनजाना")
    if len(m.get("strot", "")) > SUCHNA_SEEMA:
        galti.append(f"{naam}: माहात्म्य का स्रोत {SUCHNA_SEEMA} से लंबा")
    if "ऐप" not in nfc(m.get("strot", "")):
        galti.append(f"{naam}: माहात्म्य के स्रोत में यह नहीं लिखा कि यह ऐप का वादा नहीं")

    # नियम
    n = v.get("niyam", {})
    if khaali(n.get("pehleDin")) or khaali(n.get("vratKeDin")):
        galti.append(f"{naam}: नियम अधूरे")

    # भोजन — निर्जल अकेला नहीं, और उसका सुझाव कभी नहीं
    roop = [b.get("roop") for b in v.get("bhojan", [])]
    if not any(r in ("फलाहार", "एक समय") for r in roop):
        galti.append(f"{naam}: भोजन में फलाहार या एक समय का रूप नहीं")
    for b in v.get("bhojan", []):
        if b.get("roop") not in ("फलाहार", "एक समय", "निर्जल"):
            galti.append(f"{naam}: भोजन का रूप \"{b.get('roop')}\" अनजाना")
        if b.get("roop") == "निर्जल" and "सुझाव नहीं" not in nfc(b.get("vivaran", "")):
            galti.append(f"{naam}: निर्जल के साथ \"ऐप इसका सुझाव नहीं देता\" नहीं लिखा")
    if "निर्जल" in roop and roop[0] == "निर्जल":
        galti.append(f"{naam}: निर्जल पहला रूप नहीं हो सकता")

    # सावधानी
    if not any("डॉक्टर" in nfc(s) for s in v.get("savdhani", [])):
        galti.append(f"{naam}: सावधानी में डॉक्टर से पूछने की बात नहीं")

    # पूजा
    for i, p in enumerate(v.get("puja", [])):
        if p.get("kram") != i + 1:
            galti.append(f"{naam}: पूजा कदम {i + 1} का kram {p.get('kram')}")
        if khaali(p.get("shirshak")) or khaali(p.get("vivaran")):
            galti.append(f"{naam}: पूजा कदम {i + 1} अधूरा")

    # मंत्र — वही नियम जो विधि में (→ D-041, D-072)
    mt = v.get("mantra", {})
    if mt.get("devanagari", "").strip():
        for kunji in ("roman", "arth", "strot"):
            if khaali(mt.get(kunji)):
                galti.append(f"{naam}: मंत्र का {kunji} ख़ाली")
    elif mt.get("sthiti") != "khaali" or len(mt.get("strot", "").strip()) < 40:
        galti.append(f"{naam}: मंत्र ख़ाली है तो sthiti \"khaali\" हो और स्रोत में कारण लिखा हो")
    if mt.get("bharosa") not in BHAROSA:
        galti.append(f"{naam}: मंत्र का भरोसा \"{mt.get('bharosa')}\" अनजाना")
    if mt.get("sthiti") == "paas":
        galti.append(f"{naam}: मंत्र \"paas\" नहीं हो सकता — पंडित जी की जाँच नहीं हुई (→ D-072)")
    for kunji in ("strot", "vikalp"):
        if len(mt.get(kunji, "")) > SUCHNA_SEEMA:
            galti.append(f"{naam}: मंत्र का {kunji} {SUCHNA_SEEMA} से लंबा")

    # जुड़ी हुई चीज़ें सचमुच हों
    for p in v.get("paath", []):
        if p not in paath_ids:
            galti.append(f"{naam}: पाठ \"{p}\" तैयार पाठों में नहीं")
    vidhi = v.get("vidhiId")
    if vidhi is not None and not os.path.exists(
            os.path.join(ASSETS, "vidhi", vidhi + ".json")):
        galti.append(f"{naam}: विधि \"{vidhi}\" की फ़ाइल नहीं")
    for s in v.get("sawaal", []):
        if khaali(s.get("sawaal")) or khaali(s.get("jawaab")):
            galti.append(f"{naam}: कोई सवाल या जवाब ख़ाली")

    daawa_jaancho(naam, v)
    for kid in v.get("kathaIds", []):
        katha_jaancho(kid, v.get("samuh") == "vaar")


MAAS = ["चैत्र", "वैशाख", "ज्येष्ठ", "आषाढ़", "श्रावण", "भाद्रपद", "आश्विन",
        "कार्तिक", "मार्गशीर्ष", "पौष", "माघ", "फाल्गुन"]


def ekadashi_varsh_jaancho():
    """साल की एकादशियाँ — बारह महीने × दो पक्ष, और अधिक मास की दो।"""
    path = os.path.join(VRAT, "_ekadashi_varsh.json")
    if not os.path.exists(path):
        return
    naam = "_ekadashi_varsh"
    d = padho(path)
    suchi = d.get("ekadashi", [])
    ids = [e.get("id") for e in suchi]
    if len(set(ids)) != len(ids):
        galti.append(f"{naam}: कोई id दो बार")
    jode = set()
    for i, e in enumerate(suchi):
        eid = e.get("id")
        if e.get("kram") != i + 1:
            galti.append(f"{naam}/{eid}: kram {e.get('kram')}, होना चाहिए {i + 1}")
        for k in ("naam", "maas", "amantMaas", "kathaId", "ekLine", "vishesh"):
            if khaali(e.get(k)):
                galti.append(f"{naam}/{eid}: {k} ख़ाली")
        if e.get("paksha") not in (0, 1):
            galti.append(f"{naam}/{eid}: paksha 0 या 1 हो")
        if e.get("adhik"):
            jode.add(("अधिक", e.get("paksha")))
        else:
            maas = nfc(e.get("maas", ""))
            if maas not in [nfc(m) for m in MAAS]:
                galti.append(f"{naam}/{eid}: महीना \"{maas}\" अनजाना")
            else:
                # अमांत में कृष्ण पक्ष की एकादशी पिछले महीने में गिनी जाती है
                j = [nfc(m) for m in MAAS].index(maas)
                chahiye = nfc(MAAS[j - 1]) if e.get("paksha") == 1 else maas
                if nfc(e.get("amantMaas", "")) != chahiye:
                    galti.append(f"{naam}/{eid}: amantMaas \"{e.get('amantMaas')}\", होना चाहिए \"{chahiye}\"")
            jode.add((maas, e.get("paksha")))
        if "निर्जल" in nfc(e.get("naam", "")) and "सुझाव नहीं" not in nfc(e.get("vishesh", "")):
            galti.append(f"{naam}/{eid}: निर्जला के साथ \"ऐप सुझाव नहीं देता\" लिखा हो")
        katha_jaancho(e.get("kathaId", ""), False)
    if len(jode) != 26 or len(suchi) != 26:
        galti.append(f"{naam}: 24 + 2 अधिक मास = 26 एकादशियाँ होनी चाहिए, मिलीं {len(suchi)} ({len(jode)} अलग महीना-पक्ष)")
    daawa_jaancho(naam, d)


def main():
    suchi = padho(os.path.join(VRAT, "_suchi.json"))
    paath = padho(os.path.join(ASSETS, "paath", "_suchi.json"))
    paath_ids = {p["id"] for p in paath["paath"] if p.get("taiyar")}

    ids = [e["id"] for e in suchi["vrat"]]
    for d in {i for i in ids if ids.count(i) > 1}:
        galti.append(f"_suchi: id \"{d}\" दो बार")
    samuh_ids = {s["id"] for s in suchi["samuh"]}

    faailein = {f[:-5] for f in os.listdir(VRAT)
                if f.endswith(".json") and not f.startswith("_")}
    for e in suchi["vrat"]:
        if e.get("faail"):
            # व्रत-पन्ना नहीं, अलग ढाँचे वाली फ़ाइल (जैसे साल की एकादशियाँ)
            hai = os.path.exists(os.path.join(VRAT, e["faail"]))
            if e.get("taiyar") != hai:
                galti.append(f"_suchi/{e['id']}: taiyar {e.get('taiyar')}, पर {e['faail']} "
                             f"{'है' if hai else 'नहीं है'}")
            continue
        if e.get("samuh") not in samuh_ids:
            galti.append(f"_suchi/{e['id']}: samuh \"{e.get('samuh')}\" अनजाना")
        if e.get("paas"):
            galti.append(f"_suchi/{e['id']}: paas सच नहीं हो सकता (→ D-072)")
        if e.get("taiyar") != (e["id"] in faailein):
            galti.append(f"_suchi/{e['id']}: taiyar {e.get('taiyar')}, "
                         f"पर फ़ाइल {'है' if e['id'] in faailein else 'नहीं है'}")
    for f in faailein - set(ids):
        galti.append(f"vrat/{f}.json सूची में नहीं")

    taiyar = [e for e in suchi["vrat"] if e.get("taiyar") and e["id"] in faailein]
    for e in taiyar:
        vrat_jaancho(e, paath_ids)
    ekadashi_varsh_jaancho()

    if galti:
        for g in galti:
            print("✗", g)
        print(f"\n{len(galti)} ग़लतियाँ")
        sys.exit(1)
    print(f"✓ {len(taiyar)} व्रत, {len(suchi['vrat'])} सूची में — सब ठीक")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
