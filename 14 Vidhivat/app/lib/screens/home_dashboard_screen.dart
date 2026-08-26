import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/aane_wale_din.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'muhurta_screen.dart';
import 'samagri_screen.dart';
import 'sankalp_screen.dart';
import 'settings_screen.dart';
import 'vidhi_screen.dart';

/// The four-tab shell's starting point. It composes only real catalogue,
/// Panchang and locally saved progress data; it does not infer a ritual or
/// festival recommendation from the current date.
class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenPujaLibrary;

  const HomeDashboardScreen({
    super.key,
    required this.onOpenPujaLibrary,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late Future<_DashboardData> _data;
  String? _resumeIdAtLoad;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void didUpdateWidget(covariant HomeDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_resumeIdAtLoad != settings.latestPlayerProgressPujaId) {
      _refreshData();
    }
  }

  void _refreshData() {
    _resumeIdAtLoad = settings.latestPlayerProgressPujaId;
    _data = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final entries = await vidhiBhandar.suchi();
    final ready = entries.where((entry) => entry.taiyar).toList();
    if (ready.isEmpty) {
      throw StateError('पूजा की कोई तैयार विधि नहीं मिली।');
    }

    VidhiSuchiEntry? resumeEntry;
    Vidhi? resumeVidhi;
    final resumeId = settings.latestPlayerProgressPujaId;
    final resumeMatches = ready.where((entry) => entry.id == resumeId);
    if (resumeMatches.isNotEmpty) {
      final candidate = resumeMatches.first;
      final vidhi = await vidhiBhandar.vidhi(candidate.id);
      final progress =
          settings.playerProgressFor(candidate.id, vidhi.charan.length);
      if (progress != null) {
        resumeEntry = candidate;
        resumeVidhi = vidhi;
      }
    }

    final featuredEntry = resumeEntry ??
        ready.firstWhere(
          (entry) => entry.id == 'nitya_pooja',
          orElse: () => ready.first,
        );
    final featuredVidhi =
        resumeVidhi ?? await vidhiBhandar.vidhi(featuredEntry.id);

    const preferredPopular = [
      'ganesh_poojan',
      'satyanarayan',
      'grih_pravesh',
      'vahan_pooja',
    ];
    final popular = <VidhiSuchiEntry>[];
    for (final id in preferredPopular) {
      final matches = ready.where((entry) => entry.id == id);
      if (matches.isNotEmpty) popular.add(matches.first);
    }
    for (final entry in ready) {
      if (popular.length == 4) break;
      if (!popular.any((item) => item.id == entry.id)) popular.add(entry);
    }

    // ── आगे कौन सी पूजा कब है ──
    //
    // पूरी सूची पंचांग से बनती है — त्योहार इंजन के व्यापिनी नियम से,
    // और बाक़ी हर पूजा की अपनी `kabKarein` से। कोई तारीख़ हाथ से नहीं
    // भरी, इसलिए दस साल बाद भी सही रहेगी (→ D-038)।
    final sabhiVidhi = <Vidhi>[];
    for (final entry in ready) {
      sabhiVidhi.add(await vidhiBhandar.vidhi(entry.id));
    }
    final aage = aaneWaliPujaayein(
      pujaayein: sabhiVidhi,
      place: settings.place,
      masaSystem: settings.masaSystem,
      kitne: 5,
      dinAage: 45,
    );

    return _DashboardData(
      featuredEntry: featuredEntry,
      featuredVidhi: featuredVidhi,
      popular: popular,
      aageAaneWale: aage,
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openPuja(String id) => _push(VidhiScreen(id: id));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<_DashboardData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const SafeArea(
                child: VidhivatStateView(
                  title: 'होम अभी नहीं खुल सका',
                  message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                  icon: Icons.error_outline,
                  tone: VidhivatStateTone.error,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const SafeArea(
                child: VidhivatStateView(
                  title: 'आपका होम तैयार हो रहा है',
                  loading: true,
                ),
              );
            }

            final data = snapshot.data!;
            return SafeArea(
              bottom: false,
              child: VidhivatSacredBackdrop(
                child: Panna(
                  padding: const EdgeInsets.fromLTRB(
                    VidhivatSpacing.lg,
                    VidhivatSpacing.lg,
                    VidhivatSpacing.lg,
                    VidhivatSpacing.xxl,
                  ),
                  children: [
                    _HomeHeader(
                      onLocationTap: () => _push(const SettingsScreen()),
                    ),
                    const SizedBox(height: VidhivatSpacing.xl),
                    _FeaturedPuja(
                      data: data,
                      onOpen: () => _openPuja(data.featuredEntry.id),
                    ),
                    const SizedBox(height: VidhivatSpacing.lg),
                    const _PanchangPanel(),
                    if (data.aageAaneWale.isNotEmpty) ...[
                      const SizedBox(height: VidhivatSpacing.xxl),
                      const VidhivatSectionHeader(
                        title: 'आगे क्या आ रहा है',
                        supportingText: 'तारीख़ें पंचांग से, आपके शहर के हिसाब से',
                      ),
                      const SizedBox(height: VidhivatSpacing.md),
                      _AageAaneWali(
                        avsar: data.aageAaneWale,
                        onOpen: _openPuja,
                      ),
                    ],
                    const SizedBox(height: VidhivatSpacing.xl),
                    const VidhivatSectionHeader(
                      title: 'जल्दी करें',
                    ),
                    const SizedBox(height: VidhivatSpacing.md),
                    _QuickActionGrid(
                      onPuja: widget.onOpenPujaLibrary,
                      onMaterials: () => _push(
                        SamagriScreen(vidhi: data.featuredVidhi),
                      ),
                      onSankalp: () => _push(const SankalpScreen()),
                      onMuhurta: () => _push(const MuhurtaScreen()),
                    ),
                    const SizedBox(height: VidhivatSpacing.xxl),
                    VidhivatSectionHeader(
                      title: 'लोकप्रिय पूजा',
                      supportingText: 'सभी विधियाँ मौजूदा पूजा भंडार से',
                      action: VidhivatButton(
                        label: 'सभी देखें',
                        onPressed: widget.onOpenPujaLibrary,
                        variant: VidhivatButtonVariant.text,
                        compact: true,
                      ),
                    ),
                    const SizedBox(height: VidhivatSpacing.md),
                    _PopularPujaGrid(
                      entries: data.popular,
                      onOpen: _openPuja,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onLocationTap;

  const _HomeHeader({required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('जय श्री गणेश 🙏', style: type.pageTitle),
        const SizedBox(height: VidhivatSpacing.xs),
        Semantics(
          button: true,
          label: 'स्थान बदलें। ${settings.city.name}, ${settings.city.state}',
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: VidhivatRadius.small,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: VidhivatIconSize.small, color: colors.primary),
                  const SizedBox(width: VidhivatSpacing.xs),
                  Expanded(
                    child: Text(
                      '${settings.city.name}, ${settings.city.state}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          type.bodySmall.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: VidhivatIconSize.small, color: colors.textTertiary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedPuja extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onOpen;

  const _FeaturedPuja({required this.data, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final progress = settings.playerProgressFor(
      data.featuredEntry.id,
      data.featuredVidhi.charan.length,
    );
    final eyebrow = progress == null ? 'आज की सरल शुरुआत' : 'जहाँ छोड़ा था';
    final cta = progress == null ? 'पूजा शुरू करें' : 'पूजा जारी रखें';
    final isDefault = data.featuredEntry.id == 'nitya_pooja';
    final artwork = isDefault
        ? 'assets/images/devotional/home_ganesha_hero_v1.png'
        : DevotionalAssets.forVidhiId(data.featuredEntry.id).assetPath;
    return Semantics(
      container: true,
      label: '${data.featuredEntry.naam}। $eyebrow। $cta',
      child: Container(
        height: 210,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: VidhivatRadius.extraLarge,
          border: Border.all(color: colors.primary.withValues(alpha: 0.42)),
          color: colors.backgroundElevated,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: Transform.scale(
                  scale: 0.78,
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    artwork,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0, 0.48, 0.76, 1],
                  colors: [
                    colors.background.withValues(alpha: 0.99),
                    colors.background.withValues(alpha: 0.90),
                    colors.background.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(VidhivatSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.66,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          data.featuredEntry.naam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.sectionTitle,
                        ),
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          data.featuredEntry.ekLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        _HeroFacts(
                          duration: data.featuredVidhi.samayLikha,
                          steps: data.featuredVidhi.charan.length,
                          needsReview: !data.featuredEntry.paas,
                          resumeStep: progress == null
                              ? null
                              : progress.lastReachedStepIndex + 1,
                        ),
                        const SizedBox(height: VidhivatSpacing.xs),
                        SizedBox(
                          width: 154,
                          child: VidhivatButton(
                            label: cta,
                            semanticLabel: '${data.featuredEntry.naam} $cta',
                            onPressed: onOpen,
                            compact: true,
                            fullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroFacts extends StatelessWidget {
  final String duration;
  final int steps;
  final bool needsReview;
  final int? resumeStep;

  const _HeroFacts({
    required this.duration,
    required this.steps,
    required this.needsReview,
    required this.resumeStep,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule_outlined, size: 14, color: colors.primary),
            const SizedBox(width: VidhivatSpacing.xxs),
            Flexible(
              child: Text(
                '$duration  •  $steps चरण',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: type.caption.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
        if (resumeStep != null || needsReview) ...[
          const SizedBox(height: VidhivatSpacing.xxs),
          Row(
            children: [
              Icon(
                resumeStep != null
                    ? Icons.play_circle_outline
                    : Icons.info_outline,
                size: 14,
                color: resumeStep != null ? colors.info : colors.warning,
              ),
              const SizedBox(width: VidhivatSpacing.xxs),
              Flexible(
                child: Text(
                  resumeStep != null ? 'चरण $resumeStep' : 'जाँच बाकी',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.caption.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PanchangPanel extends StatelessWidget {
  const _PanchangPanel();

  @override
  Widget build(BuildContext context) {
    final p = settings.panchangFor(DateTime.now());
    final items = <({String label, String value, IconData icon})>[
      (label: 'तिथि', value: p.tithi.name, icon: Icons.brightness_2_outlined),
      (label: 'सूर्योदय', value: hm(p.sunrise), icon: Icons.wb_sunny_outlined),
      (
        label: 'राहुकाल',
        value: p.rahuKaal == null
            ? '—'
            : '${hm(p.rahuKaal!.start)}–${hm(p.rahuKaal!.end)}',
        icon: Icons.timelapse_outlined,
      ),
      (
        label: 'शुभ समय',
        value: p.abhijit == null
            ? '—'
            : '${hm(p.abhijit!.start)}–${hm(p.abhijit!.end)}',
        icon: Icons.spa_outlined,
      ),
    ];
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      variant: VidhivatCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('आज का पंचांग', style: type.sectionTitle),
          const SizedBox(height: VidhivatSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Expanded(
                    child: _PanchangMetric(
                      label: items[i].label,
                      value: items[i].value,
                      icon: items[i].icon,
                    ),
                  ),
                  if (i != items.length - 1)
                    VerticalDivider(
                      width: VidhivatSpacing.sm,
                      color: colors.primary.withValues(alpha: 0.28),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanchangMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PanchangMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: VidhivatIconSize.small, color: colors.primary),
        const SizedBox(height: VidhivatSpacing.xxs),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: type.caption.copyWith(color: colors.primary)),
        const SizedBox(height: VidhivatSpacing.xxs),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: type.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final VoidCallback onPuja;
  final VoidCallback onMaterials;
  final VoidCallback onSankalp;
  final VoidCallback onMuhurta;

  const _QuickActionGrid({
    required this.onPuja,
    required this.onMaterials,
    required this.onSankalp,
    required this.onMuhurta,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, IconData icon, VoidCallback tap})>[
      (label: 'पूजा विधि', icon: Icons.menu_book_outlined, tap: onPuja),
      (label: 'सामग्री', icon: Icons.ramen_dining_outlined, tap: onMaterials),
      (label: 'संकल्प', icon: Icons.water_drop_outlined, tap: onSankalp),
      (label: 'चौघड़िया', icon: Icons.calendar_month_outlined, tap: onMuhurta),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - VidhivatSpacing.sm) / 2;
        return Wrap(
          spacing: VidhivatSpacing.sm,
          runSpacing: VidhivatSpacing.sm,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                child: _QuickActionCard(
                  label: action.label,
                  icon: action.icon,
                  onTap: action.tap,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return VidhivatSurfaceCard(
      onTap: onTap,
      variant: VidhivatCardVariant.elevated,
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(
        horizontal: VidhivatSpacing.md,
        vertical: VidhivatSpacing.sm,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 54 + ((scale - 1).clamp(0.0, 1.0) * 26),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: VidhivatSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: type.cardTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularPujaGrid extends StatelessWidget {
  final List<VidhiSuchiEntry> entries;
  final ValueChanged<String> onOpen;

  const _PopularPujaGrid({required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - VidhivatSpacing.sm) / 2;
          return Wrap(
            spacing: VidhivatSpacing.sm,
            runSpacing: VidhivatSpacing.sm,
            children: [
              for (final entry in entries)
                SizedBox(
                  width: width,
                  child: _PopularPujaCard(
                    entry: entry,
                    onTap: () => onOpen(entry.id),
                  ),
                ),
            ],
          );
        },
      );
}

class _PopularPujaCard extends StatelessWidget {
  final VidhiSuchiEntry entry;
  final VoidCallback onTap;

  const _PopularPujaCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final artwork = DevotionalAssets.forVidhiId(entry.id);
    final displayName =
        entry.id == 'satyanarayan' ? 'सत्यनारायण पूजा' : entry.naam;
    return VidhivatSurfaceCard(
      onTap: onTap,
      variant: VidhivatCardVariant.elevated,
      semanticLabel: '${entry.naam} की विधि देखें',
      padding: const EdgeInsets.all(VidhivatSpacing.sm),
      child: SizedBox(
        height: 148 + ((scale - 1).clamp(0.0, 1.0) * 56),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.20),
                        blurRadius: 34,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    artwork.assetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.auto_awesome_outlined,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: VidhivatSpacing.xs),
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: type.cardTitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardData {
  final VidhiSuchiEntry featuredEntry;
  final Vidhi featuredVidhi;
  final List<VidhiSuchiEntry> popular;

  /// आगे आने वाली पूजाएँ, नज़दीक से दूर के क्रम में (→ D-038)।
  final List<PujaAvsar> aageAaneWale;

  const _DashboardData({
    required this.featuredEntry,
    required this.featuredVidhi,
    required this.popular,
    required this.aageAaneWale,
  });
}

/// **आगे क्या आ रहा है** — आज, कल, परसों और उसके बाद की पूजाएँ, क्रम से।
///
/// हर पंक्ति में तीन चीज़ें हैं: कब (आज/कल/12 दिन बाद), क्या (पूजा या
/// त्योहार का नाम), और क्यों (पूर्णिमा, मंगलवार, त्योहार)।
///
/// ⚠️ जिस त्योहार की विधि ऐप में नहीं बनी, वो **दिखता तो है पर खुलता
/// नहीं** — और उस पर साफ़ लिखा है "विधि अभी नहीं"। तारीख़ बता देना अपने
/// आप में काम की चीज़ है; उसके लिए विधि होना ज़रूरी नहीं।
class _AageAaneWali extends StatelessWidget {
  final List<PujaAvsar> avsar;
  final void Function(String id) onOpen;

  const _AageAaneWali({required this.avsar, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);

    return VidhivatSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < avsar.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: colors.borderSubtle),
            _AvsarPankti(
              avsar: avsar[i],
              onOpen: onOpen,
            ),
          ],
        ],
      ),
    );
  }
}

class _AvsarPankti extends StatelessWidget {
  final PujaAvsar avsar;
  final void Function(String id) onOpen;

  const _AvsarPankti({required this.avsar, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final text = Theme.of(context).textTheme;
    final aajHai = avsar.kitneDinBaad == 0;

    final semantics = avsar.khulSaktiHai
        ? '${avsar.naam}, ${avsar.kabLikha}, ${avsar.kyon}. खोलने के लिए दबाएँ'
        : '${avsar.naam}, ${avsar.kabLikha}, ${avsar.kyon}. इसकी विधि अभी ऐप में नहीं है';

    return Semantics(
      button: avsar.khulSaktiHai,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: avsar.khulSaktiHai ? () => onOpen(avsar.pujaId) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VidhivatSpacing.lg,
            vertical: VidhivatSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── कब ──
              SizedBox(
                width: 76,
                child: Text(
                  avsar.kabLikha,
                  style: text.labelLarge?.copyWith(
                    fontWeight: aajHai ? FontWeight.w700 : FontWeight.w600,
                    color: aajHai ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
              // ── क्या और क्यों ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avsar.naam,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      avsar.khulSaktiHai
                          ? avsar.kyon
                          : '${avsar.kyon} · विधि अभी नहीं',
                      style: text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (avsar.khulSaktiHai)
                Icon(Icons.chevron_right, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
