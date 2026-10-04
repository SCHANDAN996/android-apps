import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/math/brick_calculator.dart';

void main() {
  group('BrickSize presets', () {
    test('desi 230x110x70 gives ~434 bricks/m3 and a 4.5"/9" wall', () {
      const b = BrickSize.desi;
      expect(b.bricksPerM3, closeTo(434, 1));
      expect(b.mortarFraction, closeTo(0.231, 0.002));
      expect(b.halfWallThicknessM, closeTo(0.110, 0.001));
      expect(b.fullWallThicknessM, closeTo(0.230, 0.001));
    });

    test('modular 190x90x90 gives 500 bricks/m3', () {
      const b = BrickSize.modular;
      expect(b.bricksPerM3, closeTo(500, 0.5));
      expect(b.mortarFraction, closeTo(0.231, 0.002));
      expect(b.halfWallThicknessM, closeTo(0.090, 0.001));
      expect(b.fullWallThicknessM, closeTo(0.190, 0.001));
    });

    test('big desi 250x120x75 gives ~348 bricks/m3', () {
      const b = BrickSize.bigDesi;
      expect(b.bricksPerM3, closeTo(348, 1));
      expect(b.mortarFraction, closeTo(0.217, 0.002));
      expect(b.halfWallThicknessM, closeTo(0.120, 0.001));
      expect(b.fullWallThicknessM, closeTo(0.250, 0.001));
    });

    test('a bigger brick always needs fewer bricks per m3', () {
      expect(
        BrickSize.bigDesi.bricksPerM3 < BrickSize.desi.bricksPerM3,
        isTrue,
      );
      expect(
        BrickSize.desi.bricksPerM3 < BrickSize.modular.bricksPerM3,
        isTrue,
      );
    });

    test('presetById resolves every preset and rejects junk', () {
      for (final p in BrickSize.presets) {
        expect(BrickSize.presetById(p.id), same(p));
      }
      expect(BrickSize.presetById('nope'), isNull);
    });
  });

  group('custom size validation', () {
    test('a normal hand-measured brick is valid', () {
      expect(BrickSize.custom(240, 115, 75).isValid, isTrue);
    });

    test('rejects sizes outside 50-400 mm', () {
      expect(BrickSize.custom(30, 20, 20).isValid, isFalse);
      expect(BrickSize.custom(500, 110, 70).isValid, isFalse);
    });

    test('rejects a brick wider or taller than it is long', () {
      expect(BrickSize.custom(110, 230, 70).isValid, isFalse);
      expect(BrickSize.custom(110, 70, 230).isValid, isFalse);
    });

    test('custom size is flagged as custom', () {
      expect(BrickSize.custom(230, 110, 70).isCustom, isTrue);
      expect(BrickSize.desi.isCustom, isFalse);
    });
  });

  group('BrickCalculator', () {
    test('a 10x10 ft full-brick desi wall', () {
      const b = BrickSize.desi;
      final r = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: b.fullWallThicknessM,
        ratioC: 1,
        ratioS: 6,
        brick: b,
      );

      // 10ft x 10ft x 0.23m = 2.137 m3
      expect(r.wallVolume, closeTo(2.137, 0.005));
      expect(r.brickCount, closeTo(974, 5));
      expect(r.cementBags, greaterThan(0));
      expect(r.sandCFT, closeTo(r.sandM3 * 35.3147, 0.01));
    });

    test('same wall in metres matches the feet version', () {
      const b = BrickSize.desi;
      final ft = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: b.fullWallThicknessM,
        ratioC: 1,
        ratioS: 6,
        brick: b,
      );
      final m = BrickCalculator.calculate(
        length: 3.048,
        height: 3.048,
        unit: 'm',
        thicknessM: b.fullWallThicknessM,
        ratioC: 1,
        ratioS: 6,
        brick: b,
      );
      expect(m.wallVolume, closeTo(ft.wallVolume, 0.001));
      expect(m.brickCount, ft.brickCount);
    });

    test('a bigger brick means fewer bricks but more mortar for one wall', () {
      final desi = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 6,
        brick: BrickSize.desi,
      );
      final modular = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 6,
        brick: BrickSize.modular,
      );
      expect(desi.brickCount, lessThan(modular.brickCount));
      expect(desi.cementBags, greaterThan(modular.cementBags));
    });

    test('a custom size drives the count too', () {
      final r = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 6,
        brick: BrickSize.custom(230, 110, 70),
      );
      final preset = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 6,
        brick: BrickSize.desi,
      );
      expect(r.brickCount, preset.brickCount);
    });

    test('a richer mortar ratio needs more cement, less sand', () {
      final rich = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 4,
        brick: BrickSize.desi,
      );
      final lean = BrickCalculator.calculate(
        length: 10,
        height: 10,
        unit: 'ft',
        thicknessM: 0.23,
        ratioC: 1,
        ratioS: 6,
        brick: BrickSize.desi,
      );
      expect(rich.cementBags, greaterThan(lean.cementBags));
      expect(rich.sandM3, lessThan(lean.sandM3));
    });
  });

  group('labels', () {
    test('label is inches, labelMm is millimetres', () {
      expect(BrickSize.desi.label, '9 x 4.25 x 2.75');
      expect(BrickSize.desi.labelMm, '230 x 110 x 70');
      expect(BrickSize.modular.label, '7.5 x 3.5 x 3.5');
      expect(BrickSize.bigDesi.label, '9.75 x 4.75 x 3');
    });

    test('inch getters convert correctly', () {
      expect(BrickSize.desi.lengthIn, closeTo(9.06, 0.01));
      expect(BrickSize.custom(254, 127, 76.2).lengthIn, closeTo(10, 0.001));
    });
  });
}
