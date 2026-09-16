import 'package:flutter_test/flutter_test.dart';

import 'package:jameen_napi/data/app_language.dart';
import 'package:jameen_napi/data/land_units.dart';
import 'package:jameen_napi/widgets/map_result_sheet.dart';

/// नतीजा किस इकाई में दिखे, यह किसान के लिए सबसे अहम बात है: बिहार में
/// "0.004 बीघा" बेकार है, "5.4 धुर" काम का है।
void main() {
  final hi = AppStrings(AppLang.hindi);

  group('primaryUnitFor', () {
    test('बिहार: छोटा खेत धुर में, बड़ा कट्ठा/बीघा में', () {
      expect(primaryUnitFor('बिहार / झारखंड', 300).en, 'Dhur');
      expect(primaryUnitFor('बिहार / झारखंड', 5000).en, 'Katha');
      expect(primaryUnitFor('बिहार / झारखंड', 60000).en, 'Bigha');
    });

    test('धुर से भी छोटा टुकड़ा — सबसे छोटी राज्य इकाई ही', () {
      expect(primaryUnitFor('बिहार / झारखंड', 10).en, 'Dhurki / Farki');
    });

    test('पंजाब: मरला और कनाल', () {
      expect(primaryUnitFor('पंजाब / हरियाणा', 300).en, 'Marla');
      expect(primaryUnitFor('पंजाब / हरियाणा', 6000).en, 'Kanal');
    });

    test('राज्य न चुना हो तो एकड़ / डिसमिल / वर्ग फीट', () {
      expect(primaryUnitFor(standardStateKey, 100000).en, 'Acre');
      expect(primaryUnitFor(standardStateKey, 5000).en, 'Dismil / Decimal');
      expect(primaryUnitFor(standardStateKey, 100).en, 'Sq. Feet');
    });

    test('किसी भी इकाई में संख्या 1 से कम नहीं आती', () {
      for (final state in [standardStateKey, 'बिहार / झारखंड', 'महाराष्ट्र']) {
        for (final sqft in [50.0, 900.0, 20000.0, 900000.0]) {
          final u = primaryUnitFor(state, sqft);
          expect(sqft / u.sqft >= 1 || u.en == 'Sq. Feet', isTrue,
              reason: '$state @ $sqft → ${u.en}');
        }
      }
    });
  });

  group('formatDistance', () {
    test('1 किमी से कम — मीटर और फीट दोनों', () {
      final s = formatDistance(hi, 850);
      expect(s, contains('850'));
      expect(s, contains('2,789')); // फीट
    });

    test('1 किमी से ज़्यादा — किमी में', () {
      expect(formatDistance(hi, 2350), '2.35 किमी');
    });

    test('शून्य दूरी पर crash नहीं', () {
      expect(formatDistance(hi, 0), contains('0'));
    });
  });

  group('formatMeasured', () {
    test('नक्शे की नाप में झूठी सटीकता नहीं — 2 दशमलव तक', () {
      expect(formatMeasured(2.34567), '2.35');
      expect(formatMeasured(0.5), '0.5');
    });

    test('बड़ी संख्या भारतीय अंक-समूहन में, बिना दशमलव', () {
      expect(formatMeasured(123456.78), '1,23,457');
    });
  });
}
