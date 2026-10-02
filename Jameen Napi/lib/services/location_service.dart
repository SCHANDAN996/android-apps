import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../geo/geo_math.dart';

/// लोकेशन मिल सकती है या नहीं — screen इसी के हिसाब से संदेश दिखाती है।
enum LocationAccess {
  granted,

  /// फ़ोन की लोकेशन (GPS) ही बंद है
  serviceOff,

  /// user ने अभी मना किया — दोबारा पूछ सकते हैं
  denied,

  /// "दोबारा न पूछें" — अब सिर्फ़ Settings से चालू होगी
  deniedForever,
}

/// GPS की सारी बातचीत एक जगह।
///
/// ⚠️ **सिर्फ़ foreground।** Background location माँगते ही Play अलग declaration
/// और वीडियो माँगता है, और हमारी privacy policy भी "सिर्फ़ screen खुली रहने
/// तक" कहती है। इसलिए न `ACCESS_BACKGROUND_LOCATION`, न foreground
/// notification। (geolocator की अपनी service manifest में रहनी ज़रूरी है —
/// [fixes] वाली stream उसी से bind होकर चलती है; हटाने पर stream चुपचाप
/// कुछ नहीं देती। वो सिर्फ़ bind होती है, foreground में नहीं जाती।)
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// अभी की हालत — बिना कुछ पूछे
  Future<LocationAccess> check() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceOff;
    }
    return _map(await Geolocator.checkPermission());
  }

  /// ज़रूरत हो तो Android का permission dialog दिखाओ।
  ///
  /// इसे बुलाने से पहले screen हर बार अपना "लोकेशन क्यों?" पन्ना दिखाती है —
  /// Play की "prominent disclosure" शर्त। (एक बार दिखाकर याद रखना काफ़ी नहीं:
  /// user ने मना किया हो तो अगली बार भी system dialog से पहले वजह दिखे।)
  Future<LocationAccess> request() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceOff;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return _map(perm);
  }

  LocationAccess _map(LocationPermission p) => switch (p) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationAccess.granted,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        _ => LocationAccess.denied,
      };

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// "मेरी जगह" दबाते ही एक ताज़ा reading लें। Stream की पहली reading आने
  /// तक button को बेकार नहीं दिखाना चाहिए — कई Vivo/Android फ़ोनों में stream
  /// को पहला fix देने में काफ़ी समय लग जाता है।
  Future<GpsFix> currentFix() async {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ),
    );
    return GpsFix(LatLng(p.latitude, p.longitude), p.accuracy, p.timestamp);
  }

  /// लगातार GPS readings। हर reading को [GpsFix] में बदलकर देता है।
  ///
  /// `distanceFilter: 0` जान-बूझकर — छानने का काम [TrackFilter] करता है,
  /// जो accuracy और रफ़्तार भी देखता है। कोने पर खड़े होकर औसत लेते समय भी
  /// हर सेकंड की reading चाहिए, भले user हिला न हो।
  Stream<GpsFix> fixes() {
    return Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
      ),
    ).map((p) => GpsFix(
          LatLng(p.latitude, p.longitude),
          p.accuracy,
          p.timestamp,
        ));
  }
}
