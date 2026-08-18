import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/report_cubit.dart';
import '../../db/models/milk_entry.dart';
import '../../l10n/app_localizations.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late String _currentMonth; // MM-YYYY

  @override
  void initState() {
    super.initState();
    _currentMonth = DateFormat('MM-yyyy').format(DateTime.now());
    _loadReport();
  }

  void _loadReport() {
    final mode = context.read<AppCubit>().state.mode;
    if (mode == 'kisan') {
      context.read<ReportCubit>().loadKisanReport(_currentMonth);
    } else {
      context.read<ReportCubit>().loadDoodhwalaReport(_currentMonth);
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
            icon: const Icon(Icons.date_range_rounded),
            onPressed: _selectMonth,
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
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
    );
  }

  Widget _buildKisanReport(BuildContext context, KisanReportLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportPeriodCard(context, state.monthName),
        const SizedBox(height: 16),
        _buildKisanSummaryGrid(context, state),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'रोज का रिकॉर्ड',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(AppLocalizations.get(context, 'shareText')),
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
            Text(
              'ग्राहकों का विवरण',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(AppLocalizations.get(context, 'shareText')),
              onPressed: () {
                final buffer = StringBuffer();
                buffer.writeln('🥛 दूध का हिसाब — ${state.monthName}');
                buffer.writeln('---------------------------');
                for (final item in state.customerReports) {
                  buffer.writeln(
                    '${item.customer.name}: ${item.totalLitres.toStringAsFixed(1)} ली | ₹ ${nf.format(item.totalAmount)} | बाकी: ₹ ${nf.format(item.due)}',
                  );
                }
                buffer.writeln('---------------------------');
                buffer.writeln('कुल दूध: ${state.grandTotalLitres.toStringAsFixed(1)} ली');
                buffer.writeln('कुल बकाया: ₹ ${nf.format(state.grandTotalDue)}');
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
    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_month_rounded, color: Theme.of(context).primaryColor, size: 30),
        title: const Text('रिपोर्ट अवधि', style: TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(
          monthName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        trailing: Icon(Icons.edit_calendar_rounded, color: Theme.of(context).primaryColor),
        onTap: _selectMonth,
      ),
    );
  }

  Widget _buildKisanSummaryGrid(BuildContext context, KisanReportLoaded state) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildSummaryStat(context, 'कुल दूध', '${state.totalLitres.toStringAsFixed(1)} ली'),
        _buildSummaryStat(context, 'कुल राशि', '₹ ${nf.format(state.totalAmount)}', color: Theme.of(context).primaryColor),
        _buildSummaryStat(context, 'औसत फैट', '${state.avgFat.toStringAsFixed(1)} %'),
        _buildSummaryStat(context, 'कुल एंट्रियां', '${state.entryCount} बार'),
      ],
    );
  }

  Widget _buildDoodhwalaSummaryGrid(BuildContext context, DoodhwalaReportLoaded state) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildSummaryStat(context, 'कुल वितरण', '${state.grandTotalLitres.toStringAsFixed(1)} ली'),
        _buildSummaryStat(context, 'कुल बिक्री राशि', '₹ ${nf.format(state.grandTotalAmount)}'),
        _buildSummaryStat(context, 'कुल प्राप्त', '₹ ${nf.format(state.grandTotalPaid)}', color: Colors.green[800]),
        _buildSummaryStat(context, 'कुल बाकी', '₹ ${nf.format(state.grandTotalDue)}', color: Colors.red[800]),
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
            children: const [
              Padding(padding: EdgeInsets.all(8.0), child: Text('तारीख', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('शिफ्ट', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('दूध', style: TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('राशि', style: TextStyle(fontWeight: FontWeight.bold))),
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
                Padding(padding: const EdgeInsets.all(8.0), child: Text('${entry.qtyL.toStringAsFixed(1)} ली')),
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
          columns: const [
            DataColumn(label: Text('नाम', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('दूध (ली)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('कुल राशि', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('प्राप्त', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('बाकी', style: TextStyle(fontWeight: FontWeight.bold))),
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
