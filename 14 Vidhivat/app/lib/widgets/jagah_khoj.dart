import 'dart:async';

import 'package:flutter/material.dart';

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
          onChanged: (v) {
            setState(() {});
            _gaonKhojo(v);
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'शहर खोजें',
            hintText: 'शहर, क़स्बा या गाँव — जैसे पटना, Pune, Rampur',
            helperText: 'एक नाम के कई गाँव हों तो «गाँव, ज़िला» लिखें',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        if (cities.isEmpty && _gaon.isEmpty && _search.text.trim().isNotEmpty)
          const VidhivatSurfaceCard(
            child: Text('इस नाम की कोई जगह नहीं मिली। दूसरी वर्तनी या पास का क़स्बा खोजें।'),
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
