# Ibadati Flutter MVP

This package contains a dependency-light Flutter MVP for Android. It includes a calm teal design system, English/Hindi/Urdu UI switching, RTL support, prayer dashboard, Qibla preview, duas and azkar, Tasbih counter, Ramadan fast tracking, Zakat calculator, Explore and Settings.

## Included UI flows

- Prayer time dashboard, alert switches and calculation adjustment entry point
- Qibla preview and calibration entry point
- Dua/Azkar list and reader with save state
- Tasbih counter, goals and history view
- Ramadan fast calendar, fast log and Qaza summary
- Zakat calculation and payment-history entry point
- Language, location, Adhan, offline, privacy, help and legal settings
- Saved-content empty state and global-search empty state
- `All app screens` section containing 41 interactive Flutter implementations for every UI/UX screen designed in this project

## Design reference code

The `design-previews/` folder contains the original interactive HTML design code for all 41 screens created during the UI/UX phase. Keep these files with the Flutter source; they are the visual reference for converting each preview into its final production page.

See `SCREEN_INVENTORY.md` for the full screen list.

The UI is a functional local demo state. It does not claim to calculate live prayer times, provide a real compass, schedule background Adhan, or store records permanently yet.

## Build on Windows

1. Install Flutter stable and Android Studio.
2. Extract this ZIP into `C:\Users\Admin\Desktop\my project\MASS APP\Ibadati` (or any short path without special permissions).
3. Double-click `setup_windows.bat`.
4. The debug APK will be created at `build\app\outputs\flutter-apk\app-debug.apk`.

You can also run:

```text
flutter create --platforms=android --org com.ibadati .
flutter pub get
flutter run
flutter build apk --debug
```

## Important

Prayer times, Qibla direction and Adhan in this first source package use demo/local state. Before store release, connect verified location, calculation, compass, exact-alarm, audio and persistent-storage services and validate religious content with qualified reviewers.
