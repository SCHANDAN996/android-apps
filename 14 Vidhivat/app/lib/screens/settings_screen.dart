import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../app_version.dart';
import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/jagah_khoj.dart';

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
              // ── एक खाना, एक पन्ना (→ D-134) ──
              // पहले यहाँ चार चीज़ें थीं — यह खाना, «मेरी जगह अपने आप पहचानें», «शहर हाथ
              // से चुनें» और «अपनी जगह का नाम»। डेवलपर: "इतना complicated कि यूज़र
              // परेशान हो जाए"। अब फ़ोन की जगह भी उसी पन्ने में सबसे ऊपर है।
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  key: const Key('meri_jagah'),
                  leading: Icon(
                    settings.city.isDeviceDetected
                        ? Icons.my_location_outlined
                        : Icons.location_on_outlined,
                  ),
                  title: Text(settings.city.name),
                  subtitle: Text('${settings.city.state} · बदलने के लिए दबाएँ'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _chooseCity,
                ),
              ),
              const SizedBox(height: VidhivatSpacing.xs),
              // संकल्प में बोला जाने वाला नाम (→ D-058) — जगह चुनने से अलग, छोटी कड़ी
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _editSthanNaam,
                  child: Text(RegExp(r'[ऀ-ॿ]').hasMatch(settings.city.name)
                      ? 'संकल्प में जगह का नाम बदलें'
                      : 'संकल्प के लिए जगह का नाम हिंदी में लिखें'),
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
                textAlign: TextAlign.justify,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(
                'यह ऐप परंपरागत जानकारी देता है। किसी भी ज़रूरी काम का '
                'अंतिम निर्णय अपने पंडित जी से ही करें।',
                textAlign: TextAlign.justify,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              // ⚠ यह अंक `pubspec.yaml` के version से मिलता रहे —
              // `settings_version_test.dart` उसी पर पहरा देता है।
              Text(
                'विधिवत · संस्करण $appVersion',
                textAlign: TextAlign.justify,
                style: theme.textTheme.bodySmall,
              ),
              // खुले स्रोत के लाइसेंस — Flutter के पैकेज, और गाँवों की सूची का
              // श्रेय (CC BY 4.0 की शर्त; → D-128)। ऐप के पाठ में किसी का नाम नहीं।
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'विधिवत',
                    applicationVersion: appVersion,
                  ),
                  child: const Text('लाइसेंस'),
                ),
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
        title: const Text('संकल्प में जगह का नाम'),
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

  /// जगह चुनना — फ़ोन की अभी की जगह, या नाम से खोज (→ D-134)। गाँव का नाम अंग्रेज़ी
  /// अक्षरों में हो तो वैसा ही रखा जाता है; संकल्प के लिए हिंदी नाम ऊपर वाली छोटी कड़ी से
  /// (पहले यहाँ हर बार एक dialog पूछता था — एक और रुकावट)।
  Future<void> _chooseCity() async {
    final chosen = await jagahChuno(
      context,
      selectedCity: settings.city,
      shirshak: 'अपनी जगह चुनें',
      phoneKiJagah: 'स्थान सिर्फ़ पंचांग के लिए — फ़ोन से बाहर नहीं जाता',
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
