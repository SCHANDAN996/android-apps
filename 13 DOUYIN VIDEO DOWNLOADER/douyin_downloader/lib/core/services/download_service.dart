import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadItem {
  final String id;
  final String title;
  final String coverUrl;
  final String date;
  final String type; // 'video' or 'photo'
  final int fileSize;

  DownloadItem({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.date,
    required this.type,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverUrl': coverUrl,
        'date': date,
        'type': type,
        'fileSize': fileSize,
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        coverUrl: json['coverUrl'] ?? '',
        date: json['date'] ?? '',
        type: json['type'] ?? 'video',
        fileSize: json['fileSize'] ?? 0,
      );
}

class DownloadService {
  static const MethodChannel _channel =
      MethodChannel('com.douyindownloader.douyin_downloader/media_saver');
  static const String _historyKey = "douyin_download_history";

  /// Downloads a file from [url] with progress tracking via [onProgress]
  /// and saves it using the native MediaStore saver.
  static Future<bool> downloadMedia({
    required String url,
    required String title,
    required String coverUrl,
    required bool isVideo,
    required Function(double progress) onProgress,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      
      // Some media links require headers
      request.headers['User-Agent'] =
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36";
      request.headers['Referer'] = "https://www.douyin.com/";

      final response = await client.send(request);
      
      if (response.statusCode != 200) {
        throw Exception("Server returned code ${response.statusCode}");
      }

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      
      final ext = isVideo ? 'mp4' : 'jpg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/temp_$timestamp.$ext');

      final fileSink = tempFile.openWrite();
      int downloadedBytes = 0;

      await for (var chunk in response.stream) {
        downloadedBytes += chunk.length;
        fileSink.add(chunk);
        
        if (contentLength > 0) {
          onProgress(downloadedBytes / contentLength);
        } else {
          // Fallback progress estimation
          onProgress(-1.0);
        }
      }

      await fileSink.close();
      client.close();

      // Trigger Native Method Channel to move to Gallery
      final String fileName = "Douyin_${timestamp}_${isVideo ? 'video' : 'photo'}.$ext";
      final String mimeType = isVideo ? "video/mp4" : "image/jpeg";

      final bool success = await _channel.invokeMethod('saveMediaToGallery', {
        'filePath': tempFile.path,
        'fileName': fileName,
        'mimeType': mimeType,
      });

      // Cleanup local temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (success) {
        // Save to Download History
        await _addToHistory(
          title: title,
          coverUrl: coverUrl,
          type: isVideo ? 'video' : 'photo',
          fileSize: downloadedBytes,
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Saves download entry metadata locally
  static Future<void> _addToHistory({
    required String title,
    required String coverUrl,
    required String type,
    required int fileSize,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList(_historyKey) ?? [];
      
      final newItem = DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        coverUrl: coverUrl,
        date: DateTime.now().toLocal().toString().split('.')[0],
        type: type,
        fileSize: fileSize,
      );

      historyList.insert(0, jsonEncode(newItem.toJson()));
      
      // Limit history to last 50 entries
      if (historyList.length > 50) {
        historyList.removeRange(50, historyList.length);
      }

      await prefs.setStringList(_historyKey, historyList);
    } catch (_) {}
  }

  /// Retrieves download history list
  static Future<List<DownloadItem>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList(_historyKey) ?? [];
      return historyList
          .map((item) => DownloadItem.fromJson(jsonDecode(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Clears download history
  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }
}
