import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../services/device_location_service.dart';
import '../state/kundali_profiles.dart';
import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/jagah_khoj.dart';
import 'gun_milan_screen.dart';
import 'kundali_screen.dart';

// Keep invalid signs/text visible for validation; only normalize Hindi digits.
final _coordinateFormatter = TextInputFormatter.withFunction((oldValue, value) {
  const digits = '०१२३४५६७८९';
  final text = value.text.replaceAllMapped(
      RegExp('[०-९]'), (match) => digits.indexOf(match[0]!).toString());
  return value.copyWith(text: text);
});

/// परिवार की कुंडलियाँ — जन्म का ब्यौरा भरो, कुंडली खोलो (→ D-105)।
///
/// यहाँ से जो खुलता है वह **गणित** है: लग्न, ग्रह, दशा की तारीख़ें। फल,
/// राशिफल, दोष, उपाय — ऐप में कहीं नहीं (`CLAUDE.md`: "भविष्यवाणी के दावे
/// कभी नहीं"), और यह बात इस पन्ने पर सबसे ऊपर खुली लिखी है।
class KundaliProfilesScreen extends StatefulWidget {
  const KundaliProfilesScreen({super.key});

  @override
  State<KundaliProfilesScreen> createState() => _KundaliProfilesScreenState();
}

class _KundaliProfilesScreenState extends State<KundaliProfilesScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await kundaliProfiles.load();
    if (mounted) setState(() => _loading = false);
  }

  void _kholo(KundaliProfile p) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => KundaliScreen(profile: p)),
      );

  Future<void> _edit([KundaliProfile? existing]) async {
    final saved = await Navigator.of(context).push<KundaliProfile>(
      MaterialPageRoute(builder: (_) => KundaliForm(existing: existing)),
    );
    if (saved == null) return;
    await kundaliProfiles.save(saved);
    if (!mounted) return;
    setState(() {});
    if (existing == null) _kholo(saved);
  }

  Future<void> _delete(KundaliProfile profile) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('यह कुंडली हटाएँ?'),
        content: Text('${profile.naam} का जन्म-ब्यौरा इस फ़ोन से हट जाएगा।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('रहने दें')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('हटाएँ')),
        ],
      ),
    );
    if (yes != true) return;
    await kundaliProfiles.delete(profile.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('जन्म कुंडली')),
      body: SafeArea(
        child: VidhivatSacredBackdrop(
          child: Panna(
            children: [
              // ── दायरा — खुला, ⓘ के पीछे नहीं (→ D-056) ──────────────
              const Chetavni(
                'यह कुंडली का गणित है — जन्म के समय कौन सा ग्रह कहाँ था, लग्न '
                'क्या था, दशा कब बदलती है। फल, राशिफल या उपाय ऐप नहीं बताता।',
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatButton(
                label: 'नई कुंडली बनाएँ',
                icon: Icons.add,
                onPressed: () => _edit(),
                fullWidth: true,
              ),
              const SizedBox(height: VidhivatSpacing.lg),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (kundaliProfiles.items.isEmpty)
                Text(
                  'अभी कोई कुंडली नहीं बनी। जन्म की तारीख़, समय और जगह चाहिए।',
                  textAlign: TextAlign.justify,
                  style: type.bodyMedium.copyWith(color: colors.textSecondary),
                )
              else
                for (final p in kundaliProfiles.items) ...[
                  VidhivatSurfaceCard(
                    variant: VidhivatCardVariant.elevated,
                    onTap: () => _kholo(p),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.naam, style: type.cardTitle),
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          '${tarikh(p.janm)}, ${hm(p.janm)} · ${p.sthanNaam}',
                          textAlign: TextAlign.justify,
                          style: type.bodySmall
                              .copyWith(color: colors.textSecondary),
                        ),
                        Wrap(spacing: VidhivatSpacing.sm, children: [
                          TextButton(
                              onPressed: () => _kholo(p),
                              child: const Text('कुंडली खोलें')),
                          TextButton(
                              onPressed: () => _edit(p),
                              child: const Text('बदलें')),
                          TextButton(
                              onPressed: () => _delete(p),
                              child: const Text('हटाएँ')),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: VidhivatSpacing.sm),
                ],
              // ── गुण मिलान — दो कुंडलियाँ हों तभी (→ D-110) ──────────────
              if (!_loading && kundaliProfiles.items.length >= 2) ...[
                const SizedBox(height: VidhivatSpacing.sm),
                VidhivatButton(
                  label: 'गुण मिलान',
                  icon: Icons.compare_arrows,
                  variant: VidhivatButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GunMilanScreen(profiles: kundaliProfiles.items),
                    ),
                  ),
                ),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(
                  'दो कुंडलियों के बीच अष्टकूट के अंक — सिर्फ़ जोड़, फ़ैसला नहीं।',
                  textAlign: TextAlign.justify,
                  style: type.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: VidhivatSpacing.md),
              Text(
                'जन्म का ब्यौरा सिर्फ़ इस फ़ोन में रहता है; ऐप इसे कहीं नहीं '
                'भेजता। फ़ोन का अपना बैकअप चालू हो तो वह इसे आपके खाते में रख '
                'सकता है। ऐप हटाने पर यह भी मिट जाता है।',
                textAlign: TextAlign.justify,
                style: type.bodySmall.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// जन्म का ब्यौरा भरने का पन्ना।
///
/// जन्म की जगह तीन तरह से: सूची से शहर (हिंदी या अंग्रेज़ी नाम), अक्षांश-देशांतर
/// हाथ से, या **फ़ोन की अभी की जगह** — उनके लिए जो जन्म वाले गाँव-शहर में ही बैठे
/// हैं (डेवलपर की माँग, 21 अक्टूबर 2026; → D-128)। जगह एक बार ली जाती है और फ़ोन
/// से बाहर नहीं जाती।
class KundaliForm extends StatefulWidget {
  final KundaliProfile? existing;

  /// फ़ोन की जगह लेने वाला — जाँच में नक़ली दिया जाता है
  final Future<DeviceLocationResult> Function()? jagahLo;

  const KundaliForm({super.key, this.existing, this.jagahLo});

  @override
  State<KundaliForm> createState() => _KundaliFormState();
}

class _KundaliFormState extends State<KundaliForm> {
  late final TextEditingController _naam;
  late final TextEditingController _sthanNaam;
  late final TextEditingController _lat;
  late final TextEditingController _lon;
  DateTime? _tarikh;
  TimeOfDay? _samay;
  City? _shahar;
  bool _khudBharein = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _naam = TextEditingController(text: p?.naam ?? '');
    _sthanNaam = TextEditingController(text: p?.sthanNaam ?? '');
    _lat = TextEditingController(text: p?.latitude.toString() ?? '');
    _lon = TextEditingController(text: p?.longitude.toString() ?? '');
    if (p != null) {
      _tarikh = DateTime(p.janm.year, p.janm.month, p.janm.day);
      _samay = TimeOfDay(hour: p.janm.hour, minute: p.janm.minute);
      final mila = indianCities.where((c) =>
          c.name == p.sthanNaam &&
          c.latitude == p.latitude &&
          c.longitude == p.longitude);
      if (mila.isNotEmpty) {
        _shahar = mila.first;
      } else {
        _khudBharein = true;
      }
    }
  }

  @override
  void dispose() {
    _naam.dispose();
    _sthanNaam.dispose();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  Future<void> _tarikhChuno() async {
    final aaj = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _tarikh ?? DateTime(1990),
      // 1906 से पहले पूरे देश की एक घड़ी नहीं थी (→ bharat_samay.dart)
      firstDate: DateTime(bharatSamayPehlaSaal),
      lastDate: aaj,
      helpText: 'जन्म की तारीख़',
    );
    if (d != null && mounted) setState(() => _tarikh = d);
  }

  Future<void> _samayChuno() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _samay ?? const TimeOfDay(hour: 6, minute: 0),
      helpText: 'जन्म का समय',
    );
    if (t != null && mounted) setState(() => _samay = t);
  }

  void _kaho(String baat) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(baat)));

  Future<void> _jagahChuno() async {
    final c = await jagahChuno(
      context,
      selectedCity: _shahar,
      shirshak: 'जन्म की जगह',
      phoneKiJagah:
          'तभी, जब आप अभी जन्म की जगह पर ही हों · फ़ोन से बाहर नहीं जाती',
      jagahLo: widget.jagahLo,
    );
    if (c == null || !mounted) return;
    // फ़ोन की जगह — नाम में पास का शहर, «के पास» के साथ (ठीक वही शहर नहीं)
    setState(() => _shahar = c.isDeviceDetected
        ? City('${c.name} के पास', c.state, c.latitude, c.longitude)
        : c);
  }

  void _save() {
    final naam = _naam.text.trim();
    if (naam.isEmpty) return _kaho('नाम लिखिए।');
    if (_tarikh == null) return _kaho('जन्म की तारीख़ चुनिए।');
    if (_samay == null) return _kaho('जन्म का समय चुनिए।');

    final String sthan;
    final double lat, lon;
    if (_khudBharein) {
      sthan = _sthanNaam.text.trim();
      final a = double.tryParse(_lat.text.trim());
      final d = double.tryParse(_lon.text.trim());
      if (sthan.isEmpty) return _kaho('जगह का नाम लिखिए।');
      // भारत की सीमा के भीतर — विदेश का जन्म अभी नहीं (घड़ी अलग होती है)
      if (a == null || !a.isFinite || a < 6 || a > 37.5) {
        return _kaho('अक्षांश 6 और 37.5 के बीच का अंक होना चाहिए।');
      }
      if (d == null || !d.isFinite || d < 68 || d > 97.5) {
        return _kaho('देशांतर 68 और 97.5 के बीच का अंक होना चाहिए।');
      }
      lat = a;
      lon = d;
    } else {
      final c = _shahar;
      if (c == null) return _kaho('जन्म की जगह सूची से चुनिए।');
      sthan = c.name;
      lat = c.latitude;
      lon = c.longitude;
    }

    Navigator.of(context).pop(KundaliProfile(
      id: widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      naam: naam,
      janm: DateTime(_tarikh!.year, _tarikh!.month, _tarikh!.day, _samay!.hour,
          _samay!.minute),
      sthanNaam: sthan,
      latitude: lat,
      longitude: lon,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final yuddh = _tarikh != null &&
        yuddhKalKiGhadi(DateTime(_tarikh!.year, _tarikh!.month, _tarikh!.day,
            _samay?.hour ?? 12, _samay?.minute ?? 0));
    final purana = _tarikh != null && _tarikh!.year < 1956;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.existing == null ? 'नई कुंडली' : 'जन्म का ब्यौरा बदलें')),
      body: SafeArea(
        child: VidhivatSacredBackdrop(
          child: Panna(children: [
            TextField(
              controller: _naam,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'नाम *'),
            ),
            VidhivatButton(
              label: _tarikh == null
                  ? 'जन्म की तारीख़ चुनें'
                  : 'तारीख़: ${tarikh(_tarikh!)}',
              icon: Icons.calendar_today_outlined,
              onPressed: _tarikhChuno,
              variant: VidhivatButtonVariant.secondary,
              fullWidth: true,
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatButton(
              label: _samay == null
                  ? 'जन्म का समय चुनें'
                  : 'समय: ${_samay!.hour.toString().padLeft(2, '0')}:${_samay!.minute.toString().padLeft(2, '0')}',
              icon: Icons.schedule_outlined,
              onPressed: _samayChuno,
              variant: VidhivatButtonVariant.secondary,
              fullWidth: true,
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              'समय जितना ठीक, लग्न उतना ठीक: लग्न लगभग चार मिनट में एक अंश और दो '
              'घंटे में पूरी राशि बदल देता है। समय पता न हो तो अंदाज़ से मत '
              'भरिए — लग्न और भाव ग़लत आएँगे।',
              textAlign: TextAlign.justify,
              style: type.bodySmall.copyWith(color: colors.textSecondary),
            ),
            if (yuddh) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              const Chetavni(
                'इन दिनों (1941–42 और 1942–45) भारत की घड़ी एक घंटा आगे रखी गई '
                'थी। ऐप ने यही माना है। आपके काग़ज़ में समय "पुराने समय" से '
                'लिखा हो, तो एक घंटा जोड़कर भरिए।',
                serious: true,
              ),
            ] else if (purana) ...[
              const SizedBox(height: VidhivatSpacing.sm),
              const Chetavni(
                'उन दिनों कलकत्ता और बम्बई में शहर की अपनी घड़ी भी चलती थी, जो '
                'रेल की घड़ी से अलग थी। ऐप भारत का मानक समय मानता है — देख '
                'लीजिए कि आपके काग़ज़ का समय किस घड़ी का है।',
              ),
            ],
            const SizedBox(height: VidhivatSpacing.lg),
            if (!_khudBharein)
              // पूरा खोज-पन्ना — Autocomplete में keyboard के ऊपर एक ही सुझाव दिखता था
              // (फ़ोन पर पकड़ा, 21 अक्टूबर 2026; → D-128)
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  key: const Key('janm_sthan'),
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(
                      _shahar == null ? 'जन्म की जगह चुनें *' : _shahar!.name),
                  subtitle: Text(_shahar == null
                      ? 'गाँव या शहर का नाम लिखें, या फ़ोन की जगह लें'
                      : '${_shahar!.state} · बदलने के लिए दबाएँ'),
                  trailing: const Icon(Icons.search),
                  onTap: _jagahChuno,
                ),
              )
            else ...[
              TextField(
                controller: _sthanNaam,
                maxLength: 40,
                decoration: const InputDecoration(labelText: 'जगह का नाम *'),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lat,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        _coordinateFormatter,
                      ],
                      decoration: const InputDecoration(
                          labelText: 'अक्षांश (उत्तर)', hintText: '25.59'),
                    ),
                  ),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _lon,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        _coordinateFormatter,
                      ],
                      decoration: const InputDecoration(
                          labelText: 'देशांतर (पूर्व)', hintText: '85.14'),
                    ),
                  ),
                ],
              ),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _khudBharein = !_khudBharein),
                child: Text(_khudBharein
                    ? 'शहरों की सूची से चुनें'
                    : 'अक्षांश-देशांतर ख़ुद भरें'),
              ),
            ),
            Text(
              'गाँव न मिले तो पास का क़स्बा भी चलेगा।',
              textAlign: TextAlign.justify,
              style: type.bodySmall.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: VidhivatSpacing.xl),
            VidhivatButton(
              label: widget.existing == null ? 'कुंडली बनाएँ' : 'सहेजें',
              onPressed: _save,
              fullWidth: true,
            ),
          ]),
        ),
      ),
    );
  }
}
