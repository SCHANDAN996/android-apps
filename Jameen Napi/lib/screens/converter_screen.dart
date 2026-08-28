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

enum ConverterMode { direct, lengthWidth }

const String _lastStatePrefKey = 'converter_last_state';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  ConverterMode _mode = ConverterMode.direct;

  // Direct Mode Controller & Unit
  final TextEditingController _valueController = TextEditingController(text: '1');
  String _state = standardStateKey;
  late List<LandUnit> _units = unitsForState(_state);
  late LandUnit _fromUnit =
      _units.firstWhere((u) => u.en == 'Acre', orElse: () => _units.first);

  // Length x Width Mode Controllers & Units
  final TextEditingController _lengthController = TextEditingController(text: '100');
  final TextEditingController _widthController = TextEditingController(text: '50');
  PlotUnit _lengthUnit = PlotUnit.feet;
  PlotUnit _widthUnit = PlotUnit.feet;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _valueFocusNode = FocusNode();
  final FocusNode _lengthFocusNode = FocusNode();
  final FocusNode _widthFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLastState();
    _valueFocusNode.addListener(_autoScroll);
    _lengthFocusNode.addListener(_autoScroll);
    _widthFocusNode.addListener(_autoScroll);
  }

  void _autoScroll() {
    if (_valueFocusNode.hasFocus || _lengthFocusNode.hasFocus || _widthFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            130.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _loadLastState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_lastStatePrefKey);
      if (saved == null || !mounted) return;
      if (saved != standardStateKey && !stateUnits.containsKey(saved)) return;
      setState(() {
        _state = saved;
        _units = unitsForState(saved);
        if (!_units.contains(_fromUnit)) {
          _fromUnit = _units.firstWhere((u) => u.en == 'Acre',
              orElse: () => _units.first);
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _valueController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _scrollController.dispose();
    _valueFocusNode.dispose();
    _lengthFocusNode.dispose();
    _widthFocusNode.dispose();
    super.dispose();
  }

  void _onStateChanged(String? state) {
    if (state == null) return;
    setState(() {
      _state = state;
      _units = unitsForState(state);
      if (!_units.contains(_fromUnit)) {
        _fromUnit = _units.firstWhere((u) => u.en == 'Acre',
            orElse: () => _units.first);
      }
    });
    _saveLastState(state);
  }

  Future<void> _saveLastState(String state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastStatePrefKey, state);
    } catch (_) {}
  }

  String _buildShareText(AppStrings strings, double sqft) {
    final buffer = StringBuffer();
    buffer.writeln(strings.shareResultTitle);
    buffer.writeln('($_state)');
    buffer.writeln('');
    buffer.writeln(
        '${formatIndian(sqft)} ${strings.sqFtLabel} =');
    for (final u in _units) {
      buffer.writeln('${formatIndian(sqft / u.sqft)}  ${u.label}');
    }
    buffer.writeln('');
    buffer.writeln('— ${strings.appTitle}');
    return buffer.toString();
  }

  double? get _calculatedSqFt {
    if (_mode == ConverterMode.direct) {
      final text = _valueController.text.trim();
      if (text.isEmpty) return null;
      final val = double.tryParse(text);
      if (val == null) return null;
      return val * _fromUnit.sqft;
    } else {
      final lenText = _lengthController.text.trim();
      final widText = _widthController.text.trim();
      final len = double.tryParse(lenText) ?? 0.0;
      final wid = double.tryParse(widText) ?? 0.0;
      if (len <= 0 || wid <= 0) return null;

      final lenInFeet = len * _lengthUnit.feetFactor;
      final widInFeet = wid * _widthUnit.feetFactor;
      return lenInFeet * widInFeet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sqft = _calculatedSqFt;

    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              AdService.instance.showInterstitialWithCounter(() {});
            }
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: AppBar(
                title: Text(strings.toolLand),
              ),
              body: SafeArea(
                top: false,
                bottom: true,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
              // Segmented Button to Switch Modes
              SegmentedButton<ConverterMode>(
                segments: [
                  ButtonSegment<ConverterMode>(
                    value: ConverterMode.direct,
                    label: Text(strings.directAreaMode),
                    icon: const Icon(Icons.calculate_outlined),
                  ),
                  ButtonSegment<ConverterMode>(
                    value: ConverterMode.lengthWidth,
                    label: Text(strings.lengthWidthMode),
                    icon: const Icon(Icons.square_foot),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (set) {
                  setState(() {
                    _mode = set.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // State Selector
              DropdownButtonFormField<String>(
                initialValue: _state,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: strings.selectState,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: standardStateKey,
                    child: Text(strings.stateDisplayName(standardStateKey)),
                  ),
                  ...stateUnits.keys.map(
                    (s) => DropdownMenuItem(value: s, child: Text(strings.stateDisplayName(s))),
                  ),
                ],
                onChanged: _onStateChanged,
              ),
              const SizedBox(height: 16),

              // Mode 1: Direct Input
              if (_mode == ConverterMode.direct) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _valueController,
                        focusNode: _valueFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: strings.enterArea,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<LandUnit>(
                        initialValue: _fromUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: strings.selectUnit,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _units
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u.label, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (u) {
                          if (u != null) setState(() => _fromUnit = u);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Quick preset chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: Text(strings.clear),
                        avatar: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          setState(() {
                            _valueController.text = '';
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      ...['0.5', '1', '2', '5', '10', '20'].map((val) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ActionChip(
                            label: Text(val),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            onPressed: () {
                              setState(() {
                                _valueController.text = val;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ]
              // Mode 2: Length x Width Input
              else ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isEn
                              ? 'Enter Plot Dimensions:'
                              : 'प्लाट / खेत की लंबाई और चौड़ाई दर्ज करें:',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _lengthController,
                                focusNode: _lengthFocusNode,
                                textInputAction: TextInputAction.next,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: strings.lengthLabel,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<PlotUnit>(
                                initialValue: _lengthUnit,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: lengthWidthUnits
                                    .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(strings.plotUnitName(u),
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _lengthUnit = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _widthController,
                                focusNode: _widthFocusNode,
                                textInputAction: TextInputAction.done,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: strings.widthLabel,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<PlotUnit>(
                                initialValue: _widthUnit,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: lengthWidthUnits
                                    .map((u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(strings.plotUnitName(u),
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _widthUnit = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              if (sqft == null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      lang == AppLang.english
                          ? 'Enter values above to view total area conversion.'
                          : 'ऊपर नाप दर्ज करें, नीचे सभी इकाइयों में हिसाब अपने आप आ जाएगा।',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else ...[
                // Highlight Calculated Area Banner
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
                        strings.totalCalculatedArea,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${formatIndian(sqft)} ${strings.sqFtLabel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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
                              text: _buildShareText(strings, sqft)));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.copied),
                              duration: const Duration(seconds: 2),
                            ),
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
                const SizedBox(height: 20),

                // List of All Converted Land Units
                ..._units
                    .where((u) => _mode == ConverterMode.lengthWidth || u != _fromUnit)
                    .map(
                      (u) => AccentCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            formatIndian(sqft / u.sqft),
                            style: theme.textTheme.titleLarge?.copyWith(
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200, width: 1),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lang == AppLang.english
                            ? 'Note: Land unit sizes vary by district. Please verify with local revenue records.'
                            : 'ध्यान दें: बीघा, कट्ठा, बिस्वा जैसी इकाइयों के मान ज़िले के अनुसार थोड़े अलग हो सकते हैं। पटवारी / राजस्व रिकॉर्ड से पुष्टि ज़रूर करें।',
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 12, height: 1.3),
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
}
