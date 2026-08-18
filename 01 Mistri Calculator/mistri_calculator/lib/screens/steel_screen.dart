import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/steel_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class SteelScreen extends StatefulWidget {
  final StorageService storage;
  const SteelScreen({super.key, required this.storage});

  @override
  State<SteelScreen> createState() => _SteelScreenState();
}

class _SteelScreenState extends State<SteelScreen> {
  final _lengthCtrl = TextEditingController();
  final _rodCtrl = TextEditingController();
  final _slabVolCtrl = TextEditingController();
  int _diameter = 12; // default 12mm
  String _mode = 'manual'; // 'manual' or 'slab'
  String _inputType = 'length'; // 'length' or 'rods'
  SteelResult? _result;

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _rodCtrl.dispose();
    _slabVolCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_mode == 'slab') {
      final vol = double.tryParse(_slabVolCtrl.text);
      if (vol == null || vol <= 0) {
        _showError();
        return;
      }
      setState(() {
        _result = SteelCalculator.calculateBySlab(slabVolumeM3: vol);
      });
    } else if (_inputType == 'rods') {
      final rods = int.tryParse(_rodCtrl.text);
      if (rods == null || rods <= 0) {
        _showError();
        return;
      }
      setState(() {
        _result = SteelCalculator.calculateByRods(
          diameterMm: _diameter,
          rodCount: rods,
        );
      });
    } else {
      final length = double.tryParse(_lengthCtrl.text);
      if (length == null || length <= 0) {
        _showError();
        return;
      }
      setState(() {
        _result = SteelCalculator.calculateByLength(
          diameterMm: _diameter,
          totalLengthM: length,
        );
      });
    }

    AdService().onCalculationComplete();
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('enterValue')),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '⚙️ ${AppStrings.get('steel')}\n';
    if (_mode == 'manual') {
      text += '${AppStrings.get('diameter')}: ${_diameter}mm\n';
      if (_inputType == 'rods') {
        text += '${AppStrings.get('rodCount')}: ${_rodCtrl.text}\n';
      } else {
        text += '${AppStrings.get('totalLength')}: ${_lengthCtrl.text} m\n';
      }
    } else {
      text += '${AppStrings.get('slabVolume')}: ${_slabVolCtrl.text} m³\n';
    }
    text += '\n📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('steelWeight')}: ${r.weightKg.toStringAsFixed(1)} kg\n';

    final rates = widget.storage.allRates;
    if (rates.containsKey('steel')) {
      final cost = r.weightKg * rates['steel']!;
      text +=
          '\n💰 ${AppStrings.get('estimatedCost')}: ${IndianFormatter.formatCurrency(cost)}\n';
    }

    text += AppStrings.get('shareFooter');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('steel')),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector
            Row(
              children: [
                Expanded(
                  child: OptionChips<String>(
                    options: const ['manual', 'slab'],
                    selected: _mode,
                    labelBuilder: (m) =>
                        m == 'manual' ? AppStrings.get('manualMode') : AppStrings.get('slabMode'),
                    onSelected: (v) => setState(() {
                      _mode = v;
                      _result = null;
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                const HelpIconButton(
                  titleKey: 'steelHelpTitle',
                  descKey: 'steelHelpDesc',
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_mode == 'manual') ...[
              // Diameter
              SectionLabel(title: AppStrings.get('diameter')),
              OptionChips<int>(
                options: SteelCalculator.diameters,
                selected: _diameter,
                labelBuilder: (d) => '${d}mm',
                onSelected: (v) => setState(() => _diameter = v),
              ),
              const SizedBox(height: 20),

              // Input type toggle
              OptionChips<String>(
                options: const ['length', 'rods'],
                selected: _inputType,
                labelBuilder: (t) => t == 'length'
                    ? '${AppStrings.get('totalLength')} (m)'
                    : AppStrings.get('rodCount'),
                onSelected: (v) => setState(() => _inputType = v),
              ),
              const SizedBox(height: 16),

              if (_inputType == 'length')
                LargeInputField(
                  controller: _lengthCtrl,
                  label: '${AppStrings.get('totalLength')} (m)',
                  suffix: 'm',
                )
              else
                LargeInputField(
                  controller: _rodCtrl,
                  label: AppStrings.get('rodCount'),
                  allowDecimal: false,
                ),
            ] else ...[
              // Slab quick mode
              LargeInputField(
                controller: _slabVolCtrl,
                label: AppStrings.get('slabVolume'),
                suffix: 'm³',
              ),
            ],

            const SizedBox(height: 28),
            CalculateButton(onPressed: _calculate),

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
        HeroResultCard(
          label: AppStrings.get('steelWeight'),
          value: '${r.weightKg.toStringAsFixed(1)} kg',
          icon: Icons.straighten_rounded,
          color: const Color(0xFF4527A0),
        ),

        if (_mode == 'manual') ...[
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
                  label: AppStrings.get('diameter'),
                  value: '${_diameter}mm',
                  icon: Icons.circle_outlined,
                ),
                const Divider(height: 1),
                ResultRow(
                  label: 'kg/m',
                  value: r.weightPerMeter.toStringAsFixed(3),
                  icon: Icons.speed_outlined,
                ),
                const Divider(height: 1),
                ResultRow(
                  label: AppStrings.get('totalLength'),
                  value: '${r.totalLength.toStringAsFixed(1)} m',
                  icon: Icons.straighten_outlined,
                ),
              ],
            ),
          ),
        ],

        if (rates.containsKey('steel')) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: r.weightKg * rates['steel']!,
            items: [
              CostItem(
                '⚙️ ${AppStrings.get('steel')} (${r.weightKg.toStringAsFixed(1)} kg)',
                r.weightKg * rates['steel']!,
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
