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
///    (→ D-017)। आठों तारीख़ें स्वतंत्र संदर्भ-पंचांगों से जाँची गई हैं।
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

  /// विधि नहीं, पर व्रत-पन्ना (`assets/vrat/`) है — उसकी `id` ([tyoharKaVrat])।
  final String vratId;

  const PujaAvsar({
    required this.tarikh,
    required this.kitneDinBaad,
    required this.pujaId,
    required this.naam,
    required this.kyon,
    required this.karan,
    this.vratId = '',
  });

  /// इस पूजा का अपना पन्ना ऐप में है या नहीं।
  bool get khulSaktiHai => pujaId.isNotEmpty;

  /// विधि नहीं है, पर व्रत-पन्ना खुलेगा।
  bool get vratKhulega => pujaId.isEmpty && vratId.isNotEmpty;

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
  'धनतेरस': 'dhanteras',
  'गोवर्धन पूजा': 'govardhan_annakut',
  'भाई दूज': 'bhai_dooj_pooja',
  'वसंत पंचमी': 'saraswati_pooja',
  'रक्षाबंधन': 'raksha_bandhan_pooja',
  // होलिका दहन की अपनी विधि अभी नहीं बनी — तारीख़ फिर भी दिखेगी।

  // ── व्रत और पितृ पक्ष — इंजन में 22 सित 2026 से (→ D-087) ──
  'वट सावित्री व्रत': 'vat_savitri',
  'वरलक्ष्मी व्रत': 'varalakshmi_vrat',
  'हरितालिका तीज': 'hartalika_teej',
  'करवा चौथ': 'karwa_chauth',
  'छठ पूजा': 'chhath_pooja',
  'पितृ पक्ष आरम्भ': 'shraadh',
  'सर्वपितृ अमावस्या': 'shraadh',
};

/// त्योहार का नाम → व्रत-पन्ने (`assets/vrat/`) की `id` — जिसकी कदम-दर-कदम
/// विधि नहीं, पर "क्या करें" वाला पूरा पन्ना है (→ D-130)। होम की पट्टी,
/// कैलेंडर और "आज" — तीनों से वही पन्ना खुलता है।
const Map<String, String> tyoharKaVrat = {
  'शरद पूर्णिमा': 'sharad_purnima',
};

/// हर महीने वाली पूजा के नीचे की लाइन — पक्ष सहित, और जिस तिथि का अपना
/// मासिक नाम है वो नाम।
///
/// ## यह क्यों (22 सित 2026, फ़ोन पर पकड़ा)
///
/// "शिवरात्रि और सरल शिव अभिषेक · 3 दिन बाद · चतुर्दशी" दिख रहा था —
/// पढ़ने वाले को लगा महाशिवरात्रि तीन दिन बाद है, जो साल में एक बार आती
/// है। सिर्फ़ "चतुर्दशी" लिखने से न पक्ष पता चलता था, न यह कि यह हर
/// महीने वाली **मासिक** शिवरात्रि है। (और वह शुक्ल चतुर्दशी थी — शिव
/// जी का दिन ही नहीं; वह ग़लती पूजा की JSON में थी, वहीं सुधरी।)
String maasikKyon(int tithi, String pakshaName, String tithiName) =>
    switch (tithi) {
      15 => 'पूर्णिमा',
      30 => 'अमावस्या',
      4 => 'विनायक चतुर्थी',
      19 => 'संकष्टी चतुर्थी',
      29 => 'मासिक शिवरात्रि',
      _ => '$pakshaName $tithiName',
    };

/// इंजन के वे त्योहार जो आने वाली पूजाओं में **अलग से नहीं** आते।
///
/// दशहरा नवरात्रि पर्व का दसवाँ दिन है — उसका पत्ता नवरात्रि वाला ही है
/// (→ D-074)। अलग से आता तो उन्नीस दिन दूर की नवरात्रि और अट्ठाईस दिन दूर
/// का दशहरा दो पत्ते बनते, और दशहरा वाला खुलता भी नहीं। कैलेंडर और "आज"
/// पन्ने पर दशहरा फिर भी अपने नाम से दिखता है।
const Set<String> parvKeHisse = {'दशहरा'};

/// संक्रांति से तय होने वाली पूजाएँ — सूर्य की राशि (0 = मेष) → नाम, पूजा
/// की `id`, और नीचे की छोटी लाइन।
///
/// ## यह [tyoharKiPuja] से अलग क्यों
///
/// इंजन के त्योहार चंद्रमा की तिथि से चलते हैं। ये **सूर्य के राशि बदलने**
/// से — इसलिए इनकी तारीख़ इंजन के `sankrantiInYear` से आती है।
///
/// यहाँ हर पूजा के साथ उसका दिन-नियम भी लिखा है। मकर संक्रांति में पुण्यकाल
/// दिन में रखा जाता है: प्रवेश स्थानीय सूर्यास्त के बाद हो तो अगला दिन।
enum SankrantiDinNiyam { palKaDin, makarPunyaKal }

typedef SankrantiPuja = ({
  String naam,
  String id,
  String kyon,
  SankrantiDinNiyam dinNiyam,
});

const Map<int, SankrantiPuja> sankrantiKiPuja = {
  5: (
    naam: 'विश्वकर्मा पूजा',
    id: 'vishwakarma_pooja',
    kyon: 'कन्या संक्रांति',
    dinNiyam: SankrantiDinNiyam.palKaDin,
  ),
  9: (
    naam: 'मकर संक्रांति',
    id: 'makar_sankranti_pooja',
    kyon: 'मकर संक्रांति · पुण्यकाल',
    dinNiyam: SankrantiDinNiyam.makarPunyaKal,
  ),
};

/// पूजा में दिखाई जाने वाली स्थानीय तारीख़।
DateTime sankrantiPujaDin(
  Sankranti sankranti,
  Place place,
  SankrantiDinNiyam niyam,
) {
  final palKaDin = sankranti.din;
  if (niyam == SankrantiDinNiyam.palKaDin) return palKaDin;

  final p = computePanchang(
    palKaDin.year,
    palKaDin.month,
    palKaDin.day,
    place,
  );
  final suryast = p.sunset;
  // Panchang का सूर्यास्त स्थानीय wall-clock अंक रखता है, पर DateTime का
  // `isUtc` चिन्ह भी बचा रहता है। सीधी तुलना करने पर Dart दूसरी बार zone
  // बदल देता है; इसलिए दोनों को समान local-naive रूप में मिलाएँ।
  final sthaniyaSuryast = suryast == null
      ? null
      : DateTime(
          suryast.year,
          suryast.month,
          suryast.day,
          suryast.hour,
          suryast.minute,
          suryast.second,
        );
  if (sthaniyaSuryast != null && sankranti.pal.isAfter(sthaniyaSuryast)) {
    return palKaDin.add(const Duration(days: 1));
  }
  return palKaDin;
}

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
  //
  // एक दिन पर दो त्योहार भी हो सकते हैं — 2026 में रक्षाबंधन और वरलक्ष्मी
  // व्रत दोनों 28 अगस्त। इसलिए हर दिन की **सूची**, एक त्योहार नहीं।
  final tyoharTarikh = <DateTime, List<FestivalDate>>{};
  for (final saal in {shuru.year, shuru.year + 1}) {
    for (final f in festivalsInYear(saal, place)) {
      if (parvKeHisse.contains(f.rule.name)) continue;
      (tyoharTarikh[_sirfDin(f.date)] ??= []).add(f);
    }
  }

  final khulneWali = {for (final v in pujaayein) v.id: v};

  // ── पहला चरण: त्योहार ──
  //
  // ये पहले इकट्ठे होते हैं क्योंकि साल में कुछ ही बार आते हैं। इन्हें
  // बाद वाली तिथि/वार वाली पूजाओं से धकेला नहीं जाना चाहिए।
  final tyoharAvsar = <PujaAvsar>[];
  final tyoharKiIds = <String>{};

  // ── पितृ पक्ष चल रहा हो — आज का पत्ता ──
  //
  // आरम्भ और सर्वपितृ अमावस्या इंजन के दो नियम हैं। बीच के दिनों में दोनों
  // में से कोई "आज" नहीं होता, और आरम्भ बीत चुका होता है — तब सूची में
  // बस बारह दिन दूर की अमावस्या दिखती, जबकि श्राद्ध **आज** का काम है।
  final pitruAarambh = _pehlaDin(tyoharTarikh, 'पितृ पक्ष आरम्भ', shuru);
  final sarvapitri = _pehlaDin(tyoharTarikh, 'सर्वपितृ अमावस्या', shuru);
  if (sarvapitri != null &&
      shuru.isBefore(sarvapitri) &&
      (pitruAarambh == null || pitruAarambh.isAfter(sarvapitri))) {
    // आरम्भ आगे का नहीं (यानी इस पक्ष का बीत चुका), और अमावस्या आगे है।
    // पर पक्ष से महीनों पहले भी यही हालत दिखेगी — इसलिए पक्का करो कि
    // अमावस्या पंद्रह दिन के भीतर है।
    final baad = sarvapitri.difference(shuru).inDays;
    if (baad <= 15) {
      final khulegi = khulneWali.containsKey('shraadh') ? 'shraadh' : '';
      if (khulegi.isNotEmpty) tyoharKiIds.add(khulegi);
      tyoharAvsar.add(PujaAvsar(
        tarikh: shuru,
        kitneDinBaad: 0,
        pujaId: khulegi,
        naam: 'पितृ पक्ष',
        kyon: 'सर्वपितृ अमावस्या तक',
        karan: AvsarKaKaran.tyohar,
      ));
    }
  }

  for (var i = 0; i <= dinAage; i++) {
    final din = shuru.add(Duration(days: i));
    for (final tyohar in tyoharTarikh[din] ?? const <FestivalDate>[]) {
      final id = tyoharKiPuja[tyohar.rule.name] ?? '';
      final khulegi = khulneWali.containsKey(id) ? id : '';
      // एक पूजा एक ही बार — पितृ पक्ष का आरम्भ और अमावस्या दोनों श्राद्ध
      // खोलते हैं; पहला वाला काफ़ी है।
      if (khulegi.isNotEmpty && !tyoharKiIds.add(khulegi)) continue;
      tyoharAvsar.add(PujaAvsar(
        tarikh: din,
        kitneDinBaad: i,
        pujaId: khulegi,
        naam: tyohar.rule.name,
        kyon: 'त्योहार',
        karan: AvsarKaKaran.tyohar,
        vratId: khulegi.isEmpty ? (tyoharKaVrat[tyohar.rule.name] ?? '') : '',
      ));
    }
  }

  // ── संक्रांति वाली पूजाएँ — त्योहार की तरह, पर सूर्य की राशि से ──
  final sankrantiDin = <DateTime>{};
  for (final saal in {shuru.year, shuru.year + 1}) {
    for (final entry in sankrantiKiPuja.entries) {
      final puja = entry.value;
      final sankranti = sankrantiInYear(saal, entry.key, place);
      final din = sankrantiPujaDin(sankranti, place, puja.dinNiyam);
      // UTC में घटाओ — DST वाले फ़ोन पर स्थानीय दिन 23 घंटे का हो सकता
      // है, और `inDays` एक दिन पीछे गिनता।
      final i = DateTime.utc(din.year, din.month, din.day)
          .difference(DateTime.utc(shuru.year, shuru.month, shuru.day))
          .inDays;
      if (i < 0 || i > dinAage) continue;
      // एक दिन पर एक ही अवसर — उस दिन तिथि वाला त्योहार हो तो वही रहे।
      if (tyoharTarikh.containsKey(din)) continue;

      final khulegi = khulneWali.containsKey(puja.id) ? puja.id : '';
      if (khulegi.isNotEmpty) tyoharKiIds.add(khulegi);
      sankrantiDin.add(din);
      tyoharAvsar.add(PujaAvsar(
        tarikh: din,
        kitneDinBaad: i,
        pujaId: khulegi,
        naam: puja.naam,
        kyon: puja.kyon,
        karan: AvsarKaKaran.tyohar,
      ));
    }
  }

  // ── दूसरा चरण: तिथि और वार वाली पूजाएँ ──
  //
  // जिस पूजा का त्योहार ऊपर आ चुका है वो दोबारा नहीं आती — वरना
  // "गणेश चतुर्थी" और "गणेश पूजन · चतुर्थी" दोनों एक साथ दिखते।
  final baaki = <String, PujaAvsar>{};
  for (var i = 0; i <= dinAage; i++) {
    final din = shuru.add(Duration(days: i));
    if (tyoharTarikh.containsKey(din) || sankrantiDin.contains(din)) continue;

    // ⚡ पूरा पंचांग नहीं — सिर्फ़ सूर्योदय की तिथि और वार। 45 दिन का पूरा
    // पंचांग सस्ते फ़ोन पर होम को एक सेकंड से ज़्यादा अटकाता था; यह वही
    // तिथि ~37 गुना तेज़ देता है (engine का `suryodayaTithi`)।
    final p = suryodayaTithi(din.year, din.month, din.day, place);
    final tithiNumber = p.tithiNumber;
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
          kyon: maasikKyon(tithiNumber, p.pakshaName, p.tithiName),
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

  // ⚠️ त्योहार पहले चुने जाते हैं, फिर बची जगह तिथि-वार वाली पूजाओं से।
  //
  // पहले सब तारीख़ से छाँटकर पहले [kitne] लिए जाते थे। पैंतालीस दिन में
  // हर हफ़्ते वाली पूजाएँ ही पाँचों जगह भर देती थीं, और सात दिन दूर का
  // त्योहार (विश्वकर्मा पूजा) होम पर दिखता ही नहीं था — जबकि ऊपर का
  // "एक पूजा एक ही बार" वाला नियम इसी लिए बना था कि त्योहार को जगह मिले।
  // त्योहार कम होते हैं, इसलिए तिथि वाली पूजाओं की जगह कम ही घेरते हैं।
  int kram(PujaAvsar a, PujaAvsar b) =>
      a.kitneDinBaad.compareTo(b.kitneDinBaad);
  final chune = [
    ...([...tyoharAvsar]..sort(kram)),
    ...(baaki.values.toList()..sort(kram)),
  ].take(kitne).toList()
    ..sort(kram);
  return List.unmodifiable(chune);
}

DateTime _sirfDin(DateTime d) => DateTime(d.year, d.month, d.day);

/// [naam] वाला त्योहार [shuru] या उसके बाद सबसे पहले किस दिन।
DateTime? _pehlaDin(
  Map<DateTime, List<FestivalDate>> tarikh,
  String naam,
  DateTime shuru,
) {
  final din = tarikh.entries
      .where((e) =>
          !e.key.isBefore(shuru) && e.value.any((f) => f.rule.name == naam))
      .map((e) => e.key)
      .toList()
    ..sort();
  return din.isEmpty ? null : din.first;
}

/// हर सालाना त्योहार वाली पूजा की **अगली** तारीख़ — `pujaId → दिन`।
///
/// पूजा section में त्योहार के कार्डों पर छोटी तारीख़ और उनका क्रम इसी से
/// आता है (→ D-086)। सिर्फ़ वो पूजाएँ जिनकी तारीख़ इंजन के त्योहार-नियम
/// ([tyoharKiPuja]) या संक्रांति ([sankrantiKiPuja]) से निकलती है।
///
/// हर महीने वाली पूजाएँ (सत्यनारायण = पूर्णिमा) यहाँ **नहीं** — उनके कार्ड
/// पर "26 सित" लिखना उन्हें साल में एक बार वाला त्योहार जैसा दिखाता।
/// आज पड़ने वाला त्योहार भी गिना जाता है (0 दिन बाद)।
Map<String, DateTime> agliTyoharTarikh({
  required Place place,
  DateTime? aaj,
}) {
  final shuru = _sirfDin(aaj ?? DateTime.now());
  final agli = <String, DateTime>{};

  void rakho(String id, DateTime pal) {
    final din = _sirfDin(pal);
    if (id.isEmpty || din.isBefore(shuru)) return;
    final pehle = agli[id];
    if (pehle == null || din.isBefore(pehle)) agli[id] = din;
  }

  for (final saal in {shuru.year, shuru.year + 1}) {
    for (final f in festivalsInYear(saal, place)) {
      rakho(tyoharKiPuja[f.rule.name] ?? '', f.date);
    }
    for (final entry in sankrantiKiPuja.entries) {
      final puja = entry.value;
      final sankranti = sankrantiInYear(saal, entry.key, place);
      rakho(puja.id, sankrantiPujaDin(sankranti, place, puja.dinNiyam));
    }
  }
  return Map.unmodifiable(agli);
}
