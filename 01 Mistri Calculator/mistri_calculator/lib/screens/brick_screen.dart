import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/brick_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class BrickScreen extends StatefulWidget {
  final StorageService storage;
  const BrickScreen({super.key, required this.storage});

  @override
  State<BrickScreen> createState() => _BrickScreenState();
}

class _BrickScreenState extends State<BrickScreen> {
  final _lengthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _unit = 'ft';
  double _thickness = BrickCalculator.fullBrickThickness; // 9" default
  int _ratioC = 1;
  int _ratioS = 6; // 1:6 default
  BrickResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final length = double.tryParse(_lengthCtrl.text);
    final height = double.tryParse(_heightCtrl.text);

    if (length == null || length <= 0 || height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('enterValue')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _result = BrickCalculator.calculate(
        length: length,
        height: height,
        unit: _unit,
        thicknessM: _thickness,
        ratioC: _ratioC,
        ratioS: _ratioS,
      );
    });

    AdService().onCalculationComplete();
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    final thicknessLabel =
        _thickness == BrickCalculator.halfBrickThickness ? '4.5"' : '9"';
    final rates = widget.storage.allRates;

    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🧱 ${AppStrings.get('brick')}\n';
    text +=
        '${AppStrings.get('wallLength')}: ${_lengthCtrl.text} $_unit\n';
    text +=
        '${AppStrings.get('wallHeight')}: ${_heightCtrl.text} $_unit\n';
    text += '${AppStrings.get('wallThickness')}: $thicknessLabel\n';
    text += '${AppStrings.get('mortarRatio')}: $_ratioC:$_ratioS\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('brickCount')}: ${IndianFormatter.format(r.brickCount.toDouble())}\n';
    text +=
        '${AppStrings.get('cementBags')}: ${r.cementBags.toStringAsFixed(1)}\n';
    text +=
        '${AppStrings.get('sandCft')}: ${r.sandCFT.toStringAsFixed(1)}\n';

    if (rates.isNotEmpty) {
      final cost = _calculateCost(r, rates);
      if (cost > 0) {
        text +=
            '\n💰 ${AppStrings.get('estimatedCost')}: ${IndianFormatter.formatCurrency(cost)}\n';
      }
    }

    text += AppStrings.get('shareFooter');
    return text;
  }

  double _calculateCost(BrickResult r, Map<String, double> rates) {
    double total = 0;
    if (rates.containsKey('brick')) {
      total += (r.brickCount / 1000) * rates['brick']!;
    }
    if (rates.containsKey('cement')) {
      total += r.cementBags * rates['cement']!;
    }
    if (rates.containsKey('sand')) {
      total += r.sandCFT * rates['sand']!;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('brick')),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                UnitToggle(
                  value: _unit,
                  onChanged: (v) => setState(() => _unit = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Length & Height
            LargeInputField(
              controller: _lengthCtrl,
              label: AppStrings.get('wallLength'),
              suffix: _unit,
            ),
            const SizedBox(height: 14),
            LargeInputField(
              controller: _heightCtrl,
              label: AppStrings.get('wallHeight'),
              suffix: _unit,
            ),
            const SizedBox(height: 20),

            // Thickness
            SectionLabel(title: AppStrings.get('wallThickness')),
            OptionChips<double>(
              options: [
                BrickCalculator.halfBrickThickness,
                BrickCalculator.fullBrickThickness,
              ],
              selected: _thickness,
              labelBuilder: (t) => t == BrickCalculator.halfBrickThickness
                  ? AppStrings.get('halfBrick')
                  : AppStrings.get('fullBrick'),
              onSelected: (v) => setState(() => _thickness = v),
            ),
            const SizedBox(height: 20),

            // Mortar Ratio
            Row(
              children: [
                SectionLabel(title: AppStrings.get('mortarRatio')),
                const SizedBox(width: 6),
                const HelpIconButton(
                  titleKey: 'mortarHelpTitle',
                  descKey: 'mortarHelpDesc',
                ),
              ],
            ),
            OptionChips<String>(
              options: const ['1:4', '1:6'],
              selected: '$_ratioC:$_ratioS',
              labelBuilder: (s) => s,
              onSelected: (v) {
                final parts = v.split(':');
                setState(() {
                  _ratioC = int.parse(parts[0]);
                  _ratioS = int.parse(parts[1]);
                });
              },
            ),
            const SizedBox(height: 28),

            // Calculate button
            CalculateButton(onPressed: _calculate),

            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final r = _result!;
    final rates = widget.storage.allRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero card — brick count
        HeroResultCard(
          label: AppStrings.get('brickCount'),
          value: IndianFormatter.format(r.brickCount.toDouble()),
          icon: Icons.view_comfy_alt_rounded,
          color: const Color(0xFFD84315),
        ),
        const SizedBox(height: 16),

        // Detail card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              ResultRow(
                label: AppStrings.get('cementBags'),
                value: r.cementBags.toStringAsFixed(1),
                icon: Icons.inventory_2_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('sandCft'),
                value: r.sandCFT.toStringAsFixed(1),
                icon: Icons.grain_outlined,
                helpWidget: const HelpIconButton(
                  titleKey: 'cftHelpTitle',
                  descKey: 'cftHelpDesc',
                ),
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('sandM3'),
                value: r.sandM3.toStringAsFixed(2),
                icon: Icons.grain_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('volume')} (m³)',
                value: r.wallVolume.toStringAsFixed(2),
                icon: Icons.straighten_outlined,
              ),
            ],
          ),
        ),

        // Cost card
        if (rates.isNotEmpty && _calculateCost(r, rates) > 0) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: _calculateCost(r, rates),
            items: [
              if (rates.containsKey('brick'))
                CostItem(
                  '🧱 ${AppStrings.get('brick')} (${IndianFormatter.format(r.brickCount.toDouble())})',
                  (r.brickCount / 1000) * rates['brick']!,
                ),
              if (rates.containsKey('cement'))
                CostItem(
                  '📦 ${AppStrings.get('cementBags')} (${r.cementBags.toStringAsFixed(1)})',
                  r.cementBags * rates['cement']!,
                ),
              if (rates.containsKey('sand'))
                CostItem(
                  '🏖️ ${AppStrings.get('sandCft')} (${r.sandCFT.toStringAsFixed(1)})',
                  r.sandCFT * rates['sand']!,
                ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Share & Copy
        ShareCopyButtons(
          onShare: () {
            Share.share(_buildShareText());
          },
          onCopy: () {
            Clipboard.setData(ClipboardData(text: _buildShareText()));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.get('copied'))),
            );
          },
        ),

        const DisclaimerFooter(),
      ],
    );
  }
}
