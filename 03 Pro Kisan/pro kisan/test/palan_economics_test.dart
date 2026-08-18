import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/palan/palan_data.dart';

PalanGuide _g(String id) => palanById(id)!;

void main() {
  test('📊 तेरहों पालन का असली हिसाब', () {
    // ignore: avoid_print
    print('${'palan'.padRight(12)}${'setup'.padLeft(9)}${'chakraKh'.padLeft(10)}'
        '${'chakraAam'.padLeft(11)}${'chakraMun'.padLeft(11)}'
        '${'chakra/saal'.padLeft(12)}${'saalMun'.padLeft(10)}${'payback'.padLeft(11)}');
    for (final g in kPalanGuides) {
      final pb = g.paybackMonths;
      // ignore: avoid_print
      print('${g.id.padRight(12)}'
          '${g.setupCost.toString().padLeft(9)}'
          '${g.cycleCost.toString().padLeft(10)}'
          '${g.cycleIncome.toString().padLeft(11)}'
          '${g.cycleProfit.toString().padLeft(11)}'
          '${g.cyclesPerYear.toStringAsFixed(1).padLeft(12)}'
          '${g.yearlyProfit.toString().padLeft(10)}'
          '${(pb == null ? 'GHATA' : '${pb.toStringAsFixed(0)} mah').padLeft(11)}');
    }
  });

  group('लागत-मुनाफ़े का हिसाब', () {
    test('किसी भी पालन में चक्र का घाटा नहीं दिखना चाहिए', () {
      final losing = kPalanGuides.where((g) => g.cycleProfit <= 0).map((g) => g.id).toList();
      expect(losing, isEmpty,
          reason: 'इनमें अब भी घाटा दिख रहा है: $losing — मतलब ख़र्च का बँटवारा ग़लत है');
    });

    test('हर पालन में एक-बार और हर-बार दोनों तरह का ख़र्च है', () {
      for (final g in kPalanGuides) {
        expect(g.setupCost, greaterThan(0), reason: '${g.id} — शुरुआती ख़र्च शून्य');
        expect(g.cycleCost, greaterThan(0), reason: '${g.id} — चक्र का ख़र्च शून्य');
      }
    });

    test('बकरी — पहले लाल में −49,000 दिखता था, अब असली मुनाफ़ा', () {
      final g = _g('bakri');
      expect(g.setupCost, 110000);        // 85,000 बकरी + 25,000 शेड
      expect(g.cycleCost, 45000);         // 40,000 दाना + 5,000 दवा
      expect(g.cycleIncome, 106000);
      expect(g.cycleProfit, 61000);       // पहले −49,000 दिखता था
      expect(g.yearlyProfit, 61000);
      expect(g.paybackMonths, closeTo(21.6, 0.5));  // ~1 साल 9 माह
    });

    test('ब्रॉयलर — 45 दिन के चक्र में शेड नहीं जुड़ना चाहिए', () {
      final g = _g('broiler');
      expect(g.setupCost, 200000);        // सिर्फ़ शेड
      expect(g.cycleCost, 210000);        // चूज़े + दाना + दवा
      expect(g.cycleProfit, 9000);        // गाइड का note भी यही कहता है
      expect(g.cyclesPerYear, 8);         // 12 ÷ 1.5
      expect(g.yearlyProfit, 72000);
    });

    test('एमू — 2 साल का चक्र सही गिना जाता है', () {
      final g = _g('emu');
      expect(g.cycleMonths, 24);
      expect(g.cyclesPerYear, 0.5);
      // चूज़े हर चक्र नए ख़रीदने पड़ते हैं, इसलिए वे चक्र-ख़र्च में हैं
      expect(g.cycleCost, 250000);        // 50,000 चूज़े + 1,80,000 दाना + 20,000 दवा
      expect(g.cycleProfit, 36000);       // पहले −1,64,000 दिखता था
      expect(g.yearlyProfit, 18000);
      // बाड़ा निकलने में 11 साल — गाइड की अपनी चेतावनी से मेल खाता है
      expect(g.paybackMonths, greaterThan(100));
    });

    test('बटेर और भेड़ भी अब मुनाफ़े में', () {
      expect(_g('quail').cycleProfit, 10000);
      expect(_g('sheep').cycleProfit, 150000);
    });

    test('हर पालन का चक्र-समय भरा है', () {
      for (final g in kPalanGuides) {
        expect(g.cycleMonths, greaterThan(0), reason: g.id);
        expect(g.priceAsOf, isNotEmpty, reason: g.id);
      }
    });
  });
}
