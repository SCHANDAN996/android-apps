// 🛡️ ऐप update होने पर किसान का पुराना data बचता है या नहीं
//
// ## यह सबसे ज़रूरी जाँच क्यों है
//
// Play Store से update होने पर Android ऐप का data मिटाता नहीं — database
// फ़ाइल ज्यों की त्यों रहती है। पर उसमें **पुराना schema** होता है।
//
// नया कोड जब उसे खोलता है तो `_onUpgrade` चलता है। अगर वहाँ कोई ग़लती हो —
// column जोड़ना भूल जाएँ, या table `DROP` कर दें — तो किसान का महीनों का
// हिसाब उसी घड़ी चला जाता है। और पता तब चलता है जब वह ऐप खोलकर देखता है।
//
// इसलिए यहाँ **सचमुच** पुराने version का database बनाते हैं, उसमें असली जैसा
// data भरते हैं, फिर नए कोड से खोलकर गिनते हैं कि सब बचा या नहीं।

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/db/dairy_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// version 5 का schema — जब पशु table अभी-अभी आया था, photoPath से पहले
const _v5Schema = [
  '''CREATE TABLE customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL, phone TEXT, address TEXT,
      defaultQtyL REAL DEFAULT 1.0, rateType TEXT DEFAULT 'flat',
      ratePerLitre REAL DEFAULT 0.0, ratePerFatPoint REAL DEFAULT 6.8,
      partyType TEXT DEFAULT 'buyer')''',
  '''CREATE TABLE entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT, customerId INTEGER,
      date TEXT NOT NULL, shift TEXT NOT NULL, qtyL REAL NOT NULL,
      fatPct REAL, snf REAL, amount REAL NOT NULL,
      direction TEXT DEFAULT 'sell')''',
  '''CREATE TABLE payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT, customerId INTEGER,
      date TEXT NOT NULL, amount REAL NOT NULL, note TEXT DEFAULT '')''',
  '''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)''',
  '''CREATE TABLE pashu (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT DEFAULT '',
      type TEXT NOT NULL DEFAULT 'gaay', tagNo TEXT DEFAULT '',
      aiDate TEXT, calvingDate TEXT, lastVaccineDate TEXT,
      note TEXT DEFAULT '', active INTEGER DEFAULT 1, createdAt TEXT)''',
];

void main() {
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
        Directory.systemTemp.createTempSync('pk_migrate').path);
  });

  /// पुराने version का database फ़ाइल में बनाओ, उसमें data भरो, बंद करो।
  /// फिर असली ऐप का कोड उसे खोलेगा और migration चलाएगा।
  Future<String> banaoPuranaDb(int version, {String? photoPath}) async {
    final dir = await databaseFactory.getDatabasesPath();
    final path = '$dir/dudh_ka_hisab.db';

    await DairyDatabase.instance.close();
    await databaseFactory.deleteDatabase(path);

    final db = await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(version: version));
    for (final sql in _v5Schema) {
      await db.execute(sql);
    }

    // किसान का असली जैसा data
    await db.insert('customers', {'name': 'रामू यादव', 'phone': '9876543210'});
    await db.insert('entries', {
      'customerId': 1, 'date': '2026-06-01', 'shift': 'morning',
      'qtyL': 3.0, 'amount': 114.0,
    });
    await db.insert('payments',
        {'customerId': 1, 'date': '2026-06-05', 'amount': 500.0});
    await db.insert('settings', {'key': 'lang', 'value': 'hi'});
    await db.insert('pashu', {
      'name': 'गौरी', 'type': 'gaay', 'tagNo': 'UP-1234',
      'aiDate': '2026-05-01', 'calvingDate': '2027-02-08', 'active': 1,
    });
    if (photoPath != null) {
      // v5 में photoPath column नहीं था — v6 में जुड़ा
      await db.execute('ALTER TABLE pashu ADD COLUMN photoPath TEXT');
      await db.update('pashu', {'photoPath': photoPath});
      await db.setVersion(6);
    }
    await db.close();
    return path;
  }

  group('🛡️ update में किसान का data नहीं खोता', () {
    test('version 5 का पुराना ऐप → आज का ऐप: सब बचता है', () async {
      await banaoPuranaDb(5);

      // अब असली ऐप का कोड खोलेगा — यहीं migration 5→8 चलेगा
      final db = await DairyDatabase.instance.database;
      addTearDown(DairyDatabase.instance.close);

      // पुराना data ज्यों का त्यों?
      final c = await db.query('customers');
      expect(c, hasLength(1));
      expect(c.first['name'], 'रामू यादव');

      final e = await db.query('entries');
      expect(e, hasLength(1));
      expect(e.first['qtyL'], 3.0);
      expect(e.first['amount'], 114.0);

      final pay = await db.query('payments');
      expect(pay.first['amount'], 500.0);

      // पशु की तारीख़ें — ये किसान महीनों में जमा करता है
      final p = await db.query('pashu');
      expect(p, hasLength(1));
      expect(p.first['tagNo'], 'UP-1234');
      expect(p.first['aiDate'], '2026-05-01');
      expect(p.first['calvingDate'], '2027-02-08');

      // और नए version के table/column भी बन गए?
      expect(await db.query('saved_fields'), isEmpty); // v7 में आया
      final cols = await db.rawQuery('PRAGMA table_info(pashu)');
      expect(cols.any((c) => c['name'] == 'photoPath'), isTrue,
          reason: 'v6 वाला photoPath column नहीं बना');
    });

    test('version 8 का migration फ़ोटो का पूरा रास्ता छोटा कर देता है',
        () async {
      // पुराने ऐप में पूरा रास्ता रखा जाता था — वह दूसरे फ़ोन पर नहीं चलता
      const puranaRasta =
          '/data/user/0/com.prokisan.app/app_flutter/pashu_photos/pashu_99.jpg';
      await banaoPuranaDb(5, photoPath: puranaRasta);

      final db = await DairyDatabase.instance.database;
      addTearDown(DairyDatabase.instance.close);

      final p = await db.query('pashu');
      expect(p.first['photoPath'], 'pashu_99.jpg',
          reason: 'पूरा रास्ता छोटा नहीं हुआ — फ़ोन बदलने पर फ़ोटो टूटेगी');

      // बाक़ी सब वैसा ही रहे
      expect(p.first['name'], 'गौरी');
      expect(p.first['calvingDate'], '2027-02-08');
    });

    test('दोबारा खोलने पर कुछ नहीं बिगड़ता (migration दो बार न चले)', () async {
      await banaoPuranaDb(5);

      final db1 = await DairyDatabase.instance.database;
      final pehle = (await db1.query('entries')).length;
      await DairyDatabase.instance.close();

      // दूसरी बार — अब version पहले से 8 है, migration नहीं चलना चाहिए
      final db2 = await DairyDatabase.instance.database;
      addTearDown(DairyDatabase.instance.close);
      expect((await db2.query('entries')).length, pehle);
      expect((await db2.query('customers')).length, 1);
    });

    test('⚠️ schema version और migration साथ-साथ बढ़े हैं', () async {
      // सबसे आम ग़लती: column सिर्फ़ _onCreate में जोड़ना और _onUpgrade में
      // भूल जाना। तब नए install पर चलता है, पर पुराने किसान का ऐप टूटता है।
      //
      // यहाँ पक्का करते हैं कि सबसे पुराने version से खुलने पर भी वही सारे
      // table बनें जो नए install पर बनते हैं।
      await banaoPuranaDb(5);
      final upgraded = await DairyDatabase.instance.database;
      final purane = (await upgraded.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'"))
          .map((r) => r['name'].toString())
          .where((n) => !n.startsWith('sqlite_') && n != 'android_metadata')
          .toSet();
      await DairyDatabase.instance.close();

      // अब बिल्कुल नया install
      final dir = await databaseFactory.getDatabasesPath();
      await databaseFactory.deleteDatabase('$dir/dudh_ka_hisab.db');
      final fresh = await DairyDatabase.instance.database;
      addTearDown(DairyDatabase.instance.close);
      final naye = (await fresh.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table'"))
          .map((r) => r['name'].toString())
          .where((n) => !n.startsWith('sqlite_') && n != 'android_metadata')
          .toSet();

      expect(purane, naye,
          reason: 'update से आया database नए install जैसा नहीं है।\n'
              '  update पर: $purane\n'
              '  नए पर    : $naye\n'
              'यानी कोई table/migration _onUpgrade में लिखना छूट गया है।');
    });
  });
}
