#!/usr/bin/env bash
set -euo pipefail

case "${RECORDING_SECONDS}" in
  ''|*[!0-9]*) echo "duration_seconds must be a number"; exit 1 ;;
esac
if [ "${RECORDING_SECONDS}" -lt 10 ] || [ "${RECORDING_SECONDS}" -gt 180 ]; then
  echo "duration_seconds must be between 10 and 180"
  exit 1
fi

mkdir -p recording
adb install -r -g "${APP_APK}"
adb shell pm grant com.vidhivat android.permission.ACCESS_FINE_LOCATION || true
adb shell pm grant com.vidhivat android.permission.ACCESS_COARSE_LOCATION || true
adb shell am force-stop com.vidhivat
adb shell monkey -p com.vidhivat 1 >/dev/null
sleep 4
adb exec-out screencap -p > recording/first-frame.png

adb shell screenrecord --bit-rate 8000000 --time-limit "${RECORDING_SECONDS}" /sdcard/vidhivat-emulator.mp4 > recording/screenrecord.log 2>&1 &
recorder_pid=$!
sleep "${RECORDING_SECONDS}"
wait "${recorder_pid}" || true

adb pull /sdcard/vidhivat-emulator.mp4 recording/vidhivat-emulator.mp4
