import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/report_cubit.dart';
import '../../db/dao/customer_dao.dart';
import '../../db/dao/entry_dao.dart';
import '../../db/dao/payment_dao.dart';
import '../../db/models/milk_entry.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf_service.dart';
import '../services/excel_service.dart';
import 'report_history_screen.dart';
import 'weather/weather_common.dart' show kMonthsHi, kMonthsShortEn;
import 'widgets/milk_chart_widget.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late String _currentMonth; // MM-YYYY
  DateTimeRange? _customDateRange;

  /// कितने समय का हिसाब देखना है:
  ///  'month'     → पूरा महीना (पुराना, SQL से सीधा — सबसे तेज़)
  ///  'week'      → उसी महीने का 1-7 / 8-14 / 15-21 / 22-28 / 29-अंत
  ///  'fortnight' → 1-15 या 16-अंत (दूध के धंधे में 15-दिन का बिल आम है)
  ///  'all'       → पहली एंट्री से आज तक
  ///  'custom'    → अपनी चुनी हुई तारीख़ें
  String _period = 'month';
  int _weekIdx = 0; // 0..4
  int _fortnightIdx = 0; // 0 = 1-15, 1 = 16-अंत

  /// रिपोर्ट का नज़रिया — पहले यह kisan/doodhwala mode से तय होता था।
  /// अब उपयोगकर्ता ख़ुद toggle से चुनता है:
  ///  • 'day'      → दिन-वार (सारी एंट्रियाँ, PDF/Excel के साथ)
  ///  • 'customer' → ग्राहक-वार (हर ग्राहक का दूध/बिल/जमा/बाकी)
  String _view = 'day';

  @override
  void initState() {
    super.initState();
    _currentMonth = DateFormat('MM-yyyy').format(DateTime.now());
    _loadReport();
  }

  /// चुने हुए महीने का साल/महीना
  DateTime get _monthDate => DateFormat('MM-yyyy').parse(_currentMonth);

  String get _monthLabel {
    final d = _monthDate;
    final isHi = AppLocalizations.isHindiLike(context);
    return '${isHi ? kMonthsHi[d.month] : kMonthsShortEn[d.month]} ${d.year}';
  }

  /// अवधि → (शुरू, अंत, नाम)। 'month' के लिए इसकी ज़रूरत नहीं —
  /// वह पुराने SQL रास्ते से ही चलता है।
  ({DateTime start, DateTime end, String label}) _computeRange() {
    final d = _monthDate;
    final lastDay = DateTime(d.year, d.month + 1, 0).day;

    switch (_period) {
      case 'week':
        final from = _weekIdx * 7 + 1;
        final to = _weekIdx == 4 ? lastDay : (from + 6).clamp(1, lastDay);
        return (
          start: DateTime(d.year, d.month, from),
          end: DateTime(d.year, d.month, to),
          label: '$_monthLabel · $from-$to',
        );
      case 'fortnight':
        final from = _fortnightIdx == 0 ? 1 : 16;
        final to = _fortnightIdx == 0 ? 15 : lastDay;
        return (
          start: DateTime(d.year, d.month, from),
          end: DateTime(d.year, d.month, to),
          label: '$_monthLabel · $from-$to',
        );
      case 'all':
        return (
          start: DateTime(2000, 1, 1),
          end: DateTime.now(),
          label: AppLocalizations.get(context, 'periodAllTime'),
        );
      default: // custom
        final r = _customDateRange ??
            DateTimeRange(start: DateTime(d.year, d.month, 1), end: DateTime.now());
        return (
          start: r.start,
          end: r.end,
          label:
              '${DateFormat('dd/MM/yy').format(r.start)} - ${DateFormat('dd/MM/yy').format(r.end)}',
        );
    }
  }

  void _loadReport() {
    final cubit = context.read<ReportCubit>();

    // पूरा महीना — पुराना, आज़माया हुआ रास्ता (SQL में महीना छाँटता है)
    if (_period == 'month') {
      if (_view == 'day') {
        cubit.loadKisanReport(_currentMonth);
      } else {
        cubit.loadDoodhwalaReport(_currentMonth);
      }
      return;
    }

    final r = _computeRange();
    if (_view == 'day') {
      cubit.loadKisanDateRangeReport(r.start, r.end, label: r.label);
    } else {
      cubit.loadDoodhwalaDateRangeReport(r.start, r.end, label: r.label);
    }
  }

  void _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _customDateRange ?? DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: now,
      ),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _period = 'custom';
        _customDateRange = picked;
      });
      _loadReport();
    }
  }

  void _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('MM-yyyy').parse(_currentMonth),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        if (_period == 'custom' || _period == 'all') _period = 'month';
        _currentMonth = DateFormat('MM-yyyy').format(picked);
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'monthlyReport')),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: AppLocalizations.get(context, 'reportHistoryTitle'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ReportHistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _selectMonth,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── दिन-वार / ग्राहक-वार toggle ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(child: _viewToggleBtn(context, 'day', Icons.calendar_view_day_rounded, 'reportDayWise')),
                  const SizedBox(width: 10),
                  Expanded(child: _viewToggleBtn(context, 'customer', Icons.people_alt_rounded, 'reportCustomerWise')),
                ],
              ),
            ),
            // ── पूरा हिसाब — शुरू से आज तक, PDF और Excel दोनों में ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 6),
                    child: Text(
                      AppLocalizations.get(context, 'fullLedgerExcelHint'),
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          height: 1.3),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            foregroundColor: Colors.teal.shade800,
                            side: BorderSide(
                                color: Colors.teal.shade700, width: 1.4),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded,
                              size: 20),
                          label: const Text('PDF',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                          onPressed: _fullLedgerPdf,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(
                                color: Colors.green.shade700, width: 1.4),
                          ),
                          icon: const Icon(Icons.table_view_rounded, size: 20),
                          label: const Text('Excel',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                          onPressed: _exportFullLedger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ReportCubit, ReportState>(
                builder: (context, state) {
                  if (state is ReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is KisanReportLoaded) {
                    return _buildKisanReport(context, state);
                  }

                  if (state is DoodhwalaReportLoaded) {
                    return _buildDoodhwalaReport(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// पूरा हिसाब (सारे ग्राहक, सारी एंट्री, भुगतान, डेयरी) → एक Excel फ़ाइल
  Future<void> _exportFullLedger() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.get(context, 'preparingFile')),
        duration: const Duration(seconds: 2),
      ),
    );
    try {
      await ExcelService.instance.shareFullLedgerExcel(
        t: (k) => AppLocalizations.get(context, k),
        isHi: AppLocalizations.isHindiLike(context),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// पूरा हिसाब PDF — शुरू से आज तक, हर ग्राहक की एक पंक्ति
  Future<void> _fullLedgerPdf() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.get(context, 'preparingFile')),
        duration: const Duration(seconds: 1),
      ),
    );
    try {
      final customers = await CustomerDao().getActiveCustomers();
      final entries = await EntryDao().getAllEntries();
      final dues = await PaymentDao().getAllCustomersDue();
      final payments = await PaymentDao().getAllPayments();

      final rows = <CustomerPdfRow>[];
      for (final c in customers) {
        final ce = entries.where((e) => e.customerId == c.id);
        final paid = payments
            .where((p) => p.customerId == c.id)
            .fold<double>(0, (s, p) => s + p.amount);
        rows.add(CustomerPdfRow(
          name: c.name,
          litres: ce.fold<double>(0, (s, e) => s + e.qtyL),
          amount: ce.fold<double>(0, (s, e) => s + e.amount),
          paid: paid,
          due: dues[c.id] ?? 0,
        ));
      }

      if (!mounted) return;
      PdfService.instance.openCustomerWiseBill(
        context,
        t: (k) => AppLocalizations.get(context, k),
        periodName: AppLocalizations.get(context, 'periodAllTime'),
        rows: rows,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _viewToggleBtn(
      BuildContext context, String value, IconData icon, String labelKey) {
    final selected = _view == value;
    final teal = Theme.of(context).primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_view == value) return;
        setState(() => _view = value);
        _loadReport();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? teal : Colors.grey.shade300, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : teal),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                AppLocalizations.get(context, labelKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKisanReport(BuildContext context, KisanReportLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportPeriodCard(context, state.monthName),
        const SizedBox(height: 16),
        _buildKisanSummaryGrid(context, state),
        const SizedBox(height: 16),
        MilkChartWidget(entries: state.entries),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.get(context, 'report_daily_record'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('PDF Bill'),
                  onPressed: () {
                    PdfService.instance.openDayWiseBill(
                      context,
                      t: (k) => AppLocalizations.get(context, k),
                      periodName: state.monthName,
                      totalLitres: state.totalLitres,
                      totalAmount: state.totalAmount,
                      avgFat: state.avgFat,
                      entryCount: state.entryCount,
                      entries: state.entries,
                    );
                  },
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text('Excel'),
                  onPressed: () {
                    ExcelService.instance.shareKisanExcel(
                      periodName: state.monthName,
                      totalLitres: state.totalLitres,
                      totalAmount: state.totalAmount,
                      avgFat: state.avgFat,
                      entries: state.entries,
                    );
                  },
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: AppLocalizations.get(context, 'sharePlainTextTooltip'),
                  icon: const Icon(Icons.share_rounded, color: Colors.green),
                  onPressed: () {
                    final text = context.read<ReportCubit>().generateBillText(
                          monthName: state.monthName,
                          totalLitres: state.totalLitres,
                          rate: state.totalLitres > 0 ? state.totalAmount / state.totalLitres : 0.0,
                          totalAmount: state.totalAmount,
                        );
                    Share.share(text);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildKisanEntriesTable(context, state.entries),
      ],
    );
  }

  Widget _buildDoodhwalaReport(BuildContext context, DoodhwalaReportLoaded state) {
    final nf = NumberFormat('#,##,##0', 'en_IN');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportPeriodCard(context, state.monthName),
        const SizedBox(height: 16),
        _buildDoodhwalaSummaryGrid(context, state),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                AppLocalizations.get(context, 'report_customer_details'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('PDF'),
              onPressed: () {
                PdfService.instance.openCustomerWiseBill(
                  context,
                  t: (k) => AppLocalizations.get(context, k),
                  periodName: state.monthName,
                  rows: state.customerReports
                      .map((item) => CustomerPdfRow(
                            name: item.customer.name,
                            litres: item.totalLitres,
                            amount: item.totalAmount,
                            paid: item.totalPaid,
                            due: item.due,
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: AppLocalizations.get(context, 'shareText'),
              icon: const Icon(Icons.share_rounded, color: Colors.green),
              onPressed: () {
                final buffer = StringBuffer();
                buffer.writeln('🥛 ${AppLocalizations.get(context, 'milkModuleName')} — ${state.monthName}');
                buffer.writeln('---------------------------');
                for (final item in state.customerReports) {
                  buffer.writeln(
                    '${item.customer.name}: ${item.totalLitres.toStringAsFixed(1)} ${AppLocalizations.get(context, 'litres')} | ₹ ${nf.format(item.totalAmount)} | ${AppLocalizations.get(context, 'tableDue')}: ₹ ${nf.format(item.due)}',
                  );
                }
                buffer.writeln('---------------------------');
                buffer.writeln('${AppLocalizations.get(context, 'totalMilk')}: ${state.grandTotalLitres.toStringAsFixed(1)} ${AppLocalizations.get(context, 'litres')}');
                buffer.writeln('${AppLocalizations.get(context, 'totalDue')}: ₹ ${nf.format(state.grandTotalDue)}');
                Share.share(buffer.toString());
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDoodhwalaTable(context, state.customerReports),
      ],
    );
  }

  Widget _buildReportPeriodCard(BuildContext context, String monthName) {
    final lastDay = DateTime(_monthDate.year, _monthDate.month + 1, 0).day;
    final showMonthRow = _period != 'all' && _period != 'custom';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── अभी कौन सी अवधि दिख रही है ──
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    color: Theme.of(context).primaryColor, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    monthName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                if (showMonthRow)
                  TextButton.icon(
                    onPressed: _selectMonth,
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: Text(AppLocalizations.get(context, 'monthLabel')),
                  ),
              ],
            ),
            const Divider(height: 14),

            // ── अवधि का प्रकार ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _periodChip('month', AppLocalizations.get(context, 'thisMonth')),
                _periodChip('week', AppLocalizations.get(context, 'periodWeek')),
                _periodChip(
                    'fortnight', AppLocalizations.get(context, 'periodFortnight')),
                _periodChip('all', AppLocalizations.get(context, 'periodAllTime')),
                _periodChip('custom', AppLocalizations.get(context, 'customRange')),
              ],
            ),

            // ── कौन सा सप्ताह / कौन सा पखवाड़ा ──
            if (_period == 'week') ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < 5; i++)
                    _subChip(
                      label: i == 4
                          ? '29-$lastDay'
                          : '${i * 7 + 1}-${i * 7 + 7}',
                      selected: _weekIdx == i,
                      onTap: () {
                        setState(() => _weekIdx = i);
                        _loadReport();
                      },
                    ),
                ],
              ),
            ],
            if (_period == 'fortnight') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _subChip(
                      label: '1-15',
                      selected: _fortnightIdx == 0,
                      onTap: () {
                        setState(() => _fortnightIdx = 0);
                        _loadReport();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _subChip(
                      label: '16-$lastDay',
                      selected: _fortnightIdx == 1,
                      onTap: () {
                        setState(() => _fortnightIdx = 1);
                        _loadReport();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String value, String label) {
    final sel = _period == value;
    final teal = Theme.of(context).primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (value == 'custom') {
          _pickCustomDateRange();
          return;
        }
        setState(() => _period = value);
        _loadReport();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? teal : Colors.grey.shade400, width: sel ? 1.6 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
            color: sel ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _subChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final teal = Theme.of(context).primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? teal.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? teal : Colors.grey.shade300,
              width: selected ? 1.6 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? teal : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildKisanSummaryGrid(BuildContext context, KisanReportLoaded state) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final litresUnit = AppLocalizations.get(context, 'litres');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalMilk'), '${state.totalLitres.toStringAsFixed(1)} $litresUnit'),
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalAmount'), '₹ ${nf.format(state.totalAmount)}', color: Theme.of(context).primaryColor),
        _buildSummaryStat(context, AppLocalizations.get(context, 'avgFat'), '${state.avgFat.toStringAsFixed(1)} %'),
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalEntries'), '${state.entryCount}'),
      ],
    );
  }

  Widget _buildDoodhwalaSummaryGrid(BuildContext context, DoodhwalaReportLoaded state) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final litresUnit = AppLocalizations.get(context, 'litres');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalDistribution'), '${state.grandTotalLitres.toStringAsFixed(1)} $litresUnit'),
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalSaleAmount'), '₹ ${nf.format(state.grandTotalAmount)}'),
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalReceived'), '₹ ${nf.format(state.grandTotalPaid)}', color: Colors.green[800]),
        _buildSummaryStat(context, AppLocalizations.get(context, 'totalDue'), '₹ ${nf.format(state.grandTotalDue)}', color: Colors.red[800]),
      ],
    );
  }

  Widget _buildSummaryStat(BuildContext context, String label, String value, {Color? color}) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKisanEntriesTable(BuildContext context, List<MilkEntry> entries) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final litresUnit = AppLocalizations.get(context, 'litres');

    return Card(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(0.8),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.get(context, 'report_table_date'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.get(context, 'report_table_shift'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.get(context, 'report_table_milk'), style: const TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.get(context, 'report_table_amount'), style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          ...entries.map((entry) {
            final shift = entry.shift == 'M'
                ? AppLocalizations.get(context, 'morning')
                : AppLocalizations.get(context, 'evening');
            return TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text(entry.date)),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(shift)),
                Padding(padding: const EdgeInsets.all(8.0), child: Text('${entry.qtyL.toStringAsFixed(1)} $litresUnit')),
                Padding(padding: const EdgeInsets.all(8.0), child: Text('₹ ${nf.format(entry.amount)}')),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDoodhwalaTable(BuildContext context, List<CustomerReportItem> items) {
    final nf = NumberFormat('#,##,##0', 'en_IN');

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(AppLocalizations.get(context, 'tableName'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(AppLocalizations.get(context, 'report_table_milk'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(AppLocalizations.get(context, 'totalAmount'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(AppLocalizations.get(context, 'tablePaid'), style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(AppLocalizations.get(context, 'tableDue'), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: items.map((item) {
            final isDue = item.due > 0;
            return DataRow(
              cells: [
                DataCell(Text(item.customer.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(item.totalLitres.toStringAsFixed(1))),
                DataCell(Text('₹ ${nf.format(item.totalAmount)}')),
                DataCell(Text('₹ ${nf.format(item.totalPaid)}')),
                DataCell(
                  Text(
                    '₹ ${nf.format(item.due)}',
                    style: TextStyle(
                      color: isDue ? Colors.red[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
