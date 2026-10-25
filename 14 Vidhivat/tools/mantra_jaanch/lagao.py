# -*- coding: utf-8 -*-
"""मंत्र-जाँच के फ़ैसले विधियों में (→ D-141)।

  python -P lagao.py dikhao     — हर मंत्र का नया स्रोत-वाक्य और पृष्ठ छापो, कुछ मत लिखो
  python -P lagao.py likho      — app/assets/vidhi/**.json में लिखो

हर खाना उसी पुराने पाठ से पहचाना जाता है (NFC, खाली-जगह एक) जो suchi.json में है।
"""
import glob
import io
import json
import os
import re
import sys
import unicodedata

sys.stdout.reconfigure(encoding='utf-8')
JAD = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, JAD)
import bahi2  # noqa: E402,F401  (BAHI भरता है)
import khoj  # noqa: E402
import prishth  # noqa: E402
from bahi import BAHI  # noqa: E402

VIDHI = os.path.join(JAD, '..', '..', 'app', 'assets', 'vidhi')

# M31 — धर्मसिंधु की जन्माष्टमी-पूजा का आवाहन-वाक्य मिला, तो ख़ाली नहीं (n87, आँख से)
BAHI['M31'] = dict(faisla='saancha', gawah=[('ds', 87, '«श्रीकृष्णाय नमः श्रीकृष्णमावाहयामि»'),
                                           ('kkp', 366, '«श्रीकृष्णाय नमः»'), ('nkpp', 250, '«…मावाहयामि»')],
                   note='कृष्णाष्टक का ध्यान-श्लोक किसी छपी किताब के OCR में नहीं मिला — उसकी जगह धर्मसिंधु का आवाहन-वाक्य।')
# पूरे पाठ में एक-दो शब्द किसी गवाह में अलग — «अक्षरशः» नहीं कहना
APPROX = {'M06', 'M21', 'M60'}
# गवाह सिर्फ़ ऐप का अपना पहले से जँचा ग्रंथ — पुराना स्रोत-वाक्य ही ठीक
PURANA_STROT = {'M10', 'M51', 'M41'}
# सुधार हुआ, पर अब ये नाम-मंत्र हैं — स्रोत-वाक्य उसी ढंग का
NAAM_STYLE = {'M11', 'M13', 'M28', 'M46', 'M61'}

NAAM = {
    'nkpp': 'नित्यकर्म-पूजाप्रकाश (गीताप्रेस)',
    'kkp': 'कर्मकाण्ड-प्रदीप (लोकनाथ आचार्य)',
    'ppp': 'प्रभु पूजा पद्धति (प्रभुदत्त ब्रह्मचारी)',
    'vp': 'व्रत-परिचय (गीताप्रेस)',
    'ds': 'धर्मसिंधु',
    'ns': 'निर्णयसिंधु',
    'dsg': 'दुर्गासप्तशती (गीताप्रेस)',
    'sr': 'स्तोत्ररत्नावली (गीताप्रेस)',
    'bsr': 'बृहत्स्तोत्ररत्नाकर',
    'yv': 'शुक्ल यजुर्वेद संहिता',
    'rv': 'ऋग्वेद संहिता (सातवलेकर)',
    'ntp': 'नित्यकर्म विधि तथा देवपूजा पद्धति (माया प्रसाद शास्त्री)',
    'nkk': 'देवपूजा पद्धति (कृष्णानन्द शास्त्री)',
    'kb': 'कर्मकाण्ड भास्कर',
    'dpv': 'दुर्गापूजन पद्धति (वेणीराम शर्मा गौड़)',
    'dpp': 'दुर्गासप्तशती पूजा पद्धति (बाबूराम वशिष्ठ)',
    'gps': 'संक्षिप्त गरुडपुराण (गीताप्रेस)',
    'gpk': 'गरुड महापुराण (खेमराज श्रीकृष्णदास, मुंबई)',
    'app_saptashati': 'ऐप का दुर्गासप्तशती-पाठ, जो चार छपी प्रतियों से मिलाकर बना है',
    'app_gita': 'ऐप का गीता-पाठ, जो छपी प्रतियों से मिलाकर बना है',
    'app_upanishad': 'ऐप का उपनिषद-पाठ, जो छपी प्रतियों से मिलाकर बना है',
}

# ग्रंथ में मंत्र कहाँ का है — सिर्फ़ जो छपे पन्ने पर दिखा
MOOL = {
    'M01': 'शुक्ल यजुर्वेद, अध्याय २५ («आ नो भद्राः» — २५.१४) का शान्ति-पाठ',
    'M02': 'शुक्ल यजुर्वेद का गणपति-आवाहन मंत्र',
    'M10': 'श्रीमद्भगवद्गीता ४.२४',
    'M12': 'दुर्गासप्तशती, नारायणी-स्तुति',
    'M15': 'बिल्वाष्टक',
    'M16': 'शिवापराधक्षमापन स्तोत्र, श्लोक १४ (यही शिवमानसपूजा के अंत में भी)',
    'M18': 'नवग्रहस्तोत्र, श्लोक १',
    'M26': 'ऋग्वेद ७.५४.१',
    'M27': 'रामरक्षा स्तोत्र, श्लोक ३३',
    'M30': 'नवग्रहस्तोत्र, श्लोक २',
    'M40': 'दुर्गासप्तशती — देवी-कवच, श्लोक ३–५',
    'M44': 'रक्षाबन्धन का मंत्र',
    'M51': 'कठ, तैत्तिरीय और श्वेताश्वतर उपनिषद का शान्ति-पाठ',
    'M63': 'ऋग्वेद १०.८१.७; शुक्ल यजुर्वेद ८.४५',
    'M57': 'गरुडपुराण, आचारकाण्ड ८९.३२ — रुचिकृत पितृस्तोत्र',
}

# यूज़र के काम का छोटा पाठ-भेद — ⓘ में
BHED = {
    'M01': 'कर्मकाण्ड-प्रदीप में शुक्ल यजुर्वेद की लिखावट है («ऽअपरीतास», «नऽइन्द्रो») — शब्द वही।',
    'M02': 'छपी पद्धतियों में «गणपतिं» का अनुस्वार वैदिक चिह्न से छपा है — उच्चारण «गणपतिगुँ» जैसा।',
    'M03': 'आगे के नाम परंपरा से बदलते हैं — कर्मकाण्ड-प्रदीप में गोविन्द और विष्णु से हाथ धोना, मधुसूदन और त्रिविक्रम से होंठ पोंछना।',
    'M04': 'कृष्णानन्द शास्त्री की पद्धति में «सुस्थितो भव» छपा है।',
    'M05': 'प्राणाहुति का क्रम पद्धति-दर-पद्धति थोड़ा बदलता है।',
    'M06': 'पंक्तियाँ पद्धति-दर-पद्धति थोड़ी बदलती हैं — प्रभु पूजा पद्धति में «क्षमस्व परमेश्वर»; शिव-पूजा में «…भक्तिहीनं सुरेश्वर। यत्पूजितं महादेव…»।',
    'M08': 'दुर्गापूजन पद्धति में «पूजामादाय मामिकाम्»।',
    'M12': 'नित्यकर्म-पूजाप्रकाश में «सर्वमङ्गलमङ्गल्ये» छपा है।',
    'M15': 'नित्यकर्म-पूजाप्रकाश और कृष्णानन्द शास्त्री की पद्धति में «त्रिधायुतम्» छपा है।',
    'M17': 'यही आवाहन प्रभु पूजा पद्धति और कृष्णानन्द शास्त्री की पद्धति में पुल्लिंग में है — «आगच्छ भगवन् देव… स्थिरो भव»।',
    'M18': 'नित्यकर्म-पूजाप्रकाश के सूर्य-आवाहन में अंतिम चरण «सूर्यमावाहयाम्यहम्»।',
    'M20': 'व्रत-परिचय में पहली पंक्ति «मृत्युना दण्डपाशाभ्यां…» — शब्द वही, क्रम उलटा।',
    'M26': 'संधि की लिखावट अलग-अलग छपी है («अस्मान्त्स्वावेशो», «शन्नो») — शब्द वही।',
    'M30': 'बृहत्स्तोत्ररत्नाकर में «क्षीरार्णवसमुद्भवम्»।',
    'M39': 'दुर्गासप्तशती पूजा पद्धति में «सिद्धिदायै नमः» छपा है।',
    'M43': 'नित्यकर्म-पूजाप्रकाश में क्रम प्राण, अपान, समान, उदान, व्यान।',
    'M48': 'कृष्णानन्द शास्त्री की पद्धति में «शर्करायुतम्»।',
    'M56': 'कृष्णानन्द शास्त्री की पद्धति में «स्वाहायै स्वधायै» — क्रम उलटा।',
    'M60': 'दूसरी पंक्ति पद्धति-दर-पद्धति बदलती है — «तानि सर्वाणि नश्यन्तु…» (नित्यकर्म-पूजाप्रकाश), «…प्रणश्यन्ति…» (दुर्गापूजन पद्धति), «…प्रदक्षिणया पदे पदे» (प्रभु पूजा पद्धति)।',
}

NAIV = 'नैवेद्यं गृह्यतां देव भक्तिं मे ह्यचलां कुरु।\nईप्सितं मे वरं देहि परत्र च परां गतिम्॥'
NAIV_R = 'naivedyam grihyatam deva bhaktim me hy achalam kuru |\nipsitam me varam dehi paratra cha param gatim ||'
NAIV_A = 'हे देव, यह नैवेद्य स्वीकार कीजिए और मेरी भक्ति को अटल कर दीजिए; मुझे इच्छित वर दीजिए, और आगे उत्तम गति।'
PRANA = 'ॐ प्राणाय स्वाहा। ॐ अपानाय स्वाहा। ॐ व्यानाय स्वाहा।\nॐ उदानाय स्वाहा। ॐ समानाय स्वाहा॥'
PRANA_R = 'om pranaya svaha | om apanaya svaha | om vyanaya svaha |\nom udanaya svaha | om samanaya svaha ||'
NAIV_STROT = ('नैवेद्य का श्लोक कर्मकाण्ड-प्रदीप (लोकनाथ आचार्य) में अक्षरशः; पहली पंक्ति देवपूजा पद्धति (कृष्णानन्द शास्त्री){p_nkk} में, '
              'दूसरी नित्यकर्म विधि तथा देवपूजा पद्धति (माया प्रसाद शास्त्री){p_ntp} में भी।')
PRANA_STROT = 'प्राणाहुति का यही क्रम व्रत-परिचय (गीताप्रेस){p_vp} और कर्मकाण्ड-प्रदीप में।'

NAYA = {
    'M02': dict(
        devanagari='ॐ गणानां त्वा गणपतिं हवामहे\nप्रियाणां त्वा प्रियपतिं हवामहे\nनिधीनां त्वा निधिपतिं हवामहे वसो मम।\n'
                   'आहमजानि गर्भधमा त्वमजासि गर्भधम्॥',
        roman='om gananam tva ganapatim havamahe\npriyanam tva priyapatim havamahe\nnidhinam tva nidhipatim havamahe vaso mama |\n'
              'aham ajani garbhadham a tvam ajasi garbhadham ||',
        arth='गणों के स्वामी (गणपति) को हम बुलाते हैं, प्रियजनों के स्वामी को बुलाते हैं, निधियों के स्वामी को बुलाते हैं — हे वसु '
             '(सबके आश्रय), आप मेरे हों। आख़िरी पंक्ति यज्ञ-प्रसंग की है; उसका अर्थ भाष्यों में अलग-अलग किया गया है, इसलिए यहाँ '
             'नहीं लिखा।',
        vikalp='यह वैदिक आवाहन मंत्र है; छपी पद्धतियाँ इसे पूरा देती हैं। बहुत से घरों में इसकी जगह कोई सरल श्लोक बोला जाता है — '
               'घर की पद्धति जो हो।'),
    'M05': dict(devanagari=NAIV + '\n\n' + PRANA, roman=NAIV_R + '\n\n' + PRANA_R,
                arth='पहला श्लोक — ' + NAIV_A + ' फिर पाँच प्राणों के नाम से पाँच बार हाथ से भोग की ओर इशारा किया जाता है — भाव '
                     'यह कि भोजन भीतर बसे प्राण के लिए है।',
                vikalp='जिस घर में भोग के समय कोई दूसरा श्लोक बोला जाता हो, वहाँ वही सही है।',
                strot_extra=NAIV_STROT + ' ' + PRANA_STROT),
    'M14': dict(devanagari=NAIV, roman=NAIV_R, arth=NAIV_A,
                vikalp='जिस घर में भोग के समय कोई दूसरा श्लोक बोला जाता हो, वहाँ वही सही है।',
                strot_extra=NAIV_STROT),
    'M24': dict(devanagari='ॐ अमृतोपस्तरणमसि स्वाहा।\n\n' + NAIV + '\n\n' + PRANA + '\n\nॐ अमृतापिधानमसि स्वाहा।',
                roman='om amritopastaranam asi svaha |\n\n' + NAIV_R + '\n\n' + PRANA_R + '\n\nom amritapidhanam asi svaha |',
                arth='पहले थाली के चारों ओर जल की धार से घेरा बनाते हुए — "तुम अमृत का बिछौना हो"। फिर नैवेद्य का श्लोक — ' + NAIV_A +
                     ' फिर पाँच प्राणों के नाम से पाँच बार हाथ से भोग की ओर इशारा। अंत में उल्टी दिशा में घेरा बनाते हुए — "तुम अमृत '
                     'का ढक्कन हो"।',
                vikalp='जल का घेरा बनाने की रीति घर-घर थोड़ी अलग है। जिस घर में भोग के समय कोई दूसरा श्लोक बोला जाता हो, वहाँ वही सही है।',
                strot_extra='«…मसि स्वाहा» वाली दोनों पंक्तियाँ नित्यकर्म-पूजाप्रकाश (गीताप्रेस){p_nkpp206} और कर्मकाण्ड-प्रदीप में। ' +
                            NAIV_STROT),
    'M11': dict(devanagari='ॐ श्रियै नमः॥', roman='om shriyai namah ||',
                arth='श्री (लक्ष्मी) को नमस्कार। हर उपचार अर्पित करते समय यही नाम-मंत्र बोला जाता है।',
                vikalp='श्रीसूक्त इस पूजा का बड़ा पाठ है — वह ऐप में है: अधिक → ग्रंथालय → वेद के सूक्त।'),
    'M13': dict(devanagari='ॐ सूर्याय नमः। ॐ आदित्याय नमः॥', roman='om suryaya namah | om adityaya namah ||',
                arth='सूर्य को नमस्कार, आदित्य को नमस्कार। यही जपते हुए अर्घ्य दिया जाता है।',
                vikalp='छठ मूल रूप से **गीतों का पर्व** है — अर्घ्य के समय छठी मैया के लोकगीत गाए जाते हैं, जो हर घर और क्षेत्र के अपने होते हैं।'),
    'M20': dict(devanagari='मृत्युना पाशदण्डाभ्यां कालेन श्यामया सह।\nत्रयोदश्यां दीपदानात् सूर्यजः प्रीयतां मम॥',
                roman='mrityuna pashadandabhyam kalena shyamaya saha |\ntrayodashyam dipadanat suryajah priyatam mama ||',
                arth='मृत्यु, पाश, दण्ड, काल और श्यामा के साथ सूर्यपुत्र यमराज — त्रयोदशी के इस दीपदान से मुझ पर प्रसन्न हों।',
                vikalp='यह दीपक घर के मुख्य द्वार के बाहर, दक्षिण दिशा की ओर रखा जाता है।'),
    'M21': dict(devanagari='गङ्गासरस्वतीरेवापयोष्णीनर्मदाजलैः।\nस्नापितोऽसि मया देव तथा शान्तिं कुरुष्व मे॥\n\n'
                           'सर्वभूषाधिके सौम्ये लोकलज्जानिवारणे।\nमयोपपादिते तुभ्यं वाससी प्रतिगृह्यताम्॥',
                roman='ganga-sarasvati-reva-payoshni-narmada-jalaih |\nsnapito\'si maya deva tatha shantim kurushva me ||\n\n'
                      'sarva-bhushadhike saumye loka-lajja-nivarane |\nmayopapadite tubhyam vasasi pratigrihyatam ||',
                arth='गंगा, सरस्वती, रेवा, पयोष्णी और नर्मदा के जल से मैंने आपको स्नान कराया है — वैसे ही मुझे भी शान्ति दीजिए। सब '
                     'आभूषणों में श्रेष्ठ, सुंदर और लोक-लज्जा ढकने वाले ये दो वस्त्र मैंने आपके लिए जुटाए हैं — स्वीकार कीजिए।',
                vikalp='मौली को वस्त्र के रूप में अर्पित करने का चलन है।'),
    'M28': dict(devanagari='ॐ हनुमते नमः।', roman='om hanumate namah |',
                arth='हनुमान जी का सरल नाम-मंत्र। हर उपचार अर्पित करते समय यही बोला जाता है — "यह मैं आपको समर्पित कर रहा हूँ" के भाव से।',
                vikalp='कर्मकाण्ड भास्कर में «ॐ श्रीहनुमते नमः» छपा है — दोनों चलते हैं।'),
    'M31': dict(devanagari='ॐ श्रीकृष्णाय नमः। श्रीकृष्णमावाहयामि॥', roman='om shri-krishnaya namah | shri-krishnam avahayami ||',
                arth='श्रीकृष्ण को नमस्कार — मैं श्रीकृष्ण का आवाहन करता/करती हूँ (उन्हें पूजा में बुलाता/बुलाती हूँ)।',
                vikalp='आवाहन के बाद हाथ के फूल-अक्षत मूर्ति या तस्वीर पर चढ़ा दिए जाते हैं। पूजा के अंत में इसी का जोड़ा **विसर्जन** है — '
                       'बुलाया है तो विदा भी करना होता है।',
                gawah=[('ds', 87, ''), ('kkp', 366, ''), ('nkpp', 250, '')],
                strot_extra='धर्मसिंधु की जन्माष्टमी-पूजा में यही वाक्य — «श्रीकृष्णाय नमः श्रीकृष्णमावाहयामि»{p_ds87}; «…मावाहयामि» वाला '
                            'आवाहन-वाक्य नित्यकर्म-पूजाप्रकाश में भी।'),
    'M45': dict(devanagari='आगच्छ भगवन् देव स्थाने चात्र स्थिरो भव।\nयावत्पूजां करिष्यामि तावत्त्वं सन्निधौ भव॥',
                roman='agachchha bhagavan deva sthane chatra sthiro bhava |\nyavat pujam karishyami tavat tvam sannidhau bhava ||',
                arth='हे भगवन्, पधारिए और यहाँ इस स्थान पर स्थिर होइए; जब तक मैं पूजा करूँ, तब तक आप यहीं विराजिए।',
                vikalp='आवाहन के बाद हाथ के फूल-अक्षत मूर्ति या तस्वीर पर चढ़ा दिए जाते हैं। पूजा के अंत में इसी का जोड़ा **विसर्जन** है — '
                       'बुलाया है तो विदा भी करना होता है।'),
    'M46': dict(devanagari='ॐ श्रीरामाय नमः।', roman='om shri-ramaya namah |',
                arth='राम जी का सरल नाम-मंत्र। हर उपचार अर्पित करते समय यही बोला जाता है।', vikalp=''),
    'M61': dict(devanagari='ॐ श्रियै नमः॥', roman='om shriyai namah ||',
                arth='श्री (लक्ष्मी) को नमस्कार — वरलक्ष्मी लक्ष्मी का ही रूप हैं।', vikalp=''),
}

KHAALI = {
    'M23': 'गोवर्धन-पूजन का नाम-मंत्र किसी छपी पूजा-पद्धति में नहीं मिला। प्रार्थना का श्लोक («गोवर्धन धराधार…») व्रत-परिचय '
           'और निर्णयसिंधु दोनों में है, पर दोनों में अलग पाठ में छपा है — इसलिए यहाँ नहीं दिया। गोबर से गोवर्धन की आकृति बनाकर '
           'उस पर फूल, अक्षत और दीप रखकर पूजा की जाती है, फिर परिक्रमा होती है।',
    'M62': 'परिक्रमा की प्रार्थना का श्लोक व्रत-परिचय और निर्णयसिंधु में अलग-अलग पाठ में छपा है, और यहाँ पहले वाला रूप किसी छपी '
           'पुस्तक में नहीं मिला — इसलिए कोई श्लोक नहीं दिया। परिक्रमा करते हुए हर चक्कर पर कच्चा सूत लपेटा जाता है; संख्या क्षेत्र '
           'और परिवार से बदलती है।',
}

# कदम का विवरण भी बदलता है (उसमें पुराना मंत्र या उसका दावा था)
VIVARAN = {
    ('varalakshmi_vrat.json', 9): ('मंत्र जपें — एक सौ आठ बार जपने का चलन है।', 'नीचे दिया नाम-मंत्र जपें।'),
}
CHETAVNI = {}   # M57 वापस भरा (25 अक्टू) — श्राद्ध की सावधानी HEAD वाली ही

NAVRATRI_GENERATOR = {'M33', 'M34', 'M35', 'M36', 'M37', 'M38', 'M39'}   # ये tools/banao_navratri_din.py से बनते हैं


def saaf(s):
    return re.sub(r'\s+', ' ', unicodedata.normalize('NFC', s or '')).strip()


def ank(s):
    m = re.search(r'[०-९0-9]{1,4}', s or '')
    if not m:
        return ''
    return m.group().translate(str.maketrans('०१२३४५६७८९', '0123456789'))


_nkpp = None


_panne = {}


def _upar(k, n):
    """पन्ने की ऊपरी पट्टी (OCR) — पृष्ठ-अंक वहीं छपा होता है।"""
    if k not in _panne:
        _panne[k] = khoj.panne(k)
    t = _panne[k][n].strip()
    return (t[:90] + ' ' + t[-40:]).translate(str.maketrans('०१२३४५६७८९', '0123456789'))


def prishth_ank(k, n):
    """छपा पृष्ठ — सिर्फ़ तब, जब वही अंक उस पन्ने के सिरे पर सचमुच छपा दिखे; वरना ख़ाली।"""
    if k.startswith('app_') or k == 'kkp':
        return ''
    upar = _upar(k, n)
    if k == 'nkpp':
        for m in re.finditer(r'\d{2,3}', upar):
            if 5 <= n - int(m.group()) <= 12:
                return m.group()
        return ''
    p = ank(prishth.prishth(k, n))
    return p if p and re.search(r'(?<!\d)%s(?!\d)' % p, upar) else ''


def gawah_vakya(gawah):
    """एक किताब एक बार — उसके सब पृष्ठ साथ।"""
    kram, pg = [], {}
    for k, n, _ in gawah:
        if k not in kram:
            kram.append(k)
        p = prishth_ank(k, n)
        if p and p not in pg.setdefault(k, []):
            pg[k].append(p)
    out = []
    for k in kram:
        s = NAAM[k]
        if pg.get(k):
            s += ', पृ. ' + ', '.join(pg[k])
        out.append(s)
    return '; '.join(out)


def strot_banao(mid, e):
    f = e['faisla']
    gawah = NAYA.get(mid, {}).get('gawah') or e['gawah']
    shuru = (MOOL[mid] + '। ') if mid in MOOL else ''
    if f == 'naam' or mid in NAAM_STYLE:
        return shuru + 'देवता का नाम-मंत्र — यही नाम पूजा में इसी रूप में: ' + gawah_vakya(gawah) + '।'
    if f == 'saancha':
        return shuru + 'पूजा-वाक्य का साँचा (नाम + «नमः / आवाहयामि / समर्पयामि») — इसी ढंग से: ' + gawah_vakya(gawah) + '।' + \
            ((' ' + BHED[mid]) if mid in BHED else '')
    extra = NAYA.get(mid, {}).get('strot_extra')
    if extra:
        fill = {
            'p_nkk': ', पृ. ' + prishth_ank('nkk', 93),
            'p_ntp': ', पृ. ' + prishth_ank('ntp', 140),
            'p_vp': ', पृ. ' + prishth_ank('vp', 321),
            'p_nkpp206': ', पृ. ' + prishth_ank('nkpp', 206),
            'p_ds87': ' (पृ. ' + prishth_ank('ds', 87) + ')',
        }
        fill = {k: ('' if v.strip(' ,()पृ.') == '' else v) for k, v in fill.items()}
        return shuru + extra.format(**fill) + ((' ' + BHED[mid]) if mid in BHED else '')
    kaise = 'छपी पुस्तकों में, थोड़े पाठ-भेद के साथ: ' if mid in APPROX else 'छपी पुस्तकों में अक्षरशः: '
    return shuru + kaise + gawah_vakya(gawah) + '।' + ((' ' + BHED[mid]) if mid in BHED else '')


def naya_mantra(mid, purana):
    e = BAHI[mid]
    m = dict(purana)
    if e['faisla'] == 'khaali':
        m.update(devanagari='', roman='', arth='', strot='', bharosa='kam', vikalp=KHAALI[mid], sthiti='khaali')
        return m
    if mid in NAYA:
        for k in ('devanagari', 'roman', 'arth', 'vikalp'):
            if k in NAYA[mid]:
                m[k] = NAYA[mid][k]
    if mid in PURANA_STROT:
        m['bharosa'] = 'uncha'
        return m      # ग्रंथ (गीता, उपनिषद) या D-118 — स्रोत-वाक्य पहले से जँचा हुआ
    m['strot'] = strot_banao(mid, e)
    m['bharosa'] = 'madhyam' if mid == 'M17' else 'uncha'
    m['sthiti'] = 'draft'
    return m


def main():
    karya = sys.argv[1] if len(sys.argv) > 1 else 'dikhao'
    suchi = json.load(io.open(os.path.join(JAD, 'suchi_24oct.json'), encoding='utf-8'))
    paath_se = {m['paath']: m['id'] for m in suchi}
    if karya == 'dikhao':
        for m in suchi:
            mid = m['id']
            e = BAHI[mid]
            if e['faisla'] == 'khaali':
                print(mid, 'ख़ाली —', KHAALI[mid][:90])
                continue
            s = strot_banao(mid, e) if mid not in PURANA_STROT else '(वैसा ही)'
            print(mid, e['faisla'], len(s), '|', s)
        return
    badle = 0
    for path in sorted(glob.glob(os.path.join(VIDHI, '**', '*.json'), recursive=True)):
        if os.path.basename(path).startswith('_'):
            continue
        rel = os.path.relpath(path, VIDHI).replace('\\', '/')
        raw = io.open(path, encoding='utf-8', newline='').read()
        nl = '\r\n' if '\r\n' in raw else '\n'
        indent = len(re.search(r'\n( +)"', raw).group(1))
        v = json.loads(raw)
        chhua = False
        for i, c in enumerate(v.get('charan', [])):
            m = c.get('mantra')
            if not m or not m.get('devanagari'):
                continue
            mid = paath_se.get(saaf(m['devanagari']))
            if mid is None:
                print('⚠ पहचान नहीं:', rel, i + 1)
                continue
            if rel.startswith('navratri/') and mid in NAVRATRI_GENERATOR:
                continue
            naya = naya_mantra(mid, m)
            if naya != m:
                c['mantra'] = naya
                chhua = True
                badle += 1
            key = (os.path.basename(rel), i + 1)
            if key in VIVARAN:
                a, b = VIVARAN[key]
                assert a in c['vivaran'], (key, 'विवरण')
                c['vivaran'] = c['vivaran'].replace(a, b)
            if key in CHETAVNI:
                a, b = CHETAVNI[key]
                assert a in c['mantra'].get('chetavni', ''), (key, 'चेतावनी')
                c['mantra']['chetavni'] = c['mantra']['chetavni'].replace(a, b)
        if chhua:
            out = json.dumps(v, ensure_ascii=False, indent=indent).replace('\n', nl)
            if raw.endswith(('\n', '\r\n')):
                out += nl
            io.open(path, 'w', encoding='utf-8', newline='').write(out)
    print('बदले खाने:', badle)


if __name__ == '__main__':
    main()
