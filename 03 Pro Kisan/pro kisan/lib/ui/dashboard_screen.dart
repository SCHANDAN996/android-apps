import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/app_cubit.dart';
import '../data/india_states.dart';
import '../l10n/app_localizations.dart';
import '../data/weather_models.dart';
import '../db/dao/entry_dao.dart';
import '../db/dao/pashu_dao.dart';
import '../db/db_change_bus.dart';
import '../db/models/pashu.dart';
import '../services/weather_service.dart';
import 'weather/weather_common.dart';
import 'main_shell.dart';
import 'theme/dairy_theme.dart';

/// घर — किसान-friendly home.
///
/// डिज़ाइन नियम (UI_UX_SIMPLIFICATION_PLAN भाग-3A):
///  • ऊपर 4 बड़े "मुख्य काम" (2×2) — रोज़ का काम, बड़े icon, एक शब्द
///  • नीचे 6 "अन्य सेवाएँ" छोटे tiles के grid में (पहले 7 लंबी rows थीं — किसान खो जाता था)
///  • onboarding में चुने काम पहले दिखते हैं (personalization), पर कोई चीज़ छिपती नहीं
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// ऊपर की पट्टी के लिए — cache से आया आज का मौसम (कोई नया API call नहीं)
  CurrentWeather? _weather;
  String _weatherPlace = '';

  /// सबसे पास वाला ब्याना — किसान को रोज़ याद रहे
  Pashu? _nextCalving;

  /// आज का कुल दूध — dashboard की सबसे काम की संख्या।
  /// dbChangeBus सुनते हैं ताकि एंट्री होते ही यहाँ भी तुरंत बदले।
  double _todayMilkQty = 0;
  bool _todayHasEntry = false;

  @override
  void initState() {
    super.initState();
    _loadGlanceStrip();
    dbChangeBus.addListener(_loadTodayMilk);
  }

  @override
  void dispose() {
    dbChangeBus.removeListener(_loadTodayMilk);
    super.dispose();
  }

  Future<void> _loadTodayMilk() async {
    try {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      final entries = await EntryDao().getEntriesByDate(today);
      if (mounted) {
        setState(() {
          _todayHasEntry = entries.isNotEmpty;
          _todayMilkQty =
              entries.fold<double>(0, (sum, e) => sum + e.qtyL);
        });
      }
    } catch (_) {}
  }

  /// "एक नज़र में" पट्टी का data — सब स्थानीय, कोई इंतज़ार नहीं।
  /// मौसम सिर्फ़ cache से लेते हैं; dashboard खोलने पर network नहीं छूता।
  Future<void> _loadGlanceStrip() async {
    await _loadTodayMilk();
    try {
      final places = await WeatherService.instance.getPlaces();
      if (places.isNotEmpty) {
        final c = await WeatherService.instance.readCache(places.first);
        if (c != null && mounted) {
          setState(() {
            _weather = WeatherData.fromApi(c.data).current;
            _weatherPlace = places.first.name;
          });
        }
      }
    } catch (_) {}

    try {
      final upcoming =
          await PashuDao().getUpcomingCalvings(withinDays: 60);
      if (upcoming.isNotEmpty && mounted) {
        setState(() => _nextCalving = upcoming.first);
      }
    } catch (_) {}
  }

  String _t(BuildContext c, String k) => AppLocalizations.get(c, k);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppCubit>().state;
    final stateName = stateByCode(state.stateCode).hi;

    // ── 4 मुख्य काम — nav-tab पर ले जाते हैं (सीधे andar वाली screen नहीं) ──
    // इससे किसान हमेशा tab वाली मुख्य screen पर पहुँचता है, "दो पेज" का भ्रम नहीं।
    // भाव खेती tab (3) में है, इसलिए वह भी उसी tab पर जाता है।
    final main = <_Task>[
      _Task('dudh', _t(context, 'navMilk'), Icons.local_drink_rounded, DairyTheme.milkAccent, imageAsset: 'assets/images/3d_milk.webp', tabIndex: 1, sublabel: _t(context, 'navMilkSub')),
      _Task('pashu', _t(context, 'navPashu'), Icons.pets_rounded, DairyTheme.accentBrown, imageAsset: 'assets/images/3d_cattle.webp', tabIndex: 2, sublabel: _t(context, 'navPashuSub')),
      _Task('kheti', _t(context, 'navKheti'), Icons.grass_rounded, DairyTheme.khetiAccent, imageAsset: 'assets/images/3d_farm.webp', tabIndex: 3, sublabel: _t(context, 'navKhetiSub')),
      _Task('bhav', _t(context, 'navBhav'), Icons.trending_up_rounded, Colors.blue.shade700, imageAsset: 'assets/images/3d_rates.webp', route: '/mandi', sublabel: _t(context, 'navBhavSub')),
    ];
    if (state.occupations.isNotEmpty) {
      main.sort((a, b) {
        final ai = state.occupations.contains(a.key) ? 0 : 1;
        final bi = state.occupations.contains(b.key) ? 0 : 1;
        return ai.compareTo(bi);
      });
    }

    // ── 5 अन्य सेवाएँ — सीधे screen पर (ये किसी tab में नहीं हैं) ──
    final services = <_Task>[
      _Task('weather', _t(context, 'moreWeather'), Icons.wb_sunny_rounded, DairyTheme.amber, imageAsset: 'assets/images/3d_weather.webp', route: '/weather'),
      _Task('yojana', _t(context, 'moreYojana'), Icons.account_balance_rounded, Colors.purple.shade400, imageAsset: 'assets/images/3d_schemes.webp', route: '/yojana'),
      _Task('news', _t(context, 'moreNews'), Icons.article_rounded, Colors.teal.shade600, imageAsset: 'assets/images/3d_news.webp', route: '/news'),
      _Task('land', _t(context, 'navLand'), Icons.map_rounded, Colors.indigo.shade600, imageAsset: 'assets/images/3d_land.webp', route: '/land_measurement'),
      _Task('help', _t(context, 'dashHelplines'), Icons.phone_in_talk_rounded, Colors.red.shade600, imageAsset: 'assets/images/3d_helpline.webp', route: '/helpline'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ── Hero Farm Banner Header ──
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/header_farm_banner.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [DairyTheme.primaryTeal, DairyTheme.secondaryTeal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.50),
                            Colors.black.withValues(alpha: 0.20),
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top Row: Logo + App Name + Tagline + Location Pill ──
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.20),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.agriculture_rounded,
                                    color: DairyTheme.primaryTeal,
                                    size: 32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_t(context, 'appName'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(color: Colors.black45, blurRadius: 6)
                                          ])),
                                  Text(_t(context, 'tagline'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          shadows: const [
                                            Shadow(color: Colors.black45, blurRadius: 4)
                                          ])),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(stateName,
                                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── "आज एक नज़र में" — आज का दूध, मौसम, ब्याना ──
                        ..._glanceStrip(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 22, 16, 24 + MediaQuery.of(context).padding.bottom),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── मुख्य काम: 4 बड़े कार्ड (2×2) ──
                _sectionTitle(context, _t(context, 'quickTools')),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: main.map((t) => _bigCard(context, t)).toList(),
                ),

                const SizedBox(height: 28),

                // ── अन्य सेवाएँ: 3-column Grid ──
                _sectionTitle(context, _t(context, 'agriServices')),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: services.map((t) => _smallTile(context, t)).toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// हरे हिस्से के नीचे की पट्टी — आज का मौसम और आने वाला ब्याना।
  /// कुछ भी न हो (नया उपयोगकर्ता) तो पट्टी दिखती ही नहीं — खाली डिब्बे नहीं।
  List<Widget> _glanceStrip(BuildContext context) {
    final chips = <Widget>[];

    // आज का दूध — सिर्फ़ तब दिखे जब एंट्री हुई हो।
    // ("एंट्री बाकी" वाली याद-दिहानी हटाई गई — घर पर तक़ाज़ा अच्छा नहीं लगता।)
    if (_todayHasEntry) {
      chips.add(_glanceChip(
        context,
        emoji: '🥛',
        big: '${_todayMilkQty.toStringAsFixed(1)} ${_t(context, 'litres')}',
        small: _t(context, 'dashTodayMilk'),
        onTap: () => MainShell.goToTab.value = 1,
      ));
    }

    if (_weather != null) {
      final w = wmoInfo(context, _weather!.weatherCode);
      chips.add(_glanceChip(
        context,
        emoji: w['emoji']!,
        big: '${_weather!.temp.round()}°',
        small: _weatherPlace.isEmpty ? w['desc']! : _weatherPlace,
        onTap: () => Navigator.pushNamed(context, '/weather'),
      ));
    }

    if (_nextCalving != null) {
      final days = _nextCalving!.daysToCalving ?? 0;
      final name = _nextCalving!.trimmedName.isNotEmpty
          ? _nextCalving!.trimmedName
          : _t(context, 'pashuGaay');
      chips.add(_glanceChip(
        context,
        emoji: '🐄',
        big: days == 0
            ? _t(context, 'wToday')
            : '$days ${_t(context, 'pashuDaysLeft')}',
        small: name,
        onTap: () => Navigator.pushNamed(context, '/my_pashu'),
      ));
    }

    if (chips.isEmpty) return const [];

    return [
      const SizedBox(height: 14),
      Row(
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: chips[i]),
          ],
          // एक ही chip हो तो दूसरी तरफ़ जगह छोड़ो, फैलने मत दो
          if (chips.length == 1) const Expanded(child: SizedBox()),
        ],
      ),
    ];
  }

  Widget _glanceChip(
    BuildContext context, {
    required String emoji,
    required String big,
    required String small,
    required VoidCallback onTap,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(big,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    Text(small,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sectionTitle(BuildContext context, String text) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: DairyTheme.textDark));

  /// कार्ड खोलो — tab वाला हो तो nav बदलो, route वाला हो तो पुश करो।
  void _openTask(BuildContext context, _Task t) {
    if (t.tabIndex != null) {
      MainShell.goToTab.value = t.tabIndex!;
    } else if (t.route != null) {
      Navigator.pushNamed(context, t.route!);
    }
  }

  /// बड़ा कार्ड — रोज़ के मुख्य काम के लिए (3D image asset + elevated white card)
  Widget _bigCard(BuildContext context, _Task t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openTask(context, t),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: t.imageAsset != null
                        ? Image.asset(
                            t.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                  color: t.color.withValues(alpha: 0.14),
                                  shape: BoxShape.circle),
                              child: Icon(t.icon, color: t.color, size: 30),
                            ),
                          )
                        : Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                                color: t.color.withValues(alpha: 0.14),
                                shape: BoxShape.circle),
                            child: Icon(t.icon, color: t.color, size: 30),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B)),
                ),
                if (t.sublabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    t.sublabel!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// छोटा tile — 3D Image asset tile
  Widget _smallTile(BuildContext context, _Task t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openTask(context, t),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: t.imageAsset != null
                        ? Image.asset(
                            t.imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: t.color.withValues(alpha: 0.14),
                                  shape: BoxShape.circle),
                              child: Icon(t.icon, color: t.color, size: 22),
                            ),
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: t.color.withValues(alpha: 0.14),
                                shape: BoxShape.circle),
                            child: Icon(t.icon, color: t.color, size: 22),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      height: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Task {
  final String key, label;
  final IconData icon;
  final Color color;
  final String? imageAsset;
  final String? sublabel;

  /// इनमें से एक होगा:
  ///  • [tabIndex] — नीचे के nav-tab पर ले जाए
  ///  • [route] — सीधे उस screen पर पुश करे
  final int? tabIndex;
  final String? route;

  const _Task(this.key, this.label, this.icon, this.color,
      {this.imageAsset, this.tabIndex, this.route, this.sublabel});
}
