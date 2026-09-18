[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$ApkPath,
  [string]$AvdName = "VidhivatVideo",
  [string]$RecordingName = "vidhivat-demo.mp4"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ApkPath)) { throw "APK नहीं मिली: $ApkPath" }
if (-not $env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}
$sdkRoot = $env:ANDROID_SDK_ROOT
$adb = Join-Path $sdkRoot "platform-tools\adb.exe"
$emulator = Join-Path $sdkRoot "emulator\emulator.exe"
if (-not (Test-Path $adb) -or -not (Test-Path $emulator)) {
  throw "पहले .\setup_windows.ps1 चलाएँ."
}

& $adb start-server | Out-Null
$booted = (& $adb devices) -match "\sdevice$"
if (-not $booted) {
  Start-Process -FilePath $emulator -ArgumentList @("-avd", $AvdName, "-gpu", "host", "-no-boot-anim")
  & $adb wait-for-device
  do {
    Start-Sleep -Seconds 2
    $ready = ((& $adb shell getprop sys.boot_completed).Trim() -eq "1")
  } until ($ready)
}

& $adb install -r $ApkPath
if ($LASTEXITCODE -ne 0) { throw "APK install नहीं हुई." }

# Video में UI साफ़ दिखे, इसलिए system animations बंद।
& $adb shell settings put global window_animation_scale 0
& $adb shell settings put global transition_animation_scale 0
& $adb shell settings put global animator_duration_scale 0

$remote = "/sdcard/$RecordingName"
Write-Host ""
Write-Host "ऐप खुल गई है। अब recording शुरू करने के लिए नया PowerShell खोलें:"
Write-Host "  $adb shell screenrecord --bit-rate 12000000 --size 1080x1920 $remote"
Write-Host ""
Write-Host "App की पूरी यात्रा चलाएँ। Recording रोकने के लिए Ctrl+C दबाएँ। फिर यह चलाएँ:"
Write-Host "  $adb pull $remote .\$RecordingName"
Write-Host ""
Write-Host "एक clip अधिकतम 180 seconds की रखें। जरूरत हो तो कई छोटे clips रिकॉर्ड करें।"
