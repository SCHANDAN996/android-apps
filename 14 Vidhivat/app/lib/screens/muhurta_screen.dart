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
    // ⚠️ `current.end.difference(now)` मत लिखना। इंजन के समय घड़ी वाले
    // हैं पर उन पर UTC का ठप्पा है, और `now` असली local पल है — सीधे
    // घटाने पर जवाब पूरे 5:30 घंटे खिसक जाता है (→ `_ghadiKaSamay`)।
    final untilBoundary = current?.khatmHoneMein(now);
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
      // ⚠️ `SafeArea(top: false)` के बिना नीचे का आख़िरी हिस्सा Android
      // के नेविगेशन बार (होम/बैक) के **पीछे** चला जाता था — "आज" वाले
      // पन्ने पर सबसे नीचे की "दृक् गणित · … · हैदराबाद" वाली लाइन
      // आधी कटी दिखती थी।
      //
      // वजह: Android 15 से ऐप ज़बरदस्ती edge-to-edge चलता है — उसे पूरी
      // स्क्रीन मिलती है (यहाँ 720×1600), सिस्टम बार के नीचे की जगह
      // समेत। `top: false` इसलिए कि ऊपर AppBar पहले से सँभाल लेता है।
      //
      // फ़ोन पर पकड़ा गया (4 सित 2026), vivo V2553 · तीन-बटन वाला बार।
      body: SafeArea(
        top: false,
        child: VidhivatSacredBackdrop(
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
                                    color:
                                        shubhColour(context, abhi.auspicious!),
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
                                for (var index = 0;
                                    index < chogh.length;
                                    index++)
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

              // ── सिद्धांत वाला नोट यहाँ खुला पड़ा था — अब ℹ में ────
              //
              // वो रोचक है, पर काम का नहीं — यूज़र यहाँ यह देखने आता है
              // कि **अभी कौन सी चौघड़िया चल रही है**। साथ ही यहाँ अब वो
              // बातें भी हैं जो पहले कहीं लिखी ही नहीं थीं — चौघड़िया और
              // होरा हैं क्या, और गणना कहाँ से होती है (→ D-056)।
              const _ChoghadiyaKeNiyam(),
            ],
          ),
        ),
      ),
    );
  }
}

/// चौघड़िया और होरा के नियम — ℹ के पीछे (→ D-045, D-056)।
class _ChoghadiyaKeNiyam extends StatelessWidget {
  const _ChoghadiyaKeNiyam();

  @override
  Widget build(BuildContext context) => const VidhivatSrotButton(
        label: 'चौघड़िया और होरा के बारे में',
        panktiyan: [
          VidhivatSrotPankti(
            'चौघड़िया',
            'सूर्योदय से सूर्यास्त तक का समय आठ बराबर हिस्सों में बँटता है, '
            'और सूर्यास्त से अगले सूर्योदय तक भी आठ में। हर हिस्से का '
            'अपना नाम है — कुछ शुभ माने जाते हैं, कुछ नहीं।',
          ),
          VidhivatSrotPankti(
            'होरा',
            'दिन-रात के चौबीस हिस्से, हर एक का अपना स्वामी ग्रह। होरा '
            'ठीक एक घंटे का नहीं होता — दिन और रात की लंबाई के साथ '
            'छोटा-बड़ा होता है। ऊपर दोनों की लंबाई लिखी है।',
          ),
          VidhivatSrotPankti(
            'वारों का क्रम',
            'सूर्योदय से चौबीस होरा गिनो तो अगले सूर्योदय पर अगले वार '
            'का स्वामी आ जाता है — वारों का क्रम इसी से बना है।',
          ),
          VidhivatSrotPankti(
            'गणना',
            'आपके शहर के सूर्योदय और सूर्यास्त से। दूसरे शहर के पंचांग '
            'से मिनटों का फ़र्क़ हो सकता है।',
          ),
        ],
        antimBaat: 'शुभ-अशुभ की मान्यता परंपरा से है। किसी ज़रूरी काम का '
            'अंतिम निर्णय अपने पंडित जी से करें।',
      );
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
