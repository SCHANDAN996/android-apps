import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/strings.dart';
import '../core/math/extra_calculators.dart';
import '../core/services/ad_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/indian_formatter.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/length_field.dart';
import '../widgets/shared_widgets.dart';

/// How many litres a water tank holds — square or round.
class WaterTankScreen extends StatefulWidget {
  final StorageService storage;
  const WaterTankScreen({super.key, required this.storage});

  @override
  State<WaterTankScreen> createState() => _WaterTankScreenState();
}

class _WaterTankScreenState extends State<WaterTankScreen> {
  static const Color _color = Color(0xFF0277BD);

  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _diameterCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  String _unit = 'ft';
  bool _round = false;

  /// Litres, once calculated.
  double? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _diameterCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _clearResult() {
    if (_result != null) setState(() => _result = null);
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    double? meters(TextEditingController c) {
      final v = double.tryParse(c.text);
      return v != null && v > 0 ? UnitConverter.toMeters(v, _unit) : null;
    }

    final height = meters(_heightCtrl);
    final double? litres;
    if (_round) {
      final diameter = meters(_diameterCtrl);
      litres = diameter == null || height == null
          ? null
          : WaterTankCalculator.roundLitres(
              diameterM: diameter,
              heightM: height,
            );
    } else {
      final length = meters(_lengthCtrl);
      final width = meters(_widthCtrl);
      litres = length == null || width == null || height == null
          ? null
          : WaterTankCalculator.rectangularLitres(
              lengthM: length,
              widthM: width,
              heightM: height,
            );
    }
    if (litres == null) {
      showInputError(context);
      return;
    }
    setState(() => _result = litres);
    AdService().onCalculationComplete(repeat: repeat);
  }

  String _litres(double v) =>
      '${IndianFormatter.format(v)} ${AppStrings.get('litres')}';

  String _buildShareText() {
    final size = _round
        ? '${AppStrings.get('tankDiameter')}: ${lengthLabel(_diameterCtrl.text, _unit)}'
        : '${lengthLabel(_lengthCtrl.text, _unit)} × ${lengthLabel(_widthCtrl.text, _unit)}';
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '💧 ${AppStrings.get('waterTank')}\n';
    text += '$size × ${lengthLabel(_heightCtrl.text, _unit)}\n\n';
    text += '📊 ${AppStrings.get('result')}: ${_litres(_result!)}\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('waterTank'))),
      bottomNavigationBar: const BannerAdWidget(),
      body: CalculatorPageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  OptionChips<bool>(
                    options: const [false, true],
                    selected: _round,
                    labelBuilder: (round) =>
                        AppStrings.get(round ? 'roundTank' : 'rectTank'),
                    onSelected: (v) => setState(() {
                      _round = v;
                      _result = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  if (_round)
                    LengthField(
                      controller: _diameterCtrl,
                      label: AppStrings.get('tankDiameter'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    )
                  else ...[
                    LengthField(
                      controller: _lengthCtrl,
                      label: AppStrings.get('length'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                    const SizedBox(height: 14),
                    LengthField(
                      controller: _widthCtrl,
                      label: AppStrings.get('width'),
                      unit: _unit,
                      onChanged: (_) => _clearResult(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _heightCtrl,
                    label: AppStrings.get('height'),
                    unit: _unit,
                    onChanged: (_) => _clearResult(),
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
    final litres = _result!;
    final m3 = litres / WaterTankCalculator.litresPerM3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('waterTank'),
          value: _litres(litres),
          countTo: litres,
          countFormat: _litres,
          icon: Icons.water_drop_rounded,
          color: _color,
        ),
        const SizedBox(height: 16),
        FormSurface(
          child: Column(
            children: [
              ResultRow(
                label: '${AppStrings.get('volume')} (cft)',
                value: UnitConverter.cubicMetersToCFT(m3).toStringAsFixed(1),
                icon: Icons.view_in_ar_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: '${AppStrings.get('volume')} (m³)',
                value: m3.toStringAsFixed(2),
                icon: Icons.view_in_ar_outlined,
              ),
            ],
          ),
        ),
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
        const DisclaimerFooter(),
      ],
    );
  }
}
