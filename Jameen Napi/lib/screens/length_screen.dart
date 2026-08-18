import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import '../data/length_units.dart';
import '../services/ad_service.dart';
import '../widgets/accent_card.dart';
import '../widgets/banner_ad_widget.dart';

class LengthScreen extends StatefulWidget {
  const LengthScreen({super.key});

  @override
  State<LengthScreen> createState() => _LengthScreenState();
}

class _LengthScreenState extends State<LengthScreen> {
  final _inputController = TextEditingController(text: '100');
  // Look the default up by name so it survives any reordering of `lengthUnits`.
  LengthUnit _selectedFromUnit =
      lengthUnits.firstWhere((u) => u.en == 'Feet', orElse: () => lengthUnits.first);

  final ScrollController _scrollController = ScrollController();
  final FocusNode _lengthFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _lengthFocusNode.addListener(_autoScroll);
  }

  void _autoScroll() {
    if (_lengthFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            100.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _lengthFocusNode.dispose();
    super.dispose();
  }

  double get _inputValue => double.tryParse(_inputController.text) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputVal = _inputValue;
    final totalFeet = inputVal * _selectedFromUnit.feet;

    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final s = AppStrings(lang);

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
                title: Text(s.toolLength),
              ),
              body: SafeArea(
                top: false,
                bottom: true,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
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
                            s.lengthEnterHeading,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  focusNode: _lengthFocusNode,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: s.lengthInputLabel,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<LengthUnit>(
                                  initialValue: _selectedFromUnit,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: s.selectUnit,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  items: lengthUnits.map((u) {
                                    return DropdownMenuItem(
                                      value: u,
                                      child: Text(
                                        u.label,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedFromUnit = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                s.lengthOtherUnits,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...lengthUnits.map((targetUnit) {
                final isSelected = targetUnit == _selectedFromUnit;
                final convertedValue =
                    targetUnit.feet == 0 ? 0.0 : totalFeet / targetUnit.feet;
                final formatted = formatIndian(convertedValue);
                final unitName = s.isEn ? targetUnit.en : targetUnit.hi;

                return AccentCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  background: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                  accentColor: isSelected
                      ? const Color(0xFF0D47A1)
                      : const Color(0xFF1565C0),
                  accentWidth: isSelected ? 6.0 : 4.5,
                  borderColor: isSelected
                      ? const Color(0xFFBBDEFB)
                      : Colors.grey.shade100,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text(
                      targetUnit.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      s.isEn ? targetUnit.en : targetUnit.hi,
                      style: const TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatted,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFF1565C0),
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.copy_rounded, size: 18, color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade400),
                          tooltip: s.copy,
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: '$formatted $unitName'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('$formatted $unitName — ${s.copied}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBDEFB), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          s.lengthInfoTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...s.lengthInfoLines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          line,
                          style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 13, height: 1.3),
                        ),
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
