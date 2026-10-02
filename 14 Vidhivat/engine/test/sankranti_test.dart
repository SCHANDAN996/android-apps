import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// कन्या संक्रांति — विश्वकर्मा पूजा का दिन।
///
/// Drik Panchang (New Delhi) के "Vishwakarma Puja" पन्ने से, हर साल का
/// दिन और "Sankranti Moment" (IST)। छह साल — जिनमें दो ऐसे हैं जहाँ पल
/// शाम को है (2024, 2028) और एक जहाँ रात 1:55 पर (2025)। तीनों में दिन
/// पल की ही तारीख़ है, सूर्योदय वाली नहीं।
void main() {
  const drik = {
    2023: (9, 17, 13, 43),
    2024: (9, 16, 19, 53),
    2025: (9, 17, 1, 55),
    2026: (9, 17, 7, 58),
    2027: (9, 17, 14, 14),
    2028: (9, 16, 20, 23),
  };

  group('कन्या संक्रांति — Drik Panchang से', () {
    for (final MapEntry(key: saal, value: (m, d, h, min)) in drik.entries) {
      test('$saal: $d/$m, $h:${'$min'.padLeft(2, '0')}', () {
        final s = sankrantiInYear(saal, 5, Place.delhi);
        expect(s.rashiNaam, rashiNames[5]);
        expect(s.din, DateTime(saal, m, d), reason: 'दिन');
        final drikPal = DateTime(saal, m, d, h, min);
        final farq = s.pal.difference(drikPal).inSeconds.abs();
        // ⚠️ छह मिनट की छूट — जान-बूझकर। इंजन का सूर्य-गणित लगभग
        // ±10 arcsecond तक सही है, और सूर्य एक दिन में ~59 arcminute चलता
        // है, इसलिए संक्रांति का पल ±5 मिनट हिलता है (2023–2028 में फ़र्क़
        // −5.1 से +3.7 मिनट, दोनों दिशाओं में — यानी कोई स्थिर नियम-भेद नहीं)।
        // दिन पर असर तभी पड़ता जब पल आधी रात के पाँच मिनट के भीतर हो;
        // इन छह सालों में ऐसा नहीं है, और दिन छहों में मिलता है।
        expect(farq, lessThanOrEqualTo(360),
            reason: 'इंजन ${s.pal}, Drik $drikPal');
      });
    }
  });

  test('मकर संक्रांति जनवरी के बीच में पड़ती है', () {
    // तारीख़ का नियम यहाँ नहीं जाँचा — सिर्फ़ यह कि पल सही महीने में है।
    final s = sankrantiInYear(2026, 9, Place.delhi);
    expect(s.pal.month, 1);
    expect(s.pal.day, inInclusiveRange(13, 16));
  });

  test('ग़लत राशि पर साफ़ ग़लती', () {
    expect(() => sankrantiInYear(2026, 12, Place.delhi), throwsArgumentError);
  });
}
