# Pro Kisan ka apna Android emulator — banao, chalao, ऐप डालो, screenshot lo
#
#   .\scripts\emulator.ps1                  # chalu karo
#   .\scripts\emulator.ps1 -Install         # chalu karke release APK bhi daalo
#   .\scripts\emulator.ps1 -Shot ghar       # screenshot -> screenshots\ghar.png
#   .\scripts\emulator.ps1 -Band            # band karo
#   .\scripts\emulator.ps1 -Nayi            # AVD mita kar nayi (khaali phone)
#   .\scripts\emulator.ps1 -Api 34          # kisi khaas API ka image chuno
#
# ─────────────────────────────────────────────────────────────────────────
# ⚠️ IS MACHINE PAR KYA DIKKAT HAI (8 अगस्त 2026 ko jaancha)
#
# Intel HD Graphics 620 ka Vulkan driver 1.3.215 deta hai. Android 37 wala
# system image kam se kam 1.3.240 maangta hai. Isliye emulator Vulkan ko
# `lavapipe` (software) par daal deta hai — matlab poora rendering CPU par.
# Nateeja: ऐप chalta to hai par cold start 1 min 15 sec, aur SystemUI/
# Launcher baar-baar "isn't responding" dete hain.
#
#   emuglConfig_init: vulkan_mode_selected:lavapipe  gles_mode_selected:host
#
# GLES pehle se asli GPU par hai — sirf Vulkan software par gira hai.
#
# ✅ ILAAJ: Android Studio → SDK Manager → SDK Platforms → "Show Package
#    Details" → koi **API 33 ya 34** ka system image utaar lijiye (~1 GB).
#    Wo Vulkan nahi maangta, GLES se hi chalta hai — yaani asli Intel GPU
#    par. Utarte hi ye script apne aap use uthaa legi (sabse chhota API
#    pehle chunti hai, kyunki purana = halka).
#
# ❌ `-gpu angle_indirect` mat dijiye — is emulator version me wo option
#    hai hi nahi ("not valid, switching to auto").
# ─────────────────────────────────────────────────────────────────────────

param(
    [switch]$Install,
    [switch]$Band,
    [switch]$Nayi,
    [string]$Shot,
    [int]$Api = 0
)

$ErrorActionPreference = 'Stop'

$Sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { 'H:\Android\Sdk' }
$Adb = Join-Path $Sdk 'platform-tools\adb.exe'
$Emu = Join-Path $Sdk 'emulator\emulator.exe'
$Naam = 'prokisan'
$AvdDir = Join-Path $env:USERPROFILE '.android\avd'
$Avd = Join-Path $AvdDir "$Naam.avd"

foreach ($p in @($Adb, $Emu)) {
    if (-not (Test-Path $p)) { throw "nahi mila: $p  (ANDROID_HOME theek hai?)" }
}

# ---------------------------------------------------------------- band karo
if ($Band) {
    & $Adb emu kill 2>&1 | Out-Null
    Get-Process qemu-system*, emulator* -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "emulator band." -ForegroundColor Yellow
    exit 0
}

# ------------------------------------------------------------- screenshot
if ($Shot) {
    $dir = Join-Path $PSScriptRoot '..\screenshots'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $out = Join-Path $dir "$Shot.png"
    # exec-out se raw bytes aate hain — PowerShell me redirect text bana
    # deta hai, isliye cmd ke through nikalte hain.
    cmd /c "`"$Adb`" exec-out screencap -p > `"$out`""
    if ((Get-Item $out).Length -lt 1000) { throw "screenshot khaali aayi" }
    Write-Host "liya -> screenshots\$Shot.png" -ForegroundColor Green
    exit 0
}

# ------------------------------------------------------------------ AVD banao
# avdmanager is SDK me nahi hai (cmdline-tools\latest\bin khaali hai), isliye
# AVD haath se likhte hain — wo asal me sirf do text file hi hai.
if ($Nayi -and (Test-Path $Avd)) {
    Remove-Item $Avd -Recurse -Force
    Write-Host "purani AVD mita di." -ForegroundColor Yellow
}

if (-not (Test-Path (Join-Path $Avd 'config.ini'))) {

    # sirf wahi image jisme sach me system.img pada hai — adhoore download
    # me khaali folder rah jaata hai (jaise yahan android-35).
    $mile = Get-ChildItem (Join-Path $Sdk 'system-images') -Recurse -Filter 'system.img' `
                -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 100MB }
    if (-not $mile) {
        throw "koi poora system image nahi mila. Android Studio > SDK Manager se API 33/34 ka image utaariye."
    }

    # API nikaal kar sabse purana (= sabse halka) chuno, jab tak -Api na diya ho
    $soochi = foreach ($f in $mile) {
        $sp = Join-Path $f.Directory.FullName 'source.properties'
        $lvl = 0
        if (Test-Path $sp) {
            $m = Select-String -Path $sp -Pattern 'AndroidVersion.ApiLevel=([\d.]+)'
            if ($m) { $lvl = [double]$m.Matches[0].Groups[1].Value }
        }
        [pscustomobject]@{ Api = $lvl; Dir = $f.Directory.FullName }
    }
    $chuna = if ($Api) { $soochi | Where-Object Api -eq $Api | Select-Object -First 1 }
             else      { $soochi | Sort-Object Api | Select-Object -First 1 }
    if (-not $chuna) { throw "API $Api ka image nahi mila. mile: $($soochi.Api -join ', ')" }

    $Rel = $chuna.Dir.Substring($Sdk.Length).TrimStart('\') -replace '\\', '/'
    Write-Host "AVD bana raha hoon — API $($chuna.Api) · $Rel" -ForegroundColor Cyan
    if ($chuna.Api -ge 35) {
        Write-Host "  ⚠️ API 35+ Vulkan maangta hai; Intel HD 620 par ye software" -ForegroundColor Yellow
        Write-Host "     rendering me girega aur bahut dheema chalega." -ForegroundColor Yellow
    }
    New-Item -ItemType Directory -Force -Path $Avd | Out-Null

    @"
avd.ini.encoding=UTF-8
path=$Avd
path.rel=avd\$Naam.avd
target=android-$($chuna.Api)
"@ | Set-Content -Path (Join-Path $AvdDir "$Naam.ini") -Encoding UTF8

    # 1080x1920 = theek 9:16 — Play Store isi anupaat ko bina sawal leta hai
    @"
avd.ini.encoding=UTF-8
AvdId=$Naam
avd.ini.displayname=$Naam
PlayStore.enabled=true
abi.type=x86_64
tag.id=google_apis_playstore
tag.display=Google APIs PlayStore
image.sysdir.1=$Rel/
hw.cpu.arch=x86_64
hw.cpu.ncore=4
hw.ramSize=4096
vm.heapSize=512
disk.dataPartition.size=6442450944
hw.lcd.width=1080
hw.lcd.height=1920
hw.lcd.density=420
hw.initialOrientation=portrait
hw.keyboard=yes
hw.gpu.enabled=yes
hw.gpu.mode=host
hw.accelerometer=yes
hw.audioInput=yes
hw.battery=yes
hw.camera.back=virtualscene
hw.camera.front=emulated
hw.dPad=no
hw.gps=yes
hw.mainKeys=no
hw.sdCard=no
hw.sensors.orientation=yes
hw.sensors.proximity=yes
hw.trackBall=no
showDeviceFrame=no
skin.dynamic=yes
fastboot.forceColdBoot=no
runtime.network.latency=none
runtime.network.speed=full
"@ | Set-Content -Path (Join-Path $Avd 'config.ini') -Encoding UTF8
}

# ---------------------------------------------------------------- chalu karo
$chalu = (& $Adb devices) -match 'emulator-\d+\s+device'
if ($chalu) {
    Write-Host "emulator pehle se chalu hai." -ForegroundColor Green
} else {
    # ⚠️ ek hi AVD par do emulator chalein to FATAL aata hai — pehle safai
    Get-Process qemu-system*, emulator* -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue

    Write-Host "chalu kar raha hoon (pehli baar 3-5 minute)..." -ForegroundColor Cyan
    Start-Process -FilePath $Emu -WindowStyle Normal -ArgumentList @(
        '-avd', $Naam, '-gpu', 'host', '-no-boot-anim',
        '-netdelay', 'none', '-netspeed', 'full'
    )

    & $Adb wait-for-device
    $b = ''
    $tak = (Get-Date).AddMinutes(10)
    while ((Get-Date) -lt $tak) {
        $b = (& $Adb shell getprop sys.boot_completed 2>$null) -replace '\s', ''
        if ($b -eq '1') { break }
        Start-Sleep -Seconds 3
    }
    if ($b -ne '1') { throw "10 minute me boot nahi hua — emulator ki window dekhiye" }
    Write-Host "boot ho gaya." -ForegroundColor Green
}

# ----------------------------------------------- screenshot ke liye taiyaari
# dheeme emulator par SystemUI/Launcher ke "isn't responding" dialog bar-bar
# screenshot me aa jaate hain. Inhe band kar dete hain.
& $Adb shell settings put global hide_error_dialogs 1        2>$null
& $Adb shell settings put global window_animation_scale 0    2>$null
& $Adb shell settings put global transition_animation_scale 0 2>$null
& $Adb shell settings put global animator_duration_scale 0   2>$null
& $Adb shell settings put system screen_off_timeout 1800000  2>$null
& $Adb shell svc power stayon true                            2>$null
& $Adb shell input keyevent KEYCODE_WAKEUP                    2>$null

# ------------------------------------------------------------------- ऐप डालो
if ($Install) {
    $Apk = Join-Path $PSScriptRoot '..\build\app\outputs\flutter-apk\app-release.apk'
    if (-not (Test-Path $Apk)) {
        Write-Host "APK nahi mili. pehle: flutter build apk --release" -ForegroundColor Yellow
    } else {
        Write-Host "APK daal raha hoon..." -ForegroundColor Cyan
        & $Adb install -r -t $Apk
        & $Adb shell monkey -p com.prokisan.app -c android.intent.category.LAUNCHER 1 | Out-Null
        Write-Host "ऐप chalu ho raha hai (dheemi machine par 1 min lag sakta hai)." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "screenshot lene ke liye:" -ForegroundColor DarkGray
Write-Host "  .\scripts\emulator.ps1 -Shot ghar" -ForegroundColor DarkGray
