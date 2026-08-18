import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/payment_dao.dart';
import '../db/dao/customer_dao.dart';
import '../db/models/milk_entry.dart';
import '../db/models/customer.dart';

/// States for monthly report.
abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class KisanReportLoaded extends ReportState {
  final String month; // MM-YYYY
  final String monthName; // e.g. "जून 2026"
  final double totalLitres;
  final double totalAmount;
  final double avgFat;
  final int entryCount;
  final List<MilkEntry> entries;

  KisanReportLoaded({
    required this.month,
    required this.monthName,
    required this.totalLitres,
    required this.totalAmount,
    required this.avgFat,
    required this.entryCount,
    required this.entries,
  });
}

/// Per-customer summary for दूधवाला report.
class CustomerReportItem {
  final Customer customer;
  final double totalLitres;
  final double totalAmount;
  final double totalPaid;
  final double due;

  CustomerReportItem({
    required this.customer,
    required this.totalLitres,
    required this.totalAmount,
    required this.totalPaid,
    required this.due,
  });
}

class DoodhwalaReportLoaded extends ReportState {
  final String month;
  final String monthName;
  final List<CustomerReportItem> customerReports;
  final double grandTotalLitres;
  final double grandTotalAmount;
  final double grandTotalPaid;
  final double grandTotalDue;

  DoodhwalaReportLoaded({
    required this.month,
    required this.monthName,
    required this.customerReports,
    required this.grandTotalLitres,
    required this.grandTotalAmount,
    required this.grandTotalPaid,
    required this.grandTotalDue,
  });
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}

/// Cubit for monthly report generation.
class ReportCubit extends Cubit<ReportState> {
  final EntryDao _entryDao = EntryDao();
  final PaymentDao _paymentDao = PaymentDao();
  final CustomerDao _customerDao = CustomerDao();

  ReportCubit() : super(ReportInitial());

  static const _hindiMonths = [
    'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल',
    'मई', 'जून', 'जुलाई', 'अगस्त',
    'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर',
  ];

  String _getHindiMonthName(String month) {
    // month = "MM-YYYY"
    final parts = month.split('-');
    final m = int.tryParse(parts[0]) ?? 1;
    final y = parts[1];
    return '${_hindiMonths[m - 1]} $y';
  }

  /// Load किसान mode report for a given month.
  Future<void> loadKisanReport(String month) async {
    emit(ReportLoading());
    final totals = await _entryDao.getMonthlyTotals(month);
    final entries = await _entryDao.getMonthlyEntries(month);

    emit(KisanReportLoaded(
      month: month,
      monthName: _getHindiMonthName(month),
      totalLitres: totals['totalLitres']!,
      totalAmount: totals['totalAmount']!,
      avgFat: totals['avgFat']!,
      entryCount: totals['entryCount']!.toInt(),
      entries: entries,
    ));
  }

  /// Load दिन-वार report for any date range (सप्ताह / 15 दिन / पूरा समय / कस्टम)।
  ///
  /// [label] अवधि का पढ़ने लायक़ नाम — PDF/Excel के शीर्षक में यही जाता है
  /// (जैसे "जुलाई 2026 · 1-7")। न दें तो तारीख़ों से अपने-आप बन जाता है।
  Future<void> loadKisanDateRangeReport(DateTime start, DateTime end,
      {String? label}) async {
    emit(ReportLoading());
    final entries = await _entryDao.getCustomDateRangeEntries(start, end);
    double totalLitres = 0, totalAmount = 0, fatSum = 0;
    int fatCount = 0;

    for (final e in entries) {
      totalLitres += e.qtyL;
      totalAmount += e.amount;
      if (e.fatPct != null) {
        fatSum += e.fatPct!;
        fatCount++;
      }
    }

    final avgFat = fatCount > 0 ? fatSum / fatCount : 0.0;
    final rangeStr = label ??
        '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';

    emit(KisanReportLoaded(
      month: rangeStr,
      monthName: rangeStr,
      totalLitres: totalLitres,
      totalAmount: totalAmount,
      avgFat: avgFat,
      entryCount: entries.length,
      entries: entries,
    ));
  }

  /// Load दूधवाला mode report for a given month.
  Future<void> loadDoodhwalaReport(String month) async {
    emit(ReportLoading());
    final customers = await _customerDao.getActiveCustomers();
    final reports = <CustomerReportItem>[];

    double grandLitres = 0, grandAmount = 0, grandPaid = 0;

    for (final customer in customers) {
      if (customer.id == null) continue;

      final totals = await _entryDao.getCustomerMonthlyTotals(
        customer.id!,
        month,
      );
      final paid = await _paymentDao.getCustomerMonthlyPaymentTotal(
        customer.id!,
        month,
      );

      final litres = totals['totalLitres']!;
      final amount = totals['totalAmount']!;
      final due = amount - paid;

      grandLitres += litres;
      grandAmount += amount;
      grandPaid += paid;

      reports.add(CustomerReportItem(
        customer: customer,
        totalLitres: litres,
        totalAmount: amount,
        totalPaid: paid,
        due: due,
      ));
    }

    emit(DoodhwalaReportLoaded(
      month: month,
      monthName: _getHindiMonthName(month),
      customerReports: reports,
      grandTotalLitres: grandLitres,
      grandTotalAmount: grandAmount,
      grandTotalPaid: grandPaid,
      grandTotalDue: grandAmount - grandPaid,
    ));
  }

  /// ग्राहक-वार report किसी भी अवधि के लिए (महीना नहीं, date-range)।
  ///
  /// महीने वाली [loadDoodhwalaReport] जस की तस रहती है — यह उसका
  /// range वाला जुड़वाँ है, ताकि सप्ताह/15-दिन/पूरा-समय भी ग्राहक-वार दिखे।
  Future<void> loadDoodhwalaDateRangeReport(DateTime start, DateTime end,
      {String? label}) async {
    emit(ReportLoading());
    final customers = await _customerDao.getActiveCustomers();
    final allPayments = await _paymentDao.getAllPayments();
    final reports = <CustomerReportItem>[];

    double grandLitres = 0, grandAmount = 0, grandPaid = 0;

    bool inRange(String ddmmyyyy) {
      try {
        final p = ddmmyyyy.split('-');
        final d = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        final s = DateTime(start.year, start.month, start.day);
        final e = DateTime(end.year, end.month, end.day);
        return !d.isBefore(s) && !d.isAfter(e);
      } catch (_) {
        return false;
      }
    }

    for (final customer in customers) {
      if (customer.id == null) continue;

      final entries = await _entryDao.getCustomDateRangeEntries(start, end,
          customerId: customer.id);
      final litres = entries.fold<double>(0, (s, e) => s + e.qtyL);
      final amount = entries.fold<double>(0, (s, e) => s + e.amount);
      final paid = allPayments
          .where((p) => p.customerId == customer.id && inRange(p.date))
          .fold<double>(0, (s, p) => s + p.amount);

      grandLitres += litres;
      grandAmount += amount;
      grandPaid += paid;

      reports.add(CustomerReportItem(
        customer: customer,
        totalLitres: litres,
        totalAmount: amount,
        totalPaid: paid,
        due: amount - paid,
      ));
    }

    final rangeStr = label ??
        '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';

    emit(DoodhwalaReportLoaded(
      month: rangeStr,
      monthName: rangeStr,
      customerReports: reports,
      grandTotalLitres: grandLitres,
      grandTotalAmount: grandAmount,
      grandTotalPaid: grandPaid,
      grandTotalDue: grandAmount - grandPaid,
    ));
  }

  /// Generate bill text for WhatsApp sharing.
  String generateBillText({
    required String monthName,
    String? customerName,
    required double totalLitres,
    required double rate,
    required double totalAmount,
    double totalPaid = 0,
  }) {
    final due = totalAmount - totalPaid;
    final nf = NumberFormat('#,##,##0', 'en_IN');

    final buffer = StringBuffer();
    buffer.writeln('🥛 दूध का हिसाब — $monthName');
    if (customerName != null) {
      buffer.writeln('ग्राहक: $customerName');
    }
    buffer.writeln('कुल दूध: ${totalLitres.toStringAsFixed(1)} लीटर');
    buffer.writeln('रेट: ₹${nf.format(rate)}/ली');
    buffer.writeln(
      'कुल: ₹${nf.format(totalAmount)} | मिला: ₹${nf.format(totalPaid)} | बाकी: ₹${nf.format(due)}',
    );
    buffer.writeln('— प्रो किसान app से बना');
    return buffer.toString();
  }

  /// Get current month string in MM-YYYY format.
  String getCurrentMonth() {
    return DateFormat('MM-yyyy').format(DateTime.now());
  }
}
