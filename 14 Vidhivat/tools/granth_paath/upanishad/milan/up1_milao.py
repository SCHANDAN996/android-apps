# -*- coding: utf-8 -*-
"""ईश, केन, माण्डूक्य — S (आधार) को G, NS, WB, W से मिलाना।"""
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402


def ns_hissa(shuru, ant, fn='ws_ns_01_10.txt'):
    t = U.rd(fn)
    i = t.index(shuru)
    j = t.index(ant, i + len(shuru))
    seg = t[i + len(shuru):j]
    seg = re.sub(r'-----Page-+[०-९]+-*', ' ', seg)
    seg = re.sub(r'(?m)^\s*इति [^\n]*$', ' ', seg)
    return seg


def gretil_mool(fn, pat):
    """टीका वाली फ़ाइल से सिर्फ़ मूल — जिन अनुच्छेदों के अंत में `|| xxx_N ||` है।"""
    t = U.rd(fn)
    t = t[t.index('# Text'):]
    out = []
    for para in re.split(r'\n\s*\n', t):
        if re.search(pat, para):
            out.append(re.sub(pat, ' ', para))
    return out


def wb_mool(fn, pat=r'^\s*\d+\.\d+\.\d+\s*$'):
    """विकिस्रोत के भाष्य-पन्ने से मूल — `1.2.3` वाली पंक्ति के ठीक बाद की पंक्ति।"""
    lines = U.rd(fn).split('\n')
    out = []
    for i, l in enumerate(lines):
        if re.match(pat, l) and i + 1 < len(lines):
            out.append(re.sub(r'।।\s*[0-9]+\s*।।', ' ', lines[i + 1]))
    return out


def aadhar(nm):
    out = []
    for sec, num, lines in U.s_mantra('s_%s.txt' % nm):
        if num:
            out.append(('%s %d.%s' % (nm, sec, num), ' '.join(lines)))
    return out


if __name__ == '__main__':
    kaun = sys.argv[1] if len(sys.argv) > 1 else 'sab'
    dikhao = sys.argv[2] if len(sys.argv) > 2 else 'vivad'

    if kaun in ('isha', 'sab'):
        a = aadhar('isha')
        g = gretil_mool('g_sa_IzopaniSad-or-IzAvAsyopaniSadkANva-recension-comm.txt', r'\|\|\s*isup_\d+\s*\|\|')
        ns = ns_hissa('==ईशावास्योपनिषत् ==', '== केनोपनिषत् ==')
        ns = ns[ns.index('ॐईशा'):]
        U.milao(a, {'G': U.ki(' '.join(g)), 'NS': U.kd(ns)}, dikhao)

    if kaun in ('kena', 'sab'):
        a = aadhar('kena')
        ns = ns_hissa('== केनोपनिषत् ==', '== कठोपनिषत् ==')
        ns = ns[ns.index('ॐ केनेषितं'):]
        wb = wb_mool('wb_kena.txt')
        print('WB मूल-खंड', len(wb))
        U.milao(a, {'NS': U.kd(ns), 'WB': U.kd(' '.join(wb))}, dikhao)

    if kaun in ('mandukya', 'sab'):
        a = aadhar('mandukya')
        t = U.rd('g_sa_mANDUkyopaniSad-alt.txt')
        t = t[t.index('# Text'):]
        tuk = re.split(r'(māṇḍūkya upaniṣad|māṇḍūkya kārikā)', t)
        g = []
        for i in range(1, len(tuk) - 1, 2):
            if tuk[i] == 'māṇḍūkya upaniṣad':
                g.append(re.sub(r'verse\s*\d+', ' ', tuk[i + 1]))
        gc = gretil_mool('g_sa_mANDUkyopaniSad-comm.txt', r'\|\|\s*mandup_\d+\s*\|\|')
        print('G-alt टुकड़े', len(g), '· G-comm मूल-खंड', len(gc))
        U.milao(a, {'Ga': U.ki(' '.join(g)), 'Gc': U.ki(' '.join(gc))}, dikhao)
