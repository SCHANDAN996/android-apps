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
  static const int _schemaVersion = 1;

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
    );
  }

  /// Create all tables on first install.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        defaultQtyL REAL DEFAULT 1.0,
        rateType TEXT DEFAULT 'flat',
        flatRate REAL DEFAULT 0.0,
        active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        date TEXT NOT NULL,
        shift TEXT NOT NULL,
        qtyL REAL NOT NULL,
        fatPct REAL,
        snf REAL,
        amount REAL NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT DEFAULT '',
        FOREIGN KEY (customerId) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

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
    // Example: if (oldVersion < 2) { db.execute('ALTER TABLE ...'); }
  }

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
