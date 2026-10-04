import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/models/project_item.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProjectItem wall(String id, double bags, double sand) => ProjectItem(
  id: id,
  type: 'brick',
  detail: '10 × 10 ft',
  materials: {
    ProjectMaterial.bricks: 980,
    ProjectMaterial.cementBags: bags,
    ProjectMaterial.sandCft: sand,
  },
);

void main() {
  group('ProjectItem', () {
    test('survives a round trip through JSON', () {
      final back = ProjectItem.tryParse(wall('1', 7.3, 40.2).toJson())!;
      expect(back.id, '1');
      expect(back.type, 'brick');
      expect(back.detail, '10 × 10 ft');
      expect(back.materials[ProjectMaterial.cementBags], 7.3);
    });

    test('junk is rejected, not thrown', () {
      expect(ProjectItem.tryParse('not json'), isNull);
      expect(ProjectItem.tryParse('{"id": 1}'), isNull);
    });
  });

  group('ProjectTotals', () {
    test('rounds up once, on the total — 7.3 + 4.4 bags is 12, not 13', () {
      final t = ProjectTotals([wall('1', 7.3, 40.2), wall('2', 4.4, 20.1)]);
      expect(t.cementBags, 12);
      expect(t.sandCft, 61);
      expect(t.bricks, 1960);
      expect(t.steelKg, 0);
    });

    test('prices only what has a rate', () {
      final t = ProjectTotals([wall('1', 7.3, 40.2)]);
      final costs = t.costs({'brick': 8000, 'cement': 400, 'steel': 60});
      expect(costs['brick'], closeTo(7840, 0.01)); // 980 / 1000 x 8000
      expect(costs['cement'], 3200); // 8 bags x 400
      expect(costs.containsKey('sand'), isFalse); // no rate
      expect(costs.containsKey('steel'), isFalse); // none needed
    });
  });

  group('StorageService project', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
      await storage.init();
    });

    test('starts empty, keeps items in the order they were added', () async {
      expect(storage.projectItems, isEmpty);
      await storage.addProjectItem(wall('1', 7.3, 40));
      await storage.addProjectItem(wall('2', 4.4, 20));
      expect(storage.projectItems.map((i) => i.id), ['1', '2']);
    });

    test('removes one item, or all of them', () async {
      await storage.addProjectItem(wall('1', 7.3, 40));
      await storage.addProjectItem(wall('2', 4.4, 20));

      await storage.removeProjectItem('1');
      expect(storage.projectItems.single.id, '2');

      await storage.clearProject();
      expect(storage.projectItems, isEmpty);
    });

    test('a corrupted entry is skipped, the rest still load', () async {
      SharedPreferences.setMockInitialValues({
        'project_items': ['garbage', wall('2', 4.4, 20).toJson()],
      });
      storage = StorageService();
      await storage.init();
      expect(storage.projectItems.single.id, '2');
    });
  });
}
