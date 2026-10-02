import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// हल्की गणना (`suryodayaTithi`) को पूरे पंचांग से हर दिन मिलाना।
///
/// कैलेंडर और होम अब यही हल्की गणना दिखाते हैं। अगर यह एक भी दिन पूरे
/// पंचांग से अलग निकली, तो कैलेंडर का खाना और "आज" का पन्ना आपस में
/// अलग तिथि बताएँगे — इसलिए हर शहर, दो साल, हर दिन।
void main() {
  for (final place in [...Place.testCities, Place.mumbai]) {
    test('$place: सूर्योदय की तिथि और वार पूरे पंचांग से मिलते हैं', () {
      var din = DateTime.utc(2026, 1, 1);
      final ant = DateTime.utc(2028, 1, 1);
      var ginti = 0;
      while (din.isBefore(ant)) {
        final poora = computePanchang(din.year, din.month, din.day, place);
        final halka = suryodayaTithi(din.year, din.month, din.day, place);
        final tarikh = '${din.year}-${din.month}-${din.day}';
        expect(halka.tithiIndex, poora.tithi.index, reason: tarikh);
        expect(halka.tithiNumber, poora.tithi.number, reason: tarikh);
        expect(halka.tithiName, poora.tithi.name, reason: tarikh);
        expect(halka.vara, poora.vara, reason: tarikh);
        expect(halka.paksha, poora.paksha, reason: tarikh);
        expect(halka.pakshaName, poora.pakshaName, reason: tarikh);
        din = din.add(const Duration(days: 1));
        ginti++;
      }
      expect(ginti, 730);
    });
  }

  test('festivalsInYear दूसरी बार वही सूची लौटाता है, और बदली नहीं जा सकती', () {
    final pehli = festivalsInYear(2026, Place.delhi);
    final doosri = festivalsInYear(2026, Place.delhi);
    expect(identical(pehli, doosri), isTrue);
    expect(() => pehli.add(pehli.first), throwsUnsupportedError);
    // दूसरे शहर का अपना हिसाब — कैश शहर नहीं मिलाता।
    final chennai = festivalsInYear(2026, Place.chennai);
    expect(identical(pehli, chennai), isFalse);
  });
}
