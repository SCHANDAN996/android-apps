import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// महीने का कैलेंडर और साल के त्योहार।
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('कैलेंडर'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'महीना'), Tab(text: 'त्योहार')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MahinaTab(
            month: _month,
            onShift: (n) => setState(
              () => _month = DateTime(_month.year, _month.month + n),
            ),
          ),
          _TyoharTab(year: _month.year),
        ],
      ),
    );
  }
}

class _MahinaTab extends StatelessWidget {
  final DateTime month;
  final void Function(int) onShift;

  const _MahinaTab({required this.month, required this.onShift});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              IconButton(
                onPressed: () => onShift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  tarikh(month).split(' ').skip(1).join(' '),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => onShift(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            itemCount: lastDay,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final day = DateTime(month.year, month.month, i + 1);
              final p = settings.panchangFor(day);
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;

              return Container(
                color: isToday
                    ? VidhivatTheme.haldi.withValues(alpha: 0.10)
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${day.day}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      child: Text(
                        p.varaName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.pakshaName} ${p.tithi.name}',
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            p.nakshatra.name,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (p.kshayaTithiName != null)
                      const _Nishan('क्षय', Icons.remove_circle_outline),
                    if (p.isVriddhiTithi)
                      const _Nishan('वृद्धि', Icons.add_circle_outline),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Nishan extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Nishan(this.label, this.icon);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 6, top: 2),
        child: Row(
          children: [
            Icon(icon, size: 15, color: VidhivatTheme.haldi),
            const SizedBox(width: 3),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: VidhivatTheme.haldi),
            ),
          ],
        ),
      );
}

class _TyoharTab extends StatelessWidget {
  final int year;

  const _TyoharTab({required this.year});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = festivalsInYear(year, settings.place);

    return Panna(
      children: [
        Text('$year के त्योहार', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'हर तारीख़ के नीचे लिखा है कि वो कैसे निकली।',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (final f in list) _TyoharCard(f: f),
      ],
    );
  }
}

class _TyoharCard extends StatelessWidget {
  final FestivalDate f;

  const _TyoharCard({required this.f});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      tarikhChhoti(f.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: VidhivatTheme.haldi,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      f.rule.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (f.shiftedForBhadra || f.missedKaal || f.ambiguous) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    if (f.shiftedForBhadra) const _Tag('भद्रा से खिसका'),
                    if (f.missedKaal) const _Tag('तिथि ने काल छुआ नहीं'),
                    if (f.ambiguous) const _Tag('दो दावेदार'),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                f.explanation,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.6,
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      );
}
