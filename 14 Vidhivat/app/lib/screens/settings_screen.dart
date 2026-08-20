import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग')),
      body: Panna(
        children: [
          Khand(
            title: 'जगह',
            subtitle: 'तिथि सूर्योदय पर तय होती है — इसलिए शहर सही चुनें',
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(settings.city.name),
              subtitle: Text(settings.city.state),
              trailing: const Icon(Icons.chevron_right),
              onTap: _chooseCity,
            ),
          ),

          Khand(
            title: 'मास पद्धति',
            subtitle: 'उत्तर भारत पूर्णिमांत मानता है, दक्षिण-पश्चिम अमांत',
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

          Khand(
            title: 'यजमान',
            subtitle: 'संकल्प में यही बोला जाता है',
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(settings.hasYajman ? settings.name : 'नाम भरा नहीं'),
              subtitle: Text('${settings.gotra} गोत्र'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _editYajman,
            ),
          ),

          const Khand(
            title: 'गणना के बारे में',
            child: Column(
              children: [
                Pankti('गणना', 'दृक् गणित'),
                Pankti('अयनांश', 'लाहिड़ी (चित्रपक्ष)'),
                Pankti('दिन', 'सूर्योदय से अगले सूर्योदय तक'),
                Pankti('नेटवर्क', 'कुछ नहीं — सब फ़ोन पर'),
              ],
            ),
          ),

          const Chetavni(
            'आपका नाम, गोत्र और जगह सिर्फ़ इसी फ़ोन में रहते हैं। '
            'न कोई लॉगिन, न कोई सर्वर, न कुछ बाहर भेजा जाता है।',
            icon: Icons.lock_outline,
          ),

          const Chetavni(
            'यह ऐप परंपरागत जानकारी देता है। किसी भी ज़रूरी काम का अंतिम '
            'निर्णय अपने पंडित जी से ही करें।',
          ),

          const SizedBox(height: 12),
          Text(
            'विधिवत · संस्करण 0.1.0\nMASS APP',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _chooseCity() async {
    final chosen = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (context, controller) => ListView.builder(
          controller: controller,
          itemCount: indianCities.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('शहर चुनिए',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              );
            }
            final city = indianCities[i - 1];
            return ListTile(
              title: Text(city.name),
              subtitle: Text(city.state),
              selected: city.name == settings.city.name,
              onTap: () => Navigator.of(context).pop(city),
            );
          },
        ),
      ),
    );

    if (chosen != null) await settings.setCity(chosen);
    if (mounted) setState(() {});
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
                const SizedBox(height: 18),
                const Text('गोत्र'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
