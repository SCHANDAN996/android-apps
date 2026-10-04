import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/math/concrete_calculator.dart';
import 'package:mistri_calculator/core/math/tile_calculator.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TileCalculator input validation', () {
    test('rejects zero tiles per box instead of dividing by zero', () {
      expect(
        () => TileCalculator.calculate(
          floorLength: 10,
          floorWidth: 10,
          unit: 'ft',
          tileSize: TileCalculator.standardSizes.first,
          tilesPerBox: 0,
        ),
        throwsArgumentError,
      );
    });

    test('rejects negative tiles per box', () {
      expect(
        () => TileCalculator.calculate(
          floorLength: 10,
          floorWidth: 10,
          unit: 'ft',
          tileSize: TileCalculator.standardSizes.first,
          tilesPerBox: -1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ConcreteCalculator input validation', () {
    test('rejects zero column or beam count', () {
      expect(
        () => ConcreteCalculator.calculateColumnBeam(
          count: 0,
          length: 3,
          widthM: 0.3,
          depthM: 0.3,
          unit: 'm',
          grade: ConcreteCalculator.m20,
        ),
        throwsArgumentError,
      );
    });
  });

  test('clearing a saved rate removes it from future estimates', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await storage.setTileRate(75);
    expect(storage.tileRate, 75);

    await storage.clearTileRate();
    expect(storage.tileRate, isNull);
  });
}
