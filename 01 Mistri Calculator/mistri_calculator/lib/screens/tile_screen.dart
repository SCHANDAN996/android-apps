import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import '../core/services/ad_service.dart';
import '../core/math/tile_calculator.dart';
import '../core/utils/indian_formatter.dart';
import '../widgets/shared_widgets.dart';
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
    final length = double.tryParse(_lengthCtrl.text);
    final width = double.tryParse(_widthCtrl.text);
    final tilesPerBox = int.tryParse(_tilesPerBoxCtrl.text) ?? 4;

    if (length == null || length <= 0 || width == null || width <= 0) {
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
    text += '🔲 ${AppStrings.get('tiles')}\n';
    text +=
        '${AppStrings.get('floorLength')}: ${_lengthCtrl.text} $_unit\n';
    text +=
        '${AppStrings.get('floorWidth')}: ${_widthCtrl.text} $_unit\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('totalTiles')}: ${r.totalTiles}\n';
    text +=
        '${AppStrings.get('totalBoxes')}: ${r.totalBoxes}\n';

    final rates = widget.storage.allRates;
    if (rates.containsKey('tile')) {
      final cost = r.totalBoxes * rates['tile']!;
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
        title: Text(AppStrings.get('tiles')),
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

            // Floor dimensions
            LargeInputField(
              controller: _lengthCtrl,
              label: AppStrings.get('floorLength'),
              suffix: _unit,
            ),
            const SizedBox(height: 14),
            LargeInputField(
              controller: _widthCtrl,
              label: AppStrings.get('floorWidth'),
              suffix: _unit,
            ),
            const SizedBox(height: 20),

            // Tile size
            SectionLabel(title: AppStrings.get('tileSize')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...TileCalculator.standardSizes.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final size = entry.value;
                  final isActive = !_isCustom && _selectedTileIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTileIndex = idx;
                        _isCustom = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        size.label,
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => _isCustom = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isCustom
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isCustom
                            ? AppColors.primary
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      AppStrings.get('customSize'),
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isCustom
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_isCustom) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LargeInputField(
                      controller: _customLengthCtrl,
                      label: AppStrings.get('tileLength'),
                      suffix: 'mm',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LargeInputField(
                      controller: _customWidthCtrl,
                      label: AppStrings.get('tileWidth'),
                      suffix: 'mm',
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            LargeInputField(
              controller: _tilesPerBoxCtrl,
              label: AppStrings.get('tilesPerBox'),
              allowDecimal: false,
              suffixIcon: const HelpIconButton(
                titleKey: 'tileHelpTitle',
                descKey: 'tileHelpDesc',
              ),
            ),
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
          label: AppStrings.get('totalTiles'),
          value: IndianFormatter.format(r.totalTiles.toDouble()),
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
