# AI Build Prompt - Douyin Video Downloader (No-Watermark Video & Photo Saver)

This file contains the complete technical specification, UI/UX flow, and native/Flutter implementation details for building the **Douyin Video Downloader** app.

---

## 1. Architecture Overview
The application is built using **Flutter** for the cross-platform UI (Android target) and **Dart** for parser logic. It uses **Kotlin (Android Native)** via a Method Channel to save downloaded files directly to the public Gallery/Media Store on Android 10+ (Scoped Storage) without requiring obsolete storage permissions.

```
+------------------------------------+
|            Flutter UI              |
|  - Paste & Parse, Preview, History |
+-----------------+------------------+
                  |
+-----------------v------------------+
|       DouyinParserService          |
|  - Short link redirect resolver    |
|  - Hybrid (HTML + API) parser      |
+-----------------+------------------+
                  | (Method Channel)
+-----------------v------------------+
|           MainActivity             | (Android Native Kotlin)
|  - MediaStore Saver (Scoped Storage)|
+------------------------------------+
```

---

## 2. Dependencies (`pubspec.yaml`)
Add these packages to the Flutter project:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.2                  # For API requests and downloading video streams
  path_provider: ^2.1.5         # For accessing local temporary directories
  permission_handler: ^11.3.1   # For permission checking (if needed on older devices)
  share_plus: ^11.0.0           # For quick share features
  google_fonts: ^6.2.1          # Premium Outfit / Mukta typography
  shared_preferences: ^2.5.3    # Saving download history metadata locally
  google_mobile_ads: ^9.0.0     # For AdMob banner and interstitial integration
```

---

## 3. Native Android Platform Integration (`MainActivity.kt`)
To save media directly into the public Android Gallery (under `Downloads` or `Movies` folder) across all Android versions (including Android 10, 11, 12, 13, 14, 15) using Scoped Storage:

```kotlin
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

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.douyindownloader.douyin_downloader/media_saver"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveVideoToGallery") {
                val filePath = call.argument<String>("filePath")
                val fileName = call.argument<String>("fileName")
                if (filePath != null && fileName != null) {
                    val saved = saveVideoToMediaStore(context, filePath, fileName)
                    if (saved) {
                        result.success(true)
                    } else {
                        result.error("SAVE_FAILED", "Failed to save video to gallery", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Arguments cannot be null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveVideoToMediaStore(context: Context, filePath: String, fileName: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) return false

        val resolver = context.contentResolver
        val videoCollection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }

        val values = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/DouyinDownloader")
                put(MediaStore.Video.Media.IS_PENDING, 1)
            }
        }

        var uri: Uri? = null
        try {
            uri = resolver.insert(videoCollection, values) ?: return false
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
                values.put(MediaStore.Video.Media.IS_PENDING, 0)
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
```

---

## 4. Parser Service (`douyin_parser_service.dart`)
Implement a robust parser that:
1. Resolves standard short links `https://v.douyin.com/xxxxxx` to their long redirected URL.
2. Extracts the `aweme_id` (video/item ID) via regular expression.
3. Queries `api.douyin.wtf/api/hybrid/video_data` as primary parser endpoint.
4. Falls back to scraping mobile Douyin web page (`RENDER_DATA`) if API is offline.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DouyinVideoInfo {
  final String title;
  final String coverUrl;
  final String videoUrl;
  final String authorName;
  final String authorAvatar;

  DouyinVideoInfo({
    required this.title,
    required this.coverUrl,
    required this.videoUrl,
    required this.authorName,
    required this.authorAvatar,
  });

  factory CopyFromJson(Map<String, dynamic> json) {
    // Parsing from api.douyin.wtf hybrid endpoint response
    final isMinimal = json.containsKey('video_data');
    if (isMinimal) {
      final data = json['video_data'];
      return DouyinVideoInfo(
        title: data['title'] ?? 'Douyin Video',
        coverUrl: data['cover'] ?? '',
        videoUrl: data['nwm_video_url'] ?? data['wm_video_url'] ?? '',
        authorName: data['author']['nickname'] ?? 'User',
        authorAvatar: data['author']['avatar'] ?? '',
      );
    }
    
    // Custom fallbacks / standard parse
    return DouyinVideoInfo(
      title: json['title'] ?? 'Douyin Video',
      coverUrl: json['coverUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      authorName: json['authorName'] ?? 'Douyin User',
      authorAvatar: json['authorAvatar'] ?? '',
    );
  }
}

class DouyinParserService {
  static const String primaryApiUrl = "https://api.douyin.wtf/api/hybrid/video_data";

  // Regex to extract URL from clipboard copy text
  static String? extractUrl(String text) {
    final regExp = RegExp(r'https?:\/\/[^\s]+');
    final match = regExp.firstMatch(text);
    return match?.group(0);
  }

  // Follow redirect link to resolve actual target URL
  static Future<String> resolveRedirect(String shortUrl) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(shortUrl));
    request.followRedirects = false;
    final response = await request.close();
    final redirectUrl = response.headers.value(HttpHeaders.locationHeader);
    if (redirectUrl != null) {
      return redirectUrl;
    }
    return shortUrl;
  }

  // Parse video data using Primary API and Fallback scraper
  static Future<DouyinVideoInfo> parseVideo(String inputLink) async {
    final cleanUrl = extractUrl(inputLink);
    if (cleanUrl == null) {
      throw Exception("No valid link found in input.");
    }

    // Try primary high-speed API
    try {
      final response = await http.get(
        Uri.parse("$primaryApiUrl?url=$cleanUrl&minimal=true"),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json.containsKey('video_data') || json.containsKey('nwm_video_url')) {
          return DouyinVideoInfo.factory(json);
        }
      }
    } catch (_) {
      // Proceed to fallback
    }

    // Fallback parser: Resolving redirect and local scraping
    try {
      final resolvedUrl = await resolveRedirect(cleanUrl);
      final idRegExp = RegExp(r'video\/(\d+)');
      final match = idRegExp.firstMatch(resolvedUrl);
      final awemeId = match?.group(1);

      if (awemeId == null) {
        throw Exception("Could not extract video ID.");
      }

      // Fetch web page source of direct video
      final webResponse = await http.get(
        Uri.parse("https://www.douyin.com/video/$awemeId"),
        headers: {
          "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
        },
      );

      if (webResponse.statusCode == 200) {
        // Regex search for RENDER_DATA
        final renderDataReg = RegExp(r'<script id="RENDER_DATA" type="application\/json">([^<]+)<\/script>');
        final renderMatch = renderDataReg.firstMatch(webResponse.body);
        if (renderMatch != null) {
          final decodedJsonStr = Uri.decodeComponent(renderMatch.group(1)!);
          final Map<String, dynamic> renderData = jsonDecode(decodedJsonStr);
          
          // Traverse through renderData object structure (changes frequently, verify paths)
          // Find standard detail objects inside renderData mapping
          // Extract title, video url without watermark
        }
      }
    } catch (e) {
      throw Exception("Failed parsing video: $e");
    }

    throw Exception("Service is temporarily busy. Please try again.");
  }
}
```

---

## 5. UI Design System & Dashboard (Flutter)
- **Visuals**: Modern Glassmorphic Dark-Mode UI. Red/Cyan gradients matching TikTok/Douyin aesthetics.
- **Micro-animations**: Smooth Hero transitions on download progress, fading loaders, and pulsing download buttons.
- **Controls**:
  - `Input Box`: With direct "Paste Link" and "Clear" buttons.
  - `Download History`: Local offline list showing past downloads with thumbnails, size, and one-click play/share buttons.
  - `AdMob Banner`: Sticky banner at the bottom of the home screen.
