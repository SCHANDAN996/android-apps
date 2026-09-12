import 'package:flutter/material.dart';

import '../theme.dart';
import '../state/settings.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/parv.dart';
import '../vidhi/parv_aaj.dart';
import '../vidhi/planned_puja_catalog.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'vidhi_screen.dart';
import 'parv_screen.dart';

/// विधि का home — catalogue नहीं, पूजा चुनने की शुरुआती जगह।
///
/// सारी सामग्री assets से ही आती है। इस screen में कोई नई पूजा, समय या
/// धार्मिक दावा नहीं लिखा जाता; वह सिर्फ़ मौजूदा catalogue को पढ़ने में
/// आसान क्रम में रखती है।
class VidhiListScreen extends StatefulWidget {
  const VidhiListScreen({super.key});

  @override
  State<VidhiListScreen> createState() => _VidhiListScreenState();
}

class _VidhiListScreenState extends State<VidhiListScreen> {
  late Future<_VidhiHomeData> _home;

  @override
  void initState() {
    super.initState();
    _home = _loadHome();
  }

  Future<_VidhiHomeData> _loadHome() async {
    final entries = await vidhiBhandar.suchi();
    final ready =
        entries.where((entry) => entry.taiyar).toList(growable: false);
    if (ready.isEmpty) {
      throw StateError('पूजा की कोई तैयार विधि नहीं मिली।');
    }

    // नित्य पूजा एक real, frequently useful entry है। वह उपलब्ध न हो तो
    // catalogue की पहली तैयार पूजा feature बनती है — कोई placeholder नहीं।
    final featuredEntry = ready.firstWhere(
      (entry) => entry.id == 'nitya_pooja',
      orElse: () => ready.first,
    );

    return _VidhiHomeData(
      entries: entries,
      featuredEntry: featuredEntry,
      featuredVidhi: await vidhiBhandar.vidhi(featuredEntry.id),
      navratri: await parvBhandar.parv('navratri'),
    );
  }

  void _open(VidhiSuchiEntry entry) {
    if (!entry.taiyar) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VidhiScreen(id: entry.id)),
    );
  }

  void _openVidhiId(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VidhiScreen(id: id)),
    );
  }

  void _openNavratri(Parv parv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ParvScreen(
          parv: parv,
          aaj: navratriAaj(aaj: DateTime.now(), place: settings.place),
          onVidhiKholo: _openVidhiId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_VidhiHomeData>(
        future: _home,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SafeArea(
              child: VidhivatStateView(
                title: 'पूजाओं की सूची नहीं खुल सकी',
                message: 'ऐप दोबारा खोलकर फिर कोशिश करें।',
                icon: Icons.error_outline,
                tone: VidhivatStateTone.error,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const SafeArea(
              child: VidhivatStateView(
                title: 'पूजाएँ तैयार हो रही हैं',
                loading: true,
              ),
            );
          }

          final home = snapshot.data!;
          return SafeArea(
            bottom: false,
            child: _VidhiHome(
              data: home,
              onOpen: _open,
              onParvOpen: _openNavratri,
            ),
          );
        },
      ),
    );
  }
}

class _VidhiHome extends StatelessWidget {
  final _VidhiHomeData data;
  final ValueChanged<VidhiSuchiEntry> onOpen;
  final ValueChanged<Parv> onParvOpen;

  const _VidhiHome({
    required this.data,
    required this.onOpen,
    required this.onParvOpen,
  });

  @override
  Widget build(BuildContext context) {
    final daily = data.entries
        .where((entry) =>
            entry.shreni == Shreni.nitya && entry.id != data.featuredEntry.id)
        .toList(growable: false);
    final festivals = data.entries
        .where((entry) => entry.shreni == Shreni.tyohar)
        .toList(growable: false);
    final special = data.entries
        .where((entry) =>
            entry.shreni != Shreni.nitya && entry.shreni != Shreni.tyohar)
        .toList(growable: false);

    return VidhivatSacredBackdrop(
      child: Panna(
        padding: const EdgeInsets.fromLTRB(
          VidhivatSpacing.lg,
          VidhivatSpacing.lg,
          VidhivatSpacing.lg,
          VidhivatSpacing.xxl,
        ),
        children: [
          // नीचे वाली पट्टी पर इस पन्ने का नाम "पूजा" है — शीर्षक भी
          // वही होना चाहिए, वरना यूज़र को लगता है वो कहीं और आ गया।
          // (चुनते पूजा हैं, पढ़ते उसकी विधि हैं — इसीलिए कार्ड पर
          // "विधि देखें" ही लिखा रहता है।)
          Text('पूजा', style: VidhivatTheme.typographyOf(context).pageTitle),
          const SizedBox(height: VidhivatSpacing.xs),
          Text(
            'आज क्या करना चाहते हैं?',
            style: VidhivatTheme.typographyOf(context).bodyMedium,
          ),
          const SizedBox(height: VidhivatSpacing.xxl),
          _FeaturedPuja(
            entry: data.featuredEntry,
            vidhi: data.featuredVidhi,
            onOpen: () => onOpen(data.featuredEntry),
          ),
          if (daily.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'दैनिक पूजा',
              supportingText: 'रोज़मर्रा की सरल विधियाँ',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _PujaGrid(entries: daily, onOpen: onOpen),
          ],
          if (festivals.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'त्योहार',
              supportingText: 'विशेष दिन की पूजा-विधियाँ',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _ParvCard(
              parv: data.navratri,
              onOpen: () => onParvOpen(data.navratri),
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            _PujaGrid(entries: festivals, onOpen: onOpen),
          ],
          if (special.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'विशेष पूजा और संस्कार',
              supportingText: 'परिवार और विशेष अवसरों के लिए',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _PujaGrid(entries: special, onOpen: onOpen),
          ],
          for (final section in plannedPujaSections) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            VidhivatSectionHeader(
              title: section.title,
              supportingText: section.supportingText,
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _PlannedPujaGrid(entries: section.entries),
          ],
          const SizedBox(height: VidhivatSpacing.xxl),
          // ── यहाँ पहले हमारी अपनी प्रगति छपती थी — अब नहीं ─────────
          //
          // वाक्य था: "अभी 0 / 28 पंडित जी से जाँची गई हैं।" वो हमारे
          // अंदर के काम का हिसाब है, यूज़र के काम की बात नहीं — और वो
          // पढ़कर आदमी बाक़ी सब पर भी शक करने लगता है। ऐप जो जानता है
          // वो हर पूजा के अपने पन्ने पर लिखा है (स्रोत, पद्धति, क्षेत्र)।
          //
          // यहाँ अब सिर्फ़ वही बचा है जो यूज़र को सचमुच जानना है —
          // कितनी खुली हैं और कितनी आ रही हैं (→ D-041, D-042)।
          // गिनती "28 खुली हैं" भी जा चुकी — वो सूची सामने है,
          // गिनने की ज़रूरत नहीं। बचा सिर्फ़ वो, जो धुँधले कार्डों का
          // मतलब बताता है (→ D-056)।
          Text(
            '$plannedPujaCount पूजाएँ अभी तैयार हो रही हैं — उन पर “जल्द आएगी” लिखा है।',
            style: VidhivatTheme.typographyOf(context).caption,
          ),
        ],
      ),
    );
  }
}

class _ParvCard extends StatelessWidget {
  final Parv parv;
  final VoidCallback onOpen;

  const _ParvCard({required this.parv, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      key: const Key('navratri_parv_card'),
      variant: VidhivatCardVariant.highlight,
      onTap: onOpen,
      semanticLabel: '${parv.naam} पर्व खोलें। ${parv.ekLine}',
      child: Row(
        children: [
          const VidhivatStatusChip(
            label: 'पर्व',
            tone: VidhivatStatusTone.primary,
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parv.naam, style: type.cardTitle),
                const SizedBox(height: VidhivatSpacing.xxs),
                Text(parv.ekLine, style: type.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: VidhivatSpacing.xs),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}

class _FeaturedPuja extends StatelessWidget {
  final VidhiSuchiEntry entry;
  final Vidhi vidhi;
  final VoidCallback onOpen;

  const _FeaturedPuja({
    required this.entry,
    required this.vidhi,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return VidhivatSacredHero(
      eyebrow: 'आज की सरल शुरुआत',
      title: entry.naam,
      subtitle: entry.ekLine,
      icon: Icons.local_fire_department_outlined,
      artworkAsset: DevotionalAssets.forVidhiId(entry.id).assetPath,
      artworkSemanticLabel: DevotionalAssets.forVidhiId(entry.id).semanticLabel,
      artworkScale: entry.id == 'nitya_pooja' ? 1.25 : 1,
      semanticLabel: '${entry.naam} की featured विधि',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: VidhivatSpacing.xs,
            runSpacing: VidhivatSpacing.xs,
            children: [
              VidhivatStatusChip(
                label: vidhi.samayLikha,
                icon: Icons.schedule_outlined,
              ),
              VidhivatStatusChip(
                label: '${vidhi.charan.length} चरण',
                icon: Icons.format_list_numbered,
              ),
              VidhivatStatusChip(label: entry.shreni.naam),
              // "जाँच बाकी" वाला नारंगी chip यहाँ से हटा दिया गया —
              // वो ठीक "विधि देखें" बटन के ऊपर बैठकर हर पूजा को
              // संदिग्ध बना रहा था, और उससे यूज़र कुछ कर भी नहीं सकता था।
            ],
          ),
          const SizedBox(height: VidhivatSpacing.lg),
          VidhivatButton(
            label: 'विधि देखें',
            semanticLabel: '${entry.naam} की विधि देखें',
            onPressed: onOpen,
            icon: Icons.arrow_forward,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// All discovery sections use the same two-column image-led card grid. The
/// artwork is deliberately centered and larger than the label, so the card is
/// recognisable from a distance without putting copy over the illustration.
class _PujaGrid extends StatelessWidget {
  final List<VidhiSuchiEntry> entries;
  final ValueChanged<VidhiSuchiEntry> onOpen;

  const _PujaGrid({required this.entries, required this.onOpen});

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
                  child: _PujaGridCard(
                    entry: entry,
                    onOpen: () => onOpen(entry),
                  ),
                ),
            ],
          );
        },
      );
}

class _PujaGridCard extends StatelessWidget {
  final VidhiSuchiEntry entry;
  final VoidCallback onOpen;

  const _PujaGridCard({required this.entry, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final available = entry.taiyar;
    final artwork = DevotionalAssets.forVidhiId(entry.id);
    // A two-column card can become narrow at 320 dp. Reserve more vertical
    // room when the household has increased the system font size rather than
    // letting Hindi copy collide with the illustration.
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 198 + ((textScale - 1).clamp(0.0, 1.0) * 96);
    return VidhivatSurfaceCard(
      onTap: available ? onOpen : null,
      variant: VidhivatCardVariant.elevated,
      semanticLabel:
          available ? '${entry.naam} की विधि देखें' : '${entry.naam} जल्द आएगी',
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      child: SizedBox(
        height: cardHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artworkSize =
                (constraints.maxWidth * 0.93).clamp(84.0, 134.0).toDouble();
            final cacheSize =
                (artworkSize * MediaQuery.devicePixelRatioOf(context)).round();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: ExcludeSemantics(
                      child: Container(
                        width: artworkSize,
                        height: artworkSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.25),
                              blurRadius: artworkSize * 0.38,
                              spreadRadius: artworkSize * 0.02,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          artwork.assetPath,
                          fit: BoxFit.contain,
                          // ⚠ **`cacheWidth` और `cacheHeight` दोनों मत देना।**
                          //
                          // दोनों देने पर Flutter बिंब को ठीक उसी नाप पर **खींच** देता
                          // है — अनुपात नहीं बचाता (`ImageDescriptor.instantiateCodec`)। और
                          // `BoxFit.contain` उसे सुधार नहीं सकता, क्योंकि जो bitmap उसे मिलता
                          // है वो पहले से खिंचा हुआ होता है।
                          //
                          // यहाँ डिब्बा वर्गाकार है, इसलिए खिंचाव कम था (720×900 वाले
                          // चित्रों पर 1.25×) — पर था ज़रूर। → D-057
                          cacheHeight: cacheSize,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.auto_awesome_outlined,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  entry.naam,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: type.cardTitle.copyWith(
                    color: available ? colors.textPrimary : colors.textTertiary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlannedPujaGrid extends StatelessWidget {
  final List<PlannedPujaEntry> entries;

  const _PlannedPujaGrid({required this.entries});

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
                  child: _PlannedPujaCard(entry: entry),
                ),
            ],
          );
        },
      );
}

/// A planned card is intentionally not tappable. The name and realistic
/// artwork make the future library visible, while the persistent badge avoids
/// implying that ritual text already exists or has been verified.
class _PlannedPujaCard extends StatelessWidget {
  final PlannedPujaEntry entry;

  const _PlannedPujaCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = 198 + ((textScale - 1).clamp(0.0, 1.0) * 96);

    return Semantics(
      label: '${entry.name}, जल्द आएगी',
      child: VidhivatSurfaceCard(
        variant: VidhivatCardVariant.elevated,
        padding: const EdgeInsets.all(VidhivatSpacing.md),
        child: SizedBox(
          height: cardHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artworkSize =
                  (constraints.maxWidth * 0.9).clamp(82.0, 130.0).toDouble();
              final cacheSize =
                  (artworkSize * MediaQuery.devicePixelRatioOf(context))
                      .round();
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Center(
                          child: ExcludeSemantics(
                            child: Container(
                              width: artworkSize,
                              height: artworkSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        colors.primary.withValues(alpha: 0.2),
                                    blurRadius: artworkSize * 0.34,
                                    spreadRadius: artworkSize * 0.01,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                entry.artwork.assetPath,
                                fit: BoxFit.contain,
                                // ⚠ **`cacheWidth` और `cacheHeight` दोनों मत देना।**
                                //
                                // दोनों देने पर Flutter बिंब को ठीक उसी नाप पर **खींच** देता
                                // है — अनुपात नहीं बचाता (`ImageDescriptor.instantiateCodec`)। और
                                // `BoxFit.contain` उसे सुधार नहीं सकता, क्योंकि जो bitmap उसे मिलता
                                // है वो पहले से खिंचा हुआ होता है।
                                //
                                // यहाँ डिब्बा वर्गाकार है, इसलिए खिंचाव कम था (720×900 वाले
                                // चित्रों पर 1.25×) — पर था ज़रूर। → D-057
                                cacheHeight: cacheSize,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.auto_awesome_outlined,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        entry.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: type.cardTitle.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated.withValues(alpha: 0.94),
                          borderRadius: VidhivatRadius.pill,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.38),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: VidhivatSpacing.sm,
                            vertical: VidhivatSpacing.xxs,
                          ),
                          child: Text(
                            'जल्द आएगी',
                            style: type.caption.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VidhiHomeData {
  final List<VidhiSuchiEntry> entries;
  final VidhiSuchiEntry featuredEntry;
  final Vidhi featuredVidhi;
  final Parv navratri;

  const _VidhiHomeData({
    required this.entries,
    required this.featuredEntry,
    required this.featuredVidhi,
    required this.navratri,
  });
}
