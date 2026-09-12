"""एक साझा साँचे से नवरात्रि की दिन-वार घरेलू विधियाँ बनाता है।"""

from __future__ import annotations

import copy
import json
from pathlib import Path


JAD = Path(__file__).resolve().parents[1]
VIDHI = JAD / "app" / "assets" / "vidhi"
NIRGAM = VIDHI / "navratri"

DEVI = {
    2: ("ब्रह्मचारिणी", "brahmacharini", "शक्कर या मिश्री"),
    3: ("चंद्रघंटा", "chandraghanta", "दूध या खीर"),
    4: ("कूष्मांडा", "kushmanda", "मालपुआ"),
    5: ("स्कंदमाता", "skandamata", "केला"),
    6: ("कात्यायनी", "katyayani", "शहद"),
    7: ("कालरात्रि", "kalaratri", "गुड़"),
}

# देवी-विशेष ध्यान श्लोक — **श्री नवदुर्गा स्तोत्र** से।
#
# ⚠️ पहले यहाँ सिर्फ़ `ॐ देवी <नाम> नमः` बनता था, `bharosa: kam` के साथ।
# वह व्याकरण से भी अधूरा था (नमः के साथ चतुर्थी आती है)। 12 सित 2026 को
# असली श्लोक भरे गए — नाम की सूची का पता **दुर्गा सप्तशती के देवी कवच,
# श्लोक ३–५** है; ध्यान श्लोक नवदुर्गा स्तोत्र के हैं, जिसका मूल ग्रंथ
# कहीं दर्ज नहीं मिलता — इसलिए भरोसा **मध्यम**।
#
# key = roman नाम। (devanagari, roman, arth, vikalp)
DHYAN = {
    "brahmacharini": (
        "दधाना करपद्माभ्यामक्षमालाकमण्डलू।\n"
        "देवी प्रसीदतु मयि ब्रह्मचारिण्यनुत्तमा॥",
        "dadhana kara-padmabhyam akshamala-kamandalu |\n"
        "devi prasidatu mayi brahmacharinyanuttama ||",
        "जिनके कमल जैसे दोनों हाथों में जप की माला और कमंडलु है, वे सर्वश्रेष्ठ "
        "ब्रह्मचारिणी देवी मुझ पर प्रसन्न हों।",
        "पहले यहाँ सिर्फ़ \"ॐ देवी ब्रह्मचारिणी नमः\" लिखा था — वह व्याकरण से "
        "अधूरा था; नमः के साथ चतुर्थी विभक्ति आती है, इसलिए \"ब्रह्मचारिण्यै\"।",
    ),
    "chandraghanta": (
        "पिण्डजप्रवरारूढा चण्डकोपास्त्रकैर्युता।\n"
        "प्रसादं तनुते मह्यं चन्द्रघण्टेति विश्रुता॥",
        "pindaja-pravararudha chanda-kopastrakair yuta |\n"
        "prasadam tanute mahyam chandraghanteti vishruta ||",
        "श्रेष्ठ वाहन पर सवार और प्रचंड क्रोध वाले अस्त्रों से युक्त, चन्द्रघंटा "
        "नाम से प्रसिद्ध देवी मुझ पर कृपा करें।",
        "पाठभेद — \"चण्डकोपास्त्रकैर्युता\" कहीं \"चण्डकोपास्त्रकैर्यता\" भी "
        "छपा मिलता है; भाव वही है।",
    ),
    "kushmanda": (
        "सुरासम्पूर्णकलशं रुधिराप्लुतमेव च।\n"
        "दधाना हस्तपद्माभ्यां कूष्माण्डा शुभदास्तु मे॥",
        "sura-sampurna-kalasham rudhiraplutam eva cha |\n"
        "dadhana hasta-padmabhyam kushmanda shubhadastu me ||",
        "जो अपने कमल जैसे हाथों में सुरा से भरा और रक्त से युक्त कलश धारण किए "
        "हैं, वे कूष्मांडा देवी मेरा कल्याण करें।",
        "⚠️ इस श्लोक की भाषा तांत्रिक परंपरा की है। बहुत छपी टीकाओं में \"सुरा\" "
        "को **अमृत** और \"रुधिर\" को **रक्तवर्ण** पढ़ा जाता है — यानी अमृत से "
        "भरा लाल कलश। दोनों पाठ चलते हैं; घर की पूजा में जो पढ़ाया गया हो वही "
        "सही है। सरल रूप में सिर्फ़ नाम-मंत्र भी पूरा चलन है।",
    ),
    "skandamata": (
        "सिंहासनगता नित्यं पद्माश्रितकरद्वया।\n"
        "शुभदास्तु सदा देवी स्कन्दमाता यशस्विनी॥",
        "simhasana-gata nityam padmashrita-kara-dvaya |\n"
        "shubhadastu sada devi skandamata yashasvini ||",
        "जो सदा सिंह के आसन पर विराजती हैं और जिनके दोनों हाथों में कमल है, वे "
        "यशस्विनी स्कंदमाता सदा मेरा कल्याण करें।",
        "पाठभेद — \"पद्माश्रितकरद्वया\" कहीं \"पद्माञ्चितकरद्वया\" मिलता है।",
    ),
    "katyayani": (
        "चन्द्रहासोज्ज्वलकरा शार्दूलवरवाहना।\n"
        "कात्यायनी शुभं दद्याद्देवी दानवघातिनी॥",
        "chandrahasojjvala-kara shardula-vara-vahana |\n"
        "katyayani shubham dadyad devi danavaghatini ||",
        "जिनके हाथ में चन्द्रहास खड्ग चमकता है और जिनका वाहन श्रेष्ठ सिंह है, वे "
        "दानवों का नाश करने वाली कात्यायनी देवी कल्याण करें।",
        "पाठभेद — \"दद्याद्देवी\" कहीं \"दद्यादेवि\", और \"दानवघातिनी\" कहीं "
        "\"दानवघातिनि\" छपा मिलता है।",
    ),
    "kalaratri": (
        "एकवेणी जपाकर्णपूरा नग्ना खरास्थिता।\n"
        "लम्बोष्ठी कर्णिकाकर्णी तैलाभ्यक्तशरीरिणी॥",
        "eka-veni japa-karnapura nagna kharasthita |\n"
        "lambaushthi karnikakarni tailabhyakta-sharirini ||",
        "एक ही वेणी वाली, कानों में जपा-पुष्प पहने, दिगंबरा, गर्दभ पर स्थित — "
        "यह माँ कालरात्रि का पारंपरिक ध्यान है।",
        "⚠️ यह श्लोक देवी के **उग्र रूप** का वर्णन है और इसकी भाषा प्रतीकों की "
        "है — \"नग्ना\" का भाव दिगंबरा है, यानी जिस पर माया का कोई आवरण नहीं। "
        "बहुत घरों में यह श्लोक नहीं बोला जाता, सिर्फ़ नाम-मंत्र कहा जाता है — "
        "वह भी पूरा चलन है। पूरे स्तोत्र में इसके आगे एक और श्लोक चलता है "
        "(\"वामपादोल्लसल्लोह…\"), जो यहाँ नहीं लिया गया।",
    ),
    "siddhidatri": (
        "सिद्धगन्धर्वयक्षाद्यैरसुरैरमरैरपि।\n"
        "सेव्यमाना सदा भूयात् सिद्धिदा सिद्धिदायिनी॥",
        "siddha-gandharva-yakshadyair asurair amarair api |\n"
        "sevyamana sada bhuyat siddhida siddhidayini ||",
        "सिद्ध, गंधर्व, यक्ष, असुर और देवता — सब जिनकी सेवा करते हैं, वे सिद्धि "
        "देने वाली सिद्धिदात्री देवी सदा सिद्धि देने वाली हों।",
        "पाठभेद — \"यक्षाद्यैः\" कहीं \"यक्षाघैः\" छपा मिलता है, जो छपाई की "
        "चूक लगती है।",
    ),
}

# नमः के साथ चतुर्थी विभक्ति — "ब्रह्मचारिणी नमः" नहीं, "ब्रह्मचारिण्यै नमः"।
CHATURTHI = {
    "brahmacharini": ("ब्रह्मचारिण्यै", "brahmacharinyai"),
    "chandraghanta": ("चन्द्रघण्टायै", "chandraghantayai"),
    "kushmanda": ("कूष्माण्डायै", "kushmandayai"),
    "skandamata": ("स्कन्दमातायै", "skandamatayai"),
    "katyayani": ("कात्यायन्यै", "katyayanyai"),
    "kalaratri": ("कालरात्र्यै", "kalaratryai"),
    "siddhidatri": ("सिद्धिदात्र्यै", "siddhidatryai"),
    "mahagauri": ("महागौर्यै", "mahagauryai"),
    "shailaputri": ("शैलपुत्र्यै", "shailaputryai"),
    "durga": ("दुर्गायै", "durgayai"),
}

SROT_NAAM = ("नौ नामों की सूची **दुर्गा सप्तशती के देवी कवच, श्लोक ३–५** में है "
             "(\"प्रथमं शैलपुत्री च द्वितीयं ब्रह्मचारिणी…\")। ")
SROT_STOTRA = ("ध्यान श्लोक **श्री नवदुर्गा स्तोत्र** का है — नवरात्रि में घर-घर "
               "पढ़ा जाने वाला प्रचलित स्तोत्र। ⚠️ उसका मूल ग्रंथ कहीं दर्ज नहीं "
               "मिलता, इसलिए भरोसा मध्यम रखा गया है।")
BEEJ = ("कुछ जगह इसके साथ बीज-मंत्र वाला रूप भी मिलता है। ⚠️ ऐं-ह्रीं-क्लीं "
        "**बीज-मंत्र** हैं और कुछ पद्धतियों में वे गुरु से लेकर ही जपे जाते "
        "हैं — इसलिए ऊपर सिर्फ़ नाम-मंत्र रखा गया है।")


# भोग का मंत्र — बाक़ी पूरे ऐप में यही लगा है (→ D-068), इसलिए नवरात्रि
# में अलग कुछ नहीं बनाया गया। एक ही पाठ, एक ही स्रोत।
BHOG_MANTRA = {
    "devanagari": "शर्कराखण्डखाद्यानि दधिक्षीरघृतानि च।\n"
                  "आहारं भक्ष्यभोज्यं च नैवेद्यं प्रतिगृह्यताम्॥\n\n"
                  "ॐ प्राणाय स्वाहा। ॐ अपानाय स्वाहा। ॐ व्यानाय स्वाहा।\n"
                  "ॐ उदानाय स्वाहा। ॐ समानाय स्वाहा॥",
    "roman": "sharkara-khanda-khadyani dadhi-kshira-ghritani cha |\n"
             "aharam bhakshya-bhojyam cha naivedyam pratigrihyatam ||\n\n"
             "om pranaya svaha | om apanaya svaha | om vyanaya svaha |\n"
             "om udanaya svaha | om samanaya svaha ||",
    "arth": "पहला श्लोक — मिश्री, खाँड़ और मिठाइयाँ, दही, दूध और घी, और "
            "खाने-पीने की जो भी वस्तुएँ हैं, यह नैवेद्य स्वीकार कीजिए। फिर "
            "पाँच प्राणों के नाम से पाँच बार हाथ से भोग की ओर इशारा किया "
            "जाता है — भाव यह कि भोजन पेट के लिए नहीं, भीतर बसे प्राण के "
            "लिए है।",
    "audio": "",
    "strot": "पहला श्लोक षोडशोपचार पूजन की प्रचलित मंत्रावली का है। पाँच "
             "प्राणों वाला क्रम महानारायण उपनिषद् (= तैत्तिरीय आरण्यक, "
             "प्रपाठक १०) की प्राणाहुति से आता है। ⚠️ उस उपनिषद् के अनुवाकों "
             "की गिनती संस्करण-दर-संस्करण बदलती है, इसलिए यहाँ अनुवाक की "
             "संख्या नहीं लिखी गई।",
    "bharosa": "uncha",
    "vikalp": "बहुत घरों में, ख़ासकर कृष्ण और विष्णु के भोग में, "
              "\"त्वदीयं वस्तु गोविन्द तुभ्यमेव समर्पये। गृहाण सुमुखो भूत्वा "
              "प्रसीद परमेश्वर॥\" भी बोला जाता है। ⚠️ उसका मूल ग्रंथ कहीं दर्ज "
              "नहीं मिलता, इसलिए ऊपर वाला पाठ मुख्य रखा गया है।",
    "sthiti": "draft",
}

# नौ नामों की सूची — यही संक्षिप्त पूजा के "एक साथ स्मरण" वाले कदम पर
# जाती है। इसका पता पक्का है, इसलिए भरोसा **ऊँचा**।
NAAMAVALI_MANTRA = {
    "devanagari": "प्रथमं शैलपुत्री च द्वितीयं ब्रह्मचारिणी।\n"
                  "तृतीयं चन्द्रघण्टेति कूष्माण्डेति चतुर्थकम्॥\n"
                  "पञ्चमं स्कन्दमातेति षष्ठं कात्यायनीति च।\n"
                  "सप्तमं कालरात्रीति महागौरीति चाष्टमम्॥\n"
                  "नवमं सिद्धिदात्री च नवदुर्गाः प्रकीर्तिताः॥",
    "roman": "prathamam shailaputri cha dvitiyam brahmacharini |\n"
             "tritiyam chandraghanteti kushmandeti chaturthakam ||\n"
             "panchamam skandamateti shashtham katyayaniti cha |\n"
             "saptamam kalaratriti mahagauriti chashtamam ||\n"
             "navamam siddhidatri cha navadurgah prakirtitah ||",
    "arth": "पहली शैलपुत्री, दूसरी ब्रह्मचारिणी, तीसरी चन्द्रघंटा, चौथी "
            "कूष्मांडा, पाँचवीं स्कंदमाता, छठी कात्यायनी, सातवीं कालरात्रि, "
            "आठवीं महागौरी और नौवीं सिद्धिदात्री — ये नौ दुर्गा कही गई हैं।",
    "audio": "",
    "strot": "**दुर्गा सप्तशती — देवी कवच, श्लोक ३–५।** नवदुर्गा के नौ नाम "
             "यहीं क्रम से गिनाए गए हैं; नवरात्रि के नौ दिन इसी क्रम पर "
             "चलते हैं।",
    "bharosa": "uncha",
    "vikalp": "हर नाम पर एक फूल या अक्षत अर्पित करने का चलन है। देवी कवच का "
              "पूरा पाठ इससे कहीं लंबा है — यहाँ सिर्फ़ नामावली वाला हिस्सा "
              "लिया गया है।",
    "sthiti": "draft",
}


def mantra(naam: str, roman_naam: str) -> dict:
    """उस दिन की देवी का ध्यान श्लोक + नाम-मंत्र।

    ⚠️ यहाँ कुछ **बनाया** नहीं जाता। श्लोक `DHYAN` से आता है और स्रोत
    उसके साथ लिखा जाता है (→ D-041)। जिस देवी का श्लोक वहाँ नहीं है,
    उसके लिए सिर्फ़ नाम-मंत्र जाता है और भरोसा `kam` रहता है — वह
    ईमानदार कमी है, छिपाई नहीं जाती।
    """
    chaturthi, roman_chaturthi = CHATURTHI.get(
        roman_naam, (naam, roman_naam))
    naam_mantra = f"ॐ देवी {chaturthi} नमः।"
    naam_roman = f"om devi {roman_chaturthi} namah |"

    dhyan = DHYAN.get(roman_naam)
    if dhyan is None:
        return {
            "devanagari": naam_mantra,
            "roman": naam_roman,
            "arth": f"माँ {naam} को नमस्कार।",
            "audio": "",
            "strot": SROT_NAAM + "इस देवी का ध्यान श्लोक अभी नहीं भरा गया।",
            "bharosa": "kam",
            "vikalp": "घर की पद्धति में मिला ध्यान-मंत्र हो तो वही बोलें।",
            "sthiti": "draft",
        }

    shlok, shlok_roman, arth, vikalp = dhyan
    return {
        "devanagari": f"{shlok}\n\n{naam_mantra}",
        "roman": f"{shlok_roman}\n\n{naam_roman}",
        "arth": arth,
        "audio": "",
        "strot": SROT_NAAM + SROT_STOTRA,
        "bharosa": "madhyam",
        "vikalp": f"{BEEJ} {vikalp}",
        "sthiti": "draft",
    }


def samagri(bhog: str) -> list[dict]:
    sab = [
        ("पूजा की चौकी और देवी का चित्र", "1", True, "स्थान", ""),
        ("जल, आचमनी और आसन", "1 सेट", True, "स्थान", ""),
        ("रोली, अक्षत और चंदन", "थोड़े", True, "पूजा की थाली", ""),
        ("लाल या उपलब्ध ताज़े फूल", "कुछ", True, "पूजा की थाली", ""),
        ("घी या तेल का दीपक और माचिस", "1", True, "दीप और धूप", "अखंड ज्योति हो तो उसी की सेवा करें"),
        ("अगरबत्ती या धूप", "1", False, "दीप और धूप", ""),
        (f"भोग — {bhog}", "थोड़ा", True, "भोग", "घर का सात्त्विक विकल्प भी रख सकते हैं"),
        ("कलश और उगे हुए जवारे", "पहले से स्थापित", True, "नवरात्रि", "रोज़ थोड़ा स्वच्छ जल दें"),
    ]
    return [
        {"vastu": v, "matra": m, "ikai": "", "zaruri": z, "samuh": s, "note": n}
        for v, m, z, s, n in sab
    ]


def charan(base: dict, ank: int, devi: str, roman_devi: str, bhog: str) -> list[dict]:
    by_name = {c["shirshak"]: c for c in base["charan"]}
    copy_steps = [
        copy.deepcopy(by_name["आचमन और पवित्रीकरण"]),
        copy.deepcopy(by_name["संकल्प"]),
        copy.deepcopy(by_name["स्वस्तिवाचन"]),
        copy.deepcopy(by_name["गणेश स्मरण"]),
    ]
    steps = [
        {
            "shirshak": "अखंड ज्योति की सेवा",
            "vivaran": "दीपक को स्थिर, हवा से बची और बच्चों की पहुँच से दूर जगह पर देखें। घी कम हो तो धीरे से भरें; जलती ज्योति को अकेला न छोड़ें।",
            "samayMinute": 2,
            "vishesh": "saada",
            "mantra": None,
        },
        *copy_steps,
        {
            "shirshak": "कलश और जवारों का पूजन",
            "vivaran": "कलश को रोली-अक्षत और फूल चढ़ाएँ। जवारों की मिट्टी सूखी लगे तो थोड़ा स्वच्छ जल दें—पानी जमा न होने दें।",
            "samayMinute": 3,
            "vishesh": "saada",
            "mantra": None,
        },
        {
            "shirshak": f"माँ {devi} का ध्यान और पूजन",
            "vivaran": f"माँ {devi} के चित्र के सामने फूल रखें। चंदन या रोली, अक्षत, फूल, धूप और दीप अर्पित करके सरल नाम-मंत्र बोलें।",
            "samayMinute": 5,
            "vishesh": "saada",
            "mantra": mantra(devi, roman_devi),
        },
        {
            "shirshak": "आज का पाठ या जप",
            "vivaran": "अपनी पुस्तक से दुर्गा सप्तशती का नियत अध्याय पढ़ें। पुस्तक या सीखा हुआ पाठ न हो तो देवी का नाम शांत भाव से 11 बार बोलें। बीज-मंत्र गुरु से मिला हो तभी उसका जप करें।",
            "samayMinute": 5,
            "vishesh": "saada",
            "mantra": None,
        },
        {
            "shirshak": f"{bhog} का भोग",
            "vivaran": f"आज परंपरा में {bhog} का भोग मिलता है। उपलब्ध न हो तो घर का सात्त्विक फल या मिठाई आदर से अर्पित करें।",
            "samayMinute": 2,
            "vishesh": "saada",
            "mantra": copy.deepcopy(BHOG_MANTRA),
        },
        copy.deepcopy(by_name["आरती"]),
        copy.deepcopy(by_name["क्षमा प्रार्थना और प्रसाद"]),
    ]
    steps[-2]["paath"] = ["durga_aarti"]
    return steps


def vidhi(base: dict, ank: int, devi: str, roman_devi: str, bhog: str) -> dict:
    steps = charan(base, ank, devi, roman_devi, bhog)
    return {
        "schemaVersion": 1,
        "id": f"navratri_din_{ank}",
        "naam": f"नवरात्रि दिन {ank} — माँ {devi}",
        "upnaam": [f"माँ {devi} पूजा", f"नवरात्रि {ank}"],
        "shreni": "tyohar",
        "scope": "self_guided",
        "parichay": f"शारदीय नवरात्रि के दिन {ank} में माँ {devi} का सरल घरेलू पूजन। कलश, जवारे और अखंड ज्योति की दैनिक सेवा उसी क्रम में चलती रहती है।",
        "kabKarein": {
            "saral": f"आश्विन शुक्ल पक्ष का दिन {ank}, सुबह या घर के नित्य पूजा-समय पर",
            "tithiSuchi": [ank],
            "vaarSuchi": [],
            "note": "ऐप का पर्व-पन्ना आपके शहर के सूर्योदय से सही दिन बताता है। परिवार की पद्धति अलग हो तो वही मानें।",
            "dohrata": False,
            "tarikhKhudChunni": False,
        },
        "samayMinute": sum(c["samayMinute"] for c in steps),
        "kathinai": "aasan",
        "sankalpPurpose": "दुर्गा पूजा",
        "samagri": samagri(bhog),
        "varjya": [],
        "charan": steps,
        "sawaal": [
            {"sawaal": "बताया हुआ भोग न मिले तो?", "jawaab": "वह अनिवार्य नहीं है। घर में उपलब्ध सात्त्विक फल, मिश्री या भोजन का थोड़ा भाग आदर से रखें।"},
            {"sawaal": "अखंड ज्योति रखना ज़रूरी है?", "jawaab": "नहीं। सुरक्षित देखभाल संभव न हो तो पूजा के समय साधारण दीप जलाएँ और बाद में सम्मान से बुझने दें। जलती ज्योति अकेली न छोड़ें।"},
            {"sawaal": "नियत पाठ की पुस्तक न हो तो?", "jawaab": "देवी के नौ नाम या सरल नाम-मंत्र 11 बार श्रद्धा से बोलना पर्याप्त घरेलू विकल्प है। अप्रमाणित पाठ न जोड़ें।"},
        ],
        "strot": {
            "paddhati": "नवदुर्गा की सरल घरेलू पंचोपचार पद्धति",
            "kshetra": "उत्तर भारत में प्रचलित रूप",
            "note": "ध्यान श्लोक श्री नवदुर्गा स्तोत्र से; भोग की पंडित-जाँच बाकी है। क्षेत्र और कुल-परंपरा में क्रम व भोग बदल सकते हैं।",
        },
        "jaanch": {"panditNaam": "", "tarikh": "", "paas": False},
    }


def navami(base: dict) -> dict:
    data = vidhi(base, 9, "सिद्धिदात्री", "siddhidatri", "तिल या घर का सात्त्विक अन्न")
    data["id"] = "navratri_navami_havan"
    data["naam"] = "नवरात्रि नवमी पूजा और सरल हवन"
    data["upnaam"] = ["सिद्धिदात्री पूजा", "नवमी हवन", "नवरात्रि दिन 9"]
    data["kathinai"] = "madhyam"
    havan = {
        "shirshak": "सरल हवन — सुरक्षा पहले",
        "vivaran": "हवन-कुंड को खुली, समतल और बिना ज्वलनशील कपड़े वाली जगह रखें। पानी या अग्निशामक साधन पास रखें और बच्चों को दूर रखें। थोड़ी-थोड़ी हवन सामग्री अर्पित करें; बड़ी अग्नि न बनाएँ। अग्नि-सुरक्षा संभव न हो तो यह चरण छोड़ें और दीपक के सामने प्रार्थना करें। विस्तृत हवन आचार्य के साथ ही करें।",
        "samayMinute": 15,
        "vishesh": "saada",
        "mantra": None,
    }
    data["charan"].insert(-2, havan)
    data["samayMinute"] = sum(c["samayMinute"] for c in data["charan"])
    data["samagri"].extend([
        {"vastu": "छोटा अग्नि-सुरक्षित हवन-कुंड", "matra": "1", "ikai": "", "zaruri": False, "samuh": "हवन", "note": "हवन करना हो तभी"},
        {"vastu": "सूखी समिधा और हवन सामग्री", "matra": "थोड़ी", "ikai": "", "zaruri": False, "samuh": "हवन", "note": "बड़ी अग्नि न बनाएँ"},
        {"vastu": "अग्नि-सुरक्षा के लिए पानी", "matra": "1 बाल्टी", "ikai": "", "zaruri": False, "samuh": "हवन", "note": "हवन करें तो अनिवार्य"},
    ])
    return data


def dashami(base: dict) -> dict:
    by_name = {c["shirshak"]: c for c in base["charan"]}
    steps = [
        copy.deepcopy(by_name["आचमन और पवित्रीकरण"]),
        copy.deepcopy(by_name["संकल्प"]),
        {
            "shirshak": "देवी का अंतिम पूजन",
            "vivaran": "कलश और देवी को रोली, अक्षत और फूल चढ़ाकर नौ दिनों की पूजा स्वीकार करने की प्रार्थना करें।",
            "samayMinute": 5,
            "vishesh": "saada",
            "mantra": None,
        },
        {
            "shirshak": "जवारे निकालना",
            "vivaran": "जवारों को मिट्टी सहित धीरे से निकालें और लाल मौली से बाँधें। कुछ जवारे आशीर्वाद के रूप में घर वालों को दिए जाते हैं; घर का चलन अलग हो तो वही करें।",
            "samayMinute": 5,
            "vishesh": "saada",
            "mantra": None,
        },
        {
            "shirshak": "सम्मानपूर्वक विसर्जन",
            "vivaran": "स्थानीय नियम अनुमति दें तो जवारे स्वच्छ बहते जल में छोड़ें। जल-स्रोत में कपड़ा, प्लास्टिक, धातु या रंग न डालें। अनुमति न हो तो केवल जैविक जवारों और मिट्टी को घर के गमले या पेड़ की मिट्टी में रखें। कलश का जल पौधे में दें।",
            "samayMinute": 8,
            "vishesh": "saada",
            "mantra": None,
        },
        copy.deepcopy(by_name["आरती"]),
        copy.deepcopy(by_name["क्षमा प्रार्थना और प्रसाद"]),
    ]
    steps[-2]["paath"] = ["durga_aarti"]
    return {
        "schemaVersion": 1, "id": "vijayadashami", "naam": "विजयादशमी और जवारे विसर्जन",
        "upnaam": ["दशमी", "दुर्गा विसर्जन", "नवरात्रि दिन 10"], "shreni": "tyohar", "scope": "regional_profile",
        "parichay": "नवरात्रि के कलश और जवारों को सम्मानपूर्वक विदा करने की सरल घरेलू विधि। स्थानीय पर्यावरण और जल-विसर्जन नियमों का पालन सबसे पहले है।",
        "kabKarein": {"saral": "आश्विन शुक्ल दशमी", "tithiSuchi": [10], "vaarSuchi": [], "note": "विसर्जन का समय और तरीका क्षेत्र के अनुसार बदलता है।", "dohrata": False, "tarikhKhudChunni": False},
        "samayMinute": sum(c["samayMinute"] for c in steps), "kathinai": "aasan", "sankalpPurpose": "दुर्गा पूजा",
        "samagri": samagri("घर का सात्त्विक प्रसाद"), "varjya": [], "charan": steps,
        "sawaal": [
            {"sawaal": "नदी में विसर्जन की अनुमति न हो तो?", "jawaab": "जवारों और मिट्टी को गमले या पेड़ की मिट्टी में रखना सम्मानपूर्ण और पर्यावरण-सुरक्षित विकल्प है। पूजा का कपड़ा, प्लास्टिक या धातु जल में न डालें।"},
            {"sawaal": "कलश का जल कहाँ दें?", "jawaab": "स्वच्छ कलश-जल किसी पौधे या पेड़ की जड़ में दें; साबुन या कृत्रिम रंग मिला जल प्रकृति में न डालें।"},
            {"sawaal": "जवारे परिवार में बाँटना ज़रूरी है?", "jawaab": "नहीं। यह स्थानीय परंपरा है; घर की रीति न हो तो सम्मान से मिट्टी में विसर्जित करें।"},
        ],
        "strot": {"paddhati": "सरल घरेलू विसर्जन", "kshetra": "उत्तर भारत में प्रचलित रूप", "note": "क्षेत्र और परिवार के अनुसार अपराजिता पूजन, शमी पूजन और विसर्जन का क्रम अलग हो सकता है; पंडित-जाँच शेष।"},
        "jaanch": {"panditNaam": "", "tarikh": "", "paas": False},
    }


def sankshipt(base: dict) -> dict:
    data = vidhi(base, 1, "दुर्गा", "durga", "फल या घर की बनी मिठाई")
    data["id"] = "navratri_sankshipt"
    data["naam"] = "संक्षिप्त नवरात्रि पूजा"
    data["upnaam"] = ["छोटी नवरात्रि पूजा", "नवदुर्गा पूजन"]
    data["parichay"] = "एक ही बैठक में कलश, नवदुर्गा-स्मरण, भोग, आरती और क्षमा का सरल पूरा क्रम। यह नौ दिन की साधना का विकल्प नहीं, समय कम होने पर घरेलू संक्षिप्त रूप है।"
    data["kabKarein"]["saral"] = "नवरात्रि के किसी भी दिन, घर के सुविधाजनक पूजा-समय पर"
    data["kabKarein"]["tithiSuchi"] = []
    data["charan"][5]["shirshak"] = "कलश या जल-पात्र का पूजन"
    data["charan"][5]["vivaran"] = "स्थापित कलश हो तो उसका पूजन करें। कलश न हो तो स्वच्छ जल का पात्र रखकर रोली, अक्षत और फूल अर्पित करें।"
    data["charan"][6]["shirshak"] = "नवदुर्गा का एक साथ स्मरण"
    data["charan"][6]["vivaran"] = "शैलपुत्री, ब्रह्मचारिणी, चंद्रघंटा, कूष्मांडा, स्कंदमाता, कात्यायनी, कालरात्रि, महागौरी और सिद्धिदात्री—नौ नाम क्रम से बोलकर हर नाम पर एक फूल या अक्षत अर्पित करें।"
    data["charan"][6]["mantra"] = copy.deepcopy(NAAMAVALI_MANTRA)
    data["samayMinute"] = sum(c["samayMinute"] for c in data["charan"])
    return data


def main() -> None:
    base = json.loads((VIDHI / "nitya_pooja.json").read_text(encoding="utf-8"))
    NIRGAM.mkdir(parents=True, exist_ok=True)
    for ank, (devi, roman_devi, bhog) in DEVI.items():
        data = vidhi(base, ank, devi, roman_devi, bhog)
        (NIRGAM / f"navratri_din_{ank}.json").write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    for naam, data in {
        "navratri_sankshipt": sankshipt(base),
        "navratri_navami_havan": navami(base),
        "vijayadashami": dashami(base),
    }.items():
        (NIRGAM / f"{naam}.json").write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


if __name__ == "__main__":
    main()
