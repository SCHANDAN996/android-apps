# Jameen Napi · जमीन नापी

A Flutter app for land-area and plot calculations designed around Indian units and Hindi-friendly usage.

## Explore the implementation

- [Area and unit definitions](lib/data/land_units.dart), [length units](lib/data/length_units.dart) and [plot units](lib/data/plot_units.dart)
- [Area converter](lib/screens/converter_screen.dart), [irregular plot](lib/screens/irregular_plot_screen.dart), [triangle plot](lib/screens/triangle_plot_screen.dart), [land division](lib/screens/batwara_screen.dart) and [laggi calculation](lib/screens/laggi_screen.dart)
- [Language selection](lib/data/app_language.dart) and [settings](lib/screens/settings_screen.dart)

**Stack:** Flutter/Dart, `shared_preferences`, `share_plus`, `google_mobile_ads`, `url_launcher`. See [pubspec.yaml](pubspec.yaml) for the actual dependency and SDK versions. This checkout's dependency list does **not** include a GPS or Google Maps plugin; do not assume live GPS surveying or map polygon capture from this code.

## Run locally

```bash
cd "Jameen Napi"
flutter pub get
flutter run
```

To run the checked-in tests:

```bash
flutter test
```

Land units vary by region; users should verify local definitions and measurements before making legal or financial decisions.

**Google Play:** The owner's screenshot shows Jameen Napi under Tube algo. [Browse the developer's Play Store page](https://play.google.com/store/apps/developer?id=Tube+algo); the exact listing URL still needs verification.
