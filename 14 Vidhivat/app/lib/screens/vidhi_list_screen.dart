import 'package:flutter/material.dart';

import '../state/settings.dart';
import '../theme.dart';
import '../vidhi/aane_wale_din.dart';
import '../vidhi/bhandar.dart';
import '../vidhi/devotional_assets.dart';
import '../vidhi/parv.dart';
import '../vidhi/parv_aaj.dart';
import '../vidhi/parv_home.dart';
import '../vidhi/planned_puja_catalog.dart';
import '../vidhi/vidhi.dart';
import '../vidhi/vrat_artwork.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import 'vidhi_screen.dart';
import 'vrat_panna_screen.dart';
import 'parv_kholo.dart';

/// विधि का home — catalogue नहीं, पूजा चुनने की शुरुआती जगह।
///
/// सारी सामग्री assets से ही आती है। इस screen में कोई नई पूजा, समय या
/// धार्मिक दावा नहीं लिखा जाता; वह सिर्फ़ मौजूदा catalogue को पढ़ने में
/// आसान क्रम में रखती है।
///
/// ## ढाँचा (→ D-086)
///
/// 1. **आने वाली पूजाएँ** — बग़ल में खिसकने वाली पट्टी, पंचांग से
/// 2. **रोज़ की पूजा** — नित्य पूजा भी यहीं, बाक़ी जैसा एक कार्ड
/// 3. **त्योहार** — जो पहले आ रहा है वो पहले, कार्ड पर अगली तारीख़
/// 4. **व्रत**, फिर **संस्कार और पारिवारिक कर्म**
/// 5. जल्द आने वाली विधियाँ
///
/// पहले सबसे ऊपर नित्य पूजा का बड़ा कार्ड पूरी स्क्रीन घेर लेता था — फ़ोन
/// पर खोलते ही बाक़ी अट्ठाईस पूजाओं का पता ही नहीं चलता था।
class VidhiListScreen extends StatefulWidget {
  /// "आज" — सिर्फ़ जाँच के लिए; ऐप में हमेशा `DateTime.now()`।
  final DateTime? aaj;

  const VidhiListScreen({super.key, this.aaj});

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
    final aaj = widget.aaj ?? DateTime.now();
    final entries = await vidhiBhandar.suchi();
    final ready =
        entries.where((entry) => entry.taiyar).toList(growable: false);
    if (ready.isEmpty) {
      throw StateError('पूजा की कोई तैयार विधि नहीं मिली।');
    }

    final sabhiVidhi = await Future.wait(
      ready.map((entry) => vidhiBhandar.vidhi(entry.id)),
    );
    final navratri = await parvBhandar.parv('navratri');

    // ── आने वाली पूजाएँ — होम वाली ही गिनती (→ D-038, D-086) ──────
    //
    // वही `aaneWaliPujaayein` जो होम की पट्टी चलाता है, ताकि दोनों जगह
    // तारीख़ें कभी अलग न हों। हर हफ़्ते वाली पूजा (हनुमान = मंगल, शनि)
    // यहाँ सिर्फ़ **उसी दिन** आती है, वरना हर हफ़्ते दो जगह घेर लेती।
    final aage = aaneWaliPujaayein(
      pujaayein: sabhiVidhi,
      place: settings.place,
      masaSystem: settings.masaSystem,
      aaj: aaj,
      kitne: 12,
      dinAage: 45,
    );
    final navratriAvsar = navratriHomeAvsar(
      parv: navratri,
      aaj: navratriAaj(aaj: aaj, place: settings.place),
      aajKiTarikh: aaj,
    );

    return _VidhiHomeData(
      entries: entries,
      navratri: navratri,
      aaneWali: _banaoAaneWali(aage, navratri, navratriAvsar),
      tyoharTarikh: agliTyoharTarikh(place: settings.place, aaj: aaj),
      aaj: DateTime(aaj.year, aaj.month, aaj.day),
    );
  }

  /// पट्टी के कार्ड, बाएँ से दाएँ — आज पहले, फिर तारीख़ के क्रम से।
  static List<_AaneWali> _banaoAaneWali(
    List<PujaAvsar> aage,
    Parv navratri,
    ParvHomeAvsar? navratriAvsar,
  ) {
    final sab = <_AaneWali>[];
    final liyeGaye = <String>{};

    _AaneWali? navratriKa;
    if (navratriAvsar != null) {
      navratriKa = _AaneWali(
        upar: navratriAvsar.upar,
        naam: navratriAvsar.naam,
        neeche: navratriAvsar.neeche,
        artwork: navratriAvsar.artworkAsset,
        // हर नवरात्रि पत्ता पूरा पर्व-पन्ना खोलता है — आज की विधि उसी पन्ने
        // पर है (होम जैसा, डेवलपर का फ़ैसला 22 सित 2026)।
        pujaId: null,
        parv: true,
        kitneDinBaad: navratriAvsar.kitneDinBaad,
      );
      final id = navratriAvsar.vidhiId;
      if (id != null) liyeGaye.add(id);
      if (navratriAvsar.aajKa) {
        sab.add(navratriKa);
        navratriKa = null;
      }
    }

    for (final avsar in aage) {
      if (avsar.karan == AvsarKaKaran.vaar && avsar.kitneDinBaad > 0) {
        continue;
      }
      if (navratriKa != null && avsar.kitneDinBaad > navratriKa.kitneDinBaad) {
        sab.add(navratriKa);
        navratriKa = null;
      }
      // घटस्थापना — नवरात्रि का अपना पत्ता हो तो वही; न हो (पंद्रह दिन से
      // ज़्यादा दूर) तो यही पत्ता पूरे पर्व का बनता है, कलश की विधि का नहीं।
      if (avsar.naam.startsWith('शारदीय नवरात्रि')) {
        if (navratriAvsar != null) continue;
        sab.add(_AaneWali(
          upar: avsar.kabLikha,
          naam: navratri.naam,
          neeche: 'घटस्थापना · ${tarikhChhoti(avsar.tarikh)}',
          artwork: navratri.artworkAsset,
          pujaId: null,
          parv: true,
          kitneDinBaad: avsar.kitneDinBaad,
        ));
        continue;
      }
      if (avsar.khulSaktiHai && !liyeGaye.add(avsar.pujaId)) continue;
      sab.add(_AaneWali(
        upar: avsar.kabLikha,
        naam: avsar.naam,
        neeche: avsar.kitneDinBaad == 0
            ? avsar.kyon
            : '${avsar.kyon} · ${tarikhChhoti(avsar.tarikh)}',
        artwork: avsar.vratKhulega
            ? VratArtwork.forVratId(avsar.vratId).assetPath
            : DevotionalAssets.forVidhiId(avsar.pujaId).assetPath,
        pujaId: avsar.khulSaktiHai ? avsar.pujaId : null,
        vratId: avsar.vratKhulega ? avsar.vratId : null,
        parv: false,
        kitneDinBaad: avsar.kitneDinBaad,
      ));
    }
    if (navratriKa != null) sab.add(navratriKa);

    return List.unmodifiable(sab.take(6));
  }

  void _open(VidhiSuchiEntry entry) {
    if (!entry.taiyar) return;
    _openId(entry.id);
  }

  void _openId(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VidhiScreen(id: id)),
    );
  }

  void _openNavratri(Parv parv) => kholoNavratri(context, parv);

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
              onOpenId: _openId,
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
  final ValueChanged<String> onOpenId;
  final ValueChanged<Parv> onParvOpen;

  const _VidhiHome({
    required this.data,
    required this.onOpen,
    required this.onOpenId,
    required this.onParvOpen,
  });

  @override
  Widget build(BuildContext context) {
    // नित्य पूजा बाक़ी पूजाओं जैसा ही एक कार्ड है — बस "रोज़ की पूजा" में
    // सबसे पहले, क्योंकि रोज़ सबसे ज़्यादा वही खुलती है।
    final daily = data.entries
        .where((entry) => entry.shreni == Shreni.nitya)
        .toList()
      ..sort((a, b) => (a.id == 'nitya_pooja' ? 0 : 1)
          .compareTo(b.id == 'nitya_pooja' ? 0 : 1));

    // त्योहार और व्रत — जिसकी अगली तारीख़ पहले, वो पहले। जिनकी तारीख़
    // इंजन के त्योहार-नियम से नहीं निकलती (हर महीने वाली) वे बाद में,
    // सूची के अपने क्रम में।
    List<VidhiSuchiEntry> tarikhSe(Shreni shreni) {
      final sab = data.entries.where((e) => e.shreni == shreni).toList();
      final dated = sab
          .where((e) => data.tyoharTarikh.containsKey(e.id))
          .toList()
        ..sort((a, b) =>
            data.tyoharTarikh[a.id]!.compareTo(data.tyoharTarikh[b.id]!));
      return [
        ...dated,
        ...sab.where((e) => !data.tyoharTarikh.containsKey(e.id)),
      ];
    }

    final orderedFestivals = tarikhSe(Shreni.tyohar);
    final festivals = orderedFestivals;
    final vrat = tarikhSe(Shreni.vrat);
    final parivar = data.entries
        .where((entry) =>
            entry.shreni != Shreni.nitya &&
            entry.shreni != Shreni.tyohar &&
            entry.shreni != Shreni.vrat)
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
            textAlign: TextAlign.justify,
            style: VidhivatTheme.typographyOf(context).bodyMedium,
          ),
          if (data.aaneWali.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xl),
            const VidhivatSectionHeader(
              title: 'आने वाली पूजाएँ',
              supportingText: 'आपके शहर के पंचांग से',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _AaneWaliPatti(
              sab: data.aaneWali,
              onOpenId: onOpenId,
              onParvOpen: () => onParvOpen(data.navratri),
            ),
          ],
          if (daily.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'रोज़ की पूजा',
              supportingText: 'हर दिन की सरल विधियाँ',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _PujaGrid(entries: daily, onOpen: onOpen),
          ],
          if (festivals.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'त्योहार',
              supportingText: 'जो पहले आ रहा है, वो पहले',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _ParvCard(
              parv: data.navratri,
              onOpen: () => onParvOpen(data.navratri),
            ),
            const SizedBox(height: VidhivatSpacing.sm),
            _PujaGrid(
              entries: orderedFestivals,
              onOpen: onOpen,
              tarikh: data.tyoharTarikh,
              aaj: data.aaj,
            ),
          ],
          if (vrat.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'व्रत',
              supportingText: 'जो पहले आ रहा है, वो पहले',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            _PujaGrid(
              entries: vrat,
              onOpen: onOpen,
              tarikh: data.tyoharTarikh,
              aaj: data.aaj,
            ),
          ],
          if (parivar.isNotEmpty) ...[
            const SizedBox(height: VidhivatSpacing.xxl),
            const VidhivatSectionHeader(
              title: 'संस्कार और पारिवारिक कर्म',
              supportingText: 'घर, परिवार और पितरों के लिए',
            ),
            const SizedBox(height: VidhivatSpacing.md),
            // श्राद्ध पर पितृ पक्ष की तारीख़ — बाक़ी संस्कारों की कोई नहीं
            _PujaGrid(
              entries: parivar,
              onOpen: onOpen,
              tarikh: data.tyoharTarikh,
              aaj: data.aaj,
            ),
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
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return VidhivatSurfaceCard(
      key: const Key('navratri_parv_card'),
      variant: VidhivatCardVariant.elevated,
      onTap: onOpen,
      semanticLabel: '${parv.naam} पर्व खोलें। ${parv.ekLine}',
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageSize =
              (constraints.maxWidth * 0.31).clamp(92.0, 124.0).toDouble();
          final cacheSize =
              (imageSize * MediaQuery.devicePixelRatioOf(context)).round();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.25),
                        blurRadius: imageSize * 0.32,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    parv.artworkAsset,
                    fit: BoxFit.contain,
                    // अनुपात बचाने के लिए दोनों cache dimensions न दें।
                    cacheHeight: cacheSize,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.auto_awesome_outlined,
                      color: colors.primary,
                      size: imageSize * 0.55,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: VidhivatSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VidhivatStatusChip(
                      label: 'नौ दिन का पर्व',
                      tone: VidhivatStatusTone.primary,
                      icon: Icons.auto_awesome_outlined,
                    ),
                    const SizedBox(height: VidhivatSpacing.sm),
                    Text(parv.naam, style: type.cardTitle),
                    const SizedBox(height: VidhivatSpacing.xxs),
                    Text(parv.ekLine,
                        textAlign: TextAlign.justify, style: type.bodySmall),
                    const SizedBox(height: VidhivatSpacing.sm),
                    Text(
                      'संक्षिप्त पूजा और दिन-प्रतिदिन पूर्ण विधि',
                      style: type.caption.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: VidhivatSpacing.xs),
              Icon(Icons.arrow_forward_ios, color: colors.textSecondary),
            ],
          );
        },
      ),
    );
  }
}

/// पट्टी का एक कार्ड — किस दिन, कौन सी पूजा, और क्यों।
class _AaneWali {
  /// "आज" · "कल" · "3 दिन बाद"
  final String upar;
  final String naam;

  /// "पूर्णिमा · 26 सित" — आज वाले पर सिर्फ़ वजह।
  final String neeche;
  final String artwork;

  /// दबाने पर खुलने वाली विधि; `null` और [parv] भी नहीं = खुलता नहीं।
  final String? pujaId;

  /// दबाने पर नवरात्रि का पूरा पर्व-पन्ना खुले।
  final bool parv;

  /// विधि नहीं, व्रत-पन्ना खुले — शरद पूर्णिमा (→ D-130)।
  final String? vratId;
  final int kitneDinBaad;

  const _AaneWali({
    required this.upar,
    required this.naam,
    required this.neeche,
    required this.artwork,
    required this.pujaId,
    required this.parv,
    required this.kitneDinBaad,
    this.vratId,
  });

  bool get khulta => parv || pujaId != null || vratId != null;
}

/// आने वाली पूजाएँ — बग़ल में खिसकने वाली पट्टी (→ D-086)।
///
/// कार्ड की चौड़ाई जान-बूझकर ऐसी है कि तीसरा कार्ड आधा कटकर दिखे —
/// उससे बिना बताए समझ आता है कि पट्टी खिसकती है।
class _AaneWaliPatti extends StatelessWidget {
  final List<_AaneWali> sab;
  final ValueChanged<String> onOpenId;
  final VoidCallback onParvOpen;

  const _AaneWaliPatti({
    required this.sab,
    required this.onOpenId,
    required this.onParvOpen,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = ((constraints.maxWidth - VidhivatSpacing.sm * 2) / 2.4)
              .clamp(124.0, 172.0)
              .toDouble();
          return SingleChildScrollView(
            key: const Key('aane_wali_patti'),
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < sab.length; i++) ...[
                    if (i > 0) const SizedBox(width: VidhivatSpacing.sm),
                    SizedBox(
                      width: width,
                      child: _AaneWaliCard(
                        avsar: sab[i],
                        onOpen: sab[i].parv
                            ? onParvOpen
                            : sab[i].vratId != null
                                ? () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            VratPannaScreen(id: sab[i].vratId!),
                                      ),
                                    )
                                : sab[i].pujaId == null
                                    ? null
                                    : () => onOpenId(sab[i].pujaId!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
}

class _AaneWaliCard extends StatelessWidget {
  final _AaneWali avsar;
  final VoidCallback? onOpen;

  const _AaneWaliCard({required this.avsar, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    final aaj = avsar.kitneDinBaad == 0;
    const artworkSize = 76.0;
    final cacheSize =
        (artworkSize * MediaQuery.devicePixelRatioOf(context)).round();
    return VidhivatSurfaceCard(
      onTap: onOpen,
      variant: VidhivatCardVariant.elevated,
      semanticLabel: avsar.khulta
          ? '${avsar.upar}: ${avsar.naam}, ${avsar.neeche}। '
              '${avsar.vratId != null ? 'व्रत देखें' : 'विधि देखें'}'
          : '${avsar.upar}: ${avsar.naam}, ${avsar.neeche}। विधि अभी नहीं',
      padding: const EdgeInsets.all(VidhivatSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VidhivatStatusChip(
            label: avsar.upar,
            tone: aaj ? VidhivatStatusTone.primary : VidhivatStatusTone.neutral,
            icon: aaj ? Icons.today_outlined : Icons.event_outlined,
          ),
          const SizedBox(height: VidhivatSpacing.sm),
          Center(
            child: ExcludeSemantics(
              child: SizedBox(
                width: artworkSize,
                height: artworkSize,
                child: Image.asset(
                  avsar.artwork,
                  fit: BoxFit.contain,
                  // अनुपात बचाने के लिए दोनों cache dimensions न दें (→ D-057)।
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
          const SizedBox(height: VidhivatSpacing.sm),
          Text(
            avsar.naam,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: type.cardTitle.copyWith(
              color: avsar.khulta ? colors.textPrimary : colors.textTertiary,
            ),
          ),
          const SizedBox(height: VidhivatSpacing.xxs),
          Text(
            avsar.khulta ? avsar.neeche : '${avsar.neeche} · विधि अभी नहीं',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: type.caption.copyWith(color: colors.textSecondary),
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

  /// त्योहार वाले कार्डों की अगली तारीख़ (`pujaId → दिन`) — बाक़ी में ख़ाली।
  final Map<String, DateTime> tarikh;
  final DateTime? aaj;

  const _PujaGrid({
    required this.entries,
    required this.onOpen,
    this.tarikh = const {},
    this.aaj,
  });

  /// "आज" · "कल" · "8 नव"
  String? _tarikhLikha(String id) {
    final din = tarikh[id];
    final shuru = aaj;
    if (din == null || shuru == null) return null;
    final baad = DateTime.utc(din.year, din.month, din.day)
        .difference(DateTime.utc(shuru.year, shuru.month, shuru.day))
        .inDays;
    return switch (baad) {
      0 => 'आज',
      1 => 'कल',
      _ => tarikhChhoti(din),
    };
  }

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
                    tarikh: _tarikhLikha(entry.id),
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

  /// ऊपर बाएँ कोने की छोटी तारीख़ — सिर्फ़ त्योहार वाले कार्डों पर।
  final String? tarikh;

  const _PujaGridCard({
    required this.entry,
    required this.onOpen,
    this.tarikh,
  });

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
      semanticLabel: available
          ? '${entry.naam} की विधि देखें'
              '${tarikh == null ? '' : '। अगली बार: $tarikh'}'
          : '${entry.naam} जल्द आएगी',
      padding: const EdgeInsets.all(VidhivatSpacing.md),
      child: SizedBox(
        height: cardHeight,
        child: Stack(
          children: [
            Positioned.fill(child: LayoutBuilder(
              builder: (context, constraints) {
                final artworkSize =
                    (constraints.maxWidth * 0.93).clamp(84.0, 134.0).toDouble();
                final cacheSize =
                    (artworkSize * MediaQuery.devicePixelRatioOf(context))
                        .round();
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
                      entry.naam,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: type.cardTitle.copyWith(
                        color: available
                            ? colors.textPrimary
                            : colors.textTertiary,
                      ),
                    ),
                  ],
                );
              },
            )),
            if (tarikh != null)
              Positioned(
                top: 0,
                left: 0,
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
                        tarikh!,
                        style: type.caption.copyWith(color: colors.primary),
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
  final Parv navratri;
  final List<_AaneWali> aaneWali;
  final Map<String, DateTime> tyoharTarikh;
  final DateTime aaj;

  const _VidhiHomeData({
    required this.entries,
    required this.navratri,
    required this.aaneWali,
    required this.tyoharTarikh,
    required this.aaj,
  });
}
