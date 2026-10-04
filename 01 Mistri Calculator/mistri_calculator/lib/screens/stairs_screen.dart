import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/strings.dart';
import '../core/math/concrete_calculator.dart';
import '../core/math/extra_calculators.dart';
import '../core/models/project_item.dart';
import '../core/services/ad_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/add_to_project_button.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/length_field.dart';
import '../widgets/shared_widgets.dart';

/// A straight RCC staircase: how many steps, and the concrete for them.
class StairsScreen extends StatefulWidget {
  final StorageService storage;
  const StairsScreen({super.key, required this.storage});

  @override
  State<StairsScreen> createState() => _StairsScreenState();
}

class _StairsScreenState extends State<StairsScreen> {
  static const Color _color = Color(0xFF5D4037);

  final _heightCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _riserCtrl = TextEditingController();
  final _treadCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  String _unit = 'ft';
  ConcreteGrade _grade = ConcreteCalculator.m20;
  StairsResult? _result;

  String get _smallUnit => UnitConverter.smallUnit(_unit);

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
    _fillUsualSizes();
  }

  /// The sizes most houses are built with — 7 inch riser, 10 inch tread,
  /// 5 inch slab — so the user only has to type the height and the width.
  void _fillUsualSizes() {
    final inch = _unit == 'ft';
    _riserCtrl.text = inch ? '7' : '175';
    _treadCtrl.text = inch ? '10' : '250';
    _waistCtrl.text = inch ? '5' : '125';
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _widthCtrl.dispose();
    _riserCtrl.dispose();
    _treadCtrl.dispose();
    _waistCtrl.dispose();
    super.dispose();
  }

  void _clearResult() {
    if (_result != null) setState(() => _result = null);
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    double? positive(TextEditingController c) {
      final v = double.tryParse(c.text);
      return v != null && v > 0 ? v : null;
    }

    final height = positive(_heightCtrl);
    final width = positive(_widthCtrl);
    final riser = positive(_riserCtrl);
    final tread = positive(_treadCtrl);
    final waist = positive(_waistCtrl);
    if (height == null ||
        width == null ||
        riser == null ||
        tread == null ||
        waist == null) {
      showInputError(context);
      return;
    }

    setState(() {
      _result = StairsCalculator.calculate(
        heightM: UnitConverter.toMeters(height, _unit),
        widthM: UnitConverter.toMeters(width, _unit),
        riserM: UnitConverter.smallToMeters(riser, _unit),
        treadM: UnitConverter.smallToMeters(tread, _unit),
        waistM: UnitConverter.smallToMeters(waist, _unit),
        grade: _grade,
      );
    });
    AdService().onCalculationComplete(repeat: repeat);
  }

  /// The riser that actually gets built, in the unit on screen.
  String _riserText(StairsResult r) => _unit == 'ft'
      ? '${(r.riserM / 0.0254).toStringAsFixed(1)} in'
      : '${(r.riserM * 1000).round()} mm';

  String _goingText(StairsResult r) => _unit == 'ft'
      ? lengthLabel(UnitConverter.metersToFeet(r.goingM).toString(), 'ft')
      : '${r.goingM.toStringAsFixed(2)} m';

  double _cost(ConcreteResult c) {
    final rates = widget.storage.allRates;
    double total = 0;
    if (rates.containsKey('cement')) {
      total += c.cementBagsToBuy * rates['cement']!;
    }
    if (rates.containsKey('sand')) total += c.sandCftToBuy * rates['sand']!;
    if (rates.containsKey('aggregate')) {
      total += c.aggregateCftToBuy * rates['aggregate']!;
    }
    return total;
  }

  String get _inputLine =>
      '${lengthLabel(_heightCtrl.text, _unit)} × ${lengthLabel(_widthCtrl.text, _unit)}';

  String _buildShareText() {
    final r = _result!;
    final c = r.concrete;
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🪜 ${AppStrings.get('stairs')} (${_grade.name})\n';
    text +=
        '${AppStrings.get('floorHeight')}: ${lengthLabel(_heightCtrl.text, _unit)}\n';
    text +=
        '${AppStrings.get('stairWidth')}: ${lengthLabel(_widthCtrl.text, _unit)}\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text += '${AppStrings.get('steps')}: ${r.steps}\n';
    text += '${AppStrings.get('riser')}: ${_riserText(r)}\n';
    text +=
        '${AppStrings.get('cementBags')}: ${c.cementBagsToBuy} (${exactNote(c.cementBags)})\n';
    text +=
        '${AppStrings.get('sandCft')}: ${c.sandCftToBuy} (${exactNote(c.sandCFT)})\n';
    text +=
        '${AppStrings.get('aggregateCft')}: ${c.aggregateCftToBuy} (${exactNote(c.aggregateCFT)})\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    return ProjectItem.create(
      type: 'stairs',
      detail: '$_inputLine · ${r.steps} · ${_grade.name}',
      materials: {
        ProjectMaterial.cementBags: r.concrete.cementBags,
        ProjectMaterial.sandCft: r.concrete.sandCFT,
        ProjectMaterial.aggregateCft: r.concrete.aggregateCFT,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('stairs'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      UnitToggle(
                        value: _unit,
                        onChanged: (v) => setState(() {
                          _unit = v;
                          _fillUsualSizes();
                          _result = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LengthField(
                    controller: _heightCtrl,
                    label: AppStrings.get('floorHeight'),
                    unit: _unit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _widthCtrl,
                    label: AppStrings.get('stairWidth'),
                    unit: _unit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
                  LargeInputField(
                    controller: _riserCtrl,
                    label: AppStrings.get('riser'),
                    suffix: _smallUnit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
                  LargeInputField(
                    controller: _treadCtrl,
                    label: AppStrings.get('tread'),
                    suffix: _smallUnit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
                  LargeInputField(
                    controller: _waistCtrl,
                    label: AppStrings.get('waist'),
                    suffix: _smallUnit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 20),
                  SectionLabel(title: AppStrings.get('grade')),
                  OptionChips<ConcreteGrade>(
                    options: ConcreteCalculator.structuralGrades,
                    selected: _grade,
                    labelBuilder: (g) => g.name,
                    onSelected: (v) => setState(() {
                      _grade = v;
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
    final c = r.concrete;
    final rates = widget.storage.allRates;
    final cost = _cost(c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('steps'),
          value: '${r.steps}',
          countTo: r.steps.toDouble(),
          countFormat: (v) => '${v.round()}',
          caption: '${AppStrings.get('riser')}: ${_riserText(r)}',
          icon: Icons.stairs_rounded,
          color: _color,
        ),
        const SizedBox(height: 16),
        FormSurface(
          child: Column(
            children: [
              ResultRow(
                label: AppStrings.get('length'),
                value: _goingText(r),
                icon: Icons.straighten_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('cementBags'),
                value: '${c.cementBagsToBuy}',
                note: exactNote(c.cementBags),
                icon: Icons.inventory_2_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('sandCft'),
                value: '${c.sandCftToBuy}',
                note: exactNote(c.sandCFT),
                icon: Icons.grain_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('aggregateCft'),
                value: '${c.aggregateCftToBuy}',
                note: exactNote(c.aggregateCFT),
                icon: Icons.landscape_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('volume')} (m³)',
                value: c.wetVolume.toStringAsFixed(2),
                icon: Icons.view_in_ar_outlined,
              ),
            ],
          ),
        ),
        if (cost > 0) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: cost,
            items: [
              if (rates.containsKey('cement'))
                CostItem(
                  '📦 ${AppStrings.get('cementBags')} (${c.cementBagsToBuy})',
                  c.cementBagsToBuy * rates['cement']!,
                ),
              if (rates.containsKey('sand'))
                CostItem(
                  '🏖️ ${AppStrings.get('sandCft')} (${c.sandCftToBuy})',
                  c.sandCftToBuy * rates['sand']!,
                ),
              if (rates.containsKey('aggregate'))
                CostItem(
                  '🪨 ${AppStrings.get('aggregateCft')} (${c.aggregateCftToBuy})',
                  c.aggregateCftToBuy * rates['aggregate']!,
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
