import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/concrete_calculator.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/length_field.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';
import 'steel_screen.dart';

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
  ConcreteGrade _grade = ConcreteCalculator.m20;
  ConcreteResult? _result;

  /// Inches (or mm) — slab thickness and column/beam cross-section are never
  /// measured in feet on site.
  String get _smallUnit => UnitConverter.smallUnit(_unit);

  /// A slab's width is a room dimension; a column's or beam's is its section.
  String get _widthUnit => _type == 'slab' ? _unit : _smallUnit;

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
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    final length = double.tryParse(_lengthCtrl.text);
    final width = double.tryParse(_widthCtrl.text);
    final depth = double.tryParse(_depthCtrl.text);

    if (length == null ||
        length <= 0 ||
        width == null ||
        width <= 0 ||
        depth == null ||
        depth <= 0) {
      showInputError(context);
      return;
    }

    final count = _type == 'slab' ? null : int.tryParse(_countCtrl.text);
    if (_type != 'slab' && (count == null || count <= 0)) {
      showInputError(context);
      return;
    }

    final depthM = UnitConverter.smallToMeters(depth, _unit);

    setState(() {
      if (_type == 'slab') {
        _result = ConcreteCalculator.calculateSlab(
          length: length,
          width: width,
          thicknessM: depthM,
          unit: _unit,
          grade: _grade,
        );
      } else {
        _result = ConcreteCalculator.calculateColumnBeam(
          count: count!,
          length: length,
          widthM: UnitConverter.smallToMeters(width, _unit),
          depthM: depthM,
          unit: _unit,
          grade: _grade,
        );
      }
    });

    AdService().onCalculationComplete(repeat: repeat);
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🏗️ ${AppStrings.get('concrete')} (${_grade.name})\n';
    text += '${AppStrings.get('concreteType')}: ${AppStrings.get(_type)}\n';
    text +=
        '${AppStrings.get('length')}: ${lengthLabel(_lengthCtrl.text, _unit)}\n';
    text +=
        '${AppStrings.get('width')}: ${lengthLabel(_widthCtrl.text, _widthUnit)}\n';
    text += '${AppStrings.get('depth')}: ${_depthCtrl.text} $_smallUnit\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('cementBags')}: ${r.cementBagsToBuy} (${exactNote(r.cementBags)})\n';
    text +=
        '${AppStrings.get('sandCft')}: ${r.sandCftToBuy} (${exactNote(r.sandCFT)})\n';
    text +=
        '${AppStrings.get('aggregateCft')}: ${r.aggregateCftToBuy} (${exactNote(r.aggregateCFT)})\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  double _calculateCost(ConcreteResult r) {
    final rates = widget.storage.allRates;
    double total = 0;
    // Priced on what is actually bought — whole bags, whole CFT.
    if (rates.containsKey('cement')) {
      total += r.cementBagsToBuy * rates['cement']!;
    }
    if (rates.containsKey('sand')) total += r.sandCftToBuy * rates['sand']!;
    if (rates.containsKey('aggregate')) {
      total += r.aggregateCftToBuy * rates['aggregate']!;
    }
    return total;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    final count = _type == 'slab' ? '' : '${_countCtrl.text} × ';
    return ProjectItem.create(
      type: 'concrete',
      detail:
          '${AppStrings.get(_type)} ${_grade.name} · $count${lengthLabel(_lengthCtrl.text, _unit)} × ${lengthLabel(_widthCtrl.text, _widthUnit)} × ${_depthCtrl.text} $_smallUnit',
      materials: {
        ProjectMaterial.cementBags: r.cementBags,
        ProjectMaterial.sandCft: r.sandCFT,
        ProjectMaterial.aggregateCft: r.aggregateCFT,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('concrete'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('concrete'),
              imageAsset: 'assets/images/concrete_forms_reference.webp',
              color: const Color(0xFF37474F),
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

                  // Type selector
                  SectionLabel(title: AppStrings.get('concreteType')),
                  VisualChoiceGrid<String>(
                    options: const ['slab', 'column', 'beam'],
                    selected: _type,
                    labelBuilder: (t) => AppStrings.get(t),
                    imageAssetBuilder: (t) => switch (t) {
                      'slab' => 'assets/images/concrete_form_slab.webp',
                      'column' => 'assets/images/concrete_form_column.webp',
                      _ => 'assets/images/concrete_form_beam.webp',
                    },
                    columns: 3,
                    compact: true,
                    onSelected: (v) => setState(() {
                      // "Width" is feet for a slab but inches for a column or
                      // beam — a typed 12 must not silently change meaning.
                      if ((v == 'slab') != (_type == 'slab')) {
                        _widthCtrl.clear();
                      }
                      // A lean PCC mix must not follow into a column or beam.
                      if (v != 'slab' &&
                          !ConcreteCalculator.structuralGrades.contains(
                            _grade,
                          )) {
                        _grade = ConcreteCalculator.m20;
                      }
                      _type = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Count (for column/beam)
                  if (_type != 'slab') ...[
                    LargeInputField(
                      controller: _countCtrl,
                      label: AppStrings.get('count'),
                      allowDecimal: false,
                      onChanged: (_) => setState(() => _result = null),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Dimensions
                  LengthField(
                    controller: _lengthCtrl,
                    label: AppStrings.get('length'),
                    unit: _unit,
                    onChanged: (_) => setState(() => _result = null),
                  ),
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _widthCtrl,
                    label: AppStrings.get('width'),
                    unit: _widthUnit,
                    onChanged: (_) => setState(() => _result = null),
                  ),
                  const SizedBox(height: 14),
                  LargeInputField(
                    controller: _depthCtrl,
                    label: AppStrings.get('depth'),
                    suffix: _smallUnit,
                    onChanged: (_) => setState(() => _result = null),
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
                    options: _type == 'slab'
                        ? ConcreteCalculator.grades
                        : ConcreteCalculator.structuralGrades,
                    selected: _grade,
                    labelBuilder: (g) {
                      final s = g.sand == g.sand.roundToDouble()
                          ? '${g.sand.toInt()}'
                          : '${g.sand}';
                      return '${g.name} (${g.cement.toInt()}:$s:${g.aggregate.toInt()})';
                    },
                    onSelected: (v) => setState(() {
                      _grade = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Calculate
                  CalculateButton(onPressed: _calculate),
                ],
              ),
            ),

            // Results
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
                value: r.sandM3.toStringAsFixed(2),
                icon: Icons.grain_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('aggregateCft'),
                value: '${r.aggregateCftToBuy}',
                note: exactNote(r.aggregateCFT),
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
                  '📦 ${AppStrings.get('cementBags')} (${r.cementBagsToBuy})',
                  r.cementBagsToBuy * rates['cement']!,
                ),
              if (rates.containsKey('sand'))
                CostItem(
                  '🏖️ ${AppStrings.get('sandCft')} (${r.sandCftToBuy})',
                  r.sandCftToBuy * rates['sand']!,
                ),
              if (rates.containsKey('aggregate'))
                CostItem(
                  '🪨 ${AppStrings.get('aggregateCft')} (${r.aggregateCftToBuy})',
                  r.aggregateCftToBuy * rates['aggregate']!,
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
        // The quick steel estimate is a slab rule of thumb, so the shortcut
        // is not offered for columns and beams.
        if (_type == 'slab') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SteelScreen(
                    storage: widget.storage,
                    initialSlabVolumeM3: r.wetVolume,
                    initialUnit: _unit,
                  ),
                ),
              ),
              icon: const Icon(Icons.straighten_rounded),
              label: Text(
                AppStrings.get('steelForThis'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4527A0),
                side: const BorderSide(color: Color(0xFF4527A0)),
              ),
            ),
          ),
        ],
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
