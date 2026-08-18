import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/dairy_product_cubit.dart';
import '../data/dairy_products.dart';
import '../db/models/dairy_product_entry.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';
import 'weather/weather_common.dart' show kMonthsHi, kMonthsShortEn;

class DairyProductsScreen extends StatefulWidget {
  const DairyProductsScreen({super.key});

  @override
  State<DairyProductsScreen> createState() => _DairyProductsScreenState();
}

class _DairyProductsScreenState extends State<DairyProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DairyProductCubit>().loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _t(String key) => AppLocalizations.get(context, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // दूध वाले हिस्से जैसा teal — यह दूध का ही उप-हिस्सा है
        backgroundColor: DairyTheme.milkAccent,
        title: Text(_t('dairy_appbar_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.calculate_rounded), text: _t('dairy_tab_calculator')),
            Tab(icon: const Icon(Icons.book_rounded), text: _t('dairy_tab_ledger')),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _CalculatorTab(),
            _LedgerTab(),
          ],
        ),
      ),
    );
  }
}

class _CalculatorTab extends StatefulWidget {
  @override
  State<_CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<_CalculatorTab> {
  DairyProduct _selected = kDairyProducts.first;
  final _milkCtrl = TextEditingController();
  double _productQty = 0;
  double _totalAmount = 0;

  String _t(String key) => AppLocalizations.get(context, key);

  @override
  void dispose() {
    _milkCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final milk = double.tryParse(_milkCtrl.text.trim()) ?? 0;
    setState(() {
      _productQty = _selected.productFromMilk(milk);
      _totalAmount = _productQty * _selected.defaultPricePerKg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_t('dairy_select_product'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildProductGrid(),
          const SizedBox(height: 16),
          _buildProductInfoCard(),
          const SizedBox(height: 16),
          Text(_t('dairy_milk_input_hint'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: _milkCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '10',
              suffixText: _t('litres'),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),
          if (_productQty > 0) _buildResultCard(),
          const SizedBox(height: 16),
          if (_productQty > 0)
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: Text(_t('dairy_add_entry_btn')),
              onPressed: () => _saveEntry(context),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: kDairyProducts.length,
      itemBuilder: (context, idx) {
        final product = kDairyProducts[idx];
        final isSelected = product.id == _selected.id;
        final isHi = AppLocalizations.isHindiLike(context);
        return InkWell(
          onTap: () {
            setState(() => _selected = product);
            _calculate();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? DairyTheme.milkAccent.withValues(alpha: 0.12)
                  : Theme.of(context).cardColor,
              border: Border.all(
                color: isSelected ? DairyTheme.milkAccent : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(product.icon,
                    size: 28,
                    color: isSelected ? DairyTheme.milkAccent : Colors.grey[600]),
                const SizedBox(height: 6),
                Text(
                  product.name(isHi).split(' ').first,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                    color: isSelected ? DairyTheme.primaryTeal : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfoCard() {
    final isHi = AppLocalizations.isHindiLike(context);
    return Card(
      color: _selected.color.withValues(alpha: 0.08),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_selected.icon, color: DairyTheme.milkAccent, size: 24),
                const SizedBox(width: 10),
                Text(_selected.name(isHi),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
            const SizedBox(height: 8),
            Text(_selected.description(isHi),
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
            const SizedBox(height: 8),
            Row(
              children: [
                _infoChip(
                    '${_selected.milkToProductRatio.toStringAsFixed(0)} ${_t('litres')} → 1 kg',
                    Colors.blue),
                const SizedBox(width: 8),
                _infoChip('₹${_selected.defaultPricePerKg.toStringAsFixed(0)}/kg', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  /// नतीजा — दूध वाले header जैसा teal gradient card, premium अहसास।
  Widget _buildResultCard() {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final milkUsed = double.tryParse(_milkCtrl.text.trim()) ?? 0;
    final isHi = AppLocalizations.isHindiLike(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DairyTheme.milkAccent, Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(AppLocalizations.get(context, 'dairy_estimated_result'),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          Divider(height: 20, color: Colors.white.withValues(alpha: 0.35)),
          _resultRow(
            '🥛 ${_t('dairy_milk_used')}',
            '${milkUsed.toStringAsFixed(1)} ${_t('litres')}',
          ),
          const SizedBox(height: 8),
          _resultRow(
            _selected.name(isHi),
            '${_productQty.toStringAsFixed(2)} kg',
            bold: true,
          ),
          const SizedBox(height: 8),
          _resultRow(
            '💰 ${_t('dairy_total_sale')}',
            '₹${nf.format(_totalAmount)}',
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.9))),
        Text(value,
            style: TextStyle(
              fontSize: bold ? 18 : 16,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: Colors.white,
            )),
      ],
    );
  }

  void _saveEntry(BuildContext context) {
    final milk = double.tryParse(_milkCtrl.text.trim()) ?? 0;
    if (milk <= 0) return;

    final entry = DairyProductEntry(
      productId: _selected.id,
      date: DateFormat('dd-MM-yyyy').format(DateTime.now()),
      milkUsedL: milk,
      productQtyKg: _productQty,
      pricePerKg: _selected.defaultPricePerKg,
      totalAmount: _totalAmount,
    );

    context.read<DairyProductCubit>().addEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ ${_selected.name(AppLocalizations.isHindiLike(context))} — ${_productQty.toStringAsFixed(2)} kg ${_t('dairy_add_entry_btn')}'),
        backgroundColor: DairyTheme.primaryTeal,
        duration: const Duration(seconds: 2),
      ),
    );

    _milkCtrl.clear();
    setState(() {
      _productQty = 0;
      _totalAmount = 0;
    });
  }
}

class _LedgerTab extends StatelessWidget {
  String _t(BuildContext context, String key) => AppLocalizations.get(context, key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DairyProductCubit, DairyProductState>(
      builder: (context, state) {
        if (state is DairyProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DairyProductLoaded) {
          return RefreshIndicator(
            onRefresh: () => context.read<DairyProductCubit>().loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMonthlySummary(context, state.monthlyTotals),
                const SizedBox(height: 16),

                if (state.todayEntries.isNotEmpty) ...[
                  Text(_t(context, 'dairy_today_made'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...state.todayEntries.map((e) => _buildEntryCard(context, e)),
                  const SizedBox(height: 16),
                ],

                Text(_t(context, 'dairy_monthly_ledger'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                if (state.monthlyEntries.isEmpty)
                  Card(
                    elevation: 0,
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _t(context, 'dairy_no_entry_month'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  )
                else
                  ...state.monthlyEntries.map((e) => _buildEntryCard(context, e)),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMonthlySummary(BuildContext context, Map<String, double> totals) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final milkUsed = totals['totalMilkUsed'] ?? 0.0;
    final productQty = totals['totalProductQty'] ?? 0.0;
    final totalAmount = totals['totalAmount'] ?? 0.0;

    final isHi = AppLocalizations.isHindiLike(context);
    final m = DateTime.now().month;
    final currentMonth = isHi ? kMonthsHi[m] : kMonthsShortEn[m];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.get(context, 'dairy_monthly_summary').replaceFirst('{month}', currentMonth),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 16),
            Row(
              children: [
                _summaryItem('${_t(context, 'dairy_milk_used')}', '${milkUsed.toStringAsFixed(1)} ${_t(context, 'litres')}'),
                _summaryItem('${_t(context, 'dairy_product_qty')}', '${productQty.toStringAsFixed(1)} kg'),
                _summaryItem('${_t(context, 'dairy_total_sale')}', '₹${nf.format(totalAmount)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                  color: DairyTheme.primaryTeal)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, DairyProductEntry entry) {
    final product = getDairyProductById(entry.productId);
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final productName =
        product?.name(AppLocalizations.isHindiLike(context)) ?? entry.productId;
    final icon = product?.icon ?? Icons.category_rounded;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (product?.color ?? Colors.grey).withOpacity(0.15),
          child: Icon(icon, color: DairyTheme.primaryTeal),
        ),
        title: Text(
          '$productName — ${entry.productQtyKg.toStringAsFixed(2)} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${entry.date} | ${_t(context, 'dairy_milk_used')}: ${entry.milkUsedL.toStringAsFixed(1)} ${_t(context, 'litres')} | ₹${entry.pricePerKg.toStringAsFixed(0)}/kg',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${nf.format(entry.totalAmount)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                  color: DairyTheme.primaryTeal),
            ),
          ],
        ),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(_t(context, 'dairy_delete_confirm')),
              content: Text(AppLocalizations.get(context, 'dairy_delete_confirm_body').replaceFirst('{name}', productName)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t(context, 'no'))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                  onPressed: () {
                    if (entry.id != null) {
                      context.read<DairyProductCubit>().deleteEntry(entry.id!);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(_t(context, 'yes')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
