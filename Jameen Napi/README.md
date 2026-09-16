# जमीन नापी (Jameen Napi)

Flutter app for Indian land-area conversion, plot calculations and field measurement.

## Map / GPS measurement

- Tap satellite/street map corners to measure a field or route distance.
- Walk to each field corner for an averaged GPS fix, or record a continuous curved boundary.
- Track distance while walking, riding or driving, with accuracy, jitter and GPS-jump filtering.
- Measurements can be saved locally, shared, viewed in state-specific land units, or sent to land partition.

GPS is used only while the measurement screen is open. Calculations and saved boundaries remain on the device. Map tiles and ads need internet; GPS walking measurement does not.

## Checks

```sh
flutter test
flutter analyze
flutter build apk --debug
dart run tool/check_store_listing.dart
```
