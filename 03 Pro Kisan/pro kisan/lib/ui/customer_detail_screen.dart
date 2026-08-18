import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/report_cubit.dart';
import '../../db/models/customer.dart';
import '../../db/models/milk_entry.dart';
import '../../db/models/payment.dart';
import '../../db/dao/entry_dao.dart';
import '../../db/dao/payment_dao.dart';
import '../../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';
import '../../services/pdf_service.dart';
import 'widgets/milk_chart_widget.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final EntryDao _entryDao = EntryDao();
  final PaymentDao _paymentDao = PaymentDao();

  List<MilkEntry> _entries = [];
  List<Payment> _payments = [];
  double _totalDues = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
    });

    final currentMonth = DateFormat('MM-yyyy').format(DateTime.now());
    if (widget.customer.id != null) {
      final entriesList = await _entryDao.getCustomerMonthlyEntries(widget.customer.id!, currentMonth);
      final paymentsList = await _paymentDao.getCustomerMonthlyPayments(widget.customer.id!, currentMonth);
      final currentDue = await _paymentDao.getCustomerDue(widget.customer.id!);

      setState(() {
        _entries = entriesList;
        _payments = paymentsList;
        _totalDues = currentDue;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final isDue = _totalDues > 0;
    final isAdv = _totalDues < 0;
    final statusColor = isDue
        ? Colors.red[800]
        : isAdv
            ? Colors.green[800]
            : Colors.grey[600];

    final statusText = isDue
        ? '₹${nf.format(_totalDues.abs())} ${AppLocalizations.get(context, 'due')}'
        : isAdv
            ? '₹${nf.format(_totalDues.abs())} ${AppLocalizations.get(context, 'advance')}'
            : AppLocalizations.get(context, 'customer_balance_equal');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: AppLocalizations.get(context, 'customer_generate_pdf_tooltip'),
            onPressed: () {
              // महीने का नाम ऐप की भाषा में; intl उस भाषा को न जानता हो
              // (जैसे भोजपुरी) तो हिंदी में
              String monthName;
              try {
                monthName = DateFormat('MMMM yyyy',
                        Localizations.localeOf(context).languageCode)
                    .format(DateTime.now());
              } catch (_) {
                monthName =
                    DateFormat('MMMM yyyy', 'hi_IN').format(DateTime.now());
              }
              final totalLitres = _entries.fold<double>(0, (sum, e) => sum + e.qtyL);
              final totalAmount = _entries.fold<double>(0, (sum, e) => sum + e.amount);
              final totalPaid = _payments.fold<double>(0, (sum, p) => sum + p.amount);

              PdfService.instance.openCustomerBill(
                context,
                t: (k) => AppLocalizations.get(context, k),
                customer: widget.customer,
                periodName: monthName,
                totalLitres: totalLitres,
                totalAmount: totalAmount,
                totalPaid: totalPaid,
                due: totalAmount - totalPaid,
                entries: _entries,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: AppLocalizations.get(context, 'shareText'),
            onPressed: _shareWhatsAppBill,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDetails,
                child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatusCard(context, statusText, statusColor),
                  const SizedBox(height: 12),
                  _buildContactActions(context),
                  const SizedBox(height: 16),
                  _buildQuickActionButtons(context),
                  const SizedBox(height: 16),
                  _buildRateInfoCard(context),
                  const SizedBox(height: 16),
                  if (_entries.isNotEmpty) MilkChartWidget(entries: _entries, isCompact: true),
                  const SizedBox(height: 24),
                  _buildHistoryHeader(context),
                  const SizedBox(height: 8),
                  if (_entries.isEmpty && _payments.isEmpty)
                    _buildEmptyState(context)
                  else
                    _buildHistoryList(context),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String statusText, Color? statusColor) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    double sellTotal = 0.0;
    double buyTotal = 0.0;
    for (final e in _entries) {
      if (e.direction == 'buy') {
        buyTotal += e.amount;
      } else {
        sellTotal += e.amount;
      }
    }
    final net = sellTotal - buyTotal;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.get(context, 'summary'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusTile(
                  title: AppLocalizations.get(context, 'receivableLabel'),
                  amount: sellTotal,
                  color: Colors.green.shade800,
                  nf: nf,
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                _statusTile(
                  title: AppLocalizations.get(context, 'payableLabel'),
                  amount: buyTotal,
                  color: Colors.orange.shade800,
                  nf: nf,
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              '${AppLocalizations.get(context, 'netBalanceLabel')}: ₹${nf.format(net)}',
              style: TextStyle(
                color: net >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile({
    required String title,
    required double amount,
    required Color color,
    required NumberFormat nf,
  }) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Text('₹${nf.format(amount)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  /// Contact actions — Call / WhatsApp / Address (Issue 5)
  Widget _buildContactActions(BuildContext context) {
    final hasPhone = widget.customer.phone != null && widget.customer.phone!.isNotEmpty;
    final hasAddress = widget.customer.address != null && widget.customer.address!.isNotEmpty;

    if (!hasPhone && !hasAddress) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (hasPhone) ...[
              Row(
                children: [
                  Icon(Icons.phone_iphone_rounded, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.customer.phone!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  // Call button
                  IconButton(
                    icon: const Icon(Icons.call_rounded, color: Colors.green),
                    tooltip: AppLocalizations.get(context, 'customer_contact_call'),
                    onPressed: () => _makeCall(widget.customer.phone!),
                  ),
                  // WhatsApp button
                  IconButton(
                    icon: const Icon(Icons.message_rounded, color: Color(0xFF25D366)),
                    tooltip: 'WhatsApp',
                    onPressed: () => _openWhatsApp(widget.customer.phone!),
                  ),
                ],
              ),
            ],
            if (hasAddress) ...[
              if (hasPhone) const Divider(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    widget.customer.address!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.currency_rupee_rounded),
            label: Text(AppLocalizations.get(context, 'paid')),
            onPressed: () => _showPaymentDialog(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(AppLocalizations.get(context, 'customer_add_milk_entry_btn')),
            onPressed: () {
              Navigator.pushNamed(context, '/entry').then((_) => _loadDetails());
            },
          ),
        ),
      ],
    );
  }

  /// Rate info card — shows current rate settings (Issue 2 & 5)
  Widget _buildRateInfoCard(BuildContext context) {
    final c = widget.customer;
    return Card(
      color: Colors.grey.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 18, color: DairyTheme.primaryTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                c.rateType == 'flat'
                    ? AppLocalizations.get(context, 'customer_rate_info_flat')
                        .replaceFirst('{rate}', c.flatRate.toStringAsFixed(1))
                        .replaceFirst('{qty}', c.defaultQtyL.toStringAsFixed(1))
                    : AppLocalizations.get(context, 'customer_rate_info_fat')
                        .replaceFirst('{rate}', c.ratePerFatPoint.toStringAsFixed(1))
                        .replaceFirst('{qty}', c.defaultQtyL.toStringAsFixed(1)),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Text(
      AppLocalizations.get(context, 'history'),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
        fontSize: 18,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          AppLocalizations.get(context, 'customer_no_transactions'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');

    // Combine and sort entries and payments by date (descending)
    final items = <dynamic>[];
    items.addAll(_entries);
    items.addAll(_payments);

    items.sort((a, b) {
      final dateA = DateFormat('dd-MM-yyyy').parse(a.date);
      final dateB = DateFormat('dd-MM-yyyy').parse(b.date);
      return dateB.compareTo(dateA); // Newest first
    });

    return Column(
      children: items.map((item) {
        if (item is MilkEntry) {
          final shift = item.shift == 'M'
              ? AppLocalizations.get(context, 'morning')
              : AppLocalizations.get(context, 'evening');
          return Card(
            key: ValueKey('entry_${item.id}'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.local_drink_rounded, color: Theme.of(context).primaryColor),
              ),
              title: Text(
                '${AppLocalizations.get(context, 'report_table_milk')}: ${item.qtyL.toStringAsFixed(1)} ${AppLocalizations.get(context, 'litres')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${item.date} | $shift'),
              trailing: Text(
                '₹ ${nf.format(item.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          );
        } else if (item is Payment) {
          return Card(
            color: Colors.green[50],
            key: ValueKey('payment_${item.id}'),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check_rounded, color: Colors.white),
              ),
              title: Text(
                '${AppLocalizations.get(context, 'milkReceivedPaid')}: ₹ ${nf.format(item.amount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              subtitle: Text('${item.date}${item.note.isEmpty ? "" : " | " + item.note}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                onPressed: () => _deletePayment(item.id!),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'paid')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(context, 'amountRupees'),
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.get(context, 'paymentNote'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get(context, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) return;

                final note = noteController.text.trim();
                final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

                final payment = Payment(
                  customerId: widget.customer.id,
                  date: formattedDate,
                  amount: amount,
                  note: note,
                );

                await _paymentDao.insertPayment(payment);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  _loadDetails();
                }
              },
              child: Text(AppLocalizations.get(context, 'save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePayment(int id) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'warning')),
          content: Text(AppLocalizations.get(context, 'customer_delete_payment_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get(context, 'no')),
            ),
            ElevatedButton(
              onPressed: () async {
                await _paymentDao.deletePayment(id);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  _loadDetails();
                }
              },
              child: Text(AppLocalizations.get(context, 'yes')),
            ),
          ],
        );
      },
    );
  }

  // canLaunchUrl नहीं — Android 11+ पर वह false लौटाकर बटन को चुप कर देता है
  void _makeCall(String phone) async {
    try {
      await launchUrl(Uri.parse('tel:$phone'),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final number = cleaned.length == 10 ? '91$cleaned' : cleaned;
    try {
      final ok = await launchUrl(Uri.parse('https://wa.me/$number'),
          mode: LaunchMode.externalApplication);
      if (!ok) Share.share('WhatsApp: $phone');
    } catch (_) {
      Share.share('WhatsApp: $phone');
    }
  }

  void _shareWhatsAppBill() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', context.read<AppCubit>().state.language == 'hi' ? 'hi' : 'en').format(now);

    double totalLitres = 0.0;
    double totalAmount = 0.0;
    double totalPaid = 0.0;

    for (final entry in _entries) {
      totalLitres += entry.qtyL;
      totalAmount += entry.amount;
    }

    for (final payment in _payments) {
      totalPaid += payment.amount;
    }

    double effectiveRate = 0.0;
    if (widget.customer.rateType == 'flat') {
      effectiveRate = widget.customer.flatRate;
    } else {
      effectiveRate = totalLitres > 0 ? totalAmount / totalLitres : 0.0;
    }

    final billText = context.read<ReportCubit>().generateBillText(
          monthName: monthName,
          customerName: widget.customer.name,
          totalLitres: totalLitres,
          rate: effectiveRate,
          totalAmount: totalAmount,
          totalPaid: totalPaid,
        );

    final phone = widget.customer.phone;
    if (phone != null && phone.isNotEmpty) {
      final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final number = cleaned.length == 10 ? '91$cleaned' : cleaned;
      final encodedText = Uri.encodeComponent(billText);
      // canLaunchUrl नहीं — Android 11+ पर वह false लौटाकर हमेशा सामान्य share
      // dialog खोल देता था, WhatsApp कभी नहीं खुलता था।
      final waUri = Uri.parse('https://wa.me/$number?text=$encodedText');
      launchUrl(waUri, mode: LaunchMode.externalApplication).then((ok) {
        if (!ok) Share.share(billText);
      }).catchError((_) {
        Share.share(billText);
      });
    } else {
      Share.share(billText);
    }
  }
}
