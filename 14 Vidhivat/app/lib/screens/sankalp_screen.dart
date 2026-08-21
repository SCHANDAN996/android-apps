import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:share_plus/share_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// संकल्प जनरेटर — **ऐप का सबसे बड़ा हथियार।**
///
/// हर पूजा संकल्प से शुरू होती है, और उसमें आज का संवत्, अयन, ऋतु, मास,
/// पक्ष, तिथि, वार, नक्षत्र सब बोलना पड़ता है। यहीं हर आदमी अटकता है।
///
/// हमारे पास पंचांग इंजन है, इसलिए यह वाक्य अपने आप बन जाता है — बस
/// नाम, गोत्र और काम चुनना है।
class SankalpScreen extends StatefulWidget {
  const SankalpScreen({super.key});

  @override
  State<SankalpScreen> createState() => _SankalpScreenState();
}

class _SankalpScreenState extends State<SankalpScreen> {
  String _purposeLabel = 'नित्य पूजा';
  bool _showFull = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = DateTime.now();
    final p = settings.panchangFor(day);

    if (!settings.hasYajman) return NaamPoochho(onDone: () => setState(() {}));

    final sankalp = buildSankalp(
      p,
      SankalpDetails(
        name: settings.name,
        gotra: settings.gotra,
        place: settings.city.name,
        purpose: commonPurposes[_purposeLabel] ?? 'देवपूजनं',
      ),
    );

    final text = _showFull ? sankalp.full : sankalp.simple;

    return Scaffold(
      appBar: AppBar(
        title: const Text('संकल्प'),
        actions: [
          IconButton(
            tooltip: 'नक़ल करो',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('संकल्प नक़ल हो गया')),
              );
            },
            icon: const Icon(Icons.copy_outlined),
          ),
          IconButton(
            tooltip: 'भेजो',
            onPressed: () => SharePlus.instance.share(ShareParams(text: text)),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Panna(
        children: [
          Text(
            '${tarikh(day)} · ${settings.city.name}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${p.varaName} · ${p.masaFullName} ${p.pakshaName} ${p.tithi.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: VidhivatTheme.haldi,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // ── किस काम का संकल्प ──
          Text('किस काम का संकल्प?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in commonPurposes.keys)
                ChoiceChip(
                  label: Text(label),
                  selected: _purposeLabel == label,
                  onSelected: (_) => setState(() => _purposeLabel = label),
                ),
            ],
          ),
          const SizedBox(height: 22),

          // ── पूरा या सरल ──
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('पूरा संकल्प')),
              ButtonSegment(value: false, label: Text('सरल (हिंदी में)')),
            ],
            selected: {_showFull},
            onSelectionChanged: (s) => setState(() => _showFull = s.first),
          ),
          const SizedBox(height: 18),

          // ── संकल्प का पाठ — बहुत बड़े अक्षरों में ──
          //
          // आदमी ज़मीन पर बैठा है, हाथ में जल है, फ़ोन दो फ़ुट दूर।
          // यहाँ छोटा फ़ॉन्ट किसी काम का नहीं।
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 22,
                  height: 1.85,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (sankalp.needsPanditReview)
            const Chetavni(
              'यह संकल्प पंचांग से अपने आप बना है। संस्कृत का रूप अभी '
              'पंडित जी से जाँचा नहीं गया — पहली बार किसी जानकार से मिला लें।',
              serious: true,
            ),

          // ── हिस्सों में — साथ-साथ बोलने के लिए ──
          Khand(
            title: 'हिस्सों में',
            subtitle: 'एक-एक करके बोलना हो तो',
            child: Column(
              children: [
                for (final part in sankalp.parts)
                  Pankti(part.label, part.value),
              ],
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text('${settings.name} · ${settings.gotra} गोत्र'),
              subtitle: const Text('बदलने के लिए दबाएँ'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NaamPoochho(onDone: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// नाम और गोत्र पूछने वाला पन्ना — एक बार भरो, फिर हमेशा याद।
///
/// विधि प्लेयर भी इसी को खोलता है, इसलिए यह सार्वजनिक है।
class NaamPoochho extends StatefulWidget {
  final VoidCallback onDone;

  const NaamPoochho({super.key, required this.onDone});

  @override
  State<NaamPoochho> createState() => NaamPoochhoState();
}

class NaamPoochhoState extends State<NaamPoochho> {
  late final _naam = TextEditingController(text: settings.name);
  late String _gotra = settings.gotra;

  @override
  void initState() {
    super.initState();
    // ⚠️ यह सुनना ज़रूरी है। बिना इसके "संकल्प बनाइए" वाला बटन नाम भरने
    // पर भी बंद रहता है — क्योंकि widget दोबारा बनता ही नहीं।
    // असली फ़ोन पर चलाने पर ही यह पकड़ में आया।
    _naam.addListener(_onNaamBadla);
  }

  void _onNaamBadla() => setState(() {});

  @override
  void dispose() {
    _naam.removeListener(_onNaamBadla);
    _naam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('संकल्प')),
      body: Panna(
        children: [
          Text('आपका नाम और गोत्र', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'संकल्प में यही बोला जाता है। एक बार भरिए — फिर हर बार अपने आप '
            'आ जाएगा।\n\nयह सिर्फ़ आपके फ़ोन में रहेगा, कहीं नहीं जाएगा।',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _naam,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 20),
            decoration: const InputDecoration(
              labelText: 'नाम',
              hintText: 'जैसे — चन्दन सिंह',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),

          Text('गोत्र', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'न पता हो तो "कश्यप" चुन लीजिए — यही आम चलन है।',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in commonGotras)
                ChoiceChip(
                  label: Text(g),
                  selected: _gotra == g,
                  onSelected: (_) => setState(() => _gotra = g),
                ),
            ],
          ),
          const SizedBox(height: 30),

          FilledButton(
            onPressed: _naam.text.trim().isEmpty
                ? null
                : () async {
                    await settings.setYajman(
                      name: _naam.text.trim(),
                      gotra: _gotra,
                    );
                    widget.onDone();
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: const Text('संकल्प बनाइए'),
          ),
        ],
      ),
    );
  }
}
