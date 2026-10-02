import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:share_plus/share_plus.dart';

import '../state/kundali_profiles.dart';
import '../state/settings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/design_system.dart';
import '../widgets/kundali_chitra.dart';

/// "12°34′" — राशि के भीतर के अंश और कला।
String anshKala(double ansh) {
  var a = ansh.floor();
  var k = ((ansh - a) * 60).round();
  if (k == 60) {
    a += 1;
    k = 0;
  }
  return '$a°${k.toString().padLeft(2, '0')}′';
}

/// एक आदमी की कुंडली — चार पट्टियाँ: कुंडली · ग्रह · दशा · पंचांग (→ D-105)।
///
/// ## जो यहाँ नहीं है, और कभी नहीं आएगा
/// फल, राशिफल, दोष, उपाय। यह पन्ना बताता है कि आकाश कैसा था और दशा की
/// तारीख़ें क्या हैं — "उसका मतलब क्या है" नहीं। इंजन के `Kundali` में ऐसा
/// कोई खाना है ही नहीं जिसमें वह रखा जा सके।
///
/// ## दो सच जो खुले लिखे हैं (ⓘ के पीछे नहीं → D-056)
/// 1. लग्न राशि की सीमा के पास हो, तो कुछ मिनट का फ़र्क़ लग्न बदल देता है।
/// 2. दशा की तारीख़ें "ठीक इसी दिन" नहीं हैं।
class KundaliScreen extends StatefulWidget {
  final KundaliProfile profile;

  /// "अभी कौन सी दशा" के लिए — जाँच में घड़ी थामने के लिए।
  final DateTime? abhi;

  const KundaliScreen({super.key, required this.profile, this.abhi});

  @override
  State<KundaliScreen> createState() => _KundaliScreenState();
}

class _KundaliScreenState extends State<KundaliScreen> {
  late final Kundali _k;
  late final GrahaSthiti _spashtRahu;
  late final JanmPanchang _jp;
  late final List<DashaKhand> _dasha;
  KundaliAadhar _aadhar = KundaliAadhar.lagna;
  final _chitraKey = GlobalKey();
  bool _bhejRahe = false;

  KundaliProfile get _p => widget.profile;

  @override
  void initState() {
    super.initState();
    final janm = _p.janmUtc;
    final place = _p.place;
    _k = computeKundali(janm, place);
    _spashtRahu =
        computeKundali(janm, place, spashtRahu: true)[KundaliGraha.rahu];
    _jp = janmPanchang(janm, place, masaSystem: settings.masaSystem);
    _dasha = vimshottariMahadasha(janm, _k[KundaliGraha.chandra].nirayan);
  }

  /// चित्र वाला हिस्सा PNG बनाकर भेजना। PDF नहीं — Dart की PDF लाइब्रेरियाँ
  /// देवनागरी के संयुक्ताक्षर तोड़ती हैं (→ docs/29 §5)।
  Future<void> _bhejo() async {
    if (_bhejRahe) return;
    setState(() => _bhejRahe = true);
    try {
      final boundary = _chitraKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) return;
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(Uint8List.sublistView(data),
              mimeType: 'image/png', name: 'kundali.png'),
        ],
        fileNameOverrides: const ['kundali.png'],
        text: '${_p.naam} की जन्म कुंडली — विधिवत',
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('चित्र नहीं बन सका। दोबारा कोशिश करें।')),
        );
      }
    } finally {
      if (mounted) setState(() => _bhejRahe = false);
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_p.naam),
            actions: [
              VidhivatIconAction(
                icon: Icons.share_outlined,
                tooltip: 'कुंडली का चित्र भेजें',
                onPressed: _bhejRahe ? null : _bhejo,
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'कुंडली'),
                Tab(text: 'ग्रह'),
                Tab(text: 'दशा'),
                Tab(text: 'पंचांग'),
              ],
            ),
          ),
          body: SafeArea(
            child: VidhivatSacredBackdrop(
              child: TabBarView(
                children: [
                  _kundaliPatti(context),
                  _grahaPatti(context),
                  _dashaPatti(context),
                  _panchangPatti(context),
                ],
              ),
            ),
          ),
        ),
      );

  // ───────────────────────── कुंडली ─────────────────────────────

  Widget _kundaliPatti(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final lagna = _k.lagna;
    final bhag = bhavVibhag(_k, _aadhar);

    return Panna(
      children: [
        if (_k.lagnaSandhiMein()) Chetavni(_sandhiKiBaat(), serious: true),
        if (_p.yuddhKal)
          const Chetavni(
            'यह जन्म उन दिनों का है जब भारत की घड़ी एक घंटा आगे थी; ऐप ने वही '
            'माना है। काग़ज़ का समय "पुराने समय" से हो तो ब्यौरे में एक घंटा '
            'जोड़कर भरिए — नहीं तो लग्न ग़लत आएगा।',
            serious: true,
          ),
        SegmentedButton<KundaliAadhar>(
          segments: [
            for (final a in KundaliAadhar.values)
              ButtonSegment(value: a, label: Text(a.naam)),
          ],
          selected: {_aadhar},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _aadhar = s.first),
        ),
        const SizedBox(height: VidhivatSpacing.md),
        // ── यही हिस्सा चित्र बनकर भेजा जाता है ───────────────────────
        RepaintBoundary(
          key: _chitraKey,
          child: ColoredBox(
            color: colors.background,
            child: Padding(
              padding: const EdgeInsets.all(VidhivatSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_p.naam} · ${_aadhar.naam} कुंडली',
                      style: type.cardTitle),
                  const SizedBox(height: VidhivatSpacing.xxs),
                  Text(
                    '${tarikh(_p.janm)}, ${hm(_p.janm)} · ${_p.sthanNaam}',
                    style:
                        type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  Text(
                    'लग्न ${lagna.rashiNaam} ${anshKala(lagna.ansh)} · '
                    'चंद्र ${_k[KundaliGraha.chandra].rashiNaam} · '
                    '${_k[KundaliGraha.chandra].nakshatraNaam}',
                    style:
                        type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: VidhivatSpacing.sm),
                  KundaliChitra(kundali: _k, aadhar: _aadhar),
                  const SizedBox(height: VidhivatSpacing.xs),
                  Text(
                    'अंक राशि का है (१ मेष … १२ मीन) · ल = लग्न · (व) = वक्री',
                    style: type.caption.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: VidhivatSpacing.md),
        const VidhivatSectionHeader(title: 'भाव-दर-भाव'),
        const SizedBox(height: VidhivatSpacing.xs),
        for (final b in bhag)
          if (b.grahas.isNotEmpty || b.lagnaYahan)
            Pankti(
              'भाव ${b.bhav}',
              [
                if (b.lagnaYahan) 'लग्न',
                for (final g in b.grahas)
                  g.vakri ? '${g.graha.naam} (वक्री)' : g.graha.naam,
              ].join(', '),
              note: rashiNames[b.rashi],
            ),
        const SizedBox(height: VidhivatSpacing.md),
        _ganitKaButton(),
      ],
    );
  }

  /// लग्न राशि की सीमा के पास है — दूसरी राशि कौन सी हो सकती है, वह भी।
  String _sandhiKiBaat() {
    final lagna = _k.lagna;
    final doosri = lagna.ansh < 15
        ? rashiNames[(lagna.rashi + 11) % 12]
        : rashiNames[(lagna.rashi + 1) % 12];
    return 'लग्न ${lagna.rashiNaam} ${anshKala(lagna.ansh)} पर है — राशि की '
        'सीमा के बिल्कुल पास। जन्म का समय कुछ मिनट अलग हो तो लग्न $doosri भी हो '
        'सकता है, और तब सारे भाव एक-एक खिसक जाएँगे।';
  }

  Widget _ganitKaButton() => VidhivatSrotButton(
        label: 'यह गणना कैसे हुई',
        panktiyan: [
          const VidhivatSrotPankti(
            'ग्रह और लग्न',
            'सब कुछ खगोल के सूत्रों से इसी फ़ोन में निकलता है — नेटवर्क नहीं '
                'लगता। सूत्र एक अंतरिक्ष संस्था के छपे आँकड़ों से मिलाए हुए हैं: '
                'लग्न चौथाई कला के भीतर, ग्रह एक विकला के भीतर, चंद्र दस विकला '
                'के भीतर।',
          ),
          VidhivatSrotPankti(
            'अयनांश',
            'लाहिड़ी (चित्रपक्ष) — इस जन्म पर ${anshKala(_k.ayanamsa)}।',
          ),
          const VidhivatSrotPankti(
            'भाव',
            'एक राशि, एक भाव: लग्न की पूरी राशि पहला भाव, अगली राशि दूसरा। '
                'भाव-चलित यहाँ नहीं है।',
          ),
          VidhivatSrotPankti(
            'राहु और केतु',
            'औसत पात — पारंपरिक पंचांग यही देते हैं। कुछ जन्मपत्रियों में '
                '"स्पष्ट" राहु छपता है, जो इससे डेढ़ अंश तक आगे-पीछे होता है। इस '
                'जन्म पर स्पष्ट राहु लगभग ${_spashtRahu.rashiNaam} '
                '${anshKala(_spashtRahu.ansh)} पर है।',
          ),
          const VidhivatSrotPankti(
            'दशा',
            'विंशोत्तरी; साल 365.25 दिन का। कुछ पद्धतियाँ 360 दिन का साल लेती '
                'हैं — तब तारीख़ें अलग आती हैं।',
          ),
        ],
        antimBaat: 'आपकी छपी जन्मपत्री में अंश कुछ अलग हों तो ऊपर के चलन '
            'देखिए — फ़र्क़ अक्सर वहीं से आता है। फल बताना इस ऐप का काम नहीं।',
      );

  // ───────────────────────── ग्रह ─────────────────────────────

  Widget _grahaPatti(BuildContext context) => Panna(
        children: [
          _sthitiCard(
            context,
            naam: 'लग्न',
            s: _k.lagna,
            neeche: 'पूर्वी क्षितिज पर उगती राशि · पहला भाव',
          ),
          for (final g in _k.grahas)
            _sthitiCard(
              context,
              naam: g.graha.naam,
              s: g,
              vakri: g.vakri,
              neeche: 'भाव ${_k.bhav(g.graha)}'
                  '${g.graha == KundaliGraha.rahu || g.graha == KundaliGraha.ketu ? ' · औसत पात' : ''}',
            ),
          const SizedBox(height: VidhivatSpacing.sm),
          _ganitKaButton(),
        ],
      );

  Widget _sthitiCard(
    BuildContext context, {
    required String naam,
    required RashiSthiti s,
    required String neeche,
    bool vakri = false,
  }) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
      child: VidhivatSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: VidhivatSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(naam, style: type.cardTitle),
                if (vakri)
                  const VidhivatStatusChip(
                      label: 'वक्री', tone: VidhivatStatusTone.neutral),
              ],
            ),
            const SizedBox(height: VidhivatSpacing.xxs),
            Text('${s.rashiNaam} ${anshKala(s.ansh)}', style: type.bodyLarge),
            Text(
              '${s.nakshatraNaam}, चरण ${s.charan} · नवमांश ${s.navamshaNaam}',
              style: type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            Text(neeche,
                style: type.bodySmall.copyWith(color: colors.textTertiary)),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── दशा ─────────────────────────────

  String _avadhi(double saal) {
    final poore = saal.floor();
    final mahine = ((saal - poore) * 12).floor();
    return [
      if (poore > 0) '$poore साल',
      if (mahine > 0) '$mahine महीने',
      if (poore == 0 && mahine == 0) 'एक महीने से कम',
    ].join(' ');
  }

  /// दशा की तारीख़ — UTC क्षण को भारतीय तारीख़ में।
  String _din(DateTime utc) => tarikh(utc.add(bharatManakSamay));

  /// वही, छोटे महीने के साथ — अंतर्दशा की "कब से कब तक" एक पंक्ति में समाए।
  String _dinChhota(DateTime utc) {
    final d = utc.add(bharatManakSamay);
    return '${tarikhChhoti(d)} ${d.year}';
  }

  Widget _dashaPatti(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final abhi = (widget.abhi ?? DateTime.now()).toUtc();
    final chandra = _k[KundaliGraha.chandra];
    final pehli = _dasha.first;

    return Panna(
      children: [
        // ── दूसरा खुला सच ───────────────────────────────────────
        const Chetavni(
          'विंशोत्तरी दशा — सिर्फ़ तारीख़ें। जन्म-समय का एक मिनट इन्हें कई '
          'दिन खिसका देता है, इसलिए इन्हें "ठीक इसी दिन" न मानें। किस दशा में '
          'क्या होगा, यह ऐप नहीं बताता।',
        ),
        Pankti(
          'जन्म पर',
          '${pehli.swami.naam} की महादशा',
          note: 'चंद्र ${chandra.nakshatraNaam} में था · '
              '${_avadhi(janmParDashaShesh(chandra.nirayan))} बची थी',
          bold: true,
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        for (final m in _dasha)
          Padding(
            padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
            child: VidhivatSurfaceCard(
              variant: m.mein(abhi)
                  ? VidhivatCardVariant.highlight
                  : VidhivatCardVariant.standard,
              padding: EdgeInsets.zero,
              child: Theme(
                // ExpansionTile की अपनी ऊपर-नीचे की रेखाएँ नहीं चाहिए
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey('dasha-${m.swami.name}-${m.shuru}'),
                  initiallyExpanded: m.mein(abhi),
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: VidhivatSpacing.md),
                  childrenPadding:
                      const EdgeInsets.only(bottom: VidhivatSpacing.sm),
                  title: Wrap(
                    spacing: VidhivatSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${m.swami.naam} की महादशा', style: type.cardTitle),
                      if (m.mein(abhi))
                        const VidhivatStatusChip(
                            label: 'अभी', tone: VidhivatStatusTone.primary),
                    ],
                  ),
                  subtitle: Text(
                    m == pehli
                        ? 'जन्म से ${_din(m.ant)} तक'
                        : '${_din(m.shuru)} से ${_din(m.ant)} तक',
                    style:
                        type.bodySmall.copyWith(color: colors.textSecondary),
                  ),
                  children: [
                    for (final a in vimshottariAntardasha(m))
                      if (a.ant.isAfter(_p.janmUtc))
                        Pankti(
                          a.swami.naam,
                          '${_dinChhota(a.shuru.isBefore(_p.janmUtc) ? _p.janmUtc : a.shuru)} – ${_dinChhota(a.ant)}',
                          note: a.mein(abhi) ? 'अभी की अंतर्दशा' : null,
                          bold: a.mein(abhi),
                        ),
                  ],
                ),
              ),
            ),
          ),
        _ganitKaButton(),
      ],
    );
  }

  // ───────────────────────── जन्म-पंचांग ─────────────────────────

  Widget _panchangPatti(BuildContext context) {
    final chandra = _k[KundaliGraha.chandra];
    final surya = _k[KundaliGraha.surya];
    return Panna(
      children: [
        VidhivatSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
          child: Column(
            children: [
              Pankti('जन्म', '${tarikh(_p.janm)}, ${hm(_p.janm)}',
                  note: _p.sthanNaam),
              Pankti(
                'वार',
                _jp.varaName,
                note: _jp.suryodaySePehle
                    ? 'जन्म सूर्योदय से पहले हुआ — वार पिछले दिन का गिना जाता है'
                    : null,
              ),
              Pankti('तिथि', '${_jp.pakshaName} ${_jp.tithiName}'),
              Pankti('मास', _jp.masaFullName,
                  note: settings.masaSystem == MasaSystem.purnimanta
                      ? 'पूर्णिमांत'
                      : 'अमांत'),
              Pankti('संवत्', 'विक्रम ${_jp.vikramSamvat}',
                  note: '${_jp.vikramSamvatsara} · शक ${_jp.shakaSamvat}'),
              Pankti('नक्षत्र', '${_jp.nakshatraName}, चरण ${_jp.charan}'),
              Pankti('योग', _jp.yogaName),
              Pankti('करण', _jp.karanaName),
            ],
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        VidhivatSurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: VidhivatSpacing.xs),
          child: Column(
            children: [
              Pankti('जन्म राशि', chandra.rashiNaam,
                  note: 'चंद्र जिस राशि में था', bold: true),
              Pankti('सूर्य राशि', surya.rashiNaam),
              Pankti('लग्न', _k.lagna.rashiNaam),
              Pankti('सूर्योदय', hm(_jp.sunrise)),
              Pankti('सूर्यास्त', hm(_jp.sunset)),
            ],
          ),
        ),
        const SizedBox(height: VidhivatSpacing.sm),
        _ganitKaButton(),
      ],
    );
  }
}
