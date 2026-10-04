import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/plaster_calculator.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/length_field.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class PlasterScreen extends StatefulWidget {
  final StorageService storage;
  const PlasterScreen({super.key, required this.storage});

  @override
  State<PlasterScreen> createState() => _PlasterScreenState();
}

class _PlasterScreenState extends State<PlasterScreen> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  String _unit = 'ft';
  String _inputMode = 'dimensions'; // 'dimensions' or 'area'
  double _thickness = PlasterCalculator.innerThickness; // 12mm default
  int _ratioC = 1;
  int _ratioS = 6;
  PlasterResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    double areaM2;

    if (_inputMode == 'area') {
      final area = double.tryParse(_areaCtrl.text);
      if (area == null || area <= 0) {
        _showError();
        return;
      }
      areaM2 = _unit == 'ft' ? UnitConverter.sqFeetToSqMeters(area) : area;
    } else {
      final length = double.tryParse(_lengthCtrl.text);
      final width = double.tryParse(_widthCtrl.text);
      if (length == null || length <= 0 || width == null || width <= 0) {
        _showError();
        return;
      }
      areaM2 = PlasterCalculator.areaFromDimensions(length, width, _unit);
    }

    setState(() {
      _result = PlasterCalculator.calculate(
        areaM2: areaM2,
        thicknessM: _thickness,
        ratioC: _ratioC,
        ratioS: _ratioS,
      );
    });

    AdService().onCalculationComplete(repeat: repeat);
  }

  void _showError() => showInputError(context);

  void _clearResult() {
    if (_result != null) setState(() => _result = null);
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    final thicknessLabel = _thickness == PlasterCalculator.innerThickness
        ? '12mm'
        : '15mm';
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🪣 ${AppStrings.get('plaster')}\n';
    text +=
        '${AppStrings.get('area')}: ${r.area.toStringAsFixed(1)} m² (${UnitConverter.sqMetersToSqFeet(r.area).toStringAsFixed(1)} sq.ft)\n';
    text += '${AppStrings.get('thickness')}: $thicknessLabel\n';
    text += '${AppStrings.get('mortarRatio')}: $_ratioC:$_ratioS\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('cementBags')}: ${r.cementBagsToBuy} (${exactNote(r.cementBags)})\n';
    text +=
        '${AppStrings.get('sandCft')}: ${r.sandCftToBuy} (${exactNote(r.sandCFT)})\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  double _calculateCost(PlasterResult r) {
    final rates = widget.storage.allRates;
    double total = 0;
    // Priced on what is actually bought — whole bags, whole CFT.
    if (rates.containsKey('cement')) {
      total += r.cementBagsToBuy * rates['cement']!;
    }
    if (rates.containsKey('sand')) total += r.sandCftToBuy * rates['sand']!;
    return total;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    final thickness = _thickness == PlasterCalculator.innerThickness
        ? '12mm'
        : '15mm';
    return ProjectItem.create(
      type: 'plaster',
      detail:
          '${UnitConverter.sqMetersToSqFeet(r.area).toStringAsFixed(0)} sq.ft · $thickness · $_ratioC:$_ratioS',
      materials: {
        ProjectMaterial.cementBags: r.cementBags,
        ProjectMaterial.sandCft: r.sandCFT,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('plaster'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('plaster'),
              imageAsset: 'assets/images/plaster_thickness_reference.webp',
              color: const Color(0xFF00695C),
              imageWidth: 112,
            ),
            const SizedBox(height: 12),
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
                  const SizedBox(height: 16),

                  // Input mode
                  OptionChips<String>(
                    options: const ['dimensions', 'area'],
                    selected: _inputMode,
                    labelBuilder: (m) => m == 'dimensions'
                        ? '${AppStrings.get('length')} × ${AppStrings.get('width')}'
                        : AppStrings.get('area'),
                    onSelected: (v) => setState(() {
                      _inputMode = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  if (_inputMode == 'dimensions') ...[
                    LengthField(
                      controller: _lengthCtrl,
                      label: AppStrings.get('length'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                    const SizedBox(height: 14),
                    LengthField(
                      controller: _widthCtrl,
                      label: AppStrings.get('height'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                  ] else ...[
                    LargeInputField(
                      controller: _areaCtrl,
                      label:
                          '${AppStrings.get('area')} (${_unit == 'ft' ? AppStrings.get('sqft') : AppStrings.get('sqm')})',
                      suffix: _unit == 'ft' ? 'sq.ft' : 'm²',
                      onChanged: (_) => _clearResult(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Thickness
                  SectionLabel(title: AppStrings.get('plasterThickness')),
                  VisualChoiceGrid<double>(
                    options: [
                      PlasterCalculator.innerThickness,
                      PlasterCalculator.outerThickness,
                    ],
                    selected: _thickness,
                    labelBuilder: (t) => t == PlasterCalculator.innerThickness
                        ? AppStrings.get('inner12mm')
                        : AppStrings.get('outer15mm'),
                    imageAssetBuilder: (t) =>
                        t == PlasterCalculator.innerThickness
                        ? 'assets/images/plaster_thin.webp'
                        : 'assets/images/plaster_thick.webp',
                    compact: true,
                    onSelected: (v) => setState(() {
                      _thickness = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Mortar Ratio
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
                        _result = null;
                      });
                    },
                  ),
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
    final cost = _calculateCost(r);
    final rates = widget.storage.allRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('cementBags'),
          value: '${r.cementBagsToBuy}',
          countTo: r.cementBagsToBuy.toDouble(),
          countFormat: (v) => '${v.round()}',
          caption: exactNote(r.cementBags),
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF00695C),
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
                value: '${r.sandCftToBuy}',
                note: exactNote(r.sandCFT),
                icon: Icons.grain_outlined,
                helpWidget: const HelpIconButton(
                  titleKey: 'cftHelpTitle',
                  descKey: 'cftHelpDesc',
                ),
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('sandM3'),
                value: r.sandM3.toStringAsFixed(3),
                icon: Icons.grain_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('area')} (m²)',
                value: r.area.toStringAsFixed(1),
                icon: Icons.square_foot_outlined,
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
                  '📦 ${AppStrings.get('cementBags')} (${r.cementBagsToBuy})',
                  r.cementBagsToBuy * rates['cement']!,
                ),
              if (rates.containsKey('sand'))
                CostItem(
                  '🏖️ ${AppStrings.get('sandCft')} (${r.sandCftToBuy})',
                  r.sandCftToBuy * rates['sand']!,
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
