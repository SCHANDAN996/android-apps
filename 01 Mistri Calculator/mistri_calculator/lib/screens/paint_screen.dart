import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/paint_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/length_field.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class PaintScreen extends StatefulWidget {
  final StorageService storage;
  const PaintScreen({super.key, required this.storage});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final _areaCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _unit = 'ft';
  String _inputMode = 'room'; // 'room' or 'area'
  int _coats = 2;
  PaintResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    if (_inputMode == 'area') {
      final area = double.tryParse(_areaCtrl.text);
      if (area == null || area <= 0) {
        _showError();
        return;
      }
      final areaM2 = _unit == 'ft'
          ? UnitConverter.sqFeetToSqMeters(area)
          : area;
      setState(() {
        _result = PaintCalculator.calculateByArea(
          areaM2: areaM2,
          coats: _coats,
        );
      });
    } else {
      final l = double.tryParse(_lengthCtrl.text);
      final w = double.tryParse(_widthCtrl.text);
      final h = double.tryParse(_heightCtrl.text);
      if (l == null || l <= 0 || w == null || w <= 0 || h == null || h <= 0) {
        _showError();
        return;
      }
      setState(() {
        _result = PaintCalculator.calculateByRoom(
          length: l,
          width: w,
          height: h,
          unit: _unit,
          coats: _coats,
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
    text += '🎨 ${AppStrings.get('paint')}\n';
    text +=
        '${AppStrings.get('area')}: ${r.areaM2.toStringAsFixed(1)} m² (${UnitConverter.sqMetersToSqFeet(r.areaM2).toStringAsFixed(1)} sq.ft)\n';
    text += '${AppStrings.get('coats')}: ${r.coats}\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('paintLitres')}: ${r.totalLitres.toStringAsFixed(1)}\n';
    text +=
        '${AppStrings.get('primer')}: ${r.primerLitres.toStringAsFixed(1)} L\n';
    text += '${AppStrings.get('putty')}: ${r.puttyKg.toStringAsFixed(0)} kg\n';
    text += '${AppStrings.get('bucketSuggestion')}: ';
    text += r.bucketSuggestion.entries
        .map((e) => '${e.value} × ${e.key}')
        .join(' + ');
    text += '\n';

    final rates = widget.storage.allRates;
    if (rates.containsKey('paint')) {
      final cost = r.totalLitres * rates['paint']!;
      text +=
          '\n💰 ${AppStrings.get('estimatedCost')}: ${IndianFormatter.formatCurrency(cost)}\n';
    }

    text += AppStrings.get('shareFooter');
    return text;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    return ProjectItem.create(
      type: 'paint',
      detail:
          '${UnitConverter.sqMetersToSqFeet(r.areaM2).toStringAsFixed(0)} sq.ft · ${AppStrings.get('coats')}: ${r.coats}',
      materials: {ProjectMaterial.paintLitres: r.totalLitres},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('paint'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('paint'),
              imageAsset: 'assets/images/paint_coats_reference.webp',
              color: const Color(0xFFC62828),
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
                    options: const ['room', 'area'],
                    selected: _inputMode,
                    labelBuilder: (m) => m == 'room'
                        ? AppStrings.get('roomDimensions')
                        : AppStrings.get('manualArea'),
                    onSelected: (v) => setState(() {
                      _inputMode = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  if (_inputMode == 'room') ...[
                    LengthField(
                      controller: _lengthCtrl,
                      label: AppStrings.get('length'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                    const SizedBox(height: 14),
                    LengthField(
                      controller: _widthCtrl,
                      label: AppStrings.get('width'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                    const SizedBox(height: 14),
                    LengthField(
                      controller: _heightCtrl,
                      label: AppStrings.get('height'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                  ] else ...[
                    LargeInputField(
                      controller: _areaCtrl,
                      label:
                          '${AppStrings.get('wallArea')} (${_unit == 'ft' ? 'sq.ft' : 'm²'})',
                      suffix: _unit == 'ft' ? 'sq.ft' : 'm²',
                      onChanged: (_) => _clearResult(),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Coats
                  Row(
                    children: [
                      SectionLabel(title: AppStrings.get('coats')),
                      const SizedBox(width: 6),
                      const HelpIconButton(
                        titleKey: 'paintHelpTitle',
                        descKey: 'paintHelpDesc',
                      ),
                    ],
                  ),
                  VisualChoiceGrid<int>(
                    options: const [1, 2, 3],
                    selected: _coats,
                    labelBuilder: (c) => '$c',
                    imageAssetBuilder: (c) =>
                        'assets/images/paint_coat_$c.webp',
                    columns: 3,
                    compact: true,
                    onSelected: (v) => setState(() {
                      _coats = v;
                      _result = null;
                    }),
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
    final rates = widget.storage.allRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('paintLitres'),
          value: '${r.totalLitres.toStringAsFixed(1)} L',
          countTo: r.totalLitres,
          countFormat: (v) => '${v.toStringAsFixed(1)} L',
          icon: Icons.color_lens_rounded,
          color: const Color(0xFFC62828),
        ),
        const SizedBox(height: 16),

        // Bucket suggestion
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.get('bucketSuggestion'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const HelpIconButton(
                    titleKey: 'paintHelpTitle',
                    descKey: 'paintHelpDesc',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: r.bucketSuggestion.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${entry.value} × ${entry.key}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ResultRow(
                label: '${AppStrings.get('area')} (m²)',
                value: r.areaM2.toStringAsFixed(1),
                icon: Icons.square_foot_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('coats'),
                value: '${r.coats}',
                icon: Icons.layers_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('primer'),
                value: '${r.primerLitres.toStringAsFixed(1)} L',
                icon: Icons.format_paint_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('putty'),
                value: '${r.puttyKg.toStringAsFixed(0)} kg',
                icon: Icons.texture_outlined,
              ),
            ],
          ),
        ),

        if (rates.containsKey('paint')) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: r.totalLitres * rates['paint']!,
            items: [
              CostItem(
                '🎨 ${AppStrings.get('paintLitres')} (${r.totalLitres.toStringAsFixed(1)} L)',
                r.totalLitres * rates['paint']!,
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
