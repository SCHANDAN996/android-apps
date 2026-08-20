import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// चौघड़िया और होरा — "अभी कोई काम शुरू करना हो तो कब"।
class MuhurtaScreen extends StatefulWidget {
  const MuhurtaScreen({super.key});

  @override
  State<MuhurtaScreen> createState() => _MuhurtaScreenState();
}

class _MuhurtaScreenState extends State<MuhurtaScreen> {
  DateTime _day = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _day.year == now.year &&
        _day.month == now.month &&
        _day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final chogh = choghadiya(_day.year, _day.month, _day.day, settings.place);
    final horas = hora(_day.year, _day.month, _day.day, settings.place);

    final abhi = _isToday ? currentChoghadiya(now, settings.place) : null;
    final abhiHora = _isToday ? currentHora(now, settings.place) : null;
    final aage = _isToday
        ? upcomingAuspicious(now, settings.place, howMany: 3)
        : <MuhurtaSlot>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isToday ? 'चौघड़िया' : tarikhChhoti(_day)),
        actions: [
          IconButton(
            onPressed: () =>
                setState(() => _day = _day.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left),
          ),
          if (!_isToday)
            TextButton(
              onPressed: () => setState(() => _day = DateTime.now()),
              child: const Text('आज'),
            ),
          IconButton(
            onPressed: () =>
                setState(() => _day = _day.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Panna(
        children: [
          // ── अभी क्या चल रहा है ──
          if (abhi != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('अभी चल रही है', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          abhi.name,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: shubhColour(context, abhi.auspicious!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            abhi.auspicious! ? 'शुभ' : 'अशुभ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: shubhColour(context, abhi.auspicious!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${hm(abhi.start)} – ${hm(abhi.end)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (abhiHora != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        '${abhiHora.name} का होरा · '
                        '${hm(abhiHora.start)} – ${hm(abhiHora.end)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),

          if (aage.isNotEmpty) ...[
            const SizedBox(height: 20),
            Khand(
              title: 'आगे की शुभ चौघड़िया',
              subtitle: 'कोई काम शुरू करना हो तो',
              child: Column(
                children: [
                  for (final s in aage)
                    Pankti(
                      s.name,
                      '${hm(s.start)} – ${hm(s.end)}',
                      note: s.isDay ? 'दिन' : 'रात',
                      valueColour: VidhivatTheme.tulsi,
                      bold: true,
                    ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 20),

          // ── दिन और रात की चौघड़िया ──
          for (final din in [true, false])
            Khand(
              title: din ? 'दिन की चौघड़िया' : 'रात की चौघड़िया',
              child: Column(
                children: [
                  for (final s in chogh.where((s) => s.isDay == din))
                    Pankti(
                      s.name,
                      '${hm(s.start)}${dinKaNishan(s.start, _day)}'
                      ' – ${hm(s.end)}${dinKaNishan(s.end, _day)}',
                      note: s.auspicious! ? 'शुभ' : 'अशुभ',
                      valueColour: shubhColour(context, s.auspicious!),
                    ),
                ],
              ),
            ),

          // ── होरा ──
          Khand(
            title: 'होरा',
            subtitle: 'दिन का ${horas.isEmpty ? "—" : horas.first.duration.inMinutes} मिनट, '
                'रात का ${horas.length > 12 ? horas[12].duration.inMinutes : "—"} मिनट',
            child: Column(
              children: [
                for (var i = 0; i < horas.length; i++)
                  Pankti(
                    '${i + 1}',
                    horas[i].name,
                    note: '${hm(horas[i].start)}${dinKaNishan(horas[i].start, _day)}'
                        ' – ${hm(horas[i].end)}${dinKaNishan(horas[i].end, _day)}',
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'सूर्योदय से चौबीस होरा गिनो तो अगले सूर्योदय पर अगले वार का '
              'स्वामी आ जाता है — वारों का क्रम इसी से बना है।',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
