import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/dao/entry_dao.dart';
import '../db/dao/payment_dao.dart';
import '../db/models/milk_entry.dart';
import '../l10n/app_localizations.dart';
import '../services/excel_service.dart';
import '../services/pdf_service.dart';
import 'theme/dairy_theme.dart';
import 'weather/weather_common.dart' show kMonthsHi, kMonthsShortEn;

/// एक महीने का जोड़ — सूची में दिखाने के लिए
class _MonthSummary {
  final String key; // MM-YYYY
  final DateTime date;
  final List<MilkEntry> entries;
  final double litres;
  final double sell;
  final double buy;
  final double avgFat;
  const _MonthSummary({
    required this.key,
    required this.date,
    required this.entries,
    required this.litres,
    required this.sell,
    required this.buy,
    required this.avgFat,
  });
}

/// 📚 महीनेवार रिपोर्ट — पहली एंट्री से आज तक हर महीना।
///
/// कोई नई table नहीं बनाई गई: आंकड़े हर बार entries से जुड़ते हैं, इसलिए
/// पुराना data भी अपने-आप दिखता है और कुछ भी बेमेल नहीं हो सकता।
class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  List<_MonthSummary> _months = [];
  Map<int, double> _dues = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await EntryDao().getAllEntries();
    final dues = await PaymentDao().getAllCustomersDue();

    final grouped = <String, List<MilkEntry>>{};
    for (final e in entries) {
      // date = dd-MM-yyyy → महीना = MM-yyyy
      if (e.date.length >= 10) {
        grouped.putIfAbsent(e.date.substring(3), () => []).add(e);
      }
    }

    final list = <_MonthSummary>[];
    grouped.forEach((key, list2) {
      double litres = 0, sell = 0, buy = 0, fatSum = 0;
      int fatCount = 0;
      for (final e in list2) {
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
      DateTime d;
      try {
        d = DateFormat('MM-yyyy').parse(key);
      } catch (_) {
        d = DateTime(2000);
      }
      list.add(_MonthSummary(
        key: key,
        date: d,
        entries: list2,
        litres: litres,
        sell: sell,
        buy: buy,
        avgFat: fatCount > 0 ? fatSum / fatCount : 0,
      ));
    });

    list.sort((a, b) => b.date.compareTo(a.date)); // नया महीना ऊपर

    if (mounted) {
      setState(() {
        _months = list;
        _dues = dues;
        _loading = false;
      });
    }
  }

  String _t(String k) => AppLocalizations.get(context, k);

  String _monthName(DateTime d) {
    final isHi = AppLocalizations.isHindiLike(context);
    return '${isHi ? kMonthsHi[d.month] : kMonthsShortEn[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');

    return Scaffold(
      appBar: AppBar(title: Text(_t('reportHistoryTitle'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _months.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(_t('noEntries'),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  itemCount: _months.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 4),
                        child: Text(_t('reportHistoryHint'),
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.grey.shade600)),
                      );
                    }
                    return _monthCard(_months[i - 1], nf);
                  },
                ),
    );
  }

  Widget _monthCard(_MonthSummary m, NumberFormat nf) {
    final net = m.sell - m.buy;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: DairyTheme.milkAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_note_rounded,
                      color: DairyTheme.milkAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_monthName(m.date),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      Text(
                        '${m.litres.toStringAsFixed(1)} ${_t('litres')}  ·  ${m.entries.length} ${_t('totalEntries')}',
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${nf.format(m.sell)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.green.shade800)),
                    if (m.buy > 0)
                      Text('− ₹${nf.format(m.buy)}',
                          style: TextStyle(
                              fontSize: 11.5, color: Colors.orange.shade800)),
                    if (m.buy > 0)
                      Text('= ₹${nf.format(net)}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 19),
                    label: const Text('PDF'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.teal.shade800),
                    onPressed: () => _openPdf(m),
                  ),
                ),
                Container(width: 1, height: 22, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.table_chart_rounded, size: 19),
                    label: const Text('Excel'),
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade800),
                    onPressed: () => _shareExcel(m),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openPdf(_MonthSummary m) {
    PdfService.instance.openDayWiseBill(
      context,
      t: (k) => AppLocalizations.get(context, k),
      periodName: _monthName(m.date),
      totalLitres: m.litres,
      totalAmount: m.sell,
      avgFat: m.avgFat,
      entryCount: m.entries.length,
      entries: m.entries,
    );
  }

  Future<void> _shareExcel(_MonthSummary m) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_t('preparingFile')),
          duration: const Duration(seconds: 2)),
    );
    try {
      await ExcelService.instance.shareKisanExcel(
        periodName: _monthName(m.date),
        totalLitres: m.litres,
        totalAmount: m.sell,
        avgFat: m.avgFat,
        entries: m.entries,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // dues अभी सिर्फ़ भविष्य के लिए रखा है (महीने-वार बाकी दिखाने के लिए)
  // ignore: unused_element
  double get _totalDue => _dues.values.fold(0, (s, d) => s + d);
}
