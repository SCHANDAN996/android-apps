import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/concrete_calculator.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class ConcreteScreen extends StatefulWidget {
  final StorageService storage;
  const ConcreteScreen({super.key, required this.storage});

  @override
  State<ConcreteScreen> createState() => _ConcreteScreenState();
}

class _ConcreteScreenState extends State<ConcreteScreen> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _depthCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  String _unit = 'ft';
  String _type = 'slab'; // slab, column, beam
  ConcreteGrade _grade = ConcreteCalculator.grades[1]; // M20 default
  ConcreteResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _depthCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final length = double.tryParse(_lengthCtrl.text);
    final width = double.tryParse(_widthCtrl.text);
    final depth = double.tryParse(_depthCtrl.text);

    if (length == null || length <= 0 || width == null || width <= 0 ||
        depth == null || depth <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('enterValue')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      if (_type == 'slab') {
        _result = ConcreteCalculator.calculateSlab(
          length: length,
          width: width,
          depth: depth,
          unit: _unit,
          grade: _grade,
        );
      } else {
        final count = int.tryParse(_countCtrl.text) ?? 1;
        _result = ConcreteCalculator.calculateColumnBeam(
          count: count,
          length: length,
          width: width,
          depth: depth,
          unit: _unit,
          grade: _grade,
        );
      }
    });

    AdService().onCalculationComplete();
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🏗️ ${AppStrings.get('concrete')} (${_grade.name})\n';
    text += '${AppStrings.get('concreteType')}: ${AppStrings.get(_type)}\n';
    text +=
        '${AppStrings.get('length')}: ${_lengthCtrl.text} $_unit\n';
    text +=
        '${AppStrings.get('width')}: ${_widthCtrl.text} $_unit\n';
    text +=
        '${AppStrings.get('depth')}: ${_depthCtrl.text} $_unit\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('cementBags')}: ${r.cementBags.toStringAsFixed(1)}\n';
    text +=
        '${AppStrings.get('sandCft')}: ${r.sandCFT.toStringAsFixed(1)}\n';
    text +=
        '${AppStrings.get('aggregateCft')}: ${r.aggregateCFT.toStringAsFixed(1)}\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  double _calculateCost(ConcreteResult r) {
    final rates = widget.storage.allRates;
    double total = 0;
    if (rates.containsKey('cement')) total += r.cementBags * rates['cement']!;
    if (rates.containsKey('sand')) total += r.sandCFT * rates['sand']!;
    if (rates.containsKey('aggregate')) {
      total += r.aggregateCFT * rates['aggregate']!;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('concrete')),
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

            // Type selector
            SectionLabel(title: AppStrings.get('concreteType')),
            OptionChips<String>(
              options: const ['slab', 'column', 'beam'],
              selected: _type,
              labelBuilder: (t) => AppStrings.get(t),
              onSelected: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 16),

            // Count (for column/beam)
            if (_type != 'slab') ...[
              LargeInputField(
                controller: _countCtrl,
                label: AppStrings.get('count'),
                allowDecimal: false,
              ),
              const SizedBox(height: 14),
            ],

            // Dimensions
            LargeInputField(
              controller: _lengthCtrl,
              label: AppStrings.get('length'),
              suffix: _unit,
            ),
            const SizedBox(height: 14),
            LargeInputField(
              controller: _widthCtrl,
              label: AppStrings.get('width'),
              suffix: _unit,
            ),
            const SizedBox(height: 14),
            LargeInputField(
              controller: _depthCtrl,
              label: AppStrings.get('depth'),
              suffix: _unit,
            ),
            const SizedBox(height: 20),

            // Grade
            Row(
              children: [
                SectionLabel(title: AppStrings.get('grade')),
                const SizedBox(width: 6),
                const HelpIconButton(
                  titleKey: 'concreteHelpTitle',
                  descKey: 'concreteHelpDesc',
                ),
              ],
            ),
            OptionChips<ConcreteGrade>(
              options: ConcreteCalculator.grades,
              selected: _grade,
              labelBuilder: (g) {
                  final s = g.sand == g.sand.roundToDouble() ? '${g.sand.toInt()}' : '${g.sand}';
                  return '${g.name} (${g.cement.toInt()}:$s:${g.aggregate.toInt()})';
                },
              onSelected: (v) => setState(() => _grade = v),
            ),
            const SizedBox(height: 28),

            // Calculate
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
    final cost = _calculateCost(r);
    final rates = widget.storage.allRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('cementBags'),
          value: r.cementBags.toStringAsFixed(1),
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF37474F),
        ),
        const SizedBox(height: 16),

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
                label: AppStrings.get('aggregateCft'),
                value: r.aggregateCFT.toStringAsFixed(1),
                icon: Icons.landscape_outlined,
                helpWidget: const HelpIconButton(
                  titleKey: 'cftHelpTitle',
                  descKey: 'cftHelpDesc',
                ),
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('aggregateM3'),
                value: r.aggregateM3.toStringAsFixed(2),
                icon: Icons.landscape_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('volume')} (m³)',
                value: r.wetVolume.toStringAsFixed(2),
                icon: Icons.straighten_outlined,
              ),
            ],
          ),
        ),

        if (rates.isNotEmpty && cost > 0) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: cost,
            items: [
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
              if (rates.containsKey('aggregate'))
                CostItem(
                  '🪨 ${AppStrings.get('aggregateCft')} (${r.aggregateCFT.toStringAsFixed(1)})',
                  r.aggregateCFT * rates['aggregate']!,
                ),
            ],
          ),
        ],

        const SizedBox(height: 16),
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
