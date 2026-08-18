package com.douyindownloader.douyin_downloader

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.douyindownloader.douyin_downloader/media_saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveMediaToGallery") {
                val filePath = call.argument<String>("filePath")
                val fileName = call.argument<String>("fileName")
                val mimeType = call.argument<String>("mimeType") ?: "video/mp4"
                
                if (filePath != null && fileName != null) {
                    val saved = saveMediaToMediaStore(context, filePath, fileName, mimeType)
                    if (saved) {
                        result.success(true)
                    } else {
                        result.error("SAVE_FAILED", "Failed to save media to gallery", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Arguments cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveMediaToMediaStore(context: Context, filePath: String, fileName: String, mimeType: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) return false

        val resolver = context.contentResolver
        val isVideo = mimeType.startsWith("video/")
        
        val contentUri: Uri = if (isVideo) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            }
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
        }

        val relativePath = if (isVideo) "Movies/DouyinDownloader" else "Pictures/DouyinDownloader"

        val values = ContentValues().apply {
            put(if (isVideo) MediaStore.Video.Media.DISPLAY_NAME else MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(if (isVideo) MediaStore.Video.Media.MIME_TYPE else MediaStore.Images.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(if (isVideo) MediaStore.Video.Media.RELATIVE_PATH else MediaStore.Images.Media.RELATIVE_PATH, relativePath)
                put(if (isVideo) MediaStore.Video.Media.IS_PENDING else MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        var uri: Uri? = null
        try {
            uri = resolver.insert(contentUri, values) ?: return false
            resolver.openOutputStream(uri).use { outputStream ->
                if (outputStream == null) return false
                FileInputStream(file).use { inputStream ->
                    val buffer = ByteArray(4096)
                    var bytesRead: Int
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                    }
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                values.clear()
                values.put(if (isVideo) MediaStore.Video.Media.IS_PENDING else MediaStore.Images.Media.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            }
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            if (uri != null) {
                resolver.delete(uri, null, null)
            }
            return false
        }
    }
}
