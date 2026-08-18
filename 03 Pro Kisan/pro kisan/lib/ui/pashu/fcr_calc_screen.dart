import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/pashu_calc.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';

// ignore_for_file: deprecated_member_use

/// 🧮 मुर्गी पालन का हिसाब — FCR, दाना-लागत और मुनाफ़ा।
///
/// किसान के दो सबसे बड़े सवाल यही हैं:
///  • ब्रॉयलर: "जितना दाना डाला, उतना वज़न मिला या नहीं?" (FCR)
///  • लेयर: "एक अंडे पर दाने का कितना ख़र्च आया?"
/// दाना कुल ख़र्च का ~70% होता है, इसलिए यही हिसाब मुनाफ़े का असली पैमाना है।
class FcrCalcScreen extends StatefulWidget {
  const FcrCalcScreen({super.key});

  @override
  State<FcrCalcScreen> createState() => _FcrCalcScreenState();
}

class _FcrCalcScreenState extends State<FcrCalcScreen> {
  bool _isBroiler = true;

  final _birds = TextEditingController();
  final _feed = TextEditingController();
  final _weight = TextEditingController(); // ब्रॉयलर
  final _eggs = TextEditingController(); // लेयर
  final _feedRate = TextEditingController(text: '40');
  final _sellRate = TextEditingController(text: '105');
  final _eggPrice = TextEditingController(text: '5.5');

  FcrResult? _result;

  @override
  void dispose() {
    for (final c in [
      _birds, _feed, _weight, _eggs, _feedRate, _sellRate, _eggPrice
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String k) => AppLocalizations.get(context, k);
  double _d(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '')) ?? 0;
  int _i(TextEditingController c) =>
      int.tryParse(c.text.trim().replaceAll(',', '')) ?? 0;

  void _calc() {
    setState(() {
      _result = _isBroiler
          ? broilerFcr(
              birds: _i(_birds),
              feedKg: _d(_feed),
              totalWeightKg: _d(_weight),
              feedRatePerKg: _d(_feedRate),
              sellRatePerKg: _d(_sellRate),
            )
          : layerFcr(
              birds: _i(_birds),
              feedKg: _d(_feed),
              eggs: _i(_eggs),
              feedRatePerKg: _d(_feedRate),
              eggPrice: _d(_eggPrice),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('fcrCalcTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          Text(_t('fcrCalcHint'),
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
          const SizedBox(height: 12),

          // ── ब्रॉयलर / लेयर ──
          Row(
            children: [
              Expanded(child: _typeBtn(true, '🍗', _t('fcrBroiler'))),
              const SizedBox(width: 10),
              Expanded(child: _typeBtn(false, '🥚', _t('fcrLayer'))),
            ],
          ),
          const SizedBox(height: 16),

          _field(_birds, _t('fcrBirds'), Icons.numbers_rounded),
          _field(_feed, _t('fcrFeedKg'), Icons.inventory_2_rounded),
          if (_isBroiler)
            _field(_weight, _t('fcrWeightKg'), Icons.scale_rounded)
          else
            _field(_eggs, _t('fcrEggs'), Icons.egg_rounded),
          _field(_feedRate, _t('fcrFeedRate'), Icons.currency_rupee_rounded),
          if (_isBroiler)
            _field(_sellRate, _t('fcrSellRate'), Icons.sell_rounded)
          else
            _field(_eggPrice, _t('fcrEggPrice'), Icons.sell_rounded),

          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.calculate_rounded),
            label: Text(_t('calculate')),
            onPressed: _calc,
          ),

          if (_result != null) ...[
            const SizedBox(height: 20),
            _resultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _typeBtn(bool broiler, String emoji, String label) {
    final sel = _isBroiler == broiler;
    return GestureDetector(
      onTap: () => setState(() {
        _isBroiler = broiler;
        _result = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel
              ? DairyTheme.primaryTeal.withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? DairyTheme.primaryTeal : Colors.grey.shade300,
              width: sel ? 2 : 1),
        ),
        child: Column(
          children: [
            // ब्रॉयलर/अंडे का असली चित्र — पहले सिर्फ़ emoji था
            SizedBox(
              width: 42,
              height: 42,
              child: Image.asset(
                broiler
                    ? 'assets/images/3d_broiler.webp'
                    : 'assets/images/3d_egg.webp',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 20),
            isDense: true,
          ),
          onChanged: (_) {
            if (_result != null) setState(() => _result = null);
          },
        ),
      );

  Widget _resultCard(FcrResult r) {
    final nf = NumberFormat('#,##,##0.##', 'en_IN');
    final good = _isBroiler && r.fcr > 0 && r.fcr <= 1.8;
    final ok = _isBroiler && r.fcr > 1.8 && r.fcr <= 2.1;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isBroiler) ...[
              _row(_t('fcrResultFcr'), r.fcr.toStringAsFixed(2), big: true),
              const SizedBox(height: 4),
              Text(
                r.fcr <= 0
                    ? ''
                    : good
                        ? _t('fcrGood')
                        : ok
                            ? _t('fcrOk')
                            : _t('fcrBad'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: good
                      ? Colors.green.shade800
                      : ok
                          ? Colors.orange.shade800
                          : Colors.red.shade800,
                ),
              ),
              const Divider(height: 20),
              _row(_t('fcrCostPerKg'), '₹${nf.format(r.feedCostPerUnit)}'),
            ] else ...[
              _row(_t('fcrFeedPerEgg'), '${nf.format(r.feedPerUnit)} g',
                  big: true),
              const Divider(height: 20),
              _row(_t('fcrCostPerEgg'), '₹${nf.format(r.feedCostPerUnit)}'),
            ],
            _row(_t('fcrFeedCost'), '₹${nf.format(r.totalFeedCost)}'),
            _row(_t('fcrIncome'), '₹${nf.format(r.totalIncome)}'),
            const Divider(height: 20),
            _row(_t('fcrProfit'), '₹${nf.format(r.profit)}',
                big: true,
                color: r.profit >= 0
                    ? Colors.green.shade800
                    : Colors.red.shade800),
            _row(_t('fcrPerBird'), '₹${nf.format(r.profitPerBird)}'),
            const SizedBox(height: 10),
            Text(_t('fcrNote'),
                style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(_t('shareText')),
              onPressed: () => Share.share(_shareText(r, nf)),
            ),
          ],
        ),
      ),
    );
  }

  String _shareText(FcrResult r, NumberFormat nf) {
    final b = StringBuffer('🐔 ${_t('fcrCalcTitle')} — ${_t('appName')}\n');
    b.writeln('${_isBroiler ? _t('fcrBroiler') : _t('fcrLayer')}');
    if (_isBroiler) {
      b.writeln('${_t('fcrResultFcr')}: ${r.fcr.toStringAsFixed(2)}');
    } else {
      b.writeln('${_t('fcrFeedPerEgg')}: ${nf.format(r.feedPerUnit)} g');
    }
    b.writeln('${_t('fcrFeedCost')}: ₹${nf.format(r.totalFeedCost)}');
    b.writeln('${_t('fcrIncome')}: ₹${nf.format(r.totalIncome)}');
    b.writeln('${_t('fcrProfit')}: ₹${nf.format(r.profit)}');
    return b.toString();
  }

  Widget _row(String label, String value, {bool big = false, Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: big ? 15 : 13.5,
                      fontWeight: big ? FontWeight.w700 : FontWeight.normal)),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: big ? 20 : 14,
                    fontWeight: FontWeight.w800,
                    color: color ?? (big ? DairyTheme.primaryTeal : null))),
          ],
        ),
      );
}
