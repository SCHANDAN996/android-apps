import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import '../data/tool_strings.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart';

enum BatwaraMode { equal, custom }

class PartnerShare {
  String name;
  double ratio; // e.g. 2 or 1
  PartnerShare({required this.name, required this.ratio});
}

class BatwaraScreen extends StatefulWidget {
  const BatwaraScreen({super.key});

  @override
  State<BatwaraScreen> createState() => _BatwaraScreenState();
}

class _BatwaraScreenState extends State<BatwaraScreen> {
  final TextEditingController _totalAreaController = TextEditingController(text: '1');
  final TextEditingController _equalCountController = TextEditingController(text: '3');

  String _state = standardStateKey;
  late List<LandUnit> _units = unitsForState(_state);
  late LandUnit _selectedUnit = _units.firstWhere((u) => u.en == 'Bigha', orElse: () => _units.first);

  BatwaraMode _mode = BatwaraMode.equal;

  // Custom partners list — naam pehli baar build par bhasha ke hisaab se bharte
  // hain, kyunki initState me AppStrings uplabdh nahi hota.
  final List<PartnerShare> _customPartners = [];

  /// "हिस्सेदार 4" jaise naam ginne ke liye — list se index lene par hatane ke
  /// baad naam dohra sakta hai.
  int _partnerCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _seedPartnersIfEmpty(AppStrings strings) {
    if (_customPartners.isNotEmpty) return;
    for (var i = 0; i < 3; i++) {
      _partnerCounter++;
      _customPartners.add(PartnerShare(
        name: strings.batPartnerDefaultName(_partnerCounter),
        ratio: 1,
      ));
    }
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
        if (!_units.contains(_selectedUnit)) {
          _selectedUnit = _units.firstWhere((u) => u.en == 'Bigha', orElse: () => _units.first);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _totalAreaController.dispose();
    _equalCountController.dispose();
    super.dispose();
  }

  double? get _totalSqFt {
    final val = double.tryParse(_totalAreaController.text.trim());
    if (val == null || val <= 0) return null;
    return val * _selectedUnit.sqft;
  }

  String _buildShareText(AppStrings strings, double totalSqFt) {
    final buffer = StringBuffer();
    buffer.writeln(strings.batShareTitle);
    buffer.writeln(
        '${strings.batShareTotalArea}: ${_totalAreaController.text} ${_selectedUnit.label}');
    buffer.writeln(
        '${strings.shareTotalArea}: ${formatIndian(totalSqFt)} ${strings.sqFt}');
    buffer.writeln('${strings.stateLabel}: $_state');
    buffer.writeln('=================================');

    if (_mode == BatwaraMode.equal) {
      final count = int.tryParse(_equalCountController.text.trim()) ?? 1;
      final shareSqFt = totalSqFt / (count > 0 ? count : 1);
      buffer.writeln(strings.batShareEqualLine(count));
      buffer.writeln(strings.batShareEachGets);
      buffer.writeln('• ${formatIndian(shareSqFt)} ${strings.sqFt}');
      buffer.writeln('• ${formatIndian(shareSqFt / 9.0)} ${strings.sqGaj}');
      buffer.writeln('• ${formatIndian(shareSqFt / 435.6)} ${strings.dismil}');
      for (final u in _units) {
        buffer.writeln('• ${formatIndian(shareSqFt / u.sqft)} ${u.label}');
      }
    } else {
      final totalRatio = _customPartners.fold<double>(0, (sum, p) => sum + (p.ratio > 0 ? p.ratio : 0));
      buffer.writeln(strings.batShareRatioWise);
      for (int i = 0; i < _customPartners.length; i++) {
        final p = _customPartners[i];
        final fraction = totalRatio > 0 ? (p.ratio / totalRatio) : 0.0;
        final pSqFt = totalSqFt * fraction;
        final pct = (fraction * 100).toStringAsFixed(1);
        buffer.writeln(
            '${p.name} (${strings.batShareRatioWord('${p.ratio}')}, $pct%):');
        buffer.writeln(
            '  - ${formatIndian(pSqFt)} ${strings.sqFt} (${formatIndian(pSqFt / 9.0)} ${strings.sqGaj} / ${formatIndian(pSqFt / 435.6)} ${strings.dismil})');
        for (final u in _units) {
          buffer.writeln('  - ${formatIndian(pSqFt / u.sqft)} ${u.label}');
        }
      }
    }
    buffer.writeln('=================================');
    buffer.writeln(strings.sharedFromApp);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSqFt = _totalSqFt;

    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        _seedPartnersIfEmpty(strings);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) AdService.instance.showInterstitialWithCounter(() {});
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: Text(strings.toolBatwara),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    // Mode Switch
                    SegmentedButton<BatwaraMode>(
                      segments: [
                        ButtonSegment(
                          value: BatwaraMode.equal,
                          label: Text(strings.batEqualMode),
                          icon: const Icon(Icons.people_outline),
                        ),
                        ButtonSegment(
                          value: BatwaraMode.custom,
                          label: Text(strings.batCustomMode),
                          icon: const Icon(Icons.pie_chart_outline),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (set) {
                        setState(() => _mode = set.first);
                      },
                    ),
                    const SizedBox(height: 16),

                    // State and Unit Selector Card
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
                          Text(strings.batTotalLandDetails, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // State Dropdown
                          DropdownButtonFormField<String>(
                            initialValue: _state,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: strings.stateLabel,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: standardStateKey,
                                child: Text(standardStateKey),
                              ),
                              ...stateUnits.keys.map(
                                (s) => DropdownMenuItem(value: s, child: Text(s)),
                              ),
                            ],
                            onChanged: (s) {
                              if (s != null) {
                                setState(() {
                                  _state = s;
                                  _units = unitsForState(s);
                                  if (!_units.contains(_selectedUnit)) {
                                    _selectedUnit = _units.firstWhere((u) => u.en == 'Bigha', orElse: () => _units.first);
                                  }
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _totalAreaController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  decoration: InputDecoration(
                                    labelText: strings.batEnterTotalArea,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<LandUnit>(
                                  initialValue: _selectedUnit,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: strings.selectUnit,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  items: _units.map((u) {
                                    return DropdownMenuItem(
                                      value: u,
                                      child: Text(u.label, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (u) {
                                    if (u != null) setState(() => _selectedUnit = u);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Partition Config Card
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
                          if (_mode == BatwaraMode.equal) ...[
                            Text(strings.batPartnerCount, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _equalCountController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      labelText: strings.batPartnerFieldLabel,
                                      suffixText: strings.batPeopleSuffix,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick number chips
                            Wrap(
                              spacing: 8,
                              children: [2, 3, 4, 5, 6, 8].map((n) {
                                return ActionChip(
                                  label: Text(strings.batShareChip(n)),
                                  onPressed: () {
                                    setState(() {
                                      _equalCountController.text = n.toString();
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(strings.batRatioHeading,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text(strings.batAdd),
                                  onPressed: () {
                                    setState(() {
                                      _partnerCounter++;
                                      _customPartners.add(PartnerShare(
                                        name: strings
                                            .batPartnerDefaultName(_partnerCounter),
                                        ratio: 1,
                                      ));
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(_customPartners.length, (idx) {
                              final p = _customPartners[idx];
                              // ObjectKey ties each row's TextFormField state to the
                              // partner object, not to its position. Without it,
                              // removing a partner leaves the fields below showing the
                              // previous row's name/ratio while the maths uses the new
                              // ones (TextFormField never re-reads `initialValue`).
                              return Padding(
                                key: ObjectKey(p),
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        initialValue: p.name,
                                        decoration: InputDecoration(
                                          labelText: strings.batNameLabel(idx + 1),
                                          isDense: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onChanged: (val) => p.name = val,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        initialValue: p.ratio.toString(),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                        decoration: InputDecoration(
                                          labelText: strings.batRatioLabel,
                                          isDense: true,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onChanged: (val) {
                                          final r = double.tryParse(val);
                                          if (r != null) setState(() => p.ratio = r);
                                        },
                                      ),
                                    ),
                                    if (_customPartners.length > 2)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _customPartners.removeAt(idx));
                                        },
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Results
                    if (totalSqFt == null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(strings.batEnterAreaFirst, style: const TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ] else ...[
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
                                Clipboard.setData(ClipboardData(text: _buildShareText(strings, totalSqFt)));
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
                                Share.share(_buildShareText(strings, totalSqFt));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_mode == BatwaraMode.equal) ...[
                        _buildEqualResults(strings, totalSqFt),
                      ] else ...[
                        _buildCustomResults(strings, totalSqFt),
                      ],
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

  Widget _buildEqualResults(AppStrings strings, double totalSqFt) {
    final count = int.tryParse(_equalCountController.text.trim()) ?? 1;
    final shareSqFt = totalSqFt / (count > 0 ? count : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(strings.batEachShare(count), style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                '${formatIndian(shareSqFt)} ${strings.sqFt}',
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '(${formatIndian(shareSqFt / 9.0)} ${strings.sqGaj} • ${formatIndian(shareSqFt / 435.6)} ${strings.dismil})',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(strings.batEachShareInState(_state), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ..._units.map((u) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: Text(
                formatIndian(shareSqFt / u.sqft),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 17),
              ),
              subtitle: Text(u.label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomResults(AppStrings strings, double totalSqFt) {
    final totalRatio = _customPartners.fold<double>(0, (sum, p) => sum + (p.ratio > 0 ? p.ratio : 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.batFinalShares, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        ..._customPartners.map((p) {
          final fraction = totalRatio > 0 ? (p.ratio / totalRatio) : 0.0;
          final pSqFt = totalSqFt * fraction;
          final pct = (fraction * 100).toStringAsFixed(1);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(strings.batPercentShare(pct), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text('${formatIndian(pSqFt)} ${strings.sqFt} (${formatIndian(pSqFt / 9.0)} ${strings.sqGaj} / ${formatIndian(pSqFt / 435.6)} ${strings.dismil})', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _units.map((u) {
                      return Chip(
                        label: Text('${formatIndian(pSqFt / u.sqft)} ${u.hi}', style: const TextStyle(fontSize: 11)),
                        backgroundColor: const Color(0xFFF5F7F5),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
