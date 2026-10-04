# -*- coding: utf-8 -*-
"""मूल (mool_<नाम>.json — `up_mool.py` से) + अर्थ → `paath/<कुंजी>.txt`।

    python up_paath.py isha kena mandukya shanti

अर्थ `up_arth_*.py` में हैं। यह औज़ार एक बार चलता है; उसके बाद अर्थ सीधे
`tools/granth_paath/upanishad/paath/*.txt` में बदले जाते हैं।
"""
import io
import json
import os
import sys

import up_saadhan as U

sys.path.insert(0, os.path.join(U.REPO, 'tools'))
from lipi import dev_ank  # noqa: E402

DST = os.path.join(U.REPO, 'tools', 'granth_paath', 'upanishad', 'paath')

SHANTI_ANT = 'ॐ शान्तिः शान्तिः शान्तिः ॥'
TAAP = 'तीनों तरह के ताप शांत हों।'

# ── शांति मंत्र: पाठ और अर्थ (हर उपनिषद के आरंभ में, और अलग पन्ने पर भी) ──────
SHANTI = {
    'purnamadah': (
        ['ॐ पूर्णमदः पूर्णमिदं पूर्णात् पूर्णमुदच्यते ।',
         'पूर्णस्य पूर्णमादाय पूर्णमेवावशिष्यते ॥'],
        'वह (परब्रह्म) पूर्ण है और यह (जगत) भी पूर्ण है; उस पूर्ण से ही यह पूर्ण निकला है। पूर्ण में से पूर्ण निकाल लेने पर भी पूर्ण ही बचा रहता है।'),
    'apyayantu': (
        ['ॐ आप्यायन्तु ममाङ्गानि वाक्प्राणश्चक्षुः श्रोत्रमथो बलमिन्द्रियाणि च सर्वाणि ।',
         'सर्वं ब्रह्मौपनिषदं माऽहं ब्रह्म निराकुर्यां मा मा ब्रह्म निराकरोदनिराकरणमस्त्वनिराकरणं मेऽस्तु ।',
         'तदात्मनि निरते य उपनिषत्सु धर्मास्ते मयि सन्तु ते मयि सन्तु ॥'],
        'मेरे अंग पुष्ट हों — वाणी, प्राण, आँखें, कान, बल और सारी इंद्रियाँ। यह सब उपनिषदों में कहा हुआ ब्रह्म ही है। मैं ब्रह्म को कभी न नकारूँ और ब्रह्म मुझे कभी न त्यागे; हमारा नाता न टूटे, मेरा नाता न टूटे। आत्मा में लगे हुए मुझमें वे सब धर्म बसें जो उपनिषदों में कहे गए हैं — वे मुझमें बसें।'),
    'sahanavavatu': (
        ['ॐ सह नाववतु ।',
         'सह नौ भुनक्तु ।',
         'सह वीर्यं करवावहै ।',
         'तेजस्वि नावधीतमस्तु मा विद्विषावहै ॥'],
        'परमात्मा हम दोनों — गुरु और शिष्य — की साथ-साथ रक्षा करे; हम दोनों का साथ-साथ पालन करे। हम दोनों मिलकर पुरुषार्थ करें। हमारा पढ़ा हुआ तेजस्वी हो; हम एक-दूसरे से द्वेष न करें।'),
    'shamnomitrah': (
        ['ॐ शं नो मित्रः शं वरुणः ।',
         'शं नो भवत्वर्यमा ।',
         'शं न इन्द्रो बृहस्पतिः ।',
         'शं नो विष्णुरुरुक्रमः ।',
         'नमो ब्रह्मणे । नमस्ते वायो ।',
         'त्वमेव प्रत्यक्षं ब्रह्मासि ।',
         'त्वामेव प्रत्यक्षं ब्रह्म वदिष्यामि ।',
         'ऋतं वदिष्यामि । सत्यं वदिष्यामि ।',
         'तन्मामवतु । तद्वक्तारमवतु ।',
         'अवतु माम् । अवतु वक्तारम् ॥'],
        'मित्र हमारे लिए सुखकारी हों, वरुण सुखकारी हों; अर्यमा हमारे लिए सुखकारी हों; इंद्र और बृहस्पति सुखकारी हों; लंबे डग भरने वाले विष्णु हमारे लिए सुखकारी हों। ब्रह्म को नमस्कार। हे वायु, तुम्हें नमस्कार — तुम ही प्रत्यक्ष ब्रह्म हो; मैं तुम्हीं को प्रत्यक्ष ब्रह्म कहूँगा। मैं ऋत (ठीक बात) कहूँगा, मैं सत्य कहूँगा। वह मेरी रक्षा करे, वह बोलने वाले आचार्य की रक्षा करे; मेरी रक्षा करे, आचार्य की रक्षा करे।'),
    'bhadram': (
        ['ॐ भद्रं कर्णेभिः शृणुयाम देवा भद्रं पश्येमाक्षभिर्यजत्राः ।',
         'स्थिरैरङ्गैस्तुष्टुवांसस्तनूभिर्व्यशेम देवहितं यदायुः ॥',
         'स्वस्ति न इन्द्रो वृद्धश्रवाः स्वस्ति नः पूषा विश्ववेदाः ।',
         'स्वस्ति नस्तार्क्ष्यो अरिष्टनेमिः स्वस्ति नो बृहस्पतिर्दधातु ॥'],
        'हे देवताओ, हम कानों से शुभ ही सुनें; हे पूजनीय देवो, हम आँखों से शुभ ही देखें। मज़बूत अंगों और शरीर से तुम्हारी स्तुति करते हुए हम वह पूरी आयु पाएँ जो देवताओं ने हमारे लिए ठहराई है। बड़े यश वाले इंद्र हमारा कल्याण करें; सब कुछ जानने वाले पूषा हमारा कल्याण करें; जिनकी गति कोई रोक नहीं सकता वे तार्क्ष्य (गरुड़) हमारा कल्याण करें; बृहस्पति हमारा कल्याण करें।'),
    'vangme': (
        ['ॐ वाङ् मे मनसि प्रतिष्ठिता मनो मे वाचि प्रतिष्ठितमाविरावीर्म एधि ।',
         'वेदस्य म आणीस्थः श्रुतं मे मा प्रहासीरनेनाधीतेनाहोरात्रान् सन्दधाम्यृतं वदिष्यामि सत्यं वदिष्यामि ।',
         'तन्मामवतु तद्वक्तारमवत्ववतु मामवतु वक्तारमवतु वक्तारम् ॥'],
        'मेरी वाणी मन में टिकी रहे और मेरा मन वाणी में टिका रहे। हे अपने आप प्रकाशित परमात्मा, मेरे सामने प्रकट हो। हे वाणी और मन, तुम दोनों मेरे लिए वेद का ज्ञान लाने वाले बनो; मेरा सुना हुआ मुझे छोड़कर न जाए। इस पढ़े हुए के सहारे मैं दिन और रात को जोड़ दूँ — दिन-रात इसी में लगा रहूँ। मैं ऋत (ठीक बात) कहूँगा, मैं सत्य कहूँगा। वह ब्रह्म मेरी रक्षा करे, वह बोलने वाले आचार्य की रक्षा करे; मेरी रक्षा करे, आचार्य की रक्षा करे, आचार्य की रक्षा करे।'),
    'dyauh': (
        ['ॐ द्यौः शान्तिरन्तरिक्षं शान्तिः पृथिवी शान्तिरापः शान्तिरोषधयः शान्तिः ।',
         'वनस्पतयः शान्तिर्विश्वे देवाः शान्तिर्ब्रह्म शान्तिः सर्वं शान्तिः शान्तिरेव शान्तिः सा मा शान्तिरेधि ॥'],
        'द्युलोक में शांति हो, अंतरिक्ष में शांति हो, पृथ्वी पर शांति हो; जल में शांति हो, औषधियों में शांति हो। वनस्पतियों में शांति हो, सब देवताओं में शांति हो, ब्रह्म में शांति हो; सब कुछ शांत हो, शांति ही शांति हो — और वह शांति मुझे भी मिले।'),
    'asato': (
        ['ॐ असतो मा सद्गमय ।',
         'तमसो मा ज्योतिर्गमय ।',
         'मृत्योर्माऽमृतं गमय ॥'],
        'मुझे असत् से सत् की ओर ले चलो। मुझे अँधेरे से उजाले की ओर ले चलो। मुझे मृत्यु से अमरता की ओर ले चलो।'),
}

# अलग पन्ने पर क्रम और शीर्षक
SHANTI_KRAM = [
    ('purnamadah', 'ॐ पूर्णमदः'),
    ('sahanavavatu', 'ॐ सह नाववतु'),
    ('bhadram', 'ॐ भद्रं कर्णेभिः'),
    ('apyayantu', 'ॐ आप्यायन्तु'),
    ('shamnomitrah', 'ॐ शं नो मित्रः'),
    ('vangme', 'ॐ वाङ् मे मनसि'),
    ('dyauh', 'ॐ द्यौः शान्तिः'),
    ('asato', 'ॐ असतो मा सद्गमय'),
]

# कौन सा उपनिषद किस शांति पाठ से खुलता है
KISKA_SHANTI = {
    'isha': 'purnamadah', 'kena': 'apyayantu', 'katha': 'sahanavavatu',
    'prashna': 'bhadram', 'mundaka': 'bhadram', 'mandukya': 'bhadram',
    'tait': 'shamnomitrah', 'aitareya': 'vangme', 'shveta': 'sahanavavatu',
}


def khand(shirshak, mool, arth):
    assert arth.strip() and '\n' not in arth, shirshak
    return '# %s\n%s\n= %s\n' % (shirshak, '\n'.join(mool), arth.strip())


def shanti_khand(kunji, shirshak='शांति पाठ'):
    mool, arth = SHANTI[kunji]
    return khand(shirshak, mool + [SHANTI_ANT], arth + ' ' + TAAP)


def likho(key, khands):
    os.makedirs(DST, exist_ok=True)
    p = os.path.join(DST, key + '.txt')
    with io.open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(khands))
    print('लिखा', key, len(khands), 'खंड')


def mool(nm):
    return json.loads(U.rd('mool_%s.json' % nm))


def ek_paath(nm, key, arth, shirshak, chuno=None, shanti=True):
    """एक पाठ-फ़ाइल। `chuno(m)` — इस फ़ाइल में कौन से मंत्र; `shirshak(m)` — खंड का नाम।"""
    # shanti: False — नहीं · True — इस उपनिषद का अपना · डोरी — वही शांति मंत्र
    kaun = shanti if isinstance(shanti, str) else KISKA_SHANTI[nm]
    out = [shanti_khand(kaun)] if shanti else []
    n = 0
    for m in mool(nm):
        if chuno and not chuno(m):
            continue
        lab = '%d.%s' % (m['sec'], m['num'])
        if lab not in arth:
            raise SystemExit('%s %s का अर्थ नहीं' % (nm, lab))
        out.append(khand(shirshak(m), m['lines'], arth[lab]))
        n += 1
    likho(key, out)
    return n


def main(kaun):
    if 'isha' in kaun:
        from up_arth_1 import ISHA
        ek_paath('isha', 'isha', ISHA, lambda m: 'मंत्र ' + dev_ank(int(m['num'])))
    if 'kena' in kaun:
        from up_arth_1 import KENA
        ek_paath('kena', 'kena', KENA,
                 lambda m: 'मंत्र %s.%s' % (dev_ank(m['sec']), dev_ank(int(m['num']))))
    if 'mandukya' in kaun:
        from up_arth_1 import MANDUKYA
        ek_paath('mandukya', 'mandukya', MANDUKYA, lambda m: 'मंत्र ' + dev_ank(int(m['num'])))
    def kai(nm, arth, kunji):
        """कई पाठों वाला उपनिषद — `kunji[खंड-क्रम]` = फ़ाइल की कुंजी; शांति पाठ सिर्फ़ पहले में।"""
        for sec, key in sorted(kunji.items()):
            ek_paath(nm, key, arth, lambda m: 'मंत्र ' + dev_ank(int(m['num'])),
                     chuno=lambda m, s=sec: m['sec'] == s, shanti=(sec == 1))

    if 'katha' in kaun:
        from up_arth_2 import KATHA
        kai('katha', KATHA, {1: 'katha_11', 2: 'katha_12', 3: 'katha_13',
                             4: 'katha_21', 5: 'katha_22', 6: 'katha_23'})
    if 'prashna' in kaun:
        from up_arth_3 import PRASHNA
        kai('prashna', PRASHNA, {i: 'prashna_%d' % i for i in range(1, 7)})
    if 'mundaka' in kaun:
        from up_arth_3 import MUNDAKA
        kai('mundaka', MUNDAKA, {1: 'mundaka_11', 2: 'mundaka_12', 3: 'mundaka_21',
                                 4: 'mundaka_22', 5: 'mundaka_31', 6: 'mundaka_32'})
    if 'aitareya' in kaun:
        from up_arth_4 import AITAREYA
        # पहला अध्याय तीन खंडों का — केन की तरह «मंत्र खंड.मंत्र»; दूसरा और तीसरा अध्याय सीधे
        ek_paath('aitareya', 'aitareya_1', AITAREYA,
                 lambda m: 'मंत्र %s.%s' % (dev_ank(m['sec']), dev_ank(int(m['num']))),
                 chuno=lambda m: m['sec'] <= 3)
        ek_paath('aitareya', 'aitareya_2', AITAREYA, lambda m: 'मंत्र ' + dev_ank(int(m['num'])),
                 chuno=lambda m: m['sec'] == 4, shanti=False)
        ek_paath('aitareya', 'aitareya_3', AITAREYA, lambda m: 'मंत्र ' + dev_ank(int(m['num'])),
                 chuno=lambda m: m['sec'] == 5, shanti=False)
    if 'shveta' in kaun:
        from up_arth_4 import SHVETA
        kai('shveta', SHVETA, {i: 'shveta_%d' % i for i in range(1, 7)})
    if 'tait' in kaun:
        from up_arth_5 import TAIT
        # शीक्षा वल्ली का पहला अनुवाक ही उसका शांति पाठ ("शं नो मित्रः") है; बाक़ी दो
        # वल्लियाँ "सह नाववतु" से खुलती हैं
        for sec, shanti in ((1, False), (2, 'sahanavavatu'), (3, 'sahanavavatu')):
            ek_paath('tait', 'tait_%d' % sec, TAIT, lambda m: 'अनुवाक ' + dev_ank(int(m['num'])),
                     chuno=lambda m, s=sec: m['sec'] == s, shanti=shanti)
    if 'shanti' in kaun:
        out = []
        for i, (k, naam) in enumerate(SHANTI_KRAM, 1):
            out.append(shanti_khand(k, 'मंत्र %s — %s' % (dev_ank(i), naam)))
        likho('shanti', out)


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    main(sys.argv[1:])
