import 'package:panchang_engine/panchang_engine.dart';

import 'vidhi.dart';

/// **आगे कौन सी पूजा कब है** — dashboard वाली आने-जाने की सूची।
///
/// ## यह सब पंचांग से निकलता है, कहीं हाथ से नहीं भरा
///
/// सुनहरा नियम कहता है — *जो चीज़ हर हफ़्ते अपडेट माँगे, वो मत बनाओ।*
/// इसलिए यहाँ एक भी तारीख़ लिखी हुई नहीं है। तीन जगहों से बनती है:
///
/// 1. **त्योहार** — इंजन के `festivalRules` से, व्यापिनी नियम लगाकर
///    (→ D-017)। आठों Drik से जाँचे हुए हैं।
/// 2. **तिथि वाली पूजाएँ** — हर पूजा की JSON में लिखी `kabKarein.tithiSuchi`
///    से (जैसे सत्यनारायण = पूर्णिमा)।
/// 3. **वार वाली पूजाएँ** — `kabKarein.vaarSuchi` से (जैसे हनुमान =
///    मंगल और शनि)।
///
/// यानी दस साल बाद भी यह सूची अपने आप सही रहेगी।
///
/// ⚠️ जिन पूजाओं में तिथि और वार दोनों ख़ाली हैं (नित्य पूजा, सूर्य
/// अर्घ्य, तुलसी) वे **रोज़** की हैं — उन्हें इस सूची में नहीं डाला
/// जाता, वरना हर दिन तीन पंक्तियाँ भर जातीं। वे dashboard के ऊपर वाले
/// हिस्से में अलग दिखती हैं।

/// किस वजह से यह पूजा उस दिन दिख रही है।
enum AvsarKaKaran {
  /// इंजन के त्योहार नियम से निकली तारीख़ (सबसे पक्की)।
  tyohar,

  /// उस दिन की तिथि पूजा की `tithiSuchi` में है।
  tithi,

  /// उस दिन का वार पूजा की `vaarSuchi` में है।
  vaar,
}

/// एक आने वाला अवसर — किस दिन, कौन सी पूजा, और क्यों।
class PujaAvsar {
  /// स्थानीय तारीख़ (समय बेमानी है, सिर्फ़ दिन देखो)।
  final DateTime tarikh;

  /// आज से कितने दिन बाद। 0 = आज, 1 = कल।
  final int kitneDinBaad;

  /// पूजा की `id` — ख़ाली हो सकती है, अगर त्योहार का अपना पन्ना न हो।
  final String pujaId;

  /// जो नाम दिखाना है — त्योहार का नाम, या पूजा का।
  final String naam;

  /// नीचे की छोटी लाइन, जैसे "पूर्णिमा" या "मंगलवार"।
  final String kyon;

  final AvsarKaKaran karan;

  const PujaAvsar({
    required this.tarikh,
    required this.kitneDinBaad,
    required this.pujaId,
    required this.naam,
    required this.kyon,
    required this.karan,
  });

  /// इस पूजा का अपना पन्ना ऐप में है या नहीं।
  bool get khulSaktiHai => pujaId.isNotEmpty;

  /// "आज" · "कल" · "परसों" · "12 दिन बाद"
  String get kabLikha => switch (kitneDinBaad) {
        0 => 'आज',
        1 => 'कल',
        2 => 'परसों',
        _ => '$kitneDinBaad दिन बाद',
      };
}

/// त्योहार का नाम → उस पूजा की `id`, जब ऐप में उसका अपना पन्ना हो।
///
/// जिस त्योहार की पूजा ऐप में नहीं है वो सूची में **फिर भी दिखता है** —
/// बस खुलता नहीं। तारीख़ बता देना अपने आप में काम की चीज़ है, और उसके
/// लिए विधि होना ज़रूरी नहीं।
const Map<String, String> tyoharKiPuja = {
  'महाशिवरात्रि': 'rudrabhishek',
  'राम नवमी': 'ram_pooja',
  'जन्माष्टमी': 'krishna_pooja',
  'गणेश चतुर्थी': 'ganesh_poojan',
  'शारदीय नवरात्रि — घटस्थापना': 'kalash_sthapana',
  'दीपावली': 'lakshmi_poojan',
  // होलिका दहन और रक्षाबंधन की अपनी विधि अभी नहीं बनी — तारीख़ फिर भी दिखेगी।
};

/// आगे के दिनों में कौन-कौन सी पूजा पड़ रही है।
///
/// [dinAage] — कितने दिन आगे तक देखना है (डिफ़ॉल्ट 30)।
/// [kitne] — ज़्यादा से ज़्यादा कितने अवसर लौटाने हैं।
///
/// दो नियम इस सूची को काम की बनाते हैं:
///
/// **1. एक दिन में एक ही पूजा** — जो सबसे पक्की वजह से पड़ रही हो
/// (त्योहार > तिथि > वार)। वरना पूर्णिमा वाले शनिवार को सत्यनारायण और
/// हनुमान दोनों एक साथ आ जाते।
///
/// **2. एक पूजा एक ही बार** — उसका सबसे पहला आने वाला दिन।
///
/// दूसरा नियम इसलिए ज़रूरी है कि हनुमान पूजा हर मंगल और शनि को पड़ती है।
/// उसे हर बार दिखाया जाता तो पाँच पंक्तियों वाली सूची में **दीपावली और
/// जन्माष्टमी के लिए जगह ही न बचती** — यानी सबसे काम की चीज़ ही बाहर
/// धकेल दी जाती।
List<PujaAvsar> aaneWaliPujaayein({
  required List<Vidhi> pujaayein,
  required Place place,
  required MasaSystem masaSystem,
  DateTime? aaj,
  int dinAage = 30,
  int kitne = 6,
}) {
  final shuru = _sirfDin(aaj ?? DateTime.now());

  // ── 1. त्योहार — इस साल और अगले साल के, ताकि दिसम्बर में भी सूची भरे ──
  final tyoharTarikh = <DateTime, FestivalDate>{};
  for (final saal in {shuru.year, shuru.year + 1}) {
    for (final f in festivalsInYear(saal, place)) {
      tyoharTarikh[_sirfDin(f.date)] = f;
    }
  }

  final khulneWali = {for (final v in pujaayein) v.id: v};

  // ── पहला चरण: त्योहार ──
  //
  // ये पहले इकट्ठे होते हैं क्योंकि साल में कुछ ही बार आते हैं। इन्हें
  // बाद वाली तिथि/वार वाली पूजाओं से धकेला नहीं जाना चाहिए।
  final tyoharAvsar = <PujaAvsar>[];
  final tyoharKiIds = <String>{};
  for (var i = 0; i <= dinAage; i++) {
    final din = shuru.add(Duration(days: i));
    final tyohar = tyoharTarikh[din];
    if (tyohar == null) continue;

    final id = tyoharKiPuja[tyohar.rule.name] ?? '';
    final khulegi = khulneWali.containsKey(id) ? id : '';
    if (khulegi.isNotEmpty) tyoharKiIds.add(khulegi);
    tyoharAvsar.add(PujaAvsar(
      tarikh: din,
      kitneDinBaad: i,
      pujaId: khulegi,
      naam: tyohar.rule.name,
      kyon: 'त्योहार',
      karan: AvsarKaKaran.tyohar,
    ));
  }

  // ── दूसरा चरण: तिथि और वार वाली पूजाएँ ──
  //
  // जिस पूजा का त्योहार ऊपर आ चुका है वो दोबारा नहीं आती — वरना
  // "गणेश चतुर्थी" और "गणेश पूजन · चतुर्थी" दोनों एक साथ दिखते।
  final baaki = <String, PujaAvsar>{};
  for (var i = 0; i <= dinAage; i++) {
    final din = shuru.add(Duration(days: i));
    if (tyoharTarikh.containsKey(din)) continue;

    final p = computePanchang(din.year, din.month, din.day, place,
        masaSystem: masaSystem);
    final tithiNumber = p.tithi.number;
    final vaar = p.vara;

    PujaAvsar? tithiWali;
    PujaAvsar? vaarWali;

    for (final v in pujaayein) {
      if (tyoharKiIds.contains(v.id)) continue;
      if (baaki.containsKey(v.id)) continue;

      // ⚠️ जिसका नियम दोहराता नहीं, वो यहाँ नहीं आती (→ D-038)।
      // गृह प्रवेश हर बुधवार को नहीं होता, और करवा चौथ हर कृष्ण चतुर्थी
      // को नहीं। उन्हें दिखाना सीधे ग़लत जानकारी देना है।
      if (!v.kabKarein.dohrata) continue;

      final tithiSuchi = v.kabKarein.tithiSuchi;
      final vaarSuchi = v.kabKarein.vaarSuchi;

      // रोज़ वाली पूजाएँ इस सूची में नहीं आतीं।
      if (tithiSuchi.isEmpty && vaarSuchi.isEmpty) continue;

      if (tithiWali == null && tithiSuchi.contains(tithiNumber)) {
        tithiWali = PujaAvsar(
          tarikh: din,
          kitneDinBaad: i,
          pujaId: v.id,
          naam: v.naam,
          kyon: p.tithi.name,
          karan: AvsarKaKaran.tithi,
        );
      } else if (vaarWali == null &&
          tithiSuchi.isEmpty &&
          vaarSuchi.contains(vaar)) {
        // वार वाली पूजा तभी, जब उसमें तिथि का बंधन न हो — वरना
        // "गणेश चतुर्थी" हर मंगलवार को दिखने लगेगी।
        vaarWali = PujaAvsar(
          tarikh: din,
          kitneDinBaad: i,
          pujaId: v.id,
          naam: v.naam,
          kyon: p.varaName,
          karan: AvsarKaKaran.vaar,
        );
      }
    }

    final chuni = tithiWali ?? vaarWali;
    if (chuni != null) baaki.putIfAbsent(chuni.pujaId, () => chuni);
  }

  final sabhi = [...tyoharAvsar, ...baaki.values]
    ..sort((a, b) => a.kitneDinBaad.compareTo(b.kitneDinBaad));
  return sabhi.take(kitne).toList(growable: false);
}

DateTime _sirfDin(DateTime d) => DateTime(d.year, d.month, d.day);
