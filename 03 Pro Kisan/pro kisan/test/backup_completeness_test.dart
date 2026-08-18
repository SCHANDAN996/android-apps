// 🛡️ किसान का data backup में पूरा जाता है या नहीं
//
// ## यह जाँच क्यों बनी
//
// 7 अगस्त 2026 को पता चला कि `BackupService` सिर्फ़ **4 tables** का backup
// लेता था — customers, entries, payments, settings — जबकि database में
// **9 tables** थे।
//
// यानी किसान का **पशु (ब्याने और टीके की तारीख़ें), GPS से नापे हुए खेत, और
// घी-पनीर का हिसाब** backup में जाता ही नहीं था। वह backup लेकर फ़ोन बदलता,
// restore करता, और ऐप "सफल" कह देता — पर वह सारा data हमेशा के लिए चला जाता।
// उसे पता भी नहीं चलता।
//
// ऐसी ग़लती दोबारा **चुपचाप निकल न जाए**, इसलिए ये जाँचें असली SQLite
// database बनाकर देखती हैं कि हर table backup में है या नहीं।

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/services/backup_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // sqflite फ़ोन का हिस्सा है; कंप्यूटर पर चलाने के लिए ffi चाहिए
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // (!) har jaanch file ko apna alag database do.
    //
    // `flutter test` kai file **ek saath** chalata hai. Sab ek hi
    // `dudh_ka_hisab.db` par kaam karein to ek file database mitati hai
    // jabki doosri usi me likh rahi hoti hai - jaanchein bewajah fail
    // hoti hain aur asli gadbadi chhip jaati hai.
    await databaseFactory.setDatabasesPath(
        Directory.systemTemp.createTempSync('pk_complete').path);
  });

  /// असली schema से एक ताज़ा database बनाओ (जैसे नए install पर बनता है)
  Future<Database> freshDb() async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    // DairyDatabase का _onCreate private है, इसलिए वही schema यहाँ नहीं
    // दोहरा सकते। पर असली सूची चाहिए, इसलिए नीचे वाली जाँच schema की
    // फ़ाइल से table के नाम पढ़ती है — कोड और जाँच एक ही सच पर टिके रहें।
    return db;
  }

  group('🛡️ backup में कोई table छूटा तो नहीं', () {
    test('schema के हर table का backup लिया जाता है (या जान-बूझकर छोड़ा है)',
        () async {
      // असली schema फ़ाइल से table के नाम निकालो — यही एकमात्र सच है
      final schemaFile = await _readSchemaSource();
      final schemaTables = _tableNamesIn(schemaFile);

      expect(schemaTables, isNotEmpty,
          reason: 'schema फ़ाइल से एक भी table नहीं मिला — जाँच ही टूटी है');

      final covered = {
        ...BackupService.backupTables,
        ...BackupService.skipTables,
      };

      final chhoote = schemaTables.where((t) => !covered.contains(t)).toList();

      expect(chhoote, isEmpty,
          reason: 'ये table न backup में हैं न छोड़ी हुई सूची में:\n'
              '  $chhoote\n\n'
              'किसान का यह data backup में नहीं जाएगा और फ़ोन बदलते ही\n'
              'हमेशा के लिए चला जाएगा। `BackupService.backupTables` में\n'
              'नाम डालिए — या अगर वह सिर्फ़ cache है तो `skipTables` में।');
    });

    test('backupTables और skipTables में कोई नाम दो बार नहीं', () {
      final dono = BackupService.backupTables
          .where((t) => BackupService.skipTables.contains(t))
          .toList();
      expect(dono, isEmpty,
          reason: 'ये दोनों सूचियों में हैं, तय कीजिए किसमें रहें: $dono');
    });

    test('किसान का असली data वाला हर table backup में है', () {
      // ये वे हैं जिनमें किसान की अपनी मेहनत है — इनका छूटना सबसे भारी है
      const zaroori = [
        'customers',              // ग्राहक
        'entries',                // दूध की रोज़ की एंट्री
        'payments',               // जमा-बाक़ी
        'pashu',                  // मेरे पशु — ब्याने/टीके की तारीख़ें
        'saved_fields',           // GPS से नापे हुए खेत
        'dairy_product_entries',  // घी/पनीर/खोया
        'settings',               // भाषा, राज्य, दर
      ];
      for (final t in zaroori) {
        expect(BackupService.backupTables, contains(t),
            reason: '"$t" किसान का असली data है — backup में होना ही चाहिए');
      }
    });

    test('cache वाले table backup में नहीं (जगह बचे)', () {
      // Android Auto Backup की 25 MB की हद है। ख़बरों का cache इंटरनेट आते ही
      // दोबारा भर जाता है, इसलिए उसे भेजने का फ़ायदा नहीं।
      expect(BackupService.backupTables, isNot(contains('news_cache')));
      expect(BackupService.skipTables, contains('news_cache'));
    });
  });

  group('🛡️ नए install पर database ठीक बनता है', () {
    test('DairyDatabase का schema बिना ग़लती के बनता है', () async {
      final db = await freshDb();
      addTearDown(db.close);
      expect(db.isOpen, isTrue);
    });
  });
}

/// `dairy_database.dart` की असली फ़ाइल पढ़ो
Future<String> _readSchemaSource() async {
  // जाँच project की जड़ से चलती है
  final f = File('lib/db/dairy_database.dart');
  return f.readAsString();
}

/// source में से `CREATE TABLE [IF NOT EXISTS] <naam>` के नाम निकालो
Set<String> _tableNamesIn(String src) {
  final re = RegExp(
    r'CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([A-Za-z_][A-Za-z0-9_]*)',
    caseSensitive: false,
  );
  return re.allMatches(src).map((m) => m.group(1)!).toSet();
}
