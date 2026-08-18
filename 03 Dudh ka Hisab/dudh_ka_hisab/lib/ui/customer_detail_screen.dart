import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/report_cubit.dart';
import '../../db/models/customer.dart';
import '../../db/models/milk_entry.dart';
import '../../db/models/payment.dart';
import '../../db/dao/entry_dao.dart';
import '../../db/dao/payment_dao.dart';
import '../../l10n/app_localizations.dart';

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
            : 'हिसाब बराबर';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: AppLocalizations.get(context, 'shareText'),
            onPressed: _shareWhatsAppBill,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDetails,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatusCard(context, statusText, statusColor),
                  const SizedBox(height: 16),
                  _buildQuickActionButtons(context),
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
    );
  }

  Widget _buildStatusCard(BuildContext context, String statusText, Color? statusColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'कुल बकाया विवरण',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.customer.phone != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    widget.customer.phone!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                  ),
                ],
              )
            ]
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
            label: const Text('दूध डालें'),
            onPressed: () {
              Navigator.pushNamed(context, '/entry').then((_) => _loadDetails());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Text(
      'इस महीने का लेनदेन (${AppLocalizations.get(context, 'history')})',
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
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'इस महीने में अभी तक कोई लेनदेन या एंट्री दर्ज नहीं की गई है।',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
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
                'दूध: ${item.qtyL.toStringAsFixed(1)} लिटर',
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
                'पैसा मिला: ₹ ${nf.format(item.amount)}',
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
                decoration: const InputDecoration(
                  labelText: 'रकम (₹)',
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
          content: const Text('क्या आप इस भुगतान को हटाना चाहते हैं?'),
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

    final billText = context.read<ReportCubit>().generateBillText(
          monthName: monthName,
          customerName: widget.customer.name,
          totalLitres: totalLitres,
          rate: widget.customer.rateType == 'flat' ? widget.customer.flatRate : 0.0,
          totalAmount: totalAmount,
          totalPaid: totalPaid,
        );

    Share.share(billText);
  }
}
