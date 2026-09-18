[CmdletBinding()]
param(
  [string]$AvdName = "VidhivatVideo",
  [string]$ApiLevel = "35"
)

$ErrorActionPreference = "Stop"

if (-not $env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}
$sdkRoot = $env:ANDROID_SDK_ROOT
$sdkManager = Join-Path $sdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
$avdManager = Join-Path $sdkRoot "cmdline-tools\latest\bin\avdmanager.bat"

if (-not (Test-Path $sdkManager) -or -not (Test-Path $avdManager)) {
  throw "Android Studio खोलकर SDK Command-line Tools (latest) install करें, फिर script दोबारा चलाएँ. SDK: $sdkRoot"
}

$systemImage = "system-images;android-$ApiLevel;google_apis;x86_64"
& $sdkManager --install "platform-tools" "emulator" "platforms;android-$ApiLevel" $systemImage
if ($LASTEXITCODE -ne 0) { throw "Android SDK packages install नहीं हुए." }

$avdPath = Join-Path $env:USERPROFILE ".android\avd\$AvdName.avd"
if (-not (Test-Path $avdPath)) {
  "no" | & $avdManager create avd --force --name $AvdName --package $systemImage --device "pixel_6"
  if ($LASTEXITCODE -ne 0) { throw "AVD create नहीं हुआ." }
}

$configPath = Join-Path $avdPath "config.ini"
@"
hw.ramSize=4096
disk.dataPartition.size=8G
hw.gpu.enabled=yes
hw.keyboard=yes
showDeviceFrame=yes
skin.dynamic=yes
"@ | Add-Content -Path $configPath

Write-Host ""
Write-Host "तैयार: $AvdName"
Write-Host "अब चलाएँ: .\install_and_record.ps1 -ApkPath C:\path\to\vidhivat-release.apk"
