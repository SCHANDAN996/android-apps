import 'package:flutter/material.dart';
import 'package:panchang_engine/panchang_engine.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/aane_wale_din.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/paath.dart';
import '../vidhi/granth.dart';
import '../vidhi/paath_assets.dart';
import '../vidhi/parv.dart';
import '../vidhi/parv_aaj.dart';
import '../vidhi/parv_home.dart';
import '../vidhi/vidhi.dart';
import '../vidhi/vrat_artwork.dart';
import '../widgets/common.dart';
import '../widgets/reading_cards.dart';
import '../widgets/design_system.dart';
import 'muhurta_screen.dart';
import 'kundali_profiles_screen.dart';
import 'granth_screen.dart';
import 'granthalaya_screen.dart';
import 'paath_list_screen.dart';
import 'paath_screen.dart';
import 'parv_kholo.dart';
import 'sankalp_screen.dart';
import 'vidhi_screen.dart';
import 'vrat_panna_screen.dart';
import 'vrat_screen.dart';

/// The four-tab shell's starting point. It composes only real catalogue,
/// Panchang and locally saved progress data; it does not infer a ritual or
/// festival recommendation from the current date.
class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback onOpenPujaLibrary;

  /// "आज" — जाँच में कोई तारीख़ मानकर देखने के लिए। ऐप में `null` (अभी)।
  final DateTime? aaj;

  const HomeDashboardScreen({
    super.key,
    required this.onOpenPujaLibrary,
    this.aaj,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late Future<_DashboardData> _data;
  String? _resumeIdAtLoad;
  bool _vratSelected = false;

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
    final aaj = widget.aaj ?? DateTime.now();
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

    // गृह प्रवेश और वाहन पूजा की जगह नवरात्रि और पितृ पक्ष — डेवलपर का
    // फ़ैसला (22 सित 2026)। नवरात्रि का कार्ड कलश स्थापना की विधि नहीं,
    // पूरा पर्व-पन्ना खोलता है; पितृ पक्ष का कार्ड श्राद्ध की विधि।
    const preferredPopular = [
      'ganesh_poojan',
      'satyanarayan',
      'kalash_sthapana',
      'shraadh',
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
    final sabhiVidhi = await Future.wait(
      ready.map((entry) => vidhiBhandar.vidhi(entry.id)),
    );
    final aage = aaneWaliPujaayein(
      pujaayein: sabhiVidhi,
      place: settings.place,
      masaSystem: settings.masaSystem,
      aaj: aaj,
      kitne: 5,
      dinAage: 45,
    );

    // ── नवरात्रि का अपना पत्ता (→ D-074) ──────────────────────────
    //
    // ऊपर की पाँच जगहों की गिनती में **नहीं** — वरना हर हफ़्ते वाली
    // पूजाएँ इसे फिर बाहर धकेल देतीं, जो ठीक पहले की ग़लती थी।
    final navratri = await parvBhandar.parv('navratri');
    final navratriAvsar = navratriHomeAvsar(
      parv: navratri,
      aaj: navratriAaj(aaj: aaj, place: settings.place),
      aajKiTarikh: aaj,
    );
    // ── चालीसा और आरती — होम पर अपना हिस्सा ────────────────────
    //
    // ये पूजा नहीं हैं (→ D-039), इसलिए पूजा की सूची में नहीं घुसाए
    // जाते। पर घर में सबसे ज़्यादा यही पढ़े जाते हैं, इसलिए होम पर
    // अपनी जगह के हक़दार हैं (→ D-051)।
    final sabPaath = await paathBhandar.suchi();
    final paathReady = sabPaath.where((e) => e.taiyar).toList(growable: false);

    final granth = [
      ...await granthBhandar.suchi(),
      GranthSuchiEntry.saptashati
    ];
    final homeGranth = <GranthSuchiEntry>[
      for (final id in [
        'gita',
        'sundarkand',
        'vishnusahasranama',
        'saptashati'
      ])
        ...granth.where((g) => g.id == id),
    ];

    return _DashboardData(
      featuredEntry: featuredEntry,
      featuredVidhi: featuredVidhi,
      popular: popular,
      granth: homeGranth,
      paath: paathReady.take(4).toList(growable: false),
      navratri: navratri,
      vratPatte: aaneWaleVrat(
        place: settings.place,
        masaSystem: settings.masaSystem,
        aaj: aaj,
        dinAage: 60,
        kitne: 6,
      )
          .map((din) => _Patta(
                upar: '${din.kabLikha} · ${tarikhChhoti(din.tarikh)}',
                naam: din.niyam.naam,
                neeche: din.tithiNaam,
                artwork: VratArtwork.forVratId(din.niyam.id).assetPath,
                pujaId: null,
                vratId: din.niyam.id,
                samayAurCharan: null,
                bulawa: 'व्रत देखें',
              ))
          .toList(growable: false),
      patte: _banaoPatte(
        resumeEntry: resumeEntry,
        resumeVidhi: resumeVidhi,
        navratri: navratriAvsar,
        navratriParv: navratri,
        aage: aage,
        vidhiById: {for (final vidhi in sabhiVidhi) vidhi.id: vidhi},
        nityaEntry: featuredEntry,
        nityaVidhi: featuredVidhi,
      ),
    );
  }

  /// carousel के पत्ते, बाएँ से दाएँ (→ D-046)।
  ///
  /// पूजा विकल्प में अधूरी पूजा पहले, फिर आज और आने वाले अवसर।
  ///
  /// 1. अधूरी छूटी पूजा, अगर आज की ही है (`settings` वो ख़ुद जाँचता है)
  /// 2. आज पड़ने वाली पूजा या त्योहार — नवरात्रि चल रही हो तो उसका पत्ता
  ///    सबसे पहले (→ D-074)
  /// 3. कोई अवसर न मिले तो नित्य पूजा का उपयोगी विकल्प
  /// 4. आगे के दिन — कल, परसों, बारह दिन बाद…
  ///
  /// जिस त्योहार की विधि अभी नहीं बनी, उसका पत्ता **बनता तो है पर खुलता
  /// नहीं** — तारीख़ बता देना अपने आप में काम की चीज़ है (→ D-038)।
  List<_Patta> _banaoPatte({
    required VidhiSuchiEntry? resumeEntry,
    required Vidhi? resumeVidhi,
    required ParvHomeAvsar? navratri,
    required Parv navratriParv,
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

    // ── नवरात्रि (→ D-074) ─────────────────────────────────────────
    //
    // पर्व चल रहा हो तो "आज" वाली जगह — अधूरी पूजा के ठीक बाद, उस दिन की
    // बाक़ी पूजाओं से पहले। पहले से हो तो तारीख़ के क्रम से, नीचे के लूप में।
    _Patta? navratriPatta;
    final navratriKaId = navratri?.vidhiId;
    if (navratri != null &&
        (navratriKaId == null || !liyeGaye.contains(navratriKaId))) {
      navratriPatta = _Patta(
        upar: navratri.upar,
        naam: navratri.naam,
        neeche: navratri.neeche,
        artwork: navratri.artworkAsset,
        pujaId: navratriKaId,
        // Dashboard पर “माँ स्कंदमाता” जैसे पत्ते को दबाने पर भी पूरा
        // शारदीय नवरात्रि पन्ना खुलना चाहिए। आज की विधि इसी पन्ने के
        // “आज की पूजा” रास्ते में है; सीधे विधि खोलने पर मुख्य section
        // छूट रहा था (डेवलपर ने फ़ोन पर पकड़ा, 22 सित 2026)।
        parvId: 'navratri',
        samayAurCharan: null,
        bulawa: navratriKaId == null ? navratri.bulawa : 'नवरात्रि देखें',
      );
      if (navratriKaId != null) liyeGaye.add(navratriKaId);
      if (navratri.aajKa) {
        patte.add(navratriPatta);
        navratriPatta = null;
      }
    }

    for (final avsar in aage) {
      if (avsar.vratKhulega) continue;
      // पुराना "शारदीय नवरात्रि — घटस्थापना" पत्ता — अब नवरात्रि का अपना
      // पत्ता है, एक ही चीज़ के दो पत्ते नहीं।
      if (navratri != null && avsar.naam.startsWith('शारदीय नवरात्रि')) {
        continue;
      }
      // नवरात्रि पंद्रह दिन से दूर हो तो ऊपर वाला पत्ता नहीं बनता, और यही
      // घटस्थापना वाला पत्ता आता है। पहले यह सीधे कलश स्थापना की विधि
      // खोलता था, जबकि पूजा section का नवरात्रि कार्ड पूरा पर्व-पन्ना —
      // अब दोनों एक जगह ले जाते हैं (डेवलपर ने फ़ोन पर पकड़ा, 22 सित 2026)।
      if (avsar.naam.startsWith('शारदीय नवरात्रि')) {
        patte.add(_Patta(
          upar: avsar.kabLikha,
          naam: navratriParv.naam,
          neeche: 'घटस्थापना · ${tarikhChhoti(avsar.tarikh)}',
          artwork: navratriParv.artworkAsset,
          pujaId: null,
          parvId: 'navratri',
          samayAurCharan: null,
          bulawa: 'पर्व देखें',
        ));
        if (avsar.pujaId.isNotEmpty) liyeGaye.add(avsar.pujaId);
        continue;
      }
      if (navratriPatta != null &&
          avsar.kitneDinBaad > navratri!.kitneDinBaad) {
        patte.add(navratriPatta);
        navratriPatta = null;
      }
      if (avsar.pujaId.isNotEmpty && !liyeGaye.add(avsar.pujaId)) continue;
      final vidhi = vidhiById[avsar.pujaId];
      patte.add(_Patta(
        upar: avsar.kabLikha,
        naam: avsar.naam,
        neeche: '${tarikhChhoti(avsar.tarikh)} · ${avsar.kyon}',
        artwork: avsar.vratKhulega
            ? VratArtwork.forVratId(avsar.vratId).assetPath
            : avsar.pujaId.isEmpty
                ? 'assets/images/devotional/home_puja_arrangement_v1.png'
                : DevotionalAssets.forVidhiId(avsar.pujaId).assetPath,
        pujaId: avsar.khulSaktiHai ? avsar.pujaId : null,
        vratId: avsar.vratKhulega ? avsar.vratId : null,
        samayAurCharan: vidhi == null
            ? null
            : '${vidhi.samayLikha}  •  ${vidhi.charan.length} चरण',
        bulawa: avsar.khulSaktiHai
            ? 'विधि देखें'
            : avsar.vratKhulega
                ? 'व्रत देखें'
                : 'विधि अभी नहीं',
      ));
    }
    if (navratriPatta != null) patte.add(navratriPatta);

    // कोई अवसर न मिले तो दैनिक पूजा का विकल्प दें।
    if (patte.isEmpty && !liyeGaye.contains(nityaEntry.id)) {
      patte.insert(
        0,
        _Patta(
          upar: 'आज की सरल शुरुआत',
          naam: nityaEntry.naam,
          neeche: nityaEntry.ekLine,
          artwork: 'assets/images/devotional/home_puja_arrangement_v1.png',
          pujaId: nityaEntry.id,
          samayAurCharan: '${nityaVidhi.samayLikha}  •  '
              '${nityaVidhi.charan.length} चरण',
          bulawa: 'पूजा शुरू करें',
        ),
      );
    }

    return patte;
  }

  Future<void> _push(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (!mounted) return;
    // Player में हर चरण पर global settings notification नहीं भेजते।
    // Home का resume-card केवल लौटने पर नई saved position पढ़ता है।
    if (screen is VidhiScreen) setState(_refreshData);
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
                      vratSelected: _vratSelected,
                      onSelect: (vrat) => setState(() => _vratSelected = vrat),
                    ),
                    const SizedBox(height: VidhivatSpacing.lg),
                    if (_vratSelected && data.vratPatte.isEmpty)
                      const VidhivatStateView(
                        title: 'अगले दो महीनों में कोई व्रत नहीं मिला',
                        icon: Icons.event_busy_outlined,
                      )
                    else
                      _PujaCarousel(
                        key: ValueKey(_vratSelected),
                        patte: _vratSelected ? data.vratPatte : data.patte,
                        onOpen: _openPuja,
                        onParvOpen: (_) =>
                            kholoNavratri(context, data.navratri),
                        onRemoveProgress: _removeProgress,
                      ),
                    if (_vratSelected &&
                        data.patte.any((p) => p.canRemoveProgress)) ...[
                      const SizedBox(height: VidhivatSpacing.md),
                      SizedBox(
                        height: 210,
                        child: _PujaPatta(
                          patta:
                              data.patte.firstWhere((p) => p.canRemoveProgress),
                          onOpen: _openPuja,
                          onParvOpen: (_) =>
                              kholoNavratri(context, data.navratri),
                          onRemoveProgress: _removeProgress,
                        ),
                      ),
                    ],
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
                      navratriArtwork: data.navratri.artworkAsset,
                      onOpen: (id) => id == 'kalash_sthapana'
                          ? kholoNavratri(context, data.navratri)
                          : _openPuja(id),
                    ),
                    const SizedBox(height: VidhivatSpacing.md),
                    VidhivatButton(
                      label: 'सभी पूजाएँ देखें',
                      semanticLabel: 'सभी पूजा-विधियों की सूची खोलें',
                      onPressed: widget.onOpenPujaLibrary,
                      icon: Icons.arrow_forward,
                      variant: VidhivatButtonVariant.secondary,
                      fullWidth: true,
                    ),
                    const SizedBox(height: VidhivatSpacing.xxl),
                    const VidhivatSectionHeader(
                      title: 'तुरंत खोलें',
                    ),
                    const SizedBox(height: VidhivatSpacing.md),
                    _QuickActionGrid(
                      onKundali: () => _push(const KundaliProfilesScreen()),
                      onVrat: () => _push(const VratScreen()),
                      onSankalp: () => _push(const SankalpScreen()),
                      onMuhurta: () => _push(const MuhurtaScreen()),
                    ),
                    const SizedBox(height: VidhivatSpacing.xxl),
                    const _PanchangPanel(),
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
                    if (data.granth.isNotEmpty) ...[
                      const SizedBox(height: VidhivatSpacing.xxl),
                      const VidhivatSectionHeader(
                        title: 'ग्रंथालय',
                        supportingText: 'अध्याय और पाठ, अर्थ सहित',
                      ),
                      const SizedBox(height: VidhivatSpacing.md),
                      _ReadingGrid(
                        gridKey: const Key('home_granth_grid'),
                        entries: [
                          for (final g in data.granth)
                            (
                              id: g.id,
                              naam: g.naam,
                              artwork: PaathAssets.forGranthId(g.id).assetPath,
                            )
                        ],
                        onOpen: (id) => _push(GranthScreen(
                            granth: data.granth.firstWhere((g) => g.id == id))),
                      ),
                      const SizedBox(height: VidhivatSpacing.md),
                      VidhivatButton(
                        label: 'पूरा ग्रंथालय देखें',
                        onPressed: () => _push(const GranthalayaScreen()),
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
  final bool vratSelected;
  final ValueChanged<bool> onSelect;

  const _HomeHeader({required this.vratSelected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final vrat in [false, true]) ...[
          if (vrat) const SizedBox(width: VidhivatSpacing.sm),
          Expanded(
            child: Semantics(
              selected: vratSelected == vrat,
              button: true,
              child: Material(
                color: vratSelected == vrat
                    ? colors.primary
                    : colors.backgroundElevated,
                borderRadius: VidhivatRadius.medium,
                child: InkWell(
                  borderRadius: VidhivatRadius.medium,
                  onTap: () => onSelect(vrat),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              vrat
                                  ? Icons.calendar_month_outlined
                                  : Icons.local_florist_outlined,
                              size: 18,
                              color: vratSelected == vrat
                                  ? colors.background
                                  : colors.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                                vrat ? 'आने वाले व्रत' : 'आने वाली पूजा',
                                textAlign: TextAlign.center,
                                style: type.label.copyWith(
                                    color: vratSelected == vrat
                                        ? colors.background
                                        : colors.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
  final void Function(String parvId) onParvOpen;
  final Future<void> Function(String id) onRemoveProgress;

  const _PujaCarousel({
    super.key,
    required this.patte,
    required this.onOpen,
    required this.onParvOpen,
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
                onParvOpen: widget.onParvOpen,
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
  final void Function(String parvId) onParvOpen;

  final Future<void> Function(String id) onRemoveProgress;
  const _PujaPatta({
    required this.patta,
    required this.onOpen,
    required this.onParvOpen,
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
    final khulSaktaHai =
        patta.pujaId != null || patta.parvId != null || patta.vratId != null;

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
                  cacheHeight:
                      (210 * MediaQuery.devicePixelRatioOf(context)).round(),
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
                          textAlign: TextAlign.justify,
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
                              onPressed: () => patta.parvId != null
                                  ? onParvOpen(patta.parvId!)
                                  : patta.vratId != null
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => VratPannaScreen(
                                                id: patta.vratId!),
                                          ),
                                        )
                                      : onOpen(patta.pujaId!),
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

  /// `null` = यह पत्ता कोई विधि नहीं खोलता।
  final String? pujaId;

  /// कोई विधि नहीं, पूरा पर्व-पन्ना खुले (→ D-074)। [pujaId] और यह
  /// दोनों `null` हों तो पत्ता खुलता ही नहीं (विधि अभी बनी नहीं)।
  final String? parvId;

  /// कोई विधि नहीं, व्रत-पन्ना खुले — शरद पूर्णिमा (→ D-130)।
  final String? vratId;

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
    this.parvId,
    this.vratId,
    this.canRemoveProgress = false,
    this.samayChihn = Icons.schedule_outlined,
  });
}

/// चित्र और पूरे नाम के साथ दो स्तंभ; अक्षर बढ़ें तो कार्ड ऊँचा हो सके।
class _PaathSuchi extends StatelessWidget {
  final List<PaathSuchiEntry> entries;
  final void Function(String id) onOpen;

  const _PaathSuchi({required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) => _ReadingGrid(
        gridKey: const Key('home_paath_grid'),
        entries: [
          for (final e in entries)
            (
              id: e.id,
              naam: e.naam,
              artwork: PaathAssets.forPaathId(e.id).assetPath,
            )
        ],
        onOpen: onOpen,
      );
}

class _ReadingGrid extends StatelessWidget {
  final Key gridKey;
  final List<({String id, String naam, String artwork})> entries;
  final ValueChanged<String> onOpen;
  const _ReadingGrid(
      {required this.gridKey, required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) => ReadingCardGrid(
        gridKey: gridKey,
        children: [
          for (final entry in entries)
            ReadingArtworkCard(
              name: entry.naam,
              artwork: entry.artwork,
              onTap: () => onOpen(entry.id),
            )
        ],
      );
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
  final VoidCallback onKundali;
  final VoidCallback onVrat;
  final VoidCallback onSankalp;
  final VoidCallback onMuhurta;

  const _QuickActionGrid({
    required this.onKundali,
    required this.onVrat,
    required this.onSankalp,
    required this.onMuhurta,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <({String label, IconData icon, VoidCallback tap})>[
      (label: 'व्रत', icon: Icons.spa_outlined, tap: onVrat),
      (label: 'संकल्प', icon: Icons.water_drop_outlined, tap: onSankalp),
      (label: 'चौघड़िया', icon: Icons.calendar_month_outlined, tap: onMuhurta),
      (label: 'जन्म कुंडली', icon: Icons.auto_awesome_outlined, tap: onKundali),
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

  /// नवरात्रि वाले कार्ड का चित्र — पर्व का, कलश स्थापना का नहीं।
  final String navratriArtwork;

  const _PopularPujaGrid({
    required this.entries,
    required this.onOpen,
    required this.navratriArtwork,
  });

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
                    navratriArtwork: navratriArtwork,
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
  final String navratriArtwork;

  const _PopularPujaCard({
    required this.entry,
    required this.onTap,
    required this.navratriArtwork,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final navratri = entry.id == 'kalash_sthapana';
    final artworkPath = navratri
        ? navratriArtwork
        : DevotionalAssets.forVidhiId(entry.id).assetPath;
    final displayName = switch (entry.id) {
      'satyanarayan' => 'सत्यनारायण पूजा',
      'kalash_sthapana' => 'शारदीय नवरात्रि',
      'shraadh' => 'पितृ पक्ष — श्राद्ध',
      _ => entry.naam,
    };
    return VidhivatSurfaceCard(
      onTap: onTap,
      variant: VidhivatCardVariant.elevated,
      semanticLabel: navratri
          ? 'शारदीय नवरात्रि पर्व खोलें'
          : '$displayName की विधि देखें',
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
                    artworkPath,
                    fit: BoxFit.contain,
                    cacheHeight:
                        (76 * MediaQuery.devicePixelRatioOf(context)).round(),
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
  final List<GranthSuchiEntry> granth;

  /// होम पर दिखने वाली पहली चार चालीसा/आरती (→ D-051)।
  final List<PaathSuchiEntry> paath;

  /// सबसे ऊपर वाली पट्टी के पत्ते — आज पहला, फिर आगे के दिन (→ D-046)।
  final List<_Patta> patte;
  final List<_Patta> vratPatte;

  /// नवरात्रि का पर्व — पत्ता दबाने पर यही पन्ना खुलता है (→ D-074)।
  final Parv navratri;

  const _DashboardData({
    required this.featuredEntry,
    required this.featuredVidhi,
    required this.popular,
    required this.granth,
    required this.paath,
    required this.patte,
    required this.vratPatte,
    required this.navratri,
  });
}
