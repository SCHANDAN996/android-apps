import 'avakahada.dart';
import 'avakahada_data.dart';
import 'kundali.dart';
import 'names.dart';

/// अष्टकूट गुण मिलान — **तालिका का जोड़** (→ D-110, docs/29 चरण K4)।
///
/// वर और कन्या के जन्म के चंद्रमा से आठ कूटों के अंक, कुल 36 में से। आठों
/// का नाम और क्रम मुहूर्तचिंतामणि (विवाह प्रकरण २१) से:
/// *"वर्णो वश्यं तथा तारा योनिश्च ग्रहमैत्रकम्। गणमैत्रं भकूटं च नाडी चैते
/// गुणाधिकाः॥"* — हर अगले कूट का एक गुण ज़्यादा।
///
/// ## यह क्या नहीं करता
/// - **फ़ैसला नहीं देता।** कितने गुण पर रिश्ता "ठीक" है — यह यहाँ नहीं है।
///   पुस्तकें उस पर भी अलग-अलग हैं, और वह ऐप का काम नहीं।
/// - **"दोष" नहीं गिनता** और उनके अपवाद (परिहार) नहीं लगाता। अंक मूल
///   तालिका के हैं, बस।
/// - किसी कूट का **फल** नहीं बताता। पुस्तकों में हर शून्य के आगे जो लिखा है
///   वह इस ऐप में कहीं नहीं आएगा।
///
/// ## 🔑 तीन कूटों की तालिका पुस्तकों में अलग-अलग छपी है
/// | कूट | क्या अलग है | यहाँ |
/// |---|---|---|
/// | योनि | 91 जोड़ों में से 26 के अंक | दोनों: [KootAnk.ank] आज की प्रचलित तालिका से, [KootAnk.puraniTalikaSe] 1932 की छपी तालिका से |
/// | गण | एक खाना (कन्या मनुष्य, वर देव: 6 या 5) | दोनों, वैसे ही |
/// | वश्य | राशियों का बँटवारा भी, और अंक भी | सिर्फ़ प्रचलित; [KootAnk.talikaBantiHai] `true` — स्क्रीन यह खुलकर कहती है |
///
/// बाक़ी पाँच (वर्ण, तारा, ग्रह मैत्री, भकूट, नाड़ी) नियम से निकलते हैं और
/// देखी गई हर पुस्तक में एक हैं। पूरा ब्योरा `docs/18` अध्याय २६ में।

/// आठ कूट, मुहूर्तचिंतामणि के क्रम में; [adhiktam] = उस कूट के पूरे गुण।
enum Koot {
  varna('वर्ण', 1),
  vashya('वश्य', 2),
  tara('तारा', 3),
  yoni('योनि', 4),
  grahaMaitri('ग्रह मैत्री', 5),
  gana('गण', 6),
  bhakoot('भकूट', 7),
  nadi('नाड़ी', 8);

  final String naam;
  final int adhiktam;
  const Koot(this.naam, this.adhiktam);
}

/// एक कूट का नतीजा।
class KootAnk {
  final Koot koot;

  /// अंक — आज की प्रचलित तालिका से।
  final double ank;

  /// 1932 की छपी तालिका से अंक, **अगर वह [ank] से अलग है**; नहीं तो `null`।
  final double? puraniTalikaSe;

  /// इस कूट की तालिका पुस्तकों में इतनी बँटी है कि दूसरा अंक देना भी ठीक
  /// नहीं (वश्य)।
  final bool talikaBantiHai;

  /// वर और कन्या की ओर से जो चीज़ मिलाई गई — जैसे "क्षत्रिय", "रोहिणी"।
  final String varKa;
  final String kanyaKa;

  const KootAnk({
    required this.koot,
    required this.ank,
    required this.varKa,
    required this.kanyaKa,
    this.puraniTalikaSe,
    this.talikaBantiHai = false,
  });
}

/// पूरा मिलान।
class GunMilan {
  final Avakahada vara;
  final Avakahada kanya;

  /// आठ कूट, [Koot] के क्रम में।
  final List<KootAnk> koot;

  const GunMilan({required this.vara, required this.kanya, required this.koot});

  KootAnk operator [](Koot k) => koot[k.index];

  /// कुल गुण, 36 में से — प्रचलित तालिकाओं से।
  double get kul => koot.fold(0.0, (s, k) => s + k.ank);

  /// 1932 की छपी तालिकाओं से कुल, **अगर अलग है**; नहीं तो `null`।
  double? get puraniTalikaSeKul {
    final k = koot.fold(0.0, (s, k) => s + (k.puraniTalikaSe ?? k.ank));
    return k == kul ? null : k;
  }
}

/// कुल गुण — हमेशा 36।
const int gunMilanAdhiktam = 36;

/// दो राशि-स्वामियों की मैत्री के गुण, 5 में से।
///
/// नैसर्गिक मैत्री मुहूर्तचिंतामणि २७–२८ से; अंक का नियम दैवज्ञमनोहर से:
/// एक ही स्वामी या दोनों मित्र 5 · एक मित्र एक सम 4 · दोनों सम 3 · एक मित्र
/// एक शत्रु 1 · एक सम एक शत्रु ½ · दोनों शत्रु 0।
double grahaMaitriAnk(KundaliGraha a, KundaliGraha b) {
  if (a == b) return 5;
  assert(a.index < 7 && b.index < 7, 'राशि के स्वामी सूर्य से शनि तक ही हैं');
  final x = naisargikMaitriData[a.index][b.index];
  final y = naisargikMaitriData[b.index][a.index];
  final bada = x > y ? x : y;
  final chhota = x > y ? y : x;
  if (bada == 1 && chhota == 1) return 5;
  if (bada == 1 && chhota == 0) return 4;
  if (bada == 0 && chhota == 0) return 3;
  if (bada == 1 && chhota == -1) return 1;
  if (bada == 0 && chhota == -1) return 0.5;
  return 0;
}

/// एक नक्षत्र से दूसरे तक गिनकर तारा — 1 से 9 (दोनों नक्षत्र गिनती में)।
int tara(int seNakshatra, int takNakshatra) {
  final shesh = ((takNakshatra - seNakshatra) % 27 + 1) % 9;
  return shesh == 0 ? 9 : shesh;
}

/// तारा 3, 5 या 7 हो तो पुस्तक उसे अलग गिनती है।
bool _taraGinti(int t) => t != 3 && t != 5 && t != 7;

/// तारा के गुण, 3 में से — दोनों ओर से गिनकर।
double taraAnk(int varNakshatra, int kanyaNakshatra) {
  final n = (_taraGinti(tara(kanyaNakshatra, varNakshatra)) ? 1 : 0) +
      (_taraGinti(tara(varNakshatra, kanyaNakshatra)) ? 1 : 0);
  return n * 1.5;
}

/// भकूट के गुण — वर की राशि से कन्या की राशि कौन सी पड़ती है: 2-12, 5-9 या
/// 6-8 हो तो 0, नहीं तो 7।
double bhakootAnk(int varRashi, int kanyaRashi) {
  final sthan = (kanyaRashi - varRashi) % 12 + 1;
  const shunya = {2, 12, 5, 9, 6, 8};
  return shunya.contains(sthan) ? 0 : 7;
}

/// वर और कन्या के जन्म के चंद्रमा (निरयन देशांतर) से गुण मिलान।
GunMilan gunMilan({
  required double varChandra,
  required double kanyaChandra,
}) {
  final v = avakahada(varChandra);
  final k = avakahada(kanyaChandra);

  double? alag(num purani, num prachalit) =>
      purani == prachalit ? null : purani.toDouble();

  final yoniP = yoniAnkPrachalitData[k.yoni.index][v.yoni.index];
  final yoniA = yoniAnkPuraniData[k.yoni.index][v.yoni.index];
  final ganaP = ganaAnkPrachalitData[k.gana.index][v.gana.index];
  final ganaA = ganaAnkPuraniData[k.gana.index][v.gana.index];

  return GunMilan(
    vara: v,
    kanya: k,
    koot: [
      // वर का वर्ण कन्या के बराबर या ऊपर हो तो 1 (सूची में ऊपर = छोटा अंक)
      KootAnk(
        koot: Koot.varna,
        ank: v.varna.index <= k.varna.index ? 1 : 0,
        varKa: v.varna.naam,
        kanyaKa: k.varna.naam,
      ),
      KootAnk(
        koot: Koot.vashya,
        ank: vashyaAnkData[k.vashya.index][v.vashya.index],
        varKa: v.vashya.naam,
        kanyaKa: k.vashya.naam,
        talikaBantiHai: true,
      ),
      KootAnk(
        koot: Koot.tara,
        ank: taraAnk(v.nakshatra, k.nakshatra),
        varKa: nakshatraNames[v.nakshatra],
        kanyaKa: nakshatraNames[k.nakshatra],
      ),
      KootAnk(
        koot: Koot.yoni,
        ank: yoniP.toDouble(),
        puraniTalikaSe: alag(yoniA, yoniP),
        varKa: v.yoni.naam,
        kanyaKa: k.yoni.naam,
      ),
      KootAnk(
        koot: Koot.grahaMaitri,
        ank: grahaMaitriAnk(v.rashiSwami, k.rashiSwami),
        varKa: v.rashiSwami.naam,
        kanyaKa: k.rashiSwami.naam,
      ),
      KootAnk(
        koot: Koot.gana,
        ank: ganaP.toDouble(),
        puraniTalikaSe: alag(ganaA, ganaP),
        varKa: v.gana.naam,
        kanyaKa: k.gana.naam,
      ),
      KootAnk(
        koot: Koot.bhakoot,
        ank: bhakootAnk(v.rashi, k.rashi),
        varKa: rashiNames[v.rashi],
        kanyaKa: rashiNames[k.rashi],
      ),
      KootAnk(
        koot: Koot.nadi,
        ank: v.nadi == k.nadi ? 0 : 8,
        varKa: v.nadi.naam,
        kanyaKa: k.nadi.naam,
      ),
    ],
  );
}
