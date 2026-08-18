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

enum TriangleCalcMode { threeSides, baseHeight }

class TrianglePlotScreen extends StatefulWidget {
  const TrianglePlotScreen({super.key});

  @override
  State<TrianglePlotScreen> createState() => _TrianglePlotScreenState();
}

class _TrianglePlotScreenState extends State<TrianglePlotScreen> {
  TriangleCalcMode _mode = TriangleCalcMode.threeSides;

  // 3 Sides controllers
  final TextEditingController _sideAController = TextEditingController(text: '80');
  final TextEditingController _sideBController = TextEditingController(text: '100');
  final TextEditingController _sideCController = TextEditingController(text: '90');

  // Base Height controllers
  final TextEditingController _baseController = TextEditingController(text: '100');
  final TextEditingController _heightController = TextEditingController(text: '70');

  PlotUnit _inputUnit = PlotUnit.feet;
  String _state = standardStateKey;
  late List<LandUnit> _units = unitsForState(_state);

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
    _baseController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double? get _calculatedSqFt {
    final factor = _inputUnit.feetFactor;

    if (_mode == TriangleCalcMode.threeSides) {
      final a = (double.tryParse(_sideAController.text.trim()) ?? 0.0) * factor;
      final b = (double.tryParse(_sideBController.text.trim()) ?? 0.0) * factor;
      final c = (double.tryParse(_sideCController.text.trim()) ?? 0.0) * factor;
      return calculateTriangleHeron(a, b, c);
    } else {
      final base = (double.tryParse(_baseController.text.trim()) ?? 0.0) * factor;
      final height = (double.tryParse(_heightController.text.trim()) ?? 0.0) * factor;
      if (base <= 0 || height <= 0) return null;
      return 0.5 * base * height;
    }
  }

  String _buildShareText(AppStrings strings, double sqft) {
    final unit = strings.plotUnitName(_inputUnit);
    final buffer = StringBuffer();
    buffer.writeln(strings.triShareTitle);
    if (_mode == TriangleCalcMode.threeSides) {
      buffer.writeln('${strings.triSideA}: ${_sideAController.text} $unit');
      buffer.writeln('${strings.triSideBBase}: ${_sideBController.text} $unit');
      buffer.writeln('${strings.triSideC}: ${_sideCController.text} $unit');
    } else {
      buffer.writeln('${strings.triBase}: ${_baseController.text} $unit');
      buffer.writeln('${strings.triHeight}: ${_heightController.text} $unit');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln(
        '${strings.shareTotalArea}: ${formatIndian(sqft)} ${strings.sqFt}');
    buffer.writeln('${strings.stateLabel}: $_state');
    for (final u in _units) {
      buffer.writeln('${formatIndian(sqft / u.sqft)} ${u.label}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln(strings.sharedFromApp);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sqft = _calculatedSqFt;
    final aVal = double.tryParse(_sideAController.text.trim()) ?? 0.0;
    final bVal = double.tryParse(_sideBController.text.trim()) ?? 0.0;
    final cVal = double.tryParse(_sideCController.text.trim()) ?? 0.0;

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
                title: Text(strings.toolTriangle),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    // Mode Switch
                    SegmentedButton<TriangleCalcMode>(
                      segments: [
                        ButtonSegment(
                          value: TriangleCalcMode.threeSides,
                          label: Text(strings.triThreeSidesMode),
                          icon: const Icon(Icons.change_history),
                        ),
                        ButtonSegment(
                          value: TriangleCalcMode.baseHeight,
                          label: Text(strings.triBaseHeightMode),
                          icon: const Icon(Icons.square_foot),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (set) {
                        setState(() => _mode = set.first);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unit & State row
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
                              const DropdownMenuItem(
                                value: standardStateKey,
                                child: Text(standardStateKey, overflow: TextOverflow.ellipsis),
                              ),
                              ...stateUnits.keys.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
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

                    // Visual Triangle Canvas (in 3-sides mode)
                    if (_mode == TriangleCalcMode.threeSides && aVal > 0 && bVal > 0 && cVal > 0) ...[
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CustomPaint(
                            painter: TrianglePlotPainter(
                              a: aVal,
                              b: bVal,
                              c: cVal,
                              unitName: strings.plotUnitName(_inputUnit),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Input Card
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
                          if (_mode == TriangleCalcMode.threeSides) ...[
                            Text(strings.triEnterThreeSides, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _sideAController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    decoration: InputDecoration(
                                      labelText: strings.triSideA,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _sideBController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    decoration: InputDecoration(
                                      labelText: strings.triSideBBase,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _sideCController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              decoration: InputDecoration(
                                labelText: strings.triSideC,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ] else ...[
                            Text(strings.triEnterBaseHeight, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _baseController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    decoration: InputDecoration(
                                      labelText: strings.triBase,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _heightController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    decoration: InputDecoration(
                                      labelText: strings.triHeight,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results
                    if (sqft == null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            strings.triInvalidHint,
                            style: const TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ] else ...[
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
                              strings.triTotalArea,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatIndian(sqft)} ${strings.sqFt}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(${formatIndian(sqft / 9.0)} ${strings.sqGaj} • ${formatIndian(sqft / 435.6)} ${strings.dismil})',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
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
                                Clipboard.setData(ClipboardData(text: _buildShareText(strings, sqft)));
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
                                Share.share(_buildShareText(strings, sqft));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(strings.valuesInState(_state), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._units.map((u) {
                        return AccentCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                            title: Text(
                              formatIndian(sqft / u.sqft),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 17),
                            ),
                            subtitle: Text(u.label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          ),
                        );
                      }),
                    ],
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
}
