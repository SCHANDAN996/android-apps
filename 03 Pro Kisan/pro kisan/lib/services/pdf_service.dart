import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/models/milk_entry.dart';
import '../db/models/customer.dart';
import '../ui/bill_preview_screen.dart';

/// ग्राहक-वार summary की एक पंक्ति (report screen से आती है)।
class CustomerPdfRow {
  final String name;
  final double litres;
  final double amount;
  final double paid;
  final double due;
  const CustomerPdfRow({
    required this.name,
    required this.litres,
    required this.amount,
    required this.paid,
    required this.due,
  });
}

/// बिल/रिपोर्ट तैयार करना।
///
/// यह अब सीधे PDF नहीं बनाता — [BillData] बनाकर [BillPreviewScreen] खोलता है,
/// जहाँ उपयोगकर्ता पहले बिल देख सकता है और फिर शेयर/प्रिंट करता है।
/// PDF वहीं Flutter के rendering से बनता है, ताकि हर भारतीय भाषा सही छपे।
/// (पुराना तरीक़ा — `Printing.convertHtml` — Android पर बिना जवाब दिए अटक
/// जाता था, इसलिए "PDF बनता ही नहीं" की शिकायत आई थी।)
class PdfService {
  static final PdfService instance = PdfService._();
  PdfService._();

  static final NumberFormat _nf = NumberFormat('#,##,##0', 'en_IN');

  String _fileSafe(String s) => s.replaceAll(RegExp(r'[^\w.-]+'), '_');

  DateTime _parseDate(String d) {
    try {
      return DateFormat('dd-MM-yyyy').parse(d);
    } catch (_) {
      return DateTime(2000);
    }
  }

  /// एक तारीख़ = एक पंक्ति; सुबह/शाम अलग खानों में।
  /// (पहले हर शिफ़्ट की अपनी पंक्ति थी, तो तारीख़ दो बार छपती थी।)
  List<BillRow> _dateShiftRows(List<MilkEntry> entries,
      {required void Function(double qty, double amt) onTotal}) {
    final map = <String, List<double>>{}; // date -> [mQty, mAmt, eQty, eAmt]
    for (final e in entries) {
      final r = map.putIfAbsent(e.date, () => [0, 0, 0, 0]);
      if (e.shift == 'M') {
        r[0] += e.qtyL;
        r[1] += e.amount;
      } else {
        r[2] += e.qtyL;
        r[3] += e.amount;
      }
    }
    final dates = map.keys.toList()
      ..sort((a, b) => _parseDate(a).compareTo(_parseDate(b)));

    double tQty = 0, tAmt = 0;
    String cell(double v, {bool money = false}) {
      if (v <= 0) return '—';
      return money ? '₹${_nf.format(v)}' : v.toStringAsFixed(2);
    }

    final rows = <BillRow>[];
    for (final d in dates) {
      final r = map[d]!;
      final dayQty = r[0] + r[2];
      final dayAmt = r[1] + r[3];
      tQty += dayQty;
      tAmt += dayAmt;
      rows.add(BillRow(d, [
        cell(r[0]),
        cell(r[1], money: true),
        cell(r[2]),
        cell(r[3], money: true),
        '₹${_nf.format(dayAmt)}',
      ]));
    }
    onTotal(tQty, tAmt);
    return rows;
  }

  void _open(BuildContext context, BillData data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BillPreviewScreen(data: data)),
    );
  }

  // ───────────────────── 1) दिन-वार रिपोर्ट ─────────────────────

  void openDayWiseBill(
    BuildContext context, {
    required String Function(String) t,
    required String periodName,
    required double totalLitres,
    required double totalAmount,
    required double avgFat,
    required int entryCount,
    required List<MilkEntry> entries,
  }) {
    double tQty = 0, tAmt = 0;
    final rows = _dateShiftRows(entries, onTotal: (q, a) {
      tQty = q;
      tAmt = a;
    });

    _open(
      context,
      BillData(
        title: t('appName'),
        subtitle: t('milkDashTitle'),
        periodName: periodName,
        summary: [
          (label: t('totalMilk'), value: '${totalLitres.toStringAsFixed(1)} ${t('litres')}'),
          (label: t('totalAmount'), value: '₹${_nf.format(totalAmount)}'),
          (label: t('avgFat'), value: '${avgFat.toStringAsFixed(1)}%'),
          (label: t('totalEntries'), value: '$entryCount'),
        ],
        columnLabels: [
          t('report_table_date'),
          '🌅 ${t('litres')}',
          '🌅 ₹',
          '🌙 ${t('litres')}',
          '🌙 ₹',
          t('totalAmount'),
        ],
        rows: rows,
        totalRow: BillRow(t('grandTotal'), [
          tQty.toStringAsFixed(2),
          '',
          '',
          '',
          '₹${_nf.format(tAmt)}',
        ]),
        fileName: 'ProKisan_${_fileSafe(periodName)}.pdf',
      ),
    );
  }

  // ───────────────────── 2) एक ग्राहक का बिल ─────────────────────

  void openCustomerBill(
    BuildContext context, {
    required String Function(String) t,
    required Customer customer,
    required String periodName,
    required double totalLitres,
    required double totalAmount,
    required double totalPaid,
    required double due,
    required List<MilkEntry> entries,
  }) {
    double tQty = 0, tAmt = 0;
    final rows = _dateShiftRows(entries, onTotal: (q, a) {
      tQty = q;
      tAmt = a;
    });

    final info = StringBuffer(customer.name);
    final phone = (customer.phone ?? '').trim();
    final address = (customer.address ?? '').trim();
    if (phone.isNotEmpty) info.write('   ·   ${t('customer_phone_label')}: $phone');
    if (address.isNotEmpty) {
      info.write('\n${t('customer_address_label')}: $address');
    }

    _open(
      context,
      BillData(
        title: t('appName'),
        subtitle: t('pdfBillTitle'),
        periodName: periodName,
        customerLine: info.toString(),
        summary: [
          (label: t('totalMilk'), value: '${totalLitres.toStringAsFixed(1)} ${t('litres')}'),
          (label: t('totalAmount'), value: '₹${_nf.format(totalAmount)}'),
          (label: t('tablePaid'), value: '₹${_nf.format(totalPaid)}'),
          (label: t('tableDue'), value: '₹${_nf.format(due)}'),
        ],
        columnLabels: [
          t('report_table_date'),
          '🌅 ${t('litres')}',
          '🌅 ₹',
          '🌙 ${t('litres')}',
          '🌙 ₹',
          t('totalAmount'),
        ],
        rows: rows,
        totalRow: BillRow(t('grandTotal'), [
          tQty.toStringAsFixed(2),
          '',
          '',
          '',
          '₹${_nf.format(tAmt)}',
        ]),
        showSignature: true,
        fileName:
            'Bill_${_fileSafe(customer.name)}_${_fileSafe(periodName)}.pdf',
      ),
    );
  }

  // ───────────────────── 3) ग्राहक-वार सार ─────────────────────

  void openCustomerWiseBill(
    BuildContext context, {
    required String Function(String) t,
    required String periodName,
    required List<CustomerPdfRow> rows,
  }) {
    double tL = 0, tA = 0, tP = 0, tD = 0;
    final billRows = <BillRow>[];
    for (final r in rows) {
      tL += r.litres;
      tA += r.amount;
      tP += r.paid;
      tD += r.due;
      billRows.add(BillRow(r.name, [
        r.litres.toStringAsFixed(1),
        '₹${_nf.format(r.amount)}',
        '₹${_nf.format(r.paid)}',
        '₹${_nf.format(r.due)}',
      ]));
    }

    _open(
      context,
      BillData(
        title: t('appName'),
        subtitle: t('reportCustomerWise'),
        periodName: periodName,
        summary: [
          (label: t('customers'), value: '${rows.length}'),
          (label: t('totalMilk'), value: '${tL.toStringAsFixed(1)} ${t('litres')}'),
          (label: t('totalAmount'), value: '₹${_nf.format(tA)}'),
          (label: t('totalDue'), value: '₹${_nf.format(tD)}'),
        ],
        columnLabels: [
          t('tableName'),
          t('report_table_milk'),
          t('totalAmount'),
          t('tablePaid'),
          t('tableDue'),
        ],
        rows: billRows,
        totalRow: BillRow(t('grandTotal'), [
          tL.toStringAsFixed(1),
          '₹${_nf.format(tA)}',
          '₹${_nf.format(tP)}',
          '₹${_nf.format(tD)}',
        ]),
        fileName: 'ProKisan_Customers_${_fileSafe(periodName)}.pdf',
      ),
    );
  }
}
