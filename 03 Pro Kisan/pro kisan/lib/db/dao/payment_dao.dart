import '../dairy_database.dart';
import '../db_change_bus.dart';
import '../models/payment.dart';

/// Data Access Object for payments table.
class PaymentDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Insert a new payment record.
  Future<int> insertPayment(Payment payment) async {
    final db = await _dbHelper.database;
    final id = await db.insert('payments', payment.toMap());
    notifyDbChanged();
    return id;
  }

  /// Update a payment.
  Future<int> updatePayment(Payment payment) async {
    final db = await _dbHelper.database;
    final n = await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    notifyDbChanged();
    return n;
  }

  /// Delete a payment.
  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    final n = await db.delete('payments', where: 'id = ?', whereArgs: [id]);
    notifyDbChanged();
    return n;
  }

  /// Get payments for a specific customer in a month.
  Future<List<Payment>> getCustomerMonthlyPayments(
    int customerId,
    String month, // MM-YYYY
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'payments',
      where: "customerId = ? AND substr(date, 4) = ?",
      whereArgs: [customerId, month],
      orderBy: 'date DESC',
    );
    return maps.map((m) => Payment.fromMap(m)).toList();
  }

  /// Total payments received from a customer (all time).
  Future<double> getTotalPaymentsByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE customerId = ?',
      [customerId],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Total payments received from a customer in a specific month.
  Future<double> getCustomerMonthlyPaymentTotal(
    int customerId,
    String month,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE customerId = ? AND substr(date, 4) = ?",
      [customerId, month],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Customer due = total entry amounts - total payments.
  Future<double> getCustomerDue(int customerId) async {
    final db = await _dbHelper.database;

    final entryResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM entries WHERE customerId = ?',
      [customerId],
    );
    final paymentResult = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE customerId = ?',
      [customerId],
    );

    final totalBill = (entryResult.first['total'] as num).toDouble();
    final totalPaid = (paymentResult.first['total'] as num).toDouble();
    return totalBill - totalPaid; // positive = बाकी, negative = एडवांस
  }

  /// Get all payments (for backup).
  Future<List<Payment>> getAllPayments() async {
    final db = await _dbHelper.database;
    final maps = await db.query('payments', orderBy: 'id ASC');
    return maps.map((m) => Payment.fromMap(m)).toList();
  }

  /// Compute dues for all active customers in a single query map (Map<customerId, due>).
  Future<Map<int, double>> getAllCustomersDue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        c.id,
        COALESCE((SELECT SUM(e.amount) FROM entries e WHERE e.customerId = c.id), 0) -
        COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.customerId = c.id), 0) as due
      FROM customers c
      WHERE c.active = 1
    ''');

    final dueMap = <int, double>{};
    for (var row in result) {
      final id = row['id'] as int;
      dueMap[id] = (row['due'] as num?)?.toDouble() ?? 0.0;
    }
    return dueMap;
  }
}
