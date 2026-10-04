# -*- coding: utf-8 -*-
"""सुधार लगने के बाद का पाठ (mool_<नाम>.json) गवाहों से फिर मिलाना — जो बचा, वही docs/18 में दर्ज।

    python up3_jaanch.py katha [sab|vivad]
"""
import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')
import up_saadhan as U  # noqa: E402
from up1_milao import gretil_mool, ns_hissa, wb_mool  # noqa: E402
import up2_milao  # noqa: E402


def aadhar(nm):
    return [('%s %d.%s' % (nm, m['sec'], m['num']), ' '.join(m['lines']))
            for m in json.loads(U.rd('mool_%s.json' % nm))]


def gawah(nm):
    if nm == 'isha':
        g = gretil_mool('g_sa_IzopaniSad-or-IzAvAsyopaniSadkANva-recension-comm.txt', r'\|\|\s*isup_\d+\s*\|\|')
        ns = ns_hissa('==ईशावास्योपनिषत् ==', '== केनोपनिषत् ==')
        return {'G': U.ki(' '.join(g)), 'NS': U.kd(ns[ns.index('ॐईशा'):])}
    if nm == 'kena':
        ns = ns_hissa('== केनोपनिषत् ==', '== कठोपनिषत् ==')
        wb = wb_mool('wb_kena.txt')
        return {'NS': U.kd(ns[ns.index('ॐ केनेषितं'):]), 'WB': U.kd(' '.join(wb))}
    if nm == 'mandukya':
        t = U.rd('g_sa_mANDUkyopaniSad-alt.txt')
        t = t[t.index('# Text'):]
        tuk = re.split(r'(māṇḍūkya upaniṣad|māṇḍūkya kārikā)', t)
        g = [re.sub(r'verse\s*\d+', ' ', tuk[i + 1]) for i in range(1, len(tuk) - 1, 2)
             if tuk[i] == 'māṇḍūkya upaniṣad']
        gc = gretil_mool('g_sa_mANDUkyopaniSad-comm.txt', r'\|\|\s*mandup_\d+\s*\|\|')
        return {'Ga': U.ki(' '.join(g)), 'Gc': U.ki(' '.join(gc))}
    return up2_milao.gawah(nm)


if __name__ == '__main__':
    dikhao = 'vivad'
    naam = [x for x in sys.argv[1:] if x not in ('sab', 'vivad')]
    if 'sab' in sys.argv[1:]:
        dikhao = 'sab'
    for nm in naam:
        print('════', nm)
        U.milao(aadhar(nm), gawah(nm), dikhao, kam=1 if nm == 'shveta' else 2)
