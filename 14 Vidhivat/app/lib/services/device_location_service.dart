import 'package:geolocator/geolocator.dart';

/// One-shot foreground location only. The app never watches a user in the
/// background and never sends the resulting coordinates to a server.
enum DeviceLocationFailure { serviceDisabled, permissionDenied, unavailable }

class DeviceLocationResult {
  final double? latitude;
  final double? longitude;
  final DeviceLocationFailure? failure;
  final bool permissionPermanentlyDenied;

  const DeviceLocationResult._({
    this.latitude,
    this.longitude,
    this.failure,
    this.permissionPermanentlyDenied = false,
  });

  const DeviceLocationResult.position(double latitude, double longitude)
      : this._(latitude: latitude, longitude: longitude);

  const DeviceLocationResult.failed(
    DeviceLocationFailure failure, {
    bool permissionPermanentlyDenied = false,
  }) : this._(
          failure: failure,
          permissionPermanentlyDenied: permissionPermanentlyDenied,
        );

  bool get hasPosition => latitude != null && longitude != null;
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<DeviceLocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const DeviceLocationResult.failed(
        DeviceLocationFailure.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return DeviceLocationResult.failed(
        DeviceLocationFailure.permissionDenied,
        permissionPermanentlyDenied:
            permission == LocationPermission.deniedForever,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DeviceLocationResult.position(
        position.latitude,
        position.longitude,
      );
    } catch (_) {
      return const DeviceLocationResult.failed(
          DeviceLocationFailure.unavailable);
    }
  }

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
