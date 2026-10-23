import 'dart:async';

import 'package:flutter/material.dart';

import '../services/osm_khoj.dart';
import '../state/gaon.dart';
import '../state/shahar.dart';
import '../theme.dart';
import 'design_system.dart';

/// एक खोज, दो सूचियाँ (→ D-128): पहले ऐप के अपने ~500 शहर (हिंदी नाम, पंचांग के
/// लिए जाँचे हुए), फिर साढ़े पाँच लाख गाँव-क़स्बे (`gaon.dart`, अंग्रेज़ी नाम)।
///
/// गाँव वाली सूची पहली बार खुलने में लगभग एक सेकंड लेती है — [jagahKhojTaiyar]
/// खोज वाले खाने को छूते ही बुला लो।
Future<List<JagahMila>> jagahKhojo(String khoj, {int shahar = 4, int gaon = 12}) async {
  final q = khoj.trim();
  if (q.isEmpty) return const [];
  final apne = shaharKhojo(q).take(shahar).toList();
  if (q.length < 2) return [for (final c in apne) JagahMila(c, false)];
  final suchi = await GaonSuchi.khulo();
  final gaonMile = suchi.khojo(q, kitne: gaon + apne.length);
  final out = [for (final c in apne) JagahMila(c, false)];
  for (final g in gaonMile) {
    // वही शहर दोबारा नहीं — नाम का ढाँचा एक और जगह पास-पास
    final dohra = apne.any((c) =>
        devDhanche(c.name).contains(romanDhancha(g.naam)) &&
        (c.latitude - g.latitude).abs() < 0.15 &&
        (c.longitude - g.longitude).abs() < 0.15);
    if (!dohra) out.add(JagahMila(g.city, true));
    if (out.length >= apne.length + gaon) break;
  }
  return out;
}

/// गाँवों की सूची पहले से खुलवा दो (नतीजे का इंतज़ार नहीं)।
void jagahKhojTaiyar() => unawaited(GaonSuchi.khulo());

/// खोज का एक नतीजा। [gaonSuchiSe] = नाम अंग्रेज़ी अक्षरों में है, ऐप के अपने शहरों में नहीं।
class JagahMila {
  final City city;
  final bool gaonSuchiSe;
  const JagahMila(this.city, this.gaonSuchiSe);
}

/// जगह खोजने का पन्ना (नीचे से खुलता है) — कुंडली के जन्म-स्थान और सेटिंग (संकल्प,
/// पंचांग) दोनों में यही (→ D-128)। चुनी जगह `Navigator.pop` से [City] बनकर लौटती है।
/// गाँवों की सूची से आई जगह का नाम अंग्रेज़ी अक्षरों में होता है।
///
/// (पहले कुंडली में `Autocomplete` था — फ़ोन पर keyboard खुलते ही सुझावों की सूची में
/// एक ही नाम दिखता था; इसलिए पूरा पन्ना।)
class JagahKhojSheet extends StatefulWidget {
  final ScrollController controller;
  final City? selectedCity;
  final String shirshak;
  final String upShirshak;

  /// ख़ाली खोज पर ऐप के सारे शहर दिखें (सेटिंग) या कुछ नहीं (कुंडली)
  final bool khaaliParSab;

  const JagahKhojSheet({
    super.key,
    required this.controller,
    this.selectedCity,
    this.shirshak = 'शहर हाथ से चुनें',
    this.upShirshak = 'अनुमति न दें, तब भी पंचांग सही रहेगा',
    this.khaaliParSab = true,
  });

  @override
  State<JagahKhojSheet> createState() => _JagahKhojSheetState();
}

class _JagahKhojSheetState extends State<JagahKhojSheet> {
  final _search = TextEditingController();

  /// गाँवों की सूची से (→ D-128) — ऐप के शहरों के नीचे
  List<JagahMila> _gaon = const [];
  int _khojKram = 0;

  /// इंटरनेट से (OpenStreetMap, → D-129) — सिर्फ़ यूज़र के कहने पर; `null` = अभी नहीं खोजा
  List<OsmJagah>? _online;
  bool _onlineChal = false;
  String? _onlineHaal;
  String _onlineKhoj = '';
  bool _band = false;

  Future<void> _onlineKhojo() async {
    final q = _search.text.trim();
    if (q.length < 2 || _onlineChal) return;
    setState(() {
      _onlineChal = true;
      _onlineHaal = null;
      _onlineKhoj = q;
    });
    try {
      final mile = await osmKhoj.khojo(
        q,
        haal: (h) {
          if (mounted) setState(() => _onlineHaal = h);
        },
        // पन्ना बंद हुआ या खोज का शब्द बदल गया — यह खोज छोड़ो
        radd: () => _band || _search.text.trim() != q,
      );
      if (!mounted) return;
      setState(() {
        _online = mile;
        _onlineChal = false;
      });
    } on OsmRadd {
      if (mounted && !_band) setState(() => _onlineChal = false);
    }
  }

  @override
  void initState() {
    super.initState();
    jagahKhojTaiyar();
  }

  Future<void> _gaonKhojo(String q) async {
    final kram = ++_khojKram;
    final mile = q.trim().length < 2
        ? const <JagahMila>[]
        : (await jagahKhojo(q, shahar: 0, gaon: 15));
    if (mounted && kram == _khojKram) setState(() => _gaon = mile);
  }

  @override
  void dispose() {
    _band = true;
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ख़ाली हो तो पूरी सूची (सेटिंग में); अंग्रेज़ी में लिखा नाम भी ("Delhi") — → shaharKhojo
    final cities = (!widget.khaaliParSab && _search.text.trim().isEmpty)
        ? const <City>[]
        : shaharKhojo(_search.text);

    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        0,
        VidhivatSpacing.lg,
        VidhivatSpacing.xxl,
      ),
      children: [
        VidhivatSectionHeader(
          title: widget.shirshak,
          supportingText: widget.upShirshak,
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        TextField(
          key: const Key('jagah_khoj'),
          controller: _search,
          autofocus: !widget.khaaliParSab,
          textInputAction: TextInputAction.search,
          // keyboard का «खोज» — इंटरनेट पर भी (Nominatim हर अक्षर पर खोज मना करता है)
          onSubmitted: (_) => _onlineKhojo(),
          onChanged: (v) {
            setState(() {
              if (v.trim() != _onlineKhoj) _online = null;
            });
            _gaonKhojo(v);
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'शहर खोजें',
            hintText: 'शहर, क़स्बा या गाँव — जैसे पटना, Pune, Rampur',
            helperText: 'लिखकर keyboard का «खोज» दबाएँ — पहले इंटरनेट पर खोजेगा',
            // फ़ोन पर एक लाइन में कटकर «…इंटरनेट पर खो…» दिखता था
            helperMaxLines: 2,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),

        // ── पहले इंटरनेट (डेवलपर, 23 अक्टूबर: "इंटरनेट हो तो पहली कोशिश इंटरनेट से,
        // ऑफ़लाइन बाद में" — → D-133) ──
        // OpenStreetMap की नीति हर अक्षर पर अपने-आप खोज मना करती है, इसलिए खोज
        // keyboard के «खोज» या इस बटन पर चलती है; उसके नतीजे सबसे ऊपर। ऐप की अपनी सूची
        // (शहर, गाँव) नीचे — इंटरनेट न हो या कुछ न मिले तो वही काम आती है।
        if (_search.text.trim().length >= 2) ...[
          if (_onlineChal)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.sm),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: VidhivatSpacing.sm),
                  Expanded(child: Text(_onlineHaal ?? 'इंटरनेट पर खोज रहे हैं…')),
                ],
              ),
            )
          else if (_online == null)
            VidhivatButton(
              key: const Key('online_khoj'),
              label: 'इंटरनेट पर खोजें',
              icon: Icons.public,
              onPressed: _onlineKhojo,
              fullWidth: true,
            )
          else ...[
            const VidhivatSectionHeader(
              title: 'इंटरनेट से',
              supportingText: 'खोज का शब्द इंटरनेट पर जाता है; आपकी जगह नहीं',
            ),
            if (_online!.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: VidhivatSpacing.sm),
                child: Text('इंटरनेट पर नहीं मिला — नीचे ऐप की सूची देखें, या दूसरी वर्तनी '
                    'और «गाँव, ज़िला» लिखकर खोजें।'),
              ),
            for (final o in _online!)
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(o.naam),
                subtitle: Text(o.pata.isEmpty ? 'भारत' : o.pata),
                onTap: () => Navigator.of(context).pop(City(
                    o.naam, o.pata.isEmpty ? 'भारत' : o.pata, o.latitude, o.longitude)),
              ),
            // ODbL लाइसेंस की शर्त — जहाँ OpenStreetMap का डेटा दिखे, वहीं श्रेय
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.xs),
              child: Text(
                'जगहों का डेटा © OpenStreetMap contributors',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: VidhivatSpacing.md),
          if (cities.isNotEmpty || _gaon.isNotEmpty)
            const VidhivatSectionHeader(
              title: 'ऐप की सूची से',
              supportingText: 'बिना इंटरनेट भी',
            ),
        ],
        if (cities.isEmpty &&
            _gaon.isEmpty &&
            _search.text.trim().isNotEmpty &&
            !_onlineChal &&
            (_online?.isEmpty ?? true))
          const VidhivatSurfaceCard(
            child: Text('ऐप की सूची में इस नाम की कोई जगह नहीं मिली। ऊपर «इंटरनेट पर खोजें» '
                'दबाएँ, या दूसरी वर्तनी / पास का क़स्बा खोजें।'),
          ),
        for (final city in cities)
          ListTile(
            title: Text(city.name),
            subtitle: Text(city.state),
            selected: city.name == widget.selectedCity?.name &&
                !(widget.selectedCity?.isDeviceDetected ?? true),
            onTap: () => Navigator.of(context).pop(city),
          ),
        if (_gaon.isNotEmpty) ...[
          const SizedBox(height: VidhivatSpacing.md),
          const VidhivatSectionHeader(
            title: 'गाँव और क़स्बे',
            supportingText: 'नाम अंग्रेज़ी अक्षरों में, जैसे सूची में हैं',
          ),
          for (final m in _gaon)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(m.city.name),
              subtitle: Text(m.city.state),
              onTap: () => Navigator.of(context).pop(m.city),
            ),
        ],
      ],
    );
  }
}

/// [JagahKhojSheet] खोलो — चुनी जगह लौटती है, या `null`।
Future<City?> jagahChuno(
  BuildContext context, {
  City? selectedCity,
  String shirshak = 'शहर हाथ से चुनें',
  String upShirshak = 'अनुमति न दें, तब भी पंचांग सही रहेगा',
  bool khaaliParSab = true,
}) =>
    showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        builder: (context, controller) => JagahKhojSheet(
          controller: controller,
          selectedCity: selectedCity,
          shirshak: shirshak,
          upShirshak: upShirshak,
          khaaliParSab: khaaliParSab,
        ),
      ),
    );
