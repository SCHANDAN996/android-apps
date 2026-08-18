import '../dairy_database.dart';
import '../models/payment.dart';

/// Data Access Object for payments table.
class PaymentDao {
  final DairyDatabase _dbHelper = DairyDatabase.instance;

  /// Insert a new payment record.
  Future<int> insertPayment(Payment payment) async {
    final db = await _dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }

  /// Update a payment.
  Future<int> updatePayment(Payment payment) async {
    final db = await _dbHelper.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  /// Delete a payment.
  Future<int> deletePayment(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
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
}
