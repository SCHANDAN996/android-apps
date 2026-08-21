import 'package:flutter/material.dart';

import '../theme.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import 'vidhi_screen.dart';

/// पूजाओं की सूची — **ऐप का पहला पन्ना।**
///
/// विधि ही ऐप का दिल है (→ D-002) और यही इकलौती चीज़ है जो किसी
/// प्रतियोगी के पास नहीं (→ D-012)। इसलिए यह सबसे आगे है, पंचांग नहीं।
///
/// जो पूजा अभी बनी नहीं, वो सूची में **साफ़-साफ़ "जल्द आएगी"** के साथ
/// दिखती है — छिपाई नहीं जाती, पर खुलती भी नहीं। अधूरी चीज़ आधी बनाकर
/// दिखाना इस प्रोजेक्ट में मना है।
class VidhiListScreen extends StatefulWidget {
  const VidhiListScreen({super.key});

  @override
  State<VidhiListScreen> createState() => _VidhiListScreenState();
}

class _VidhiListScreenState extends State<VidhiListScreen> {
  late Future<List<VidhiSuchiEntry>> _suchi;

  @override
  void initState() {
    super.initState();
    _suchi = vidhiBhandar.suchi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('पूजा विधि')),
      body: FutureBuilder<List<VidhiSuchiEntry>>(
        future: _suchi,
        builder: (context, snap) {
          if (snap.hasError) {
            return Panna(
              children: [
                Chetavni(
                  'पूजाओं की सूची नहीं खुल सकी।\n\n${snap.error}',
                  icon: Icons.error_outline,
                  serious: true,
                ),
              ],
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final suchi = snap.data!;
          final taiyar = suchi.where((e) => e.taiyar).length;
          final paas = suchi.where((e) => e.paas).length;

          return Panna(
            children: [
              for (final shreni in Shreni.values)
                if (suchi.any((e) => e.shreni == shreni))
                  Khand(
                    title: shreni.naam,
                    child: Column(
                      children: [
                        for (final e in suchi.where((x) => x.shreni == shreni))
                          _PoojaPankti(entry: e),
                      ],
                    ),
                  ),

              // सच्चाई साफ़ लिखी है — और सबसे ज़रूरी संख्या पंडित जी वाली है,
              // कितनी पूजाएँ लिखी जा चुकीं वो नहीं।
              Text(
                taiyar < suchi.length
                    ? '$taiyar / ${suchi.length} पूजाएँ जुड़ चुकी हैं, बाक़ी पर '
                        'काम चल रहा है।'
                    : paas == suchi.length
                        ? 'सारी ${suchi.length} पूजाएँ पंडित जी से जाँची हुई हैं।'
                        : 'सारी ${suchi.length} पूजाएँ जुड़ चुकी हैं, पर अभी '
                            '$paas / ${suchi.length} ही पंडित जी से जाँची गई '
                            'हैं। जो नहीं जाँची, उन पर खोलते ही चेतावनी दिखती '
                            'है — और मंत्र वहीं तक लिखे हैं जहाँ तक भरोसेमंद '
                            'स्रोत मिला।',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// सूची की एक पंक्ति।
class _PoojaPankti extends StatelessWidget {
  final VidhiSuchiEntry entry;

  const _PoojaPankti({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dhundhla = !entry.taiyar;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      enabled: entry.taiyar,
      leading: Icon(
        entry.taiyar ? Icons.local_fire_department_outlined : Icons.schedule,
        color: dhundhla
            ? theme.disabledColor
            : (entry.paas ? VidhivatTheme.tulsi : VidhivatTheme.haldi),
      ),
      title: Text(
        entry.naam,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: dhundhla ? theme.disabledColor : null,
        ),
      ),
      subtitle: Text(
        dhundhla ? 'जल्द आएगी' : entry.ekLine,
        style: theme.textTheme.bodySmall?.copyWith(
          color: dhundhla ? theme.disabledColor : null,
        ),
      ),
      trailing: entry.taiyar ? const Icon(Icons.chevron_right) : null,
      onTap: entry.taiyar
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VidhiScreen(id: entry.id),
                ),
              )
          : null,
    );
  }
}
