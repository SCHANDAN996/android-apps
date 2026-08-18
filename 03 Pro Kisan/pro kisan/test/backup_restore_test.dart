// 🛡️ backup लेकर वापस डालने पर किसान का data बचता है या नहीं
//
// यह जाँच असली schema पर असली database बनाती है, उसमें असली जैसा data भरती
// है, backup लेती है, सब मिटाकर restore करती है — और फिर गिनकर देखती है कि
// सब वापस आया या नहीं।
//
// ⚠️ पहले restore पहले `delete` करता था फिर डालता था। बीच में कुछ टूट जाए तो
// किसान का data मिट चुका होता और नया आया नहीं होता। अब वह एक ही transaction
// में है और ख़ाली फ़ाइल पर कुछ छेड़ता ही नहीं — नीचे दोनों बातें जाँची हैं।

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/db/dairy_database.dart';
import 'package:pro_kisan/services/backup_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // ⚠️ हर जाँच फ़ाइल को अपना अलग database दो।
    //
    // `flutter test` कई फ़ाइलें **एक साथ** चलाता है। सब एक ही
    // `dudh_ka_hisab.db` पर काम करें तो एक फ़ाइल database मिटाती है जबकि
    // दूसरी उसी में लिख रही होती है — जाँचें बेवजह फेल होती हैं और असली
    // गड़बड़ी छिप जाती है।
    await databaseFactory.setDatabasesPath(
        Directory.systemTemp.createTempSync('pk_restore').path);
  });

  /// हर जाँच से पहले ताज़ा database — पिछली जाँच का data न बचे
  setUp(() async {
    final db = await DairyDatabase.instance.database;
    for (final t in BackupService.backupTables) {
      try {
        await db.delete(t);
      } catch (_) {}
    }
  });

  /// किसान जैसा data भरो — हर तरह का, ताकि कोई कोना छूटे नहीं
  Future<void> bharoAsliJaisaData() async {
    final db = await DairyDatabase.instance.database;

    await db.insert('customers', {
      'name': 'रामू यादव',
      'phone': '9876543210',
      'defaultQtyL': 2.0,
    });
    await db.insert('entries', {
      'customerId': 1,
      'date': '2026-08-07',
      'shift': 'morning',
      'qtyL': 2.5,
      'fatPct': 4.2,
      'amount': 95.0,
    });
    await db.insert('payments', {
      'customerId': 1,
      'date': '2026-08-07',
      'amount': 500.0,
    });
    await db.insert('settings', {'key': 'lang', 'value': 'hi'});

    // ── ये चार वही हैं जो पहले backup से छूट जाते थे ──
    await db.insert('pashu', {
      'name': 'गौरी',
      'type': 'gaay',
      'tagNo': 'UP-1234',
      'aiDate': '2026-05-01',
      'calvingDate': '2027-02-08',
      'photoPath': 'pashu_1.jpg',
      'active': 1,
    });
    await db.insert('saved_fields', {
      'name': 'बड़ा खेत',
      'areaSqM': 4046.86,
      'perimeterM': 254.0,
      'pointsJson': '[[25.1,82.9],[25.2,82.9]]',
      'savedAt': '2026-08-07',
    });
    await db.insert('dairy_product_entries', {
      'productId': 'ghee',
      'date': '2026-08-07',
      'milkUsedL': 10.0,
      'productQtyKg': 0.5,
      'pricePerKg': 600.0,
      'totalAmount': 300.0,
    });
    await db.insert('saved_news', {
      'title': 'गेहूं का MSP बढ़ा',
      'link': 'https://example.com/1',
      'savedAt': '2026-08-07',
    });
  }

  Future<Map<String, int>> ginti() async {
    final db = await DairyDatabase.instance.database;
    final out = <String, int>{};
    for (final t in BackupService.backupTables) {
      final r = await db.rawQuery('SELECT COUNT(*) c FROM $t');
      out[t] = (r.first['c'] as int?) ?? 0;
    }
    return out;
  }

  group('🛡️ backup → restore में कुछ नहीं खोता', () {
    test('हर table का data वापस आता है — पशु और खेत भी', () async {
      await bharoAsliJaisaData();
      final pehle = await ginti();

      // हर table में कुछ न कुछ होना चाहिए, वरना जाँच बेमानी है
      for (final e in pehle.entries) {
        expect(e.value, greaterThan(0),
            reason: '"${e.key}" में जाँच का data ही नहीं भरा');
      }

      final svc = BackupService();
      final payload = await svc.buildPayload();

      // सब मिटाओ — जैसे नया फ़ोन हो
      final db = await DairyDatabase.instance.database;
      for (final t in BackupService.backupTables) {
        await db.delete(t);
      }
      expect((await ginti()).values.every((v) => v == 0), isTrue);

      // अब वापस डालो
      final ok = await svc.restoreFromDetectedBackup(payload);
      expect(ok, isTrue, reason: 'restore ही नाकाम हो गया');

      final baad = await ginti();
      expect(baad, pehle,
          reason: 'restore के बाद गिनती बदल गई — कुछ खो गया:\n'
              '  पहले: $pehle\n  बाद: $baad');
    });

    test('पशु की ब्याने-टीके की तारीख़ें ज्यों की त्यों लौटती हैं', () async {
      await bharoAsliJaisaData();
      final svc = BackupService();
      final payload = await svc.buildPayload();

      final db = await DairyDatabase.instance.database;
      await db.delete('pashu');
      await svc.restoreFromDetectedBackup(payload);

      final rows = await db.query('pashu');
      expect(rows, hasLength(1));
      final p = rows.first;
      // ये तारीख़ें किसान महीनों में जमा करता है — एक अंक भी बदला तो
      // ब्याने का रिमाइंडर ग़लत दिन बजेगा
      expect(p['name'], 'गौरी');
      expect(p['tagNo'], 'UP-1234');
      expect(p['aiDate'], '2026-05-01');
      expect(p['calvingDate'], '2027-02-08');
    });

    test('⚠️ ख़ाली/टूटी फ़ाइल पर restore कुछ नहीं मिटाता', () async {
      // सबसे ख़तरनाक हालत: किसान ग़लत फ़ाइल चुन ले। पहले वाला कोड पहले
      // delete करता था — उसका सब चला जाता। अब हाथ ही नहीं लगना चाहिए।
      await bharoAsliJaisaData();
      final pehle = await ginti();

      final svc = BackupService();
      expect(await svc.restoreFromDetectedBackup({}), isFalse);
      expect(await svc.restoreFromDetectedBackup({'tables': {}}), isFalse);
      expect(await svc.restoreFromDetectedBackup({'version': '2.0.0'}), isFalse);

      expect(await ginti(), pehle, reason: 'ख़ाली फ़ाइल ने data मिटा दिया!');
    });

    test('पुरानी 1.0.0 वाली backup फ़ाइल भी चलती है', () async {
      // जिस किसान के फ़ोन में पुरानी backup पड़ी है, उसका restore टूटे नहीं
      await bharoAsliJaisaData();
      final db = await DairyDatabase.instance.database;
      final pashuPehle = (await db.query('pashu')).length;

      const purani = {
        'version': '1.0.0',
        'customers': [
          {'id': 9, 'name': 'सुनीता देवी', 'phone': '9000000000'}
        ],
        'entries': <Map<String, dynamic>>[],
        'payments': <Map<String, dynamic>>[],
        'settings': {'lang': 'hi'},
      };

      expect(await BackupService().restoreFromDetectedBackup(purani), isTrue);

      final c = await db.query('customers');
      expect(c, hasLength(1));
      expect(c.first['name'], 'सुनीता देवी');

      // ⚠️ पुरानी फ़ाइल में पशु होते ही नहीं — इसलिए पशु मिटने नहीं चाहिए
      expect((await db.query('pashu')).length, pashuPehle,
          reason: 'पुरानी backup ने पशु मिटा दिए — वे उसमें थे ही नहीं!');
    });
  });
}
