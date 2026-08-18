import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/app_cubit.dart';
import '../../data/crop_meta.dart';
import '../../data/crops.dart';
import '../../data/india_states.dart';
import '../../data/land_units.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';
import 'crop_picker.dart';

/// खाद-बीज कैलकुलेटर — तीन साफ़ क़दम।
///
/// **क़दम 1** फ़सल चुनिए (खोज पट्टी + 2×2 बड़े कार्ड, ऊपर से नीचे)
/// **क़दम 2** रक़बा भरिए (ऊपर चुनी फ़सल का बड़ा चित्र)
/// **क़दम 3** जवाब — 4 tab में: खाद · बीज · कब डालें · अन्य ज़रूरी
///
/// पहले सब एक ही लंबे पन्ने पर था और फ़सलें एक पतली आड़ी पट्टी में — किसान
/// को 30 बार बग़ल में खिसकाना पड़ता था और नीचे scroll में खो जाता था।
class KhaadScreen extends StatefulWidget {
  /// खेत नापने से आने पर — रकबा और इकाई पहले से भरी हुई
  final double? prefilledArea;
  final String? prefilledUnit;

  const KhaadScreen({super.key, this.prefilledArea, this.prefilledUnit});

  @override
  State<KhaadScreen> createState() => _KhaadScreenState();
}

class _KhaadScreenState extends State<KhaadScreen> {
  /// `null` = अभी फ़सल नहीं चुनी → क़दम 1 दिखेगा
  Crop? _crop;
  final _areaCtrl = TextEditingController();
  String _unit = 'bigha';

  KhaadResult3Tier? _result;
  double _areaHa = 0;

  /// 0 = कम, 1 = सही (default), 2 = ज़्यादा
  int _tier = 1;

  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);

  /// चुनी हुई भाषा का कोड — नाम के अनुवाद के लिए
  String get _lang => AppLocalizations.langCode(context);

  // ── इकाइयाँ (bigha/katha राज्य के हिसाब से) ──────────────────────
  List<Map<String, String>> get _units {
    final stateCode = context.read<AppCubit>().state.stateCode;
    final hasBigha = stateByCode(stateCode).bighaSqFt != null;
    final units = [
      {'code': 'acre', 'label': _t('unitAcre')},
      {'code': 'hectare', 'label': _t('unitHectare')},
      {'code': 'guntha', 'label': _t('unitGuntha')},
      {'code': 'sqm', 'label': _t('unitSqm')},
      {'code': 'sqft', 'label': _t('unitSqft')},
    ];
    if (hasBigha) {
      units.insert(0, {'code': 'bigha', 'label': _t('bigha')});
      units.insert(1, {'code': 'katha', 'label': _t('katha')});
    }
    return units;
  }

  String _unitLabel() =>
      _units.firstWhere((e) => e['code'] == _unit, orElse: () => {'label': ''})['label'] ?? '';

  @override
  void initState() {
    super.initState();
    if (widget.prefilledArea != null) {
      _areaCtrl.text = widget.prefilledArea!.toStringAsFixed(2);
    }
    if (widget.prefilledUnit != null) _unit = widget.prefilledUnit!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasBigha = stateByCode(context.read<AppCubit>().state.stateCode).bighaSqFt != null;
      if (!hasBigha && (_unit == 'bigha' || _unit == 'katha')) {
        setState(() => _unit = 'acre');
      }
    });
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    final crop = _crop;
    final area = double.tryParse(_areaCtrl.text.trim()) ?? 0;
    if (crop == null || area <= 0) {
      setState(() {
        _result = null;
        _areaHa = 0;
      });
      return;
    }
    final bighaSqFt = stateByCode(context.read<AppCubit>().state.stateCode).bighaSqFt;
    var unit = _unit;
    if (bighaSqFt == null && (unit == 'bigha' || unit == 'katha')) unit = 'acre';
    final ha = toHectares(value: area, unitCode: unit, bighaSqFt: bighaSqFt);
    setState(() {
      _areaHa = ha;
      _result = computeKhaad3Tier(crop: crop, areaHa: ha);
    });
  }

  void _adjustArea(double delta) {
    final v = ((double.tryParse(_areaCtrl.text.trim()) ?? 0) + delta).clamp(0.0, 999.0);
    setState(() => _areaCtrl.text = v == 0 ? '' : v.toStringAsFixed(1));
    _calc();
  }

  // ═══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final crop = _crop;
    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(
        title: Text(_t('khaadTitle')),
        leading: crop != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: _isHi ? 'फ़सल बदलें' : 'Change crop',
                onPressed: () => setState(() {
                  _crop = null;
                  _result = null;
                }),
              )
            : null,
      ),
      body: SafeArea(
        child: crop == null ? _step1ChooseCrop() : _step2And3(crop),
      ),
    );
  }

  // ── क़दम 1: फ़सल चुनिए ─────────────────────────────────────────────
  Widget _step1ChooseCrop() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isHi ? 'पहले फ़सल चुनिए' : 'First choose your crop',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              _isHi
                  ? 'फ़सल पर उँगली रखते ही अगला क़दम आ जाएगा'
                  : 'Tap a crop and the next step opens',
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            CropPicker(
              selected: _crop,
              onPicked: (c) {
                setState(() => _crop = c);
                _calc();
              },
            ),
          ],
        ),
      );

  // ── क़दम 2 + 3 ────────────────────────────────────────────────────
  Widget _step2And3(Crop crop) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _chosenCropHeader(crop),
            const SizedBox(height: 16),
            _areaCard(),
            if (_result == null) ...[
              const SizedBox(height: 24),
              _emptyHint(),
            ] else ...[
              const SizedBox(height: 18),
              _tierChips(),
              const SizedBox(height: 14),
              _ResultTabs(
                crop: crop,
                areaHa: _areaHa,
                tier: _tier,
                result: _result!,
                isHi: _isHi,
                t: _t,
                areaLabel: '${_areaCtrl.text.trim()} ${_unitLabel()}',
              ),
            ],
            const SizedBox(height: 18),
            _sourceNote(crop, _isHi),
            const SizedBox(height: 8),
            _disclaimer(_t('khaadDisclaimer')),
          ],
        ),
      );

  /// चुनी हुई फ़सल — बड़ा चित्र + "बदलें"
  Widget _chosenCropHeader(Crop crop) {
    final img = cropImage(crop.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DairyTheme.primaryTeal.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: img == null
                ? Center(child: Text(cropEmoji(crop.id), style: const TextStyle(fontSize: 48)))
                : Image.asset(
                    img,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Text(cropEmoji(crop.id), style: const TextStyle(fontSize: 48))),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.name(_isHi, _lang),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  crop.seasonName(_isHi),
                  style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _crop = null;
              _result = null;
            }),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text(_isHi ? 'बदलें' : 'Change'),
          ),
        ],
      ),
    );
  }

  Widget _areaCard() => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isHi ? 'खेत कितना है?' : 'How big is the field?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _areaCtrl,
                      autofocus: false,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '0',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (_) => _calc(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        for (final u in _units)
                          DropdownMenuItem(value: u['code'], child: Text(u['label']!)),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _unit = v);
                        _calc();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Wrap — छोटे फ़ोन पर चारों बटन एक पंक्ति में नहीं समाते थे
              // (जाँच में 9 pixel बाहर निकल रहे थे)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _quickBtn(-1, '−1'),
                  _quickBtn(-0.5, '−0.5'),
                  _quickBtn(0.5, '+0.5'),
                  _quickBtn(1, '+1'),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _quickBtn(double delta, String label) => ActionChip(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: DairyTheme.primaryTeal)),
        backgroundColor: Colors.white,
        side: BorderSide(color: DairyTheme.primaryTeal.withValues(alpha: 0.3)),
        onPressed: () => _adjustArea(delta),
      );

  Widget _emptyHint() => Center(
        child: Column(
          children: [
            Icon(Icons.grass_rounded, size: 46, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              _t('khaadEnterArea'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );

  Widget _tierChips() {
    final labels = [_t('tierLow'), _t('tierRight'), _t('tierHigh')];
    final descs = [_t('tierLowDesc'), _t('tierRightDesc'), _t('tierHighDesc')];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _tier == i ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    selected: _tier == i,
                    showCheckmark: false,
                    selectedColor: DairyTheme.primaryTeal,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onSelected: (_) => setState(() => _tier = i),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(descs[_tier], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// नतीजा — 4 tab
// ═════════════════════════════════════════════════════════════════════

class _ResultTabs extends StatelessWidget {
  final Crop crop;
  final double areaHa;
  final int tier;
  final KhaadResult3Tier result;
  final bool isHi;
  final String Function(String) t;
  final String areaLabel;

  const _ResultTabs({
    required this.crop,
    required this.areaHa,
    required this.tier,
    required this.result,
    required this.isHi,
    required this.t,
    required this.areaLabel,
  });

  KhaadResult get _r => [result.min, result.recommended, result.max][tier];

  /// emoji ऊपर, नाम नीचे — चारों tab तंग फ़ोन में भी समा जाते हैं
  Widget _tab(String emoji, String label) => Tab(
        height: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            // चारों tab एक साथ दिखने चाहिए। पहले `isScrollable: true` था और
            // छोटे फ़ोन पर चौथा ("अन्य ज़रूरी") पर्दे से बाहर रह जाता था —
            // किसान को पता ही नहीं चलता कि वहाँ कुछ और भी है।
            child: TabBar(
              labelColor: DairyTheme.primaryTeal,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: DairyTheme.primaryTeal,
              indicatorWeight: 3,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontSize: 12.5),
              tabs: [
                _tab('🧪', isHi ? 'खाद' : 'Fertilizer'),
                _tab('🌱', isHi ? 'बीज' : 'Seed'),
                _tab('📅', isHi ? 'कब डालें' : 'When'),
                _tab('💊', isHi ? 'अन्य ज़रूरी' : 'Extras'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ऊँचाई तय नहीं कर सकते (हर tab अलग लंबाई का), इसलिए भीतर scroll नहीं —
          // पूरा पन्ना ही scroll होता है।
          _AutoHeightTabs(
            children: [
              _fertilizerTab(context),
              _seedTab(context),
              _whenTab(context),
              _extrasTab(context),
            ],
          ),
        ],
      ),
    );
  }

  // ── 🧪 खाद ──────────────────────────────────────────────────────
  Widget _fertilizerTab(BuildContext context) {
    final r = _r;
    return _card(
      children: [
        Text('${crop.name(isHi, AppLocalizations.langCode(context))} · $areaLabel',
            style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700)),
        const Divider(height: 20),
        _fertRow('🌿', t('ureaFull'), r.ureaKg, r.ureaBags),
        const SizedBox(height: 12),
        _fertRow('🧪', t('dapFull'), r.dapKg, r.dapBags),
        const SizedBox(height: 12),
        _fertRow('🔶', t('mopFull'), r.mopKg, r.mopBags),
        if (r.hasSspRoute) ...[
          const Divider(height: 26),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isHi ? 'बेहतर रास्ता — DAP की जगह SSP' : 'Better option — SSP instead of DAP',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isHi
                      ? 'यह फ़सल गंधक माँगती है। SSP में फ़ॉस्फ़ोरस के साथ गंधक भी आता है — DAP में नहीं।'
                      : 'This crop needs sulphur. SSP supplies phosphorus AND sulphur — DAP does not.',
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: 10),
                _fertRow('🟤', isHi ? 'SSP' : 'SSP', r.sspKg, r.sspBags),
                const SizedBox(height: 10),
                _fertRow('🌿', t('ureaFull'), r.ureaWithSspKg, r.ureaWithSspBags),
                const SizedBox(height: 10),
                Text(
                  isHi
                      ? '✓ इससे ${r.sulphurFromSspKg.toStringAsFixed(1)} किलो गंधक मुफ़्त मिल जाएगी'
                      : '✓ This gives ${r.sulphurFromSspKg.toStringAsFixed(1)} kg sulphur free',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                ),
                if (r.gypsumKg > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isHi
                          ? '+ ${r.gypsumKg.toStringAsFixed(0)} किलो जिप्सम और डालिए'
                          : '+ add ${r.gypsumKg.toStringAsFixed(0)} kg gypsum',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── 🌱 बीज ──────────────────────────────────────────────────────
  Widget _seedTab(BuildContext context) {
    final kindLabel = switch (crop.seedKind) {
      SeedKind.seed => isHi ? 'बीज' : 'Seed',
      SeedKind.tuber => isHi ? 'बीज (कंद)' : 'Seed (tubers)',
      SeedKind.setts => isHi ? 'बीज (टुकड़े)' : 'Seed (setts)',
      SeedKind.saplings => isHi ? 'पौधे' : 'Saplings',
    };

    return _card(
      children: [
        if (crop.seedKind == SeedKind.saplings) ...[
          _bigNumber(
            kindLabel,
            '${(crop.plantsPerHa * areaHa).round()}',
            isHi ? 'पौधे' : 'plants',
            Icons.park_rounded,
          ),
        ] else ...[
          _bigNumber(
            kindLabel,
            _seedText(crop.seedMinKgHa * areaHa, crop.seedMaxKgHa * areaHa),
            _seedUnit(),
            Icons.grain_rounded,
          ),
          const SizedBox(height: 6),
          Text(
            isHi
                ? 'सही मात्रा: ${_fmtSeed(crop.seedKgHa * areaHa)} ${_seedUnit()}'
                : 'Recommended: ${_fmtSeed(crop.seedKgHa * areaHa)} ${_seedUnit()}',
            style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
          ),
        ],
        if (crop.spacing(isHi) != null) ...[
          const Divider(height: 24),
          _infoRow(Icons.straighten_rounded, isHi ? 'दूरी और तरीक़ा' : 'Spacing & method',
              crop.spacing(isHi)!),
        ],
        if (crop.seedTreatment(isHi) != null) ...[
          const Divider(height: 24),
          _infoRow(Icons.shield_rounded, isHi ? 'बीज उपचार' : 'Seed treatment',
              crop.seedTreatment(isHi)!,
              color: Colors.deepPurple),
        ],
      ],
    );
  }

  String _seedUnit() => switch (crop.seedKind) {
        SeedKind.tuber => isHi ? 'क्विंटल' : 'quintal',
        SeedKind.setts => isHi ? 'टन' : 'tonne',
        _ => t('kg'),
      };

  double _seedScale() => switch (crop.seedKind) {
        SeedKind.tuber => 0.01, // किलो → क्विंटल
        SeedKind.setts => 0.001, // किलो → टन
        _ => 1,
      };

  String _fmtSeed(double kg) {
    final v = kg * _seedScale();
    return v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(v < 10 ? 2 : 1);
  }

  String _seedText(double minKg, double maxKg) {
    if (minKg <= 0 || (maxKg - minKg).abs() < 0.001) return _fmtSeed(crop.seedKgHa * areaHa);
    return '${_fmtSeed(minKg)} – ${_fmtSeed(maxKg)}';
  }

  // ── 📅 कब डालें ─────────────────────────────────────────────────
  Widget _whenTab(BuildContext context) {
    final rows = computeSplitPlan(crop: crop, areaHa: areaHa, tier: _r);
    if (rows.isEmpty) {
      return _card(children: [Text(crop.splits(isHi), style: const TextStyle(fontSize: 14, height: 1.5))]);
    }
    return _card(
      children: [
        Text(
          isHi
              ? 'एक साथ पूरी खाद मत डालिए — नीचे लिखे हिसाब से बाँटिए।'
              : 'Do not apply everything at once — split it as below.',
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 22),
          _splitRow(i + 1, rows[i]),
        ],
      ],
    );
  }

  Widget _splitRow(int n, SplitRow row) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: DairyTheme.primaryTeal, shape: BoxShape.circle),
            child: Text('$n',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.when(isHi),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (row.isEmpty)
                  Text(isHi ? '— कुछ नहीं —' : '— nothing —',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (row.ureaKg > 0)
                        _pill('🌿 ${t('ureaFull')}', row.ureaKg, Colors.green),
                      if (row.dapKg > 0) _pill('🧪 ${t('dapFull')}', row.dapKg, Colors.orange),
                      if (row.mopKg > 0) _pill('🔶 ${t('mopFull')}', row.mopKg, Colors.red),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );

  Widget _pill(String label, double kg, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withValues(alpha: 0.3)),
        ),
        child: Text(
          '$label  ${kg.toStringAsFixed(kg < 10 ? 1 : 0)} ${t('kg')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c),
        ),
      );

  // ── 💊 अन्य ज़रूरी ───────────────────────────────────────────────
  Widget _extrasTab(BuildContext context) {
    final e = computeExtras(crop: crop, areaHa: areaHa);
    return _card(
      children: [
        if (e.fymTon > 0)
          _extraRow(
            '🐄',
            isHi ? 'गोबर की खाद / कम्पोस्ट' : 'Farmyard manure / compost',
            '${e.fymTon.toStringAsFixed(e.fymTon < 10 ? 1 : 0)} ${isHi ? "टन" : "tonne"}',
            isHi
                ? 'बुवाई से 3-4 हफ़्ते पहले खेत में मिला दीजिए। यही मिट्टी को ज़िंदा रखती है।'
                : 'Mix into the field 3-4 weeks before sowing. This is what keeps soil alive.',
          ),
        if (e.sulphurKg > 0) ...[
          const Divider(height: 24),
          _extraRow(
            '🟡',
            isHi ? 'गंधक (सल्फ़र)' : 'Sulphur',
            '${e.sulphurKg.toStringAsFixed(0)} ${t('kg')}',
            isHi
                ? 'SSP लेने पर बहुत हद तक इसी से पूरी हो जाती है — "खाद" tab देखिए।'
                : 'Largely covered if you use SSP — see the Fertilizer tab.',
          ),
        ],
        if (e.zincSulphateKg > 0) ...[
          const Divider(height: 24),
          _extraRow(
            '⚪',
            isHi ? 'ज़िंक सल्फ़ेट' : 'Zinc sulphate',
            '${e.zincSulphateKg.toStringAsFixed(0)} ${t('kg')}',
            isHi
                ? 'हर दूसरे साल, बुवाई से 15 दिन पहले। भारत की 40% से ज़्यादा मिट्टी में ज़िंक की कमी है।'
                : 'Every second year, 15 days before sowing. Over 40% of Indian soils are zinc-deficient.',
          ),
        ],
        if (e.boraxKg > 0) ...[
          const Divider(height: 24),
          _extraRow(
            '🔵',
            isHi ? 'बोरेक्स (बोरॉन)' : 'Borax (boron)',
            '${e.boraxKg.toStringAsFixed(0)} ${t('kg')}',
            isHi
                ? 'बुवाई/रोपाई पर मिट्टी में। कमी से तना खोखला और बीच भूरा हो जाता है।'
                : 'Into soil at sowing/transplanting. Deficiency causes hollow stems and brown cores.',
          ),
        ],
        if (crop.seedTreatment(isHi) != null) ...[
          const Divider(height: 24),
          _extraRow(
            '🧫',
            isHi ? 'जीवाणु खाद / बीज उपचार' : 'Biofertilizer / seed treatment',
            '',
            crop.seedTreatment(isHi)!,
          ),
        ],
        if (e.isEmpty && crop.seedTreatment(isHi) == null)
          Text(
            isHi ? 'इस फ़सल के लिए कोई अलग सामग्री नहीं चाहिए।' : 'Nothing extra needed for this crop.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  // ── छोटे हिस्से ──────────────────────────────────────────────────
  Widget _card({required List<Widget> children}) => Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );

  Widget _fertRow(String emoji, String name, double kg, double bags) => Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${bags.toStringAsFixed(1)} ${t('bagShort')}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: DairyTheme.primaryTeal)),
              Text('${kg.toStringAsFixed(1)} ${t('kg')}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ],
      );

  Widget _bigNumber(String label, String value, String unit, IconData icon) => Row(
        children: [
          Icon(icon, size: 30, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.brown)),
                Text(unit, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      );

  Widget _infoRow(IconData icon, String title, String body, {Color color = DairyTheme.primaryTeal}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 13.5, height: 1.45)),
              ],
            ),
          ),
        ],
      );

  Widget _extraRow(String emoji, String title, String amount, String note) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
              ),
              if (amount.isNotEmpty)
                Text(amount,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w800, color: DairyTheme.primaryTeal)),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(note,
                style: TextStyle(fontSize: 13, height: 1.45, color: Colors.grey.shade700)),
          ),
        ],
      );
}

/// TabBarView को अपने आप ऊँचाई लेने देता है।
///
/// सादा `TabBarView` को तय ऊँचाई चाहिए — भीतर scroll करना पड़ता, जो एक पन्ने
/// के अंदर दूसरा scroll बना देता (किसान के लिए उलझन)। इसलिए एक बार में सिर्फ़
/// चुना हुआ tab बनाते हैं और पूरा पन्ना ही scroll होता है।
class _AutoHeightTabs extends StatefulWidget {
  final List<Widget> children;
  const _AutoHeightTabs({required this.children});

  @override
  State<_AutoHeightTabs> createState() => _AutoHeightTabsState();
}

class _AutoHeightTabsState extends State<_AutoHeightTabs> {
  TabController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = DefaultTabController.of(context);
    if (c != _ctrl) {
      _ctrl?.removeListener(_onTab);
      _ctrl = c..addListener(_onTab);
    }
  }

  void _onTab() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onTab);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.children[_ctrl?.index.clamp(0, widget.children.length - 1) ?? 0];
}

// ═════════════════════════════════════════════════════════════════════

/// हर फ़सल के आँकड़े कहाँ से आए — नीचे छोटे अक्षरों में, ⭑ के साथ।
///
/// एक सामान्य लाइन काफ़ी नहीं थी: गेहूं का स्रोत ICAR-IIWBR करनाल है और
/// चना का ICAR-IIPR कानपुर। किसान (या कोई जाँचने वाला) देख सके कि *इस*
/// आँकड़े की ज़िम्मेदारी किस संस्थान की है।
Widget _sourceNote(Crop crop, bool isHi) {
  final verified = crop.isVerified;
  final text = verified
      ? '⭑ ${isHi ? "स्रोत" : "Source"}: ${crop.source}'
      : (isHi
          ? '⭑ इस फ़सल के आँकड़े सामान्य सिफ़ारिश पर आधारित हैं — अभी किसी संस्थान से मिलाए नहीं गए।'
          : '⭑ Figures for this crop are general guidance — not yet matched to an institute source.');
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: verified
          ? DairyTheme.primaryTeal.withValues(alpha: 0.06)
          : Colors.grey.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      border: Border(
        left: BorderSide(color: verified ? DairyTheme.primaryTeal : Colors.grey, width: 3),
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: verified ? Colors.teal.shade900 : Colors.grey.shade700,
      ),
    ),
  );
}

Widget _disclaimer(String text) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
