import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/math/concrete_calculator.dart';
import 'package:mistri_calculator/core/math/plaster_calculator.dart';
import 'package:mistri_calculator/core/services/ad_service.dart';
import 'package:mistri_calculator/core/utils/purchase.dart';
import 'package:mistri_calculator/core/utils/unit_converter.dart';

void main() {
  group('roundUpToBuy', () {
    test('a part bag means one more bag', () {
      expect(roundUpToBuy(7.3), 8);
      expect(roundUpToBuy(0.2), 1);
    });

    test('a whole number stays, even with floating-point dust', () {
      expect(roundUpToBuy(8), 8);
      expect(roundUpToBuy(8.0000000001), 8);
    });

    test('nothing to buy for zero or less', () {
      expect(roundUpToBuy(0), 0);
      expect(roundUpToBuy(-1), 0);
    });
  });

  group('small units', () {
    test('feet users type inches, metre users type mm', () {
      expect(UnitConverter.smallUnit('ft'), 'in');
      expect(UnitConverter.smallUnit('m'), 'mm');
      expect(UnitConverter.smallToMeters(5, 'ft'), closeTo(0.127, 1e-9));
      expect(UnitConverter.smallToMeters(125, 'm'), closeTo(0.125, 1e-9));
    });
  });

  group('ConcreteCalculator', () {
    final m20 = ConcreteCalculator.m20;

    test('a 10x10 ft slab, 5 inch thick, M20', () {
      final r = ConcreteCalculator.calculateSlab(
        length: 10,
        width: 10,
        thicknessM: UnitConverter.smallToMeters(5, 'ft'),
        unit: 'ft',
        grade: m20,
      );
      // 3.048 x 3.048 x 0.127 = 1.18 m3
      expect(r.wetVolume, closeTo(1.18, 0.005));
      // 1.18 x 1.54 x 1.05 / 5.5 parts / 0.0347 = ~10 bags
      expect(r.cementBags, closeTo(10.0, 0.1));
      expect(r.cementBagsToBuy, 10);
      expect(r.aggregateCFT, closeTo(r.sandCFT * 2, 0.01));
    });

    test('four 9x12 inch columns, 10 ft tall', () {
      final r = ConcreteCalculator.calculateColumnBeam(
        count: 4,
        length: 10,
        widthM: UnitConverter.smallToMeters(9, 'ft'),
        depthM: UnitConverter.smallToMeters(12, 'ft'),
        unit: 'ft',
        grade: m20,
      );
      // 4 x 3.048 x 0.2286 x 0.3048 = 0.85 m3
      expect(r.wetVolume, closeTo(0.85, 0.005));
    });

    test('buying quantities never fall below the calculated ones', () {
      final r = ConcreteCalculator.calculateSlab(
        length: 12,
        width: 11,
        thicknessM: 0.125,
        unit: 'ft',
        grade: m20,
      );
      expect(r.cementBagsToBuy, greaterThanOrEqualTo(r.cementBags));
      expect(r.sandCftToBuy, greaterThanOrEqualTo(r.sandCFT));
      expect(r.aggregateCftToBuy, greaterThanOrEqualTo(r.aggregateCFT));
    });
  });

  group('PlasterCalculator', () {
    test('100 sq m of 12 mm plaster at 1:4 includes the surface allowance', () {
      final r = PlasterCalculator.calculate(
        areaM2: 100,
        thicknessM: PlasterCalculator.innerThickness,
        ratioC: 1,
        ratioS: 4,
      );
      // 100 x 0.012 x 1.33 x 1.20 / 5 parts / 0.0347 = ~11 bags
      expect(r.cementBags, closeTo(11.04, 0.05));
      expect(r.cementBagsToBuy, 12);
    });
  });

  group('interstitial timing', () {
    final now = DateTime(2026, 10, 3, 12);

    bool show({
      bool hadFreshResult = true,
      int calcsSinceLast = AdService.calcsPerInterstitial,
      DateTime? lastShownAt,
    }) => AdService.shouldShowInterstitial(
      hadFreshResult: hadFreshResult,
      calcsSinceLast: calcsSinceLast,
      lastShownAt: lastShownAt,
      now: now,
    );

    test('shows after enough calculations when leaving a result', () {
      expect(show(), isTrue);
    });

    test('never on a screen where nothing was calculated', () {
      expect(show(hadFreshResult: false), isFalse);
    });

    test('not before enough calculations', () {
      expect(show(calcsSinceLast: 2), isFalse);
    });

    test('not twice within the minimum gap', () {
      expect(
        show(lastShownAt: now.subtract(const Duration(minutes: 1))),
        isFalse,
      );
      expect(
        show(lastShownAt: now.subtract(AdService.minInterstitialGap)),
        isTrue,
      );
    });
  });
}
