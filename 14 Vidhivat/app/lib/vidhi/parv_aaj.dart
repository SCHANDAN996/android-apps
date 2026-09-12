import 'package:panchang_engine/panchang_engine.dart';

import 'parv.dart';

/// शारदीय नवरात्रि में आज की जगह पंचांग से निकालता है।
///
/// दिन १–९ आश्विन शुक्ल पक्ष की अपनी तिथि से जुड़ते हैं। कोई तिथि
/// सूर्योदय को न छुए तो इंजन का क्षय-वाला व्यापिनी नियम उसे पड़ोस की
/// तारीख़ पर रखता है; दो सूर्योदय छुए तो दोनों तारीख़ें मानकर वृद्धि
/// दिखाई जाती है। दशमी को विजयादशमी के लिए दिन १० रखा गया है।
ParvAaj navratriAaj({
  required DateTime aaj,
  required Place place,
}) {
  final din = <int, Set<DateTime>>{};
  final mileHue = <int>{};

  for (var ank = 1; ank <= 10; ank++) {
    final mila = findFestival(_navratriNiyam(ank), aaj.year, place);
    if (mila == null) continue;
    din[ank] = {
      _sirfTarikh(mila.date),
      if (mila.ambiguous && mila.otherCandidate != null)
        _sirfTarikh(mila.otherCandidate!),
    };
  }

  // क्षय में दो पूजा-दिन एक ही नागरिक तारीख़ पर आते हैं। बाद वाला दिन
  // "इस साल एक साथ" कहलाता है, ताकि सूची में दोनों अलग पढ़े जा सकें।
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
  final navami = navratriTarikhein.isEmpty ? null : navratriTarikhein.last;
  final dashami = <DateTime>[...?din[10]]..sort();
  final ant = dashami.isEmpty ? navami : dashami.last;
  final aajKiTarikh = _sirfTarikh(aaj);

  final pratipada = findFestival(_navratriNiyam(1), aaj.year, place);
  final ghata = pratipada == null
      ? null
      : _ghatasthapanaKaSamay(pratipada: pratipada, place: place);
  final ashtami = findFestival(_navratriNiyam(8), aaj.year, place);
  final sandhiMadhya = ashtami?.tithiEnd;

  int? aajKaDin;
  for (var ank = 1; ank <= 10; ank++) {
    if (din[ank]?.contains(aajKiTarikh) ?? false) {
      // क्षय में एक ही तारीख़ पर दो दिन हैं। सूची में बाद वाला दिन मुख्य
      // "आज" रहता है और पहले पर "इस साल एक साथ" का संकेत मिलता है।
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
    tippani: _tippani(kulDin, mileHue, din),
    mileHueDin: Set.unmodifiable(mileHue),
    ghatasthapanaShuru: ghata?.shuru,
    ghatasthapanaAnt: ghata?.ant,
    ghatasthapanaAbhijitShuru: ghata?.abhijitShuru,
    ghatasthapanaAbhijitAnt: ghata?.abhijitAnt,
    sandhiShuru: sandhiMadhya?.subtract(const Duration(minutes: 24)),
    sandhiAnt: sandhiMadhya?.add(const Duration(minutes: 24)),
  );
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

String? _tippani(
  int kulDin,
  Set<int> mileHue,
  Map<int, Set<DateTime>> din,
) {
  if (mileHue.isNotEmpty) {
    final naam = mileHue.map((ank) => _tithiNaam(ank)).join(' और ');
    return 'इस साल $naam सूर्योदय को अलग दिन नहीं मिली, इसलिए उससे '
        'जुड़ी पूजा पिछले दिन के साथ होगी। नवरात्रि $kulDin दिन की है।';
  }

  final vriddhi = <int>[];
  for (var ank = 1; ank <= 9; ank++) {
    if ((din[ank]?.length ?? 0) > 1) vriddhi.add(ank);
  }
  if (vriddhi.isNotEmpty) {
    final naam = vriddhi.map(_tithiNaam).join(' और ');
    return 'इस साल $naam दो सूर्योदय तक है, इसलिए नवरात्रि '
        '$kulDin दिन की है।';
  }
  return null;
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
