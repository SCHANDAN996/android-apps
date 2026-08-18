package com.tourchlite.tourch_lite

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraCharacteristics
import android.os.Build
import android.os.IBinder
import android.util.Log

class TorchService : Service() {

    private val TAG = "TorchService"
    private val CHANNEL_ID = "torch_lite_service_channel"
    private val NOTIFICATION_ID = 12903

    private var cameraManager: CameraManager? = null
    private var cameraId: String? = null
    private var isTorchOn = false

    // Double-press detection tuning.
    private val doublePressWindowMs = 900L   // max gap allowed between the two screen events
    private val cooldownMs = 1500L           // ignore further events right after a toggle
    private var lastEventTime: Long = 0
    private var lastToggleTime: Long = 0
    private var screenReceiver: BroadcastReceiver? = null

    companion object {
        const val ACTION_TOGGLE_TORCH = "com.tourchlite.tourch_lite.TOGGLE_TORCH"
        const val ACTION_STOP_SERVICE = "com.tourchlite.tourch_lite.STOP_SERVICE"
        
        var isServiceRunning = false
        var isFlashlightOn = false
        
        var onStateChangeListener: ((Boolean) -> Unit)? = null
    }

    override fun onCreate() {
        super.onCreate()
        isServiceRunning = true
        initCamera()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        registerScreenReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            when (intent.action) {
                ACTION_TOGGLE_TORCH -> {
                    if (intent.hasExtra("enable")) {
                        val wantOn = intent.getBooleanExtra("enable", false)
                        setTorch(wantOn)
                    } else {
                        setTorch(!isTorchOn)
                    }
                }
                ACTION_STOP_SERVICE -> {
                    stopSelf()
                    return START_NOT_STICKY
                }
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        isServiceRunning = false
        unregisterScreenReceiver()
        setTorch(false)
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
            Log.e(TAG, "Error initializing camera: ${e.message}")
        }
    }

    fun setTorch(on: Boolean) {
        val id = cameraId
        val manager = cameraManager
        if (id != null && manager != null) {
            try {
                manager.setTorchMode(id, on)
                isTorchOn = on
                isFlashlightOn = on
                
                val mManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                mManager.notify(NOTIFICATION_ID, buildNotification())
                
                onStateChangeListener?.invoke(on)
            } catch (e: Exception) {
                Log.e(TAG, "Error toggling torch: ${e.message}")
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Torch Lite Detector",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun buildNotification(): Notification {
        val toggleIntent = Intent(this, TorchService::class.java).apply {
            action = ACTION_TOGGLE_TORCH
        }
        val stopIntent = Intent(this, TorchService::class.java).apply {
            action = ACTION_STOP_SERVICE
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val togglePendingIntent = PendingIntent.getService(this, 1, toggleIntent, flags)
        val stopPendingIntent = PendingIntent.getService(this, 2, stopIntent, flags)

        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)
        val openAppPendingIntent = PendingIntent.getActivity(this, 0, openAppIntent, flags)

        val torchTextState = if (isTorchOn) "Torch: ON" else "Torch: OFF"
        
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder.setContentTitle("Torch Lite Gestures Active")
            .setContentText("Double-press power button to turn ON/OFF. ($torchTextState)")
            .setSmallIcon(android.R.drawable.ic_menu_compass) 
            .setContentIntent(openAppPendingIntent)
            .setOngoing(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            val toggleAction = Notification.Action.Builder(
                android.R.drawable.ic_media_play,
                if (isTorchOn) "Turn OFF" else "Turn ON",
                togglePendingIntent
            ).build()
            
            val stopAction = Notification.Action.Builder(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Disable Shortcut",
                stopPendingIntent
            ).build()

            builder.addAction(toggleAction)
            builder.addAction(stopAction)
        }

        return builder.build()
    }

    private fun registerScreenReceiver() {
        screenReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val action = intent?.action ?: return
                if (action != Intent.ACTION_SCREEN_ON && action != Intent.ACTION_SCREEN_OFF) return

                val now = android.os.SystemClock.elapsedRealtime()
                val sinceLastEvent = now - lastEventTime
                val sinceLastToggle = now - lastToggleTime

                Log.d(TAG, "Screen event: $action, gap: $sinceLastEvent ms")

                // Two screen events close together = a power-button double press.
                // The cooldown stops a third "bounce" event from instantly undoing the toggle
                // (that was the bug where the torch appeared to never turn ON).
                if (sinceLastEvent in 1..doublePressWindowMs && sinceLastToggle > cooldownMs) {
                    setTorch(!isTorchOn)
                    lastToggleTime = now
                }
                lastEventTime = now
            }
        }

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        // Android 13+ requires an explicit export flag when registering receivers.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(screenReceiver, filter)
        }
    }

    private fun unregisterScreenReceiver() {
        screenReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering screen receiver: ${e.message}")
            }
        }
        screenReceiver = null
    }
}
