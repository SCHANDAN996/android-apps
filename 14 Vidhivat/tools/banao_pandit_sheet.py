# -*- coding: utf-8 -*-
"""पंडित जी की जाँच-शीट बनाओ — **JSON से अपने आप।**

    cd "14 Vidhivat" && python tools/banao_pandit_sheet.py

नतीजा docs/12_PANDIT_SHEET.html में लिखा जाता है। ब्राउज़र में खोलकर
Ctrl+P से A4 पर छाप लीजिए।


पहले यह शीट हाथ से लिखी थी और कंटेंट बदलते ही पुरानी पड़ गई (12 पूजाओं
वाली शीट, जबकि ऐप में 18 हो चुकी थीं, और गणपति का सुधरा हुआ स्रोत उसमें
था ही नहीं)। अब हर बार इसी स्क्रिप्ट से बनेगी, इसलिए दोबारा नहीं बिगड़ेगी।

सबसे बड़ी बात: शीट **पाठ-वार** है, पूजा-वार नहीं। 79 भरे हुए मंत्र असल
में सिर्फ़ 15 अलग पाठ हैं — पंडित जी 15 डिब्बों पर निशान लगाएँ, और सब
जगह लागू हो जाए।
"""
import io, json, glob, os, html
from collections import defaultdict, OrderedDict

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)                      # 14 Vidhivat/
APP = os.path.join(_ROOT, "app")
OUT = os.path.join(_ROOT, "docs", "12_PANDIT_SHEET.html")

BHAROSA_NAAM = {"uncha": ("भरोसा ऊँचा", "uncha"),
                "madhyam": ("भरोसा मध्यम", "madhyam"),
                "kam": ("भरोसा कम", "kam")}
SCOPE_NAAM = {
    "self_guided": "घर पर अपने आप",
    "regional_profile": "क्षेत्रीय परंपरा",
    "preparation_only": "सिर्फ़ तैयारी",
    "expert_assisted": "पंडित जी के साथ",
}

def e(x):
    return html.escape(x or "", quote=False)

# ── कंटेंट पढ़ो ──
files = [p for p in sorted(glob.glob(os.path.join(APP, "assets", "vidhi", "*.json")))
         if not p.endswith("_suchi.json")]
pujas = [json.load(io.open(p, encoding="utf-8")) for p in files]

# चालीसा और आरती — पूजा से अलग फ़ोल्डर (→ D-039)
paath_files = [p for p in sorted(glob.glob(
    os.path.join(APP, "assets", "paath", "*.json")))
    if not p.endswith("_suchi.json")]
paaths = [json.load(io.open(p, encoding="utf-8")) for p in paath_files]
paaths.sort(key=lambda d: (d.get("prakar", ""), d["naam"]))
PAATH_PRAKAR = {"chalisa": "चालीसा", "aarti": "आरती", "stotra": "स्तोत्र"}
pujas.sort(key=lambda d: (list(SCOPE_NAAM).index(d.get("scope", "self_guided")), d["naam"]))

bhare = OrderedDict()     # देवनागरी → {mantra, uses:[(पूजा, चरण)]}
khaali = defaultdict(list)  # वजह → [(पूजा, चरण)]

for d in pujas:
    for c in d["charan"]:
        m = c.get("mantra")
        if not m:
            continue
        if m.get("devanagari", "").strip():
            k = m["devanagari"].strip()
            if k not in bhare:
                bhare[k] = {"m": m, "uses": []}
            bhare[k]["uses"].append((d["naam"], c["shirshak"]))
        else:
            khaali[(m.get("vikalp") or "").strip() or "वजह नहीं लिखी"].append(
                (d["naam"], c["shirshak"]))

# सबसे ज़्यादा इस्तेमाल होने वाले पाठ पहले
bhare = OrderedDict(sorted(bhare.items(), key=lambda kv: -len(kv[1]["uses"])))
khaali_sorted = sorted(khaali.items(), key=lambda kv: -len(kv[1]))

kul_slot = sum(1 for d in pujas for c in d["charan"] if c.get("mantra"))
kul_bhare = sum(len(v["uses"]) for v in bhare.values())
kul_khaali = sum(len(v) for v in khaali.values())

# ── HTML ──
CSS = io.open(os.path.join(_HERE, "pandit_sheet.css"), encoding="utf-8").read()

P = []
w = P.append

w('<title>विधिवत जाँच-पत्र</title>')
w('<link rel="preconnect" href="https://fonts.googleapis.com">')
w('<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>')
w('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?'
  'family=Tiro+Devanagari+Sanskrit:ital@0;1&family=Mukta:wght@300;400;500;600;700&display=swap">')
w("<style>\n" + CSS + "\n</style>")

w('<div class="patra">')

# ── शीर्ष ──
w('''  <header class="shirsh">
    <p class="eyebrow">विधिवत · पूजा विधि ऐप · जाँच-पत्र</p>
    <h1>मंत्र, विधि और संकल्प की जाँच</h1>
    <p>
      यह काग़ज़ इसलिए बना है कि आपका समय बोलकर लिखवाने में न लगे। सब कुछ
      पहले से लिखा हुआ है — आपको सिर्फ़ <b>सही पर निशान</b> लगाना है, और
      जहाँ ग़लत हो वहाँ नीचे दी हुई लकीर पर सही रूप लिख देना है।
    </p>
    <p>
      <b>भाग १ पाठ-वार है, पूजा-वार नहीं।</b> ऐप में %d जगह मंत्र आते हैं,
      पर वे असल में सिर्फ़ <b>%d अलग पाठ</b> हैं — एक ही पाठ कई पूजाओं में
      चलता है। इसलिए आपको %d डिब्बों पर निशान लगाना है, %d पर नहीं।
    </p>
    <p>
      जो पाठ यहाँ छपे हैं वे खुले स्रोतों से मिलाकर लिखे गए ड्राफ़्ट हैं।
      <b>इनमें से एक भी अभी ऐप में “पास” नहीं माना गया है</b> — ऐप हर मंत्र
      के साथ यह चेतावनी दिखाता है, और आपके निशान लगने तक दिखाता रहेगा।
    </p>

    <div class="bharne-wale">
      <span>जाँचने वाले पंडित जी — <b>&nbsp;</b></span>
      <span>तारीख़ — <b>&nbsp;</b></span>
      <span>पद्धति / क्षेत्र — <b>&nbsp;</b></span>
    </div>
  </header>

  <p class="chaap-sanket">
    छापने के लिए <b>Ctrl + P</b> (Mac पर <b>⌘ + P</b>) दबाइए — पन्ना A4 पर
    ठीक बैठने के लिए बना हुआ है।
  </p>

  <div class="dhyan">
    <h4>तीन बातें पहले</h4>
    <p><b>१.</b> जहाँ दो चलन हैं, वो हमने ख़ुद लिख दिया है — “दूसरा चलन”
      वाली पंक्ति में। कृपया बताइए कि इस घर में कौन सा बोला जाए।</p>
    <p><b>२.</b> %d जगह मंत्र जान-बूझकर ख़ाली छोड़े गए हैं। वजह भाग ३ में
      लिखी है।</p>
    <p><b>३.</b> अगर कोई चरण इस घर की परंपरा में होता ही नहीं, तो उसे काट
      दीजिए — वो भी उतनी ही ज़रूरी जानकारी है।</p>
    <p><b>४.</b> भाग ५ में चालीसा और आरती हैं — उनका पाठ अभी बिल्कुल
      ख़ाली है; वहाँ सिर्फ़ यह बताना है कि किस पुस्तिका से लें।</p>
  </div>
''' % (kul_bhare, len(bhare), len(bhare), kul_bhare, kul_khaali))

# ── भाग १ — हर अलग पाठ ──
w('  <section class="bhaag">')
w('    <h2>भाग १ — %d अलग मंत्र-पाठ</h2>' % len(bhare))
w('''    <p class="bhoomika">
      हर डिब्बे के नीचे लिखा है कि यह पाठ <b>किन-किन पूजाओं में</b> चलता
      है। ऊपर वाले पाठ सबसे ज़्यादा जगह इस्तेमाल होते हैं — उन पर निशान
      लगते ही सबसे ज़्यादा फ़र्क़ पड़ेगा। जहाँ दर्जा <b>मध्यम</b> या
      <b>कम</b> है, वहाँ ख़ास ध्यान दीजिए।
    </p>''')

for i, (paath, info) in enumerate(bhare.items(), 1):
    m = info["m"]
    uses = info["uses"]
    dn, dc = BHAROSA_NAAM.get(m.get("bharosa", "kam"), ("भरोसा कम", "kam"))
    w('    <article class="khand">')
    w('      <header>')
    w('        <span class="ank">%d</span>' % i)
    w('        <h3>%s</h3>' % e(uses[0][1]))
    w('        <span class="darja %s">%s</span>' % (dc, dn))
    w('      </header>')
    w('      <div class="andar">')
    w('        <p class="paath">%s</p>' % e(paath))
    if m.get("roman", "").strip():
        w('        <p class="roman">%s</p>' % e(m["roman"]))
    if m.get("arth", "").strip():
        w('        <p class="arth">%s</p>' % e(m["arth"]))
    if m.get("vikalp", "").strip():
        w('        <p class="vikalp"><span class="chhota-lebal">दूसरा चलन</span>%s</p>'
          % e(m["vikalp"]))
    if m.get("strot", "").strip():
        w('        <p class="strot"><span class="chhota-lebal">स्रोत</span>%s</p>'
          % e(m["strot"]))
    # कहाँ-कहाँ चलता है
    jagah = ", ".join("%s (%s)" % (e(p), e(c)) for p, c in uses)
    w('        <p class="strot"><span class="chhota-lebal">%d जगह चलता है</span>%s</p>'
      % (len(uses), jagah))
    w('''        <div class="likho">
          <div class="tick-line"><span class="dabba"></span> पाठ सही है, ऐसे ही रहने दें</div>
          <div class="tick-line"><span class="dabba"></span> सुधार चाहिए — नीचे लिखा है</div>
          <div class="lakeer"></div><div class="lakeer"></div><div class="lakeer"></div>
        </div>''')
    w('      </div>')
    w('    </article>')
w('  </section>')

# ── भाग २ — संकल्प ──
w('''  <section class="bhaag">
    <h2>भाग २ — संकल्प की संस्कृत, टुकड़े-टुकड़े</h2>
    <p class="bhoomika">
      ऐप पंचांग से आज का पूरा संकल्प ख़ुद बना देता है — संवत्सर, अयन, ऋतु,
      मास, पक्ष, तिथि, वार, नक्षत्र सब भरकर। <b>मानों की जाँच हो चुकी है</b>
      (दृक् पंचांग से बारह तारीख़ें, पाँच शहर)। यहाँ सिर्फ़ <b>संस्कृत के
      रूप</b> देखने हैं।
    </p>

    <div class="dhyan">
      <h4>तीन जगह हमें ख़ुद शक है</h4>
      <p><b>तिथि —</b> ऐप “नवमी तिथौ” बनाता है। क्या “नवम्यां तिथौ” होना चाहिए? अगर हाँ, तो तीसों तिथियों के सही रूप चाहिए।</p>
      <p><b>गोत्र —</b> ऐप हमेशा “गोत्रोत्पन्नः” बनाता है, जो पुल्लिंग है। महिला यजमान के लिए “गोत्रोत्पन्ना” चाहिए — और शायद कुछ और शब्द भी बदलते हैं।</p>
      <p><b>नाम —</b> ऐप “…गोत्रोत्पन्नः चन्दन सिंह अहं” बनाता है। बीच में “नाम” जोड़ना चाहिए (“…नामाहं”)?</p>
    </div>

    <div class="tal-wrap">
      <table>
        <thead><tr><th>#</th><th>ऐप क्या बनाता है</th><th>व्याकरण</th><th>सही / सुधार</th></tr></thead>
        <tbody>
          <tr><td class="n">१</td><td class="roop">जम्बूद्वीपे भरतखण्डे भारतवर्षे</td><td class="byakaran">तीनों सप्तमी एकवचन</td><td class="likhne"></td></tr>
          <tr><td class="n">२</td><td class="roop">आर्यावर्तान्तर्गते</td><td class="byakaran">आर्यावर्त + अन्तर्गत, सप्तमी</td><td class="likhne"></td></tr>
          <tr><td class="n">३</td><td class="roop">वाराणसी क्षेत्रे</td><td class="byakaran">क्षेत्रे सप्तमी है, पर शहर का नाम हिंदी रूप में रहता है। समास मानें तो चलेगा?</td><td class="likhne"></td></tr>
          <tr><td class="n">४</td><td class="roop">सिद्धार्थी नाम संवत्सरे</td><td class="byakaran">संवत्सरे सप्तमी; “नाम” अव्यय</td><td class="likhne"></td></tr>
          <tr><td class="n">५</td><td class="roop">दक्षिणायने</td><td class="byakaran">सप्तमी एकवचन (उत्तरायणे भी)</td><td class="likhne"></td></tr>
          <tr><td class="n">६</td><td class="roop">वर्षा ऋतौ</td><td class="byakaran">ऋतौ सप्तमी। सन्धि से “वर्षर्तौ” बनता है — अलग लिखें या जोड़ें?</td><td class="likhne"></td></tr>
          <tr><td class="n">७</td><td class="roop">श्रावण मासे</td><td class="byakaran">मासे सप्तमी</td><td class="likhne"></td></tr>
          <tr><td class="n">७ब</td><td class="roop">अधिक ज्येष्ठ मासे</td><td class="byakaran">अधिक मास में “पुरुषोत्तम मासे” कहना चाहिए?</td><td class="likhne"></td></tr>
          <tr><td class="n">८</td><td class="roop">शुक्ल पक्षे</td><td class="byakaran">पक्षे सप्तमी (कृष्ण पक्षे भी)</td><td class="likhne"></td></tr>
          <tr class="shak"><td class="n">९</td><td class="roop">नवमी तिथौ</td><td class="byakaran">🔴 “नवम्यां तिथौ” चाहिए? तीसों तिथियों के रूप लिखवाने हैं</td><td class="likhne"></td></tr>
          <tr><td class="n">१०</td><td class="roop">शुक्रवासरे</td><td class="byakaran">वासरे सप्तमी</td><td class="likhne"></td></tr>
          <tr><td class="n">११</td><td class="roop">अनुराधा नक्षत्रे</td><td class="byakaran">नक्षत्रे सप्तमी; नाम समास में</td><td class="likhne"></td></tr>
          <tr class="shak"><td class="n">१२</td><td class="roop">कश्यप गोत्रोत्पन्नः</td><td class="byakaran">🔴 महिला के लिए “गोत्रोत्पन्ना” — और क्या बदलेगा?</td><td class="likhne"></td></tr>
          <tr class="shak"><td class="n">१३</td><td class="roop">चन्दन सिंह अहं</td><td class="byakaran">🔴 बीच में “नाम” जोड़ें? (…नामाहं)</td><td class="likhne"></td></tr>
          <tr><td class="n">१४</td><td class="roop">श्री सत्यनारायण पूजनं करिष्ये</td><td class="byakaran">करिष्ये — लृट् लकार, आत्मनेपद, उत्तम पुरुष</td><td class="likhne"></td></tr>
        </tbody>
      </table>
    </div>

    <p class="bhoomika" style="margin-top:20px"><b>शुरुआत का हिस्सा</b> — यह हर बार एक जैसा रहता है, बदलता नहीं।</p>
    <div class="tal-wrap">
      <table>
        <thead><tr><th>#</th><th>पाठ</th><th>सही / सुधार</th></tr></thead>
        <tbody>
          <tr><td class="n">क</td><td class="roop">ॐ विष्णुर्विष्णुर्विष्णुः।</td><td class="likhne"></td></tr>
          <tr><td class="n">ख</td><td class="roop">श्रीमद्भगवतो महापुरुषस्य विष्णोराज्ञया प्रवर्तमानस्य</td><td class="likhne"></td></tr>
          <tr><td class="n">ग</td><td class="roop">अद्य ब्रह्मणो द्वितीये परार्धे श्वेतवाराहकल्पे</td><td class="likhne"></td></tr>
          <tr><td class="n">घ</td><td class="roop">वैवस्वतमन्वन्तरे अष्टाविंशतितमे कलियुगे कलिप्रथमचरणे</td><td class="likhne"></td></tr>
          <tr><td class="n">ङ</td><td class="roop">मम आत्मनः श्रुतिस्मृतिपुराणोक्तफलप्राप्त्यर्थं</td><td class="likhne"></td></tr>
        </tbody>
      </table>
    </div>
  </section>
''')

# ── भाग ३ — ख़ाली मंत्र ──
w('  <section class="bhaag">')
w('    <h2>भाग ३ — %d जगह मंत्र ख़ाली हैं</h2>' % kul_khaali)
w('''    <p class="bhoomika">
      ये जान-बूझकर ख़ाली हैं — अंदाज़े से मंत्र लिखना इस ऐप में मना है।
      हर वजह के आगे लिखा है कि वो किन पूजाओं पर लागू है। जो आप लिखवा
      सकें, नीचे की लकीर पर लिख दीजिए; बाक़ी ख़ाली ही रहने दीजिए।
    </p>''')
for i, (vajah, uses) in enumerate(khaali_sorted, 1):
    w('    <article class="khand">')
    w('      <header><span class="ank">%d</span><h3>%s</h3>'
      '<span class="darja kam">%d जगह</span></header>' % (i, e(uses[0][1]), len(uses)))
    w('      <div class="andar">')
    w('        <p class="khaali-hai">— अभी कोई मंत्र नहीं लिखा गया —</p>')
    w('        <p class="arth">%s</p>' % e(vajah))
    jagah = ", ".join("%s (%s)" % (e(p), e(c)) for p, c in uses)
    w('        <p class="strot"><span class="chhota-lebal">कहाँ-कहाँ</span>%s</p>' % jagah)
    w('''        <div class="likho">
          <div class="tick-line"><span class="dabba"></span> यह चरण इस पद्धति में होता ही नहीं — हटा दें</div>
          <div class="tick-line"><span class="dabba"></span> होता है — मंत्र नीचे लिखा है</div>
          <div class="lakeer"></div><div class="lakeer"></div><div class="lakeer"></div>
        </div>''')
    w('      </div>')
    w('    </article>')
w('  </section>')

# ── भाग ४ — सारी पूजाएँ ──
w('  <section class="bhaag">')
w('    <h2>भाग ४ — %d पूजाएँ, कदम और सामग्री</h2>' % len(pujas))
w('''    <p class="bhoomika">
      हर पूजा का <b>दायरा</b> भी लिखा है — यानी ऐप उसे कहाँ तक अपने आप
      करने लायक दिखाता है। “सिर्फ़ तैयारी” और “पंडित जी के साथ” वाली
      पूजाओं की पूरी विधि ऐप में खुलती ही नहीं। <b>क्या यह बँटवारा ठीक है?</b>
    </p>''')
w('    <div class="tal-wrap"><table>')
w('      <thead><tr><th>पूजा</th><th>दायरा</th><th>कदम</th><th>समय</th>'
  '<th>सामग्री</th><th>मंत्र</th><th>ठीक / सुधार</th></tr></thead><tbody>')
for d in pujas:
    ms = [c.get("mantra") for c in d["charan"] if c.get("mantra")]
    mb = [x for x in ms if x.get("devanagari", "").strip()]
    shak = ' class="shak"' if d.get("scope") in ("preparation_only", "expert_assisted") else ""
    w('        <tr%s><td>%s</td><td class="byakaran">%s</td>'
      '<td class="byakaran">%d</td><td class="byakaran">%d मि</td>'
      '<td class="byakaran">%d</td><td class="byakaran">%d/%d</td>'
      '<td class="likhne"></td></tr>'
      % (shak, e(d["naam"]), SCOPE_NAAM.get(d.get("scope"), "—"),
         len(d["charan"]), d.get("samayMinute", 0), len(d["samagri"]),
         len(mb), len(ms)))
w('      </tbody></table></div>')
w('''    <div class="likho" style="margin-top:20px">
      <span class="chhota-lebal">कोई पूजा छूट गई हो, या कोई दायरा ग़लत लगे तो यहाँ लिखिए</span>
      <div class="lakeer"></div><div class="lakeer"></div><div class="lakeer"></div>
    </div>''')
w('  </section>')

# ── भाग ५ — चालीसा और आरती ──
paath_pad_kul = sum(len(d["khand"]) for d in paaths)
paath_pad_bhare = sum(1 for d in paaths for k in d["khand"]
                      if k.get("dev", "").strip())

w('  <section class="bhaag">')
w('    <h2>भाग ५ — चालीसा और आरती</h2>')
w('''    <p class="bhoomika">
      ये पूजा नहीं हैं — बैठकर या खड़े होकर पढ़ी जाने वाली रचनाएँ हैं,
      इसलिए ऐप में अलग जगह पर रखी गई हैं। <b>इनका पाठ जान-बूझकर नहीं लिखा
      गया</b> — चालीसा और आरती गाई जाती हैं और घर-घर में शब्द थोड़े बदलते
      हैं, इसलिए वही रूप जाएगा जो इस घर में पढ़ा जाता है।
    </p>''')
w('''    <div class="dhyan">
      <h4>यहाँ आपसे क्या चाहिए</h4>
      <p><b>१.</b> हर पाठ के आगे बताइए कि इस घर में कौन सा रूप पढ़ा जाता है
        — किस पुस्तिका से, या आप बोलकर लिखवा दीजिए।</p>
      <p><b>२.</b> जो पाठ इस सूची में होना ही नहीं चाहिए, उसे काट दीजिए।</p>
      <p><b>३.</b> कोई ज़रूरी चालीसा या आरती छूट गई हो तो नीचे लिख दीजिए।</p>
    </div>''')
w('    <div class="tal-wrap"><table>')
w('      <thead><tr><th>पाठ</th><th>प्रकार</th><th>देवता</th><th>रचयिता</th>'
  '<th>पद</th><th>किस पुस्तिका से लें / सुधार</th></tr></thead><tbody>')
for d in paaths:
    _bhare = sum(1 for k in d["khand"] if k.get("dev", "").strip())
    w('        <tr><td>%s</td><td class="byakaran">%s</td>'
      '<td class="byakaran">%s</td><td class="byakaran">%s</td>'
      '<td class="byakaran">%d/%d</td><td class="likhne"></td></tr>'
      % (e(d["naam"]), PAATH_PRAKAR.get(d.get("prakar"), "—"),
         e(d.get("devta", "")), e(d.get("rachnakar", "")),
         _bhare, len(d["khand"])))
w('      </tbody></table></div>')
w('''    <div class="likho" style="margin-top:20px">
      <span class="chhota-lebal">कोई चालीसा या आरती छूट गई हो तो यहाँ लिखिए</span>
      <div class="lakeer"></div><div class="lakeer"></div><div class="lakeer"></div>
    </div>''')
w('  </section>')

# ── अंत ──
w('''  <footer class="antim">
    <h2>जाँच के बाद</h2>
    <ol>
      <li>जो सही निकला वो ऐप में “पास” होगा, और उसकी चेतावनी हट जाएगी।</li>
      <li>जो सुधरा वो सुधारकर डाला जाएगा — और फिर दोबारा दिखाया जाएगा।</li>
      <li>ऐप में आपका नाम और यह तारीख़ दिखेगी, ताकि लोग जान सकें कि विधि किसने जाँची।</li>
      <li>मंत्रों की रिकॉर्डिंग आपकी अपनी आवाज़ में होगी — कहीं से उठाई हुई नहीं।</li>
    </ol>

    <div class="dhyan">
      <h4>आधा-अधूरा पास मत करवाइए</h4>
      <p>अगर कुछ भी अटका रह जाए — एक मंत्र, एक रूप — तो उसे ख़ाली छोड़ दीजिए।
        ऐप उस जगह साफ़ लिख देगा कि यह अभी नहीं आया है। <b>अधूरी चीज़ आधी
        बनाकर दिखाने से अच्छा है न दिखाना।</b></p>
    </div>

    <div class="dastkhat">
      <div><div class="lakeer"></div><span>पंडित जी के हस्ताक्षर</span></div>
      <div><div class="lakeer"></div><span>तारीख़</span></div>
      <div><div class="lakeer"></div><span>पद्धति / परंपरा</span></div>
    </div>
  </footer>
''')
w('</div>')

io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(P) + "\n")
print("बनी: %d पूजाएँ · %d अलग मंत्र-पाठ (%d जगह) · %d ख़ाली मंत्र · "
      "%d चालीसा-आरती (%d/%d पद) · %d अक्षर"
      % (len(pujas), len(bhare), kul_bhare, kul_khaali,
         len(paaths), paath_pad_bhare, paath_pad_kul,
         sum(len(x) for x in P)))
