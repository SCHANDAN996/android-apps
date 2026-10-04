/// App-wide facts that must match `pubspec.yaml`.
///
/// `version_test.dart` reads the pubspec and fails if [version] drifts, so
/// bumping the app version can't silently leave the Settings screen behind.
class AppInfo {
  const AppInfo._();

  /// Keep in sync with the `version:` line in pubspec.yaml (the part before +).
  static const String version = '1.2.0';
}
