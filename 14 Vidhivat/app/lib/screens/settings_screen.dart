import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../services/device_location_service.dart';
import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isFindingLocation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग')),
      // ⚠️ नीचे ऐप की अपनी कोई पट्टी नहीं है, इसलिए `SafeArea` के बिना
      // सबसे नीचे का हिस्सा Android के नेविगेशन बार के पीछे चला जाता है।
      // `top: false` इसलिए कि ऊपर AppBar पहले से सँभाल लेता है।
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
          child: Panna(
            children: [
              const VidhivatSectionHeader(
                  title: 'स्थान',
                  supportingText: 'तिथि सूर्योदय पर तय होती है'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(
                    settings.city.isDeviceDetected
                        ? Icons.my_location_outlined
                        : Icons.location_on_outlined,
                  ),
                  title: Text(settings.city.name),
                  subtitle: Text(settings.city.locationSourceLabel),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _chooseCity,
                ),
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatButton(
                label: _isFindingLocation
                    ? 'स्थान पहचाना जा रहा है…'
                    : 'मेरी जगह अपने आप पहचानें',
                icon: Icons.my_location_outlined,
                variant: VidhivatButtonVariant.secondary,
                onPressed: _isFindingLocation ? null : _detectDeviceLocation,
                fullWidth: true,
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              TextButton.icon(
                onPressed: _chooseCity,
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: const Text('शहर हाथ से चुनें'),
              ),
              const SizedBox(height: VidhivatSpacing.md),
              
              // ── अपनी जगह का नाम (→ D-058) ───────────────────
              //
              // सूची में 480 शहर हैं, फिर भी गाँव उसमें कभी नहीं आएगा —
              // भारत में छह लाख से ज़्यादा गाँव हैं। और संकल्प में जगह का
              // नाम बोला जाता है, इसलिए वहाँ नज़दीकी शहर का नाम बोलना
              // सच नहीं होता।
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline),
                  title: const Text('अपनी जगह का नाम'),
                  subtitle: Text(settings.city.naamKhudLikha
                      ? 'संकल्प में यही बोला जाएगा · बदलने के लिए दबाएँ'
                      : 'गाँव या क़स्बे का नाम ख़ुद लिखिए · पंचांग वैसा ही रहेगा'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _editSthanNaam,
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(
                  title: 'मास पद्धति',
                  supportingText: 'उत्तर भारत पूर्णिमांत, दक्षिण-पश्चिम अमांत'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: RadioGroup<MasaSystem>(
                  groupValue: settings.masaSystem,
                  onChanged: (v) {
                    if (v != null) settings.setMasaSystem(v);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<MasaSystem>(
                        value: MasaSystem.purnimanta,
                        title: Text('पूर्णिमांत'),
                        subtitle: Text('मास पूर्णिमा पर बदलता है'),
                      ),
                      RadioListTile<MasaSystem>(
                        value: MasaSystem.amanta,
                        title: Text('अमांत'),
                        subtitle: Text('मास अमावस्या पर बदलता है'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(
                  title: 'यजमान',
                  supportingText: 'संकल्प में यही बोला जाता है'),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title:
                      Text(settings.hasYajman ? settings.name : 'नाम भरा नहीं'),
                  subtitle: Text('${settings.gotra} गोत्र'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _editYajman,
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(title: 'गणना के बारे में'),
              const SizedBox(height: VidhivatSpacing.sm),
              const VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Pankti('गणना', 'दृक् गणित'),
                    Pankti('अयनांश', 'लाहिड़ी (चित्रपक्ष)'),
                    Pankti('दिन', 'सूर्योदय से अगले सूर्योदय तक'),
                    Pankti('मुख्य गणना', 'ऑफ़लाइन — इसी फ़ोन पर'),
                  ],
                ),
              ),
              // ── ये दोनों पहले रंगीन डिब्बे थे — अब सादी पंक्तियाँ ──
              //
              // बात दोनों की यूज़र के काम की है, इसलिए मिटाई नहीं — पर यह
              // पन्ने का पैर है, चेतावनी की जगह नहीं। दो नीले डिब्बे यहाँ
              // ऐसे लगते थे जैसे कुछ गड़बड़ हो (→ D-056)।
              const SizedBox(height: VidhivatSpacing.xl),
              Text(
                'आपका नाम, गोत्र और चुनी हुई जगह ऐप की स्थानीय सेटिंग में '
                'रहते हैं। इनके लिए कोई लॉगिन या ऐप सर्वर नहीं है।',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(
                'यह ऐप परंपरागत जानकारी देता है। किसी भी ज़रूरी काम का '
                'अंतिम निर्णय अपने पंडित जी से ही करें।',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(
                'विधिवत · संस्करण 0.1.0\nMASS APP',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// जगह का नाम ख़ुद लिखने का पर्चा।
  ///
  /// ⚠ यहाँ सिर्फ़ **नाम** बदलता है। अक्षांश-देशांतर वही रहते हैं,
  /// इसलिए सूर्योदय और तिथि पर कोई फ़र्क़ नहीं पड़ता (→ D-058)।
  Future<void> _editSthanNaam() async {
    final controller = TextEditingController(text: settings.city.name);
    final naya = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('अपनी जगह का नाम'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'जो नाम संकल्प में बोला जाए — अपना गाँव, क़स्बा या मुहल्ला। '
              'सूर्योदय और तिथि पहले जैसे ही रहेंगे।',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'जगह का नाम',
                hintText: 'जैसे — अंबिकापुर',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            Text(
              'संकल्प संस्कृत में बोला जाता है, इसलिए नाम देवनागरी में लिखें।',
              style: VidhivatTheme.typographyOf(context).caption,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('रहने दें'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('रख लीजिए'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (naya != null && naya.trim().isNotEmpty) {
      await settings.setSthanNaam(naya);
    }
  }

  Future<void> _chooseCity() async {
    final chosen = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (context, controller) => _ManualCityPicker(
          controller: controller,
          selectedCity: settings.city,
        ),
      ),
    );

    if (chosen != null) await settings.setCity(chosen);
    if (mounted) setState(() {});
  }

  Future<void> _detectDeviceLocation() async {
    setState(() => _isFindingLocation = true);
    final result = await const DeviceLocationService().getCurrentLocation();
    if (!mounted) return;
    setState(() => _isFindingLocation = false);

    if (result.hasPosition) {
      await settings.setCityFromDeviceLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
      );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${settings.city.name} के पास का स्थान चुन लिया गया')),
      );
      return;
    }

    final message = switch (result.failure) {
      DeviceLocationFailure.serviceDisabled =>
        'फ़ोन में स्थान की सुविधा बंद है। नीचे से शहर हाथ से चुन सकते हैं।',
      DeviceLocationFailure.permissionDenied =>
        'स्थान की अनुमति नहीं मिली। नीचे से शहर हाथ से चुन सकते हैं।',
      _ => 'स्थान नहीं मिल पाया। नीचे से शहर हाथ से चुन सकते हैं।',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editYajman() async {
    final naam = TextEditingController(text: settings.name);
    var gotra = settings.gotra;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('यजमान'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: naam,
                  decoration: const InputDecoration(
                    labelText: 'नाम',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: VidhivatSpacing.lg),
                const Text('गोत्र'),
                const SizedBox(height: VidhivatSpacing.xs),
                Wrap(
                  spacing: VidhivatSpacing.xs,
                  runSpacing: VidhivatSpacing.xs,
                  children: [
                    for (final g in commonGotras)
                      ChoiceChip(
                        label: Text(g),
                        selected: gotra == g,
                        onSelected: (_) => setLocal(() => gotra = g),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('रहने दो'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('रखो'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await settings.setYajman(name: naam.text.trim(), gotra: gotra);
    }
    naam.dispose();
    if (mounted) setState(() {});
  }
}

class _ManualCityPicker extends StatefulWidget {
  final ScrollController controller;
  final City selectedCity;

  const _ManualCityPicker({
    required this.controller,
    required this.selectedCity,
  });

  @override
  State<_ManualCityPicker> createState() => _ManualCityPickerState();
}

class _ManualCityPickerState extends State<_ManualCityPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim();
    final cities = indianCities
        .where((city) =>
            query.isEmpty ||
            city.name.contains(query) ||
            city.state.contains(query))
        .toList(growable: false);

    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        0,
        VidhivatSpacing.lg,
        VidhivatSpacing.xxl,
      ),
      children: [
        const VidhivatSectionHeader(
          title: 'शहर हाथ से चुनें',
          supportingText: 'अनुमति न दें, तब भी पंचांग सही रहेगा',
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'शहर खोजें',
            hintText: 'जैसे — पटना, दिल्ली, पुणे',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        if (cities.isEmpty)
          const VidhivatSurfaceCard(
            child: Text('इस नाम का शहर सूची में नहीं है। दूसरा नाम खोजें।'),
          ),
        for (final city in cities)
          ListTile(
            title: Text(city.name),
            subtitle: Text(city.state),
            selected: city.name == widget.selectedCity.name &&
                !widget.selectedCity.isDeviceDetected,
            onTap: () => Navigator.of(context).pop(city),
          ),
      ],
    );
  }
}
