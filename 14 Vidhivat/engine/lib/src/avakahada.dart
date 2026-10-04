import 'avakahada_data.dart';
import 'kundali.dart';

/// अवकहड़ा — जन्म के चंद्रमा से निकलने वाली **तालिका की चीज़ें**: नाम का
/// अक्षर, वर्ण, वश्य, योनि, गण, नाड़ी (→ D-110, docs/29 चरण K4)।
///
/// ## यह क्या है, और क्या नहीं
/// इसमें कोई खगोल नहीं है — चंद्रमा की राशि और नक्षत्र-चरण `kundali.dart` से
/// आते हैं; यहाँ सिर्फ़ पुरानी पुस्तकों की तालिकाएँ हैं जो बताती हैं कि उस
/// नक्षत्र-चरण का अक्षर कौन सा है, उस नक्षत्र की योनि क्या गिनी जाती है।
///
/// यह **नहीं** बताता कि "देव गण वाला आदमी कैसा होता है" या "यह नाड़ी हो तो
/// क्या होगा"। ऐसी कोई बात इस फ़ाइल में नहीं है और नहीं आएगी (`CLAUDE.md`:
/// *"भविष्यवाणी के दावे कभी नहीं"*)।
///
/// ## तालिकाएँ कहाँ से
/// `avakahada_data.dart` — जो `tools/banao_avakahada.py` से बनती है। नक्षत्र →
/// योनि/गण/नाड़ी और राशि → वर्ण/स्वामी मुहूर्तचिंतामणि (विवाह प्रकरण) के
/// श्लोकों से हैं और हर पुस्तक में एक हैं। **वश्य** में पुस्तकें बँटी हैं —
/// [Avakahada.vashyaPurana] देखिए। पते `docs/18` अध्याय २६ में।

/// राशि का वर्ण। यह **राशि** का पुराना वर्गीकरण है — किसी आदमी की जाति या
/// ऊँच-नीच से इसका कोई संबंध नहीं; स्क्रीन यह खुलकर कहती है।
enum Varna {
  brahman('ब्राह्मण'),
  kshatriya('क्षत्रिय'),
  vaishya('वैश्य'),
  shudra('शूद्र');

  final String naam;
  const Varna(this.naam);
}

enum Vashya {
  chatushpad('चतुष्पद'),
  manav('मानव'),
  jalchar('जलचर'),
  vanchar('वनचर'),
  keet('कीट');

  final String naam;
  const Vashya(this.naam);
}

/// चौदह योनियाँ — तालिकाओं के क्रम में।
enum Yoni {
  ashva('अश्व', 'घोड़ा'),
  gaj('गज', 'हाथी'),
  mesh('मेष', 'भेड़'),
  sarp('सर्प', 'साँप'),
  shvan('श्वान', 'कुत्ता'),
  marjar('मार्जार', 'बिल्ली'),
  mushak('मूषक', 'चूहा'),
  gau('गौ', 'गाय'),
  mahish('महिष', 'भैंस'),
  vyaghra('व्याघ्र', 'बाघ'),
  mrig('मृग', 'हिरण'),
  vanar('वानर', 'बंदर'),
  nakul('नकुल', 'नेवला'),
  simha('सिंह', 'शेर');

  final String naam;

  /// बोलचाल का नाम।
  final String saral;
  const Yoni(this.naam, this.saral);
}

enum Gana {
  dev('देव'),
  manushya('मनुष्य'),
  rakshas('राक्षस');

  final String naam;
  const Gana(this.naam);
}

enum Nadi {
  adi('आदि'),
  madhya('मध्य'),
  antya('अंत्य');

  final String naam;
  const Nadi(this.naam);
}

/// राशि (0 = मेष) का स्वामी। तालिका के अंक 0–6 = सूर्य … शनि — ठीक वही क्रम
/// जो [KundaliGraha] के पहले सात का है।
KundaliGraha rashiSwami(int rashi) =>
    KundaliGraha.values[rashiSwamiData[rashi % 12]];

/// अभिजित — उत्तराषाढ़ा का आख़िरी चरण और श्रवण का पहला पंद्रहवाँ हिस्सा
/// (मुहूर्तचिंतामणि: *"वैश्वप्रान्त्याङ्घ्रिः श्रुतितिथिभागतोऽभिजित् स्यात्"*)।
/// निरयन 276°40′ से 280°53′20″ तक।
const double abhijitShuru = 276.0 + 40.0 / 60.0;
const double abhijitAnt = 280.0 + (53.0 + 20.0 / 60.0) / 60.0;

/// जिन तीन अक्षरों से नाम शुरू नहीं होता, उनकी जगह पुस्तक क्या कहती है:
/// *"ङ, ण, ञ हो तो नामाद्यक्षर ग, ड, ज होगा"*।
const Map<String, String> naamAksharBadal = {'ङ': 'ग', 'ण': 'ड', 'ञ': 'ज'};

/// एक आदमी का अवकहड़ा — सब कुछ जन्म के चंद्रमा के निरयन देशांतर से।
class Avakahada {
  /// जन्म का चंद्रमा।
  final RashiSthiti chandra;

  const Avakahada(this.chandra);

  int get rashi => chandra.rashi;
  int get nakshatra => chandra.nakshatra;

  /// नक्षत्र का चरण, 1 से 4।
  int get charan => chandra.charan;

  /// नाम का पहला अक्षर — शतपद चक्र से।
  String get naamAkshar => naamAksharData[nakshatra][charan - 1];

  /// अगर [naamAkshar] ङ, ण या ञ है तो उसकी जगह चलने वाला अक्षर; नहीं तो `null`।
  String? get naamAksharKiJagah => naamAksharBadal[naamAkshar];

  /// चंद्रमा अभिजित के घेरे में हो तो उसका अक्षर (जू, जे, जो, खा); नहीं तो
  /// `null`। कुंडली 27 नक्षत्रों पर चलती है, इसलिए मुख्य अक्षर [naamAkshar] ही
  /// रहता है; जो घर अभिजित मानते हैं उनके लिए यह दूसरा अक्षर है।
  String? get abhijitAkshar {
    final l = chandra.nirayan;
    if (l < abhijitShuru || l >= abhijitAnt) return null;
    final charan = ((l - abhijitShuru) / ((abhijitAnt - abhijitShuru) / 4))
        .floor()
        .clamp(0, 3);
    return abhijitAksharData[charan];
  }

  Varna get varna => Varna.values[rashiVarnaData[rashi]];

  /// वश्य — आज की प्रचलित गिनती से। धनु और मकर आधी-आधी बँटी हैं, इसलिए
  /// राशि के भीतर के अंश भी देखे जाते हैं।
  Vashya get vashya =>
      Vashya.values[rashiVashyaData[rashi][chandra.ansh < 15 ? 0 : 1]];

  /// पुरानी छपी पुस्तकों के श्लोक में यही राशि किसी और वश्य में गिनी है तो
  /// वह; नहीं तो `null`। (कर्क — कीट; कुंभ — जलचर; सिंह — चतुष्पद।)
  Vashya? get vashyaPurana {
    final v = rashiVashyaPuranaBhedData[rashi];
    return v == null ? null : Vashya.values[v];
  }

  Yoni get yoni => Yoni.values[nakshatraYoniData[nakshatra]];
  Gana get gana => Gana.values[nakshatraGanaData[nakshatra]];
  Nadi get nadi => Nadi.values[nakshatraNadiData[nakshatra]];

  /// चंद्र राशि का स्वामी।
  KundaliGraha get rashiSwami =>
      KundaliGraha.values[rashiSwamiData[rashi]];
}

/// चंद्रमा के निरयन देशांतर (0–360°) से अवकहड़ा।
Avakahada avakahada(double chandraNirayan) {
  final l = chandraNirayan % 360.0;
  return Avakahada(RashiSthiti(l < 0 ? l + 360.0 : l));
}
