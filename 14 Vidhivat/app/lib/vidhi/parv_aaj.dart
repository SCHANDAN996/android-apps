import 'package:panchang_engine/panchang_engine.dart';

import 'parv.dart';

/// शारदीय नवरात्रि में आज की जगह पंचांग से निकालता है।
///
/// ## हर दिन का नियम अलग है (→ D-073)
///
/// पहले हर दिन — दशमी भी — सिर्फ़ **सूर्योदय की तिथि** से गिना जाता था।
/// 13 सित 2026 को फ़ोन पर पर्व-पन्ना खोला तो 2026 में नवरात्रि 10 दिन की
/// और दशहरा **21 अक्टूबर** दिख रहा था, जबकि प्रचलित पंचांग-पद्धति **20 अक्टूबर**
/// कहती है और महानवमी 19 को। तिथियों के समय ऐप और संदर्भ-गणना में मिनट तक एक
/// थे — ग़लती सिर्फ़ दिन चुनने के नियम में थी।
///
/// | दिन | नियम | स्रोत |
/// |---|---|---|
/// | १–८ | जिस सूर्योदय को तिथि छुए; दो छुए तो **पहला** दिन मुख्य | प्रचलित नवरात्रि पंचांग-क्रम |
/// | ९ महानवमी | नवमी अपने हिंदू दिन के **सायंकाल से पहले** शुरू हो जाए, तो उसी दिन — अष्टमी, संधि पूजा और नवमी एक साथ। वरना उदय-व्यापिनी नवमी | प्रचलित महानवमी-निर्णय |
/// | १० विजयादशमी | **अपराह्न**-व्यापिनी दशमी। दोनों दिन हो तो पहला; किसी दिन न हो तो नवमी-युक्त (पहला), पर दूसरे दिन श्रवण हो तो दूसरा | निर्णय सिन्धु |
///
/// 2024–2028 के पाँचों साल स्वतंत्र दिल्ली संदर्भ-तारीख़ों से जाँचे गए।
ParvAaj navratriAaj({
  required DateTime aaj,
  required Place place,
}) {
  final din = <int, List<DateTime>>{};
  final seema = <int, ({DateTime start, DateTime end})>{};
  final kshaya = <int>{};
  final months = lunarMonthsAround(aaj.year, place);

  for (var ank = 1; ank <= 10; ank++) {
    final mila = findFestival(_navratriNiyam(ank), aaj.year, place, months);
    if (mila == null) continue;
    seema[ank] = (start: mila.tithiStart, end: mila.tithiEnd);

    final udaya = _udayaTarikhein(mila.tithiStart, mila.tithiEnd, place);
    if (udaya.isEmpty) {
      // क्षय — तिथि किसी सूर्योदय को नहीं छूती। इंजन का "प्रबल दिन" वाला
      // नियम (जिस दिन सबसे देर रहे) यहाँ पहले से ठीक है — 2027 की
      // घटस्थापना इसी से संदर्भ-पंचांगों से मिलती है।
      din[ank] = [_sirfTarikh(mila.date)];
      kshaya.add(ank);
    } else {
      din[ank] = udaya;
    }
  }

  // ── दिन ९ — महानवमी ─────────────────────────────────────────────
  //
  // दुर्गा अष्टमी पहला अष्टमी-सूर्योदय है। अष्टमी दो सूर्योदय छुए (2027)
  // तो नवमी दूसरे दिन मिलती है — तब सिर्फ़ संधि पूजा और महानवमी साथ होती
  // हैं, दुर्गा अष्टमी एक दिन पहले। 2027 का संदर्भ-पंचांग भी यही कहता है।
  var navamiKeSaath = _NavamiKeSaath.nahi;
  final navami = seema[9];
  if (navami != null) {
    final hinduDin = _hinduDin(navami.start, place);
    final sayankal = _sayankalShuru(hinduDin, place);
    if (sayankal != null && navami.start.isBefore(sayankal)) {
      din[9] = [hinduDin];
      final ashtami = din[8] ?? const <DateTime>[];
      if (ashtami.isNotEmpty && ashtami.first == hinduDin) {
        navamiKeSaath = _NavamiKeSaath.durgaAshtami;
      } else if (ashtami.contains(hinduDin)) {
        navamiKeSaath = _NavamiKeSaath.sandhiPuja;
      }
    }
  }

  // ── दिन १० — विजयादशमी ──────────────────────────────────────────
  final dashami = seema[10];
  if (dashami != null) {
    din[10] = [_vijayadashami(dashami, place)];
  }

  // एक ही नागरिक तारीख़ पर दो पूजा-दिन — क्षय से, या अष्टमी-नवमी के
  // सायंकाल से पहले मिलने से। बाद वाला दिन "इस साल एक साथ" कहलाता है।
  final mileHue = <int>{};
  for (var ank = 2; ank <= 9; ank++) {
    final isDin = din[ank];
    final pichhla = din[ank - 1];
    if (isDin != null &&
        pichhla != null &&
        isDin.any((tarikh) => pichhla.contains(tarikh))) {
      mileHue.add(ank);
    }
  }

  final navratriTarikhein = <DateTime>{
    for (var ank = 1; ank <= 9; ank++) ...?din[ank],
  }.toList()
    ..sort();
  final shuru = navratriTarikhein.isEmpty ? null : navratriTarikhein.first;
  final antim = navratriTarikhein.isEmpty ? null : navratriTarikhein.last;
  final ant = din[10]?.first ?? antim;
  final aajKiTarikh = _sirfTarikh(aaj);

  final pratipada = findFestival(_navratriNiyam(1), aaj.year, place);
  final ghata = pratipada == null
      ? null
      : _ghatasthapanaKaSamay(pratipada: pratipada, place: place);
  final sandhiMadhya = seema[8]?.end;

  int? aajKaDin;
  for (var ank = 1; ank <= 10; ank++) {
    if (din[ank]?.contains(aajKiTarikh) ?? false) {
      // एक तारीख़ पर दो दिन हों तो बाद वाला दिन "आज" रहता है, और पहले
      // पर "इस साल एक साथ" का संकेत मिलता है।
      aajKaDin = ank;
    }
  }

  final kitneDinBaad = shuru != null && aajKiTarikh.isBefore(shuru)
      ? shuru.difference(aajKiTarikh).inDays
      : null;
  final kulDin = navratriTarikhein.length;

  return ParvAaj(
    aajKaDin: aajKaDin,
    kitneDinBaad: kitneDinBaad,
    shuruTarikh: shuru,
    antTarikh: ant,
    kulDin: kulDin,
    tippani: _tippani(
      kulDin: kulDin,
      din: din,
      kshaya: kshaya,
      navamiKeSaath: navamiKeSaath,
    ),
    mileHueDin: Set.unmodifiable(mileHue),
    dinTarikhein: Map.unmodifiable({
      for (final entry in din.entries)
        entry.key: List<DateTime>.unmodifiable(entry.value),
    }),
    ghatasthapanaShuru: ghata?.shuru,
    ghatasthapanaAnt: ghata?.ant,
    ghatasthapanaAbhijitShuru: ghata?.abhijitShuru,
    ghatasthapanaAbhijitAnt: ghata?.abhijitAnt,
    sandhiShuru: sandhiMadhya?.subtract(const Duration(minutes: 24)),
    sandhiAnt: sandhiMadhya?.add(const Duration(minutes: 24)),
  );
}

/// वे नागरिक तारीख़ें जिनके सूर्योदय पर तिथि चल रही हो — क्रम में।
List<DateTime> _udayaTarikhein(DateTime start, DateTime end, Place place) {
  final tarikhein = <DateTime>[];
  final pehli = _sirfTarikh(start).subtract(const Duration(days: 1));
  for (var i = 0; i <= 3; i++) {
    final tarikh = pehli.add(Duration(days: i));
    final uday = _suryoday(tarikh, place);
    if (uday == null) continue;
    if (!uday.isBefore(start) && uday.isBefore(end)) tarikhein.add(tarikh);
  }
  return tarikhein;
}

/// वह हिंदू दिन (सूर्योदय से अगले सूर्योदय तक) जिसमें यह क्षण पड़ता है।
DateTime _hinduDin(DateTime kshan, Place place) {
  final tarikh = _sirfTarikh(kshan);
  final uday = _suryoday(tarikh, place);
  if (uday != null && kshan.isBefore(uday)) {
    return tarikh.subtract(const Duration(days: 1));
  }
  return tarikh;
}

/// सायंकाल — दिन के पाँच भागों में आख़िरी (सूर्यास्त से दिनमान का पाँचवाँ
/// हिस्सा पहले से सूर्यास्त तक)। अपराह्न इसके ठीक पहले का भाग है।
DateTime? _sayankalShuru(DateTime tarikh, Place place) {
  final aparahna = kaalWindow(
      Vyapini.aparahna, tarikh.year, tarikh.month, tarikh.day, place);
  return aparahna?.end;
}

/// विजयादशमी — अपराह्न-व्यापिनी दशमी, निर्णय सिन्धु के नियम से।
DateTime _vijayadashami(({DateTime start, DateTime end}) dashami, Place place) {
  final pehla = _hinduDin(dashami.start, place);
  final doosra = pehla.add(const Duration(days: 1));

  bool aparahnaMe(DateTime tarikh) {
    final kaal = kaalWindow(
        Vyapini.aparahna, tarikh.year, tarikh.month, tarikh.day, place);
    if (kaal == null) return false;
    return dashami.start.isBefore(kaal.end) && dashami.end.isAfter(kaal.start);
  }

  final pehleDin = aparahnaMe(pehla);
  final doosreDin = aparahnaMe(doosra);

  if (pehleDin && !doosreDin) return pehla;
  if (!pehleDin && doosreDin) return doosra;
  if (pehleDin && doosreDin) return pehla;

  // किसी दिन अपराह्न में दशमी नहीं — नवमी-युक्त दशमी (पहला दिन), पर दूसरे
  // दिन श्रवण नक्षत्र हो तो एकादशी-युक्त (दूसरा दिन)।
  return _shravanAparahnaMe(doosra, place) ? doosra : pehla;
}

bool _shravanAparahnaMe(DateTime tarikh, Place place) {
  final kaal = kaalWindow(
      Vyapini.aparahna, tarikh.year, tarikh.month, tarikh.day, place);
  if (kaal == null) return false;
  final p = computePanchang(tarikh.year, tarikh.month, tarikh.day, place);
  for (final n in p.nakshatras) {
    if (!n.name.contains('श्रवण')) continue;
    final start = n.startsAt;
    final end = n.endsAt;
    if (start == null || end == null) continue;
    if (start.isBefore(kaal.end) && end.isAfter(kaal.start)) return true;
  }
  return false;
}

DateTime? _suryoday(DateTime tarikh, Place place) {
  final rise =
      sunriseSunset(tarikh.year, tarikh.month, tarikh.day, place).sunrise;
  return rise?.add(place.timeZoneOffset);
}

({
  DateTime? shuru,
  DateTime? ant,
  DateTime? abhijitShuru,
  DateTime? abhijitAnt,
}) _ghatasthapanaKaSamay({
  required FestivalDate pratipada,
  required Place place,
}) {
  final p = computePanchang(
    pratipada.date.year,
    pratipada.date.month,
    pratipada.date.day,
    place,
  );
  if (p.sunrise == null || p.dinamana == null) {
    return (shuru: null, ant: null, abhijitShuru: null, abhijitAnt: null);
  }

  // मुख्य खिड़की: दिन का पहला तिहाई, पर केवल प्रतिपदा के भीतर।
  final pehlaTihaiAnt = p.sunrise!.add(p.dinamana! * (1 / 3));
  final shuru = pratipada.tithiStart.isAfter(p.sunrise!)
      ? pratipada.tithiStart
      : p.sunrise!;
  final ant = pratipada.tithiEnd.isBefore(pehlaTihaiAnt)
      ? pratipada.tithiEnd
      : pehlaTihaiAnt;

  // मुख्य खिड़की न मिले तो अभिजित का वही हिस्सा जो प्रतिपदा में हो।
  DateTime? abhijitShuru;
  DateTime? abhijitAnt;
  final abhijit = p.abhijit;
  if (abhijit != null) {
    abhijitShuru = pratipada.tithiStart.isAfter(abhijit.start)
        ? pratipada.tithiStart
        : abhijit.start;
    abhijitAnt = pratipada.tithiEnd.isBefore(abhijit.end)
        ? pratipada.tithiEnd
        : abhijit.end;
    if (!abhijitShuru.isBefore(abhijitAnt)) {
      abhijitShuru = null;
      abhijitAnt = null;
    }
  }

  return (
    shuru: shuru.isBefore(ant) ? shuru : null,
    ant: shuru.isBefore(ant) ? ant : null,
    abhijitShuru: abhijitShuru,
    abhijitAnt: abhijitAnt,
  );
}

FestivalRule _navratriNiyam(int ank) => FestivalRule(
      id: 'navratri_din_$ank',
      name: ank == 10 ? 'विजयादशमी' : 'नवरात्रि दिन $ank',
      masa: 6,
      paksha: 0,
      tithi: ank,
      vyapini: Vyapini.sunrise,
    );

enum _NavamiKeSaath { nahi, durgaAshtami, sandhiPuja }

String? _tippani({
  required int kulDin,
  required Map<int, List<DateTime>> din,
  required Set<int> kshaya,
  required _NavamiKeSaath navamiKeSaath,
}) {
  final vakya = <String>[];

  final vriddhi = [
    for (var ank = 1; ank <= 8; ank++)
      if ((din[ank]?.length ?? 0) > 1) ank,
  ];
  if (vriddhi.isNotEmpty) {
    vakya.add('${vriddhi.map(_tithiNaam).join(' और ')} दो सूर्योदय तक है।');
  }

  final kshayaDin = [
    for (final ank in kshaya)
      if (ank >= 2 && ank <= 8) ank,
  ]..sort();
  if (kshayaDin.isNotEmpty) {
    vakya.add('${kshayaDin.map(_tithiNaam).join(' और ')} किसी सूर्योदय को '
        'नहीं छूती, इसलिए उसकी पूजा पड़ोस के दिन के साथ होगी।');
  }

  switch (navamiKeSaath) {
    case _NavamiKeSaath.durgaAshtami:
      vakya.add('अष्टमी और नवमी सायंकाल से पहले मिल रही हैं, इसलिए दुर्गा '
          'अष्टमी, संधि पूजा और महानवमी एक ही दिन हैं।');
    case _NavamiKeSaath.sandhiPuja:
      vakya.add('नवमी अष्टमी के दूसरे दिन सायंकाल से पहले शुरू हो रही है, '
          'इसलिए संधि पूजा और महानवमी एक ही दिन हैं।');
    case _NavamiKeSaath.nahi:
      break;
  }

  if (vakya.isEmpty) return null;
  return 'इस साल ${vakya.join(' ')} नवरात्रि $kulDin दिन की है।';
}

String _tithiNaam(int ank) => const [
      '',
      'प्रतिपदा',
      'द्वितीया',
      'तृतीया',
      'चतुर्थी',
      'पंचमी',
      'षष्ठी',
      'सप्तमी',
      'अष्टमी',
      'नवमी',
      'दशमी',
    ][ank];

DateTime _sirfTarikh(DateTime tarikh) =>
    DateTime.utc(tarikh.year, tarikh.month, tarikh.day);
