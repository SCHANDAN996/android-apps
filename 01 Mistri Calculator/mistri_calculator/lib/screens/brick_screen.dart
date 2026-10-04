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
import '../widgets/length_field.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
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
  final _brickLenCtrl = TextEditingController();
  final _brickWidCtrl = TextEditingController();
  final _brickHgtCtrl = TextEditingController();
  String _unit = 'ft';
  BrickSize _brick = BrickCalculator.defaultBrick;

  /// Brick size entry unit for the custom fields: 'in' or 'mm'.
  String _brickUnit = 'in';

  /// true = half-brick wall, false = full-brick wall. The actual thickness
  /// comes from the selected brick, so it follows the size the user picks.
  bool _halfWall = false;
  int _ratioC = 1;
  int _ratioS = 6; // 1:6 default
  BrickResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
    _brick = widget.storage.brickSize;
    final saved = widget.storage.customBrickSize;
    if (saved != null) _fillCustomFields(saved);
  }

  /// Writes a size into the three fields, converted to the unit on screen.
  void _fillCustomFields(BrickSize size) {
    final f = _brickUnit == 'in' ? BrickSize.mmPerInch : 1.0;
    _brickLenCtrl.text = _fmtMm(size.lengthMm / f);
    _brickWidCtrl.text = _fmtMm(size.widthMm / f);
    _brickHgtCtrl.text = _fmtMm(size.heightMm / f);
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _heightCtrl.dispose();
    _brickLenCtrl.dispose();
    _brickWidCtrl.dispose();
    _brickHgtCtrl.dispose();
    super.dispose();
  }

  static String _fmtMm(double v) {
    final rounded = (v * 10).roundToDouble() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
  }

  /// Wall thickness for the current brick and half/full choice.
  double get _thickness =>
      _halfWall ? _brick.halfWallThicknessM : _brick.fullWallThicknessM;

  /// Just the measurement, in inches — e.g. `4.3"`.
  String _wallMeasure(bool half) {
    final m = half ? _brick.halfWallThicknessM : _brick.fullWallThicknessM;
    return '${BrickSize.formatInches(m * 1000 / BrickSize.mmPerInch)}"';
  }

  /// Name plus measurement, for the shared text where there is no picture.
  String _wallLabel(bool half) {
    final name = AppStrings.get(half ? 'halfBrickShort' : 'fullBrickShort');
    return '$name - ${_wallMeasure(half)}';
  }

  /// Reads the three custom fields into a BrickSize, converting inches to mm.
  BrickSize? _readCustomSize() {
    final l = double.tryParse(_brickLenCtrl.text);
    final w = double.tryParse(_brickWidCtrl.text);
    final h = double.tryParse(_brickHgtCtrl.text);
    if (l == null || w == null || h == null) return null;
    final f = _brickUnit == 'in' ? BrickSize.mmPerInch : 1.0;
    return BrickSize.custom(l * f, w * f, h * f);
  }

  void _onCustomChanged(String _) {
    final size = _readCustomSize();
    if (size == null) return;
    setState(() {
      _brick = size;
      _result = null;
    });
    widget.storage.setCustomBrickSize(size);
  }

  void _selectBrick(String id) {
    setState(() {
      _result = null;
      if (id == BrickSize.customId) {
        _brick =
            _readCustomSize() ??
            BrickSize.custom(_brick.lengthMm, _brick.widthMm, _brick.heightMm);
        if (_brickLenCtrl.text.isEmpty) _fillCustomFields(_brick);
      } else {
        _brick = BrickSize.presetById(id) ?? BrickCalculator.defaultBrick;
      }
    });
    widget.storage.setBrickSizeId(id);
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    final length = double.tryParse(_lengthCtrl.text);
    final height = double.tryParse(_heightCtrl.text);

    if (length == null || length <= 0 || height == null || height <= 0) {
      showInputError(context);
      return;
    }

    if (_brick.isCustom && !_brick.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('brickSizeInvalid')),
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
        brick: _brick,
      );
    });

    AdService().onCalculationComplete(repeat: repeat);
  }

  String _buildShareText() {
    if (_result == null) return '';
    final r = _result!;
    final thicknessLabel = _wallLabel(_halfWall);
    final rates = widget.storage.allRates;

    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🧱 ${AppStrings.get('brick')}\n';
    text +=
        '${AppStrings.get('wallLength')}: ${lengthLabel(_lengthCtrl.text, _unit)}\n';
    text +=
        '${AppStrings.get('wallHeight')}: ${lengthLabel(_heightCtrl.text, _unit)}\n';
    text += '${AppStrings.get('wallThickness')}: $thicknessLabel\n';
    text += '${AppStrings.get('brickSize')}: ${_brick.label} inch\n';
    text += '${AppStrings.get('mortarRatio')}: $_ratioC:$_ratioS\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('brickCount')}: ${IndianFormatter.format(r.brickCount.toDouble())}\n';
    text +=
        '${AppStrings.get('cementBags')}: ${r.cementBagsToBuy} (${exactNote(r.cementBags)})\n';
    text +=
        '${AppStrings.get('sandCft')}: ${r.sandCftToBuy} (${exactNote(r.sandCFT)})\n';

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
    // Priced on what is actually bought — whole bags, whole CFT.
    if (rates.containsKey('cement')) {
      total += r.cementBagsToBuy * rates['cement']!;
    }
    if (rates.containsKey('sand')) {
      total += r.sandCftToBuy * rates['sand']!;
    }
    return total;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    return ProjectItem.create(
      type: 'brick',
      detail:
          '${lengthLabel(_lengthCtrl.text, _unit)} × ${lengthLabel(_heightCtrl.text, _unit)} · ${_wallMeasure(_halfWall)} · $_ratioC:$_ratioS',
      materials: {
        ProjectMaterial.bricks: r.brickCount.toDouble(),
        ProjectMaterial.cementBags: r.cementBags,
        ProjectMaterial.sandCft: r.sandCFT,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('brick'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('brick'),
              imageAsset: 'assets/images/brick_variants_reference.webp',
              color: const Color(0xFFD84315),
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

                  // Length & Height
                  LengthField(
                    controller: _lengthCtrl,
                    label: AppStrings.get('wallLength'),
                    unit: _unit,
                    onChanged: (_) => setState(() => _result = null),
                  ),
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _heightCtrl,
                    label: AppStrings.get('wallHeight'),
                    unit: _unit,
                    onChanged: (_) => setState(() => _result = null),
                  ),
                  const SizedBox(height: 20),

                  // Brick size — the brick count, the mortar share and the wall
                  // thickness below all follow from this.
                  Row(
                    children: [
                      SectionLabel(title: AppStrings.get('brickSize')),
                      const SizedBox(width: 6),
                      const HelpIconButton(
                        titleKey: 'brickSizeHelpTitle',
                        descKey: 'brickSizeHelpDesc',
                      ),
                    ],
                  ),
                  VisualChoiceGrid<String>(
                    options: [
                      ...BrickSize.presets.map((b) => b.id),
                      BrickSize.customId,
                    ],
                    columns: 2,
                    fillWidth: true,
                    cardHeight: 190,
                    imageHeight: 104,
                    showImageBackground: false,
                    labelsAtBottom: true,
                    selectedColor: const Color(0xFF3B2A20),
                    selected: _brick.id,
                    labelBuilder: _brickChipLabel,
                    subLabelBuilder: _brickChipSubLabel,
                    imageAssetBuilder: _brickOptionAsset,
                    imageScaleBuilder: _brickOptionScale,
                    onSelected: _selectBrick,
                  ),
                  if (_brick.isCustom) ...[
                    const SizedBox(height: 14),
                    _buildCustomBrickInputs(),
                  ],
                  const SizedBox(height: 20),

                  // Thickness — derived from the brick chosen above
                  SectionLabel(title: AppStrings.get('wallThickness')),
                  VisualChoiceGrid<bool>(
                    options: const [true, false],
                    selected: _halfWall,
                    labelBuilder: (half) => AppStrings.get(
                      half ? 'halfBrickShort' : 'fullBrickShort',
                    ),
                    subLabelBuilder: _wallMeasure,
                    imageAssetBuilder: (half) => half
                        ? 'assets/images/wall_option_half.webp'
                        : 'assets/images/wall_option_full.webp',
                    onSelected: (v) => setState(() {
                      _halfWall = v;
                      _result = null;
                    }),
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
                        _result = null;
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  // Calculate button
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

  static const Map<String, String> _brickNameKeys = {
    'desi': 'brickDesi',
    'modular': 'brickModular',
    'big': 'brickBig',
  };

  String _brickChipLabel(String id) => id == BrickSize.customId
      ? AppStrings.get('brickCustom')
      : AppStrings.get(_brickNameKeys[id]!);

  /// Uses the visual scale as a quick size cue: small standard brick,
  /// medium desi brick, then the largest gray concrete block.
  double _brickOptionScale(String id) => switch (id) {
    'modular' => 0.56,
    'desi' => 0.78,
    'big' => 1.0,
    _ => 0.74,
  };

  String _brickOptionAsset(String id) => switch (id) {
    'desi' => 'assets/images/brick_option_medium_512.webp',
    'modular' => 'assets/images/brick_option_modular.webp',
    'big' => 'assets/images/brick_option_cement_block_512.webp',
    _ => 'assets/images/brick_option_custom.webp',
  };

  /// The size in inches, shown small under the name. The custom chip stays
  /// blank until there is an actual custom size — otherwise it borrows the
  /// preset's numbers and looks like a size the user never entered.
  String _brickChipSubLabel(String id) {
    if (id != BrickSize.customId) {
      return '${BrickSize.presetById(id)!.label}"';
    }
    final custom = _brick.isCustom ? _brick : widget.storage.customBrickSize;
    return custom == null ? '' : '${custom.label}"';
  }

  Widget _buildCustomBrickInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            UnitToggle(
              value: _brickUnit,
              options: const ['mm', 'in'],
              onChanged: (v) {
                if (v == _brickUnit) return;
                final current = _readCustomSize() ?? _brick;
                setState(() {
                  _brickUnit = v;
                  _fillCustomFields(current);
                  _brick = current;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final fields = [
              LargeInputField(
                controller: _brickLenCtrl,
                label: AppStrings.get('brickLengthMm'),
                onChanged: _onCustomChanged,
              ),
              LargeInputField(
                controller: _brickWidCtrl,
                label: AppStrings.get('brickWidthMm'),
                onChanged: _onCustomChanged,
              ),
              LargeInputField(
                controller: _brickHgtCtrl,
                label: AppStrings.get('brickHeightMm'),
                onChanged: _onCustomChanged,
              ),
            ];

            if (constraints.maxWidth < 400) {
              return Column(
                children: [
                  fields[0],
                  const SizedBox(height: 14),
                  fields[1],
                  const SizedBox(height: 14),
                  fields[2],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 10),
                Expanded(child: fields[1]),
                const SizedBox(width: 10),
                Expanded(child: fields[2]),
              ],
            );
          },
        ),
      ],
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
          countTo: r.brickCount.toDouble(),
          countFormat: IndianFormatter.format,
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
                value: '${r.cementBagsToBuy}',
                note: exactNote(r.cementBags),
                icon: Icons.inventory_2_outlined,
              ),
              const Divider(height: 1),
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

        // Share & Copy
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
