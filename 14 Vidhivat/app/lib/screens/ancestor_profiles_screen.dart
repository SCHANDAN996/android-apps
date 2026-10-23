import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../services/pitru_reminders.dart';
import '../state/ancestor_profiles.dart';
import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/jagah_khoj.dart';

class AncestorProfilesScreen extends StatefulWidget {
  const AncestorProfilesScreen({super.key});

  @override
  State<AncestorProfilesScreen> createState() => _AncestorProfilesScreenState();
}

class _AncestorProfilesScreenState extends State<AncestorProfilesScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ancestorProfiles.load();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _edit([AncestorProfile? existing]) async {
    final saved = await Navigator.of(context).push<AncestorProfile>(
      MaterialPageRoute(builder: (_) => _AncestorForm(existing: existing)),
    );
    if (saved == null) return;
    await ancestorProfiles.save(saved);
    try {
      await pitruReminders.schedule(saved);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('तिथि सहेजी गई, लेकिन reminder सेट नहीं हो सका।'),
        ));
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _delete(AncestorProfile profile) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('यह स्मरण-तिथि हटाएँ?'),
        content: const Text(
            'यह फ़ोन से स्थायी रूप से हटेगी और reminder भी रद्द होगा।'),
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
    await pitruReminders.cancel(profile.id);
    await ancestorProfiles.delete(profile.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('परिवार की स्मरण-तिथियाँ')),
        body: SafeArea(
          child: VidhivatSacredBackdrop(
            child: Panna(
              children: [
                const Chetavni(
                  'नाम और तिथि ऐप के local storage में हैं; ऐप इन्हें अपने '
                  'server पर नहीं भेजता। फ़ोन का system backup अलग से लागू '
                  'हो सकता है। ऐप हटाने पर ये भी मिट सकते हैं। यह सरल स्मरण-सहायक है, '
                  'पूर्ण श्राद्ध-विधि का प्रमाण नहीं।',
                ),
                const SizedBox(height: VidhivatSpacing.md),
                VidhivatButton(
                  label: 'परिजन की तिथि जोड़ें',
                  icon: Icons.add,
                  onPressed: () => _edit(),
                  fullWidth: true,
                ),
                const SizedBox(height: VidhivatSpacing.lg),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (ancestorProfiles.items.isEmpty)
                  Text('अभी कोई तिथि नहीं सहेजी गई है।',
                      style: VidhivatTheme.typographyOf(context).bodyMedium)
                else
                  for (final profile in ancestorProfiles.items) ...[
                    VidhivatSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              profile.name.isEmpty
                                  ? profile.relation
                                  : '${profile.relation} · ${profile.name}',
                              style: VidhivatTheme.typographyOf(context)
                                  .cardTitle),
                          const SizedBox(height: VidhivatSpacing.xs),
                          Text(_tithiLabel(profile.tithi)),
                          if (profile.nextDay(DateTime.now(),
                                  observingPlace: settings.place)
                              case final next?)
                            Text('अगली तिथि: ${tarikh(next.date)}'),
                          Text(profile.reminder
                              ? 'Reminder: सुबह लगभग 9 बजे · ${settings.place.name}'
                              : 'Reminder बंद'),
                          Wrap(spacing: VidhivatSpacing.sm, children: [
                            TextButton(
                                onPressed: () => _edit(profile),
                                child: const Text('बदलें')),
                            TextButton(
                                onPressed: () => _delete(profile),
                                child: const Text('हटाएँ')),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: VidhivatSpacing.sm),
                  ],
              ],
            ),
          ),
        ),
      );
}

String _tithiLabel(int value) {
  if (value == 0) return 'तिथि अज्ञात · सर्वपितृ अमावस्या';
  if (value == 16) return 'पूर्णिमा श्राद्ध · पक्ष से पहले';
  if (value == 15) return 'कृष्ण अमावस्या · सर्वपितृ';
  return 'कृष्ण ${tithiNames[14 + value]}';
}

class _AncestorForm extends StatefulWidget {
  final AncestorProfile? existing;
  const _AncestorForm({this.existing});

  @override
  State<_AncestorForm> createState() => _AncestorFormState();
}

class _AncestorFormState extends State<_AncestorForm> {
  late final TextEditingController _relation;
  late final TextEditingController _name;
  late int _tithi;
  late bool _reminder;
  late bool _showName;
  late String _source;
  late Place _deathPlace;

  /// खोज-पन्ने से चुनी जगह का ज़िला/राज्य — सिर्फ़ दिखाने को
  String? _deathPlacePata;
  DateTime? _deathLocal;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _relation = TextEditingController(text: p?.relation ?? '');
    _name = TextEditingController(text: p?.name ?? '');
    _tithi = p?.tithi ?? 0;
    _reminder = p?.reminder ?? false;
    _showName = p?.showNameOnLockScreen ?? false;
    _source = p?.source ?? 'manual';
    _deathLocal = p?.deathLocal;
    _deathPlace = p?.place ?? settings.place;
  }

  @override
  void dispose() {
    _relation.dispose();
    _name.dispose();
    super.dispose();
  }

  /// मृत्यु की जगह — वही खोज-पन्ना जो कुंडली और सेटिंग में है: ऐप के शहर,
  /// साढ़े पाँच लाख गाँव-क़स्बे, और इंटरनेट (→ D-128, D-129, D-133)।
  Future<void> _jagahChuno() async {
    final c = await jagahChuno(context, shirshak: 'मृत्यु की जगह');
    if (c == null || !mounted) return;
    setState(() {
      _deathPlace = c.place;
      _deathPlacePata = c.state;
      if (_deathLocal != null && _source == 'calculated') {
        _tithi = AncestorProfile.tithiAtDeath(_deathLocal!, _deathPlace);
      }
    });
  }

  Future<void> _pickDeath() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deathLocal ?? DateTime(2000),
      firstDate: DateTime(1850),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_deathLocal ?? DateTime(2000, 1, 1, 12)),
    );
    if (time == null || !mounted) return;
    final local =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _deathLocal = local;
      _tithi = AncestorProfile.tithiAtDeath(local, _deathPlace);
      _source = 'calculated';
    });
  }

  Future<void> _save() async {
    final relation = _relation.text.trim();
    if (relation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('सम्बन्ध लिखें, जैसे माता या पिता।')),
      );
      return;
    }
    var remind = _reminder;
    if (remind && widget.existing?.reminder != true) {
      remind = await pitruReminders.askPermission();
      if (!remind && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('अनुमति नहीं मिली; तिथि reminder के बिना सहेजी जाएगी।')),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(AncestorProfile(
      id: widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      relation: relation,
      name: _name.text.trim(),
      tithi: _tithi,
      source: _source,
      deathLocal: _deathLocal,
      placeName: _deathPlace.name,
      latitude: _deathPlace.latitude,
      longitude: _deathPlace.longitude,
      utcOffsetMinutes: _deathPlace.timeZoneOffset.inMinutes,
      reminder: remind,
      showNameOnLockScreen: _showName,
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title:
                Text(widget.existing == null ? 'तिथि जोड़ें' : 'तिथि बदलें')),
        body: SafeArea(
          child: VidhivatSacredBackdrop(
            child: Panna(children: [
              TextField(
                controller: _relation,
                maxLength: 40,
                decoration: const InputDecoration(
                    labelText: 'सम्बन्ध *', hintText: 'जैसे माता, पिता, दादी'),
              ),
              TextField(
                controller: _name,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'नाम (वैकल्पिक)'),
              ),
              // पहले `Autocomplete` था — सिर्फ़ ~500 शहर, और फ़ोन पर keyboard खुलते ही
              // एक ही सुझाव दिखता था। अब कुंडली वाला पूरा खोज-पन्ना (→ D-133)।
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  key: const Key('mrityu_sthan'),
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(_deathPlace.name),
                  subtitle: Text(_deathPlacePata == null
                      ? 'मृत्यु की जगह — गाँव, क़स्बा या शहर खोजें'
                      : '$_deathPlacePata · बदलने के लिए दबाएँ'),
                  trailing: const Icon(Icons.search),
                  onTap: _jagahChuno,
                ),
              ),
              const SizedBox(height: VidhivatSpacing.md),
              VidhivatButton(
                label: _deathLocal == null
                    ? 'मृत्यु की तारीख़ और समय से तिथि निकालें'
                    : 'चुना समय: ${tarikh(_deathLocal!)} ${_deathLocal!.hour.toString().padLeft(2, '0')}:${_deathLocal!.minute.toString().padLeft(2, '0')}',
                onPressed: _pickDeath,
                variant: VidhivatButtonVariant.secondary,
                fullWidth: true,
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                  'गणना की जगह: ${_deathPlace.name}. '
                  'सही जगह न मिले तो तिथि हाथ से चुनें। समय न पता हो तो अनुमान न लगाएँ।',
                  style: VidhivatTheme.typographyOf(context).bodySmall),
              const SizedBox(height: VidhivatSpacing.md),
              DropdownButtonFormField<int>(
                key: ValueKey(_tithi),
                initialValue: _tithi,
                decoration: const InputDecoration(
                    labelText: 'श्राद्ध की तिथि · हाथ से बदल सकते हैं'),
                isExpanded: true,
                items: [
                  for (var i = 0; i <= 16; i++)
                    DropdownMenuItem(value: i, child: Text(_tithiLabel(i))),
                ],
                onChanged: (value) => setState(() {
                  _tithi = value ?? 0;
                  _source = 'manual';
                }),
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              Text(
                  _source == 'calculated'
                      ? 'यह चुने समय और स्थान से निकली तिथि है; दूसरे वर्ष या स्थान के पंचांग में फर्क हो सकता है।'
                      : 'यह आपके द्वारा चुनी तिथि है; परिवार की ज्ञात रीति को प्राथमिकता दें।',
                  style: VidhivatTheme.typographyOf(context).bodySmall),
              const SizedBox(height: VidhivatSpacing.lg),
              SwitchListTile(
                title: const Text('स्थानीय reminder'),
                subtitle:
                    const Text('लगभग सुबह 9 बजे; सटीक समय की गारंटी नहीं'),
                value: _reminder,
                onChanged: (value) => setState(() => _reminder = value),
              ),
              if (_reminder)
                SwitchListTile(
                  title: const Text('सूचना में नाम दिखाएँ'),
                  subtitle: const Text(
                      'बंद रहने पर lock screen पर सामान्य संदेश दिखेगा'),
                  value: _showName,
                  onChanged: (value) => setState(() => _showName = value),
                ),
              const SizedBox(height: VidhivatSpacing.md),
              VidhivatButton(
                  label: 'फ़ोन पर सहेजें', onPressed: _save, fullWidth: true),
            ]),
          ),
        ),
      );
}
