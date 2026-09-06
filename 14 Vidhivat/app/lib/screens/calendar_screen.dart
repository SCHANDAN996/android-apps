import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';

/// महीने का कैलेंडर और साल के त्योहार।
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  static const _maxFestivalCacheEntries = 8;
  static const _maxPanchangCacheEntries = 160;
  late final _tabs = TabController(length: 2, vsync: this);
  late DateTime _month;
  late DateTime _selectedDay;
  final Map<String, List<FestivalDate>> _festivalCache = {};
  final Map<String, Panchang> _panchangCache = {};

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _month = DateTime(today.year, today.month);
    _selectedDay = DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _shiftMonth(int offset) {
    final shifted = DateTime(_month.year, _month.month + offset);
    final lastDay = DateTime(shifted.year, shifted.month + 1, 0).day;
    final selectedDayNumber =
        _selectedDay.day > lastDay ? lastDay : _selectedDay.day;
    setState(() {
      _month = shifted;
      _selectedDay = DateTime(
        shifted.year,
        shifted.month,
        selectedDayNumber,
      );
    });
  }

  List<FestivalDate> _festivalsForYear(int year) {
    final key = '$year|${settings.city.cacheKey}';
    final cached = _festivalCache[key];
    if (cached != null) return cached;
    if (_festivalCache.length >= _maxFestivalCacheEntries) {
      _festivalCache.remove(_festivalCache.keys.first);
    }
    return _festivalCache[key] = festivalsInYear(year, settings.place);
  }

  Panchang _panchangFor(DateTime day) {
    final key = '${day.year}-${day.month}-${day.day}|${settings.city.cacheKey}|'
        '${settings.masaSystem.name}';
    final cached = _panchangCache[key];
    if (cached != null) return cached;
    if (_panchangCache.length >= _maxPanchangCacheEntries) {
      _panchangCache.remove(_panchangCache.keys.first);
    }
    return _panchangCache[key] = settings.panchangFor(day);
  }

  @override
  Widget build(BuildContext context) {
    final festivals = _festivalsForYear(_month.year);

    return Scaffold(
      appBar: AppBar(
        title: const Text('कैलेंडर'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'महीना'), Tab(text: 'त्योहार')],
        ),
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
          child: TabBarView(
            controller: _tabs,
            children: [
              _MahinaTab(
                month: _month,
                selectedDay: _selectedDay,
                festivals: festivals,
                panchangFor: _panchangFor,
                onShift: _shiftMonth,
                onSelect: (day) => setState(() => _selectedDay = day),
              ),
              _TyoharTab(year: _month.year, festivals: festivals),
            ],
          ),
        ),
      ),
    );
  }
}

class _MahinaTab extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final List<FestivalDate> festivals;
  final Panchang Function(DateTime) panchangFor;
  final void Function(int) onShift;
  final ValueChanged<DateTime> onSelect;

  const _MahinaTab({
    required this.month,
    required this.selectedDay,
    required this.festivals,
    required this.panchangFor,
    required this.onShift,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmptyCells = DateTime(month.year, month.month).weekday % 7;
    final today = DateTime.now();
    final selectedPanchang = panchangFor(selectedDay);
    final selectedFestivals = _festivalsOn(selectedDay, festivals);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.xxs,
        VidhivatSpacing.sm,
        VidhivatSpacing.xxs,
        VidhivatSpacing.xxl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: VidhivatSurfaceCard(
            variant: VidhivatCardVariant.highlight,
            padding: const EdgeInsets.symmetric(horizontal: VidhivatSpacing.xs),
            child: Row(
              children: [
                VidhivatIconAction(
                  key: const Key('calendar_previous_month'),
                  onPressed: () => onShift(-1),
                  icon: Icons.chevron_left,
                  tooltip: 'पिछला महीना',
                ),
                Expanded(
                  child: Text(
                    tarikh(month).split(' ').skip(1).join(' '),
                    textAlign: TextAlign.center,
                    style: VidhivatTheme.typographyOf(context).sectionTitle,
                  ),
                ),
                VidhivatIconAction(
                  key: const Key('calendar_next_month'),
                  onPressed: () => onShift(1),
                  icon: Icons.chevron_right,
                  tooltip: 'अगला महीना',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.md),
        _WeekdayHeader(),
        const SizedBox(height: VidhivatSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingEmptyCells + lastDay,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: VidhivatSpacing.massive,
          ),
          itemBuilder: (context, index) {
            if (index < leadingEmptyCells) {
              return const SizedBox.shrink();
            }
            final dayNumber = index - leadingEmptyCells + 1;
            final day = DateTime(month.year, month.month, dayNumber);
            final dayPanchang = panchangFor(day);
            final dayFestivals = _festivalsOn(day, festivals);
            return _CalendarDay(
              day: day,
              panchang: dayPanchang,
              selected: _sameDay(day, selectedDay),
              today: _sameDay(day, today),
              festivals: dayFestivals,
              onTap: () => onSelect(day),
            );
          },
        ),
        const SizedBox(height: VidhivatSpacing.xxl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: VidhivatSectionHeader(title: 'चुना हुआ दिन'),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: VidhivatSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Pankti('तारीख़', tarikh(selectedDay), bold: true),
                Pankti('वार', selectedPanchang.varaName),
                Pankti(
                  'तिथि',
                  '${selectedPanchang.pakshaName} ${selectedPanchang.tithi.name}',
                ),
                Pankti('नक्षत्र', selectedPanchang.nakshatra.name),
              ],
            ),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.xl),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: VidhivatSectionHeader(title: 'त्योहार / व्रत'),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VidhivatSpacing.sm),
          child: selectedFestivals.isEmpty
              ? Text(
                  'इस दिन कोई त्योहार या व्रत नहीं पड़ता।',
                  style: VidhivatTheme.typographyOf(context).bodySmall,
                )
              : Column(
                  children: [
                    for (final festival in selectedFestivals)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: VidhivatSpacing.sm,
                        ),
                        child: VidhivatSurfaceCard(
                          padding: const EdgeInsets.all(VidhivatSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  festival.rule.name,
                                  style: VidhivatTheme.typographyOf(context)
                                      .cardTitle,
                                ),
                              ),
                              if (festival.ambiguous)
                                const VidhivatStatusChip(
                                  label: 'दो तारीख़ें',
                                  tone: VidhivatStatusTone.info,
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final name in varaNames)
            Expanded(
              child: Semantics(
                label: name,
                excludeSemantics: true,
                child: SizedBox(
                  height: VidhivatActionSize.minimumTouchTarget,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: VidhivatSpacing.xxs,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name.replaceAll('वार', ''),
                          maxLines: 1,
                          style: VidhivatTheme.typographyOf(context).caption,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
}

class _CalendarDay extends StatelessWidget {
  final DateTime day;
  final Panchang panchang;
  final bool selected;
  final bool today;
  final List<FestivalDate> festivals;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.panchang,
    required this.selected,
    required this.today,
    required this.festivals,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final festivalNames = festivals.map((f) => f.rule.name).join(', ');
    final label = <String>[
      tarikh(day),
      panchang.varaName,
      '${panchang.pakshaName} ${panchang.tithi.name}',
      if (today) 'आज',
      if (festivals.isNotEmpty) 'त्योहार: $festivalNames',
    ].join(', ');

    return Semantics(
      key: Key('calendar_day_${day.year}_${day.month}_${day.day}'),
      label: label,
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(VidhivatSpacing.xxs),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : VidhivatMotion.fast,
          curve: Curves.easeOut,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryMuted
                : today
                    ? colors.surfaceSubtle
                    : colors.surface.withValues(alpha: 0),
            borderRadius: VidhivatRadius.small,
            border: selected || today
                ? Border.all(
                    color: selected ? colors.primary : colors.info,
                    width: VidhivatStroke.focus,
                  )
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: VidhivatSpacing.xxl,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${day.day}',
                        maxLines: 1,
                        style: VidhivatTheme.typographyOf(context)
                            .label
                            .copyWith(
                              fontWeight:
                                  selected || today ? FontWeight.w700 : null,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: VidhivatSpacing.sm,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (today)
                          Icon(
                            Icons.today_outlined,
                            size: VidhivatSpacing.sm,
                            color: colors.info,
                          ),
                        if (today && festivals.isNotEmpty)
                          const SizedBox(width: VidhivatSpacing.xxs),
                        if (festivals.isNotEmpty)
                          Icon(
                            Icons.event_outlined,
                            size: VidhivatSpacing.sm,
                            color: colors.primary,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TyoharTab extends StatelessWidget {
  final int year;
  final List<FestivalDate> festivals;

  const _TyoharTab({required this.year, required this.festivals});

  @override
  Widget build(BuildContext context) {
    return Panna(
      children: [
        VidhivatSectionHeader(
            title: '$year के त्योहार',
            supportingText: 'तारीख़ें आपके शहर के सूर्योदय से'),
        const SizedBox(height: VidhivatSpacing.lg),
        for (final f in festivals) _TyoharCard(f: f),
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
    final colors = VidhivatTheme.colorsOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
      child: VidhivatSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: VidhivatSpacing.massive + VidhivatSpacing.xxl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tarikhChhoti(f.date),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (f.ambiguous && f.otherCandidate != null)
                        Text(
                          'या ${tarikhChhoti(f.otherCandidate!)}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
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
              const SizedBox(height: VidhivatSpacing.xs),
              Wrap(
                spacing: VidhivatSpacing.xs,
                runSpacing: VidhivatSpacing.xs,
                children: [
                  if (f.shiftedForBhadra)
                    const VidhivatStatusChip(
                      label: 'भद्रा से खिसका',
                      tone: VidhivatStatusTone.warning,
                    ),
                  if (f.missedKaal)
                    const VidhivatStatusChip(
                      label: 'तिथि ने काल छुआ नहीं',
                      tone: VidhivatStatusTone.warning,
                    ),
                  if (f.ambiguous)
                    const VidhivatStatusChip(
                      label: 'दो तारीख़ें',
                      tone: VidhivatStatusTone.info,
                    ),
                ],
              ),
            ],
            // ── चार से छह लाइन का हिसाब यहाँ खुला पड़ा रहता था ──
            //
            // हर कार्ड पर, यानी **साल में लगभग चालीस बार** — मास,
            // पक्ष, तिथि, व्यापिनी नियम, तिथि के दोनों सिरे, भद्रा,
            // और नीचे "दृक् गणित · लाहिड़ी अयनांश · पूर्णिमांत पद्धति"।
            //
            // यूज़र को यहाँ **तारीज़़** चाहिए। हिसाब तभी चाहिए जब किसी
            // दूसरे पंचांग से फ़र्क़ दिखे — और तब वो पूरा मिलना चाहिए,
            // इसलिए मिटाया नहीं, एक दबाव पीछे किया (→ D-045, D-056)।
            _TyoharKaHisaab(f: f),
          ],
        ),
      ),
    );
  }
}

/// एक त्योहार की तारीख़ का पूरा हिसाब — ℹ के पीछे (→ D-056)।
///
/// इंजन का `explanation` एक ही डोरी है, लाइनों में बंटी हुई।
/// **आख़िरी लाइन हमेशा गणित की पद्धति होती है** ("दृक् गणित ·
/// लाहिड़ी अयनांश · … पद्धति") — वो अलग पंक्ति बनती है, बाक़ी
/// सब एक साथ। इंजन को छूए बिना यही सबसे सीधा रास्ता था।
class _TyoharKaHisaab extends StatelessWidget {
  final FestivalDate f;

  const _TyoharKaHisaab({required this.f});

  @override
  Widget build(BuildContext context) {
    final lines = f.explanation.split('\n');
    final ganit = lines.length > 1 ? lines.last : '';
    final hisaab =
        (lines.length > 1 ? lines.sublist(0, lines.length - 1) : lines)
            .join('\n');
    return VidhivatSrotButton(
      label: 'यह तारीख़ कैसे बनी',
      shirshak: f.rule.name,
      panktiyan: [
        VidhivatSrotPankti('हिसाब', hisaab),
        VidhivatSrotPankti('गणना', ganit),
      ],
      antimBaat: 'आपके घर या क्षेत्र का चलन अलग हो तो वही सही है।',
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<FestivalDate> _festivalsOn(
  DateTime day,
  List<FestivalDate> festivals,
) =>
    festivals
        .where(
          (festival) =>
              _sameDay(festival.date, day) ||
              (festival.ambiguous &&
                  festival.otherCandidate != null &&
                  _sameDay(festival.otherCandidate!, day)),
        )
        .toList(growable: false);
