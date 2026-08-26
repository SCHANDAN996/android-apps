import 'dart:async';

import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// चौघड़िया और होरा — "अभी कोई काम शुरू करना हो तो कब"।
class MuhurtaScreen extends StatefulWidget {
  const MuhurtaScreen({super.key});

  @override
  State<MuhurtaScreen> createState() => _MuhurtaScreenState();
}

class _MuhurtaScreenState extends State<MuhurtaScreen>
    with WidgetsBindingObserver {
  DateTime _day = DateTime.now();
  Timer? _refreshTimer;
  String? _refreshContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
      _scheduleNextRefresh();
    } else {
      _refreshTimer?.cancel();
      _refreshContext = null;
    }
  }

  bool get _isToday {
    final now = DateTime.now();
    return _day.year == now.year &&
        _day.month == now.month &&
        _day.day == now.day;
  }

  void _showDay(DateTime day) {
    setState(() => _day = day);
    _scheduleNextRefresh();
  }

  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();
    _refreshContext = '${_day.year}-${_day.month}-${_day.day}|'
        '${settings.city.cacheKey}';
    if (!_isToday) return;

    final now = DateTime.now();
    final current = currentChoghadiya(now, settings.place);
    final untilBoundary = current?.end.difference(now);
    final safeDelay = untilBoundary != null &&
            untilBoundary > Duration.zero &&
            untilBoundary < const Duration(days: 1)
        ? untilBoundary + const Duration(seconds: 1)
        : const Duration(minutes: 15);

    _refreshTimer = Timer(safeDelay, () {
      if (!mounted) return;
      setState(() {});
      _scheduleNextRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expectedRefreshContext =
        '${_day.year}-${_day.month}-${_day.day}|${settings.city.cacheKey}';
    if (_refreshContext != expectedRefreshContext) {
      _refreshContext = expectedRefreshContext;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleNextRefresh();
      });
    }
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
          VidhivatIconAction(
            onPressed: () => _showDay(_day.subtract(const Duration(days: 1))),
            icon: Icons.chevron_left,
            tooltip: 'पिछला दिन',
          ),
          if (!_isToday)
            TextButton(
              onPressed: () => _showDay(DateTime.now()),
              child: const Text('आज'),
            ),
          VidhivatIconAction(
            onPressed: () => _showDay(_day.add(const Duration(days: 1))),
            icon: Icons.chevron_right,
            tooltip: 'अगला दिन',
          ),
        ],
      ),
      body: VidhivatSacredBackdrop(
        child: Panna(
          children: [
            // ── अभी क्या चल रहा है ──
            if (abhi != null)
              VidhivatSurfaceCard(
                key: const Key('current_choghadiya'),
                variant: VidhivatCardVariant.highlight,
                semanticLabel: [
                  'अभी ${abhi.name}',
                  abhi.auspicious! ? 'शुभ' : 'अशुभ',
                  '${hm(abhi.start)} से ${hm(abhi.end)}',
                  if (abhiHora != null)
                    '${abhiHora.name} का होरा, ${hm(abhiHora.start)} से ${hm(abhiHora.end)}',
                ].join(', '),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('अभी चल रही है',
                        style: VidhivatTheme.typographyOf(context).label),
                    const SizedBox(height: VidhivatSpacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            abhi.name,
                            style: VidhivatTheme.typographyOf(context)
                                .displayMedium
                                .copyWith(
                                  color: shubhColour(context, abhi.auspicious!),
                                ),
                          ),
                        ),
                        const SizedBox(width: VidhivatSpacing.sm),
                        VidhivatStatusChip(
                          label: abhi.auspicious! ? 'शुभ' : 'अशुभ',
                          tone: abhi.auspicious!
                              ? VidhivatStatusTone.success
                              : VidhivatStatusTone.warning,
                        ),
                      ],
                    ),
                    Text(
                      '${hm(abhi.start)} – ${hm(abhi.end)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (abhiHora != null) ...[
                      const SizedBox(height: VidhivatSpacing.sm),
                      Text(
                        '${abhiHora.name} का होरा · '
                        '${hm(abhiHora.start)} – ${hm(abhiHora.end)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),

            if (aage.isNotEmpty) ...[
              const SizedBox(height: VidhivatSpacing.xxl),
              const VidhivatSectionHeader(
                title: 'आगे की शुभ चौघड़िया',
                supportingText: 'कोई काम शुरू करना हो तो',
              ),
              const SizedBox(height: VidhivatSpacing.sm),
              VidhivatSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final s in aage)
                      Pankti(
                        s.name,
                        '${hm(s.start)} – ${hm(s.end)}',
                        note: s.isDay ? 'दिन' : 'रात',
                        valueColour: VidhivatTheme.colorsOf(context).success,
                        bold: true,
                      ),
                  ],
                ),
              ),
            ] else
              const SizedBox(height: VidhivatSpacing.lg),

            const SizedBox(height: VidhivatSpacing.xxl),
            // ── दिन और रात की चौघड़िया ──
            for (final din in [true, false])
              Padding(
                padding: const EdgeInsets.only(bottom: VidhivatSpacing.xl),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VidhivatSectionHeader(
                          title: din ? 'दिन की चौघड़िया' : 'रात की चौघड़िया'),
                      const SizedBox(height: VidhivatSpacing.sm),
                      VidhivatSurfaceCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var index = 0; index < chogh.length; index++)
                                if (chogh[index].isDay == din)
                                  _ChoghadiyaRow(
                                    slot: chogh[index],
                                    index: index,
                                    day: _day,
                                  ),
                            ],
                          )),
                    ]),
              ),

            // ── होरा ──
            const VidhivatSectionHeader(title: 'होरा'),
            const SizedBox(height: VidhivatSpacing.sm),
            VidhivatSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      VidhivatSpacing.md,
                      VidhivatSpacing.md,
                      VidhivatSpacing.md,
                      VidhivatSpacing.xs,
                    ),
                    child: Text(
                        'दिन का ${horas.isEmpty ? "—" : horas.first.duration.inMinutes} मिनट, '
                        'रात का ${horas.length > 12 ? horas[12].duration.inMinutes : "—"} मिनट',
                        style: VidhivatTheme.typographyOf(context).bodySmall),
                  ),
                  for (var i = 0; i < horas.length; i++)
                    Pankti(
                      '${i + 1}',
                      horas[i].name,
                      note:
                          '${hm(horas[i].start)}${dinKaNishan(horas[i].start, _day)}'
                          ' – ${hm(horas[i].end)}${dinKaNishan(horas[i].end, _day)}',
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VidhivatSpacing.xxs,
              ),
              child: Text(
                'सूर्योदय से चौबीस होरा गिनो तो अगले सूर्योदय पर अगले वार का '
                'स्वामी आ जाता है — वारों का क्रम इसी से बना है।',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoghadiyaRow extends StatelessWidget {
  final MuhurtaSlot slot;
  final int index;
  final DateTime day;

  const _ChoghadiyaRow({
    required this.slot,
    required this.index,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final range = '${hm(slot.start)}${dinKaNishan(slot.start, day)}'
        ' – ${hm(slot.end)}${dinKaNishan(slot.end, day)}';
    final status = slot.auspicious! ? 'शुभ' : 'अशुभ';

    return Semantics(
      key: Key('choghadiya_period_$index'),
      container: true,
      excludeSemantics: true,
      label: '${slot.name}, $range, $status',
      child: Pankti(
        slot.name,
        range,
        note: status,
        valueColour: shubhColour(context, slot.auspicious!),
      ),
    );
  }
}
