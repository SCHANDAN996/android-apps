import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';

class MyRatesScreen extends StatefulWidget {
  final StorageService storage;
  const MyRatesScreen({super.key, required this.storage});

  @override
  State<MyRatesScreen> createState() => _MyRatesScreenState();
}

class _MyRatesScreenState extends State<MyRatesScreen> {
  late TextEditingController _brickCtrl;
  late TextEditingController _cementCtrl;
  late TextEditingController _sandCtrl;
  late TextEditingController _aggregateCtrl;
  late TextEditingController _steelCtrl;
  late TextEditingController _tileCtrl;
  late TextEditingController _paintCtrl;

  /// Show whole rates cleanly (500 instead of 500.0), keep decimals if present.
  static String _rateText(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  void initState() {
    super.initState();
    _brickCtrl = TextEditingController(
      text: _rateText(widget.storage.brickRate),
    );
    _cementCtrl = TextEditingController(
      text: _rateText(widget.storage.cementRate),
    );
    _sandCtrl = TextEditingController(text: _rateText(widget.storage.sandRate));
    _aggregateCtrl = TextEditingController(
      text: _rateText(widget.storage.aggregateRate),
    );
    _steelCtrl = TextEditingController(
      text: _rateText(widget.storage.steelRate),
    );
    _tileCtrl = TextEditingController(text: _rateText(widget.storage.tileRate));
    _paintCtrl = TextEditingController(
      text: _rateText(widget.storage.paintRate),
    );
  }

  @override
  void dispose() {
    _brickCtrl.dispose();
    _cementCtrl.dispose();
    _sandCtrl.dispose();
    _aggregateCtrl.dispose();
    _steelCtrl.dispose();
    _tileCtrl.dispose();
    _paintCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    Future<void> saveRate(
      TextEditingController controller,
      Future<void> Function(double value) setRate,
      Future<void> Function() clearRate,
    ) async {
      final rawValue = controller.text.trim();
      if (rawValue.isEmpty) {
        await clearRate();
        return;
      }

      final value = double.tryParse(rawValue);
      if (value != null && value >= 0) await setRate(value);
    }

    await saveRate(
      _brickCtrl,
      widget.storage.setBrickRate,
      widget.storage.clearBrickRate,
    );
    await saveRate(
      _cementCtrl,
      widget.storage.setCementRate,
      widget.storage.clearCementRate,
    );
    await saveRate(
      _sandCtrl,
      widget.storage.setSandRate,
      widget.storage.clearSandRate,
    );
    await saveRate(
      _aggregateCtrl,
      widget.storage.setAggregateRate,
      widget.storage.clearAggregateRate,
    );
    await saveRate(
      _steelCtrl,
      widget.storage.setSteelRate,
      widget.storage.clearSteelRate,
    );
    await saveRate(
      _tileCtrl,
      widget.storage.setTileRate,
      widget.storage.clearTileRate,
    );
    await saveRate(
      _paintCtrl,
      widget.storage.setPaintRate,
      widget.storage.clearPaintRate,
    );

    await widget.storage.markRatesUpdated();

    if (mounted) {
      setState(() {}); // the "last updated" line
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('ratesSaved')),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(),
      appBar: AppBar(title: Text(AppStrings.get('myRates'))),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rates header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('myRates'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          AppStrings.currentLang == 'hi'
                              ? 'अपने इलाके का रेट डालें। हर कैलकुलेशन में अनुमानित ख़र्चा दिखेगा।'
                              : 'Enter your local rates. Estimated cost will show in every calculation.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Image.asset(
                      'assets/images/rate_planning_kit.webp',
                      fit: BoxFit.contain,
                      semanticLabel: 'Construction estimation tools',
                    ),
                  ),
                ],
              ),
            ),
            if (widget.storage.ratesUpdatedAt case final at?) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  (widget.storage.ratesAgeDays ?? 0) >
                          StorageService.ratesStaleAfterDays
                      ? AppStrings.get(
                          'ratesOld',
                        ).replaceAll('{n}', '${widget.storage.ratesAgeDays}')
                      : '${AppStrings.get('ratesUpdated')}: ${DateFormat('d MMM yyyy').format(at)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            _RateField(
              controller: _brickCtrl,
              label: AppStrings.get('brickRate'),
              icon: Icons.view_comfy_alt_rounded,
              iconColor: const Color(0xFFD84315),
            ),
            _RateField(
              controller: _cementCtrl,
              label: AppStrings.get('cementRate'),
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFF37474F),
            ),
            _RateField(
              controller: _sandCtrl,
              label: AppStrings.get('sandRate'),
              icon: Icons.grain_outlined,
              iconColor: const Color(0xFFFF8F00),
            ),
            _RateField(
              controller: _aggregateCtrl,
              label: AppStrings.get('aggregateRate'),
              icon: Icons.landscape_outlined,
              iconColor: const Color(0xFF5D4037),
            ),
            _RateField(
              controller: _steelCtrl,
              label: AppStrings.get('steelRate'),
              icon: Icons.straighten_rounded,
              iconColor: const Color(0xFF4527A0),
            ),
            _RateField(
              controller: _tileCtrl,
              label: AppStrings.get('tileRate'),
              icon: Icons.grid_view_rounded,
              iconColor: const Color(0xFF0277BD),
            ),
            _RateField(
              controller: _paintCtrl,
              label: AppStrings.get('paintRate'),
              icon: Icons.color_lens_rounded,
              iconColor: const Color(0xFFC62828),
            ),
            const SizedBox(height: 24),

            CalculateButton(onPressed: _save, label: AppStrings.get('save')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _RateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _RateField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LargeInputField(
              controller: controller,
              label: label,
              suffix: '₹',
            ),
          ),
        ],
      ),
    );
  }
}
