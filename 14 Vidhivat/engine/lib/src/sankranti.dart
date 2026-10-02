import 'julian.dart';
import 'names.dart';
import 'panchang.dart';
import 'place.dart';

/// **संक्रांति** — वह पल जब सूर्य (निरयण) नई राशि में जाता है।
///
/// ## यह तिथि वाले त्योहारों से अलग क्यों है
///
/// ज़्यादातर पर्व चंद्रमा की तिथि से चलते हैं, इसलिए हर साल अंग्रेज़ी
/// तारीख़ बदलती है। संक्रांति वाले पर्व — मकर संक्रांति, विश्वकर्मा पूजा
/// (कन्या संक्रांति) — **सूर्य की राशि** से चलते हैं, इसलिए लगभग उसी
/// तारीख़ पर आते हैं। पर "लगभग" ही: 2024 में कन्या संक्रांति 16 सितम्बर
/// की शाम थी, 2025 में 17 सितम्बर की रात 1:55 पर।
///
/// ## गणित
///
/// वही `sunSiderealAt` जो मास और अधिक मास में लगता है (लाहिरी अयनांश)।
/// पहले दिन-दिन आगे बढ़कर वह दिन ढूँढा जाता है जिसमें राशि बदली, फिर
/// बीच को आधा-आधा करके पल एक सेकंड के भीतर।
///
/// ## कितना सही
///
/// Drik Panchang से पल **±5 मिनट** तक मिलता है (सूर्य-गणित की अपनी सीमा)।
/// इसलिए जो पल स्थानीय आधी रात के पाँच मिनट के भीतर पड़े, उसका दिन
/// छपे पंचांग से मिला लेना चाहिए। 2023–2028 में ऐसा कोई साल नहीं है।
///
/// ⚠️ कौन-सा दिन मनाया जाए, यह हर संक्रांति-पर्व का अपना नियम है।
/// यहाँ सिर्फ़ **पल** और उस पल की **स्थानीय तारीख़** है — विश्वकर्मा
/// पूजा के लिए Drik Panchang यही तारीख़ लेता है (2023–2028 मिलाकर देखा,
/// `test/sankranti_test.dart`)। मकर संक्रांति का नियम अलग है (सूर्यास्त
/// के बाद हो तो अगला दिन), वह अभी यहाँ नहीं लगाया गया।
class Sankranti {
  /// 0 = मेष … 5 = कन्या … 9 = मकर … 11 = मीन।
  final int rashi;

  /// संक्रांति का पल, [place] के स्थानीय समय में।
  final DateTime pal;

  const Sankranti({required this.rashi, required this.pal});

  String get rashiNaam => rashiNames[rashi];

  /// पल की स्थानीय तारीख़ (समय बेमानी)।
  DateTime get din => DateTime(pal.year, pal.month, pal.day);
}

/// [year] में सूर्य का [rashi] में प्रवेश — [place] के स्थानीय समय में।
///
/// हर राशि में सूर्य साल में एक ही बार जाता है, इसलिए एक ही जवाब है।
Sankranti sankrantiInYear(int year, int rashi, Place place) {
  if (rashi < 0 || rashi > 11) {
    throw ArgumentError.value(rashi, 'rashi', '0 से 11 के बीच होनी चाहिए');
  }
  int rashiAt(double jd) => (sunSiderealAt(jd) / 30.0).floor() % 12;

  // स्थानीय आधी रात से स्थानीय आधी रात तक — ताकि 1 जनवरी की सुबह वाली
  // संक्रांति भी इसी साल में गिनी जाए।
  final tzDin = place.timeZoneOffset.inMinutes / 1440.0;
  var jd = julianDay(year, 1, 1.0) - tzDin;
  final ant = julianDay(year + 1, 1, 1.0) - tzDin;

  var pehle = rashiAt(jd);
  while (jd < ant) {
    final agla = jd + 1.0;
    final baad = rashiAt(agla);
    if (baad == rashi && pehle != rashi) {
      // इस एक दिन के भीतर राशि बदली — आधा-आधा करके पल ढूँढो।
      var neeche = jd, upar = agla;
      while ((upar - neeche) * 86400 > 1) {
        final beech = (neeche + upar) / 2;
        if (rashiAt(beech) == rashi) {
          upar = beech;
        } else {
          neeche = beech;
        }
      }
      final utc = utcFromJulianDay(upar);
      final sthaniya = utc.add(place.timeZoneOffset);
      return Sankranti(
        rashi: rashi,
        pal: DateTime(sthaniya.year, sthaniya.month, sthaniya.day,
            sthaniya.hour, sthaniya.minute, sthaniya.second),
      );
    }
    pehle = baad;
    jd = agla;
  }
  throw StateError('$year में राशि $rashi की संक्रांति नहीं मिली');
}
