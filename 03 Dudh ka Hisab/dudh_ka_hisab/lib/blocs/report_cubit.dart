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
    buffer.writeln('— दूध का हिसाब app से बना');
    return buffer.toString();
  }

  /// Get current month string in MM-YYYY format.
  String getCurrentMonth() {
    return DateFormat('MM-yyyy').format(DateTime.now());
  }
}
