/// पूजा विधि का ढाँचा — **ऐप का दिल** (→ D-002)।
///
/// हर पूजा एक JSON फ़ाइल है, `assets/vidhi/` में। यह फ़ाइल उस JSON को
/// पढ़कर Dart की चीज़ों में बदलती है, और साथ में **जाँचती भी है** कि
/// ढाँचा सही है।
///
/// ## दो नियम जो यह फ़ाइल ज़बरदस्ती लगवाती है
///
/// **1. मंत्र बिना स्रोत के "पास" नहीं हो सकता।**
/// प्रोजेक्ट का नियम है — *मंत्र ग़लत होना तिथि ग़लत होने से भी बुरा है।*
/// इसलिए [Mantra.sthiti] `paas` तभी हो सकता है जब देवनागरी पाठ और स्रोत
/// दोनों भरे हों। अधूरा मंत्र चुपचाप "तैयार" नहीं दिख सकता।
///
/// **2. पूजा तब तक चेतावनी के साथ दिखेगी जब तक पंडित जी पास न कर दें।**
/// [Vidhi.needsPanditReview] — बिल्कुल वैसे ही जैसे संकल्प में
/// `needsPanditReview` है (→ D-020)।
///
/// ## ऑडियो का नाम JSON में लिखा है, बनाया नहीं जाता
/// हर मंत्र की रिकॉर्डिंग का नाम [Mantra.audio] में साफ़-साफ़ लिखा होता
/// है। मंत्र का पाठ सुधारने से रिकॉर्डिंग अपने आप अनाथ नहीं होती —
/// नाम वही रहता है। (यह ग़लती suite के एक और ऐप में हो चुकी है।)
library;

import 'dart:convert';

/// इस ढाँचे का नंबर। JSON में भी यही लिखा होना चाहिए।
///
/// आगे ढाँचा बदले तो यह बढ़ाना, और पुरानी फ़ाइलें भी साथ में बदलना।
const int vidhiSchemaVersion = 1;

/// JSON में कुछ गड़बड़ हो तो यह फेंका जाता है।
///
/// चुपचाप ग़लत कंटेंट दिखाने से अच्छा है ज़ोर से फ़ेल होना — जाँच में
/// पकड़ा जाएगा, यूज़र तक नहीं पहुँचेगा।
class VidhiFormatException implements Exception {
  final String file;
  final String message;

  const VidhiFormatException(this.file, this.message);

  @override
  String toString() => 'VidhiFormatException ($file): $message';
}

// ─────────────────────────────────────────────────────────────
// छोटी-छोटी सूचियाँ
// ─────────────────────────────────────────────────────────────

/// पूजा किस तरह की है।
enum Shreni {
  nitya('नित्य'),
  tyohar('त्योहार'),
  sanskar('संस्कार'),
  vrat('व्रत'),
  pitru('पितृ');

  final String naam;
  const Shreni(this.naam);

  static Shreni parse(String file, String raw) => Shreni.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'shreni "$raw" ऐसी कोई श्रेणी नहीं। चलेंगी: '
          '${Shreni.values.map((s) => s.name).join(", ")}',
        ),
      );
}

/// पूजा कितनी कठिन है — यूज़र को पहले ही पता होना चाहिए।
enum Kathinai {
  aasan('आसान'),
  madhyam('मध्यम'),
  kathin('विस्तृत');

  final String naam;
  const Kathinai(this.naam);

  static Kathinai parse(String file, String raw) => Kathinai.values.firstWhere(
        (k) => k.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'kathinai "$raw" ग़लत है। चलेंगी: '
          '${Kathinai.values.map((k) => k.name).join(", ")}',
        ),
      );
}

/// यह पूजा ऐप में **किस हद तक** दिखाई जा सकती है।
///
/// यही वो खाना है जो तय करता है कि "विधि शुरू करें" वाला बटन पूरी DIY
/// विधि खोले या सिर्फ़ तैयारी की जानकारी। (→ D-035,
/// `docs/14_PUJA_LIBRARY_EXPANSION_PLAN.md`)
///
/// ⚠️ **हर संस्कार अपने आप करने लायक नहीं होता।** उपनयन में आचार्य ही
/// गायत्री का उपदेश देते हैं, मुंडन में बच्चे पर उस्तरा चलता है, श्राद्ध
/// में कौन कर सकता है यह कुल-परंपरा तय करती है। ऐसी विधियों को बिना
/// रोक-टोक "अपने आप कर लीजिए" वाले रूप में दिखाना ग़लत सलाह है।
enum Scope {
  /// घर पर अपने आप की जा सकती है — पूरी विधि दिखेगी।
  selfGuided('self_guided', 'घर पर अपने आप', 'यह विधि घर पर अपने आप की जा सकती है।'),

  /// किसी एक क्षेत्र/परिवार की परंपरा है — विधि दिखेगी, पर साथ में यह
  /// चेतावनी कि दूसरी जगह अलग चलन है।
  regionalProfile('regional_profile', 'क्षेत्रीय परंपरा',
      'यह एक क्षेत्र की परंपरा है। दूसरे क्षेत्रों और परिवारों में विधि अलग होती है।'),

  /// सिर्फ़ तैयारी, अर्थ और सावधानी — **पूरी विधि नहीं दिखेगी।**
  preparationOnly('preparation_only', 'सिर्फ़ तैयारी',
      'यहाँ सिर्फ़ तैयारी, अर्थ और सावधानियाँ हैं। पूरी विधि जानकार से ही कराइए।'),

  /// मुख्य विधि पंडित/आचार्य के बिना नहीं — **पूरी विधि नहीं दिखेगी।**
  expertAssisted('expert_assisted', 'पंडित जी के साथ',
      'इसकी मुख्य विधि पंडित या आचार्य के बिना पूरी नहीं होती। यह पन्ना सिर्फ़ तैयारी के लिए है।');

  /// JSON में लिखा जाने वाला नाम।
  final String kunji;

  /// सूची और विवरण में दिखने वाला छोटा नाम।
  final String naam;

  /// पन्ने पर दिखने वाली पूरी बात।
  final String batao;

  const Scope(this.kunji, this.naam, this.batao);

  /// पूरी कदम-दर-कदम विधि खोली जा सकती है या नहीं।
  bool get poorViDhiKholSakteHain =>
      this == Scope.selfGuided || this == Scope.regionalProfile;

  static Scope parse(String file, String raw) => Scope.values.firstWhere(
        (s) => s.kunji == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'scope "$raw" ग़लत है। चलेंगी: '
          '${Scope.values.map((s) => s.kunji).join(", ")}',
        ),
      );
}

/// इस पाठ पर कितना भरोसा है — **पंडित जी की जाँच से पहले।**
///
/// सारे मंत्र एक जैसे पक्के नहीं होते। कुछ हर पद्धति में हूबहू एक जैसे
/// मिलते हैं (आचमन, गणेश का वैदिक मंत्र), कुछ में क्षेत्र और परिवार से
/// शब्द बदलते हैं (षोडशोपचार के श्लोक, आरती)।
///
/// यह दर्जा पंडित जी को बताता है कि **कहाँ ध्यान से देखना है** — ताकि
/// बैठक में समय वहीं लगे जहाँ ज़रूरत है।
enum Bharosa {
  /// कई प्रामाणिक स्रोतों में हूबहू एक जैसा मिला।
  uncha('ऊँचा'),

  /// स्रोत मिले, पर पाठ में जगह-जगह छोटे फ़र्क़ हैं।
  madhyam('मध्यम'),

  /// पद्धति से बहुत बदलता है — पंडित जी ही तय करें।
  kam('कम');

  final String naam;
  const Bharosa(this.naam);

  static Bharosa parse(String file, String raw) => Bharosa.values.firstWhere(
        (b) => b.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'bharosa "$raw" ग़लत है। चलेंगी: '
          '${Bharosa.values.map((b) => b.name).join(", ")}',
        ),
      );
}

/// मंत्र किस हालत में है।
///
/// यही वो जगह है जहाँ "अधूरी चीज़ आधी बनाकर मत दिखाना" लागू होता है।
enum MantraSthiti {
  /// अभी पाठ लिखा ही नहीं गया — ऐप में मंत्र की जगह ख़ाली दिखेगी।
  khaali('भरा नहीं'),

  /// पाठ लिखा है, पर पंडित जी से पास नहीं — चेतावनी के साथ दिखेगा।
  draft('जाँच बाक़ी'),

  /// पंडित जी ने पास कर दिया — बिना चेतावनी दिखा सकते हैं।
  paas('पास');

  final String naam;
  const MantraSthiti(this.naam);

  static MantraSthiti parse(String file, String raw) =>
      MantraSthiti.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'mantra.sthiti "$raw" ग़लत है। चलेंगी: '
          '${MantraSthiti.values.map((s) => s.name).join(", ")}',
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// मंत्र
// ─────────────────────────────────────────────────────────────

/// एक मंत्र — देवनागरी, रोमन, सरल अर्थ, और उसकी रिकॉर्डिंग।
///
/// ⚠️ **कॉपीराइट:** अर्थ अपना लिखा हुआ होना चाहिए, किसी प्रकाशक की छपी
/// टीका से उठाया हुआ नहीं। रिकॉर्डिंग भी अपनी। [strot] में यही दर्ज होता
/// है कि पाठ कहाँ से आया।
class Mantra {
  /// देवनागरी पाठ। ख़ाली हो सकता है — तब [sthiti] `khaali` होगी।
  final String devanagari;

  /// रोमन में — जिन्हें देवनागरी पढ़नी न आती हो।
  final String roman;

  /// सरल हिंदी अर्थ — **अपना लिखा हुआ।**
  final String arth;

  /// रिकॉर्डिंग की फ़ाइल, `assets/vidhi/audio/` के अंदर का नाम।
  /// ख़ाली = अभी रिकॉर्डिंग नहीं है।
  final String audio;

  /// पाठ कहाँ से लिया — किताब का नाम, या "पंडित जी ने बोलकर लिखवाया"।
  final String strot;

  /// पंडित जी की जाँच से पहले इस पाठ पर कितना भरोसा है।
  final Bharosa bharosa;

  /// जहाँ पाठ के एक से ज़्यादा चलन हैं, वो यहाँ साफ़ लिखा है — ताकि
  /// पंडित जी बता सकें कि आपके घर में कौन सा चलता है।
  final String vikalp;

  final MantraSthiti sthiti;

  const Mantra({
    required this.devanagari,
    required this.roman,
    required this.arth,
    required this.audio,
    required this.strot,
    required this.bharosa,
    required this.vikalp,
    required this.sthiti,
  });

  bool get hasPath => devanagari.trim().isNotEmpty;
  bool get hasAudio => audio.trim().isNotEmpty;

  /// ऐप में इसके साथ चेतावनी दिखानी है या नहीं।
  bool get needsPanditReview => sthiti != MantraSthiti.paas;

  factory Mantra.fromJson(String file, Map<String, dynamic> j) {
    final sthiti = MantraSthiti.parse(file, _str(file, j, 'sthiti'));
    final devanagari = _str(file, j, 'devanagari', required: false);
    final strot = _str(file, j, 'strot', required: false);

    // ── नियम 1: बिना पाठ या बिना स्रोत के मंत्र "पास" नहीं हो सकता ──
    if (sthiti != MantraSthiti.khaali && devanagari.trim().isEmpty) {
      throw VidhiFormatException(
        file,
        'मंत्र की sthiti "${sthiti.name}" है पर devanagari ख़ाली है। '
        'पाठ नहीं लिखा तो sthiti "khaali" रखो।',
      );
    }
    if (sthiti == MantraSthiti.paas && strot.trim().isEmpty) {
      throw VidhiFormatException(
        file,
        'मंत्र "paas" है पर strot ख़ाली है। बिना स्रोत के कोई मंत्र पास '
        'नहीं हो सकता — किताब का नाम या पंडित जी का नाम लिखो।',
      );
    }
    if (sthiti == MantraSthiti.khaali && devanagari.trim().isNotEmpty) {
      throw VidhiFormatException(
        file,
        'मंत्र में पाठ लिखा है पर sthiti "khaali" है। पाठ लिखा है तो '
        'कम से कम "draft" करो।',
      );
    }
    // ड्राफ़्ट भी बिना स्रोत के नहीं चलेगा। पाठ लिखा है तो यह बताना ही
    // पड़ेगा कि कहाँ से आया — वरना वो अंदाज़ा है, ड्राफ़्ट नहीं (→ D-022)।
    if (sthiti == MantraSthiti.draft && strot.trim().isEmpty) {
      throw VidhiFormatException(
        file,
        'मंत्र "draft" है पर strot ख़ाली है। बिना स्रोत के लिखा पाठ '
        'ड्राफ़्ट नहीं, अंदाज़ा है।',
      );
    }

    return Mantra(
      devanagari: devanagari,
      roman: _str(file, j, 'roman', required: false),
      arth: _str(file, j, 'arth', required: false),
      audio: _str(file, j, 'audio', required: false),
      strot: strot,
      bharosa: Bharosa.parse(
        file,
        _str(file, j, 'bharosa', required: false, fallback: 'kam'),
      ),
      vikalp: _str(file, j, 'vikalp', required: false),
      sthiti: sthiti,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// सामग्री
// ─────────────────────────────────────────────────────────────

/// पूजा की एक सामग्री।
///
/// मात्रा और इकाई अलग-अलग रखी हैं ताकि आगे सूची को जोड़ा जा सके
/// (दो पूजाएँ एक दिन हों तो), और WhatsApp पर भेजने लायक साफ़ लाइन बने।
class Samagri {
  /// चीज़ का नाम, जैसे "रोली"
  final String vastu;

  /// कितनी — "1", "सवा किलो", "5"। लिखा हुआ मान, ताकि "सवा" भी चल सके।
  final String matra;

  /// इकाई — "नग", "किलो", "पत्ते"। ख़ाली भी हो सकती है।
  final String ikai;

  /// ज़रूरी है या वैकल्पिक। **यह फ़र्क़ ज़रूरी है** — पूरी सूची देखकर
  /// लोग घबरा जाते हैं।
  final bool zaruri;

  /// किस समूह की — "पूजा की थाली", "प्रसाद", "कलश"। सूची इसी से बँटती है।
  final String samuh;

  /// कोई छोटी बात, जैसे "घर में हो तो नई ज़रूरी नहीं"
  final String note;

  const Samagri({
    required this.vastu,
    required this.matra,
    required this.ikai,
    required this.zaruri,
    required this.samuh,
    required this.note,
  });

  /// "रोली — 1 डिब्बी" जैसी एक लाइन। WhatsApp वाली सूची इसी से बनती है।
  String get line {
    final maap = [matra, ikai].where((s) => s.trim().isNotEmpty).join(' ');
    return maap.isEmpty ? vastu : '$vastu — $maap';
  }

  factory Samagri.fromJson(String file, Map<String, dynamic> j) => Samagri(
        vastu: _str(file, j, 'vastu'),
        matra: _str(file, j, 'matra', required: false),
        ikai: _str(file, j, 'ikai', required: false),
        zaruri: _bool(file, j, 'zaruri'),
        samuh: _str(file, j, 'samuh'),
        note: _str(file, j, 'note', required: false),
      );
}

// ─────────────────────────────────────────────────────────────
// चरण
// ─────────────────────────────────────────────────────────────

/// किसी चरण की कोई ख़ास बात — ऐप को वहाँ कुछ अलग करना है।
enum CharanVishesh {
  /// कुछ ख़ास नहीं, सादा चरण।
  saada,

  /// यहाँ **संकल्प** बोला जाता है। ऐप यहाँ पंचांग से बना हुआ आज का
  /// पूरा संकल्प दिखाएगा (→ D-006)। यही ऐप का सबसे बड़ा फ़र्क़ है।
  sankalp,

  /// यहाँ कथा पढ़ी जाती है — लंबा हिस्सा, अलग दिखाना है।
  katha,

  /// आरती।
  aarti;

  static CharanVishesh parse(String file, String raw) =>
      CharanVishesh.values.firstWhere(
        (v) => v.name == raw,
        orElse: () => throw VidhiFormatException(
          file,
          'vishesh "$raw" ग़लत है। चलेंगी: '
          '${CharanVishesh.values.map((v) => v.name).join(", ")}',
        ),
      );
}

/// विधि का एक कदम।
class Charan {
  /// छोटा शीर्षक, जैसे "कलश स्थापना"
  final String shirshak;

  /// क्या करना है — सादी हिंदी में, कदम-दर-कदम।
  final String vivaran;

  /// इस कदम का मंत्र। हर कदम पर मंत्र नहीं होता, इसलिए `null` सामान्य है.
  final Mantra? mantra;

  /// लगभग कितने मिनट। 0 = पता नहीं।
  final int samayMinute;

  final CharanVishesh vishesh;

  const Charan({
    required this.shirshak,
    required this.vivaran,
    required this.mantra,
    required this.samayMinute,
    required this.vishesh,
  });

  factory Charan.fromJson(String file, Map<String, dynamic> j) {
    final mantraJson = j['mantra'];
    return Charan(
      shirshak: _str(file, j, 'shirshak'),
      vivaran: _str(file, j, 'vivaran'),
      mantra: mantraJson == null
          ? null
          : Mantra.fromJson(file, _map(file, mantraJson, 'mantra')),
      samayMinute: _int(file, j, 'samayMinute', required: false),
      vishesh: CharanVishesh.parse(
        file,
        _str(file, j, 'vishesh', required: false, fallback: 'saada'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// बाक़ी टुकड़े
// ─────────────────────────────────────────────────────────────

/// पूजा कब की जाती है।
///
/// ⚠️ यहाँ कोई गणना नहीं होती — सिर्फ़ नियम लिखा होता है। असली तारीख़
/// हमेशा पंचांग इंजन से आती है। (ऐप में कभी गणना मत लिखना।)
class KabKarein {
  /// सादी भाषा में, जैसे "पूर्णिमा के दिन, शाम को"
  final String saral;

  /// कौन सी तिथियों पर — 1 से 30। ख़ाली = कोई बंधन नहीं।
  final List<int> tithiSuchi;

  /// कौन से वार — 0 = रविवार। ख़ाली = कोई बंधन नहीं।
  final List<int> vaarSuchi;

  /// कोई और बात, जैसे "किसी शुभ काम के बाद भी की जाती है"
  final String note;

  /// **यह नियम सचमुच दोहराता है या नहीं** (→ D-038)।
  ///
  /// यह फ़र्क़ बहुत ज़रूरी है। दोनों पूजाओं में `vaarSuchi` भरी होती है,
  /// पर उसका मतलब अलग होता है:
  ///
  /// - **हनुमान पूजा** — हर मंगल और शनि को सचमुच की जाती है → `true`
  /// - **गृह प्रवेश** — `vaarSuchi` का मतलब सिर्फ़ यह है कि *कौन से वार
  ///   शुभ माने जाते हैं*। गृह प्रवेश हर बुधवार को नहीं होता, वो ज़िंदगी
  ///   में एक बार होता है और तारीख़ पंडित जी तय करते हैं (→ D-019) →
  ///   `false`
  ///
  /// यही बात तिथि पर भी लागू है — सत्यनारायण हर पूर्णिमा को होती है
  /// (`true`), पर करवा चौथ साल में एक बार, भले ही कृष्ण चतुर्थी हर महीने
  /// आती हो (`false`)।
  ///
  /// `false` वाली पूजाएँ "आगे क्या आ रहा है" में नहीं आतीं। वे त्योहार
  /// के नियम से आती हैं, या नहीं आतीं।
  final bool dohrata;

  const KabKarein({
    required this.saral,
    required this.tithiSuchi,
    required this.vaarSuchi,
    required this.note,
    required this.dohrata,
  });

  factory KabKarein.fromJson(String file, Map<String, dynamic> j) {
    final tithis = _intList(file, j, 'tithiSuchi');
    for (final t in tithis) {
      if (t < 1 || t > 30) {
        throw VidhiFormatException(file, 'तिथि $t — 1 से 30 के बीच होनी चाहिए');
      }
    }
    final vaars = _intList(file, j, 'vaarSuchi');
    for (final v in vaars) {
      if (v < 0 || v > 6) {
        throw VidhiFormatException(file, 'वार $v — 0 से 6 के बीच होना चाहिए');
      }
    }
    return KabKarein(
      saral: _str(file, j, 'saral'),
      tithiSuchi: tithis,
      vaarSuchi: vaars,
      note: _str(file, j, 'note', required: false),
      dohrata: _bool(file, j, 'dohrata'),
    );
  }
}

/// आम सवाल और उसका जवाब।
class SawaalJawaab {
  final String sawaal;
  final String jawaab;

  const SawaalJawaab({required this.sawaal, required this.jawaab});

  factory SawaalJawaab.fromJson(String file, Map<String, dynamic> j) =>
      SawaalJawaab(
        sawaal: _str(file, j, 'sawaal'),
        jawaab: _str(file, j, 'jawaab'),
      );
}

/// यह विधि कहाँ से आई — **ऐप में दिखेगी।** भरोसा इसी से बनता है।
class Strot {
  /// कौन सी पद्धति, जैसे "गृहस्थ की सरल पद्धति"
  final String paddhati;

  /// किस क्षेत्र की, जैसे "उत्तर भारत"
  final String kshetra;

  final String note;

  const Strot({
    required this.paddhati,
    required this.kshetra,
    required this.note,
  });

  factory Strot.fromJson(String file, Map<String, dynamic> j) => Strot(
        paddhati: _str(file, j, 'paddhati'),
        kshetra: _str(file, j, 'kshetra'),
        note: _str(file, j, 'note', required: false),
      );
}

/// किसने जाँची — **ऐप में नाम और तारीख़ दिखेगी।**
class Jaanch {
  final String panditNaam;

  /// "2026-09-15" — ISO में, ताकि छाँटी जा सके।
  final String tarikh;

  /// पास हो गई या नहीं।
  final bool paas;

  const Jaanch({
    required this.panditNaam,
    required this.tarikh,
    required this.paas,
  });

  factory Jaanch.fromJson(String file, Map<String, dynamic> j) {
    final paas = _bool(file, j, 'paas');
    final naam = _str(file, j, 'panditNaam', required: false);
    final tarikh = _str(file, j, 'tarikh', required: false);

    // बिना नाम और तारीख़ के कोई पूजा "पास" नहीं हो सकती —
    // वरना ऐप में झूठा भरोसा दिखेगा।
    if (paas && (naam.trim().isEmpty || tarikh.trim().isEmpty)) {
      throw VidhiFormatException(
        file,
        'jaanch.paas सच है पर panditNaam या tarikh ख़ाली है। '
        'ऐप में दोनों दिखते हैं — बिना उनके पास मत करो।',
      );
    }
    if (tarikh.trim().isNotEmpty && DateTime.tryParse(tarikh) == null) {
      throw VidhiFormatException(
        file,
        'jaanch.tarikh "$tarikh" — "2026-09-15" वाले रूप में लिखो',
      );
    }

    return Jaanch(panditNaam: naam, tarikh: tarikh, paas: paas);
  }
}

// ─────────────────────────────────────────────────────────────
// पूरी पूजा
// ─────────────────────────────────────────────────────────────

/// एक पूरी पूजा।
class Vidhi {
  final String id;
  final String naam;

  /// और किन नामों से खोजी जाती है।
  final List<String> upnaam;

  final Shreni shreni;

  /// ऐप इसे कहाँ तक दिखा सकता है (→ D-035)।
  final Scope scope;

  /// दो-तीन लाइन — यह पूजा क्यों की जाती है।
  final String parichay;

  final KabKarein kabKarein;

  /// पूरी पूजा में लगभग कितने मिनट।
  ///
  /// **नियम (→ D-036): यह हमेशा कदमों के मिनटों का जोड़ होता है।** जो
  /// काम पूजा वाले दिन से पहले या साथ-साथ होता है (सामान जुटाना, प्रसाद
  /// बनाना) उसके चरण पर `samayMinute: 0` रहता है और वो जोड़ में नहीं आता।
  /// जाँच हर बार यह मिलान करती है, इसलिए दोनों कभी अलग नहीं हो सकते।
  final int samayMinute;

  final Kathinai kathinai;

  /// संकल्प के लिए — `commonPurposes` की कुंजी, जैसे "सत्यनारायण"।
  /// ख़ाली हो तो संकल्प वाला चरण सादा दिखेगा।
  final String sankalpPurpose;

  final List<Samagri> samagri;
  final List<Charan> charan;
  final List<SawaalJawaab> sawaal;
  final Strot strot;
  final Jaanch jaanch;

  const Vidhi({
    required this.id,
    required this.naam,
    required this.upnaam,
    required this.shreni,
    required this.scope,
    required this.parichay,
    required this.kabKarein,
    required this.samayMinute,
    required this.kathinai,
    required this.sankalpPurpose,
    required this.samagri,
    required this.charan,
    required this.sawaal,
    required this.strot,
    required this.jaanch,
  });

  /// ऐप में चेतावनी दिखानी है या नहीं। (→ D-020 वाला ही ढंग)
  bool get needsPanditReview => !jaanch.paas;

  /// इस पूजा में कुल कितने मंत्र हैं।
  int get mantraKul => charan.where((c) => c.mantra != null).length;

  /// कितने मंत्रों का पाठ भरा जा चुका है।
  int get mantraBhareHue =>
      charan.where((c) => c.mantra?.hasPath ?? false).length;

  /// कितने मंत्रों की रिकॉर्डिंग है।
  int get mantraAudioWale =>
      charan.where((c) => c.mantra?.hasAudio ?? false).length;

  /// ज़रूरी सामग्री ही — घबराने वाली पूरी सूची नहीं।
  List<Samagri> get zaruriSamagri =>
      samagri.where((s) => s.zaruri).toList(growable: false);

  /// सामग्री समूह के हिसाब से, JSON वाले क्रम में।
  ///
  /// हर चीज़ के साथ उसका **असली क्रमांक** भी आता है। टिक इसी क्रमांक पर
  /// लगती है — वरना "सिर्फ़ ज़रूरी" वाला बटन दबाते ही टिक दूसरी चीज़ों
  /// पर खिसक जाएगी।
  Map<String, List<({int index, Samagri samagri})>> get samagriSamuhWar {
    final out = <String, List<({int index, Samagri samagri})>>{};
    for (var i = 0; i < samagri.length; i++) {
      out
          .putIfAbsent(samagri[i].samuh, () => [])
          .add((index: i, samagri: samagri[i]));
    }
    return out;
  }

  /// "लगभग डेढ़ घंटा" जैसी लाइन।
  String get samayLikha {
    if (samayMinute <= 0) return '—';
    if (samayMinute < 60) return '$samayMinute मिनट';
    final ghante = samayMinute ~/ 60;
    final minute = samayMinute % 60;
    if (minute == 0) return '$ghante घंटा';
    if (minute == 30) return '$ghante½ घंटा';
    return '$ghante घंटा $minute मिनट';
  }

  /// WhatsApp पर भेजने लायक सामग्री की सूची।
  String samagriText({bool sirfZaruri = false}) {
    final lines = <String>['*$naam* — सामग्री की सूची', ''];
    samagriSamuhWar.forEach((samuh, cheezein) {
      final chuni = cheezein
          .map((e) => e.samagri)
          .where((s) => !sirfZaruri || s.zaruri)
          .toList(growable: false);
      if (chuni.isEmpty) return;
      lines
        ..add('*$samuh*')
        ..addAll(chuni.map((s) => '• ${s.line}${s.zaruri ? '' : ' (वैकल्पिक)'}'))
        ..add('');
    });
    lines.add('— विधिवत ऐप से');
    return lines.join('\n');
  }

  factory Vidhi.fromJson(String file, Map<String, dynamic> j) {
    final version = _int(file, j, 'schemaVersion');
    if (version != vidhiSchemaVersion) {
      throw VidhiFormatException(
        file,
        'schemaVersion $version है, ऐप $vidhiSchemaVersion चाहता है',
      );
    }

    final charan = _list(file, j, 'charan')
        .map((c) => Charan.fromJson(file, _map(file, c, 'charan')))
        .toList(growable: false);
    if (charan.isEmpty) {
      throw VidhiFormatException(file, 'एक भी चरण नहीं — विधि ख़ाली है');
    }

    final samagri = _list(file, j, 'samagri')
        .map((s) => Samagri.fromJson(file, _map(file, s, 'samagri')))
        .toList(growable: false);

    // ── समय का एक ही नियम (→ D-036) ──
    //
    // पहले हर पूजा में घोषित समय कदमों के जोड़ से कम था — बारहों में।
    // यानी यूज़र आधा घंटा सोचकर बैठता और डेढ़ घंटा लग जाता। अब जोड़ ही
    // घोषित समय है, और यह जाँच उसे दोबारा बिगड़ने नहीं देती।
    final samayJod = charan.fold<int>(0, (a, c) => a + c.samayMinute);
    final samayLikha = _int(file, j, 'samayMinute');
    if (samayLikha != samayJod) {
      throw VidhiFormatException(
        file,
        'samayMinute $samayLikha लिखा है पर कदमों का जोड़ $samayJod है। '
        'दोनों बराबर होने चाहिए — जो काम पूजा से पहले होता है उस चरण पर '
        'samayMinute 0 रखो।',
      );
    }

    // पूजा तभी पास हो सकती है जब उसका हर मंत्र पास हो।
    final jaanch = Jaanch.fromJson(file, _map(file, j['jaanch'], 'jaanch'));
    if (jaanch.paas) {
      final kachche = charan
          .where((c) => c.mantra != null && c.mantra!.needsPanditReview)
          .map((c) => c.shirshak);
      if (kachche.isNotEmpty) {
        throw VidhiFormatException(
          file,
          'पूजा "paas" है पर इन चरणों के मंत्र अभी पास नहीं: '
          '${kachche.join(", ")}',
        );
      }
    }

    return Vidhi(
      id: _str(file, j, 'id'),
      naam: _str(file, j, 'naam'),
      upnaam: _strList(file, j, 'upnaam'),
      shreni: Shreni.parse(file, _str(file, j, 'shreni')),
      scope: Scope.parse(file, _str(file, j, 'scope')),
      parichay: _str(file, j, 'parichay'),
      kabKarein:
          KabKarein.fromJson(file, _map(file, j['kabKarein'], 'kabKarein')),
      samayMinute: _int(file, j, 'samayMinute'),
      kathinai: Kathinai.parse(file, _str(file, j, 'kathinai')),
      sankalpPurpose: _str(file, j, 'sankalpPurpose', required: false),
      samagri: samagri,
      charan: charan,
      sawaal: _list(file, j, 'sawaal')
          .map((s) => SawaalJawaab.fromJson(file, _map(file, s, 'sawaal')))
          .toList(growable: false),
      strot: Strot.fromJson(file, _map(file, j['strot'], 'strot')),
      jaanch: jaanch,
    );
  }

  /// सीधे JSON के पाठ से।
  factory Vidhi.parse(String file, String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON ही ग़लत है — $e');
    }
    return Vidhi.fromJson(file, _map(file, decoded, 'फ़ाइल'));
  }
}

// ─────────────────────────────────────────────────────────────
// सूची — कौन-कौन सी पूजाएँ हैं
// ─────────────────────────────────────────────────────────────

/// सूची में एक पूजा का छोटा परिचय।
///
/// पूरी फ़ाइल तभी पढ़ी जाती है जब यूज़र उस पूजा को खोले — इसलिए सूची
/// अलग फ़ाइल में है। **यह सूची पूरी फ़ाइल से मेल खानी चाहिए**, और
/// `vidhi_test.dart` हर बार यही जाँचता है।
class VidhiSuchiEntry {
  final String id;
  final String naam;
  final Shreni shreni;

  /// एक लाइन — सूची में नाम के नीचे दिखेगी।
  final String ekLine;

  /// इसकी पूरी फ़ाइल बन चुकी है या नहीं।
  ///
  /// v1 में बारह पूजाएँ तय हैं (→ D-009), पर वे एक-एक करके बनेंगी। जो
  /// अभी नहीं बनी उसे सूची में **साफ़-साफ़ "जल्द आएगी"** लिखकर दिखाना
  /// है — छिपाना भी नहीं, और खोलने पर ख़ाली पन्ना भी नहीं दिखाना।
  ///
  /// `vidhi_test.dart` जाँचता है कि `taiyar` सच है तो फ़ाइल सचमुच मौजूद
  /// है और पढ़ी जा सकती है।
  final bool taiyar;

  /// पंडित जी से पास हो चुकी है या नहीं।
  final bool paas;

  const VidhiSuchiEntry({
    required this.id,
    required this.naam,
    required this.shreni,
    required this.ekLine,
    required this.taiyar,
    required this.paas,
  });

  factory VidhiSuchiEntry.fromJson(String file, Map<String, dynamic> j) {
    final taiyar = _bool(file, j, 'taiyar');
    final paas = _bool(file, j, 'paas');
    if (paas && !taiyar) {
      throw VidhiFormatException(
        file,
        'पूजा "paas" है पर "taiyar" नहीं — जो बनी ही नहीं वो पास कैसे हुई?',
      );
    }
    return VidhiSuchiEntry(
      id: _str(file, j, 'id'),
      naam: _str(file, j, 'naam'),
      shreni: Shreni.parse(file, _str(file, j, 'shreni')),
      ekLine: _str(file, j, 'ekLine'),
      taiyar: taiyar,
      paas: paas,
    );
  }

  static List<VidhiSuchiEntry> parseAll(String file, String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw VidhiFormatException(file, 'JSON ही ग़लत है — $e');
    }
    final root = _map(file, decoded, 'फ़ाइल');
    final version = _int(file, root, 'schemaVersion');
    if (version != vidhiSchemaVersion) {
      throw VidhiFormatException(
        file,
        'schemaVersion $version है, ऐप $vidhiSchemaVersion चाहता है',
      );
    }
    final list = _list(file, root, 'poojayein')
        .map((e) => VidhiSuchiEntry.fromJson(file, _map(file, e, 'poojayein')))
        .toList(growable: false);

    final ids = <String>{};
    for (final e in list) {
      if (!ids.add(e.id)) {
        throw VidhiFormatException(file, 'id "${e.id}" दो बार आई है');
      }
    }
    return list;
  }
}

// ─────────────────────────────────────────────────────────────
// JSON पढ़ने के छोटे औज़ार
//
// हर एक फ़ाइल का नाम साथ लेकर चलता है, ताकि ग़लती मिलने पर यह पता चले
// कि **किस** फ़ाइल में है। बारह पूजाओं में यह बहुत काम आएगा।
// ─────────────────────────────────────────────────────────────

Map<String, dynamic> _map(String file, dynamic value, String kahan) {
  if (value is! Map) {
    throw VidhiFormatException(file, '"$kahan" में object चाहिए था, मिला: $value');
  }
  return value.cast<String, dynamic>();
}

List<dynamic> _list(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) return const [];
  if (v is! List) {
    throw VidhiFormatException(file, '"$key" में सूची चाहिए थी, मिला: $v');
  }
  return v;
}

String _str(
  String file,
  Map<String, dynamic> j,
  String key, {
  bool required = true,
  String fallback = '',
}) {
  final v = j[key];
  if (v == null) {
    if (required) throw VidhiFormatException(file, '"$key" है ही नहीं');
    return fallback;
  }
  if (v is! String) {
    throw VidhiFormatException(file, '"$key" में लिखावट चाहिए थी, मिला: $v');
  }
  if (required && v.trim().isEmpty) {
    throw VidhiFormatException(file, '"$key" ख़ाली है');
  }
  return v;
}

int _int(String file, Map<String, dynamic> j, String key,
    {bool required = true}) {
  final v = j[key];
  if (v == null) {
    if (required) throw VidhiFormatException(file, '"$key" है ही नहीं');
    return 0;
  }
  if (v is! int) {
    throw VidhiFormatException(file, '"$key" में पूर्णांक चाहिए था, मिला: $v');
  }
  return v;
}

bool _bool(String file, Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v == null) throw VidhiFormatException(file, '"$key" है ही नहीं');
  if (v is! bool) {
    throw VidhiFormatException(file, '"$key" में true/false चाहिए था, मिला: $v');
  }
  return v;
}

List<String> _strList(String file, Map<String, dynamic> j, String key) =>
    _list(file, j, key).map((e) {
      if (e is! String) {
        throw VidhiFormatException(file, '"$key" में लिखावट चाहिए थी, मिला: $e');
      }
      return e;
    }).toList(growable: false);

List<int> _intList(String file, Map<String, dynamic> j, String key) =>
    _list(file, j, key).map((e) {
      if (e is! int) {
        throw VidhiFormatException(file, '"$key" में पूर्णांक चाहिए था, मिला: $e');
      }
      return e;
    }).toList(growable: false);
