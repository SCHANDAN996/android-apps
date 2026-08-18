import 'package:sqflite/sqflite.dart';
import '../dairy_database.dart';
import '../models/customer.dart';

/// Data Access Object for customers table.
class CustomerDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Insert a new customer. Returns the new row id.
  Future<int> insertCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  /// Update an existing customer.
  Future<int> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Soft-delete a customer (set active = 0).
  Future<int> deactivateCustomer(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      {'active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all active customers, sorted by name.
  Future<List<Customer>> getActiveCustomers() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'active = 1',
      orderBy: 'name ASC',
    );
    return maps.map((m) => Customer.fromMap(m)).toList();
  }

  /// Get a single customer by ID.
  Future<Customer?> getCustomerById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  /// Get all customers (including inactive) for backup.
  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final maps = await db.query('customers');
    return maps.map((m) => Customer.fromMap(m)).toList();
  }

  /// Count active customers.
  Future<int> getActiveCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM customers WHERE active = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
