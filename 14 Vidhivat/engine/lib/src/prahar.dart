import 'place.dart';
import 'sunrise.dart';

/// **प्रहर** — दिन के चार, रात के चार।
///
/// सूर्योदय से सूर्यास्त तक का समय चार बराबर हिस्सों में बँटता है — वे दिन
/// के चार प्रहर। सूर्यास्त से अगले सूर्योदय तक के चार, रात के। आठों मिलकर
/// एक अहोरात्र।
///
/// ⚠️ **प्रहर तीन घंटे का नहीं होता।** किताबें "एक प्रहर = तीन घंटे"
/// लिखती हैं क्योंकि आठ प्रहर चौबीस घंटे में आते हैं — पर वो औसत है।
/// जून में दिल्ली का दिन का प्रहर साढ़े तीन घंटे का होता है और रात का ढाई
/// घंटे से भी कम। दिसंबर में ठीक उल्टा।
///
/// ## यह फ़ाइल क्यों बनी
///
/// **सूतक** के लिए (→ D-054)। चंद्रग्रहण का सूतक "तीन प्रहर पहले" लगता
/// है। हमने पहले उसे सीधा नौ घंटे घटाकर निकाला था — और Drik Panchang से
/// मिलाने पर वो **उनतालीस मिनट** ग़लत निकला, क्योंकि असली नियम घड़ी के
/// नौ घंटे नहीं, **तीन प्रहर पीछे वाले प्रहर की शुरुआत** है।

/// एक अहोरात्र में कितने प्रहर।
const int praharEkDinMein = 8;

/// बच्चों, बूढ़ों और बीमारों के लिए सूतक कितने प्रहर पहले — सिर्फ़ एक।
///
/// सूर्यग्रहण और चंद्रग्रहण, दोनों में यही। छपी पद्धतियाँ उन्हें पूरे तीन
/// या चार प्रहर भूखा रहने को नहीं कहतीं।
const int komalJanoKeSutakKePrahar = 1;

/// [kshan] जिस प्रहर में पड़ता है, उससे [kitne] प्रहर पीछे वाले प्रहर की
/// **शुरुआत**।
///
/// यही सूतक का असली सूत्र है। `kitne = 0` देने पर उसी प्रहर की शुरुआत
/// मिलती है जिसमें [kshan] है।
///
/// ⚠️ [kshan] **असली UTC पल** होना चाहिए — घड़ी-वाला नक़ली UTC नहीं
/// (`muhurta.dart` वाली परिपाटी यहाँ नहीं चलती, → D-043)।
///
/// ध्रुवीय इलाक़ों में जहाँ सूरज उगता-डूबता ही नहीं, वहाँ `null`।
DateTime? praharPeeche(DateTime kshan, Place place, int kitne) {
  final seemaayen = praharKiSeemaayen(kshan, place);

  // वह आख़िरी सीमा जो [kshan] से पहले (या ठीक उसी पल) पड़ती है — यानी
  // उस प्रहर की शुरुआत जिसमें [kshan] है।
  var abKa = -1;
  for (var i = 0; i < seemaayen.length; i++) {
    if (seemaayen[i].isAfter(kshan)) break;
    abKa = i;
  }

  final chahiye = abKa - kitne;
  if (abKa < 0 || chahiye < 0) return null;
  return seemaayen[chahiye];
}

/// [kshan] के आसपास के प्रहरों की शुरुआतें, बढ़ते क्रम में।
///
/// तीन दिन पीछे से दो दिन आगे तक — यानी लगभग चालीस प्रहर। सूतक को तीन
/// चाहिए, इसलिए गुंजाइश काफ़ी है।
List<DateTime> praharKiSeemaayen(
  DateTime kshan,
  Place place, {
  int pichleDin = 3,
  int aageDin = 2,
}) {
  // स्थानीय तारीख़ — सूर्योदय हमेशा स्थानीय दिन का होता है।
  final sthaniya = kshan.add(place.timeZoneOffset);
  final pehlaDin = DateTime.utc(sthaniya.year, sthaniya.month, sthaniya.day)
      .subtract(Duration(days: pichleDin));

  // पहले सारे दिनों के उदय-अस्त निकालो — रात का प्रहर **अगले** दिन के
  // सूर्योदय तक जाता है, इसलिए एक दिन ज़्यादा चाहिए।
  final kulDin = pichleDin + aageDin + 1;
  final uday = <DateTime?>[];
  final ast = <DateTime?>[];
  for (var i = 0; i <= kulDin; i++) {
    final d = pehlaDin.add(Duration(days: i));
    final ss = sunriseSunset(d.year, d.month, d.day, place);
    uday.add(ss.sunrise);
    ast.add(ss.sunset);
  }

  final seemaayen = <DateTime>[];
  for (var i = 0; i < kulDin; i++) {
    final aajUday = uday[i];
    final aajAst = ast[i];
    final kalUday = uday[i + 1];
    // ध्रुवीय इलाक़ा — उस दिन के प्रहर बनते ही नहीं।
    if (aajUday == null || aajAst == null || kalUday == null) continue;

    final dinKaPrahar = aajAst.difference(aajUday) ~/ 4;
    final raatKaPrahar = kalUday.difference(aajAst) ~/ 4;

    for (var j = 0; j < 4; j++) {
      seemaayen.add(aajUday.add(dinKaPrahar * j));
    }
    for (var j = 0; j < 4; j++) {
      seemaayen.add(aajAst.add(raatKaPrahar * j));
    }
  }

  seemaayen.sort((a, b) => a.compareTo(b));
  return seemaayen;
}
