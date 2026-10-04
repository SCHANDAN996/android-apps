# -*- coding: utf-8 -*-
"""कठ, प्रश्न, मुण्डक, तैत्तिरीय, ऐतरेय, श्वेताश्वतर — S (आधार) को बाक़ी गवाहों से मिलाना।

    python up2_milao.py katha [sab|vivad]
"""
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402
from up1_milao import aadhar, ns_hissa, wb_mool  # noqa: E402


def g_text(fn):
    t = U.rd(fn)
    return t[t.index('# Text'):]


def g_para(fn, pat):
    """GRETIL: जिन अनुच्छेदों में `pat` (मंत्र का अंक-चिह्न) है, वही — चिह्न हटाकर।"""
    out = []
    for para in re.split(r'\n\s*\n', g_text(fn)):
        if re.search(pat, para):
            p = re.sub(pat, ' ', para)
            p = re.sub(r'(?m)^\s*start \w+ [\d.,]+\s*$', ' ', p)
            out.append(p)
    return out


def gawah(nm):
    if nm == 'katha':
        g = g_para('g_sa_kathopaniSad.txt', r'//\s*kau_[\d.]+\s*//')
        ns = ns_hissa('== कठोपनिषत् ==', '== प्रश्नोपनिषत् ==')
        return {'G': U.ki(' '.join(g)), 'NS': U.kd(ns)}
    if nm == 'prashna':
        # विकिस्रोत का भाष्य-पन्ना (WB) यहाँ GRETIL वाला ही पाठ है — अलग गवाह नहीं
        g = g_para('g_sa_praznopaniSad-comm.txt', r'(\|\||//)\s*prup_[\d.]+\s*(\|\||//)')
        ns = ns_hissa('== प्रश्नोपनिषत् ==', '== मुण्डकोपनिषत् ==')
        print('G', len(g))
        return {'G': U.ki(' '.join(g)), 'NS': U.kd(ns)}
    if nm == 'mundaka':
        ns = ns_hissa('== मुण्डकोपनिषत् ==', '==devi upanishad ?==')
        wb = wb_mool('wb_mundaka.txt')
        print('WB', len(wb))
        return {'NS': U.kd(ns), 'WB': U.kd(' '.join(wb))}
    if nm == 'aitareya':
        g = g_para('g_sa_aitareyopaniSad-comm.txt', r'(\|\||//)\s*aitup_[\d.,]+\s*(\|\||//)')
        ns = ns_hissa('== ऐतरेयोपनिषत् ==', '== छान्दोग्योपनिषत् ==')
        print('G', len(g))
        return {'G': U.ki(' '.join(g)), 'NS': U.kd(ns)}
    if nm == 'tait':
        g = g_para('g_sa_taittirIyopaniSad-zaMkarabhASya.txt', r'\(TaittU_[\d.,]+\)')
        g = [re.sub(r"iti [^/]*?'?nuvākaḥ\s*//", ' ', x) for x in g]
        ns = ns_hissa('==तैत्तिरीयोपनिषत्==', '== ऐतरेयोपनिषत् ==')
        print('G', len(g))
        return {'G': U.ki(' '.join(g)), 'NS': U.kd(ns)}
    if nm == 'shveta':
        ga = g_para('g_sa_zvetAzvataropaniSad-alt.txt', r'//\s*SvetUp_[\d.]+')
        # विकिस्रोत के छह पन्ने (अध्याय-क्रम में: 5, 3, 2, 1, 4, 6) — S की नक़ल नहीं हैं
        w = []
        for i in (5, 3, 2, 1, 4, 6):
            t = U.rd('ws_shveta_%d.txt' % i)
            t = re.sub(r'</?poem>|\{\{[^}]*\}\}|\[\[[^\]]*\]\]', ' ', t)
            t = re.sub(r'(?m)^\s*[|॥]+\s*\S+ऽध्यायः\s*[|॥]+\s*$', ' ', t)
            t = re.sub(r'(?m)^.*(सहनाववतु|शान्तिः शान्तिः|इति .*ध्यायः).*$', ' ', t)
            w.append(t)
        print('Ga', len(ga))
        return {'Ga': U.ki(' '.join(ga)), 'W': U.kd(' '.join(w))}
    raise SystemExit('?')


if __name__ == '__main__':
    nm = sys.argv[1]
    dikhao = sys.argv[2] if len(sys.argv) > 2 else 'vivad'
    a = aadhar(nm)
    U.milao(a, gawah(nm), dikhao)
