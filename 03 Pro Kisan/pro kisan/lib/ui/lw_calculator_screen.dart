import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../data/india_states.dart';
import '../l10n/app_localizations.dart';
import '../services/land_measurement_service.dart';
import 'khaad/khaad_screen.dart';
import 'theme/dairy_theme.dart';

/// 📐 लंबाई × चौड़ाई कैलकुलेटर — BottomSheet
///
/// किसान "10 लट्ठा × 8 लट्ठा" जैसा डालता है, तुरंत बीघा/एकड़/हेक्टेयर दिखता है।
/// GPS की कोई ज़रूरत नहीं — गाँव में 90% खेत चौकोर होते हैं।
class LWCalculatorSheet extends StatefulWidget {
  const LWCalculatorSheet({super.key});

  /// BottomSheet खोलने का shortcut
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LWCalculatorSheet(),
    );
  }

  @override
  State<LWCalculatorSheet> createState() => _LWCalculatorSheetState();
}

class _LWCalculatorSheetState extends State<LWCalculatorSheet> {
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();

  /// default unit = लट्ठा (गाँव में सबसे आम)
  String _unit = 'latha';

  /// rectangle / triangle
  String _shape = 'rectangle';

  AreaResult? _result;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final l = double.tryParse(_lengthCtrl.text.trim());
    final w = double.tryParse(_widthCtrl.text.trim());
    if (l == null || w == null || l <= 0 || w <= 0) {
      setState(() => _result = null);
      return;
    }
    final stateCode = context.read<AppCubit>().state.stateCode;
    setState(() {
      _result = LandMeasurementService.calculateFromLW(
        length: l,
        width: w,
        unit: _unit,
        shape: _shape,
        stateCode: stateCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final stateCode = context.watch<AppCubit>().state.stateCode;
    final bighaSqFt = stateByCode(stateCode).bighaSqFt;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ──
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── title ──
            Row(
              children: [
                const Icon(Icons.straighten_rounded,
                    color: DairyTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  _t('landLxW'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Shape Selector ──
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'rectangle',
                  label: Text(_t('landRectangle')),
                  icon: const Icon(Icons.crop_square_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'triangle',
                  label: Text(_t('landTriangle')),
                  icon: const Icon(Icons.change_history_rounded, size: 18),
                ),
              ],
              selected: {_shape},
              onSelectionChanged: (v) {
                setState(() => _shape = v.first);
                _calculate();
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    DairyTheme.primaryTeal.withValues(alpha: 0.15),
                selectedForegroundColor: DairyTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 14),

            // ── Unit Selector ──
            Row(
              children: [
                Text('${_t('landUnit')}:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(width: 10),
                Expanded(
                  child: _unitChipRow(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Length & Width inputs ──
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    label: _shape == 'triangle'
                        ? _t('landBase')
                        : _t('landLength'),
                    controller: _lengthCtrl,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('×',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400)),
                ),
                Expanded(
                  child: _inputField(
                    label: _shape == 'triangle'
                        ? _t('landHeight')
                        : _t('landWidth'),
                    controller: _widthCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Calculate button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: Text(_t('landCalcBtn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DairyTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // ── Result Card ──
            if (_result != null && !_result!.isEmpty) ...[
              const SizedBox(height: 18),
              _resultCard(bighaSqFt),
            ],
          ],
        ),
      ),
    );
  }

  Widget _unitChipRow() {
    const units = [
      {'code': 'latha', 'emoji': '📏'},
      {'code': 'feet', 'emoji': '👣'},
      {'code': 'meter', 'emoji': '📐'},
      {'code': 'yard', 'emoji': '🧶'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: units.map((u) {
          final code = u['code']!;
          final selected = _unit == code;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text('${u['emoji']} ${_t('landUnit_$code')}'),
              selected: selected,
              onSelected: (_) {
                setState(() => _unit = code);
                _calculate();
              },
              selectedColor: DairyTheme.primaryTeal.withValues(alpha: 0.18),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? DairyTheme.primaryTeal : Colors.grey.shade700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onChanged: (_) => _calculate(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _resultCard(double? bighaSqFt) {
    final r = _result!;
    final sqFt = r.squareMeters * 10.7639;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DairyTheme.primaryTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: DairyTheme.primaryTeal.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(_t('landMeasureResult'),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DairyTheme.primaryTeal)),
          const SizedBox(height: 10),

          // बड़े आँकड़े
          Row(
            children: [
              if (r.bigha != null)
                _stat(_t('landMeasureBigha'), r.bigha!.toStringAsFixed(2)),
              _stat(_t('landMeasureAcres'), r.acres.toStringAsFixed(3)),
              _stat(_t('landMeasureHectares'), r.hectares.toStringAsFixed(3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${r.squareMeters.toStringAsFixed(0)} ${_t('landMeasureSquareMeters')}'
            '  ·  ${sqFt.toStringAsFixed(0)} ${_t('unitSqft')}'
            '${bighaSqFt != null ? '\n1 ${_t('bigha')} = ${bighaSqFt.toStringAsFixed(0)} ${_t('unitSqft')}' : ''}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            '📏 ${_t('mapPerimeter')}: ${r.perimeterMeters.toStringAsFixed(1)} ${_t('mapMetre')}'
            ' (${(r.perimeterMeters / 0.3048).toStringAsFixed(0)} ${_t('landUnit_feet')})',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 14),

          // 🌾 खाद कैलकुलेटर से लिंक
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context); // sheet बंद करो
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KhaadScreen(
                      prefilledArea: r.bigha ?? r.acres,
                      prefilledUnit: r.bigha != null ? 'bigha' : 'acre',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.grass_rounded, size: 18),
              label: Text(_t('landToKhaad')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: DairyTheme.primaryTeal)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      );
}
