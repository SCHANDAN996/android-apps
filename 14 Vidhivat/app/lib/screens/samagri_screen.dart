import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';

/// सामग्री की सूची — टिक लगाओ, और WhatsApp पर भेजो।
///
/// यह पन्ना बाज़ार में खुलता है, इसलिए:
/// - अक्षर बड़े, टिक का डिब्बा बड़ा (चलते-चलते उँगली से लगेगा)
/// - टिक फ़ोन में याद रहती है, ऐप बंद करने पर मिटती नहीं
/// - "सिर्फ़ ज़रूरी" वाला बटन — पूरी सूची देखकर लोग घबरा जाते हैं
///
/// टिक **सिर्फ़ इसी फ़ोन में** रहती है, कहीं नहीं जाती (→ D-004)।
class SamagriScreen extends StatefulWidget {
  final Vidhi vidhi;

  const SamagriScreen({super.key, required this.vidhi});

  @override
  State<SamagriScreen> createState() => _SamagriScreenState();
}

class _SamagriScreenState extends State<SamagriScreen> {
  bool _sirfZaruri = false;

  Vidhi get vidhi => widget.vidhi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ticks = settings.samagriTicks(vidhi.id);

    // टिक सामग्री के पूरे क्रम पर लगती है, छाँटी हुई सूची पर नहीं —
    // वरना "सिर्फ़ ज़रूरी" चालू करते ही टिक दूसरी चीज़ों पर खिसक जाएँगी।
    final kul = _sirfZaruri ? vidhi.zaruriSamagri.length : vidhi.samagri.length;
    final lagiHui = _sirfZaruri
        ? ticks.where((i) => vidhi.samagri[i].zaruri).length
        : ticks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('सामग्री'),
        actions: [
          IconButton(
            tooltip: 'भेजो',
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: vidhi.samagriText(sirfZaruri: _sirfZaruri)),
            ),
            icon: const Icon(Icons.share_outlined),
          ),
          if (ticks.isNotEmpty)
            IconButton(
              tooltip: 'सारी टिक हटाओ',
              onPressed: () async {
                await settings.clearSamagriTicks(vidhi.id);
                if (context.mounted) setState(() {});
              },
              icon: const Icon(Icons.restart_alt),
            ),
        ],
      ),
      body: Panna(
        children: [
          Text(vidhi.naam, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  '$lagiHui / $kul जुट गईं',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: lagiHui == kul && kul > 0
                        ? VidhivatTheme.tulsi
                        : null,
                  ),
                ),
              ),
              FilterChip(
                label: const Text('सिर्फ़ ज़रूरी'),
                selected: _sirfZaruri,
                onSelected: (v) => setState(() => _sirfZaruri = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: kul == 0 ? 0 : lagiHui / kul,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 22),

          for (final entry in vidhi.samagriSamuhWar.entries)
            ..._samuhKhand(context, entry.key, entry.value, ticks),

          const SizedBox(height: 8),
          Text(
            'टिक सिर्फ़ आपके फ़ोन में रहती है। "सारी टिक हटाओ" से अगली '
            'बार के लिए सूची साफ़ हो जाती है।',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  List<Widget> _samuhKhand(
    BuildContext context,
    String samuh,
    List<({int index, Samagri samagri})> cheezein,
    Set<int> ticks,
  ) {
    final dikhane = cheezein
        .where((e) => !_sirfZaruri || e.samagri.zaruri)
        .toList(growable: false);
    if (dikhane.isEmpty) return const [];

    return [
      Khand(
        title: samuh,
        child: Column(
          children: [
            for (var i = 0; i < dikhane.length; i++) ...[
              if (i > 0) const Divider(),
              _SamagriPankti(
                samagri: dikhane[i].samagri,
                index: dikhane[i].index,
                ticked: ticks.contains(dikhane[i].index),
                onChanged: (index, value) async {
                  await settings.setSamagriTick(vidhi.id, index, value);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

class _SamagriPankti extends StatelessWidget {
  final Samagri samagri;
  final int index;
  final bool ticked;
  final void Function(int index, bool value) onChanged;

  const _SamagriPankti({
    required this.samagri,
    required this.index,
    required this.ticked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maap = [samagri.matra, samagri.ikai]
        .where((s) => s.trim().isNotEmpty)
        .join(' ');

    return CheckboxListTile(
      value: ticked,
      onChanged: (v) => onChanged(index, v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              samagri.vastu,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: ticked ? TextDecoration.lineThrough : null,
                color: ticked
                    ? theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.45)
                    : null,
              ),
            ),
          ),
          if (maap.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                maap,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: VidhivatTheme.haldi,
                ),
              ),
            ),
        ],
      ),
      subtitle: (samagri.note.isNotEmpty || !samagri.zaruri)
          ? Text(
              [
                if (!samagri.zaruri) 'वैकल्पिक',
                if (samagri.note.isNotEmpty) samagri.note,
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            )
          : null,
    );
  }
}
