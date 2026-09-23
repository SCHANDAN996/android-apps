# Android & Flutter apps · Chandan Singh

A collection of Flutter/Dart app projects focused on everyday use in India. Browse the source, inspect a feature, and run each Flutter project from its own directory.

## Start here

| Project | Scope visible in this repository | Code / notes |
| --- | --- | --- |
| **Jameen Napi** | Land area, plot and length calculators; local preferences and sharing | [Source](Jameen%20Napi/) · [Project guide](Jameen%20Napi/README.md) |
| **Vidhivat** | Puja guidance, calendar screens and a separate pure-Dart panchang engine | [Project overview](14%20Vidhivat/README.md) · [App](14%20Vidhivat/app/) · [Engine](14%20Vidhivat/engine/) |
| **Mistri Calculator** | Brick, concrete, steel, plaster, tile and paint estimates | [App and guide](01%20Mistri%20Calculator/mistri_calculator/) |
| **Pro Kisan** | Agriculture and dairy modules; BLoC/Cubit and database-backed workflows | [App source](03%20Pro%20Kisan/pro%20kisan/) |
| **Ibadati** | Flutter UI prototype for prayer-related flows | [Prototype and limitations](15%20Ibadati/README.md) |

Some other directories contain plans or work in progress. They are not presented as released apps. The original documentation for each project contains its own release checklist or development status; check that before evaluating store readiness.

## What the code demonstrates

- **Flutter & Dart:** navigation, screens, reusable widgets and feature modules.
- **Local-first features:** app preferences and on-device data in the projects that use them.
- **Domain logic:** land and construction calculations; a separately testable panchang engine.
- **Android delivery work:** app configuration and store assets in selected projects.

The projects are independent Flutter packages, **not** one Flutter app at the repository root. Dependencies and SDK requirements vary by project.

## Run a project

Install Flutter and an Android SDK, then open the directory containing that project's `pubspec.yaml`:

```bash
cd "Jameen Napi"
flutter pub get
flutter run
```

For Vidhivat, the Flutter app is in `14 Vidhivat/app` and its local Dart package is in `14 Vidhivat/engine`. Read [its project guide](14%20Vidhivat/README.md) for package-specific commands. Run a project's tests from its own directory with `flutter test` (or `dart test` for the pure-Dart engine).

## Contact

**Chandan Singh** · [GitHub profile](https://github.com/SCHANDAN996) · [Email](mailto:all.chandansingh@gmail.com)

**Portfolio note:** Public Play Store links and demo videos should be added to the relevant project guide only after the exact listing and release status are verified. Features in plans are not represented here as shipped functionality.
