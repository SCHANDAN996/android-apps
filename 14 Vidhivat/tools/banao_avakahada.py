# -*- coding: utf-8 -*-
"""अवकहड़ा और गुण मिलान की तालिकाएँ → `engine/lib/src/avakahada_data.dart` (→ D-110, docs/29 K4)।

    python tools/banao_avakahada.py            # जाँचता है और Dart फ़ाइल लिखता है
    python tools/banao_avakahada.py --jaancho  # सिर्फ़ जाँचता है; फ़ाइल बदली हो तो 1 लौटाता है
    python tools/banao_avakahada.py --bhed     # पुस्तकों के बीच के फ़र्क़ छापता है (docs/18 अध्याय २६)

🔑 **ये तालिकाएँ याद से नहीं लिखी गईं।** हर एक छपी पुस्तक के पन्ने का चित्र देखकर
पढ़ी गई है (पते `docs/18_SROT_PANJI.md` अध्याय २६ में), और जहाँ हो सका वहाँ मशीन से
कसी गई है:

- **नाम के अक्षर** — दो अलग पुस्तकों के दो अलग श्लोकों से, और शतपद चक्र के अपने
  नियम से (बीस व्यंजन × पाँच स्वर + चार जगह तीन-तीन अक्षर) — तीनों एक हों तभी आगे।
- **योनि की दोनों तालिकाएँ** — सममित हों, अपनी योनि पर 4 हो, और मुहूर्तचिंतामणि के
  सात महावैर वाले जोड़ों पर 0 हो।
- **ग्रह मैत्री** — अंक नियम से निकलते हैं (मुहूर्तचिंतामणि की नैसर्गिक मैत्री +
  दैवज्ञमनोहर का अंक-नियम); छपी 7×7 तालिका से हर खाना मिलना चाहिए।
- **तारा, भकूट** — नियम से; छपी तालिका की पंक्तियों से मिलना चाहिए।

## कुंजी (पुस्तकें)
    MC  मुहूर्तचिंतामणि, विवाह प्रकरण २१–३९ (दो डिजिटल पाठ + दो छपी टीकाएँ)
    A   अति बृहत् अवकहड़ा चक्रम् / ज्योतिःशास्त्र सोपानम् (पं. सीताराम शर्मा), 1932
    B   बृहदवकहडाचक्रम् (दूसरी पुस्तक, दूसरे श्लोक)
    F   अष्टकूट मिलान की एक आधुनिक पाठ्य-पुस्तिका (कंप्यूटर-कुंडली वाली तालिकाएँ)
    U   एक मुक्त विश्वविद्यालय की पाठ्य-सामग्री (A की ही परंपरा)
    K   मुहूर्तचिंतामणि की एक हिंदी टीका के चक्र (A की ही परंपरा, छपाई की भूलों सहित)

## दो तालिकाएँ क्यों
योनि, गण और वश्य के अंक पुस्तकों में **सचमुच अलग** छपे हैं (→ D-041: जहाँ पद्धतियाँ
लड़ें, दोनों)। `prachalit` = F (आज के कंप्यूटर-पंचांग वाली); `purani` = A (1932)।
वश्य में तो राशियों का बँटवारा ही अलग है — वहाँ सिर्फ़ `prachalit` है और ऐप यह
खुलकर कहता है।
"""
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lipi import khula  # noqa: E402

OUT = os.path.join(HERE, '..', 'engine', 'lib', 'src', 'avakahada_data.dart')

NAKSHATRA = ['अश्विनी', 'भरणी', 'कृत्तिका', 'रोहिणी', 'मृगशिरा', 'आर्द्रा', 'पुनर्वसु', 'पुष्य',
             'आश्लेषा', 'मघा', 'पूर्वा फाल्गुनी', 'उत्तरा फाल्गुनी', 'हस्त', 'चित्रा', 'स्वाति',
             'विशाखा', 'अनुराधा', 'ज्येष्ठा', 'मूल', 'पूर्वाषाढ़ा', 'उत्तराषाढ़ा', 'श्रवण',
             'धनिष्ठा', 'शतभिषा', 'पूर्वा भाद्रपदा', 'उत्तरा भाद्रपदा', 'रेवती']
RASHI = ['मेष', 'वृष', 'मिथुन', 'कर्क', 'सिंह', 'कन्या', 'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन']

# ═══════════════════════════ नाम के अक्षर (शतपद चक्र) ═══════════════════════════
# B के श्लोक ९–१५ («चूचेचोलाऽश्विनी प्रोक्ता…») और A के श्लोक («…पू षा णा ठा तथा
# हस्ते…») — दो अलग श्लोक, अक्षर वही। मात्रा छोटी-बड़ी दोनों पुस्तकों में अलग लिखी है
# (A की भाषा-टीका: «ओ व वि वु»; B: «ओ वा वी वू») — चक्र में वे एक ही हैं।
SHATPAD = [
    'चू चे चो ला', 'ली लू ले लो', 'अ ई उ ए', 'ओ वा वी वू', 'वे वो का की', 'कू घ ङ छ',
    'के को हा ही', 'हू हे हो डा', 'डी डू डे डो', 'मा मी मू मे', 'मो टा टी टू', 'टे टो पा पी',
    'पू ष ण ठ', 'पे पो रा री', 'रू रे रो ता', 'ती तू ते तो', 'ना नी नू ने', 'नो या यी यू',
    'ये यो भा भी', 'भू धा फा ढा', 'भे भो जा जी', 'खी खू खे खो', 'गा गी गू गे', 'गो सा सी सू',
    'से सो दा दी', 'दू थ झ ञ', 'दे दो चा ची',
]
# अभिजित — उत्तराषाढ़ा और श्रवण के बीच का अट्ठाईसवाँ नक्षत्र (B: «जूजेजोषाभिजिद्»,
# A: «जू जे जो खाऽभिजित्पदाः»; पुरानी छपाई में ष = ख)।
ABHIJIT = 'जू जे जो खा'

_SWAR = {'': 'a', 'ा': 'a', 'ि': 'i', 'ी': 'i', 'ु': 'u', 'ू': 'u', 'े': 'e', 'ो': 'o'}
_SWAR_AKSHAR = {'अ': 'a', 'आ': 'a', 'इ': 'i', 'ई': 'i', 'उ': 'u', 'ऊ': 'u', 'ए': 'e', 'ओ': 'o'}


def _varg(akshar):
    """'वी' → ('व', 'i') — व्यंजन और स्वर का वर्ग (छोटा-बड़ा एक)।"""
    if akshar in _SWAR_AKSHAR:
        return ('', _SWAR_AKSHAR[akshar])
    return (akshar[0], _SWAR[akshar[1:]])


def shatpad_niyam():
    """शतपद चक्र अपने नियम से — कृत्तिका से शुरू, 112 अक्षर।

    बीस वर्ण (स्वर, फिर व क ह ड म ट प र त न य भ ज ख ग स द च ल), हर एक पाँच स्वरों
    के साथ (अ इ उ ए ओ); और क, प, भ, द के «उ» के बाद तीन-तीन अकेले अक्षर।
    चक्र का नाम यहीं से है: अ-व-क-ह-ड़ा।
    """
    beech = {'क': 'घङछ', 'प': 'षणठ', 'भ': 'धफढ', 'द': 'थझञ'}
    out = []
    for v in ['', 'व', 'क', 'ह', 'ड', 'म', 'ट', 'प', 'र', 'त', 'न', 'य', 'भ', 'ज', 'ख', 'ग', 'स', 'द', 'च', 'ल']:
        for s in 'aiueo':
            out.append((v, s))
            if s == 'u' and v in beech:
                out.extend((x, 'a') for x in beech[v])
    return out


def jaancho_shatpad():
    niyam = shatpad_niyam()
    assert len(niyam) == 112, len(niyam)
    # चक्र का क्रम: कृत्तिका … उत्तराषाढ़ा, अभिजित, श्रवण … रेवती, अश्विनी, भरणी
    kram = SHATPAD[2:21] + [ABHIJIT] + SHATPAD[21:] + SHATPAD[:2]
    likha = [_varg(a) for pad in kram for a in pad.split()]
    assert len(likha) == 112, len(likha)
    for i, (n, l) in enumerate(zip(niyam, likha)):
        assert n == l, ('शतपद चक्र नियम से नहीं मिला', i, n, l)
    for pad in SHATPAD + [ABHIJIT]:
        assert len(pad.split()) == 4, pad


# ═══════════════════════════ नक्षत्र → योनि, गण, नाड़ी ═══════════════════════════
YONI = ['अश्व', 'गज', 'मेष', 'सर्प', 'श्वान', 'मार्जार', 'मूषक', 'गौ', 'महिष', 'व्याघ्र', 'मृग',
        'वानर', 'नकुल', 'सिंह']
(ASHVA, GAJ, MESH, SARP, SHVAN, MARJAR, MUSHAK, GAU, MAHISH, VYAGHRA, MRIG, VANAR, NAKUL,
 SIMHA) = range(14)

# MC २५–२६ «अश्विन्यम्बुपयोर्हयो निगदितः…» — हर पाद में दो योनियाँ, हर योनि के दो नक्षत्र।
# (उत्तराषाढ़ा का जोड़ीदार अभिजित है — 27 की गिनती में नकुल अकेला रह जाता है।)
YONI_NAK = [ASHVA, GAJ, MESH, SARP, SARP, SHVAN, MARJAR, MESH, MARJAR, MUSHAK, MUSHAK, GAU,
            MAHISH, VYAGHRA, MAHISH, VYAGHRA, MRIG, MRIG, SHVAN, VANAR, NAKUL, VANAR, SIMHA,
            ASHVA, SIMHA, GAU, GAJ]
# वही श्लोक: «योनिः पादगयोः परस्परमहावैरम्» — एक पाद की दोनों योनियाँ; B का «योनिवैरम्»
# श्लोक (गोव्याघ्रं गजसिंहमश्वमहिषं…) यही सात जोड़े गिनाता है।
MAHAVAIR = [(ASHVA, MAHISH), (GAJ, SIMHA), (MESH, VANAR), (SARP, NAKUL), (SHVAN, MRIG),
            (MARJAR, MUSHAK), (GAU, VYAGHRA)]

DEV, MANUSHYA, RAKSHAS = range(3)
# MC २९ «रक्षोनरामरगणाः क्रमतो मघाहिवस्विन्द्रमूलवरुणानलतक्षराधाः…»
GANA_NAK = [DEV, MANUSHYA, RAKSHAS, MANUSHYA, DEV, MANUSHYA, DEV, DEV, RAKSHAS, RAKSHAS,
            MANUSHYA, MANUSHYA, DEV, RAKSHAS, DEV, RAKSHAS, DEV, RAKSHAS, RAKSHAS, MANUSHYA,
            MANUSHYA, DEV, RAKSHAS, RAKSHAS, MANUSHYA, MANUSHYA, DEV]

ADI, MADHYA, ANTYA = range(3)
# MC ३४ «ज्येष्ठारौद्रार्यमाम्भःपतिभयुगयुगं दास्रभं चैकनाडी…»
NADI_NAK = [ADI, MADHYA, ANTYA, ANTYA, MADHYA, ADI, ADI, MADHYA, ANTYA, ANTYA, MADHYA, ADI,
            ADI, MADHYA, ANTYA, ANTYA, MADHYA, ADI, ADI, MADHYA, ANTYA, ANTYA, MADHYA, ADI,
            ADI, MADHYA, ANTYA]


def jaancho_nakshatra():
    assert len(YONI_NAK) == len(GANA_NAK) == len(NADI_NAK) == 27
    # हर योनि के दो नक्षत्र; नकुल का एक (दूसरा अभिजित)
    for y in range(14):
        assert YONI_NAK.count(y) == (1 if y == NAKUL else 2), YONI[y]
    for g in range(3):
        assert GANA_NAK.count(g) == 9
        assert NADI_NAK.count(g) == 9
    # नाड़ी का साँप जैसा क्रम: आदि मध्य अंत्य · अंत्य मध्य आदि · …
    for i in range(27):
        assert NADI_NAK[i] == [0, 1, 2, 2, 1, 0][i % 6], i


# ═══════════════════════════ राशि → वर्ण, स्वामी, वश्य ═══════════════════════════
BRAHMAN, KSHATRIYA, VAISHYA, SHUDRA = range(4)
# MC २२ «द्विजा झषालिकर्कटास्ततो नृपा विशोऽङ्घ्रिजाः»; B श्लोक १४; A का वर्णज्ञान श्लोक।
VARNA_RASHI = [KSHATRIYA, VAISHYA, SHUDRA, BRAHMAN, KSHATRIYA, VAISHYA, SHUDRA, BRAHMAN,
               KSHATRIYA, VAISHYA, SHUDRA, BRAHMAN]

SURYA, CHANDRA, MANGAL, BUDH, GURU, SHUKRA, SHANI = range(7)
GRAHA = ['सूर्य', 'चंद्र', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि']
# MC ३९ «कुजशुक्रसौम्यशशिसूर्यचन्द्रजाः कविभौमजीवशनिसौरयो गुरुः»
RASHI_SWAMI = [MANGAL, SHUKRA, BUDH, CHANDRA, SURYA, BUDH, SHUKRA, MANGAL, GURU, SHANI, SHANI,
               GURU]

CHATUSHPAD, MANAV, JALCHAR, VANCHAR, KEET = range(5)
VASHYA = ['चतुष्पद', 'मानव', 'जलचर', 'वनचर', 'कीट']
# F की «वश्य-बोधक तालिका»: हर राशि का (पूर्वार्ध, उत्तरार्ध)। धनु और मकर आधे-आधे —
# यह बँटवारा A और B के श्लोकों में भी वही है।
VASHYA_RASHI = [(CHATUSHPAD, CHATUSHPAD), (CHATUSHPAD, CHATUSHPAD), (MANAV, MANAV),
                (JALCHAR, JALCHAR), (VANCHAR, VANCHAR), (MANAV, MANAV), (MANAV, MANAV),
                (KEET, KEET), (MANAV, CHATUSHPAD), (CHATUSHPAD, JALCHAR), (MANAV, MANAV),
                (JALCHAR, JALCHAR)]
# A (श्लोक १८–१९) और B (श्लोक १८–१९) का बँटवारा — जहाँ F से अलग है।
# «कीटस्तु कर्कटः», «कुम्भश्च मीनश्चैते जलेचराः», और सिंह चतुष्पदों में गिना है।
VASHYA_RASHI_PURANA_BHED = {3: KEET, 4: CHATUSHPAD, 10: JALCHAR}

# ═══════════════════════════ अंक की तालिकाएँ — [कन्या][वर] ═══════════════════════════
H = 0.5
# F, पृष्ठ १० «वश्यगुण-बोधक तालिका»
VASHYA_ANK = [
    [2, 1, 1, H, 1],
    [1, 2, H, 0, 1],
    [1, H, 2, 1, 1],
    [0, 0, 1, 2, 0],
    [1, 0, 1, 0, 2],
]
# सिर्फ़ `--bhed` के लिए: वही तालिका दूसरी पुस्तकों में (खाने उसी क्रम में)।
VASHYA_ANK_A = [  # A (1932), पृष्ठ ४७
    [2, 1, 1, H, 0],
    [1, 2, 1, 0, 0],
    [1, H, 2, 1, 2],
    [0, 0, 2, 2, 0],
    [1, 0, 1, 0, 2],
]
VASHYA_ANK_U = [  # U, पृष्ठ ११२
    [2, 1, 1, H, 0],
    [1, 2, H, 0, 0],
    [1, H, 2, 1, 2],
    [0, 0, 1, 2, 0],
    [1, 1, 1, 0, 2],
]

# F, पृष्ठ २२ «वर की योनि / कन्या की योनि»। एक खाना छपाई की भूल है और ठीक किया गया:
# [व्याघ्र][गौ] में 1 छपा है, जबकि [गौ][व्याघ्र] = 0 और गौ–व्याघ्र महावैर का जोड़ा है।
YONI_ANK_PRACHALIT = [
    [4, 2, 2, 3, 2, 2, 2, 1, 0, 1, 3, 3, 2, 1],
    [2, 4, 3, 3, 2, 2, 2, 2, 3, 1, 2, 3, 2, 0],
    [2, 3, 4, 2, 1, 2, 1, 3, 3, 1, 2, 0, 3, 1],
    [3, 3, 2, 4, 2, 1, 1, 1, 1, 2, 2, 2, 0, 2],
    [2, 2, 1, 2, 4, 2, 1, 2, 2, 1, 0, 2, 1, 1],
    [2, 2, 2, 1, 2, 4, 0, 2, 2, 1, 3, 3, 2, 1],
    [2, 2, 1, 1, 1, 0, 4, 2, 2, 2, 2, 2, 1, 2],
    [1, 2, 3, 1, 2, 2, 2, 4, 3, 0, 3, 2, 2, 1],
    [0, 3, 3, 1, 2, 2, 2, 3, 4, 1, 2, 2, 2, 1],
    [1, 1, 1, 2, 1, 1, 2, 0, 1, 4, 1, 1, 2, 1],
    [3, 2, 2, 2, 0, 3, 2, 3, 2, 1, 4, 2, 2, 1],
    [3, 3, 0, 2, 2, 3, 2, 2, 2, 1, 2, 4, 3, 2],
    [2, 2, 3, 0, 1, 2, 1, 2, 2, 2, 2, 3, 4, 2],
    [1, 0, 1, 2, 1, 1, 2, 1, 1, 1, 1, 2, 2, 4],
]
# A (1932), पृष्ठ ५० «योनि गुणबोधक चक्र»
YONI_ANK_PURANI = [
    [4, 2, 3, 2, 2, 2, 2, 3, 0, 1, 3, 2, 2, 1],
    [2, 4, 3, 2, 2, 2, 2, 2, 3, 2, 2, 3, 2, 0],
    [3, 3, 4, 3, 2, 3, 2, 3, 3, 1, 3, 0, 3, 1],
    [2, 2, 3, 4, 2, 2, 1, 1, 2, 2, 2, 2, 0, 2],
    [2, 2, 2, 2, 4, 1, 1, 2, 2, 1, 0, 2, 2, 1],
    [2, 2, 3, 2, 1, 4, 0, 2, 2, 1, 2, 2, 2, 2],
    [2, 2, 2, 1, 1, 0, 4, 2, 2, 2, 2, 2, 2, 1],
    [3, 2, 3, 1, 2, 2, 2, 4, 3, 0, 3, 2, 3, 1],
    [0, 3, 3, 2, 2, 2, 2, 3, 4, 1, 2, 2, 2, 3],
    [1, 2, 1, 2, 1, 1, 2, 0, 1, 4, 1, 1, 2, 2],
    [3, 2, 3, 2, 0, 2, 2, 3, 2, 1, 4, 2, 2, 2],
    [2, 3, 0, 2, 2, 2, 2, 2, 2, 1, 2, 4, 2, 3],
    [2, 2, 3, 0, 2, 2, 2, 3, 2, 2, 2, 2, 4, 2],
    [1, 0, 1, 2, 1, 2, 1, 1, 3, 2, 2, 3, 2, 4],
]

# F, पृष्ठ २९ «गण गुण बोधक तालिका» (U की तालिका भी यही)
GANA_ANK_PRACHALIT = [
    [6, 5, 1],
    [6, 6, 0],
    [1, 0, 6],
]
# A (1932), पृष्ठ ५३ — «स्वगणे षड् गुणाः प्रोक्ताः पञ्च देवमनुष्ययोः। देवराक्षसयोश्चैकः
# शून्यं मनुजरक्षसोः»
GANA_ANK_PURANI = [
    [6, 5, 1],
    [5, 6, 0],
    [1, 0, 6],
]

# ─── ग्रह मैत्री: नैसर्गिक मैत्री (MC २७–२८) + अंक का नियम (दैवज्ञमनोहर) ───
MITRA, SAM, SHATRU = 1, 0, -1
# NAISARGIK[ग्रह][दूसरा] — «ग्रह» की नज़र में «दूसरा» क्या है।
NAISARGIK = [
    #  सू      चं      मं      बु      गु      शु      श
    [SAM, MITRA, MITRA, SAM, MITRA, SHATRU, SHATRU],        # सूर्य
    [MITRA, SAM, SAM, MITRA, SAM, SAM, SAM],                # चंद्र — कोई शत्रु नहीं
    [MITRA, MITRA, SAM, SHATRU, MITRA, SAM, SAM],           # मंगल
    [MITRA, SHATRU, SAM, SAM, SAM, MITRA, SAM],             # बुध
    [MITRA, MITRA, MITRA, SHATRU, SAM, SHATRU, SAM],        # गुरु
    [SHATRU, SHATRU, SAM, MITRA, SAM, SAM, MITRA],          # शुक्र
    [SHATRU, SHATRU, SHATRU, MITRA, SAM, MITRA, SAM],       # शनि
]


def maitri_ank(a, b):
    """«ग्रहमैत्रं सप्तविधं गुणाः पञ्च प्रकीर्तिताः…» — दो राशि-स्वामियों का अंक।"""
    if a == b:
        return 5
    jod = sorted((NAISARGIK[a][b], NAISARGIK[b][a]), reverse=True)
    return {(1, 1): 5, (1, 0): 4, (0, 0): 3, (1, -1): 1, (0, -1): H, (-1, -1): 0}[tuple(jod)]


# A (1932), पृष्ठ ५२ «ग्रहमैत्री गुण बोधक» — जैसी छपी है। U के पृष्ठ ११६ पर भी यही।
MAITRI_ANK_A = [
    [5, 5, 5, 4, 5, 0, 0],
    [5, 5, 4, 1, 4, H, H],
    [5, 4, 5, H, 5, 3, H],
    [4, 1, H, 5, H, 5, 4],
    [5, 4, 5, H, 5, H, 3],
    [0, H, 3, 5, H, 5, 5],
    [0, H, H, 4, 3, 5, 5],
]


def tara_ank(var_nak, kanya_nak):
    """MC २४ + «एकतश्चेच्छुभा तारा…»: दोनों ओर से गिनकर 9 से भाग; 3, 5, 7 बचे तो अशुभ।"""
    def shubh(se, tak):
        return ((tak - se) % 27 + 1) % 9 not in (3, 5, 7)
    return {2: 3, 1: 1.5, 0: 0}[shubh(kanya_nak, var_nak) + shubh(var_nak, kanya_nak)]


def bhakoot_ank(var_rashi, kanya_rashi):
    """MC ३१ «मृत्युः षडष्टके ज्ञेयोऽपत्यहानिर्नवात्मजे। द्विर्द्वादशे निर्धनत्वम्…»"""
    return 0 if (kanya_rashi - var_rashi) % 12 + 1 in (2, 12, 5, 9, 6, 8) else 7


# A (1932), पृष्ठ ५४ «राशिकूट गुणबोधक चक्र» की पहली दो पंक्तियाँ (कन्या मेष, कन्या वृष)।
BHAKOOT_A = {
    0: [7, 0, 7, 7, 0, 0, 7, 0, 0, 7, 7, 0],
    1: [0, 7, 0, 7, 7, 0, 0, 7, 0, 0, 7, 7],
}
# A (1932), पृष्ठ ४८ «तारागुणबोधक चक्र» — [कन्या की तारा][वर की तारा], 1…9
TARA_A = [
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
    [1.5, 1.5, 0, 1.5, 0, 1.5, 0, 1.5, 1.5],
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
    [1.5, 1.5, 0, 1.5, 0, 1.5, 0, 1.5, 1.5],
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
    [1.5, 1.5, 0, 1.5, 0, 1.5, 0, 1.5, 1.5],
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
    [3, 3, 1.5, 3, 1.5, 3, 1.5, 3, 3],
]


def jaancho_ank():
    for naam, t in (('प्रचलित', YONI_ANK_PRACHALIT), ('पुरानी', YONI_ANK_PURANI)):
        assert len(t) == 14 and all(len(r) == 14 for r in t)
        for i in range(14):
            assert t[i][i] == 4, (naam, YONI[i])
            for j in range(14):
                assert t[i][j] == t[j][i], ('योनि तालिका सममित नहीं', naam, YONI[i], YONI[j])
                assert 0 <= t[i][j] <= 4
                if i != j:
                    vair = (i, j) in MAHAVAIR or (j, i) in MAHAVAIR
                    assert (t[i][j] == 0) == vair, ('महावैर', naam, YONI[i], YONI[j])
    for i in range(7):
        for j in range(7):
            assert maitri_ank(i, j) == MAITRI_ANK_A[i][j], ('ग्रह मैत्री', GRAHA[i], GRAHA[j])
            assert maitri_ank(i, j) == maitri_ank(j, i)
    for k, row in BHAKOOT_A.items():
        for v in range(12):
            assert bhakoot_ank(v, k) == row[v], ('भकूट', RASHI[k], RASHI[v])
    # तारा: छपी तालिका में तारा = 9 से भाग का शेष (0 की जगह 9)
    for kt in range(1, 10):
        for vt in range(1, 10):
            ank = {2: 3, 1: 1.5, 0: 0}[(kt not in (3, 5, 7)) + (vt not in (3, 5, 7))]
            assert TARA_A[kt - 1][vt - 1] == ank, ('तारा', kt, vt)
    for t in (VASHYA_ANK, VASHYA_ANK_A, VASHYA_ANK_U):
        assert len(t) == 5 and all(len(r) == 5 and all(0 <= x <= 2 for x in r) for r in t)
        assert all(t[i][i] == 2 for i in range(5))
    assert len(VASHYA_RASHI) == len(VARNA_RASHI) == len(RASHI_SWAMI) == 12


# ═══════════════════════════ पुस्तकों के बीच का फ़र्क़ ═══════════════════════════
def bhed():
    print('## योनि — प्रचलित (F) बनाम पुरानी (A), जहाँ अलग हैं (जोड़ा एक बार)')
    n = 0
    for i in range(14):
        for j in range(i + 1, 14):
            a, b = YONI_ANK_PRACHALIT[i][j], YONI_ANK_PURANI[i][j]
            if a != b:
                n += 1
                print('  %s–%s: %d | %d' % (YONI[i], YONI[j], a, b))
    print('  कुल %d जोड़े अलग, 91 में से' % n)
    print('## वश्य — F | A (1932) | U, जहाँ तीनों एक नहीं ([कन्या][वर])')
    for i in range(5):
        for j in range(5):
            x = (VASHYA_ANK[i][j], VASHYA_ANK_A[i][j], VASHYA_ANK_U[i][j])
            if len(set(x)) > 1:
                print('  कन्या %s, वर %s: %s | %s | %s' % ((VASHYA[i], VASHYA[j]) + x))
    print('## गण — जहाँ अलग ([कन्या][वर])')
    g = ['देव', 'मनुष्य', 'राक्षस']
    for i in range(3):
        for j in range(3):
            if GANA_ANK_PRACHALIT[i][j] != GANA_ANK_PURANI[i][j]:
                print('  कन्या %s, वर %s: %d | %d'
                      % (g[i], g[j], GANA_ANK_PRACHALIT[i][j], GANA_ANK_PURANI[i][j]))
    # 27×27 नक्षत्र-जोड़ों पर योनि + गण का कुल फ़र्क़ कितना जाता है
    fark = {}
    for v in range(27):
        for k in range(27):
            p = YONI_ANK_PRACHALIT[YONI_NAK[k]][YONI_NAK[v]] + GANA_ANK_PRACHALIT[GANA_NAK[k]][GANA_NAK[v]]
            q = YONI_ANK_PURANI[YONI_NAK[k]][YONI_NAK[v]] + GANA_ANK_PURANI[GANA_NAK[k]][GANA_NAK[v]]
            fark[q - p] = fark.get(q - p, 0) + 1
    print('## 729 नक्षत्र-जोड़ों पर (पुरानी − प्रचलित), योनि + गण:')
    for d in sorted(fark):
        print('  %+d: %d जोड़े' % (d, fark[d]))


# ═══════════════════════════ Dart ═══════════════════════════
def _suchi(xs):
    def ek(x):
        if isinstance(x, float):
            return repr(x)
        return str(x)
    return '[' + ', '.join(ek(x) for x in xs) + ']'


def dart():
    L = []
    w = L.append
    w('// ⚠️ यह फ़ाइल औज़ार से बनी है — हाथ से मत छूना।')
    w('//')
    w('//     python tools/banao_avakahada.py')
    w('//')
    w('// अवकहड़ा और गुण मिलान की तालिकाएँ (→ D-110)। हर तालिका किस पुस्तक के किस पन्ने')
    w('// से पढ़ी गई और मशीन से कैसे कसी गई — `tools/banao_avakahada.py` और')
    w('// `docs/18_SROT_PANJI.md` अध्याय २६ में।')
    w('//')
    w('// दो-आयामी तालिकाओं में पहला खाना **कन्या** का है, दूसरा **वर** का: `t[कन्या][वर]`।')
    w('')
    w('/// नाम का पहला अक्षर — नक्षत्र (0 = अश्विनी) और चरण (0–3) से। शतपद चक्र।')
    w('const List<List<String>> naamAksharData = [')
    for pad, nak in zip(SHATPAD, NAKSHATRA):
        w("  [%s], // %s" % (', '.join("'%s'" % a for a in pad.split()), nak))
    w('];')
    w('')
    w('/// अभिजित के चार चरणों के अक्षर (उत्तराषाढ़ा और श्रवण के बीच)।')
    w('const List<String> abhijitAksharData = [%s];' % ', '.join("'%s'" % a for a in ABHIJIT.split()))
    w('')
    w('/// नक्षत्र → योनि (`Yoni.values` में जगह)।')
    w('const List<int> nakshatraYoniData = %s;' % _suchi(YONI_NAK))
    w('')
    w('/// नक्षत्र → गण (0 देव, 1 मनुष्य, 2 राक्षस)।')
    w('const List<int> nakshatraGanaData = %s;' % _suchi(GANA_NAK))
    w('')
    w('/// नक्षत्र → नाड़ी (0 आदि, 1 मध्य, 2 अंत्य)।')
    w('const List<int> nakshatraNadiData = %s;' % _suchi(NADI_NAK))
    w('')
    w('/// राशि → वर्ण (0 ब्राह्मण, 1 क्षत्रिय, 2 वैश्य, 3 शूद्र)।')
    w('const List<int> rashiVarnaData = %s;' % _suchi(VARNA_RASHI))
    w('')
    w('/// राशि → स्वामी (0 सूर्य, 1 चंद्र, 2 मंगल, 3 बुध, 4 गुरु, 5 शुक्र, 6 शनि)।')
    w('const List<int> rashiSwamiData = %s;' % _suchi(RASHI_SWAMI))
    w('')
    w('/// राशि → वश्य: [पूर्वार्ध, उत्तरार्ध] (0 चतुष्पद, 1 मानव, 2 जलचर, 3 वनचर, 4 कीट)।')
    w('const List<List<int>> rashiVashyaData = [')
    for (a, b), r in zip(VASHYA_RASHI, RASHI):
        w('  [%d, %d], // %s' % (a, b, r))
    w('];')
    w('')
    w('/// पुरानी पुस्तकों के श्लोक में जिन राशियों का वश्य अलग गिना है: राशि → वश्य।')
    w('const Map<int, int> rashiVashyaPuranaBhedData = {%s};'
      % ', '.join('%d: %d' % kv for kv in sorted(VASHYA_RASHI_PURANA_BHED.items())))
    w('')
    w('/// वश्य के अंक — `[कन्या][वर]`।')
    w('const List<List<double>> vashyaAnkData = [')
    for r in VASHYA_ANK:
        w('  %s,' % _suchi([float(x) for x in r]))
    w('];')
    for naam, t, tip in (('yoniAnkPrachalitData', YONI_ANK_PRACHALIT, 'योनि के अंक — आज की प्रचलित तालिका'),
                         ('yoniAnkPuraniData', YONI_ANK_PURANI, 'योनि के अंक — 1932 की छपी तालिका'),
                         ('ganaAnkPrachalitData', GANA_ANK_PRACHALIT, 'गण के अंक — आज की प्रचलित तालिका'),
                         ('ganaAnkPuraniData', GANA_ANK_PURANI, 'गण के अंक — 1932 की छपी तालिका')):
        w('')
        w('/// %s — `[कन्या][वर]`।' % tip)
        w('const List<List<int>> %s = [' % naam)
        for r in t:
            w('  %s,' % _suchi(r))
        w('];')
    w('')
    w('/// नैसर्गिक मैत्री — `[ग्रह][दूसरा]`: 1 मित्र, 0 सम, -1 शत्रु। क्रम: सूर्य … शनि।')
    w('const List<List<int>> naisargikMaitriData = [')
    for r, g in zip(NAISARGIK, GRAHA):
        w('  %s, // %s' % (_suchi(r), g))
    w('];')
    return khula('\n'.join(L) + '\n')


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    jaancho_shatpad()
    jaancho_nakshatra()
    jaancho_ank()
    if '--bhed' in sys.argv:
        bhed()
        return 0
    naya = dart()
    purana = io.open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else None
    if '--jaancho' in sys.argv:
        ok = naya == purana
        print('avakahada_data.dart', '✓ हूबहू' if ok else '✗ औज़ार से अलग है')
        return 0 if ok else 1
    with io.open(OUT, 'w', encoding='utf-8', newline='\n') as f:
        f.write(naya)
    print('लिखा', os.path.relpath(OUT, os.path.join(HERE, '..')),
          '(बदला)' if naya != purana else '(वही)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
