import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/strings.dart';
import '../core/math/extra_calculators.dart';
import '../core/models/project_item.dart';
import '../core/services/ad_service.dart';
import '../core/services/storage_service.dart';
import '../core/utils/indian_formatter.dart';
import '../core/utils/unit_converter.dart';
import '../widgets/add_to_project_button.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/length_field.dart';
import '../widgets/shared_widgets.dart';

/// Earth to dig for a foundation trench or pit.
class ExcavationScreen extends StatefulWidget {
  final StorageService storage;
  const ExcavationScreen({super.key, required this.storage});

  @override
  State<ExcavationScreen> createState() => _ExcavationScreenState();
}

class _ExcavationScreenState extends State<ExcavationScreen> {
  static const Color _color = Color(0xFF6D4C41);

  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _depthCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');
  String _unit = 'ft';
  ExcavationResult? _result;

  @override
  void initState() {
    super.initState();
    _unit = widget.storage.defaultUnit;
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _depthCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _clearResult() {
    if (_result != null) setState(() => _result = null);
  }

  void _calculate() {
    // Tapping Calculate again on an unchanged form is not a new calculation.
    final repeat = _result != null;
    final length = double.tryParse(_lengthCtrl.text);
    final width = double.tryParse(_widthCtrl.text);
    final depth = double.tryParse(_depthCtrl.text);
    final count = int.tryParse(_countCtrl.text);
    if (length == null ||
        length <= 0 ||
        width == null ||
        width <= 0 ||
        depth == null ||
        depth <= 0 ||
        count == null ||
        count <= 0) {
      showInputError(context);
      return;
    }
    setState(() {
      _result = ExcavationCalculator.calculate(
        lengthM: UnitConverter.toMeters(length, _unit),
        widthM: UnitConverter.toMeters(width, _unit),
        depthM: UnitConverter.toMeters(depth, _unit),
        count: count,
      );
    });
    AdService().onCalculationComplete(repeat: repeat);
  }

  String get _inputLine =>
      '${_countCtrl.text} × ${lengthLabel(_lengthCtrl.text, _unit)} × ${lengthLabel(_widthCtrl.text, _unit)} × ${lengthLabel(_depthCtrl.text, _unit)}';

  String _cft(double v) => '${IndianFormatter.format(v, decimals: 1)} cft';

  String _buildShareText() {
    final r = _result!;
    var text = '${AppStrings.get('shareHeader')}\n\n';
    text += '⛏️ ${AppStrings.get('excavation')}\n';
    text += '$_inputLine\n\n';
    text += '📊 ${AppStrings.get('result')}:\n';
    text +=
        '${AppStrings.get('excavationVolume')}: ${_cft(r.volumeCft)} (${r.volumeM3.toStringAsFixed(2)} m³)\n';
    text += '${AppStrings.get('looseSoil')}: ${_cft(r.looseVolumeCft)}\n';
    text += AppStrings.get('shareFooter');
    return text;
  }

  ProjectItem _projectItem() => ProjectItem.create(
    type: 'excavation',
    detail: _inputLine,
    materials: {ProjectMaterial.excavationCft: _result!.volumeCft},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('excavation'))),
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
                  LargeInputField(
                    controller: _countCtrl,
                    label: AppStrings.get('count'),
                    allowDecimal: false,
                    onChanged: (_) => _clearResult(),
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  LengthField(
                    controller: _depthCtrl,
                    label: AppStrings.get('depth'),
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
    final r = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroResultCard(
          label: AppStrings.get('excavationVolume'),
          value: _cft(r.volumeCft),
          countTo: r.volumeCft,
          countFormat: _cft,
          icon: Icons.terrain_rounded,
          color: _color,
        ),
        const SizedBox(height: 16),
        FormSurface(
          child: Column(
            children: [
              ResultRow(
                label: '${AppStrings.get('volume')} (m³)',
                value: r.volumeM3.toStringAsFixed(2),
                icon: Icons.view_in_ar_outlined,
              ),
              const Divider(height: 1),
              ResultRow(
                label: AppStrings.get('looseSoil'),
                value: _cft(r.looseVolumeCft),
                icon: Icons.local_shipping_outlined,
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
