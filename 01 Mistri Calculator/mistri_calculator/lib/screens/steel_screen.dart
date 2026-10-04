import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/steel_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class SteelScreen extends StatefulWidget {
  final StorageService storage;

  /// Opened from a concrete result: start in slab mode with this volume
  /// already filled in, in [initialUnit].
  final double? initialSlabVolumeM3;
  final String? initialUnit;

  const SteelScreen({
    super.key,
    required this.storage,
    this.initialSlabVolumeM3,
    this.initialUnit,
  });

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
  String _unit = 'ft';
  SteelResult? _result;

  /// Slab volume is spoken in CFT by anyone who measures in feet.
  String get _volumeUnit => _unit == 'ft' ? 'cft' : 'm³';

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit ?? widget.storage.defaultUnit;
    final volume = widget.initialSlabVolumeM3;
    if (volume != null) {
      _mode = 'slab';
      _slabVolCtrl.text =
          (_unit == 'ft' ? UnitConverter.cubicMetersToCFT(volume) : volume)
              .toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _rodCtrl.dispose();
    _slabVolCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    if (_mode == 'slab') {
      final vol = double.tryParse(_slabVolCtrl.text);
      if (vol == null || vol <= 0) {
        _showError();
        return;
      }
      setState(() {
        _result = SteelCalculator.calculateBySlab(
          slabVolumeM3: _unit == 'ft'
              ? UnitConverter.cftToCubicMeters(vol)
              : vol,
        );
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
          totalLengthM: UnitConverter.toMeters(length, _unit),
        );
      });
    }

    AdService().onCalculationComplete(repeat: repeat);
  }

  void _showError() => showInputError(context);

  void _clearResult() {
    if (_result != null) setState(() => _result = null);
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
        text +=
            '${AppStrings.get('totalLength')}: ${_lengthCtrl.text} $_unit\n';
      }
    } else {
      text +=
          '${AppStrings.get('slabVolume')}: ${_slabVolCtrl.text} $_volumeUnit\n';
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

  ProjectItem _projectItem() {
    final String detail;
    if (_mode == 'slab') {
      detail =
          '${AppStrings.get('slabVolume')}: ${_slabVolCtrl.text} $_volumeUnit';
    } else if (_inputType == 'rods') {
      detail = '${_diameter}mm · ${_rodCtrl.text} × 12 m';
    } else {
      detail = '${_diameter}mm · ${_lengthCtrl.text} $_unit';
    }
    return ProjectItem.create(
      type: 'steel',
      detail: detail,
      materials: {ProjectMaterial.steelKg: _result!.weightKg},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('steel'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('steel'),
              imageAsset: 'assets/images/steel_diameters_reference.webp',
              color: const Color(0xFF4527A0),
              imageWidth: 112,
            ),
            const SizedBox(height: 16),
            FormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UnitToggle(
                        value: _unit,
                        onChanged: (v) => setState(() {
                          _unit = v;
                          _result = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mode selector
                  Row(
                    children: const [
                      SectionLabel(title: 'Mode'),
                      SizedBox(width: 6),
                      HelpIconButton(
                        titleKey: 'steelHelpTitle',
                        descKey: 'steelHelpDesc',
                      ),
                    ],
                  ),
                  OptionChips<String>(
                    options: const ['manual', 'slab'],
                    selected: _mode,
                    labelBuilder: (m) => m == 'manual'
                        ? AppStrings.get('manualMode')
                        : AppStrings.get('slabMode'),
                    onSelected: (v) => setState(() {
                      _mode = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 20),

                  if (_mode == 'manual') ...[
                    // Diameter
                    SectionLabel(title: AppStrings.get('diameter')),
                    OptionChips<int>(
                      options: SteelCalculator.diameters,
                      selected: _diameter,
                      labelBuilder: (d) => '${d}mm',
                      onSelected: (v) => setState(() {
                        _diameter = v;
                        _result = null;
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Input type toggle
                    OptionChips<String>(
                      options: const ['length', 'rods'],
                      selected: _inputType,
                      labelBuilder: (t) => t == 'length'
                          ? '${AppStrings.get('totalLength')} ($_unit)'
                          : AppStrings.get('rodCount'),
                      onSelected: (v) => setState(() {
                        _inputType = v;
                        _result = null;
                      }),
                    ),
                    const SizedBox(height: 16),

                    if (_inputType == 'length')
                      LargeInputField(
                        controller: _lengthCtrl,
                        label: AppStrings.get('totalLength'),
                        suffix: _unit,
                        onChanged: (_) => _clearResult(),
                      )
                    else
                      LargeInputField(
                        controller: _rodCtrl,
                        label: AppStrings.get('rodCount'),
                        allowDecimal: false,
                        onChanged: (_) => _clearResult(),
                      ),
                  ] else ...[
                    // Slab quick mode
                    LargeInputField(
                      controller: _slabVolCtrl,
                      label: AppStrings.get('slabVolume'),
                      suffix: _volumeUnit,
                      onChanged: (_) => _clearResult(),
                    ),
                  ],

                  const SizedBox(height: 28),
                  CalculateButton(onPressed: _calculate),
                ],
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              ResultReveal(child: _buildResults()),
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
          countTo: r.weightKg,
          countFormat: (v) => '${v.toStringAsFixed(1)} kg',
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
                  value: _unit == 'ft'
                      ? '${UnitConverter.metersToFeet(r.totalLength).toStringAsFixed(1)} ft'
                      : '${r.totalLength.toStringAsFixed(1)} m',
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(AppStrings.get('copied'))));
          },
        ),
        const SizedBox(height: 12),
        AddToProjectButton(
          storage: widget.storage,
          result: r,
          buildItem: _projectItem,
        ),
        const DisclaimerFooter(),
      ],
    );
  }
}
