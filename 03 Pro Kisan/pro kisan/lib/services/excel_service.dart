import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/dairy_products.dart';
import '../db/dao/customer_dao.dart';
import '../db/dao/dairy_product_dao.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/payment_dao.dart';
import '../db/models/milk_entry.dart';

class ExcelService {
  static final ExcelService instance = ExcelService._();
  ExcelService._();

  /// 📊 पूरा हिसाब — एक ही Excel फ़ाइल में सब कुछ, अलग-अलग शीट में:
  ///   1. सारांश        — कुल दूध/बिक्री/ख़रीद/जमा/बाकी
  ///   2. ग्राहक         — हर ग्राहक का पूरा लेखा-जोखा (बाकी राशि सहित)
  ///   3. दूध एंट्री     — हर एक एंट्री (तारीख़, शिफ़्ट, ग्राहक, लीटर, रेट)
  ///   4. भुगतान        — किसने कब कितना दिया
  ///   5. डेयरी प्रोडक्ट — खोवा/पनीर/घी आदि का हिसाब
  ///
  /// [t] से हर शीर्षक ऐप की चुनी भाषा में आता है, [isHi] से प्रोडक्ट के नाम।
  Future<void> shareFullLedgerExcel({
    required String Function(String) t,
    required bool isHi,
  }) async {
    final customers = await CustomerDao().getAllCustomers();
    final entries = await EntryDao().getAllEntries();
    final payments = await PaymentDao().getAllPayments();
    final dairy = await DairyProductDao().getAllEntries();
    final dues = await PaymentDao().getAllCustomersDue();

    final nameById = {
      for (final c in customers)
        if (c.id != null) c.id!: c.name
    };
    final ownAccount = t('home_farmer_default');

    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();

    // ── 1. सारांश ──
    double sell = 0, buy = 0, litres = 0;
    for (final e in entries) {
      litres += e.qtyL;
      if (e.direction == 'buy') {
        buy += e.amount;
      } else {
        sell += e.amount;
      }
    }
    final paid = payments.fold<double>(0, (s, p) => s + p.amount);
    final totalDue = dues.values.fold<double>(0, (s, d) => s + d);

    final s1 = excel[t('summaryLabel')];
    s1.appendRow([TextCellValue('${t('appName')} — ${t('fullLedgerTitle')}')]);
    s1.appendRow([
      TextCellValue(t('reportGeneratedOn')),
      TextCellValue(DateTime.now().toString().substring(0, 16)),
    ]);
    s1.appendRow([]);
    s1.appendRow([TextCellValue(t('customers')), IntCellValue(customers.where((c) => c.active == 1).length)]);
    s1.appendRow([TextCellValue(t('totalMilk')), DoubleCellValue(litres)]);
    s1.appendRow([TextCellValue(t('totalSellLabel')), DoubleCellValue(sell)]);
    s1.appendRow([TextCellValue(t('totalBuyLabel')), DoubleCellValue(buy)]);
    s1.appendRow([TextCellValue(t('tablePaid')), DoubleCellValue(paid)]);
    s1.appendRow([TextCellValue(t('totalDue')), DoubleCellValue(totalDue)]);
    s1.appendRow([TextCellValue(t('totalEntries')), IntCellValue(entries.length)]);

    // ── 2. ग्राहक ──
    final s2 = excel[t('customers')];
    s2.appendRow([
      TextCellValue(t('tableName')),
      TextCellValue(t('customer_phone_label')),
      TextCellValue(t('customer_address_label')),
      TextCellValue(t('partyTypeLabel')),
      TextCellValue(t('rateType')),
      TextCellValue(t('rate')),
      TextCellValue(t('defaultQtyLabel')),
      TextCellValue(t('totalMilk')),
      TextCellValue(t('totalAmount')),
      TextCellValue(t('tableDue')),
    ]);
    for (final c in customers) {
      final cEntries = entries.where((e) => e.customerId == c.id);
      final cLitres = cEntries.fold<double>(0, (s, e) => s + e.qtyL);
      final cAmount = cEntries.fold<double>(0, (s, e) => s + e.amount);
      s2.appendRow([
        TextCellValue(c.name),
        TextCellValue(c.phone ?? ''),
        TextCellValue(c.address ?? ''),
        TextCellValue(t(switch (c.partyType) {
          'supplier' => 'partyTypeSupplier',
          'both' => 'partyTypeBoth',
          _ => 'partyTypeBuyer',
        })),
        TextCellValue(t(c.rateType == 'fat' ? 'fatBased' : 'flat')),
        DoubleCellValue(c.rateType == 'fat' ? c.ratePerFatPoint : c.flatRate),
        DoubleCellValue(c.defaultQtyL),
        DoubleCellValue(cLitres),
        DoubleCellValue(cAmount),
        DoubleCellValue(dues[c.id] ?? 0),
      ]);
    }

    // ── 3. दूध एंट्री ──
    final s3 = excel[t('recentEntries')];
    s3.appendRow([
      TextCellValue(t('report_table_date')),
      TextCellValue(t('report_table_shift')),
      TextCellValue(t('tableName')),
      TextCellValue(t('directionLabel')),
      TextCellValue(t('litres')),
      TextCellValue(t('fat')),
      TextCellValue(t('rate')),
      TextCellValue(t('totalAmount')),
    ]);
    for (final e in entries) {
      s3.appendRow([
        TextCellValue(e.date),
        TextCellValue(t(e.shift == 'M' ? 'morning' : 'evening')),
        TextCellValue(nameById[e.customerId] ?? ownAccount),
        TextCellValue(t(e.direction == 'buy' ? 'directionBuy' : 'directionSell')),
        DoubleCellValue(e.qtyL),
        e.fatPct == null ? TextCellValue('') : DoubleCellValue(e.fatPct!),
        DoubleCellValue(e.qtyL > 0 ? e.amount / e.qtyL : 0),
        DoubleCellValue(e.amount),
      ]);
    }

    // ── 4. भुगतान ──
    final s4 = excel[t('paid')];
    s4.appendRow([
      TextCellValue(t('report_table_date')),
      TextCellValue(t('tableName')),
      TextCellValue(t('amount')),
      TextCellValue(t('paymentNote')),
    ]);
    for (final p in payments) {
      s4.appendRow([
        TextCellValue(p.date),
        TextCellValue(nameById[p.customerId] ?? ownAccount),
        DoubleCellValue(p.amount),
        TextCellValue(p.note),
      ]);
    }

    // ── 5. डेयरी प्रोडक्ट ──
    if (dairy.isNotEmpty) {
      final s5 = excel[t('dairy_appbar_title')];
      s5.appendRow([
        TextCellValue(t('report_table_date')),
        TextCellValue(t('dairy_select_product')),
        TextCellValue(t('dairy_milk_used')),
        TextCellValue(t('dairy_product_qty')),
        TextCellValue(t('rate')),
        TextCellValue(t('totalAmount')),
      ]);
      for (final d in dairy) {
        s5.appendRow([
          TextCellValue(d.date),
          TextCellValue(getDairyProductById(d.productId)?.name(isHi) ?? d.productId),
          DoubleCellValue(d.milkUsedL),
          DoubleCellValue(d.productQtyKg),
          DoubleCellValue(d.pricePerKg),
          DoubleCellValue(d.totalAmount),
        ]);
      }
    }

    // Excel हमेशा एक ख़ाली "Sheet1" बनाता है — उसे हटा दो
    if (defaultSheet != null) {
      try {
        excel.delete(defaultSheet);
      } catch (_) {}
    }

    final stamp = DateTime.now().toString().substring(0, 10);
    await _saveAndShare(excel, 'ProKisan_Full_Ledger_$stamp.xlsx',
        '${t('appName')} — ${t('fullLedgerTitle')}');
  }

  /// एक महीने की रिपोर्ट **फ़ाइल में सेव** करो (शेयर नहीं) और path लौटाओ।
  ///
  /// महीना पूरा होते ही यह अपने-आप चलती है — Excel शुद्ध Dart से बनती है,
  /// इसलिए बिना कोई screen खोले, चुपचाप बन जाती है।
  Future<String?> saveMonthlyExcelReport({
    required String month, // MM-yyyy
    required String periodName, // "जुलाई 2026"
    required String Function(String) t,
    required List<MilkEntry> entries,
    required Map<int, String> customerNames,
  }) async {
    if (entries.isEmpty) return null;

    double litres = 0, sell = 0, buy = 0, fatSum = 0;
    int fatCount = 0;
    for (final e in entries) {
      litres += e.qtyL;
      if (e.direction == 'buy') {
        buy += e.amount;
      } else {
        sell += e.amount;
      }
      if (e.fatPct != null) {
        fatSum += e.fatPct!;
        fatCount++;
      }
    }

    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    final sheet = excel[t('summaryLabel')];

    sheet.appendRow([
      TextCellValue('${t('appName')} — ${t('milkDashTitle')}'),
      TextCellValue(periodName),
    ]);
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue(t('totalMilk')), DoubleCellValue(litres)]);
    sheet.appendRow([TextCellValue(t('totalSellLabel')), DoubleCellValue(sell)]);
    sheet.appendRow([TextCellValue(t('totalBuyLabel')), DoubleCellValue(buy)]);
    sheet.appendRow([
      TextCellValue(t('netBalanceLabel')),
      DoubleCellValue(sell - buy),
    ]);
    sheet.appendRow([
      TextCellValue(t('avgFat')),
      DoubleCellValue(fatCount > 0 ? fatSum / fatCount : 0),
    ]);
    sheet.appendRow(
        [TextCellValue(t('totalEntries')), IntCellValue(entries.length)]);
    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue(t('report_table_date')),
      TextCellValue(t('report_table_shift')),
      TextCellValue(t('tableName')),
      TextCellValue(t('litres')),
      TextCellValue(t('fat')),
      TextCellValue(t('rate')),
      TextCellValue(t('totalAmount')),
    ]);
    for (final e in entries) {
      sheet.appendRow([
        TextCellValue(e.date),
        TextCellValue(t(e.shift == 'M' ? 'morning' : 'evening')),
        TextCellValue(customerNames[e.customerId] ?? t('home_farmer_default')),
        DoubleCellValue(e.qtyL),
        e.fatPct == null ? TextCellValue('') : DoubleCellValue(e.fatPct!),
        DoubleCellValue(e.qtyL > 0 ? e.amount / e.qtyL : 0),
        DoubleCellValue(e.amount),
      ]);
    }

    if (defaultSheet != null) {
      try {
        excel.delete(defaultSheet);
      } catch (_) {}
    }

    final bytes = excel.encode();
    if (bytes == null) return null;

    // पहले सार्वजनिक folder (ऐप हटाने पर भी बचे), न बने तो ऐप का अपना folder
    final candidates = <String>[];
    candidates.add('/storage/emulated/0/Documents/ProKisan_Reports');
    candidates.add('/storage/emulated/0/Download/ProKisan_Reports');
    try {
      final appDocs = await getApplicationDocumentsDirectory();
      candidates.add('${appDocs.path}/ProKisan_Reports');
    } catch (_) {}

    final fileName = 'ProKisan_${month.replaceAll('-', '_')}.xlsx';
    for (final dirPath in candidates) {
      try {
        final dir = Directory(dirPath);
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = File('$dirPath/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _saveAndShare(
      Excel excel, String fileName, String subject) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    final bytes = excel.encode();
    if (bytes == null) return;
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [
        XFile(file.path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      ],
      subject: subject,
    );
  }

  /// किसान मोड के लिए Excel शेयर करें
  Future<void> shareKisanExcel({
    required String periodName,
    required double totalLitres,
    required double totalAmount,
    required double avgFat,
    required List<MilkEntry> entries,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

    // Header
    sheet.appendRow([TextCellValue('प्रो किसान - दूध बिक्री रिपोर्ट'), TextCellValue(periodName)]);
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue('सारांश')]);
    sheet.appendRow([TextCellValue('कुल दूध (लीटर)'), DoubleCellValue(totalLitres)]);
    sheet.appendRow([TextCellValue('कुल राशि (₹)'), DoubleCellValue(totalAmount)]);
    sheet.appendRow([TextCellValue('औसत फैट'), DoubleCellValue(avgFat)]);
    sheet.appendRow([TextCellValue('कुल एंट्री'), IntCellValue(entries.length)]);
    sheet.appendRow([]);

    // Table Headers
    sheet.appendRow([
      TextCellValue('तारीख'),
      TextCellValue('शिफ्ट'),
      TextCellValue('लीटर'),
      TextCellValue('फैट%'),
      TextCellValue('रेट (₹/ली)'),
      TextCellValue('राशि (₹)'),
    ]);

    // Data
    for (var e in entries) {
      final shift = e.shift == 'M' ? 'सुबह' : 'शाम';
      final rateStr = e.qtyL > 0 ? (e.amount / e.qtyL).toStringAsFixed(1) : '-';
      sheet.appendRow([
        TextCellValue(e.date),
        TextCellValue(shift),
        DoubleCellValue(e.qtyL),
        TextCellValue(e.fatPct?.toStringAsFixed(1) ?? '-'),
        TextCellValue(rateStr),
        DoubleCellValue(e.amount),
      ]);
    }

    // Save and Share
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ProKisan_Report_${periodName.replaceAll(' ', '_')}.xlsx';
    final file = File(path);
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: 'दूध का हिसाब - Excel फाइल',
      );
    }
  }

  /// दूधवाला मोड: ग्राहकवार Excel
  Future<void> shareCustomerExcel({
    required String customerName,
    required String periodName,
    required double totalLitres,
    required double totalAmount,
    required double totalPaid,
    required double due,
    required List<MilkEntry> entries,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

    sheet.appendRow([TextCellValue('प्रो किसान - ग्राहक बिल'), TextCellValue(periodName)]);
    sheet.appendRow([TextCellValue('ग्राहक: $customerName')]);
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue('कुल दूध (लीटर)'), DoubleCellValue(totalLitres)]);
    sheet.appendRow([TextCellValue('कुल बिल (₹)'), DoubleCellValue(totalAmount)]);
    sheet.appendRow([TextCellValue('प्राप्त (₹)'), DoubleCellValue(totalPaid)]);
    sheet.appendRow([TextCellValue('बाकी (₹)'), DoubleCellValue(due)]);
    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue('तारीख'),
      TextCellValue('शिफ्ट'),
      TextCellValue('लीटर'),
      TextCellValue('रेट (₹/ली)'),
      TextCellValue('राशि (₹)'),
    ]);

    for (var e in entries) {
      final shift = e.shift == 'M' ? 'सुबह' : 'शाम';
      final rateStr = e.qtyL > 0 ? (e.amount / e.qtyL).toStringAsFixed(1) : '-';
      sheet.appendRow([
        TextCellValue(e.date),
        TextCellValue(shift),
        DoubleCellValue(e.qtyL),
        TextCellValue(rateStr),
        DoubleCellValue(e.amount),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/Bill_${customerName}_$periodName.xlsx';
    final file = File(path);
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: 'दूध बिल - Excel',
      );
    }
  }
}
