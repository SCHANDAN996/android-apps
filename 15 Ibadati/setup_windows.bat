@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found. Install Flutter and add it to PATH first.
  pause
  exit /b 1
)
if not exist android (
  flutter create --platforms=android --org com.ibadati .
)
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
echo.
echo APK: build\app\outputs\flutter-apk\app-debug.apk
pause
