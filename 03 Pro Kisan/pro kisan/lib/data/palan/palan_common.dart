/// हर पालन पर लागू होने वाली बातें — योजनाएँ, आम ग़लतियाँ, ख़रीदने की जगहें।
///
/// पहले ऐप में **सरकारी मदद का एक शब्द भी नहीं था**। किसान के पास पूँजी नहीं
/// होती — यही जानकारी उसे धंधा शुरू करवा सकती है, इसलिए हर गाइड में दिखेगी।
///
/// ⚠️ योजनाओं की शर्तें बदलती रहती हैं — इसीलिए हर जगह "अपने ब्लॉक/बैंक से
/// पुष्टि कीजिए" लिखा है, और नीचे तारीख़ भी दी है।
library;

import 'palan_model.dart';

/// जानकारी किस तारीख़ तक की जाँची हुई है
const String kSchemeAsOf = 'अगस्त 2026';

/// सब पालन पर लागू सरकारी मदद
const List<L> kCommonSchemes = [
  (
    hi: '🏛️ राष्ट्रीय पशुधन मिशन (NLM) — बकरी/भेड़ फ़ार्म पर ₹50 लाख तक, '
        'मुर्गी पर ₹25 लाख तक और सुअर पर ₹30 लाख तक **50% अनुदान**। '
        'आवेदन nlm.udyamimitra.in पर। पहले बैंक से लोन मंज़ूर होता है, फिर '
        'सरकार आधी रकम दो किस्तों में बैंक को देती है।',
    en: '🏛️ National Livestock Mission (NLM) — 50% capital subsidy: up to ₹50 lakh '
        'for goat/sheep farms, ₹25 lakh for poultry, ₹30 lakh for piggery. '
        'Apply at nlm.udyamimitra.in. The bank sanctions a term loan first; the '
        'government then releases half the project cost in two instalments.',
  ),
  (
    hi: '💳 पशु किसान क्रेडिट कार्ड (KCC) — ₹1.60 लाख तक **बिना गारंटी**, '
        'कुल सीमा ₹3 लाख। समय पर चुकाने पर ब्याज सिर्फ़ **4%** पड़ता है। '
        'चुकाने की अवधि 5 साल। अपने बैंक की शाखा में आवेदन कीजिए।',
    en: '💳 Pashu Kisan Credit Card (KCC) — up to ₹1.60 lakh **without collateral**, '
        'overall limit ₹3 lakh. Effective interest just **4%** if repaid on time. '
        '5-year repayment. Apply at your bank branch.',
  ),
  (
    hi: '🛡️ पशुधन बीमा — जानवर मरने पर भरपाई। प्रीमियम का बड़ा हिस्सा सरकार '
        'देती है (छोटे किसान के लिए और भी ज़्यादा)। बिना बीमा एक मौत पूरे साल '
        'का मुनाफ़ा खा जाती है।',
    en: '🛡️ Livestock insurance — compensation if an animal dies. Government pays '
        'most of the premium (more for small farmers). Without it, one death can '
        'wipe out a whole year of profit.',
  ),
  (
    hi: '👥 स्वयं सहायता समूह (SHG) / FPO — अकेले से समूह बनाकर लेने पर लोन '
        'आसान मिलता है, और NLM में समूह को भी अनुदान मिलता है।',
    en: '👥 Self-Help Groups / FPOs — loans are easier as a group, and NLM subsidy '
        'is available to groups too.',
  ),
  (
    hi: '📞 अपने ब्लॉक के **पशु चिकित्सा अधिकारी** या **KVK** से मिलिए — '
        'राज्य की अपनी योजनाएँ अलग होती हैं और वही सबसे सही जानकारी देंगे।',
    en: '📞 Meet your block **Veterinary Officer** or **KVK** — states run their own '
        'schemes and they have the most accurate details.',
  ),
];

/// हर पालन में होने वाली आम ग़लतियाँ
const List<L> kCommonMistakes = [
  (
    hi: '❌ **बाज़ार देखे बिना शुरू करना** — पहले पता कीजिए कि आपका माल कौन, '
        'कहाँ और किस दाम पर ख़रीदेगा। पालना आसान है, बेचना मुश्किल।',
    en: '❌ **Starting without a market** — first find out who will buy, where and at '
        'what price. Rearing is easy; selling is hard.',
  ),
  (
    hi: '❌ **एक साथ बहुत बड़े पैमाने पर शुरू करना** — पहले छोटी संख्या से '
        '6 महीने सीखिए, फिर बढ़ाइए। सबसे ज़्यादा नुक़सान यहीं होता है।',
    en: '❌ **Starting too big** — learn with a small number for 6 months, then scale. '
        'This is where most money is lost.',
  ),
  (
    hi: '❌ **जगह में ठूँस देना** — भीड़ से बीमारी फैलती है और बढ़त रुक जाती है। '
        'गाइड में लिखी जगह से कम कभी मत दीजिए।',
    en: '❌ **Overcrowding** — disease spreads and growth stops. Never give less space '
        'than this guide states.',
  ),
  (
    hi: '❌ **टीका या कीड़े की दवा छोड़ देना** — यह सबसे सस्ता ख़र्च है और सबसे '
        'बड़ा बचाव। एक बीमारी पूरे झुंड को ले जाती है।',
    en: '❌ **Skipping vaccines or deworming** — the cheapest cost and the biggest '
        'protection. One outbreak can take the whole flock.',
  ),
  (
    hi: '❌ **नया जानवर सीधे झुंड में मिला देना** — 2-3 हफ़्ते अलग रखिए '
        '(क्वारंटीन), वरना वह अपने साथ बीमारी लाता है।',
    en: '❌ **Mixing new animals straight in** — keep them separate for 2-3 weeks, '
        'else they bring disease with them.',
  ),
  (
    hi: '❌ **हिसाब न रखना** — कितना दाना गया, कितना बिका, कौन बीमार हुआ — '
        'लिखे बिना पता ही नहीं चलता कि मुनाफ़ा है या घाटा।',
    en: '❌ **Not keeping records** — feed used, sales made, who fell sick. Without '
        'records you cannot tell profit from loss.',
  ),
];

/// अच्छी नस्ल कहाँ से मिलेगी — ठगी यहीं होती है
const List<L> kCommonWhereToBuy = [
  (
    hi: '🏫 **कृषि विज्ञान केंद्र (KVK)** — हर ज़िले में है। सही नस्ल, सही दाम '
        'और मुफ़्त सलाह — सबसे भरोसेमंद जगह।',
    en: '🏫 **Krishi Vigyan Kendra (KVK)** — one in every district. Right breed, fair '
        'price and free advice — the most trustworthy source.',
  ),
  (
    hi: '🏛️ **सरकारी पशु प्रजनन फ़ार्म** और ICAR संस्थान — शुद्ध नस्ल के लिए '
        'सबसे अच्छे। पहले फ़ोन करके उपलब्धता पूछ लीजिए।',
    en: '🏛️ **Government breeding farms** and ICAR institutes — best for pure breeds. '
        'Call ahead to check availability.',
  ),
  (
    hi: '👨‍🌾 **अपने इलाक़े का पुराना, सफल पालक** — उसी के यहाँ से लीजिए। जानवर '
        'उसी मौसम-पानी का आदी होगा, इसलिए कम बीमार पड़ेगा।',
    en: '👨‍🌾 **An established local farmer** — animals already suited to your climate '
        'and water fall sick less often.',
  ),
  (
    hi: '⚠️ **इनसे बचिए:** जो कहे "हम आपका माल वापस ख़रीद लेंगे" और महँगे बच्चे '
        'बेचे — यही सबसे आम ठगी है। लिखित समझौते के बिना कभी पैसा मत दीजिए।',
    en: '⚠️ **Avoid:** anyone selling costly stock with a "we will buy back your '
        'produce" promise — the commonest scam. Never pay without a written contract.',
  ),
  (
    hi: '⚠️ ख़रीदने से पहले जानवर की **उम्र, दाँत, वज़न और टीके का रिकॉर्ड** ज़रूर '
        'देखिए। बीमार दिखे तो चाहे कितना सस्ता हो, मत लीजिए।',
    en: '⚠️ Before buying, check **age, teeth, weight and vaccination record**. If it '
        'looks sick, walk away no matter how cheap.',
  ),
];
