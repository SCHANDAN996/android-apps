import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import '../data/plot_units.dart';
import '../data/tool_strings.dart';
import '../services/ad_service.dart';
import '../widgets/accent_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/plot_painter.dart';

class IrregularPlotScreen extends StatefulWidget {
  const IrregularPlotScreen({super.key});

  @override
  State<IrregularPlotScreen> createState() => _IrregularPlotScreenState();
}

class _IrregularPlotScreenState extends State<IrregularPlotScreen> {
  final TextEditingController _sideAController = TextEditingController(text: '120');
  final TextEditingController _sideBController = TextEditingController(text: '80');
  final TextEditingController _sideCController = TextEditingController(text: '110');
  final TextEditingController _sideDController = TextEditingController(text: '90');
  final TextEditingController _diagonalController = TextEditingController(text: '145');

  PlotUnit _inputUnit = PlotUnit.feet;
  String _state = standardStateKey;
  late List<LandUnit> _units = unitsForState(_state);

  bool _showDiagonal = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('converter_last_state');
      if (saved == null || !mounted) return;
      // dropdown me na hone wali value assertion faila deti hai
      if (saved != standardStateKey && !stateUnits.containsKey(saved)) return;
      setState(() {
        _state = saved;
        _units = unitsForState(saved);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _sideAController.dispose();
    _sideBController.dispose();
    _sideCController.dispose();
    _sideDController.dispose();
    _diagonalController.dispose();
    super.dispose();
  }

  IrregularPlotResult? _calculateResult() {
    final aRaw = double.tryParse(_sideAController.text.trim()) ?? 0.0;
    final bRaw = double.tryParse(_sideBController.text.trim()) ?? 0.0;
    final cRaw = double.tryParse(_sideCController.text.trim()) ?? 0.0;
    final dRaw = double.tryParse(_sideDController.text.trim()) ?? 0.0;
    final diagRaw = _showDiagonal ? (double.tryParse(_diagonalController.text.trim()) ?? 0.0) : null;

    if (aRaw <= 0 || bRaw <= 0 || cRaw <= 0 || dRaw <= 0) return null;

    final factor = _inputUnit.feetFactor;
    final aInFeet = aRaw * factor;
    final bInFeet = bRaw * factor;
    final cInFeet = cRaw * factor;
    final dInFeet = dRaw * factor;
    final diagInFeet = (diagRaw != null && diagRaw > 0) ? (diagRaw * factor) : null;

    return calculateIrregularPlot(
      a: aInFeet,
      b: bInFeet,
      c: cInFeet,
      d: dInFeet,
      diagonal: diagInFeet,
    );
  }

  String _buildShareMessage(AppStrings strings, IrregularPlotResult result, double sqft) {
    final unit = strings.plotUnitName(_inputUnit);
    final buffer = StringBuffer();
    buffer.writeln(strings.irrShareTitle);
    buffer.writeln('${strings.irrSideNorth}: ${_sideAController.text} $unit');
    buffer.writeln('${strings.irrSideEast}: ${_sideBController.text} $unit');
    buffer.writeln('${strings.irrSideSouth}: ${_sideCController.text} $unit');
    buffer.writeln('${strings.irrSideWest}: ${_sideDController.text} $unit');
    if (result.exactAreaSqFt != null) {
      buffer.writeln(
          '${strings.irrDiagonalLabel}: ${_diagonalController.text} $unit');
      buffer.writeln('');
      buffer.writeln(
          '${strings.irrShareExact}: ${formatIndian(sqft)} ${strings.sqFt}');
    } else {
      buffer.writeln('');
      buffer.writeln(
          '${strings.irrShareAverage}: ${formatIndian(sqft)} ${strings.sqFt}');
    }
    buffer.writeln('${strings.stateLabel}: $_state');
    buffer.writeln('---------------------------');
    for (final u in _units) {
      buffer.writeln('${formatIndian(sqft / u.sqft)}  ${u.label}');
    }
    buffer.writeln('---------------------------');
    buffer.writeln(strings.sharedFromApp);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _calculateResult();
    final aVal = double.tryParse(_sideAController.text.trim()) ?? 0.0;
    final bVal = double.tryParse(_sideBController.text.trim()) ?? 0.0;
    final cVal = double.tryParse(_sideCController.text.trim()) ?? 0.0;
    final dVal = double.tryParse(_sideDController.text.trim()) ?? 0.0;
    final diagVal = _showDiagonal ? double.tryParse(_diagonalController.text.trim()) : null;

    final primarySqFt = result?.exactAreaSqFt ?? result?.averageAreaSqFt;

    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) AdService.instance.showInterstitialWithCounter(() {});
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: Text(strings.toolIrregularPlot),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    // Unit and State Selector Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<PlotUnit>(
                            initialValue: _inputUnit,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: strings.unitLabel,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: plotSideUnits
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(strings.plotUnitName(u),
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _inputUnit = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _state,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: strings.stateLabel,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: standardStateKey,
                                child: Text(strings.stateDisplayName(standardStateKey),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              ...stateUnits.keys.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(strings.stateDisplayName(s), overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                            onChanged: (s) {
                              if (s != null) {
                                setState(() {
                                  _state = s;
                                  _units = unitsForState(s);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visual Plot Canvas Preview
                    if (aVal > 0 && bVal > 0 && cVal > 0 && dVal > 0) ...[
                      Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomPaint(
                            painter: QuadrilateralPlotPainter(
                              a: aVal,
                              b: bVal,
                              c: cVal,
                              d: dVal,
                              diagonal: diagVal,
                              unitName: strings.plotUnitName(_inputUnit),
                              northLabel: strings.dirNorth,
                              eastLabel: strings.dirEast,
                              southLabel: strings.dirSouth,
                              westLabel: strings.dirWest,
                              diagonalLabel: strings.diagonalShort,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Input Form Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  strings.irrEnterFourSides,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                                tooltip: strings.reset,
                                onPressed: () {
                                  setState(() {
                                    _sideAController.text = '0';
                                    _sideBController.text = '0';
                                    _sideCController.text = '0';
                                    _sideDController.text = '0';
                                    _diagonalController.text = '0';
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSideField(
                                  controller: _sideAController,
                                  label: strings.irrSideNorth,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSideField(
                                  controller: _sideBController,
                                  label: strings.irrSideEast,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSideField(
                                  controller: _sideCController,
                                  label: strings.irrSideSouth,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSideField(
                                  controller: _sideDController,
                                  label: strings.irrSideWest,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          // Diagonal Checkbox Row
                          Row(
                            children: [
                              Checkbox(
                                value: _showDiagonal,
                                activeColor: const Color(0xFF2E7D32),
                                onChanged: (val) {
                                  setState(() => _showDiagonal = val ?? false);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  strings.irrAddDiagonal,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          if (_showDiagonal) ...[
                            const SizedBox(height: 8),
                            _buildSideField(
                              controller: _diagonalController,
                              label: strings.irrDiagonalLabel,
                              color: Colors.deepOrange,
                              helperText: strings.irrDiagonalHelper,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results Section
                    if (result == null || primarySqFt == null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            strings.irrEnterAllSides,
                            style: const TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ] else ...[
                      // Error in diagonal if any
                      if (result.diagonalMismatch) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.irrDiagonalMismatch,
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Hero Area Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              result.exactAreaSqFt != null
                                  ? strings.irrExactArea
                                  : strings.irrAverageArea,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatIndian(primarySqFt)} ${strings.sqFt}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (result.exactAreaSqFt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                strings.irrTriangleBreakdown(
                                    '${formatIndian(result.area1SqFt!)} ${strings.sqFt}',
                                    '${formatIndian(result.area2SqFt!)} ${strings.sqFt}'),
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons (Copy & Share)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.copy, size: 18),
                              label: Text(strings.copy),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2E7D32),
                                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: _buildShareMessage(strings, result, primarySqFt),
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(strings.copied), duration: const Duration(seconds: 2)),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(Icons.share, size: 18),
                              label: Text(strings.share),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                Share.share(_buildShareMessage(strings, result, primarySqFt));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Converted Units Breakdown
                      Text(
                        strings.valuesInState(_state),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._units.map(
                        (u) => AccentCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            title: Text(
                              formatIndian(primarySqFt / u.sqft),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            subtitle: Text(
                              u.label,
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    // Information Alert Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.irrPatwariNote,
                              style: TextStyle(color: Colors.blue.shade900, fontSize: 12, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: const BannerAdWidget(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSideField({
    required TextEditingController controller,
    required String label,
    required Color color,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
