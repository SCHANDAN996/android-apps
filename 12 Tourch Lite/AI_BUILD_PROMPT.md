# AI Build Prompt - Tourch Lite (Double-Tap Lock Button Flashlight)

This file contains the complete technical specification and code reference for building the **Tourch Lite** app. It implements an offline-first premium flashlight app where double-pressing the physical power/lock button turns the torch ON, and pressing it once when active turns the torch OFF.

---

## Architecture Overview
The application is built using **Flutter** for the frontend UI and **Kotlin** (Android Native) for the low-level physical key/screen broadcast listening via a foreground service.

```
+------------------------------------+
|            Flutter UI              |
+-----------------+------------------+
                  | (Method Channel)
+-----------------v------------------+
|           MainActivity             |
+-----------------+------------------+
                  | (Local Intents)
+-----------------v------------------+
|           TorchService             | (Foreground Service)
|  - BroadcastReceiver (Screen ON/OFF)
|  - CameraManager (setTorchMode)
+------------------------------------+
```

---

## 1. Native Manifest & Permissions (`AndroidManifest.xml`)
We request camera access, foreground service capability, and auto-start on device reboot:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.flash" android:required="true" />

    <application ...>
        ...
        <service
            android:name=".TorchService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="specialUse">
            <property
                android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
                android:value="Flashlight background control via lock button shortcut." />
        </service>

        <receiver
            android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

---

## 2. Boot Receiver (`BootReceiver.kt`)
Restarts the service on phone reboot if it was previously enabled:

```kotlin
package com.tourchlite.tourch_lite

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean("flutter.bg_service_enabled", false)
            if (isEnabled) {
                val serviceIntent = Intent(context, TorchService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}
```

---

## 3. Background service (`TorchService.kt`)
Handles notification rendering, screen state changes receiver, double-tap timestamp tracking, and Camera2 API torch integration:

- **Double-tap trigger:** Screen state changes twice within a **800ms** threshold.
- **Single-tap turn off:** Any screen state change while the torch is active turns it OFF immediately.

---

## 4. Main Activity (`MainActivity.kt`)
Binds methods channels `"com.tourchlite.tourch_lite/torch"` to allow Flutter UI to toggle the torch, start/stop service, and query state. Re-directs torch status changes back to Dart in real-time.
