import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/math/concrete_calculator.dart';
import 'package:mistri_calculator/core/math/extra_calculators.dart';
import 'package:mistri_calculator/core/math/paint_calculator.dart';
import 'package:mistri_calculator/core/models/project_item.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:mistri_calculator/widgets/length_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('feet and inches', () {
    test('decimal feet split into the two boxes', () {
      expect(splitFeet(10.5), ('10', '6'));
      expect(splitFeet(10), ('10', ''));
      expect(splitFeet(0.75), ('', '9'));
      expect(splitFeet(null), ('', ''));
    });

    test('rounding never shows 12 inches', () {
      // 10 ft 11.99 in is 11 ft, not "10 ft 12 in".
      expect(splitFeet(10.9999), ('11', ''));
      // 10 ft 7 in stored as 10.5833
      expect(splitFeet(10.5833), ('10', '7'));
    });

    test('labels read the way a mason says them', () {
      expect(lengthLabel('10.5', 'ft'), '10 ft 6 in');
      expect(lengthLabel('10', 'ft'), '10 ft');
      expect(lengthLabel('0.75', 'ft'), '9 in');
      expect(lengthLabel('3.2', 'm'), '3.2 m');
      expect(lengthLabel('9', 'in'), '9 in');
    });
  });

  group('paint buckets', () {
    Map<String, int> buckets(double areaM2) => PaintCalculator.calculateByArea(
      areaM2: areaM2,
      coats: 1,
    ).bucketSuggestion;

    test('9.5 litres is one 10 L bucket, not 4 + 4 + 1 + 1', () {
      expect(buckets(95), {'10L': 1});
    });

    test('floating-point dust does not add a bucket', () {
      expect(buckets(300.00000000001), {'20L': 1, '10L': 1});
    });

    test('a small job still gets whole tins', () {
      expect(buckets(63), {'4L': 1, '1L': 3}); // 6.3 L → 7 L
    });
  });

  group('primer and putty', () {
    test('follow the wall area, not the number of coats', () {
      final one = PaintCalculator.calculateByArea(areaM2: 93, coats: 1);
      final three = PaintCalculator.calculateByArea(areaM2: 93, coats: 3);
      expect(one.primerLitres, closeTo(9.3, 0.01));
      expect(one.puttyKg, closeTo(50, 0.1)); // ~1000 sq ft at 20 sq ft / kg
      expect(three.primerLitres, one.primerLitres);
    });
  });

  group('concrete grades', () {
    test('M20 is found by name, PCC mixes are not structural', () {
      expect(ConcreteCalculator.m20.name, 'M20');
      final names = ConcreteCalculator.structuralGrades.map((g) => g.name);
      expect(names, ['M15', 'M20', 'M25']);
    });
  });

  group('StairsCalculator', () {
    test('a 10 ft floor with 7 inch risers', () {
      final r = StairsCalculator.calculate(
        heightM: 3.048,
        widthM: 0.9144, // 3 ft
        riserM: 0.1778, // 7 in
        treadM: 0.254, // 10 in
        waistM: 0.127, // 5 in
        grade: ConcreteCalculator.m20,
      );
      expect(r.steps, 17); // 120 in / 7 in = 17.1
      expect(r.riserM * r.steps, closeTo(3.048, 1e-9));
      expect(r.goingM, closeTo(16 * 0.254, 1e-9));
      // slope 5.08 m x 0.9144 x 0.127 + 16 wedges = ~0.92 m3
      expect(r.concrete.wetVolume, closeTo(0.92, 0.01));
    });

    test('rejects a zero dimension', () {
      expect(
        () => StairsCalculator.calculate(
          heightM: 3,
          widthM: 0,
          riserM: 0.17,
          treadM: 0.25,
          waistM: 0.12,
          grade: ConcreteCalculator.m20,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ExcavationCalculator', () {
    test('a 30 x 2 x 3 ft trench', () {
      final r = ExcavationCalculator.calculate(
        lengthM: 9.144,
        widthM: 0.6096,
        depthM: 0.9144,
      );
      expect(r.volumeCft, closeTo(180, 0.1));
      expect(r.looseVolumeCft, closeTo(225, 0.1));
    });
  });

  group('WaterTankCalculator', () {
    test('a 1 m cube holds 1000 litres', () {
      expect(
        WaterTankCalculator.rectangularLitres(
          lengthM: 1,
          widthM: 1,
          heightM: 1,
        ),
        1000,
      );
    });

    test('a round tank, 1 m across and 1 m tall, holds ~785 litres', () {
      expect(
        WaterTankCalculator.roundLitres(diameterM: 1, heightM: 1),
        closeTo(785.4, 0.1),
      );
    });
  });

  group('several houses', () {
    late StorageService storage;
    final wall = ProjectItem(
      id: 'w1',
      type: 'brick',
      detail: '10 ft × 10 ft',
      materials: const {ProjectMaterial.cementBags: 7.3},
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
      await storage.init();
    });

    test('there is always one house to add to', () {
      expect(storage.projects, hasLength(1));
      expect(storage.currentProject.id, Project.defaultId);
    });

    test('what was saved before houses existed is still there', () async {
      SharedPreferences.setMockInitialValues({
        'project_items': [wall.toJson()],
      });
      storage = StorageService();
      await storage.init();
      expect(storage.projectItems.single.id, 'w1');
    });

    test('each house keeps its own items and labour', () async {
      await storage.addProjectItem(wall);
      await storage.setProjectLabour(5000);

      final sharma = await storage.addProject('Sharma ji');
      expect(storage.currentProject.name, 'Sharma ji');
      expect(storage.projectItems, isEmpty);
      expect(storage.projectLabour, 0);

      await storage.setCurrentProject(Project.defaultId);
      expect(storage.projectItems.single.id, 'w1');
      expect(storage.projectLabour, 5000);

      await storage.deleteProject(sharma.id);
      expect(storage.projects, hasLength(1));
    });

    test('deleting the house in use falls back to another one', () async {
      await storage.renameProject(Project.defaultId, 'Ghar');
      final second = await storage.addProject('Dukaan');
      await storage.deleteProject(second.id);
      expect(storage.currentProject.name, 'Ghar');
    });

    test('an item can be given a name', () async {
      await storage.addProjectItem(wall);
      await storage.renameProjectItem('w1', 'Bedroom wall');
      expect(storage.projectItems.single.name, 'Bedroom wall');
      expect(storage.projectItems.single.detail, '10 ft × 10 ft');
    });

    test('rates remember when they were saved', () async {
      expect(storage.ratesAgeDays, isNull);
      await storage.markRatesUpdated();
      expect(storage.ratesAgeDays, 0);
    });
  });
}
