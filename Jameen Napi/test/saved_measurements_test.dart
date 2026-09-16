import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jameen_napi/data/saved_measurements.dart';
import 'package:jameen_napi/geo/measure_session.dart';

void main() {
  MeasureSession areaSession() {
    final session = MeasureSession(MeasureKind.area)
      ..add(const LatLng(25.0, 85.0))
      ..add(const LatLng(25.0, 85.001))
      ..add(const LatLng(25.001, 85.001));
    return session;
  }

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('saved map measurements round-trip through local preferences', () async {
    final stored = await SavedMeasurementStore.instance.save('उत्तर का खेत', areaSession());
    final all = await SavedMeasurementStore.instance.loadAll();

    expect(all, hasLength(1));
    expect(all.single.id, stored.id);
    expect(all.single.name, 'उत्तर का खेत');
    expect(all.single.session.kind, MeasureKind.area);
    expect(all.single.session.pointCount, 3);
  });

  test('saving an opened measurement replaces it instead of duplicating it',
      () async {
    final first = await SavedMeasurementStore.instance.save('पुराना नाम', areaSession());
    final changed = MeasureSession(MeasureKind.distance)
      ..add(const LatLng(25.0, 85.0))
      ..add(const LatLng(25.001, 85.0));

    final replacement = await SavedMeasurementStore.instance.save(
      'नया नाम',
      changed,
      replaceId: first.id,
    );
    final all = await SavedMeasurementStore.instance.loadAll();

    expect(all, hasLength(1));
    expect(replacement.id, first.id);
    expect(all.single.name, 'नया नाम');
    expect(all.single.session.kind, MeasureKind.distance);
  });

  test('bad saved JSON is ignored without affecting the app', () {
    expect(SavedMeasurementStore.decode('{wrong'), isEmpty);
    expect(SavedMeasurementStore.decode('[{"name": false}]'), isEmpty);
  });
}
