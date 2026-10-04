# -*- coding: utf-8 -*-
"""तैत्तिरीय उपनिषद — S से अनुवाक-दर-अनुवाक मूल; G, NS और छपी टीका के OCR से मिलान।

तैत्तिरीय बाक़ी उपनिषदों से अलग है: मंत्रों में नहीं, **अनुवाकों** में बँटा है; S हर
अनुवाक के भीतर दस-दस वाक्यों पर «॥ १॥ ॥ २॥» लगाता है (पाठ की पुरानी गिनती) — वे
अर्थ की इकाई नहीं हैं, इसलिए यहाँ हटते हैं और अनुवाक ही खंड बनता है।

    python up_tait.py            mool_tait.json लिखता है और छापता है
    python up_tait.py milao      G, NS से मिलान
"""
import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402
import up_mool  # noqa: E402

ANUVAK_ANT = re.compile(r'इत(ि|्य)\s*\S*नुवाकः\s*॥')
VALLI = re.compile(r'(शीक्षावल्ली|ब्रह्मानन्दवल्ली|भृगुवल्ली)\s*$')
SHANTI = re.compile(r'^\s*(ॐ सह नाववतु|तेजस्वि\s?नावधीतमस्तु|॥?\s*ॐ शान्तिः शान्तिः शान्तिः\s*॥\s*$)')

# हर सुधार पर G (शांकर भाष्य वाला छपा संस्करण) और छपी टीका — docs/18 §२५
SUDHAR = [
    ('1.3', 'उपनिषदम् व्याख्यास्यामः', 'उपनिषदं व्याख्यास्यामः'),
    ('1.3', 'अधराहनुः पूर्वरूपम् । उत्तराहनूत्तररूपम्', 'अधरा हनुः पूर्वरूपम् । उत्तरा हनुरुत्तररूपम्'),
    ('1.3', 'व्याख्याता वे`द', 'व्याख्याता वेद'),
    ('1.5', 'सर्वेलोक महीयन्ते', 'सर्वे लोका महीयन्ते'),
    ('1.5', 'सर्वेवेदा महीयन्ते', 'सर्वे वेदा महीयन्ते'),
    ('1.5', 'सर्वे प्राण महीयन्ते', 'सर्वे प्राणा महीयन्ते'),
    ('1.5', 'सर्वेऽस्मैदेवा', 'सर्वेऽस्मै देवा'),
    ('1.6', 'एषोऽन्तहृदय', 'एषोऽन्तर्हृदय'),
    ('1.6', 'प्राचीन योग्योपास्व', 'प्राचीनयोग्योपास्स्व'),
    ('1.7', 'चर्ममांस स्नावास्थि', 'चर्म मांसं स्नावास्थि'),
    ('1.7', 'पाङ्क्तग् स्पृणोतीति', 'पाङ्क्तं स्पृणोतीति'),
    ('1.8', 'ॐंशोमिति', 'ओं शोमिति'),
    ('1.9', 'राथी तरः', 'राथीतरः'),
    ('1.10', 'सुमेध अमृतोक्षितः', 'सुमेधा अमृतोक्षितः'),
    ('1.11', 'वेदमनूच्याचार्योन्तेवासिनमनुशास्ति', 'वेदमनूच्याचार्योऽन्तेवासिनमनुशास्ति'),
    ('2.1', 'ओषधीभ्योन्नम्', 'ओषधीभ्योऽन्नम्'),
    ('2.6', 'कश्चन गच्छती३ 3 for prolonging the vowel in the form । अऽऽ ।', 'कश्चन गच्छती३ ।'),
    ('2.7', 'तदात्मान स्वयमकुरुत', 'तदात्मानं स्वयमकुरुत'),
    ('2.8', 'पितृणां', 'पितॄणां', 2),
    ('2.8', 'शतं आजानजानां', 'शतमाजानजानां'),
    ('2.9', 'आत्मान स्पृणुते', 'आत्मानं स्पृणुते', 2),
    ('3.2', 'भुतानि', 'भूतानि'),
    ('3.6', 'आनन्दाध्येव', 'आनन्दाद्ध्येव'),
    ('3.10', 'सदाचारप्रदर्शनम् । ब्रह्मानन्दानुभवः ', ''),
    ('3.10', 'एदद्वा', 'एतद्वा'),
    ('3.10', 'अन्न राध्यते', 'अन्नं राध्यते'),
    ('3.10', 'इमाँल्लोकन्कामान्नी', 'इमाँल्लोकान्कामान्नी'),
    ('3.10', 'हा ३ वु हा ३ वु हा ३ वु', 'हा३वु हा३वु हा३वु'),
    ('3.10', 'अहमन्नादोऽ३हमन्नादोऽ३अहमन्नादः', 'अहमन्नादो३ऽहमन्नादो३ऽहमन्नादः'),
    ('3.10', 'ना३भाइ', 'ना३भायि'),
    ('3.10', 'मा३अऽवाः', 'मा३वाः'),
]

# S जहाँ वैदिक अनुस्वार के बाद अगला शब्द सटाकर लिखता है («इदꣳसर्वम्») — शब्द अलग
SATE = [
    ('इतीमामहासंहिताः', 'इतीमा महासंहिताः'),
    ('इदंसर्वम', 'इदं सर्वम'),
    ('प्रवचनंसन्धानम्', 'प्रवचनं सन्धानम्'),
    ('प्रजननंसन्धानम्', 'प्रजननं सन्धानम्'),
    ('द्रविणंसवर्चसम्', 'द्रविणं सवर्चसम्'),
    ('यान्यस्माकंसुचरितानि', 'यान्यस्माकं सुचरितानि'),
    ('पृथिवींश्रिताः', 'पृथिवीं श्रिताः'),
    ('अन्नंहि', 'अन्नं हि'),
    ('रसंह्येवायं', 'रसं ह्येवायं'),
    ('एतंह वाव', 'एतं ह वाव'),
    ('किमहंसाधु', 'किमहं साधु'),
    ('तंहोवाच', 'तं होवाच'),
    ('ऽन्नंराद्धम्', 'ऽन्नं राद्धम्'),
    ('अन्नंराध्यते', 'अन्नं राध्यते'),
    ('अहंश्लोककृदहंश्लोककृदहंश्लोककृत्', 'अहं श्लोककृदहं श्लोककृदहं श्लोककृत्'),
]

LAMBAI = 24      # फ़ोन की एक पंक्ति में लगभग इतने अक्षर आते हैं — इतने तक के छोटे वाक्य साथ


def anuvak_kacche():
    """[(वल्ली, अनुवाक, पूरा पाठ एक डोरी में)]"""
    out, buf, valli, n = [], [], 0, 0
    for line in U.rd('s_tait.txt').split('\n'):
        s = line.strip()
        if not s or re.match(r'^(Encoded|Proofread)', s):
            continue
        if VALLI.search(s) and '।' not in s:
            valli += 1
            n = 0
            buf = []
            continue
        if valli == 0:
            continue
        if s.startswith('॥ इति') or s == '॥ हरिः ॐ ॥':
            continue
        # वल्ली २ और ३ के आगे-पीछे का शांति पाठ (अलग खंड में जाता है)
        if valli >= 2 and SHANTI.match(s):
            continue
        if valli == 1 and n == 12:
            continue                                   # पहली वल्ली के बाद का सब (शांति) छोड़ो
        # संपादक के शीर्षक — हाशिये से हटे हुए, बिना विराम
        if re.match(r'^\s{2,}', line) and '।' not in s and '॥' not in s:
            continue
        ant = ANUVAK_ANT.search(s)
        if ant:
            s = s[:ant.start()].strip()
        if s:
            buf.append(s)
        if ant:
            n += 1
            t = ' '.join(buf)
            t = re.sub(r'॥\s*[०-९]+\s*॥', '।', t)       # दस-दस वाक्यों की गिनती
            t = re.sub(r'\s*।\s*।', ' ।', t)
            t = re.sub(r'।\s*$', '॥', t.strip())
            out.append((valli, n, t))
            buf = []
    return out


def panktiyan(t):
    """वाक्यों को «।» पर तोड़कर LAMBAI तक के टुकड़ों में पंक्तियाँ।"""
    vakya = [x.strip() for x in re.split(r'(?<=[।॥])\s+', t) if x.strip()]
    lines, cur = [], ''
    for v in vakya:
        if cur and len(cur) + 1 + len(v) > LAMBAI:
            lines.append(cur)
            cur = v
        else:
            cur = (cur + ' ' + v).strip()
    if cur:
        lines.append(cur)
    return [up_mool.likhawat(x) for x in lines]


def mool():
    out = []
    for valli, n, t in anuvak_kacche():
        t = up_mool.likhawat(t.replace('ꣳ', 'ं'))
        out.append({'sec': valli, 'num': str(n), 'text': t})
    for m in out:
        for a, b in SATE:
            m['text'] = m['text'].replace(a, b)
    for sudhar in SUDHAR:
        lab, a, b = sudhar[:3]
        kitne = sudhar[3] if len(sudhar) > 3 else 1
        mila = 0
        for m in out:
            if '%d.%s' % (m['sec'], m['num']) == lab:
                mila += m['text'].count(a)
                m['text'] = up_mool.likhawat(m['text'].replace(a, b))
        if mila != kitne:
            raise SystemExit('सुधार नहीं लगा: tait %s %r (%d)' % (lab, a, mila))
    for m in out:
        m['lines'] = panktiyan(m['text'])
        if re.search(r'[A-Za-z0-9]', m['text']):
            raise SystemExit('अंग्रेज़ी अक्षर/अंक बचे: tait %d.%s' % (m['sec'], m['num']))
    return out


def g_anuvak():
    """GRETIL (शांकर भाष्य सहित): हर `(TaittU_v,a.n)` चिह्न वाला अनुच्छेद मूल है।"""
    t = U.rd('g_sa_taittirIyopaniSad-zaMkarabhASya.txt')
    t = t[t.index('# Text'):]
    out = {}
    for para in re.split(r'\n\s*\n', t):
        m = re.search(r'\(TaittU_(\d+),(\d+)\.(\d+)\)', para)
        if not m:
            continue
        key = (int(m.group(1)), int(m.group(2)))
        p = re.sub(r'\(TaittU_[\d,.]+\)', ' ', para)
        p = re.sub(r"iti [^/]*?nuvākaḥ\s*//", ' ', p)
        out.setdefault(key, []).append(p)
    return {k: ' '.join(v) for k, v in out.items()}


if __name__ == '__main__':
    m = mool()
    if len(sys.argv) > 1 and sys.argv[1] == 'milao':
        from up1_milao import ns_hissa
        g = g_anuvak()
        ns = U.kd(ns_hissa('==तैत्तिरीयोपनिषत्==', '== ऐतरेयोपनिषत् =='))
        aadhar = [('tait %d.%s' % (x['sec'], x['num']), x['text']) for x in m]
        print('G में अनुवाक', len(g))
        gk = U.ki(' '.join(g[k] for k in sorted(g)))
        U.milao(aadhar, {'G': gk, 'NS': ns}, sys.argv[2] if len(sys.argv) > 2 else 'vivad')
    else:
        U.wr('mool_tait.json', json.dumps(m, ensure_ascii=False, indent=1))
        for x in m:
            print('# %d.%s' % (x['sec'], x['num']))
            for l in x['lines']:
                print('   ', l)
        from collections import Counter
        print(Counter(x['sec'] for x in m))
