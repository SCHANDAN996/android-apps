# Project status

## Implemented in this MVP source

- Material 3 light/dark design system
- English, Hindi and Urdu UI switching
- Urdu RTL layout
- Home and prayer-time dashboards
- Per-prayer notification toggles (local UI state)
- Qibla compass preview
- Dua and Azkar reader samples
- Interactive Tasbih counter
- Interactive 30-day Ramadan fast tracker
- Interactive Zakat calculator
- Explore and Settings navigation
- Saved and search empty states
- Location fallback, offline download, privacy, help and legal UI flows
- Adhan notification support guide
- 41 actual Flutter screen implementations: setup, daily worship, content, trackers, settings and system states
- Interactive controls across the UI: alerts, settings choices, city search field, fast calendar, Tasbih counter, Zakat estimate, feedback and confirmation states
- Android bootstrap/build script for Windows
- Basic launch widget test

## Required before production release

- Verified prayer-time calculation package/service
- GPS/geocoding and timezone handling for worldwide cities
- Device compass/magnetometer and Qibla bearing calculation
- Android exact alarms, background execution and Adhan audio
- Persistent local database and migrations
- Complete verified Dua/Azkar content and translations
- Production localization files for all supported languages
- Privacy policy, terms, store listing and signed release configuration
- Accessibility, device and release QA

The current package is an honest functional Flutter UI MVP. It is not a store-ready religious authority or completed backend: live religious calculations and device integrations must be verified before release.
