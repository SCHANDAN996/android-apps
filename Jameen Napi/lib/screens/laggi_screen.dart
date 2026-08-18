import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import '../data/plot_units.dart';
import '../data/tool_strings.dart';
import '../services/ad_service.dart';
import '../widgets/accent_card.dart';
import '../widgets/banner_ad_widget.dart';

class LaggiScreen extends StatefulWidget {
  const LaggiScreen({super.key});

  @override
  State<LaggiScreen> createState() => _LaggiScreenState();
}

class _LaggiScreenState extends State<LaggiScreen> {
  double _haath = 5.5; // Default: 5.5 haath (8.25 ft / 99 inches)
  final TextEditingController _customHaathController = TextEditingController(text: '5.5');
  bool _isCustom = false;

  // Presets of common Laggi sizes in India
  final List<double> _presets = [4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0];

  @override
  void dispose() {
    _customHaathController.dispose();
    super.dispose();
  }

  LaggiInfo get _info => LaggiInfo.fromHaath(_haath);

  String _buildShareText(AppStrings strings, LaggiInfo info) {
    final buffer = StringBuffer();
    final haath = strings.lagHaathChip('${info.haath}');
    buffer.writeln(strings.lagShareTitle);
    buffer.writeln(
        '${strings.lagShareLength}: $haath (${formatIndian(info.feet)} ${strings.plotUnitName(PlotUnit.feet)} / ${formatIndian(info.inches)} ${strings.inches})');
    buffer.writeln('----------------------------------');
    buffer.writeln('• 1 धुरकी (Dhurki) = ${formatIndian(info.dhurkiSqFt)} ${strings.sqFt}');
    buffer.writeln('• 1 धुर (Dhur) = ${formatIndian(info.dhurSqFt)} ${strings.sqFt} (${formatIndian(info.dhurSqFt / 9.0)} ${strings.sqGaj})');
    buffer.writeln('• 1 कट्ठा (Katha) = ${formatIndian(info.kathaSqFt)} ${strings.sqFt} (${formatIndian(info.kathaSqFt / 9.0)} ${strings.sqGaj})');
    buffer.writeln('• 1 बीघा (Bigha) = ${formatIndian(info.bighaSqFt)} ${strings.sqFt} (${formatIndian(info.bighaSqFt / 9.0)} ${strings.sqGaj})');
    buffer.writeln('----------------------------------');
    buffer.writeln('• 1 कट्ठा (Katha) = ${formatIndian(info.dismilPerKatha)} ${strings.dismil}');
    buffer.writeln('• 1 बीघा (Bigha) = ${formatIndian(info.dismilPerBigha)} ${strings.dismil}');
    buffer.writeln('• ${strings.lagInAcre} = ${formatIndian(info.kathaPerAcre)} कट्ठा (${formatIndian(info.bighaPerAcre)} बीघा)');
    buffer.writeln('----------------------------------');
    buffer.writeln(strings.sharedFromApp);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = _info;

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
                title: Text(strings.toolLaggi),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    // Intro Card
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
                          Text(
                            strings.lagChooseLaggi,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.lagHaathNote,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                          const SizedBox(height: 14),

                          // Presets Chips Wrap
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _presets.map((h) {
                              final isSelected = !_isCustom && _haath == h;
                              return ChoiceChip(
                                label: Text(strings.lagHaathChip('$h')),
                                selected: isSelected,
                                selectedColor: const Color(0xFF2E7D32),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (sel) {
                                  if (sel) {
                                    setState(() {
                                      _isCustom = false;
                                      _haath = h;
                                      _customHaathController.text = h.toString();
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Custom input option
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _customHaathController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  decoration: InputDecoration(
                                    labelText: strings.lagCustomHaath,
                                    suffixText: strings.lagHaathSuffix,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  onChanged: (val) {
                                    final parsed = double.tryParse(val.trim());
                                    if (parsed != null && parsed > 0) {
                                      setState(() {
                                        _isCustom = true;
                                        _haath = parsed;
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
                    const SizedBox(height: 16),

                    // Highlight Hero Summary
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
                            strings.lagTotalLength('$_haath'),
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatIndian(info.feet)} ${strings.plotUnitName(PlotUnit.feet)}  (${formatIndian(info.feet / 3.0)} ${strings.plotUnitName(PlotUnit.gaj)})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '1 धुर = ${formatIndian(info.dhurSqFt)} ${strings.sqFt}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Copy & Share
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
                              Clipboard.setData(ClipboardData(text: _buildShareText(strings, info)));
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
                              Share.share(_buildShareText(strings, info));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scale Calculation Cards
                    Text(
                      strings.lagAllUnits('$_haath'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    _buildUnitCard('1 धुर (Dhur)', '${formatIndian(info.dhurSqFt)} ${strings.sqFt}', '${formatIndian(info.dhurSqFt / 9.0)} ${strings.sqGaj} • ${formatIndian(info.dhurSqFt / 10.7639104)} ${strings.sqMeter}'),
                    _buildUnitCard('1 कट्ठा (Katha) = 20 धुर', '${formatIndian(info.kathaSqFt)} ${strings.sqFt}', '${formatIndian(info.kathaSqFt / 9.0)} ${strings.sqGaj} • ${formatIndian(info.dismilPerKatha)} ${strings.dismil}'),
                    _buildUnitCard('1 बीघा (Bigha) = 20 कट्ठा', '${formatIndian(info.bighaSqFt)} ${strings.sqFt}', '${formatIndian(info.bighaSqFt / 9.0)} ${strings.sqGaj} • ${formatIndian(info.dismilPerBigha)} ${strings.dismil}'),
                    _buildUnitCard(strings.lagInAcre, '${formatIndian(info.kathaPerAcre)} कट्ठा', '${formatIndian(info.bighaPerAcre)} बीघा • 100 ${strings.dismil}'),
                    _buildUnitCard('1 धुरकी (Dhurki) = 1/20 धुर', '${formatIndian(info.dhurkiSqFt)} ${strings.sqFt}', '${formatIndian(info.dhurkiSqFt * 144.0)} ${strings.sqInch}'),

                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              strings.lagAminFormula,
                              style: TextStyle(color: Colors.amber.shade900, fontSize: 12, height: 1.35),
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

  Widget _buildUnitCard(String title, String mainValue, String subValue) {
    return AccentCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          mainValue,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13)),
            if (subValue.isNotEmpty)
              Text(subValue, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
