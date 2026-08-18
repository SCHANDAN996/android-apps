import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import '../db/dao/settings_dao.dart';
import '../db/dairy_database.dart';
import '../db/db_change_bus.dart';
import 'backup_guard.dart';

class BackupService {
  final SettingsDao _settingsDao = SettingsDao();

  /// backup की बनावट का version.
  ///
  /// `1.0.0` — सिर्फ़ customers/entries/payments/settings (7 अगस्त 2026 तक)
  /// `2.0.0` — सारे tables (पशु, नापे हुए खेत, घी-पनीर, सहेजी ख़बरें भी)
  ///
  /// पुरानी `1.0.0` फ़ाइल भी restore होती रहेगी — जिस किसान के फ़ोन में पुरानी
  /// backup पड़ी है उसका restore टूटना नहीं चाहिए।
  static const String _backupVersion = "2.0.0";
  static const String _autobackupFileName = "pro_kisan_autobackup.json";

  /// जिन tables का backup लेना है।
  ///
  /// ⚠️ **नया table बनाएँ तो नाम यहाँ भी डालिए।** वरना किसान का वह सारा data
  /// backup में जाएगा ही नहीं, और restore "सफल" कहकर उसे चुपचाप खा जाएगा।
  ///
  /// 7 अगस्त 2026 को यही हुआ था — backup सिर्फ़ 4 tables लेता था, जबकि DB में
  /// 9 थे। किसान का **पशु (ब्याने-टीके की तारीख़ें), नापे हुए खेत और घी-पनीर
  /// का हिसाब** फ़ोन बदलते ही ग़ायब हो जाता।
  ///
  /// `test/backup_completeness_test.dart` इसे पकड़ता है — वह DB की असली सूची
  /// से मिलाकर देखता है कि कोई table छूटा तो नहीं।
  static const List<String> backupTables = [
    'customers',
    'entries',
    'payments',
    'settings',
    'pashu',
    'saved_fields',
    'dairy_product_entries',
    'saved_news',
  ];

  /// जिन्हें जान-बूझकर छोड़ा है — ये किसान का data नहीं, बस cache हैं।
  /// इंटरनेट आते ही दोबारा भर जाते हैं, इसलिए backup में जगह घेरने का फ़ायदा
  /// नहीं (Android Auto Backup की 25 MB की हद है)।
  static const List<String> skipTables = ['news_cache'];

  /// Generate Backup JSON Payload Map
  ///
  /// हर table को **सीधे SQL से** पढ़ते हैं, model के `toMap()` से नहीं।
  /// वजह: model में कोई खाना जोड़ना/हटाना भूल जाएँ तो backup चुपचाप अधूरा हो
  /// जाता। raw पंक्ति में जो है, वही जाता है — कुछ छूटता नहीं।
  Future<Map<String, dynamic>> _generateBackupPayload() async {
    final db = await DairyDatabase.instance.database;

    final tables = <String, List<Map<String, dynamic>>>{};
    for (final t in backupTables) {
      try {
        tables[t] = await db.query(t);
      } catch (_) {
        // table अभी बना ही न हो (पुराना DB) — उसे छोड़कर आगे बढ़ो,
        // पूरा backup रोकने की ज़रूरत नहीं
        tables[t] = const [];
      }
    }

    return {
      "version": _backupVersion,
      "timestamp": DateTime.now().toIso8601String(),
      // गिनती सिर्फ़ दिखाने के लिए — restore इन पर निर्भर नहीं
      "customerCount": tables['customers']?.length ?? 0,
      "entryCount": tables['entries']?.length ?? 0,
      "pashuCount": tables['pashu']?.length ?? 0,

      // ── 2.0.0 का असली हिस्सा: हर table अपने नाम से ──
      "tables": tables,

      // ── पुराने ऐप के लिए (1.0.0 पढ़ने वाला restore इन्हें ढूँढ़ता है) ──
      // नया ऐप `tables` इस्तेमाल करता है; ये सिर्फ़ पीछे की ओर निभाने को हैं।
      "customers": tables['customers'] ?? const [],
      "entries": tables['entries'] ?? const [],
      "payments": tables['payments'] ?? const [],
      "settings": await _settingsDao.getAllSettings(),
    };
  }

  /// backup का पूरा payload — जो भी उसे भेजना/जाँचना चाहे उसके लिए।
  ///
  /// इस्तेमाल दो जगह होता है:
  ///  • `GoogleDriveBackup` — किसान के Google खाते पर चढ़ाने के लिए
  ///  • `test/backup_restore_test.dart` — यह जाँचने कि restore में कुछ खोता तो नहीं
  ///
  /// दोनों **वही** payload लें, यह ज़रूरी है — वरना जाँच किसी और चीज़ को
  /// परखेगी और Drive पर कुछ और चढ़ेगा।
  Future<Map<String, dynamic>> buildPayload() => _generateBackupPayload();

  /// Silent Auto-Save to App Storage (100% Play Store & Scoped Storage Compliant)
  Future<bool> autoSaveToPublicFolder() async {
    try {
      final payload = await _generateBackupPayload();
      final jsonString = jsonEncode(payload);

      List<Directory> targetDirs = [];

      // 1. App Documents Directory (Internal storage)
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        final folder = Directory('${appDocs.path}/ProKisan_Backups');
        if (!await folder.exists()) await folder.create(recursive: true);
        targetDirs.add(folder);
      } catch (_) {}

      // 2. App External Storage Directory (External app storage, survives until uninstalled)
      try {
        final extDocs = await getExternalStorageDirectory();
        if (extDocs != null) {
          final folder = Directory('${extDocs.path}/ProKisan_Backups');
          if (!await folder.exists()) await folder.create(recursive: true);
          targetDirs.add(folder);
        }
      } catch (_) {}

      // 3. ⭐ Public Documents — असली जीवन-रक्षक: ऐप UNINSTALL होने पर भी
      // यह folder बचा रहता है। (ऊपर के दोनों folder uninstall पर मिट जाते
      // हैं — पहले सिर्फ़ वही थे, इसलिए uninstall-protection टूटी हुई थी।)
      // Android 11+ पर public Documents में अपनी file बनाना बिना permission
      // के FUSE से चलता है।
      try {
        final publicDocs =
            Directory('/storage/emulated/0/Documents/ProKisan_Backups');
        if (!await publicDocs.exists()) await publicDocs.create(recursive: true);
        targetDirs.add(publicDocs);
      } catch (_) {}

      // 4. Download folder — कुछ फ़ोन Documents नहीं बनाने देते, तो यहाँ
      try {
        final publicDl =
            Directory('/storage/emulated/0/Download/ProKisan_Backups');
        if (!await publicDl.exists()) await publicDl.create(recursive: true);
        targetDirs.add(publicDl);
      } catch (_) {}

      int writeSuccessCount = 0;
      // कौन-कौन सी जगह सचमुच लिखा गया — settings में यही दिखाते हैं, ताकि
      // उपयोगकर्ता को फ़ाइल ढूँढ़नी न पड़े। (Android 11+ पर public folder में
      // लिखना अक्सर मना होता है, इसलिए "अंदाज़े का path" दिखाना ग़लत होगा।)
      final savedPaths = <String>[];
      for (var dir in targetDirs) {
        try {
          final file = File('${dir.path}/$_autobackupFileName');
          await file.writeAsString(jsonString);
          writeSuccessCount++;
          savedPaths.add(file.path);
        } catch (_) {}
      }

      await _settingsDao.setValue('last_auto_backup', DateTime.now().toIso8601String());
      try {
        await _settingsDao.setValue('backup_saved_paths', savedPaths.join('\n'));
      } catch (_) {}
      return writeSuccessCount > 0;
    } catch (_) {
      return false;
    }
  }

  /// Scan for existing backup file across safe auto-backup locations
  Future<Map<String, dynamic>?> detectExistingBackup() async {
    try {
      List<String> pathsToSearch = [];

      // 1. Application Documents Directory
      try {
        final appDocs = await getApplicationDocumentsDirectory();
        pathsToSearch.add('${appDocs.path}/ProKisan_Backups/$_autobackupFileName');
      } catch (_) {}

      // 2. External Storage Directory
      try {
        final extDocs = await getExternalStorageDirectory();
        if (extDocs != null) {
          pathsToSearch.add('${extDocs.path}/ProKisan_Backups/$_autobackupFileName');
        }
      } catch (_) {}

      // 3. Public Documents (uninstall के बाद भी बचता है)
      pathsToSearch.add('/storage/emulated/0/Documents/ProKisan_Backups/$_autobackupFileName');

      // 4. Public Download
      pathsToSearch.add('/storage/emulated/0/Download/ProKisan_Backups/$_autobackupFileName');

      for (var path in pathsToSearch) {
        try {
          final file = File(path);
          if (await file.exists()) {
            final content = await file.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            if (data.containsKey("version") && data.containsKey("customers")) {
              data['filePath'] = path;
              return data;
            }
          }
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }

  /// 1-Click Restore from Detected Backup Data Payload
  /// backup की फ़ाइल में से हर table की पंक्तियाँ निकालो।
  ///
  /// दोनों बनावटें समझता है —
  ///  • `2.0.0` → सब कुछ `tables` के नीचे
  ///  • `1.0.0` → customers/entries/payments/settings ऊपर ही पड़े हैं
  ///
  /// पुरानी फ़ाइल वाले किसान का restore टूटना नहीं चाहिए, इसलिए दोनों निभाते हैं।
  Map<String, List<Map<String, dynamic>>> _readTables(Map<String, dynamic> data) {
    final out = <String, List<Map<String, dynamic>>>{};

    List<Map<String, dynamic>> rows(dynamic v) => v is List
        ? v.map((e) => Map<String, dynamic>.from(e as Map)).toList()
        : const [];

    final t = data['tables'];
    if (t is Map) {
      // 2.0.0
      t.forEach((k, v) => out['$k'] = rows(v));
    } else {
      // 1.0.0 — पुरानी बनावट
      for (final k in ['customers', 'entries', 'payments']) {
        if (data.containsKey(k)) out[k] = rows(data[k]);
      }
      // settings पुरानी फ़ाइल में key→value का नक्शा था, पंक्तियाँ नहीं
      final s = data['settings'];
      if (s is Map) {
        out['settings'] = s.entries
            .map((e) => {'key': e.key.toString(), 'value': e.value.toString()})
            .toList();
      }
    }
    return out;
  }

  /// 1-Click Restore from Detected Backup Data Payload
  ///
  /// ⚠️ **पहले पूरा पढ़ो और जाँचो, तभी हाथ लगाओ।**
  ///
  /// पहले यह उल्टा था — पहले चार tables `delete` करता, फिर डालता। बीच में
  /// कुछ टूट जाए (फ़ाइल अधूरी, कोई खाना बदला हुआ) तो किसान का data मिट चुका
  /// होता और नया आया नहीं होता। अब सब कुछ एक ही transaction में है और उससे
  /// पहले जाँच लेते हैं कि फ़ाइल में सचमुच कुछ है।
  Future<bool> restoreFromDetectedBackup(Map<String, dynamic> data) async {
    try {
      final parsed = _readTables(data);

      // ख़ाली/टूटी फ़ाइल पर कुछ मत छेड़ो — वरना जो है वह भी चला जाएगा
      final kuchHai = parsed.values.any((rows) => rows.isNotEmpty);
      if (!kuchHai) return false;

      final db = await DairyDatabase.instance.database;

      await db.transaction((txn) async {
        // सिर्फ़ उन्हीं tables को हाथ लगाओ जो फ़ाइल में सचमुच आए हैं।
        // पुरानी 1.0.0 फ़ाइल में पशु नहीं होते — तब पशु मिटने नहीं चाहिए।
        //
        // उल्टे क्रम में मिटाते हैं (पहले बच्चे, फिर माँ) ताकि किसी दिन
        // foreign key लगें तो भी यह कोड सही रहे।
        for (final t in backupTables.reversed) {
          if (parsed.containsKey(t)) {
            try {
              await txn.delete(t);
            } catch (_) {}
          }
        }

        for (final t in backupTables) {
          final rows = parsed[t];
          if (rows == null) continue;
          for (final row in rows) {
            try {
              await txn.insert(t, row,
                  conflictAlgorithm: ConflictAlgorithm.replace);
            } catch (_) {
              // एक पंक्ति में कोई पुराना/नया खाना बेमेल हो तो उसी को छोड़ो,
              // पूरा restore मत रोको — बाक़ी सब किसान को वापस मिल जाए
            }
          }
        }
      });

      notifyDbChanged();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Exports all data to a JSON string and triggers sharing sheet.
  Future<bool> exportBackup() async {
    try {
      final payload = await _generateBackupPayload();
      final jsonString = jsonEncode(payload);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/pro_kisan_backup.json');
      await file.writeAsString(jsonString);

      // Also auto-save to public folder on export
      await autoSaveToPublicFolder();

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'प्रो किसान बहीखाता बैकअप फाइल',
      );
      final bheja = result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;

      // ⚠️ भेजने के बाद यह बताना ज़रूरी है, वरना हफ़्ते वाली याद टोकती रहेगी
      // — किसान ने WhatsApp पर भेज तो दिया, पर ऐप को पता ही नहीं चलता।
      if (bheja) {
        try {
          await BackupGuard.instance.markBackedUp();
        } catch (_) {}
      }
      return bheja;
    } catch (e) {
      return false;
    }
  }

  /// Imports database from a selected JSON file.
  Future<String> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return "कोई फाइल चुनी नहीं गई";
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (!data.containsKey("version")) {
        return "गलत फाइल प्रारूप (प्रारूप वर्शन नहीं मिला)";
      }

      final success = await restoreFromDetectedBackup(data);
      if (success) {
        return "सफलतापूर्वक डेटा रीस्टोर हो गया!";
      } else {
        return "त्रुटि: रीस्टोर विफल रहा";
      }
    } catch (e) {
      return "त्रुटि: रीस्टोर विफल रहा (${e.toString()})";
    }
  }

  /// Get last backup timestamp string
  Future<String?> getLastBackupTimestamp() async {
    return await _settingsDao.getValue('last_auto_backup');
  }
}
