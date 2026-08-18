import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite database manager for Dudh ka Hisab.
///
/// This module is designed to be **reusable** across future apps
/// (Hajiri, SHG Hisab, Truck Bhada, etc.) — just swap table definitions.
class DairyDatabase {
  static final DairyDatabase instance = DairyDatabase._internal();
  factory DairyDatabase() => instance;
  DairyDatabase._internal();

  static Database? _database;

  /// Current schema version — bump this when adding migrations.
  ///
  /// ⚠️ बढ़ाते समय `_onUpgrade` में भी लिखना **ज़रूरी** है। सिर्फ़ `_onCreate`
  /// में लिखना सबसे आम ग़लती है — नए install पर चल जाता है, पर जिस किसान का
  /// ऐप पहले से लगा है उसके यहाँ column बनता ही नहीं और ऐप टूट जाता है।
  static const int _schemaVersion = 8;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dudh_ka_hisab.db');

    return await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  /// हर table का DDL एक ही जगह — `IF NOT EXISTS` के साथ।
  ///
  /// ⚠️ पहले `dairy_product_entries`, `news_cache` और `saved_news` का DDL
  /// **दो जगह** लिखा था — एक `_onCreate` में, दूसरा `_onUpgrade` में। दोनों
  /// अलग हो जाने का पूरा ख़तरा था: नए install पर एक तरह का table बनता और
  /// update पर दूसरी तरह का। अब एक ही सच है।
  static const Map<String, String> _tableDdl = {
    'customers': '''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        defaultQtyL REAL DEFAULT 1.0,
        rateType TEXT DEFAULT 'flat',
        flatRate REAL DEFAULT 0.0,
        ratePerFatPoint REAL DEFAULT 6.8,
        partyType TEXT DEFAULT 'buyer',
        active INTEGER DEFAULT 1
      )
    ''',
    'entries': '''
      CREATE TABLE IF NOT EXISTS entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        date TEXT NOT NULL,
        shift TEXT NOT NULL,
        qtyL REAL NOT NULL,
        fatPct REAL,
        snf REAL,
        amount REAL NOT NULL,
        direction TEXT DEFAULT 'sell',
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''',
    'payments': '''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT DEFAULT '',
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''',
    'settings': '''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''',
    'dairy_product_entries': '''
      CREATE TABLE IF NOT EXISTS dairy_product_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        date TEXT NOT NULL,
        milkUsedL REAL NOT NULL,
        productQtyKg REAL NOT NULL,
        pricePerKg REAL NOT NULL DEFAULT 0.0,
        totalAmount REAL NOT NULL DEFAULT 0.0,
        note TEXT DEFAULT ''
      )
    ''',
    'news_cache': '''
      CREATE TABLE IF NOT EXISTS news_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        desc TEXT,
        fullDesc TEXT,
        date TEXT,
        link TEXT UNIQUE,
        image TEXT,
        source TEXT,
        category TEXT
      )
    ''',
    'saved_news': '''
      CREATE TABLE IF NOT EXISTS saved_news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        desc TEXT,
        fullDesc TEXT,
        date TEXT,
        link TEXT UNIQUE,
        image TEXT,
        source TEXT,
        savedAt TEXT
      )
    ''',
    'pashu': _createPashuTable,
    'saved_fields': _createSavedFieldsTable,
  };

  /// जो table मौजूद नहीं, उसे बना दो। जो है उसे छुओ मत।
  ///
  /// `_onCreate` और `_onUpgrade` दोनों इसी से चलते हैं। फ़ायदा — अगर किसी
  /// किसान का database बीच में कहीं अटक गया (migration अधूरा रह गया, या
  /// backup से अजीब version का data आ गया), तो अगली बार ऐप खुलते ही वह
  /// **ख़ुद ठीक हो जाता है**। किसी table के न होने से ऐप टूटना नहीं चाहिए।
  Future<void> _ensureAllTables(Database db) async {
    for (final ddl in _tableDdl.values) {
      await db.execute(ddl);
    }
  }

  /// Create all tables on first install.
  Future<void> _onCreate(Database db, int version) async {
    await _ensureAllTables(db);

    // Insert default settings
    await db.insert('settings', {'key': 'mode', 'value': 'kisan'});
    await db.insert('settings', {'key': 'language', 'value': 'hi'});
    await db.insert('settings', {'key': 'flatRate', 'value': '60'});
    await db.insert('settings', {'key': 'ratePerFatPoint', 'value': '6.8'});
    await db.insert('settings', {'key': 'entryCount', 'value': '0'});
    await db.insert('settings', {'key': 'reviewShown', 'value': 'false'});
  }

  /// Migrations for future schema updates.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ⚠️ सबसे पहले: जो table किसी वजह से बना ही नहीं, उसे बना दो।
    //
    // नीचे वाले `if (oldVersion < N)` यह मानकर चलते हैं कि किसान हर version
    // से होकर गुज़रा है। आम तौर पर यह सच है, पर हमेशा नहीं — migration बीच
    // में टूट सकता है, या backup से किसी और version का database आ सकता है।
    // तब कोई table छूट जाता और ऐप उसे पढ़ते ही टूट जाता।
    //
    // यह एक पंक्ति उसे ख़ुद ठीक कर देती है। जो table पहले से हैं उन्हें
    // छूती नहीं (`IF NOT EXISTS`), इसलिए किसी का data नहीं बिगड़ता।
    await _ensureAllTables(db);

    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE customers ADD COLUMN ratePerFatPoint REAL DEFAULT 6.8',
      );
      await db.execute(
        'ALTER TABLE customers ADD COLUMN address TEXT',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dairy_product_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId TEXT NOT NULL,
          date TEXT NOT NULL,
          milkUsedL REAL NOT NULL,
          productQtyKg REAL NOT NULL,
          pricePerKg REAL NOT NULL DEFAULT 0.0,
          totalAmount REAL NOT NULL DEFAULT 0.0,
          note TEXT DEFAULT ''
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS news_cache (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          desc TEXT,
          fullDesc TEXT,
          date TEXT,
          link TEXT UNIQUE,
          image TEXT,
          source TEXT,
          category TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS saved_news (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          desc TEXT,
          fullDesc TEXT,
          date TEXT,
          link TEXT UNIQUE,
          image TEXT,
          source TEXT,
          savedAt TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE customers ADD COLUMN partyType TEXT DEFAULT 'buyer'",
      );
      await db.execute(
        "ALTER TABLE entries ADD COLUMN direction TEXT DEFAULT 'sell'",
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_entries_direction ON entries(direction)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_customers_partyType ON customers(partyType)',
      );
    }
    if (oldVersion < 5) {
      await db.execute(_createPashuTable);
    }
    if (oldVersion < 6) {
      // पहले table बिना photoPath के बना हो सकता है — column-exists जाँच के बाद ADD
      final cols = await db.rawQuery("PRAGMA table_info(pashu)");
      final has = cols.any((c) => c['name'] == 'photoPath');
      if (!has) {
        await db.execute("ALTER TABLE pashu ADD COLUMN photoPath TEXT");
      }
    }
    if (oldVersion < 7) {
      await db.execute(_createSavedFieldsTable);
    }
    if (oldVersion < 8) {
      // पशु की फ़ोटो का **पूरा रास्ता** हटाकर सिर्फ़ फ़ाइल का नाम रखो।
      //
      // पूरा रास्ता उसी फ़ोन का होता था —
      //   /data/user/0/com.prokisan.app/app_flutter/pashu_photos/pashu_1.jpg
      //
      // फ़ोन बदलने पर (Android auto-backup से data लौटने पर) वह रास्ता वहाँ
      // होता ही नहीं, इसलिए पशु तो दिखते पर फ़ोटो की जगह टूटा निशान आता।
      //
      // अब सिर्फ़ 'pashu_1.jpg' रखते हैं; फ़ोल्डर PashuPhotoService.fullPath()
      // चलते समय जोड़ लेता है।
      //
      // SQLite में "आख़िरी / के बाद वाला हिस्सा" सीधे निकालने का function नहीं
      // है, इसलिए पंक्तियाँ पढ़कर Dart में काटते हैं। पशु आम तौर पर 5-50 ही
      // होते हैं, इसलिए यह भारी नहीं पड़ता।
      try {
        final rows = await db.query('pashu',
            columns: ['id', 'photoPath'], where: "photoPath IS NOT NULL");
        for (final r in rows) {
          final path = (r['photoPath'] ?? '').toString();
          if (path.isEmpty || !path.contains('/')) continue; // पहले से नाम है
          final name = path.split('/').last;
          await db.update('pashu', {'photoPath': name},
              where: 'id = ?', whereArgs: [r['id']]);
        }
      } catch (_) {
        // पशु table अभी न हो या कुछ और अड़चन — फ़ोटो का रास्ता ठीक न होना
        // ऐप रोकने लायक़ बात नहीं। fullPath() पुराने रास्ते भी समझता है।
      }
    }
  }

  /// पुराना ऐप नए database को खोल ले तो **कुछ मत करो**।
  ///
  /// ⚠️ यहाँ `onDatabaseDowngradeDelete` **कभी मत** लगाना — वह किसान का पूरा
  /// database मिटा देता है।
  ///
  /// बिना handler के sqflite अपवाद फेंकता है और ऐप खुलता ही नहीं। ऐसा तब हो
  /// सकता है जब Play Store पर rollback हो या किसान पुरानी APK साइड-लोड कर ले।
  /// ख़ाली handler से पुराना ऐप खुल जाता है — जो नए column उसे नहीं पता, उन्हें
  /// वह छूता ही नहीं, इसलिए data बचा रहता है।
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // जान-बूझकर ख़ाली
  }

  /// "मेरे पशु" — किसान के जानवरों की सूची + ब्याने/टीके की तारीख़ें।
  /// तारीख़ें ISO (yyyy-MM-dd) में रखी जाती हैं ताकि string तुलना ही काफ़ी हो।
  static const String _createPashuTable = '''
    CREATE TABLE IF NOT EXISTS pashu (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT DEFAULT '',
      type TEXT NOT NULL DEFAULT 'gaay',
      tagNo TEXT DEFAULT '',
      aiDate TEXT,
      calvingDate TEXT,
      lastVaccineDate TEXT,
      note TEXT DEFAULT '',
      photoPath TEXT,
      active INTEGER DEFAULT 1,
      createdAt TEXT
    )
  ''';

  /// 📐 "सेव किए हुए खेत" — नापे गए खेतों का इतिहास
  static const String _createSavedFieldsTable = '''
    CREATE TABLE IF NOT EXISTS saved_fields (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      areaSqM REAL NOT NULL,
      perimeterM REAL NOT NULL,
      pointsJson TEXT NOT NULL,
      stateCode TEXT,
      savedAt TEXT NOT NULL
    )
  ''';

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  /// Get the raw database for backup/restore operations.
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'dudh_ka_hisab.db');
  }
}
