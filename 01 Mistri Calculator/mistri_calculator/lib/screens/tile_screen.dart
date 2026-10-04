import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/tile_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/length_field.dart';
import '../widgets/add_to_project_button.dart';
import '../core/models/project_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/help_dialogs.dart';

class TileScreen extends StatefulWidget {
  final StorageService storage;
  const TileScreen({super.key, required this.storage});

  @override
  State<TileScreen> createState() => _TileScreenState();
}

class _TileScreenState extends State<TileScreen> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _tilesPerBoxCtrl = TextEditingController(text: '4');
  final _customLengthCtrl = TextEditingController();
  final _customWidthCtrl = TextEditingController();
  String _unit = 'ft';
  int _selectedTileIndex = 1; // 600x600mm default
  bool _isCustom = false;
  TileResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _tilesPerBoxCtrl.dispose();
    _customLengthCtrl.dispose();
    _customWidthCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    final length = double.tryParse(_lengthCtrl.text);
    final width = double.tryParse(_widthCtrl.text);
    final tilesPerBox = int.tryParse(_tilesPerBoxCtrl.text);

    if (length == null ||
        length <= 0 ||
        width == null ||
        width <= 0 ||
        tilesPerBox == null ||
        tilesPerBox <= 0) {
      _showError();
      return;
    }

    TileSize tileSize;
    if (_isCustom) {
      final tl = double.tryParse(_customLengthCtrl.text);
      final tw = double.tryParse(_customWidthCtrl.text);
      if (tl == null || tl <= 0 || tw == null || tw <= 0) {
        _showError();
        return;
      }
      tileSize = TileSize('Custom', tl, tw);
    } else {
      tileSize = TileCalculator.standardSizes[_selectedTileIndex];
    }

    setState(() {
      _result = TileCalculator.calculate(
        floorLength: length,
        floorWidth: width,
        unit: _unit,
        tileSize: tileSize,
        tilesPerBox: tilesPerBox,
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
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '🔲 ${AppStrings.get('tiles')}\n';
    text +=
        '${AppStrings.get('floorLength')}: ${lengthLabel(_lengthCtrl.text, _unit)}\n';
    text +=
        '${AppStrings.get('floorWidth')}: ${lengthLabel(_widthCtrl.text, _unit)}\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text += '${AppStrings.get('totalTiles')}: ${r.totalTiles}\n';
    text += '${AppStrings.get('totalBoxes')}: ${r.totalBoxes}\n';

    final rates = widget.storage.allRates;
    if (rates.containsKey('tile')) {
      final cost = r.totalBoxes * rates['tile']!;
      text +=
          '\n💰 ${AppStrings.get('estimatedCost')}: ${IndianFormatter.formatCurrency(cost)}\n';
    }

    text += AppStrings.get('shareFooter');
    return text;
  }

  /// Scales the tile picture by the tile's real area, so a 2x2 ft tile looks
  /// bigger than a 1x1 ft one. Custom sits in the middle until it is measured.
  double _tileOptionScale(String value) {
    if (value == 'custom') return 0.8;
    final t = TileCalculator.standardSizes[int.parse(value)];
    final area = t.lengthMm * t.widthMm;
    const smallest = 300.0 * 300.0;
    const largest = 1200.0 * 600.0;
    final f = ((area - smallest) / (largest - smallest)).clamp(0.0, 1.0);
    return 0.55 + 0.45 * f;
  }

  ProjectItem _projectItem() {
    final r = _result!;
    return ProjectItem.create(
      type: 'tiles',
      detail:
          '${lengthLabel(_lengthCtrl.text, _unit)} × ${lengthLabel(_widthCtrl.text, _unit)}',
      materials: {
        ProjectMaterial.tiles: r.totalTiles.toDouble(),
        ProjectMaterial.tileBoxes: r.totalBoxes.toDouble(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('tiles'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalculatorToolHeader(
              title: AppStrings.get('tiles'),
              imageAsset: 'assets/images/tile_sizes_reference.webp',
              color: const Color(0xFF0277BD),
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

                  // Floor dimensions
                  LengthField(
                    controller: _lengthCtrl,
                    label: AppStrings.get('floorLength'),
                    unit: _unit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _widthCtrl,
                    label: AppStrings.get('floorWidth'),
                    unit: _unit,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 20),

                  // Tile size
                  SectionLabel(title: AppStrings.get('tileSize')),
                  VisualChoiceGrid<String>(
                    options: [
                      ...TileCalculator.standardSizes.asMap().keys.map(
                        (index) => index.toString(),
                      ),
                      'custom',
                    ],
                    selected: _isCustom
                        ? 'custom'
                        : _selectedTileIndex.toString(),
                    labelBuilder: (value) => value == 'custom'
                        ? AppStrings.get('customSize')
                        : TileCalculator.standardSizes[int.parse(value)].label,
                    imageAssetBuilder: (_) => 'assets/images/tile_size_4.webp',
                    // One tile, drawn bigger or smaller to match the real size -
                    // four different crops would all render at the same size and
                    // say nothing.
                    imageScaleBuilder: _tileOptionScale,
                    compact: true,
                    onSelected: (value) => setState(() {
                      _isCustom = value == 'custom';
                      if (!_isCustom) _selectedTileIndex = int.parse(value);
                      _result = null;
                    }),
                  ),

                  if (_isCustom) ...[
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = [
                          LargeInputField(
                            controller: _customLengthCtrl,
                            label: AppStrings.get('tileLength'),
                            suffix: 'mm',
                            onChanged: (_) => _clearResult(),
                          ),
                          LargeInputField(
                            controller: _customWidthCtrl,
                            label: AppStrings.get('tileWidth'),
                            suffix: 'mm',
                            onChanged: (_) => _clearResult(),
                          ),
                        ];

                        // Two outlined fields with translated labels become too
                        // cramped on compact phones. Stack them before they can
                        // paint into each other.
                        if (constraints.maxWidth < 360) {
                          return Column(
                            children: [
                              fields[0],
                              const SizedBox(height: 14),
                              fields[1],
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: fields[0]),
                            const SizedBox(width: 12),
                            Expanded(child: fields[1]),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 14),
                  LargeInputField(
                    controller: _tilesPerBoxCtrl,
                    label: AppStrings.get('tilesPerBox'),
                    allowDecimal: false,
                    onChanged: (_) => _clearResult(),
                    suffixIcon: const HelpIconButton(
                      titleKey: 'tileHelpTitle',
                      descKey: 'tileHelpDesc',
                    ),
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
          label: AppStrings.get('totalTiles'),
          value: IndianFormatter.format(r.totalTiles.toDouble()),
          countTo: r.totalTiles.toDouble(),
          countFormat: IndianFormatter.format,
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF0277BD),
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
                label: AppStrings.get('totalBoxes'),
                value: '${r.totalBoxes}',
                icon: Icons.inventory_2_outlined,
                helpWidget: const HelpIconButton(
                  titleKey: 'tileHelpTitle',
                  descKey: 'tileHelpDesc',
                ),
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('area')} (m²)',
                value: r.floorArea.toStringAsFixed(1),
                icon: Icons.square_foot_outlined,
              ),
            ],
          ),
        ),

        if (rates.containsKey('tile')) ...[
          const SizedBox(height: 16),
          CostCard(
            totalCost: r.totalBoxes * rates['tile']!,
            items: [
              CostItem(
                '🔲 ${AppStrings.get('totalBoxes')} (${r.totalBoxes})',
                r.totalBoxes * rates['tile']!,
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
