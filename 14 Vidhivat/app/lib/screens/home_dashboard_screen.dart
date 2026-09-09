import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/aane_wale_din.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/paath.dart';
import '../vidhi/vidhi.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'muhurta_screen.dart';
import 'paath_list_screen.dart';
import 'paath_screen.dart';
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

    // ── चालीसा और आरती — होम पर अपना हिस्सा ────────────────────
    //
    // ये पूजा नहीं हैं (→ D-039), इसलिए पूजा की सूची में नहीं घुसाए
    // जाते। पर घर में सबसे ज़्यादा यही पढ़े जाते हैं, इसलिए होम पर
    // अपनी जगह के हक़दार हैं (→ D-051)।
    final sabPaath = await paathBhandar.suchi();
    final paathReady = sabPaath.where((e) => e.taiyar).toList(growable: false);

    return _DashboardData(
      featuredEntry: featuredEntry,
      featuredVidhi: featuredVidhi,
      popular: popular,
      paath: paathReady.take(4).toList(growable: false),
      patte: _banaoPatte(
        resumeEntry: resumeEntry,
        resumeVidhi: resumeVidhi,
        aage: aage,
        vidhiById: {for (final vidhi in sabhiVidhi) vidhi.id: vidhi},
        nityaEntry: featuredEntry,
        nityaVidhi: featuredVidhi,
      ),
    );
  }

  /// carousel के पत्ते, बाएँ से दाएँ (→ D-046)।
  ///
  /// क्रम में एक ही बात है — **आज पहले, फिर आगे का।**
  ///
  /// 1. अधूरी छूटी पूजा, अगर आज की ही है (`settings` वो ख़ुद जाँचता है)
  /// 2. आज पड़ने वाली पूजा या त्योहार
  /// 3. आज कुछ न हो तो **नित्य पूजा** — ताकि पहला पत्ता कभी ख़ाली न रहे
  /// 4. आगे के दिन — कल, परसों, बारह दिन बाद…
  ///
  /// जिस त्योहार की विधि अभी नहीं बनी, उसका पत्ता **बनता तो है पर खुलता
  /// नहीं** — तारीख़ बता देना अपने आप में काम की चीज़ है (→ D-038)।
  List<_Patta> _banaoPatte({
    required VidhiSuchiEntry? resumeEntry,
    required Vidhi? resumeVidhi,
    required List<PujaAvsar> aage,
    required Map<String, Vidhi> vidhiById,
    required VidhiSuchiEntry nityaEntry,
    required Vidhi nityaVidhi,
  }) {
    final patte = <_Patta>[];
    final liyeGaye = <String>{};

    if (resumeEntry != null && resumeVidhi != null) {
      final progress =
          settings.playerProgressFor(resumeEntry.id, resumeVidhi.charan.length);
      if (progress != null) {
        patte.add(_Patta(
          upar: 'जहाँ छोड़ा था',
          naam: resumeEntry.naam,
          neeche: resumeEntry.ekLine,
          artwork: DevotionalAssets.forVidhiId(resumeEntry.id).assetPath,
          pujaId: resumeEntry.id,
          // यहाँ समय नहीं, **कहाँ तक पहुँचे** — वही काम की बात है।
          samayAurCharan: 'चरण ${progress.lastReachedStepIndex + 1}'
              ' / ${resumeVidhi.charan.length}',
          samayChihn: Icons.play_circle_outline,
          bulawa: 'पूजा जारी रखें',
          canRemoveProgress: true,
        ));
        liyeGaye.add(resumeEntry.id);
      }
    }

    for (final avsar in aage) {
      if (avsar.pujaId.isNotEmpty && !liyeGaye.add(avsar.pujaId)) continue;
      final vidhi = vidhiById[avsar.pujaId];
      patte.add(_Patta(
        upar: avsar.kabLikha,
        naam: avsar.naam,
        neeche: avsar.kyon,
        artwork: DevotionalAssets.forVidhiId(avsar.pujaId).assetPath,
        pujaId: avsar.khulSaktiHai ? avsar.pujaId : null,
        samayAurCharan: vidhi == null
            ? null
            : '${vidhi.samayLikha}  •  ${vidhi.charan.length} चरण',
        bulawa: avsar.khulSaktiHai ? 'विधि देखें' : 'विधि अभी नहीं',
      ));
    }

    // आज के लिए कुछ नहीं बना — तब नित्य पूजा सबसे आगे। ऐसा दिन आम है,
    // और उस दिन भी पहला पत्ता कुछ *करने लायक* होना चाहिए।
    final aajKaKuchHai = patte.isNotEmpty &&
        (patte.first.upar == 'जहाँ छोड़ा था' || patte.first.upar == 'आज');
    if (!aajKaKuchHai && !liyeGaye.contains(nityaEntry.id)) {
      patte.insert(
        0,
        _Patta(
          upar: 'आज की सरल शुरुआत',
          naam: nityaEntry.naam,
          neeche: nityaEntry.ekLine,
          artwork: DevotionalAssets.forVidhiId(nityaEntry.id).assetPath,
          pujaId: nityaEntry.id,
          samayAurCharan: '${nityaVidhi.samayLikha}  •  '
              '${nityaVidhi.charan.length} चरण',
          bulawa: 'पूजा शुरू करें',
        ),
      );
    }

    return patte;
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openPuja(String id) => _push(VidhiScreen(id: id));

  Future<void> _removeProgress(String pujaId) async {
    await settings.clearPlayerProgress(pujaId);
    if (!mounted) return;
    setState(_refreshData);
  }

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
                    // ── सबसे ऊपर, स्वाइप होने वाला (→ D-046) ────────
                    //
                    // पहले यहाँ एक जमा हुआ कार्ड था और नीचे अलग से
                    // "आगे क्या आ रहा है" की सूची — वही पाँच पूजाएँ,
                    // दो बार। अब एक ही पट्टी: आज पहला, फिर आगे के दिन।
                    _PujaCarousel(
                      patte: data.patte,
                      onOpen: _openPuja,
                      onRemoveProgress: _removeProgress,
                    ),
                    const SizedBox(height: VidhivatSpacing.lg),
                    const _PanchangPanel(),
                    const SizedBox(height: VidhivatSpacing.xl),
                    // "जल्दी करें" लिखा था — हिंदी में उसका मतलब "hurry
                    // up" निकलता है, जो पूजा वाले ऐप में उल्टा ही है।
                    const VidhivatSectionHeader(
                      title: 'तुरंत खोलें',
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
                    const VidhivatSectionHeader(
                      title: 'लोकप्रिय पूजा',
                      // "सभी विधियाँ मौजूदा पूजा भंडार से" लिखा था —
                      // "भंडार" हमारा अंदरूनी शब्द है, यूज़र का नहीं।
                      supportingText: 'घरों में सबसे ज़्यादा की जाने वाली',
                    ),
                    const SizedBox(height: VidhivatSpacing.md),
                    _PopularPujaGrid(
                      entries: data.popular,
                      onOpen: _openPuja,
                    ),
                    // ── "सभी देखें" अब सूची के **नीचे** ─────────────
                    //
                    // पहले यह शीर्षक के बग़ल में एक फीका text-बटन था, और
                    // दो-पंक्ति वाले शीर्षक के सामने टेढ़ा भी बैठता था।
                    // वहाँ पढ़ने का क्रम टूटता है — आदमी शीर्षक पढ़कर
                    // नीचे चित्रों में उतर जाता है, दाईं तरफ़ देखता ही नहीं।
                    //
                    // चारों पूजाएँ देख चुकने के **बाद** ही यह सवाल उठता
                    // है कि "और क्या है?" — इसलिए बटन ठीक वहीं है, और
                    // अब पूरी चौड़ाई का है ताकि नज़र में आए।
                    const SizedBox(height: VidhivatSpacing.md),
                    VidhivatButton(
                      label: 'सभी पूजाएँ देखें',
                      semanticLabel: 'सभी पूजा-विधियों की सूची खोलें',
                      onPressed: widget.onOpenPujaLibrary,
                      icon: Icons.arrow_forward,
                      variant: VidhivatButtonVariant.secondary,
                      fullWidth: true,
                    ),
                    if (data.paath.isNotEmpty) ...[
                      const SizedBox(height: VidhivatSpacing.xxl),
                      const VidhivatSectionHeader(
                        title: 'चालीसा और आरती',
                        supportingText: 'बैठकर पढ़ने वाली स्तुतियाँ',
                      ),
                      const SizedBox(height: VidhivatSpacing.md),
                      _PaathSuchi(
                        entries: data.paath,
                        onOpen: (id) => _push(PaathScreen(id: id)),
                      ),
                      const SizedBox(height: VidhivatSpacing.md),
                      VidhivatButton(
                        label: 'सभी चालीसा और आरती',
                        semanticLabel: 'चालीसा और आरती की पूरी सूची खोलें',
                        onPressed: () => _push(const PaathListScreen()),
                        icon: Icons.arrow_forward,
                        variant: VidhivatButtonVariant.secondary,
                        fullWidth: true,
                      ),
                    ],
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

/// होम की सबसे ऊपर वाली **स्वाइप होने वाली पट्टी** (→ D-046)।
///
/// ## auto-swipe जान-बूझकर नहीं है
///
/// shopping ऐप में ऊपर वाला banner *विज्ञापन* होता है — अपने आप खिसक
/// जाए तो कुछ नहीं बिगड़ता। यहाँ यह पत्ता **ऐप का मुख्य बटन** है।
///
/// 1. **उँगली और पत्ते की टक्कर** — आदमी "पूजा जारी रखें" दबाने जा रहा
///    है, तभी पत्ता खिसक गया → वो ग़लत पूजा खोल बैठेगा
/// 2. **पढ़ने की रफ़्तार** — इस ऐप के बहुत से यूज़र उम्रदराज़ हैं;
///    "12 दिन बाद · शरद पूर्णिमा" पढ़ते-पढ़ते पत्ता चला जाना खीज देता है
/// 3. अपने आप चलती चीज़ Play के accessibility नियमों में भी खटकती है
///
/// **बदले में "यह स्वाइप होता है" दो तरह से दिखता है:** अगला पत्ता किनारे
/// से झाँकता रहता है (`viewportFraction`), और नीचे बिंदु हैं।
class _PujaCarousel extends StatefulWidget {
  final List<_Patta> patte;
  final void Function(String id) onOpen;
  final Future<void> Function(String id) onRemoveProgress;

  const _PujaCarousel({
    required this.patte,
    required this.onOpen,
    required this.onRemoveProgress,
  });

  @override
  State<_PujaCarousel> createState() => _PujaCarouselState();
}

class _PujaCarouselState extends State<_PujaCarousel> {
  /// 0.88 — यानी दाईं तरफ़ अगला पत्ता थोड़ा दिखता रहे। यही बताता है कि
  /// आगे और भी है; auto-swipe की ज़रूरत इसी से ख़त्म हो जाती है।
  static const _jhalak = 0.88;

  late final PageController _pages =
      PageController(viewportFraction: widget.patte.length > 1 ? _jhalak : 1);
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _jao(int naya) {
    if (naya < 0 || naya >= widget.patte.length) return;
    _pages.animateToPage(
      naya,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : VidhivatMotion.standard,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final patte = widget.patte;
    if (patte.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            key: const Key('puja_carousel'),
            controller: _pages,
            itemCount: patte.length,
            padEnds: false,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(
                right: patte.length > 1 ? VidhivatSpacing.sm : 0,
              ),
              child: _PujaPatta(
                patta: patte[i],
                onOpen: widget.onOpen,
                onRemoveProgress: widget.onRemoveProgress,
              ),
            ),
          ),
        ),
        if (patte.length > 1) ...[
          const SizedBox(height: VidhivatSpacing.sm),
          _Bindu(kul: patte.length, chuna: _index, onChuno: _jao),
        ],
      ],
    );
  }
}

/// नीचे के बिंदु। सजावट नहीं — इनसे पता चलता है कि कितने पत्ते हैं और
/// अभी कौन सा खुला है। दबाने पर उस पत्ते तक पहुँचा भी देते हैं।
class _Bindu extends StatelessWidget {
  final int kul;
  final int chuna;
  final ValueChanged<int> onChuno;

  const _Bindu({
    required this.kul,
    required this.chuna,
    required this.onChuno,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    return Semantics(
      label: '${chuna + 1} में से $kul',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < kul; i++)
            InkWell(
              onTap: () => onChuno(i),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(VidhivatSpacing.xs),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : VidhivatMotion.fast,
                  width: i == chuna ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == chuna ? colors.primary : colors.borderSubtle,
                    borderRadius: VidhivatRadius.pill,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// एक पत्ता — चित्र पीछे, बाईं तरफ़ पढ़ने की चीज़ें।
class _PujaPatta extends StatelessWidget {
  final _Patta patta;
  final void Function(String id) onOpen;

  final Future<void> Function(String id) onRemoveProgress;
  const _PujaPatta({
    required this.patta,
    required this.onOpen,
    required this.onRemoveProgress,
  });

  Future<void> _confirmRemoveProgress(BuildContext context) async {
    final pujaId = patta.pujaId;
    if (pujaId == null) return;
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('अधूरी पूजा हटाएँ?'),
        content: const Text(
          'यह सिर्फ़ “जहाँ छोड़ा था” वाली जगह हटाएगा। पूजा की विधि नहीं मिटेगी।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('नहीं'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('हटाएँ'),
          ),
        ],
      ),
    );
    if (shouldRemove == true && context.mounted) {
      await onRemoveProgress(pujaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final khulSaktaHai = patta.pujaId != null;

    return Semantics(
      container: true,
      button: khulSaktaHai,
      label: [
        patta.naam,
        patta.upar,
        patta.neeche,
        if (!khulSaktaHai) 'इसकी विधि अभी ऐप में नहीं है',
        if (patta.canRemoveProgress) 'अधूरी पूजा हटाने का विकल्प उपलब्ध है',
      ].join('। '),
      excludeSemantics: true,
      child: Container(
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
            // ── भगवान का चित्र ऊपर से कभी मत काटो ──────────────────
            //
            // पहले यहाँ `BoxFit.cover` था। पत्ता चौड़ा है और चित्र
            // चौकोर, इसलिए cover उसे **चौड़ाई** से नापता था और ऊपर-नीचे
            // से काट देता था — यानी सीधे भगवान के सिर और मुकुट पर कैंची।
            // किसी देवता की तस्वीर आधी दिखाना इस ऐप में नहीं चलेगा।
            //
            // `fitHeight` ऊँचाई से नापता है, इसलिए **कुछ नहीं कटता**।
            // चौकोर चित्र पत्ते से सँकरा रह जाता है और दाईं तरफ़ चिपक
            // जाता है; `translate` उसे थोड़ा और बाहर खिसकाता है ताकि
            // किनारे की ख़ाली जगह डिब्बे से बाहर चली जाए और डिब्बा उसे
            // साफ़ काट दे (`clipBehavior` ऊपर लगा है)।
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(16, 0),
                child: Image.asset(
                  patta.artwork,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerRight,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
            // ⚠️ चित्र के ऊपर लिखा है, इसलिए अक्षर बढ़ने पर यह डिब्बा
            // फैल नहीं सकता — बड़े font पर पाठ बाहर निकलने से रोकना पड़ता है।
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
                          patta.upar,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          patta.naam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.sectionTitle,
                        ),
                        const SizedBox(height: VidhivatSpacing.xxs),
                        Text(
                          patta.neeche,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.bodySmall
                              .copyWith(color: colors.textSecondary),
                        ),
                        const Spacer(),
                        if (patta.samayAurCharan != null)
                          Row(
                            children: [
                              Icon(patta.samayChihn,
                                  size: 14, color: colors.primary),
                              const SizedBox(width: VidhivatSpacing.xxs),
                              Flexible(
                                child: Text(
                                  patta.samayAurCharan!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: type.caption
                                      .copyWith(color: colors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: VidhivatSpacing.xs),
                        if (khulSaktaHai)
                          SizedBox(
                            width: 154,
                            child: VidhivatButton(
                              label: patta.bulawa,
                              semanticLabel: '${patta.naam} — ${patta.bulawa}',
                              onPressed: () => onOpen(patta.pujaId!),
                              compact: true,
                              fullWidth: true,
                            ),
                          )
                        else
                          // विधि बनी ही नहीं — तो बटन मत दिखाओ। तारीख़
                          // बता देना अपने आप में काम की चीज़ है (→ D-038)।
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: VidhivatSpacing.xs,
                            ),
                            child: Text(
                              patta.bulawa,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: type.caption
                                  .copyWith(color: colors.textTertiary),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (patta.canRemoveProgress)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip: 'अधूरी पूजा हटाएँ',
                  onPressed: () => _confirmRemoveProgress(context),
                  icon: Icon(
                    Icons.close,
                    color: colors.textPrimary,
                    size: VidhivatIconSize.small,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// carousel का एक पत्ता — सिर्फ़ दिखाने की चीज़ें, कोई गणना नहीं।
///
/// सब कुछ पहले से मौजूद डेटा से बनता है: तारीख़ें `aaneWaliPujaayein()`
/// से (जो पंचांग से निकलती हैं → D-038), समय और चरण पूजा की अपनी
/// JSON से, और अधूरी जगह `settings` से।
class _Patta {
  /// सबसे ऊपर की छोटी लाइन — "आज", "कल", "12 दिन बाद", "जहाँ छोड़ा था"।
  final String upar;

  final String naam;

  /// नाम के नीचे — एक लाइन का परिचय, या "पूर्णिमा", या "चरण 8 / 9"।
  final String neeche;

  final String artwork;

  /// `null` = यह पत्ता खुलता नहीं (विधि अभी बनी ही नहीं)।
  final String? pujaId;

  /// "22 मिनट • 9 चरण", या अधूरी पूजा पर "चरण 8 / 9"।
  /// विधि न हो तो `null`।
  final String? samayAurCharan;

  /// [samayAurCharan] के आगे का चिह्न। घड़ी तब जब वो सचमुच समय हो —
  /// चरणों की गिनती पर घड़ी लगाना ग़लत बात कहता है।
  final IconData samayChihn;

  /// बटन पर क्या लिखा हो; न खुलने वाले पत्ते पर यही सादा पाठ बन जाता है।
  final String bulawa;
  final bool canRemoveProgress;

  const _Patta({
    required this.upar,
    required this.naam,
    required this.neeche,
    required this.artwork,
    required this.pujaId,
    required this.samayAurCharan,
    required this.bulawa,
    this.canRemoveProgress = false,
    this.samayChihn = Icons.schedule_outlined,
  });
}

/// होम पर चालीसा और आरती — पंक्तियों में, चित्रों में नहीं।
///
/// पूजा के कार्ड चित्र-वाले हैं क्योंकि वहाँ देवता की पहचान काम आती है।
/// पाठ **पढ़ने की चीज़** है — यहाँ नाम और "कब पढ़ें" ज़्यादा काम के हैं,
/// इसलिए यह हिस्सा पंक्तियों में है (→ D-051)।
class _PaathSuchi extends StatelessWidget {
  final List<PaathSuchiEntry> entries;
  final void Function(String id) onOpen;

  const _PaathSuchi({required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);

    return VidhivatSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: colors.borderSubtle),
            Semantics(
              button: true,
              label: '${entries[i].naam}। ${entries[i].ekLine}',
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onOpen(entries[i].id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VidhivatSpacing.lg,
                    vertical: VidhivatSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: VidhivatIconSize.medium, color: colors.primary),
                      const SizedBox(width: VidhivatSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entries[i].naam, style: type.cardTitle),
                            const SizedBox(height: 2),
                            Text(
                              entries[i].ekLine,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: type.bodySmall
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.textTertiary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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

  /// होम पर दिखने वाली पहली चार चालीसा/आरती (→ D-051)।
  final List<PaathSuchiEntry> paath;

  /// सबसे ऊपर वाली पट्टी के पत्ते — आज पहला, फिर आगे के दिन (→ D-046)।
  final List<_Patta> patte;

  const _DashboardData({
    required this.featuredEntry,
    required this.featuredVidhi,
    required this.popular,
    required this.paath,
    required this.patte,
  });
}
