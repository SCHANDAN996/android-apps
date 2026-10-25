import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vidhivat/services/device_location_service.dart';

class _BrokenLocationPlatform extends GeolocatorPlatform {
  final String stage;
  _BrokenLocationPlatform(this.stage);

  void _fail(String at) {
    if (stage == at) throw PlatformException(code: 'unavailable');
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    _fail('service');
    return true;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    _fail('permission-check');
    return LocationPermission.denied;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    _fail('permission-request');
    return LocationPermission.deniedForever;
  }
}

void main() {
  late GeolocatorPlatform original;
  setUp(() => original = GeolocatorPlatform.instance);
  tearDown(() => GeolocatorPlatform.instance = original);

  for (final stage in ['service', 'permission-check', 'permission-request']) {
    test('$stage error becomes an unavailable result', () async {
      GeolocatorPlatform.instance = _BrokenLocationPlatform(stage);
      final result = await const DeviceLocationService().getCurrentLocation();
      expect(result.hasPosition, isFalse);
      expect(result.failure, DeviceLocationFailure.unavailable);
    });
  }

  test('permanent permission denial is retained', () async {
    GeolocatorPlatform.instance = _BrokenLocationPlatform('none');
    final result = await const DeviceLocationService().getCurrentLocation();
    expect(result.failure, DeviceLocationFailure.permissionDenied);
    expect(result.permissionPermanentlyDenied, isTrue);
  });

  test('non-finite coordinates are not usable positions', () {
    expect(const DeviceLocationResult.position(double.nan, 85).hasPosition,
        isFalse);
    expect(const DeviceLocationResult.position(25, double.infinity).hasPosition,
        isFalse);
    expect(
        const DeviceLocationResult.position(25.59, 85.14).hasPosition, isTrue);
  });
}
