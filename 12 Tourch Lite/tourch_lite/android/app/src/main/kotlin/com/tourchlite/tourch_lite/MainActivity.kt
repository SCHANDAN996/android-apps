package com.tourchlite.tourch_lite

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraCharacteristics
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tourchlite.tourch_lite/torch"
    private var methodChannel: MethodChannel? = null

    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var localTorchState = false

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 13+: the foreground service needs a visible notification, which
        // requires runtime permission. Without it the background shortcut is unreliable.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS)
                    != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1001)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        initCamera()

        TorchService.onStateChangeListener = { isOn ->
            runOnUiThread {
                methodChannel?.invokeMethod("onTorchStateChanged", isOn)
                localTorchState = isOn
            }
        }

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isServiceRunning" -> {
                    result.success(TorchService.isServiceRunning)
                }
                "isFlashlightOn" -> {
                    val state = if (TorchService.isServiceRunning) {
                        TorchService.isFlashlightOn
                    } else {
                        localTorchState
                    }
                    result.success(state)
                }
                "startService" -> {
                    startTorchService()
                    result.success(true)
                }
                "stopService" -> {
                    stopTorchService()
                    result.success(true)
                }
                "toggleFlashlight" -> {
                    val wantOn = call.argument<Boolean>("enable") ?: false
                    toggleFlashlight(wantOn)
                    result.success(wantOn)
                }
                "setBrightness" -> {
                    val value = call.argument<Double>("value")?.toFloat() ?: -1f
                    setBrightness(value)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        TorchService.onStateChangeListener = null
        super.onDestroy()
    }

    private fun initCamera() {
        cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        try {
            cameraManager?.let { manager ->
                for (id in manager.cameraIdList) {
                    val characteristics = manager.getCameraCharacteristics(id)
                    val hasFlash = characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE)
                    if (hasFlash == true) {
                        cameraId = id
                        break
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startTorchService() {
        val intent = Intent(this, TorchService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopTorchService() {
        val intent = Intent(this, TorchService::class.java)
        stopService(intent)
    }

    private fun toggleFlashlight(enable: Boolean) {
        if (TorchService.isServiceRunning) {
            val intent = Intent(this, TorchService::class.java).apply {
                action = TorchService.ACTION_TOGGLE_TORCH
                putExtra("enable", enable)
            }
            startService(intent)
        } else {
            val id = cameraId
            val manager = cameraManager
            if (id != null && manager != null) {
                try {
                    manager.setTorchMode(id, enable)
                    localTorchState = enable
                    methodChannel?.invokeMethod("onTorchStateChanged", enable)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun setBrightness(value: Float) {
        runOnUiThread {
            try {
                val layout = window.attributes
                layout.screenBrightness = value
                window.attributes = layout
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
