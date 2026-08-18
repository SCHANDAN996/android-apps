import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/pashu_calc.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';
import 'fcr_calc_screen.dart';
import 'my_pashu_screen.dart';
import 'palan_picker_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
// 🏠 PASHU DASHBOARD — 2×2 Premium Card Grid
// ═══════════════════════════════════════════════════════════════════════

class PashuScreen extends StatelessWidget {
  const PashuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    String t(String k) => AppLocalizations.get(context, k);

    return Scaffold(
      appBar: AppBar(title: Text(t('pashuTitle'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 2×2 Main Grid ──
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
              children: [
                _DashCard(
                  title: t('myPashu'),
                  subtitle: isHi ? 'अपने पशु देखें / जोड़ें' : 'View & Add Animals',
                  image: 'assets/images/3d_cattle.webp',
                  gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  icon: Icons.pets_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPashuScreen()),
                  ),
                ),
                _DashCard(
                  title: t('gaabhinCalc'),
                  subtitle: isHi ? 'ब्याने की तारीख निकालें' : 'Calculate Due Date',
                  // गाभिन गाय — भरे पेट वाली। पहले यहाँ बछड़ा लगा था, पर
                  // "गाभिन" का मतलब गाय का गर्भ है, बछड़ा नहीं।
                  image: 'assets/images/3d_gaabhin.webp',
                  gradient: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                  icon: Icons.event_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _GaabhinCalcPage()),
                  ),
                ),
                _DashCard(
                  title: t('aaharCalc'),
                  subtitle: isHi ? 'संतुलित आहार की गणना' : 'Feed Requirement',
                  image: 'assets/images/3d_fodder.webp',
                  gradient: const [Color(0xFFEA580C), Color(0xFFF97316)],
                  icon: Icons.restaurant_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const _AaharCalcPage()),
                  ),
                ),
                _DashCard(
                  title: isHi ? 'पशु पालन गाइड' : 'Farming Guide',
                  subtitle: isHi ? 'बकरी, मुर्गी, मछली…' : 'Goat, Poultry, Fish…',
                  // बकरी + मुर्गी + बत्तख + सूअर — गाइड में 13 जीव हैं,
                  // इसलिए अकेले मुर्गे की जगह कई जीव एक साथ।
                  image: 'assets/images/3d_palan_guide.webp',
                  gradient: const [Color(0xFF059669), Color(0xFF34D399)],
                  icon: Icons.grass_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PalanPickerScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Quick Tools Section ──
            Text(
              isHi ? '⚡ त्वरित उपकरण' : '⚡ Quick Tools',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: DairyTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            _QuickToolTile(
              title: AppLocalizations.get(context, 'fcrCalcTitle'),
              subtitle: isHi
                  ? 'मुर्गी / ब्रॉयलर चारा रूपांतरण अनुपात'
                  : 'Poultry Feed Conversion Ratio',
              emoji: '🧮',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FcrCalcScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 🎴 Dashboard Card Widget
// ═══════════════════════════════════════════════════════════════════════

class _DashCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle circle decoration (top-right)
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3D Image
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          widget.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            widget.icon,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ⚡ Quick Tool Tile
// ═══════════════════════════════════════════════════════════════════════

class _QuickToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  const _QuickToolTile({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DairyTheme.primaryTeal.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DairyTheme.textDark)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 📄 FULL-PAGE ROUTE WRAPPERS
// ═══════════════════════════════════════════════════════════════════════

/// गाभिन कैलकुलेटर — अपनी पूरी screen
class _GaabhinCalcPage extends StatelessWidget {
  const _GaabhinCalcPage();
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'gaabhinCalc')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 36),
          child: const _GaabhinCalc(),
        ),
      ),
    );
  }
}

/// आहार/दाना कैलकुलेटर — अपनी पूरी screen
class _AaharCalcPage extends StatelessWidget {
  const _AaharCalcPage();
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'aaharCalc')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 36),
          child: const _AaharCalc(),
        ),
      ),
    );
  }
}

/// पशु पालन गाइड Grid — अपनी पूरी screen

// ═══════════════════════════════════════════════════════════════════════
// 🔧 HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

String _daysFromNow(DateTime d, BuildContext context) {
  final today = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  final hi = Localizations.localeOf(context).languageCode == 'hi';
  if (diff > 0) return hi ? '$diff दिन बाद' : 'in $diff days';
  if (diff == 0) return hi ? 'आज' : 'today';
  return hi ? '${-diff} दिन पहले' : '${-diff} days ago';
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

// ═══════════════════════════════════════════════════════════════════════
// 🤰 GAABHIN CALCULATOR
// ═══════════════════════════════════════════════════════════════════════

class _GaabhinCalc extends StatefulWidget {
  const _GaabhinCalc();
  @override
  State<_GaabhinCalc> createState() => _GaabhinCalcState();
}

class _GaabhinCalcState extends State<_GaabhinCalc> {
  PashuSpecies _species = kSpeciesCow;
  DateTime? _aiDate;
  PashuMilestones? _result;

  String _t(String k) => AppLocalizations.get(context, k);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _aiDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (d != null) setState(() => _aiDate = d);
  }

  void _calc() {
    if (_aiDate == null) return;
    setState(() => _result = gaabhinMilestonesFor(_aiDate!, _species));
  }

  void _share() {
    final r = _result;
    if (r == null) return;
    final text = '${_species.emoji} ${_t('gaabhinCalc')} — ${_t('appName')}\n'
        '${_t('animalType')}: ${_t(_species.nameKey)}\n'
        '${_t('aiDate')}: ${_fmtDate(_aiDate!)}\n'
        '${_t('expectedDelivery')}: ${_fmtDate(r.expectedDelivery)}\n'
        '${_t('pregCheck')}: ${_fmtDate(r.pregnancyCheck)}\n'
        '${_t('dryOff')}: ${_fmtDate(r.dryOff)}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(_t('animalType'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final sp in kAllSpecies) _animalBtn(sp),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today_rounded),
          label: Text(_aiDate == null ? _t('selectDate') : '${_t('aiDate')}: ${_fmtDate(_aiDate!)}'),
          onPressed: _pickDate,
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
        const SizedBox(height: 14),
        ElevatedButton(onPressed: _aiDate == null ? null : _calc, child: Text(_t('calculate'))),
        if (_result != null) ...[
          const SizedBox(height: 20),
          _resultCard(_t('expectedDelivery'), _result!.expectedDelivery, Icons.child_care_rounded, DairyTheme.primaryTeal),
          _resultCard(_t('pregCheck'), _result!.pregnancyCheck, Icons.health_and_safety_rounded, Colors.blue),
          _resultCard(_t('nextHeat'), _result!.nextHeat, Icons.loop_rounded, Colors.orange),
          if (_species.dryOffBeforeDays > 0)
            _resultCard(_t('dryOff'), _result!.dryOff, Icons.no_drinks_rounded, Colors.brown),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.share),
            label: Text(_t('shareText')),
            onPressed: _share,
          ),
        ],
        const SizedBox(height: 16),
        _disclaimer(_t('vetDisclaimer')),
      ],
    );
  }

  Widget _animalBtn(PashuSpecies sp) {
    final sel = _species.id == sp.id;
    return GestureDetector(
      onTap: () => setState(() {
        _species = sp;
        _result = null;
      }),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: sel
              ? DairyTheme.primaryTeal.withValues(alpha: 0.12)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? DairyTheme.primaryTeal : Colors.grey.shade300,
              width: sel ? 2 : 1),
        ),
        child: Column(
          children: [
            if (sp.imageAsset != null)
              SizedBox(
                width: 44,
                height: 44,
                child: Image.asset(
                  sp.imageAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Text(sp.emoji, style: const TextStyle(fontSize: 26)),
                ),
              )
            else
              Text(sp.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(_t(sp.nameKey),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${sp.gestationDays} ${_t('days')}',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(String label, DateTime date, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(fontSize: 14)),
        subtitle: Text(_fmtDate(date), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text(_daysFromNow(date, context),
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 🌾 AAHAR / DANA CALCULATOR
// ═══════════════════════════════════════════════════════════════════════

class _AaharCalc extends StatefulWidget {
  const _AaharCalc();
  @override
  State<_AaharCalc> createState() => _AaharCalcState();
}

class _AaharCalcState extends State<_AaharCalc> {
  final _milkCtrl = TextEditingController(text: '10');
  final _weightCtrl = TextEditingController(text: '500');
  final _countCtrl = TextEditingController(text: '100');
  final _beeBoxesCtrl = TextEditingController(text: '10');
  bool _latePreg = false;
  bool _isOffSeason = false;
  AaharSpeciesItem _selectedSpecies = kAaharSpeciesList.first;
  FullAaharResult? _result;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void initState() {
    super.initState();
    _setDefaultInputsForSpecies(_selectedSpecies);
    _calc();
  }

  @override
  void dispose() {
    _milkCtrl.dispose();
    _weightCtrl.dispose();
    _countCtrl.dispose();
    _beeBoxesCtrl.dispose();
    super.dispose();
  }

  void _setDefaultInputsForSpecies(AaharSpeciesItem sp) {
    switch (sp.id) {
      case 'cow':
        _milkCtrl.text = '10';
        break;
      case 'buffalo':
        _milkCtrl.text = '8';
        break;
      case 'goat':
        _milkCtrl.text = '1.5';
        break;
      case 'sheep':
        _weightCtrl.text = '35';
        break;
      case 'pig':
        _weightCtrl.text = '60';
        break;
      case 'broiler':
        _countCtrl.text = '100';
        break;
      case 'duck':
        _countCtrl.text = '50';
        break;
      case 'quail':
        _countCtrl.text = '200';
        break;
      case 'turkey':
        _countCtrl.text = '20';
        break;
      case 'emu':
        _countCtrl.text = '5';
        break;
      case 'fish':
        _weightCtrl.text = '500';
        break;
      case 'beekeeping':
        _beeBoxesCtrl.text = '10';
        break;
      default:
        _milkCtrl.text = '5';
    }
  }

  void _calc() {
    final milk = double.tryParse(_milkCtrl.text.trim()) ?? 0;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    final count = int.tryParse(_countCtrl.text.trim()) ?? 1;
    final boxes = int.tryParse(_beeBoxesCtrl.text.trim()) ?? 10;

    setState(() {
      _result = calculateFullAahar(
        speciesId: _selectedSpecies.id,
        milkL: milk,
        latePregnancy: _latePreg,
        weightKg: weight,
        count: _selectedSpecies.inputType == 'bee' ? boxes : count,
        isOffSeason: _isOffSeason,
      );
    });
  }

  void _shareResult() {
    if (_result == null) return;
    final isHi = AppLocalizations.isHindiLike(context);
    final name = isHi ? _selectedSpecies.hindiName : _selectedSpecies.englishName;
    final unit = isHi ? 'kg/दिन' : 'kg/day';
    final na = isHi ? 'लागू नहीं' : 'N/A';
    final unitNoteStr = _result!.getUnitNote(isHi);

    final text = '🌾 $name ${_t('aaharCalc')} — Pro Kisan\n'
        '• ${isHi ? "दाना" : "Concentrate Feed"}: ${_result!.danaKg > 0 ? '${_result!.danaKg.toStringAsFixed(1)} $unit' : na}\n'
        '• ${isHi ? "हरा चारा" : "Green Fodder"}: ${_result!.greenFodderKg > 0 ? '${_result!.greenFodderKg.toStringAsFixed(1)} $unit' : na}\n'
        '• ${isHi ? "सूखा भूसा" : "Dry Straw"}: ${_result!.dryFodderKg > 0 ? '${_result!.dryFodderKg.toStringAsFixed(1)} $unit' : na}\n'
        '• ${isHi ? "पूरक/मिनरल/सिरप" : "Supplements/Minerals"}: ${_result!.mineralGrams.toStringAsFixed(0)} $unitNoteStr';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    final dayStr = isHi ? 'kg / दिन' : 'kg / day';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(isHi ? 'जीव / पशु / पक्षी चुनें:' : 'Select Animal / Bird:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kAaharSpeciesList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final sp = kAaharSpeciesList[idx];
              final sel = _selectedSpecies.id == sp.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpecies = sp;
                    _setDefaultInputsForSpecies(sp);
                  });
                  _calc();
                },
                child: Container(
                  width: 82,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sel
                        ? DairyTheme.primaryTeal.withValues(alpha: 0.14)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? DairyTheme.primaryTeal : Colors.grey.shade300,
                        width: sel ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: Image.asset(
                          sp.imageAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHi ? sp.hindiName : sp.englishName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: sel ? DairyTheme.primaryTeal : Colors.black87),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Input Fields based on inputType ──
        if (_selectedSpecies.inputType == 'milk') ...[
          TextField(
            controller: _milkCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: isHi ? 'दैनिक दूध उत्पादन (लीटर)' : 'Daily Milk Output (Litres)',
              prefixIcon: const Icon(Icons.water_drop_rounded, color: DairyTheme.primaryTeal),
            ),
            onChanged: (_) => _calc(),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _latePreg,
            title: Text(isHi ? 'क्या अंतिम गर्भावस्था (गाभिन) में है?' : 'In Late Pregnancy?'),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() => _latePreg = v ?? false);
              _calc();
            },
          ),
        ] else if (_selectedSpecies.inputType == 'weight') ...[
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _selectedSpecies.id == 'fish'
                  ? (isHi ? 'तालाब में कुल मछली वजन / बायोमास (kg)' : 'Total Fish Biomass in Pond (kg)')
                  : (isHi ? 'अनुमानित शारीरिक वजन (kg)' : 'Estimated Body Weight (kg)'),
              prefixIcon: const Icon(Icons.fitness_center_rounded, color: DairyTheme.primaryTeal),
            ),
            onChanged: (_) => _calc(),
          ),
        ] else if (_selectedSpecies.inputType == 'count') ...[
          TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: isHi ? 'पक्षियों / जीवों की संख्या' : 'Total Count / Birds',
              prefixIcon: const Icon(Icons.numbers_rounded, color: DairyTheme.primaryTeal),
            ),
            onChanged: (_) => _calc(),
          ),
        ] else if (_selectedSpecies.inputType == 'bee') ...[
          TextField(
            controller: _beeBoxesCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: isHi ? 'मधुमक्खी बक्सों (Boxes) की संख्या' : 'Number of Beehives/Boxes',
              prefixIcon: const Icon(Icons.hive_rounded, color: DairyTheme.primaryTeal),
            ),
            onChanged: (_) => _calc(),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _isOffSeason,
            title: Text(isHi ? 'क्या ऑफ-सीज़न (मौन/फूलों की कमी का समय) है?' : 'Is Off-Season (Floral Dearth)?'),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() => _isOffSeason = v ?? false);
              _calc();
            },
          ),
        ],

        const SizedBox(height: 14),
        ElevatedButton.icon(
          icon: const Icon(Icons.calculate_rounded),
          onPressed: _calc,
          label: Text(isHi ? 'संतुलित आहार की गणना करें' : 'Calculate Feed Requirement'),
        ),

        // ── Result Breakdown ──
        if (_result != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DairyTheme.primaryTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DairyTheme.primaryTeal.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(_selectedSpecies.imageAsset, width: 36, height: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${isHi ? _selectedSpecies.hindiName : _selectedSpecies.englishName} — ${isHi ? 'दैनिक संतुलित आहार' : 'Daily Balanced Feed'}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DairyTheme.primaryTeal),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (_result!.danaKg > 0)
                  _feedRow(isHi ? '🌾 दाना (Concentrate Feed)' : '🌾 Concentrate Feed', '${_result!.danaKg.toStringAsFixed(1)} $dayStr', DairyTheme.primaryTeal),
                if (_result!.greenFodderKg > 0)
                  _feedRow(isHi ? '🌿 हरा चारा (Green Fodder)' : '🌿 Green Fodder', '${_result!.greenFodderKg.toStringAsFixed(1)} $dayStr', Colors.green.shade700),
                if (_result!.dryFodderKg > 0)
                  _feedRow(isHi ? '🍂 सूखा भूसा (Dry Straw)' : '🍂 Dry Straw', '${_result!.dryFodderKg.toStringAsFixed(1)} $dayStr', Colors.brown.shade700),
                if (_result!.mineralGrams > 0)
                  _feedRow(isHi ? '🧂 पूरक / मिनरल / सिरप' : '🧂 Supplement / Minerals', '${_result!.mineralGrams.toStringAsFixed(0)} ${_result!.getUnitNote(isHi)}', Colors.orange.shade800),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.share_rounded),
            label: Text(isHi ? 'शेयर करें (Share Feed Plan)' : 'Share Feed Plan'),
            onPressed: _shareResult,
          ),
        ],

        const SizedBox(height: 16),
        _disclaimer(_t('vetDisclaimer')),
      ],
    );
  }

  Widget _feedRow(String title, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 🏡 PALAN GRID — बकरी, मुर्गी, मछली, मधुमक्खी…
// ═══════════════════════════════════════════════════════════════════════

